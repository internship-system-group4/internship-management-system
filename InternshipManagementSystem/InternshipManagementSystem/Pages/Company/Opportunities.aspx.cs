// =============================================================================
//  Manage Opportunities
//  Owner : Sara Rajoub
//  Cards : R01, R02
//
//  Create, edit and close this company's opportunities, with majors, requirements and seat count. A supervisor must not be able to touch another company's rows.
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
    public partial class Opportunities : InternshipManagementSystem.Security.CompanyPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            // TODO(Sara Rajoub, R01, R02): build this page.
        }
    }
}
