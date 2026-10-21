using System;
using System.Web.UI.WebControls;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
namespace InternshipManagementSystem.Pages.CompanyArea
{
    public partial class Applications : Security.CompanyPage
    {
        protected override void OnInit(EventArgs e)
        {
            ViewStateUserKey = Session.SessionID;
            base.OnInit(e);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;
            NoticeText.Text = Session["CompanyDecisionNotice"] as string;
            NoticePanel.Visible = !string.IsNullOrEmpty(NoticeText.Text);
            Session.Remove("CompanyDecisionNotice");
            LoadApplications();
        }

        private void LoadApplications()
        {
            try
            {
                var applications = new ApplicationRepository().GetByCompany(CurrentSupervisor.CompanyId);
                ApplicationRepeater.DataSource = applications;
                ApplicationRepeater.DataBind();
                EmptyPanel.Visible = applications.Count == 0;
                ApplicationCount.Text = applications.Count.ToString();
            }
            catch (FirebaseException) { ShowError("We could not load applications. Refresh to try again."); }
            catch (InvalidOperationException) { ShowError("The application service is not configured. Please contact the coordinator."); }
        }

        protected void Application_Command(object source, RepeaterCommandEventArgs e)
        {
            ErrorPanel.Visible = false;
            NoticePanel.Visible = false;
            if (e.CommandName != "Accept" && e.CommandName != "Reject") return;
            var reason = e.Item.FindControl("RejectionReason") as TextBox;
            if (e.CommandName == "Reject" && reason != null) reason.Attributes["data-rejection-error"] = "true";
            try
            {
                var decision = e.CommandName == "Accept" ? ApplicationStatus.Accepted : ApplicationStatus.Rejected;
                new ApplicationRepository().Decide(CurrentSupervisor, Convert.ToString(e.CommandArgument),
                    decision, reason == null ? "" : reason.Text);
                Session["CompanyDecisionNotice"] = "Application " + decision.ToString().ToLowerInvariant()
                    + ". The student can now see your decision.";
                Response.Redirect("Applications.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (InvalidOperationException ex) { ShowError(ex.Message); }
            catch (FirebaseException)
            {
                ShowError("We could not confirm the decision. Your reason is still here. Refresh to check the current status before trying again.");
            }
        }

        protected string SafeCvUrl(object value)
        {
            string url = Convert.ToString(value);
            return ApplicationRepository.IsSafeDocumentUrl(url) ? url : "";
        }

        protected string StatusClass(object value)
        {
            return "application-status status-" + ((ApplicationStatus)value).ToString().ToLowerInvariant();
        }

        private void ShowError(string message)
        {
            ErrorPanel.Visible = true;
            ErrorText.Text = message;
        }
    }
}
