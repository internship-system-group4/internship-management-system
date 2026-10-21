// =============================================================================
//  Final Completion Review
//  Owner : Ahmad
//  Cards : A10 - A14
//
//  The last step of the whole workflow: show both final evaluations, approved hours and the university's conditions; compute the final result with GradingService; approve completion; then generate the official PDF report and the certificate. Nothing may be marked complete without this approval.
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

namespace InternshipManagementSystem.Pages.CoordinatorArea
{
    public partial class CompletionReview : InternshipManagementSystem.Security.CoordinatorPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            // TODO(Ahmad, A10 - A14): build this page.
        }
    }
}
