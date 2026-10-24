using System;
using System.Globalization;
using System.Linq;
using System.Web.UI;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Services;
namespace InternshipManagementSystem.Pages.CompanyArea
{
    public partial class FinalEvaluation : InternshipManagementSystem.Security.CompanyPage
    {
        private static readonly bool Academic = false;
        protected override void OnInit(EventArgs e) { ViewStateUserKey = Session.SessionID; base.OnInit(e); }
        protected void Page_Load(object sender, EventArgs e)
        {
            Response.Cache.SetNoStore();
            if (IsPostBack) return;
            try
            {
                var placements = Academic ? new PlacementRepository().GetByAcademicSupervisor(CurrentUser.Id) :
                    new PlacementRepository().GetByCompany(((CompanySupervisor)CurrentUser).CompanyId).Where(p => p.CompanySupervisorId == CurrentUser.Id).ToList();
                ddlPlacement.Items.Clear(); ddlPlacement.Items.Add(new System.Web.UI.WebControls.ListItem(L.T("Company.FinalEvaluation.SelectAnAssignedInternship"), ""));
                foreach (var p in placements.Where(p => p.Status != PlacementStatus.Cancelled && p.Status != PlacementStatus.Offered))
                    ddlPlacement.Items.Add(new System.Web.UI.WebControls.ListItem(p.StudentName + " · " + p.CompanyName, p.Id));
                string id = Request.QueryString["id"];
                if (id != null && ddlPlacement.Items.FindByValue(id) != null) { ddlPlacement.SelectedValue = id; LoadEvaluation(); }
            }
            catch (FirebaseAuthExpiredException) { throw; }
            catch (FirebaseException) { Message(L.T("Company.FinalEvaluation.UnableToLoadAssignedInternshipsPlease"), false); }
        }
        protected void ddlPlacement_SelectedIndexChanged(object sender, EventArgs e)
        {
            try { LoadEvaluation(); }
            catch (FirebaseAuthExpiredException) { throw; }
            catch (FirebaseException) { Message(L.T("Company.FinalEvaluation.UnableToLoadTheEvaluationPlease"), false); }
            catch (InvalidOperationException ex) { Message(ex.Message, false); }
        }
        private Placement AssignedPlacement()
        {
            if (!System.Text.RegularExpressions.Regex.IsMatch(ddlPlacement.SelectedValue, @"\A[A-Za-z0-9_-]{1,128}\z")) return null;
            var p = new PlacementRepository().GetById(ddlPlacement.SelectedValue);
            if (p == null || !CurrentUser.IsActive || (Academic ? CurrentUser.Role != UserRole.AcademicSupervisor || p.AcademicSupervisorId != CurrentUser.Id :
                CurrentUser.Role != UserRole.CompanySupervisor || p.CompanySupervisorId != CurrentUser.Id || p.CompanyId != ((CompanySupervisor)CurrentUser).CompanyId))
                return null;
            return p;
        }
        private void LoadEvaluation()
        {
            pnlForm.Visible = false; litCompanyEvidence.Text = ""; litStatus.Text = "";
            var p = AssignedPlacement();
            if (p == null) return;
            var repository = new EvaluationRepository();
            var company = repository.GetCompanyFinalForPlacement(p.Id);
            var academic = Academic ? repository.GetAcademicFinalForPlacement(p.Id) : null;
            bool submitted = Academic ? academic != null && academic.IsSubmitted : company != null && company.IsSubmitted;
            bool final = CompletionReviewService.IsFinal(new CompletionRepository().GetByPlacement(p.Id));
            txtScore.Text = Academic ? (academic == null || academic.MaxScore <= 0 ? "" : academic.TotalScore.ToString(CultureInfo.InvariantCulture)) :
                (company == null || company.MaxScore <= 0 ? "" : company.TotalScore.ToString(CultureInfo.InvariantCulture));
            txtMaximum.Text = Academic ? (academic == null || academic.MaxScore <= 0 ? "" : academic.MaxScore.ToString(CultureInfo.InvariantCulture)) :
                (company == null || company.MaxScore <= 0 ? "" : company.MaxScore.ToString(CultureInfo.InvariantCulture));
            txtComments.Text = Academic ? (academic == null ? "" : academic.AcademicComments) : (company == null ? "" : company.OverallComment);
            if (Academic)
                litCompanyEvidence.Text = company != null && company.IsSubmitted ? "<div class=\"alert alert-light\"><strong>Confidential company evaluation</strong><p>" +
                    Server.HtmlEncode(company.TotalScore.ToString(CultureInfo.InvariantCulture) + " / " + company.MaxScore.ToString(CultureInfo.InvariantCulture)) + "</p><p>" +
                    Server.HtmlEncode(string.Join("\n", new[] { company.Strengths, company.AreasForImprovement, company.OverallComment })) + "</p></div>" : "<p>Awaiting the company supervisor's submitted final evaluation.</p>";
            pnlForm.Visible = true;
            txtScore.Enabled = txtMaximum.Enabled = txtComments.Enabled = btnSubmit.Enabled = !submitted && !final;
            litStatus.Text = submitted ? L.T("Company.FinalEvaluation.FinalEvaluationSubmittedThisSubmissionIs") : final ? L.T("Company.FinalEvaluation.CompletionIsFinalizedEvidenceIsRead") : L.T("Company.FinalEvaluation.FinalEvaluationHasNotBeenSubmitted");
        }
        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            try
            {
                var p = AssignedPlacement();
                if (p == null || p.Status == PlacementStatus.Cancelled || p.Status == PlacementStatus.Offered) throw new InvalidOperationException("Select an eligible assigned internship.");
                var repository = new EvaluationRepository();
                var company = repository.GetCompanyFinalForPlacement(p.Id);
                var academic = Academic ? repository.GetAcademicFinalForPlacement(p.Id) : null;
                if (Academic && (company == null || !company.IsSubmitted)) throw new InvalidOperationException("Review the submitted company final evaluation before submitting to the coordinator.");
                if (Academic ? academic != null && academic.IsSubmitted : company != null && company.IsSubmitted) throw new InvalidOperationException("This evaluation has already been submitted.");
                double score = 0, maximum = 0;
                bool blank = string.IsNullOrWhiteSpace(txtScore.Text) && string.IsNullOrWhiteSpace(txtMaximum.Text);
                if (!blank && (!double.TryParse(txtScore.Text, NumberStyles.Float, CultureInfo.InvariantCulture, out score) ||
                    !double.TryParse(txtMaximum.Text, NumberStyles.Float, CultureInfo.InvariantCulture, out maximum) || !CompletionReviewService.ValidScore(score, maximum)))
                    throw new InvalidOperationException("Enter a finite score between zero and the positive maximum on this assessment's scale.");
                if ((txtComments.Text ?? "").Length > 4000 || blank && string.IsNullOrWhiteSpace(txtComments.Text)) throw new InvalidOperationException("Provide comments for an evidence-only evaluation; comments must be no more than 4,000 characters.");
                if (Academic)
                {
                    academic = academic ?? new FinalAcademicEvaluation();
                    academic.PlacementId = p.Id; academic.StudentId = p.StudentId; academic.AcademicSupervisorId = CurrentUser.Id;
                    academic.TotalScore = score; academic.MaxScore = maximum; academic.AcademicComments = txtComments.Text.Trim();
                    academic.IsSubmitted = true; academic.SubmittedAt = Time.NowMs();
                    repository.SaveAcademicFinal(academic);
                }
                else
                {
                    company = company ?? new FinalCompanyEvaluation();
                    company.PlacementId = p.Id; company.StudentId = p.StudentId; company.CompanyId = p.CompanyId; company.SupervisorId = CurrentUser.Id;
                    company.TotalScore = score; company.MaxScore = maximum; company.OverallComment = txtComments.Text.Trim();
                    company.IsSubmitted = true; company.SubmittedAt = Time.NowMs();
                    repository.SaveCompanyFinal(company);
                }
                LoadEvaluation(); Message(L.T("Company.FinalEvaluation.ConfidentialFinalEvaluationSubmittedSuccessfully"), true);
            }
            catch (FirebaseAuthExpiredException) { throw; }
            catch (FirebaseException) { Message(L.T("Company.FinalEvaluation.SubmissionCouldNotBeConfirmedReload"), false); }
            catch (InvalidOperationException ex) { Message(ex.Message, false); }
        }
        private void Message(string text, bool success) { lblMessage.Text = Server.HtmlEncode(text); lblMessage.CssClass = success ? "alert alert-success d-block" : "alert alert-danger d-block"; lblMessage.Visible = true; }
    }
}
