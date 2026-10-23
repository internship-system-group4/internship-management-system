// =============================================================================
//  My Meetings
//  Owner : Fatima
//  Cards : F09 (OPTIONAL)
//
//  Each participant sees only their own meetings, with join links.
//
//  Namespace note: these page namespaces end in "Area" on purpose. A namespace
//  called ...Pages.Student would hide the Student model class and every file in
//  the folder would fail to compile with "Student is a namespace but is used
//  like a type". Keep the suffix.
// =============================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.MeetingsArea
{
    public partial class MyMeetings : InternshipManagementSystem.Security.AuthenticatedPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;
            if (Request.QueryString["created"] == "1")
            {
                lblMessage.Text = "Zoom meeting created. Selected participants can join from this page.";
                lblMessage.CssClass = "alert alert-success d-block";
                lblMessage.Visible = true;
            }
            try
            {
                List<Meeting> meetings = new MeetingRepository().GetAll()
                    .Where(m => m.CanBeViewedBy(CurrentUser.Id))
                    .OrderByDescending(m => m.ScheduledAt).ToList();
                Dictionary<string, string> people = new UserRepository().GetAllPeople()
                    .Where(p => !string.IsNullOrEmpty(p.Id))
                    .GroupBy(p => p.Id).ToDictionary(g => g.Key, g => g.First().FullName);
                var rows = meetings.Select(m => new
                {
                    m.Title,
                    m.Agenda,
                    m.Status,
                    When = Time.FromUnixMs(m.ScheduledAt).ToString("yyyy-MM-dd HH:mm 'UTC'"),
                    ScheduledAt = m.ScheduledAt,
                    Duration = m.DurationMinutes,
                    Participants = string.Join(", ", (m.ParticipantIds ?? new List<string>())
                        .Select(id => people.ContainsKey(id) ? people[id] : "Former participant")),
                    JoinUrl = SafeZoomUrl(m.JoinUrl),
                    CanJoin = m.Status != MeetingStatus.Cancelled && SafeZoomUrl(m.JoinUrl) != null
                }).ToList();
                rptMeetings.DataSource = rows;
                rptMeetings.DataBind();
                pnlEmpty.Visible = rows.Count == 0;
            }
            catch (FirebaseException)
            {
                lblMessage.Text = "Meetings could not be loaded. Please try again.";
                lblMessage.CssClass = "alert alert-danger d-block";
                lblMessage.Visible = true;
            }
        }

        private static string SafeZoomUrl(string value)
        {
            Uri url;
            return Uri.TryCreate(value, UriKind.Absolute, out url) && url.Scheme == Uri.UriSchemeHttps
                && (url.Host.Equals("zoom.us", StringComparison.OrdinalIgnoreCase)
                    || url.Host.EndsWith(".zoom.us", StringComparison.OrdinalIgnoreCase))
                ? value : null;
        }
    }
}
