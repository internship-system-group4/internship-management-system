// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad   (shared layout - tell the team before editing)
//  Layout for the Student Portal pages. Shows who is signed in and handles sign-out,
//  so no individual page has to.
// =============================================================================
using System;
using System.Web.UI;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Layout
{
    public partial class StudentMaster : MasterPage
    {
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
