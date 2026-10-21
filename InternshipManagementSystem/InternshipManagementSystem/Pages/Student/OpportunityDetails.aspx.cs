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

            string id = Request.QueryString["id"];

            if (!ApplicationRepository.IsValidKey(id))
            {
                Notice =
                    "Invalid opportunity link. " +
                    "Please select an opportunity from Explore.";
                return;
            }

            try
            {
                var repository = new OpportunityRepository();

                SelectedOpportunity = repository.GetById(id);

                if (SelectedOpportunity == null)
                {
                    Notice = "Opportunity not found.";
                    return;
                }

                // Students may only view opportunities
                // that match their college and major.
                if (!SelectedOpportunity.IsEligible(CurrentStudent))
                {
                    SelectedOpportunity = null;

                    Notice =
                        "This opportunity is not available " +
                        "for your college or major.";
                    return;
                }

                CanApply =
                    SelectedOpportunity.IsOpenForApplications;

                if (CanApply)
                {
                    ApplyUrl =
                        "Apply.aspx?opportunityId=" +
                        Server.UrlEncode(id);
                }
                else
                {
                    Notice =
                        "This opportunity is no longer " +
                        "accepting applications.";
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError(
                    "Opportunity Details: " + ex
                );

                SelectedOpportunity = null;
                CanApply = false;

                Notice =
                    "Unable to load opportunity details. " +
                    "Please try again later.";
            }
        }

        protected static string DisplayDate(long timestamp)
        {
            return Time.DisplayDate(timestamp);
        }

        protected string EligibleMajorsText
        {
            get
            {
                if (SelectedOpportunity == null ||
                    SelectedOpportunity.EligibleMajors == null ||
                    SelectedOpportunity.EligibleMajors.Count == 0)
                {
                    return "Not specified";
                }

                return string.Join(
                    ", ",
                    SelectedOpportunity.EligibleMajors
                );
            }
        }
    }
}

