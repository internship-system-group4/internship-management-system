// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad  (Trello cards A10 - A12)
//  Final completion review: requirement checks, final result and the
//  coordinator's decision.
// =============================================================================

using System;
using System.Collections.Generic;
using System.Linq;
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

        public double TaskPercent;
        public double CompanyPercent;
        public double AcademicPercent;
        public double FinalPercent;

        public bool HoursMet { get { return RequiredHours > 0 && ApprovedHours >= RequiredHours; } }
        public bool EvaluationsReady { get { return CompanySubmitted && AcademicSubmitted; } }
        public bool Passing { get { return EvaluationsReady && GradingService.IsPassing(FinalPercent); } }
        public string Result { get { return Passing ? "Pass" : "Fail"; } }

        /// <summary>The university's completion gate: both final evaluations,
        /// the required approved hours and a passing result.</summary>
        public bool CanApprove { get { return EvaluationsReady && HoursMet && Passing; } }
    }

    public static class CompletionService
    {
        public static CompletionSummary Summarise(PlacementProgressData progress)
        {
            CompletionSummary summary = new CompletionSummary();
            if (progress == null) return summary;

            Placement placement = progress.Overview.Placement;
            Student student = progress.Overview.Student;

            summary.CompanySubmitted = progress.CompanyFinal != null && progress.CompanyFinal.IsSubmitted;
            summary.AcademicSubmitted = progress.AcademicFinal != null && progress.AcademicFinal.IsSubmitted;

            // Hours come from the approved entries themselves, never from a counter.
            summary.ApprovedHours = progress.Overview.ApprovedHours;
            summary.RequiredHours = placement.RequiredHours > 0 ? placement.RequiredHours
                : (student != null && student.RequiredHours > 0 ? student.RequiredHours : Constants.DefaultRequiredHours);

            summary.TasksTotal = progress.Tasks.Count;
            summary.TasksGraded = progress.Tasks.Count(t => t.Status == InternshipTaskStatus.Graded);

            // Only the newest evaluation of each task counts (Evaluations is newest first).
            List<TaskEvaluation> latest = progress.Evaluations
                .GroupBy(e => e.TaskId)
                .Select(g => g.First())
                .ToList();
            summary.TaskPercent = GradingService.TaskComponentPercent(progress.Tasks, latest);

            if (summary.CompanySubmitted)
            {
                summary.CompanyPercent = PercentOf(progress.CompanyFinal.TotalScore,
                    progress.CompanyFinal.MaxScore, progress.CompanyFinal.Components);
            }
            if (summary.AcademicSubmitted)
            {
                summary.AcademicPercent = PercentOf(progress.AcademicFinal.TotalScore,
                    progress.AcademicFinal.MaxScore, progress.AcademicFinal.Components);
            }

            summary.FinalPercent = GradingService.FinalPercent(
                summary.TaskPercent, summary.CompanyPercent, summary.AcademicPercent);
            return summary;
        }

        /// <summary>Approves completion. Checks the gate again on the server,
        /// so a stale page can never approve a placement that is not ready.</summary>
        public static CompletionRecord Approve(PlacementProgressData progress, Coordinator coordinator, string note)
        {
            CompletionSummary summary = Summarise(progress);
            if (!summary.CanApprove)
                throw new InvalidOperationException("This internship does not meet all completion requirements yet.");

            CompletionRecord record = BuildRecord(progress, summary, coordinator, note, CompletionStatus.Approved);
            record.ApprovedAt = Time.NowMs();
            record.ReportFileUrl = PdfReportService.ReportUrl(record.Id);
            record.CertificateFileUrl = PdfReportService.CertificateUrl(record.Id);

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
            if (string.IsNullOrWhiteSpace(note))
                throw new InvalidOperationException("Write a note explaining why the completion is returned.");

            CompletionSummary summary = Summarise(progress);
            CompletionRecord record = BuildRecord(progress, summary, coordinator, note, CompletionStatus.Rejected);
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
            record.Result = summary.Result;
            record.ApprovedHours = (int)summary.ApprovedHours;
            record.RequiredHours = summary.RequiredHours;
            record.Status = status;
            record.ReviewedByCoordinatorId = coordinator.Id;
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
