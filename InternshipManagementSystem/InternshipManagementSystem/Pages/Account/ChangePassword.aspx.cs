// =============================================================================
//  Change Password
//  Owner : Ahmad
//  Cards : A04
//
//  Accounts created by the coordinator start with a temporary password and
//  MustChangePassword = true. Security/SecurePage.cs sends these users here
//  from every protected page, so they cannot open anything else until they
//  choose a new password. This page clears the flag after the change.
//
//  Namespace note: these page namespaces end in "Area" on purpose. A namespace
//  called ...Pages.Student would hide the Student model class and every file in
//  the folder would fail to compile with "Student is a namespace but is used
//  like a type". Keep the suffix.
// =============================================================================
using System;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Security;
using InternshipManagementSystem.Services;

namespace InternshipManagementSystem.Pages.AccountArea
{
    public partial class ChangePassword : InternshipManagementSystem.Security.AuthenticatedPage
    {
        /// <summary>This page must stay reachable while the user still has a
        /// temporary password - it is the page that clears the flag.</summary>
        protected override bool AllowWhilePasswordChangePending
        {
            get { return true; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            // Explain why the user is here when the change is required
            pnlTemporary.Visible = CurrentUser.MustChangePassword;
        }

        protected void btnChange_Click(object sender, EventArgs e)
        {
            string currentPassword = txtCurrentPassword.Text;
            string newPassword = txtNewPassword.Text;
            string confirmPassword = txtConfirmPassword.Text;

            // Check the input again on the server (JavaScript can be turned off)
            if (currentPassword == "" || newPassword == "" || confirmPassword == "")
            {
                ShowError("Please fill in all fields.");
                return;
            }

            if (!Common.Validators.IsStrongEnoughPassword(newPassword))
            {
                ShowError("The new password must be at least 6 characters.");
                return;
            }

            if (newPassword != confirmPassword)
            {
                ShowError("The new passwords do not match.");
                return;
            }

            if (newPassword == currentPassword)
            {
                ShowError("The new password must be different from the current password.");
                return;
            }

            // 1. Check the current password with Firebase. This also gives a
            //    fresh token, which Firebase needs before changing a password.
            AuthResult signIn = AuthService.SignIn(CurrentUser.Email, currentPassword);
            if (!signIn.Success)
            {
                if (signIn.ErrorCode != null
                    && (signIn.ErrorCode.StartsWith("INVALID_PASSWORD") || signIn.ErrorCode.StartsWith("INVALID_LOGIN_CREDENTIALS")))
                {
                    ShowError("The current password is incorrect.");
                }
                else
                {
                    ShowError(signIn.ErrorMessage);
                }
                return;
            }

            // 2. Change the password in Firebase Authentication
            AuthResult change = AuthService.ChangePassword(signIn.IdToken, newPassword);
            if (!change.Success)
            {
                ShowError(change.ErrorMessage);
                return;
            }

            // 3. Clear the flag, so the user is no longer sent to this page
            try
            {
                new UserRepository().ClearMustChangePassword(CurrentUser.Id);
            }
            catch (FirebaseException)
            {
                ShowError("Your password was changed, but your account could not be updated. "
                    + "Please try again using your new password as the current password.");
                return;
            }

            // 4. Open the user's dashboard
            Response.Redirect(ResolveUrl(CurrentUser.DashboardUrl), false);
            Context.ApplicationInstance.CompleteRequest();
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            SessionHelper.SignOut();
            Response.Redirect(ResolveUrl(Constants.Routes.Login), false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private void ShowError(string message)
        {
            lblError.Text = Server.HtmlEncode(message);
            lblError.Visible = true;
        }
    }
}
