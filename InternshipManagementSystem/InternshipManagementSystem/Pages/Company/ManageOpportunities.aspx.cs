
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
    public partial class ManageOpportunities : CompanyPage
    {
        private readonly OpportunityRepository repo =
            new OpportunityRepository();

        protected List<Opportunity> OpportunityItems =
            new List<Opportunity>();

        protected Opportunity Editing;

        protected string Notice;
        protected bool NoticeIsError;

        protected string College
        {
            get
            {
                return Constants.CollegeName;
            }
        }

        protected string[] Programs
        {
            get
            {
                return Constants.Programs;
            }
        }

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            if (Session != null)
            {
                ViewStateUserKey = Session.SessionID;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (CurrentSupervisor == null ||
                string.IsNullOrWhiteSpace(
                    CurrentSupervisor.CompanyId))
            {
                ShowError(
                    "Your supervisor account is not linked to a company."
                );

                return;
            }

            try
            {
                if (IsPostBack)
                {
                    string closeId = Request.Form["moClose"];

                    if (!string.IsNullOrWhiteSpace(closeId))
                    {
                        CloseOpportunity(closeId);
                    }
                    else if (Request.Form["moAction"] == "save")
                    {
                        SaveEdit();
                    }
                }

                LoadCompanyOpportunities();

                string editId;

                if (IsPostBack &&
                    Request.Form["moAction"] == "save")
                {
                    editId = Request.Form["moId"];
                }
                else
                {
                    editId = Request.QueryString["edit"];
                }

                if (!string.IsNullOrWhiteSpace(editId))
                {
                    Editing = OpportunityItems
                        .FirstOrDefault(x => x.Id == editId);

                    if (Editing == null)
                    {
                        ShowError(
                            "Opportunity not found or access denied."
                        );
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError(
                    "ManageOpportunities error: " + ex
                );

                ShowError(
                    "Unable to load or update opportunities. " +
                    "Please check Firebase and try again."
                );
            }
        }

        // =====================================================
        // LOAD COMPANY OPPORTUNITIES
        // =====================================================

        private void LoadCompanyOpportunities()
        {
            string companyId =
                CurrentSupervisor.CompanyId;

            OpportunityItems = repo.GetAll()
                .Where(x =>
                    x != null &&
                    x.CompanyId == companyId)
                .OrderByDescending(x => x.CreatedAt)
                .ToList();
        }

        // =====================================================
        // FORM FIELD HELPERS
        // =====================================================

        protected string Field(
            string name,
            string fallback)
        {
            if (IsPostBack &&
                Request.Form["moAction"] == "save")
            {
                return Request.Form[name] ?? "";
            }

            return fallback ?? "";
        }

        protected bool MajorChecked(string major)
        {
            if (Editing == null)
            {
                return false;
            }

            if (IsPostBack &&
                Request.Form["moAction"] == "save")
            {
                string[] selectedMajors =
                    Request.Form.GetValues("moMajors")
                    ?? new string[0];

                return selectedMajors.Contains(major);
            }

            return Editing.EligibleMajors != null &&
                   Editing.EligibleMajors.Contains(major);
        }

        protected static string DateValue(long timestamp)
        {
            if (timestamp <= 0)
            {
                return "";
            }

            return Time.FromUnixMs(timestamp)
                .ToLocalTime()
                .ToString("yyyy-MM-dd");
        }

        // =====================================================
        // ERROR MESSAGE
        // =====================================================

        private void ShowError(string message)
        {
            Notice = message;
            NoticeIsError = true;
        }

        // =====================================================
        // SECURITY: VERIFY OPPORTUNITY OWNERSHIP
        // =====================================================

        private bool UpdateOwned(
            string id,
            Action<Opportunity> change)
        {
            if (string.IsNullOrWhiteSpace(id) ||
                id.IndexOf('/') >= 0 ||
                id.IndexOf('.') >= 0 ||
                id.IndexOf('#') >= 0 ||
                id.IndexOf('$') >= 0 ||
                id.IndexOf('[') >= 0 ||
                id.IndexOf(']') >= 0)
            {
                ShowError("Invalid opportunity ID.");
                return false;
            }

            string path =
                Constants.Paths.Opportunities + "/" + id;

            string etag;

            string json =
                FirebaseContext.GetWithEtag(
                    path,
                    out etag
                );

            Opportunity opportunity =
                string.IsNullOrWhiteSpace(json)
                    ? null
                    : Json.Deserialize<Opportunity>(json);

            if (opportunity == null ||
                opportunity.CompanyId !=
                CurrentSupervisor.CompanyId)
            {
                ShowError(
                    "Access denied. This opportunity " +
                    "does not belong to your company."
                );

                return false;
            }

            opportunity.Id = id;

            change(opportunity);

            bool updated =
                FirebaseContext.PutIfUnchanged(
                    path,
                    opportunity,
                    etag
                );

            if (!updated)
            {
                ShowError(
                    "This opportunity was changed by " +
                    "another user. Refresh and try again."
                );

                return false;
            }

            return true;
        }

        // =====================================================
        // CLOSE OPPORTUNITY
        // =====================================================

        private void CloseOpportunity(string id)
        {
            bool closed = UpdateOwned(
                id,
                opportunity =>
                {
                    opportunity.Status =
                        OpportunityStatus.Closed;
                }
            );

            if (closed)
            {
                Notice =
                    "Opportunity closed successfully. " +
                    "It will no longer accept applications.";

                NoticeIsError = false;
            }
        }

        // =====================================================
        // EDIT OPPORTUNITY
        // =====================================================

        private void SaveEdit()
        {
            string title =
                (Request.Form["moTitle"] ?? "").Trim();

            string location =
                (Request.Form["moLocation"] ?? "").Trim();

            string description =
                (Request.Form["moDescription"] ?? "").Trim();

            string requirements =
                (Request.Form["moRequirements"] ?? "").Trim();

            string college =
                (Request.Form["moCollege"] ?? "").Trim();

            List<string> majors =
                (Request.Form.GetValues("moMajors")
                ?? new string[0])
                .Distinct()
                .ToList();

            int seats = 0;
            int duration = 0;

            DateTime deadline = DateTime.MinValue;
            DateTime start = DateTime.MinValue;

            bool valid =
                title.Length >= 4 &&
                title.Length <= 160 &&

                location.Length >= 2 &&
                location.Length <= 160 &&

                description.Length >= 20 &&
                description.Length <= 5000 &&

                requirements.Length >= 5 &&
                requirements.Length <= 3000 &&

                college == Constants.CollegeName &&

                majors.Count > 0 &&

                !majors.Any(
                    x => !Constants.Programs.Contains(x)
                ) &&

                int.TryParse(
                    Request.Form["moSeats"],
                    out seats
                ) &&

                seats >= 1 &&
                seats <= 10000 &&

                int.TryParse(
                    Request.Form["moDuration"],
                    out duration
                ) &&

                duration >= 1 &&
                duration <= 104 &&

                DateTime.TryParseExact(
                    Request.Form["moDeadline"],
                    "yyyy-MM-dd",
                    CultureInfo.InvariantCulture,
                    DateTimeStyles.None,
                    out deadline
                ) &&

                DateTime.TryParseExact(
                    Request.Form["moStart"],
                    "yyyy-MM-dd",
                    CultureInfo.InvariantCulture,
                    DateTimeStyles.None,
                    out start
                ) &&

                start.Date > deadline.Date;

            if (!valid)
            {
                ShowError(
                    "Please check all required fields, " +
                    "eligible majors, seats, duration, " +
                    "and dates. The start date must " +
                    "be after the application deadline."
                );

                return;
            }

            bool seatsInvalid = false;

            bool saved = UpdateOwned(
                Request.Form["moId"],
                opportunity =>
                {
                    // Never reduce total seats below
                    // the number of already filled seats.

                    if (seats < opportunity.FilledSeats)
                    {
                        seatsInvalid = true;
                        return;
                    }

                    opportunity.Title = title;
                    opportunity.Location = location;
                    opportunity.Description = description;
                    opportunity.Requirements = requirements;

                    opportunity.EligibleCollege = college;
                    opportunity.EligibleMajors = majors;

                    opportunity.TotalSeats = seats;
                    opportunity.DurationWeeks = duration;

                    opportunity.ApplicationDeadline =
                        Time.ToUnixMs(
                            deadline.Date
                                .AddDays(1)
                                .AddTicks(-1)
                        );

                    opportunity.StartDate =
                        Time.ToUnixMs(start.Date);

                    // Important:
                    // Do not change CompanyId.
                    // Do not change FilledSeats.
                    // Do not change CreatedAt.
                    // Do not change Status here.
                }
            );

            if (seatsInvalid)
            {
                ShowError(
                    "Total seats cannot be less " +
                    "than the number of filled seats."
                );

                return;
            }

            if (saved)
            {
                Notice =
                    "Opportunity updated successfully.";

                NoticeIsError = false;
            }
        }
    }
}
