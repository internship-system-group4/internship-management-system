// =============================================================================
//  Final Completion Review
//  Owner : Ahmad
//  Cards : A10 - A14
//
//  The last step of the whole workflow. Without ?id the page lists every
//  internship with its UIMS review status. With ?id={placementId} it shows
//  the student and placement, both final evaluations (confidential, coordinator
//  only), task and hours evidence, the provisional result of the
//  project-proposed evaluation method, and the requirement checklist for the
//  internship type. The coordinator records manual verifications (with an
//  evidence reference) and then approves, returns for corrections, or rejects.
//
//  Every decision is re-validated on the server by CompletionService and saved
//  with a compare-and-swap. The approval stamp animation only plays after the
//  redirect that follows a successful save (a one-time session flag), so a
//  refresh shows the stored approval without replaying it.
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
using System.Web.UI.WebControls;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;
using InternshipManagementSystem.Services;

namespace InternshipManagementSystem.Pages.CoordinatorArea
{
    public partial class CompletionReview : InternshipManagementSystem.Security.CoordinatorPage
    {
        private const string StampFlag = "completion-stamp";

        protected List<CompletionQueueRow> Queue;
        protected PlacementProgressData Progress;
        protected CompletionSummary Summary;
        protected string LoadError;
        protected string Message;
        protected bool MessageIsError;

        /// <summary>True only on the first view after a successful approval.</summary>
        protected bool PlayStamp;

        protected bool IsDetail
        {
            get { return Request.QueryString["id"] != null; }
        }

        protected CompletionRecord Record
        {
            get { return Progress == null ? null : Progress.Completion; }
        }

        protected bool IsApproved
        {
            get { return Record != null && Record.Status == CompletionStatus.Approved; }
        }

        protected bool IsRejectedFinal
        {
            get { return Record != null && Record.IsRejectedFinal; }
        }

