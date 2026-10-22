using System;
using System.Web.UI;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Security;
using InternshipManagementSystem.Data;
namespace InternshipManagementSystem.Layout
{
    public partial class PublicMaster : MasterPage
    {
        protected string PortalActionUrl
        {
            get { return ResolveUrl(SessionHelper.Current == null ? Constants.Routes.Login : SessionHelper.Current.DashboardUrl); }
        }
        protected string PortalActionText { get { return SessionHelper.Current == null ? "Log in" : "My dashboard"; } }
        protected string NavigationAttributes(string path)
        {
            return string.Equals(Request.AppRelativeCurrentExecutionFilePath,path,StringComparison.OrdinalIgnoreCase) ? "aria-current=\"page\"" : "";
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            // Reuse the trusted profile lookup before presenting a role dashboard action.
            // Public content stays available when a cached account can no longer be verified.
            if (SessionHelper.Current == null) return;
            try
            {
                var person = new UserRepository().GetPerson(SessionHelper.Current.Id);
                if (person != null && person.CanLogin()) SessionHelper.Refresh(person);
                else SessionHelper.SignOut();
            }
            catch (FirebaseAuthExpiredException) { SessionHelper.SignOut(); }
            catch (FirebaseException) { SessionHelper.SignOut(); }
            catch (InvalidOperationException) { SessionHelper.SignOut(); }
        }
    }
}
