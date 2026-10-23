// =============================================================================
//  My Progress & Evaluation
//  Owner : Ahmad
//  Cards : A15, A16
//
//  Task grades, supervisor feedback, submission and revision history, APPROVED
//  training hours and overall progress - plus the final result and report
//  download once the coordinator approves.
//
//  Confidentiality: the two final evaluation forms (company and academic) are
//  never read here. Only TaskEvaluation records and the CompletionRecord's
//  final result are shown, and the result only after coordinator approval.
//
//  Namespace note: these page namespaces end in "Area" on purpose. A namespace
//  called ...Pages.Student would hide the Student model class and every file in
//  the folder would fail to compile with "Student is a namespace but is used
//  like a type". Keep the suffix.
// =============================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Services;

namespace InternshipManagementSystem.Pages.StudentArea
{
    public partial class Progress : InternshipManagementSystem.Security.StudentPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            try
            {
                LoadPage();
            }
            catch (FirebaseException ex)
            {
                System.Diagnostics.Trace.TraceError("Progress page failed: " + ex.Message);
                pnlError.Visible = true;
                pnlContent.Visible = false;
                // Show the real Firebase error only when running on this machine.
                if (Request.IsLocal) litErrorDetail.Text = ex.Message;
            }

            if (_problems.Count > 0)
            {
                pnlWarning.Visible = true;
                rptProblems.DataSource = _problems;
                rptProblems.DataBind();
            }
        }

        // Sections that could not be loaded; the rest of the page still shows.
        private readonly List<string> _problems = new List<string>();

        /// <summary>
        /// Runs a filtered Firebase query. If the database has no .indexOn rule
        /// for that field ("Index not defined"), reads the whole collection and
        /// filters it here instead. Any other failure is recorded and an empty
        /// list is returned so one section cannot break the whole page.
        /// </summary>
        private List<T> LoadSafely<T>(string section, Func<List<T>> query,
            Func<List<T>> readAll, Func<T, bool> isMine)
        {
            try
            {
                return query();
            }
            catch (FirebaseException ex)
            {
                if (ex.Message.IndexOf("Index not defined", StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    System.Diagnostics.Trace.TraceWarning("Missing Firebase index for " + section + "; filtering in code.");
                    try
                    {
                        return readAll().Where(isMine).ToList();
                    }
                    catch (FirebaseException fallbackError)
                    {
                        ex = fallbackError;
                    }
                }

                System.Diagnostics.Trace.TraceError("Progress page could not load " + section + ": " + ex.Message);
                _problems.Add(Request.IsLocal ? section + " — " + ex.Message : section);
                return new List<T>();
            }
        }

        private void LoadPage()
        {
            Student student = CurrentStudent;

            Placement placement = new PlacementRepository().GetById(student.Id);
            if (placement == null || placement.StudentId != student.Id)
            {
                pnlNoPlacement.Visible = true;
                pnlContent.Visible = false;
                return;
            }

            string id = student.Id;

            TaskRepository taskRepo = new TaskRepository();
            List<InternshipTask> tasks = LoadSafely("Tasks",
                    () => taskRepo.GetByStudent(id), taskRepo.GetAll, t => t.StudentId == id)
                .Where(t => t.PlacementId == placement.Id)
                .ToList();

            // Match evaluations by the student's own task IDs.
            HashSet<string> taskIds = new HashSet<string>(tasks.Where(t => t.Id != null).Select(t => t.Id));
            EvaluationRepository evaluationRepo = new EvaluationRepository();
            List<TaskEvaluation> evaluations = LoadSafely(L.T("Student.Progress.TaskEvaluations"),
                    () => evaluationRepo.GetTaskEvaluationsForStudent(id),
                    evaluationRepo.GetAllTaskEvaluations, ev => ev.StudentId == id)
                .Where(ev => ev.TaskId != null && taskIds.Contains(ev.TaskId))
                .ToList();

            SubmissionRepository submissionRepo = new SubmissionRepository();
            List<Submission> submissions = LoadSafely("Submissions",
                    () => submissionRepo.GetWhere("StudentId", id), submissionRepo.GetAll, s => s.StudentId == id)
                .Where(s => s.PlacementId == placement.Id)
                .ToList();

            HoursRepository hoursRepo = new HoursRepository();
            List<TrainingHoursEntry> hours = LoadSafely(L.T("Student.Progress.TrainingHours2"),
                    () => hoursRepo.GetByStudent(id), hoursRepo.GetAll, h => h.StudentId == id)
                .Where(h => h.PlacementId == placement.Id)
                .ToList();

            CompletionRepository completionRepo = new CompletionRepository();
            CompletionRecord completion = LoadSafely(L.T("Student.Progress.CompletionStatus"),
                    () => completionRepo.GetWhere("StudentId", id), completionRepo.GetAll, c => c.StudentId == id)
                .FirstOrDefault(c => c.PlacementId == placement.Id);

            ShowInternship(placement);
            List<TaskEvaluation> latestGrades = ShowTasks(tasks, evaluations, submissions);
            ShowAttempts(tasks, evaluations, submissions);
            int approvedHours = ShowHours(placement, hours);
            ShowSummary(placement, tasks, latestGrades, approvedHours);
            ShowCompletion(completion);
        }

        // ---- internship details -------------------------------------------
        private void ShowInternship(Placement placement)
        {
            litOpportunity.Text = TextOrDash(placement.OpportunityTitle);
            litCompany.Text = TextOrDash(placement.CompanyName);
            litSupervisor.Text = TextOrDash(placement.CompanySupervisorName);
            litDates.Text = Time.DisplayDate(placement.StartDate) + " to " + Time.DisplayDate(placement.EndDate);
            litPlacementStatus.Text = L.Value("PlacementStatus", placement.Status);
        }

        // ---- per-task grades and feedback ---------------------------------
        /// <summary>Fills the task table and returns the latest real grade of
        /// each task (revision requests are not grades).</summary>
        private List<TaskEvaluation> ShowTasks(List<InternshipTask> tasks,
            List<TaskEvaluation> evaluations, List<Submission> submissions)
        {
            List<TaskEvaluation> latestGrades = new List<TaskEvaluation>();
            List<TaskRow> rows = new List<TaskRow>();

            foreach (InternshipTask task in tasks.OrderBy(t => t.Deadline))
            {
                List<TaskEvaluation> taskEvaluations = evaluations
                    .Where(ev => ev.TaskId == task.Id)
                    .OrderByDescending(ev => ev.EvaluatedAt)
                    .ToList();

                TaskEvaluation latest = taskEvaluations.FirstOrDefault();
                TaskEvaluation latestGrade = taskEvaluations.FirstOrDefault(ev => !ev.RevisionRequested);
                if (latestGrade != null) latestGrades.Add(latestGrade);

                TaskRow row = new TaskRow();
                row.Title = TextOrDash(task.Title);
                row.Deadline = Time.DisplayDate(task.Deadline);
                row.Status = StatusText(task.Status);
                row.StatusCss = StatusCss(task.Status);
                row.IsOverdue = task.IsOverdue;
                row.Attempts = submissions.Count(s => s.TaskId == task.Id);

                if (latestGrade != null)
                {
                    double max = latestGrade.MaxScore > 0 ? latestGrade.MaxScore : task.MaxScore;
                    row.Grade = latestGrade.TotalScore.ToString("0.##") + " / " + max.ToString("0.##");
                    row.Criteria = CriteriaText(latestGrade.Components);
                }
                else
                {
                    row.Grade = L.T("Student.Progress.NotGradedYet");
                    row.Criteria = "";
                }

                // Show the newest supervisor message: revision instructions win
                // when the latest action was a revision request.
                if (latest != null && latest.RevisionRequested)
                {
                    row.Feedback = "Revision requested: " + TextOrDash(latest.RevisionInstructions);
                    if (!string.IsNullOrWhiteSpace(latest.Feedback)) row.Feedback += " — " + latest.Feedback;
                }
                else if (latest != null && !string.IsNullOrWhiteSpace(latest.Feedback))
                {
                    row.Feedback = latest.Feedback;
                }
                else
                {
                    row.Feedback = L.T("Student.Progress.NoFeedbackYet");
                }

                rows.Add(row);
            }

            rptTasks.DataSource = rows;
            rptTasks.DataBind();
            pnlNoTasks.Visible = rows.Count == 0;
            return latestGrades;
        }

        // ---- submission and revision history ------------------------------
        private void ShowAttempts(List<InternshipTask> tasks,
            List<TaskEvaluation> evaluations, List<Submission> submissions)
        {
            Dictionary<string, string> titles = new Dictionary<string, string>();
            foreach (InternshipTask task in tasks)
            {
                if (!string.IsNullOrEmpty(task.Id)) titles[task.Id] = TextOrDash(task.Title);
            }

            List<AttemptRow> rows = new List<AttemptRow>();
            foreach (Submission submission in submissions.OrderByDescending(s => s.SubmittedAt))
            {
                AttemptRow row = new AttemptRow();
                string title;
                row.TaskTitle = titles.TryGetValue(submission.TaskId ?? "", out title) ? title : "—";
                row.Attempt = submission.AttemptNumber;
                row.SubmittedAt = Time.Display(submission.SubmittedAt);

                TaskEvaluation evaluation = evaluations
                    .Where(ev => ev.SubmissionId == submission.Id)
                    .OrderByDescending(ev => ev.EvaluatedAt)
                    .FirstOrDefault();

                if (evaluation == null)
                {
                    row.Outcome = L.T("Student.Progress.AwaitingReview");
                    row.OutcomeCss = "uims-pill-pending";
                    row.Details = "";
                }
                else if (evaluation.RevisionRequested)
                {
                    row.Outcome = L.T("Student.Progress.RevisionRequested");
                    row.OutcomeCss = "uims-pill-rejected";
                    row.Details = TextOrDash(evaluation.RevisionInstructions);
                }
                else
                {
                    row.Outcome = "Graded";
                    row.OutcomeCss = "uims-pill-accepted";
                    row.Details = evaluation.TotalScore.ToString("0.##") + " / " + evaluation.MaxScore.ToString("0.##");
                }

                rows.Add(row);
            }

            rptAttempts.DataSource = rows;
            rptAttempts.DataBind();
            pnlNoAttempts.Visible = rows.Count == 0;
        }

        // ---- training hours -----------------------------------------------
        /// <summary>Fills the hours log and returns the approved total. Only
        /// Approved entries count (business rule).</summary>
        private int ShowHours(Placement placement, List<TrainingHoursEntry> hours)
        {
            int approved = hours.Where(h => h.Status == HoursStatus.Approved).Sum(h => h.Hours);
            int pending = hours.Where(h => h.Status == HoursStatus.Reported).Sum(h => h.Hours);
            int rejected = hours.Where(h => h.Status == HoursStatus.Rejected).Sum(h => h.Hours);

            litHoursApproved.Text = approved.ToString();
            litHoursPending.Text = pending.ToString();
            litHoursRejected.Text = rejected.ToString();

            var rows = hours
                .OrderByDescending(h => h.WorkDate > 0 ? h.WorkDate : h.ReportedAt)
                .Select(h => new
                {
                    Date = Time.DisplayDate(h.WorkDate > 0 ? h.WorkDate : h.ReportedAt),
                    Hours = h.Hours,
                    Description = TextOrDash(h.Description),
                    Status = h.Status == HoursStatus.Reported ? L.T("Student.Progress.PendingApproval") : L.Value("HoursStatus", h.Status),
                    StatusCss = h.Status == HoursStatus.Approved ? "uims-pill-accepted"
                              : h.Status == HoursStatus.Rejected ? "uims-pill-rejected"
                              : "uims-pill-pending",
                    Note = TextOrDash(h.ReviewNote)
                })
                .ToList();

            rptHours.DataSource = rows;
            rptHours.DataBind();
            pnlNoHours.Visible = rows.Count == 0;
            return approved;
        }

        // ---- top summary --------------------------------------------------
        private void ShowSummary(Placement placement, List<InternshipTask> tasks,
            List<TaskEvaluation> latestGrades, int approvedHours)
        {
            int required = placement.RequiredHours > 0 ? placement.RequiredHours : CurrentStudent.RequiredHours;
            int percent = required > 0 ? (int)Math.Min(100, approvedHours * 100.0 / required) : 0;

            litSumHours.Text = approvedHours + " / " + required;
            litSumHoursPercent.Text = percent.ToString();
            hoursBar.Style["width"] = percent + "%";
            hoursBar.Attributes["aria-valuenow"] = percent.ToString();
            hoursBar.Attributes["data-ui-progress"] = "";
            hoursBar.Attributes["data-ui-approved"] = approvedHours.ToString();
            hoursBar.Attributes["data-ui-target"] = required.ToString();
            hoursBar.Attributes["aria-valuetext"] = required > 0
                ? approvedHours + " approved hours of " + required + " required hours"
                : approvedHours + " approved hours. Training hours target is not set.";
            if (required <= 0) hoursBar.Attributes.Remove("aria-valuenow");

            int graded = tasks.Count(t => t.Status == InternshipTaskStatus.Graded);
            litSumTasks.Text = graded + " / " + tasks.Count;

            litSumRevisions.Text = tasks.Count(t => t.Status == InternshipTaskStatus.RevisionRequested).ToString();

            if (latestGrades.Count == 0)
            {
                litSumAverage.Text = "—";
            }
            else
            {
                double average = GradingService.TaskComponentPercent(tasks, latestGrades);
                litSumAverage.Text = average.ToString("0.#") + "%";
            }
        }

        // ---- completion and official report (card A16) --------------------
        private void ShowCompletion(CompletionRecord completion)
        {
            if (completion == null || completion.Status != CompletionStatus.Approved)
            {
                pnlNotApproved.Visible = true;
                litCompletionStage.Text = CompletionStageText(completion);
                return;
            }

            pnlApproved.Visible = true;
            litFinalScore.Text = completion.FinalScore.ToString("0.#") + "%";
            litFinalResult.Text = TextOrDash(completion.Result);
            litApprovedAt.Text = Time.DisplayDate(completion.ApprovedAt);

            bool canDownload = PdfReportService.MayDownload(completion, CurrentStudent)
                               && (IsWebLink(completion.ReportFileUrl)
                                   || completion.ReportFileUrl.StartsWith("~/Pages/Account/CompletionReport.aspx"));
            if (canDownload)
            {
                lnkReport.NavigateUrl = completion.ReportFileUrl;
                lnkReport.Visible = true;
            }
            else
            {
                pnlReportPending.Visible = true;
            }
        }

        // ---- helpers ------------------------------------------------------
        private static string CompletionStageText(CompletionRecord completion)
        {
            if (completion == null) return L.T("Student.Progress.YourInternshipIsStillInProgress");
            switch (completion.Status)
            {
                case CompletionStatus.AwaitingCompanyEvaluation:
                case CompletionStatus.AwaitingAcademicEvaluation:
                    return L.T("Student.Progress.YourSupervisorsArePreparingTheirFinal");
                case CompletionStatus.UnderCoordinatorReview:
                    return L.T("Student.Progress.TheInternshipCoordinatorIsReviewingYour");
                case CompletionStatus.Rejected:
                    return L.T("Student.Progress.YourCompletionWasNotApprovedPlease");
                default:
                    return L.T("Student.Progress.YourInternshipIsStillInProgress");
            }
        }

        private static string CriteriaText(List<GradeComponent> components)
        {
            if (components == null || components.Count == 0) return "";
            return string.Join(" · ", components.Select(c =>
                TextOrDash(c.Name) + ": " + c.Score.ToString("0.##") + "/" + c.MaxScore.ToString("0.##")));
        }

        private static string StatusText(InternshipTaskStatus status)
        {
            switch (status)
            {
                case InternshipTaskStatus.UnderReview: return L.T("Student.Progress.UnderReview");
                case InternshipTaskStatus.RevisionRequested: return L.T("Student.Progress.RevisionRequested");
                default: return status.ToString();
            }
        }

        private static string StatusCss(InternshipTaskStatus status)
        {
            switch (status)
            {
                case InternshipTaskStatus.Graded: return "uims-pill-accepted";
                case InternshipTaskStatus.RevisionRequested: return "uims-pill-rejected";
                case InternshipTaskStatus.Assigned: return "uims-pill-info";
                default: return "uims-pill-pending";
            }
        }

        private static bool IsWebLink(string url)
        {
            Uri address;
            return Uri.TryCreate(url, UriKind.Absolute, out address)
                   && (address.Scheme == Uri.UriSchemeHttp || address.Scheme == Uri.UriSchemeHttps);
        }

        private static string TextOrDash(string value)
        {
            return string.IsNullOrWhiteSpace(value) ? "—" : value;
        }

        // Row shapes for the repeaters.
        public class TaskRow
        {
            public string Title { get; set; }
            public string Deadline { get; set; }
            public string Status { get; set; }
            public string StatusCss { get; set; }
            public bool IsOverdue { get; set; }
            public int Attempts { get; set; }
            public string Grade { get; set; }
            public string Criteria { get; set; }
            public string Feedback { get; set; }
        }

        public class AttemptRow
        {
            public string TaskTitle { get; set; }
            public int Attempt { get; set; }
            public string SubmittedAt { get; set; }
            public string Outcome { get; set; }
            public string OutcomeCss { get; set; }
            public string Details { get; set; }
        }
    }
}
