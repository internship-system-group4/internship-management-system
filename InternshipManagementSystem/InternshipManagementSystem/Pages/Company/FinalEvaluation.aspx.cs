// =============================================================================
//  Reports & Final Evaluation
//  Owner : Nada
//  Cards : N08, N09
//
//  N08: the company's final evaluation on the university's criteria.
//  N09: send it to the student's assigned academic supervisor.
//  CONFIDENTIAL: the student may never see this form. Only company
//  supervisors (CompanyPage) can open this page, and every placement is
//  checked against the signed-in supervisor's company.
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
using InternshipManagementSystem.Services;

namespace InternshipManagementSystem.Pages.CompanyArea
{
    public partial class FinalEvaluation : InternshipManagementSystem.Security.CompanyPage
    {
        private const int MaxTextLength = 2000;
        private const int MaxCommentLength = 500;

        private readonly PlacementRepository _placementRepo = new PlacementRepository();
        private readonly EvaluationRepository _evaluationRepo = new EvaluationRepository();
        private readonly TaskRepository _taskRepo = new TaskRepository();
        private readonly UserRepository _userRepo = new UserRepository();

        /// <summary>The placement being evaluated (placement id = student UID).</summary>
        private string PlacementId
        {
            get { return Request.QueryString["id"]; }
        }

