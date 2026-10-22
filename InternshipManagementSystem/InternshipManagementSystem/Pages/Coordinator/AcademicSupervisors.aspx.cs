using System;
using System.Collections.Generic;
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
            if (!IsPostBack) BindSupervisors();
        }

        protected void btnCreate_Click(object sender, EventArgs e)
        {
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
            pnlDetails.Visible = false;
            ViewState["EditingSupervisorId"] = null;
            BindSupervisors();
        }

        protected void btnClearSearch_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            pnlDetails.Visible = false;
            ViewState["EditingSupervisorId"] = null;
            BindSupervisors();
        }

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            var button = sender as System.Web.UI.WebControls.LinkButton;
            if (button == null) return;

            try
            {
                AcademicSupervisor supervisor = new UserRepository().GetAcademicSupervisor(button.CommandArgument);
                if (supervisor == null)
                {
                    ShowListMessage("Supervisor record not found.");
                    return;
                }
                ShowDetails(supervisor);
            }
            catch (FirebaseException)
            {
                ShowListMessage("Could not load this supervisor. Please try again.");
            }
        }

        protected void btnSaveDetails_Click(object sender, EventArgs e)
        {
            string id = ViewState["EditingSupervisorId"] as string;
            pnlDetails.Visible = !string.IsNullOrEmpty(id);
            if (string.IsNullOrEmpty(id))
            {
                ShowListMessage("Select a supervisor before saving changes.");
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
                if (users.GetAcademicSupervisor(id) == null)
                {
                    pnlDetails.Visible = false;
                    ViewState["EditingSupervisorId"] = null;
                    BindSupervisors();
                    ShowListMessage("Supervisor record not found.");
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

                txtEditFullName.Text = name;
                txtEditPhone.Text = phone;
                txtEditDepartment.Text = department;
                txtEditAcademicRank.Text = rank;
                ShowDetailsMessage("Supervisor information saved.", true);
                BindSupervisors();
            }
            catch (FirebaseException)
            {
                ShowDetailsMessage("Could not save supervisor information. Please try again.", false);
            }
        }

        private void BindSupervisors()
        {
            lblListMessage.Visible = false;
            try
            {
                List<AcademicSupervisor> supervisors = new List<AcademicSupervisor>();
                string search = (txtSearch.Text ?? "").Trim();
                foreach (Person person in new UserRepository().GetByRole(UserRole.AcademicSupervisor))
                {
                    AcademicSupervisor supervisor = person as AcademicSupervisor;
                    if (supervisor == null) continue;
                    if (search.Length == 0 || Matches(supervisor.FullName, search)
                        || Matches(supervisor.Email, search) || Matches(supervisor.Department, search)
                        || Matches(supervisor.AcademicRank, search))
                    {
                        supervisors.Add(supervisor);
                    }
                }
                supervisors.Sort((a, b) => string.Compare(a.FullName, b.FullName, StringComparison.OrdinalIgnoreCase));
                rptSupervisors.DataSource = supervisors;
                rptSupervisors.DataBind();
                lblNoSupervisors.Text = search.Length == 0 ? "No academic supervisors found." : "No supervisors match your search.";
                lblNoSupervisors.Visible = supervisors.Count == 0;
            }
            catch (FirebaseException)
            {
                rptSupervisors.DataSource = new List<AcademicSupervisor>();
                rptSupervisors.DataBind();
                lblNoSupervisors.Visible = false;
                ShowListMessage("Could not load supervisors. Please try again.");
            }
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
            lblDetailsEmail.Text = InternshipManagementSystem.Common.Validators.Safe(supervisor.Email);
            lblGroupCount.Text = supervisor.GroupIds == null ? "0" : supervisor.GroupIds.Count.ToString();
            txtEditFullName.Text = supervisor.FullName;
            txtEditPhone.Text = supervisor.PhoneNumber;
            txtEditDepartment.Text = supervisor.Department;
            txtEditAcademicRank.Text = supervisor.AcademicRank;
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

        private void ShowDetailsMessage(string message, bool success)
        {
            lblDetailsMessage.Text = InternshipManagementSystem.Common.Validators.Safe(message);
            lblDetailsMessage.CssClass = success ? "alert alert-success d-block" : "alert alert-danger d-block";
            lblDetailsMessage.Visible = true;
        }
    }
}
