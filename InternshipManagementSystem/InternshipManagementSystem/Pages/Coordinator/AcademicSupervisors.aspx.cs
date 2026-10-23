using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;
using InternshipManagementSystem.Services;

namespace InternshipManagementSystem.Pages.CoordinatorArea
{
    public partial class AcademicSupervisors : CoordinatorPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Rebuild repeater buttons on postback before their click events are dispatched.
            BindSupervisors();
        }

        protected void btnCreate_Click(object sender, EventArgs e)
        {
            hdnActiveTab.Value = "add";
            string name = InternshipManagementSystem.Common.Validators.Clean(txtFullName.Text);
            string email = (txtEmail.Text ?? "").Trim();
            string phone = InternshipManagementSystem.Common.Validators.Clean(txtPhone.Text);
            string department = InternshipManagementSystem.Common.Validators.Clean(txtDepartment.Text);
            string rank = InternshipManagementSystem.Common.Validators.Clean(txtAcademicRank.Text);

            if (name == null || email.Length == 0 || department == null)
            {
                ShowCreateMessage("Enter a name, login email, and department.", false);
                return;
            }
            if (name.Length > 120 || email.Length > 254 || department.Length > 120
                || (phone != null && phone.Length > 40) || (rank != null && rank.Length > 80))
            {
                ShowCreateMessage("One or more fields are too long.", false);
                return;
            }
            if (!InternshipManagementSystem.Common.Validators.IsEmail(email))
            {
                ShowCreateMessage("Enter a valid email address.", false);
                return;
            }
            if (!InternshipManagementSystem.Common.Validators.IsStrongEnoughPassword(txtPassword.Text))
            {
                ShowCreateMessage("The temporary password must be at least 6 characters.", false);
                return;
            }
            if (txtPassword.Text != txtConfirmPassword.Text)
            {
                ShowCreateMessage("The passwords do not match.", false);
                return;
            }
            if (!FirebaseContext.IsConfigured)
            {
                ShowCreateMessage("Firebase is not configured. Ask the project administrator to check the local settings.", false);
                return;
            }

            AuthResult account = AuthService.CreateAccount(email, txtPassword.Text);
            if (!account.Success || string.IsNullOrEmpty(account.Uid) || string.IsNullOrEmpty(account.IdToken))
            {
                ShowCreateMessage(account.ErrorMessage ?? "Could not create the account.", false);
                return;
            }

            AcademicSupervisor supervisor = new AcademicSupervisor
            {
                Id = account.Uid,
                FullName = name,
                Email = email,
                PhoneNumber = phone,
                Department = department,
                AcademicRank = rank,
                GroupIds = new List<string>(),
                MustChangePassword = true
            };

            try
            {
                new UserRepository().SavePerson(supervisor);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Academic supervisor profile save failed for UID {0}: {1}", account.Uid, ex);
                AuthResult rollback = AuthService.DeleteAccount(account.IdToken);
                if (!rollback.Success)
                {
                    System.Diagnostics.Trace.TraceError("Academic supervisor Auth rollback failed for UID {0}: {1}", account.Uid, rollback.ErrorCode);
                    ShowCreateMessage("The account was created but its profile could not be saved. Contact the administrator before retrying.", false);
                }
                else
                {
                    ShowCreateMessage("The supervisor could not be saved. Please try again.", false);
                }
                return;
            }

            ShowCreateMessage("Academic supervisor account created. Share the login credentials privately.", true);
            txtFullName.Text = txtEmail.Text = txtPhone.Text = txtDepartment.Text = txtAcademicRank.Text = "";
            txtPassword.Text = txtConfirmPassword.Text = "";
            BindSupervisors();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            hdnActiveTab.Value = "records";
            pnlRecord.Visible = false;
            pnlDetails.Visible = false;
            ViewState["EditingSupervisorId"] = null;
            BindSupervisors();
        }

        protected void btnClearSearch_Click(object sender, EventArgs e)
        {
            hdnActiveTab.Value = "records";
            txtSearch.Text = "";
            pnlRecord.Visible = false;
            pnlDetails.Visible = false;
            ViewState["EditingSupervisorId"] = null;
            BindSupervisors();
        }

        protected void btnManageSearch_Click(object sender, EventArgs e)
        {
            hdnActiveTab.Value = "manage";
            pnlDetails.Visible = false;
            ViewState["EditingSupervisorId"] = null;
            BindSupervisors();
        }

        protected void btnClearManageSearch_Click(object sender, EventArgs e)
        {
            hdnActiveTab.Value = "manage";
            txtManageSearch.Text = "";
            pnlDetails.Visible = false;
            ViewState["EditingSupervisorId"] = null;
            BindSupervisors();
        }

        protected void btnView_Click(object sender, EventArgs e)
        {
            var button = sender as System.Web.UI.WebControls.LinkButton;
            if (button == null || !IsValidSupervisorId(button.CommandArgument)) return;
            hdnActiveTab.Value = "records";
            try
            {
                AcademicSupervisor supervisor = new UserRepository().GetAcademicSupervisor(button.CommandArgument);
                if (supervisor == null)
                {
                    ShowListMessage("Supervisor record not found.");
                    return;
                }
                lblRecordName.Text = InternshipManagementSystem.Common.Validators.Safe(supervisor.FullName);
                lblRecordEmail.Text = InternshipManagementSystem.Common.Validators.Safe(supervisor.Email);
                lblRecordPhone.Text = InternshipManagementSystem.Common.Validators.Safe(supervisor.PhoneNumber ?? "—");
                lblRecordDepartment.Text = InternshipManagementSystem.Common.Validators.Safe(supervisor.Department);
                lblRecordRank.Text = InternshipManagementSystem.Common.Validators.Safe(supervisor.AcademicRank ?? "—");
                lblRecordGroups.Text = supervisor.GroupIds == null ? "0" : supervisor.GroupIds.Count.ToString();
                lblRecordStatus.Text = supervisor.IsActive ? "Active" : "Inactive";
                pnlRecord.Visible = true;
            }
            catch (FirebaseException)
            {
                ShowListMessage("Could not load this supervisor. Please try again.");
            }
        }

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            var button = sender as System.Web.UI.WebControls.LinkButton;
            if (button == null || !IsValidSupervisorId(button.CommandArgument)) return;
            hdnActiveTab.Value = "manage";

            try
            {
                AcademicSupervisor supervisor = new UserRepository().GetAcademicSupervisor(button.CommandArgument);
                if (supervisor == null)
                {
                    ShowManageMessage("Supervisor record not found.");
                    return;
                }
                ShowDetails(supervisor);
            }
            catch (FirebaseException)
            {
                ShowManageMessage("Could not load this supervisor. Please try again.");
            }
        }

        protected void btnSaveDetails_Click(object sender, EventArgs e)
        {
            hdnActiveTab.Value = "manage";
            string id = ViewState["EditingSupervisorId"] as string;
            pnlDetails.Visible = IsValidSupervisorId(id);
            if (!pnlDetails.Visible)
            {
                ShowManageMessage("Select a supervisor before saving changes.");
                return;
            }

            string name = InternshipManagementSystem.Common.Validators.Clean(txtEditFullName.Text);
            string phone = InternshipManagementSystem.Common.Validators.Clean(txtEditPhone.Text);
            string department = InternshipManagementSystem.Common.Validators.Clean(txtEditDepartment.Text);
            string rank = InternshipManagementSystem.Common.Validators.Clean(txtEditAcademicRank.Text);
            if (name == null || department == null)
            {
                ShowDetailsMessage("Enter a name and department.", false);
                return;
            }
            if (name.Length > 120 || department.Length > 120
                || (phone != null && phone.Length > 40) || (rank != null && rank.Length > 80))
            {
                ShowDetailsMessage("One or more fields are too long.", false);
                return;
            }

            try
            {
                UserRepository users = new UserRepository();
                AcademicSupervisor supervisor = users.GetAcademicSupervisor(id);
                if (supervisor == null)
                {
                    pnlDetails.Visible = false;
                    ViewState["EditingSupervisorId"] = null;
                    BindSupervisors();
                    ShowManageMessage("Supervisor record not found.");
                    return;
                }

                // The login email and group assignments have separate workflows.
                users.Update(id, new Dictionary<string, object>
                {
                    { "FullName", name },
                    { "PhoneNumber", phone },
                    { "Department", department },
                    { "AcademicRank", rank }
                });

                supervisor.FullName = name;
                supervisor.PhoneNumber = phone;
                supervisor.Department = department;
                supervisor.AcademicRank = rank;
                ShowDetails(supervisor);
                BindSupervisors();
                ShowDetailsMessage("Supervisor information saved.", true);
            }
            catch (FirebaseException)
            {
                ShowDetailsMessage("Could not save supervisor information. Please try again.", false);
            }
        }

        protected void btnToggleAccess_Click(object sender, EventArgs e)
        {
            hdnActiveTab.Value = "manage";
            string id = ViewState["EditingSupervisorId"] as string;
            if (!IsValidSupervisorId(id))
            {
                pnlDetails.Visible = false;
                ShowManageMessage("Select a supervisor before changing access.");
                return;
            }
            try
            {
                UserRepository users = new UserRepository();
                AcademicSupervisor supervisor = users.GetAcademicSupervisor(id);
                if (supervisor == null)
                {
                    pnlDetails.Visible = false;
                    ViewState["EditingSupervisorId"] = null;
                    BindSupervisors();
                    ShowManageMessage("Supervisor record not found.");
                    return;
                }
                bool activate = !supervisor.IsActive;
                users.SetActive(id, activate);
                supervisor.IsActive = activate;
                ShowDetails(supervisor);
                BindSupervisors();
                ShowDetailsMessage(activate ? "Supervisor access restored." : "Supervisor access removed. Assigned groups and history are retained.", true);
            }
            catch (FirebaseException)
            {
                pnlDetails.Visible = true;
                ShowDetailsMessage("Could not change supervisor access. Please try again.", false);
            }
        }

        private void BindSupervisors()
        {
            lblListMessage.Visible = false;
            lblManageMessage.Visible = false;
            try
            {
                List<AcademicSupervisor> supervisors = new List<AcademicSupervisor>();
                foreach (Person person in new UserRepository().GetByRole(UserRole.AcademicSupervisor))
                {
                    AcademicSupervisor supervisor = person as AcademicSupervisor;
                    if (supervisor != null) supervisors.Add(supervisor);
                }
                supervisors.Sort((a, b) => string.Compare(a.FullName, b.FullName, StringComparison.OrdinalIgnoreCase));
                string search = (txtSearch.Text ?? "").Trim();
                string manageSearch = (txtManageSearch.Text ?? "").Trim();
                List<AcademicSupervisor> records = supervisors.FindAll(s => MatchesSearch(s, search));
                List<AcademicSupervisor> manageRecords = supervisors.FindAll(s => MatchesSearch(s, manageSearch));
                rptSupervisors.DataSource = records;
                rptSupervisors.DataBind();
                rptManageSupervisors.DataSource = manageRecords;
                rptManageSupervisors.DataBind();
                lblNoSupervisors.Text = search.Length == 0 ? "No academic supervisors found." : "No supervisors match your search.";
                lblNoSupervisors.Visible = records.Count == 0;
                lblNoManageSupervisors.Text = manageSearch.Length == 0 ? "No academic supervisors found." : "No supervisors match your search.";
                lblNoManageSupervisors.Visible = manageRecords.Count == 0;
            }
            catch (FirebaseException)
            {
                rptSupervisors.DataSource = new List<AcademicSupervisor>();
                rptSupervisors.DataBind();
                rptManageSupervisors.DataSource = new List<AcademicSupervisor>();
                rptManageSupervisors.DataBind();
                lblNoSupervisors.Visible = false;
                lblNoManageSupervisors.Visible = false;
                ShowListMessage("Could not load supervisors. Please try again.");
                ShowManageMessage("Could not load supervisors. Please try again.");
            }
        }

        private static bool MatchesSearch(AcademicSupervisor supervisor, string search)
        {
            return search.Length == 0 || Matches(supervisor.FullName, search)
                || Matches(supervisor.Email, search) || Matches(supervisor.Department, search)
                || Matches(supervisor.AcademicRank, search);
        }

        private static bool IsValidSupervisorId(string id)
        {
            return !string.IsNullOrEmpty(id) && Regex.IsMatch(id, @"\A[A-Za-z0-9_-]{1,128}\z");
        }

        private static bool Matches(string value, string search)
        {
            return !string.IsNullOrEmpty(value)
                && value.IndexOf(search, StringComparison.OrdinalIgnoreCase) >= 0;
        }

        private void ShowDetails(AcademicSupervisor supervisor)
        {
            ViewState["EditingSupervisorId"] = supervisor.Id;
            pnlDetails.Visible = true;
            lblDetailsMessage.Visible = false;
            lblDetailsName.Text = InternshipManagementSystem.Common.Validators.Safe(supervisor.FullName);
            lblDetailsEmail.Text = InternshipManagementSystem.Common.Validators.Safe(supervisor.Email);
            lblGroupCount.Text = supervisor.GroupIds == null ? "0" : supervisor.GroupIds.Count.ToString();
            txtEditFullName.Text = supervisor.FullName;
            txtEditPhone.Text = supervisor.PhoneNumber;
            txtEditDepartment.Text = supervisor.Department;
            txtEditAcademicRank.Text = supervisor.AcademicRank;
            btnToggleAccess.Text = supervisor.IsActive ? "Remove access" : "Restore access";
            btnToggleAccess.CssClass = supervisor.IsActive ? "btn btn-outline-danger" : "btn btn-outline-success";
            btnToggleAccess.OnClientClick = supervisor.IsActive
                ? "return confirm('Remove this supervisor’s access? Assigned groups and history will be retained.');"
                : "";
            lblAccessDescription.Text = supervisor.IsActive
                ? "Removing access blocks sign in. Assigned groups stay linked and may need reassignment."
                : "This supervisor cannot sign in. Restore access when needed.";
        }

        private void ShowCreateMessage(string message, bool success)
        {
            lblCreateMessage.Text = InternshipManagementSystem.Common.Validators.Safe(message);
            lblCreateMessage.CssClass = success ? "alert alert-success d-block" : "alert alert-danger d-block";
            lblCreateMessage.Visible = true;
        }

        private void ShowListMessage(string message)
        {
            lblListMessage.Text = InternshipManagementSystem.Common.Validators.Safe(message);
            lblListMessage.CssClass = "alert alert-danger d-block";
            lblListMessage.Visible = true;
        }

        private void ShowManageMessage(string message)
        {
            lblManageMessage.Text = InternshipManagementSystem.Common.Validators.Safe(message);
            lblManageMessage.CssClass = "alert alert-danger d-block";
            lblManageMessage.Visible = true;
        }

        private void ShowDetailsMessage(string message, bool success)
        {
            lblDetailsMessage.Text = InternshipManagementSystem.Common.Validators.Safe(message);
            lblDetailsMessage.CssClass = success ? "alert alert-success d-block" : "alert alert-danger d-block";
            lblDetailsMessage.Visible = true;
        }
    }
}
