using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Web;
using System.Web.Configuration;
using System.Web.UI.WebControls;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.StudentArea
{
    public partial class MyTasks : StudentPage
    {
        private const int MaxFileBytes = 10 * 1024 * 1024;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Page.Form != null) Page.Form.Enctype = "multipart/form-data";
            LoadTasks();
            if (IsPostBack)
            {
                InternshipTask selected = GetSelectedTask();
                if (selected != null) ShowTask(selected);
            }
            else
            {
                if (Session["TaskSubmissionNotice"] is bool && (bool)Session["TaskSubmissionNotice"])
                    ShowMessage(L.T("Student.MyTasks.YourTaskWasSubmittedSuccessfully"), true);
                Session.Remove("TaskSubmissionNotice");
                // Opened from a notification (MyTasks.aspx?task={id}): show that task straight away.
                string fromLink = Request.QueryString["task"];
                if (ApplicationRepository.IsValidKey(fromLink))
                {
                    InternshipTask linked = new TaskRepository().GetById(fromLink);
                    if (OwnsTask(linked)) { ViewState["SelectedTaskId"] = linked.Id; ShowTask(linked); }
                }
            }
        }

        private void LoadTasks()
        {
            List<InternshipTask> all = new TaskRepository().GetByStudent(CurrentStudent.Id);
            Placement placement = new PlacementRepository().GetById(CurrentStudent.Id);
            List<InternshipTask> tasks = new List<InternshipTask>();
            if (placement != null && placement.StudentId == CurrentStudent.Id)
                foreach (InternshipTask task in all)
                    if (task != null && task.StudentId == CurrentStudent.Id &&
                        task.PlacementId == placement.Id) tasks.Add(task);

            string selectedId = ViewState["SelectedTaskId"] as string;
            InternshipTask selected = null;
            foreach (InternshipTask task in tasks)
                if (task.Id == selectedId) { selected = task; break; }
            if (selected == null && tasks.Count > 0)
            {
                selected = tasks[0];
                ViewState["SelectedTaskId"] = selected.Id;
            }

            List<StudentTaskRow> rows = new List<StudentTaskRow>();
            SubmissionRepository repo = new SubmissionRepository();
            foreach (InternshipTask task in tasks)
            {
                StudentTaskRow row = new StudentTaskRow();
                row.Id = task.Id;
                row.Title = task.Title ?? L.T("Student.MyTasks.UntitledTask");
                row.StartLabel = task.StartDate > 0 ? L.T("Student.MyTasks.Starts") + FormatDate(task.StartDate) : L.T("Student.MyTasks.AssignedTask");
                row.DeadlineLabel = task.Deadline > 0 ? FormatDate(task.Deadline) : L.T("Student.MyTasks.NotSet");
                row.StatusLabel = FriendlyStatus(task.Status);
                row.StatusClass = StatusClass(task.Status);
                row.AttemptsLabel = CountAttempts(repo.GetByTask(task.Id), task).ToString();
                row.ActionLabel = task.AcceptsSubmission
                    ? (task.Status == InternshipTaskStatus.RevisionRequested ? "Resubmit" : "Submit")
                    : "Details";
                row.RowClass = selected != null && selected.Id == task.Id ? "is-selected" : "";
                rows.Add(row);
            }
            rptTasks.DataSource = rows;
            rptTasks.DataBind();
            pnlNoTasks.Visible = tasks.Count == 0;
            phNoTaskRows.Visible = tasks.Count == 0;
            pnlSelectTask.Visible = tasks.Count == 0;
            pnlSelectedTask.Visible = selected != null;
            if (selected != null) ShowTask(selected);
        }

        protected void rptTasks_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "SelectTask") return;
            InternshipTask task = new TaskRepository().GetById(Convert.ToString(e.CommandArgument));
            if (!OwnsTask(task)) return;
            ViewState["SelectedTaskId"] = task.Id;
            LoadTasks();
        }

        protected void btnSubmitTask_Click(object sender, EventArgs e)
        {
            InternshipTask task = GetSelectedTask();
            if (!OwnsTask(task)) { ShowMessage(L.T("Student.MyTasks.ThisTaskIsNotAssignedTo"), false); return; }
            if (!task.AcceptsSubmission) { ShowMessage(L.T("Student.MyTasks.ThisTaskIsNotAcceptingSubmissions3"), false); return; }

            Placement placement = new PlacementRepository().GetById(CurrentStudent.Id);
            if (placement == null || placement.StudentId != CurrentStudent.Id ||
                placement.Id != task.PlacementId)
            { ShowMessage(L.T("Student.MyTasks.YourPlacementCouldNotBeVerified"), false); return; }

            string note = (txtSubmissionText.Text ?? "").Trim();
            string link = (txtSubmissionLink.Text ?? "").Trim();
            bool hasFile = fuSubmission.HasFile;
            if (link.Length > 0 && !IsHttpUrl(link))
            { ShowMessage(L.T("Student.I18n.Enteravalidlinkbeginningwithhttp"), false); return; }
            if (task.RequiresFileUpload && !hasFile) { string bucket = WebConfigurationManager.AppSettings["Firebase.StorageBucket"]; ShowMessage(string.IsNullOrWhiteSpace(bucket) ? L.T("Student.I18n.Thistaskrequiresafilebutfile") : L.T("Student.I18n.ThistaskrequiresanattachmentChoosea"), false); return; }
            if (note.Length == 0 && link.Length == 0 && !hasFile)
            { ShowMessage(L.T("Student.MyTasks.AddANoteALinkOr2"), false); return; }

            SubmissionRepository repo = new SubmissionRepository();
            int previousAttempt = CountAttempts(repo.GetByTask(task.Id), task);
            if (previousAttempt > 0 && task.Status != InternshipTaskStatus.RevisionRequested)
            { ShowMessage(L.T("Student.MyTasks.YourSubmissionIsWaitingForReview"), false); return; }

            Submission submission = new Submission();
            submission.TaskId = task.Id;
            submission.StudentId = CurrentStudent.Id;
            submission.PlacementId = task.PlacementId;
            submission.AttemptNumber = previousAttempt + 1;
            submission.DescriptionText = note;
            submission.LinkUrl = link;

            if (hasFile)
            {
                try
                {
                    string savedFileName;
                    submission.FileUrl = UploadFile(fuSubmission.PostedFile, task.Id, CurrentStudent.Id, out savedFileName);
                    submission.FileName = savedFileName;
                }
                catch (WebException) { ShowMessage(L.T("Student.MyTasks.TheAttachmentCouldNotBeUploaded"), false); return; }
                catch (InvalidOperationException ex) { ShowMessage(ex.Message, false); return; }
            }

            try
            {
                if (string.IsNullOrEmpty(repo.Insert(submission)))
                { ShowMessage(L.T("Student.MyTasks.TheSubmissionCouldNotBeSaved"), false); return; }
            }
            catch (FirebaseException)
            { ShowMessage(L.T("Student.MyTasks.TheSubmissionCouldNotBeSaved"), false); return; }

            InternshipTaskStatus status = previousAttempt == 0
                ? InternshipTaskStatus.Submitted : InternshipTaskStatus.Resubmitted;
            try
            {
                new TaskRepository().Update(task.Id, new Dictionary<string, object> { { "Status", status } });
                task.Status = status;
            }
            catch (FirebaseException)
            {
                ShowMessage(L.T("Student.MyTasks.YourSubmissionWasSavedButThe"), false);
                return;
            }

            Session["TaskSubmissionNotice"] = true;
            Response.Redirect("MyTasks.aspx?task=" + Uri.EscapeDataString(task.Id), false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private InternshipTask GetSelectedTask()
        {
            string id = ViewState["SelectedTaskId"] as string;
            return string.IsNullOrWhiteSpace(id) ? null : new TaskRepository().GetById(id);
        }

        private bool OwnsTask(InternshipTask task)
        {
            if (task == null || CurrentStudent == null || task.StudentId != CurrentStudent.Id) return false;
            Placement p = new PlacementRepository().GetById(CurrentStudent.Id);
            return p != null && p.StudentId == CurrentStudent.Id && p.Id == task.PlacementId;
        }

        private void ShowTask(InternshipTask task)
        {
            if (!OwnsTask(task)) { pnlSelectedTask.Visible = false; pnlSelectTask.Visible = true; return; }
            pnlSelectedTask.Visible = true;
            pnlSelectTask.Visible = false;
            litTaskTitle.Text = task.Title ?? "";
            litStatus.Text = FriendlyStatus(task.Status);
            litDescription.Text = string.IsNullOrWhiteSpace(task.Description) ? L.T("Student.MyTasks.NoDescriptionWasProvided") : task.Description;
            litInstructions.Text = string.IsNullOrWhiteSpace(task.Instructions) ? L.T("Student.MyTasks.NoAdditionalInstructionsWereProvided") : task.Instructions;
            litDeadline.Text = task.Deadline > 0 ? FormatDate(task.Deadline) : L.T("Student.MyTasks.NotSet");

            Uri attachment;
            lnkTaskAttachment.Visible = Uri.TryCreate(task.AttachmentUrl, UriKind.Absolute, out attachment) &&
                attachment.Scheme == Uri.UriSchemeHttps && attachment.Host == "firebasestorage.googleapis.com";
            if (lnkTaskAttachment.Visible)
            {
                lnkTaskAttachment.NavigateUrl = task.AttachmentUrl;
                lnkTaskAttachment.Attributes["rel"] = "noopener noreferrer";
                lnkTaskAttachment.Text = L.T("Student.I18n.Downloadtaskattachment") +
                    Server.HtmlEncode(string.IsNullOrWhiteSpace(task.AttachmentName) ? L.T("Student.MyTasks.AttachedFile") : task.AttachmentName);
            }

            pnlSubmissionForm.Visible = task.AcceptsSubmission;
            pnlSubmissionClosed.Visible = !task.AcceptsSubmission;
            btnSubmitTask.Text = task.Status == InternshipTaskStatus.RevisionRequested ? L.T("Student.MyTasks.ResubmitTask") : L.T("Student.MyTasks.SubmitTask2");
            bool storageReady = !string.IsNullOrWhiteSpace(WebConfigurationManager.AppSettings["Firebase.StorageBucket"]);
            fuSubmission.Enabled = storageReady;
            litFileRequirement.Text = !storageReady
                ? (task.RequiresFileUpload
                    ? "<span class=\"text-danger small d-block mt-1\">This task requires a file, but file storage is not configured.</span>"
                    : "<span class=\"text-muted small d-block mt-1\">File uploads are not configured yet. You can submit a link instead.</span>")
                : (task.RequiresFileUpload ? "<span class=\"text-danger small d-block mt-1\">An attachment is required for this task.</span>" : "");
            rptCriteria.DataSource = task.Criteria;
            rptCriteria.DataBind();
            lblNoCriteria.Visible = task.Criteria == null || task.Criteria.Count == 0;
            BindHistory(task);
        }

        private void BindHistory(InternshipTask task)
        {
            List<Submission> submissions = new SubmissionRepository().GetByTask(task.Id);
            List<TaskEvaluation> evaluations = new TaskEvaluationRepository().GetByTask(task.Id);
            List<HistoryRow> rows = new List<HistoryRow>();
            foreach (Submission s in submissions)
            {
                if (s == null || s.StudentId != CurrentStudent.Id || s.PlacementId != task.PlacementId) continue;
                TaskEvaluation evaluation = null;
                foreach (TaskEvaluation e in evaluations)
                    if (e != null && e.SubmissionId == s.Id && e.StudentId == CurrentStudent.Id &&
                        e.PlacementId == task.PlacementId) { evaluation = e; break; }

                HistoryRow row = new HistoryRow();
                row.AttemptLabel = s.AttemptNumber.ToString();
                row.SubmittedLabel = FormatDate(s.SubmittedAt);
                row.StatusLabel = evaluation == null
                    ? SubmissionStatusLabel(s.Status)
                    : (evaluation.RevisionRequested ? L.T("Student.MyTasks.RevisionRequested") : "Reviewed");
                row.Feedback = evaluation == null ? L.T("Student.MyTasks.NoFeedbackYet") :
                    (evaluation.RevisionRequested
                        ? (evaluation.RevisionInstructions ?? evaluation.Feedback ?? L.T("Student.MyTasks.RevisionRequested2"))
                        : (evaluation.Feedback ?? L.T("Student.MyTasks.EvaluationCompleted")));
                row.FileUrl = SafeStorageUrl(s.FileUrl) ? s.FileUrl : "";
                row.FileName = string.IsNullOrWhiteSpace(s.FileName) ? L.T("Student.MyTasks.DownloadSubmittedFile") : s.FileName;
                row.HasFile = row.FileUrl.Length > 0;
                row.LinkUrl = IsHttpUrl(s.LinkUrl) ? s.LinkUrl : "";
                row.HasLink = row.LinkUrl.Length > 0;
                rows.Add(row);
            }
            rows.Sort(delegate(HistoryRow a, HistoryRow b)
            { return Convert.ToInt32(b.AttemptLabel).CompareTo(Convert.ToInt32(a.AttemptLabel)); });
            rptHistory.DataSource = rows;
            rptHistory.DataBind();
            phNoAttempts.Visible = rows.Count == 0;
        }

        private int CountAttempts(List<Submission> list, InternshipTask task)
        {
            int count = 0;
            if (list == null) return count;
            foreach (Submission s in list)
                if (s != null && s.StudentId == CurrentStudent.Id && s.PlacementId == task.PlacementId &&
                    s.AttemptNumber > count) count = s.AttemptNumber;
            return count;
        }

        private static string FriendlyStatus(InternshipTaskStatus s)
        {
            switch (s)
            {
                case InternshipTaskStatus.Submitted: return "Submitted";
                case InternshipTaskStatus.UnderReview: return L.T("Student.MyTasks.UnderReview");
                case InternshipTaskStatus.RevisionRequested: return L.T("Student.MyTasks.RevisionRequested");
                case InternshipTaskStatus.Resubmitted: return "Resubmitted";
                case InternshipTaskStatus.Graded: return "Reviewed";
                default: return "Assigned";
            }
        }

        private static string SubmissionStatusLabel(SubmissionStatus s)
        {
            switch (s)
            {
                case SubmissionStatus.UnderReview: return L.T("Student.MyTasks.UnderReview");
                case SubmissionStatus.RevisionRequested: return L.T("Student.MyTasks.RevisionRequested");
                case SubmissionStatus.Accepted: return "Reviewed";
                default: return "Submitted";
            }
        }

        private static string StatusClass(InternshipTaskStatus s)
        {
            if (s == InternshipTaskStatus.Submitted || s == InternshipTaskStatus.UnderReview ||
                s == InternshipTaskStatus.Resubmitted) return "status-submitted";
            if (s == InternshipTaskStatus.RevisionRequested) return "status-revision";
            if (s == InternshipTaskStatus.Graded) return "status-done";
            return "status-action";
        }

        private static string FormatDate(long ms)
        {
            if (ms <= 0) return L.T("Student.MyTasks.NotSet");
            DateTimeOffset d = DateTimeOffset.FromUnixTimeMilliseconds(ms);
            try { return TimeZoneInfo.ConvertTime(d, TimeZoneInfo.FindSystemTimeZoneById("Jordan Standard Time")).ToString("dd MMM yyyy, h:mm tt"); }
            catch { return d.UtcDateTime.ToString("dd MMM yyyy, h:mm tt") + " UTC"; }
        }

        private static bool IsHttpUrl(string value)
        {
            Uri uri;
            return !string.IsNullOrWhiteSpace(value) && Uri.TryCreate(value, UriKind.Absolute, out uri) &&
                (uri.Scheme == Uri.UriSchemeHttp || uri.Scheme == Uri.UriSchemeHttps);
        }

        private static bool SafeStorageUrl(string value)
        {
            Uri uri;
            return Uri.TryCreate(value, UriKind.Absolute, out uri) && uri.Scheme == Uri.UriSchemeHttps &&
                uri.Host == "firebasestorage.googleapis.com";
        }

        private static string UploadFile(HttpPostedFile file, string taskId, string studentId, out string fileName)
        {
            fileName = Path.GetFileName(file.FileName);
            string ext = Path.GetExtension(fileName).ToLowerInvariant();
            string[] allowed = { ".pdf", ".doc", ".docx", ".zip", ".png", ".jpg", ".jpeg" };
            bool valid = false;
            foreach (string item in allowed) if (ext == item) valid = true;
            if (!valid) throw new InvalidOperationException(L.T("Student.I18n.ChooseaPDFWordZIPPNGor"));
            if (file.ContentLength <= 0 || file.ContentLength > MaxFileBytes)
                throw new InvalidOperationException(L.T("Student.I18n.Thefilemustbelargerthanzero"));

            string bucket = WebConfigurationManager.AppSettings["Firebase.StorageBucket"];
            if (string.IsNullOrWhiteSpace(bucket)) throw new InvalidOperationException(L.T("Student.I18n.Filestorageisnotconfigured"));
            bucket = bucket.Trim();
            if (bucket.StartsWith("gs://", StringComparison.OrdinalIgnoreCase)) bucket = bucket.Substring(5).TrimEnd('/');
            string token = HttpContext.Current.Session[Constants.SessionTokenKey] as string;
            if (string.IsNullOrWhiteSpace(token)) throw new InvalidOperationException(L.T("Student.I18n.YoursessionexpiredSigninagainbefore"));

            string objectName = "task-submissions/" + studentId + "/" + taskId + "/" + Guid.NewGuid().ToString("N") + ext;
            byte[] bytes = new byte[file.ContentLength];
            int total = 0;
            while (total < bytes.Length)
            {
                int read = file.InputStream.Read(bytes, total, bytes.Length - total);
                if (read <= 0) break;
                total += read;
            }
            if (total != bytes.Length) throw new InvalidOperationException(L.T("Student.I18n.Theselectedfilecouldnotberead"));

            string url = "https://firebasestorage.googleapis.com/v0/b/" + Uri.EscapeDataString(bucket) +
                "/o?uploadType=media&name=" + Uri.EscapeDataString(objectName);
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);
            request.Method = "POST";
            request.ContentType = string.IsNullOrWhiteSpace(file.ContentType) ? "application/octet-stream" : file.ContentType;
            request.Headers[HttpRequestHeader.Authorization] = "Bearer " + token;
            request.ContentLength = bytes.Length;
            request.Timeout = 60000;
            using (Stream stream = request.GetRequestStream()) stream.Write(bytes, 0, bytes.Length);
            string responseText;
            using (HttpWebResponse response = (HttpWebResponse)request.GetResponse())
            using (StreamReader reader = new StreamReader(response.GetResponseStream())) responseText = reader.ReadToEnd();
            Dictionary<string, object> responseMap = Json.ToMap(responseText);
            object tokenValue;
            string downloadToken = responseMap != null && responseMap.TryGetValue("downloadTokens", out tokenValue)
                ? Convert.ToString(tokenValue) : null;
            if (string.IsNullOrWhiteSpace(downloadToken)) throw new InvalidOperationException(L.T("Student.I18n.Storagedidnotreturnadownloadlink"));
            return "https://firebasestorage.googleapis.com/v0/b/" + Uri.EscapeDataString(bucket) +
                "/o/" + Uri.EscapeDataString(objectName) + "?alt=media&token=" + Uri.EscapeDataString(downloadToken);
        }

        private void ShowMessage(string message, bool success)
        {
            lblSubmitMessage.Text = Server.HtmlEncode(message);
            lblSubmitMessage.CssClass = success ? "alert alert-success d-block mt-3" : "alert alert-danger d-block mt-3";
            lblSubmitMessage.Visible = true;
        }

        public class StudentTaskRow
        {
            public string Id { get; set; }
            public string Title { get; set; }
            public string StartLabel { get; set; }
            public string DeadlineLabel { get; set; }
            public string StatusLabel { get; set; }
            public string StatusClass { get; set; }
            public string AttemptsLabel { get; set; }
            public string ActionLabel { get; set; }
            public string RowClass { get; set; }
        }

        public class HistoryRow
        {
            public string AttemptLabel { get; set; }
            public string SubmittedLabel { get; set; }
            public string StatusLabel { get; set; }
            public string Feedback { get; set; }
            public string FileUrl { get; set; }
            public string FileName { get; set; }
            public bool HasFile { get; set; }
            public string LinkUrl { get; set; }
            public bool HasLink { get; set; }
        }
    }
}





