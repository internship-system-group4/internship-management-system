// =============================================================================
//  My Progress & Evaluation
//  Owner : Ahmad
//  Cards : A15, A16
//
//  Task grades, supervisor feedback, submission and revision history, APPROVED training hours and overall progress - plus the final result and report download once the coordinator approves. The confidential final evaluation forms must never appear here; use the EvaluationRepository methods named for task evaluations only.
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
    public partial class Progress : InternshipManagementSystem.Security.StudentPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            // TODO(Ahmad, A15, A16): build this page.
        }
    }
}
