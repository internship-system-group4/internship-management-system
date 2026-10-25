// Compiled with the notification/repository sources and an in-memory Firebase fixture.
// No production accounts, mailboxes, credentials or network services are used.
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using System.Web;
using System.Web.SessionState;
using InternshipManagementSystem.Security;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Services;

class EmailNotificationsSmoke
{
    static int checks;
    static readonly Dictionary<string, Person> users = new Dictionary<string, Person> {
        { "s", new Student { Id = "s", FullName = "Student", Email = "student@example.test" } },
        { "s2", new Student { Id = "s2", Email = "otherstudent@example.test" } },
        { "company", new CompanySupervisor { Id = "company", CompanyId = "c", Email = "company@example.test" } },
        { "outsider", new CompanySupervisor { Id = "outsider", CompanyId = "other", Email = "outside@example.test" } },
        { "academic", new AcademicSupervisor { Id = "academic", Email = "academic@example.test" } },
        { "coord", new Coordinator { Id = "coord", Email = "coord@example.test" } },
        { "inactive", new Coordinator { Id = "inactive", Email = "inactive@example.test", IsActive = false } },
        { "duplicate", new Coordinator { Id = "duplicate", Email = "COORD@example.test" } },
        { "invalid", new Coordinator { Id = "invalid", Email = "bad address" } }
    };
    static readonly Placement assigned = new Placement { Id = "s", StudentId = "s", CompanyId = "c",
        CompanySupervisorId = "company", AcademicSupervisorId = "academic" };
    static List<string> messages = new List<string>();
    static void Check(bool pass, string message) { checks++; if (!pass) throw new Exception(message); }
    static void Event(object before, object after)
    {
        messages.Clear();
        new NotificationDispatcher(id => users.ContainsKey(id) ? users[id] : null,
            role => users.Values.Where(u => u.Role == role).ToList(), id => id == "s" ? assigned : null,
            (recipient, subject, body, page) => messages.Add(recipient.Email + "|" + subject + "|" + body + "|" + page))
            .Saved(before, after);
    }
    static void PolicyChecks()
    {
        Event(null, new InternshipTask { StudentId = "s", Title = "Design database" });
        Check(messages.Count == 1 && messages[0].StartsWith("student@") && messages[0].Contains("Design database"), "Task assignment recipient/content");
        Event(new InternshipTask { StudentId = "s" }, new InternshipTask { StudentId = "s", Title = "Edited title" });
        Check(messages.Count == 1 && messages[0].Contains("details updated"), "Task edit did not notify the trainee");
        Event(new InternshipTask { StudentId = "s" }, new InternshipTask { StudentId = "s2" });
        Check(messages.Count == 1 && messages[0].StartsWith("otherstudent@"), "Task reassignment recipient");
        Event(null, new Submission { PlacementId = "s", StudentId = "s" });
        Check(messages.Count == 1 && messages[0].StartsWith("company@"), "Submission did not notify assigned supervisor");
        Event(null, new Submission { PlacementId = "s", StudentId = "s2" });
        Check(messages.Count == 0, "Mismatched submission leaked across placement");
        Event(null, new TaskEvaluation { StudentId = "s", RevisionRequested = true });
        Check(messages.Count == 1 && messages[0].Contains("revision requested"), "Revision request notification");
        Event(null, new TaskEvaluation { StudentId = "s" });
        Check(messages.Count == 1 && messages[0].Contains("Task evaluated"), "Task grade notification");
        Event(null, new FinalCompanyEvaluation { StudentId = "s", PlacementId = "s" });
        Check(messages.Count == 0, "Company draft sent mail");
        FinalCompanyEvaluation company = new FinalCompanyEvaluation { StudentId = "s", PlacementId = "s", IsSubmitted = true,
            OverallComment = "CONFIDENTIAL_COMMENT", TotalScore = 93.12345 };
        Event(new FinalCompanyEvaluation(), company);
        Check(messages.Count == 2 && messages.Any(m => m.StartsWith("coord@")) && messages.Any(m => m.StartsWith("academic@")), "Company evaluation recipients/dedup/inactive checks");
        Check(messages.All(m => !m.Contains("CONFIDENTIAL_COMMENT") && !m.Contains("93.12345") && !m.StartsWith("student@")), "Confidential evaluation exposed");
        Event(company, company);
        Check(messages.Count == 0, "Submitted company evaluation resent on save");
        Event(null, new FinalAcademicEvaluation { StudentId = "s", IsSubmitted = false });
        Check(messages.Count == 0, "Academic draft sent mail");
        Event(null, new FinalAcademicEvaluation { StudentId = "s", IsSubmitted = true, AcademicComments = "CONFIDENTIAL_COMMENT" });
        Check(messages.Count == 1 && messages[0].StartsWith("coord@") && !messages[0].Contains("CONFIDENTIAL_COMMENT"), "Academic evaluation recipients/privacy");
        Event(null, new CompletionRecord { StudentId = "s", Status = CompletionStatus.UnderCoordinatorReview });
        Check(messages.Count == 1 && messages[0].StartsWith("coord@"), "Coordinator review request");
        foreach (CompletionStatus state in new[] { CompletionStatus.AwaitingCompanyEvaluation, CompletionStatus.AwaitingAcademicEvaluation })
        {
            Event(null, new CompletionRecord { StudentId = "s", PlacementId = "s", Status = state });
            Check(messages.Count == 1 && messages[0].StartsWith(state == CompletionStatus.AwaitingCompanyEvaluation ? "company@" : "academic@"), "Evaluation request recipient");
        }
        Event(null, new CompletionRecord { StudentId = "s", Status = CompletionStatus.Approved, FinalScore = 93.12345, CoordinatorNote = "CONFIDENTIAL_COMMENT" });
        Check(messages.Count == 1 && messages[0].StartsWith("student@") && !messages[0].Contains("CONFIDENTIAL_COMMENT") && !messages[0].Contains("93.12345"), "Completion notification privacy");
        Event(null, new CompletionRecord { StudentId = "s", Status = CompletionStatus.NeedsCorrections, CoordinatorNote = "CONFIDENTIAL_COMMENT" });
        Check(messages.Count == 1 && messages[0].StartsWith("student@") && messages[0].Contains("returned for corrections") && !messages[0].Contains("CONFIDENTIAL_COMMENT"), "Corrections notification privacy");
        Event(new CompletionRecord { Status = CompletionStatus.Approved }, new CompletionRecord { StudentId = "s", Status = CompletionStatus.Approved });
        Check(messages.Count == 0, "Unchanged completion status sent mail");
        Event(null, new TrainingHoursEntry { PlacementId = "s", StudentId = "s" });
        Check(messages.Count == 1 && messages[0].StartsWith("academic@"), "Hours report recipient");
        Event(new TrainingHoursEntry(), new TrainingHoursEntry { StudentId = "s", Status = HoursStatus.Rejected });
        Check(messages.Count == 1 && messages[0].StartsWith("student@") && messages[0].Contains("rejected"), "Hours decision recipient");
        Event(null, new InternshipApplication { StudentId = "s", CompanyId = "c" });
        Check(messages.Count == 1 && messages[0].StartsWith("company@"), "Application leaked to another company");
        Event(new InternshipApplication(), new InternshipApplication { StudentId = "s", Status = ApplicationStatus.Accepted });
        Check(messages.Count == 1 && messages[0].StartsWith("student@"), "Application decision recipient");
        Event(null, assigned);
        Check(messages.Count == 3, "Placement confirmation recipients");
        Meeting meeting = new Meeting { CreatedById = "company", Title = "Review", ScheduledAt = Time.NowMs(),
            ParticipantIds = new List<string> { "s", "s", "company" } };
        Event(null, meeting);
        Check(messages.Count == 1 && messages[0].Contains("Meeting invitation"), "Meeting creator or duplicate participant notified");
        Event(meeting, meeting);
        Check(messages.Count == 0, "Unchanged meeting resent");
        Meeting changed = Json.Deserialize<Meeting>(Json.Serialize(meeting));
        changed.ParticipantIds = new List<string> { "academic" };
        Event(meeting, changed);
        Check(messages.Count == 2 && messages.Any(m => m.StartsWith("student@") && m.Contains("cancelled")) &&
            messages.Any(m => m.StartsWith("academic@") && m.Contains("Meeting invitation")), "Added/removed meeting participants");
        changed.Status = MeetingStatus.Cancelled;
        Event(meeting, changed);
        Check(messages.Count == 2 && messages.All(m => m.Contains("cancelled")), "Meeting cancellation");
        users["s"].IsActive = false;
        Event(null, new InternshipTask { StudentId = "s" });
        Check(messages.Count == 0, "Inactive student received mail");
        users["s"].IsActive = true;
        int attempts = 0;
        new NotificationDispatcher(id => users[id], role => new List<Person> { users["coord"], users["academic"] },
            id => assigned, (p, s, b, url) => { attempts++; if (attempts == 1) throw new IOException("SMTP unavailable"); })
            .Saved(null, new FinalAcademicEvaluation { StudentId = "s", IsSubmitted = true });
        Check(attempts == 2, "One delivery failure blocked remaining recipients");
    }

