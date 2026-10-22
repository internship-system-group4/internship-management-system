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
        // Set for this verified POST response only. Never persisted in ViewState.
        protected string VerifiedDestination { get; private set; }
        protected override void OnInit(EventArgs e)
        {
            ViewStateUserKey = Session.SessionID;
            base.OnInit(e);
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            Response.Cache.SetCacheability(System.Web.HttpCacheability.NoCache);
            Response.Cache.SetNoStore();
            if (IsPostBack) return;

            // An existing session is only a hint; reverify the profile before
            // redirecting and never accept a role from the URL or posted fields.
            if (SessionHelper.Current != null)
            {
                try
                {
                    var user = new UserRepository().GetPerson(SessionHelper.Current.Id);
                    if (user != null && user.CanLogin())
                    {
                        SessionHelper.Refresh(user);
                        Response.Redirect(ResolveUrl(user.MustChangePassword ? Constants.Routes.ChangePassword : user.DashboardUrl), false);
                        Context.ApplicationInstance.CompleteRequest();
                        return;
                    }
                    SessionHelper.SignOut();
                    ShowError("Your account is not active. Please contact the coordinator.");
                }
                catch (FirebaseAuthExpiredException) { SessionHelper.SignOut(); ShowError("Your session has expired. Please log in again."); }
                catch (FirebaseException) { SessionHelper.SignOut(); ShowError("We could not verify your account. Please log in again."); }
                catch (InvalidOperationException) { SessionHelper.SignOut(); ShowError("The sign-in service is not configured. Please contact the coordinator."); }
            }

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
            catch (FirebaseAuthExpiredException)
            {
                SessionHelper.SignOut();
                ShowError("We could not verify your account access. Please try logging in again.");
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
                ShowError("We could not verify your account access. Please contact the coordinator.");
                SessionHelper.SignOut();
                return;
            }

            if (!user.CanLogin())
            {
                SessionHelper.SignOut();
                ShowError("Your account is not active. Please contact the coordinator.");
                return;
            }

            // Reject unknown roles and destinations before creating the session.
            string destination = ResolveUrl(user.MustChangePassword ? Constants.Routes.ChangePassword : user.DashboardUrl);
            if (!Enum.IsDefined(typeof(UserRole), user.Role) || !IsApprovedDestination(destination))
            {
                SessionHelper.SignOut();
                ShowError("We could not verify your account access. Please contact the coordinator.");
                return;
            }

            // 3. Save the user in the session.
            SessionHelper.SignIn(user, result.IdToken);

            // Progressive enhancement only: this flag requests presentation, never authorization.
            // No script / reduced motion takes the original immediate server redirect.
            if (Request.Form["campusAnimation"] == "1")
            {
                VerifiedDestination = destination;
                txtPassword.Text = string.Empty;
                btnLogin.Enabled = false;
                // Survives missing/broken scripts, failed WebGL and a stalled animation.
                Response.AddHeader("Refresh", "3; url=" + destination);
            }
            else
            {
                Response.Redirect(destination, false);
                Context.ApplicationInstance.CompleteRequest();
            }
        }

        private bool IsApprovedDestination(string destination)
        {
            string[] routes = { Constants.Routes.ChangePassword,
                "~/Pages/Student/Dashboard.aspx", "~/Pages/Company/Dashboard.aspx",
                "~/Pages/Academic/Dashboard.aspx", "~/Pages/Coordinator/Dashboard.aspx" };
            foreach (string route in routes)
                if (string.Equals(destination, ResolveUrl(route), StringComparison.Ordinal)) return true;
            return false;
        }

        private void ShowError(string message)
        {
            lblError.Text = Server.HtmlEncode(message);
            lblError.Visible = true;
        }
    }
}
