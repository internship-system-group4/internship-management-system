// =============================================================================
//  Manage Tasks
//  Owner : Fatima
//  Cards : F01, F02
//
//  Create tasks with title, description, instructions, deadline, trainee and evaluation criteria, and list them with their submission statuses. Set each task's MaxScore and Weight from the university's method - not a flat 100.
//
//  Namespace note: these page namespaces end in "Area" on purpose. A namespace
//  called ...Pages.Student would hide the Student model class and every file in
//  the folder would fail to compile with "Student is a namespace but is used
//  like a type". Keep the suffix.
// =============================================================================
using System;
using System.Collections.Generic;
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

            if (title == "" || txtDescription.Text.Trim() == "" ||
                txtInstructions.Text.Trim() == "")
            {
                lblMessage.Text = "Enter the title, description and instructions.";
                return;
            }

            if (string.IsNullOrEmpty(placementId))
            {
                lblMessage.Text = "Please select a trainee.";
                return;
            }

            DateTime deadline;
            if (!DateTime.TryParse(txtDeadline.Text, out deadline) ||
                deadline <= DateTime.Now)
            {
                lblMessage.Text = "Enter a future deadline.";
                return;
            }

            double maxScore;
            if (!double.TryParse(txtMaxScore.Text, out maxScore) ||
                double.IsNaN(maxScore) || double.IsInfinity(maxScore) ||
                maxScore <= 0)
            {
                lblMessage.Text = "Enter a valid maximum score greater than zero.";
                return;
            }

            double weight;
            if (!double.TryParse(txtWeight.Text, out weight) ||
                double.IsNaN(weight) || double.IsInfinity(weight) ||
                weight <= 0)
            {
                lblMessage.Text = "Enter a valid task weight greater than zero.";
                return;
            }

            List<GradeComponent> criteria =
                Session["TaskCriteria"] as List<GradeComponent>;

            if (criteria == null || criteria.Count == 0)
            {
                lblMessage.Text = "Add at least one evaluation criterion.";
                return;
            }

            double totalCriteriaWeight = 0;
            foreach (GradeComponent criterion in criteria)
            {
                totalCriteriaWeight += criterion.Weight;
            }

            if (Math.Abs(totalCriteriaWeight - 100) > 0.01)
            {
                lblMessage.Text = "Evaluation criteria weights must total 100%.";
                return;
            }

            try
            {
                Placement placement =
                    new PlacementRepository().GetById(placementId);

                // لا نعتمد على اختيار القائمة وحده؛ نتحقق من الشركة في قاعدة البيانات.
                if (placement == null ||
                    placement.CompanyId != CurrentSupervisor.CompanyId ||
                    string.IsNullOrEmpty(placement.StudentId))
                {
                    lblMessage.Text = "The selected trainee does not belong to your company.";
                    return;
                }

                InternshipTask task = new InternshipTask();
                task.PlacementId = placement.Id;
                task.StudentId = placement.StudentId;
                task.CompanyId = CurrentSupervisor.CompanyId;
                task.CreatedBySupervisorId = CurrentSupervisor.Id;
                task.Title = title;
                task.Description = txtDescription.Text.Trim();
                task.Instructions = txtInstructions.Text.Trim();
                task.Deadline = new DateTimeOffset(deadline).ToUnixTimeMilliseconds();
                task.MaxScore = maxScore;
                task.Weight = weight;
                task.Criteria = new List<GradeComponent>(criteria);

                string taskId = new TaskRepository().Insert(task);

                if (string.IsNullOrEmpty(taskId))
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
                ddlTrainee.SelectedIndex = 0;

                Session["TaskCriteria"] = new List<GradeComponent>();
                gvCriteria.DataSource = new List<GradeComponent>();
                gvCriteria.DataBind();
                LoadCompanyTasks();
            }
            catch (FirebaseException)
            {
                lblMessage.Text = "Could not save the task. Please try again.";
            }
        }
        private void LoadTrainees()
        {
            ddlTrainee.Items.Clear();

            ddlTrainee.Items.Add(
                new ListItem("Select a trainee", "")
            );

            PlacementRepository repository = new PlacementRepository();

            List<Placement> placements = repository.GetAll();

            foreach (Placement placement in placements)
            {
                if (placement.CompanyId == CurrentSupervisor.CompanyId)
                {
                    ddlTrainee.Items.Add(
                        new ListItem(placement.StudentName, placement.Id)
                    );
                }
            }
        }
        

        protected void btnAddCriterion_Click(object sender, EventArgs e)
        {
            string name = txtCriterionName.Text.Trim();
            string description = txtCriterionDescription.Text.Trim();

            
            if (name == "")
            {
                lblMessage.CssClass = "text-danger";
                lblMessage.Text = "Please enter a criterion name.";
                return;
            }

            // نحول العلامة القصوى من نص لرقم
            double maxScore;

            bool validMaxScore = double.TryParse(
                txtCriterionMaxScore.Text,
                out maxScore
            );

            if (!validMaxScore || double.IsNaN(maxScore)
                || double.IsInfinity(maxScore) || maxScore <= 0)
            {
                lblMessage.CssClass = "text-danger";
                lblMessage.Text = "Enter a valid maximum score greater than zero.";
                return;
            }

            // نحول وزن المعيار من نص لرقم
            double weight;

            bool validWeight = double.TryParse(
                txtCriterionWeight.Text,
                out weight
            );

            if (!validWeight || double.IsNaN(weight)
                || double.IsInfinity(weight)
                || weight <= 0 || weight > 100)
            {
                lblMessage.CssClass = "text-danger";
                lblMessage.Text = "Enter a criterion weight greater than zero and up to 100.";
                return;
            }

            // نجيب القائمة المحفوظة مؤقتًا
            List<GradeComponent> criteria =
                Session["TaskCriteria"] as List<GradeComponent>;

            if (criteria == null)
            {
                lblMessage.CssClass = "text-danger";
                lblMessage.Text = "Your session expired. Reload the page and add the criteria again.";
                return;
            }

            // نحسب مجموع الأوزان مع المعيار الجديد
            double totalWeight = weight;

            foreach (GradeComponent item in criteria)
            {
                totalWeight = totalWeight + item.Weight;
            }

            if (totalWeight > 100.000001)
            {
                lblMessage.CssClass = "text-danger";
                lblMessage.Text = "The total criteria weight cannot exceed 100%.";
                return;
            }

            // نجهز المعيار الجديد
            GradeComponent criterion = new GradeComponent();

            criterion.Name = name;
            criterion.Description = description;
            criterion.MaxScore = maxScore;
            criterion.Weight = weight;

            // نضيفه للقائمة ونحفظ القائمة مؤقتًا
            criteria.Add(criterion);

            Session["TaskCriteria"] = criteria;

            // نعرض القائمة بالجدول
            gvCriteria.DataSource = criteria;
            gvCriteria.DataBind();

            // نفرغ حقول المعيار لإضافة معيار ثاني
            txtCriterionName.Text = "";
            txtCriterionDescription.Text = "";
            txtCriterionMaxScore.Text = "";
            txtCriterionWeight.Text = "";

            lblMessage.CssClass = "text-success";
            lblMessage.Text = "Criterion added successfully.";
        }
        private void LoadCompanyTasks()
        {
            List<CompanyTaskRow> rows = new List<CompanyTaskRow>();

            // نقرأ المهام والتسليمات ثم نعرض ما يخص شركة المشرف فقط.
            // Speed: tasks and submissions are read at the same time.
            FirebaseContext.Prefetch(
                FirebaseRead.Node(Constants.Paths.Tasks),
                FirebaseRead.Node(Constants.Paths.Submissions));
            List<InternshipTask> tasks = new TaskRepository().GetAll();
            List<Submission> submissions = new SubmissionRepository().GetAll();
            PlacementRepository placements = new PlacementRepository();

            // Speed: then each task's placement, all at the same time.
            List<FirebaseRead> placementReads = new List<FirebaseRead>();
            foreach (InternshipTask task in tasks)
            {
                if (task.CompanyId == CurrentSupervisor.CompanyId && ApplicationRepository.IsValidKey(task.PlacementId))
                    placementReads.Add(FirebaseRead.Node(Constants.Paths.Placements + "/" + task.PlacementId));
            }
            FirebaseContext.Prefetch(placementReads);

            foreach (InternshipTask task in tasks)
            {
                if (task.CompanyId != CurrentSupervisor.CompanyId) continue;

                Placement placement = placements.GetById(task.PlacementId);

                if (placement == null ||
                    placement.CompanyId != CurrentSupervisor.CompanyId ||
                    placement.StudentId != task.StudentId)
                {
                    continue;
                }

                Submission latest = null;

                foreach (Submission submission in submissions)
                {
                    if (submission.TaskId != task.Id ||
                        submission.PlacementId != task.PlacementId ||
                        submission.StudentId != task.StudentId)
                    {
                        continue;
                    }

                    if (latest == null ||
                        submission.AttemptNumber > latest.AttemptNumber ||
                        (submission.AttemptNumber == latest.AttemptNumber &&
                         submission.SubmittedAt > latest.SubmittedAt))
                    {
                        latest = submission;
                    }
                }

                rows.Add(new CompanyTaskRow
                {
                    Title = task.Title,
                    Trainee = string.IsNullOrWhiteSpace(placement.StudentName)
                        ? placement.StudentId
                        : placement.StudentName,
                    Deadline = task.Deadline > 0
                        ? DateTimeOffset.FromUnixTimeMilliseconds(task.Deadline)
                            .UtcDateTime.ToString("yyyy-MM-dd HH:mm") + " UTC"
                        : "Not set",
                    MaxScore = task.MaxScore,
                    Weight = task.Weight,
                    TaskStatus = task.Status.ToString(),
                    SubmissionStatus = latest == null
                        ? "Not submitted"
                        : latest.Status.ToString() + " (attempt " +
                          latest.AttemptNumber + ")"
                });
            }

            rptCompanyTasks.DataSource = rows;
            rptCompanyTasks.DataBind();
            lblNoCompanyTasks.Visible = rows.Count == 0;
        }

        public class CompanyTaskRow
        {
            public string Title { get; set; }
            public string Trainee { get; set; }
            public string Deadline { get; set; }
            public double MaxScore { get; set; }
            public double Weight { get; set; }
            public string TaskStatus { get; set; }
            public string SubmissionStatus { get; set; }
        }
    }

}