        /// <summary>Approved and rejected reviews are read-only.</summary>
        protected bool IsEditable
        {
            get { return Progress != null && !IsApproved && !IsRejectedFinal; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // "Export to Excel" link on the queue: CompletionReview.aspx?export=xlsx
            if (!IsDetail && !IsPostBack && Request.QueryString["export"] == "xlsx")
            {
                if (ExportGrades()) return;
            }

            try
            {
                if (IsDetail) LoadReview();
                else Queue = new CoordinatorMonitoringRepository().LoadCompletionQueue()
                    .OrderBy(r => r.ReviewOrder).ThenBy(r => r.Overview.StudentName).ToList();
            }
            catch (FirebaseException ex)
            {
                System.Diagnostics.Trace.TraceError("Completion review load failed: " + ex.Message);
                LoadError = L.T("Coordinator.CompletionReview.WeCouldNotLoadCompletionData");
            }
            catch (InvalidOperationException ex)
            {
                System.Diagnostics.Trace.TraceError("Completion review load failed: " + ex.Message);
                LoadError = L.T("Coordinator.CompletionReview.WeCouldNotLoadCompletionData");
            }

            if (!IsPostBack && Progress != null)
            {
                string done = Request.QueryString["done"];
                if (done == "approved") Message = L.T("Coordinator.Review.DoneApproved");
                else if (done == "corrections") Message = L.T("Coordinator.Review.DoneCorrections");
                else if (done == "rejected") Message = L.T("Coordinator.Review.DoneRejected");
                else if (done == "checks") Message = L.T("Coordinator.Review.DoneChecks");
                else if (done == "type") Message = L.T("Coordinator.Review.DoneType");

                // The stamp plays once, right after the server confirmed the approval.
                string flag = SessionHelper.TakeFlash(StampFlag);
                PlayStamp = done == "approved" && IsApproved && flag == Progress.Overview.Placement.Id;

                BindChecks();
                ddlType.SelectedValue = Summary.InternshipType;
            }

            // The two final evaluations shown at the top of the review.
            if (Progress != null)
            {
                ucFinal.Company = Progress.CompanyFinal;
                ucFinal.Academic = Progress.AcademicFinal;
                ucFinal.CompanySupervisorName = Progress.CompanySupervisorName;
                ucFinal.AcademicSupervisorName = Progress.AcademicSupervisorName;
            }

            pnlDecision.Visible = IsEditable;
            pnlChecks.Visible = IsEditable;
            pnlType.Visible = IsEditable;
            if (IsEditable)
            {
                btnApprove.Enabled = Summary.CanApprove;
                btnApprove.OnClientClick = Confirm("Coordinator.Review.ConfirmApprove");
                btnReturn.OnClientClick = Confirm("Coordinator.Review.ConfirmCorrections");
                btnReject.OnClientClick = Confirm("Coordinator.Review.ConfirmReject");
            }
        }

        // ---- Excel export of grades and results ----------------------------------

        /// <summary>Sends every internship's scores and result as an .xlsx file.
        /// Uses the same CompletionService.Summarise as the review page, so the
        /// numbers in Excel always match what the coordinator sees.
        /// Returns false (and shows the page with an error) if loading failed.</summary>
        private bool ExportGrades()
        {
            byte[] file;
            try
            {
                CoordinatorMonitoringRepository repo = new CoordinatorMonitoringRepository();
                List<CompletionQueueRow> queue = repo.LoadCompletionQueue()
                    .OrderBy(r => r.Overview.StudentName).ToList();

                string[] headers =
                {
                    L.T("Coordinator.Export.StudentName"), L.T("Coordinator.Export.StudentNumber"),
                    L.T("Coordinator.Export.Program"), L.T("Coordinator.Export.Company"),
                    L.T("Coordinator.Export.Opportunity"), L.T("Coordinator.Export.InternshipType"),
                    L.T("Coordinator.Export.ApprovedHours"), L.T("Coordinator.Export.RequiredHours"),
                    L.T("Coordinator.Export.TasksGraded"), L.T("Coordinator.Export.TaskScore"),
                    L.T("Coordinator.Export.CompanyScore"), L.T("Coordinator.Export.AcademicScore"),
                    L.T("Coordinator.Export.FinalScore"), L.T("Coordinator.Export.Result"),
                    L.T("Coordinator.Export.ReviewStatus"), L.T("Coordinator.Export.DecidedOn")
                };

                List<object[]> rows = new List<object[]>();
                foreach (CompletionQueueRow row in queue)
                {
                    PlacementProgressData progress = repo.LoadDetails(row.Overview.Placement.Id);
                    if (progress == null) continue;
                    CompletionSummary s = CompletionService.Summarise(progress);
                    Placement placement = progress.Overview.Placement;
                    CompletionRecord record = progress.Completion;

                    string result = s.EvaluationsReady
                        ? (s.Passing ? L.T("Coordinator.Review.Pass") : L.T("Coordinator.Review.Fail"))
                        : L.T("Coordinator.Review.Pending");
                    long decidedAt = record == null ? 0 : (record.DecidedAt > 0 ? record.DecidedAt : record.ApprovedAt);

                    rows.Add(new object[]
                    {
                        progress.Overview.StudentName,
                        progress.Overview.StudentNumber,
                        ProgramName(progress.Overview.Student),
                        placement.CompanyName,
                        placement.OpportunityTitle,
                        TypeLabel(s.InternshipType),
                        s.ApprovedHours,
                        s.RequiredHours,
                        s.TasksGraded + " / " + s.TasksTotal,
                        Math.Round(s.TaskPercent, 2),
                        s.CompanySubmitted ? (object)Math.Round(s.CompanyPercent, 2) : L.T("Coordinator.Review.Pending"),
                        s.AcademicSubmitted ? (object)Math.Round(s.AcademicPercent, 2) : L.T("Coordinator.Review.Pending"),
                        s.EvaluationsReady ? (object)Math.Round(s.FinalPercent, 2) : L.T("Coordinator.Review.Pending"),
                        result,
                        ReviewLabel(row.ReviewStatus),
                        decidedAt > 0 ? Time.DisplayDate(decidedAt) : ""
                    });
                }

                file = ExcelExportService.Build(L.T("Coordinator.Export.SheetName"), headers, rows, L.IsArabic);
            }
            catch (FirebaseException ex)
            {
                System.Diagnostics.Trace.TraceError("Grades export failed: " + ex.Message);
                Message = L.T("Coordinator.Export.Failed");
                MessageIsError = true;
                return false;
            }
            catch (InvalidOperationException ex)
            {
                System.Diagnostics.Trace.TraceError("Grades export failed: " + ex.Message);
                Message = L.T("Coordinator.Export.Failed");
                MessageIsError = true;
                return false;
            }

            string fileName = "UIMS-grades-results-" + DateTime.Now.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture) + ".xlsx";
            Response.Clear();
            Response.ContentType = ExcelExportService.ContentType;
            Response.AddHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
            Response.AddHeader("Cache-Control", "no-store");
            Response.BinaryWrite(file);
            Response.Flush();
            Response.SuppressContent = true;
            Queue = new List<CompletionQueueRow>();   // the page still renders (suppressed); keep it safe
            Context.ApplicationInstance.CompleteRequest();
            return true;
        }