    static void RepositoryChecks(int port)
    {
        foreach (Person user in users.Values) FirebaseContext.Put("users/" + user.Id, user);
        FirebaseContext.Put("placements/s", assigned);
        if (!EmailNotificationService.Enabled)
        {
            FirebaseContext.Reads = 0;
            TaskRepository disabledTasks = new TaskRepository();
            string disabledId = disabledTasks.Insert(new InternshipTask { StudentId = "s" });
            disabledTasks.Update(disabledId, new Dictionary<string, object> { { "Title", "Updated" } });
            Check(FirebaseContext.Reads == 0, "Disabled notifications made extra database reads");
            return;
        }
        using (SmtpFixture smtp = new SmtpFixture(port))
        {
            TaskRepository tasks = new TaskRepository();
            string id = tasks.Insert(new InternshipTask { StudentId = "s", Title = "Repository task" });
            Check(smtp.Count == 1 && smtp.Last.Contains("Repository task") && smtp.Last.Contains("https://example.test/uims/Pages/Student/MyTasks.aspx"),
                "Repository insert or SMTP body/app subpath failed: count=" + smtp.Count + (smtp.Count > 0 ? "\n" + smtp.Last : ""));
            tasks.Update(id, new Dictionary<string, object> { { "Title", "Edited task" } });
            Check(smtp.Count == 2, "Task edit notification missing");
            tasks.Update(id, new Dictionary<string, object> { { "StudentId", "s2" } });
            Check(smtp.Count == 3 && smtp.Last.Contains("otherstudent@example.test"), "Patch reassignment did not send");
            InternshipTask existing = tasks.GetById(id);
            tasks.Save(id, existing);
            Check(smtp.Count == 3, "Save resent task assignment");
            FirebaseContext.FailWrites = true;
            try { tasks.Insert(new InternshipTask { StudentId = "s" }); throw new Exception("Failed write succeeded"); }
            catch (IOException) { }
            FirebaseContext.FailWrites = false;
            Check(smtp.Count == 3, "Failed write sent mail");
            FirebaseContext.FailReads = true;
            tasks.Save(id, existing);
            FirebaseContext.FailReads = false;
            Check(smtp.Count == 3, "Unavailable notification snapshot produced false assignment");
            EvaluationRepository evaluations = new EvaluationRepository();
            // Final evaluations now require the assigned author and are immutable once submitted.
            UseUser("company");
            FinalCompanyEvaluation company = new FinalCompanyEvaluation { StudentId = "s", PlacementId = "s", CompanyId = "c", SupervisorId = "company", TotalScore = 80, MaxScore = 100, IsSubmitted = true, SubmittedAt = Time.NowMs() };
            evaluations.SaveCompanyFinal(company);
            Check(smtp.Count == 5, "Company final did not notify coordinator and academic");
            try { evaluations.SaveCompanyFinal(company); throw new Exception("Submitted company evaluation was mutable"); }
            catch (InvalidOperationException) { }
            Check(smtp.Count == 5, "Company final resave duplicated notifications");
            UseUser("academic");
            FinalAcademicEvaluation draft = new FinalAcademicEvaluation { StudentId = "s", PlacementId = "s", AcademicSupervisorId = "academic" };
            string evaluationId = evaluations.SaveAcademicFinal(draft);
            Check(smtp.Count == 5 && draft.Id == evaluationId, "Draft mail or missing generated ID");
            draft.TotalScore = 80; draft.MaxScore = 100;
            draft.IsSubmitted = true;
            draft.SubmittedAt = Time.NowMs();
            evaluations.SaveAcademicFinal(draft);
            Check(smtp.Count == 6 && smtp.Last.Contains("coord@example.test"), "Draft submission did not notify coordinator");
            try { evaluations.SaveAcademicFinal(draft); throw new Exception("Submitted academic evaluation was mutable"); }
            catch (InvalidOperationException) { }
            Check(smtp.Count == 6, "Repeated evaluation save sent mail");
            UseUser("coord");
            CompletionRepository completions = new CompletionRepository();
            string completionId = completions.Insert(new CompletionRecord { StudentId = "s", Status = CompletionStatus.UnderCoordinatorReview });
            Check(smtp.Count == 7, "Persisted review request did not notify coordinator");
            completions.Update(completionId, new Dictionary<string, object> { { "Status", (int)CompletionStatus.Approved } });
            Check(smtp.Count == 8, "Persisted completion decision did not notify student");
            completions.Update(completionId, new Dictionary<string, object> { { "Status", (int)CompletionStatus.Approved } });
            Check(smtp.Count == 8, "Repeated status patch resent completion mail");
            int before = smtp.Count;
            new SubmissionRepository().Insert(new Submission { StudentId = "s", PlacementId = "s", TaskId = "t" });
            Check(smtp.Count == before + 1 && smtp.Last.Contains("company@example.test"), "Submission repository hook");
            before = smtp.Count;
            FirebaseContext.Put("tasks/t", new InternshipTask { Id = "t", StudentId = "s", PlacementId = "s" });
            FirebaseContext.Put("submissions/sub", new Submission { Id = "sub", TaskId = "t", StudentId = "s", PlacementId = "s" });
            UseUser("company");
            evaluations.SaveTaskEvaluation(new TaskEvaluation { StudentId = "s", PlacementId = "s", TaskId = "t", SubmissionId = "sub", EvaluatedBySupervisorId = "company", RevisionRequested = true });
            Check(smtp.Count == before + 1 && smtp.Last.Contains("revision requested"), "Task evaluation repository hook");
            before = smtp.Count;
            HoursRepository hours = new HoursRepository();
            string hoursId = hours.Insert(new TrainingHoursEntry { StudentId = "s", PlacementId = "s" });
            Check(smtp.Count == before + 1 && smtp.Last.Contains("academic@example.test"), "Reported hours repository hook");
            hours.Update(hoursId, new Dictionary<string, object> { { "Status", (int)HoursStatus.Approved } });
            Check(smtp.Count == before + 2 && smtp.Last.Contains("student@example.test"), "Hours review repository hook");
            before = smtp.Count;
            ApplicationRepository applications = new ApplicationRepository();
            string applicationId = applications.Insert(new InternshipApplication { StudentId = "s", CompanyId = "c" });
            Check(smtp.Count == before + 1 && smtp.Last.Contains("company@example.test"), "Application repository hook");
            applications.Update(applicationId, new Dictionary<string, object> { { "Status", (int)ApplicationStatus.Rejected } });
            Check(smtp.Count == before + 2 && smtp.Last.Contains("student@example.test"), "Application decision repository hook");
            before = smtp.Count;
            MeetingRepository meetings = new MeetingRepository();
            string meetingId = meetings.Insert(new Meeting { CreatedById = "company", RequestedToId = "s", Title = "Repository meeting", ParticipantIds = new List<string> { "s" }, ScheduledAt = Time.NowMs() + 3600000 });
            Check(smtp.Count == before + 1, "Meeting repository insert hook");
            meetings.Update(meetingId, new Dictionary<string, object> { { "Status", (int)MeetingStatus.Cancelled } });
            Check(smtp.Count == before + 2 && smtp.Last.Contains("cancelled"), "Meeting repository cancellation hook");
            before = smtp.Count;
            PlacementRepository placements = new PlacementRepository();
            Placement newPlacement = new Placement { CompanySupervisorId = "company", AcademicSupervisorId = "academic" };
            Check(placements.Confirm("s2", newPlacement) && smtp.Count == before + 3, "Placement confirmation hook");
            Check(!placements.Confirm("s2", newPlacement) && smtp.Count == before + 3, "Duplicate placement confirmation resent mail");
            smtp.Reject = true;
            string retained = tasks.Insert(new InternshipTask { StudentId = "s", Title = "SMTP rejection" });
            Check(tasks.GetById(retained) != null, "SMTP failure rolled back domain save");
        }
    }

