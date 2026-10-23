using System;
using System.Linq;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Pages.StudentArea
{
    public partial class Apply : Security.StudentPage
    {
        protected Opportunity SelectedOpportunity;
        protected InternshipApplication ExistingApplication;
        protected bool IsViewMode { get { return ExistingApplication != null; } }
        protected string ExistingCvUrl
        {
            get
            {
                string url = ExistingApplication == null ? "" : ExistingApplication.CvUrl;
                return ApplicationRepository.IsSafeDocumentUrl(url) ? url : "";
            }
        }
        protected string OpportunityId { get { return Request.QueryString["opportunityId"] ?? Request.QueryString["id"]; } }

        protected override void OnInit(EventArgs e)
        {
            ViewStateUserKey = Session.SessionID;
            base.OnInit(e);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                if (!ApplicationRepository.IsValidKey(OpportunityId))
                { Block("Choose an internship from Explore Opportunities to start your application."); return; }
                SelectedOpportunity = new OpportunityRepository().GetById(OpportunityId);

                // Already applied: show the submitted application read-only instead of the form.
                ExistingApplication = new ApplicationRepository().GetByStudent(CurrentStudent.Id)
                    .FirstOrDefault(a => a.OpportunityId == OpportunityId);
                if (ExistingApplication != null)
                {
                    FormPanel.Visible = false;
                    ViewPanel.Visible = true;
                    OpportunityPanel.Visible = SelectedOpportunity != null;
                    return;
                }

                if (SelectedOpportunity == null) { Block("This internship could not be found."); return; }
                OpportunityPanel.Visible = true;
                if (!SelectedOpportunity.IsOpenForApplications) { Block("This internship is no longer accepting applications."); return; }
                if (!SelectedOpportunity.IsEligible(CurrentStudent)) { Block("This internship is not available for your college or major."); return; }
                if (new PlacementRepository().Exists(CurrentStudent.Id)) { Block("You already have a confirmed internship."); return; }
                FormPanel.Visible = true;
                if (!IsPostBack) CvUrl.Text = CurrentStudent.CvUrl;
            }
            catch (FirebaseException) { Block("We could not load this internship. Please try again shortly."); }
            catch (InvalidOperationException) { Block("The application service is not configured. Please contact the coordinator."); }
        }

        protected void Submit_Click(object sender, EventArgs e)
        {
            if (!FormPanel.Visible || IsViewMode) return;
            try
            {
                new ApplicationRepository().Submit(CurrentStudent, OpportunityId, CoverLetter.Text, CvUrl.Text, Confirm.Checked);
                Session["ApplicationSubmitted"] = true;
                Response.Redirect("MyApplications.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (InvalidOperationException ex) { ShowError(ex.Message); }
            catch (FirebaseException)
            { ShowError("We could not confirm your submission. Check My Applications before trying again. Your form is still here."); }
        }

        private void Block(string message) { FormPanel.Visible = false; ShowError(message); }
        private void ShowError(string message)
        {
            ErrorPanel.Visible = true;
            ErrorText.Text = Server.HtmlEncode(message);
        }
    }
}
