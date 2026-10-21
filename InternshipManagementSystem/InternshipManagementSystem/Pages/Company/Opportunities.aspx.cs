// =============================================================================
//  Manage Opportunities
//  Owner : Sara Rajoub
//  Cards : R01, R02
//
//  Create, edit and close this company's opportunities, with majors, requirements and seat count. A supervisor must not be able to touch another company's rows.
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
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.CompanyArea
{
    public partial class Opportunities : CompanyPage
    {
        protected string Notice { get; private set; }
        protected bool NoticeIsError { get; private set; }
        protected string SupervisorCompanyName
        {
            get { return CurrentSupervisor == null ? "" : (CurrentSupervisor.CompanyName ?? ""); }
        }

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            if (Session != null) ViewStateUserKey = Session.SessionID;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.QueryString["created"] == "1" && !IsPostBack)
                Notice = "Opportunity published successfully. Eligible students can now discover it.";

            if (IsPostBack && Request.Form["opAction"] == "publish")
                Publish();
        }

        protected string FormValue(string name)
        {
            return IsPostBack ? (Request.Form[name] ?? "") : "";
        }

        protected string FormValueOrDefault(string name, string fallback)
        {
            return IsPostBack ? (Request.Form[name] ?? "") : fallback;
        }

        protected bool IsMajorSelected(string major)
        {
            string[] values = Request.Form.GetValues("opMajors") ?? new string[0];
            return values.Contains(major, StringComparer.Ordinal);
        }

        private void Fail(string message)
        {
            Notice = message;
            NoticeIsError = true;
        }

        private static bool ParseDate(string input, out DateTime value)
        {
            return DateTime.TryParseExact(input, "yyyy-MM-dd", CultureInfo.InvariantCulture,
                DateTimeStyles.None, out value);
        }

        private void Publish()
        {
            try
            {
                var supervisor = CurrentSupervisor;
                if (supervisor == null || string.IsNullOrWhiteSpace(supervisor.Id)
                    || string.IsNullOrWhiteSpace(supervisor.CompanyId))
                {
                    Fail("Your account is not linked to a company. Contact the coordinator.");
                    return;
                }

                string title = (Request.Form["opTitle"] ?? "").Trim();
                string location = (Request.Form["opLocation"] ?? "").Trim();
                string description = (Request.Form["opDescription"] ?? "").Trim();
                string requirements = (Request.Form["opRequirements"] ?? "").Trim();
                string college = (Request.Form["opCollege"] ?? "").Trim();
                string[] requestedMajors = Request.Form.GetValues("opMajors") ?? new string[0];
                var majors = requestedMajors.Distinct(StringComparer.Ordinal).ToList();

                if (title.Length < 4 || title.Length > 160 || location.Length < 2 || location.Length > 160
                    || description.Length < 20 || description.Length > 5000
                    || requirements.Length < 5 || requirements.Length > 3000)
                {
                    Fail("Please complete the title, location, description (at least 20 characters), and requirements.");
                    return;
                }

                if (college != Constants.CollegeName || majors.Count == 0
                    || majors.Any(m => !Constants.Programs.Contains(m)))
                {
                    Fail("Select the configured college and at least one valid major.");
                    return;
                }

                int seats, duration;
                if (!int.TryParse(Request.Form["opSeats"], out seats) || seats < 1 || seats > 10000
                    || !int.TryParse(Request.Form["opDuration"], out duration) || duration < 1 || duration > 104)
                {
                    Fail("Seats must be 1–10000 and duration must be 1–104 weeks.");
                    return;
                }

                DateTime deadline, start;
                if (!ParseDate(Request.Form["opDeadline"], out deadline)
                    || !ParseDate(Request.Form["opStart"], out start))
                {
                    Fail("Enter a valid application deadline and start date.");
                    return;
                }
                if (deadline.Date < DateTime.Today || start.Date <= deadline.Date)
                {
                    Fail("Deadline cannot be in the past; start date must be after the application deadline.");
                    return;
                }

                // Store end of deadline day (local server time) as Unix milliseconds.
                DateTime deadlineEnd = deadline.Date.AddDays(1).AddTicks(-1);
                var item = new Opportunity
                {
                    CompanyId = supervisor.CompanyId,
                    CompanyName = supervisor.CompanyName,
                    CreatedBySupervisorId = supervisor.Id,
                    Title = title,
                    Description = description,
                    Requirements = requirements,
                    Location = location,
                    EligibleCollege = college,
                    EligibleMajors = majors,
                    TotalSeats = seats,
                    FilledSeats = 0,
                    DurationWeeks = duration,
                    StartDate = Time.ToUnixMs(start.Date),
                    ApplicationDeadline = Time.ToUnixMs(deadlineEnd),
                    Status = OpportunityStatus.Open,
                    CreatedAt = Time.NowMs()
                };

                string id = new OpportunityRepository().Insert(item);
                if (string.IsNullOrWhiteSpace(id))
                {
                    Fail("Firebase did not return an opportunity ID. Verify the saved record before retrying.");
                    return;
                }
                Response.Redirect("~/Pages/Company/Opportunities.aspx?created=1", false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception)
            {
                Fail("Unable to publish. Check Firebase configuration, access rules and connectivity.");
            }
        }
    }
}