    static List<UserNotification> Inbox(string id) { UseUser(id); return new NotificationRepository().GetMine(); }
    // Raw bell records, oldest first (fixture keys sort by creation order).
    static List<Notification> Notices(string id)
    {
        var map = Json.Deserialize<Dictionary<string, Notification>>(FirebaseContext.Get("notifications/" + id));
        return map == null ? new List<Notification>() : map.OrderBy(k => k.Key, StringComparer.Ordinal).Select(k => k.Value).ToList();
    }
    // The newest notice must be the bilingual NotificationService one, opening the given page.
    static void Newest(string id, int count, string key, string link, string reason)
    {
        var all = Notices(id);
        var last = all.LastOrDefault();
        Check(all.Count == count && last != null && last.Key == key && last.Link == link,
            reason + ": " + string.Join(" || ", all.Select(n => (n.Key ?? n.Title) + " -> " + n.Link)));
    }
    static void Denied(Action action, string reason) {
        bool denied = false; try { action(); } catch (InvalidOperationException) { denied = true; } catch (UnauthorizedAccessException) { denied = true; }
        Check(denied, reason);
    }
    static void InboxWorkflowChecks(int port)
    {
        users["academic2"] = new AcademicSupervisor { Id = "academic2", Email = "academic2@example.test" };
        foreach (var u in users.Values) FirebaseContext.Put("users/" + u.Id, u);
        FirebaseContext.Put("placements/s", assigned);
        FirebaseContext.Put("users/academic2", new AcademicSupervisor { Id = "academic2", Email = "academic2@example.test" });
        using (var smtp = new SmtpFixture(port)) {
            UseUser("company");
            var task = new InternshipTask { PlacementId = "s", Title = "Research <script>alert(1)</script>", Description = "Prepare a proposal", Deadline = Time.NowMs() + 86400000,
                MaxScore = 25, Weight = 2, Criteria = new List<GradeComponent> {
                    new GradeComponent { Name = "Research", MaxScore = 40, Weight = 20 }, new GradeComponent { Name = "Implementation", MaxScore = 10, Weight = 80 } } };
            string id = TaskWorkflowService.Assign(task);
            Newest("s", 1, "TaskAssigned", "~/Pages/Student/MyTasks.aspx?task=" + id, "Assigned task missing from student inbox or duplicated");
            Check(smtp.Count == (EmailNotificationService.Enabled ? 1 : 0), "Inbox incorrectly depends on email toggle");
            if (EmailNotificationService.Enabled) Check(smtp.Last.Contains("text/html") && smtp.Last.Contains("&lt;script&gt;"), "HTML email escaping or MIME alternatives");
            UseUser("outsider"); Denied(() => TaskWorkflowService.Assign(task), "Unassigned company supervisor assigned a task");
            Denied(() => TaskWorkflowService.Submit(id, "Other student's work", ""), "Supervisor submitted as student");
            UseUser("s"); Denied(() => TaskWorkflowService.Submit(id, "Work", "javascript:alert(1)"), "Unsafe submission URL accepted");
            string first = TaskWorkflowService.Submit(id, "First attempt", "https://example.test/work");
            Check(new TaskRepository().GetById(id).Status == InternshipTaskStatus.Submitted, "Submission did not update task status atomically");
            Denied(() => TaskWorkflowService.Submit(id, "Duplicate", ""), "Double submit created another attempt");
            Newest("company", 1, "TaskSubmitted", "~/Pages/Company/TaskReview.aspx?submission=" + first, "Submission did not notify the assigned company supervisor once");
            UseUser("company"); TaskWorkflowService.Review(first, true, null, "Please add evidence");
            Check(new SubmissionRepository().GetById(first).Status == SubmissionStatus.RevisionRequested, "Submission revision status missing");
            Newest("s", 2, "TaskRevision", "~/Pages/Student/MyTasks.aspx?task=" + id, "Revision notification missing or duplicated");
            UseUser("company"); Denied(() => TaskWorkflowService.Review(first, true, null, "Again"), "Same attempt was reviewed twice");
            UseUser("s"); string second = TaskWorkflowService.Submit(id, "Improved attempt", "");
            var attempts = new SubmissionRepository().GetByPlacement("s").Where(s => s.TaskId == id).OrderBy(s => s.AttemptNumber).ToList();
            Check(attempts.Count == 2 && attempts[0].DescriptionText == "First attempt" && attempts[1].AttemptNumber == 2, "Submission history was overwritten");
            Newest("company", 2, "TaskResubmitted", "~/Pages/Company/TaskReview.aspx?submission=" + second, "Resubmission notification missing or duplicated");
            UseUser("company"); TaskWorkflowService.Review(second, false, new List<double> { 20, 8 }, "Good improvement");
            var grade = new EvaluationRepository().GetTaskEvaluationsForPlacement("s").Single(e => e.SubmissionId == second);
            Check(Math.Abs(grade.TotalScore - 18.5) < 0.001 && grade.MaxScore == 25, "Rubric weights or task maximum ignored");
            Check(new SubmissionRepository().GetById(second).Status == SubmissionStatus.Accepted && new TaskRepository().GetById(id).Status == InternshipTaskStatus.Graded, "Grading status changes missing");
            Newest("s", 3, "TaskGraded", "~/Pages/Student/MyTasks.aspx?task=" + id, "Evaluation notification missing or duplicated");
            Check(Notices("s").Last().Args.SequenceEqual(new[] { task.Title, "18.5", "25" }), "Grade notice is missing the task title or score");
            if (EmailNotificationService.Enabled) Check(smtp.Count == 5, "Task cycle should send one email per event (assign, submit, revision, resubmit, grade): " + smtp.Count);
            Check(new HoursRepository().GetByPlacement("s").Count == 0, "Task completion approved training hours automatically");
            UseUser("s"); var repository = new NotificationRepository();
            string studentNotice = repository.GetMine().First().Id;
            repository.MarkRead(studentNotice);
            Check(repository.GetMine().Count(n => !n.IsRead) == 2, "Single read flag not persisted");
            UseUser("company"); repository.MarkRead(studentNotice);
            Check(Inbox("s").Count(n => !n.IsRead) == 2, "Cross-user mark-read changed another inbox");
            repository.MarkRead("all"); Check(repository.GetMine().All(n => n.IsRead), "Mark all read failed");
            Denied(() => repository.GetLatest("company", 100), "Cross-user legacy inbox read allowed");
            // Legacy records remain readable after the two implementations are merged.
            FirebaseContext.Put("notifications/s/legacy", new Notification { RecipientId = "s", Title = "Legacy notice", Message = "Existing activity", Link = "~/Pages/Student/MyTasks.aspx", CreatedAt = Time.NowMs() });
            Check(repository.GetMine().Any(n => n.Detail == "Existing activity" && n.Page == "Pages/Student/MyTasks.aspx"), "Existing inbox entries were lost");
            UseUser("coord"); var group = new StudentGroup { Name = "Notification cohort", AcademicSupervisorId = "academic" };
            new GroupRepository().SaveAssignments(group, new List<string> { "s" });
            int academicCount = Inbox("academic").Count; int studentCount = Inbox("s").Count;
            UseUser("coord"); new GroupRepository().SaveAssignments(group, new List<string> { "s" });
            Check(Inbox("academic").Count == academicCount && Inbox("s").Count == studentCount, "Unchanged group save resent assignment");
            UseUser("coord"); group.AcademicSupervisorId = "academic2"; new GroupRepository().SaveAssignments(group, new List<string> { "s" });
            Check(Inbox("academic").Count == academicCount + 1 && Inbox("s").Count == studentCount + 1, "Group reassignment recipients missing");
            UseUser("academic2"); Check(new NotificationRepository().GetMine().Count == 1, "New academic supervisor not notified");
            UseUser("coord"); new GroupRepository().DeleteGroup(group.Id);
            Check(Inbox("academic2").Count == 2, "Group deletion notification missing");
            // Specialized application decisions bypass generic Update; verify the explicit hook.
            FirebaseContext.Put("opportunities/opp", new Opportunity { Id = "opp", CompanyId = "c" });
            FirebaseContext.Put("applications/app", new InternshipApplication { Id = "app", OpportunityId = "opp", CompanyId = "c", StudentId = "s" });
            int beforeStudent = Inbox("s").Count;
            UseUser("company"); new ApplicationRepository().Decide((CompanySupervisor)users["company"], "app", ApplicationStatus.Accepted, "");
            Check(Inbox("s").Count == beforeStudent + 1, "Specialized application decision hook missing or duplicated");
            UseUser("company"); var meeting = new Meeting { Title = "Review request", CreatedById = "company", RequestedToId = "s", ScheduledAt = Time.NowMs() + 3600000 };
            string meetingId = new MeetingRepository().Insert(meeting);
            Check(Inbox("s").Count == beforeStudent + 2, "Meeting request channel hook missing or duplicated");
            int companyCount = Inbox("company").Count;
            UseUser("s"); new MeetingRepository().ApplyAction(meetingId, "s", "Accept");
            Check(Inbox("company").Count == companyCount + 1, "Meeting acceptance did not notify requester");
            UseUser("s"); Denied(() => new MeetingRepository().ApplyAction(meetingId, "s", "Accept"), "Repeated meeting response accepted");
            beforeStudent = Inbox("s").Count;
            UseUser("company"); smtp.Reject = true;
            task.Title = "SMTP failure"; string retained = TaskWorkflowService.Assign(task);
            Check(new TaskRepository().GetById(retained) != null && Notices("s").Count(n => n.Args != null && n.Args.Contains("SMTP failure")) == 1,
                "Email failure lost saved task or in-app notification");
            smtp.Reject = false; int emailCount = smtp.Count;
            FirebaseContext.FailNotificationWrites = true; UseUser("company"); task.Title = "Inbox write failure"; TaskWorkflowService.Assign(task); FirebaseContext.FailNotificationWrites = false;
            Check(smtp.Count == emailCount + (EmailNotificationService.Enabled ? 1 : 0), "Inbox failure prevented email attempt");
            beforeStudent = Inbox("s").Count;
            FirebaseContext.FailWrites = true; UseUser("company");
            bool failedWrite = false; try { TaskWorkflowService.Assign(task); } catch (IOException) { failedWrite = true; }
            FirebaseContext.FailWrites = false;
            Check(failedWrite && Inbox("s").Count == beforeStudent, "Failed domain write created a notification");
            // No email address must never suppress the recipient's in-app activity.
            var noEmail = new Student { Id = "nomail" }; FirebaseContext.Put("users/nomail", noEmail);
            UseUser("company"); new TaskRepository().Insert(new InternshipTask { StudentId = "nomail", Title = "Inbox only recipient" });
            SessionHelper.SignIn(noEmail, "fixture"); Check(new NotificationRepository().GetMine().Count == 1, "Recipient without email lost in-app notice");
            UseUser("coord"); EmailNotificationService.Saved(null, new FinalAcademicEvaluation { StudentId = "s", IsSubmitted = true, TotalScore = 93.12345, AcademicComments = "PRIVATE_FEEDBACK" });
            Check(new NotificationRepository().GetMine().All(n => !n.Detail.Contains("PRIVATE_FEEDBACK") && !n.Detail.Contains("93.12345")), "Private final evaluations leaked into inbox");
            NotificationServiceOnlyEvents(smtp);
        }
    }

