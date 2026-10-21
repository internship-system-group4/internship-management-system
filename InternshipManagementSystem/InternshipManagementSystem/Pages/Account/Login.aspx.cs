// =============================================================================
//  Login
//  Owner : Ahmad
//  Cards : A01, A02
//
//  Email and password, show/hide password, validation, clear errors. On success call AuthService.SignIn, load the account with UserRepository.GetPerson, then SessionHelper.SignIn and redirect to user.DashboardUrl.
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

namespace InternshipManagementSystem.Pages.AccountArea
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            // TODO(Ahmad, A01, A02): build this page.
        }
    }
}
