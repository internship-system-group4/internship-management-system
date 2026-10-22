using System;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Common;

namespace InternshipManagementSystem.Pages.Academic
{
    public partial class FinalEvaluation : AcademicPage
    {
        private string CurrentStudentId
        {
            get { return Request.QueryString["id"]; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(CurrentStudentId))
            {
                Response.Redirect("Dashboard.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadEvaluationData();
            }
        }

        private void LoadEvaluationData()
        {
            UserRepository userRepo = new UserRepository();
            Student student = userRepo.GetStudent(CurrentStudentId);

            // Security check
            if (student == null || student.AcademicSupervisorId != CurrentSupervisor.Id)
            {
                Response.Redirect("Dashboard.aspx");
                return;
            }

            litStudentName.Text = student.FullName;

            EvaluationRepository evalRepo = new EvaluationRepository();

            // 1. Load Company Evaluation (Read-Only)
            FinalCompanyEvaluation companyEval = evalRepo.GetCompanyFinalForPlacement(CurrentStudentId);
            if (companyEval != null && companyEval.IsSubmitted)
            {
                pnlCompanyEvalExists.Visible = true;
                pnlNoCompanyEval.Visible = false;

                litCompanyScore.Text = companyEval.TotalScore.ToString();
                litCompanyMaxScore.Text = companyEval.MaxScore.ToString();
                litStrengths.Text = string.IsNullOrEmpty(companyEval.Strengths) ? "N/A" : companyEval.Strengths;
                litImprovements.Text = string.IsNullOrEmpty(companyEval.AreasForImprovement) ? "N/A" : companyEval.AreasForImprovement;
                litCompanyComment.Text = string.IsNullOrEmpty(companyEval.OverallComment) ? "N/A" : companyEval.OverallComment;
            }

            // 2. Check if Academic Evaluation is already submitted
            FinalAcademicEvaluation academicEval = evalRepo.GetAcademicFinalForPlacement(CurrentStudentId);
            if (academicEval != null && academicEval.IsSubmitted)
            {
                // Lock the form if already submitted
                txtCompanyComponent.Enabled = false;
                txtReportComponent.Enabled = false;
                txtDiscussionComponent.Enabled = false;
                txtAcademicComments.Enabled = false;
                btnSubmitEvaluation.Visible = false;

                // Convert Unix timestamp to DateTime (Fixed CS0117 Error)
                DateTime submitDate = new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc)
                    .AddMilliseconds(academicEval.SubmittedAt).ToLocalTime();

                lblStatusMessage.Text = "Evaluation successfully submitted to the Coordinator on " + submitDate.ToString("dd/MM/yyyy");
                lblStatusMessage.CssClass = "text-success me-3";
                lblStatusMessage.Visible = true;
            }
        }

        protected void btnSubmitEvaluation_Click(object sender, EventArgs e)
        {
            // Parse scores safely
            double compScore, repScore, discScore;
            double.TryParse(txtCompanyComponent.Text, out compScore);
            double.TryParse(txtReportComponent.Text, out repScore);
            double.TryParse(txtDiscussionComponent.Text, out discScore);

            double totalScore = compScore + repScore + discScore;

            FinalAcademicEvaluation eval = new FinalAcademicEvaluation
            {
                StudentId = CurrentStudentId,
                PlacementId = CurrentStudentId, // Based on repo rules, placement ID matches student ID
                AcademicSupervisorId = CurrentSupervisor.Id,
                TotalScore = totalScore,
                MaxScore = 100,
                AcademicComments = txtAcademicComments.Text,
                IsSubmitted = true,
                SubmittedAt = Time.NowMs()
            };

            // Save the evaluation via the repository
            EvaluationRepository evalRepo = new EvaluationRepository();
            evalRepo.SaveAcademicFinal(eval);

            // Update UI
            txtCompanyComponent.Enabled = false;
            txtReportComponent.Enabled = false;
            txtDiscussionComponent.Enabled = false;
            txtAcademicComments.Enabled = false;
            btnSubmitEvaluation.Visible = false;

            lblStatusMessage.Text = "Evaluation successfully submitted to the Coordinator!";
            lblStatusMessage.CssClass = "text-success me-3";
            lblStatusMessage.Visible = true;
        }
    }
}