    // Events whose bell notice AND email come from NotificationService alone.
    // (In this fixture the English text is the resource id, e.g. "Shared.Notify.GroupAdded.Message".)
    static void NotificationServiceOnlyEvents(SmtpFixture smtp)
    {
        int expected = EmailNotificationService.Enabled ? 1 : 0;
        // Exactly `count` emails so far, and (when email is on) the newest one contains `text`.
        Func<int, string, bool> mailed = (count, text) => smtp.Count == count && (expected == 0 || smtp.Last.Contains(text));
        FirebaseContext.Put("placements/s", assigned); // earlier group steps cleared its academic supervisor

        // Welcome email to a new student.
        int start = smtp.Count; UseUser("coord");
        NotificationService.StudentAccountCreated((Student)users["s2"]);
        Check(smtp.Count == start + expected && Notices("s2").Count(n => n.Key == "WelcomeStudent") == 1, "Welcome notice or email missing");

        // Group create / reassign / delete: one email per person per event.
        users["academic3"] = new AcademicSupervisor { Id = "academic3", Email = "academic3@example.test" };
        FirebaseContext.Put("users/academic3", users["academic3"]);
        UseUser("coord"); var group = new StudentGroup { Name = "Email cohort", AcademicSupervisorId = "academic" };
        start = smtp.Count; new GroupRepository().SaveAssignments(group, new List<string> { "s" });
        Check(smtp.Count == start + 2 * expected, "Group creation should email the student and the supervisor: " + (smtp.Count - start));
        start = smtp.Count; UseUser("coord"); new GroupRepository().SaveAssignments(group, new List<string> { "s" });
        Check(smtp.Count == start, "Unchanged group save sent email");
        start = smtp.Count; UseUser("coord"); group.AcademicSupervisorId = "academic3"; new GroupRepository().SaveAssignments(group, new List<string> { "s" });
        Check(smtp.Count == start + 3 * expected, "Group reassignment should email the student, new and former supervisor: " + (smtp.Count - start));
        start = smtp.Count; UseUser("coord"); new GroupRepository().DeleteGroup(group.Id);
        Check(mailed(start + 2 * expected, "GroupDeletedSupervisor"), "Group deletion emails");
        FirebaseContext.Put("placements/s", assigned);

        // A published opportunity emails eligible active students that have an address.
        FirebaseContext.Put("opportunities/open", new Opportunity { Id = "open", CompanyId = "c", CompanyName = "Fixture Co", Title = "Open role", Status = OpportunityStatus.Open, TotalSeats = 2 });
        start = smtp.Count; UseUser("company"); NotificationService.OpportunityPublished("open");
        Check(smtp.Count == start + 2 * expected && Notices("s").Count(n => n.Key == "OpportunityPublished") == 1, "Opportunity emails: " + (smtp.Count - start));

        // Meeting replies email the requester once.
        UseUser("company"); var meeting = new Meeting { Title = "Check-in", CreatedById = "company", RequestedToId = "s", ScheduledAt = Time.NowMs() + 7200000, DurationMinutes = 30 };
        start = smtp.Count; string meetingId = new MeetingRepository().Insert(meeting);
        Check(mailed(start + expected, "student@example.test") && Notices("s").Count(n => n.Key == "MeetingRequest") == 2, "Meeting request: one notice and one email");
        start = smtp.Count; UseUser("s"); new MeetingRepository().ApplyAction(meetingId, "s", "Reject");
        Check(mailed(start + expected, "company@example.test") && Notices("company").Last().Key == "MeetingDeclined", "Meeting decline did not email the requester");

        // Company final evaluation page: the academic supervisor and each coordinator address once.
        start = smtp.Count; UseUser("company"); NotificationService.CompanyEvaluationSent("s");
        Check(smtp.Count == start + 2 * expected, "Company evaluation page emails: " + (smtp.Count - start));
        start = smtp.Count; NotificationService.CompanyFinalSubmitted(new FinalCompanyEvaluation { PlacementId = "s", IsSubmitted = true });
        Check(smtp.Count == start, "Repository company final path must not email twice (EmailNotificationService already does)");

        // Completion decisions: the bell shows the note/result, the email never does.
        UseUser("coord"); start = smtp.Count;
        NotificationService.CompletionDecided(new CompletionRecord { StudentId = "s", PlacementId = "s", Status = CompletionStatus.Approved, Result = "PRIVATE_RESULT", CoordinatorNote = "PRIVATE_NOTE" });
        var mails = smtp.Since(start);
        Check(mails.Count == 3 * expected && mails.All(m => !m.Contains("PRIVATE_RESULT") && !m.Contains("PRIVATE_NOTE")), "Completion approval emails missing or leaked the result");
        Check(!EmailNotificationService.Enabled || mails.Any(m => m.Contains("student@example.test") && m.Contains("CompletionApprovedNoResult") && m.Contains("https://example.test/uims/Pages/Student/Progress.aspx")), "Student approval email text or link");
        Check(Notices("s").Last(n => n.Key != null && n.Key.StartsWith("Completion")).Args.Contains("PRIVATE_RESULT"), "Bell lost the released result");
        start = smtp.Count;
        NotificationService.CompletionDecided(new CompletionRecord { StudentId = "s", PlacementId = "s", Status = CompletionStatus.Rejected, Decision = CompletionRecord.DecisionCorrections, CoordinatorNote = "PRIVATE_NOTE" });
        Check(mailed(start + expected, "CompletionReturnedNoNote") && smtp.Since(start).All(m => !m.Contains("PRIVATE_NOTE")), "Returned completion email missing or leaked the note");
        Check(Notices("s").Last().Key == "CompletionReturned" && Notices("s").Last().Args.Contains("PRIVATE_NOTE"), "Bell lost the coordinator's note");
    }

