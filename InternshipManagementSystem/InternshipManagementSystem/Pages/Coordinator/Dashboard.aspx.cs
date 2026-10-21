using System;
using InternshipManagementSystem.Data;
namespace InternshipManagementSystem.Pages.CoordinatorArea
{
    public partial class Dashboard : Security.CoordinatorPage
    {
        protected CoordinatorDashboardData Summary;
        protected string LoadError;
        protected void Page_Load(object sender, EventArgs e)
        {
            try { Summary = new CoordinatorMonitoringRepository().LoadDashboard(); }
            catch (FirebaseException) { LoadError = "We could not load the dashboard. Refresh to try again."; }
            catch (InvalidOperationException) { LoadError = "Firebase is not configured. Contact the project administrator."; }
        }
    }
}
