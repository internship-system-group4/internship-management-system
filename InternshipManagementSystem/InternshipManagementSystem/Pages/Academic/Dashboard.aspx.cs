// =============================================================================
//  Academic Dashboard
//  Owner : Suja
//  Cards : S01
//
//  Students assigned to this supervisor by the coordinator, with internship status and progress. UserRepository.GetStudentsBySupervisor does the filtering.
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
    public partial class Dashboard : InternshipManagementSystem.Security.AcademicPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            // TODO(Suja, S01): build this page.
        }
    }
}