    static void UseUser(string id)
    {
        HttpContext.Current = new HttpContext(new HttpRequest("", "http://fixture.test", ""), new HttpResponse(new StringWriter()));
        SessionStateUtility.AddHttpSessionStateToContext(HttpContext.Current, new HttpSessionStateContainer("fixture", new SessionStateItemCollection(),
            new HttpStaticObjectsCollection(), 10, true, HttpCookieMode.UseCookies, SessionStateMode.InProc, false));
        SessionHelper.SignIn(users[id], "fixture");
    }

    static int Main(string[] args)
    {
        try
        {
            PolicyChecks();
            if (EmailNotificationService.InboxEnabled) InboxWorkflowChecks(int.Parse(args[0]));
            else RepositoryChecks(int.Parse(args[0]));
            Console.WriteLine("PASS: " + checks + " notification checks (email " + (EmailNotificationService.Enabled ? "enabled" : "disabled") + ").");
            return 0;
        }
        catch (Exception ex) { Console.Error.WriteLine(ex); return 1; }
    }

    sealed class SmtpFixture : IDisposable
    {
        readonly TcpListener listener;
        readonly Thread worker;
        readonly List<string> mail = new List<string>();
        public volatile bool Reject;
        public int Count { get { lock (mail) return mail.Count; } }
        public string Last { get { lock (mail) return mail.Last(); } }
        public List<string> Since(int index) { lock (mail) return mail.Skip(index).ToList(); }
        public SmtpFixture(int port)
        {
            listener = new TcpListener(IPAddress.Loopback, port);
            listener.Start();
            worker = new Thread(Run) { IsBackground = true };
            worker.Start();
        }
        void Run()
        {
            try
            {
                while (true)
                using (TcpClient client = listener.AcceptTcpClient())
                using (NetworkStream stream = client.GetStream())
                using (StreamReader reader = new StreamReader(stream, Encoding.UTF8))
                using (StreamWriter writer = new StreamWriter(stream, new UTF8Encoding(false)) { AutoFlush = true, NewLine = "\r\n" })
                {
                    writer.WriteLine("220 localhost fixture");
                    string line;
                    while ((line = reader.ReadLine()) != null)
                    {
                        if (line.StartsWith("DATA"))
                        {
                            writer.WriteLine("354 Start mail input");
                            StringBuilder body = new StringBuilder();
                            while ((line = reader.ReadLine()) != null && line != ".") body.AppendLine(line);
                            string raw = body.ToString();
                            raw = System.Text.RegularExpressions.Regex.Replace(raw,
                                @"(?im)^Content-Transfer-Encoding: base64\r?\n\r?\n([A-Za-z0-9+/\r\n=]+)",
                                m => Encoding.UTF8.GetString(Convert.FromBase64String(m.Groups[1].Value)));
                            lock (mail) mail.Add(raw);
                            writer.WriteLine("250 Queued");
                        }
                        else if (line.StartsWith("QUIT")) { writer.WriteLine("221 Bye"); break; }
                        else if (Reject && line.StartsWith("MAIL")) writer.WriteLine("550 Rejected by fixture");
                        else writer.WriteLine("250 OK");
                    }
                }
            }
            catch (SocketException) { }
            catch (IOException) { }
        }
        public void Dispose() { listener.Stop(); worker.Join(1000); }
    }
}

