using System;
using System.Collections.Generic;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.StudentArea
{
    public partial class StudentCVPortfolio : StudentPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) LoadLinks();
        }

        private void LoadLinks()
        {
            try
            {
                var student = new UserRepository().GetStudent(CurrentStudent.Id);
                if (student == null) { ShowMessage("Student account not found.", false); btnSave.Enabled = false; return; }
                txtCvUrl.Text = student.CvUrl ?? "";
                txtPortfolioUrl.Text = student.PortfolioUrl ?? "";
                RenderLinks(student.CvUrl, student.PortfolioUrl);
            }
            catch (Exception) { ShowMessage("Unable to load your links. Please try again.", false); btnSave.Enabled = false; }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string cv = txtCvUrl.Text.Trim();
            string portfolio = txtPortfolioUrl.Text.Trim();
            if (!IsSafeLink(cv) || !IsSafeLink(portfolio))
            {
                ShowMessage("Please enter valid HTTPS links (up to 2000 characters), or leave a field empty.", false);
                return;
            }
            try
            {
                string uid = CurrentStudent.Id;
                if (new UserRepository().GetStudent(uid) == null) { ShowMessage("Student account not found.", false); return; }
                // PATCH only student-owned fields; academic data is untouched.
                FirebaseContext.Patch("users/" + uid, new Dictionary<string, object>
                {
                    { "CvUrl", cv }, { "PortfolioUrl", portfolio }
                });
                RenderLinks(cv, portfolio);
                ShowMessage("Your links were saved successfully.", true);
            }
            catch (Exception) { ShowMessage("Unable to save links. Please try again.", false); }
        }

        private static bool IsSafeLink(string value)
        {
            if (string.IsNullOrEmpty(value)) return true;
            if (value.Length > 2000) return false;
            Uri uri;
            return Uri.TryCreate(value, UriKind.Absolute, out uri)
                && uri.Scheme == Uri.UriSchemeHttps
                && !string.IsNullOrWhiteSpace(uri.Host)
                && uri.UserInfo.Length == 0;
        }

        private void RenderLinks(string cv, string portfolio)
        {
            lnkCv.Visible = IsSafeLink(cv) && !string.IsNullOrEmpty(cv);
            lnkPortfolio.Visible = IsSafeLink(portfolio) && !string.IsNullOrEmpty(portfolio);
            lblNoCv.Visible = !lnkCv.Visible;
            lblNoPortfolio.Visible = !lnkPortfolio.Visible;
            if (lnkCv.Visible) lnkCv.NavigateUrl = cv;
            if (lnkPortfolio.Visible) lnkPortfolio.NavigateUrl = portfolio;
        }

        private void ShowMessage(string message, bool success)
        {
            lblMessage.Text = Server.HtmlEncode(message);
            lblMessage.CssClass = "r07-message alert " + (success ? "alert-success" : "alert-danger");
        }
    }
}
