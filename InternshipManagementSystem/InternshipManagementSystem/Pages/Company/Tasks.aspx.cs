// =============================================================================
//  Manage Tasks
//  Owner : Fatima
//  Cards : F01, F02
//
//  Create tasks with title, description, instructions, deadline, trainee and evaluation criteria, and list them with their submission statuses. Set each task's MaxScore and Weight from the university's method - not a flat 100.
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
    public partial class Tasks : InternshipManagementSystem.Security.CompanyPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            // TODO(Fatima, F01, F02): build this page.
        }
    }
}
