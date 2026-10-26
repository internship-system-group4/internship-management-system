// =============================================================================
//  Password Recovery
//  Owner : Ahmad
//  Cards : A03
//
//  The user enters an email and Firebase sends a password-reset link.
//  The link opens Firebase's own reset page, where the user picks a new
//  password, then signs in again from the Login page.
//
//  The page posts back normally. recovery-campus.js sends the same postback in
//  the background and reads RecoveryResult from the returned page, so the
//  campus scene only shows "Reset Link Sent" after Firebase has answered.
//
//  Namespace note: these page namespaces end in "Area" on purpose. A namespace
//  called ...Pages.Student would hide the Student model class and every file in
//  the folder would fail to compile with "Student is a namespace but is used
//  like a type". Keep the suffix.
// =============================================================================
using System;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Services;

namespace InternshipManagementSystem.Pages.AccountArea
{
    public partial class ForgotPassword : System.Web.UI.Page
    {
        // Seconds a visitor waits between two reset requests (stops double clicks
        // and repeated sends from one browser; Firebase also limits requests).
        private const int CooldownSeconds = 30;
        private const string LastRequestKey = "uims.passwordResetRequestedAt";

        // "" = form, "sent" = request accepted, "error" = show lblMessage.
        // Read by the page markup (data-result) and by recovery-campus.js.
        protected string RecoveryResult { get; private set; } = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            Response.Cache.SetCacheability(System.Web.HttpCacheability.NoCache);
            Response.Cache.SetNoStore();
        }

        protected void btnSend_Click(object sender, EventArgs e)
        {
            string email = txtEmail.Text.Trim();

            // Check the input again on the server (JavaScript can be turned off)
            if (email == "")
            {
                ShowError(L.T("Account.ForgotPassword.PleaseEnterYourEmailAddress"));
                return;
            }

            if (!Common.Validators.IsEmail(email))
            {
                ShowError(L.T("Account.ForgotPassword.PleaseEnterAValidEmailAddress"));
                return;
            }

            if (IsCoolingDown())
            {
                ShowError(L.T("Account.ForgotPassword.PleaseWaitAMomentBefore"));
                return;
            }

            AuthResult result = AuthService.SendPasswordResetEmail(email);

            if (result.Success)
            {
                // Same message for every email, so nobody can find out
                // which addresses have an account (AuthService also treats
                // unknown and disabled accounts as success).
                Session[LastRequestKey] = DateTime.UtcNow;
                RecoveryResult = "sent";
                txtEmail.Text = "";
            }
            else
            {
                // Network problems, Firebase rate limits and missing settings
                // come back as friendly messages from AuthService.
                ShowError(result.ErrorMessage);
            }
        }

        private bool IsCoolingDown()
        {
            object last = Session[LastRequestKey];
            return last is DateTime && (DateTime.UtcNow - (DateTime)last).TotalSeconds < CooldownSeconds;
        }

        private void ShowError(string message)
        {
            RecoveryResult = "error";
            lblMessage.Text = Server.HtmlEncode(message);
            lblMessage.CssClass = "alert alert-danger d-block";
            lblMessage.Visible = true;
        }
    }
}
