// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad (Trello card X02 - shared data model)
//  A student's application to one opportunity (cards O01-O05).
//  Add fields freely; never rename or delete one without telling the team.
// =============================================================================

using InternshipManagementSystem.Common;

namespace InternshipManagementSystem.Models
{
    /// <summary>
    /// Named InternshipApplication, not Application: inside a Web Forms
    /// code-behind, "Application" already means Page.Application (the
    /// HttpApplicationState), and the clash produces confusing errors.
    /// </summary>
    public class InternshipApplication
    {
        public string Id { get; set; }

        public string StudentId { get; set; }
        public string StudentName { get; set; }
        public string StudentMajor { get; set; }

        public string OpportunityId { get; set; }
        public string OpportunityTitle { get; set; }
        public string CompanyId { get; set; }
        public string CompanyName { get; set; }

        public string CoverLetter { get; set; }
        public string CvUrl { get; set; }

        public ApplicationStatus Status { get; set; }

        /// <summary>Required by the requirements document whenever an
        /// application is rejected (card O05).</summary>
        public string RejectionReason { get; set; }

        public string DecidedBySupervisorId { get; set; }
        public long DecidedAt { get; set; }

        /// <summary>True only after the student actively confirms the offer -
        /// acceptance by the company is not confirmation (card O03).</summary>
        public bool IsConfirmedByStudent { get; set; }

        public long SubmittedAt { get; set; }

        public InternshipApplication()
        {
            Status = ApplicationStatus.Pending;
            SubmittedAt = Time.NowMs();
        }
    }
}
