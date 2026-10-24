using System;
using System.Collections.Generic;
using System.Linq;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Services
{
    public static class TaskWorkflowService
    {
        // Serializes browser retries in this application instance. Firebase performs
        // each submission/review and its status changes as one multi-path write.
        private static readonly object gate = new object();

        public static List<Placement> CompanyPlacements()
        {
            var actor = SessionHelper.Current as CompanySupervisor;
            if (actor == null || !actor.IsActive) throw new UnauthorizedAccessException();
            return new PlacementRepository().GetByCompany(actor.CompanyId)
                .Where(p => p.CompanySupervisorId == actor.Id && p.Status != PlacementStatus.Cancelled).ToList();
        }

        private static Placement Authorize(string id, bool company)
        {
            var actor = SessionHelper.Current;
            var p = new PlacementRepository().GetById(id);
            var supervisor = actor as CompanySupervisor;
            if (actor == null || !actor.IsActive || p == null ||
                (company ? supervisor == null || p.CompanySupervisorId != actor.Id || p.CompanyId != supervisor.CompanyId
                    : actor.Role != UserRole.Student || p.StudentId != actor.Id))
                throw new UnauthorizedAccessException("You are not assigned to this internship.");
            if (p.Status == PlacementStatus.Completed || p.Status == PlacementStatus.Cancelled ||
                CompletionReviewService.IsFinal(new CompletionRepository().GetByPlacement(p.Id)))
                throw new InvalidOperationException("This internship is finalized; its tasks are read-only.");
            return p;
        }

        public static string Assign(InternshipTask task)
        {
            if (task == null) throw new InvalidOperationException("Enter task details.");
            var p = Authorize(task.PlacementId, true);
            if (string.IsNullOrWhiteSpace(task.Title) || task.Title.Length > 160 ||
                string.IsNullOrWhiteSpace(task.Description) || task.Description.Length > 8000 ||
                (task.Instructions ?? "").Length > 8000 || task.Deadline <= Time.NowMs() ||
                !CompletionReviewService.ValidScore(0, task.MaxScore) || !Finite(task.Weight) || task.Weight <= 0 ||
                task.Criteria == null || task.Criteria.Count == 0 || task.Criteria.Count > 20 ||
                task.Criteria.Any(c => string.IsNullOrWhiteSpace(c.Name) || c.Name.Length > 200 || !Finite(c.MaxScore) || c.MaxScore <= 0 || !Finite(c.Weight) || c.Weight <= 0) ||
                Math.Abs(task.Criteria.Sum(c => c.Weight) - 100) > 0.01)
                throw new InvalidOperationException("Enter a title, description, future deadline, positive task weight, and criteria whose weights total 100%.");
            task.StudentId = p.StudentId; task.CompanyId = p.CompanyId;
            task.CreatedBySupervisorId = SessionHelper.Current.Id;
            task.Status = InternshipTaskStatus.Assigned;
            return new TaskRepository().Insert(task);
        }

        public static string Submit(string taskId, string description, string link)
        {
            lock (gate)
            {
                var task = new TaskRepository().GetById(taskId);
                if (task == null) throw new InvalidOperationException("Task no longer exists.");
                var p = Authorize(task.PlacementId, false);
                if (task.StudentId != p.StudentId || !task.AcceptsSubmission)
                    throw new InvalidOperationException("This task is not awaiting a submission. Refresh the page.");
                if (string.IsNullOrWhiteSpace(description) && string.IsNullOrWhiteSpace(link) || (description ?? "").Length > 8000 || (link ?? "").Length > 2000 || !SafeLink(link))
                    throw new InvalidOperationException("Enter a work description and, optionally, a valid HTTPS or HTTP work/file link.");
                if (task.RequiresFileUpload && string.IsNullOrWhiteSpace(link))
                    throw new InvalidOperationException("This task requires a file link.");
                var attempts = new SubmissionRepository().GetByPlacement(p.Id).Where(s => s.TaskId == task.Id).ToList();
                var submission = new Submission { Id = Guid.NewGuid().ToString("N"), TaskId = task.Id,
                    StudentId = p.StudentId, PlacementId = p.Id, DescriptionText = (description ?? "").Trim(), LinkUrl = (link ?? "").Trim(),
                    AttemptNumber = attempts.Count == 0 ? 1 : attempts.Max(s => s.AttemptNumber) + 1 };
                FirebaseContext.Patch("", new Dictionary<string, object> {
                    { "submissions/" + submission.Id, submission },
                    { "tasks/" + task.Id + "/Status", (int)(attempts.Count == 0 ? InternshipTaskStatus.Submitted : InternshipTaskStatus.Resubmitted) }
                });
                EmailNotificationService.Saved(null, submission);
                return submission.Id;
            }
        }

        public static void Review(string submissionId, bool revision, List<double> scores, string feedback)
        {
            lock (gate)
            {
                var submission = new SubmissionRepository().GetById(submissionId);
                if (submission == null) throw new InvalidOperationException("Submission no longer exists.");
                var p = Authorize(submission.PlacementId, true);
                var task = new TaskRepository().GetById(submission.TaskId);
                var latest = new SubmissionRepository().GetByPlacement(p.Id).Where(s => s.TaskId == submission.TaskId)
                    .OrderByDescending(s => s.AttemptNumber).FirstOrDefault();
                if (task == null || task.PlacementId != p.Id || task.StudentId != p.StudentId || submission.StudentId != p.StudentId ||
                    latest == null || latest.Id != submission.Id || submission.Status == SubmissionStatus.Accepted || submission.Status == SubmissionStatus.RevisionRequested ||
                    new EvaluationRepository().GetTaskEvaluationsForPlacement(p.Id).Any(e => e.SubmissionId == submission.Id))
                    throw new InvalidOperationException("Only the latest unreviewed attempt can be reviewed. Refresh the page.");
                if ((feedback ?? "").Length > 8000 || revision && string.IsNullOrWhiteSpace(feedback))
                    throw new InvalidOperationException("Enter revision instructions (up to 8000 characters).");
                var criteria = task.Criteria ?? new List<GradeComponent>();
                if (!revision && (criteria.Count == 0 || scores == null || scores.Count != criteria.Count ||
                    scores.Where((s, i) => !CompletionReviewService.ValidScore(s, criteria[i].MaxScore)).Any()))
                    throw new InvalidOperationException("Enter a valid mark for every criterion.");
                var evaluation = new TaskEvaluation { Id = Guid.NewGuid().ToString("N"), TaskId = task.Id, SubmissionId = submission.Id,
                    StudentId = p.StudentId, PlacementId = p.Id, EvaluatedBySupervisorId = SessionHelper.Current.Id,
                    MaxScore = task.MaxScore, TotalScore = revision ? 0 : criteria.Select((c, i) => scores[i] / c.MaxScore * c.Weight).Sum() * task.MaxScore / 100, Feedback = feedback,
                    RevisionRequested = revision, RevisionInstructions = revision ? feedback : null,
                    Components = criteria.Select((c, i) => new GradeComponent { Name = c.Name, MaxScore = c.MaxScore,
                        Weight = c.Weight, Score = revision ? 0 : scores[i] }).ToList() };
                FirebaseContext.Patch("", new Dictionary<string, object> {
                    { "taskEvaluations/" + evaluation.Id, evaluation },
                    { "submissions/" + submission.Id + "/Status", (int)(revision ? SubmissionStatus.RevisionRequested : SubmissionStatus.Accepted) },
                    { "tasks/" + task.Id + "/Status", (int)(revision ? InternshipTaskStatus.RevisionRequested : InternshipTaskStatus.Graded) }
                });
                EmailNotificationService.Saved(null, evaluation);
            }
        }

        public static bool SafeLink(string value)
        {
            if (string.IsNullOrWhiteSpace(value)) return true;
            Uri uri;
            return Uri.TryCreate(value.Trim(), UriKind.Absolute, out uri) &&
                (uri.Scheme == Uri.UriSchemeHttps || uri.Scheme == Uri.UriSchemeHttp) && string.IsNullOrEmpty(uri.UserInfo);
        }
        private static bool Finite(double number) { return !double.IsNaN(number) && !double.IsInfinity(number); }
    }
}
