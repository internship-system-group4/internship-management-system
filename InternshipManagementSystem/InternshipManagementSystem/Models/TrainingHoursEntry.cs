// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad (Trello card X02 - shared data model)
//  Reported hours awaiting approval (card S04).
//  Add fields freely; never rename or delete one without telling the team.
// =============================================================================

using InternshipManagementSystem.Common;

namespace InternshipManagementSystem.Models
{
    /// <summary>
    /// Business rule, stated explicitly in the requirements: completing a task
    /// does NOT approve its hours. Hours arrive as Reported and a supervisor
    /// moves them to Approved. Only approved entries count toward
    /// Student.ApprovedHours.
    /// </summary>
    public class TrainingHoursEntry
    {
        public string Id { get; set; }

        public string PlacementId { get; set; }
        public string StudentId { get; set; }

        /// <summary>Set when the hours come from a specific task; null for a
        /// manual entry.</summary>
        public string TaskId { get; set; }

        public int Hours { get; set; }
        public long WorkDate { get; set; }
        public string Description { get; set; }

        public HoursStatus Status { get; set; }

        public string ReviewedById { get; set; }
        public string ReviewNote { get; set; }
        public long ReviewedAt { get; set; }

        public long ReportedAt { get; set; }

        public TrainingHoursEntry()
        {
            Status = HoursStatus.Reported;
            ReportedAt = Time.NowMs();
        }
    }
}
