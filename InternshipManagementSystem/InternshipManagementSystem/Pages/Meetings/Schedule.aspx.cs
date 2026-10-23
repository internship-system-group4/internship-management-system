using System;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.MeetingsArea
{
    public partial class Schedule : AuthenticatedPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Response.Redirect(
                ResolveUrl("~/Pages/Meetings/MyMeetings.aspx"),
                true);
        }
    }
}