        /// <summary>True while the form is read-only (already sent).</summary>
        private bool IsLocked
        {
            get { return ViewState["Locked"] != null && (bool)ViewState["Locked"]; }
            set { ViewState["Locked"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            try
            {
                if (string.IsNullOrEmpty(PlacementId)) LoadReports();
                else LoadEvaluation();
            }
            catch (FirebaseAuthExpiredException)
            {
                throw;   // SecurePage signs the user out and redirects to login.
            }
            catch (Exception ex)
            {
                ShowMessage("Could not load the page: " + ex.Message, false);
            }
        }

        // =====================================================================
        //  Reports list
        // =====================================================================
        private void LoadReports()
        {
            pnlReports.Visible = true;
            pnlEvaluation.Visible = false;

            string companyId = CurrentSupervisor.CompanyId;
            if (string.IsNullOrEmpty(companyId))
            {
                ShowMessage("Your account is not linked to a company yet. Please contact the coordinator.", false);
                return;
            }

            // Read every collection once and filter here, so the page works
            // even when the database has no .indexOn rules.
            List<Placement> placements = new List<Placement>();
            foreach (Placement p in _placementRepo.GetAll())
            {
                if (p.CompanyId == companyId && p.Status != PlacementStatus.Cancelled) placements.Add(p);
            }

            List<InternshipTask> allTasks = _taskRepo.GetAll();
            List<TaskEvaluation> allTaskEvaluations = _evaluationRepo.GetAllTaskEvaluations();
            List<FinalCompanyEvaluation> finals = _evaluationRepo.GetCompanyFinalsForCompany(companyId);

            int notStarted = 0, drafts = 0, sent = 0;
            List<EvaluationReportRow> rows = new List<EvaluationReportRow>();

            foreach (Placement p in placements)
            {
                List<InternshipTask> tasks = TasksFor(p.Id, allTasks);
                List<TaskEvaluation> evaluations = TaskEvaluationsFor(p.Id, allTaskEvaluations);
                FinalCompanyEvaluation final = FinalFor(p.Id, finals);

                EvaluationReportRow row = new EvaluationReportRow();
                row.PlacementId = p.Id;
                row.StudentName = string.IsNullOrEmpty(p.StudentName) ? "Student" : p.StudentName;
                row.OpportunityTitle = p.OpportunityTitle;
                row.ApprovedHours = p.ApprovedHours;
                row.RequiredHours = p.RequiredHours;
                row.HoursPercent = HoursPercent(p);
                row.TotalTasks = tasks.Count;
                row.GradedTasks = CountGraded(tasks);
                row.TaskScoreText = TaskScoreText(tasks, evaluations);

                if (final == null)
                {
                    notStarted++;
                    row.StatusText = "Not started";
                    row.StatusCss = "uims-pill uims-pill-pending";
                    row.ScoreText = "";
                    row.ActionText = "Evaluate";
                }
                else if (!final.IsSubmitted)
                {
                    drafts++;
                    row.StatusText = "Draft";
                    row.StatusCss = "uims-pill uims-pill-info";
                    row.ScoreText = "Draft score " + final.TotalScore.ToString("0.0") + " / 100";
                    row.ActionText = "Continue";
                }
                else
                {
                    sent++;
                    row.StatusText = "Sent";
                    row.StatusCss = "uims-pill uims-pill-accepted";
                    row.ScoreText = final.TotalScore.ToString("0.0") + " / 100 on " + Time.DisplayDate(final.SubmittedAt);
                    row.ActionText = "View report";
                }

                rows.Add(row);
            }

            rows.Sort((a, b) => string.Compare(a.StudentName, b.StudentName, StringComparison.OrdinalIgnoreCase));

            litTotal.Text = placements.Count.ToString();
            litNotStarted.Text = notStarted.ToString();
            litDrafts.Text = drafts.ToString();
            litSent.Text = sent.ToString();

            gvReports.DataSource = rows;
            gvReports.DataBind();
        }

        // =====================================================================
        //  One evaluation
        // =====================================================================
        private void LoadEvaluation()
        {
            pnlReports.Visible = false;

            Placement placement = LoadOwnPlacement();
            if (placement == null) return;
            pnlEvaluation.Visible = true;

            // ---- trainee summary ----
            litStudentName.Text = string.IsNullOrEmpty(placement.StudentName) ? "Student" : placement.StudentName;
            litOpportunity.Text = placement.OpportunityTitle;
            litCompany.Text = placement.CompanyName;
            litPeriod.Text = Time.DisplayDate(placement.StartDate) + " - " + Time.DisplayDate(placement.EndDate);
            litCompanySupervisor.Text = string.IsNullOrEmpty(placement.CompanySupervisorName)
                ? CurrentSupervisor.FullName : placement.CompanySupervisorName;
            litAcademicSupervisor.Text = AcademicSupervisorName(placement);
            litPlacementStatus.Text = placement.Status.ToString();

            // ---- evidence ----
            List<InternshipTask> tasks = TasksFor(placement.Id, _taskRepo.GetAll());
            List<TaskEvaluation> evaluations = TaskEvaluationsForPlacement(placement.Id);

            int overdue = 0;
            foreach (InternshipTask task in tasks)
            {
                if (task.IsOverdue) overdue++;
            }
            int revisions = 0;
            foreach (TaskEvaluation evaluation in evaluations)
            {
                if (evaluation.RevisionRequested) revisions++;
            }

            litHours.Text = placement.ApprovedHours + " / " + placement.RequiredHours;
            litTasks.Text = CountGraded(tasks) + " / " + tasks.Count;
            litTaskScore.Text = TaskScoreText(tasks, evaluations);
            litOverdue.Text = overdue.ToString();
            litRevisions.Text = revisions.ToString();
            pnlHoursWarning.Visible = !placement.HoursRequirementMet;

            // ---- the form ----
            FinalCompanyEvaluation saved = _evaluationRepo.GetCompanyFinalForPlacement(placement.Id);
            List<GradeComponent> criteria = GradingPolicy.CompanyFinalCriteria();

            if (saved != null)
            {
                CopySavedRatings(saved.Components, criteria);
                txtStrengths.Text = saved.Strengths;
                txtImprovements.Text = saved.AreasForImprovement;
                txtOverall.Text = saved.OverallComment;
            }

            IsLocked = saved != null && saved.IsSubmitted;

            rptCriteria.DataSource = criteria;
            rptCriteria.DataBind();
            litScore.Text = GradingService.PercentOf(criteria).ToString("0.0");

            ShowState(saved);
        }

        protected void rptCriteria_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem) return;

            GradeComponent criterion = (GradeComponent)e.Item.DataItem;
            DropDownList ddlRating = (DropDownList)e.Item.FindControl("ddlRating");
            TextBox txtComment = (TextBox)e.Item.FindControl("txtComment");

            ddlRating.Items.Add(new ListItem("Select a rating", ""));
            for (int rating = 1; rating <= (int)GradingPolicy.CompanyCriterionMaxRating; rating++)
            {
                ddlRating.Items.Add(new ListItem(rating + " - " + GradingPolicy.RatingLabel(rating), rating.ToString()));
            }

            int savedRating = (int)Math.Round(criterion.Score);
            if (savedRating > 0) ddlRating.SelectedValue = savedRating.ToString();

            ddlRating.Attributes["data-weight"] = criterion.Weight.ToString(System.Globalization.CultureInfo.InvariantCulture);
            ddlRating.Attributes["aria-label"] = "Rating for " + criterion.Name;
            txtComment.Attributes["aria-label"] = "Comment for " + criterion.Name;
            txtComment.Text = criterion.Comment;

            ddlRating.Enabled = !IsLocked;
            txtComment.Enabled = !IsLocked;
        }

