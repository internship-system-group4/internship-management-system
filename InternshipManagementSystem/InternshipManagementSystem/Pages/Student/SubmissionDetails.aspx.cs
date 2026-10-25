using System;
using System.Collections.Generic;
using System.Linq;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;
using InternshipManagementSystem.Services;

namespace InternshipManagementSystem.Pages.StudentArea
{
    /// <summary>The student's own immutable task-submission attempt.</summary>
    public partial class SubmissionDetails : StudentPage
    {
        protected bool NotFound;
        protected bool LoadFailed;
        protected Submission CurrentSubmission;
        protected InternshipTask CurrentTask;
        protected string CompanyName, SubmittedDate, DeadlineDate;
        protected string StatusLabel, StatusClass, FeedbackText, ScoreText;
        protected string WorkLink, FileUrl, FileName;
        protected bool HasFeedback, HasScore, HasWorkLink, CanOpenWorkLink, HasFile;
        protected readonly List<AttemptItem> AttemptHistory = new List<AttemptItem>();
        protected readonly List<GradeComponent> Criteria = new List<GradeComponent>();

        protected void Page_Load(object sender, EventArgs e)
        {
            Response.Cache.SetCacheability(System.Web.HttpCacheability.NoCache);
            Response.Cache.SetNoStore();
            if (IsPostBack) return;
            string id = Request.QueryString["id"];
            if (!ApplicationRepository.IsValidKey(id)) { NotFound = true; return; }
            try
            {
                Submission submission = new SubmissionRepository().GetById(id);
                if (submission == null || submission.StudentId != CurrentStudent.Id) { NotFound = true; return; }
                InternshipTask task = new TaskRepository().GetById(submission.TaskId);
                Placement placement = new PlacementRepository().GetById(CurrentStudent.Id);
                if (task == null || placement == null || task.Id != submission.TaskId ||
                    task.StudentId != CurrentStudent.Id || task.PlacementId != placement.Id ||
                    submission.PlacementId != placement.Id || placement.StudentId != CurrentStudent.Id)
                { NotFound = true; return; }

                CurrentSubmission = submission;
                CurrentTask = task;
                CompanyName = string.IsNullOrWhiteSpace(placement.CompanyName) ? "—" : placement.CompanyName;
                SubmittedDate = FormatDate(submission.SubmittedAt);
                DeadlineDate = task.Deadline > 0 ? FormatDate(task.Deadline) : L.T("Student.MyTasks.NotSet");
                if (task.Criteria != null) Criteria.AddRange(task.Criteria.Where(c => c != null));

                List<TaskEvaluation> evaluations = new TaskEvaluationRepository().GetByTask(task.Id)
                    .Where(item => item != null && item.StudentId == CurrentStudent.Id && item.PlacementId == placement.Id)
                    .ToList();
                TaskEvaluation evaluation = evaluations.Where(item => item.SubmissionId == submission.Id)
                    .OrderByDescending(item => item.EvaluatedAt).FirstOrDefault();
                StatusLabel = State(submission, evaluation);
                StatusClass = evaluation == null ? "is-waiting" : evaluation.RevisionRequested ? "is-revision" : "is-reviewed";
                FeedbackText = evaluation == null ? "" :
                    (evaluation.RevisionRequested && !string.IsNullOrWhiteSpace(evaluation.RevisionInstructions)
                        ? evaluation.RevisionInstructions : evaluation.Feedback) ?? "";
                HasFeedback = evaluation != null;
                if (HasFeedback && string.IsNullOrWhiteSpace(FeedbackText))
                    FeedbackText = L.T("Student.SubmissionDetails.ReviewedNoNote");
                HasScore = evaluation != null && !evaluation.RevisionRequested && evaluation.MaxScore > 0;
                if (HasScore) ScoreText = L.F("Student.SubmissionDetails.Score", evaluation.TotalScore.ToString("0.##"), evaluation.MaxScore.ToString("0.##"));

                Uri workUri;
                HasWorkLink = Uri.TryCreate(submission.LinkUrl, UriKind.Absolute, out workUri) &&
                    (workUri.Scheme == Uri.UriSchemeHttp || workUri.Scheme == Uri.UriSchemeHttps);
                WorkLink = HasWorkLink ? submission.LinkUrl : "";
                CanOpenWorkLink = HasWorkLink && !IsRestrictedPortalLink(workUri);
                HasFile = TaskSubmissionStorage.IsSafeUrl(submission.FileUrl);
                FileUrl = HasFile ? submission.FileUrl : "";
                FileName = string.IsNullOrWhiteSpace(submission.FileName) ? L.T("Student.MyTasks.DownloadSubmittedFile") : submission.FileName;

                foreach (Submission attempt in new SubmissionRepository().GetByTask(task.Id)
                    .Where(s => s != null && s.StudentId == CurrentStudent.Id && s.PlacementId == placement.Id)
                    .OrderByDescending(s => s.AttemptNumber).ThenByDescending(s => s.SubmittedAt))
                {
                    TaskEvaluation attemptEvaluation = evaluations.Where(item => item.SubmissionId == attempt.Id)
                        .OrderByDescending(item => item.EvaluatedAt).FirstOrDefault();
                    AttemptHistory.Add(new AttemptItem {
                        Number = attempt.AttemptNumber,
                        Date = FormatDate(attempt.SubmittedAt),
                        State = State(attempt, attemptEvaluation),
                        IsCurrent = attempt.Id == submission.Id,
                        Url = "SubmissionDetails.aspx?id=" + Server.UrlEncode(attempt.Id)
                    });
                }
            }
            catch (FirebaseException ex)
            {
                System.Diagnostics.Trace.TraceError("Submission details failed: " + ex);
                LoadFailed = true;
            }
        }

