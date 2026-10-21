using System;
using System.Web.UI;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Security;
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
        protected void Page_Load(object sender, EventArgs e) { }
    }
}
