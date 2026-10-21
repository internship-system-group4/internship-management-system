// =============================================================================
//  Final Academic Evaluation
//  Owner : Suja
//  Cards : S05, S06
//
//  The academic final evaluation form and its submission to the coordinator. CONFIDENTIAL, exactly like the company's form.
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
    public partial class FinalEvaluation : InternshipManagementSystem.Security.AcademicPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            // TODO(Suja, S05, S06): build this page.
        }
    }
}