        private bool IsRestrictedPortalLink(Uri uri)
        {
            if (uri.IsLoopback && !string.Equals(uri.Authority, Request.Url.Authority, StringComparison.OrdinalIgnoreCase)) return true;
            if (!string.Equals(uri.Authority, Request.Url.Authority, StringComparison.OrdinalIgnoreCase)) return false;
            string path = uri.AbsolutePath;
            return path.StartsWith("/Pages/Coordinator/", StringComparison.OrdinalIgnoreCase) ||
                path.StartsWith("/Pages/Academic/", StringComparison.OrdinalIgnoreCase) ||
                path.StartsWith("/Pages/Company/", StringComparison.OrdinalIgnoreCase) ||
                path.StartsWith("/Pages/Account/", StringComparison.OrdinalIgnoreCase);
        }

        private static string State(Submission submission, TaskEvaluation evaluation)
        {
            if (evaluation != null)
                return L.T(evaluation.RevisionRequested ? "Student.SubmissionDetails.RevisionRequested" : "Student.SubmissionDetails.Reviewed");
            if (submission.Status == SubmissionStatus.UnderReview) return L.T("Student.SubmissionDetails.UnderReview");
            return L.T(submission.AttemptNumber > 1 ? "Student.SubmissionDetails.Resubmitted" : "Student.SubmissionDetails.Submitted");
        }

        private static string FormatDate(long ms)
        {
            if (ms <= 0) return L.T("Student.MyTasks.NotSet");
            DateTimeOffset date = DateTimeOffset.FromUnixTimeMilliseconds(ms);
            try { return TimeZoneInfo.ConvertTime(date, TimeZoneInfo.FindSystemTimeZoneById("Jordan Standard Time")).ToString("dd MMM yyyy, h:mm tt"); }
            catch { return date.UtcDateTime.ToString("dd MMM yyyy, h:mm tt") + " UTC"; }
        }

        protected class AttemptItem
        {
            public int Number { get; set; }
            public string Date { get; set; }
            public string State { get; set; }
            public bool IsCurrent { get; set; }
            public string Url { get; set; }
        }
    }
}
