using System;
using InternshipManagementSystem.Common;
using System.Globalization;
using InternshipManagementSystem.Data;
namespace InternshipManagementSystem.Pages.CoordinatorArea
{
    public partial class PlacementDetails : Security.CoordinatorPage
    {
        protected PlacementProgressData Progress;
        protected string LoadError;
        protected void Page_Load(object sender, EventArgs e)
        {
            string id = Request.QueryString["id"] ?? Request.QueryString["studentId"];
            if (!ApplicationRepository.IsValidKey(id)) { LoadError = L.T("Coordinator.PlacementDetails.ChooseAStudentFromPlacementsProgress"); return; }
            try
            {
                Progress = new CoordinatorMonitoringRepository().LoadDetails(id);
                if (Progress == null) { Response.StatusCode = 404; Response.TrySkipIisCustomErrors = true; LoadError = L.T("Coordinator.PlacementDetails.ThisConfirmedPlacementCouldNotBe"); }
            }
            catch (FirebaseException) { LoadError = L.T("Coordinator.PlacementDetails.WeCouldNotLoadInternshipProgress"); }
            catch (InvalidOperationException) { LoadError = L.T("Coordinator.PlacementDetails.FirebaseIsNotConfiguredContactThe"); }
        }
        protected string Score(double value, double maximum)
        {
            return maximum > 0 ? value.ToString("0.##", CultureInfo.InvariantCulture) + " / " + maximum.ToString("0.##", CultureInfo.InvariantCulture) : L.T("Coordinator.PlacementDetails.NotScored");
        }
        protected string StatusLabel(Enum value) { return System.Text.RegularExpressions.Regex.Replace(value.ToString(), "([a-z])([A-Z])", "$1 $2"); }
        protected bool SafeLink(string value) { return ApplicationRepository.IsSafeDocumentUrl(value) || InternshipManagementSystem.Services.TaskSubmissionStorage.IsSafeUrl(value); }
    }
}