namespace InternshipManagementSystem.Data
{
    // API-compatible fixture: JSON round trips ensure callers never share stored references.
    public static class FirebaseContext
    {
        static readonly Dictionary<string, object> data = new Dictionary<string, object>();
        static int nextId;
        public static int Reads;
        public static bool FailWrites, FailReads, FailNotificationWrites;
        public static string Get(string path)
        {
            Reads++;
            if (FailReads) throw new IOException("Fixture read failure");
            object node = data;
            foreach (var part in path.Split(new[] { '/' }, StringSplitOptions.RemoveEmptyEntries)) {
                var map = node as Dictionary<string, object>;
                if (map == null || !map.TryGetValue(part, out node)) return null;
            }
            return node == null ? null : Json.Serialize(node);
        }
        public static string GetRecent(string path, int limit) {
            var map = Json.Deserialize<Dictionary<string, UserNotification>>(Get(path));
            return map == null ? null : Json.Serialize(map.OrderByDescending(k => k.Value.CreatedAt).Take(limit).ToDictionary(k => k.Key,k => k.Value));
        }
        public static string GetWhere(string path, string field, string value)
        {
            var all = Json.Deserialize<Dictionary<string, Dictionary<string, object>>>(Get(path));
            return all == null ? null : Json.Serialize(all.Where(k => k.Value.ContainsKey(field) && Convert.ToString(k.Value[field]) == value)
                .ToDictionary(k => k.Key, k => k.Value));
        }
        public static string Put(string path, object value)
        {
            if (FailWrites || FailNotificationWrites && path.StartsWith("notifications/")) throw new IOException("Fixture write failure");
            var parts = path.Split('/'); var node = data;
            for (int i = 0; i < parts.Length - 1; i++) {
                object next;
                if (!node.TryGetValue(parts[i], out next) || !(next is Dictionary<string, object>)) node[parts[i]] = next = new Dictionary<string, object>();
                node = (Dictionary<string, object>)next;
            }
            node[parts.Last()] = new System.Web.Script.Serialization.JavaScriptSerializer().DeserializeObject(Json.Serialize(value));
            return Json.Serialize(value);
        }
        public static string Push(string path, object value)
        { string id = NewKey(); Put(path + "/" + id, value); return id; }
        // Zero-padded so keys sort by creation order, like real Firebase push keys.
        public static string NewKey() { return "record" + (++nextId).ToString("D6"); }
        public static string PushWithId(string path, object value)
        {
            string id = NewKey();
            var property = value == null ? null : value.GetType().GetProperty("Id");
            if (property != null && property.CanWrite && property.PropertyType == typeof(string)) property.SetValue(value, id, null);
            Put(path.TrimEnd('/') + "/" + id, value);
            return id;
        }
        public static string GetLast(string path, int count)
        {
            var map = Json.ToMap(Get(path) ?? "null");
            if (map == null || map.Count == 0) return null;
            return Json.Serialize(map.OrderBy(k => k.Key, StringComparer.Ordinal).Skip(Math.Max(0, map.Count - count)).ToDictionary(k => k.Key, k => k.Value));
        }
        public static string Patch(string path, object changes)
        {
            if (FailWrites) throw new IOException("Fixture write failure");
            foreach (var pair in Json.ToMap(Json.Serialize(changes))) Put((path.Length == 0 ? "" : path + "/") + pair.Key, pair.Value);
            return Json.Serialize(changes);
        }
        public static bool PutIfEmpty(string path, object value)
        { if (Get(path) != null) return false; Put(path, value); return true; }
        public static string GetVersioned(string path, out string etag)
        { string json = Get(path); etag = json ?? "null"; return json; }
        public static string GetWithEtag(string path, out string etag) { return GetVersioned(path, out etag); }
        public static bool PutIfUnchanged(string path, object value, string etag) { return PutIfVersion(path,value,etag); }
        public static bool PutIfVersion(string path, object value, string etag)
        { if ((Get(path) ?? "null") != etag) return false; Put(path, value); return true; }
        public static void Delete(string path) { Put(path,null); }
    }
}

namespace InternshipManagementSystem.Data {
    public class FirebaseException : Exception { public FirebaseException(string message) : base(message) {} }
}
namespace InternshipManagementSystem.Data {
    public class FirebaseAuthExpiredException : Exception {}
}
