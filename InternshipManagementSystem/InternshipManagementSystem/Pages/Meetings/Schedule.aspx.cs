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
                LoadStudents();
                LoadParticipants();
                LoadMeetings();
            }
            catch (FirebaseException)
            {
                ShowMessage("Could not load meetings. Please try again.", false);
            }
        }

        // الطالب يرى تدريبه فقط. المشرف يرى الطلاب التابعين له.
        private void LoadStudents()
        {
            ddlPlacement.Items.Clear();
            ddlPlacement.Items.Add(
                new ListItem("Select a student", ""));

            foreach (Placement placement in
                     new PlacementRepository().GetAll())
            {
                if (!CanManagePlacement(placement)) continue;

                string studentName =
                    string.IsNullOrWhiteSpace(placement.StudentName)
                    ? "Student"
                    : placement.StudentName;

                ddlPlacement.Items.Add(
                    new ListItem(studentName, placement.Id));
            }

            // الطالب لا يحتاج يختار تدريبه يدويًا.
            if (CurrentUser is Student && ddlPlacement.Items.Count > 1)
            {
                ddlPlacement.SelectedIndex = 1;
                ddlPlacement.Enabled = false;
            }
        }

        private bool CanManagePlacement(Placement placement)
        {
            if (placement == null || CurrentUser == null)
                return false;

            if (CurrentUser is Student)
                return placement.StudentId == CurrentUser.Id;

            CompanySupervisor companySupervisor =
                CurrentUser as CompanySupervisor;

            if (companySupervisor != null)
            {
                return !string.IsNullOrEmpty(companySupervisor.CompanyId)
                    && placement.CompanyId ==
                       companySupervisor.CompanyId;
            }

            if (CurrentUser is AcademicSupervisor)
            {
                return placement.AcademicSupervisorId ==
                       CurrentUser.Id;
            }

            return false;
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
            lblNoParticipants.Visible = true;
            lblNoParticipants.Text =
                "Choose a student to see participants.";

            string placementId = ddlPlacement.SelectedValue;

            if (string.IsNullOrEmpty(placementId))
                return;

            Placement placement =
                new PlacementRepository().GetById(placementId);

            if (!CanManagePlacement(placement))
            {
                lblNoParticipants.Text =
                    "This internship is not available.";
                return;
            }

            // الأرقام موجودة في Placement نفسه؛ لا نعتمد على users.
            AddParticipant(
                placement.StudentId,
                placement.StudentName,
                "Student");

            AddParticipant(
                placement.CompanySupervisorId,
                placement.CompanySupervisorName,
                "Company supervisor");

            AddParticipant(
                placement.AcademicSupervisorId,
                "",
                "Academic supervisor");

            lblNoParticipants.Visible =
                cblParticipants.Items.Count == 0;

            if (lblNoParticipants.Visible)
            {
                lblNoParticipants.Text =
                    "No other participants are linked to this internship.";
            }
        }

        private void AddParticipant(
            string personId, string personName, string fallbackName)
        {
            if (string.IsNullOrWhiteSpace(personId) ||
                personId == CurrentUser.Id ||
                cblParticipants.Items.FindByValue(personId) != null)
            {
                return;
            }

            string displayName =
                string.IsNullOrWhiteSpace(personName)
                ? fallbackName
                : personName;

            cblParticipants.Items.Add(
                new ListItem(displayName, personId));
        }

        protected void btnSchedule_Click(object sender, EventArgs e)
        {
            string placementId = ddlPlacement.SelectedValue;

            if (string.IsNullOrWhiteSpace(placementId))
            {
                ShowMessage("Select a student first.", false);
                return;
            }

            string title = txtTitle.Text.Trim();
            string agenda = txtAgenda.Text.Trim();
            string joinUrl = txtJoinUrl.Text.Trim();

            if (title == "")
            {
                ShowMessage("Enter a meeting title.", false);
                return;
            }

            DateTime meetingTime;

            if (!DateTime.TryParseExact(
                    txtScheduledAt.Text,
                    "yyyy-MM-ddTHH:mm",
                    CultureInfo.InvariantCulture,
                    DateTimeStyles.None,
                    out meetingTime))
            {
                ShowMessage("Enter a valid meeting date and time.", false);
                return;
            }

            // الحقل في الصفحة مكتوب عليه UTC.
            meetingTime = DateTime.SpecifyKind(
                meetingTime, DateTimeKind.Utc);

            if (meetingTime <= DateTime.UtcNow)
            {
                ShowMessage("Choose a future date and time.", false);
                return;
            }

            Uri zoomLink;

            if (!Uri.TryCreate(
                    joinUrl, UriKind.Absolute, out zoomLink) ||
                zoomLink.Scheme != Uri.UriSchemeHttps)
            {
                ShowMessage(
                    "Enter a valid HTTPS meeting link.", false);
                return;
            }

            try
            {
                Placement placement =
                    new PlacementRepository().GetById(placementId);

                // نفحص الصلاحية مرة ثانية قبل الحفظ.
                if (!CanManagePlacement(placement))
                {
                    ShowMessage(
                        "You cannot schedule a meeting for this student.",
                        false);
                    return;
                }

                List<string> allowedIds =
                    new List<string>();

                AddAllowedId(allowedIds, placement.StudentId);
                AddAllowedId(
                    allowedIds, placement.CompanySupervisorId);
                AddAllowedId(
                    allowedIds, placement.AcademicSupervisorId);

                List<string> selectedIds =
                    new List<string>();

                foreach (ListItem item in cblParticipants.Items)
                {
                    if (!item.Selected) continue;

                    // ممنوع إرسال دعوة لشخص خارج هذا التدريب.
                    if (!allowedIds.Contains(item.Value) ||
                        item.Value == CurrentUser.Id)
                    {
                        ShowMessage(
                            "Invalid participant selection.", false);
                        return;
                    }

                    if (!selectedIds.Contains(item.Value))
                        selectedIds.Add(item.Value);
                }

                if (selectedIds.Count == 0)
                {
                    ShowMessage(
                        "Choose at least one participant.", false);
                    return;
                }

                Meeting meeting = new Meeting();
                meeting.Title = title;
                meeting.Agenda = agenda;
                meeting.PlacementId = placement.Id;
                meeting.CreatedById = CurrentUser.Id;
                meeting.ParticipantIds = selectedIds;
                meeting.ScheduledAt =
                    new DateTimeOffset(meetingTime)
                        .ToUnixTimeMilliseconds();
                meeting.DurationMinutes =
                    int.Parse(ddlDuration.SelectedValue);
                meeting.JoinUrl = joinUrl;

                string meetingId =
                    new MeetingRepository().Insert(meeting);

                if (string.IsNullOrEmpty(meetingId))
                {
                    ShowMessage(
                        "Meeting could not be saved.", false);
                    return;
                }

                txtTitle.Text = "";
                txtAgenda.Text = "";
                txtScheduledAt.Text = "";
                txtJoinUrl.Text = "";

                foreach (ListItem item in cblParticipants.Items)
                    item.Selected = false;

                LoadMeetings();

                ShowMessage(
                    "Meeting scheduled successfully.", true);
            }
            catch (FirebaseException)
            {
                ShowMessage(
                    "Could not save the meeting. Please try again.",
                    false);
            }
        }

        private void AddAllowedId(
            List<string> ids, string personId)
        {
            if (!string.IsNullOrWhiteSpace(personId) &&
                !ids.Contains(personId))
            {
                ids.Add(personId);
            }
        }

        private void LoadMeetings()
        {
            List<Meeting> mine = new List<Meeting>();

            foreach (Meeting meeting in
                     new MeetingRepository().GetAll())
            {
                if (meeting.CanBeViewedBy(CurrentUser.Id))
                    mine.Add(meeting);
            }

            rptMeetings.DataSource = mine;
            rptMeetings.DataBind();
            lblNoMeetings.Visible = mine.Count == 0;
        }

        protected void rptMeetings_ItemCommand(
            object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "ViewMeeting")
                return;

            try
            {
                string meetingId =
                    Convert.ToString(e.CommandArgument);

                Meeting meeting =
                    new MeetingRepository().GetById(meetingId);

                // نفحص الوصول على السيرفر قبل عرض الرابط.
                if (meeting == null ||
                    !meeting.CanBeViewedBy(CurrentUser.Id))
                {
                    ShowMessage(
                        "Meeting not found or access denied.", false);
                    return;
                }

                lblDetailTitle.Text =
                    Server.HtmlEncode(meeting.Title ?? "");

                lblDetailAgenda.Text =
                    Server.HtmlEncode(meeting.Agenda ?? "");

                lblDetailDate.Text =
                    FormatDate(meeting.ScheduledAt);

                lblDetailDuration.Text =
                    meeting.DurationMinutes + " minutes";

                Uri link;
                lnkJoin.Visible =
                    Uri.TryCreate(
                        meeting.JoinUrl,
                        UriKind.Absolute,
                        out link) &&
                    link.Scheme == Uri.UriSchemeHttps;

                if (lnkJoin.Visible)
                    lnkJoin.NavigateUrl = meeting.JoinUrl;

                pnlMeetingDetails.Visible = true;
            }
            catch (FirebaseException)
            {
                ShowMessage(
                    "Could not open meeting details.", false);
            }
        }

        protected string FormatDate(object value)
        {
            if (value == null)
                return "Not set";

            long milliseconds =
                Convert.ToInt64(value);

            if (milliseconds <= 0)
                return "Not set";

            return DateTimeOffset
                .FromUnixTimeMilliseconds(milliseconds)
                .UtcDateTime
                .ToString(
                    "yyyy-MM-dd HH:mm 'UTC'",
                    CultureInfo.InvariantCulture);
        }

        private void ShowMessage(
            string message, bool success)
        {
            lblMessage.Text =
                Server.HtmlEncode(message);

            lblMessage.CssClass = success
                ? "alert alert-success d-block mt-3"
                : "alert alert-danger d-block mt-3";
        }
    }
}