// =============================================================================
//  Manage Tasks
//  Owner : Fatima
//  Cards : F01, F02
//
//  Create tasks with title, description, instructions, deadline, trainee and
//  evaluation criteria, and list them.
//
//  Grading is kept simple: the supervisor gives each criterion a number of
//  points. The task's MaxScore is the sum of those points, and each
//  criterion's Weight (its share of the task, in %) is worked out from them.
//  So there is only one number to type per criterion and no flat 100.
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

namespace InternshipManagementSystem.Pages.CompanyArea
{
    public partial class Tasks : CompanyPage
    {
        private const string CriteriaKey = "TaskCriteria";
        private const string CreatedKey = "TaskCreatedMessage";
        private const int MinPoints = 1;
        private const int MaxPoints = 100;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Session[CriteriaKey] = new List<GradeComponent>();
                LoadTrainees();
                LoadTasks();
                ShowCriteria(new List<GradeComponent>());

                // Message from the task that was just saved.
                string created = Session[CreatedKey] as string;
                if (created != null)
                {
                    Session.Remove(CreatedKey);
                    lblPageMessage.Visible = true;
                    lblPageMessage.CssClass = "alert alert-success d-block mb-4";
                    lblPageMessage.Text = Server.HtmlEncode(created);
                    ClientScript.RegisterStartupScript(GetType(), "closeTaskForm", "showTasksList();", true);
                }
            }
        }

        // ------------------------------------------------------------------
        //  Criteria
        // ------------------------------------------------------------------

        protected void btnAddCriterion_Click(object sender, EventArgs e)
        {
            List<GradeComponent> criteria = GetCriteria();
            if (criteria == null) return;

            string name = txtCriterionName.Text.Trim();
            if (name == "")
            {
                ShowError(L.T("Company.Tasks.WriteWhatYouWillCheckFor"));
                return;
            }

            foreach (GradeComponent item in criteria)
            {
                if (string.Equals(item.Name, name, StringComparison.OrdinalIgnoreCase))
                {
                    ShowError("\"" + name + "\" is already in the list.");
                    return;
                }
            }

            int points;
            if (!int.TryParse(txtCriterionPoints.Text.Trim(), out points)
                || points < MinPoints || points > MaxPoints)
            {
                ShowError(L.F("Company.Tasks.PointsMustBeAWholeNumberFrom", MinPoints, MaxPoints));
                return;
            }

            GradeComponent criterion = new GradeComponent();
            criterion.Name = name;
            criterion.Description = txtCriterionDescription.Text.Trim();
            criterion.MaxScore = points;
            criteria.Add(criterion);

            SaveCriteria(criteria);

            // Clear the fields so the next criterion can be typed.
            txtCriterionName.Text = "";
            txtCriterionDescription.Text = "";
            txtCriterionPoints.Text = "";
        }

        protected void btnUseStarter_Click(object sender, EventArgs e)
        {
            List<GradeComponent> criteria = GetCriteria();
            if (criteria == null) return;

            if (criteria.Count == 0)
            {
                criteria.Add(NewCriterion("Quality of work", 10, "Correct, clean and well organised."));
                criteria.Add(NewCriterion("Completeness", 5, "Everything in the instructions is done."));
                criteria.Add(NewCriterion("On time", 5, "Submitted before the deadline."));
            }

            SaveCriteria(criteria);
        }

        protected void gvCriteria_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "RemoveCriterion") return;

            List<GradeComponent> criteria = GetCriteria();
            if (criteria == null) return;

            int index;
            if (int.TryParse(Convert.ToString(e.CommandArgument), out index)
                && index >= 0 && index < criteria.Count)
            {
                criteria.RemoveAt(index);
            }

            SaveCriteria(criteria);
        }

        // ------------------------------------------------------------------
        //  Create task
        // ------------------------------------------------------------------

        protected void btnCreateTask_Click(object sender, EventArgs e)
        {
            List<GradeComponent> criteria = GetCriteria();
            if (criteria == null) return;

            string title = txtTitle.Text.Trim();
            if (title == "")
            {
                ShowError(L.T("Company.Tasks.PleaseEnterATaskTitle"));
                return;
            }

            string placementId = ddlTrainee.SelectedValue;
            Placement placement = FindMyPlacement(placementId);
            if (placement == null)
            {
                ShowError(L.T("Company.Tasks.PleaseChooseATrainee"));
                return;
            }

            DateTime deadline;
            if (!DateTime.TryParse(txtDeadline.Text, out deadline))
            {
                ShowError(L.T("Company.Tasks.PleaseChooseADeadline"));
                return;
            }

            if (deadline <= DateTime.Now)
            {
                ShowError(L.T("Company.Tasks.TheDeadlineMustBeInThe"));
                return;
            }

            int weight;
            if (!int.TryParse(ddlWeight.SelectedValue, out weight) || weight < 1 || weight > 3)
            {
                weight = 1;
            }

            if (criteria.Count == 0)
            {
                ShowError(L.T("Company.Tasks.AddAtLeastOneCriterionIn"));
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
            task.Deadline = Time.ToUnixMs(deadline);
            task.Criteria = criteria;
            task.MaxScore = TotalPoints(criteria);
            task.Weight = weight;
            task.Status = InternshipTaskStatus.Assigned;

            string id;
            try
            {
                id = new TaskRepository().Insert(task);
            }
            catch (Exception)
            {
                id = null;
            }

            if (string.IsNullOrEmpty(id))
            {
                ShowError(L.T("Company.Tasks.TheTaskCouldNotBeSaved"));
                return;
            }

            Session.Remove(CriteriaKey);
            Session[CreatedKey] = "Task \"" + title + "\" was assigned to "
                                  + placement.StudentName + " (out of "
                                  + task.MaxScore.ToString("0") + " points).";
            Response.Redirect(Request.Path, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        // ------------------------------------------------------------------
        //  Helpers
        // ------------------------------------------------------------------

        private void LoadTrainees()
        {
            ddlTrainee.Items.Clear();
            ddlTrainee.Items.Add(new ListItem(L.T("Company.Tasks.SelectATrainee"), ""));

            foreach (Placement placement in MyPlacements())
            {
                if (placement.Status != PlacementStatus.Confirmed
                    && placement.Status != PlacementStatus.Active)
                {
                    continue;
                }

                string text = placement.StudentName;
                if (!string.IsNullOrEmpty(placement.OpportunityTitle))
                {
                    text = text + " - " + placement.OpportunityTitle;
                }

                ddlTrainee.Items.Add(new ListItem(text, placement.Id));
            }
        }

        private void LoadTasks()
        {
            Dictionary<string, string> names = new Dictionary<string, string>();
            foreach (Placement placement in MyPlacements())
            {
                if (!string.IsNullOrEmpty(placement.Id)) names[placement.Id] = placement.StudentName;
            }

            List<InternshipTask> tasks = new TaskRepository().GetByCompany(CurrentSupervisor.CompanyId);
            tasks.Sort((a, b) => a.Deadline.CompareTo(b.Deadline));

            List<object> rows = new List<object>();
            foreach (InternshipTask task in tasks)
            {
                string trainee;
                if (task.PlacementId == null || !names.TryGetValue(task.PlacementId, out trainee))
                {
                    trainee = "-";
                }

                rows.Add(new
                {
                    Title = task.Title,
                    Trainee = trainee,
                    Deadline = Time.Display(task.Deadline),
                    Points = task.MaxScore > 0 ? task.MaxScore.ToString("0.##") : "-",
                    Counts = WeightLabel(task.Weight),
                    Status = task.IsOverdue ? "Overdue" : StatusLabel(task.Status)
                });
            }

            gvTasks.DataSource = rows;
            gvTasks.DataBind();
        }

        private List<Placement> MyPlacements()
        {
            return new PlacementRepository().GetByCompany(CurrentSupervisor.CompanyId);
        }

        /// <summary>Only accept a placement that belongs to this company.</summary>
        private Placement FindMyPlacement(string placementId)
        {
            if (string.IsNullOrEmpty(placementId)) return null;

            foreach (Placement placement in MyPlacements())
            {
                if (placement.Id == placementId) return placement;
            }
            return null;
        }

        private List<GradeComponent> GetCriteria()
        {
            List<GradeComponent> criteria = Session[CriteriaKey] as List<GradeComponent>;
            if (criteria == null)
            {
                ShowError(L.T("Company.Tasks.YourSessionExpiredPleaseReloadThe"));
            }
            return criteria;
        }

        /// <summary>Recalculates each criterion's share, stores the list and shows it.</summary>
        private void SaveCriteria(List<GradeComponent> criteria)
        {
            double total = TotalPoints(criteria);
            foreach (GradeComponent item in criteria)
            {
                item.Weight = total <= 0 ? 0 : item.MaxScore / total * 100.0;
            }

            Session[CriteriaKey] = criteria;
            ShowCriteria(criteria);
        }

        private void ShowCriteria(List<GradeComponent> criteria)
        {
            gvCriteria.DataSource = criteria;
            gvCriteria.DataBind();

            double total = TotalPoints(criteria);
            lblTotalPoints.Text = total.ToString("0") + (total == 1 ? " point" : " points");
            pnlStarter.Visible = criteria.Count == 0;
        }

        private static double TotalPoints(List<GradeComponent> criteria)
        {
            double total = 0;
            foreach (GradeComponent item in criteria) total += item.MaxScore;
            return total;
        }

        private static GradeComponent NewCriterion(string name, int points, string description)
        {
            GradeComponent criterion = new GradeComponent();
            criterion.Name = name;
            criterion.MaxScore = points;
            criterion.Description = description;
            return criterion;
        }

        private static string WeightLabel(double weight)
        {
            if (weight >= 3) return L.T("Company.Tasks.MajorX3");
            if (weight >= 2) return L.T("Company.Tasks.ImportantX2");
            return L.T("Company.Tasks.NormalX1");
        }

        private static string StatusLabel(InternshipTaskStatus status)
        {
            switch (status)
            {
                case InternshipTaskStatus.Submitted: return "Submitted";
                case InternshipTaskStatus.UnderReview: return L.T("Company.Tasks.UnderReview");
                case InternshipTaskStatus.RevisionRequested: return L.T("Company.Tasks.RevisionRequested");
                case InternshipTaskStatus.Resubmitted: return "Resubmitted";
                case InternshipTaskStatus.Graded: return "Graded";
                default: return "Assigned";
            }
        }

        private void ShowError(string message)
        {
            lblMessage.CssClass = "alert alert-danger d-block mb-0";
            lblMessage.Text = Server.HtmlEncode(message);
        }
    }
}
