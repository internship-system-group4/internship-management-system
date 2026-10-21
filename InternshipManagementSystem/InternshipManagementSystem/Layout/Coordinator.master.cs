// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad   (shared layout - tell the team before editing)
//  Layout for the Coordinator pages. Shows who is signed in and handles sign-out,
//  so no individual page has to.
// =============================================================================
using System;
using System.Linq;
using System.Web.UI;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Layout
{
    public partial class CoordinatorMaster : MasterPage
    {
        protected string UserInitials
        {
            get
            {
                var user = SessionHelper.Current;
                if (user == null || string.IsNullOrWhiteSpace(user.FullName)) return "";
                return string.Concat(user.FullName.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries)
                    .Take(2).Select(name => name.Substring(0, 1))).ToUpperInvariant();
            }
        }

        protected string NavigationAttributes(string path)
        {
            string current = Request.AppRelativeCurrentExecutionFilePath;
            if (string.Equals(current, "~/Pages/Meetings/Schedule.aspx", StringComparison.OrdinalIgnoreCase))
                current = "~/Pages/Meetings/MyMeetings.aspx";
            else if (string.Equals(current, "~/Pages/Coordinator/PlacementDetails.aspx", StringComparison.OrdinalIgnoreCase))
                current = "~/Pages/Coordinator/Placements.aspx";
            return string.Equals(current, path, StringComparison.OrdinalIgnoreCase)
                ? "aria-current=\"page\"" : "";
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            Person user = SessionHelper.Current;
            if (user == null) return;

            litUserName.Text = Validators.Safe(user.FullName);
            litRoleName.Text = Validators.Safe(user.RoleDisplayName);
        }

        protected void btnSignOut_Click(object sender, EventArgs e)
        {
            SessionHelper.SignOut();
            Response.Redirect(ResolveUrl(Constants.Routes.Login));
        }
    }
}
