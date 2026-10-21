using System;
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
            if (!ApplicationRepository.IsValidKey(id)) { LoadError = "Choose a student from Placements & Progress to view their internship."; return; }
            try
            {
                Progress = new CoordinatorMonitoringRepository().LoadDetails(id);
                if (Progress == null) { Response.StatusCode = 404; Response.TrySkipIisCustomErrors = true; LoadError = "This confirmed placement could not be found."; }
            }
            catch (FirebaseException) { LoadError = "We could not load internship progress. Refresh to try again."; }
            catch (InvalidOperationException) { LoadError = "Firebase is not configured. Contact the project administrator."; }
        }
        protected string Score(double value, double maximum)
        {
            return maximum > 0 ? value.ToString("0.##", CultureInfo.InvariantCulture) + " / " + maximum.ToString("0.##", CultureInfo.InvariantCulture) : "Not scored";
        }
        protected string StatusLabel(Enum value) { return System.Text.RegularExpressions.Regex.Replace(value.ToString(), "([a-z])([A-Z])", "$1 $2"); }
        protected bool SafeLink(string value) { return ApplicationRepository.IsSafeDocumentUrl(value); }
    }
}
