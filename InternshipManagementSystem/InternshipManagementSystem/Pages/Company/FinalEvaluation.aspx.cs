// =============================================================================
//  Reports & Final Evaluation
//  Owner : Nada
//  Cards : N08, N09
//
//  The company's final evaluation on the university's criteria, then send it to the student's assigned academic supervisor. CONFIDENTIAL: the student may never see this form.
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
    public partial class FinalEvaluation : InternshipManagementSystem.Security.CompanyPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            // TODO(Nada, N08, N09): build this page.
        }
    }
}
