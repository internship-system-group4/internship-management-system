using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Services;
using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;

namespace InternshipManagementSystem.Pages.CoordinatorArea
{
    public partial class Companies : InternshipManagementSystem.Security.CoordinatorPage
    {
        private readonly CompanyRepository _companyRepo = new CompanyRepository();
        private readonly UserRepository _userRepo = new UserRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack == false)
            {
                BindExistingCompanies();
                BindSupervisors();
            }
        }

        private void BindExistingCompanies()
        {
            rptExistingCompanies.DataSource = _companyRepo.GetAll();
            rptExistingCompanies.DataBind();
        }

        private void BindSupervisors()
        {
            List<CompanySupervisor> supervisorsList = new List<CompanySupervisor>();
            List<Person> allSupervisors = _userRepo.GetByRole(UserRole.CompanySupervisor);

            foreach (Person person in allSupervisors)
            {
                CompanySupervisor supervisor = person as CompanySupervisor;
                if (supervisor != null)
                {
                    supervisorsList.Add(supervisor);
                }
            }

            gvSupervisors.DataSource = supervisorsList;
            gvSupervisors.DataBind();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string supName = txtSupervisorName.Text;
            string supEmail = txtSupervisorEmail.Text;
            string tempPass = txtTempPassword.Text;
            string jobTitle = txtJobTitle.Text;
            string supPhone = txtSupervisorPhone.Text;

            if (supName == "" || supEmail == "" || tempPass == "")
            {
                ShowPopupMessage("Missing Fields", "Please fill in all required supervisor fields (*).", false);
                return;
            }

            string mode = hfCompanyMode.Value;
            string finalCompanyId = "";
            string finalCompanyName = "";

            try
            {
                if (mode == "Existing")
                {
                    finalCompanyId = hfExistingCompId.Value;
                    finalCompanyName = hfExistingCompName.Value;

                    if (finalCompanyId == "")
                    {
                        ShowPopupMessage("Action Required", "Please select an existing company from the list.", false);
                        return;
                    }
                }
                else
                {
                    string compName = txtCompanyName.Text;
                    string compInd = txtIndustry.Text;
                    string compCity = txtCity.Text;

                    if (compName == "" || compInd == "" || compCity == "")
                    {
                        ShowPopupMessage("Missing Fields", "Please fill in the required company fields (*).", false);
                        return;
                    }

                    Company newCompany = new Company();
                    newCompany.Name = compName;
                    newCompany.Industry = compInd;
                    newCompany.Website = txtWebsite.Text;
                    newCompany.ContactEmail = txtCompanyEmail.Text;
                    newCompany.ContactPhone = txtCompanyPhone.Text;
                    newCompany.IsActive = true;

                    string address = txtAddress.Text;
                    newCompany.Address = address == "" ? compCity : address + ", " + compCity;

                    finalCompanyId = _companyRepo.Insert(newCompany);
                    finalCompanyName = newCompany.Name;
                }

                AuthResult authResult = AuthService.CreateAccount(supEmail, tempPass);

                if (authResult.Success == false)
                {
                    ShowPopupMessage("Creation Failed", authResult.ErrorMessage, false);
                    return;
                }

                CompanySupervisor supervisor = new CompanySupervisor();
                supervisor.Id = authResult.Uid;
                supervisor.FullName = supName;
                supervisor.Email = supEmail;
                supervisor.PhoneNumber = supPhone;
                supervisor.JobTitle = jobTitle;
                supervisor.CompanyId = finalCompanyId;
                supervisor.CompanyName = finalCompanyName;
                supervisor.MustChangePassword = true;
                supervisor.IsActive = true;

                _userRepo.SavePerson(supervisor);

                ClearForm();
                BindExistingCompanies();
                BindSupervisors();

                litModalTitle.Text = "Success!";
                litModalMessage.Text = "Account created successfully! Supervisor is linked to " + finalCompanyName;
                litModalIcon.Text = "<i class='bi bi-check-circle-fill text-success' style='font-size: 3.5rem;'></i>";

                ClientScript.RegisterStartupScript(this.GetType(), "ShowSuccess", "hideSystemModal('addSupervisorModal'); openSystemModal('serverMessageModal');", true);
            }
            catch (Exception ex)
            {
                ShowPopupMessage("Error", "Error processing request: " + ex.Message, false);
            }
        }

        protected void gvSupervisors_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "ViewDetails")
            {
                try
                {
                    string supervisorId = e.CommandArgument.ToString();
                    Person person = _userRepo.GetPerson(supervisorId);
                    CompanySupervisor supervisor = person as CompanySupervisor;

                    if (supervisor != null)
                    {
                        litViewSupName.Text = supervisor.FullName;
                        litViewJobTitle.Text = string.IsNullOrEmpty(supervisor.JobTitle) ? "Not Provided" : supervisor.JobTitle;
                        litViewEmail.Text = supervisor.Email;
                        litViewPhone.Text = string.IsNullOrEmpty(supervisor.PhoneNumber) ? "Not Provided" : supervisor.PhoneNumber;

                        Company comp = _companyRepo.GetById(supervisor.CompanyId);
                        if (comp != null)
                        {
                            litViewCompName.Text = comp.Name;
                            litViewIndustry.Text = string.IsNullOrEmpty(comp.Industry) ? "Not Provided" : comp.Industry;
                        }
                        else
                        {
                            litViewCompName.Text = supervisor.CompanyName;
                            litViewIndustry.Text = "Not Provided";
                        }

                        ClientScript.RegisterStartupScript(this.GetType(), "OpenView", "openSystemModal('viewDetailsModal');", true);
                    }
                }
                catch (Exception ex)
                {
                    ShowPopupMessage("Error", "Error loading details: " + ex.Message, false);
                }
            }
        }

        protected void btnConfirmToggle_Click(object sender, EventArgs e)
        {
            try
            {
                string supervisorId = hfToggleSupervisorId.Value;
                if (!string.IsNullOrEmpty(supervisorId))
                {
                    Person person = _userRepo.GetPerson(supervisorId);
                    if (person != null)
                    {
                        bool newStatus = !person.IsActive;
                        _userRepo.SetActive(supervisorId, newStatus);
                        BindSupervisors();

                        string statusWord = newStatus ? "Activated" : "Deactivated";

                        litModalTitle.Text = "Status Updated";
                        litModalMessage.Text = $"The supervisor account has been {statusWord} successfully.";
                        litModalIcon.Text = "<i class='bi bi-check-circle-fill text-success' style='font-size: 3.5rem;'></i>";

                        ClientScript.RegisterStartupScript(this.GetType(), "ToggleSuccess", "hideSystemModal('confirmToggleModal'); openSystemModal('serverMessageModal');", true);
                    }
                }
            }
            catch (Exception ex)
            {
                ShowPopupMessage("Error", "Error updating status: " + ex.Message, false);
            }
        }

        private void ShowPopupMessage(string title, string message, bool isSuccess)
        {
            litModalTitle.Text = title;
            litModalMessage.Text = message;

            if (isSuccess)
                litModalIcon.Text = "<i class='bi bi-check-circle-fill text-success' style='font-size: 3.5rem;'></i>";
            else
                litModalIcon.Text = "<i class='bi bi-exclamation-circle-fill text-danger' style='font-size: 3.5rem;'></i>";

            ClientScript.RegisterStartupScript(this.GetType(), "ShowMessage", "openSystemModal('serverMessageModal');", true);
        }

        private void ClearForm()
        {
            txtCompanyName.Text = ""; txtIndustry.Text = ""; txtCity.Text = "";
            txtWebsite.Text = ""; txtAddress.Text = ""; txtCompanyEmail.Text = ""; txtCompanyPhone.Text = "";
            txtSupervisorName.Text = ""; txtJobTitle.Text = ""; txtSupervisorEmail.Text = "";
            txtSupervisorPhone.Text = ""; txtTempPassword.Text = "";
            hfExistingCompId.Value = ""; hfExistingCompName.Value = ""; hfCompanyMode.Value = "New";
        }
    }
}