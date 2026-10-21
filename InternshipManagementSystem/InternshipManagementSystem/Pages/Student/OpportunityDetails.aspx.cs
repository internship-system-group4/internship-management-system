// =============================================================================
//  Opportunity Details
//  Owner : Sara Rajoub
//  Cards : R04
//
//  Full details and an Apply button. Pass the opportunity id on to Apply.aspx - that hand-off is the contract with Osama's card O01.
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
    public partial class OpportunityDetails : InternshipManagementSystem.Security.StudentPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            // TODO(Sara Rajoub, R04): build this page.
        }
    }
}
