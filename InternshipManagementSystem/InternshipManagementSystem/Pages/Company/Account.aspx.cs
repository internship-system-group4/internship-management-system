using System;
using System.Collections.Generic;
using System.IO;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.CompanyArea
{
    public partial class Account : InternshipManagementSystem.Security.CompanyPage
    {
        private readonly UserRepository _userRepo = new UserRepository();
        private readonly CompanyRepository _companyRepo = new CompanyRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack == false)
            {
                LoadProfileData();
            }
        }

        private void LoadProfileData()
        {
            if (CurrentSupervisor == null) return;

            try
            {
                // قراءة البيانات الأساسية المضمونة في الكلاس
                txtFullName.Text = CurrentSupervisor.FullName;
                litDisplayName.Text = CurrentSupervisor.FullName;
                litInitials.Text = GetInitials(CurrentSupervisor.FullName);

                litEmail.Text = CurrentSupervisor.Email;

                Company company = _companyRepo.GetById(CurrentSupervisor.CompanyId);
                litCompany.Text = company != null ? company.Name : "Associated Company";

                // القيم الافتراضية للحقول التي قد لا تكون في الكلاس لتجنب الخطأ
                txtPhone.Text = "";
                txtJobTitle.Text = "";

                // تركنا التحكم بالصورة مبدئياً على الدائرة النصية
                imgAvatar.Visible = false;
                divInitials.Visible = true;
            }
            catch (Exception ex)
            {
                ShowPopupMessage("Error", "Could not load profile data: " + ex.Message, false);
            }
        }

        protected void BtnSaveChanges_Click(object sender, EventArgs e)
        {
            if (CurrentSupervisor == null) return;

            try
            {
                string newName = txtFullName.Text.Trim();
                if (string.IsNullOrEmpty(newName))
                {
                    ShowPopupMessage("Missing Field", "Full Name cannot be empty.", false);
                    return;
                }

                // 1. تجهيز الـ Dictionary للتحديث في Firebase
                var updates = new Dictionary<string, object>
                {
                    { "FullName", newName },
                    { "Phone", txtPhone.Text.Trim() },
                    { "JobTitle", txtJobTitle.Text.Trim() }
                };

                // 2. معالجة الصورة المرفوعة (إذا اختار المستخدم صورة)
                string base64Image = null;
                if (fuProfileImage.HasFile)
                {
                    // تحويل الصورة لنص (Base64) لحفظها بسهولة في الفايربيس
                    using (Stream stream = fuProfileImage.PostedFile.InputStream)
                    {
                        using (MemoryStream ms = new MemoryStream())
                        {
                            stream.CopyTo(ms);
                            byte[] imageBytes = ms.ToArray();
                            string mimeType = fuProfileImage.PostedFile.ContentType;
                            base64Image = $"data:{mimeType};base64,{Convert.ToBase64String(imageBytes)}";

                            // إضافة الصورة للـ Dictionary
                            updates.Add("ProfileImageBase64", base64Image);
                        }
                    }
                }

                // 3. تحديث الفايربيس
                _userRepo.Update(CurrentSupervisor.Id, updates);

                // 4. تحديث الواجهة فوراً ليرى المستخدم التغيير بدون Refresh
                litDisplayName.Text = newName;
                litInitials.Text = GetInitials(newName);

                litPhone.Text = string.IsNullOrEmpty(txtPhone.Text) ? "Not provided" : txtPhone.Text;
                litJobTitle.Text = string.IsNullOrEmpty(txtJobTitle.Text) ? "Not provided" : txtJobTitle.Text;

                // إذا رفع صورة، نظهر الصورة ونخفي دائرة الأحرف
                if (!string.IsNullOrEmpty(base64Image))
                {
                    imgAvatar.ImageUrl = base64Image;
                    imgAvatar.Visible = true;
                    divInitials.Visible = false;
                }

                ShowPopupMessage("Profile Updated", "Your account settings and picture have been successfully saved.", true);
            }
            catch (Exception ex)
            {
                ShowPopupMessage("Error", "Could not save changes: " + ex.Message, false);
            }
        }

        private void ShowPopupMessage(string title, string message, bool isSuccess)
        {
            litModalTitle.Text = title;
            litModalMessage.Text = message;

            if (isSuccess)
                litModalIcon.Text = "<span data-ui-confirmed='true'><i class='bi bi-check-circle-fill text-success' style='font-size: 3rem;'></i></span>";
            else
                litModalIcon.Text = "<i class='bi bi-exclamation-circle-fill text-danger' style='font-size: 3rem;'></i>";

            ClientScript.RegisterStartupScript(this.GetType(), "ShowMessage", "var myModal = new bootstrap.Modal(document.getElementById('serverMessageModal')); myModal.show();", true);
        }

        protected string GetInitials(string fullName)
        {
            if (string.IsNullOrWhiteSpace(fullName)) return "SU";
            var parts = fullName.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 1) return parts[0].Substring(0, 1).ToUpper();
            return (parts[0].Substring(0, 1) + parts[parts.Length - 1].Substring(0, 1)).ToUpper();
        }
    }
}