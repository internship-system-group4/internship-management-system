// =============================================================================
//  UIMS - Group 4   |   Owner: Suja  (Trello card S04)
//  Training-hours approval (card S04).
// =============================================================================

using System.Collections.Generic;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Services
{
    /// <summary>
    /// The requirements document is explicit: "Training hours are not approved
    /// automatically simply because a task has been completed."
    ///
    /// So hours enter the system as Reported and nothing but an explicit
    /// supervisor decision through this service turns them into Approved. The
    /// cached totals on Student and Placement are recomputed from the approved
    /// entries, never incremented by hand.
    /// </summary>
    public static class HoursService
    {
        /// <summary>A student or supervisor records worked hours. Status is
        /// Reported - do not pass Approved in here.</summary>
        public static string Report(TrainingHoursEntry entry)
        {
            if (entry == null) return null;
            entry.Status = HoursStatus.Reported;
            entry.ReportedAt = Time.NowMs();
            string id = new HoursRepository().Insert(entry);
            if (!string.IsNullOrEmpty(id)) NotificationService.HoursReported(entry);
            return id;
        }

        /// <summary>Approve or reject one entry, then refresh the cached
        /// totals so every dashboard agrees.</summary>
        public static void Decide(string entryId, bool approve, string reviewerId, string note)
        {
            HoursRepository hours = new HoursRepository();
            TrainingHoursEntry entry = hours.GetById(entryId);
            if (entry == null) return;

            hours.Update(entryId, new Dictionary<string, object>
            {
                { "Status", (int)(approve ? HoursStatus.Approved : HoursStatus.Rejected) },
                { "ReviewedById", reviewerId },
                { "ReviewNote", note },
                { "ReviewedAt", Time.NowMs() }
            });

            RecomputeTotals(entry.PlacementId, entry.StudentId);
            NotificationService.HoursDecided(entry, approve);
        }

        /// <summary>Recalculates approved hours from the entries themselves.
        /// Always derive the total; never trust an incremented counter.</summary>
        public static int RecomputeTotals(string placementId, string studentId)
        {
            if (string.IsNullOrEmpty(placementId)) return 0;

            int approved = new HoursRepository().SumApproved(placementId);

            new PlacementRepository().Update(placementId, new Dictionary<string, object>
            {
                { "ApprovedHours", approved }
            });

            if (!string.IsNullOrEmpty(studentId))
            {
                new UserRepository().Update(studentId, new Dictionary<string, object>
                {
                    { "ApprovedHours", approved }
                });
            }

            return approved;
        }

        /// <summary>Gate used by the coordinator's completion review (card A12).</summary>
        public static bool MeetsRequirement(Placement placement)
        {
            return placement != null && placement.HoursRequirementMet;
        }
    }
}
