using System;
using System.Collections.Generic;
using System.Linq;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Data
{
    // Presentation-only read models. Existing repositories remain the write/authorization authority.
    public class JourneyFact { public string Label; public string Value; }
    public class JourneyAction { public string Label; public string Url; }
    public class JourneyStage
    {
        public string Title, State, Summary, Description;
        public List<JourneyFact> Facts = new List<JourneyFact>();
        public List<JourneyAction> Actions = new List<JourneyAction>();
        public string StateLabel { get { return State == "completed" ? "Complete" : State == "current" ? "Current" : State == "blocked" ? "Action required" : "Upcoming"; } }
    }
    public class WorkspaceJourneyData
    {
        public string Title, Context;
        public List<JourneyStage> Stages = new List<JourneyStage>();
    }
    public class WorkspaceStudentData
    {
        public List<TrainingHoursEntry> Hours;
        public Placement Placement;
        public long ApprovedHours, PendingHours;
        public int RequiredHours, EvaluatedTasks;
        public CompletionRecord Completion;
        public List<InternshipApplication> Applications;
        public List<InternshipTask> Tasks;
        public WorkspaceJourneyData Journey;
    }
    public class WorkspaceCompanyData
    {
        public List<TrainingHoursEntry> Hours;
        public int Opportunities, PendingApplications, PendingSubmissions, PendingFinals;
        public long PendingHours;
        public List<InternshipApplication> Applications;
        public List<PlacementOverview> Trainees;
        public List<Submission> Submissions;
        public WorkspaceJourneyData Journey;
    }
    public class WorkspaceAcademicRow
    {
        public string Id { get; set; } public string FullName { get; set; } public string StudentNumber { get; set; } public string Major { get; set; } public string CompanyName { get; set; }
        public long ApprovedHours { get; set; } public long PendingHours { get; set; }
        public int RequiredHours { get; set; }
        public PlacementStatus? PlacementStatus { get; set; }
        public bool HasPlacement { get; set; } public bool CompanySubmitted { get; set; } public bool AcademicSubmitted { get; set; }
        public int HoursPercent { get { return RequiredHours > 0 ? (int)Math.Min(100, ApprovedHours * 100 / RequiredHours) : 0; } }
        public string HoursText { get { return RequiredHours > 0 ? ApprovedHours + " / " + RequiredHours + " h" : ApprovedHours + " h · target not set"; } }
        public string NextAction { get { return !HasPlacement ? "Awaiting placement" : CompanySubmitted && !AcademicSubmitted ? "Academic evaluation due" : "Training in progress"; } }
    }
    public class WorkspaceAcademicData
    {
        public List<TrainingHoursEntry> Hours;
        public List<WorkspaceAcademicRow> Students;
        public int HoursMet, CompanyFeedback, PendingEvaluations;
        public WorkspaceJourneyData Journey;
    }
    public class WorkspaceCoordinatorData
    {
        public List<Student> Students;
        public CoordinatorDashboardData Summary;
        public List<CompletionQueueRow> Queue;
        public int UnassignedStudents;
        public WorkspaceJourneyData Journey;
    }
    public class WorkspaceDashboardRepository
    {
        private static bool Canonical(Placement p) { return p != null && p.Id == p.StudentId && p.Status != PlacementStatus.Offered && Enum.IsDefined(typeof(PlacementStatus), p.Status); }
        private static string N(long value) { return value.ToString(System.Globalization.CultureInfo.InvariantCulture); }
        private static JourneyFact Fact(string label, string value) { return new JourneyFact { Label = label, Value = value }; }
        private static JourneyStage Stage(string title, string state, string summary, string description, string action, string url, params JourneyFact[] facts)
        {
            return new JourneyStage { Title = title, State = state, Summary = summary, Description = description, Facts = facts.ToList(), Actions = new List<JourneyAction> { new JourneyAction { Label = action, Url = url } } };
        }
        public WorkspaceStudentData LoadStudent(Student student)
        {
            var apps = new ApplicationRepository().GetWhere("StudentId", student.Id).OrderByDescending(a => a.SubmittedAt).ToList();
            var placement = new PlacementRepository().GetById(student.Id);
            if (!Canonical(placement) || placement.StudentId != student.Id) placement = null;
            var tasks = new TaskRepository().GetByStudent(student.Id).Where(t => placement != null && t.PlacementId == placement.Id && t.CompanyId == placement.CompanyId).ToList();
            var taskIds = new HashSet<string>(tasks.Select(t => t.Id));
            var grades = new EvaluationRepository().GetTaskEvaluationsForStudent(student.Id).Where(e => taskIds.Contains(e.TaskId ?? "") && placement != null && e.PlacementId == placement.Id).Select(e => e.TaskId).Distinct().Count();
            var hours = new HoursRepository().GetByStudent(student.Id).Where(h => placement != null && h.PlacementId == placement.Id && h.Hours > 0).ToList();
            var approved = hours.Where(h => h.Status == HoursStatus.Approved).Sum(h => (long)h.Hours);
            var pending = hours.Where(h => h.Status == HoursStatus.Reported).Sum(h => (long)h.Hours);
            // Never read either confidential final evaluation from a student dashboard.
            var completion = placement == null ? null : new CompletionRepository().GetWhere("StudentId", student.Id).Where(c => c.PlacementId == placement.Id).OrderByDescending(c => c.ApprovedAt).ThenByDescending(c => c.CreatedAt).FirstOrDefault();
            int target = placement == null ? Math.Max(0, student.RequiredHours) : Math.Max(0, placement.RequiredHours);
            bool complete = completion != null && completion.Status == CompletionStatus.Approved;
            bool cancelled = placement != null && placement.Status == PlacementStatus.Cancelled;
            bool trainingMet = target > 0 && approved >= target && tasks.Count > 0 && tasks.All(t => t.Status == InternshipTaskStatus.Graded);
            bool review = completion != null && completion.Status == CompletionStatus.UnderCoordinatorReview;
            bool returned = completion != null && completion.Status == CompletionStatus.Rejected;
            bool acceptedOffer = apps.Any(a => a.Status == ApplicationStatus.Accepted);
            var journey = new WorkspaceJourneyData { Title = "Your internship journey", Context = "Your own application, confirmed placement and training record." };
            journey.Stages.Add(Stage("Application", placement != null || acceptedOffer ? "completed" : "current", N(apps.Count) + (apps.Count == 1 ? " application" : " applications"), "Explore eligible opportunities and follow the company’s decision. An accepted offer still needs your confirmation.", "View applications", "~/Pages/Student/MyApplications.aspx", Fact("Applications", N(apps.Count)), Fact("Awaiting company review", N(apps.Count(a => a.Status == ApplicationStatus.Pending))), Fact("Accepted offers", N(apps.Count(a => a.Status == ApplicationStatus.Accepted)))));
            journey.Stages.Add(Stage("Placement", cancelled ? "blocked" : placement != null ? "completed" : acceptedOffer ? "current" : "upcoming", placement == null ? "Not confirmed" : cancelled ? "Placement cancelled" : placement.CompanyName, placement == null ? "Confirm one accepted offer to establish your single internship placement." : cancelled ? "This placement has been cancelled. Contact your coordinator before continuing." : "This is your confirmed internship. Your training work is linked to this placement.", placement == null ? "Review offers" : "View placement", placement == null ? "~/Pages/Student/MyApplications.aspx" : "~/Pages/Student/Progress.aspx", Fact("Company", placement == null ? "Not confirmed" : placement.CompanyName), Fact("Confirmed", placement == null ? "Not yet" : Time.DisplayDate(placement.ConfirmedAt)), Fact("Training dates", placement == null ? "Not set" : Time.DisplayDate(placement.StartDate) + " – " + Time.DisplayDate(placement.EndDate))));
            journey.Stages.Add(Stage("Training", cancelled ? "blocked" : complete || trainingMet ? "completed" : placement != null ? "current" : "upcoming", N(approved) + " approved hours", "Only supervisor-approved training hours count. Submitted hours remain separate until approved.", "Open training tasks", "~/Pages/Student/MyTasks.aspx", Fact("Approved hours", N(approved)), Fact("Pending hours", N(pending)), Fact("Required hours", target > 0 ? N(target) : "Target not set"), Fact("Tasks graded", grades + " of " + tasks.Count)));
            journey.Stages.Add(Stage("Evaluation", complete || review ? "completed" : placement != null && trainingMet ? "current" : "upcoming", review || complete ? "Assessment received" : "Supervisor assessment", "Your supervisors manage the final assessments. Their internal forms stay private; your released result appears only after coordinator approval.", "View progress and feedback", "~/Pages/Student/Progress.aspx", Fact("Task feedback available", N(grades)), Fact("Completion record", completion == null ? "Not started" : complete ? "Approved" : review ? "Under coordinator review" : returned ? "Returned for follow-up" : "Awaiting supervisor assessment")));
            journey.Stages.Add(Stage("Completion", complete ? "completed" : returned ? "blocked" : review ? "current" : "upcoming", complete ? "Coordinator approved" : returned ? "Follow-up required" : "Coordinator approval", "Meeting an hours target does not complete an internship. Only the coordinator can approve completion and release the final result.", "Open completion status", "~/Pages/Student/Progress.aspx", Fact("Decision", complete ? "Approved " + Time.DisplayDate(completion.ApprovedAt) : returned ? "Returned — contact your supervisor" : "Not approved yet")));
            return new WorkspaceStudentData { Hours = hours, Placement = placement, ApprovedHours = approved, PendingHours = pending, RequiredHours = target, EvaluatedTasks = grades, Completion = completion, Applications = apps, Tasks = tasks, Journey = journey };
        }
        public WorkspaceCompanyData LoadCompany(string companyId)
        {
            var applications = new ApplicationRepository().GetAll().Where(a => a.CompanyId == companyId).ToList();
            var placements = new PlacementRepository().GetAll().Where(p => Canonical(p) && p.CompanyId == companyId && p.Status != PlacementStatus.Cancelled).ToList();
            var byId = placements.ToDictionary(p => p.Id);
            var hours = new HoursRepository().GetAll().Where(h => byId.ContainsKey(h.PlacementId ?? "") && h.StudentId == byId[h.PlacementId].StudentId && h.Hours > 0).ToList();
            var tasks = new TaskRepository().GetAll().Where(t => byId.ContainsKey(t.PlacementId ?? "") && t.CompanyId == companyId && t.StudentId == byId[t.PlacementId].StudentId).ToDictionary(t => t.Id);
            var submissions = new SubmissionRepository().GetAll().Where(s => tasks.ContainsKey(s.TaskId ?? "") && s.StudentId == tasks[s.TaskId].StudentId && s.PlacementId == tasks[s.TaskId].PlacementId && (s.Status == SubmissionStatus.Submitted || s.Status == SubmissionStatus.UnderReview)).OrderByDescending(s => s.SubmittedAt).ToList();
            var finals = new EvaluationRepository().GetCompanyFinalsForCompany(companyId).Where(f => f.IsSubmitted && byId.ContainsKey(f.PlacementId ?? "") && f.StudentId == byId[f.PlacementId].StudentId).Select(f => f.PlacementId).Distinct().Count();
            var trainees = placements.Select(p => new PlacementOverview { Placement = p, ApprovedHours = hours.Where(h => h.PlacementId == p.Id && h.Status == HoursStatus.Approved).Sum(h => (long)h.Hours), PendingHours = hours.Where(h => h.PlacementId == p.Id && h.Status == HoursStatus.Reported).Sum(h => (long)h.Hours) }).ToList();
            int pending = applications.Count(a => a.Status == ApplicationStatus.Pending), waitingFinals = Math.Max(0, placements.Count - finals);
            long pendingHours = hours.Where(h => h.Status == HoursStatus.Reported).Sum(h => (long)h.Hours);
            var journey = new WorkspaceJourneyData { Title = "Company review workflow", Context = "Application, training and assessment queues for your company." };
            journey.Stages.Add(Stage("Applications", pending > 0 ? "current" : "upcoming", pending + " awaiting review", "Review candidates for your company. Acceptance is an offer; a placement exists only after the student confirms it.", "Review applications", "~/Pages/Company/Applications.aspx", Fact("Pending decisions", N(pending)), Fact("All company applications", N(applications.Count))));
            journey.Stages.Add(Stage("Training", placements.Count > 0 ? "current" : "upcoming", placements.Count + " trainees", "Follow your company’s confirmed placements and review reported hours. Pending hours are not approved progress.", "View trainees and hours", "~/Pages/Company/Trainees.aspx", Fact("Confirmed placements", N(placements.Count)), Fact("Hours awaiting approval", N(pendingHours))));
            journey.Stages.Add(Stage("Submissions", submissions.Count > 0 ? "current" : "upcoming", submissions.Count + " to review", "Open the submitted work, grade against the task criteria, or request a revision using the existing review workflow.", "Review submitted work", "~/Pages/Company/TaskReview.aspx", Fact("Waiting submissions", N(submissions.Count))));
            journey.Stages.Add(Stage("Final assessment", waitingFinals > 0 ? "current" : finals > 0 ? "completed" : "upcoming", waitingFinals + " not submitted", "Complete your company assessment for the applicable trainee. This does not replace the academic assessment or coordinator approval.", "Open final evaluations", "~/Pages/Company/FinalEvaluation.aspx", Fact("Company assessments submitted", N(finals)), Fact("Placements without a submitted assessment", N(waitingFinals))));
            return new WorkspaceCompanyData { Hours = hours, Applications = applications, Opportunities = new OpportunityRepository().GetAll().Count(o => o.CompanyId == companyId), PendingApplications = pending, PendingSubmissions = submissions.Count, PendingFinals = waitingFinals, PendingHours = pendingHours, Submissions = submissions, Trainees = trainees, Journey = journey };
        }
        public WorkspaceAcademicData LoadAcademic(string supervisorId)
        {
            var students = new UserRepository().GetStudentsBySupervisor(supervisorId);
            var ids = new HashSet<string>(students.Select(s => s.Id));
            var placements = new PlacementRepository().GetAll().Where(p => Canonical(p) && ids.Contains(p.StudentId) && p.AcademicSupervisorId == supervisorId).ToDictionary(p => p.StudentId);
            var hours = new HoursRepository().GetAll().Where(h => placements.ContainsKey(h.StudentId ?? "") && h.PlacementId == placements[h.StudentId].Id && h.Hours > 0).ToList();
            var evaluations = new EvaluationRepository();
            var rows = students.Select(s =>
            {
                Placement p; placements.TryGetValue(s.Id, out p);
                var company = p == null ? null : evaluations.GetCompanyFinalForPlacement(p.Id);
                var academic = p == null ? null : evaluations.GetAcademicFinalForPlacement(p.Id);
                return new WorkspaceAcademicRow { Id = s.Id, FullName = s.FullName, StudentNumber = s.StudentNumber, Major = s.Major, PlacementStatus = p == null ? (PlacementStatus?)null : p.Status, HasPlacement = p != null, CompanyName = p == null ? "Not confirmed" : p.CompanyName, RequiredHours = p == null ? s.RequiredHours : p.RequiredHours, ApprovedHours = hours.Where(h => h.StudentId == s.Id && h.Status == HoursStatus.Approved).Sum(h => (long)h.Hours), PendingHours = hours.Where(h => h.StudentId == s.Id && h.Status == HoursStatus.Reported).Sum(h => (long)h.Hours), CompanySubmitted = company != null && company.StudentId == s.Id && company.CompanyId == p.CompanyId && company.IsSubmitted, AcademicSubmitted = academic != null && academic.StudentId == s.Id && academic.AcademicSupervisorId == supervisorId && academic.IsSubmitted };
            }).OrderByDescending(s => s.CompanySubmitted && !s.AcademicSubmitted).ThenBy(s => s.FullName).ToList();
            int feedback = rows.Count(r => r.CompanySubmitted), pending = rows.Count(r => r.CompanySubmitted && !r.AcademicSubmitted), met = rows.Count(r => r.RequiredHours > 0 && r.ApprovedHours >= r.RequiredHours);
            var journey = new WorkspaceJourneyData { Title = "Academic review workflow", Context = "Follow-up and assessment queues for your assigned students." };
            journey.Stages.Add(Stage("Assigned students", rows.Count > 0 ? "current" : "upcoming", rows.Count + " students", "Open a student’s record to review the placement, training tasks and academic follow-up. Unassigned students are outside this view.", "View assigned students", "~/Pages/Academic/StudentProgress.aspx", Fact("Assigned to you", N(rows.Count)), Fact("With confirmed placements", N(rows.Count(r => r.HasPlacement)))));
            journey.Stages.Add(Stage("Training progress", rows.Any(r => r.HasPlacement) ? "current" : "upcoming", met + (met == 1 ? " hours target met" : " hours targets met"), "Review approved and pending hours separately. An hours target being met is not a final completion decision.", "Review training progress", "~/Pages/Academic/StudentProgress.aspx", Fact("Hours requirements met", N(met)), Fact("Hours awaiting company approval", N(rows.Sum(r => r.PendingHours)))));
            journey.Stages.Add(Stage("Company feedback", feedback > 0 ? "current" : "upcoming", feedback + " assessments received", "Read authorized company feedback inside the assigned student’s record. Internal assessments remain restricted.", "Open student records", "~/Pages/Academic/StudentProgress.aspx", Fact("Submitted company assessments", N(feedback))));
            journey.Stages.Add(Stage("Academic evaluation", pending > 0 ? "current" : rows.Any(r => r.AcademicSubmitted) ? "completed" : "upcoming", pending + " ready for follow-up", "Complete the academic assessment through the existing evaluation page. The coordinator makes the final completion decision.", "Open academic evaluations", "~/Pages/Academic/FinalEvaluation.aspx", Fact("Company assessment received; academic not submitted", N(pending)), Fact("Academic assessments submitted", N(rows.Count(r => r.AcademicSubmitted)))));
            return new WorkspaceAcademicData { Hours = hours, Students = rows, HoursMet = met, CompanyFeedback = feedback, PendingEvaluations = pending, Journey = journey };
        }
        public WorkspaceCoordinatorData LoadCoordinator()
        {
            var repo = new CoordinatorMonitoringRepository();
            var summary = repo.LoadDashboard();
            var queue = repo.LoadCompletionQueue();
            var students = new UserRepository().GetAllPeople().OfType<Student>().ToList();
            int unassigned = students.Count(s => s.IsActive && string.IsNullOrWhiteSpace(s.AcademicSupervisorId));
            var journey = new WorkspaceJourneyData { Title = "Programme coordination", Context = "Programme-wide work queues. Completion is a separate, coordinator-only decision for each student." };
            journey.Stages.Add(Stage("Assignments", unassigned > 0 ? "current" : "upcoming", unassigned + " without a supervisor", "Check active student records and group assignments. This count uses the academic supervisor recorded on each student profile.", "Manage assignments", "~/Pages/Coordinator/Groups.aspx", Fact("Active profiles without an academic supervisor", N(unassigned))));
            journey.Stages.Add(Stage("Training oversight", summary.ActivePlacements > 0 ? "current" : "upcoming", summary.ActivePlacements + " active placements", "Monitor confirmed training and exceptions. Each record retains its own company, supervisor and hours requirement.", "Open placements", "~/Pages/Coordinator/Placements.aspx", Fact("Confirmed or active", N(summary.ActivePlacements)), Fact("Hours awaiting approval", N(summary.PendingHours)), Fact("Overdue ungraded tasks", N(summary.OverdueTasks))));
            journey.Stages.Add(Stage("Final evaluations", summary.CompanyFinals + summary.AcademicFinals > 0 ? "current" : "upcoming", (summary.CompanyFinals + summary.AcademicFinals) + " submitted", "Review received assessments in the authorized completion workflow. Submitted evaluations do not automatically approve completion.", "Review evaluations", "~/Pages/Coordinator/CompletionReview.aspx", Fact("Company assessments", N(summary.CompanyFinals)), Fact("Academic assessments", N(summary.AcademicFinals))));
            journey.Stages.Add(Stage("Completion review", queue.Any(q => q.IsReady || q.IsReturned) ? "current" : "upcoming", queue.Count(q => q.IsReady) + " ready for review", "Review the actual requirements and final result before approving. Only an explicit coordinator decision releases the student’s result and report.", "Open completion queue", "~/Pages/Coordinator/CompletionReview.aspx", Fact("Both evaluations received; not approved", N(queue.Count(q => q.IsReady))), Fact("Approved completions", N(queue.Count(q => q.IsApproved))), Fact("Returned for follow-up", N(queue.Count(q => q.IsReturned)))));
            return new WorkspaceCoordinatorData { Students = students, Summary = summary, Queue = queue, UnassignedStudents = unassigned, Journey = journey };
        }
    }
}
