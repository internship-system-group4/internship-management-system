using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.CompanyArea
{
    public partial class FinalEvaluation : InternshipManagementSystem.Security.CompanyPage
    {
        private readonly PlacementRepository _placementRepo = new PlacementRepository();
        private readonly UserRepository _userRepo = new UserRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack == false)
            {
                if (CurrentSupervisor == null || string.IsNullOrWhiteSpace(CurrentSupervisor.CompanyId))
                {
                    Response.Redirect("~/Login.aspx");
                    return;
                }

                LoadTraineesDropdown();

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

                        // منطق جلب السيرة الذاتية (CV) المطابق لصفحة التفاصيل
                        string cvLink = "";
                        try
                        {
                            cvLink = !string.IsNullOrEmpty(student.CvUrl) ? student.CvUrl :
                                    (!string.IsNullOrEmpty(student.PortfolioUrl) ? student.PortfolioUrl : "");
                        }
                        catch { }

                        // إظهار أو إخفاء زر الـ CV وتعيين الرابط
                        if (!string.IsNullOrEmpty(cvLink))
                        {
                            hlViewCV.NavigateUrl = cvLink;
                            divCvContainer.Visible = true;
                        }
                        else
                        {
                            divCvContainer.Visible = false;
                            hlViewCV.NavigateUrl = "";
                        }
                    }
                    
                    litInternshipTitle.Text = placement.OpportunityTitle;
                    litStatusBadge.Text = L.T("Company.FinalEvaluation.SpanClassStatusBadgeWarningI");

                    // جلب وتعبئة بيانات المسودة المحفوظة إن وجدت باستخدام التحويل الآمن
                    txtTechSkills.Text = placement.EvalTech > 0 ? placement.EvalTech.ToString() : "";
                    txtWorkQuality.Text = placement.EvalWork > 0 ? placement.EvalWork.ToString() : "";
                    txtProfessionalism.Text = placement.EvalProf > 0 ? placement.EvalProf.ToString() : "";
                    txtCommunication.Text = placement.EvalComm > 0 ? placement.EvalComm.ToString() : "";
                    
                    string hours = Convert.ToString(placement.ActualHours);
                    txtActualHours.Text = (!string.IsNullOrEmpty(hours) && hours != "0") ? hours : "";

                    if (!string.IsNullOrEmpty(placement.EvalPerformance))
                        ddlPerformance.SelectedValue = placement.EvalPerformance;
                    else
                        ddlPerformance.SelectedIndex = 0;

                    if (!string.IsNullOrEmpty(placement.CompanyRecommendation))
                        ddlRecommendation.SelectedValue = placement.CompanyRecommendation;
                    else
                        ddlRecommendation.SelectedIndex = 0;

                    txtStrengths.Text = placement.EvalStrengths ?? "";
                    txtImprovements.Text = placement.EvalImprovements ?? "";
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
                int.TryParse(txtTechSkills.Text, out int tech);
                int.TryParse(txtWorkQuality.Text, out int work);
                int.TryParse(txtProfessionalism.Text, out int prof);
                int.TryParse(txtCommunication.Text, out int comm);
                int.TryParse(txtActualHours.Text, out int hours);

                var updates = new Dictionary<string, object>
                {
                    { "EvalTech", tech },
                    { "EvalWork", work },
                    { "EvalProf", prof },
                    { "EvalComm", comm },
                    { "EvalPerformance", ddlPerformance.SelectedValue },
                    { "EvalStrengths", txtStrengths.Text },
                    { "EvalImprovements", txtImprovements.Text },
                    { "ActualHours", hours },
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
                int.TryParse(txtActualHours.Text, out int hours);

                if (tech > 40 || work > 25 || prof > 20 || comm > 15)
                {
                    ShowPopupMessage(L.T("Company.FinalEvaluation.InvalidScores"), L.T("Company.FinalEvaluation.PleaseCheckYourNumbersScoresCannot"), false);
                    return;
                }

                if (string.IsNullOrEmpty(ddlPerformance.SelectedValue) || string.IsNullOrEmpty(ddlRecommendation.SelectedValue) || hours == 0)
                {
                    ShowPopupMessage(L.T("Company.FinalEvaluation.MissingFields"), L.T("Company.FinalEvaluation.PleaseCompleteActualHoursFeedbackAnd"), false);
                    return;
                }

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
                    { "ActualHours", hours },
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
                litModalIcon.Text = "<i class='bi bi-check-circle text-success'></i>";
            else
                litModalIcon.Text = "<i class='bi bi-exclamation-circle text-danger'></i>";

            ClientScript.RegisterStartupScript(this.GetType(), "ShowMessage", "var myModal = new bootstrap.Modal(document.getElementById('serverMessageModal')); myModal.show();", true);
        }

        private void ClearTraineeCard()
        {
            litStudentName.Text = L.T("Company.FinalEvaluation.SelectATraineePlaceholder");
            litStudentMajor.Text = "-";
            litStudentInitials.Text = "--";
            litInternshipTitle.Text = "-";
            litStatusBadge.Text = L.T("Company.FinalEvaluation.SpanClassBadgeBgSecondaryPending");
            
            // إخفاء زر الـ CV عند تفريغ البطاقة
            divCvContainer.Visible = false;
            hlViewCV.NavigateUrl = "";
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