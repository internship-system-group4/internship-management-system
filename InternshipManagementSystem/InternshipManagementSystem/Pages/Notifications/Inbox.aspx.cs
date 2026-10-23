using System;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.Notifications
{
    public class Inbox : AuthenticatedPage
    {
        protected override void OnPreInit(EventArgs e)
        {
            var user = SessionHelper.Current;
            string layout = user == null ? "Student" : user.Role == UserRole.Coordinator ? "Coordinator" :
                user.Role == UserRole.AcademicSupervisor ? "Academic" : user.Role == UserRole.CompanySupervisor ? "Company" : "Student";
            MasterPageFile = "~/Layout/" + layout + ".master";
            base.OnPreInit(e);
        }
    }
}
