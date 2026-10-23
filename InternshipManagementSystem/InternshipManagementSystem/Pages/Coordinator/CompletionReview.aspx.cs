// =============================================================================
//  Final Completion Review
//  Owner : Ahmad
//  Cards : A10 - A14
//
//  The last step of the whole workflow. Without ?id the page lists every
//  placement with its completion stage. With ?id={placementId} it shows both
//  final evaluations, the approved hours and the university's conditions,
//  computes the final result with GradingService, and lets the coordinator
//  approve or return the completion. After approval the official PDF report
//  is released to the student and the certificate can be printed.
//  Nothing is marked complete without this approval.
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

namespace InternshipManagementSystem.Pages.CoordinatorArea
{
    public partial class CompletionReview : InternshipManagementSystem.Security.CoordinatorPage
    {
        protected List<CompletionQueueRow> Queue;
        protected PlacementProgressData Progress;
        protected CompletionSummary Summary;
        protected string LoadError;
        protected string Message;
        protected bool MessageIsError;

        protected bool IsDetail
        {
            get { return Request.QueryString["id"] != null; }
        }

        protected bool IsApproved
        {
            get { return Progress != null && Progress.Completion != null && Progress.Completion.Status == CompletionStatus.Approved; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                if (IsDetail) LoadReview(); else Queue = new CoordinatorMonitoringRepository().LoadCompletionQueue();
            }
            catch (FirebaseException) { LoadError = L.T("Coordinator.CompletionReview.WeCouldNotLoadCompletionData"); }
            catch (InvalidOperationException ex) { LoadError = ex.Message; }

            if (!IsPostBack)
            {
                if (Request.QueryString["done"] == "approved") Message = L.T("Coordinator.CompletionReview.CompletionApprovedTheOfficialReportIs");
                if (Request.QueryString["done"] == "returned") Message = L.T("Coordinator.CompletionReview.CompletionReturnedToTheStudentWith");
            }
            pnlDecision.Visible = Progress != null && !IsApproved;
            if (pnlDecision.Visible) btnApprove.Enabled = Summary.CanApprove;
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

        protected void Approve_Click(object sender, EventArgs e)
        {
            Decide(true);
        }

        protected void Return_Click(object sender, EventArgs e)
        {
            Decide(false);
        }

        private void Decide(bool approve)
        {
            if (Progress == null) return;
            try
            {
                if (approve) CompletionService.Approve(Progress, CurrentCoordinator, txtNote.Text);
                else CompletionService.Return(Progress, CurrentCoordinator, txtNote.Text);
            }
            catch (InvalidOperationException ex)
            {
                Message = ex.Message;
                MessageIsError = true;
                return;
            }
            catch (FirebaseException)
            {
                Message = L.T("Coordinator.CompletionReview.TheDecisionCouldNotBeSaved");
                MessageIsError = true;
                return;
            }
            // Redirect so a browser refresh cannot submit the decision twice.
            Response.Redirect("CompletionReview.aspx?id=" + Server.UrlEncode(Progress.Overview.Placement.Id)
                              + "&done=" + (approve ? "approved" : "returned"), false);
            Context.ApplicationInstance.CompleteRequest();
        }

        // ---- display helpers ----------------------------------------------
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

        protected static string StageCss(CompletionQueueRow row)
        {
            if (row.IsApproved) return "completion-pill is-done";
            if (row.IsReturned) return "completion-pill is-returned";
            if (row.IsReady) return "completion-pill is-ready";
            return "completion-pill";
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
            Person person = new UserRepository().GetPerson(id);
            return person == null ? "—" : person.FullName;
        }

        protected int CountWhere(Func<CompletionQueueRow, bool> test)
        {
            return Queue == null ? 0 : Queue.Count(test);
        }
    }
}
