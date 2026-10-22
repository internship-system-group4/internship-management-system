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

namespace InternshipManagementSystem.Pages.StudentArea
{
    public partial class Dashboard : InternshipManagementSystem.Security.StudentPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) LoadDashboard();
        }

        private void LoadDashboard()
        {
            Student student = CurrentStudent;
            if (student == null) return;
            litStudentName.Text = HttpUtility.HtmlEncode(student.FullName ?? "Student");
            try
            {
                // Query by the signed-in student's Firebase Auth UID, never a query-string ID.
                var applications = new ApplicationRepository().GetWhere("StudentId", student.Id)
                    .OrderByDescending(a => a.SubmittedAt).ToList();
                var tasks = new TaskRepository().GetWhere("StudentId", student.Id);
                var evaluations = new EvaluationRepository().GetTaskEvaluationsForStudent(student.Id);

                litApplications.Text = applications.Count.ToString();
                litTasks.Text = tasks.Count.ToString();
                litEvaluations.Text = evaluations.Select(e => e.TaskId).Where(id => !string.IsNullOrEmpty(id)).Distinct().Count().ToString();
                litHours.Text = student.ApprovedHours.ToString();

                int required = student.RequiredHours;
                int approved = Math.Max(0, student.ApprovedHours);
                int percent = required > 0 ? (int)Math.Min(100, approved * 100.0 / required) : 0;
                litProgressHours.Text = approved + " / " + required + " hours";
                litPercent.Text = percent.ToString();
                progressFill.Style["width"] = percent + "%";
                progressFill.Attributes["aria-valuenow"] = percent.ToString();

                var upcoming = tasks.Where(t => t.Deadline > 0 && t.Deadline >= Time.NowMs()
                    && t.Status != InternshipTaskStatus.Graded)
                    .OrderBy(t => t.Deadline).Take(5)
                    .Select(t => new { Title = t.Title, DeadlineText = Time.DisplayDate(t.Deadline), Status = t.Status.ToString() }).ToList();
                rptTasks.DataSource = upcoming;
                rptTasks.DataBind();
                pnlNoTasks.Visible = upcoming.Count == 0;

                var recent = applications.Take(5).Select(a => new {
                    Title = a.OpportunityTitle,
                    Company = a.CompanyName,
                    Date = Time.DisplayDate(a.SubmittedAt),
                    Status = a.Status.ToString()
                }).ToList();
                rptApplications.DataSource = recent;
                rptApplications.DataBind();
                pnlNoApplications.Visible = recent.Count == 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Student dashboard failed: " + ex);
                pnlError.Visible = true;
                // Never display another student's data or show fabricated statistics on error.
            }
        }
    }
}