        protected void btnSaveDraft_Click(object sender, EventArgs e)
        {
            Save(false);
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            Save(true);
        }

        /// <summary>Saves a draft, or sends the evaluation to the academic
        /// supervisor when <paramref name="submit"/> is true (card N09).</summary>
        private void Save(bool submit)
        {
            try
            {
                Placement placement = LoadOwnPlacement();
                if (placement == null) return;

                FinalCompanyEvaluation evaluation = _evaluationRepo.GetCompanyFinalForPlacement(placement.Id);

                // Server-side lock: a sent evaluation can never be changed here.
                if (evaluation != null && evaluation.IsSubmitted)
                {
                    LoadEvaluation();
                    ShowMessage("This evaluation was already sent to the academic supervisor and can no longer be changed.", false);
                    return;
                }

                List<GradeComponent> criteria = ReadCriteriaFromForm();
                string strengths = Clean(txtStrengths.Text, MaxTextLength);
                string improvements = Clean(txtImprovements.Text, MaxTextLength);
                string overall = Clean(txtOverall.Text, MaxTextLength);

                if (submit)
                {
                    string error = ValidateForSubmit(placement, criteria, strengths, improvements);
                    if (error != null)
                    {
                        ShowMessage(error, false);
                        return;
                    }
                }

                if (evaluation == null) evaluation = new FinalCompanyEvaluation();

                evaluation.PlacementId = placement.Id;
                evaluation.StudentId = placement.StudentId;
                evaluation.CompanyId = placement.CompanyId;
                evaluation.SupervisorId = CurrentSupervisor.Id;
                evaluation.Components = criteria;
                evaluation.TotalScore = Math.Round(GradingService.PercentOf(criteria), 1);
                evaluation.MaxScore = GradingPolicy.CompanyEvaluationMaxScore;
                evaluation.Strengths = strengths;
                evaluation.AreasForImprovement = improvements;
                evaluation.OverallComment = overall;
                evaluation.ReportedTotalHours = placement.ApprovedHours;
                evaluation.IsSubmitted = submit;
                evaluation.SubmittedAt = submit ? Time.NowMs() : 0;

                string id = _evaluationRepo.SaveCompanyFinal(evaluation);
                if (string.IsNullOrEmpty(id))
                {
                    ShowMessage("The evaluation could not be saved. Please try again.", false);
                    return;
                }

                LoadEvaluation();
                if (submit)
                    ShowMessage("The evaluation was sent to " + AcademicSupervisorName(placement) + ".", true);
                else
                    ShowMessage("Draft saved. You can come back and finish it later.", true);
            }
            catch (FirebaseAuthExpiredException)
            {
                throw;   // SecurePage signs the user out and redirects to login.
            }
            catch (Exception ex)
            {
                ShowMessage("The evaluation could not be saved: " + ex.Message, false);
            }
        }

