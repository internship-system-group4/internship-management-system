// =============================================================================
//  Login
//  Owner : Ahmad
//  Cards : A01, A02
//
//  1. Firebase Authentication checks the email and password (AuthService.SignIn).
//  2. The user's profile and role are loaded from users/{uid} (UserRepository).
//  3. The user is saved in the session (SessionHelper) and sent to the
//     dashboard of their role (user.DashboardUrl).
//  Every protected page then checks the session and the role on the server
//  (Security/SecurePage.cs), so typing a URL directly cannot skip the check.
//
//  Namespace note: these page namespaces end in "Area" on purpose. A namespace
//  called ...Pages.Student would hide the Student model class and every file in
//  the folder would fail to compile with "Student is a namespace but is used
//  like a type". Keep the suffix.
// =============================================================================
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
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            // Messages sent here by the page guard (Security/SecurePage.cs)
            string error = Request.QueryString["error"];
            if (error == "deactivated")
            {
                ShowError("Your account is not active. Please contact the coordinator.");
            }
            else if (error == "expired")
            {
                ShowError("Your session has expired. Please log in again.");
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text;

            // Check the input again on the server (JavaScript can be turned off)
            if (email == "" || password == "")
            {
                ShowError("Please enter your email and password.");
                return;
            }

            if (!Common.Validators.IsEmail(email))
            {
                ShowError("Please enter a valid email address.");
                return;
            }

            // 1. Check the email and password with Firebase Authentication
            AuthResult result = AuthService.SignIn(email, password);
            if (!result.Success)
            {
                ShowError(result.ErrorMessage);
                return;
            }

            // 2. Load the user's profile (it holds the role) from Firebase
            Person user;
            try
            {
                user = new UserRepository().GetPerson(result.Uid);
            }
            catch (FirebaseException)
            {
                SessionHelper.SignOut();
                ShowError("We could not load your account. Please try again later.");
                return;
            }
            catch (InvalidOperationException)
            {
                SessionHelper.SignOut();
                ShowError("Firebase is not configured yet. See docs/05-firebase-setup.md.");
                return;
            }

            if (user == null)
            {
                SessionHelper.SignOut();
                ShowError("Your account is not set up yet. Please contact the coordinator.");
                return;
            }

            if (!user.CanLogin())
            {
                SessionHelper.SignOut();
                ShowError("Your account is not active. Please contact the coordinator.");
                return;
            }

            // 3. Save the user in the session and open the dashboard of their role.
            //    If the user still has a temporary password, the dashboard sends
            //    them to Change Password first.
            SessionHelper.SignIn(user, result.IdToken);
            Response.Redirect(ResolveUrl(user.DashboardUrl), false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private void ShowError(string message)
        {
            lblError.Text = Server.HtmlEncode(message);
            lblError.Visible = true;
        }
    }
}
