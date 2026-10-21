// =============================================================================
//  My Account
//  Owner : Suja
//  Cards : S07
//
//  Account information with permitted updates only.
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

namespace InternshipManagementSystem.Pages.AcademicArea
{
    public partial class Account : InternshipManagementSystem.Security.AcademicPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            // TODO(Suja, S07): build this page.
        }
    }
}
