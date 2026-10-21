// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad (Trello card X02 - shared data model)
//  The coordinator's final approval and the official report (cards A10-A14).
//  Add fields freely; never rename or delete one without telling the team.
// =============================================================================

using InternshipManagementSystem.Common;

namespace InternshipManagementSystem.Models
{
    /// <summary>
    /// The last step of the whole workflow. A student is only officially
    /// finished when a coordinator sets Status = Approved here - nothing else
    /// in the system may mark an internship complete.
    /// </summary>
    public class CompletionRecord
    {
        public string Id { get; set; }

        public string PlacementId { get; set; }
        public string StudentId { get; set; }

        public string CompanyEvaluationId { get; set; }
        public string AcademicEvaluationId { get; set; }

        public double CompanyScorePercent { get; set; }
        public double AcademicScorePercent { get; set; }
        public double TaskScorePercent { get; set; }

        /// <summary>Computed by Services/GradingService.cs from the weights in
        /// docs/01-university-rules.md (card A11).</summary>
        public double FinalScore { get; set; }
        public string FinalGradeLetter { get; set; }

        public int ApprovedHours { get; set; }
        public int RequiredHours { get; set; }

        public CompletionStatus Status { get; set; }

        public string ReviewedByCoordinatorId { get; set; }
        public string CoordinatorNote { get; set; }
        public long ApprovedAt { get; set; }

        /// <summary>Set once the PDF exists (card A13). The student's download
        /// (card A16) must stay unavailable while this is null.</summary>
        public string ReportFileUrl { get; set; }
        public string CertificateFileUrl { get; set; }

        public long CreatedAt { get; set; }

        public CompletionRecord()
        {
            Status = CompletionStatus.NotReady;
            CreatedAt = Time.NowMs();
        }

        /// <summary>Gate for card A16: the student may download only after this
        /// is true.</summary>
        public bool IsReleasedToStudent()
        {
            return Status == CompletionStatus.Approved
                   && !string.IsNullOrEmpty(ReportFileUrl);
        }
    }
}
