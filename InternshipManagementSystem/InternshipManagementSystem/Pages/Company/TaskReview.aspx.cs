// =============================================================================
//  Review Submissions
//  Owner : Fatima
//  Cards : F05, F06, F07
//
//  Inspect a submission, grade it against the task's criteria, leave feedback, or request a revision. The full attempt history must stay readable afterwards - that is card F07 and it is part of the live demo.
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
    public partial class TaskReview : InternshipManagementSystem.Security.CompanyPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            // TODO(Fatima, F05, F06, F07): build this page.
        }
    }
}
