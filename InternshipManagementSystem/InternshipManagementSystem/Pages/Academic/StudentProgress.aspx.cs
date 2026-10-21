// =============================================================================
//  Student Progress Monitor
//  Owner : Suja
//  Cards : S02, S03, S04
//
//  One assigned student's company, supervisor, tasks, submissions, evaluations, hours, delays and feedback; academic comments; and the training-hours approval decisions. Use HoursService.Decide so the cached totals stay correct.
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
    public partial class StudentProgress : InternshipManagementSystem.Security.AcademicPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            // TODO(Suja, S02, S03, S04): build this page.
        }
    }
}
