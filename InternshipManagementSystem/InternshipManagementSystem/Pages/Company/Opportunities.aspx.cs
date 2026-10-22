// =============================================================================
//  Manage Opportunities
//  Owner : Sara Rajoub
//  Cards : R01, R02
//
//  (Create on this page), edit and close this company's opportunities, with majors, requirements and seat count. A supervisor must not be able to touch another company's rows.
//
//  Namespace note: these page namespaces end in "Area" on purpose. A namespace
//  called ...Pages.Student would hide the Student model class and every file in
//  the folder would fail to compile with "Student is a namespace but is used
//  like a type". Keep the suffix.
// =============================================================================


using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;

using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.CompanyArea
{
    public partial class Opportunities : CompanyPage
    {
        protected string Notice = "";
        protected bool IsError = false;

        protected string CollegeName = Constants.CollegeName;
        protected string[] Majors = Constants.Programs;

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
            {
                SaveOpportunity(action == "publish");
            }
        }

        private void SaveOpportunity(bool publish)
        {
            if (CurrentSupervisor == null ||
                string.IsNullOrWhiteSpace(CurrentSupervisor.CompanyId))
            {
                ShowError("Your account is not linked to a company.");
                return;
            }

            string title = Value("opTitle");
            string department = Value("opDepartment");
            string location = Value("opLocation");
            string type = Value("opType");
            string mode = Value("opMode");
            string description = Value("opDescription");
            string requirements = Value("opRequirements");
            string technologies = Value("opTechnologies");

            string[] selectedMajors =
                Request.Form.GetValues("opMajors") ?? new string[0];

            List<string> eligibleMajors = selectedMajors
                .Where(x => Majors.Contains(x))
                .Distinct()
                .ToList();

            int seats;
            int duration;
            DateTime deadline;
            DateTime start;
            DateTime end;

            bool validSeats = int.TryParse(
                Request.Form["opSeats"], out seats);

            bool validDuration = int.TryParse(
                Request.Form["opDuration"], out duration);

            bool validDeadline = DateTime.TryParseExact(
                Request.Form["opDeadline"],
                "yyyy-MM-dd",
                CultureInfo.InvariantCulture,
                DateTimeStyles.None,
                out deadline);

            bool validStart = DateTime.TryParseExact(
                Request.Form["opStart"],
                "yyyy-MM-dd",
                CultureInfo.InvariantCulture,
                DateTimeStyles.None,
                out start);

            bool validEnd = DateTime.TryParseExact(
                Request.Form["opEnd"],
                "yyyy-MM-dd",
                CultureInfo.InvariantCulture,
                DateTimeStyles.None,
                out end);

            if (title.Length > 160 ||
                department.Length > 120 ||
                location.Length > 160 ||
                description.Length > 5000 ||
                requirements.Length > 3000 ||
                technologies.Length > 1000)
            {
                ShowError("One or more fields are too long.");
                return;
            }

            if (selectedMajors.Length != eligibleMajors.Count)
            {
                ShowError("Please select valid specializations.");
                return;
            }

            if (publish)
            {
                if (title.Length < 4 ||
                    department.Length == 0 ||
                    location.Length < 2 ||
                    description.Length < 20 ||
                    requirements.Length < 5 ||
                    eligibleMajors.Count == 0 ||
                    !validSeats || seats < 1 || seats > 10000 ||
                    !validDuration || duration < 1 || duration > 104 ||
                    !validDeadline || !validStart || !validEnd)
                {
                    ShowError("Please complete all required fields.");
                    return;
                }
            }

            if ((validSeats && (seats < 1 || seats > 10000)) ||
                (validDuration && (duration < 1 || duration > 104)))
            {
                ShowError("Please enter valid seats and duration.");
                return;
            }

            if (validDeadline && validStart &&
                start.Date <= deadline.Date)
            {
                ShowError("Start date must be after the deadline.");
                return;
            }

            if (validStart && validEnd &&
                end.Date <= start.Date)
            {
                ShowError("End date must be after start date.");
                return;
            }

            if (publish &&
                deadline.Date < DateTime.Today)
            {
                ShowError("Application deadline cannot be in the past.");
                return;
            }

            if (type != "Internship" ||
                (mode != "On-site" &&
                 mode != "Hybrid" &&
                 mode != "Remote"))
            {
                ShowError("Please select a valid opportunity type.");
                return;
            }

            try
            {
                string id = Guid.NewGuid().ToString("N");

                CompanyOpportunity opportunity =
                    new CompanyOpportunity();

                opportunity.Id = id;
                opportunity.CompanyId =
                    CurrentSupervisor.CompanyId;

                opportunity.Title = title;
                opportunity.Location = location;
                opportunity.Description = description;
                opportunity.Requirements = requirements;

                opportunity.EligibleCollege = CollegeName;
                opportunity.EligibleMajors = eligibleMajors;

                opportunity.TotalSeats =
                    validSeats ? seats : 0;

                opportunity.FilledSeats = 0;

                opportunity.DurationWeeks =
                    validDuration ? duration : 0;

                opportunity.ApplicationDeadline =
                    validDeadline ? ToUnix(deadline) : 0;

                opportunity.StartDate =
                    validStart ? ToUnix(start) : 0;

                opportunity.EndDate =
                    validEnd ? ToUnix(end) : 0;

                opportunity.Department = department;
                opportunity.OpportunityType = type;
                opportunity.TrainingMode = mode;
                opportunity.TechnologiesUsed = technologies;

                opportunity.Status = publish
                    ? OpportunityStatus.Open
                    : OpportunityStatus.Draft;

                opportunity.CreatedAt =
                    DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();

                string path =
                    Constants.Paths.Opportunities + "/" + id;

                string etag;
                FirebaseContext.GetWithEtag(path, out etag);

                bool saved = FirebaseContext.PutIfUnchanged(
                    path, opportunity, etag);

                if (!saved)
                {
                    ShowError("Unable to save. Please try again.");
                    return;
                }

                // Tell eligible students about a newly published opportunity.
                if (publish)
                    Services.NotificationService.OpportunityPublished(id);

                Notice = publish
                    ? "Opportunity published successfully."
                    : "Draft saved successfully.";

                IsError = false;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError(
                    "Create opportunity: " + ex);

                ShowError(
                    "Unable to save the opportunity in Firebase.");
            }
        }

        private string Value(string key)
        {
            return (Request.Form[key] ?? "").Trim();
        }

        private static long ToUnix(DateTime date)
        {
            return new DateTimeOffset(
                date.Date).ToUnixTimeMilliseconds();
        }

        private void ShowError(string message)
        {
            Notice = message;
            IsError = true;
        }
    }
}
