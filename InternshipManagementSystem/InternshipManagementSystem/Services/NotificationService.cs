// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad
//  Sends the notifications that appear in the top-bar bell of every portal.
// =============================================================================

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Services
{
    /// <summary>
    /// One method per workflow event. The repositories call these right after
    /// a successful save, so a page that saves through a repository gets its
    /// notification for free.
    ///
    /// A notification is a nice-to-have: if sending one fails (for example the
    /// database rules are missing), the error is logged and the real action
    /// still succeeds. Never let a notification break a save.
    /// </summary>
    public static class NotificationService
    {
        // Notification types - the bell picks an icon from these.
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

        // ------------------------------------------------------------------
        //  Basic sending
        // ------------------------------------------------------------------

        /// <summary>Sends one notification. Nothing is sent to the person who
        /// did the action themselves.</summary>
        public static void Send(string recipientId, string type, string title, string message, string link)
        {
            if (string.IsNullOrEmpty(recipientId)) return;
            Person current = SessionHelper.Current;
            if (current != null && current.Id == recipientId) return;

            try
            {
                new NotificationRepository().Add(new Notification
                {
                    RecipientId = recipientId,
                    Type = type,
                    Title = title,
                    Message = message,
                    Link = link,
                    IsRead = false
                });
            }
            catch (Exception ex)
            {
                Trace.TraceWarning("Notification '{0}' was not sent to {1}: {2}", title, recipientId, ex.Message);
            }
        }

        /// <summary>Runs one event safely: a failed lookup only skips the notification.</summary>
        private static void Safely(string eventName, Action action)
        {
            try
            {
                action();
            }
            catch (Exception ex)
            {
                Trace.TraceWarning("Notification event {0} skipped: {1}", eventName, ex.Message);
            }
        }

        private static void SendToCoordinators(string type, string title, string message, string link)
        {
            foreach (Person coordinator in new UserRepository().GetByRole(UserRole.Coordinator))
            {
                if (coordinator.IsActive) Send(coordinator.Id, type, title, message, link);
            }
        }

        private static string NameOf(string userId)
        {
            Person person = new UserRepository().GetPerson(userId);
            return person == null || string.IsNullOrWhiteSpace(person.FullName) ? "A student" : person.FullName;
        }

        private static string Shorten(string text, int length)
        {
            text = (text ?? "").Trim();
            return text.Length <= length ? text : text.Substring(0, length).TrimEnd() + "…";
        }

        private static string WithId(string page, string id)
        {
            return string.IsNullOrEmpty(id) ? page : page + "?id=" + Uri.EscapeDataString(id);
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
                    Send(student.Id, TypeOpportunity, "New internship opportunity",
                        companyName + " posted \"" + opportunity.Title + "\".",
                        WithId("~/Pages/Student/OpportunityDetails.aspx", opportunity.Id));
                }
            });
        }

        /// <summary>A student applied: tell the company's supervisors.</summary>
        public static void ApplicationSubmitted(InternshipApplication application)
        {
            Safely("ApplicationSubmitted", () =>
            {
                foreach (Person person in new UserRepository().GetByRole(UserRole.CompanySupervisor))
                {
                    CompanySupervisor supervisor = person as CompanySupervisor;
                    if (supervisor == null || !supervisor.IsActive || supervisor.CompanyId != application.CompanyId) continue;
                    Send(supervisor.Id, TypeApplication, "New application",
                        application.StudentName + " applied for \"" + application.OpportunityTitle + "\".",
                        "~/Pages/Company/Applications.aspx");
                }
            });
        }

        /// <summary>The company accepted or rejected an application: tell the student.</summary>
        public static void ApplicationDecided(InternshipApplication application, ApplicationStatus decision)
        {
            Safely("ApplicationDecided", () =>
            {
                if (decision == ApplicationStatus.Accepted)
                {
                    Send(application.StudentId, TypeApplication, "Application accepted",
                        application.CompanyName + " accepted your application for \"" + application.OpportunityTitle
                        + "\". Confirm the offer in My Applications.",
                        "~/Pages/Student/MyApplications.aspx");
                }
                else if (decision == ApplicationStatus.Rejected)
                {
                    Send(application.StudentId, TypeApplication, "Application not accepted",
                        application.CompanyName + " did not accept your application for \"" + application.OpportunityTitle + "\".",
                        "~/Pages/Student/MyApplications.aspx");
                }
            });
        }

        /// <summary>The student confirmed an offer: tell the company supervisor,
        /// the academic supervisor and the coordinators.</summary>
        public static void PlacementConfirmed(Placement placement)
        {
            Safely("PlacementConfirmed", () =>
            {
                Send(placement.CompanySupervisorId, TypePlacement, "New trainee",
                    placement.StudentName + " confirmed the internship \"" + placement.OpportunityTitle + "\".",
                    WithId("~/Pages/Company/TraineeDetails.aspx", placement.Id));

                Send(placement.AcademicSupervisorId, TypePlacement, "Student placement confirmed",
                    placement.StudentName + " will train at " + placement.CompanyName + ".",
                    WithId("~/Pages/Academic/StudentProgress.aspx", placement.StudentId));

                SendToCoordinators(TypePlacement, "Placement confirmed",
                    placement.StudentName + " confirmed a placement at " + placement.CompanyName + ".",
                    WithId("~/Pages/Coordinator/PlacementDetails.aspx", placement.Id));
            });
        }

        // ------------------------------------------------------------------
        //  2. Groups and academic supervisors
        // ------------------------------------------------------------------

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
                {
                    Send(studentId, TypeGroup, "You were added to a group",
                        "You are now in " + groupName + ". Your academic supervisor is " + supervisor.FullName + ".",
                        "~/Pages/Student/Dashboard.aspx");
                }

                foreach (string studentId in removedStudentIds)
                {
                    Send(studentId, TypeGroup, "Group updated",
                        "You were removed from " + groupName + ". The coordinator will assign you a new group.",
                        "~/Pages/Student/Dashboard.aspx");
                }

                if (supervisorChanged)
                {
                    foreach (string studentId in keptStudentIds)
                    {
                        Send(studentId, TypeGroup, "New academic supervisor",
                            supervisor.FullName + " is now the academic supervisor of " + groupName + ".",
                            "~/Pages/Student/Dashboard.aspx");
                    }
                }

                int total = addedStudentIds.Count + keptStudentIds.Count;
                if (supervisorChanged)
                {
                    Send(supervisor.Id, TypeGroup, "Group assigned to you",
                        groupName + " is now assigned to you with " + total + (total == 1 ? " student." : " students."),
                        "~/Pages/Academic/Dashboard.aspx");
                }
                else if (addedStudentIds.Count > 0)
                {
                    Send(supervisor.Id, TypeGroup, "New students in your group",
                        addedStudentIds.Count + (addedStudentIds.Count == 1 ? " student was" : " students were")
                        + " added to " + groupName + ".",
                        "~/Pages/Academic/Dashboard.aspx");
                }

                if (supervisorChanged && !string.IsNullOrEmpty(formerSupervisorId))
                {
                    Send(formerSupervisorId, TypeGroup, "Group reassigned",
                        groupName + " is now supervised by " + supervisor.FullName + ".",
                        "~/Pages/Academic/Dashboard.aspx");
                }
            });
        }

        /// <summary>The coordinator deleted a group: tell its students and supervisor.</summary>
        public static void GroupDeleted(string groupName, string supervisorId, List<string> studentIds)
        {
            Safely("GroupDeleted", () =>
            {
                foreach (string studentId in studentIds)
                {
                    Send(studentId, TypeGroup, "Group removed",
                        groupName + " was deleted. The coordinator will assign you a new group.",
                        "~/Pages/Student/Dashboard.aspx");
                }
                if (!string.IsNullOrEmpty(supervisorId))
                {
                    Send(supervisorId, TypeGroup, "Group removed",
                        groupName + " was deleted and is no longer assigned to you.",
                        "~/Pages/Academic/Dashboard.aspx");
                }
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
                string due = task.Deadline > 0 ? " Due " + Time.DisplayDate(task.Deadline) + "." : "";
                Send(task.StudentId, TypeTask, "New task assigned",
                    "\"" + task.Title + "\" was added to your tasks." + due,
                    "~/Pages/Student/MyTasks.aspx");
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

                bool again = submission.AttemptNumber > 1;
                Send(recipient, TypeTask, again ? "Task resubmitted" : "Task submitted",
                    NameOf(submission.StudentId) + (again ? " resubmitted \"" : " submitted \"") + task.Title + "\".",
                    "~/Pages/Company/TaskReview.aspx");
            });
        }

        /// <summary>The company reviewed a submission: tell the student.</summary>
        public static void TaskReviewed(TaskEvaluation evaluation)
        {
            Safely("TaskReviewed", () =>
            {
                InternshipTask task = new TaskRepository().GetById(evaluation.TaskId);
                string title = task == null ? "your task" : "\"" + task.Title + "\"";

                if (evaluation.RevisionRequested)
                {
                    Send(evaluation.StudentId, TypeTask, "Revision requested",
                        "Your supervisor asked for changes to " + title + ".",
                        "~/Pages/Student/MyTasks.aspx");
                }
                else
                {
                    Send(evaluation.StudentId, TypeTask, "Task reviewed",
                        "Your work on " + title + " was graded: "
                        + evaluation.TotalScore + " / " + evaluation.MaxScore + ".",
                        "~/Pages/Student/MyTasks.aspx");
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
                Send(comment.StudentId, TypeComment, "New comment from your academic supervisor",
                    Shorten(comment.Comment, 120),
                    "~/Pages/Student/Progress.aspx");
            });
        }

        /// <summary>Hours were reported: tell the academic supervisor who approves them.</summary>
        public static void HoursReported(TrainingHoursEntry entry)
        {
            Safely("HoursReported", () =>
            {
                Placement placement = new PlacementRepository().GetById(entry.PlacementId);
                if (placement == null) return;
                Send(placement.AcademicSupervisorId, TypeHours, "Training hours to review",
                    placement.StudentName + " reported " + entry.Hours + (entry.Hours == 1 ? " hour." : " hours."),
                    WithId("~/Pages/Academic/StudentProgress.aspx", placement.StudentId));
            });
        }

        /// <summary>Hours were approved or rejected: tell the student.</summary>
        public static void HoursDecided(TrainingHoursEntry entry, bool approved)
        {
            Safely("HoursDecided", () =>
            {
                string hours = entry.Hours + (entry.Hours == 1 ? " hour" : " hours");
                Send(entry.StudentId, TypeHours, approved ? "Training hours approved" : "Training hours rejected",
                    approved ? hours + " were added to your approved total."
                             : hours + " were not approved. Check the note on My Progress.",
                    "~/Pages/Student/Progress.aspx");
            });
        }

        // ------------------------------------------------------------------
        //  5. Final evaluations and completion
        //  The forms are confidential, so the student is not told about them -
        //  only about the released result.
        // ------------------------------------------------------------------

        public static void CompanyFinalSubmitted(FinalCompanyEvaluation evaluation)
        {
            Safely("CompanyFinalSubmitted", () =>
            {
                if (!evaluation.IsSubmitted) return;
                Placement placement = new PlacementRepository().GetById(evaluation.PlacementId);
                string student = placement != null ? placement.StudentName : NameOf(evaluation.StudentId);

                if (placement != null)
                {
                    Send(placement.AcademicSupervisorId, TypeEvaluation, "Company evaluation submitted",
                        "The company submitted the final evaluation for " + student + ". You can now complete yours.",
                        WithId("~/Pages/Academic/FinalEvaluation.aspx", evaluation.StudentId));
                }
                SendToCoordinators(TypeEvaluation, "Company evaluation submitted",
                    "The company submitted the final evaluation for " + student + ".",
                    WithId("~/Pages/Coordinator/PlacementDetails.aspx", evaluation.PlacementId));
            });
        }

        public static void AcademicFinalSubmitted(FinalAcademicEvaluation evaluation)
        {
            Safely("AcademicFinalSubmitted", () =>
            {
                if (!evaluation.IsSubmitted) return;
                SendToCoordinators(TypeEvaluation, "Academic evaluation submitted",
                    "The academic evaluation for " + NameOf(evaluation.StudentId) + " is ready for completion review.",
                    "~/Pages/Coordinator/CompletionReview.aspx");
            });
        }

        /// <summary>The coordinator approved or returned a completion record.</summary>
        public static void CompletionDecided(CompletionRecord record)
        {
            Safely("CompletionDecided", () =>
            {
                if (record.Status == CompletionStatus.Approved)
                {
                    Send(record.StudentId, TypeCompletion, "Your final result is released",
                        "Your internship result is " + (record.Result ?? "available") + ".",
                        "~/Pages/Student/Progress.aspx");
                }
                else if (record.Status == CompletionStatus.Rejected)
                {
                    Send(record.StudentId, TypeCompletion, "Completion review returned",
                        string.IsNullOrWhiteSpace(record.CoordinatorNote)
                            ? "The coordinator returned your completion review."
                            : Shorten(record.CoordinatorNote, 120),
                        "~/Pages/Student/Progress.aspx");
                }
            });
        }

        // ------------------------------------------------------------------
        //  6. Meetings
        // ------------------------------------------------------------------

        public static void MeetingScheduled(Meeting meeting)
        {
            Safely("MeetingScheduled", () =>
            {
                if (meeting.ParticipantIds == null) return;
                foreach (string participantId in meeting.ParticipantIds.Distinct())
                {
                    if (participantId == meeting.CreatedById) continue;
                    Send(participantId, TypeMeeting, "New meeting scheduled",
                        "\"" + meeting.Title + "\" on " + Time.Display(meeting.ScheduledAt) + ".",
                        "~/Pages/Meetings/MyMeetings.aspx");
                }
            });
        }
    }
}
