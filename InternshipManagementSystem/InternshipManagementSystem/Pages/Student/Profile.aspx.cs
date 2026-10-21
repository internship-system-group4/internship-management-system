// =============================================================================
//  My Profile
//  Owner : Sara Rajoub
//  Cards : R06, R07
//
//  Show academic data read-only and let the student edit permitted personal fields plus a CV or portfolio link. University, college, major and required hours are coordinator-controlled and must stay locked.
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
    public partial class Profile : InternshipManagementSystem.Security.StudentPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            // TODO(Sara Rajoub, R06, R07): build this page.
        }
    }
}
