// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad  (Trello card A02)
//  Role-based access control for all 40 pages, written once.
// =============================================================================

using System;
using System.Linq;
using System.Web.UI;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Security
{
    // Role-specific base pages protect access before page handlers run.
    public abstract class SecurePage : Page
    {
        /// <summary>Roles allowed to open this page.</summary>
        protected abstract UserRole[] AllowedRoles { get; }

        /// <summary>Only the change-password page itself overrides this to
        /// true; without the exemption gate 2 would redirect to itself for
        /// ever.</summary>
        protected virtual bool AllowWhilePasswordChangePending
        {
            get { return false; }
        }

        protected Person CurrentUser
        {
            get { return SessionHelper.Current; }
        }

        protected override void OnPreInit(EventArgs e)
        {
            // Do not let the browser cache protected pages, so the Back button
            // cannot show them again after logout.
            Response.Cache.SetCacheability(System.Web.HttpCacheability.NoCache);
            Response.Cache.SetNoStore();

            Person user = CurrentUser;

            // 1. anonymous
            if (user == null)
            {
                RedirectTo(Constants.Routes.Login, "returnUrl=" +
                    Server.UrlEncode(Request.Url.PathAndQuery));
                return;
            }

            // 2. Re-read the account on every protected request, so deactivation,
            //    deletion and permission changes take effect. A failed lookup must
            //    not use stale access.
            //    Speed: the account and the top-bar notifications are fetched
            //    together (one wait instead of two). Every postback - the only way
            //    to change anything - asks Firebase directly. Simply opening a page
            //    may reuse the read from the last few seconds (Firebase.ReadCacheSeconds);
            //    a deactivation saved on this server clears that copy at once.
            FirebaseRead[] accountReads =
            {
                FirebaseRead.Node(Constants.Paths.Users + "/" + user.Id),
                FirebaseRead.Last(Constants.Paths.Notifications + "/" + user.Id, Layout.NotificationBell.CountWindow)
            };
            if (IsPostBackRequest) FirebaseContext.Reload(accountReads);
            else FirebaseContext.Prefetch(accountReads);
            user = new UserRepository().GetPerson(user.Id);
            if (user == null || !user.CanLogin())
            {
                SessionHelper.SignOut();
                RedirectTo(Constants.Routes.Login, "error=deactivated");
                return;
            }
            SessionHelper.Refresh(user);

            // 3. temporary password still in place (card A04)
            if (user.MustChangePassword && !AllowWhilePasswordChangePending)
            {
                RedirectTo(Constants.Routes.ChangePassword, null);
                return;
            }

            // 4. wrong role
            if (AllowedRoles != null && !AllowedRoles.Contains(user.Role))
            {
                RedirectTo(Constants.Routes.AccessDenied, null);
                return;
            }

            base.OnPreInit(e);
        }

        /// <summary>IsPostBack is not ready yet in PreInit, so look at the HTTP method.</summary>
        private bool IsPostBackRequest
        {
            get { return !string.Equals(Request.HttpMethod, "GET", StringComparison.OrdinalIgnoreCase); }
        }

        private void RedirectTo(string virtualPath, string query)
        {
            string url = ResolveUrl(virtualPath);
            if (!string.IsNullOrEmpty(query)) url += "?" + query;
            // End the response as well as redirecting. CompleteRequest alone
            // does not stop the Web Forms lifecycle or postback handlers.
            Response.Redirect(url, true);
        }

        protected override void OnError(EventArgs e)
        {
            // Page errors can wrap exceptions thrown in any lifecycle event.
            Exception error = Server.GetLastError();
            while (error != null)
            {
                if (error is FirebaseAuthExpiredException)
                {
                    Server.ClearError();
                    SessionHelper.SignOut();
                    RedirectTo(Constants.Routes.Login, "error=expired");
                    return;
                }
                error = error.InnerException;
            }
            base.OnError(e);
        }
    }

    /// <summary>Any signed-in user, whatever their role. Used by the optional
    /// meetings pages, which three different roles share.</summary>
    public abstract class AuthenticatedPage : SecurePage
    {
        protected override void OnPreInit(EventArgs e)
        {
            // Keep all authentication/activation/password checks before selecting a role shell.
            base.OnPreInit(e);
            if (!Request.AppRelativeCurrentExecutionFilePath.StartsWith(
                "~/Pages/Meetings/", StringComparison.OrdinalIgnoreCase)) return;
            switch (CurrentUser.Role)
            {
                case UserRole.Student: MasterPageFile = "~/Layout/Student.master"; break;
                case UserRole.CompanySupervisor: MasterPageFile = "~/Layout/Company.master"; break;
                case UserRole.AcademicSupervisor: MasterPageFile = "~/Layout/Academic.master"; break;
                case UserRole.Coordinator: MasterPageFile = "~/Layout/Coordinator.master"; break;
            }
        }

        protected override UserRole[] AllowedRoles
        {
            get
            {
                return new[]
                {
                    UserRole.Student,
                    UserRole.CompanySupervisor,
                    UserRole.AcademicSupervisor,
                    UserRole.Coordinator
                };
            }
        }
    }
}
