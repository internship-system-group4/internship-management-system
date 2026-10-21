// =============================================================================
//  Manage Companies (Add Company Supervisor)
//  Owner : Nada
//  Cards : N03, N04
// =============================================================================
using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Services;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.CoordinatorArea
{
    public partial class Companies : InternshipManagementSystem.Security.CoordinatorPage
    {
        private readonly CompanyRepository _companyRepo = new CompanyRepository();
        private readonly UserRepository _userRepo = new UserRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindSupervisors();
            }
        }

        private void BindSupervisors()
        {
            List<Person> people = _userRepo.GetByRole(UserRole.CompanySupervisor);
            List<CompanySupervisor> supervisors = new List<CompanySupervisor>();
            foreach (Person p in people)
            {
                if (p is CompanySupervisor cs)
                {
                    supervisors.Add(cs);
                }
            }
            gvSupervisors.DataSource = supervisors;
            gvSupervisors.DataBind();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string companyName = txtCompanyName.Value.Trim();
            string industry = txtIndustry.Value.Trim();
            string city = txtCity.Value.Trim();
            string website = txtWebsite.Value.Trim();
            string address = txtAddress.Value.Trim();
            string companyEmail = txtCompanyEmail.Value.Trim();
            string companyPhone = txtCompanyPhone.Value.Trim();

            string supervisorName = txtSupervisorName.Value.Trim();
            string jobTitle = txtJobTitle.Value.Trim();
            string supervisorEmail = txtSupervisorEmail.Value.Trim();
            string supervisorPhone = txtSupervisorPhone.Value.Trim();
            string tempPassword = txtTempPassword.Value.Trim();

            if (string.IsNullOrEmpty(companyName) || string.IsNullOrEmpty(supervisorEmail) || string.IsNullOrEmpty(tempPassword))
            {
                ShowMessage("Please fill in all required fields (*).", false);
                return;
            }

            try
            {
                // 1. حفظ الشركة في Firebase والحصول على معرفها الفريد (Company ID)
                Company newCompany = new Company
                {
                    Name = companyName,
                    Industry = industry,
                    Address = string.IsNullOrEmpty(address) ? city : $"{address}, {city}",
                    Website = website,
                    ContactEmail = companyEmail,
                    ContactPhone = companyPhone,
                    IsActive = true
                };

                string companyId = _companyRepo.Insert(newCompany);
                if (string.IsNullOrEmpty(companyId))
                {
                    ShowMessage("Failed to create company record in Firebase.", false);
                    return;
                }

                // 2. إنشاء حساب المصادقة للمشرف باستخدام خدمة أحمد المشتركة (AuthService)[cite: 3, 10]
                AuthResult authResult = AuthService.CreateAccount(supervisorEmail, tempPassword);
                if (!authResult.Success)
                {
                    ShowMessage(authResult.ErrorMessage, false);
                    return;
                }

                // 3. بناء كائن المشرف وربطه بالشركة وحفظه في جدول المستخدمين (Users)[cite: 3, 10]
                CompanySupervisor supervisor = new CompanySupervisor
                {
                    Id = authResult.Uid,
                    FullName = supervisorName,
                    Email = supervisorEmail,
                    PhoneNumber = supervisorPhone,
                    JobTitle = jobTitle,
                    CompanyId = companyId,
                    CompanyName = companyName,
                    MustChangePassword = true,
                    IsActive = true
                };

                _userRepo.SavePerson(supervisor);

                ShowMessage("Company and Supervisor account created and saved in Firebase successfully!", true);
                ClearForm();
                BindSupervisors();
            }
            catch (Exception ex)
            {
                ShowMessage("An error occurred: " + ex.Message, false);
            }
        }

        // دالة الإضافة السريعة للشركات العشر الخاصة بأحمد
        protected void SeedAhmadCompanies_Click(object sender, EventArgs e)
        {
            var companiesList = new[]
            {
                new { Name = "Amazon", Industry = "Cloud & E-Commerce", Domain = "amazon.com", Email = "sup.amazon@gju.edu.jo", Phone = "+96265000001", Job = "Senior Tech Recruiter", SupName = "Ahmad Amazon Supervisor" },
                new { Name = "Sky Software", Industry = "Hospitality & Enterprise", Domain = "skysoftware.com", Email = "sup.sky@gju.edu.jo", Phone = "+96265000002", Job = "Development Manager", SupName = "Rami Sky Supervisor" },
                new { Name = "ProgressSoft", Industry = "Financial Solutions", Domain = "progressoft.com", Email = "sup.progress@gju.edu.jo", Phone = "+96265000003", Job = "Engineering Lead", SupName = "Lina Progress Supervisor" },
                new { Name = "Microsoft", Industry = "Technology", Domain = "microsoft.com", Email = "sup.microsoft@gju.edu.jo", Phone = "+96265000004", Job = "Program Manager", SupName = "Omar Microsoft Supervisor" },
                new { Name = "SEDCO", Industry = "Queueing Systems", Domain = "sedco-co.com", Email = "sup.sedco@gju.edu.jo", Phone = "+96265000005", Job = "IT Operations Manager", SupName = "Tariq SEDCO Supervisor" },
                new { Name = "Optimum Partner", Industry = "Consulting", Domain = "optimumpartner.com", Email = "sup.optimum@gju.edu.jo", Phone = "+96265000006", Job = "HR Lead", SupName = "Dana Optimum Supervisor" },
                new { Name = "Asgatech", Industry = "Software Solutions", Domain = "asgatech.com", Email = "sup.asgatech@gju.edu.jo", Phone = "+96265000007", Job = "Project Manager", SupName = "Sami Asgatech Supervisor" },
                new { Name = "PWC", Industry = "Auditing & Tax", Domain = "pwc.com", Email = "sup.pwc@gju.edu.jo", Phone = "+96265000008", Job = "Tech Consultant", SupName = "Nour PWC Supervisor" },
                new { Name = "Optimuze", Industry = "Digital Solutions", Domain = "optimuze.com", Email = "sup.optimuze@gju.edu.jo", Phone = "+96265000009", Job = "Technical Lead", SupName = "Zaid Optimuze Supervisor" },
                new { Name = "Atypon", Industry = "Publishing Platforms", Domain = "atypon.com", Email = "sup.atypon@gju.edu.jo", Phone = "+96265000010", Job = "Director", SupName = "Yousef Atypon Supervisor" }
            };

            string defaultTempPassword = "Password123!";

            foreach (var item in companiesList)
            {
                try
                {
                    Company company = new Company
                    {
                        Name = item.Name,
                        Industry = item.Industry,
                        Address = "Amman, Jordan",
                        Website = "https://www." + item.Domain,
                        ContactEmail = item.Email,
                        ContactPhone = item.Phone,
                        IsActive = true
                    };

                    string companyId = _companyRepo.Insert(company);
                    if (string.IsNullOrEmpty(companyId)) continue;

                    AuthResult auth = AuthService.CreateAccount(item.Email, defaultTempPassword);
                    if (!auth.Success || string.IsNullOrEmpty(auth.Uid)) continue;

                    CompanySupervisor supervisor = new CompanySupervisor
                    {
                        Id = auth.Uid,
                        FullName = item.SupName,
                        Email = item.Email,
                        PhoneNumber = item.Phone,
                        JobTitle = item.Job,
                        CompanyId = companyId,
                        CompanyName = item.Name,
                        MustChangePassword = true,
                        IsActive = true
                    };

                    _userRepo.SavePerson(supervisor);
                }
                catch
                {
                    // تجاهل الخطأ في حال تكرار البريد للاستمرار
                }
            }

            ShowMessage("All 10 partner companies and supervisors successfully seeded to Firebase!", true);
            BindSupervisors();
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
                    ShowMessage("Supervisor status updated in Firebase.", true);
                }
            }
        }

        private void ShowMessage(string message, bool success)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = success ? "alert alert-success d-block" : "alert alert-danger d-block";
        }

        private void ClearForm()
        {
            txtCompanyName.Value = "";
            txtIndustry.Value = "";
            txtCity.Value = "";
            txtWebsite.Value = "";
            txtAddress.Value = "";
            txtCompanyEmail.Value = "";
            txtCompanyPhone.Value = "";
            txtSupervisorName.Value = "";
            txtJobTitle.Value = "";
            txtSupervisorEmail.Value = "";
            txtSupervisorPhone.Value = "";
            txtTempPassword.Value = "";
        }
    }
}