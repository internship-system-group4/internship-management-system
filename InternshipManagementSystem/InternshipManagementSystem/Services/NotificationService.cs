// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad
//  Sends the notifications that appear in the top-bar bell of every portal.
// =============================================================================

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Globalization;
using System.Linq;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Services
{
    /// <summary>
    /// One method per workflow event. The repositories (and a few pages) call
    /// these right after a successful save.
    ///
    /// Each notification stores a Key such as "ApplicationSubmitted" plus a few
    /// Args (names, titles). The text lives in Shared.resx / Shared.ar.resx as
    /// "Notify.{Key}.Title" and "Notify.{Key}.Message", so every person reads it
    /// in their own language. The English text is saved too, as a fallback.
    ///
    /// A notification never breaks a save: if sending fails (for example the
    /// database rules are missing) the error is logged and the action still succeeds.
    /// </summary>
    public static class NotificationService
    {
        // Notification types - the bell picks an icon and a label from these.
        public const string TypeTask = "Task";
        public const string TypeGroup = "Group";
        public const string TypeApplication = "Application";
        public const string TypePlacement = "Placement";
        public const string TypeHours = "Hours";
        public const string TypeEvaluation = "Evaluation";
        public const string TypeComment = "Comment";
        public const string TypeMeeting = "Meeting";
        public const string TypeOpportunity = "Opportunity";
        public const string TypeCompletion = "Completion";
        public const string TypeAccount = "Account";

        // ------------------------------------------------------------------
        //  Text shown to the reader (bell, toast and Notifications page)
        // ------------------------------------------------------------------

        public static string TitleOf(Notification item)
        {
            if (item == null) return "";
            string id = "Shared.Notify." + item.Key + ".Title";
            if (!string.IsNullOrEmpty(item.Key) && L.Has(id)) return L.T(id);
            return item.Title ?? "";
        }

        public static string MessageOf(Notification item)
        {
            if (item == null) return "";
            string id = "Shared.Notify." + item.Key + ".Message";
            if (!string.IsNullOrEmpty(item.Key) && L.Has(id))
            {
                try
                {
                    object[] args = (item.Args ?? new List<string>()).Cast<object>().ToArray();
                    return string.Format(CultureInfo.CurrentCulture, L.T(id), args);
                }
                catch (FormatException) { }
            }
            return item.Message ?? "";
        }

        /// <summary>Short category name, for example "Application" / "طلب تدريب".</summary>
        public static string TypeLabel(string type)
        {
            string id = "Shared.Notify.Type." + type;
            return !string.IsNullOrEmpty(type) && L.Has(id) ? L.T(id) : L.T("Shared.Notify.Type.General");
        }

        // ------------------------------------------------------------------
        //  Delivery health - shown in the bell when the rules block notifications
        // ------------------------------------------------------------------

        /// <summary>True after a notification was refused by the Firebase rules
        /// ("Permission denied"). Cleared by the next one that is saved.</summary>
        public static bool BlockedByRules { get; private set; }

        private static void RecordFailure(Notification notification, Exception ex)
        {
            string reason = ex == null ? "" : ex.Message;
            if (reason.IndexOf("Permission denied", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                BlockedByRules = true;
                // Trace.TraceError shows in the Visual Studio Output window.
                Trace.TraceError("[UIMS notifications] Firebase refused notification '{0}' for {1}. " +
                    "Publish the \"notifications\" rule from docs/05-firebase-setup.md in Firebase > Realtime Database > Rules.",
                    notification.Key, notification.RecipientId);
            }
            else
            {
                Trace.TraceError("[UIMS notifications] '{0}' was not sent to {1}: {2}",
                    notification.Key, notification.RecipientId, reason);
            }
        }

        // ------------------------------------------------------------------
        //  Basic sending
        // ------------------------------------------------------------------

        /// <summary>Sends one notification. Nothing is sent to the person who
        /// did the action themselves.</summary>
        public static void Send(string recipientId, string type, string key, string link, params string[] args)
        {
            if (string.IsNullOrEmpty(recipientId)) return;
            Person current = SessionHelper.Current;
            if (current != null && current.Id == recipientId) return;

            List<string> values = (args ?? new string[0]).Select(a => a ?? "").ToList();
            var notification = new Notification
            {
                RecipientId = recipientId,
                Type = type,
                Key = key,
                Args = values,
                Title = L.InEnglish("Shared.Notify." + key + ".Title"),
                Message = EnglishMessage(key, values),
                Link = link,
                IsRead = false
            };

            // Inside an event (see Safely) the notifications are collected and
            // saved together at the end, in one request.
            if (pending != null)
            {
                if (!pending.Any(n => n.RecipientId == recipientId && n.Key == key && n.Link == link)) pending.Add(notification);
                return;
            }
            SaveOne(notification);
        }

        private static string EnglishMessage(string key, List<string> values)
        {
            string format = L.InEnglish("Shared.Notify." + key + ".Message");
            try { return string.Format(CultureInfo.InvariantCulture, format, values.Cast<object>().ToArray()); }
            catch (FormatException) { return format; }
        }

        private static void SaveOne(Notification notification)
        {
            try
            {
                new NotificationRepository().Add(notification);
                BlockedByRules = false;
            }
            catch (Exception ex)
            {
                RecordFailure(notification, ex);
            }
        }

        /// <summary>Notifications collected by the event that is running now.
        /// One per thread, and a web request runs on one thread.</summary>
        [ThreadStatic] private static List<Notification> pending;

        /// <summary>Runs one event safely: a failed lookup only skips the notification.
        /// Everything the event sends is saved at the end in ONE request.</summary>
        private static void Safely(string eventName, Action action)
        {
            bool outermost = pending == null;
            if (outermost) pending = new List<Notification>();
            try
            {
                action();
            }
            catch (Exception ex)
            {
                Trace.TraceError("[UIMS notifications] Event {0} skipped: {1}", eventName, ex.Message);
            }
            finally
            {
                if (outermost)
                {
                    List<Notification> batch = pending;
                    pending = null;
                    SaveAll(batch);
                }
            }
        }

        private static void SaveAll(List<Notification> batch)
        {
            if (batch.Count == 0) return;
            if (batch.Count == 1) { SaveOne(batch[0]); return; }
            try
            {
                new NotificationRepository().AddMany(batch);
                BlockedByRules = false;
            }
            catch (Exception ex)
            {
                // A multi-path update is all or nothing; fall back to one by one
                // so a single bad recipient does not stop the others.
                Trace.TraceWarning("Batched notifications failed, sending one by one: " + ex.Message);
                foreach (Notification notification in batch) SaveOne(notification);
            }
        }

        private static void SendToCoordinators(string type, string key, string link, params string[] args)
        {
            foreach (Person coordinator in new UserRepository().GetByRole(UserRole.Coordinator))
            {
                if (coordinator.IsActive) Send(coordinator.Id, type, key, link, args);
            }
        }

        private static string NameOf(string userId)
        {
            Person person = new UserRepository().GetPerson(userId);
            return person == null || string.IsNullOrWhiteSpace(person.FullName) ? L.InEnglish("Shared.Notify.AStudent") : person.FullName;
        }

        private static string Shorten(string text, int length)
        {
            text = (text ?? "").Trim();
            return text.Length <= length ? text : text.Substring(0, length).TrimEnd() + "…";
        }

        private static string With(string page, string name, string value)
        {
            return string.IsNullOrEmpty(value) ? page : page + "?" + name + "=" + Uri.EscapeDataString(value);
        }

        private static string WithId(string page, string id)
        {
            return With(page, "id", id);
        }

        private static string Number(double value)
        {
            return value.ToString("0.##", CultureInfo.InvariantCulture);
        }

        // ------------------------------------------------------------------
        //  1. Opportunities and applications
        // ------------------------------------------------------------------

        /// <summary>A company published an opportunity: tell every eligible student.</summary>
        public static void OpportunityPublished(string opportunityId)
        {
            Safely("OpportunityPublished", () =>
            {
                Opportunity opportunity = new OpportunityRepository().GetById(opportunityId);
                if (opportunity == null || !opportunity.IsOpenForApplications) return;

                string companyName = opportunity.CompanyName;
                if (string.IsNullOrWhiteSpace(companyName))
                {
                    Company company = new CompanyRepository().GetById(opportunity.CompanyId);
                    companyName = company == null || string.IsNullOrWhiteSpace(company.Name) ? "A company" : company.Name;
                }

                foreach (Person person in new UserRepository().GetByRole(UserRole.Student))
                {
                    Student student = person as Student;
                    if (student == null || !student.IsActive || !opportunity.IsEligible(student)) continue;
                    Send(student.Id, TypeOpportunity, "OpportunityPublished",
                        WithId("~/Pages/Student/OpportunityDetails.aspx", opportunity.Id),
                        companyName, opportunity.Title);
                }
            });
        }

        /// <summary>A student applied: tell every active supervisor of that company,
        /// and the supervisor who posted the opportunity.</summary>
        public static void ApplicationSubmitted(InternshipApplication application)
        {
            Safely("ApplicationSubmitted", () =>
            {
                var recipients = new HashSet<string>();
                foreach (Person person in new UserRepository().GetByRole(UserRole.CompanySupervisor))
                {
                    CompanySupervisor supervisor = person as CompanySupervisor;
                    if (supervisor != null && supervisor.IsActive && supervisor.CompanyId == application.CompanyId)
                        recipients.Add(supervisor.Id);
                }

                Opportunity opportunity = new OpportunityRepository().GetById(application.OpportunityId);
                if (opportunity != null && !string.IsNullOrEmpty(opportunity.CreatedBySupervisorId))
                    recipients.Add(opportunity.CreatedBySupervisorId);

                if (recipients.Count == 0)
                {
                    Trace.TraceWarning("[UIMS notifications] No company supervisor found for company {0}; nobody was told about application {1}.",
                        application.CompanyId, application.Id);
                }

                foreach (string id in recipients)
                {
                    Send(id, TypeApplication, "ApplicationSubmitted",
                        With("~/Pages/Company/Applications.aspx", "focus", application.Id),
                        application.StudentName, application.OpportunityTitle);
                }
            });
        }

        /// <summary>The company accepted or rejected an application: tell the student.</summary>
        public static void ApplicationDecided(InternshipApplication application, ApplicationStatus decision)
        {
            Safely("ApplicationDecided", () =>
            {
                string link = With("~/Pages/Student/MyApplications.aspx", "focus", application.Id);
                if (decision == ApplicationStatus.Accepted)
                {
                    Send(application.StudentId, TypeApplication, "ApplicationAccepted", link,
                        application.CompanyName, application.OpportunityTitle);
                }
                else if (decision == ApplicationStatus.Rejected)
                {
                    Send(application.StudentId, TypeApplication, "ApplicationRejected", link,
                        application.CompanyName, application.OpportunityTitle);
                }
            });
        }

        /// <summary>The student confirmed an offer: tell the company supervisor,
        /// the academic supervisor and the coordinators.</summary>
        public static void PlacementConfirmed(Placement placement)
        {
            Safely("PlacementConfirmed", () =>
            {
                Send(placement.CompanySupervisorId, TypePlacement, "PlacementConfirmedCompany",
                    WithId("~/Pages/Company/TraineeDetails.aspx", placement.Id),
                    placement.StudentName, placement.OpportunityTitle);

                Send(placement.AcademicSupervisorId, TypePlacement, "PlacementConfirmedAcademic",
                    WithId("~/Pages/Academic/StudentProgress.aspx", placement.StudentId),
                    placement.StudentName, placement.CompanyName);

                SendToCoordinators(TypePlacement, "PlacementConfirmedCoordinator",
                    WithId("~/Pages/Coordinator/PlacementDetails.aspx", placement.Id),
                    placement.StudentName, placement.CompanyName);
            });
        }

        // ------------------------------------------------------------------
        //  2. Accounts, groups and academic supervisors
        // ------------------------------------------------------------------

        /// <summary>The coordinator created a student account: welcome the student.</summary>
        public static void StudentAccountCreated(Student student)
        {
            Safely("StudentAccountCreated", () =>
            {
                if (student == null) return;
                Send(student.Id, TypeAccount, "WelcomeStudent", "~/Pages/Student/Profile.aspx", student.FullName);
            });
        }

        /// <summary>The coordinator saved a group. Each person only hears about
        /// what changed for them.</summary>
        public static void GroupSaved(string groupName, AcademicSupervisor supervisor, string formerSupervisorId,
                                      List<string> addedStudentIds, List<string> removedStudentIds,
                                      List<string> keptStudentIds)
        {
            Safely("GroupSaved", () =>
            {
                bool supervisorChanged = formerSupervisorId != supervisor.Id;

                foreach (string studentId in addedStudentIds)
                    Send(studentId, TypeGroup, "GroupAdded", "~/Pages/Student/Dashboard.aspx", groupName, supervisor.FullName);

                foreach (string studentId in removedStudentIds)
                    Send(studentId, TypeGroup, "GroupRemoved", "~/Pages/Student/Dashboard.aspx", groupName);

                if (supervisorChanged)
                {
                    foreach (string studentId in keptStudentIds)
                        Send(studentId, TypeGroup, "GroupNewSupervisor", "~/Pages/Student/Dashboard.aspx", supervisor.FullName, groupName);
                }

                int total = addedStudentIds.Count + keptStudentIds.Count;
                if (supervisorChanged)
                {
                    Send(supervisor.Id, TypeGroup, "GroupAssigned", "~/Pages/Academic/Dashboard.aspx",
                        groupName, total.ToString(CultureInfo.InvariantCulture));
                }
                else if (addedStudentIds.Count > 0)
                {
                    Send(supervisor.Id, TypeGroup, "GroupStudentsAdded", "~/Pages/Academic/Dashboard.aspx",
                        groupName, addedStudentIds.Count.ToString(CultureInfo.InvariantCulture));
                }

                if (supervisorChanged && !string.IsNullOrEmpty(formerSupervisorId))
                {
                    Send(formerSupervisorId, TypeGroup, "GroupReassigned", "~/Pages/Academic/Dashboard.aspx",
                        groupName, supervisor.FullName);
                }
            });
        }

        /// <summary>The coordinator deleted a group: tell its students and supervisor.</summary>
        public static void GroupDeleted(string groupName, string supervisorId, List<string> studentIds)
        {
            Safely("GroupDeleted", () =>
            {
                foreach (string studentId in studentIds)
                    Send(studentId, TypeGroup, "GroupDeletedStudent", "~/Pages/Student/Dashboard.aspx", groupName);

                if (!string.IsNullOrEmpty(supervisorId))
                    Send(supervisorId, TypeGroup, "GroupDeletedSupervisor", "~/Pages/Academic/Dashboard.aspx", groupName);
            });
        }

        // ------------------------------------------------------------------
        //  3. Tasks, submissions and reviews
        // ------------------------------------------------------------------

        /// <summary>The company created a task: tell the student.</summary>
        public static void TaskAssigned(InternshipTask task)
        {
            Safely("TaskAssigned", () =>
            {
                string link = With("~/Pages/Student/MyTasks.aspx", "task", task.Id);
                if (task.Deadline > 0)
                    Send(task.StudentId, TypeTask, "TaskAssigned", link, task.Title, Time.DisplayDate(task.Deadline));
                else
                    Send(task.StudentId, TypeTask, "TaskAssignedNoDue", link, task.Title);
            });
        }

        /// <summary>The student submitted work: tell the company supervisor.</summary>
        public static void TaskSubmitted(Submission submission)
        {
            Safely("TaskSubmitted", () =>
            {
                InternshipTask task = new TaskRepository().GetById(submission.TaskId);
                if (task == null) return;

                string recipient = task.CreatedBySupervisorId;
                if (string.IsNullOrEmpty(recipient))
                {
                    Placement placement = new PlacementRepository().GetById(task.PlacementId);
                    if (placement != null) recipient = placement.CompanySupervisorId;
                }

                Send(recipient, TypeTask, submission.AttemptNumber > 1 ? "TaskResubmitted" : "TaskSubmitted",
                    With("~/Pages/Company/TaskReview.aspx", "submission", submission.Id),
                    NameOf(submission.StudentId), task.Title);
            });
        }

        /// <summary>The company graded a submission or asked for changes: tell the student.</summary>
        public static void TaskReviewed(TaskEvaluation evaluation)
        {
            Safely("TaskReviewed", () =>
            {
                InternshipTask task = new TaskRepository().GetById(evaluation.TaskId);
                string title = task == null ? "" : task.Title;
                string link = With("~/Pages/Student/MyTasks.aspx", "task", evaluation.TaskId);

                if (evaluation.RevisionRequested)
                {
                    Send(evaluation.StudentId, TypeTask, "TaskRevision", link,
                        title, Shorten(evaluation.RevisionInstructions, 140));
                }
                else
                {
                    Send(evaluation.StudentId, TypeTask, "TaskGraded", link,
                        title, Number(evaluation.TotalScore), Number(evaluation.MaxScore));
                }
            });
        }

        // ------------------------------------------------------------------
        //  4. Academic follow-up and training hours
        // ------------------------------------------------------------------

        /// <summary>The academic supervisor wrote a comment the student may see.</summary>
        public static void AcademicCommentAdded(AcademicComment comment)
        {
            Safely("AcademicCommentAdded", () =>
            {
                if (!comment.IsVisibleToStudent) return;
                Send(comment.StudentId, TypeComment, "CommentAdded", "~/Pages/Student/Progress.aspx",
                    Shorten(comment.Comment, 140));
            });
        }

        /// <summary>Hours were reported: tell the academic supervisor who approves them.</summary>
        public static void HoursReported(TrainingHoursEntry entry)
        {
            Safely("HoursReported", () =>
            {
                Placement placement = new PlacementRepository().GetById(entry.PlacementId);
                if (placement == null) return;
                Send(placement.AcademicSupervisorId, TypeHours, "HoursReported",
                    WithId("~/Pages/Academic/StudentProgress.aspx", placement.StudentId),
                    placement.StudentName, Number(entry.Hours));
            });
        }

        /// <summary>Hours were approved or rejected: tell the student.</summary>
        public static void HoursDecided(TrainingHoursEntry entry, bool approved)
        {
            Safely("HoursDecided", () =>
            {
                Send(entry.StudentId, TypeHours, approved ? "HoursApproved" : "HoursRejected",
                    "~/Pages/Student/Progress.aspx", Number(entry.Hours));
            });
        }

        // ------------------------------------------------------------------
        //  5. Final evaluations and completion
        //  The forms are confidential, so the student is not told about them -
        //  only about the released result.
        // ------------------------------------------------------------------

        public static void CompanyFinalSubmitted(FinalCompanyEvaluation evaluation)
        {
            if (evaluation == null || !evaluation.IsSubmitted) return;
            CompanyEvaluationSent(evaluation.PlacementId);
        }

        /// <summary>The company sent its final evaluation for a placement: the
        /// academic supervisor's evaluation is now due, and the coordinators are told.</summary>
        public static void CompanyEvaluationSent(string placementId)
        {
            Safely("CompanyEvaluationSent", () =>
            {
                Placement placement = new PlacementRepository().GetById(placementId);
                if (placement == null) return;
                string student = string.IsNullOrWhiteSpace(placement.StudentName) ? NameOf(placement.StudentId) : placement.StudentName;

                Send(placement.AcademicSupervisorId, TypeEvaluation, "CompanyEvalForAcademic",
                    WithId("~/Pages/Academic/FinalEvaluation.aspx", placement.StudentId), student);

                SendToCoordinators(TypeEvaluation, "CompanyEvalForCoordinator",
                    WithId("~/Pages/Coordinator/PlacementDetails.aspx", placement.Id),
                    placement.CompanyName ?? "", student);
            });
        }

        /// <summary>The academic supervisor submitted the final evaluation:
        /// the coordinators now need to review the completion.</summary>
        public static void AcademicFinalSubmitted(FinalAcademicEvaluation evaluation)
        {
            Safely("AcademicFinalSubmitted", () =>
            {
                if (!evaluation.IsSubmitted) return;
                SendToCoordinators(TypeEvaluation, "AcademicEvalForCoordinator",
                    WithId("~/Pages/Coordinator/CompletionReview.aspx", evaluation.StudentId),
                    NameOf(evaluation.StudentId));
            });
        }

        /// <summary>The coordinator approved, returned or rejected a completion record.</summary>
        public static void CompletionDecided(CompletionRecord record)
        {
            Safely("CompletionDecided", () =>
            {
                const string progress = "~/Pages/Student/Progress.aspx";
                bool hasNote = !string.IsNullOrWhiteSpace(record.CoordinatorNote);
                string note = Shorten(record.CoordinatorNote, 140);

                if (record.Status == CompletionStatus.Approved)
                {
                    Send(record.StudentId, TypeCompletion, "CompletionApproved", progress, record.Result ?? "");

                    // The supervisors who followed the student hear that it is done.
                    Placement placement = new PlacementRepository().GetById(record.StudentId);
                    if (placement != null)
                    {
                        string student = string.IsNullOrWhiteSpace(placement.StudentName) ? NameOf(record.StudentId) : placement.StudentName;
                        Send(placement.AcademicSupervisorId, TypeCompletion, "CompletionApprovedSupervisor",
                            WithId("~/Pages/Academic/StudentProgress.aspx", placement.StudentId), student);
                        Send(placement.CompanySupervisorId, TypeCompletion, "CompletionApprovedSupervisor",
                            WithId("~/Pages/Company/TraineeDetails.aspx", placement.Id), student);
                    }
                }
                else if (record.IsRejectedFinal)
                {
                    if (hasNote) Send(record.StudentId, TypeCompletion, "CompletionRejected", progress, note);
                    else Send(record.StudentId, TypeCompletion, "CompletionRejectedNoNote", progress);
                }
                else if (record.Status == CompletionStatus.Rejected)
                {
                    if (hasNote) Send(record.StudentId, TypeCompletion, "CompletionReturned", progress, note);
                    else Send(record.StudentId, TypeCompletion, "CompletionReturnedNoNote", progress);
                }
            });
        }

        // ------------------------------------------------------------------
        //  6. Meetings
        // ------------------------------------------------------------------

        /// <summary>A meeting was requested, accepted, declined, completed or cancelled.
        /// <paramref name="key"/> is one of MeetingRequest, MeetingAccepted,
        /// MeetingDeclined, MeetingCompleted, MeetingCancelled.</summary>
        public static void MeetingChanged(Meeting meeting, string actorId, string recipientId, string key)
        {
            Safely("MeetingChanged", () =>
            {
                if (meeting == null) return;
                Send(recipientId, TypeMeeting, key, "~/Pages/Meetings/MyMeetings.aspx",
                    NameOf(actorId), meeting.Title, Time.Display(meeting.ScheduledAt));
            });
        }

        public static void MeetingScheduled(Meeting meeting)
        {
            if (meeting == null || meeting.ParticipantIds == null) return;
            foreach (string participantId in meeting.ParticipantIds.Distinct())
            {
                if (participantId != meeting.CreatedById)
                    MeetingChanged(meeting, meeting.CreatedById, participantId, "MeetingRequest");
            }
        }
    }
}
