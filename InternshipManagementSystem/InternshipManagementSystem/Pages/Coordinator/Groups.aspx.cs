// =============================================================================
//  Groups & Assignments
//  Owner : Ahmad
//  Cards : A08, A09
//
//  Organise students into groups, assign one academic supervisor per group, and allow reassignment. Write both StudentGroup.AcademicSupervisorId and each Student.AcademicSupervisorId, or Suja's dashboard will come up empty.
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
    public partial class Groups : InternshipManagementSystem.Security.CoordinatorPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            // TODO(Ahmad, A08, A09): build this page.
        }
    }
}
