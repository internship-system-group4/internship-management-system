// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad (Trello card X02 - shared data model)
//  A supervisor's grade and feedback on one submission (card F05).
//  Add fields freely; never rename or delete one without telling the team.
// =============================================================================

using System.Collections.Generic;
using System.Web.Script.Serialization;
using InternshipManagementSystem.Common;

namespace InternshipManagementSystem.Models
{
    public class TaskEvaluation
    {
        public string Id { get; set; }

        public string TaskId { get; set; }
        public string SubmissionId { get; set; }
        public string PlacementId { get; set; }
        public string StudentId { get; set; }
        public string EvaluatedBySupervisorId { get; set; }

        public List<GradeComponent> Components { get; set; }

        public double TotalScore { get; set; }
        public double MaxScore { get; set; }

        /// <summary>Visible to the student - this is permitted task feedback,
        /// unlike the confidential final evaluation forms.</summary>
        public string Feedback { get; set; }

        /// <summary>Set when the supervisor asks for changes instead of
        /// grading (card F06).</summary>
        public bool RevisionRequested { get; set; }
        public string RevisionInstructions { get; set; }

        public long EvaluatedAt { get; set; }

        public TaskEvaluation()
        {
            Components = new List<GradeComponent>();
            EvaluatedAt = Time.NowMs();
        }

        [ScriptIgnore]
        public double Percentage
        {
            get { return MaxScore <= 0 ? 0 : (TotalScore / MaxScore) * 100.0; }
        }
    }
}
