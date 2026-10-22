// =============================================================================
//  Schedule a Meeting
//  Owner : Fatima
//  Cards : F08, F10 (OPTIONAL)
//
//  OPTIONAL - do not start this until every core card is done. Date, time, participants and a pasted Zoom join link, saved to Firebase, with back-end access checks via Meeting.CanBeViewedBy.
//
//  Namespace note: these page namespaces end in "Area" on purpose. A namespace
//  called ...Pages.Student would hide the Student model class and every file in
//  the folder would fail to compile with "Student is a namespace but is used
//  like a type". Keep the suffix.
// =============================================================================
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Web.UI.WebControls;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.MeetingsArea
{
    public partial class Schedule : AuthenticatedPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            try
            {
                LoadPlacements();
                LoadMeetings();
            }
            catch (FirebaseException)
            {
                ShowMessage("Could not load meetings. Please try again.", false);
            }
        }

        private bool BelongsToCurrentUser(Placement placement)
        {
            if (placement == null) return false;

            CompanySupervisor supervisor = CurrentUser as CompanySupervisor;

            return placement.StudentId == CurrentUser.Id
                || placement.CompanySupervisorId == CurrentUser.Id
                || placement.AcademicSupervisorId == CurrentUser.Id
                || (supervisor != null &&
                    placement.CompanyId == supervisor.CompanyId);
        }

        private void LoadPlacements()
        {
            ddlPlacement.Items.Clear();
            ddlPlacement.Items.Add(
                new ListItem("Select an internship", ""));

            foreach (Placement placement in new PlacementRepository().GetAll())
            {
                if (!BelongsToCurrentUser(placement)) continue;

                string name = string.IsNullOrWhiteSpace(placement.StudentName)
                    ? placement.StudentId
                    : placement.StudentName;

                ddlPlacement.Items.Add(
                    new ListItem(name, placement.Id));
            }

            cblParticipants.Items.Clear();
        }

        protected void ddlPlacement_SelectedIndexChanged(
            object sender, EventArgs e)
        {
            try
            {
                LoadParticipants();
            }
            catch (FirebaseException)
            {
                ShowMessage("Could not load participants.", false);
            }
        }

        private void LoadParticipants()
        {
            cblParticipants.Items.Clear();

            if (string.IsNullOrWhiteSpace(ddlPlacement.SelectedValue))
                return;

            Placement placement = new PlacementRepository()
                .GetById(ddlPlacement.SelectedValue);

            if (!BelongsToCurrentUser(placement)) return;

            AddParticipant(placement.StudentId);
            AddParticipant(placement.CompanySupervisorId);
            AddParticipant(placement.AcademicSupervisorId);
        }

        private void AddParticipant(string personId)
        {
            if (string.IsNullOrWhiteSpace(personId) ||
                personId == CurrentUser.Id ||
                cblParticipants.Items.FindByValue(personId) != null)
                return;

            Person person = new UserRepository().GetPerson(personId);
            if (person == null) return;

            string name = string.IsNullOrWhiteSpace(person.FullName)
                ? person.Id
                : person.FullName;

            cblParticipants.Items.Add(
                new ListItem(name, personId));
        }

        protected void btnSchedule_Click(object sender, EventArgs e)
        {
            try
            {
                Placement placement = new PlacementRepository()
                    .GetById(ddlPlacement.SelectedValue);

                if (!BelongsToCurrentUser(placement))
                {
                    ShowMessage("Select one of your internships.", false);
                    return;
                }

                string title = txtTitle.Text.Trim();
                string agenda = txtAgenda.Text.Trim();
                string url = txtJoinUrl.Text.Trim();

                if (title == "")
                {
                    ShowMessage("Enter a meeting title.", false);
                    return;
                }

                DateTime localDate;
                if (!DateTime.TryParseExact(
                    txtScheduledAt.Text,
                    new[] { "yyyy-MM-ddTHH:mm", "yyyy-MM-ddTHH:mm:ss" },
                    CultureInfo.InvariantCulture,
                    DateTimeStyles.None,
                    out localDate))
                {
                    ShowMessage("Enter a valid meeting date and time.", false);
                    return;
                }

                int offsetMinutes;
                if (!int.TryParse(hfTimezoneOffset.Value,
                                  out offsetMinutes) ||
                    offsetMinutes < -840 ||
                    offsetMinutes > 840)
                {
                    ShowMessage(
                        "Could not read your time zone. Refresh and try again.",
                        false);
                    return;
                }

                // JavaScript offset = UTC - local time.
                DateTime utcDate = DateTime.SpecifyKind(
                    localDate.AddMinutes(offsetMinutes),
                    DateTimeKind.Utc);

                long scheduledAt =
                    new DateTimeOffset(utcDate).ToUnixTimeMilliseconds();

                if (scheduledAt <= DateTimeOffset.UtcNow
                                      .ToUnixTimeMilliseconds())
                {
                    ShowMessage("Choose a future date and time.", false);
                    return;
                }

                int duration;
                if (!int.TryParse(ddlDuration.SelectedValue, out duration) ||
                    (duration != 30 && duration != 45 && duration != 60))
                {
                    ShowMessage("Select a valid duration.", false);
                    return;
                }

                if (!IsZoomUrl(url))
                {
                    ShowMessage("Enter a valid HTTPS Zoom link.", false);
                    return;
                }

                // لا نعتمد على IDs المرسلة من المتصفح.
                // نتحقق أن كل مشارك من الأشخاص المرتبطين بهذا التدريب.
                List<string> allowed = new List<string>
                {
                    placement.StudentId,
                    placement.CompanySupervisorId,
                    placement.AcademicSupervisorId
                };

                List<string> selected = new List<string>();

                foreach (ListItem item in cblParticipants.Items)
                {
                    if (!item.Selected) continue;

                    if (!allowed.Contains(item.Value))
                    {
                        ShowMessage("Invalid participant selected.", false);
                        return;
                    }

                    if (!selected.Contains(item.Value))
                        selected.Add(item.Value);
                }

                if (selected.Count == 0)
                {
                    ShowMessage("Select at least one participant.", false);
                    return;
                }

                Meeting meeting = new Meeting
                {
                    Title = title,
                    Agenda = agenda,
                    CreatedById = CurrentUser.Id,
                    PlacementId = placement.Id,
                    ParticipantIds = selected,
                    ScheduledAt = scheduledAt,
                    DurationMinutes = duration,
                    JoinUrl = url
                };

                string id = new MeetingRepository().Insert(meeting);

                if (string.IsNullOrWhiteSpace(id))
                {
                    ShowMessage("Meeting could not be saved.", false);
                    return;
                }

                txtTitle.Text = "";
                txtAgenda.Text = "";
                txtScheduledAt.Text = "";
                txtJoinUrl.Text = "";
                cblParticipants.ClearSelection();

                LoadMeetings();
                ShowMessage("Meeting scheduled successfully.", true);
            }
            catch (FirebaseException)
            {
                ShowMessage("Could not save the meeting. Try again.", false);
            }
        }

        private void LoadMeetings()
        {
            List<Meeting> visible = new List<Meeting>();

            foreach (Meeting meeting in new MeetingRepository().GetAll())
            {
                if (meeting.CanBeViewedBy(CurrentUser.Id))
                    visible.Add(meeting);
            }

            rptMeetings.DataSource = visible;
            rptMeetings.DataBind();
            lblNoMeetings.Visible = visible.Count == 0;
        }

        protected void rptMeetings_ItemCommand(
            object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "ViewMeeting") return;

            try
            {
                string id = Convert.ToString(e.CommandArgument);
                Meeting meeting = new MeetingRepository().GetById(id);

                // نفحص الصلاحية مرة ثانية عند فتح التفاصيل.
                if (meeting == null ||
                    !meeting.CanBeViewedBy(CurrentUser.Id))
                {
                    pnlMeetingDetails.Visible = false;
                    ShowMessage(
                        "You do not have access to this meeting.", false);
                    return;
                }

                lblDetailTitle.Text =
                    Server.HtmlEncode(meeting.Title ?? "");

                lblDetailAgenda.Text =
                    Server.HtmlEncode(meeting.Agenda ?? "");

                lblDetailDate.Text = FormatDate(meeting.ScheduledAt);

                lblDetailDuration.Text =
                    meeting.DurationMinutes + " minutes";

                lnkJoin.Visible = IsZoomUrl(meeting.JoinUrl);

                if (lnkJoin.Visible)
                    lnkJoin.NavigateUrl = meeting.JoinUrl;

                pnlMeetingDetails.Visible = true;
            }
            catch (FirebaseException)
            {
                ShowMessage("Could not open this meeting.", false);
            }
        }

        protected string FormatDate(object value)
        {
            long milliseconds;

            if (!long.TryParse(Convert.ToString(value),
                               out milliseconds) ||
                milliseconds <= 0)
                return "Not set";

            return DateTimeOffset
                .FromUnixTimeMilliseconds(milliseconds)
                .UtcDateTime
                .ToString("yyyy-MM-dd HH:mm") + " UTC";
        }

        private static bool IsZoomUrl(string value)
        {
            Uri uri;

            if (!Uri.TryCreate(value, UriKind.Absolute, out uri) ||
                uri.Scheme != Uri.UriSchemeHttps)
                return false;

            string host = uri.Host.ToLowerInvariant();

            return host == "zoom.us" ||
                   host.EndsWith(".zoom.us") ||
                   host == "zoom.com" ||
                   host.EndsWith(".zoom.com");
        }

        private void ShowMessage(string message, bool success)
        {
            lblMessage.Text = Server.HtmlEncode(message);
            lblMessage.CssClass = success
                ? "alert alert-success d-block mt-3"
                : "alert alert-danger d-block mt-3";
        }
    }
}