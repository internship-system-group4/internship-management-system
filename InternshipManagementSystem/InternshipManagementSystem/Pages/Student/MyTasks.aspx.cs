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
            string taskId = ViewState["SelectedTaskId"] as string;
            InternshipTask task = new TaskRepository().GetById(taskId);

            // نعيد فحص المهمة عند التسليم، ولا نعتمد على فحص زر التفاصيل.
            if (task == null || task.StudentId != CurrentStudent.Id) return;

            Placement placement =
                new PlacementRepository().GetById(CurrentStudent.Id);

            if (placement == null ||
                placement.StudentId != CurrentStudent.Id ||
                task.PlacementId != placement.Id)
            {
                ShowMessage("Your confirmed placement was not found.", false, task);
                return;
            }

            if (!task.AcceptsSubmission)
            {
                ShowMessage("This task is not accepting submissions now.", false, task);
                return;
            }

            if (task.RequiresFileUpload)
            {
                ShowMessage(
                    "This task requires a file. File uploads are not available yet.",
                    false, task);
                return;
            }

            string submissionText = txtSubmissionText.Text.Trim();
            string submissionLink = txtSubmissionLink.Text.Trim();

            if (submissionText == "" && submissionLink == "")
            {
                ShowMessage("Enter submission text or a link.", false, task);
                return;
            }

            if (submissionLink != "")
            {
                Uri address;
                bool validLink = Uri.TryCreate(
                    submissionLink, UriKind.Absolute, out address);

                if (!validLink ||
                    (address.Scheme != Uri.UriSchemeHttp &&
                     address.Scheme != Uri.UriSchemeHttps))
                {
                    ShowMessage("Enter a valid http or https link.", false, task);
                    return;
                }
            }

            SubmissionRepository repository = new SubmissionRepository();
            List<Submission> submissions = repository.GetByTask(task.Id);

            int lastAttempt = 0;

            foreach (Submission previous in submissions)
            {
                if (previous.StudentId == CurrentStudent.Id &&
                    previous.PlacementId == task.PlacementId &&
                    previous.AttemptNumber > lastAttempt)
                {
                    lastAttempt = previous.AttemptNumber;
                }
            }

            // لا نسمح بمحاولة ثانية إلا بعد طلب تعديل من المشرف.
            if (lastAttempt > 0 &&
                task.Status != InternshipTaskStatus.RevisionRequested)
            {
                ShowMessage(
                    "You already submitted this task. Wait for a revision request.",
                    false, task);
                return;
            }

            Submission submission = new Submission();
            submission.TaskId = task.Id;
            submission.PlacementId = task.PlacementId;
            submission.StudentId = CurrentStudent.Id;
            submission.AttemptNumber = lastAttempt + 1;
            submission.DescriptionText = submissionText;
            submission.LinkUrl = submissionLink;

            try
            {
                // Insert ينشئ سجلًا جديدًا؛ المحاولات السابقة تبقى محفوظة.
                string newId = repository.Insert(submission);

                if (string.IsNullOrEmpty(newId))
                {
                    ShowMessage("Submission could not be saved.", false, task);
                    return;
                }
            }
            catch (FirebaseException)
            {
                ShowMessage("Submission could not be saved. Try again.", false, task);
                return;
            }

            InternshipTaskStatus newStatus =
                lastAttempt == 0
                    ? InternshipTaskStatus.Submitted
                    : InternshipTaskStatus.Resubmitted;

            try
            {
                new TaskRepository().Update(
                    task.Id,
                    new Dictionary<string, object>
                    {
                        { "Status", newStatus }
                    });

                task.Status = newStatus;
            }
            catch (FirebaseException)
            {
                ShowMessage(
                    "Submission was saved, but the task status could not be updated. Refresh the page.",
                    false, task);
                return;
            }

            txtSubmissionText.Text = "";
            txtSubmissionLink.Text = "";

            LoadTasks();
            ShowMessage("Submission saved successfully.", true, task);
        }

        private void ShowTask(InternshipTask task)
        {
            litTaskTitle.Text = task.Title ?? "";
            litStatus.Text = task.Status.ToString();
            litDescription.Text = task.Description ?? "";
            litInstructions.Text = task.Instructions ?? "";

            litDeadline.Text = task.Deadline > 0
                ? DateTimeOffset.FromUnixTimeMilliseconds(task.Deadline)
                    .UtcDateTime.ToString("yyyy-MM-dd HH:mm") + " UTC"
                : "Not set";

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
