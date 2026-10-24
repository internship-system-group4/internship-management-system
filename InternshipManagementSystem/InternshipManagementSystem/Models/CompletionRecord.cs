// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad (Trello card X02 - shared data model)
//  The coordinator's final approval and the official report (cards A10-A14).
//  Add fields freely; never rename or delete one without telling the team.
// =============================================================================

using System.Collections.Generic;
using System.Web.Script.Serialization;
using InternshipManagementSystem.Common;
using System.Collections.Generic;

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
        public string Result { get; set; }
        public CompletionRule EvaluationRuleSnapshot { get; set; }
        public double? ProvisionalScore { get; set; }
        public string ProvisionalResult { get; set; }
        public List<RequirementVerification> Verifications { get; set; }
        public List<CompletionAuditEntry> AuditTrail { get; set; }
        public CompletionDocumentSnapshot DocumentSnapshot { get; set; }

        public int ApprovedHours { get; set; }
        public int RequiredHours { get; set; }

        public CompletionStatus Status { get; set; }

        public string ReviewedByCoordinatorId { get; set; }
        public string CoordinatorNote { get; set; }
        public bool PriorApprovalVerified { get; set; }
        public bool TrainingConditionsVerified { get; set; }
        public bool DocumentsVerified { get; set; }
        public bool AcademicSignoffVerified { get; set; }
        public long ReviewedAt { get; set; }
        public long ApprovedAt { get; set; }

        /// <summary>Protected PDF route published after approval (card A13).
        /// The student's download stays unavailable while this is null.</summary>
        public string ReportFileUrl { get; set; }
        public string CertificateFileUrl { get; set; }

        public long CreatedAt { get; set; }

        // ---- added for the final completion review (all optional) ----------

        /// <summary>The coordinator's decision: "Approved", "Corrections" or
        /// "Rejected". Status stays Rejected for both Corrections and Rejected
        /// so older pages keep showing "not approved". A Rejected status with
        /// no Decision is a legacy "returned" record = Corrections.</summary>
        public string Decision { get; set; }
        public long DecidedAt { get; set; }

        /// <summary>Requirements the coordinator verified by hand, by key
        /// (see InternshipRules.ManualChecks).</summary>
        public Dictionary<string, RequirementCheck> Checks { get; set; }

        /// <summary>EvaluationMethod.Id used for the provisional result.</summary>
        public string EvaluationMethod { get; set; }
        public string InternshipType { get; set; }

        /// <summary>Copied at approval so the report and certificate print the
        /// same details every time, even if a profile changes later.</summary>
        public string StudentName { get; set; }
        public string StudentNumber { get; set; }
        public string Program { get; set; }
        public string CompanyName { get; set; }
        public string OpportunityTitle { get; set; }
        public long TrainingStart { get; set; }
        public long TrainingEnd { get; set; }
        public string CoordinatorName { get; set; }

        public const string DecisionApproved = "Approved";
        public const string DecisionCorrections = "Corrections";
        public const string DecisionRejected = "Rejected";

        /// <summary>Returned to the student to fix something; can be reviewed again.</summary>
        [ScriptIgnore]
        public bool NeedsCorrections
        {
            get { return Status == CompletionStatus.Rejected && Decision != DecisionRejected; }
        }

        /// <summary>A documented, final rejection.</summary>
        [ScriptIgnore]
        public bool IsRejectedFinal
        {
            get { return Status == CompletionStatus.Rejected && Decision == DecisionRejected; }
        }

        public RequirementCheck Check(string key)
        {
            RequirementCheck check;
            return Checks != null && key != null && Checks.TryGetValue(key, out check) ? check : null;
        }

        public CompletionRecord()
        {
            Status = CompletionStatus.NotReady;
            CreatedAt = Time.NowMs();
            Verifications = new List<RequirementVerification>();
            AuditTrail = new List<CompletionAuditEntry>();
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
