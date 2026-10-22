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
                ShowMessage("Please fill in all required supervisor fields.", false);
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
                        ShowMessage("Please select an existing company.", false);
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
                        ShowMessage("Please fill in the required company fields.", false);
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
                    ShowMessage(authResult.ErrorMessage, false);
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

                ShowMessage("Account created successfully! Supervisor is linked to " + finalCompanyName, true);

                ClearForm();
                BindExistingCompanies();
                BindSupervisors();

                // كود إغلاق النافذة المنبثقة تلقائياً بعد النجاح
                ClientScript.RegisterStartupScript(this.GetType(), "CloseModal", "var myModalEl = document.getElementById('addSupervisorModal'); var modal = bootstrap.Modal.getInstance(myModalEl); if(modal) { modal.hide(); }", true);
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }
        }

        protected void gvSupervisors_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "ToggleStatus")
            {
                string supervisorId = e.CommandArgument.ToString();
                Person person = _userRepo.GetPerson(supervisorId);

                if (person != null)
                {
                    bool newStatus = !person.IsActive;
                    _userRepo.SetActive(supervisorId, newStatus);
                    BindSupervisors();
                    ShowMessage("Supervisor status updated successfully.", true);
                }
            }
        }

        private void ShowMessage(string msg, bool isSuccess)
        {
            lblMessage.Text = msg;
            lblMessage.CssClass = isSuccess ? "alert alert-success d-block" : "alert alert-danger d-block";
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