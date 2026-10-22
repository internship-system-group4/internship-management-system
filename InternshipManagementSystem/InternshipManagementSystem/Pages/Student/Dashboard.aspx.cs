// =============================================================================
//  Student Dashboard
//  Owner : Sara Rajoub
//  Cards : R05
//
//  Summary of applications, tasks, deadlines, evaluations and progress for the signed-in student only.
//
//  Namespace note: these page namespaces end in "Area" on purpose. A namespace
//  called ...Pages.Student would hide the Student model class and every file in
//  the folder would fail to compile with "Student is a namespace but is used
//  like a type". Keep the suffix.
// =============================================================================

using System;
using System.Linq;
using System.Collections.Generic;
using System.Web;

using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.StudentArea
{
    public partial class Dashboard : StudentPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadDashboard();
            }
        }

        private void LoadDashboard()
        {
            Student student = CurrentStudent;

            if (student == null)
            {
                pnlError.Visible = true;
                return;
            }

            // Student name comes from the signed-in account.
            string studentName = student.FullName;

            if (string.IsNullOrWhiteSpace(studentName))
            {
                studentName = "Student";
            }

            litStudentName.Text = HttpUtility.HtmlEncode(studentName);

            // Show a neutral state until Firebase data is loaded.
            litApplications.Text = "—";
            litTasks.Text = "—";
            litEvaluations.Text = "—";
            litHours.Text = "—";
            litProgressHours.Text = "—";
            litPercent.Text = "—";
            try
            {
                System.Diagnostics.Debug.WriteLine("Loading Applications...");
                LoadApplications(student.Id);

                System.Diagnostics.Debug.WriteLine("Loading Tasks...");
                LoadTasks(student.Id);

                System.Diagnostics.Debug.WriteLine("Loading Evaluations...");
                LoadEvaluations(student.Id);

                System.Diagnostics.Debug.WriteLine("Loading Training Progress...");
                LoadTrainingProgress(student);

                pnlError.Visible = false;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(
                    "DASHBOARD ERROR: " + ex.ToString()
                );

                pnlError.Visible = true;
            }

        }

        private void LoadApplications(string studentId)
        {
            List<InternshipApplication> applications =
                new ApplicationRepository()
                    .GetWhere("StudentId", studentId)
                    .OrderByDescending(a => a.SubmittedAt)
                    .ToList();

            litApplications.Text = applications.Count.ToString();

            var recentApplications = applications
                .Take(5)
                .Select(a => new
                {
                    Title = string.IsNullOrWhiteSpace(a.OpportunityTitle)
                        ? "Internship Opportunity"
                        : a.OpportunityTitle,

                    Company = string.IsNullOrWhiteSpace(a.CompanyName)
                        ? "Company not specified"
                        : a.CompanyName,

                    Date = a.SubmittedAt > 0
                        ? Time.DisplayDate(a.SubmittedAt)
                        : "Date unavailable",

                    Status = a.Status.ToString()
                })
                .ToList();

            rptApplications.DataSource = recentApplications;
            rptApplications.DataBind();

            pnlNoApplications.Visible =
                recentApplications.Count == 0;
        }

        private void LoadTasks(string studentId)
        {
            List<InternshipTask> tasks =
                new TaskRepository()
                    .GetWhere("StudentId", studentId)
                    .ToList();

            litTasks.Text = tasks.Count.ToString();

            long currentTime = Time.NowMs();

            var upcomingTasks = tasks
                .Where(t =>
                    t.Deadline > 0 &&
                    t.Deadline >= currentTime &&
                    t.Status != InternshipTaskStatus.Graded)
                .OrderBy(t => t.Deadline)
                .Take(5)
                .Select(t => new
                {
                    Title = string.IsNullOrWhiteSpace(t.Title)
                        ? "Training Task"
                        : t.Title,

                    DeadlineText = Time.DisplayDate(t.Deadline),

                    Status = t.Status.ToString()
                })
                .ToList();

            rptTasks.DataSource = upcomingTasks;
            rptTasks.DataBind();

            pnlNoTasks.Visible = upcomingTasks.Count == 0;
        }

        private void LoadEvaluations(string studentId)
        {
            List<TaskEvaluation> evaluations =
                new EvaluationRepository()
                    .GetTaskEvaluationsForStudent(studentId);

            // Count evaluated tasks, not duplicate evaluation records.
            int evaluatedTasks = evaluations
                .Where(e => !string.IsNullOrWhiteSpace(e.TaskId))
                .Select(e => e.TaskId)
                .Distinct()
                .Count();

            litEvaluations.Text = evaluatedTasks.ToString();
        }

        private void LoadTrainingProgress(Student student)
        {
            int approvedHours = Math.Max(0, student.ApprovedHours);
            int requiredHours = Math.Max(0, student.RequiredHours);

            litHours.Text = approvedHours.ToString();

            litProgressHours.Text =
                approvedHours + " / " + requiredHours + " hours";

            int progressPercent = 0;

            if (requiredHours > 0)
            {
                double percentage =
                    (approvedHours * 100.0) / requiredHours;

                progressPercent = (int)Math.Min(100, percentage);
            }

            litPercent.Text = progressPercent.ToString();

            progressFill.Style["width"] =
                progressPercent + "%";

            progressFill.Attributes["aria-valuenow"] =
                progressPercent.ToString();
        }
    }
}
