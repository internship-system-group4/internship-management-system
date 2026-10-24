using System;
using System.Collections.Generic;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Services;

namespace InternshipManagementSystem.Pages.Academic
{
    public partial class Account : AcademicPage
    {
        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            btnUploadPhoto.Click += btnUploadPhoto_Click;
            fuProfileImage.Attributes["onchange"] = "document.getElementById('" + btnUploadPhoto.ClientID + "').click();";
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadAccountData();
            }
        }

        private void LoadAccountData()
        {
            if (CurrentSupervisor != null)
            {
                litProfileName.Text = CurrentSupervisor.FullName;
                litProfileDept.Text = string.IsNullOrEmpty(CurrentSupervisor.Major) ? L.T("Academic.Account.AcademicStaff") : CurrentSupervisor.Major;

                if (!string.IsNullOrEmpty(CurrentSupervisor.FullName))
                {
                    litAvatarInitials.Text = CurrentSupervisor.FullName.Substring(0, 1).ToUpper();
                }

                // Personal Info
                txtFullName.Text = CurrentSupervisor.FullName;
                txtEmail.Text = CurrentSupervisor.Email;
                txtAge.Text = CurrentSupervisor.Age > 0 ? CurrentSupervisor.Age.ToString() : "";
                txtPhone.Text = CurrentSupervisor.PhoneNumber;

                // Academic Info (Read-Only)
                //txtSupervisorId.Text = CurrentSupervisor.SupervisorNumber;
                txtSupervisorId.Text = !string.IsNullOrEmpty(CurrentSupervisor.SupervisorNumber) ? CurrentSupervisor.SupervisorNumber : CurrentSupervisor.Id;
                txtUniversity.Text = string.IsNullOrEmpty(CurrentSupervisor.University) ? "German Jordanian University" : CurrentSupervisor.University;
                txtCollege.Text = CurrentSupervisor.College;
                txtMajor.Text = CurrentSupervisor.Major;
                txtEnrollmentYear.Text = CurrentSupervisor.EnrollmentYear > 0 ? CurrentSupervisor.EnrollmentYear.ToString() : "";
            }
        }

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            try
            {
                CurrentSupervisor.PhoneNumber = txtPhone.Text.Trim();

                if (int.TryParse(txtAge.Text, out int age))
                {
                    CurrentSupervisor.Age = age;
                }

                UserRepository userRepo = new UserRepository();
                userRepo.SavePerson(CurrentSupervisor);

                SessionHelper.Refresh(CurrentSupervisor);
                LoadAccountData();

                ShowMessage(L.T("Academic.Account.YourProfileInformationHasBeenUpdated"), true);
            }
            catch (Exception ex)
            {
                ShowMessage(L.F("Academic.Account.Error", ex.Message), false);
            }
        }

        protected void btnUploadPhoto_Click(object sender, EventArgs e)
        {
            if (fuProfileImage.HasFile)
            {
                try
                {
                    string extension = System.IO.Path.GetExtension(fuProfileImage.FileName).ToLower();
                    if (extension == ".jpg" || extension == ".jpeg" || extension == ".png")
                    {
                        string folderPath = Server.MapPath("~/Assets/Uploads/");
                        if (!System.IO.Directory.Exists(folderPath))
                        {
                            System.IO.Directory.CreateDirectory(folderPath);
                        }

                        string fileName = Guid.NewGuid().ToString("N") + extension;
                        string fullPath = System.IO.Path.Combine(folderPath, fileName);
                        fuProfileImage.SaveAs(fullPath);

                        string photoUrl = "~/Assets/Uploads/" + fileName;
                        new UserRepository().Update(CurrentSupervisor.Id,
                            new Dictionary<string, object> { { "ProfileImageUrl", photoUrl } });
                        CurrentSupervisor.ProfileImageUrl = photoUrl;
                        SessionHelper.Refresh(CurrentSupervisor);

                        ShowMessage(L.T("Academic.Account.ProfilePhotoUploadedSuccessfully"), true);
                    }
                    else
                    {
                        ShowMessage(L.T("Academic.Account.OnlyJpgJpegOrPngFiles"), false);
                    }
                }
                catch (Exception ex)
                {
                    ShowMessage(L.F("Academic.Account.ErrorUploadingFile", ex.Message), false);
                }
            }
            else
            {
                ShowMessage(L.T("Academic.Account.PleaseSelectAnImageFileFirst"), false);
            }
        }

        protected void btnSavePassword_Click(object sender, EventArgs e)
        {
            string newPass = txtNewPassword.Text;
            string confirmPass = txtConfirmPassword.Text;

            if (newPass != confirmPass)
            {
                ShowMessage(L.T("Academic.Account.PasswordsDoNotMatchPleaseTry"), false);
                return;
            }

            if (newPass.Length < 6)
            {
                ShowMessage(L.T("Academic.Account.PasswordMustBeAtLeast6"), false);
                return;
            }

            string idToken = Session[InternshipManagementSystem.Common.Constants.SessionTokenKey] as string;

            if (string.IsNullOrEmpty(idToken))
            {
                ShowMessage(L.T("Academic.Account.SessionExpiredPleaseLogOutAnd"), false);
                return;
            }

            AuthResult result = AuthService.ChangePassword(idToken, newPass);

            if (result.Success)
            {
                ShowMessage(L.T("Academic.Account.YourPasswordHasBeenChangedSuccessfully"), true);
                txtNewPassword.Text = "";
                txtConfirmPassword.Text = "";
            }
            else
            {
                ShowMessage(result.ErrorMessage, false);
            }
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            pnlMessage.Visible = true;
            litMessage.Text = message;
            if (isSuccess)
            {
                pnlMessage.CssClass = "alert alert-success mb-4";
                pnlMessage.Style["border-left"] = "4px solid #1b6b3a";
                pnlMessage.Style["background-color"] = "#e3f6ea";
                pnlMessage.Style["color"] = "#1b6b3a";
            }
            else
            {
                pnlMessage.CssClass = "alert alert-danger mb-4";
                pnlMessage.Style["border-left"] = "4px solid #9b1c1c";
                pnlMessage.Style["background-color"] = "#fdeaea";
                pnlMessage.Style["color"] = "#9b1c1c";
            }
        }
    }
}
