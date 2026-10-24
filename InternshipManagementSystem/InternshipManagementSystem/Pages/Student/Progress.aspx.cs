// =============================================================================
//  My Progress & Evaluation
//  Owner : Ahmad
//  Cards : A15, A16
//
//  The student's internship journey, task grades and supervisor feedback,
//  submission and revision history, APPROVED training hours, the requirement
//  and document status, and the released result and report download once the
//  coordinator approves.
//
//  Confidentiality: the two final evaluation forms (company and academic) are
//  never read here (Firebase rules also block students from them). Only
//  TaskEvaluation records and the CompletionRecord are used, and the final
//  result is shown only after coordinator approval.
//
//  Namespace note: these page namespaces end in "Area" on purpose. A namespace
//  called ...Pages.Student would hide the Student model class and every file in
//  the folder would fail to compile with "Student is a namespace but is used
//  like a type". Keep the suffix.
// =============================================================================
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Services;

namespace InternshipManagementSystem.Pages.StudentArea
{
    public partial class Progress : InternshipManagementSystem.Security.StudentPage
    {
        // ---- view model read by the markup -----------------------------------
        protected bool LoadFailed;
        protected string LoadErrorDetail;
        protected readonly List<string> Problems = new List<string>();
        protected bool HasPlacement;

        protected Placement Placement;
        protected CompletionRecord Completion;
        protected string InternshipType = InternshipTypes.Local;
        protected bool TypeIsDefault = true;
        protected AcademicProgram Program;
        protected string AcademicSupervisorName = "—";

        protected int ApprovedHours, PendingHours, RejectedHours, RequiredHours, HoursPercent;
        protected double Weeks;
        protected int TasksTotal, TasksGraded, OpenRevisions;
        protected string AverageText = "—";

        protected List<TaskRow> Tasks = new List<TaskRow>();
        protected List<AttemptRow> Attempts = new List<AttemptRow>();
        protected List<HoursRow> HoursLog = new List<HoursRow>();
        protected List<JourneyStep> Journey = new List<JourneyStep>();
        protected List<DocItem> Docs = new List<DocItem>();

        protected bool Released;
        protected string ReportUrl;
        protected string ReportDownloadUrl;

        protected bool IsInternational { get { return InternshipType == InternshipTypes.International; } }
        protected bool TrainingMet { get { return IsInternational ? Weeks >= InternshipRules.InternationalMinimumWeeks : RequiredHours > 0 && ApprovedHours >= RequiredHours; } }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;
            try
            {
                LoadPage();
            }
            catch (FirebaseException ex)
            {
                System.Diagnostics.Trace.TraceError("Progress page failed: " + ex.Message);
                LoadFailed = true;
                // Show the real Firebase error only when running on this machine.
                if (Request.IsLocal) LoadErrorDetail = ex.Message;
            }
        }

