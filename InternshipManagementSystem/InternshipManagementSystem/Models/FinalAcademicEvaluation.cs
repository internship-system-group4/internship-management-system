// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad (Trello card X02 - shared data model)
//  The academic supervisor's confidential final evaluation (cards S05, S06).
//  Add fields freely; never rename or delete one without telling the team.
// =============================================================================

using System.Collections.Generic;
using InternshipManagementSystem.Common;

namespace InternshipManagementSystem.Models
{
    /// <summary>
    /// CONFIDENTIAL - same rule as FinalCompanyEvaluation. The student never
    /// sees this form; they see only their final result once the coordinator
    /// approves completion.
    /// </summary>
    public class FinalAcademicEvaluation
    {
        public string Id { get; set; }

        public string PlacementId { get; set; }
        public string StudentId { get; set; }
        public string AcademicSupervisorId { get; set; }

        public List<GradeComponent> Components { get; set; }

        public double TotalScore { get; set; }
        public double MaxScore { get; set; }

        public string AcademicComments { get; set; }

        /// <summary>The academic supervisor's reading of the company's
        /// evaluation, which they receive via card N09.</summary>
        public string CompanyEvaluationRemarks { get; set; }

        public bool IsSubmitted { get; set; }
        public long SubmittedAt { get; set; }
        public long CreatedAt { get; set; }

        public FinalAcademicEvaluation()
        {
            Components = new List<GradeComponent>();
            CreatedAt = Time.NowMs();
        }
    }
}
