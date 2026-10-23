using System;
using System.Collections.Generic;
using System.Globalization;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;
using System.Web.UI.WebControls;

namespace InternshipManagementSystem.Pages.CompanyArea
{
    public partial class Tasks : CompanyPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
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
            lblMessage.CssClass = "text-danger";
            lblMessage.Text = "";

            string title = txtTitle.Text.Trim();
            string placementId = ddlTrainee.SelectedValue;

            if (title.Length == 0 ||
                txtDescription.Text.Trim().Length == 0 ||
                txtInstructions.Text.Trim().Length == 0)
            {
                lblMessage.Text =
                    "Enter the title, description and instructions.";
                return;
            }

            if (string.IsNullOrWhiteSpace(placementId))
            {
                lblMessage.Text = "Please select a trainee.";
                return;
            }

            DateTime deadline;
            if (!DateTime.TryParse(
                    txtDeadline.Text,
                    CultureInfo.CurrentCulture,
                    DateTimeStyles.None,
                    out deadline) ||
                deadline <= DateTime.Now)
            {
                lblMessage.Text = "Enter a future deadline.";
                return;
            }

            double maxScore;
            if (!double.TryParse(
                    txtMaxScore.Text,
                    NumberStyles.Float,
                    CultureInfo.CurrentCulture,
                    out maxScore) ||
                double.IsNaN(maxScore) ||
                double.IsInfinity(maxScore) ||
                maxScore <= 0)
            {
                lblMessage.Text =
                    "Enter a valid maximum score greater than zero.";
                return;
            }

            double weight;
            if (!double.TryParse(
                    txtWeight.Text,
                    NumberStyles.Float,
                    CultureInfo.CurrentCulture,
                    out weight) ||
                double.IsNaN(weight) ||
                double.IsInfinity(weight) ||
                weight <= 0)
            {
                lblMessage.Text =
                    "Enter a valid task weight greater than zero.";
                return;
            }

            List<GradeComponent> criteria =
                Session["TaskCriteria"] as List<GradeComponent>;

            if (criteria == null || criteria.Count == 0)
            {
                lblMessage.Text =
                    "Add at least one evaluation criterion.";
                return;
            }

            double totalCriteriaWeight = 0;

            foreach (GradeComponent criterion in criteria)
            {
                totalCriteriaWeight += criterion.Weight;
            }

            if (Math.Abs(totalCriteriaWeight - 100) > 0.01)
            {
                lblMessage.Text =
                    "Evaluation criteria weights must total 100%.";
                return;
            }

