// =============================================================================
//  Opportunity Details
//  Owner : Sara Rajoub
//  Cards : R04
//
//  Full details and an Apply button. Pass the opportunity id on to Apply.aspx - that hand-off is the contract with Osama's card O01.
//
//  Namespace note: these page namespaces end in "Area" on purpose. A namespace
//  called ...Pages.Student would hide the Student model class and every file in
//  the folder would fail to compile with "Student is a namespace but is used
//  like a type". Keep the suffix.
// =============================================================================


using System;
using System.Linq;
using System.Web;

using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.StudentArea
{
    public partial class OpportunityDetails : StudentPage
    {
        protected Opportunity SelectedOpportunity;

        protected string Notice = "";
        protected bool CanApply = false;
        protected string ApplyUrl = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (CurrentStudent == null)
            {
                Notice = "Please sign in as a student.";
                return;
            }

            string opportunityId = Request.QueryString["id"];

            // Check that the opportunity ID is safe and valid.
            if (!ApplicationRepository.IsValidKey(opportunityId))
            {
                Notice = "Invalid opportunity link. " +
                         "Please select an opportunity from Explore Opportunities.";
                return;
            }

            try
            {
                OpportunityRepository repository =
                    new OpportunityRepository();

                SelectedOpportunity =
                    repository.GetById(opportunityId);

                if (SelectedOpportunity == null)
                {
                    Notice = "This opportunity could not be found.";
                    return;
                }

                // The student can only view eligible opportunities.
                if (!SelectedOpportunity.IsEligible(CurrentStudent))
                {
                    SelectedOpportunity = null;

                    Notice = "This opportunity is not available " +
                             "for your college or major.";
                    return;
                }

                // The model checks status, deadline and remaining seats.
                CanApply = SelectedOpportunity.IsOpenForApplications;

                if (CanApply)
                {
                    // Osama's Apply.aspx expects opportunityId.
                    ApplyUrl = "Apply.aspx?opportunityId=" +
                               HttpUtility.UrlEncode(opportunityId);
                }
                else
                {
                    Notice = "This opportunity is no longer " +
                             "accepting applications.";
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError(
                    "Opportunity Details Error: " + ex.ToString()
                );

                SelectedOpportunity = null;
                CanApply = false;

                Notice = "Unable to load opportunity details. " +
                         "Please try again later.";
            }
        }

        protected string CompanyNameText
        {
            get
            {
                if (SelectedOpportunity == null)
                {
                    return "Not specified";
                }

                return ValueOrDefault(
                    SelectedOpportunity.CompanyName
                );
            }
        }

        protected static string ValueOrDefault(string value)
        {
            if (string.IsNullOrWhiteSpace(value))
            {
                return "Not specified";
            }

            return value;
        }

        protected static string DisplayDate(long timestamp)
        {
            if (timestamp <= 0)
            {
                return "Not specified";
            }

            return Time.DisplayDate(timestamp);
        }
    }
}

