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
                message = "Application submitted. Your status is Pending and the company can now review it.";
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
                var applications = new ApplicationRepository().GetByStudent(CurrentStudent.Id);
                ApplicationRepeater.DataSource = applications;
                ApplicationRepeater.DataBind();
                EmptyPanel.Visible = applications.Count == 0;
            }
            catch (FirebaseException) { ShowError("We could not load applications. Refresh to try again."); }
            catch (InvalidOperationException) { ShowError("The application service is not configured. Contact the coordinator."); }
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
                    ? "Your internship is confirmed and saved. The application flag still needs syncing; use Sync confirmation below."
                    : "Internship confirmed. This is your selected placement; other offers cannot be confirmed.";
                Response.Redirect("MyApplications.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (InvalidOperationException ex) { ShowError(ex.Message); }
            catch (FirebaseException) { ShowError("We could not confirm the result. Refresh to check your placement before trying again."); }
        }
        private void ShowError(string message) { ErrorPanel.Visible = true; ErrorText.Text = message; }
    }
}
