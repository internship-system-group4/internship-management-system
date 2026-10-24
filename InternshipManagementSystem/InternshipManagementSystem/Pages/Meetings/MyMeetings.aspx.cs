using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web.Script.Serialization;
using System.Web.UI.WebControls;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.MeetingsArea
{
    public partial class MyMeetings : AuthenticatedPage
    {
        private static TimeZoneInfo JordanZone
        {
            get
            {
                return TimeZoneInfo.FindSystemTimeZoneById(
                    "Jordan Standard Time");
            }
        }

        protected override void OnInit(EventArgs e)
        {
            ViewStateUserKey = Session.SessionID;

            base.OnInit(e);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
            {
                return;
            }

            ViewState["RequestId"] =
                Guid.NewGuid().ToString("N");

            try
            {
                string requestedView =
                    Request.QueryString["view"] ?? "all";

                ListItem selected =
                    MeetingFilter.Items.FindByValue(requestedView);

                if (selected != null)
                {
                    MeetingFilter.ClearSelection();

                    selected.Selected = true;
                }
                LoadAllowedRecipients();
                if (Recipient.Items.Count <= 1)
                {
                    Recipient.Items[0].Text = CurrentUser.Role == UserRole.Coordinator
                        ? L.T("Meetings.MyMeetings.MeetingRequestsAreNotAvailableFor")
                        : L.T("Meetings.MyMeetings.NoAssignedContactsAvailable");
                }
                SendRequest.Enabled = Recipient.Items.Count > 1;

                BindMeetings();

                string flash =
                    Session["MeetingFlash"] as string;

                Session.Remove("MeetingFlash");

                if (!string.IsNullOrEmpty(flash))
                {
                    Notice(
                        "Done",
                        flash,
                        false);
                }
            }
            catch (FirebaseAuthExpiredException)
            {
                throw;
            }
            catch (FirebaseException)
            {
                Notice(
                    L.T("Meetings.MyMeetings.CouldNotLoadMeetings"),
                    L.T("Meetings.MyMeetings.CheckYourConnectionAndFirebaseRules"),
                    false);
            }
        }

        private void LoadAllowedRecipients()
        {
            Recipient.Items.Clear();
            Recipient.Items.Add(new ListItem(L.T("Meetings.MyMeetings.SelectAPerson"), ""));
            UserRepository users = new UserRepository();
            PlacementRepository placements = new PlacementRepository();
            Dictionary<string, Person> allowed = new Dictionary<string, Person>(StringComparer.Ordinal);

            CompanySupervisor company = CurrentUser as CompanySupervisor;
            if (company != null && !string.IsNullOrWhiteSpace(company.CompanyId))
            {
                foreach (Placement placement in placements.GetByCompany(company.CompanyId))
                {
                    if (!IsMeetingPlacement(placement) || placement.CompanyId != company.CompanyId) continue;
                    Student student = users.GetStudent(placement.StudentId);
                    if (student != null && student.CanLogin()) allowed[student.Id] = student;
                }
            }

            AcademicSupervisor academic = CurrentUser as AcademicSupervisor;
            if (academic != null)
            {
                foreach (Student student in users.GetStudentsBySupervisor(academic.Id))
                {
                    if (student != null && student.CanLogin()) allowed[student.Id] = student;
                }
                foreach (Placement placement in placements.GetByAcademicSupervisor(academic.Id))
                {
                    if (!IsMeetingPlacement(placement)) continue;
                    Student student = users.GetStudent(placement.StudentId);
                    if (student != null && student.CanLogin()) allowed[student.Id] = student;
                }
            }

            Student currentStudent = CurrentUser as Student;
            if (currentStudent != null)
            {
                Placement placement = placements.GetById(currentStudent.Id);
                string academicSupervisorId = currentStudent.AcademicSupervisorId;
                if (string.IsNullOrWhiteSpace(academicSupervisorId) && IsMeetingPlacement(placement))
                    academicSupervisorId = placement.AcademicSupervisorId;
                if (!string.IsNullOrWhiteSpace(academicSupervisorId))
                {
                    AcademicSupervisor supervisor = users.GetAcademicSupervisor(academicSupervisorId);
                    if (supervisor != null && supervisor.CanLogin()) allowed[supervisor.Id] = supervisor;
                }
                if (IsMeetingPlacement(placement) && placement.StudentId == currentStudent.Id &&
                    !string.IsNullOrWhiteSpace(placement.CompanySupervisorId))
                {
                    CompanySupervisor supervisor = users.GetCompanySupervisor(placement.CompanySupervisorId);
                    if (supervisor != null && supervisor.CanLogin() && supervisor.CompanyId == placement.CompanyId)
                        allowed[supervisor.Id] = supervisor;
                }
            }

            foreach (Person person in allowed.Values.OrderBy(p => p.FullName))
            {
                Recipient.Items.Add(new ListItem(person.FullName + " - " + person.RoleDisplayName, person.Id));
            }
        }

        private static bool IsMeetingPlacement(Placement placement)
        {
            return placement != null &&
                (placement.Status == PlacementStatus.Confirmed ||
                 placement.Status == PlacementStatus.Active ||
                 placement.Status == PlacementStatus.AwaitingCompletion);
        }

        // إرسال طلب ميتنج جديد.
        protected void SendRequest_Click(
            object sender,
            EventArgs e)
        {
            try
            {
                DateTime date;

                bool validDate = DateTime.TryParseExact(
                    MeetingDate.Text,
                    "yyyy-MM-ddTHH:mm",
                    CultureInfo.InvariantCulture,
                    DateTimeStyles.None,
                    out date);

                if (!validDate)
                {
                    throw new InvalidOperationException(
                        "Enter a valid date and time.");
                }

                date = DateTime.SpecifyKind(
                    date,
                    DateTimeKind.Unspecified);

                DateTime utc =
                    TimeZoneInfo.ConvertTimeToUtc(
                        date,
                        JordanZone);

                int duration;

                if (!int.TryParse(
                    Duration.SelectedValue,
                    out duration))
                {
                    throw new InvalidOperationException(
                        L.T("Meetings.I18n.Chooseavalidduration"));
                }

                Meeting meeting = new Meeting
                {
                    Id = ViewState["RequestId"] as string,

                    Title = MeetingTitle.Text.Trim(),

                    Agenda = Agenda.Text.Trim(),

                    CreatedById = CurrentUser.Id,

                    RequestedToId = Recipient.SelectedValue,

                    ScheduledAt =
                        new DateTimeOffset(utc)
                            .ToUnixTimeMilliseconds(),

                    DurationMinutes = duration
                };

                new MeetingRepository().CreateRequest(
                    meeting,
                    CurrentUser.Id);

                Finish(
                    "sent",
                    L.T("Meetings.MyMeetings.YourRequestWasSentItWill"));
            }
            catch (FirebaseAuthExpiredException)
            {
                throw;
            }
            catch (FirebaseException)
            {
                Notice(
                    L.T("Meetings.MyMeetings.RequestNotConfirmed"),
                    L.T("Meetings.MyMeetings.CouldNotConfirmSavingCheckThe"),
                    true);
            }
            catch (InvalidOperationException ex)
            {
                Notice(
                    L.T("Meetings.MyMeetings.CheckYourRequest"),
                    ex.Message,
                    true);
            }
            catch (ArgumentException)
            {
                Notice(
                    L.T("Meetings.MyMeetings.CheckTheTime"),
                    L.T("Meetings.MyMeetings.EnterAValidDateAndTime"),
                    true);
            }
        }

        // تحميل الميتنجات وتحديث العدادات والجدول.
        private void BindMeetings()
        {
            long now = Time.NowMs();

            List<Meeting> all =
                new MeetingRepository()
                    .GetMine(CurrentUser.Id);

            Dictionary<string, Person> people =
                new UserRepository()
                    .GetAll()
                    .ToDictionary(person => person.Id);

            IncomingCount.Text = all
                .Count(meeting => CanRespond(meeting, now))
                .ToString();

            SentCount.Text = all
                .Count(meeting =>
                    IsPending(meeting, now)
                    && meeting.CreatedById == CurrentUser.Id)
                .ToString();

            UpcomingCount.Text = all
                .Count(meeting =>
                    meeting.IsApproved()
                    && meeting.EndsAt() > now)
                .ToString();

            HistoryCount.Text = all
                .Count(meeting => meeting.IsHistory(now))
                .ToString();

            IEnumerable<Meeting> filtered = all;

            switch (MeetingFilter.SelectedValue)
            {
                case "incoming":
                    filtered = all.Where(
                        meeting => CanRespond(meeting, now));

                    break;

                case "sent":
                    filtered = all.Where(
                        meeting =>
                            IsPending(meeting, now)
                            && meeting.CreatedById == CurrentUser.Id);

                    break;

                case "upcoming":
                    filtered = all.Where(
                        meeting =>
                            meeting.IsApproved()
                            && meeting.EndsAt() > now);

                    break;

                case "history":
                    filtered = all.Where(
                        meeting => meeting.IsHistory(now));

                    break;
            }

            MeetingViewName.Text =
                Server.HtmlEncode(
                    MeetingFilter.SelectedItem.Text);

            MeetingGrid.DataSource = filtered
                .Select(meeting => new
                {
                    meeting.Id,

                    meeting.Title,

                    FromName = Name(
                        people,
                        meeting.CreatedById),

                    ToName = Name(
                        people,
                        meeting.RequestedToId),

                    DateText = LocalDate(
                        meeting.ScheduledAt),

                    DurationText =
                        meeting.DurationMinutes + L.T("Meetings.I18n.min"),

                    StateText =
                        meeting.DisplayStatus(now),

                    CanRespond =
                        CanRespond(meeting, now),

                    CanJoin =
                        CanJoin(meeting, now),

                    CanComplete =
                        meeting.CreatedById == CurrentUser.Id
                        && meeting.IsApproved()
                        && meeting.ScheduledAt <= now,

                    CanCancel =
                        meeting.CreatedById == CurrentUser.Id
                        && meeting.Status == MeetingStatus.Scheduled
                        && (
                            meeting.ApprovalState == "Pending"
                            || meeting.ApprovalState == "Accepted"
                        )
                        && meeting.EndsAt() > now
                })
                .ToList();

            MeetingGrid.DataBind();
        }

        private static bool IsPending(
            Meeting meeting,
            long now)
        {
            return meeting.ApprovalState == "Pending"
                && meeting.Status == MeetingStatus.Scheduled
                && meeting.EndsAt() > now;
        }

        private bool CanRespond(
            Meeting meeting,
            long now)
        {
            return meeting.RequestedToId == CurrentUser.Id
                && IsPending(meeting, now);
        }

        // الدخول متاح قبل الموعد بـ15 دقيقة
        // وحتى ما قبل نهاية مدة الميتنج.
        private static bool CanJoin(
            Meeting meeting,
            long now)
        {
            return meeting.IsApproved()
                && now >= meeting.ScheduledAt - 15L * 60000
                && now < meeting.EndsAt();
        }

        private static string Name(
            Dictionary<string, Person> people,
            string id)
        {
            Person person;

            if (id != null
                && people.TryGetValue(id, out person))
            {
                return person.FullName;
            }

            return L.T("Meetings.MyMeetings.AccountUnavailable");
        }

        private static string LocalDate(long milliseconds)
        {
            DateTime utc =
                DateTimeOffset
                    .FromUnixTimeMilliseconds(milliseconds)
                    .UtcDateTime;

            DateTime local =
                TimeZoneInfo.ConvertTimeFromUtc(
                    utc,
                    JordanZone);

            return local.ToString(
                "ddd, dd MMM yyyy - HH:mm",
                CultureInfo.InvariantCulture);
        }

        // أكشنات الأزرار الموجودة داخل جدول الميتنجات.
        protected void MeetingGrid_RowCommand(
            object sender,
            GridViewCommandEventArgs e)
        {
            string action = e.CommandName;

            string[] allowedActions =
            {
                "Accept",
                "Reject",
                "Complete",
                "CancelMeeting",
                "Details",
                "Join"
            };

            if (!allowedActions.Contains(action))
            {
                return;
            }

            string id =
                Convert.ToString(e.CommandArgument);

            try
            {
                MeetingRepository repository =
                    new MeetingRepository();

                Meeting meeting =
                    repository.GetById(id);

                if (meeting == null
                    || !meeting.CanBeViewedBy(CurrentUser.Id))
                {
                    throw new InvalidOperationException(
                        L.T("Meetings.I18n.Meetingnotfoundoraccessdenied"));
                }

                // عرض التفاصيل داخل Popup.
                if (action == "Details")
                {
                    Dictionary<string, Person> people =
                        new UserRepository()
                            .GetAll()
                            .ToDictionary(person => person.Id);

                    DetailTitle.Text =
                        Server.HtmlEncode(meeting.Title);

                    DetailPeople.Text =
                        Server.HtmlEncode(
                            L.T("Meetings.I18n.From")
                            + Name(people, meeting.CreatedById)
                            + L.T("Meetings.I18n.To")
                            + Name(people, meeting.RequestedToId));

                    DetailTime.Text =
                        Server.HtmlEncode(
                            LocalDate(meeting.ScheduledAt)
                            + L.T("Meetings.I18n.Jordantime")
                            + meeting.DurationMinutes
                            + L.T("Meetings.I18n.minutes"));

                    DetailState.Text =
                        Server.HtmlEncode(
                            L.Value("Ui", meeting.DisplayStatus(Time.NowMs())));

                    DetailAgenda.Text =
                        Server.HtmlEncode(
                            string.IsNullOrWhiteSpace(meeting.Agenda)
                                ? L.T("Meetings.MyMeetings.NoAgendaProvided")
                                : meeting.Agenda);

                    RunScript(
                        "showMeetingDialog('detailsDialog');");

                    return;
                }

                // فتح الروم داخل Popup بعد التحقق على السيرفر.
                if (action == "Join")
                {
                    if (!CanJoin(meeting, Time.NowMs()))
                    {
                        throw new InvalidOperationException(
                            L.T("Meetings.I18n.Joinisavailablefrom15minutesbefore"));
                    }

                    Uri uri;

                    bool validUrl = Uri.TryCreate(
                        meeting.JoinUrl,
                        UriKind.Absolute,
                        out uri);

                    if (!validUrl
                        || uri.Scheme != "https"
                        || !string.Equals(
                            uri.Host,
                            "meet.jit.si",
                            StringComparison.OrdinalIgnoreCase)
                        || !System.Text.RegularExpressions.Regex.IsMatch(
                            uri.AbsolutePath,
                            @"^/UIMS-[a-f0-9]{32}$"))
                    {
                        throw new InvalidOperationException(
                            L.T("Meetings.I18n.ThisisanoldermeetinglinkCreate"));
                    }

                    string roomName =
                        uri.AbsolutePath.TrimStart('/');

                    string roomJson =
                        new JavaScriptSerializer()
                            .Serialize(roomName);

                    RunScript(
                        "openMeetingRoom("
                        + roomJson
                        + ");");

                    return;
                }

                // تنفيذ الموافقة أو الرفض أو الإلغاء أو الإنهاء.
                string repositoryAction =
                    action == "CancelMeeting"
                        ? "Cancel"
                        : action;

                repository.ApplyAction(
                    id,
                    CurrentUser.Id,
                    repositoryAction);

                if (action == "Accept")
                {
                    Finish(
                        "upcoming",
                        L.T("Meetings.MyMeetings.MeetingAcceptedUseJoinMeetingDuring"));
                }
                else
                {
                    string message;

                    if (action == "Reject")
                    {
                        message = L.T("Meetings.MyMeetings.TheRequestWasDeclined");
                    }
                    else if (action == "Complete")
                    {
                        message = L.T("Meetings.MyMeetings.TheMeetingWasMarkedCompleted");
                    }
                    else
                    {
                        message = L.T("Meetings.MyMeetings.TheMeetingWasCancelled");
                    }

                    Finish(
                        "history",
                        message);
                }
            }
            catch (FirebaseAuthExpiredException)
            {
                throw;
            }
            catch (FirebaseException)
            {
                Notice(
                    L.T("Meetings.MyMeetings.ActionNotConfirmed"),
                    L.T("Meetings.MyMeetings.RefreshTheListToCheckThe"),
                    false);
            }
            catch (InvalidOperationException ex)
            {
                Notice(
                    L.T("Meetings.MyMeetings.ActionUnavailable"),
                    ex.Message,
                    false);
            }
        }

        // تطبيق نوع العرض المحدد.
        protected void ApplyFilter_Click(
            object sender,
            EventArgs e)
        {
            Reload(false);
        }

        // تحديث القائمة مع رسالة نجاح.
        protected void Refresh_Click(
            object sender,
            EventArgs e)
        {
            Reload(true);
        }

        private void Reload(bool notify)
        {
            try
            {
                BindMeetings();

                if (notify)
                {
                    Notice(
                        L.T("Meetings.MyMeetings.ListUpdated"),
                        L.T("Meetings.MyMeetings.YouAreViewingTheLatestMeeting"),
                        false);
                }
            }
            catch (FirebaseAuthExpiredException)
            {
                throw;
            }
            catch (FirebaseException)
            {
                Notice(
                    L.T("Meetings.MyMeetings.CouldNotRefresh"),
                    L.T("Meetings.MyMeetings.CheckYourConnectionAndTryAgain"),
                    false);
            }
        }

        // إعادة التوجيه بعد نجاح العملية
        // لمنع تكرار إرسالها عند تحديث الصفحة.
        private void Finish(
            string view,
            string message)
        {
            Session["MeetingFlash"] = message;

            Response.Redirect(
                "MyMeetings.aspx?view=" + view,
                true);
        }

        // إظهار رسالة داخل Popup.
        private void Notice(
            string title,
            string message,
            bool reopenRequest)
        {
            NoticeTitle.Text =
                Server.HtmlEncode(title);

            NoticeText.Text =
                Server.HtmlEncode(message);

            string javascript = "";

            if (reopenRequest)
            {
                javascript +=
                    "showMeetingDialog('requestDialog');";
            }

            javascript +=
                "showMeetingDialog('noticeDialog');";

            RunScript(javascript);
        }

        private void RunScript(string javascript)
        {
            ClientScript.RegisterStartupScript(
                GetType(),
                Guid.NewGuid().ToString("N"),
                "window.addEventListener('load', function(){"
                    + javascript
                    + "});",
                true);
        }
    }
}


