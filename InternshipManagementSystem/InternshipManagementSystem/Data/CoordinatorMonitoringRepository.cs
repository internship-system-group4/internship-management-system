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
        public List<PlacementOverview> LoadPlacements()
        {
            return BuildRows(new PlacementRepository().GetAll(), new UserRepository().GetAllPeople().OfType<Student>().ToList(),
                new HoursRepository().GetAll());
        }
        public CoordinatorDashboardData LoadDashboard()
        {
            var students = new UserRepository().GetAllPeople().OfType<Student>().ToList();
            var companies = new CompanyRepository().GetAll();
            var opportunities = new OpportunityRepository().GetAll();
            var placements = new PlacementRepository().GetAll().Where(IsPlacement).ToList();
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
                PendingHours = hours.Where(h => byId.ContainsKey(h.PlacementId ?? "") && h.StudentId == byId[h.PlacementId].StudentId && h.Status == HoursStatus.Reported && h.Hours > 0).Sum(h => (long)h.Hours),
                Recent = BuildRows(placements, students, hours).Take(5).ToList()
            };
        }
        public PlacementProgressData LoadDetails(string id)
        {
            if (!ApplicationRepository.IsValidKey(id)) return null;
            var placement = new PlacementRepository().GetById(id);
            if (placement == null || !IsPlacement(placement)) return null;
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
            var hours = Read<TrainingHoursEntry>(Constants.Paths.TrainingHours, "PlacementId", id).Where(h => h.StudentId == placement.StudentId).OrderByDescending(h => h.WorkDate).ToList();
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
                AcademicSupervisorName = Name(placement.AcademicSupervisorId, "Not assigned"),
                Comments = Read<AcademicComment>(Constants.Paths.AcademicComments, "PlacementId", id).Where(c => c.StudentId == placement.StudentId).OrderByDescending(c => c.CreatedAt).ToList()
            };
        }
        /// <summary>Every placement with its final-evaluation and completion
        /// state, for the Final Completion Review queue (card A10).</summary>
        public List<CompletionQueueRow> LoadCompletionQueue()
        {
            var rows = LoadPlacements().Where(r => r.Placement.Status != PlacementStatus.Cancelled).ToList();
            var companyDone = new HashSet<string>(Read<FinalCompanyEvaluation>(Constants.Paths.CompanyEvaluations)
                .Where(e => e.IsSubmitted).Select(e => e.PlacementId + "|" + e.StudentId));
            var academicDone = new HashSet<string>(Read<FinalAcademicEvaluation>(Constants.Paths.AcademicEvaluations)
                .Where(e => e.IsSubmitted).Select(e => e.PlacementId + "|" + e.StudentId));
            var completions = Read<CompletionRecord>(Constants.Paths.Completions);
            return rows.Select(r =>
            {
                string key = r.Placement.Id + "|" + r.Placement.StudentId;
                return new CompletionQueueRow
                {
                    Overview = r,
                    CompanySubmitted = companyDone.Contains(key),
                    AcademicSubmitted = academicDone.Contains(key),
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
        public string StatusText { get { return Placement.Status == PlacementStatus.AwaitingCompletion ? "Awaiting completion" : Placement.Status.ToString(); } }
        public string StudentNumber { get { return Student == null ? "—" : Student.StudentNumber; } }
        public string Major { get { return Student == null ? "—" : Student.Major; } }
        public int HoursPercent { get { return Placement.RequiredHours <= 0 ? 0 : (int)Math.Min(100, ApprovedHours * 100 / Placement.RequiredHours); } }
        public string HoursText { get { return Placement.RequiredHours > 0 ? ApprovedHours + " / " + Placement.RequiredHours + " h" : ApprovedHours + " h · requirement not configured"; } }
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
                if (IsApproved) return "Approved";
                if (IsReturned) return "Returned";
                if (IsReady) return "Ready for review";
                if (!CompanySubmitted) return "Awaiting company evaluation";
                return "Awaiting academic evaluation";
            }
        }
        // Ready first, then returned, then waiting for evaluations, approved last.
        public int SortOrder { get { return IsApproved ? 3 : IsReady ? (IsReturned ? 1 : 0) : 2; } }
    }
    public class CoordinatorDashboardData
    {
        public int Students, ActiveStudents, Companies, ActiveCompanies, Opportunities, OpenOpportunities,
            Placements, ActivePlacements, TaskEvaluations, CompanyFinals, AcademicFinals, AwaitingCompletion, OverdueTasks;
        public long PendingHours;
        public List<PlacementOverview> Recent;
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
