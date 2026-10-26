using System;
using System.Collections.Generic;
using System.Globalization;
using System.Web.Configuration;
using System.Web;
using System.Net;
using System.IO;
using System.Web.UI.WebControls;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.CompanyArea
{
    public partial class Tasks : CompanyPage
    {
        private const string AllTraineesValue = "__ALL_TRAINEES__";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Page.Form != null) Page.Form.Enctype = "multipart/form-data";
            if (!IsPostBack)
            {
                List<GradeComponent> criteria =
                    new List<GradeComponent>();

                Session["TaskCriteria"] = criteria;
                gvCriteria.DataSource = criteria;
                gvCriteria.DataBind();

                LoadTrainees();
                LoadCompanyTasks();
            }
        }

        protected void btnCreateTask_Click(object sender, EventArgs e)
        {
            lblMessage.CssClass = "text-danger d-block mt-2";
            lblMessage.Text = "";

            string title = txtTitle.Text.Trim();
            string description = txtDescription.Text.Trim();
            string instructions = txtInstructions.Text.Trim();
            string placementId = ddlTrainee.SelectedValue;

            if (title.Length == 0 || description.Length == 0 || instructions.Length == 0)
            {
                ShowMessage(L.T("Company.Tasks.EnterTheTitleDescriptionAndCriteria"), false);
                return;
            }
            if (string.IsNullOrWhiteSpace(placementId))
            {
                ShowMessage(L.T("Company.Tasks.PleaseSelectATrainee"), false);
                return;
            }

            DateTime startDate;
            // A start of "now" is fine: allow a few minutes for filling in the form.
            if (!TryParseTaskDateTime(txtStartDate.Text, out startDate) ||
                startDate < DateTime.Now.AddMinutes(-15))
            {
                ShowMessage(L.T("Company.Tasks.EnterAStartDateAndTime"), false);
                return;
            }

            DateTime deadline;
            if (!TryParseTaskDateTime(txtDeadline.Text, out deadline) ||
                deadline <= startDate)
            {
                ShowMessage(L.T("Company.Tasks.TheDeadlineMustBeAfterThe"), false);
                return;
            }

            double maxScore;
            if (!TryReadPositiveNumber(txtMaxScore.Text, out maxScore))
            {
                ShowMessage(L.T("Company.Tasks.EnterATotalScoreGreaterThan"), false);
                return;
            }

            string attachmentUrl = null;
            string attachmentName = null;
            string attachmentObjectName = null;
            List<string> createdTaskIds = new List<string>();
            int targetCount = 0;

            try
            {
                List<Placement> targetPlacements = GetTaskTargetPlacements(placementId);
                targetCount = targetPlacements.Count;
                if (targetCount == 0)
                {
                    ShowMessage(L.T("Company.Tasks.ThereAreNoTraineesAvailableFor"), false);
                    return;
                }

                if (fuTaskAttachment.HasFile)
                {
                    attachmentUrl = UploadTaskAttachment(
                        fuTaskAttachment.PostedFile, CurrentSupervisor.CompanyId,
                        out attachmentName, out attachmentObjectName);
                }

                DateTime localStart = DateTime.SpecifyKind(startDate, DateTimeKind.Local);
                DateTime localDeadline = DateTime.SpecifyKind(deadline, DateTimeKind.Local);
                long startTimestamp = new DateTimeOffset(localStart).ToUnixTimeMilliseconds();
                long deadlineTimestamp = new DateTimeOffset(localDeadline).ToUnixTimeMilliseconds();
                TaskRepository taskRepository = new TaskRepository();

                foreach (Placement placement in targetPlacements)
                {
                    List<GradeComponent> criteria = new List<GradeComponent>
                    {
                        new GradeComponent
                        {
                            Name = "Task grading criteria",
                            Description = instructions,
                            MaxScore = maxScore,
                            Weight = 100
                        }
                    };

                    InternshipTask task = new InternshipTask
                    {
                        PlacementId = placement.Id,
                        StudentId = placement.StudentId,
                        CompanyId = CurrentSupervisor.CompanyId,
                        CreatedBySupervisorId = CurrentSupervisor.Id,
                        Title = title,
                        Description = description,
                        Instructions = instructions,
                        StartDate = startTimestamp,
                        Deadline = deadlineTimestamp,
                        MaxScore = maxScore,
                        Weight = 1,
                        Criteria = criteria,
                        AttachmentUrl = attachmentUrl,
                        AttachmentName = attachmentName
                    };

                    string taskId = taskRepository.Insert(task);
                    if (string.IsNullOrWhiteSpace(taskId))
                        throw new InvalidOperationException("A task record could not be saved.");

                    createdTaskIds.Add(taskId);
                }

                ResetTaskForm();
                ShowMessage(targetCount == 1
                    ? L.T("Company.Tasks.TaskCreatedSuccessfully")
                    : L.F("Company.I18n.Taskcreatedsuccessfullyforall0trainees", targetCount), true);
                LoadCompanyTasks();
                ClientScript.RegisterStartupScript(
                    GetType(), "taskCreateSuccess",
                    "showTaskSuccessDialog(" + targetCount + ");", true);
            }
            catch (FirebaseException)
            {
                if (createdTaskIds.Count == 0) DeleteTaskAttachment(attachmentObjectName);
                ShowTaskCreationFailure(createdTaskIds.Count, targetCount,
                    L.T("Company.Tasks.CouldNotSaveTheTaskCheck"));
            }
            catch (WebException)
            {
                if (createdTaskIds.Count == 0) DeleteTaskAttachment(attachmentObjectName);
                ShowTaskCreationFailure(createdTaskIds.Count, targetCount,
                    L.T("Company.Tasks.TheFileCouldNotBeUploaded"));
            }
            catch (InvalidOperationException ex)
            {
                if (createdTaskIds.Count == 0) DeleteTaskAttachment(attachmentObjectName);
                ShowTaskCreationFailure(createdTaskIds.Count, targetCount,
                    Server.HtmlEncode(ex.Message));
            }
        }

        private static string UploadTaskAttachment(
            HttpPostedFile file, string companyId,
            out string originalName, out string objectName)
        {
            originalName = Path.GetFileName(file.FileName);
            objectName = null;
            string extension = Path.GetExtension(originalName).ToLowerInvariant();

            if (extension != ".pdf" && extension != ".doc" && extension != ".docx")
                throw new InvalidOperationException(L.T("Company.I18n.ChooseaPDForWordfile"));
            if (file.ContentLength <= 0 || file.ContentLength > 10 * 1024 * 1024)
                throw new InvalidOperationException(L.T("Company.I18n.Theattachmentmustbesmallerthan10"));

            string bucket = WebConfigurationManager.AppSettings["Firebase.StorageBucket"];
            if (string.IsNullOrWhiteSpace(bucket))
            {
                // No Firebase Storage bucket: keep the file on the server instead,
                // the same way student submissions are kept.
                string storageName;
                string localUrl = Services.TaskAttachmentStorage.SaveLocal(file, companyId, out storageName);
                objectName = LocalPrefix + companyId + "/" + storageName;
                return localUrl;
            }

            bucket = bucket.Trim();
            if (bucket.StartsWith("gs://", StringComparison.OrdinalIgnoreCase))
                bucket = bucket.Substring(5).TrimEnd('/');

            string idToken = HttpContext.Current.Session[Constants.SessionTokenKey] as string;
            if (string.IsNullOrWhiteSpace(idToken))
                throw new InvalidOperationException(L.T("Company.I18n.YoursessionexpiredSigninagainbefore"));

            objectName = "task-attachments/" + companyId + "/" +
                Guid.NewGuid().ToString("N") + extension;

            byte[] bytes = new byte[file.ContentLength];
            int totalRead = 0;
            while (totalRead < bytes.Length)
            {
                int count = file.InputStream.Read(bytes, totalRead, bytes.Length - totalRead);
                if (count <= 0) break;
                totalRead += count;
            }
            if (totalRead != bytes.Length)
                throw new InvalidOperationException(L.T("Company.I18n.Theattachmentcouldnotberead"));

            string uploadUrl = "https://firebasestorage.googleapis.com/v0/b/" +
                Uri.EscapeDataString(bucket) + "/o?uploadType=media&name=" +
                Uri.EscapeDataString(objectName);
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(uploadUrl);
            request.Method = "POST";
            request.ContentType = string.IsNullOrWhiteSpace(file.ContentType)
                ? "application/octet-stream" : file.ContentType;
            request.Headers[HttpRequestHeader.Authorization] = "Bearer " + idToken;
            request.ContentLength = bytes.Length;
            request.Timeout = 60000;

            using (Stream requestStream = request.GetRequestStream())
                requestStream.Write(bytes, 0, bytes.Length);

            string responseText;
            using (HttpWebResponse response = (HttpWebResponse)request.GetResponse())
            using (StreamReader reader = new StreamReader(response.GetResponseStream()))
                responseText = reader.ReadToEnd();

            Dictionary<string, object> responseMap = Json.ToMap(responseText);
            object tokenValue;
            string downloadToken = responseMap != null &&
                responseMap.TryGetValue("downloadTokens", out tokenValue)
                    ? Convert.ToString(tokenValue) : null;
            if (string.IsNullOrWhiteSpace(downloadToken))
                throw new InvalidOperationException(L.T("Company.I18n.Firebasedidnotreturnadownloadtoken"));

            return "https://firebasestorage.googleapis.com/v0/b/" +
                Uri.EscapeDataString(bucket) + "/o/" +
                Uri.EscapeDataString(objectName) +
                "?alt=media&token=" + Uri.EscapeDataString(downloadToken);
        }

        // Marks an attachment kept on the server (see TaskAttachmentStorage).
        private const string LocalPrefix = "local:";

        private static void DeleteTaskAttachment(string objectName)
        {
            if (string.IsNullOrWhiteSpace(objectName)) return;
            if (objectName.StartsWith(LocalPrefix, StringComparison.Ordinal))
            {
                string[] parts = objectName.Substring(LocalPrefix.Length).Split('/');
                if (parts.Length == 2) Services.TaskAttachmentStorage.DeleteLocal(parts[0], parts[1]);
                return;
            }
            try
            {
                string bucket = WebConfigurationManager.AppSettings["Firebase.StorageBucket"];
                string idToken = HttpContext.Current.Session[Constants.SessionTokenKey] as string;
                if (string.IsNullOrWhiteSpace(bucket) || string.IsNullOrWhiteSpace(idToken)) return;

                bucket = bucket.Trim();
                if (bucket.StartsWith("gs://", StringComparison.OrdinalIgnoreCase))
                    bucket = bucket.Substring(5).TrimEnd('/');

                string deleteUrl = "https://firebasestorage.googleapis.com/v0/b/" +
                    Uri.EscapeDataString(bucket) + "/o/" +
                    Uri.EscapeDataString(objectName);
                HttpWebRequest request = (HttpWebRequest)WebRequest.Create(deleteUrl);
                request.Method = "DELETE";
                request.Headers[HttpRequestHeader.Authorization] = "Bearer " + idToken;
                request.Timeout = 15000;
                using (HttpWebResponse response = (HttpWebResponse)request.GetResponse()) { }
            }
            catch
            {
                // Keep cleanup failures from hiding the task-save error.
            }
        }

        protected void btnAddCriterion_Click(object sender, EventArgs e)
        {
            string name = txtCriterionName.Text.Trim();
            string description = txtCriterionDescription.Text.Trim();

            if (name.Length == 0)
            {
                ShowMessage(L.T("Company.Tasks.PleaseEnterACriterionName"), false);
                return;
            }

            double maxScore;
            if (!TryReadPositiveNumber(
                    txtCriterionMaxScore.Text,
                    out maxScore))
            {
                ShowMessage(
                    L.T("Company.Tasks.EnterAValidCriterionMaximumScore"),
                    false);
                return;
            }

            double weight;
            if (!TryReadPositiveNumber(
                    txtCriterionWeight.Text,
                    out weight) ||
                weight > 100)
            {
                ShowMessage(
                    L.T("Company.Tasks.EnterACriterionWeightGreaterThan"),
                    false);
                return;
            }

            List<GradeComponent> criteria =
                Session["TaskCriteria"] as List<GradeComponent>;

            if (criteria == null)
            {
                ShowMessage(
                    L.T("Company.Tasks.YourSessionExpiredReloadThePage"),
                    false);
                return;
            }

            double totalWeight = weight;
            foreach (GradeComponent existing in criteria)
            {
                totalWeight += existing.Weight;
            }

            if (totalWeight > 100.000001)
            {
                ShowMessage(
                    L.T("Company.Tasks.TheTotalCriteriaWeightCannotExceed"),
                    false);
                return;
            }

            criteria.Add(new GradeComponent
            {
                Name = name,
                Description = description,
                MaxScore = maxScore,
                Weight = weight
            });

            Session["TaskCriteria"] = criteria;
            gvCriteria.DataSource = criteria;
            gvCriteria.DataBind();

            txtCriterionName.Text = "";
            txtCriterionDescription.Text = "";
            txtCriterionMaxScore.Text = "";
            txtCriterionWeight.Text = "";

            ShowMessage(L.T("Company.Tasks.CriterionAddedSuccessfully"), true);
        }

        private List<Placement> GetTaskTargetPlacements(string placementId)
        {
            PlacementRepository placementRepository = new PlacementRepository();
            List<Placement> targets = new List<Placement>();

            if (string.Equals(placementId, AllTraineesValue, StringComparison.Ordinal))
            {
                List<Placement> companyPlacements =
                    placementRepository.GetByCompany(CurrentSupervisor.CompanyId);

                if (companyPlacements == null) return targets;

                foreach (Placement placement in companyPlacements)
                {
                    if (placement != null &&
                        placement.CompanyId == CurrentSupervisor.CompanyId &&
                        !string.IsNullOrWhiteSpace(placement.StudentId))
                    {
                        targets.Add(placement);
                    }
                }

                return targets;
            }

            Placement selected = placementRepository.GetById(placementId);
            if (selected == null ||
                selected.CompanyId != CurrentSupervisor.CompanyId ||
                string.IsNullOrWhiteSpace(selected.StudentId))
            {
                throw new InvalidOperationException(
                    L.T("Company.I18n.Theselectedtraineedoesnotbelongto"));
            }

            targets.Add(selected);
            return targets;
        }

        private void ShowTaskCreationFailure(int createdCount, int targetCount, string error)
        {
            if (createdCount > 0)
            {
                ShowMessage(
                    "Tasks were saved for " + createdCount + " of " + targetCount +
                    " trainees. Those saved tasks remain assigned. " + error,
                    false);
                return;
            }

            ShowMessage(error, false);
        }

        private void LoadTrainees()
        {
            ddlTrainee.Items.Clear();
            ddlTrainee.Items.Add(
                new ListItem(L.T("Company.Tasks.SelectATrainee2"), "")
            );

            try
            {
                // الشركة ترى placements التابعة لها فقط.
                List<Placement> placements =
                    new PlacementRepository()
                        .GetByCompany(CurrentSupervisor.CompanyId);

                foreach (Placement placement in placements)
                {
                    if (placement == null ||
                        placement.CompanyId != CurrentSupervisor.CompanyId ||
                        string.IsNullOrWhiteSpace(placement.StudentId))
                    {
                        continue;
                    }

                    string name =
                        string.IsNullOrWhiteSpace(placement.StudentName)
                            ? placement.StudentId
                            : placement.StudentName;

                    ddlTrainee.Items.Add(
                        new ListItem(name, placement.Id)
                    );
                }

                if (ddlTrainee.Items.Count > 1)
                {
                    ddlTrainee.Items.Insert(
                        1,
                        new ListItem(L.T("Company.Tasks.AllMyTrainees"), AllTraineesValue));
                }
            }
            catch (FirebaseException)
            {
                lblNoCompanyTasks.Visible = true;
                lblNoCompanyTasks.Text =
                    L.T("Company.Tasks.CouldNotLoadTraineesFromFirebase");
            }
        }

        private void LoadCompanyTasks()
        {
            string requestedStudentId = Request.QueryString["studentId"];
            string selectedTraineeName = "";

            List<CompanyTaskRow> rows =
                new List<CompanyTaskRow>();

            int pendingCount = 0;
            int reviewedCount = 0;
            int overdueCount = 0;

            try
            {
                // لا تجلب التاسكات من كل الشركات.
                List<InternshipTask> tasks =
                    new TaskRepository()
                        .GetByCompany(CurrentSupervisor.CompanyId);

                SubmissionRepository submissionRepository =
                    new SubmissionRepository();

                TaskEvaluationRepository evaluationRepository =
                    new TaskEvaluationRepository();

                PlacementRepository placementRepository =
                    new PlacementRepository();

                UserRepository userRepository =
                    new UserRepository();

                Dictionary<string, Student> studentCache =
                    new Dictionary<string, Student>();

                foreach (InternshipTask task in tasks)
                {
                    if (task == null ||
                        task.CompanyId != CurrentSupervisor.CompanyId)
                    {
                        continue;
                    }

                    Placement placement =
                        placementRepository.GetById(task.PlacementId);

                    // تحقق أن التاسك مرتبط بمتدرب وplacement صحيحين.
                    if (placement == null ||
                        placement.CompanyId != CurrentSupervisor.CompanyId ||
                        placement.StudentId != task.StudentId)
                    {
                        continue;
                    }

                    if (!string.IsNullOrWhiteSpace(requestedStudentId) &&
                        !string.Equals(task.StudentId, requestedStudentId, StringComparison.Ordinal))
                    {
                        continue;
                    }

                    if (!string.IsNullOrWhiteSpace(placement.StudentName))
                    {
                        selectedTraineeName = placement.StudentName;
                    }

                    Student student;
                    if (!studentCache.TryGetValue(task.StudentId, out student))
                    {
                        student = userRepository.GetStudent(task.StudentId);
                        studentCache[task.StudentId] = student;
                    }

                    string department = "—";
                    if (student != null)
                    {
                        if (!string.IsNullOrWhiteSpace(student.Major))
                        {
                            department = student.Major;
                        }
                        else if (!string.IsNullOrWhiteSpace(student.College))
                        {
                            department = student.College;
                        }
                    }

                    string traineeName =
                        string.IsNullOrWhiteSpace(placement.StudentName)
                            ? task.StudentId
                            : placement.StudentName;

                    // جلب تسليمات هذا التاسك فقط.
                    List<Submission> submissions =
                        submissionRepository.GetByTask(task.Id);

                    Submission latestSubmission = null;

                    foreach (Submission submission in submissions)
                    {
                        if (submission == null ||
                            submission.TaskId != task.Id ||
                            submission.PlacementId != task.PlacementId ||
                            submission.StudentId != task.StudentId)
                        {
                            continue;
                        }

                        if (latestSubmission == null ||
                            submission.AttemptNumber >
                                latestSubmission.AttemptNumber ||
                            (submission.AttemptNumber ==
                                latestSubmission.AttemptNumber &&
                             submission.SubmittedAt >
                                latestSubmission.SubmittedAt))
                        {
                            latestSubmission = submission;
                        }
                    }

                    bool needsReview =
                        latestSubmission != null &&
                        (task.Status == InternshipTaskStatus.Submitted ||
                         task.Status == InternshipTaskStatus.Resubmitted ||
                         task.Status == InternshipTaskStatus.UnderReview);

                    if (needsReview)
                    {
                        pendingCount++;
                    }

                    if (task.Status == InternshipTaskStatus.Graded)
                    {
                        reviewedCount++;
                    }

                    if (task.IsOverdue)
                    {
                        overdueCount++;
                    }

                    string evaluationSummary = L.T("Company.Tasks.NotEvaluated");

                    if (latestSubmission != null)
                    {
                        // جلب تقييمات هذا التاسك فقط.
                        List<TaskEvaluation> evaluations =
                            evaluationRepository.GetByTask(task.Id);

                        TaskEvaluation latestEvaluation = null;

                        foreach (TaskEvaluation evaluation in evaluations)
                        {
                            if (evaluation == null ||
                                evaluation.SubmissionId != latestSubmission.Id ||
                                evaluation.StudentId != task.StudentId ||
                                evaluation.PlacementId != task.PlacementId)
                            {
                                continue;
                            }

                            if (latestEvaluation == null ||
                                evaluation.EvaluatedAt >
                                    latestEvaluation.EvaluatedAt)
                            {
                                latestEvaluation = evaluation;
                            }
                        }

                        if (latestEvaluation != null)
                        {
                            evaluationSummary =
                                latestEvaluation.RevisionRequested
                                    ? L.T("Company.Tasks.FeedbackSent")
                                    : latestEvaluation.TotalScore.ToString("0.##") +
                                      " / " +
                                      latestEvaluation.MaxScore.ToString("0.##");
                        }
                    }

                    rows.Add(new CompanyTaskRow
                    {
                        TaskId = task.Id,
                        StudentId = task.StudentId,
                        Title = task.Title,
                        Trainee = traineeName,
                        Department = department,

                        StartDate = task.StartDate > 0
                            ? DateTimeOffset
                                .FromUnixTimeMilliseconds(task.StartDate)
                                .ToLocalTime()
                                .ToString("dd MMM yyyy, h:mm tt")
                            : L.T("Company.Tasks.NotSet"),
                        Deadline = task.Deadline > 0
                            ? DateTimeOffset
                                .FromUnixTimeMilliseconds(task.Deadline)
                                .ToLocalTime()
                                .ToString("dd MMM yyyy, h:mm tt")
                            : L.T("Company.Tasks.NotSet"),
                        Description = task.Description ?? "",
                        Instructions = task.Instructions ?? "",
                        MaxScore = task.MaxScore.ToString("0.##", CultureInfo.InvariantCulture),
                        AttachmentName = task.AttachmentName ?? "",
                        AttachmentUrl = IsSafeTaskAttachmentUrl(task.AttachmentUrl)
                            ? task.AttachmentUrl
                            : "",

                        SubmissionStatus = latestSubmission == null
                            ? L.T("Company.Tasks.NotSubmitted")
                            : latestSubmission.Status.ToString(),

                        TaskStatus = task.Status.ToString(),
                        TaskStatusLabel = GetTaskStatusLabel(task.Status),
                        TaskStatusCss = GetTaskStatusCss(task.Status),
                        NeedsReview = needsReview,
                        EvaluationSummary = evaluationSummary
                    });
                }

                rptCompanyTasks.DataSource = rows;
                rptCompanyTasks.DataBind();

                pnlStudentTaskFilter.Visible =
                    !string.IsNullOrWhiteSpace(requestedStudentId);
                lblStudentTaskFilterName.Text =
                    Server.HtmlEncode(string.IsNullOrWhiteSpace(selectedTraineeName)
                        ? "selected trainee"
                        : selectedTraineeName);

                lblNoCompanyTasks.Visible = rows.Count == 0;
                if (rows.Count == 0)
                {
                    lblNoCompanyTasks.Text =
                        L.T("Company.Tasks.NoTasksYetCreateYourFirst");
                }

                litPendingReview.Text = pendingCount.ToString();
                litReviewedTasks.Text = reviewedCount.ToString();
                litOverdueTasks.Text = overdueCount.ToString();
                litTaskCount.Text = rows.Count.ToString();
            }
            catch (FirebaseException)
            {
                rptCompanyTasks.DataSource = new List<CompanyTaskRow>();
                rptCompanyTasks.DataBind();

                lblNoCompanyTasks.Visible = true;
                lblNoCompanyTasks.Text =
                    L.T("Company.Tasks.CouldNotLoadTasksCheckFirebase");

                litPendingReview.Text = "—";
                litReviewedTasks.Text = "—";
                litOverdueTasks.Text = "—";
                litTaskCount.Text = "0";
            }
        }

        private static string GetTaskStatusLabel(
            InternshipTaskStatus status)
        {
            switch (status)
            {
                case InternshipTaskStatus.Submitted:
                case InternshipTaskStatus.Resubmitted:
                case InternshipTaskStatus.UnderReview:
                    return "Pending review";

                case InternshipTaskStatus.Graded:
                    return "Reviewed";

                case InternshipTaskStatus.RevisionRequested:
                    return "Revision needed";

                default:
                    return "In progress";
            }
        }

        private static string GetTaskStatusCss(
            InternshipTaskStatus status)
        {
            switch (status)
            {
                case InternshipTaskStatus.Submitted:
                case InternshipTaskStatus.Resubmitted:
                case InternshipTaskStatus.UnderReview:
                    return "tasks-status-badge tasks-status-pending";

                case InternshipTaskStatus.Graded:
                    return "tasks-status-badge tasks-status-reviewed";

                case InternshipTaskStatus.RevisionRequested:
                    return "tasks-status-badge tasks-status-revision";

                default:
                    return "tasks-status-badge tasks-status-progress";
            }
        }

        private static bool TryParseTaskDateTime(string value, out DateTime dateTime)
        {
            string[] acceptedFormats =
            {
                "yyyy-MM-dd'T'HH:mm",
                "yyyy-MM-dd'T'HH:mm:ss",
                "yyyy-MM-dd'T'HH:mm:ss.FFF"
            };

            if (DateTime.TryParseExact(
                    value,
                    acceptedFormats,
                    CultureInfo.InvariantCulture,
                    DateTimeStyles.None,
                    out dateTime))
            {
                return true;
            }

            return DateTime.TryParse(
                value,
                CultureInfo.CurrentCulture,
                DateTimeStyles.AllowWhiteSpaces,
                out dateTime);
        }

        private static bool TryReadPositiveNumber(
            string value,
            out double number)
        {
            bool parsed = double.TryParse(
                value,
                NumberStyles.Float,
                CultureInfo.CurrentCulture,
                out number);

            if (!parsed)
            {
                parsed = double.TryParse(
                    value,
                    NumberStyles.Float,
                    CultureInfo.InvariantCulture,
                    out number);
            }

            return parsed &&
                   !double.IsNaN(number) &&
                   !double.IsInfinity(number) &&
                   number > 0;
        }

        private void ShowMessage(string message, bool success)
        {
            lblMessage.CssClass = success
                ? "text-success"
                : "text-danger";

            lblMessage.Text = message;
        }

        private void ResetTaskForm()
        {
            txtTitle.Text = "";
            txtDescription.Text = "";
            txtInstructions.Text = "";
            txtStartDate.Text = "";
            txtDeadline.Text = "";
            txtMaxScore.Text = "";
            txtWeight.Text = "";

            if (ddlTrainee.Items.Count > 0)
            {
                ddlTrainee.SelectedIndex = 0;
            }

            List<GradeComponent> emptyCriteria =
                new List<GradeComponent>();

            Session["TaskCriteria"] = emptyCriteria;
            gvCriteria.DataSource = emptyCriteria;
            gvCriteria.DataBind();
        }

        private static bool IsSafeTaskAttachmentUrl(string value)
        {
            Uri attachmentUri;
            return Uri.TryCreate(value, UriKind.Absolute, out attachmentUri) &&
                   (attachmentUri.Scheme == Uri.UriSchemeHttps ||
                    attachmentUri.Scheme == Uri.UriSchemeHttp);
        }

        public class CompanyTaskRow
        {
            public string TaskId { get; set; }
            public string StudentId { get; set; }
            public string Title { get; set; }
            public string Trainee { get; set; }
            public string Department { get; set; }
            public string StartDate { get; set; }
            public string Deadline { get; set; }
            public string Description { get; set; }
            public string Instructions { get; set; }
            public string MaxScore { get; set; }
            public string AttachmentName { get; set; }
            public string AttachmentUrl { get; set; }
            public string SubmissionStatus { get; set; }
            public string TaskStatus { get; set; }
            public string TaskStatusLabel { get; set; }
            public string TaskStatusCss { get; set; }
            public bool NeedsReview { get; set; }
            public string EvaluationSummary { get; set; }
        }
    }
}


