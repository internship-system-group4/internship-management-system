// =============================================================================
//  Schedule a Meeting
//  Owner : Fatima
//  Cards : F08, F10 (OPTIONAL)
//
//  Creates Zoom meetings and saves selected participants and the join URL.
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
using System.Web.UI.WebControls;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;
using InternshipManagementSystem.Services;

namespace InternshipManagementSystem.Pages.MeetingsArea
{
    public partial class Schedule : InternshipManagementSystem.Security.AuthenticatedPage
    {
        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            try
            {
                foreach (Person person in new UserRepository().GetAllPeople()
                    .Where(p => p.IsActive && p.Id != CurrentUser.Id)
                    .OrderBy(p => p.FullName))
                {
                    lstParticipants.Items.Add(new ListItem(person.FullName + " (" + person.RoleDisplayName + ")", person.Id));
                }
            }
            catch (FirebaseException)
            {
                ShowMessage("Participants could not be loaded. Please try again.");
                btnCreate.Enabled = false;
            }
        }

        protected void Page_Load(object sender, EventArgs e) { }

        protected void btnCreate_Click(object sender, EventArgs e)
        {
            string title = (txtTitle.Text ?? "").Trim();
            string agenda = (txtAgenda.Text ?? "").Trim();
            int duration;
            int offset;
            DateTime localStart;
            if (title.Length == 0 || title.Length > 200 || agenda.Length > 2000
                || !int.TryParse(txtDuration.Text, out duration) || duration < 1 || duration > 1440
                || !DateTime.TryParseExact(txtStart.Text, new[] { "yyyy-MM-ddTHH:mm", "yyyy-MM-ddTHH:mm:ss" },
                    CultureInfo.InvariantCulture, DateTimeStyles.None, out localStart)
                || !int.TryParse(hdnOffset.Value, out offset) || offset < -840 || offset > 840)
            {
                ShowMessage("Enter a title, valid local date and time, and a duration from 1 to 1440 minutes.");
                return;
            }
            DateTime startUtc = DateTime.SpecifyKind(localStart.AddMinutes(offset), DateTimeKind.Utc);
            if (startUtc <= DateTime.UtcNow.AddMinutes(1))
            {
                ShowMessage("Choose a time at least a minute in the future.");
                return;
            }
            List<string> selected = lstParticipants.Items.Cast<ListItem>()
                .Where(item => item.Selected).Select(item => item.Value).Distinct().ToList();
            if (selected.Count == 0)
            {
                ShowMessage("Select at least one participant.");
                return;
            }
            bool zoomCreated = false;
            try
            {
                HashSet<string> validIds = new HashSet<string>(new UserRepository().GetAllPeople()
                    .Where(p => p.IsActive && p.Id != CurrentUser.Id).Select(p => p.Id));
                if (selected.Any(id => !validIds.Contains(id)))
                {
                    ShowMessage("One of the selected participants is no longer available. Reload the page and try again.");
                    return;
                }
                ZoomMeetingResult zoom = ZoomMeetingService.Create(title, agenda, startUtc, duration);
                zoomCreated = true;
                Meeting meeting = new Meeting
                {
                    Title = title,
                    Agenda = agenda,
                    CreatedById = CurrentUser.Id,
                    ParticipantIds = selected,
                    ScheduledAt = Time.ToUnixMs(startUtc),
                    DurationMinutes = duration,
                    ZoomMeetingId = zoom.MeetingId,
                    JoinUrl = zoom.JoinUrl
                };
                if (string.IsNullOrEmpty(new MeetingRepository().Insert(meeting)))
                    throw new InvalidOperationException("The meeting could not be saved. Contact the administrator with the meeting title before retrying.");
                Response.Redirect(ResolveUrl("~/Pages/Meetings/MyMeetings.aspx?created=1"), false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (InvalidOperationException ex)
            {
                ShowMessage(ex.Message);
            }
            catch (FirebaseException)
            {
                ShowMessage(zoomCreated
                    ? "Zoom created the meeting, but it could not be saved here. Contact the administrator before retrying to avoid a duplicate."
                    : "The participant list could not be verified. Please try again.");
            }
        }

        private void ShowMessage(string message)
        {
            lblMessage.Text = Server.HtmlEncode(message);
            lblMessage.CssClass = "alert alert-danger d-block";
            lblMessage.Visible = true;
        }
    }
}