        private static string Confirm(string key)
        {
            return "return confirm('" + System.Web.HttpUtility.JavaScriptStringEncode(L.T(key)) + "');";
        }

        private void LoadReview()
        {
            string id = Request.QueryString["id"];
            if (!ApplicationRepository.IsValidKey(id))
            {
                LoadError = L.T("Coordinator.CompletionReview.ChooseAStudentFromTheCompletion");
                return;
            }
            Progress = new CoordinatorMonitoringRepository().LoadDetails(id);
            if (Progress == null)
            {
                Response.StatusCode = 404;
                Response.TrySkipIisCustomErrors = true;
                LoadError = L.T("Coordinator.CompletionReview.ThisConfirmedPlacementCouldNotBe");
                return;
            }
            Summary = CompletionService.Summarise(Progress);
        }

        private void BindChecks()
        {
            rptChecks.DataSource = Summary.Items.Where(i => i.Manual).ToList();
            rptChecks.DataBind();
        }

        protected void Checks_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            RequirementItem item = e.Item.DataItem as RequirementItem;
            if (item == null) return;
            DropDownList status = (DropDownList)e.Item.FindControl("ddlStatus");
            TextBox evidence = (TextBox)e.Item.FindControl("txtEvidence");
            HiddenField key = (HiddenField)e.Item.FindControl("hidKey");
            key.Value = item.Key;
            if (status.Items.FindByValue(item.State) != null) status.SelectedValue = item.State;
            evidence.Text = item.Check == null ? "" : item.Check.Evidence;
            status.Attributes["aria-label"] = L.T("Coordinator.Review.StatusFor") + " " + item.Title;
            evidence.Attributes["aria-label"] = L.T("Coordinator.Review.EvidenceFor") + " " + item.Title;
        }

        // ---- actions -----------------------------------------------------------
        protected void SaveChecks_Click(object sender, EventArgs e)
        {
            if (!IsEditable) { ShowError(L.T("Coordinator.Req.ErrorDecided")); return; }
            // Validate everything first so a mistake never saves half the list.
            List<string[]> changes = new List<string[]>();
            List<string> problems = new List<string>();
            foreach (RepeaterItem row in rptChecks.Items)
            {
                string key = ((HiddenField)row.FindControl("hidKey")).Value;
                string status = ((DropDownList)row.FindControl("ddlStatus")).SelectedValue;
                string evidence = Common.Validators.Clean(((TextBox)row.FindControl("txtEvidence")).Text);
                RequirementItem current = Summary.Items.FirstOrDefault(i => i.Manual && i.Key == key);
                if (current == null) continue;

                string oldEvidence = current.Check == null ? null : Common.Validators.Clean(current.Check.Evidence);
                if (status == current.State && evidence == oldEvidence) continue;
                if (current.Check == null && status == RequirementCheck.Pending && evidence == null) continue;

                if (status != RequirementCheck.Pending && (evidence == null || evidence.Length < 3))
                    problems.Add(current.Title);
                changes.Add(new[] { key, status, evidence });
            }

            if (problems.Count > 0)
            {
                ShowError(L.T("Coordinator.Review.EvidenceRequired") + " " + string.Join(", ", problems));
                return;
            }
            if (changes.Count == 0)
            {
                ShowError(L.T("Coordinator.Review.NothingChanged"));
                return;
            }

            try
            {
                foreach (string[] change in changes)
                    CompletionService.SaveCheck(Progress, CurrentCoordinator, change[0], change[1], change[2]);
            }
            catch (InvalidOperationException ex) { ShowError(ex.Message); return; }
            catch (FirebaseException ex) { Log(ex); ShowError(L.T("Coordinator.Review.SaveFailed")); return; }
            Done("checks");
        }

        protected void SaveType_Click(object sender, EventArgs e)
        {
            if (!IsEditable) { ShowError(L.T("Coordinator.Req.ErrorDecided")); return; }
            try { CompletionService.SetInternshipType(Progress, ddlType.SelectedValue); }
            catch (InvalidOperationException ex) { ShowError(ex.Message); return; }
            catch (FirebaseException ex) { Log(ex); ShowError(L.T("Coordinator.Review.SaveFailed")); return; }
            Done("type");
        }