        /// <summary>
        /// Runs a filtered Firebase query. If the database has no .indexOn rule
        /// for that field ("Index not defined"), reads the whole collection and
        /// filters it here instead. Any other failure is recorded and an empty
        /// list is returned so one section cannot break the whole page.
        /// </summary>
        private List<T> LoadSafely<T>(string section, Func<List<T>> query,
            Func<List<T>> readAll, Func<T, bool> isMine)
        {
            try
            {
                return query();
            }
            catch (FirebaseException ex)
            {
                if (ex.Message.IndexOf("Index not defined", StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    System.Diagnostics.Trace.TraceWarning("Missing Firebase index for " + section + "; filtering in code.");
                    try
                    {
                        return readAll().Where(isMine).ToList();
                    }
                    catch (FirebaseException fallbackError)
                    {
                        ex = fallbackError;
                    }
                }

                System.Diagnostics.Trace.TraceError("Progress page could not load " + section + ": " + ex.Message);
                Problems.Add(Request.IsLocal ? section + " — " + ex.Message : section);
                return new List<T>();
            }
        }

        private void LoadPage()
        {
            Student student = CurrentStudent;

            // Speed: the six reads this page needs run at the same time.
            FirebaseContext.Prefetch(
                FirebaseRead.Node(Constants.Paths.Placements + "/" + student.Id),
                FirebaseRead.Where(Constants.Paths.Tasks, "StudentId", student.Id),
                FirebaseRead.Where(Constants.Paths.TaskEvaluations, "StudentId", student.Id),
                FirebaseRead.Where(Constants.Paths.Submissions, "StudentId", student.Id),
                FirebaseRead.Where(Constants.Paths.TrainingHours, "StudentId", student.Id),
                FirebaseRead.Where(Constants.Paths.Completions, "StudentId", student.Id));

            Placement placement = new PlacementRepository().GetById(student.Id);
            if (placement == null || placement.StudentId != student.Id) return;
            HasPlacement = true;
            Placement = placement;

            string id = student.Id;

            TaskRepository taskRepo = new TaskRepository();
            List<InternshipTask> tasks = LoadSafely(L.T("Student.Progress.SectionTasks"),
                    () => taskRepo.GetByStudent(id), taskRepo.GetAll, t => t.StudentId == id)
                .Where(t => t.PlacementId == placement.Id)
                .ToList();

            // Match evaluations by the student's own task IDs.
            HashSet<string> taskIds = new HashSet<string>(tasks.Where(t => t.Id != null).Select(t => t.Id));
            EvaluationRepository evaluationRepo = new EvaluationRepository();
            List<TaskEvaluation> evaluations = LoadSafely(L.T("Student.Progress.TaskEvaluations"),
                    () => evaluationRepo.GetTaskEvaluationsForStudent(id),
                    evaluationRepo.GetAllTaskEvaluations, ev => ev.StudentId == id)
                .Where(ev => ev.TaskId != null && taskIds.Contains(ev.TaskId))
                .ToList();

            SubmissionRepository submissionRepo = new SubmissionRepository();
            List<Submission> submissions = LoadSafely(L.T("Student.Progress.SectionSubmissions"),
                    () => submissionRepo.GetWhere("StudentId", id), submissionRepo.GetAll, s => s.StudentId == id)
                .Where(s => s.PlacementId == placement.Id)
                .ToList();

            HoursRepository hoursRepo = new HoursRepository();
            List<TrainingHoursEntry> hours = LoadSafely(L.T("Student.Progress.TrainingHours2"),
                    () => hoursRepo.GetByStudent(id), hoursRepo.GetAll, h => h.StudentId == id)
                .Where(h => h.PlacementId == placement.Id)
                .ToList();

            CompletionRepository completionRepo = new CompletionRepository();
            Completion = LoadSafely(L.T("Student.Progress.CompletionStatus"),
                    () => completionRepo.GetWhere("StudentId", id), completionRepo.GetAll, c => c.StudentId == id)
                .Where(c => c.PlacementId == placement.Id)
                .OrderByDescending(c => c.ApprovedAt).ThenByDescending(c => c.CreatedAt)
                .FirstOrDefault();

            InternshipType = InternshipTypes.Of(placement);
            TypeIsDefault = !InternshipTypes.IsSet(placement);
            Program = AcademicPrograms.Find(student.Major);
            Weeks = InternshipRules.Weeks(placement);
            AcademicSupervisorName = SupervisorName(placement.AcademicSupervisorId);

            List<TaskEvaluation> latestGrades = BuildTasks(tasks, evaluations, submissions);
            BuildAttempts(tasks, evaluations, submissions);
            BuildHours(placement, student, hours);
            BuildSummary(tasks, latestGrades);
            BuildRelease(student);
            BuildDocs();
            BuildJourney(tasks);
        }

        // ---- tasks -------------------------------------------------------------
        /// <summary>Fills the task rows and returns the latest real grade of
        /// each task (revision requests are not grades).</summary>
        private List<TaskEvaluation> BuildTasks(List<InternshipTask> tasks,
            List<TaskEvaluation> evaluations, List<Submission> submissions)
        {
            List<TaskEvaluation> latestGrades = new List<TaskEvaluation>();
            foreach (InternshipTask task in tasks.OrderBy(t => t.Deadline <= 0 ? long.MaxValue : t.Deadline))
            {
                List<TaskEvaluation> taskEvaluations = evaluations
                    .Where(ev => ev.TaskId == task.Id)
                    .OrderByDescending(ev => ev.EvaluatedAt)
                    .ToList();

                TaskEvaluation latest = taskEvaluations.FirstOrDefault();
                TaskEvaluation latestGrade = taskEvaluations.FirstOrDefault(ev => !ev.RevisionRequested);
                if (latestGrade != null) latestGrades.Add(latestGrade);

                TaskRow row = new TaskRow();
                row.Title = TextOrDash(task.Title);
                row.Deadline = Time.DisplayDate(task.Deadline);
                row.DueText = DueText(task);
                row.DueCss = task.IsOverdue ? "is-overdue" : DueSoon(task) ? "is-soon" : "";
                row.Status = L.Value("TaskStatus", task.Status);
                row.StatusCss = StatusCss(task.Status);
                row.Attempts = submissions.Count(s => s.TaskId == task.Id);

                if (latestGrade != null)
                {
                    double max = latestGrade.MaxScore > 0 ? latestGrade.MaxScore : task.MaxScore;
                    row.Grade = Number(latestGrade.TotalScore) + " / " + Number(max);
                    row.GradePercent = max > 0 ? (latestGrade.TotalScore / max * 100).ToString("0", CultureInfo.InvariantCulture) + "%" : "";
                    row.Criteria = latestGrade.Components == null ? new List<string>()
                        : latestGrade.Components.Select(c => TextOrDash(c.Name) + " " + Number(c.Score) + "/" + Number(c.MaxScore)).ToList();
                }
                else
                {
                    row.Grade = L.T("Student.Progress.NotGradedYet");
                    row.Scale = task.MaxScore > 0 ? L.F("Student.Progress.GradedOutOf", Number(task.MaxScore)) : "";
                    row.Criteria = new List<string>();
                }

                if (latest != null && latest.RevisionRequested)
                {
                    row.IsRevision = true;
                    row.Feedback = TextOrDash(latest.RevisionInstructions);
                    if (!string.IsNullOrWhiteSpace(latest.Feedback)) row.Feedback += " — " + latest.Feedback;
                }
                else if (latest != null && !string.IsNullOrWhiteSpace(latest.Feedback))
                {
                    row.Feedback = latest.Feedback;
                }

                Tasks.Add(row);
            }
            return latestGrades;
        }

        // ---- submission and revision history (every attempt is kept) -----------
        private void BuildAttempts(List<InternshipTask> tasks,
            List<TaskEvaluation> evaluations, List<Submission> submissions)
        {
            Dictionary<string, InternshipTask> byId = tasks.Where(t => !string.IsNullOrEmpty(t.Id)).ToDictionary(t => t.Id);
            foreach (Submission submission in submissions.OrderByDescending(s => s.SubmittedAt))
            {
                InternshipTask task;
                byId.TryGetValue(submission.TaskId ?? "", out task);
                AttemptRow row = new AttemptRow();
                row.TaskTitle = task == null ? "—" : TextOrDash(task.Title);
                row.Attempt = submission.AttemptNumber;
                row.SubmittedAt = Time.Display(submission.SubmittedAt);

                TaskEvaluation evaluation = evaluations
                    .Where(ev => ev.SubmissionId == submission.Id)
                    .OrderByDescending(ev => ev.EvaluatedAt)
                    .FirstOrDefault();

                if (evaluation == null)
                {
                    row.Outcome = L.T("Student.Progress.AwaitingReview");
                    row.Tone = "pending";
                }
                else if (evaluation.RevisionRequested)
                {
                    row.Outcome = L.T("Student.Progress.RevisionRequested");
                    row.Tone = "attention";
                    row.Details = TextOrDash(evaluation.RevisionInstructions);
                    row.Feedback = evaluation.Feedback;
                }
                else
                {
                    row.Outcome = L.T("Student.Progress.Graded");
                    row.Tone = "done";
                    double max = evaluation.MaxScore > 0 ? evaluation.MaxScore : (task == null ? 0 : task.MaxScore);
                    row.Details = L.F("Student.Progress.GradeValue", Number(evaluation.TotalScore), Number(max));
                    row.Feedback = evaluation.Feedback;
                }
                Attempts.Add(row);
            }
        }

        // ---- training hours: only Approved entries count -----------------------
        private void BuildHours(Placement placement, Student student, List<TrainingHoursEntry> hours)
        {
            ApprovedHours = hours.Where(h => h.Status == HoursStatus.Approved && h.Hours > 0).Sum(h => h.Hours);
            PendingHours = hours.Where(h => h.Status == HoursStatus.Reported && h.Hours > 0).Sum(h => h.Hours);
            RejectedHours = hours.Where(h => h.Status == HoursStatus.Rejected && h.Hours > 0).Sum(h => h.Hours);
            RequiredHours = placement.RequiredHours > 0 ? placement.RequiredHours : student.RequiredHours;
            HoursPercent = RequiredHours > 0 ? (int)Math.Min(100, ApprovedHours * 100.0 / RequiredHours) : 0;

            foreach (TrainingHoursEntry h in hours.OrderByDescending(h => h.WorkDate > 0 ? h.WorkDate : h.ReportedAt))
            {
                HoursLog.Add(new HoursRow
                {
                    Date = Time.DisplayDate(h.WorkDate > 0 ? h.WorkDate : h.ReportedAt),
                    Hours = h.Hours,
                    Description = TextOrDash(h.Description),
                    Status = h.Status == HoursStatus.Reported ? L.T("Student.Progress.PendingApproval") : L.Value("HoursStatus", h.Status),
                    StatusCss = h.Status == HoursStatus.Approved ? "rv-badge is-done"
                              : h.Status == HoursStatus.Rejected ? "rv-badge is-rejected" : "rv-badge is-pending",
                    Note = TextOrDash(h.ReviewNote)
                });
            }
        }

        // ---- summary cards ------------------------------------------------------
        private void BuildSummary(List<InternshipTask> tasks, List<TaskEvaluation> latestGrades)
        {
            TasksTotal = tasks.Count;
            TasksGraded = tasks.Count(t => t.Status == InternshipTaskStatus.Graded);
            OpenRevisions = tasks.Count(t => t.Status == InternshipTaskStatus.RevisionRequested);
            // Each task on its own scale, converted to a percentage and weighted
            // by the task's Weight. Ungraded tasks are left out, never zero.
            if (latestGrades.Count > 0)
                AverageText = GradingService.TaskComponentPercent(tasks, latestGrades).ToString("0.#", CultureInfo.InvariantCulture) + "%";
        }

        // ---- completion and official report (card A16) --------------------------
        private void BuildRelease(Student student)
        {
            if (Completion == null || Completion.Status != CompletionStatus.Approved) return;
            Released = true;
            string url = Completion.ReportFileUrl ?? "";
            bool internalLink = url.StartsWith("~/Pages/Account/CompletionReport.aspx", StringComparison.Ordinal);
            if (PdfReportService.MayDownload(Completion, student) && (internalLink || IsWebLink(url)))
            {
                ReportUrl = ResolveUrl(url);
                ReportDownloadUrl = internalLink ? ResolveUrl(PdfReportService.DownloadUrl(url)) : ReportUrl;
            }
        }

        // ---- requirements and documents ------------------------------------------
        private void BuildDocs()
        {
            bool local = !IsInternational;
            Docs.Add(FromChecks("Student.Progress.DocPriorApproval", local ? new[] { "prior-approval" } : new[] { "contract-approval" },
                L.F("Student.Progress.DocPlacementConfirmed", Time.DisplayDate(Placement.ConfirmedAt))));

            DocItem training = new DocItem { Title = L.T(local ? "Student.Progress.DocHours" : "Student.Progress.DocDuration") };
            if (TrainingMet) { training.State = DocVerified; }
            else { training.State = DocPending; }
            training.Detail = local
                ? L.F("Student.Progress.DocHoursDetail", ApprovedHours, RequiredHours)
                : L.F("Student.Progress.DocDurationDetail", Weeks.ToString("0.#", CultureInfo.InvariantCulture), InternshipRules.InternationalMinimumWeeks);
            Docs.Add(training);

            Docs.Add(FromChecks(local ? "Student.Progress.DocReport" : "Student.Progress.DocInternationalReport",
                local ? new[] { "training-report" } : new[] { "report" }, null));
            Docs.Add(FromChecks(local ? "Student.Progress.DocForms" : "Student.Progress.DocCertificate",
                local ? new[] { "training-forms" } : new[] { "certificate" }, null));

            DocItem taskDocs = new DocItem { Title = L.T("Student.Progress.DocTasks") };
            if (TasksTotal == 0) { taskDocs.State = DocPending; taskDocs.Detail = L.T("Student.Progress.DocTasksNone"); }
            else if (OpenRevisions > 0) { taskDocs.State = DocCorrections; taskDocs.Detail = L.F("Student.Progress.DocTasksRevision", OpenRevisions); }
            else if (TasksGraded == TasksTotal) { taskDocs.State = DocVerified; taskDocs.Detail = L.F("Student.Progress.DocTasksDetail", TasksGraded, TasksTotal); }
            else if (Tasks.All(t => t.Attempts > 0)) { taskDocs.State = DocSubmitted; taskDocs.Detail = L.F("Student.Progress.DocTasksDetail", TasksGraded, TasksTotal); }
            else { taskDocs.State = DocPending; taskDocs.Detail = L.F("Student.Progress.DocTasksDetail", TasksGraded, TasksTotal); }
            Docs.Add(taskDocs);

            Docs.Add(FromChecks("Student.Progress.DocDepartment",
                local ? new[] { "prerequisites", "major-relevance", "schedule", "company-eligibility" } : new[] { "full-time", "local-training-done" }, null));
            Docs.Add(FromChecks(local ? "Student.Progress.DocEndorsement" : "Student.Progress.DocFacultyValidation",
                local ? new[] { "endorsement" } : new[] { "faculty-validation" }, null));

            DocItem approval = new DocItem { Title = L.T("Student.Progress.DocCoordinator") };
            if (Completion == null || (Completion.Status != CompletionStatus.Approved && Completion.Status != CompletionStatus.Rejected))
            { approval.State = DocPending; approval.Detail = L.T("Student.Progress.DocCoordinatorPending"); }
            else if (Completion.Status == CompletionStatus.Approved)
            { approval.State = DocVerified; approval.Detail = L.F("Student.Progress.DocCoordinatorApproved", Time.DisplayDate(Completion.ApprovedAt)); }
            else if (Completion.IsRejectedFinal)
            { approval.State = DocRejected; approval.Detail = TextOrDash(Completion.CoordinatorNote); }
            else
            { approval.State = DocCorrections; approval.Detail = TextOrDash(Completion.CoordinatorNote); }
            Docs.Add(approval);
        }

        /// <summary>One document line from the coordinator's recorded checks.
        /// No record means "Pending" (not yet verified) - never "Rejected".</summary>
        private DocItem FromChecks(string titleKey, string[] keys, string pendingDetail)
        {
            DocItem item = new DocItem { Title = L.T(titleKey) };
            List<RequirementCheck> checks = keys.Select(k => Completion == null ? null : Completion.Check(k)).ToList();
            if (checks.Any(c => c != null && c.Status == RequirementCheck.NeedsCorrections))
            {
                item.State = DocCorrections;
                item.Detail = string.Join(" · ", checks.Where(c => c != null && c.Status == RequirementCheck.NeedsCorrections).Select(c => c.Evidence));
            }
            else if (checks.All(c => c != null && c.Status == RequirementCheck.NotApplicable))
            {
                item.State = DocNotApplicable;
            }
            else if (checks.All(c => c != null && c.IsSatisfied))
            {
                item.State = DocVerified;
                long when = checks.Max(c => c.CheckedAt);
                item.Detail = when > 0 ? L.F("Student.Progress.DocVerifiedOn", Time.DisplayDate(when)) : null;
            }
            else
            {
                item.State = DocPending;
                int done = checks.Count(c => c != null && c.IsSatisfied);
                if (keys.Length > 1 && done > 0) item.Detail = L.F("Student.Progress.DocPartlyVerified", done, keys.Length);
                else if (pendingDetail != null) item.Detail = pendingDetail + " " + L.T("Student.Progress.DocDeptNotVerified");
                else item.Detail = L.T("Student.Progress.DocNotVerified");
            }
            return item;
        }

        // ---- the journey ------------------------------------------------------------
        private void BuildJourney(List<InternshipTask> tasks)
        {
            long now = Time.NowMs();
            bool cancelled = Placement.Status == PlacementStatus.Cancelled;

            Journey.Add(Step("placement", "Student.Progress.StepPlacement",
                cancelled ? StepRejected : StepDone,
                cancelled ? L.T("Student.Progress.StepPlacementCancelled") : L.F("Student.Progress.StepPlacementDone", Time.DisplayDate(Placement.ConfirmedAt)),
                L.T("Student.Progress.StepPlacementHint")));

            bool started = (Placement.StartDate > 0 && Placement.StartDate <= now) || ApprovedHours > 0 || PendingHours > 0;
            bool overdue = tasks.Any(t => t.IsOverdue);
            string trainingState = TrainingMet ? StepDone : !started ? StepPending : (overdue ? StepAttention : StepActive);
            string trainingDetail = IsInternational
                ? L.F("Student.Progress.StepTrainingWeeks", Weeks.ToString("0.#", CultureInfo.InvariantCulture), InternshipRules.InternationalMinimumWeeks)
                : L.F("Student.Progress.StepTrainingHours", ApprovedHours, RequiredHours);
            if (overdue && !TrainingMet) trainingDetail += " · " + L.T("Student.Progress.StepOverdue");
            Journey.Add(Step("training", "Student.Progress.StepTraining", cancelled ? StepPending : trainingState, trainingDetail, L.T("Student.Progress.StepTrainingHint")));

            List<DocItem> documents = Docs.Where((d, i) => i >= 2 && i <= 6).ToList();
            string docsState = documents.All(d => d.State == DocVerified || d.State == DocNotApplicable) ? StepDone
                : documents.Any(d => d.State == DocCorrections) ? StepAttention
                : documents.Any(d => d.State == DocVerified || d.State == DocSubmitted) ? StepActive : StepPending;
            Journey.Add(Step("documents", "Student.Progress.StepDocuments", docsState,
                L.F("Student.Progress.StepDocumentsDetail", documents.Count(d => d.State == DocVerified || d.State == DocNotApplicable), documents.Count),
                L.T("Student.Progress.StepDocumentsHint")));

            // Final evaluations are confidential: only their existence is known,
            // through the coordinator's completion record.
            bool evaluationsIn = Completion != null && (Completion.Status == CompletionStatus.Approved
                || Completion.Status == CompletionStatus.UnderCoordinatorReview
                || (!string.IsNullOrEmpty(Completion.CompanyEvaluationId) && !string.IsNullOrEmpty(Completion.AcademicEvaluationId)));
            Journey.Add(Step("evaluations", "Student.Progress.StepEvaluations",
                evaluationsIn ? StepDone : TrainingMet ? StepActive : StepPending,
                evaluationsIn ? L.T("Student.Progress.StepEvaluationsDone") : TrainingMet ? L.T("Student.Progress.StepEvaluationsActive") : L.T("Student.Progress.StepEvaluationsPending"),
                L.T("Student.Progress.StepEvaluationsHint")));

            string reviewState; string reviewDetail;
            if (Completion != null && Completion.Status == CompletionStatus.Approved) { reviewState = StepDone; reviewDetail = L.F("Student.Progress.StepReviewApproved", Time.DisplayDate(Completion.ApprovedAt)); }
            else if (Completion != null && Completion.IsRejectedFinal) { reviewState = StepRejected; reviewDetail = L.T("Student.Progress.StepReviewRejected"); }
            else if (Completion != null && Completion.NeedsCorrections) { reviewState = StepAttention; reviewDetail = L.T("Student.Progress.StepReviewCorrections"); }
            else if (Completion != null && (Completion.Status == CompletionStatus.UnderCoordinatorReview || (Completion.Checks != null && Completion.Checks.Count > 0))) { reviewState = StepActive; reviewDetail = L.T("Student.Progress.StepReviewActive"); }
            else { reviewState = StepPending; reviewDetail = L.T("Student.Progress.StepReviewPending"); }
            Journey.Add(Step("review", "Student.Progress.StepReview", reviewState, reviewDetail, L.T("Student.Progress.StepReviewHint")));

            bool reportReady = Released && ReportUrl != null;
            Journey.Add(Step("report", "Student.Progress.StepReport", reportReady ? StepDone : Released ? StepActive : StepPending,
                reportReady ? L.T("Student.Progress.StepReportDone") : Released ? L.T("Student.Progress.StepReportPreparing") : L.T("Student.Progress.StepReportPending"),
                L.T("Student.Progress.StepReportHint")));
        }

        private static JourneyStep Step(string key, string titleKey, string state, string detail, string hint)
        {
            return new JourneyStep { Key = key, Title = L.T(titleKey), State = state, Detail = detail, Hint = hint };
        }

        /// <summary>The first step that is not completed: what is happening now.</summary>
        protected JourneyStep CurrentStep
        {
            get { return Journey.FirstOrDefault(s => s.State != StepDone) ?? Journey.LastOrDefault(); }
        }

        /// <summary>Completed steps in a row from the start, for the progress line.</summary>
        protected int CompletedRun
        {
            get { int n = 0; foreach (JourneyStep s in Journey) { if (s.State != StepDone) break; n++; } return n; }
        }

        protected int JourneyPercent
        {
            get { return Journey.Count <= 1 ? 0 : (int)Math.Round(Math.Max(0, CompletedRun - 1) * 100.0 / (Journey.Count - 1)); }
        }

        // ---- labels -------------------------------------------------------------------
        protected const string StepDone = "done", StepActive = "active", StepPending = "pending", StepAttention = "attention", StepRejected = "rejected";
        protected const string DocVerified = "verified", DocSubmitted = "submitted", DocPending = "pending", DocMissing = "missing",
            DocCorrections = "corrections", DocNotApplicable = "na", DocRejected = "rejected";

        protected static string StepLabel(string state)
        {
            switch (state)
            {
                case StepDone: return L.T("Student.Progress.StateCompleted");
                case StepActive: return L.T("Student.Progress.StateInProgress");
                case StepAttention: return L.T("Student.Progress.StateAttention");
                case StepRejected: return L.T("Student.Progress.StateRejected");
                default: return L.T("Student.Progress.StatePending");
            }
        }

        protected static string DocLabel(string state)
        {
            switch (state)
            {
                case DocVerified: return L.T("Student.Progress.DocStateVerified");
                case DocSubmitted: return L.T("Student.Progress.DocStateSubmitted");
                case DocMissing: return L.T("Student.Progress.DocStateMissing");
                case DocCorrections: return L.T("Student.Progress.DocStateCorrections");
                case DocNotApplicable: return L.T("Student.Progress.DocStateNA");
                case DocRejected: return L.T("Student.Progress.StateRejected");
                default: return L.T("Student.Progress.DocStatePending");
            }
        }

        protected static string DocCss(string state)
        {
            switch (state)
            {
                case DocVerified: return "rv-badge is-done";
                case DocSubmitted: return "rv-badge is-info";
                case DocMissing: return "rv-badge is-rejected";
                case DocCorrections: return "rv-badge is-attention";
                case DocNotApplicable: return "rv-badge is-na";
                case DocRejected: return "rv-badge is-rejected";
                default: return "rv-badge is-pending";
            }
        }

        protected string TypeLabel
        {
            get { return IsInternational ? L.T("Student.Progress.TypeInternational") : L.T("Student.Progress.TypeLocal"); }
        }

        protected string ProgramLabel
        {
            get
            {
                if (Program != null) return Program.Name;
                return string.IsNullOrWhiteSpace(CurrentStudent.Major) ? L.T("Student.Progress.NotRecorded") : CurrentStudent.Major;
            }
        }

        protected string RequirementLabel
        {
            get
            {
                return IsInternational
                    ? L.F("Student.Progress.RequirementInternational", InternshipRules.InternationalMinimumWeeks)
                    : L.F("Student.Progress.RequirementLocal", RequiredHours);
            }
        }

        protected string CompletionApprovalText
        {
            get
            {
                if (Completion == null) return L.T("Student.Progress.ApprovalNotStarted");
                if (Completion.Status == CompletionStatus.Approved) return L.F("Student.Progress.ApprovalApproved", Time.DisplayDate(Completion.ApprovedAt));
                if (Completion.IsRejectedFinal) return L.T("Student.Progress.ApprovalRejected");
                if (Completion.NeedsCorrections) return L.T("Student.Progress.ApprovalCorrections");
                return L.T("Student.Progress.ApprovalWaiting");
            }
        }

        protected string ResultText
        {
            get
            {
                if (!Released || string.IsNullOrWhiteSpace(Completion.Result)) return L.T("Student.Progress.NotReleased");
                return Completion.Result == "Pass" ? L.T("Student.Progress.Pass") : Completion.Result == "Fail" ? L.T("Student.Progress.Fail") : Completion.Result;
            }
        }

        /// <summary>Fixed SVG paths for each milestone (constant markup, no user data).</summary>
        protected static string Glyph(string key)
        {
            switch (key)
            {
                case "placement": return "<rect x=\"3\" y=\"7\" width=\"18\" height=\"14\" rx=\"2\"/><path d=\"M8 7V5a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2\"/>";
                case "training": return "<circle cx=\"12\" cy=\"12\" r=\"9\"/><path d=\"M12 7v5l3 2\"/>";
                case "documents": return "<path d=\"M14 3H6a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z\"/><path d=\"M14 3v6h6\"/><path d=\"M8 13h8M8 17h5\"/>";
                case "evaluations": return "<path d=\"M12 3l2.6 5.6 6 .7-4.5 4.1 1.2 6L12 16.4 6.7 19.4l1.2-6L3.4 9.3l6-.7z\"/>";
                case "review": return "<path d=\"M12 3l7 4v5c0 4.5-3 8-7 9-4-1-7-4.5-7-9V7l7-4z\"/><path d=\"m9 12 2 2 4-4\"/>";
                default: return "<path d=\"M14 3H6a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z\"/><path d=\"M14 3v6h6\"/><path d=\"M12 11v6\"/><path d=\"m9 14 3 3 3-3\"/>";
            }
        }

        protected static string StateGlyph(string state)
        {
            switch (state)
            {
                case StepDone: return "<path class=\"pg-check\" d=\"M4 8.5l2.6 2.6L12 5.6\"/>";
                case StepAttention: return "<path d=\"M8 4.5v4.2\"/><path d=\"M8 11.3v.2\"/>";
                case StepRejected: return "<path d=\"M5.2 5.2l5.6 5.6M10.8 5.2l-5.6 5.6\"/>";
                case StepActive: return "<circle cx=\"8\" cy=\"8\" r=\"2.6\" class=\"pg-fill\"/>";
                default: return "<circle cx=\"8\" cy=\"8\" r=\"1.6\" class=\"pg-fill\"/>";
            }
        }

        // ---- helpers ----------------------------------------------------------------
        private string SupervisorName(string id)
        {
            if (!ApplicationRepository.IsValidKey(id)) return L.T("Student.Progress.NotAssigned");
            try
            {
                Person person = new UserRepository().GetPerson(id);
                return person == null ? L.T("Student.Progress.NotAssigned") : person.FullName;
            }
            catch (FirebaseException) { return "—"; }
        }

        private static bool DueSoon(InternshipTask task)
        {
            if (task.Deadline <= 0 || task.Status == InternshipTaskStatus.Graded || task.IsOverdue) return false;
            return task.Deadline - Time.NowMs() <= 3L * 24 * 60 * 60 * 1000;
        }

        private static string DueText(InternshipTask task)
        {
            if (task.Deadline <= 0) return "";
            if (task.Status == InternshipTaskStatus.Graded) return "";
            if (task.IsOverdue) return L.T("Student.Progress.Overdue");
            double days = (task.Deadline - Time.NowMs()) / (24.0 * 60 * 60 * 1000);
            if (days < 1) return L.T("Student.Progress.DueToday");
            if (days <= 7) return L.F("Student.Progress.DueInDays", (int)Math.Ceiling(days));
            return "";
        }

        private static string StatusCss(InternshipTaskStatus status)
        {
            switch (status)
            {
                case InternshipTaskStatus.Graded: return "rv-badge is-done";
                case InternshipTaskStatus.RevisionRequested: return "rv-badge is-attention";
                case InternshipTaskStatus.Assigned: return "rv-badge is-info";
                default: return "rv-badge is-pending";
            }
        }

        private static string Number(double value)
        {
            return value.ToString("0.##", CultureInfo.InvariantCulture);
        }

        private static bool IsWebLink(string url)
        {
            Uri address;
            return Uri.TryCreate(url, UriKind.Absolute, out address)
                   && (address.Scheme == Uri.UriSchemeHttp || address.Scheme == Uri.UriSchemeHttps);
        }

        private static string TextOrDash(string value)
        {
            return string.IsNullOrWhiteSpace(value) ? "—" : value;
        }

        // Row shapes for the markup.
        public class TaskRow
        {
            public string Title, Deadline, DueText, DueCss, Status, StatusCss, Grade, GradePercent, Scale, Feedback;
            public int Attempts;
            public bool IsRevision;
            public List<string> Criteria;
        }

        public class AttemptRow
        {
            public string TaskTitle, SubmittedAt, Outcome, Tone, Details, Feedback;
            public int Attempt;
        }

        public class HoursRow
        {
            public string Date, Description, Status, StatusCss, Note;
            public int Hours;
        }

        public class JourneyStep
        {
            public string Key, Title, State, Detail, Hint;
        }

        public class DocItem
        {
            public string Title, State, Detail;
        }
    }
}
