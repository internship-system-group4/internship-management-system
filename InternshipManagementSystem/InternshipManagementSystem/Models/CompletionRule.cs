using System.Collections.Generic;

namespace InternshipManagementSystem.Models
{
    // Server-managed configuration. No implicit rule is selected for legacy placements.
    public class CompletionRule
    {
        public string Id { get; set; }
        public string University { get; set; }
        public string School { get; set; }
        public string[] Programs { get; set; }
        public string Course { get; set; }
        public string InternshipType { get; set; }
        public string EvaluationMethod { get; set; } // Weighted or EvidenceOnly
        public string SourceClassification { get; set; } // Official or Project-Proposed
        public string SourceUrl { get; set; }
        public double TaskWeight { get; set; }
        public double CompanyWeight { get; set; }
        public double AcademicWeight { get; set; }
        public double? PassingPercent { get; set; }
        public int RequiredHours { get; set; }
        public int RequiredDurationDays { get; set; }
        public bool RequireCurrentTaskGrades { get; set; }
        public List<CompletionRequirement> Requirements { get; set; }
    }
    public class CompletionRequirement
    {
        public string Key { get; set; }
        public string Label { get; set; }
        public string SourceClassification { get; set; }
        public string SourceUrl { get; set; }
        public bool RequiresPriorApprovalDate { get; set; }
    }
    public class RequirementVerification
    {
        public string Key { get; set; }
        public bool Confirmed { get; set; }
        public string EvidenceReference { get; set; }
        public long EvidenceDate { get; set; }
        public string CoordinatorId { get; set; }
        public long VerifiedAt { get; set; }
    }
    public class CompletionAuditEntry
    {
        public string Action { get; set; }
        public string CoordinatorId { get; set; }
        public long Timestamp { get; set; }
        public string Note { get; set; }
    }
    public class CompletionDocumentSnapshot
    {
        public string StudentName { get; set; }
        public string StudentNumber { get; set; }
        public string Program { get; set; }
        public string CompanyName { get; set; }
        public string InternshipType { get; set; }
        public long StartDate { get; set; }
        public long EndDate { get; set; }
    }
}
