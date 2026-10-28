using System;
using System.Collections.Generic;
using System.Linq;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Data
{
    // Read-only coordinator views. No monitoring action changes grades, hours or completion.
    public class CoordinatorMonitoringRepository
    {
        // Reads a collection, optionally filtered by one field. If Firebase has no
        // .indexOn rule for that field ("Index not defined"), it reads the whole
        // collection and filters here instead, so the page still loads.
        private List<T> Read<T>(string collection, string field = null, string value = null) where T : class
        {
            string json;
            bool filterHere = false;
            if (field == null) json = FirebaseContext.Get(collection);
            else
            {
                try { json = FirebaseContext.GetWhere(collection, field, value); }
                catch (FirebaseException ex)
                {
                    if (ex.Message.IndexOf("Index not defined", StringComparison.OrdinalIgnoreCase) < 0) throw;
                    json = FirebaseContext.Get(collection);
                    filterHere = true;
                }
            }
            var map = Json.Deserialize<Dictionary<string, Dictionary<string, object>>>(json);
            var result = new List<T>();
            if (map == null) return result;
            foreach (var pair in map)
            {
                if (pair.Value == null) continue;
                object fieldValue;
                if (filterHere && (!pair.Value.TryGetValue(field, out fieldValue) || Convert.ToString(fieldValue) != value)) continue;
                pair.Value["Id"] = pair.Key;
                result.Add(Json.Deserialize<T>(Json.Serialize(pair.Value)));
            }
            return result;
        }
        /// <summary>Speed: reads every collection the coordinator overviews use
        /// at the same time, so the many reads that follow come from the cache.</summary>
        public static void PrefetchProgrammeData()
        {
            FirebaseContext.Prefetch(
                FirebaseRead.Node(Constants.Paths.Users),
                FirebaseRead.Node(Constants.Paths.Companies),
                FirebaseRead.Node(Constants.Paths.Opportunities),
                FirebaseRead.Node(Constants.Paths.Placements),
                FirebaseRead.Node(Constants.Paths.Tasks),
                FirebaseRead.Node(Constants.Paths.Submissions),
                FirebaseRead.Node(Constants.Paths.TrainingHours),
                FirebaseRead.Node(Constants.Paths.CompanyEvaluations),
                FirebaseRead.Node(Constants.Paths.AcademicEvaluations),
                FirebaseRead.Node(Constants.Paths.TaskEvaluations),
                FirebaseRead.Node(Constants.Paths.Completions));
        }

        private static bool IsPlacement(Placement p)
        {
            return ApplicationRepository.IsValidKey(p.Id) && p.Id == p.StudentId
                && Enum.IsDefined(typeof(PlacementStatus), p.Status) && p.Status != PlacementStatus.Offered;
        }
        private List<PlacementOverview> BuildRows(List<Placement> placements, List<Student> students, List<TrainingHoursEntry> hours)
        {
            var profiles = students.ToDictionary(s => s.Id);
            return placements.Where(IsPlacement).Select(p =>
            {
                Student student;
                profiles.TryGetValue(p.StudentId, out student);
                var linked = hours.Where(h => h.PlacementId == p.Id && h.StudentId == p.StudentId && h.Hours > 0).ToList();
                return new PlacementOverview
                {
                    Placement = p, Student = student,
                    ApprovedHours = linked.Where(h => h.Status == HoursStatus.Approved).Sum(h => (long)h.Hours),
                    PendingHours = linked.Where(h => h.Status == HoursStatus.Reported).Sum(h => (long)h.Hours)
                };
            }).OrderByDescending(r => r.Placement.ConfirmedAt).ToList();
        }
        /// <summary>Some placements were saved without a company or opportunity
        /// name (their opportunity had none). Fill the blanks from the company and
        /// opportunity records so no row shows an empty company. Display only:
        /// nothing is written back to Firebase.</summary>
        private static void FillNames(IEnumerable<Placement> placements, List<Company> companies, List<Opportunity> opportunities)
        {
            var companyNames = new Dictionary<string, string>();
            foreach (var c in companies)
                if (c != null && c.Id != null && !string.IsNullOrWhiteSpace(c.Name)) companyNames[c.Id] = c.Name.Trim();
            var opportunityById = new Dictionary<string, Opportunity>();
            foreach (var o in opportunities)
                if (o != null && o.Id != null) opportunityById[o.Id] = o;

            foreach (var p in placements)
            {
                Opportunity opportunity;
                opportunityById.TryGetValue(p.OpportunityId ?? "", out opportunity);
                if (string.IsNullOrWhiteSpace(p.CompanyName))
                {
                    string name;
                    if (companyNames.TryGetValue(p.CompanyId ?? "", out name)) p.CompanyName = name;
                    else if (opportunity != null && !string.IsNullOrWhiteSpace(opportunity.CompanyName)) p.CompanyName = opportunity.CompanyName.Trim();
                }
                if (string.IsNullOrWhiteSpace(p.OpportunityTitle) && opportunity != null && !string.IsNullOrWhiteSpace(opportunity.Title))
                    p.OpportunityTitle = opportunity.Title.Trim();
            }
        }

        public List<PlacementOverview> LoadPlacements()
        {
            FirebaseContext.Prefetch(
                FirebaseRead.Node(Constants.Paths.Placements),
                FirebaseRead.Node(Constants.Paths.Users),
                FirebaseRead.Node(Constants.Paths.TrainingHours),
                FirebaseRead.Node(Constants.Paths.Companies),
                FirebaseRead.Node(Constants.Paths.Opportunities));
            var placements = new PlacementRepository().GetAll();
            FillNames(placements, new CompanyRepository().GetAll(), new OpportunityRepository().GetAll());
            return BuildRows(placements, new UserRepository().GetAllPeople().OfType<Student>().ToList(),
                new HoursRepository().GetAll());
        }
        public CoordinatorDashboardData LoadDashboard()
        {
            PrefetchProgrammeData();
            var students = new UserRepository().GetAllPeople().OfType<Student>().ToList();
            var companies = new CompanyRepository().GetAll();
            var opportunities = new OpportunityRepository().GetAll();
            var placements = new PlacementRepository().GetAll().Where(IsPlacement).ToList();
            FillNames(placements, companies, opportunities);
            var byId = placements.ToDictionary(p => p.Id);
            var tasks = new TaskRepository().GetAll().Where(t => byId.ContainsKey(t.PlacementId ?? "")
                && t.StudentId == byId[t.PlacementId].StudentId && t.CompanyId == byId[t.PlacementId].CompanyId).ToList();
            var taskIds = tasks.ToDictionary(t => t.Id);
            var submissions = Read<Submission>(Constants.Paths.Submissions).Where(s => taskIds.ContainsKey(s.TaskId ?? "")
                && s.PlacementId == taskIds[s.TaskId].PlacementId && s.StudentId == taskIds[s.TaskId].StudentId).ToDictionary(s => s.Id);
            var hours = new HoursRepository().GetAll();
            var companyFinals = Read<FinalCompanyEvaluation>(Constants.Paths.CompanyEvaluations).Where(e => e.IsSubmitted && byId.ContainsKey(e.PlacementId ?? "") && e.StudentId == byId[e.PlacementId].StudentId && e.CompanyId == byId[e.PlacementId].CompanyId).ToList();
            var academicFinals = Read<FinalAcademicEvaluation>(Constants.Paths.AcademicEvaluations).Where(e => e.IsSubmitted && byId.ContainsKey(e.PlacementId ?? "") && e.StudentId == byId[e.PlacementId].StudentId && e.AcademicSupervisorId == byId[e.PlacementId].AcademicSupervisorId).ToList();
            var taskEvaluations = Read<TaskEvaluation>(Constants.Paths.TaskEvaluations).Where(e => submissions.ContainsKey(e.SubmissionId ?? "") && e.StudentId == submissions[e.SubmissionId].StudentId
                && e.TaskId == submissions[e.SubmissionId].TaskId && e.PlacementId == submissions[e.SubmissionId].PlacementId).ToList();
            return new CoordinatorDashboardData
            {
                Students = students.Count, ActiveStudents = students.Count(s => s.IsActive),
                Companies = companies.Count, ActiveCompanies = companies.Count(c => c.IsActive),
                Opportunities = opportunities.Count, OpenOpportunities = opportunities.Count(o => o.IsOpenForApplications),
                Placements = placements.Count, ActivePlacements = placements.Count(p => p.Status == PlacementStatus.Confirmed || p.Status == PlacementStatus.Active),
                TaskEvaluations = taskEvaluations.Count, CompanyFinals = companyFinals.Count, AcademicFinals = academicFinals.Count,
                AwaitingCompletion = placements.Count(p => p.Status == PlacementStatus.AwaitingCompletion),
                OverdueTasks = tasks.Count(t => t.IsOverdue),
                OverdueTaskItems = tasks.Where(t => t.IsOverdue).OrderBy(t => t.Deadline).ToList(),
                PendingHours = hours.Where(h => byId.ContainsKey(h.PlacementId ?? "") && h.StudentId == byId[h.PlacementId].StudentId && h.Status == HoursStatus.Reported && h.Hours > 0).Sum(h => (long)h.Hours),
                Recent = BuildRows(placements, students, hours).Take(5).ToList()
            };
        }
        public PlacementProgressData LoadDetails(string id)
        {
            if (!ApplicationRepository.IsValidKey(id)) return null;
            // Speed: everything about this placement is read at the same time.
            FirebaseContext.Prefetch(
                FirebaseRead.Node(Constants.Paths.Placements + "/" + id),
                FirebaseRead.Where(Constants.Paths.Tasks, "PlacementId", id),
                FirebaseRead.Where(Constants.Paths.Submissions, "PlacementId", id),
                FirebaseRead.Where(Constants.Paths.TaskEvaluations, "PlacementId", id),
                FirebaseRead.Where(Constants.Paths.TrainingHours, "PlacementId", id),
                FirebaseRead.Where(Constants.Paths.CompanyEvaluations, "PlacementId", id),
                FirebaseRead.Where(Constants.Paths.AcademicEvaluations, "PlacementId", id),
                FirebaseRead.Where(Constants.Paths.Completions, "PlacementId", id),
                FirebaseRead.Where(Constants.Paths.AcademicComments, "PlacementId", id));
            var placement = new PlacementRepository().GetById(id);
            if (placement == null || !IsPlacement(placement)) return null;
            if (string.IsNullOrWhiteSpace(placement.CompanyName) || string.IsNullOrWhiteSpace(placement.OpportunityTitle))
            {
                var company = ApplicationRepository.IsValidKey(placement.CompanyId) ? new CompanyRepository().GetById(placement.CompanyId) : null;
                var opportunity = ApplicationRepository.IsValidKey(placement.OpportunityId) ? new OpportunityRepository().GetById(placement.OpportunityId) : null;
                FillNames(new[] { placement },
                    company == null ? new List<Company>() : new List<Company> { company },
                    opportunity == null ? new List<Opportunity>() : new List<Opportunity> { opportunity });
            }
            FirebaseContext.Prefetch(
                FirebaseRead.Node(Constants.Paths.Users + "/" + placement.StudentId),
                ApplicationRepository.IsValidKey(placement.CompanySupervisorId) ? FirebaseRead.Node(Constants.Paths.Users + "/" + placement.CompanySupervisorId) : null,
                ApplicationRepository.IsValidKey(placement.AcademicSupervisorId) ? FirebaseRead.Node(Constants.Paths.Users + "/" + placement.AcademicSupervisorId) : null);
            var users = new UserRepository();
            var student = users.GetStudent(placement.StudentId);
            var tasks = Read<InternshipTask>(Constants.Paths.Tasks, "PlacementId", id)
                .Where(t => t.StudentId == placement.StudentId && t.CompanyId == placement.CompanyId).OrderBy(t => t.Deadline <= 0 ? long.MaxValue : t.Deadline).ToList();
            var taskIds = new HashSet<string>(tasks.Select(t => t.Id));
            var submissions = Read<Submission>(Constants.Paths.Submissions, "PlacementId", id)
                .Where(s => s.StudentId == placement.StudentId && taskIds.Contains(s.TaskId)).OrderByDescending(s => s.SubmittedAt).ToList();
            var submissionMap = submissions.ToDictionary(s => s.Id);
            var evaluations = Read<TaskEvaluation>(Constants.Paths.TaskEvaluations, "PlacementId", id)
                .Where(e => e.StudentId == placement.StudentId && taskIds.Contains(e.TaskId) && submissionMap.ContainsKey(e.SubmissionId ?? "") && submissionMap[e.SubmissionId].TaskId == e.TaskId).OrderByDescending(e => e.EvaluatedAt).ToList();
            var hours = Read<TrainingHoursEntry>(Constants.Paths.TrainingHours, "PlacementId", id).Where(h => h.StudentId == placement.StudentId)
                // Plus the hours earned through accepted tasks (Services/TaskHoursCredit.cs).
                .Concat(Services.TaskHoursCredit.Build(tasks, submissions, evaluations))
                .OrderByDescending(h => h.WorkDate).ToList();
            var companyFinal = Read<FinalCompanyEvaluation>(Constants.Paths.CompanyEvaluations, "PlacementId", id)
                .Where(e => e.StudentId == placement.StudentId && e.CompanyId == placement.CompanyId)
                .OrderByDescending(e => e.IsSubmitted).ThenByDescending(e => e.SubmittedAt).ThenByDescending(e => e.CreatedAt).FirstOrDefault();
            var academicFinal = Read<FinalAcademicEvaluation>(Constants.Paths.AcademicEvaluations, "PlacementId", id)
                .Where(e => e.StudentId == placement.StudentId && e.AcademicSupervisorId == placement.AcademicSupervisorId)
                .OrderByDescending(e => e.IsSubmitted).ThenByDescending(e => e.SubmittedAt).ThenByDescending(e => e.CreatedAt).FirstOrDefault();
            var completion = Read<CompletionRecord>(Constants.Paths.Completions, "PlacementId", id)
                .Where(c => c.StudentId == placement.StudentId).OrderByDescending(c => c.ApprovedAt).ThenByDescending(c => c.CreatedAt).FirstOrDefault();
            return new PlacementProgressData
            {
                Overview = BuildRows(new List<Placement> { placement }, student == null ? new List<Student>() : new List<Student> { student }, hours)[0],
                Tasks = tasks, Submissions = submissions, Evaluations = evaluations, Hours = hours,
                CompanyFinal = companyFinal, AcademicFinal = academicFinal, Completion = completion,
                CompanySupervisorName = Name(placement.CompanySupervisorId, placement.CompanySupervisorName),
                AcademicSupervisorName = Name(placement.AcademicSupervisorId, L.T("Workspace.CoordinatorMonitoringRepository.NotAssigned")),
                Comments = Read<AcademicComment>(Constants.Paths.AcademicComments, "PlacementId", id).Where(c => c.StudentId == placement.StudentId).OrderByDescending(c => c.CreatedAt).ToList()
            };
        }
        /// <summary>Every placement with its final-evaluation and completion
        /// state, for the Final Completion Review queue (card A10).</summary>
        public List<CompletionQueueRow> LoadCompletionQueue()
        {
            FirebaseContext.Prefetch(
                FirebaseRead.Node(Constants.Paths.Placements),
                FirebaseRead.Node(Constants.Paths.Users),
                FirebaseRead.Node(Constants.Paths.TrainingHours),
                FirebaseRead.Node(Constants.Paths.CompanyEvaluations),
                FirebaseRead.Node(Constants.Paths.AcademicEvaluations),
                FirebaseRead.Node(Constants.Paths.Completions));
            var rows = LoadPlacements().Where(r => r.Placement.Status != PlacementStatus.Cancelled).ToList();
            // Same matching as LoadDetails: an evaluation only counts when it was
            // written by this placement's company / academic supervisor. Otherwise
            // the queue could say "Ready" while the review page says "Missing".
            var companyDone = new HashSet<string>(Read<FinalCompanyEvaluation>(Constants.Paths.CompanyEvaluations)
                .Where(e => e.IsSubmitted).Select(e => e.PlacementId + "|" + e.StudentId + "|" + e.CompanyId));
            var academicDone = new HashSet<string>(Read<FinalAcademicEvaluation>(Constants.Paths.AcademicEvaluations)
                .Where(e => e.IsSubmitted).Select(e => e.PlacementId + "|" + e.StudentId + "|" + e.AcademicSupervisorId));
            var completions = Read<CompletionRecord>(Constants.Paths.Completions);
            return rows.Select(r =>
            {
                string key = r.Placement.Id + "|" + r.Placement.StudentId;
                return new CompletionQueueRow
                {
                    Overview = r,
                    CompanySubmitted = companyDone.Contains(key + "|" + r.Placement.CompanyId),
                    AcademicSubmitted = academicDone.Contains(key + "|" + r.Placement.AcademicSupervisorId),
                    Completion = completions.Where(c => c.PlacementId == r.Placement.Id && c.StudentId == r.Placement.StudentId)
                        .OrderByDescending(c => c.ApprovedAt).ThenByDescending(c => c.CreatedAt).FirstOrDefault()
                };
            }).OrderBy(q => q.SortOrder).ThenBy(q => q.Overview.StudentName).ToList();
        }
        private string Name(string id, string fallback)
        {
            if (!ApplicationRepository.IsValidKey(id)) return fallback;
            var person = new UserRepository().GetPerson(id);
            return person == null ? fallback : person.FullName;
        }
    }
    public class PlacementOverview
    {
        public Placement Placement { get; set; }
        public Student Student { get; set; }
        public long ApprovedHours { get; set; }
        public long PendingHours { get; set; }
        public string StudentName { get { return Student == null ? Placement.StudentName : Student.FullName; } }
        public string StatusText { get { return Placement.Status == PlacementStatus.AwaitingCompletion ? L.T("Workspace.CoordinatorMonitoringRepository.AwaitingCompletion") : L.Value("PlacementStatus", Placement.Status); } }
        public string StudentNumber { get { return Student == null ? "—" : Student.StudentNumber; } }
        public string Major { get { return Student == null ? "—" : Student.Major; } }
        /// <summary>The hours target, never below 160 (see InternshipRules.RequiredHours).</summary>
        public int RequiredHours { get { return InternshipRules.RequiredHours(Placement.RequiredHours, Student == null ? 0 : Student.RequiredHours); } }
        public bool TrainingDone { get { return InternshipRules.TrainingDone(Placement, ApprovedHours, RequiredHours); } }
        public int HoursPercent { get { return (int)Math.Min(100, ApprovedHours * 100 / RequiredHours); } }
        public string HoursText { get { return ApprovedHours + " / " + RequiredHours + " " + L.T("Workspace.UnitH"); } }
    }
    public class CompletionQueueRow
    {
        public PlacementOverview Overview;
        public bool CompanySubmitted, AcademicSubmitted;
        public CompletionRecord Completion;
        public bool IsApproved { get { return Completion != null && Completion.Status == CompletionStatus.Approved; } }
        public bool IsReturned { get { return Completion != null && Completion.Status == CompletionStatus.Rejected; } }
        public bool IsReady { get { return !IsApproved && CompanySubmitted && AcademicSubmitted; } }
        public string StageText
        {
            get
            {
                if (IsApproved) return L.T("Workspace.CoordinatorMonitoringRepository.Approved");
                if (IsReturned) return L.T("Workspace.CoordinatorMonitoringRepository.Returned");
                if (IsReady) return L.T("Workspace.CoordinatorMonitoringRepository.ReadyForReview");
                if (!CompanySubmitted) return L.T("Workspace.CoordinatorMonitoringRepository.AwaitingCompanyEvaluation");
                return L.T("Workspace.CoordinatorMonitoringRepository.AwaitingAcademicEvaluation");
            }
        }
        // Ready first, then returned, then waiting for evaluations, approved last.
        public int SortOrder { get { return IsApproved ? 3 : IsReady ? (IsReturned ? 1 : 0) : 2; } }

        // ---- Final Completion Review queue (added; the members above are unchanged) ----
        public const string ReviewInProgress = "in-progress";
        public const string ReviewAwaitingEvaluations = "awaiting";
        public const string ReviewReady = "ready";
        public const string ReviewCorrections = "corrections";
        public const string ReviewApproved = "approved";
        public const string ReviewRejected = "rejected";

        /// <summary>UIMS review status of the row. These are application
        /// labels, not the internal status names of any GJU system.</summary>
        public string ReviewStatus
        {
            get
            {
                if (IsApproved) return ReviewApproved;
                if (Completion != null && Completion.IsRejectedFinal) return ReviewRejected;
                if (Completion != null && Completion.NeedsCorrections) return ReviewCorrections;
                bool trainingDone = Overview.TrainingDone;
                // "Ready" means the coordinator can actually approve the training
                // part: both evaluations AND 160 hours (or 20 weeks abroad).
                if (CompanySubmitted && AcademicSubmitted) return trainingDone ? ReviewReady : ReviewInProgress;
                if (CompanySubmitted || AcademicSubmitted || trainingDone
                    || Overview.Placement.Status == PlacementStatus.AwaitingCompletion) return ReviewAwaitingEvaluations;
                return ReviewInProgress;
            }
        }

        /// <summary>Queue order: needs a decision first, finished records last.</summary>
        public int ReviewOrder
        {
            get
            {
                switch (ReviewStatus)
                {
                    case ReviewReady: return 0;
                    case ReviewCorrections: return 1;
                    case ReviewAwaitingEvaluations: return 2;
                    case ReviewInProgress: return 3;
                    case ReviewApproved: return 4;
                    default: return 5;
                }
            }
        }
    }
    public class CoordinatorDashboardData
    {
        public int Students, ActiveStudents, Companies, ActiveCompanies, Opportunities, OpenOpportunities,
            Placements, ActivePlacements, TaskEvaluations, CompanyFinals, AcademicFinals, AwaitingCompletion, OverdueTasks;
        public long PendingHours;
        public List<PlacementOverview> Recent;
        public List<InternshipTask> OverdueTaskItems;
    }
    public class PlacementProgressData
    {
        public PlacementOverview Overview;
        public List<InternshipTask> Tasks;
        public List<Submission> Submissions;
        public List<TaskEvaluation> Evaluations;
        public List<TrainingHoursEntry> Hours;
        public List<AcademicComment> Comments;
        public FinalCompanyEvaluation CompanyFinal;
        public FinalAcademicEvaluation AcademicFinal;
        public CompletionRecord Completion;
        public string CompanySupervisorName, AcademicSupervisorName;
    }
}
