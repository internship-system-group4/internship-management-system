
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;
using InternshipManagementSystem.Services;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;

namespace InternshipManagementSystem.Pages.CompanyArea
{
    public partial class ManageOpportunities : CompanyPage
    {
        private readonly OpportunityRepository repository =
            new OpportunityRepository();

        protected List<Opportunity> OpportunityItems =
            new List<Opportunity>();

        protected Opportunities.CompanyOpportunity Editing;

        // Shared Add/Edit rules; the errors of a failed edit are shown under each field.
        protected Services.OpportunityFormRules EditForm = new Services.OpportunityFormRules();
        private Opportunities.CompanyOpportunity FailedEdit;
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
                ShowError(
                    L.T("Company.ManageOpportunities.YourAccountIsNotLinkedTo"));
                return;
            }

            try
            {
                if (IsPostBack)
                {
                    string action = Request.Form["moAction"];

                    if (action == "toggle")
                        ToggleOpportunity(Request.Form["moId"]);

                    if (action == "save")
                        SaveEdit();
                }

                LoadOpportunities();

                // Success message from Opportunities.aspx after a new posting.
                string saved = Session["OpportunitySavedNotice"] as string;
                if (!IsPostBack && !string.IsNullOrEmpty(saved))
                {
                    Session.Remove("OpportunitySavedNotice");
                    Notice = saved;
                    IsError = false;
                }

                string editId = Request.QueryString["edit"];
                string viewId = Request.QueryString["view"];

                if (FailedEdit != null)
                    Editing = FailedEdit;
                else if (!string.IsNullOrWhiteSpace(editId))
                    LoadEditing(editId);
                else if (!string.IsNullOrWhiteSpace(viewId))
                    LoadViewing(viewId);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError(
                    "Manage opportunities: " + ex);

                ShowError(
                    L.T("Company.ManageOpportunities.UnableToLoadOrUpdateOpportunities"));
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
                ShowError(
                    L.T("Company.ManageOpportunities.InvalidOpportunityID"));
                return null;
            }

            string path =
                Constants.Paths.Opportunities + "/" + id;

            string json = FirebaseContext.GetWithEtag(
                path, out etag);

            if (string.IsNullOrWhiteSpace(json) ||
                json.Trim() == "null")
            {
                ShowError(
                    L.T("Company.ManageOpportunities.OpportunityNotFound"));
                return null;
            }

            Opportunities.CompanyOpportunity item =
                Json.Deserialize<Opportunities.CompanyOpportunity>(
                    json);

