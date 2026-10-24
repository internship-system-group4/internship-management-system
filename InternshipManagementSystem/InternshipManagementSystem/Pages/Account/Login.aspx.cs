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

        // No ViewStateUserKey here on purpose: the visitor has no session yet,
        // so the session id can change between showing this form and posting
        // it, which made the login button fail with "Validation of viewstate
        // MAC failed".
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
                        Response.Redirect(ResumeDestination(user) ?? ResolveUrl(user.MustChangePassword ? Constants.Routes.ChangePassword : user.DashboardUrl), false);
                        Context.ApplicationInstance.CompleteRequest();
                        return;
                    }
                    SessionHelper.SignOut();
                    ShowError(L.T("Account.Login.YourAccountIsNotActivePlease"));
                }
                catch (FirebaseAuthExpiredException) { SessionHelper.SignOut(); ShowError(L.T("Account.Login.YourSessionHasExpiredPleaseLog")); }
                catch (FirebaseException) { SessionHelper.SignOut(); ShowError(L.T("Account.Login.WeCouldNotVerifyYourAccount")); }
                catch (InvalidOperationException) { SessionHelper.SignOut(); ShowError(L.T("Account.Login.TheSignInServiceIsNot")); }
            }

            // Messages sent here by the page guard (Security/SecurePage.cs)
            string error = Request.QueryString["error"];
            if (error == "deactivated")
            {
                ShowError(L.T("Account.Login.YourAccountIsNotActivePlease"));
            }
            else if (error == "expired")
            {
                ShowError(L.T("Account.Login.YourSessionHasExpiredPleaseLog"));
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text;

            // Check the input again on the server (JavaScript can be turned off)
            if (email == "" || password == "")
            {
                ShowError(L.T("Account.Login.PleaseEnterYourEmailAndPassword"));
                return;
            }

            if (!Common.Validators.IsEmail(email))
            {
                ShowError(L.T("Account.Login.PleaseEnterAValidEmailAddress"));
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
                ShowError(L.T("Account.Login.WeCouldNotLoadYourAccount"));
                return;
            }
            catch (FirebaseAuthExpiredException)
            {
                SessionHelper.SignOut();
                ShowError(L.T("Account.Login.WeCouldNotVerifyYourAccount2"));
                return;
            }
            catch (InvalidOperationException)
            {
                SessionHelper.SignOut();
                ShowError(L.T("Account.Login.FirebaseIsNotConfiguredYetSee"));
                return;
            }

            if (user == null)
            {
                ShowError(L.T("Account.Login.WeCouldNotVerifyYourAccount3"));
                SessionHelper.SignOut();
                return;
            }

            if (!user.CanLogin())
            {
                SessionHelper.SignOut();
                ShowError(L.T("Account.Login.YourAccountIsNotActivePlease"));
                return;
            }

            // Reject unknown roles and destinations before creating the session.
            string resume = ResumeDestination(user);
            string destination = resume ?? ResolveUrl(user.MustChangePassword ? Constants.Routes.ChangePassword : user.DashboardUrl);
            if (!Enum.IsDefined(typeof(UserRole), user.Role) || (resume == null && !IsApprovedDestination(destination)))
            {
                SessionHelper.SignOut();
                ShowError(L.T("Account.Login.WeCouldNotVerifyYourAccount3"));
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

        // Resume only the fixed student opportunity routes and a single valid key.
        // Eligible accounts are still checked by the destination's StudentPage guard.
        // Everything else still goes to the role dashboard, so this cannot become an open redirect.
        private string ResumeDestination(Person user)
        {
            string requested = Request.QueryString["returnUrl"];
            if (string.IsNullOrEmpty(requested) || user == null || user.Role != UserRole.Student || user.MustChangePassword) return null;
            string browse = ResolveUrl("~/Pages/Student/Opportunities.aspx");
            if (string.Equals(requested, browse, StringComparison.Ordinal)) return browse;
            foreach (string prefix in new[] {
                ResolveUrl("~/Pages/Student/Apply.aspx") + "?opportunityId=",
                ResolveUrl("~/Pages/Student/OpportunityDetails.aspx") + "?id=" })
            {
                if (!requested.StartsWith(prefix, StringComparison.Ordinal)) continue;
                string id = requested.Substring(prefix.Length);
                return ApplicationRepository.IsValidKey(id) ? prefix + Uri.EscapeDataString(id) : null;
            }
            return null;
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
