// =============================================================================
//  My Account
//  Owner : Nada
//  Cards : N10
//
//  Permitted profile fields only. A supervisor must not be able to change their own role or company association.
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

namespace InternshipManagementSystem.Pages.CompanyArea
{
    public partial class Account : InternshipManagementSystem.Security.CompanyPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            // TODO(Nada, N10): build this page.
        }
    }
}
