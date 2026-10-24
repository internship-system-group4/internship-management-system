
using System;
using System.Collections.Generic;
using System.Linq;

using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.StudentArea
{
    public partial class Opportunities : StudentPage
    {
        protected List<Opportunity> AvailableOpportunities =
            new List<Opportunity>();

        protected Placement ConfirmedPlacement;

        protected string SearchText = "";
        protected string Notice = "";
        protected string StudentCollege = "";
        protected string StudentMajor = "";

        protected bool HasConfirmedInternship
        {
            get { return ConfirmedPlacement != null; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (CurrentStudent == null)
            {
                Notice = L.T(
                    "Student.Opportunities.PleaseSignInAsAStudent");
                return;
            }

            StudentCollege = CurrentStudent.College ?? "";
            StudentMajor = CurrentStudent.Major ?? "";

            try
            {
                // Check whether the student has already
                // confirmed an internship placement.
                ConfirmedPlacement = new PlacementRepository()
                    .GetById(CurrentStudent.Id);

                // If confirmed, do not load other opportunities.
                if (HasConfirmedInternship)
                {
                    AvailableOpportunities.Clear();
                    return;
                }

                if (string.IsNullOrWhiteSpace(StudentCollege) ||
                    string.IsNullOrWhiteSpace(StudentMajor))
                {
                    Notice = "Your college or major is missing. " +
                        L.T(
                            "Student.Opportunities.PleaseContactTheInternshipCoordinator");
                    return;
                }

                SearchText =
                    (Request.QueryString["q"] ?? "").Trim();

                if (SearchText.Length > 100)
                {
                    SearchText = SearchText.Substring(0, 100);
                }

                OpportunityRepository repository =
                    new OpportunityRepository();

                List<Opportunity> allOpportunities =
                    repository.GetAll();

                // Show only open opportunities matching
                // the student's academic program.
                AvailableOpportunities = allOpportunities
                    .Where(o =>
                        o != null &&
                        o.IsOpenForApplications &&
                        o.IsEligible(CurrentStudent))
                    .OrderByDescending(o => o.CreatedAt)
                    .ToList();

                // Search only within eligible opportunities.
                if (!string.IsNullOrWhiteSpace(SearchText))
                {
                    AvailableOpportunities =
                        AvailableOpportunities
                        .Where(o =>
                            ContainsText(o.Title, SearchText) ||
                            ContainsText(o.CompanyName, SearchText) ||
                            ContainsText(o.Location, SearchText) ||
                            ContainsText(o.Description, SearchText))
                        .ToList();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError(
                    "Explore Opportunities Error: " + ex);

                AvailableOpportunities.Clear();

                Notice = "Unable to load opportunities right now. " +
                    L.T(
                        "Student.Opportunities.PleaseTryAgainLater");
            }
        }

        private static bool ContainsText(
            string source,
            string search)
        {
            return !string.IsNullOrWhiteSpace(source) &&
                   source.IndexOf(
                       search,
                       StringComparison.OrdinalIgnoreCase) >= 0;
        }

        protected static string DisplayDate(long timestamp)
        {
            if (timestamp <= 0)
            {
                return L.T(
                    "Student.Opportunities.NotSpecified");
            }

            return Time.DisplayDate(timestamp);
        }

        protected static string ShortDescription(
            string description)
        {
            if (string.IsNullOrWhiteSpace(description))
            {
                return L.T(
                    "Student.Opportunities.ExploreThisInternshipToLearnMore");
            }

            if (description.Length > 155)
            {
                return description.Substring(0, 155)
                    .TrimEnd() + "...";
            }

            return description;
        }

        protected static string DetailsUrl(string id)
        {
            return "OpportunityDetails.aspx?id=" +
                System.Web.HttpUtility.UrlEncode(id ?? "");
        }
    }
}