            try
            {
                Placement placement =
                    new PlacementRepository().GetById(placementId);

                // تأكد أن المتدرب المختار تابع لشركة المشرف الحالي.
                if (placement == null ||
                    placement.CompanyId != CurrentSupervisor.CompanyId ||
                    string.IsNullOrWhiteSpace(placement.StudentId))
                {
                    lblMessage.Text =
                        "The selected trainee does not belong to your company.";
                    return;
                }

                InternshipTask task = new InternshipTask
                {
                    PlacementId = placement.Id,
                    StudentId = placement.StudentId,
                    CompanyId = CurrentSupervisor.CompanyId,
                    CreatedBySupervisorId = CurrentSupervisor.Id,
                    Title = title,
                    Description = txtDescription.Text.Trim(),
                    Instructions = txtInstructions.Text.Trim(),
                    Deadline =
                        new DateTimeOffset(deadline).ToUnixTimeMilliseconds(),
                    MaxScore = maxScore,
                    Weight = weight,
                    Criteria = new List<GradeComponent>(criteria)
                };

                string taskId = new TaskRepository().Insert(task);

                if (string.IsNullOrWhiteSpace(taskId))
                {
                    lblMessage.Text = "Task could not be saved.";
                    return;
                }

                lblMessage.CssClass = "text-success";
                lblMessage.Text = "Task created successfully.";

                txtTitle.Text = "";
                txtDescription.Text = "";
                txtInstructions.Text = "";
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

                LoadCompanyTasks();
            }
            catch (FirebaseException)
            {
                lblMessage.CssClass = "text-danger";
                lblMessage.Text =
                    "Could not save the task. Please check Firebase and try again.";
            }
        }

        private void LoadTrainees()
        {
            ddlTrainee.Items.Clear();
            ddlTrainee.Items.Add(
                new ListItem("Select a trainee", "")
            );

            try
            {
                // جلب placements الخاصة بهذه الشركة فقط.
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

                    string traineeName =
                        string.IsNullOrWhiteSpace(placement.StudentName)
                            ? placement.StudentId
                            : placement.StudentName;

                    ddlTrainee.Items.Add(
                        new ListItem(traineeName, placement.Id)
                    );
                }
            }
            catch (FirebaseException)
            {
                lblNoCompanyTasks.Visible = true;
                lblNoCompanyTasks.Text =
                    "Could not load trainees from Firebase. Check the database connection.";
            }
        }

        protected void btnAddCriterion_Click(object sender, EventArgs e)
        {
            string name = txtCriterionName.Text.Trim();
            string description = txtCriterionDescription.Text.Trim();

            if (name.Length == 0)
            {
                lblMessage.CssClass = "text-danger";
                lblMessage.Text = "Please enter a criterion name.";
                return;
            }

            double maxScore;
            bool validMaxScore = double.TryParse(
                txtCriterionMaxScore.Text,
                NumberStyles.Float,
                CultureInfo.CurrentCulture,
                out maxScore);

            if (!validMaxScore ||
                double.IsNaN(maxScore) ||
                double.IsInfinity(maxScore) ||
                maxScore <= 0)
            {
                lblMessage.CssClass = "text-danger";
                lblMessage.Text =
                    "Enter a valid maximum score greater than zero.";
                return;
            }

            double weight;
            bool validWeight = double.TryParse(
                txtCriterionWeight.Text,
                NumberStyles.Float,
                CultureInfo.CurrentCulture,
                out weight);

            if (!validWeight ||
                double.IsNaN(weight) ||
                double.IsInfinity(weight) ||
                weight <= 0 ||
                weight > 100)
            {
                lblMessage.CssClass = "text-danger";
                lblMessage.Text =
                    "Enter a criterion weight greater than zero and up to 100.";
                return;
            }

            List<GradeComponent> criteria =
                Session["TaskCriteria"] as List<GradeComponent>;

            if (criteria == null)
            {
                lblMessage.CssClass = "text-danger";
                lblMessage.Text =
                    "Your session expired. Reload the page and add the criteria again.";
                return;
            }

            double totalWeight = weight;

            foreach (GradeComponent criterion in criteria)
            {
                totalWeight += criterion.Weight;
            }

            if (totalWeight > 100.000001)
            {
                lblMessage.CssClass = "text-danger";
                lblMessage.Text =
                    "The total criteria weight cannot exceed 100%.";
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

            lblMessage.CssClass = "text-success";
            lblMessage.Text = "Criterion added successfully.";
        }

        private void LoadCompanyTasks()
        {
            List<CompanyTaskRow> rows =
                new List<CompanyTaskRow>();

            int pendingReviewCount = 0;
            int reviewedCount = 0;
            int overdueCount = 0;

            try
            {
                // لا تحمل التاسكات التابعة لكل الشركات.
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

                // تخزين مؤقت داخل الطلب الحالي لتجنب قراءة الطالب أكثر من مرة.
                Dictionary<string, Student> students =
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

                    // تأكد من ارتباط التاسك بالـplacement الصحيح.
                    if (placement == null ||
                        placement.CompanyId != CurrentSupervisor.CompanyId ||
                        placement.StudentId != task.StudentId)
                    {
                        continue;
                    }

                    Student student;
                    if (!students.TryGetValue(task.StudentId, out student))
                    {
                        student = userRepository.GetStudent(task.StudentId);
                        students[task.StudentId] = student;
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
                        pendingReviewCount++;
                    }

                    if (task.Status == InternshipTaskStatus.Graded)
                    {
                        reviewedCount++;
                    }

                    if (task.IsOverdue)
                    {
                        overdueCount++;
                    }

                    string evaluationSummary = "Not evaluated";

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
                                    ? "Feedback sent"
                                    : latestEvaluation.TotalScore.ToString("0.##") +
                                      " / " +
                                      latestEvaluation.MaxScore.ToString("0.##");
                        }
                    }

                    rows.Add(new CompanyTaskRow
                    {
                        TaskId = task.Id,
                        Title = task.Title,
                        Trainee = traineeName,
                        Department = department,

                        Deadline = task.Deadline > 0
                            ? DateTimeOffset
                                .FromUnixTimeMilliseconds(task.Deadline)
                                .ToLocalTime()
                                .ToString("dd MMM yyyy")
                            : "Not set",

                        SubmissionStatus = latestSubmission == null
                            ? "Not submitted"
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

                lblNoCompanyTasks.Visible = rows.Count == 0;

                if (rows.Count == 0)
                {
                    lblNoCompanyTasks.Text =
                        "No tasks yet. Create your first task to get started.";
                }

                litPendingReview.Text = pendingReviewCount.ToString();
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
                    "Could not load tasks from Firebase. Check the database connection and rules.";

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

        public class CompanyTaskRow
        {
            public string TaskId { get; set; }
            public string Title { get; set; }
            public string Trainee { get; set; }
            public string Department { get; set; }
            public string Deadline { get; set; }
            public string SubmissionStatus { get; set; }
            public string TaskStatus { get; set; }
            public string TaskStatusLabel { get; set; }
            public string TaskStatusCss { get; set; }
            public bool NeedsReview { get; set; }
            public string EvaluationSummary { get; set; }
        }
    }
}