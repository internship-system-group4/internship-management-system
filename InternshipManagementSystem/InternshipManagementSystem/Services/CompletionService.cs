// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad  (Trello cards A10 - A12)
//  Final completion review: requirement checks, final result and the
//  coordinator's decision.
// =============================================================================

using System;
using System.Collections.Generic;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Services
{
    /// <summary>Everything the coordinator needs to decide on one placement.</summary>
    public class CompletionSummary
    {
        public bool CompanySubmitted;
        public bool AcademicSubmitted;
        public long ApprovedHours;
        public int RequiredHours;
        public int TasksTotal;
        public int TasksGraded;
        public bool RequirementsMet;
        public string ProvisionalResult;
        public double? ProvisionalScore;

        public double TaskPercent;
        public double CompanyPercent;
        public double AcademicPercent;
        public double FinalPercent;

        public bool HoursMet { get { return RequiredHours > 0 && ApprovedHours >= RequiredHours; } }
        public bool EvaluationsReady { get { return CompanySubmitted && AcademicSubmitted; } }
        public bool Passing { get { return ProvisionalResult == "Pass"; } }
        public string Result { get { return ProvisionalResult == "Evidence complete" ? "Completed" : ProvisionalResult; } }

        /// <summary>The university's completion gate: both final evaluations,
        /// the required approved hours and a passing result.</summary>
        public bool CanApprove { get { return RequirementsMet && EvaluationsReady && HoursMet; } }
    }

    public static class CompletionService
    {
        public static CompletionSummary Summarise(PlacementProgressData progress)
        {
            CompletionSummary summary = new CompletionSummary();
            if (progress == null) return summary;

            var assessment = CompletionReviewService.Assess(Evidence(progress), Time.NowMs());
            summary.CompanySubmitted = assessment.CompanySubmitted;
            summary.AcademicSubmitted = assessment.AcademicSubmitted;
            summary.ApprovedHours = assessment.ApprovedHours;
            summary.RequiredHours = assessment.RequiredHours;
            summary.RequirementsMet = assessment.CanApprove;
            summary.ProvisionalResult = assessment.Result;
            summary.ProvisionalScore = assessment.Score;
            summary.TasksTotal = progress.Tasks.Count;
            summary.TasksGraded = assessment.CompletedTasks;
            summary.TaskPercent = assessment.TaskPercent ?? 0;
            summary.CompanyPercent = assessment.CompanyPercent ?? 0;
            summary.AcademicPercent = assessment.AcademicPercent ?? 0;
            summary.FinalPercent = assessment.Score ?? 0;
            return summary;
        }

        private static CompletionReviewEvidence Evidence(PlacementProgressData progress)
        {
            return new CompletionReviewEvidence { Placement = progress.Overview.Placement, Student = progress.Overview.Student,
                Record = progress.Completion, Rule = progress.Completion == null ? null : progress.Completion.EvaluationRuleSnapshot,
                Company = progress.CompanyFinal, Academic = progress.AcademicFinal, Tasks = progress.Tasks,
                TaskEvaluations = progress.Evaluations, Submissions = progress.Submissions, Hours = progress.Hours };
        }

        /// <summary>Approves completion. Checks the gate again on the server,
        /// so a stale page can never approve a placement that is not ready.</summary>
        public static CompletionRecord Approve(PlacementProgressData progress, Coordinator coordinator, string note)
        {
            CompletionReviewService.ValidateDecision(coordinator, Evidence(progress), CompletionStatus.Approved, note, Time.NowMs());
            CompletionSummary summary = Summarise(progress);
            if (!summary.CanApprove)
                throw new InvalidOperationException("This internship does not meet all completion requirements yet.");

            CompletionRecord record = BuildRecord(progress, summary, coordinator, note, CompletionStatus.Approved);
            record.ApprovedAt = Time.NowMs();
            record.ReportFileUrl = PdfReportService.ReportUrl(record.Id);
            record.CertificateFileUrl = PdfReportService.CertificateUrl(record.Id);
            var placement = progress.Overview.Placement;
            var student = progress.Overview.Student;
            record.DocumentSnapshot = new CompletionDocumentSnapshot { StudentName = student.FullName, StudentNumber = student.StudentNumber,
                Program = student.Major, CompanyName = placement.CompanyName, InternshipType = record.EvaluationRuleSnapshot.InternshipType,
                StartDate = placement.StartDate, EndDate = placement.EndDate };

            new CompletionRepository().Save(record.Id, record);   // also notifies the student

            new PlacementRepository().Update(progress.Overview.Placement.Id, new Dictionary<string, object>
            {
                { "Status", (int)PlacementStatus.Completed }
            });
            return record;
        }

        /// <summary>Returns the completion to the student with a reason. The
        /// coordinator can review it again later.</summary>
        public static CompletionRecord Return(PlacementProgressData progress, Coordinator coordinator, string note)
        {
            CompletionReviewService.ValidateDecision(coordinator, Evidence(progress), CompletionStatus.NeedsCorrections, note, Time.NowMs());
            if (string.IsNullOrWhiteSpace(note))
                throw new InvalidOperationException("Write a note explaining why the completion is returned.");

            CompletionSummary summary = Summarise(progress);
            CompletionRecord record = BuildRecord(progress, summary, coordinator, note, CompletionStatus.NeedsCorrections);
            record.ReportFileUrl = null; record.CertificateFileUrl = null; record.ApprovedAt = 0;
            new CompletionRepository().Save(record.Id, record);   // also notifies the student
            return record;
        }

        private static CompletionRecord BuildRecord(PlacementProgressData progress, CompletionSummary summary,
            Coordinator coordinator, string note, CompletionStatus status)
        {
            Placement placement = progress.Overview.Placement;
            if (progress.Completion != null && progress.Completion.Status == CompletionStatus.Approved)
                throw new InvalidOperationException("Completion has already been approved for this internship.");

            // One record per placement: reuse the existing key, otherwise use the placement id.
            CompletionRecord record = progress.Completion ?? new CompletionRecord();
            if (string.IsNullOrEmpty(record.Id)) record.Id = placement.Id;

            record.PlacementId = placement.Id;
            record.StudentId = placement.StudentId;
            record.CompanyEvaluationId = progress.CompanyFinal == null ? null : progress.CompanyFinal.Id;
            record.AcademicEvaluationId = progress.AcademicFinal == null ? null : progress.AcademicFinal.Id;
            record.TaskScorePercent = Round(summary.TaskPercent);
            record.CompanyScorePercent = Round(summary.CompanyPercent);
            record.AcademicScorePercent = Round(summary.AcademicPercent);
            record.FinalScore = Round(summary.FinalPercent);
            record.Result = status == CompletionStatus.Approved ? summary.Result : null;
            record.ProvisionalResult = summary.ProvisionalResult;
            record.ProvisionalScore = summary.ProvisionalScore;
            record.ApprovedHours = (int)summary.ApprovedHours;
            record.RequiredHours = summary.RequiredHours;
            record.Status = status;
            record.ReviewedByCoordinatorId = coordinator.Id;
            record.ReviewedAt = Time.NowMs();
            record.CoordinatorNote = string.IsNullOrWhiteSpace(note) ? null : note.Trim();
            return record;
        }

        /// <summary>A final evaluation as a 0-100 percentage. Uses the stored
        /// total and maximum, or the weighted criteria when no maximum is set.</summary>
        public static double PercentOf(double total, double max, List<GradeComponent> components)
        {
            double percent = max > 0 ? (total / max) * 100.0 : GradingService.PercentOf(components);
            return Math.Max(0, Math.Min(100, percent));
        }

        private static double Round(double value)
        {
            return Math.Round(value, 2);
        }
    }
}
