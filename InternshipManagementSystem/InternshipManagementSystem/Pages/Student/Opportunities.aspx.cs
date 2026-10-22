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

        protected string SearchText = "";
        protected string Notice = "";
        protected string StudentCollege = "";
        protected string StudentMajor = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (CurrentStudent == null)
            {
                Notice = "Please sign in as a student.";
                return;
            }

            StudentCollege = CurrentStudent.College ?? "";
            StudentMajor = CurrentStudent.Major ?? "";

            if (string.IsNullOrWhiteSpace(StudentCollege) ||
                string.IsNullOrWhiteSpace(StudentMajor))
            {
                Notice =
                    "Your college or major is missing. " +
                    "Please contact the university coordinator.";
                return;
            }

            try
            {
                SearchText =
                    (Request.QueryString["q"] ?? "").Trim();

                if (SearchText.Length > 100)
                {
                    SearchText = SearchText.Substring(0, 100);
                }

                var repository = new OpportunityRepository();

                AvailableOpportunities = repository.GetAll()
                    .Where(o =>
                        o != null &&
                        o.IsOpenForApplications &&
                        o.IsEligible(CurrentStudent))
                    .OrderByDescending(o => o.CreatedAt)
                    .ToList();

                if (!string.IsNullOrWhiteSpace(SearchText))
                {
                    AvailableOpportunities =
                        AvailableOpportunities.Where(o =>
                            ContainsText(o.Title, SearchText) ||
                            ContainsText(o.CompanyName, SearchText) ||
                            ContainsText(o.Location, SearchText) ||
                            ContainsText(o.Description, SearchText) ||
                            ContainsText(o.Requirements, SearchText)
                        ).ToList();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError(
                    "Explore Opportunities: " + ex
                );

                AvailableOpportunities.Clear();

                Notice =
                    "Unable to load opportunities right now. " +
                    "Please try again later.";
            }
        }

        private static bool ContainsText(
            string source,
            string search)
        {
            return !string.IsNullOrEmpty(source) &&
                source.IndexOf(
                    search,
                    StringComparison.OrdinalIgnoreCase
                ) >= 0;
        }

        protected static string DisplayDate(long timestamp)
        {
            return Time.DisplayDate(timestamp);
        }

        protected static string DetailsUrl(string id)
        {
            return "OpportunityDetails.aspx?id=" +
                System.Web.HttpUtility.UrlEncode(id ?? "");
        }
    }
}
