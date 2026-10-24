using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.CompanyArea
{
    public partial class EvaluationReport : InternshipManagementSystem.Security.CompanyPage
    {
        private readonly PlacementRepository _placementRepo = new PlacementRepository();
        private readonly UserRepository _userRepo = new UserRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack == false)
            {
                LoadTraineesDropdown();

                // ربط اسم المشرف لطباعته على الشهادة التلقائية
                if (CurrentSupervisor != null)
                {
                    litCompanySupervisorName.Text = CurrentSupervisor.FullName;
                }
            }
        }

        private void LoadTraineesDropdown()
        {
            try
            {
                List<Placement> allPlacements = _placementRepo.GetAll();
                ddlTrainees.Items.Clear();
                ddlTrainees.Items.Add(new ListItem("-- Select a trainee to evaluate --", ""));

                foreach (Placement p in allPlacements)
                {
                    if (p.CompanyId == CurrentSupervisor.CompanyId)
                    {
                        if (p.Status.ToString() != "Completed")
                        {
                            ddlTrainees.Items.Add(new ListItem(p.StudentName, p.Id));
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowPopupMessage(L.T("Shared.Popup.Error"), L.F("Company.FinalEvaluation.CouldNotLoadTrainees", ex.Message), false);
            }
        }

        protected void DdlTrainees_SelectedIndexChanged(object sender, EventArgs e)
        {
            string placementId = ddlTrainees.SelectedValue;
            if (string.IsNullOrEmpty(placementId))
            {
                ClearTraineeCard();
                return;
            }

            try
            {
                Placement placement = _placementRepo.GetById(placementId);
                if (placement != null)
                {
                    Student student = _userRepo.GetStudent(placement.StudentId);
                    if (student != null)
                    {
                        litStudentName.Text = student.FullName;
                        litStudentMajor.Text = student.Major;
                        litStudentInitials.Text = GetInitials(student.FullName);
                    }
                    litInternshipTitle.Text = placement.OpportunityTitle;
                    litStatusBadge.Text = L.T("Company.FinalEvaluation.SpanClassStatusBadgeWarningI");

                    ClearFormFields();
                }
            }
            catch (Exception ex)
            {
                ShowPopupMessage(L.T("Shared.Popup.Error"), L.F("Company.FinalEvaluation.CouldNotLoadTraineeDetails", ex.Message), false);
            }
        }

        protected void BtnMyDrafts_Click(object sender, EventArgs e)
        {
            try
            {
                List<Placement> allPlacements = _placementRepo.GetAll();
                List<Placement> drafts = new List<Placement>();

                foreach (Placement p in allPlacements)
                {
                    if (p.CompanyId == CurrentSupervisor.CompanyId && p.Status.ToString() != "Completed")
                    {
                        drafts.Add(p);
                    }
                }

                gvDrafts.DataSource = drafts;
                gvDrafts.DataBind();

                ClientScript.RegisterStartupScript(this.GetType(), "ShowDrafts", "var draftModal = new bootstrap.Modal(document.getElementById('draftsModal')); draftModal.show();", true);
            }
            catch (Exception ex)
            {
                ShowPopupMessage(L.T("Shared.Popup.Error"), L.F("Company.FinalEvaluation.CouldNotLoadDrafts", ex.Message), false);
            }
        }

        protected void GvDrafts_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "LoadDraft")
            {
                string placementId = e.CommandArgument.ToString();
                ddlTrainees.SelectedValue = placementId;
                DdlTrainees_SelectedIndexChanged(null, null);
                ShowPopupMessage(L.T("Company.FinalEvaluation.DraftLoaded"), L.T("Company.FinalEvaluation.DraftDataReadyPleaseOpenThe"), true);
            }
        }

        protected void BtnSaveDraft_Click(object sender, EventArgs e)
        {
            string placementId = ddlTrainees.SelectedValue;
            if (string.IsNullOrEmpty(placementId))
            {
                ShowPopupMessage(L.T("Company.FinalEvaluation.SelectTrainee"), L.T("Company.FinalEvaluation.PleaseSelectATraineeFromThe"), false);
                return;
            }

            try
            {
                var updates = new Dictionary<string, object>
                {
                    { "EvalTech", txtTechSkills.Text },
                    { "EvalWork", txtWorkQuality.Text },
                    { "EvalProf", txtProfessionalism.Text },
                    { "EvalComm", txtCommunication.Text },
                    { "EvalPerformance", ddlPerformance.SelectedValue },
                    { "EvalStrengths", txtStrengths.Text },
                    { "EvalImprovements", txtImprovements.Text },
                    { "ActualHours", txtActualHours.Text },
                    { "CompanyRecommendation", ddlRecommendation.SelectedValue }
                };

                _placementRepo.Update(placementId, updates);
                ShowPopupMessage(L.T("Company.FinalEvaluation.DraftSaved"), L.T("Company.FinalEvaluation.YourEvaluationHasBeenSafelySaved"), true);
            }
            catch (Exception ex)
            {
                ShowPopupMessage(L.T("Shared.Popup.Error"), L.F("Company.FinalEvaluation.CouldNotSaveDraft", ex.Message), false);
            }
        }

        protected void BtnSendEvaluation_Click(object sender, EventArgs e)
        {
            string placementId = ddlTrainees.SelectedValue;
            if (string.IsNullOrEmpty(placementId))
            {
                ShowPopupMessage(L.T("Company.FinalEvaluation.SelectTrainee"), L.T("Company.FinalEvaluation.PleaseSelectATraineeToEvaluate"), false);
                return;
            }

            try
            {
                int.TryParse(txtTechSkills.Text, out int tech);
                int.TryParse(txtWorkQuality.Text, out int work);
                int.TryParse(txtProfessionalism.Text, out int prof);
                int.TryParse(txtCommunication.Text, out int comm);

                // تطبيق معايير GJU: (40, 25, 20, 15)
                if (tech > 40 || work > 25 || prof > 20 || comm > 15)
                {
                    ShowPopupMessage(L.T("Company.FinalEvaluation.InvalidScores"), L.T("Company.FinalEvaluation.PleaseCheckYourNumbersScoresCannot"), false);
                    return;
                }

                if (string.IsNullOrEmpty(ddlPerformance.SelectedValue) || string.IsNullOrEmpty(ddlRecommendation.SelectedValue) || string.IsNullOrEmpty(txtActualHours.Text))
                {
                    ShowPopupMessage(L.T("Company.FinalEvaluation.MissingFields"), L.T("Company.FinalEvaluation.PleaseCompleteActualHoursFeedbackAnd"), false);
                    return;
                }

                // توليد رقم مرجعي فريد للشهادة المعتمدة لتسهيل مشاركتها وتحقق الطالب منها ومن نشرها
                string certificateId = "GJU-UIMS-CERT-" + Guid.NewGuid().ToString().Substring(0, 8).ToUpper();
                string issueDate = DateTime.UtcNow.ToString("yyyy-MM-dd");

                var updates = new Dictionary<string, object>
                {
                    { "Status", "Completed" },
                    { "EvalTech", tech },
                    { "EvalWork", work },
                    { "EvalProf", prof },
                    { "EvalComm", comm },
                    { "EvalPerformance", ddlPerformance.SelectedValue },
                    { "EvalStrengths", txtStrengths.Text },
                    { "EvalImprovements", txtImprovements.Text },
                    { "FinalScore", (tech + work + prof + comm) },
                    { "ActualHours", txtActualHours.Text },
                    { "CompanyRecommendation", ddlRecommendation.SelectedValue },
                    { "CertificateId", certificateId },
                    { "CertificateIssueDate", issueDate }
                };

                _placementRepo.Update(placementId, updates);

                litStatusBadge.Text = L.T("Company.FinalEvaluation.SpanClassStatusBadgeGreenI");
                ShowPopupMessage(L.T("Company.FinalEvaluation.CertificateIssued"), L.T("Company.FinalEvaluation.SuccessEvaluationSubmittedToTheGJU"), true);

                ClearFormFields();
                LoadTraineesDropdown();
            }
            catch (Exception ex)
            {
                ShowPopupMessage(L.T("Shared.Popup.Error"), L.F("Company.FinalEvaluation.CouldNotSendEvaluation", ex.Message), false);
            }
        }

        private void ShowPopupMessage(string title, string message, bool isSuccess)
        {
            litModalTitle.Text = title;
            litModalMessage.Text = message;

            if (isSuccess)
                litModalIcon.Text = L.T("Company.FinalEvaluation.IClassBiBiCheckCircle");
            else
                litModalIcon.Text = L.T("Company.FinalEvaluation.IClassBiBiExclamationCircle");

            ClientScript.RegisterStartupScript(this.GetType(), "ShowMessage", "var myModal = new bootstrap.Modal(document.getElementById('serverMessageModal')); myModal.show();", true);
        }

        private void ClearTraineeCard()
        {
            litStudentName.Text = L.T("Company.FinalEvaluation.SelectATraineePlaceholder");
            litStudentMajor.Text = "-";
            litStudentInitials.Text = "--";
            litInternshipTitle.Text = "-";
            litStatusBadge.Text = L.T("Company.FinalEvaluation.SpanClassBadgeBgSecondaryPending");
        }

        private void ClearFormFields()
        {
            txtTechSkills.Text = "";
            txtWorkQuality.Text = "";
            txtCommunication.Text = "";
            txtProfessionalism.Text = "";
            txtActualHours.Text = "";
            ddlPerformance.SelectedIndex = 0;
            ddlRecommendation.SelectedIndex = 0;
            txtStrengths.Text = "";
            txtImprovements.Text = "";
        }

        protected string GetInitials(string fullName)
        {
            if (string.IsNullOrWhiteSpace(fullName)) return "ST";
            var parts = fullName.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 1) return parts[0].Substring(0, 1).ToUpper();
            return (parts[0].Substring(0, 1) + parts[parts.Length - 1].Substring(0, 1)).ToUpper();
        }
    }
}