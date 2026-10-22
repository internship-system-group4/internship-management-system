// Edit & colse page opportunities 

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
        private readonly OpportunityRepository repository =
            new OpportunityRepository();

        protected List<Opportunity> OpportunityItems =
            new List<Opportunity>();

        protected Opportunities.CompanyOpportunity Editing;
        protected Opportunities.CompanyOpportunity Viewing;

        protected string Notice = "";
        protected bool IsError = false;

        protected string CollegeName = Constants.CollegeName;
        protected string[] Majors = Constants.Programs;

        protected int OpenCount;
        protected int DraftCount;
        protected int ClosedCount;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (CurrentSupervisor == null ||
                string.IsNullOrWhiteSpace(CurrentSupervisor.CompanyId))
            {
                ShowError("Your account is not linked to a company.");
                return;
            }

            try
            {
                if (IsPostBack)
                {
                    string action = Request.Form["moAction"];

                    if (action == "close")
                        CloseOpportunity(Request.Form["moId"]);

                    if (action == "save")
                        SaveEdit();
                }

                LoadOpportunities();

                string editId = Request.QueryString["edit"];

                string viewId = Request.QueryString["view"];

                if (!string.IsNullOrWhiteSpace(editId))
                    LoadEditing(editId);
                else if (!string.IsNullOrWhiteSpace(viewId))
                    LoadViewing(viewId);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError(
                    "Manage opportunities: " + ex);

                ShowError(
                    "Unable to load or update opportunities.");
            }
        }

        private void LoadOpportunities()
        {
            OpportunityItems = repository.GetAll()
                .Where(o =>
                    o != null &&
                    o.CompanyId == CurrentSupervisor.CompanyId)
                .OrderByDescending(o => o.CreatedAt)
                .ToList();

            OpenCount = OpportunityItems.Count(o =>
                o.Status == OpportunityStatus.Open);

            DraftCount = OpportunityItems.Count(o =>
                o.Status == OpportunityStatus.Draft);

            ClosedCount = OpportunityItems.Count(o =>
                o.Status == OpportunityStatus.Closed);
        }

        private bool ValidId(string id)
        {
            return !string.IsNullOrWhiteSpace(id) &&
                id.IndexOfAny(
                    new char[] { '.', '#', '$', '[', ']', '/' }
                ) < 0;
        }

        private Opportunities.CompanyOpportunity GetOwned(
            string id,
            out string etag)
        {
            etag = "";

            if (!ValidId(id))
            {
                ShowError("Invalid opportunity ID.");
                return null;
            }

            string path =
                Constants.Paths.Opportunities + "/" + id;

            string json = FirebaseContext.GetWithEtag(
                path, out etag);

            if (string.IsNullOrWhiteSpace(json) ||
                json.Trim() == "null")
            {
                ShowError("Opportunity not found.");
                return null;
            }

            Opportunities.CompanyOpportunity item =
                Json.Deserialize<Opportunities.CompanyOpportunity>(
                    json);

            if (item == null ||
                item.CompanyId != CurrentSupervisor.CompanyId)
            {
                ShowError(
                    "You cannot manage another company's opportunity.");
                return null;
            }

            item.Id = id;
            return item;
        }

        private void LoadEditing(string id)
        {
            string etag;
            Editing = GetOwned(id, out etag);
        }

        // Read-only details for the View button.
        private void LoadViewing(string id)
        {
            string etag;
            Viewing = GetOwned(id, out etag);
        }

        protected static string TextOrDash(string value)
        {
            return string.IsNullOrWhiteSpace(value) ? "-" : value;
        }

        private void CloseOpportunity(string id)
        {
            string etag;

            Opportunities.CompanyOpportunity item =
                GetOwned(id, out etag);

            if (item == null)
                return;

            if (item.Status == OpportunityStatus.Closed)
            {
                ShowError("This opportunity is already closed.");
                return;
            }

            item.Status = OpportunityStatus.Closed;

            string path =
                Constants.Paths.Opportunities + "/" + id;

            bool saved = FirebaseContext.PutIfUnchanged(
                path, item, etag);

            if (saved)
            {
                Notice = "Opportunity closed successfully.";
                IsError = false;
            }
            else
            {
                ShowError(
                    "Opportunity changed. Please refresh and try again.");
            }
        }

        private void SaveEdit()
        {
            string id = Request.Form["moId"];
            string etag;

            Opportunities.CompanyOpportunity item =
                GetOwned(id, out etag);

            if (item == null)
                return;

            string title = Value("moTitle");
            string department = Value("moDepartment");
            string location = Value("moLocation");
            string description = Value("moDescription");
            string requirements = Value("moRequirements");
            string technologies = Value("moTechnologies");
            string mode = Value("moMode");

            string[] selected =
                Request.Form.GetValues("moMajors") ?? new string[0];

            List<string> majors = selected
                .Where(x => Majors.Contains(x))
                .Distinct()
                .ToList();

            int seats;
            int duration;
            DateTime deadline;
            DateTime start;
            DateTime end;

            bool validSeats = int.TryParse(
                Request.Form["moSeats"], out seats);

            bool validDuration = int.TryParse(
                Request.Form["moDuration"], out duration);

            bool validDeadline = DateTime.TryParseExact(
                Request.Form["moDeadline"],
                "yyyy-MM-dd",
                CultureInfo.InvariantCulture,
                DateTimeStyles.None,
                out deadline);

            bool validStart = DateTime.TryParseExact(
                Request.Form["moStart"],
                "yyyy-MM-dd",
                CultureInfo.InvariantCulture,
                DateTimeStyles.None,
                out start);

            bool validEnd = DateTime.TryParseExact(
                Request.Form["moEnd"],
                "yyyy-MM-dd",
                CultureInfo.InvariantCulture,
                DateTimeStyles.None,
                out end);

            if (title.Length < 4 || title.Length > 160 ||
                department.Length == 0 || department.Length > 120 ||
                location.Length < 2 || location.Length > 160 ||
                description.Length < 20 ||
                description.Length > 5000 ||
                requirements.Length < 5 ||
                requirements.Length > 3000 ||
                technologies.Length > 1000 ||
                majors.Count == 0 ||
                selected.Length != majors.Count ||
                !validSeats || seats < 1 || seats > 10000 ||
                !validDuration || duration < 1 || duration > 104 ||
                !validDeadline || !validStart || !validEnd)
            {
                ShowError("Please check all opportunity fields.");
                return;
            }

            if (seats < item.FilledSeats)
            {
                ShowError(
                    "Seats cannot be less than filled seats.");
                return;
            }

            if (start.Date <= deadline.Date ||
                end.Date <= start.Date)
            {
                ShowError(
                    "Start date must follow the deadline, " +
                    "and end date must follow start date.");
                return;
            }

            if (mode != "On-site" &&
                mode != "Hybrid" &&
                mode != "Remote")
            {
                ShowError("Invalid training mode.");
                return;
            }

            item.Title = title;
            item.Department = department;
            item.Location = location;
            item.Description = description;
            item.Requirements = requirements;
            item.TechnologiesUsed = technologies;
            item.TrainingMode = mode;

            item.EligibleCollege = CollegeName;
            item.EligibleMajors = majors;

            item.TotalSeats = seats;
            item.DurationWeeks = duration;

            item.ApplicationDeadline = ToUnix(deadline);
            item.StartDate = ToUnix(start);
            item.EndDate = ToUnix(end);

            string path =
                Constants.Paths.Opportunities + "/" + id;

            bool saved = FirebaseContext.PutIfUnchanged(
                path, item, etag);

            if (saved)
            {
                Notice = "Opportunity updated successfully.";
                IsError = false;
            }
            else
            {
                ShowError(
                    "Opportunity changed. Refresh and try again.");
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

        protected static string DateText(long value)
        {
            if (value <= 0)
                return "";

            return DateTimeOffset
                .FromUnixTimeMilliseconds(value)
                .ToLocalTime()
                .ToString("yyyy-MM-dd");
        }

        protected bool IsMajorSelected(string major)
        {
            if (Editing == null ||
                Editing.EligibleMajors == null)
                return false;

            return Editing.EligibleMajors.Contains(major);
        }

        protected string StatusText(Opportunity item)
        {
            return item.Status.ToString();
        }

        private void ShowError(string message)
        {
            Notice = message;
            IsError = true;
        }
    }
}
