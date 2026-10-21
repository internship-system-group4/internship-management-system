// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad (Trello card X02 - shared data model)
//  One weighted line of any evaluation (cards A11, F01, N08, S05).
//  Add fields freely; never rename or delete one without telling the team.
// =============================================================================

using System.Web.Script.Serialization;

namespace InternshipManagementSystem.Models
{
    /// <summary>
    /// The reusable building block of every evaluation in the system. The
    /// requirements document forbids assuming everything is scored out of 100,
    /// so a component carries its own MaxScore and its own Weight, and the
    /// final grade is computed from them in Services/GradingService.cs.
    /// </summary>
    public class GradeComponent
    {
        public string Name { get; set; }
        public string Description { get; set; }

        public double Score { get; set; }
        public double MaxScore { get; set; }

        /// <summary>Share of the parent evaluation, as a percentage.</summary>
        public double Weight { get; set; }

        public string Comment { get; set; }

        public GradeComponent()
        {
            MaxScore = 100;
            Weight = 0;
        }

        /// <summary>Score as a 0-1 fraction of MaxScore.</summary>
        [ScriptIgnore]
        public double Ratio
        {
            get { return MaxScore <= 0 ? 0 : Score / MaxScore; }
        }

        /// <summary>This component's contribution to the parent total.</summary>
        [ScriptIgnore]
        public double WeightedPoints
        {
            get { return Ratio * Weight; }
        }
    }
}
