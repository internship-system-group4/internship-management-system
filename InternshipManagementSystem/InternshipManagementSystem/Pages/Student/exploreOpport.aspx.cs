using System;
using InternshipManagementSystem.Security;
namespace InternshipManagementSystem.Pages.StudentArea
{
    // Legacy bookmark: the current student opportunities page owns this workflow.
    public partial class exploreOpport : StudentPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Response.Redirect("~/Pages/Student/Opportunities.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
