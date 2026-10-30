using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI.WebControls;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Pages.CompanyArea
{
    public partial class FinalEvaluation : Security.CompanyPage
    {
        private readonly PlacementRepository _placementRepo = new PlacementRepository();
        private readonly UserRepository _userRepo = new UserRepository();
        private readonly EvaluationRepository _evaluations = new EvaluationRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;
            LoadTraineesDropdown();
            litCompanySupervisorName.Text = CurrentSupervisor.FullName;
            string requested = Request.QueryString["id"];
            if (!string.IsNullOrEmpty(requested) && ddlTrainees.Items.FindByValue(requested) != null)
            {
                ddlTrainees.SelectedValue = requested;
                DdlTrainees_SelectedIndexChanged(null, null);
            }
        }

        private List<Placement> MyPlacements()
        {
            return _placementRepo.GetByCompany(CurrentSupervisor.CompanyId)
                .Where(p => p.CompanySupervisorId == CurrentSupervisor.Id && p.Status != PlacementStatus.Cancelled).ToList();
        }

        private Placement SelectedPlacement()
        {
            string id = ddlTrainees.SelectedValue;
            var placement = ApplicationRepository.IsValidKey(id) ? _placementRepo.GetById(id) : null;
            if (placement == null || placement.CompanyId != CurrentSupervisor.CompanyId ||
                placement.CompanySupervisorId != CurrentSupervisor.Id)
                throw new InvalidOperationException(L.T("Company.FinalEvaluation.UnassignedPlacement"));
            return placement;
        }

        private void LoadTraineesDropdown()
        {
            try
            {
                ddlTrainees.Items.Clear();
                ddlTrainees.Items.Add(new ListItem(L.T("Company.FinalEvaluation.SelectTraineePrompt"), ""));
                foreach (var placement in MyPlacements())
                    ddlTrainees.Items.Add(new ListItem(placement.StudentName, placement.Id));
            }
            catch (Exception ex) { ShowPopupMessage(L.T("Shared.Popup.Error"), L.F("Company.FinalEvaluation.CouldNotLoadTrainees", ex.Message), false); }
        }

        protected void DdlTrainees_SelectedIndexChanged(object sender, EventArgs e)
        {
            ClearTraineeCard(); ClearFormFields();
            btnSaveDraft.Enabled = true;
            if (string.IsNullOrEmpty(ddlTrainees.SelectedValue)) return;
            try
            {
                var placement = SelectedPlacement();
                var student = _userRepo.GetStudent(placement.StudentId);
                litStudentName.Text = student == null ? placement.StudentName : student.FullName;
                litStudentMajor.Text = student == null ? "-" : L.Value("Directory", student.Major);
                litStudentInitials.Text = GetInitials(litStudentName.Text);
                // Uploaded CV/portfolio PDF or a shared link (checked by ApplicantDocument.aspx).
                string cv = Services.StudentDocumentService.TraineeCvUrl(placement, student);
                hlViewCV.NavigateUrl = cv; divCvContainer.Visible = !string.IsNullOrEmpty(cv);
                litInternshipTitle.Text = placement.OpportunityTitle;
                var evaluation = _evaluations.GetCompanyFinalForPlacement(placement.Id);
                if (evaluation == null)
                {
                    // Keep legacy drafts readable, but all new saves use the confidential collection.
                    txtTechSkills.Text = placement.EvalTech.ToString();
                    txtWorkQuality.Text = placement.EvalWork.ToString();
                    txtProfessionalism.Text = placement.EvalProf.ToString();
                    txtCommunication.Text = placement.EvalComm.ToString();
                    txtActualHours.Text = placement.ActualHours > 0 ? placement.ActualHours.ToString() : "";
                    SelectValue(ddlPerformance, placement.EvalPerformance);
                    SelectValue(ddlRecommendation, placement.CompanyRecommendation);
                    txtStrengths.Text = placement.EvalStrengths ?? "";
                    txtImprovements.Text = placement.EvalImprovements ?? "";
                }
                else
                {
                    var components = evaluation.Components ?? new List<GradeComponent>();
                    TextBox[] fields = { txtTechSkills, txtWorkQuality, txtProfessionalism, txtCommunication };
                    for (int i = 0; i < fields.Length; i++) fields[i].Text = i < components.Count ? components[i].Score.ToString(System.Globalization.CultureInfo.InvariantCulture) : "";
                    txtActualHours.Text = evaluation.ReportedTotalHours.ToString();
                    txtStrengths.Text = evaluation.Strengths ?? "";
                    txtImprovements.Text = evaluation.AreasForImprovement ?? "";
                    SelectValue(ddlPerformance, evaluation.Performance);
                    SelectValue(ddlRecommendation, evaluation.Recommendation);
                    if (evaluation.IsSubmitted)
                    {
                        btnSaveDraft.Enabled = false;
                        litStatusBadge.Text = "<span class=\"badge bg-success\">" + Server.HtmlEncode(L.T("Company.FinalEvaluation.SubmittedStatus")) + "</span>";
                        return;
                    }
                }
                litStatusBadge.Text = L.T("Company.FinalEvaluation.SpanClassStatusBadgeWarningI");
            }
            catch (Exception ex) { ShowPopupMessage(L.T("Shared.Popup.Error"), L.F("Company.FinalEvaluation.CouldNotLoadTraineeDetails", ex.Message), false); }
        }

        private static void SelectValue(DropDownList list, string value)
        {
            list.SelectedIndex = 0;
            if (value != null && list.Items.FindByValue(value) != null) list.SelectedValue = value;
        }

        protected void BtnMyDrafts_Click(object sender, EventArgs e)
        {
            try
            {
                gvDrafts.DataSource = MyPlacements().Where(p => {
                    var evaluation = _evaluations.GetCompanyFinalForPlacement(p.Id);
                    return evaluation != null ? !evaluation.IsSubmitted : p.EvalTech > 0 || p.EvalWork > 0 || p.EvalProf > 0 || p.EvalComm > 0;
                }).ToList();
                gvDrafts.DataBind();
                ClientScript.RegisterStartupScript(GetType(), "ShowDrafts", "bootstrap.Modal.getOrCreateInstance(document.getElementById('draftsModal')).show();", true);
            }
            catch (Exception ex) { ShowPopupMessage(L.T("Shared.Popup.Error"), L.F("Company.FinalEvaluation.CouldNotLoadDrafts", ex.Message), false); }
        }

        protected void GvDrafts_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "LoadDraft") return;
            string id = Convert.ToString(e.CommandArgument);
            if (ddlTrainees.Items.FindByValue(id) == null) return;
            ddlTrainees.SelectedValue = id; DdlTrainees_SelectedIndexChanged(null, null);
        }

        private int ReadScore(TextBox field, int maximum, bool submitted)
        {
            int value;
            if (!submitted && string.IsNullOrWhiteSpace(field.Text)) return 0;
            if (!int.TryParse(field.Text, out value) || value < 0 || value > maximum)
                throw new InvalidOperationException(L.T("Company.FinalEvaluation.InvalidScoreRange"));
            return value;
        }

        private void SaveEvaluation(bool submitted)
        {
            try
            {
                var placement = SelectedPlacement();
                int tech = ReadScore(txtTechSkills, 40, submitted), work = ReadScore(txtWorkQuality, 25, submitted),
                    prof = ReadScore(txtProfessionalism, 20, submitted), comm = ReadScore(txtCommunication, 15, submitted);
                int hours;
                if (string.IsNullOrWhiteSpace(txtActualHours.Text) && !submitted) hours = 0;
                else if (!int.TryParse(txtActualHours.Text, out hours) || hours < 0 || submitted && hours == 0)
                    throw new InvalidOperationException(L.T("Company.FinalEvaluation.PleaseCompleteActualHoursFeedbackAnd"));
                if (submitted && (string.IsNullOrEmpty(ddlPerformance.SelectedValue) || string.IsNullOrEmpty(ddlRecommendation.SelectedValue)))
                    throw new InvalidOperationException(L.T("Company.FinalEvaluation.PleaseCompleteActualHoursFeedbackAnd"));
                var previous = _evaluations.GetCompanyFinalForPlacement(placement.Id);
                if (previous != null && previous.IsSubmitted)
                    throw new InvalidOperationException(L.T("Company.FinalEvaluation.SubmittedStatus"));
                var evaluation = new FinalCompanyEvaluation {
                    Id = previous == null ? null : previous.Id, PlacementId = placement.Id, StudentId = placement.StudentId,
                    CompanyId = placement.CompanyId, SupervisorId = CurrentSupervisor.Id,
                    TotalScore = tech + work + prof + comm, MaxScore = 100,
                    Strengths = txtStrengths.Text, AreasForImprovement = txtImprovements.Text,
                    Performance = ddlPerformance.SelectedValue, Recommendation = ddlRecommendation.SelectedValue,
                    OverallComment = ddlPerformance.SelectedValue + "; " + ddlRecommendation.SelectedValue,
                    ReportedTotalHours = hours, IsSubmitted = submitted, SubmittedAt = submitted ? Time.NowMs() : 0,
                    CreatedAt = previous == null ? Time.NowMs() : previous.CreatedAt,
                    Components = new List<GradeComponent> {
                        new GradeComponent { Name="Technical skills", Score=tech, MaxScore=40, Weight=40 },
                        new GradeComponent { Name="Quality of work", Score=work, MaxScore=25, Weight=25 },
                        new GradeComponent { Name="Professionalism", Score=prof, MaxScore=20, Weight=20 },
                        new GradeComponent { Name="Communication", Score=comm, MaxScore=15, Weight=15 }
                    }
                };
                _evaluations.SaveCompanyFinal(evaluation);
                if (submitted) Services.NotificationService.CompanyEvaluationSent(placement.Id);
                DdlTrainees_SelectedIndexChanged(null, null);
                ShowPopupMessage(L.T(submitted ? "Company.FinalEvaluation.SubmittedTitle" : "Company.FinalEvaluation.DraftSaved"),
                    L.T(submitted ? "Company.FinalEvaluation.SubmittedMessage" : "Company.FinalEvaluation.YourEvaluationHasBeenSafelySaved"), true);
            }
            catch (Exception ex) { ShowPopupMessage(L.T("Shared.Popup.Error"), L.F("Company.FinalEvaluation.CouldNotSendEvaluation", ex.Message), false); }
        }

        protected void BtnSaveDraft_Click(object sender, EventArgs e) { SaveEvaluation(false); }
        protected void BtnSendEvaluation_Click(object sender, EventArgs e) { SaveEvaluation(true); }

        protected void BtnSendCertificate_Click(object sender, EventArgs e)
        {
            try
            {
                Placement placement = SelectedPlacement();
                CompletionRecord completion = new CompletionRepository().GetByPlacement(placement.Id);
                if (completion == null || completion.StudentId != placement.StudentId ||
                    !completion.IsReleasedToStudent() || string.IsNullOrWhiteSpace(completion.CertificateFileUrl))
                    throw new InvalidOperationException(L.T("Company.FinalEvaluation.CertificateAwaitingApproval"));

                Services.NotificationService.ApprovedCertificateShared(completion);
                ShowPopupMessage(L.T("Company.FinalEvaluation.CertificateSharedTitle"),
                    L.T("Company.FinalEvaluation.CertificateSharedMessage"), true);
            }
            catch (InvalidOperationException ex)
            {
                ShowPopupMessage(L.T("Shared.Popup.Error"), ex.Message, false);
            }
            catch (Exception)
            {
                ShowPopupMessage(L.T("Shared.Popup.Error"),
                    L.T("Company.FinalEvaluation.CertificateShareFailed"), false);
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
