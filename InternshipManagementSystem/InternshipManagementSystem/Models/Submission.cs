// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad (Trello card X02 - shared data model)
//  One attempt by a student at a task - never overwritten (cards F04, F06, F07).
//  Add fields freely; never rename or delete one without telling the team.
// =============================================================================

using InternshipManagementSystem.Common;

namespace InternshipManagementSystem.Models
{
    /// <summary>
    /// Every submission is a NEW record. A resubmission after a revision
    /// request must never overwrite the earlier attempt: card F07 requires the
    /// full history to stay readable, so AttemptNumber increases and old rows
    /// stay in place.
    /// </summary>
    public class Submission
    {
        public string Id { get; set; }

        public string TaskId { get; set; }
        public string PlacementId { get; set; }
        public string StudentId { get; set; }

        public int AttemptNumber { get; set; }

        public string DescriptionText { get; set; }
        public string LinkUrl { get; set; }
        public string FileUrl { get; set; }
        public string FileName { get; set; }

        /// <summary>Hours the student reports for this work. Enters the system
        /// as Reported, never as Approved.</summary>
        public int ReportedHours { get; set; }

        public SubmissionStatus Status { get; set; }
        public long SubmittedAt { get; set; }

        public Submission()
        {
            AttemptNumber = 1;
            Status = SubmissionStatus.Submitted;
            SubmittedAt = Time.NowMs();
        }
    }
}
