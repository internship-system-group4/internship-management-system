using System;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.CoordinatorArea
{
    public partial class AddStudent : CoordinatorPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Response.Redirect(ResolveUrl("~/Pages/Coordinator/Students.aspx?create=student"), false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
