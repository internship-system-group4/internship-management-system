// =============================================================================
//  Schedule a Meeting
//  Owner : Fatima
//  Cards : F08, F10 (OPTIONAL)
//
//  OPTIONAL - do not start this until every core card is done. Date, time, participants and a pasted Zoom join link, saved to Firebase, with back-end access checks via Meeting.CanBeViewedBy.
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
    public partial class Schedule : InternshipManagementSystem.Security.AuthenticatedPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            // TODO(Fatima, F08, F10 (OPTIONAL)): build this page.
        }
    }
}
