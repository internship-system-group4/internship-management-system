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
        Check(messages.Count == 0, "Routine task edit resent assignment");
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
            Check(smtp.Count == 1, "Patch resent task assignment");
            tasks.Update(id, new Dictionary<string, object> { { "StudentId", "s2" } });
            Check(smtp.Count == 2 && smtp.Last.Contains("otherstudent@example.test"), "Patch reassignment did not send");
            InternshipTask existing = tasks.GetById(id);
            tasks.Save(id, existing);
            Check(smtp.Count == 2, "Save resent task assignment");
            FirebaseContext.FailWrites = true;
            try { tasks.Insert(new InternshipTask { StudentId = "s" }); throw new Exception("Failed write succeeded"); }
            catch (IOException) { }
            FirebaseContext.FailWrites = false;
            Check(smtp.Count == 2, "Failed write sent mail");
            FirebaseContext.FailReads = true;
            tasks.Save(id, existing);
            FirebaseContext.FailReads = false;
            Check(smtp.Count == 2, "Unavailable notification snapshot produced false assignment");
            EvaluationRepository evaluations = new EvaluationRepository();
            // Final evaluations now require the assigned author and are immutable once submitted.
            UseUser("company");
            FinalCompanyEvaluation company = new FinalCompanyEvaluation { StudentId = "s", PlacementId = "s", CompanyId = "c", SupervisorId = "company", IsSubmitted = true, SubmittedAt = Time.NowMs() };
            evaluations.SaveCompanyFinal(company);
            Check(smtp.Count == 4, "Company final did not notify coordinator and academic");
            try { evaluations.SaveCompanyFinal(company); throw new Exception("Submitted company evaluation was mutable"); }
            catch (InvalidOperationException) { }
            Check(smtp.Count == 4, "Company final resave duplicated notifications");
            UseUser("academic");
            FinalAcademicEvaluation draft = new FinalAcademicEvaluation { StudentId = "s", PlacementId = "s", AcademicSupervisorId = "academic" };
            string evaluationId = evaluations.SaveAcademicFinal(draft);
            Check(smtp.Count == 4 && draft.Id == evaluationId, "Draft mail or missing generated ID");
            draft.IsSubmitted = true;
            draft.SubmittedAt = Time.NowMs();
            evaluations.SaveAcademicFinal(draft);
            Check(smtp.Count == 5 && smtp.Last.Contains("coord@example.test"), "Draft submission did not notify coordinator");
            try { evaluations.SaveAcademicFinal(draft); throw new Exception("Submitted academic evaluation was mutable"); }
            catch (InvalidOperationException) { }
            Check(smtp.Count == 5, "Repeated evaluation save sent mail");
            UseUser("coord");
            CompletionRepository completions = new CompletionRepository();
            string completionId = completions.Insert(new CompletionRecord { StudentId = "s", Status = CompletionStatus.UnderCoordinatorReview });
            Check(smtp.Count == 6, "Persisted review request did not notify coordinator");
            completions.Update(completionId, new Dictionary<string, object> { { "Status", (int)CompletionStatus.Approved } });
            Check(smtp.Count == 7, "Persisted completion decision did not notify student");
            completions.Update(completionId, new Dictionary<string, object> { { "Status", (int)CompletionStatus.Approved } });
            Check(smtp.Count == 7, "Repeated status patch resent completion mail");
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
            string meetingId = meetings.Insert(new Meeting { CreatedById = "company", ParticipantIds = new List<string> { "s" }, ScheduledAt = Time.NowMs() });
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
            RepositoryChecks(int.Parse(args[0]));
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
                            int separator = raw.IndexOf("\r\n\r\n", StringComparison.Ordinal);
                            if (separator >= 0 && raw.Contains("Content-Transfer-Encoding: base64"))
                                raw = raw.Substring(0, separator) + "\n\n" + Encoding.UTF8.GetString(
                                    Convert.FromBase64String(raw.Substring(separator + 4)));
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
        static readonly Dictionary<string, Dictionary<string, object>> data = new Dictionary<string, Dictionary<string, object>>();
        static int nextId;
        public static int Reads;
        public static bool FailWrites, FailReads;
        public static string Get(string path)
        {
            Reads++;
            if (FailReads) throw new IOException("Fixture read failure");
            string[] parts = path.Split('/');
            if (!data.ContainsKey(parts[0])) return null;
            if (parts.Length == 1) return Json.Serialize(data[parts[0]]);
            return data[parts[0]].ContainsKey(parts[1]) ? Json.Serialize(data[parts[0]][parts[1]]) : null;
        }
        public static string GetWhere(string path, string field, string value)
        {
            var all = Json.Deserialize<Dictionary<string, Dictionary<string, object>>>(Get(path));
            return all == null ? null : Json.Serialize(all.Where(k => k.Value.ContainsKey(field) && Convert.ToString(k.Value[field]) == value)
                .ToDictionary(k => k.Key, k => k.Value));
        }
        public static string Put(string path, object value)
        {
            if (FailWrites) throw new IOException("Fixture write failure");
            string[] parts = path.Split('/');
            if (!data.ContainsKey(parts[0])) data[parts[0]] = new Dictionary<string, object>();
            data[parts[0]][parts[1]] = Json.ToMap(Json.Serialize(value));
            return Json.Serialize(value);
        }
        public static string Push(string path, object value)
        { string id = "record" + (++nextId); Put(path + "/" + id, value); return id; }
        public static string Patch(string path, object changes)
        {
            if (FailWrites) throw new IOException("Fixture write failure");
            string[] parts = path.Split('/');
            Dictionary<string, object> stored = (Dictionary<string, object>)data[parts[0]][parts[1]];
            foreach (var pair in Json.ToMap(Json.Serialize(changes))) stored[pair.Key] = pair.Value;
            return Json.Serialize(stored);
        }
        public static bool PutIfEmpty(string path, object value)
        { if (Get(path) != null) return false; Put(path, value); return true; }
        public static string GetVersioned(string path, out string etag)
        { string json = Get(path); etag = json ?? "null"; return json; }
        public static bool PutIfVersion(string path, object value, string etag)
        { if ((Get(path) ?? "null") != etag) return false; Put(path, value); return true; }
        public static void Delete(string path)
        { string[] parts = path.Split('/'); data[parts[0]].Remove(parts[1]); }
    }
}
