// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad  (Trello card A02)
//  Role-based access control for all 40 pages, written once.
// =============================================================================

using System;
using System.Linq;
using System.Web.UI;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Security
{
    /// <summary>
    /// Inherit from this (or from one of the role-specific classes below)
    /// instead of System.Web.UI.Page, and the page is protected.
    ///
    /// This is what makes card A02's requirement true - "a user cannot open
    /// another role's protected pages, including by typing a URL directly" -
    /// for every page at once, instead of 40 hand-written checks of which a
    /// few would certainly be forgotten.
    ///
    /// Three gates run before the page's own Page_Load:
    ///   1. not signed in            -> Login
    ///   2. temporary password       -> Change Password   (card A04)
    ///   3. wrong role, or account deactivated -> Access Denied
    ///
    /// Usage:
    ///     public partial class MyTasks : StudentPage { ... }
    /// and then CurrentStudent is available with no session code at all.
    /// </summary>
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

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            Person user = CurrentUser;

            // 1. anonymous
            if (user == null)
            {
                RedirectTo(Constants.Routes.Login, "returnUrl=" +
                    Server.UrlEncode(Request.Url.PathAndQuery));
                return;
            }

            // 2. deactivated mid-session (card N04) - re-read nothing, the flag
            //    on the cached account is refreshed on the next sign-in, so the
            //    cheap check here is CanLogin()
            if (!user.CanLogin())
            {
                SessionHelper.SignOut();
                RedirectTo(Constants.Routes.Login, "error=deactivated");
                return;
            }

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
            }
        }

        private void RedirectTo(string virtualPath, string query)
        {
            string url = ResolveUrl(virtualPath);
            if (!string.IsNullOrEmpty(query)) url += "?" + query;
            Response.Redirect(url, false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }

    /// <summary>Any signed-in user, whatever their role. Used by the optional
    /// meetings pages, which three different roles share.</summary>
    public abstract class AuthenticatedPage : SecurePage
    {
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
