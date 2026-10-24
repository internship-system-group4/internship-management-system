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
