// =============================================================================
//  My Meetings
//  Owner : Fatima
//  Cards : F09 (OPTIONAL)
//
//  OPTIONAL - each participant sees only their own meetings, with join links.
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

namespace InternshipManagementSystem.Pages.MeetingsArea
{
    public partial class MyMeetings : InternshipManagementSystem.Security.AuthenticatedPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            // TODO(Fatima, F09 (OPTIONAL)): build this page.
        }
    }
}