        protected void Approve_Click(object sender, EventArgs e)
        {
            if (!Decide(() => CompletionService.Approve(Progress, CurrentCoordinator, txtNote.Text))) return;
            SessionHelper.SetFlash(StampFlag, Progress.Overview.Placement.Id);
            Done("approved");
        }

        protected void Return_Click(object sender, EventArgs e)
        {
            if (Decide(() => CompletionService.ReturnForCorrections(Progress, CurrentCoordinator, txtNote.Text))) Done("corrections");
        }

        protected void Reject_Click(object sender, EventArgs e)
        {
            if (Decide(() => CompletionService.Reject(Progress, CurrentCoordinator, txtNote.Text))) Done("rejected");
        }

        private bool Decide(Func<CompletionRecord> action)
        {
            if (!IsEditable)
            {
                // A second tab or an old form tried to decide a closed review.
                ShowError(IsApproved ? L.T("Coordinator.Req.ErrorAlreadyApproved") : L.T("Coordinator.Req.ErrorAlreadyRejected"));
                return false;
            }
            try
            {
                action();
                return true;
            }
            catch (InvalidOperationException ex) { ShowError(ex.Message); }
            catch (FirebaseException ex) { Log(ex); ShowError(L.T("Coordinator.CompletionReview.TheDecisionCouldNotBeSaved")); }
            return false;
        }

