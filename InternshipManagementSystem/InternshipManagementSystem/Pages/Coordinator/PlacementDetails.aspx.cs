using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text.RegularExpressions;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Pages.CoordinatorArea
{
    public partial class PlacementDetails : InternshipManagementSystem.Security.CoordinatorPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;
            string studentId = Request.QueryString["id"];
            if (string.IsNullOrEmpty(studentId) || !Regex.IsMatch(studentId, @"\A[A-Za-z0-9_-]{1,128}\z"))
            {
                ShowMissing(L.T("Coordinator.PlacementDetails.ChooseAPlacementFromPlacementsProgress"));
                return;
            }
            try { LoadDetails(studentId); }
            catch (FirebaseException) { ShowMissing(L.T("Coordinator.PlacementDetails.CouldNotLoadThisPlacementPlease")); }
        }

        private void LoadDetails(string studentId)
        {
            Placement placement = new PlacementRepository().GetById(studentId);
            if (placement == null || placement.StudentId != studentId)
            {
                ShowMissing(L.T("Coordinator.PlacementDetails.PlacementNotFound"));
                return;
            }
            Student student = new UserRepository().GetStudent(studentId);
            pnlMissing.Visible = false;
            pnlDetails.Visible = true;
            litStudent.Text = Encode(student == null ? placement.StudentName : student.FullName);
            litStudentNumber.Text = Encode(student == null ? "—" : student.StudentNumber);
            litProgram.Text = Encode(student == null ? "—" : student.Major);
            litCompany.Text = Encode(placement.CompanyName);
            litOpportunity.Text = Encode(placement.OpportunityTitle);
            litCompanySupervisor.Text = Encode(placement.CompanySupervisorName);
            litStatus.Text = Encode(placement.Status.ToString());
            litPeriod.Text = Time.DisplayDate(placement.StartDate) + " to " + Time.DisplayDate(placement.EndDate);
            AcademicSupervisor academic = string.IsNullOrEmpty(placement.AcademicSupervisorId) ? null :
                new UserRepository().GetAcademicSupervisor(placement.AcademicSupervisorId);
            litAcademicSupervisor.Text = Encode(academic == null ? L.T("Coordinator.PlacementDetails.NotAssigned") : academic.FullName);
            lnkFinalReview.NavigateUrl = ResolveUrl("~/Pages/Coordinator/CompletionReview.aspx?id=" +
                Server.UrlEncode(studentId));

            List<InternshipTask> tasks = new TaskRepository().GetByPlacement(placement.Id)
                .Where(t => t.StudentId == studentId && !string.IsNullOrEmpty(t.Id)).ToList();
            HashSet<string> taskIds = new HashSet<string>(tasks.Select(t => t.Id), StringComparer.Ordinal);
            List<Submission> submissions = new SubmissionRepository().GetByPlacement(placement.Id)
                .Where(s => s.StudentId == studentId && taskIds.Contains(s.TaskId)).ToList();
            List<TaskEvaluation> evaluations = new EvaluationRepository().GetTaskEvaluationsForPlacement(placement.Id)
                .Where(e => e.StudentId == studentId && taskIds.Contains(e.TaskId)).ToList();
            List<TaskRow> taskRows = tasks.OrderBy(t => t.Deadline == 0 ? long.MaxValue : t.Deadline)
                .Select(t => BuildTaskRow(t, submissions, evaluations)).ToList();
            rptTasks.DataSource = taskRows;
            rptTasks.DataBind();
            pnlNoTasks.Visible = taskRows.Count == 0;
            litTaskCount.Text = taskRows.Count.ToString(CultureInfo.InvariantCulture);
            litGradedCount.Text = taskRows.Count(t => t.Graded).ToString(CultureInfo.InvariantCulture);
            litSubmissionCount.Text = submissions.Count.ToString(CultureInfo.InvariantCulture);

            List<TrainingHoursEntry> hours = new HoursRepository().GetByPlacement(placement.Id)
                .Where(h => h.StudentId == studentId).ToList();
            int approved = hours.Where(h => h.Status == HoursStatus.Approved).Sum(h => Math.Max(0, h.Hours));
            int pending = hours.Where(h => h.Status == HoursStatus.Reported).Sum(h => Math.Max(0, h.Hours));
            int required = Math.Max(Constants.DefaultRequiredHours,
                placement.RequiredHours > 0 ? placement.RequiredHours : student == null ? 0 : student.RequiredHours);
            litHours.Text = approved.ToString(CultureInfo.InvariantCulture) + " / " +
                            required.ToString(CultureInfo.InvariantCulture);
            litPendingHours.Text = pending.ToString(CultureInfo.InvariantCulture);
            int percent = required > 0 ? (int)Math.Min(100, approved * 100L / required) : 0;
            hoursProgress.Attributes["aria-valuenow"] = percent.ToString(CultureInfo.InvariantCulture);
            hoursBar.Style["width"] = percent.ToString(CultureInfo.InvariantCulture) + "%";
            litHoursPercent.Text = percent.ToString(CultureInfo.InvariantCulture) + "%";
            rptHours.DataSource = hours.OrderByDescending(h => h.WorkDate)
                .Select(h => new HoursRow
                {
                    Date = Time.DisplayDate(h.WorkDate > 0 ? h.WorkDate : h.ReportedAt),
                    Description = string.IsNullOrWhiteSpace(h.Description) ? L.T("Coordinator.PlacementDetails.TrainingEntry") : h.Description,
                    Hours = h.Hours.ToString(CultureInfo.InvariantCulture),
                    Status = h.Status.ToString()
                }).ToList();
            rptHours.DataBind();
            pnlNoHours.Visible = hours.Count == 0;

            EvaluationRepository finalEvaluations = new EvaluationRepository();
            FinalCompanyEvaluation company = finalEvaluations.GetCompanyFinalForPlacement(placement.Id);
            FinalAcademicEvaluation academicFinal = finalEvaluations.GetAcademicFinalForPlacement(placement.Id);
            litCompanyEvaluation.Text = company != null && company.IsSubmitted ? "Submitted" : L.T("Coordinator.PlacementDetails.Pending");
            litAcademicEvaluation.Text = academicFinal != null && academicFinal.IsSubmitted ? "Submitted" : L.T("Coordinator.PlacementDetails.Pending");
            CompletionRecord completion = new CompletionRepository().GetByPlacement(placement.Id);
            litCompletion.Text = completion == null ? L.T("Coordinator.PlacementDetails.NotReviewed") :
                completion.Status == CompletionStatus.Approved ? L.T("Coordinator.PlacementDetails.ApprovedPass") :
                completion.Status == CompletionStatus.Rejected ?
                    (completion.Result == "Fail" ? L.T("Coordinator.PlacementDetails.ReviewedFail") : L.T("Coordinator.PlacementDetails.Rejected")) : L.T("Coordinator.PlacementDetails.AwaitingReview");
        }

        private static TaskRow BuildTaskRow(InternshipTask task, List<Submission> submissions,
                                            List<TaskEvaluation> evaluations)
        {
            List<Submission> attempts = submissions.Where(s => s.TaskId == task.Id).ToList();
            TaskEvaluation latest = evaluations.Where(e => e.TaskId == task.Id)
                .OrderByDescending(e => e.EvaluatedAt).FirstOrDefault();
            Submission lastAttempt = attempts.OrderByDescending(s => s.SubmittedAt).FirstOrDefault();
            bool graded = latest != null && !latest.RevisionRequested && latest.MaxScore > 0 &&
                          lastAttempt != null && latest.EvaluatedAt >= lastAttempt.SubmittedAt;
            return new TaskRow
            {
                Title = string.IsNullOrWhiteSpace(task.Title) ? L.T("Coordinator.PlacementDetails.UntitledTask") : task.Title,
                Deadline = Time.DisplayDate(task.Deadline),
                Status = latest != null && latest.RevisionRequested &&
                         (lastAttempt == null || latest.EvaluatedAt >= lastAttempt.SubmittedAt)
                    ? L.T("Coordinator.PlacementDetails.RevisionRequested") : graded ? "Graded" : task.Status.ToString(),
                Attempts = attempts.Count.ToString(CultureInfo.InvariantCulture),
                Grade = graded ? latest.TotalScore.ToString("0.##", CultureInfo.InvariantCulture) + " / " +
                    latest.MaxScore.ToString("0.##", CultureInfo.InvariantCulture) : "—",
                Feedback = latest == null ? L.T("Coordinator.PlacementDetails.NoFeedbackYet") :
                    latest.RevisionRequested ? First(latest.RevisionInstructions,
                        First(latest.Feedback, L.T("Coordinator.PlacementDetails.RevisionRequested"))) :
                    First(latest.Feedback, L.T("Coordinator.PlacementDetails.NoWrittenFeedback")),
                Graded = graded
            };
        }

        private void ShowMissing(string message)
        {
            pnlMissing.Visible = true;
            pnlDetails.Visible = false;
            litMissing.Text = Encode(message);
        }

        private string Encode(string value) { return Server.HtmlEncode(value ?? "—"); }
        private static string First(string value, string fallback)
        { return string.IsNullOrWhiteSpace(value) ? fallback : value; }

        public sealed class TaskRow
        {
            public string Title { get; set; }
            public string Deadline { get; set; }
            public string Status { get; set; }
            public string Attempts { get; set; }
            public string Grade { get; set; }
            public string Feedback { get; set; }
            public bool Graded { get; set; }
        }

        public sealed class HoursRow
        {
            public string Date { get; set; }
            public string Description { get; set; }
            public string Hours { get; set; }
            public string Status { get; set; }
        }
    }
}
