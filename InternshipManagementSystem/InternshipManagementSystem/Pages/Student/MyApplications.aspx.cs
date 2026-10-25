using System;
using System.Web.UI.WebControls;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
namespace InternshipManagementSystem.Pages.StudentArea
{
    public partial class MyApplications : Security.StudentPage
    {
        protected Placement ConfirmedPlacement;
        protected override void OnInit(EventArgs e)
        {
            ViewStateUserKey = Session.SessionID;
            base.OnInit(e);
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;
            var message = Session["OfferConfirmationNotice"] as string;
            Session.Remove("OfferConfirmationNotice");
            if (Session["ApplicationSubmitted"] is bool && (bool)Session["ApplicationSubmitted"])
                message = L.T("Student.MyApplications.ApplicationSubmittedYourStatusIsPending");
            Session.Remove("ApplicationSubmitted");
            NoticeText.Text = message;
            NoticePanel.Visible = !string.IsNullOrEmpty(message);
            try
            {
                ConfirmedPlacement = new PlacementRepository().GetById(CurrentStudent.Id);
                PlacementPanel.Visible = ConfirmedPlacement != null;
                if (ConfirmedPlacement != null)
                {
                    PlacementTitle.Text = ConfirmedPlacement.OpportunityTitle;
                    PlacementCompany.Text = ConfirmedPlacement.CompanyName;
                }
                var applications = ApplicationRepository.DistinctForStudent(
                    new ApplicationRepository().GetWhere("StudentId", CurrentStudent.Id),
                    ConfirmedPlacement == null ? null : ConfirmedPlacement.ApplicationId);
                ApplicationRepeater.DataSource = applications;
                ApplicationRepeater.DataBind();
                EmptyPanel.Visible = applications.Count == 0;
            }
            catch (FirebaseException) { ShowError(L.T("Student.MyApplications.WeCouldNotLoadApplicationsRefresh")); }
            catch (InvalidOperationException) { ShowError(L.T("Student.MyApplications.TheApplicationServiceIsNotConfigured")); }
        }
        protected bool CanConfirm(object item)
        {
            return ConfirmedPlacement == null && ((InternshipApplication)item).Status == ApplicationStatus.Accepted;
        }
        protected bool IsConfirmed(object item)
        {
            return ConfirmedPlacement != null && ConfirmedPlacement.ApplicationId == ((InternshipApplication)item).Id;
        }
        protected bool NeedsSync(object item)
        {
            return IsConfirmed(item) && !((InternshipApplication)item).IsConfirmedByStudent;
        }
        protected void Application_Command(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "Confirm" && e.CommandName != "Sync") return;
            ErrorPanel.Visible = false;
            NoticePanel.Visible = false;
            try
            {
                var consent = e.Item.FindControl("ConfirmConsent") as CheckBox;
                if (e.CommandName == "Confirm" && (consent == null || !consent.Checked))
                    throw new InvalidOperationException("Confirm that you understand you can choose only one internship.");
                var result = new PlacementRepository().ConfirmAcceptedOffer(CurrentStudent, Convert.ToString(e.CommandArgument));
                Session["OfferConfirmationNotice"] = result.ApplicationSyncPending
                    ? L.T("Student.MyApplications.YourInternshipIsConfirmedAndSaved")
                    : L.T("Student.MyApplications.InternshipConfirmedThisIsYourSelected");
                Response.Redirect("MyApplications.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (InvalidOperationException ex) { ShowError(ex.Message); }
            catch (FirebaseException) { ShowError(L.T("Student.MyApplications.WeCouldNotConfirmTheResult")); }
        }
        private void ShowError(string message) { ErrorPanel.Visible = true; ErrorText.Text = message; }
    }
}
