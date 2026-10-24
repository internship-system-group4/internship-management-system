// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad (shared data model)
//  One requirement the coordinator verified by hand during the final
//  completion review. Stored inside completions/{placementId}/Checks/{key}.
//  Add fields freely; never rename or delete one without telling the team.
// =============================================================================

namespace InternshipManagementSystem.Models
{
    /// <summary>
    /// A checkbox alone is never evidence: Verified and Not applicable both
    /// require a written evidence reference, and every change records who made
    /// it and when.
    /// </summary>
    public class RequirementCheck
    {
        public const string Pending = "Pending";
        public const string Verified = "Verified";
        public const string NeedsCorrections = "NeedsCorrections";
        public const string NotApplicable = "NotApplicable";

        public string Key { get; set; }

        /// <summary>Pending, Verified, NeedsCorrections or NotApplicable.</summary>
        public string Status { get; set; }

        /// <summary>Where the evidence is: form number, file name, email date...</summary>
        public string Evidence { get; set; }

        public string CoordinatorId { get; set; }
        public long CheckedAt { get; set; }

        public static bool IsValidStatus(string status)
        {
            return status == Pending || status == Verified || status == NeedsCorrections || status == NotApplicable;
        }

        /// <summary>True when the requirement no longer blocks approval.</summary>
        [System.Web.Script.Serialization.ScriptIgnore]
        public bool IsSatisfied
        {
            get { return Status == Verified || Status == NotApplicable; }
        }
    }
}
