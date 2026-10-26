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
        protected InternshipApplication ExistingApplication;
        protected bool CanApply = false;
        protected string ApplyUrl = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (CurrentStudent == null)
            {
                Notice = L.T("Student.OpportunityDetails.PleaseSignInAsAStudent");
                return;
            }

            string opportunityId = Request.QueryString["id"];

            // Check that the opportunity ID is safe and valid.
            if (!ApplicationRepository.IsValidKey(opportunityId))
            {
                Notice = "Invalid opportunity link. " +
                         L.T("Student.OpportunityDetails.PleaseSelectAnOpportunityFromExplore");
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
                    Notice = L.T("Student.OpportunityDetails.ThisOpportunityCouldNotBeFound");
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
                ExistingApplication = new ApplicationRepository().GetByStudent(CurrentStudent.Id)
                    .FirstOrDefault(a => string.Equals(a.OpportunityId, opportunityId,
                        StringComparison.OrdinalIgnoreCase));
                // A student with a confirmed internship cannot apply anywhere else.
                bool hasPlacement = new PlacementRepository().Exists(CurrentStudent.Id);
                CanApply = SelectedOpportunity.IsOpenForApplications && ExistingApplication == null && !hasPlacement;

                if (hasPlacement && ExistingApplication == null)
                {
                    Notice = L.T("Student.Apply.YouAlreadyHaveAConfirmedInternship") + " " +
                             L.T("Student.Opportunities.YouCannotApplyToOtherInternships");
                }
                else if (CanApply || ExistingApplication != null)
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
                         L.T("Student.OpportunityDetails.PleaseTryAgainLater");
            }
        }

        protected string CompanyNameText
        {
            get
            {
                if (SelectedOpportunity == null)
                {
                    return L.T("Student.OpportunityDetails.NotSpecified");
                }

                string name = SelectedOpportunity.CompanyName;
                if (string.IsNullOrWhiteSpace(name) && ExistingApplication != null)
                    name = ExistingApplication.CompanyName;
                return ValueOrDefault(name);
            }
        }

        protected static string ValueOrDefault(string value)
        {
            if (string.IsNullOrWhiteSpace(value))
            {
                return L.T("Student.OpportunityDetails.NotSpecified");
            }

            return value;
        }

        protected static string DisplayDate(long timestamp)
        {
            if (timestamp <= 0)
            {
                return L.T("Student.OpportunityDetails.NotSpecified");
            }

            return Time.DisplayDate(timestamp);
        }
    }
}

