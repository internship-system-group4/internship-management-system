// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad (Trello card X02 - shared data model)
//  The company's confidential final evaluation (cards N08, N09).
//  Add fields freely; never rename or delete one without telling the team.
// =============================================================================

using System.Collections.Generic;
using InternshipManagementSystem.Common;

namespace InternshipManagementSystem.Models
{
    /// <summary>
    /// CONFIDENTIAL. The requirements document states the student may not view
    /// this form. Only the company supervisor who wrote it, the assigned
    /// academic supervisor, and the coordinator may read it. Enforce that in
    /// the repository and in the page, not only in the UI.
    /// </summary>
    public class FinalCompanyEvaluation
    {
        public string Id { get; set; }

        public string PlacementId { get; set; }
        public string StudentId { get; set; }
        public string CompanyId { get; set; }
        public string SupervisorId { get; set; }

        /// <summary>The university's criteria, scales and weights (card X01).</summary>
        public List<GradeComponent> Components { get; set; }

        public double TotalScore { get; set; }
        public double MaxScore { get; set; }

        public string Strengths { get; set; }
        public string AreasForImprovement { get; set; }
        public string OverallComment { get; set; }

        public string Performance { get; set; }
        public string Recommendation { get; set; }

        public int ReportedTotalHours { get; set; }

        /// <summary>False while still a draft; true once sent on to the
        /// academic supervisor (card N09).</summary>
        public bool IsSubmitted { get; set; }
        public long SubmittedAt { get; set; }
        public long CreatedAt { get; set; }

        public FinalCompanyEvaluation()
        {
            Components = new List<GradeComponent>();
            CreatedAt = Time.NowMs();
        }
    }
}
