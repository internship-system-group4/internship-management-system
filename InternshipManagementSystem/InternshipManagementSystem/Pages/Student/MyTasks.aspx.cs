// =============================================================================
//  My Tasks
//  Owner : Fatima
//  Cards : F03, F04
//
//  The student's own tasks with deadlines and statuses, and the submission form for text, a link or a file. Each submission is a new Submission record with an incremented AttemptNumber - never overwrite the previous attempt.
//
//  Namespace note: these page namespaces end in "Area" on purpose. A namespace
//  called ...Pages.Student would hide the Student model class and every file in
//  the folder would fail to compile with "Student is a namespace but is used
//  like a type". Keep the suffix.
// =============================================================================
using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.StudentArea
{
    public partial class MyTasks : StudentPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadTasks();
            }
        }

        private void LoadTasks()
        {
            List<InternshipTask> tasks =
                new TaskRepository().GetByStudent(CurrentStudent.Id);

            rptTasks.DataSource = tasks;
            rptTasks.DataBind();
            pnlNoTasks.Visible = tasks.Count == 0;
        }

        protected void rptTasks_ItemCommand(
            object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "ViewDetails") return;

            string taskId = Convert.ToString(e.CommandArgument);
            InternshipTask task = new TaskRepository().GetById(taskId);

            // لا نعرض مهمة طالب آخر حتى لو وصلنا رقمها.
            if (task == null || task.StudentId != CurrentStudent.Id) return;

            ViewState["SelectedTaskId"] = task.Id;
            ShowTask(task);
        }

        protected void btnSubmitTask_Click(object sender, EventArgs e)
        {
            var task = new TaskRepository().GetById(ViewState["SelectedTaskId"] as string);
            if (task == null || task.StudentId != CurrentStudent.Id) return;
            try {
                Services.TaskWorkflowService.Submit(task.Id, txtSubmissionText.Text, txtSubmissionLink.Text);
                txtSubmissionText.Text = txtSubmissionLink.Text = "";
                LoadTasks();
                ShowMessage(L.T("Student.MyTasks.SubmissionSavedSuccessfully"), true, new TaskRepository().GetById(task.Id));
            } catch (Exception ex) {
                Services.EmailNotificationService.LogFailure(ex);
                ShowMessage(ex is InvalidOperationException || ex is UnauthorizedAccessException ? ex.Message : "Could not submit your work. Please try again.", false, task);
            }
        }

        private void ShowTask(InternshipTask task)
        {
            litTaskTitle.Text = task.Title ?? "";
            litStatus.Text = L.Value("TaskStatus", task.Status);
            litDescription.Text = task.Description ?? "";
            litInstructions.Text = task.Instructions ?? "";

            litDeadline.Text = task.Deadline > 0
                ? DateTimeOffset.FromUnixTimeMilliseconds(task.Deadline)
                    .UtcDateTime.ToString("yyyy-MM-dd HH:mm") + " UTC"
                : L.T("Student.MyTasks.NotSet");

            rptCriteria.DataSource = task.Criteria;
            rptCriteria.DataBind();
            lblNoCriteria.Visible =
                task.Criteria == null || task.Criteria.Count == 0;

            List<Submission> mySubmissions = new List<Submission>();

            foreach (Submission item in
                     new SubmissionRepository().GetByTask(task.Id))
            {
                if (item.StudentId == CurrentStudent.Id &&
                    item.PlacementId == task.PlacementId)
                {
                    mySubmissions.Add(item);
                }
            }

            rptHistory.DataSource = mySubmissions;
            rptHistory.DataBind();
            phNoAttempts.Visible = mySubmissions.Count == 0;

            ClientScript.RegisterStartupScript(
                GetType(), "openTaskDetails", "showTaskDetails();", true);
        }

        private void ShowMessage(
            string message, bool success, InternshipTask task)
        {
            lblSubmitMessage.Text = Server.HtmlEncode(message);
            lblSubmitMessage.CssClass = success
                ? "alert alert-success d-block mt-3"
                : "alert alert-danger d-block mt-3";
            lblSubmitMessage.Visible = true;

            ShowTask(task);
        }
    }
}
