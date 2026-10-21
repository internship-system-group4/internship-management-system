// =============================================================================
//  Manage Companies
//  Owner : Nada
//  Cards : N03, N04
//
//  The coordinator - not the company - creates company supervisor accounts here, and activates or deactivates them. Use the same AuthService + UserRepository pair as Manage Students so every account is provisioned identically.
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
    public partial class Companies : InternshipManagementSystem.Security.CoordinatorPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            // TODO(Nada, N03, N04): build this page.
        }
    }
}
