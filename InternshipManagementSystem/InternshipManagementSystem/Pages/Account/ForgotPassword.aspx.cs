// =============================================================================
//  Password Recovery
//  Owner : Ahmad
//  Cards : A03
//
//  Request a Firebase password-reset email. AuthService.SendPasswordResetEmail already reports success either way so the page never reveals whether an address exists.
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
    public partial class ForgotPassword : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            // TODO(Ahmad, A03): build this page.
        }
    }
}
