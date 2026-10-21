// =============================================================================
//  Explore Opportunities
//  Owner : Sara Rajoub
//  Cards : R03
//
//  Open opportunities matching the student's college and major. Opportunity.IsEligible(student) and Opportunity.IsOpenForApplications already hold that logic.
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
    public partial class Opportunities : InternshipManagementSystem.Security.StudentPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            // TODO(Sara Rajoub, R03): build this page.
        }
    }
}
