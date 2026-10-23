using System;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Security;
using InternshipManagementSystem.Services;

namespace InternshipManagementSystem.Pages.AccountArea
{
    public partial class ChangePassword : AuthenticatedPage
    {
        protected override bool AllowWhilePasswordChangePending
        {
            get { return true; }
        }

        protected void btnChange_Click(object sender, EventArgs e)
        {
            if (!InternshipManagementSystem.Common.Validators.IsStrongEnoughPassword(txtNewPassword.Text))
            {
                ShowMessage("The new password must be at least 6 characters.");
                return;
            }
            if (txtNewPassword.Text != txtConfirmPassword.Text)
            {
                ShowMessage("The passwords do not match.");
                return;
            }

            AuthResult result = AuthService.ChangePassword(SessionHelper.IdToken, txtNewPassword.Text);
            if (!result.Success)
            {
                ShowMessage(result.ErrorMessage ?? "Could not change the password.");
                return;
            }

            try
            {
                new UserRepository().ClearMustChangePassword(CurrentUser.Id);
                CurrentUser.MustChangePassword = false;
                SessionHelper.Refresh(CurrentUser);
                Response.Redirect(ResolveUrl(CurrentUser.DashboardUrl), false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (FirebaseException)
            {
                ShowMessage("Password changed, but the account could not be updated. Please try again or contact your coordinator.");
            }
        }

        private void ShowMessage(string message)
        {
            lblMessage.Text = InternshipManagementSystem.Common.Validators.Safe(message);
            lblMessage.CssClass = "alert alert-danger d-block";
            lblMessage.Visible = true;
        }
    }
}
