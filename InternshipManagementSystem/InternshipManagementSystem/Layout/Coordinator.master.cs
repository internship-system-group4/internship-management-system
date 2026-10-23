// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad   (shared layout - tell the team before editing)
//  Layout for the Coordinator pages. Shows who is signed in and handles sign-out,
//  so no individual page has to.
// =============================================================================
using System;
using System.Web.UI;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Layout
{
    public partial class CoordinatorMaster : MasterPage
    {
        protected void btnSignOut_Click(object sender, EventArgs e)
        {
            SessionHelper.SignOut();
            Response.Redirect(ResolveUrl(Constants.Routes.Login));
        }
    }
}
