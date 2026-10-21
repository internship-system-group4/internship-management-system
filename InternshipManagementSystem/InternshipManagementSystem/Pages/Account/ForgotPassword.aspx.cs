// =============================================================================
//  Password Recovery
//  Owner : Ahmad
//  Cards : A03
//
//  The user enters an email and Firebase sends a password-reset link.
//  The link opens Firebase's own reset page, where the user picks a new
//  password, then signs in again from the Login page.
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
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnSend_Click(object sender, EventArgs e)
        {
            string email = txtEmail.Text.Trim();

            // Check the input again on the server (JavaScript can be turned off)
            if (email == "")
            {
                ShowMessage("Please enter your email address.", false);
                return;
            }

            if (!Common.Validators.IsEmail(email))
            {
                ShowMessage("Please enter a valid email address.", false);
                return;
            }

            AuthResult result = AuthService.SendPasswordResetEmail(email);

            if (result.Success)
            {
                // Same message for every email, so nobody can find out
                // which addresses have an account.
                ShowMessage("If an account exists for this email, a password reset link has been sent. "
                    + "Please check your inbox and spam folder.", true);
                txtEmail.Text = "";
            }
            else
            {
                ShowMessage(result.ErrorMessage, false);
            }
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            lblMessage.Text = Server.HtmlEncode(message);
            lblMessage.CssClass = isSuccess ? "alert alert-success d-block" : "alert alert-danger d-block";
            lblMessage.Visible = true;
        }
    }
}
