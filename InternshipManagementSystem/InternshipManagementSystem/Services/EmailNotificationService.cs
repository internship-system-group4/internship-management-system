using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Globalization;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Web.Configuration;
using System.Web;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Services
{
    /// <summary>Best-effort, post-save notifications. Never rolls back a domain operation.</summary>
    public static class EmailNotificationService
    {
        public static bool Enabled
        {
            get { return string.Equals(Setting("Email.Enabled"), "true", StringComparison.OrdinalIgnoreCase); }
        }

        public static bool InboxEnabled
        {
            get { return !string.Equals(Setting("Notifications.Enabled"), "false", StringComparison.OrdinalIgnoreCase); }
        }

        internal static void TryNotify(Action action)
        {
            try { if (Enabled || InboxEnabled) action(); }
            catch (Exception ex) { LogFailure(ex); }
        }

        internal static void LogFailure(Exception ex)
        {
            // SMTP errors can contain addresses, credentials or message content.
            Trace.TraceWarning("Email notification failed ({0}). Check mail configuration and server availability.",
                ex.GetType().Name);
        }

        /// <summary>Sends the email (and, when <paramref name="writeInbox"/> is true, the
        /// English inbox entry) for a saved record. Pass writeInbox = false when the
        /// caller already sent the bilingual notice through NotificationService,
        /// so the person does not get the same event twice in the bell.</summary>
        internal static void Saved(object previous, object current, bool writeInbox = true)
        {
            if (!writeInbox && !Enabled) return;
            var addresses = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            TryNotify(() => new NotificationDispatcher(
                id => new UserRepository().GetPerson(id),
                role => new UserRepository().GetByRole(role),
                id => new PlacementRepository().GetById(id),
                (recipient, subject, detail, page) => DeliverChannels(recipient, subject, detail, page,
                    addresses.Add((recipient.Email ?? "").Trim()), writeInbox), false).Saved(previous, current));
        }

        internal static void DeliverChannels(Person recipient, string subject, string detail, string page, bool sendEmail = true, bool writeInbox = true)
        {
            UserNotification item = new UserNotification { RecipientId = recipient.Id, Title = subject,
                SenderId = Security.SessionHelper.Current == null ? null : Security.SessionHelper.Current.Id,
                Detail = detail, Page = page, CreatedAt = Time.NowMs(), EmailStatus = !Enabled ? "Disabled" : sendEmail ? "Pending" : "Duplicate" };
            bool stored = false;
            try { if (InboxEnabled && writeInbox) { new NotificationRepository().Add(item); stored = true; } }
            catch (Exception ex) { LogFailure(ex); }
            if (!Enabled || !sendEmail) return;
            string status = "Sent";
            try { Send(recipient, subject, detail, page); }
            catch (Exception ex) { status = "Failed"; LogFailure(ex); }
            if (stored)
                try { new NotificationRepository().SetEmailStatus(item, status); }
                catch (Exception ex) { LogFailure(ex); }
        }

        /// <summary>Only the email (no inbox entry), for events whose bell notice comes
        /// from NotificationService. <paramref name="link"/> may start with "~/".
        /// A failure is only logged.</summary>
        internal static void EmailOnly(Person recipient, string subject, string detail, string link)
        {
            if (!Enabled || recipient == null || string.IsNullOrWhiteSpace(recipient.Email)) return;
            try { Send(recipient, subject, detail, (link ?? "").TrimStart('~', '/')); }
            catch (Exception ex) { LogFailure(ex); }
        }

        private static string Setting(string name)
        { return (WebConfigurationManager.AppSettings[name] ?? "").Trim(); }

        private static void Send(Person recipient, string subject, string detail, string relativePage)
        {
            Uri baseUri;
            string baseUrl = Setting("Email.ApplicationUrl").TrimEnd('/') + "/";
            if (!Uri.TryCreate(baseUrl, UriKind.Absolute, out baseUri) ||
                (baseUri.Scheme != Uri.UriSchemeHttps && baseUri.Scheme != Uri.UriSchemeHttp) ||
                !string.IsNullOrEmpty(baseUri.UserInfo) || !string.IsNullOrEmpty(baseUri.Query) ||
                !string.IsNullOrEmpty(baseUri.Fragment))
                throw new InvalidOperationException("Email.ApplicationUrl must be the application's absolute URL.");

            int port;
            if (!int.TryParse(Setting("Email.SmtpPort"), out port) || port < 1 || port > 65535)
                throw new InvalidOperationException("Email.SmtpPort is invalid.");
            if (string.IsNullOrEmpty(Setting("Email.SmtpHost")))
                throw new InvalidOperationException("Email.SmtpHost is required.");
            bool enableSsl;
            if (!bool.TryParse(Setting("Email.EnableSsl"), out enableSsl))
                throw new InvalidOperationException("Email.EnableSsl must be true or false.");

            using (MailMessage message = new MailMessage())
            using (SmtpClient client = new SmtpClient(Setting("Email.SmtpHost"), port))
            {
                message.From = new MailAddress(Setting("Email.FromAddress"), Setting("Email.FromName"));
                message.To.Add(new MailAddress(recipient.Email.Trim()));
                message.Subject = "UIMS: " + subject;
                message.SubjectEncoding = Encoding.UTF8;
                message.BodyEncoding = Encoding.UTF8;
                string link = new Uri(baseUri, relativePage).AbsoluteUri;
                string plain = "Hello " + (recipient.FullName ?? "") + ",\n\n" + detail +
                    "\n\nSign in to UIMS to view the details:\n" + new Uri(baseUri, relativePage).AbsoluteUri +
                    "\n\nUniversity Internship Management System\nThis is an automatic notification.";
                message.Body = plain;
                message.AlternateViews.Add(AlternateView.CreateAlternateViewFromString(plain, Encoding.UTF8, "text/plain"));
                string html = "<!doctype html><html><body style='margin:0;background:#f3f6fa;font-family:Arial,sans-serif;color:#162b47'>" +
                    "<table role='presentation' width='100%'><tr><td align='center' style='padding:32px 12px'>" +
                    "<table role='presentation' width='560' style='max-width:100%;background:white;border-radius:18px'><tr><td style='padding:32px'>" +
                    "<p style='color:#2466ad;font-weight:bold;letter-spacing:2px'>UIMS · NOTIFICATIONS</p><h1 style='font-size:24px'>" + HttpUtility.HtmlEncode(subject) +
                    "</h1><p>Hello " + HttpUtility.HtmlEncode(recipient.FullName ?? "") + ",</p><p style='line-height:1.7'>" + HttpUtility.HtmlEncode(detail) +
                    "</p><p style='margin:28px 0'><a style='display:inline-block;background:#195c9e;color:white;padding:14px 22px;border-radius:10px;text-decoration:none' href='" + HttpUtility.HtmlAttributeEncode(link) +
                    "'>View in UIMS →</a></p><p style='font-size:12px;color:#62748a'>Sign in to view details securely.<br>University Internship Management System</p>" +
                    "</td></tr></table></td></tr></table></body></html>";
                message.AlternateViews.Add(AlternateView.CreateAlternateViewFromString(html, Encoding.UTF8, "text/html"));
                client.DeliveryMethod = SmtpDeliveryMethod.Network;
                client.EnableSsl = enableSsl;
                client.UseDefaultCredentials = false;
                client.Timeout = 5000;
                string username = Setting("Email.SmtpUsername");
                if (username.Length > 0)
                    client.Credentials = new NetworkCredential(username,
                        WebConfigurationManager.AppSettings["Email.SmtpPassword"] ?? "");
                client.Send(message);
            }
        }
    }

    /// <summary>Event policy kept separate from SMTP so recipients and transitions can be tested offline.</summary>
    internal sealed class NotificationDispatcher
    {
        private readonly Func<string, Person> person;
        private readonly Func<UserRole, List<Person>> people;
        private readonly Func<string, Placement> placement;
        private readonly Action<Person, string, string, string> send;
        private readonly HashSet<string> delivered = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        private readonly bool emailRecipients;

        internal NotificationDispatcher(Func<string, Person> person, Func<UserRole, List<Person>> people,
            Func<string, Placement> placement, Action<Person, string, string, string> send, bool emailRecipients = true)
        { this.person = person; this.people = people; this.placement = placement; this.send = send; this.emailRecipients = emailRecipients; }

        internal void Saved(object previous, object current)
        {
            InternshipTask task = current as InternshipTask;
            if (task != null)
            {
                InternshipTask old = previous as InternshipTask;
                if (old == null || old.StudentId != task.StudentId)
                    To(task.StudentId, "New task assigned", "You have been assigned the task: " + task.Title + ".",
                        "Pages/Student/MyTasks.aspx");
                else if (old.Title != task.Title || old.Description != task.Description || old.Instructions != task.Instructions || old.Deadline != task.Deadline)
                    To(task.StudentId, "Task details updated", "Your assigned task has been updated: " + task.Title + ". Check the instructions and deadline.", "Pages/Student/MyTasks.aspx");
                return;
            }
            Submission submission = current as Submission;
            if (submission != null && previous == null)
            {
                Placement p = placement(submission.PlacementId);
                if (p != null && p.StudentId == submission.StudentId)
                    To(p.CompanySupervisorId, "Task submission ready for review",
                        "A trainee has submitted a task attempt for your review.", "Pages/Company/TaskReview.aspx");
                return;
            }
            TaskEvaluation review = current as TaskEvaluation;
            if (review != null && previous == null)
            {
                To(review.StudentId, review.RevisionRequested ? "Task revision requested" : "Task evaluated",
                    review.RevisionRequested ? "Your supervisor has requested a revision to a task. Open your tasks to read the instructions."
                    : "Your supervisor has evaluated a task. Open your progress to read the feedback.",
                    review.RevisionRequested ? "Pages/Student/MyTasks.aspx" : "Pages/Student/Progress.aspx");
                return;
            }
            FinalCompanyEvaluation company = current as FinalCompanyEvaluation;
            if (company != null)
            {
                FinalCompanyEvaluation old = previous as FinalCompanyEvaluation;
                if (company.IsSubmitted && (old == null || !old.IsSubmitted))
                {
                    Coordinators(company.StudentId, "Company evaluation submitted",
                        "A company final evaluation has been submitted and is available for completion review.");
                    Placement p = placement(company.PlacementId);
                    if (p != null && p.StudentId == company.StudentId)
                        To(p.AcademicSupervisorId, "Company evaluation available",
                            "A company final evaluation is available for an assigned student. Sign in to review it and complete your academic evaluation.",
                            "Pages/Academic/FinalEvaluation.aspx?id=" + Uri.EscapeDataString(company.StudentId));
                }
                return;
            }
            FinalAcademicEvaluation academic = current as FinalAcademicEvaluation;
            if (academic != null)
            {
                FinalAcademicEvaluation old = previous as FinalAcademicEvaluation;
                if (academic.IsSubmitted && (old == null || !old.IsSubmitted))
                    Coordinators(academic.StudentId, "Academic evaluation submitted",
                        "An academic final evaluation has been submitted and is available for completion review.");
                return;
            }
            CompletionRecord completion = current as CompletionRecord;
            if (completion != null)
            {
                CompletionRecord old = previous as CompletionRecord;
                if (old != null && old.Status == completion.Status) return;
                if (completion.Status == CompletionStatus.UnderCoordinatorReview)
                    Coordinators(completion.StudentId, "Completion review requested",
                        "An internship completion is awaiting your review.");
                else if (completion.Status == CompletionStatus.AwaitingCompanyEvaluation ||
                    completion.Status == CompletionStatus.AwaitingAcademicEvaluation)
                {
                    Placement p = placement(completion.PlacementId);
                    if (p != null && p.StudentId == completion.StudentId)
                        To(completion.Status == CompletionStatus.AwaitingCompanyEvaluation ? p.CompanySupervisorId : p.AcademicSupervisorId,
                            "Final evaluation requested", "A final evaluation is requested for an assigned trainee.",
                            completion.Status == CompletionStatus.AwaitingCompanyEvaluation ? "Pages/Company/FinalEvaluation.aspx" : "Pages/Academic/FinalEvaluation.aspx");
                }
                else if (completion.Status == CompletionStatus.Approved || completion.Status == CompletionStatus.Rejected || completion.Status == CompletionStatus.NeedsCorrections)
                    To(completion.StudentId, "Internship completion review updated",
                        "Your internship completion review has been " + (completion.Status == CompletionStatus.Approved ? "approved" : completion.Status == CompletionStatus.NeedsCorrections ? "returned for corrections" : "rejected") +
                        ". Sign in to view your progress and any released result.", "Pages/Student/Progress.aspx");
                return;
            }
            TrainingHoursEntry hours = current as TrainingHoursEntry;
            if (hours != null)
            {
                TrainingHoursEntry old = previous as TrainingHoursEntry;
                if (old == null && hours.Status == HoursStatus.Reported)
                {
                    Placement p = placement(hours.PlacementId);
                    if (p != null && p.StudentId == hours.StudentId)
                        To(p.AcademicSupervisorId, "Training hours awaiting review",
                            "An assigned student has reported training hours for your review.", "Pages/Academic/StudentProgress.aspx");
                }
                else if (old != null && old.Status != hours.Status &&
                    (hours.Status == HoursStatus.Approved || hours.Status == HoursStatus.Rejected))
                    To(hours.StudentId, "Training hours reviewed", "Your reported training hours have been " +
                        (hours.Status == HoursStatus.Approved ? "approved" : "rejected") + ".", "Pages/Student/Progress.aspx");
                return;
            }
            InternshipApplication application = current as InternshipApplication;
            if (application != null)
            {
                InternshipApplication old = previous as InternshipApplication;
                if (old == null && application.Status == ApplicationStatus.Pending)
                {
                    foreach (CompanySupervisor supervisor in people(UserRole.CompanySupervisor).OfType<CompanySupervisor>()
                        .Where(p => p.CompanyId == application.CompanyId))
                        Deliver(supervisor, "New internship application", "A student has applied to an internship opportunity at your company.",
                            "Pages/Company/Applications.aspx");
                }
                else if ((old == null || old.Status != application.Status) &&
                    (application.Status == ApplicationStatus.Accepted || application.Status == ApplicationStatus.Rejected))
                    To(application.StudentId, "Internship application updated", "Your internship application has been " +
                        (application.Status == ApplicationStatus.Accepted ? "accepted" : "rejected") + ". Sign in for the details.",
                        "Pages/Student/MyApplications.aspx");
                return;
            }
            Student student = current as Student;
            if (student != null)
            {
                Student old = previous as Student;
                if (old == null || old.AcademicSupervisorId != student.AcademicSupervisorId)
                {
                    To(student.AcademicSupervisorId, "New student assigned", "A student has been assigned to you for academic supervision.", "Pages/Academic/Dashboard.aspx");
                    if (!string.IsNullOrEmpty(student.AcademicSupervisorId))
                        To(student.Id, "Academic supervisor assigned", "Your academic supervisor assignment has been updated.", "Pages/Student/Profile.aspx");
                    else if (old != null && !string.IsNullOrEmpty(old.AcademicSupervisorId))
                        To(student.Id, "Academic supervision updated", "Your academic supervision assignment has been removed. Contact your coordinator for your new assignment.", "Pages/Student/Profile.aspx");
                    if (old != null && old.AcademicSupervisorId != student.AcademicSupervisorId)
                        To(old.AcademicSupervisorId, "Student assignment ended", "A student's academic supervision has been reassigned or removed.", "Pages/Academic/Dashboard.aspx");
                }
                return;
            }
            AcademicComment comment = current as AcademicComment;
            if (comment != null)
            {
                AcademicComment old = previous as AcademicComment;
                if (comment.IsVisibleToStudent && (old == null || !old.IsVisibleToStudent || old.Comment != comment.Comment))
                    To(comment.StudentId, "New academic feedback", "Your academic supervisor has added feedback. Sign in to read it.", "Pages/Student/Progress.aspx");
                return;
            }
            Placement confirmed = current as Placement;
            if (confirmed != null)
            {
                Placement old = previous as Placement;
                if (old != null)
                {
                    if (old.CompanySupervisorId != confirmed.CompanySupervisorId)
                    {
                        To(confirmed.CompanySupervisorId, "New trainee assigned", "A trainee has been assigned to you.", "Pages/Company/Trainees.aspx");
                        To(old.CompanySupervisorId, "Trainee assignment ended", "A trainee has been reassigned from your supervision.", "Pages/Company/Trainees.aspx");
                        To(confirmed.StudentId, "Company supervisor updated", "Your company supervisor assignment has changed.", "Pages/Student/Progress.aspx");
                    }
                    if (old.AcademicSupervisorId != confirmed.AcademicSupervisorId)
                    {
                        To(confirmed.AcademicSupervisorId, "Student placement assigned", "A student placement has been assigned to you.", "Pages/Academic/Dashboard.aspx");
                        To(old.AcademicSupervisorId, "Student placement reassigned", "A student placement has been reassigned from your supervision.", "Pages/Academic/Dashboard.aspx");
                        To(confirmed.StudentId, "Academic supervisor updated", "Your placement's academic supervisor has changed.", "Pages/Student/Progress.aspx");
                    }
                    if (old.Status != confirmed.Status && confirmed.Status == PlacementStatus.Cancelled)
                    {
                        To(confirmed.StudentId, "Internship placement cancelled", "Your internship placement has been cancelled. Contact your coordinator.", "Pages/Student/Progress.aspx");
                        To(confirmed.CompanySupervisorId, "Internship placement cancelled", "An assigned trainee's placement has been cancelled.", "Pages/Company/Trainees.aspx");
                        To(confirmed.AcademicSupervisorId, "Internship placement cancelled", "An assigned student's placement has been cancelled.", "Pages/Academic/Dashboard.aspx");
                    }
                    return;
                }
                To(confirmed.StudentId, "Internship placement confirmed", "Your internship placement has been confirmed.", "Pages/Student/Progress.aspx");
                To(confirmed.CompanySupervisorId, "New trainee placement confirmed", "A trainee has confirmed an internship placement with you.", "Pages/Company/Trainees.aspx");
                To(confirmed.AcademicSupervisorId, "Student placement confirmed", "An assigned student's internship placement has been confirmed.", "Pages/Academic/Dashboard.aspx");
                return;
            }
            Meeting meeting = current as Meeting;
            if (meeting != null) MeetingSaved(previous as Meeting, meeting);
            ContactMessage contact = current as ContactMessage;
            if (contact != null && previous == null)
                foreach (var coordinator in people(UserRole.Coordinator))
                    Deliver(coordinator, "New contact message", "A new contact message is awaiting your review.", "Pages/Coordinator/ContactMessages.aspx");
        }

        private void MeetingSaved(Meeting old, Meeting meeting)
        {
            List<string> ids = meeting.ParticipantIds ?? new List<string>();
            List<string> oldIds = old == null ? new List<string>() : old.ParticipantIds ?? new List<string>();
            bool changed = old == null || old.Title != meeting.Title || old.Agenda != meeting.Agenda ||
                old.ScheduledAt != meeting.ScheduledAt || old.DurationMinutes != meeting.DurationMinutes ||
                old.Status != meeting.Status || old.JoinUrl != meeting.JoinUrl;
            foreach (string id in ids.Union(oldIds).Where(id => id != meeting.CreatedById))
            {
                bool removed = !ids.Contains(id);
                if (!changed && !removed && oldIds.Contains(id)) continue;
                bool cancelled = removed || meeting.Status == MeetingStatus.Cancelled;
                To(id, cancelled ? "Meeting invitation cancelled" : old == null || !oldIds.Contains(id) ? "Meeting invitation" : "Meeting updated",
                    cancelled ? "Your meeting invitation has been cancelled."
                    : "You are invited to " + meeting.Title + " on " + Time.FromUnixMs(meeting.ScheduledAt)
                        .ToString("yyyy-MM-dd HH:mm 'UTC'", CultureInfo.InvariantCulture) + ". Sign in for the meeting details.",
                    "Pages/Meetings/MyMeetings.aspx");
            }
        }

        private void Coordinators(string studentId, string subject, string detail)
        {
            foreach (Person coordinator in people(UserRole.Coordinator))
                Deliver(coordinator, subject, detail,
                    "Pages/Coordinator/CompletionReview.aspx?id=" + Uri.EscapeDataString(studentId ?? ""));
        }

        private void To(string id, string subject, string detail, string page)
        {
            if (string.IsNullOrEmpty(id)) return;
            try { Deliver(person(id), subject, detail, page); }
            catch (Exception ex) { EmailNotificationService.LogFailure(ex); }
        }

        private void Deliver(Person recipient, string subject, string detail, string page)
        {
            if (recipient == null || !recipient.IsActive) return;
            try
            {
                if (!emailRecipients)
                {
                    if (string.IsNullOrEmpty(recipient.Id) || !delivered.Add(recipient.Id)) return;
                    send(recipient, subject, detail, page);
                    return;
                }
                if (string.IsNullOrWhiteSpace(recipient.Email)) return;
                string address = recipient.Email.Trim();
                MailAddress parsed = new MailAddress(address);
                if (!string.Equals(parsed.Address, address, StringComparison.OrdinalIgnoreCase) ||
                    !delivered.Add(address)) return;
                send(recipient, subject, detail, page);
            }
            catch (Exception ex) { EmailNotificationService.LogFailure(ex); }
        }
    }
}
