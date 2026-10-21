// =============================================================================
//  Access Denied
//  Owner : Ahmad
//  Cards : A02
//
//  Security/SecurePage.cs sends a signed-in user here when their role may not
//  open a page. The button takes them back to their own dashboard.
//
//  Namespace note: these page namespaces end in "Area" on purpose. A namespace
//  called ...Pages.Student would hide the Student model class and every file in
//  the folder would fail to compile with "Student is a namespace but is used
//  like a type". Keep the suffix.
// =============================================================================
using System;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.PublicArea
{
    public partial class AccessDenied : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Person user = SessionHelper.Current;

            if (user != null)
            {
                lnkBack.Text = "Go to my dashboard";
                lnkBack.NavigateUrl = user.DashboardUrl;
            }
            else
            {
                lnkBack.Text = "Go to login";
                lnkBack.NavigateUrl = Constants.Routes.Login;
            }
        }
    }
}
