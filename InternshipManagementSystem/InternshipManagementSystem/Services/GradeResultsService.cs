using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Services
{
    // The preview and download use the same scoped data and grade rules.
    public static class GradeResultsService
    {
        public static bool CanView(Person viewer, Placement placement)
        {
            if (viewer == null || !viewer.IsActive || string.IsNullOrEmpty(viewer.Id) ||
                placement == null || string.IsNullOrEmpty(placement.Id) ||
                string.IsNullOrEmpty(placement.StudentId) || placement.Status == PlacementStatus.Cancelled ||
                placement.Status == PlacementStatus.Offered) return false;
            if (viewer.Role == UserRole.Coordinator) return true;
            if (viewer.Role == UserRole.AcademicSupervisor)
                return placement.AcademicSupervisorId == viewer.Id;
            CompanySupervisor company = viewer as CompanySupervisor;
            return viewer.Role == UserRole.CompanySupervisor && company != null &&
                !string.IsNullOrEmpty(company.CompanyId) && placement.CompanyId == company.CompanyId &&
                placement.CompanySupervisorId == viewer.Id;
        }

        public static List<GradeResultRow> Load(Person viewer)
        {
            if (viewer == null || !viewer.IsActive || string.IsNullOrEmpty(viewer.Id))
                throw new UnauthorizedAccessException();
            PlacementRepository placements = new PlacementRepository();
            List<Placement> scoped;
            if (viewer.Role == UserRole.Coordinator) scoped = placements.GetAll();
            else if (viewer.Role == UserRole.AcademicSupervisor)
                scoped = placements.GetByAcademicSupervisor(viewer.Id);
            else if (viewer.Role == UserRole.CompanySupervisor && viewer is CompanySupervisor &&
                     !string.IsNullOrEmpty(((CompanySupervisor)viewer).CompanyId))
                scoped = placements.GetByCompany(((CompanySupervisor)viewer).CompanyId);
            else throw new UnauthorizedAccessException();

            EvaluationRepository evaluations = new EvaluationRepository();
            List<GradeResultRow> rows = new List<GradeResultRow>();
            foreach (Placement placement in scoped.Where(p => CanView(viewer, p)))
            {
                // Never query the confidential academic evaluation for a company user.
                FinalAcademicEvaluation academic = viewer.Role == UserRole.CompanySupervisor ? null :
                    evaluations.GetAcademicFinalForPlacement(placement.Id);
                rows.Add(CreateRow(viewer, placement, new UserRepository().GetStudent(placement.StudentId),
                    new TaskRepository().GetByPlacement(placement.Id),
                    evaluations.GetTaskEvaluationsForPlacement(placement.Id),
                    new SubmissionRepository().GetByPlacement(placement.Id),
                    evaluations.GetCompanyFinalForPlacement(placement.Id), academic,
                    new CompletionRepository().GetByPlacement(placement.Id),
                    new HoursRepository().GetByPlacement(placement.Id)));
            }
            return rows.OrderBy(r => r.StudentName, StringComparer.CurrentCultureIgnoreCase)
                .ThenBy(r => r.StudentNumber, StringComparer.Ordinal).ToList();
        }

        public static GradeResultRow CreateRow(Person viewer, Placement placement, Student student,
            List<InternshipTask> tasks, List<TaskEvaluation> evaluations, List<Submission> submissions,
            FinalCompanyEvaluation company, FinalAcademicEvaluation academic, CompletionRecord completion,
            List<TrainingHoursEntry> hours)
        {
            if (!CanView(viewer, placement)) throw new UnauthorizedAccessException();
            if (student != null && student.Id != placement.StudentId) throw new InvalidOperationException("Student mismatch.");
            tasks = tasks.Where(t => t != null && t.PlacementId == placement.Id &&
                t.StudentId == placement.StudentId && !string.IsNullOrEmpty(t.Id)).ToList();
            evaluations = evaluations.Where(e => e != null && e.PlacementId == placement.Id &&
                e.StudentId == placement.StudentId).ToList();
            submissions = submissions.Where(s => s != null && s.PlacementId == placement.Id &&
                s.StudentId == placement.StudentId).ToList();
            List<TaskEvaluation> current = new List<TaskEvaluation>();
            foreach (InternshipTask task in tasks)
            {
                TaskEvaluation latest = evaluations.Where(e => e.TaskId == task.Id)
                    .OrderByDescending(e => e.EvaluatedAt).FirstOrDefault();
                Submission submitted = submissions.Where(s => s.TaskId == task.Id)
                    .OrderByDescending(s => s.SubmittedAt).FirstOrDefault();
                if (latest != null && !latest.RevisionRequested && ValidScore(latest.TotalScore, latest.MaxScore) &&
                    submitted != null && latest.EvaluatedAt >= submitted.SubmittedAt) current.Add(latest);
            }
            GradeResultRow row = new GradeResultRow
            {
                StudentName = student == null || string.IsNullOrWhiteSpace(student.FullName)
                    ? placement.StudentName : student.FullName,
                StudentNumber = student == null ? "" : student.StudentNumber,
                CompanyName = placement.CompanyName,
                PlacementStatus = placement.Status.ToString(),
                AssignedTasks = tasks.Count,
                GradedTasks = current.Count,
                TaskPercent = tasks.Count > 0 && current.Count == tasks.Count
                    ? (double?)GradingService.TaskComponentPercent(tasks, current) : null,
                ApprovedHours = hours.Where(h => h != null && h.PlacementId == placement.Id &&
                    h.StudentId == placement.StudentId && h.Status == HoursStatus.Approved)
                    .Sum(h => Math.Max(0, h.Hours)),
                ReviewStatus = "Not reviewed",
                Result = "Pending"
            };
            if (row.TaskPercent.HasValue && !ValidScore(row.TaskPercent.Value, 100)) row.TaskPercent = null;
            if (company != null && company.PlacementId == placement.Id && company.StudentId == placement.StudentId &&
                company.CompanyId == placement.CompanyId && company.IsSubmitted &&
                (viewer.Role != UserRole.CompanySupervisor || company.SupervisorId == viewer.Id) &&
                ValidScore(company.TotalScore, company.MaxScore))
                row.CompanyPercent = company.TotalScore / company.MaxScore * 100;
            if (viewer.Role != UserRole.CompanySupervisor && academic != null && academic.IsSubmitted &&
                academic.PlacementId == placement.Id && academic.StudentId == placement.StudentId &&
                academic.AcademicSupervisorId == placement.AcademicSupervisorId &&
                ValidScore(academic.TotalScore, academic.MaxScore))
                row.AcademicPercent = academic.TotalScore / academic.MaxScore * 100;

            if (completion != null && completion.PlacementId == placement.Id && completion.StudentId == placement.StudentId)
            {
                row.ReviewStatus = ReviewLabel(completion.Status);
                if (completion.Status == CompletionStatus.Approved &&
                    (completion.Result == "Pass" || completion.Result == "Fail") && ValidScore(completion.FinalScore, 100))
                {
                    row.FinalPercent = completion.FinalScore;
                    row.Result = completion.Result;
                    // Released grades are the saved decision, even if later evaluations change.
                    row.TaskPercent = ValidScore(completion.TaskScorePercent, 100) ? (double?)completion.TaskScorePercent : null;
                    row.CompanyPercent = ValidScore(completion.CompanyScorePercent, 100) ? (double?)completion.CompanyScorePercent : null;
                    if (viewer.Role != UserRole.CompanySupervisor)
                        row.AcademicPercent = ValidScore(completion.AcademicScorePercent, 100) ? (double?)completion.AcademicScorePercent : null;
                    row.ApprovedHours = completion.ApprovedHours;
                }
            }
            return row;
        }

        private static string ReviewLabel(CompletionStatus status)
        {
            switch (status)
            {
                case CompletionStatus.AwaitingCompanyEvaluation: return "Awaiting company evaluation";
                case CompletionStatus.AwaitingAcademicEvaluation: return "Awaiting academic evaluation";
                case CompletionStatus.UnderCoordinatorReview: return "Under coordinator review";
                case CompletionStatus.Approved: return "Approved";
                case CompletionStatus.Rejected: return "Rejected";
                default: return "Not ready";
            }
        }

        private static bool ValidScore(double score, double maximum)
        {
            return !double.IsNaN(score) && !double.IsInfinity(score) &&
                !double.IsNaN(maximum) && !double.IsInfinity(maximum) &&
                maximum > 0 && score >= 0 && score <= maximum;
        }
    }

    public sealed class GradeResultRow
    {
        public string StudentName { get; set; }
        public string StudentNumber { get; set; }
        public string CompanyName { get; set; }
        public string PlacementStatus { get; set; }
        public int AssignedTasks { get; set; }
        public int GradedTasks { get; set; }
        public int ApprovedHours { get; set; }
        public double? TaskPercent { get; set; }
        public double? CompanyPercent { get; set; }
        public double? AcademicPercent { get; set; }
        public double? FinalPercent { get; set; }
        public string ReviewStatus { get; set; }
        public string Result { get; set; }
        public string TaskGrade { get { return GradeLabel(TaskPercent); } }
        public string CompanyGrade { get { return GradeLabel(CompanyPercent); } }
        public string AcademicGrade { get { return GradeLabel(AcademicPercent); } }
        public string FinalGrade { get { return GradeLabel(FinalPercent); } }
        private static string GradeLabel(double? value)
        { return value.HasValue ? value.Value.ToString("0.##", CultureInfo.InvariantCulture) + "%" : "Pending"; }
    }
}
