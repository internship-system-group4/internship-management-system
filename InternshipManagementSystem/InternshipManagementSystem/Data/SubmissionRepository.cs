// =============================================================================
//  UIMS - Group 4   |   Owner: Fatima  (Trello card F04)
//  Submission attempts, append-only (cards F04, F06, F07).
// =============================================================================

using System.Collections.Generic;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Data
{
    public class SubmissionRepository : NotifyingRepositoryBase<Submission>
    {
        protected override string Collection
        {
            get { return Constants.Paths.Submissions; }
        }

        protected override void SetId(Submission entity, string id)
        {
            entity.Id = id;
        }

        /// <summary>A new attempt tells the company supervisor ("submitted" or
        /// "resubmitted"), with a link to this exact submission.</summary>
        protected override bool SendNotice(Submission previous, Submission current)
        {
            if (previous != null) return false;
            Services.NotificationService.TaskSubmitted(current);
            return true;
        }

        public List<Submission> GetByPlacement(string placementId)
        {
            return GetWhere("PlacementId", placementId);
        }
        public List<Submission> GetByTask(string id) { return GetWhere("TaskId", id); }
        public List<Submission> GetByStudent(string id) { return GetWhere("StudentId", id); }
    }
}