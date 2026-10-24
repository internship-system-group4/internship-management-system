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
                litCompany.Text = company != null ? company.Name : L.T("Company.Account.AssociatedCompanyPlaceholder");

                // القيم الافتراضية للحقول التي قد لا تكون في الكلاس لتجنب الخطأ
                txtPhone.Text = "";
                txtJobTitle.Text = "";

                string savedPhoto = CurrentSupervisor.ProfileImageBase64;
                bool hasPhoto = !string.IsNullOrEmpty(savedPhoto) &&
                    (savedPhoto.StartsWith("data:image/jpeg;base64,", StringComparison.OrdinalIgnoreCase) ||
                     savedPhoto.StartsWith("data:image/png;base64,", StringComparison.OrdinalIgnoreCase));
                imgAvatar.Visible = hasPhoto;
                if (hasPhoto) imgAvatar.ImageUrl = savedPhoto;
                divInitials.Visible = !hasPhoto;
            }
            catch (Exception ex)
            {
                ShowPopupMessage(L.T("Shared.Popup.Error"), L.F("Company.Account.CouldNotLoadProfileData", ex.Message), false);
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
                    ShowPopupMessage(L.T("Company.Account.MissingField"), L.T("Company.Account.FullNameCannotBeEmpty"), false);
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

                CurrentSupervisor.FullName = newName;
                if (!string.IsNullOrEmpty(base64Image))
                    CurrentSupervisor.ProfileImageBase64 = base64Image;
                SessionHelper.Refresh(CurrentSupervisor);

                // 4. تحديث الواجهة فوراً ليرى المستخدم التغيير بدون Refresh
                litDisplayName.Text = newName;
                litInitials.Text = GetInitials(newName);

                litPhone.Text = string.IsNullOrEmpty(txtPhone.Text) ? L.T("Company.Account.NotProvided") : txtPhone.Text;
                litJobTitle.Text = string.IsNullOrEmpty(txtJobTitle.Text) ? L.T("Company.Account.NotProvided") : txtJobTitle.Text;

                // إذا رفع صورة، نظهر الصورة ونخفي دائرة الأحرف
                if (!string.IsNullOrEmpty(base64Image))
                {
                    imgAvatar.ImageUrl = base64Image;
                    imgAvatar.Visible = true;
                    divInitials.Visible = false;
                }

                ShowPopupMessage(L.T("Company.Account.ProfileUpdated"), L.T("Company.Account.YourAccountSettingsAndPictureHave"), true);
            }
            catch (Exception ex)
            {
                ShowPopupMessage(L.T("Shared.Popup.Error"), L.F("Company.Account.CouldNotSaveChanges", ex.Message), false);
            }
        }

        private void ShowPopupMessage(string title, string message, bool isSuccess)
        {
            litModalTitle.Text = title;
            litModalMessage.Text = message;

            if (isSuccess)
                litModalIcon.Text = L.T("Company.Account.SpanDataUiConfirmedTrueI");
            else
                litModalIcon.Text = L.T("Company.Account.IClassBiBiExclamationCircle");

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