            if (item == null ||
                item.CompanyId != CurrentSupervisor.CompanyId)
            {
                ShowError(
                    L.T("Company.ManageOpportunities.YouCannotManageAnotherCompanyS"));
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

        private void LoadViewing(string id)
        {
            string etag;
            Viewing = GetOwned(id, out etag);
        }

        protected static string TextOrDash(string value)
        {
            return string.IsNullOrWhiteSpace(value) ? "-" : value;
        }

        private void ToggleOpportunity(string id)
        {
            string etag;

            Opportunities.CompanyOpportunity item =
                GetOwned(id, out etag);

            if (item == null)
                return;

            // Closed is displayed as Inactive.
            // Draft opportunities cannot be toggled.
            if (item.Status != OpportunityStatus.Open &&
                item.Status != OpportunityStatus.Closed)
            {
                ShowError(
                    "Only open or inactive opportunities can be toggled.");
                return;
            }

            bool activating =
                item.Status == OpportunityStatus.Closed;

            // Activate / Deactivate freely.
            // No deadline or seat validation here.
            item.Status = activating
                ? OpportunityStatus.Open
                : OpportunityStatus.Closed;

            string path =
                Constants.Paths.Opportunities + "/" + id;

            bool saved = FirebaseContext.PutIfUnchanged(
                path, item, etag);

            if (saved)
            {
                // Keep the public preview synchronized.
                repository.SyncPublicPreview(id);

                Notice = activating
                    ? "Opportunity activated successfully."
                    : "Opportunity deactivated successfully.";

                IsError = false;
            }
            else
            {
                ShowError(
                    L.T("Company.ManageOpportunities.OpportunityChangedPleaseRefreshAndTry"));
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

            // Same rules as the Add form. "Not in the past" only applies when the
            // last date to apply was changed, so older postings can still be edited.
            EditForm = OpportunityFormRules.Read(Request.Form, "mo", Majors);
            bool deadlineChanged = Request.Form["moDeadline"] != DateText(item.ApplicationDeadline);
            EditForm.Check(true, deadlineChanged, item.FilledSeats);

            // Put the typed values on the item so a failed save keeps them on screen.
            item.Title = EditForm.Title;
            item.Department = EditForm.Department;
            item.Location = EditForm.Location;
            item.Description = EditForm.Description;
            item.Requirements = EditForm.Requirements;
            item.TechnologiesUsed = EditForm.Technologies;
            item.TrainingMode = EditForm.Mode;
            item.EligibleCollege = CollegeName;
            item.EligibleMajors = EditForm.Majors;
            item.TotalSeats = EditForm.HasSeats ? EditForm.Seats : 0;
            item.ApplicationDeadline = EditForm.HasDeadline ? OpportunityFormRules.DayEndMs(EditForm.Deadline) : 0;
            item.StartDate = EditForm.HasStart ? OpportunityFormRules.DayStartMs(EditForm.Start) : 0;
            item.EndDate = EditForm.HasStart ? OpportunityFormRules.DayStartMs(EditForm.End) : 0;
            item.DurationWeeks = EditForm.DurationWeeks;

            if (!EditForm.IsValid)
            {
                FailedEdit = item;
                ShowError(L.T("Company.OpportunityForm.FixErrors"));
                return;
            }

            string path =
                Constants.Paths.Opportunities + "/" + id;

            bool saved = FirebaseContext.PutIfUnchanged(
                path, item, etag);

            if (saved)
            {
                repository.SyncPublicPreview(id);

                Notice = L.T(
                    "Company.ManageOpportunities.OpportunityUpdatedSuccessfully");

                IsError = false;
            }
            else
            {
                FailedEdit = item;
                ShowError(
                    L.T("Company.ManageOpportunities.OpportunityChangedRefreshAndTryAgain"));
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

        // ---- Edit form helpers (errors under each field, 3-month end date) ----

        protected string EditError(string field) { return EditForm.ErrorFor(field); }

        protected string EditInvalid(string field)
        {
            return string.IsNullOrEmpty(EditForm.ErrorFor(field)) ? "" : " is-invalid";
        }

        protected string EditHidden(string field)
        {
            return string.IsNullOrEmpty(EditForm.ErrorFor(field)) ? "hidden" : "";
        }

        protected string FormMessagesJson
        {
            get { return new System.Web.Script.Serialization.JavaScriptSerializer().Serialize(OpportunityFormRules.ScriptMessages()); }
        }

        protected string TodayText
        {
            get { return DateTime.Today.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture); }
        }

        /// <summary>End date shown on the edit form: always start + 3 months.</summary>
        protected string EditEndText
        {
            get
            {
                if (Editing == null || Editing.StartDate <= 0) return "—";
                DateTime start = DateTimeOffset.FromUnixTimeMilliseconds(Editing.StartDate).ToLocalTime().Date;
                return OpportunityFormRules.Show(OpportunityFormRules.EndFor(start));
            }
        }

        protected string EditDurationText
        {
            get
            {
                if (Editing == null || Editing.StartDate <= 0) return L.T("Company.OpportunityForm.DurationEmpty");
                return L.F("Company.OpportunityForm.Duration", DateText(Editing.StartDate), EditEndText);
            }
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

        protected string StatusClass(Opportunity item)
        {
            if (item == null)
                return "is-draft";

            if (item.Status == OpportunityStatus.Open)
                return "is-open";

            return item.Status == OpportunityStatus.Closed
                ? "is-inactive"
                : "is-draft";
        }

        protected string StatusText(Opportunity item)
        {
            if (item.Status == OpportunityStatus.Closed)
                return "Inactive";

            return L.Value("OpportunityStatus", item.Status);
        }

        private void ShowError(string message)
        {
            Notice = message;
            IsError = true;
        }
    }
}
