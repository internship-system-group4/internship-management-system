using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Services;
using System;
using System.Collections.Generic;
using System.Linq;
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

        /// <summary>Puts the header row in a real &lt;thead&gt; so the shared
        /// directory table styles (and the mobile card layout) work.</summary>
        protected void Page_PreRender(object sender, EventArgs e)
        {
            if (gvSupervisors.HeaderRow != null)
                gvSupervisors.HeaderRow.TableSection = TableRowSection.TableHeader;
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

            gvSupervisors.DataSource = supervisorsList.OrderBy(supervisor => supervisor.CreatedAt).ThenBy(supervisor => supervisor.Id, StringComparer.Ordinal).ToList();
            gvSupervisors.DataBind();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string supName = txtSupervisorName.Text;
            string supEmail = txtSupervisorEmail.Text;
            string tempPass = txtTempPassword.Text;
            string jobTitle = txtJobTitle.Text;
            string supPhone = (txtSupervisorPhone.Text ?? "").Trim();

            if (supName == "" || supEmail == "" || tempPass == "")
            {
                ShowPopupMessage(L.T("Coordinator.Companies.MissingFields"), L.T("Coordinator.Companies.PleaseFillInAllRequiredSupervisor"), false);
                return;
            }
            // The supervisor's phone is required: exactly 10 digits (e.g. 0791234567).
            if (!InternshipManagementSystem.Common.Validators.IsPhone10(supPhone))
            {
                ShowPopupMessage(L.T("Coordinator.Companies.MissingFields"), L.T("Coordinator.Phone.Invalid"), false);
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
                        ShowPopupMessage(L.T("Coordinator.Companies.ActionRequired"), L.T("Coordinator.Companies.PleaseSelectAnExistingCompanyFrom"), false);
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
                        ShowPopupMessage(L.T("Coordinator.Companies.MissingFields"), L.T("Coordinator.Companies.PleaseFillInTheRequiredCompany"), false);
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
                    ShowPopupMessage(L.T("Coordinator.Companies.CreationFailed"), authResult.ErrorMessage, false);
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

                litModalTitle.Text = InternshipManagementSystem.Common.Validators.Safe(L.T("Coordinator.Companies.AccountCreatedTitle"));
                litModalMessage.Text = InternshipManagementSystem.Common.Validators.Safe(L.F("Coordinator.Companies.AccountCreatedSuccessfullySupervisorIsLinked", finalCompanyName));
                litModalIcon.Text = ResultIcon(true);

                ClientScript.RegisterStartupScript(this.GetType(), "ShowSuccess", "hideSystemModal('addSupervisorModal'); openSystemModal('serverMessageModal');", true);
            }
            catch (Exception ex)
            {
                ShowPopupMessage(L.T("Shared.Popup.Error"), L.F("Coordinator.Companies.ErrorProcessingRequest", ex.Message), false);
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
                        // Literals do not encode, so every value is HTML-encoded here.
                        litViewInitials.Text = InternshipManagementSystem.Common.Validators.Safe(StudentDirectoryRow.MakeInitials(supervisor.FullName));
                        litViewSupName.Text = InternshipManagementSystem.Common.Validators.Safe(supervisor.FullName);
                        litViewEmailHero.Text = InternshipManagementSystem.Common.Validators.Safe(supervisor.Email);
                        litViewJobTitle.Text = InternshipManagementSystem.Common.Validators.Safe(string.IsNullOrEmpty(supervisor.JobTitle) ? L.T("Coordinator.Companies.NotProvided") : supervisor.JobTitle);
                        litViewEmail.Text = InternshipManagementSystem.Common.Validators.Safe(supervisor.Email);
                        litViewPhone.Text = InternshipManagementSystem.Common.Validators.Safe(string.IsNullOrEmpty(supervisor.PhoneNumber) ? L.T("Coordinator.Companies.NotProvided") : supervisor.PhoneNumber);
                        lnkViewProfile.NavigateUrl = ResolveUrl("~/Pages/Coordinator/SupervisorProfile.aspx?id=" + Uri.EscapeDataString(supervisor.Id ?? supervisorId));

                        Company comp = _companyRepo.GetById(supervisor.CompanyId);
                        if (comp != null)
                        {
                            litViewCompName.Text = InternshipManagementSystem.Common.Validators.Safe(comp.Name);
                            litViewIndustry.Text = InternshipManagementSystem.Common.Validators.Safe(string.IsNullOrEmpty(comp.Industry) ? L.T("Coordinator.Companies.NotProvided") : comp.Industry);
                        }
                        else
                        {
                            litViewCompName.Text = InternshipManagementSystem.Common.Validators.Safe(supervisor.CompanyName);
                            litViewIndustry.Text = L.T("Coordinator.Companies.NotProvided");
                        }

                        ClientScript.RegisterStartupScript(this.GetType(), "OpenView", "openSystemModal('viewDetailsModal');", true);
                    }
                }
                catch (Exception ex)
                {
                    ShowPopupMessage(L.T("Shared.Popup.Error"), L.F("Coordinator.Companies.ErrorLoadingDetails", ex.Message), false);
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

                        litModalTitle.Text = InternshipManagementSystem.Common.Validators.Safe(L.T("Coordinator.Companies.StatusUpdated"));
                        litModalMessage.Text = InternshipManagementSystem.Common.Validators.Safe(L.F(
                            newStatus ? "Coordinator.Toggle.NowActive" : "Coordinator.Toggle.NowInactive", person.FullName));
                        litModalIcon.Text = ResultIcon(true);

                        ClientScript.RegisterStartupScript(this.GetType(), "ToggleSuccess", "hideSystemModal('confirmToggleModal'); openSystemModal('serverMessageModal');", true);
                    }
                }
            }
            catch (Exception ex)
            {
                ShowPopupMessage(L.T("Shared.Popup.Error"), L.F("Coordinator.Companies.ErrorUpdatingStatus", ex.Message), false);
            }
        }

        private void ShowPopupMessage(string title, string message, bool isSuccess)
        {
            // Literals do not encode, so the texts are encoded here.
            litModalTitle.Text = InternshipManagementSystem.Common.Validators.Safe(title);
            litModalMessage.Text = InternshipManagementSystem.Common.Validators.Safe(message);
            litModalIcon.Text = ResultIcon(isSuccess);

            ClientScript.RegisterStartupScript(this.GetType(), "ShowMessage", "openSystemModal('serverMessageModal');", true);
        }

        /// <summary>The round icon at the top of the result pop-up (coordinator-pages.css).</summary>
        private static string ResultIcon(bool success)
        {
            return success
                ? "<div class=\"dir-result-icon is-success\"><span data-ui-icon=\"approved\" aria-hidden=\"true\"></span></div>"
                : "<div class=\"dir-result-icon is-warning\"><span data-ui-icon=\"warning\" aria-hidden=\"true\"></span></div>";
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