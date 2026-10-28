// =============================================================================
//  UIMS - Group 4   |   Owner: Suja  (Trello card S04)
//  Training hours entries (card S04).
// =============================================================================

using System.Collections.Generic;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Data
{
    public class HoursRepository : NotifyingRepositoryBase<TrainingHoursEntry>
    {
        protected override string Collection
        {
            get { return Constants.Paths.TrainingHours; }
        }

        protected override void SetId(TrainingHoursEntry entity, string id)
        {
            entity.Id = id;
        }

        /// <summary>Reported hours tell the academic supervisor; an approval or
        /// rejection tells the student. (HoursService saves through here.)</summary>
        protected override bool SendNotice(TrainingHoursEntry previous, TrainingHoursEntry current)
        {
            if (previous == null && current.Status == HoursStatus.Reported)
            {
                Services.NotificationService.HoursReported(current);
                return true;
            }
            bool decided = current.Status == HoursStatus.Approved || current.Status == HoursStatus.Rejected;
            if (previous != null && previous.Status != current.Status && decided)
            {
                Services.NotificationService.HoursDecided(current, current.Status == HoursStatus.Approved);
                return true;
            }
            return false;
        }

        // ---- Hours earned through accepted tasks (Services/TaskHoursCredit.cs) ----
        // Lists of hours entries also contain one calculated, approved entry per
        // accepted task, so every page that totals hours includes them.

        public override List<TrainingHoursEntry> GetAll()
        {
            List<TrainingHoursEntry> list = base.GetAll();
            list.AddRange(TaskCredits(null, null));
            return list;
        }

        public override List<TrainingHoursEntry> GetWhere(string field, string value)
        {
            List<TrainingHoursEntry> list = base.GetWhere(field, value);
            if (field == "PlacementId" || field == "StudentId")
                list.AddRange(TaskCredits(field, value));
            return list;
        }

        private static List<TrainingHoursEntry> TaskCredits(string field, string value)
        {
            try
            {
                List<InternshipTask> tasks = field == null
                    ? new TaskRepository().GetAll()
                    : new TaskRepository().GetWhere(field, value);
                tasks = tasks.FindAll(t => t != null && t.CreditHours > 0);
                if (tasks.Count == 0) return new List<TrainingHoursEntry>();

                List<TaskEvaluation> evaluations = field == null
                    ? new TaskEvaluationRepository().GetAll()
                    : new TaskEvaluationRepository().GetWhere(field, value);
                List<Submission> submissions = field == null
                    ? new SubmissionRepository().GetAll()
                    : new SubmissionRepository().GetWhere(field, value);
                return Services.TaskHoursCredit.Build(tasks, submissions, evaluations);
            }
            catch (FirebaseException ex)
            {
                // The saved entries still load; only the task hours are missing.
                System.Diagnostics.Trace.TraceWarning("Task hours: " + ex.Message);
                return new List<TrainingHoursEntry>();
            }
        }

        /// <summary>Approved hours per placement (placements are keyed by the student's
        /// UID), including hours earned through accepted tasks. One read for a whole
        /// list page; returns null when the hours cannot be read, so pages fall back
        /// to the cached totals.</summary>
        public Dictionary<string, int> ApprovedTotalsByPlacement()
        {
            try
            {
                var totals = new Dictionary<string, int>();
                foreach (TrainingHoursEntry entry in GetAll())
                {
                    if (entry == null || entry.Status != HoursStatus.Approved || entry.Hours <= 0 ||
                        string.IsNullOrEmpty(entry.PlacementId)) continue;
                    int current;
                    totals.TryGetValue(entry.PlacementId, out current);
                    totals[entry.PlacementId] = current + entry.Hours;
                }
                return totals;
            }
            catch (FirebaseException) { return null; }
        }

        /// <summary>Approved hours of one placement, or <paramref name="cached"/> when
        /// the hours cannot be read.</summary>
        public int ApprovedOrCached(string placementId, int cached)
        {
            try { return SumApproved(placementId); }
            catch (FirebaseException) { return cached; }
        }

        public List<TrainingHoursEntry> GetByPlacement(string placementId)
        {
            return GetWhere("PlacementId", placementId);
        }

        public List<TrainingHoursEntry> GetByStudent(string studentId)
        {
            return GetWhere("StudentId", studentId);
        }

        /// <summary>Only Approved entries count. Reported and Rejected do not -
        /// this is the rule the requirements document calls out explicitly.</summary>
        public int SumApproved(string placementId)
        {
            int total = 0;
            foreach (TrainingHoursEntry entry in GetByPlacement(placementId))
            {
                if (entry.Status == HoursStatus.Approved) total += entry.Hours;
            }
            return total;
        }

        public int SumPending(string placementId)
        {
            int total = 0;
            foreach (TrainingHoursEntry entry in GetByPlacement(placementId))
            {
                if (entry.Status == HoursStatus.Reported) total += entry.Hours;
            }
            return total;
        }
    }
}