        private string ValidateForSubmit(Placement placement, List<GradeComponent> criteria,
                                         string strengths, string improvements)
        {
            if (string.IsNullOrEmpty(placement.AcademicSupervisorId))
                return "This student has no academic supervisor yet, so the evaluation cannot be sent. Save it as a draft and ask the coordinator to assign one.";

            foreach (GradeComponent criterion in criteria)
            {
                if (criterion.Score < 1)
                    return "Please rate every criterion before sending. Missing: " + criterion.Name + ".";
            }

            if (strengths.Length == 0) return "Please describe the student's strengths before sending.";
            if (improvements.Length == 0) return "Please describe areas for improvement before sending.";
            return null;
        }

        // =====================================================================
        //  Helpers
        // =====================================================================

        /// <summary>Loads the placement from the query string and makes sure it
        /// belongs to the signed-in supervisor's company. Shows an error and
        /// returns null otherwise.</summary>
        private Placement LoadOwnPlacement()
        {
            if (!ApplicationRepository.IsValidKey(PlacementId))
            {
                ShowNotFound("Invalid trainee link.");
                return null;
            }

            Placement placement = _placementRepo.GetById(PlacementId);
            if (placement == null || string.IsNullOrEmpty(CurrentSupervisor.CompanyId)
                || placement.CompanyId != CurrentSupervisor.CompanyId)
            {
                // Same message for "missing" and "other company" so nothing leaks.
                ShowNotFound("This trainee was not found in your company.");
                return null;
            }

            if (placement.Status == PlacementStatus.Cancelled)
            {
                ShowNotFound("This placement was cancelled, so it cannot be evaluated.");
                return null;
            }
            return placement;
        }

        private void ShowNotFound(string message)
        {
            pnlEvaluation.Visible = false;
            pnlReports.Visible = false;
            ShowMessage(message + " <a href=\"FinalEvaluation.aspx\">Back to trainee reports</a>", false, true);
        }

        /// <summary>Reads the ratings and comments the supervisor entered.
        /// The repeater rows are in the same order as the policy criteria.</summary>
        private List<GradeComponent> ReadCriteriaFromForm()
        {
            List<GradeComponent> criteria = GradingPolicy.CompanyFinalCriteria();
            for (int i = 0; i < rptCriteria.Items.Count && i < criteria.Count; i++)
            {
                DropDownList ddlRating = (DropDownList)rptCriteria.Items[i].FindControl("ddlRating");
                TextBox txtComment = (TextBox)rptCriteria.Items[i].FindControl("txtComment");

                int rating;
                int.TryParse(ddlRating.SelectedValue, out rating);
                if (rating < 0 || rating > GradingPolicy.CompanyCriterionMaxRating) rating = 0;

                criteria[i].Score = rating;
                criteria[i].Comment = Clean(txtComment.Text, MaxCommentLength);
            }
            return criteria;
        }

        /// <summary>Copies saved ratings onto the current criteria by name, so
        /// a later change to the policy list does not shift the ratings.</summary>
        private static void CopySavedRatings(List<GradeComponent> saved, List<GradeComponent> criteria)
        {
            if (saved == null) return;
            foreach (GradeComponent criterion in criteria)
            {
                foreach (GradeComponent old in saved)
                {
                    if (old != null && old.Name == criterion.Name)
                    {
                        criterion.Score = old.Score;
                        criterion.Comment = old.Comment;
                    }
                }
            }
        }

        private void ShowState(FinalCompanyEvaluation saved)
        {
            txtStrengths.Enabled = !IsLocked;
            txtImprovements.Enabled = !IsLocked;
            txtOverall.Enabled = !IsLocked;
            pnlActions.Visible = !IsLocked;
            pnlSubmitted.Visible = IsLocked;

            if (saved == null)
            {
                lblStatus.Text = "Not started";
                lblStatus.CssClass = "uims-pill uims-pill-pending";
            }
            else if (!saved.IsSubmitted)
            {
                lblStatus.Text = "Draft";
                lblStatus.CssClass = "uims-pill uims-pill-info";
            }
            else
            {
                lblStatus.Text = "Sent to academic supervisor";
                lblStatus.CssClass = "uims-pill uims-pill-accepted";
                litSubmitted.Text = "Sent on " + Time.DisplayDate(saved.SubmittedAt)
                    + ". The academic supervisor and the coordinator can now read it. It can no longer be changed.";
            }
        }

