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
            }
        }
        protected void btnCreateTask_Click(object sender, EventArgs e)
        {
            string title = txtTitle.Text.Trim();
            string placementId = ddlTrainee.SelectedValue;

            lblMessage.CssClass = "text-danger";

            if (title == "")
            {
                lblMessage.Text = "Please enter a task title.";
                return;
            }

            if (placementId == "")
            {
                lblMessage.Text = "Please select a trainee.";
                return;
            }

            lblMessage.CssClass = "text-success";
            lblMessage.Text = "Title and trainee selected. Task is not saved yet.";
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
    }
}