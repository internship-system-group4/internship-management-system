using System;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;
using InternshipManagementSystem.Services;

namespace InternshipManagementSystem.Pages.AccountArea
{
    public partial class Login : System.Web.UI.Page
    {
        protected void btnSignIn_Click(object sender, EventArgs e)
        {
            string email = (txtEmail.Text ?? "").Trim();
            if (!InternshipManagementSystem.Common.Validators.IsEmail(email) || string.IsNullOrEmpty(txtPassword.Text))
            {
                ShowMessage("Enter a valid email and password.");
                return;
            }

            AuthResult result = AuthService.SignIn(email, txtPassword.Text);
            if (!result.Success)
            {
                ShowMessage(result.ErrorMessage ?? "Could not sign in.");
                return;
            }

            try
            {
                Person person = new UserRepository().GetPerson(result.Uid);
                if (person == null || !person.CanLogin() || !string.Equals(person.Email, email, StringComparison.OrdinalIgnoreCase))
                {
                    SessionHelper.SignOut();
                    ShowMessage("This account is not available. Contact your coordinator.");
                    return;
                }

                SessionHelper.SignIn(person, result.IdToken);
                Response.Redirect(ResolveUrl(person.MustChangePassword ? Constants.Routes.ChangePassword : person.DashboardUrl), false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (FirebaseException)
            {
                SessionHelper.SignOut();
                ShowMessage("Could not load the account. Please try again.");
            }
        }

        private void ShowMessage(string message)
        {
            lblMessage.Text = InternshipManagementSystem.Common.Validators.Safe(message);
            lblMessage.Visible = true;
        }
    }
}