        /// <summary>Redirect after every change so a refresh cannot repeat it.</summary>
        private void Done(string what)
        {
            Response.Redirect("CompletionReview.aspx?id=" + Server.UrlEncode(Progress.Overview.Placement.Id) + "&done=" + what, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private void ShowError(string message)
        {
            Message = message;
            MessageIsError = true;
        }

        private static void Log(Exception ex)
        {
            System.Diagnostics.Trace.TraceError("Completion review action failed: " + ex.Message);
        }

        // ---- display helpers ---------------------------------------------------
        protected static string Percent(double value)
        {
            return value.ToString("0.##", CultureInfo.InvariantCulture) + "%";
        }

        protected static string Score(double value, double maximum)
        {
            return maximum > 0
                ? value.ToString("0.##", CultureInfo.InvariantCulture) + " / " + maximum.ToString("0.##", CultureInfo.InvariantCulture)
                : L.T("Coordinator.CompletionReview.NotScored");
        }

        protected static string Weighted(double percent, double weight)
        {
            return (percent * weight / 100.0).ToString("0.##", CultureInfo.InvariantCulture);
        }

        protected static string Text(string value)
        {
            return string.IsNullOrWhiteSpace(value) ? "—" : value;
        }

        protected static IEnumerable<GradeComponent> Components(List<GradeComponent> components)
        {
            return components ?? new List<GradeComponent>();
        }

        protected string CoordinatorName(string id)
        {
            if (!ApplicationRepository.IsValidKey(id)) return "—";
            try
            {
                Person person = new UserRepository().GetPerson(id);
                return person == null ? "—" : person.FullName;
            }
            catch (FirebaseException) { return "—"; }
        }

        protected int CountStatus(string status)
        {
            return Queue == null ? 0 : Queue.Count(r => r.ReviewStatus == status);
        }

        /// <summary>One summary tile on the queue; clicking it filters the list.</summary>
        protected class QueueTile
        {
            public string Status, Icon, IconCss, Css;
            public int Count;
        }

        /// <summary>The main tiles always show; "in progress" and "rejected" only when they have records.</summary>
        protected List<QueueTile> QueueTiles
        {
            get
            {
                var tiles = new List<QueueTile>
                {
                    new QueueTile { Status = CompletionQueueRow.ReviewReady, Icon = "approved", IconCss = "is-success" },
                    new QueueTile { Status = CompletionQueueRow.ReviewAwaitingEvaluations, Icon = "clock", IconCss = "is-warning" },
                    new QueueTile { Status = CompletionQueueRow.ReviewCorrections, Icon = "warning", IconCss = "is-danger" },
                    new QueueTile { Status = CompletionQueueRow.ReviewApproved, Icon = "study", IconCss = "is-success" },
                    new QueueTile { Status = CompletionQueueRow.ReviewInProgress, Icon = "chart", IconCss = "" },
                    new QueueTile { Status = CompletionQueueRow.ReviewRejected, Icon = "close", IconCss = "is-danger" }
                };
                foreach (var tile in tiles) tile.Count = CountStatus(tile.Status);
                return tiles.Where((t, i) => i < 4 || t.Count > 0).ToList();
            }
        }

        /// <summary>Status pill on a queue row, in the same colours as the rest of the portal.</summary>
        protected static string QueuePill(string status)
        {
            switch (status)
            {
                case CompletionQueueRow.ReviewApproved: return "dir-status is-active";
                case CompletionQueueRow.ReviewReady: return "dir-status is-info";
                case CompletionQueueRow.ReviewRejected: return "dir-status is-inactive";
                case CompletionQueueRow.ReviewCorrections:
                case CompletionQueueRow.ReviewAwaitingEvaluations: return "dir-status is-warning";
                default: return "dir-status is-neutral";
            }
        }

        protected static string ReviewLabel(string status)
        {
            switch (status)
            {
                case CompletionQueueRow.ReviewApproved: return L.T("Coordinator.Review.StatusApproved");
                case CompletionQueueRow.ReviewRejected: return L.T("Coordinator.Review.StatusRejected");
                case CompletionQueueRow.ReviewCorrections: return L.T("Coordinator.Review.StatusCorrections");
                case CompletionQueueRow.ReviewReady: return L.T("Coordinator.Review.StatusReady");
                case CompletionQueueRow.ReviewAwaitingEvaluations: return L.T("Coordinator.Review.StatusAwaiting");
                default: return L.T("Coordinator.Review.StatusInProgress");
            }
        }

        protected static string ReviewCss(string status)
        {
            switch (status)
            {
                case CompletionQueueRow.ReviewApproved: return "rv-badge is-done";
                case CompletionQueueRow.ReviewRejected: return "rv-badge is-rejected";
                case CompletionQueueRow.ReviewCorrections: return "rv-badge is-attention";
                case CompletionQueueRow.ReviewReady: return "rv-badge is-active";
                case CompletionQueueRow.ReviewAwaitingEvaluations: return "rv-badge is-pending";
                default: return "rv-badge is-info";
            }
        }

        /// <summary>Review status of the open record, using the same labels as the queue.</summary>
        protected string DetailStatus
        {
            get
            {
                if (IsApproved) return CompletionQueueRow.ReviewApproved;
                if (IsRejectedFinal) return CompletionQueueRow.ReviewRejected;
                if (Record != null && Record.NeedsCorrections) return CompletionQueueRow.ReviewCorrections;
                // Same rule as the queue: "Ready" needs both evaluations and the training done.
                if (Summary.EvaluationsReady) return Summary.TrainingRequirementMet ? CompletionQueueRow.ReviewReady : CompletionQueueRow.ReviewInProgress;
                if (Summary.CompanySubmitted || Summary.AcademicSubmitted || Summary.TrainingRequirementMet) return CompletionQueueRow.ReviewAwaitingEvaluations;
                return CompletionQueueRow.ReviewInProgress;
            }
        }

        protected static string EvaluationLabel(CompletionQueueRow row)
        {
            if (row.CompanySubmitted && row.AcademicSubmitted) return L.T("Coordinator.Review.EvalBoth");
            if (row.CompanySubmitted) return L.T("Coordinator.Review.EvalCompanyOnly");
            if (row.AcademicSubmitted) return L.T("Coordinator.Review.EvalAcademicOnly");
            return L.T("Coordinator.Review.EvalNone");
        }

        protected static string ProgramName(Student student)
        {
            if (student == null) return "—";
            AcademicProgram program = AcademicPrograms.Find(student.Major);
            return program != null ? program.Name : Text(student.Major);
        }

        protected static bool ProgramNeedsCheck(Student student)
        {
            return student == null || AcademicPrograms.Quality(student.Major) != MajorQuality.Recognized;
        }

        protected static string CourseCode(Student student, string type)
        {
            if (student == null || type == InternshipTypes.International) return null;
            AcademicProgram program = AcademicPrograms.Find(student.Major);
            return program == null ? null : program.LocalCourse;
        }

        protected static string TypeLabel(string type)
        {
            return type == InternshipTypes.International ? L.T("Coordinator.Review.TypeInternational") : L.T("Coordinator.Review.TypeLocal");
        }

        protected static string StateLabel(string state)
        {
            switch (state)
            {
                case "Met": return L.T("Coordinator.Review.StateMet");
                case "Missing": return L.T("Coordinator.Review.StateMissing");
                case RequirementCheck.Verified: return L.T("Coordinator.Review.StateVerified");
                case RequirementCheck.NeedsCorrections: return L.T("Coordinator.Review.StateCorrections");
                case RequirementCheck.NotApplicable: return L.T("Coordinator.Review.StateNotApplicable");
                default: return L.T("Coordinator.Review.StatePending");
            }
        }

        protected static string StateCss(string state)
        {
            switch (state)
            {
                case "Met":
                case RequirementCheck.Verified: return "rv-badge is-done";
                case "Missing": return "rv-badge is-rejected";
                case RequirementCheck.NeedsCorrections: return "rv-badge is-attention";
                case RequirementCheck.NotApplicable: return "rv-badge is-na";
                default: return "rv-badge is-pending";
            }
        }

        protected static string SourceLabel(RuleSource source)
        {
            return L.T(InternshipRules.SourceKey(source));
        }

        protected static string SourceCss(RuleSource source)
        {
            return "rv-source " + InternshipRules.SourceCss(source);
        }

        protected string TaskStatusLabel(InternshipTaskStatus status)
        {
            return L.Value("TaskStatus", status);
        }

        protected static string TaskStatusCss(InternshipTaskStatus status)
        {
            switch (status)
            {
                case InternshipTaskStatus.Graded: return "rv-badge is-done";
                case InternshipTaskStatus.RevisionRequested: return "rv-badge is-attention";
                case InternshipTaskStatus.Assigned: return "rv-badge is-info";
                default: return "rv-badge is-pending";
            }
        }

        /// <summary>The newest real grade of a task, as "8 / 10", or a dash.</summary>
        protected string TaskGrade(InternshipTask task)
        {
            TaskEvaluation grade = Progress.Evaluations.FirstOrDefault(ev => ev.TaskId == task.Id && !ev.RevisionRequested);
            if (grade == null) return L.T("Coordinator.Review.NotGraded");
            double max = grade.MaxScore > 0 ? grade.MaxScore : task.MaxScore;
            return Score(grade.TotalScore, max);
        }

        protected int Attempts(InternshipTask task)
        {
            return Progress.Submissions.Count(s => s.TaskId == task.Id);
        }

        protected long RejectedHours
        {
            get { return Progress.Hours.Where(h => h.Status == HoursStatus.Rejected && h.Hours > 0).Sum(h => (long)h.Hours); }
        }

        protected int TrainingPercent
        {
            get
            {
                if (Summary.IsInternational)
                    return (int)Math.Min(100, Summary.Weeks * 100.0 / InternshipRules.InternationalMinimumWeeks);
                return Summary.RequiredHours <= 0 ? 0 : (int)Math.Min(100, Summary.ApprovedHours * 100.0 / Summary.RequiredHours);
            }
        }

        /// <summary>Mandatory checks the coordinator verifies by hand, and how many are done.</summary>
        protected int ManualTotal
        {
            get { return Summary == null ? 0 : Summary.Items.Count(i => i.Manual && i.Mandatory); }
        }

        protected int ManualMet
        {
            get { return Summary == null ? 0 : Summary.Items.Count(i => i.Manual && i.Mandatory && i.Satisfied); }
        }

        protected int RequirementsPercent
        {
            get { return Summary.MandatoryTotal == 0 ? 0 : (int)Math.Round(Summary.MandatoryMet * 100.0 / Summary.MandatoryTotal); }
        }

        protected string CheckedBy(RequirementItem item)
        {
            if (item.Check == null || item.Check.CheckedAt <= 0) return "";
            return L.F("Coordinator.Review.CheckedBy", CoordinatorName(item.Check.CoordinatorId), Time.Friendly(item.Check.CheckedAt));
        }

        protected static string Initials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "?";
            string[] parts = name.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            string first = parts[0].Substring(0, 1);
            string last = parts.Length > 1 ? parts[parts.Length - 1].Substring(0, 1) : "";
            return (first + last).ToUpperInvariant();
        }

        protected static string SearchText(CompletionQueueRow row)
        {
            Student s = row.Overview.Student;
            return (row.Overview.StudentName + " " + row.Overview.StudentNumber + " " + row.Overview.Placement.CompanyName
                    + " " + (s == null ? "" : s.Major)).ToLowerInvariant();
        }
    }
}
