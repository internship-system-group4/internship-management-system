using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Services;
namespace InternshipManagementSystem.Pages.CompanyArea
{
    public partial class Applications : Security.CompanyPage
    {
        /// <summary>One application plus the applicant's profile details.</summary>
        public class ApplicantRow
        {
            public InternshipApplication Application { get; set; }
            public string Id { get { return Application.Id; } }
            public string OpportunityTitle { get { return Application.OpportunityTitle; } }
            public string CoverLetter { get { return Application.CoverLetter; } }
            public ApplicationStatus Status { get { return Application.Status; } }
            public long SubmittedAt { get { return Application.SubmittedAt; } }
            public long DecidedAt { get { return Application.DecidedAt; } }
            public string RejectionReason { get { return Application.RejectionReason; } }
            public bool IsConfirmedByStudent { get { return Application.IsConfirmedByStudent; } }

            public string StudentName { get; set; }
            public string StudentMajor { get; set; }
            public string StudentNumber { get; set; }
            public string University { get; set; }
            public string College { get; set; }
            public string Email { get; set; }
            public string Phone { get; set; }
            public string TechnicalSkills { get; set; }
            public string SoftSkills { get; set; }
            public string LinkedInUrl { get; set; }
            public bool HasCv { get; set; }
            public bool HasPortfolio { get; set; }
        }

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
                ApplicationRepeater.DataSource = BuildRows(applications);
                ApplicationRepeater.DataBind();
                EmptyPanel.Visible = applications.Count == 0;
                ApplicationCount.Text = applications.Count.ToString();
            }
            catch (FirebaseException) { ShowError("We could not load applications. Refresh to try again."); }
            catch (InvalidOperationException) { ShowError("The application service is not configured. Please contact the coordinator."); }
        }

        private List<ApplicantRow> BuildRows(List<InternshipApplication> applications)
        {
            var users = new UserRepository();
            var rows = new List<ApplicantRow>();
            foreach (InternshipApplication application in applications)
            {
                Student student = null;
                try { student = users.GetStudent(application.StudentId); }
                catch (FirebaseException) { /* use the copy saved on the application */ }

                var extras = StudentDocumentService.LoadExtras(application.StudentId);
                var documents = StudentDocumentService.LoadDocuments(application.StudentId);

                var row = new ApplicantRow { Application = application };
                row.StudentName = student != null && !string.IsNullOrWhiteSpace(student.FullName)
                    ? student.FullName : application.StudentName;
                row.StudentMajor = student != null && !string.IsNullOrWhiteSpace(student.Major)
                    ? student.Major : application.StudentMajor;
                if (student != null)
                {
                    row.StudentNumber = student.StudentNumber;
                    row.University = student.University;
                    row.College = student.College;
                    row.Email = student.Email;
                    row.Phone = student.PhoneNumber;
                }
                row.TechnicalSkills = extras.TechnicalSkills;
                row.SoftSkills = extras.SoftSkills;
                row.LinkedInUrl = ApplicationRepository.IsSafeDocumentUrl(extras.LinkedInUrl) ? extras.LinkedInUrl : "";

                // Same order ApplicantDocument.aspx uses to open the file.
                row.HasCv = StudentDocumentService.IsExternalLink(application.CvUrl)
                    || StudentDocumentService.UploadedFilePath(application.StudentId, documents.CvStorageName) != null
                    || StudentDocumentService.IsExternalLink(documents.CvUrl);
                row.HasPortfolio = StudentDocumentService.IsExternalLink(documents.PortfolioUrl)
                    || StudentDocumentService.UploadedFilePath(application.StudentId, documents.PortfolioStorageName) != null;
                rows.Add(row);
            }
            return rows;
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

        /// <summary>Shows a value, or a dash when the student left it empty.</summary>
        protected string OrDash(object value)
        {
            string text = Convert.ToString(value);
            return string.IsNullOrWhiteSpace(text) ? "—" : text;
        }

        protected string DocumentUrl(object applicationId, string type)
        {
            return "ApplicantDocument.aspx?id=" + Uri.EscapeDataString(Convert.ToString(applicationId)) + "&type=" + type;
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
