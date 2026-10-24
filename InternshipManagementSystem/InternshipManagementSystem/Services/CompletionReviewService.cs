using System;
using System.Collections.Generic;
using System.Linq;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Services
{
    public class CompletionReviewEvidence
    {
        public Student Student;
        public Placement Placement;
        public CompletionRecord Record;
        public CompletionRule Rule;
        public FinalCompanyEvaluation Company;
        public FinalAcademicEvaluation Academic;
        public List<InternshipTask> Tasks = new List<InternshipTask>();
        public List<TaskEvaluation> TaskEvaluations = new List<TaskEvaluation>();
        public List<Submission> Submissions = new List<Submission>();
        public List<TrainingHoursEntry> Hours = new List<TrainingHoursEntry>();
    }
    public class CompletionAssessment
    {
        public List<string> Issues = new List<string>();
        public List<string> EvaluationIssues = new List<string>();
        public int ApprovedHours;
        public int RequiredHours;
        public int CompletedTasks;
        public double? TaskPercent;
        public double? CompanyPercent;
        public double? AcademicPercent;
        public double? Score;
        public string Result;
        public bool CompanySubmitted;
        public bool AcademicSubmitted;
        public bool CanApprove { get { return Issues.Count == 0; } }
    }
    public static class CompletionReviewService
    {
        public static void RequireCoordinator(Person actor)
        {
            if (actor == null || actor.Role != UserRole.Coordinator || !actor.IsActive || string.IsNullOrEmpty(actor.Id))
                throw new UnauthorizedAccessException("Only an active coordinator can review completion.");
        }
        public static bool IsFinal(CompletionRecord record)
        { return record != null && (record.Status == CompletionStatus.Approved || record.Status == CompletionStatus.Rejected); }

        public static bool Applies(CompletionRule rule, Student student)
        {
            return rule != null && student != null && Same(rule.University, student.University) &&
                Same(rule.School, student.College) && rule.Programs != null &&
                rule.Programs.Any(p => Same(p, student.Major));
        }
        private static bool Same(string a, string b)
        { return !string.IsNullOrWhiteSpace(a) && string.Equals(a.Trim(), (b ?? "").Trim(), StringComparison.OrdinalIgnoreCase); }
        private static bool Finite(double value) { return !double.IsNaN(value) && !double.IsInfinity(value); }
        public static bool ValidScore(double score, double max)
        { return Finite(score) && Finite(max) && max > 0 && score >= 0 && score <= max; }

        // A saved profile or rule can raise the minimum, but cannot waive it.
        public static int RequiredHours(Placement placement, Student student, CompletionRule rule = null)
        {
            return Math.Max(Constants.DefaultRequiredHours, Math.Max(rule == null ? 0 : rule.RequiredHours,
                Math.Max(placement == null ? 0 : placement.RequiredHours, student == null ? 0 : student.RequiredHours)));
        }

        public static bool CountsAsApproved(TrainingHoursEntry entry, Placement placement, long now)
        {
            return entry != null && placement != null && entry.PlacementId == placement.Id &&
                entry.StudentId == placement.StudentId && entry.Status == HoursStatus.Approved && entry.Hours > 0 &&
                entry.ReviewedAt > 0 && entry.ReviewedAt <= now && !string.IsNullOrWhiteSpace(entry.ReviewedById) &&
                placement.StartDate > 0 && placement.EndDate > placement.StartDate &&
                entry.WorkDate >= placement.StartDate && entry.WorkDate <= placement.EndDate && entry.WorkDate <= now;
        }

        public static long ApprovedHours(IEnumerable<TrainingHoursEntry> entries, Placement placement, long now)
        { return entries.Where(h => CountsAsApproved(h, placement, now)).Sum(h => (long)h.Hours); }

        public static string ConfigurationIssue(CompletionRule rule, Student student)
        {
            if (rule == null) return "Select and save an applicable evaluation and training rule. No default grading policy has been applied.";
            if (!Applies(rule, student)) return "The selected rule does not match the student's university, school and academic program. Correct the profile or select another rule.";
            if (string.IsNullOrWhiteSpace(rule.Id) || string.IsNullOrWhiteSpace(rule.InternshipType) ||
                (rule.SourceClassification != "Official" && rule.SourceClassification != "Project-Proposed") ||
                (rule.SourceClassification == "Official" && !OfficialUrl(rule.SourceUrl)))
                return "The evaluation rule needs an ID, training type and valid source classification/reference.";
            if (rule.RequiredHours <= 0 && rule.RequiredDurationDays <= 0)
                return "Configure required hours or duration for this training type.";
            if (rule.Requirements == null || rule.Requirements.Count == 0 ||
                rule.Requirements.Any(r => r == null || string.IsNullOrWhiteSpace(r.Key) || string.IsNullOrWhiteSpace(r.Label) ||
                    (r.SourceClassification != "Official" && r.SourceClassification != "Project-Proposed") ||
                    (r.SourceClassification == "Official" && !OfficialUrl(r.SourceUrl))) ||
                rule.Requirements.Select(r => r.Key).Distinct().Count() != rule.Requirements.Count)
                return "Configure uniquely identified documentation, training conditions and academic approvals with their sources.";
            if (rule.EvaluationMethod == "EvidenceOnly") return null;
            if (rule.EvaluationMethod != "Weighted" || !Finite(rule.TaskWeight) || !Finite(rule.CompanyWeight) ||
                !Finite(rule.AcademicWeight) || rule.TaskWeight < 0 || rule.CompanyWeight < 0 || rule.AcademicWeight < 0 ||
                Math.Abs(rule.TaskWeight + rule.CompanyWeight + rule.AcademicWeight - 100) > .001 ||
                !rule.PassingPercent.HasValue || !Finite(rule.PassingPercent.Value) || rule.PassingPercent < 0 || rule.PassingPercent > 100)
                return "Configure a supported evaluation method, weights totalling 100 and explicit passing criteria.";
            return null;
        }
        private static bool OfficialUrl(string value)
        {
            Uri uri;
            return Uri.TryCreate(value, UriKind.Absolute, out uri) && uri.Scheme == "https" &&
                (uri.Host == "gju.edu.jo" || uri.Host.EndsWith(".gju.edu.jo", StringComparison.OrdinalIgnoreCase));
        }

        public static CompletionAssessment Assess(CompletionReviewEvidence evidence, long now)
        {
            var a = new CompletionAssessment();
            var p = evidence.Placement;
            if (p == null || evidence.Student == null || p.StudentId != evidence.Student.Id)
            { a.Issues.Add("Student and placement must exist and match."); return a; }
            a.RequiredHours = RequiredHours(p, evidence.Student, evidence.Rule);
            if (string.IsNullOrWhiteSpace(p.CompanyId) || string.IsNullOrWhiteSpace(p.CompanyName))
                a.Issues.Add("The placement must identify the training company and its name before completion can be approved.");
            string configurationIssue = ConfigurationIssue(evidence.Rule, evidence.Student);
            if (configurationIssue != null) a.EvaluationIssues.Add(configurationIssue);
            var c = evidence.Company;
            var u = evidence.Academic;
            a.CompanySubmitted = c != null && c.IsSubmitted && c.SubmittedAt > 0 && c.SubmittedAt <= now &&
                c.PlacementId == p.Id && c.StudentId == p.StudentId && c.CompanyId == p.CompanyId &&
                !string.IsNullOrEmpty(p.CompanySupervisorId) && c.SupervisorId == p.CompanySupervisorId;
            a.AcademicSubmitted = u != null && u.IsSubmitted && u.SubmittedAt > 0 && u.SubmittedAt <= now &&
                u.PlacementId == p.Id && u.StudentId == p.StudentId && !string.IsNullOrEmpty(p.AcademicSupervisorId) &&
                u.AcademicSupervisorId == p.AcademicSupervisorId;
            if (!a.CompanySubmitted) a.EvaluationIssues.Add("Company final evaluation must be submitted by the assigned company supervisor.");
            if (!a.AcademicSubmitted) a.EvaluationIssues.Add("Academic final evaluation must be submitted by the assigned academic supervisor to the coordinator.");
            if (a.CompanySubmitted && ValidScore(c.TotalScore, c.MaxScore)) a.CompanyPercent = c.TotalScore / c.MaxScore * 100;
            if (a.AcademicSubmitted && ValidScore(u.TotalScore, u.MaxScore)) a.AcademicPercent = u.TotalScore / u.MaxScore * 100;
            a.CompletedTasks = evidence.Tasks.Count(t => TaskIsGraded(t, evidence));
            if (evidence.Tasks.Count > 0 && a.CompletedTasks == evidence.Tasks.Count)
                a.TaskPercent = GradingService.TaskComponentPercent(evidence.Tasks, evidence.TaskEvaluations.Where(x =>
                    x.PlacementId == p.Id && x.StudentId == p.StudentId && x.EvaluatedBySupervisorId == p.CompanySupervisorId).ToList());
            if (configurationIssue == null)
            {
                var rule = evidence.Rule;
                if (rule.RequireCurrentTaskGrades && (evidence.Tasks.Count == 0 || a.CompletedTasks != evidence.Tasks.Count))
                    a.EvaluationIssues.Add("Project rule: every assigned task needs a current company evaluation and at least one task is required.");
                if (rule.EvaluationMethod == "Weighted")
                {
                    if (rule.TaskWeight > 0 && !a.TaskPercent.HasValue) a.EvaluationIssues.Add("Task component is incomplete.");
                    if (rule.CompanyWeight > 0 && !a.CompanyPercent.HasValue) a.EvaluationIssues.Add("Company evaluation needs a valid score on its own scale.");
                    if (rule.AcademicWeight > 0 && !a.AcademicPercent.HasValue) a.EvaluationIssues.Add("Academic evaluation needs a valid score on its own scale.");
                    if (a.EvaluationIssues.Count == 0)
                    {
                        a.Score = ((a.TaskPercent ?? 0) * rule.TaskWeight + (a.CompanyPercent ?? 0) * rule.CompanyWeight +
                            (a.AcademicPercent ?? 0) * rule.AcademicWeight) / 100;
                        a.Result = a.Score >= rule.PassingPercent ? "Pass" : "Fail";
                    }
                }
                else if (a.EvaluationIssues.Count == 0) a.Result = "Evidence complete";
            }
            a.Issues.AddRange(a.EvaluationIssues);
            if (a.Result == "Fail") a.Issues.Add("The provisional evaluation does not meet the configured passing criteria. Completion remains a separate decision.");
            if (!Enum.IsDefined(typeof(PlacementStatus), p.Status) || p.Status == PlacementStatus.Offered || p.Status == PlacementStatus.Cancelled)
                a.Issues.Add("This placement is not eligible for completion review.");
            if (p.StartDate <= 0 || p.EndDate <= p.StartDate || p.EndDate > now)
                a.Issues.Add("Training must have valid dates and have ended before completion can be approved.");
            // Hours are independently approved; task completion never adds hours.
            long hours = ApprovedHours(evidence.Hours, p, now);
            a.ApprovedHours = (int)Math.Min(int.MaxValue, hours);
            if (a.ApprovedHours < a.RequiredHours)
                a.Issues.Add("Independently approved training hours are below the required minimum of " + a.RequiredHours + ".");
            if (configurationIssue == null)
            {
                if (evidence.Rule.RequiredDurationDays > 0 &&
                    (p.EndDate - p.StartDate) / 86400000.0 + 1 < evidence.Rule.RequiredDurationDays)
                    a.Issues.Add("The recorded training period is shorter than the configured duration.");
                foreach (var requirement in evidence.Rule.Requirements)
                {
                    var matches = evidence.Record == null || evidence.Record.Verifications == null ? new List<RequirementVerification>() :
                        evidence.Record.Verifications.Where(x => x != null && x.Key == requirement.Key).ToList();
                    var v = matches.Count == 1 ? matches[0] : null;
                    if (v == null || !v.Confirmed || string.IsNullOrWhiteSpace(v.EvidenceReference) ||
                        string.IsNullOrWhiteSpace(v.CoordinatorId) || v.VerifiedAt <= 0 || v.VerifiedAt > now)
                        a.Issues.Add("Evidence verification required: " + requirement.Label);
                    else if (requirement.RequiresPriorApprovalDate && (v.EvidenceDate <= 0 || v.EvidenceDate >= p.StartDate))
                        a.Issues.Add("School approval evidence must be dated before the training start.");
                }
            }
            return a;
        }

        public static bool TaskIsGraded(InternshipTask task, CompletionReviewEvidence e)
        {
            var last = e.TaskEvaluations.Where(x => x.TaskId == task.Id && x.PlacementId == e.Placement.Id &&
                x.StudentId == e.Student.Id && x.EvaluatedBySupervisorId == e.Placement.CompanySupervisorId)
                .OrderByDescending(x => x.EvaluatedAt).FirstOrDefault();
            var submission = e.Submissions.Where(s => s.TaskId == task.Id && s.StudentId == e.Student.Id && s.PlacementId == e.Placement.Id)
                .OrderByDescending(s => s.SubmittedAt).FirstOrDefault();
            return last != null && !last.RevisionRequested && ValidScore(last.TotalScore, last.MaxScore) &&
                submission != null && last.SubmissionId == submission.Id && last.EvaluatedAt >= submission.SubmittedAt;
        }
        public static void ValidateDecision(Person actor, CompletionReviewEvidence e, CompletionStatus status, string note, long now)
        {
            RequireCoordinator(actor);
            if (e.Student == null || e.Placement == null || e.Placement.StudentId != e.Student.Id)
                throw new InvalidOperationException("Placement not found.");
            if (IsFinal(e.Record)) throw new InvalidOperationException("This review has a final decision and is read-only.");
            if (e.Placement.Status == PlacementStatus.Cancelled || e.Placement.Status == PlacementStatus.Offered)
                throw new InvalidOperationException("The placement is not eligible for this action.");
            if ((note ?? "").Length > 2000) throw new InvalidOperationException("The coordinator note must be 2,000 characters or fewer.");
            if (status != CompletionStatus.Approved && status != CompletionStatus.Rejected && status != CompletionStatus.NeedsCorrections)
                throw new InvalidOperationException("Unsupported completion action.");
            if (status != CompletionStatus.Approved && string.IsNullOrWhiteSpace(note))
                throw new InvalidOperationException("A reason is required for corrections or rejection.");
            if (status == CompletionStatus.Approved)
            {
                var assessment = Assess(e, now);
                if (!assessment.CanApprove) throw new InvalidOperationException(string.Join(" ", assessment.Issues));
            }
        }
    }
}
