
using System;

using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.CompanyArea
{
    public partial class ViewOpportunity : CompanyPage
    {
        // Opportunity displayed on the read-only page.
        protected Opportunities.CompanyOpportunity Item;

        // Error message displayed when loading fails.
        protected string ErrorMessage = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            // Verify that the logged-in supervisor
            // belongs to a company.
            if (CurrentSupervisor == null ||
                string.IsNullOrWhiteSpace(
                    CurrentSupervisor.CompanyId))
            {
                ErrorMessage =
                    L.T("Company.ViewOpportunity.YourAccountIsNotLinkedTo");

                return;
            }

            // Read the selected opportunity ID.
            string id = Request.QueryString["id"];

            // Validate the Firebase record key.
            if (string.IsNullOrWhiteSpace(id) ||
                id.IndexOfAny(
                    new char[] { '.', '#', '$', '[', ']', '/' }
                ) >= 0)
            {
                ErrorMessage = L.T("Company.ViewOpportunity.InvalidOpportunityID");
                return;
            }

            try
            {
                // Read the opportunity from Firebase.
                string path =
                    Constants.Paths.Opportunities + "/" + id;

                string json = FirebaseContext.Get(path);

                // Check whether the opportunity exists.
                if (string.IsNullOrWhiteSpace(json) ||
                    json.Trim() == "null")
                {
                    ErrorMessage = L.T("Company.ViewOpportunity.OpportunityNotFound");
                    return;
                }

                // Convert Firebase JSON to the opportunity model.
                Opportunities.CompanyOpportunity opportunity =
                    Json.Deserialize<
                        Opportunities.CompanyOpportunity
                    >(json);

                // Only allow the supervisor to view
                // opportunities belonging to their company.
                if (opportunity == null ||
                    opportunity.CompanyId !=
                        CurrentSupervisor.CompanyId)
                {
                    ErrorMessage =
                        L.T("Company.ViewOpportunity.OpportunityNotFoundOrAccessDenied");

                    return;
                }

                // Use the Firebase key as the opportunity ID.
                opportunity.Id = id;

                // Display the opportunity.
                Item = opportunity;
            }
            catch (Exception ex)
            {
                // Use the full namespace to avoid conflict
                // with the ASP.NET Page.Trace property.
                System.Diagnostics.Trace.TraceError(
                    "View opportunity: " + ex);

                ErrorMessage =
                    L.T("Company.ViewOpportunity.UnableToLoadOpportunityDetails");
            }
        }

        // Format Firebase Unix timestamps as dates.
        protected static string DateText(long value)
        {
            if (value <= 0)
                return L.T("Company.ViewOpportunity.NotSpecified");

            try
            {
                return DateTimeOffset
                    .FromUnixTimeMilliseconds(value)
                    .ToLocalTime()
                    .ToString("yyyy-MM-dd");
            }
            catch (ArgumentOutOfRangeException)
            {
                return L.T("Company.ViewOpportunity.NotSpecified");
            }
        }

        // Display a fallback when a field is empty.
        protected static string Display(string value)
        {
            return string.IsNullOrWhiteSpace(value)
                ? L.T("Company.ViewOpportunity.NotSpecified")
                : value;
        }
    }
}
