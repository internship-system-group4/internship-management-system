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
                ShowPopupMessage("Error", "Could not load trainees: " + ex.Message, false);
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
                    litStatusBadge.Text = "<span class='status-badge-warning'><i class='bi bi-circle-fill me-1' style='font-size: 0.4rem;'></i>In Progress</span>";

                    ClearFormFields();
                }
            }
            catch (Exception ex)
            {
                ShowPopupMessage("Error", "Could not load trainee details: " + ex.Message, false);
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
                ShowPopupMessage("Error", "Could not load drafts: " + ex.Message, false);
            }
        }

        protected void GvDrafts_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "LoadDraft")
            {
                string placementId = e.CommandArgument.ToString();
                ddlTrainees.SelectedValue = placementId;
                DdlTrainees_SelectedIndexChanged(null, null);
                ShowPopupMessage("Draft Loaded", "Draft data ready. Please open the forms to continue.", true);
            }
        }

        protected void BtnSaveDraft_Click(object sender, EventArgs e)
        {
            string placementId = ddlTrainees.SelectedValue;
            if (string.IsNullOrEmpty(placementId))
            {
                ShowPopupMessage("Select Trainee", "Please select a trainee from the dropdown first.", false);
                return;
            }

            try
            {
                // حفظ البيانات شاملة الساعات والتوصية
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
                ShowPopupMessage("Draft Saved", "Your evaluation has been safely saved to My Drafts.", true);
            }
            catch (Exception ex)
            {
                ShowPopupMessage("Error", "Could not save draft: " + ex.Message, false);
            }
        }

        protected void BtnSendEvaluation_Click(object sender, EventArgs e)
        {
            string placementId = ddlTrainees.SelectedValue;
            if (string.IsNullOrEmpty(placementId))
            {
                ShowPopupMessage("Select Trainee", "Please select a trainee to evaluate.", false);
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
                    ShowPopupMessage("Invalid Scores", "Please check your numbers. Scores cannot exceed the maximum GJU criteria values.", false);
                    return;
                }

                if (string.IsNullOrEmpty(ddlPerformance.SelectedValue) || string.IsNullOrEmpty(ddlRecommendation.SelectedValue) || string.IsNullOrEmpty(txtActualHours.Text))
                {
                    ShowPopupMessage("Missing Fields", "Please complete actual hours, feedback, and recommendation fields.", false);
                    return;
                }

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
                    { "CompanyRecommendation", ddlRecommendation.SelectedValue }
                };

                _placementRepo.Update(placementId, updates);

                litStatusBadge.Text = "<span class='status-badge-green'><i class='bi bi-circle-fill me-1' style='font-size: 0.4rem;'></i>Evaluated</span>";
                ShowPopupMessage("Certificate Issued!", "Success! Evaluation submitted to the GJU Academic Supervisor. You may now print the certificate.", true);

                ClearFormFields();
                LoadTraineesDropdown();
            }
            catch (Exception ex)
            {
                ShowPopupMessage("Error", "Could not send evaluation: " + ex.Message, false);
            }
        }

        private void ShowPopupMessage(string title, string message, bool isSuccess)
        {
            litModalTitle.Text = title;
            litModalMessage.Text = message;

            if (isSuccess)
                litModalIcon.Text = "<i class='bi bi-check-circle-fill text-success' style='font-size: 3rem;'></i>";
            else
                litModalIcon.Text = "<i class='bi bi-exclamation-circle-fill text-danger' style='font-size: 3rem;'></i>";

            ClientScript.RegisterStartupScript(this.GetType(), "ShowMessage", "var myModal = new bootstrap.Modal(document.getElementById('serverMessageModal')); myModal.show();", true);
        }

        private void ClearTraineeCard()
        {
            litStudentName.Text = "Select a trainee";
            litStudentMajor.Text = "-";
            litStudentInitials.Text = "--";
            litInternshipTitle.Text = "-";
            litStatusBadge.Text = "<span class='badge bg-secondary'>Pending</span>";
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