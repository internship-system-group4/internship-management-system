// =============================================================================
//  Explore Opportunities
//  Owner : Sara Rajoub
//  Cards : R03
//
//  Open opportunities matching the student's college and major. Opportunity.IsEligible(student) and Opportunity.IsOpenForApplications already hold that logic.
//
//  Namespace note: these page namespaces end in "Area" on purpose. A namespace
//  called ...Pages.Student would hide the Student model class and every file in
//  the folder would fail to compile with "Student is a namespace but is used
//  like a type". Keep the suffix.
// =============================================================================



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

        protected Dictionary<string, InternshipApplication> ApplicationsByOpportunity =
            new Dictionary<string, InternshipApplication>(StringComparer.OrdinalIgnoreCase);

        protected bool HasApplied(string opportunityId)
        {
            return !string.IsNullOrEmpty(opportunityId) && ApplicationsByOpportunity.ContainsKey(opportunityId);
        }

        protected string ApplicationLabel(string opportunityId)
        {
            InternshipApplication application;
            return ApplicationsByOpportunity.TryGetValue(opportunityId ?? "", out application)
                ? L.T("Student.Opportunities.Applied") + " · " + L.Value("Ui", application.Status)
                : L.T("Student.Opportunities.Open");
        }

        protected string CompanyNameFor(Opportunity opportunity)
        {
            if (!string.IsNullOrWhiteSpace(opportunity.CompanyName))
                return opportunity.CompanyName;
            InternshipApplication application;
            if (ApplicationsByOpportunity.TryGetValue(opportunity.Id ?? "", out application)
                && !string.IsNullOrWhiteSpace(application.CompanyName))
                return application.CompanyName;
            return "Partner Company";
        }

        protected string SearchText = "";
        protected string Notice = "";
        protected string StudentCollege = "";
        protected string StudentMajor = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (CurrentStudent == null)
            {
                Notice = L.T("Student.Opportunities.PleaseSignInAsAStudent");
                return;
            }

            // Academic information is read from the logged-in student.
            // Students cannot change their college or major here.
            StudentCollege = CurrentStudent.College ?? "";
            StudentMajor = CurrentStudent.Major ?? "";

            if (string.IsNullOrWhiteSpace(StudentCollege) ||
                string.IsNullOrWhiteSpace(StudentMajor))
            {
                Notice = "Your college or major is missing. " +
                         L.T("Student.Opportunities.PleaseContactTheInternshipCoordinator");
                return;
            }

            SearchText = (Request.QueryString["q"] ?? "").Trim();

            if (SearchText.Length > 100)
            {
                SearchText = SearchText.Substring(0, 100);
            }

            try
            {
                OpportunityRepository repository =
                    new OpportunityRepository();

                List<Opportunity> allOpportunities =
                    repository.GetAll();
                ApplicationsByOpportunity = new ApplicationRepository()
                    .GetByStudent(CurrentStudent.Id)
                    .Where(a => !string.IsNullOrWhiteSpace(a.OpportunityId))
                    .ToDictionary(a => a.OpportunityId, StringComparer.OrdinalIgnoreCase);

                // R03: Only open opportunities that match the student's
                // college and major can be displayed.
                AvailableOpportunities = allOpportunities
                    .Where(o =>
                        o != null &&
                        o.IsOpenForApplications &&
                        o.IsEligible(CurrentStudent))
                    .OrderByDescending(o => o.CreatedAt)
                    .ToList();

                // Optional search within eligible opportunities only.
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
                    "Explore Opportunities Error: " + ex.ToString()
                );

                AvailableOpportunities.Clear();

                Notice = "Unable to load opportunities right now. " +
                         L.T("Student.Opportunities.PleaseTryAgainLater");
            }
        }

        private static bool ContainsText(string source, string search)
        {
            return !string.IsNullOrWhiteSpace(source) &&
                   source.IndexOf(
                       search,
                       StringComparison.OrdinalIgnoreCase
                   ) >= 0;
        }

        protected static string DisplayDate(long timestamp)
        {
            if (timestamp <= 0)
            {
                return L.T("Student.Opportunities.NotSpecified");
            }

            return Time.DisplayDate(timestamp);
        }

        protected static string ShortDescription(string description)
        {
            if (string.IsNullOrWhiteSpace(description))
            {
                return L.T("Student.Opportunities.ExploreThisInternshipToLearnMore");
            }

            if (description.Length > 155)
            {
                return description.Substring(0, 155).TrimEnd() + "...";
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
