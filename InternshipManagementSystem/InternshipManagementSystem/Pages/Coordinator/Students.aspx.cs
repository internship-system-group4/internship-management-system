// =============================================================================
//  Manage Students
//  Owner : Ahmad
//  Cards : A05, A06
//
//  Create student accounts with a temporary password through AuthService.CreateAccount, save the profile at users/{uid}, and provide a searchable list with edit. Set MustChangePassword = true on creation.
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

namespace InternshipManagementSystem.Pages.CoordinatorArea
{
    public partial class Students : InternshipManagementSystem.Security.CoordinatorPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            // TODO(Ahmad, A05, A06): build this page.
        }
    }
}
