// =============================================================================
//  My Tasks
//  Owner : Fatima
//  Cards : F03, F04
//
//  The student's own tasks with deadlines and statuses, and the submission form for text, a link or a file. Each submission is a new Submission record with an incremented AttemptNumber - never overwrite the previous attempt.
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

namespace InternshipManagementSystem.Pages.StudentArea
{
    public partial class MyTasks : InternshipManagementSystem.Security.StudentPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            // TODO(Fatima, F03, F04): build this page.
        }
    }
}