        private string AcademicSupervisorName(Placement placement)
        {
            if (string.IsNullOrEmpty(placement.AcademicSupervisorId)) return "Not assigned yet";
            AcademicSupervisor supervisor = _userRepo.GetAcademicSupervisor(placement.AcademicSupervisorId);
            return supervisor == null ? "Not assigned yet" : supervisor.FullName;
        }

        /// <summary>Task evaluations of one placement. Falls back to reading
        /// all of them when the database has no .indexOn rule.</summary>
        private List<TaskEvaluation> TaskEvaluationsForPlacement(string placementId)
        {
            try
            {
                return _evaluationRepo.GetTaskEvaluationsForPlacement(placementId);
            }
            catch (FirebaseException)
            {
                return TaskEvaluationsFor(placementId, _evaluationRepo.GetAllTaskEvaluations());
            }
        }

        private static List<InternshipTask> TasksFor(string placementId, List<InternshipTask> all)
        {
            List<InternshipTask> result = new List<InternshipTask>();
            foreach (InternshipTask task in all)
            {
                if (task.PlacementId == placementId) result.Add(task);
            }
            return result;
        }

        private static List<TaskEvaluation> TaskEvaluationsFor(string placementId, List<TaskEvaluation> all)
        {
            List<TaskEvaluation> result = new List<TaskEvaluation>();
            foreach (TaskEvaluation evaluation in all)
            {
                if (evaluation.PlacementId == placementId) result.Add(evaluation);
            }
            return result;
        }

        private static FinalCompanyEvaluation FinalFor(string placementId, List<FinalCompanyEvaluation> finals)
        {
            FinalCompanyEvaluation best = null;
            foreach (FinalCompanyEvaluation final in finals)
            {
                if (final.PlacementId != placementId) continue;
                if (best == null || (final.IsSubmitted && !best.IsSubmitted)) best = final;
            }
            return best;
        }

        private static int CountGraded(List<InternshipTask> tasks)
        {
            int graded = 0;
            foreach (InternshipTask task in tasks)
            {
                if (task.Status == InternshipTaskStatus.Graded) graded++;
            }
            return graded;
        }

        private static string TaskScoreText(List<InternshipTask> tasks, List<TaskEvaluation> evaluations)
        {
            bool anyGrade = false;
            foreach (TaskEvaluation evaluation in evaluations)
            {
                if (!evaluation.RevisionRequested) anyGrade = true;
            }
            if (!anyGrade) return "No grades yet";
            return GradingService.TaskComponentPercent(tasks, evaluations).ToString("0.0") + "%";
        }

        private static int HoursPercent(Placement placement)
        {
            if (placement.RequiredHours <= 0) return 0;
            int percent = (int)Math.Round((double)placement.ApprovedHours / placement.RequiredHours * 100);
            return Math.Max(0, Math.Min(100, percent));
        }

        private static string Clean(string text, int maxLength)
        {
            string value = (text ?? "").Trim();
            return value.Length > maxLength ? value.Substring(0, maxLength) : value;
        }

        private void ShowMessage(string message, bool success, bool allowHtml = false)
        {
            lblMessage.Text = allowHtml ? message : Server.HtmlEncode(message);
            lblMessage.CssClass = success ? "alert alert-success d-block mb-3" : "alert alert-danger d-block mb-3";
            lblMessage.Visible = true;
        }
    }

    /// <summary>One row of the trainee reports table.</summary>
    public class EvaluationReportRow
    {
        public string PlacementId { get; set; }
        public string StudentName { get; set; }
        public string OpportunityTitle { get; set; }
        public int ApprovedHours { get; set; }
        public int RequiredHours { get; set; }
        public int HoursPercent { get; set; }
        public int TotalTasks { get; set; }
        public int GradedTasks { get; set; }
        public string TaskScoreText { get; set; }
        public string StatusText { get; set; }
        public string StatusCss { get; set; }
        public string ScoreText { get; set; }
        public string ActionText { get; set; }
    }
}
