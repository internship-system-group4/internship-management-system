// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad  (Trello cards A10 - A12)
//  Final completion review: requirement checks, provisional result and the
//  coordinator's decision.
//
//  Rules (see docs/35-progress-and-completion-review.md):
//   - The numeric result uses EvaluationMethod (a PROJECT PROPOSAL). It never
//     approves anything by itself and cannot override a missing requirement.
//   - Approval needs every mandatory requirement: both final evaluations, the
//     hours or duration rule of the internship type, graded task evidence, a
//     Pass provisional result and each manual check verified with evidence.
//   - Every decision is re-validated here on the server and written with a
//     compare-and-swap, so a stale page or a second coordinator cannot approve
//     twice or overwrite a different decision.
// =============================================================================

using System;
using System.Collections.Generic;
using System.Linq;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Services
{
    /// <summary>One line of the coordinator's checklist.</summary>
    public class RequirementItem
    {
        public string Key;
        public string Title;
        public string Hint;
        public string Detail;
        public RuleSource Source;
        public bool Manual;
        public bool Mandatory = true;
        public bool Satisfied;

        /// <summary>Verified, Met, Pending, NeedsCorrections, NotApplicable, Missing.</summary>
        public string State;
        public RequirementCheck Check;
    }

    /// <summary>Everything the coordinator needs to decide on one placement.</summary>
    public class CompletionSummary
    {
        public bool CompanySubmitted;
        public bool AcademicSubmitted;
        public long ApprovedHours;
        public long PendingHours;
        public int RequiredHours;
        public int TasksTotal;
        public int TasksGraded;

        public double TaskPercent;
        public double CompanyPercent;
        public double AcademicPercent;
        public double FinalPercent;

        public string InternshipType = InternshipTypes.Local;
        public bool InternshipTypeIsDefault = true;
        public double Weeks;

        public List<RequirementItem> Items = new List<RequirementItem>();

        public bool HoursMet { get { return RequiredHours > 0 && ApprovedHours >= RequiredHours; } }
        public bool DurationMet { get { return Weeks >= InternshipRules.InternationalMinimumWeeks; } }
        public bool IsInternational { get { return InternshipType == InternshipTypes.International; } }
        public bool TrainingRequirementMet { get { return IsInternational ? DurationMet : HoursMet; } }
        public bool TasksComplete { get { return TasksTotal > 0 && TasksGraded == TasksTotal; } }
        public bool EvaluationsReady { get { return CompanySubmitted && AcademicSubmitted; } }
        public bool Passing { get { return EvaluationsReady && GradingService.IsPassing(FinalPercent); } }
        public string Result { get { return Passing ? "Pass" : "Fail"; } }

        public int MandatoryTotal { get { return Items.Count(i => i.Mandatory); } }
        public int MandatoryMet { get { return Items.Count(i => i.Mandatory && i.Satisfied); } }

        /// <summary>Every mandatory requirement is satisfied. The numeric result
        /// is one of them, never a shortcut past the others.</summary>
        public bool CanApprove { get { return Items.Count > 0 && Items.Where(i => i.Mandatory).All(i => i.Satisfied); } }
    }

    public static class CompletionService
    {
        public static CompletionSummary Summarise(PlacementProgressData progress)
        {
            CompletionSummary summary = new CompletionSummary();
            if (progress == null) return summary;

            Placement placement = progress.Overview.Placement;
            Student student = progress.Overview.Student;

            summary.InternshipType = InternshipTypes.Of(placement);
            summary.InternshipTypeIsDefault = !InternshipTypes.IsSet(placement);
            summary.Weeks = InternshipRules.Weeks(placement);

            summary.CompanySubmitted = progress.CompanyFinal != null && progress.CompanyFinal.IsSubmitted;
            summary.AcademicSubmitted = progress.AcademicFinal != null && progress.AcademicFinal.IsSubmitted;

            // Hours come from the approved entries themselves, never from a counter.
            summary.ApprovedHours = CompletionReviewService.ApprovedHours(progress.Hours, placement, Time.NowMs());
            summary.PendingHours = progress.Overview.PendingHours;
            // Never below 160: a smaller stored target cannot shorten the training.
            summary.RequiredHours = CompletionReviewService.RequiredHours(placement, student,
                progress.Completion == null ? null : progress.Completion.EvaluationRuleSnapshot);

            summary.TasksTotal = progress.Tasks.Count;
            summary.TasksGraded = progress.Tasks.Count(t => t.Status == InternshipTaskStatus.Graded);

            // The newest real grade of each task (Evaluations is newest first);
            // revision requests are not grades and ungraded tasks are left out,
            // never counted as zero.
            List<TaskEvaluation> latest = progress.Evaluations
                .Where(e => !e.RevisionRequested)
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

            BuildChecklist(summary, progress);
            return summary;
        }

        private static void BuildChecklist(CompletionSummary s, PlacementProgressData progress)
        {
            s.Items.Add(Auto(InternshipRules.KeyCompanyEvaluation, "Coordinator.Req.CompanyEvaluation", RuleSource.ProjectBrief,
                s.CompanySubmitted,
                s.CompanySubmitted ? L.F("Coordinator.Req.SubmittedOn", Time.Display(progress.CompanyFinal.SubmittedAt))
                    : progress.CompanyFinal == null ? L.T("Coordinator.Req.NotStartedByCompany") : L.T("Coordinator.Req.DraftNotSubmitted")));

            s.Items.Add(Auto(InternshipRules.KeyAcademicEvaluation, "Coordinator.Req.AcademicEvaluation", RuleSource.ProjectBrief,
                s.AcademicSubmitted,
                s.AcademicSubmitted ? L.F("Coordinator.Req.SubmittedOn", Time.Display(progress.AcademicFinal.SubmittedAt))
                    : progress.AcademicFinal == null ? L.T("Coordinator.Req.NotStartedByAcademic") : L.T("Coordinator.Req.DraftNotSubmitted")));

            if (s.IsInternational)
            {
                s.Items.Add(Auto(InternshipRules.KeyDuration, "Coordinator.Req.Duration", RuleSource.VerifiedGju, s.DurationMet,
                    s.Weeks > 0 ? L.F("Coordinator.Req.DurationDetail", s.Weeks.ToString("0.#"), InternshipRules.InternationalMinimumWeeks)
                                : L.T("Coordinator.Req.DurationUnknown")));
            }
            else
            {
                string detail = L.F("Coordinator.Req.HoursDetail", s.ApprovedHours, s.RequiredHours);
                if (s.PendingHours > 0) detail += " " + L.F("Coordinator.Req.HoursPending", s.PendingHours);
                s.Items.Add(Auto(InternshipRules.KeyHours, "Coordinator.Req.Hours", RuleSource.VerifiedGju, s.HoursMet, detail));
            }

            s.Items.Add(Auto(InternshipRules.KeyTasks, "Coordinator.Req.Tasks", RuleSource.ProjectBrief, s.TasksComplete,
                s.TasksTotal == 0 ? L.T("Coordinator.Req.NoTasks") : L.F("Coordinator.Req.TasksDetail", s.TasksGraded, s.TasksTotal)));

            s.Items.Add(Auto(InternshipRules.KeyResult, "Coordinator.Req.Result", RuleSource.ProjectProposal, s.Passing,
                s.EvaluationsReady ? L.F("Coordinator.Req.ResultDetail", s.Result, s.FinalPercent.ToString("0.##"), GradingPolicy.PassMarkPercent)
                                   : L.T("Coordinator.Req.ResultWaiting")));

            CompletionRecord record = progress.Completion;
            foreach (RequirementDefinition definition in InternshipRules.ManualChecks(s.InternshipType))
            {
                RequirementCheck check = record == null ? null : record.Check(definition.Key);
                string state = check == null || !RequirementCheck.IsValidStatus(check.Status) ? RequirementCheck.Pending : check.Status;
                s.Items.Add(new RequirementItem
                {
                    Key = definition.Key,
                    Title = L.T(definition.TitleKey),
                    Hint = L.T(definition.HintKey),
                    Source = definition.Source,
                    Manual = true,
                    Mandatory = definition.Mandatory,
                    Check = check,
                    State = state,
                    Satisfied = check != null && check.IsSatisfied && !string.IsNullOrWhiteSpace(check.Evidence),
                    Detail = check == null ? L.T("Coordinator.Req.NotVerifiedYet") : check.Evidence
                });
            }
        }

        private static RequirementItem Auto(string key, string titleKey, RuleSource source, bool met, string detail)
        {
            return new RequirementItem
            {
                Key = key, Title = L.T(titleKey), Source = source, Manual = false,
                Satisfied = met, State = met ? "Met" : "Missing", Detail = detail
            };
        }

        // ---- coordinator actions --------------------------------------------

        /// <summary>Saves the coordinator's manual verification of one
        /// requirement. Verified and Not applicable need written evidence.</summary>
        public static void SaveCheck(PlacementProgressData progress, Coordinator coordinator,
            string key, string status, string evidence)
        {
            if (progress == null || coordinator == null) throw new InvalidOperationException(L.T("Coordinator.Req.ErrorNoPlacement"));
            Placement placement = progress.Overview.Placement;
            CompletionRecord current = progress.Completion;
            if (current != null && (current.Status == CompletionStatus.Approved || current.IsRejectedFinal))
                throw new InvalidOperationException(L.T("Coordinator.Req.ErrorDecided"));

            RequirementDefinition definition = InternshipRules.FindManual(InternshipTypes.Of(placement), key);
            if (definition == null) throw new InvalidOperationException(L.T("Coordinator.Req.ErrorUnknownCheck"));
            if (!RequirementCheck.IsValidStatus(status)) throw new InvalidOperationException(L.T("Coordinator.Req.ErrorStatus"));

            evidence = Validators.Clean(evidence);
            if (evidence != null && evidence.Length > 300) evidence = evidence.Substring(0, 300);
            if ((status == RequirementCheck.Verified || status == RequirementCheck.NotApplicable || status == RequirementCheck.NeedsCorrections)
                && (evidence == null || evidence.Length < 3))
                throw new InvalidOperationException(L.F("Coordinator.Req.ErrorEvidence", L.T(definition.TitleKey)));

            CompletionRepository repository = new CompletionRepository();
            string completionId = current == null || string.IsNullOrEmpty(current.Id) ? placement.Id : current.Id;
            if (current == null) repository.EnsureFor(placement);
            repository.SaveCheck(completionId, new RequirementCheck
            {
                Key = definition.Key, Status = status, Evidence = evidence,
                CoordinatorId = coordinator.Id, CheckedAt = Time.NowMs()
            });
        }

        /// <summary>Changes the internship type while the review is still open.</summary>
        public static void SetInternshipType(PlacementProgressData progress, string type)
        {
            if (progress == null || !InternshipTypes.IsValid(type)) throw new InvalidOperationException(L.T("Coordinator.Req.ErrorType"));
            CompletionRecord current = progress.Completion;
            if (current != null && (current.Status == CompletionStatus.Approved || current.IsRejectedFinal))
                throw new InvalidOperationException(L.T("Coordinator.Req.ErrorDecided"));
            new PlacementRepository().Update(progress.Overview.Placement.Id, new Dictionary<string, object> { { "InternshipType", type } });
        }

        /// <summary>Approves completion. Re-checks every requirement on the
        /// server and writes with a compare-and-swap, so a stale page or a
        /// second click can never approve twice.</summary>
        public static CompletionRecord Approve(PlacementProgressData progress, Coordinator coordinator, string note)
        {
            CompletionSummary summary = Summarise(progress);
            if (!summary.CanApprove)
                throw new InvalidOperationException(L.T("Coordinator.Req.ErrorNotReady"));

            CompletionRecord record = Decide(progress, summary, coordinator, note,
                CompletionStatus.Approved, CompletionRecord.DecisionApproved, record2 =>
                {
                    record2.ApprovedAt = record2.DecidedAt;
                    record2.ReportFileUrl = PdfReportService.ReportUrl(record2.Id);
                    record2.CertificateFileUrl = PdfReportService.CertificateUrl(record2.Id);
                    Snapshot(record2, progress, coordinator);
                });

            // The placement update is secondary: the completion record is the
            // source of truth, so a failure here is logged, not shown as failure.
            try
            {
                new PlacementRepository().Update(progress.Overview.Placement.Id, new Dictionary<string, object>
                {
                    { "Status", (int)PlacementStatus.Completed }
                });
            }
            catch (FirebaseException ex)
            {
                System.Diagnostics.Trace.TraceError("Approved completion but could not mark placement completed: " + ex.Message);
            }
            return record;
        }

        /// <summary>Returns the completion for corrections. The student keeps
        /// working and the coordinator can review again. This is not a failure.</summary>
        public static CompletionRecord ReturnForCorrections(PlacementProgressData progress, Coordinator coordinator, string note)
        {
            if (string.IsNullOrWhiteSpace(note) || note.Trim().Length < 5)
                throw new InvalidOperationException(L.T("Coordinator.Req.ErrorCorrectionsNote"));
            return Decide(progress, Summarise(progress), coordinator, note,
                CompletionStatus.Rejected, CompletionRecord.DecisionCorrections, null);
        }

        /// <summary>A documented, final rejection. Requires a reason.</summary>
        public static CompletionRecord Reject(PlacementProgressData progress, Coordinator coordinator, string note)
        {
            if (string.IsNullOrWhiteSpace(note) || note.Trim().Length < 10)
                throw new InvalidOperationException(L.T("Coordinator.Req.ErrorRejectReason"));
            return Decide(progress, Summarise(progress), coordinator, note,
                CompletionStatus.Rejected, CompletionRecord.DecisionRejected, null);
        }

        /// <summary>Kept for compatibility with older callers: same as
        /// ReturnForCorrections.</summary>
        public static CompletionRecord Return(PlacementProgressData progress, Coordinator coordinator, string note)
        {
            return ReturnForCorrections(progress, coordinator, note);
        }

        private static CompletionRecord Decide(PlacementProgressData progress, CompletionSummary summary,
            Coordinator coordinator, string note, CompletionStatus status, string decision, Action<CompletionRecord> extra)
        {
            if (progress == null || coordinator == null) throw new InvalidOperationException(L.T("Coordinator.Req.ErrorNoPlacement"));
            Placement placement = progress.Overview.Placement;
            CompletionRepository repository = new CompletionRepository();
            string id = progress.Completion == null || string.IsNullOrEmpty(progress.Completion.Id) ? placement.Id : progress.Completion.Id;

            // Fresh read with a version tag: decisions are made on the stored
            // record, not on what the page loaded earlier.
            string etag;
            CompletionRecord stored = repository.GetVersioned(id, out etag);
            if (stored != null && stored.Status == CompletionStatus.Approved)
                throw new InvalidOperationException(L.T("Coordinator.Req.ErrorAlreadyApproved"));
            if (stored != null && stored.IsRejectedFinal)
                throw new InvalidOperationException(L.T("Coordinator.Req.ErrorAlreadyRejected"));

            // Approval must also hold for the checks as they are stored now.
            if (status == CompletionStatus.Approved)
            {
                progress.Completion = stored;
                summary = Summarise(progress);
                if (!summary.CanApprove) throw new InvalidOperationException(L.T("Coordinator.Req.ErrorNotReady"));
            }

            CompletionRecord record = stored ?? new CompletionRecord();
            record.Id = id;
            record.PlacementId = placement.Id;
            record.StudentId = placement.StudentId;
            record.CompanyEvaluationId = progress.CompanyFinal == null ? null : progress.CompanyFinal.Id;
            record.AcademicEvaluationId = progress.AcademicFinal == null ? null : progress.AcademicFinal.Id;
            record.TaskScorePercent = Round(summary.TaskPercent);
            record.CompanyScorePercent = Round(summary.CompanyPercent);
            record.AcademicScorePercent = Round(summary.AcademicPercent);
            record.FinalScore = Round(summary.FinalPercent);
            record.Result = summary.EvaluationsReady ? summary.Result : null;
            record.ApprovedHours = (int)summary.ApprovedHours;
            record.RequiredHours = summary.RequiredHours;
            record.InternshipType = summary.InternshipType;
            record.EvaluationMethod = EvaluationMethod.Id;
            record.Status = status;
            record.Decision = decision;
            record.DecidedAt = Time.NowMs();
            record.ReviewedByCoordinatorId = coordinator.Id;
            record.CoordinatorNote = string.IsNullOrWhiteSpace(note) ? null : note.Trim();
            if (record.CoordinatorNote != null && record.CoordinatorNote.Length > 1000)
                record.CoordinatorNote = record.CoordinatorNote.Substring(0, 1000);
            if (extra != null) extra(record);

            if (!repository.TrySaveDecision(record, etag))
                throw new InvalidOperationException(L.T("Coordinator.Req.ErrorChanged"));
            return record;
        }

        private static void Snapshot(CompletionRecord record, PlacementProgressData progress, Coordinator coordinator)
        {
            Placement placement = progress.Overview.Placement;
            Student student = progress.Overview.Student;
            AcademicProgram program = student == null ? null : AcademicPrograms.Find(student.Major);
            record.StudentName = progress.Overview.StudentName;
            record.StudentNumber = student == null ? null : student.StudentNumber;
            record.Program = program != null ? program.Name : (student == null ? null : student.Major);
            record.CompanyName = placement.CompanyName;
            record.OpportunityTitle = placement.OpportunityTitle;
            record.TrainingStart = placement.StartDate;
            record.TrainingEnd = placement.EndDate;
            record.CoordinatorName = coordinator.FullName;
            record.DocumentSnapshot = new CompletionDocumentSnapshot {
                StudentName = record.StudentName, StudentNumber = record.StudentNumber,
                Program = record.Program, CompanyName = record.CompanyName,
                InternshipType = record.InternshipType, StartDate = record.TrainingStart, EndDate = record.TrainingEnd
            };
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
