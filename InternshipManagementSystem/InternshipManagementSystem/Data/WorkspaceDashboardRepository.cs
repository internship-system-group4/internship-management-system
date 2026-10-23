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
        public string StateLabel { get { return State == "completed" ? L.T("Workspace.Complete") : State == "current" ? L.T("Workspace.Current") : State == "blocked" ? L.T("Workspace.ActionRequired") : L.T("Workspace.Upcoming"); } }
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
        public string HoursText { get { return RequiredHours > 0 ? ApprovedHours + " / " + RequiredHours + " " + L.T("Workspace.UnitH") : ApprovedHours + L.T("Workspace.HTargetNotSet"); } }
        public string NextAction { get { return !HasPlacement ? L.T("Workspace.AwaitingPlacement") : CompanySubmitted && !AcademicSubmitted ? L.T("Workspace.AcademicEvaluationDue") : L.T("Workspace.TrainingInProgress"); } }
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
            var journey = new WorkspaceJourneyData { Title = L.T("Workspace.YourInternshipJourney"), Context = L.T("Workspace.YourOwnApplicationConfirmedPlacementAndTraining") };
            journey.Stages.Add(Stage(L.T("Workspace.Application"), placement != null || acceptedOffer ? "completed" : "current", N(apps.Count) + (apps.Count == 1 ? L.T("Workspace.Application2") : L.T("Workspace.Applications2")), L.T("Workspace.ExploreEligibleOpportunitiesAndFollowTheCompany"), L.T("Workspace.ViewApplications"), "~/Pages/Student/MyApplications.aspx", Fact(L.T("Workspace.Applications"), N(apps.Count)), Fact(L.T("Workspace.AwaitingCompanyReview"), N(apps.Count(a => a.Status == ApplicationStatus.Pending))), Fact(L.T("Workspace.AcceptedOffers"), N(apps.Count(a => a.Status == ApplicationStatus.Accepted)))));
            journey.Stages.Add(Stage(L.T("Workspace.Placement"), cancelled ? "blocked" : placement != null ? "completed" : acceptedOffer ? "current" : "upcoming", placement == null ? L.T("Workspace.NotConfirmed") : cancelled ? L.T("Workspace.PlacementCancelled") : placement.CompanyName, placement == null ? L.T("Workspace.ConfirmOneAcceptedOfferToEstablishYour") : cancelled ? L.T("Workspace.ThisPlacementHasBeenCancelledContactYour") : L.T("Workspace.ThisIsYourConfirmedInternshipYourTraining"), placement == null ? L.T("Workspace.ReviewOffers") : L.T("Workspace.ViewPlacement"), placement == null ? "~/Pages/Student/MyApplications.aspx" : "~/Pages/Student/Progress.aspx", Fact(L.T("Workspace.Company"), placement == null ? L.T("Workspace.NotConfirmed") : placement.CompanyName), Fact(L.T("Workspace.Confirmed"), placement == null ? L.T("Workspace.NotYet") : Time.DisplayDate(placement.ConfirmedAt)), Fact(L.T("Workspace.TrainingDates"), placement == null ? L.T("Workspace.NotSet") : Time.DisplayDate(placement.StartDate) + " – " + Time.DisplayDate(placement.EndDate))));
            journey.Stages.Add(Stage(L.T("Workspace.Training"), cancelled ? "blocked" : complete || trainingMet ? "completed" : placement != null ? "current" : "upcoming", N(approved) + L.T("Workspace.ApprovedHours2"), L.T("Workspace.OnlySupervisorApprovedTrainingHoursCountSubmitted"), L.T("Workspace.OpenTrainingTasks"), "~/Pages/Student/MyTasks.aspx", Fact(L.T("Workspace.ApprovedHours"), N(approved)), Fact(L.T("Workspace.PendingHours"), N(pending)), Fact(L.T("Workspace.RequiredHours"), target > 0 ? N(target) : L.T("Workspace.TargetNotSet")), Fact(L.T("Workspace.TasksGraded"), grades + L.T("Workspace.Of") + tasks.Count)));
            journey.Stages.Add(Stage(L.T("Workspace.Evaluation"), complete || review ? "completed" : placement != null && trainingMet ? "current" : "upcoming", review || complete ? L.T("Workspace.AssessmentReceived") : L.T("Workspace.SupervisorAssessment"), L.T("Workspace.YourSupervisorsManageTheFinalAssessmentsTheir"), L.T("Workspace.ViewProgressAndFeedback"), "~/Pages/Student/Progress.aspx", Fact(L.T("Workspace.TaskFeedbackAvailable"), N(grades)), Fact(L.T("Workspace.CompletionRecord"), completion == null ? L.T("Workspace.NotStarted") : complete ? L.T("Workspace.Approved") : review ? L.T("Workspace.UnderCoordinatorReview") : returned ? L.T("Workspace.ReturnedForFollowUp") : L.T("Workspace.AwaitingSupervisorAssessment"))));
            journey.Stages.Add(Stage(L.T("Workspace.Completion"), complete ? "completed" : returned ? "blocked" : review ? "current" : "upcoming", complete ? L.T("Workspace.CoordinatorApproved") : returned ? L.T("Workspace.FollowUpRequired") : L.T("Workspace.CoordinatorApproval"), L.T("Workspace.MeetingAnHoursTargetDoesNotComplete"), L.T("Workspace.OpenCompletionStatus"), "~/Pages/Student/Progress.aspx", Fact(L.T("Workspace.Decision2"), complete ? L.T("Workspace.Approved2") + Time.DisplayDate(completion.ApprovedAt) : returned ? L.T("Workspace.ReturnedContactYourSupervisor") : L.T("Workspace.NotApprovedYet"))));
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
            var journey = new WorkspaceJourneyData { Title = L.T("Workspace.CompanyReviewWorkflow"), Context = L.T("Workspace.ApplicationTrainingAndAssessmentQueuesForYour") };
            journey.Stages.Add(Stage(L.T("Workspace.Applications"), pending > 0 ? "current" : "upcoming", pending + L.T("Workspace.AwaitingReview"), L.T("Workspace.ReviewCandidatesForYourCompanyAcceptanceIs"), L.T("Workspace.ReviewApplications"), "~/Pages/Company/Applications.aspx", Fact(L.T("Workspace.PendingDecisions"), N(pending)), Fact(L.T("Workspace.AllCompanyApplications"), N(applications.Count))));
            journey.Stages.Add(Stage(L.T("Workspace.Training"), placements.Count > 0 ? "current" : "upcoming", placements.Count + L.T("Workspace.Trainees"), L.T("Workspace.FollowYourCompanySConfirmedPlacementsAnd"), L.T("Workspace.ViewTraineesAndHours"), "~/Pages/Company/Trainees.aspx", Fact(L.T("Workspace.ConfirmedPlacements"), N(placements.Count)), Fact(L.T("Workspace.HoursAwaitingApproval"), N(pendingHours))));
            journey.Stages.Add(Stage(L.T("Workspace.Submissions"), submissions.Count > 0 ? "current" : "upcoming", submissions.Count + L.T("Workspace.ToReview"), L.T("Workspace.OpenTheSubmittedWorkGradeAgainstThe"), L.T("Workspace.ReviewSubmittedWork"), "~/Pages/Company/TaskReview.aspx", Fact(L.T("Workspace.WaitingSubmissions"), N(submissions.Count))));
            journey.Stages.Add(Stage(L.T("Workspace.FinalAssessment"), waitingFinals > 0 ? "current" : finals > 0 ? "completed" : "upcoming", waitingFinals + L.T("Workspace.NotSubmitted"), L.T("Workspace.CompleteYourCompanyAssessmentForTheApplicable"), L.T("Workspace.OpenFinalEvaluations"), "~/Pages/Company/FinalEvaluation.aspx", Fact(L.T("Workspace.CompanyAssessmentsSubmitted"), N(finals)), Fact(L.T("Workspace.PlacementsWithoutASubmittedAssessment"), N(waitingFinals))));
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
                return new WorkspaceAcademicRow { Id = s.Id, FullName = s.FullName, StudentNumber = s.StudentNumber, Major = s.Major, PlacementStatus = p == null ? (PlacementStatus?)null : p.Status, HasPlacement = p != null, CompanyName = p == null ? L.T("Workspace.NotConfirmed") : p.CompanyName, RequiredHours = p == null ? s.RequiredHours : p.RequiredHours, ApprovedHours = hours.Where(h => h.StudentId == s.Id && h.Status == HoursStatus.Approved).Sum(h => (long)h.Hours), PendingHours = hours.Where(h => h.StudentId == s.Id && h.Status == HoursStatus.Reported).Sum(h => (long)h.Hours), CompanySubmitted = company != null && company.StudentId == s.Id && company.CompanyId == p.CompanyId && company.IsSubmitted, AcademicSubmitted = academic != null && academic.StudentId == s.Id && academic.AcademicSupervisorId == supervisorId && academic.IsSubmitted };
            }).OrderByDescending(s => s.CompanySubmitted && !s.AcademicSubmitted).ThenBy(s => s.FullName).ToList();
            int feedback = rows.Count(r => r.CompanySubmitted), pending = rows.Count(r => r.CompanySubmitted && !r.AcademicSubmitted), met = rows.Count(r => r.RequiredHours > 0 && r.ApprovedHours >= r.RequiredHours);
            var journey = new WorkspaceJourneyData { Title = L.T("Workspace.AcademicReviewWorkflow"), Context = L.T("Workspace.FollowUpAndAssessmentQueuesForYour") };
            journey.Stages.Add(Stage(L.T("Workspace.AssignedStudents"), rows.Count > 0 ? "current" : "upcoming", rows.Count + L.T("Workspace.Students"), L.T("Workspace.OpenAStudentSRecordToReview"), L.T("Workspace.ViewAssignedStudents"), "~/Pages/Academic/StudentProgress.aspx", Fact(L.T("Workspace.AssignedToYou"), N(rows.Count)), Fact(L.T("Workspace.WithConfirmedPlacements"), N(rows.Count(r => r.HasPlacement)))));
            journey.Stages.Add(Stage(L.T("Workspace.TrainingProgress"), rows.Any(r => r.HasPlacement) ? "current" : "upcoming", met + (met == 1 ? L.T("Workspace.HoursTargetMet2") : L.T("Workspace.HoursTargetsMet")), L.T("Workspace.ReviewApprovedAndPendingHoursSeparatelyAn"), L.T("Workspace.ReviewTrainingProgress"), "~/Pages/Academic/StudentProgress.aspx", Fact(L.T("Workspace.HoursRequirementsMet"), N(met)), Fact(L.T("Workspace.HoursAwaitingCompanyApproval"), N(rows.Sum(r => r.PendingHours)))));
            journey.Stages.Add(Stage(L.T("Workspace.CompanyFeedback"), feedback > 0 ? "current" : "upcoming", feedback + L.T("Workspace.AssessmentsReceived"), L.T("Workspace.ReadAuthorizedCompanyFeedbackInsideTheAssigned"), L.T("Workspace.OpenStudentRecords"), "~/Pages/Academic/StudentProgress.aspx", Fact(L.T("Workspace.SubmittedCompanyAssessments"), N(feedback))));
            journey.Stages.Add(Stage(L.T("Workspace.AcademicEvaluation"), pending > 0 ? "current" : rows.Any(r => r.AcademicSubmitted) ? "completed" : "upcoming", pending + L.T("Workspace.ReadyForFollowUp"), L.T("Workspace.CompleteTheAcademicAssessmentThroughTheExisting"), L.T("Workspace.OpenAcademicEvaluations"), "~/Pages/Academic/FinalEvaluation.aspx", Fact(L.T("Workspace.CompanyAssessmentReceivedAcademicNotSubmitted"), N(pending)), Fact(L.T("Workspace.AcademicAssessmentsSubmitted"), N(rows.Count(r => r.AcademicSubmitted)))));
            return new WorkspaceAcademicData { Hours = hours, Students = rows, HoursMet = met, CompanyFeedback = feedback, PendingEvaluations = pending, Journey = journey };
        }
        public WorkspaceCoordinatorData LoadCoordinator()
        {
            var repo = new CoordinatorMonitoringRepository();
            var summary = repo.LoadDashboard();
            var queue = repo.LoadCompletionQueue();
            var students = new UserRepository().GetAllPeople().OfType<Student>().ToList();
            int unassigned = students.Count(s => s.IsActive && string.IsNullOrWhiteSpace(s.AcademicSupervisorId));
            var journey = new WorkspaceJourneyData { Title = L.T("Workspace.ProgrammeCoordination"), Context = L.T("Workspace.ProgrammeWideWorkQueuesCompletionIsA") };
            journey.Stages.Add(Stage(L.T("Workspace.Assignments"), unassigned > 0 ? "current" : "upcoming", unassigned + L.T("Workspace.WithoutASupervisor"), L.T("Workspace.CheckActiveStudentRecordsAndGroupAssignments"), L.T("Workspace.ManageAssignments"), "~/Pages/Coordinator/Groups.aspx", Fact(L.T("Workspace.ActiveProfilesWithoutAnAcademicSupervisor"), N(unassigned))));
            journey.Stages.Add(Stage(L.T("Workspace.TrainingOversight"), summary.ActivePlacements > 0 ? "current" : "upcoming", summary.ActivePlacements + L.T("Workspace.ActivePlacements"), L.T("Workspace.MonitorConfirmedTrainingAndExceptionsEachRecord"), L.T("Workspace.OpenPlacements"), "~/Pages/Coordinator/Placements.aspx", Fact(L.T("Workspace.ConfirmedOrActive"), N(summary.ActivePlacements)), Fact(L.T("Workspace.HoursAwaitingApproval"), N(summary.PendingHours)), Fact(L.T("Workspace.OverdueUngradedTasks"), N(summary.OverdueTasks))));
            journey.Stages.Add(Stage(L.T("Workspace.FinalEvaluations"), summary.CompanyFinals + summary.AcademicFinals > 0 ? "current" : "upcoming", (summary.CompanyFinals + summary.AcademicFinals) + L.T("Workspace.Submitted2"), L.T("Workspace.ReviewReceivedAssessmentsInTheAuthorizedCompletion"), L.T("Workspace.ReviewEvaluations"), "~/Pages/Coordinator/CompletionReview.aspx", Fact(L.T("Workspace.CompanyAssessments"), N(summary.CompanyFinals)), Fact(L.T("Workspace.AcademicAssessments"), N(summary.AcademicFinals))));
            journey.Stages.Add(Stage(L.T("Workspace.CompletionReview"), queue.Any(q => q.IsReady || q.IsReturned) ? "current" : "upcoming", queue.Count(q => q.IsReady) + L.T("Workspace.ReadyForReview2"), L.T("Workspace.ReviewTheActualRequirementsAndFinalResult"), L.T("Workspace.OpenCompletionQueue"), "~/Pages/Coordinator/CompletionReview.aspx", Fact(L.T("Workspace.BothEvaluationsReceivedNotApproved"), N(queue.Count(q => q.IsReady))), Fact(L.T("Workspace.ApprovedCompletions"), N(queue.Count(q => q.IsApproved))), Fact(L.T("Workspace.ReturnedForFollowUp"), N(queue.Count(q => q.IsReturned)))));
            return new WorkspaceCoordinatorData { Students = students, Summary = summary, Queue = queue, UnassignedStudents = unassigned, Journey = journey };
        }
    }
}
