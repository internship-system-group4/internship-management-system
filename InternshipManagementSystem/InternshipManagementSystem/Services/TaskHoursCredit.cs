// =============================================================================
//  UIMS - Group 4
//  Training hours earned through tasks.
//
//  Every task has a weight in training hours (InternshipTask.CreditHours), set
//  by the company supervisor when assigning it. When the supervisor ACCEPTS the
//  submitted work (a grade, not a revision request), those hours count as
//  approved training hours. This is an explicit supervisor decision, so hours
//  are still never approved just because a task was submitted.
//
//  The hours are worked out from the accepted review instead of being written
//  as separate records: HoursRepository adds one approved entry per accepted
//  task, so every page that counts hours (progress, dashboards, the
//  coordinator's final review) includes them automatically, and nothing breaks
//  if Firebase does not let a company supervisor write training-hours records.
// =============================================================================

using System.Collections.Generic;
using System.Linq;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Services
{
    public static class TaskHoursCredit
    {
        /// <summary>Ids of the calculated entries start with this, so they are never
        /// mistaken for saved records (they cannot be edited or reviewed).</summary>
        public const string IdPrefix = "task-credit-";

        public static bool IsCredit(TrainingHoursEntry entry)
        {
            return entry != null && entry.Id != null && entry.Id.StartsWith(IdPrefix, System.StringComparison.Ordinal);
        }

        /// <summary>One approved hours entry for each task whose newest review
        /// accepted the work. Tasks waiting for review or sent back for a
        /// revision earn nothing yet.</summary>
        public static List<TrainingHoursEntry> Build(IEnumerable<InternshipTask> tasks,
            IEnumerable<Submission> submissions, IEnumerable<TaskEvaluation> evaluations)
        {
            var result = new List<TrainingHoursEntry>();
            if (tasks == null || evaluations == null) return result;

            var submissionById = (submissions ?? Enumerable.Empty<Submission>())
                .Where(s => s != null && !string.IsNullOrEmpty(s.Id))
                .GroupBy(s => s.Id)
                .ToDictionary(g => g.Key, g => g.First());

            var newestReview = evaluations
                .Where(e => e != null && !string.IsNullOrEmpty(e.TaskId))
                .GroupBy(e => e.TaskId)
                .ToDictionary(g => g.Key, g => g.OrderByDescending(e => e.EvaluatedAt).First());

            foreach (InternshipTask task in tasks)
            {
                if (task == null || string.IsNullOrEmpty(task.Id) || task.CreditHours <= 0) continue;

                TaskEvaluation review;
                if (!newestReview.TryGetValue(task.Id, out review) || review.RevisionRequested) continue;
                if (review.StudentId != task.StudentId || review.PlacementId != task.PlacementId) continue;

                // The work date is when the student handed the work in.
                Submission submission;
                long workDate = submissionById.TryGetValue(review.SubmissionId ?? "", out submission) && submission.SubmittedAt > 0
                    ? submission.SubmittedAt
                    : review.EvaluatedAt;

                result.Add(new TrainingHoursEntry
                {
                    Id = IdPrefix + task.Id,
                    PlacementId = task.PlacementId,
                    StudentId = task.StudentId,
                    TaskId = task.Id,
                    Hours = task.CreditHours,
                    WorkDate = workDate,
                    Description = L.F("Shared.TaskHours.EntryDescription", task.Title),
                    Status = HoursStatus.Approved,
                    ReviewedById = review.EvaluatedBySupervisorId,
                    ReviewNote = L.T("Shared.TaskHours.EntryNote"),
                    ReviewedAt = review.EvaluatedAt,
                    ReportedAt = workDate
                });
            }
            return result;
        }
    }
}
