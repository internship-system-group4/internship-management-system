using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;

using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;
using InternshipManagementSystem.Services;

namespace InternshipManagementSystem.Pages.CompanyArea
{
    /// <summary>Add a new opportunity. The rules live in Services/OpportunityFormRules.cs
    /// (shared with the Edit form). Training always lasts 3 months: the supervisor
    /// picks the start date and the end date is set for them.</summary>
    public partial class Opportunities : CompanyPage
    {
        protected string Notice = "";
        protected bool IsError = false;

        protected string CollegeName = Constants.CollegeName;
        protected string[] Majors = Constants.Programs;

        // Errors of the last post, shown under each field.
        protected OpportunityFormRules Form = new OpportunityFormRules();

        // Additional fields required by the Figma design.
        // Inherit from the existing Opportunity model.
        public class CompanyOpportunity : Opportunity
        {
            public string Department { get; set; }
            public string OpportunityType { get; set; }
            public string TrainingMode { get; set; }
            public string TechnologiesUsed { get; set; }
            public long EndDate { get; set; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                return;

            string action = Request.Form["opAction"];

            if (action == "draft" || action == "publish")
                SaveOpportunity(action == "publish");
        }

        private void SaveOpportunity(bool publish)
        {
            if (CurrentSupervisor == null ||
                string.IsNullOrWhiteSpace(CurrentSupervisor.CompanyId))
            {
                ShowError(L.T("Company.Opportunities.YourAccountIsNotLinkedTo"));
                return;
            }

            // Read and check every field at once (a draft only needs a title).
            Form = OpportunityFormRules.Read(Request.Form, "op", Majors);
            Form.Check(publish, true, 0);

            if (!Form.IsValid)
            {
                ShowError(L.T("Company.OpportunityForm.FixErrors"));
                return;
            }

            try
            {
                string id = Guid.NewGuid().ToString("N");
                var opportunity = new CompanyOpportunity();
                opportunity.Id = id;
                opportunity.CompanyId = CurrentSupervisor.CompanyId;

                var company = new CompanyRepository().GetById(CurrentSupervisor.CompanyId);
                opportunity.CompanyName = company != null && !string.IsNullOrWhiteSpace(company.Name)
                    ? company.Name.Trim() : CurrentSupervisor.CompanyName;
                if (string.IsNullOrWhiteSpace(opportunity.CompanyName))
                    throw new InvalidOperationException("The linked company needs a name before creating an opportunity.");
                opportunity.CreatedBySupervisorId = CurrentSupervisor.Id;

                opportunity.Title = Form.Title;
                opportunity.Department = Form.Department;
                opportunity.Location = Form.Location;
                opportunity.Description = Form.Description;
                opportunity.Requirements = Form.Requirements;
                opportunity.TechnologiesUsed = Form.Technologies;
                opportunity.OpportunityType = "Internship";
                opportunity.TrainingMode = Form.Mode;

                opportunity.EligibleCollege = CollegeName;
                opportunity.EligibleMajors = Form.Majors;

                opportunity.TotalSeats = Form.HasSeats ? Form.Seats : 0;
                opportunity.FilledSeats = 0;

                // Students can apply until the end of the last date to apply.
                opportunity.ApplicationDeadline = Form.HasDeadline ? OpportunityFormRules.DayEndMs(Form.Deadline) : 0;
                opportunity.StartDate = Form.HasStart ? OpportunityFormRules.DayStartMs(Form.Start) : 0;
                opportunity.EndDate = Form.HasStart ? OpportunityFormRules.DayStartMs(Form.End) : 0;
                opportunity.DurationWeeks = Form.DurationWeeks;

                opportunity.Status = publish ? OpportunityStatus.Open : OpportunityStatus.Draft;
                opportunity.CreatedAt = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();

                string path = Constants.Paths.Opportunities + "/" + id;
                if (!FirebaseContext.PutIfEmpty(path, opportunity))
                {
                    ShowError(L.T("Company.Opportunities.UnableToSavePleaseTryAgain"));
                    return;
                }

                if (publish)
                {
                    // Tell eligible students and update the public homepage preview.
                    NotificationService.OpportunityPublished(id);
                    new OpportunityRepository().SyncPublicPreview(id);
                }

                // Go back to the list (Post/Redirect/Get) so a refresh or a
                // second click cannot post the same opportunity twice.
                Session["OpportunitySavedNotice"] = publish
                    ? L.T("Company.Opportunities.OpportunityPublishedSuccessfully")
                    : L.T("Company.Opportunities.DraftSavedSuccessfully");
                Response.Redirect("ManageOpportunities.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Create opportunity: " + ex);
                ShowError(L.T("Company.Opportunities.UnableToSaveTheOpportunityIn"));
            }
        }

        // ---- Helpers used by the markup ----

        protected string Today
        {
            get { return DateTime.Today.ToString("yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture); }
        }

        protected string MessagesJson
        {
            get { return new JavaScriptSerializer().Serialize(OpportunityFormRules.ScriptMessages()); }
        }

        /// <summary>The posted value, so nothing typed is lost when a check fails.</summary>
        protected string Posted(string name)
        {
            return IsPostBack ? (Request.Form[name] ?? "").Trim() : "";
        }

        protected string Error(string field) { return Form.ErrorFor(field); }

        protected string Invalid(string field)
        {
            return string.IsNullOrEmpty(Form.ErrorFor(field)) ? "" : " is-invalid";
        }

        protected string Hidden(string field)
        {
            return string.IsNullOrEmpty(Form.ErrorFor(field)) ? "hidden" : "";
        }

        protected string Selected(string name, string value, bool isDefault)
        {
            string posted = IsPostBack ? Request.Form[name] : null;
            bool selected = string.IsNullOrEmpty(posted) ? isDefault : posted == value;
            return selected ? "selected" : "";
        }

        protected string MajorChecked(string major)
        {
            string[] posted = IsPostBack ? Request.Form.GetValues("opMajors") : null;
            return posted != null && posted.Contains(major) ? "checked" : "";
        }

        protected string AutoEndText
        {
            get { return Form.HasStart ? OpportunityFormRules.Show(Form.End) : "—"; }
        }

        protected string DurationText
        {
            get
            {
                return Form.HasStart
                    ? L.F("Company.OpportunityForm.Duration", OpportunityFormRules.Show(Form.Start), OpportunityFormRules.Show(Form.End))
                    : L.T("Company.OpportunityForm.DurationEmpty");
            }
        }

        private void ShowError(string message)
        {
            Notice = message;
            IsError = true;
        }
    }
}
