
using System;
using System.Text.RegularExpressions;
using System.Web;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;
using InternshipManagementSystem.Services;

namespace InternshipManagementSystem.Pages.CoordinatorArea
{
    public partial class Account : CoordinatorPage
    {
        // Disable Unobtrusive Validation for this page only.
        // Fixes the missing jQuery ScriptResourceMapping error.
        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            UnobtrusiveValidationMode =
                System.Web.UI.UnobtrusiveValidationMode.None;
        }

        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);

            if (!IsPostBack)
            {
                LoadProfile();
            }
        }

        private void LoadProfile()
        {
            Coordinator user = CurrentCoordinator;

            if (user == null)
                return;

            txtName.Text = user.FullName ?? "";
            txtPhone.Text = user.PhoneNumber ?? "";
            txtEmail.Text = user.Email ?? "";

            // Coordinator model currently has no StaffId field.
            txtStaffId.Text = user.Id ?? "";

            txtUniversity.Text = Constants.UniversityName;
            txtCollege.Text = user.College ?? "";

            lblStatus.Text = user.IsActive
                ? L.Value("Ui", "Active")
                : L.Value("Ui", "Inactive");
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            LoadProfile();
            Notice(L.T("Coordinator.Account.ChangesDiscarded"), false);
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
                return;

            string name = (txtName.Text ?? "").Trim();
            string phone = (txtPhone.Text ?? "").Trim();

            if (name.Length < 2 || name.Length > 100)
            {
                Notice(
                    L.T("Coordinator.Account.EnterAValidFullName2"),
                    true
                );
                return;
            }

            if (phone.Length > 0 &&
                !Regex.IsMatch(phone, @"^\+?[0-9\s()\-]{7,25}$"))
            {
                Notice(L.T("Coordinator.Account.EnterAValidPhoneNumber"), true);
                return;
            }

            try
            {
                Coordinator user = CurrentCoordinator;

                if (user == null)
                    return;

                // Update editable fields only.
                FirebaseContext.Patch(
                    Constants.Paths.Users + "/" + user.Id,
                    new
                    {
                        FullName = name,
                        PhoneNumber = phone
                    });

                user.FullName = name;
                user.PhoneNumber = phone;

                SessionHelper.Refresh(user);

                Notice(L.T("Coordinator.Account.ProfileUpdatedSuccessfully"), false, true);
            }
            catch (Exception)
            {
                Notice(
                    L.T("Coordinator.Account.CouldNotSaveProfilePleaseTry"),
                    true
                );
            }
        }

        protected void btnChangePassword_Click(object sender, EventArgs e)
        {
            string current = txtCurrentPassword.Text ?? "";
            string next = txtNewPassword.Text ?? "";
            string confirm = txtConfirmPassword.Text ?? "";

            if (current.Length == 0 ||
                next.Length == 0 ||
                confirm.Length == 0)
            {
                Notice(L.T("Coordinator.Account.CompleteAllPasswordFields"), true);
                return;
            }

            if (next.Length < 8 || next.Length > 128)
            {
                Notice(
                    L.T("Coordinator.Account.NewPasswordMustContain8128"),
                    true
                );
                return;
            }

            if (next != confirm)
            {
                Notice(
                    L.T("Coordinator.Account.NewPasswordsDoNotMatch"),
                    true
                );
                return;
            }

            if (current == next)
            {
                Notice(
                    L.T("Coordinator.Account.ChooseAPasswordDifferentFromThe"),
                    true
                );
                return;
            }

            try
            {
                Coordinator user = CurrentCoordinator;

                if (user == null)
                    return;

                // Verify current password through Firebase Authentication.
                AuthResult verified = AuthService.SignIn(
                    user.Email,
                    current
                );

                if (!verified.Success || verified.Uid != user.Id)
                {
                    Notice(
                        L.T("Coordinator.Account.CurrentPasswordIsIncorrectPleaseTry"),
                        true
                    );
                    return;
                }

                // Change password using a fresh authentication token.
                AuthResult updated = AuthService.ChangePassword(
                    verified.IdToken,
                    next
                );

                if (!updated.Success)
                {
                    Notice(
                        updated.ErrorMessage ?? L.T("Coordinator.Account.PasswordUpdateFailed"),
                        true
                    );
                    return;
                }

                Notice(
                    L.T("Coordinator.Account.PasswordUpdatedSuccessfully"),
                    false, true
                );
            }
            catch (Exception)
            {
                Notice(
                    L.T("Coordinator.Account.CouldNotChangePasswordPleaseTry"),
                    true
                );
            }
        }

        private void Notice(string message, bool error, bool confirmedWrite = false)
        {
            lblNotice.Text = HttpUtility.HtmlEncode(message);
            lblNotice.Attributes["role"] = error ? "alert" : "status";
            if (confirmedWrite) lblNotice.Attributes["data-ui-confirmed"] = "true";
            else lblNotice.Attributes.Remove("data-ui-confirmed");

            lblNotice.CssClass = error
                ? "ca-notice ca-notice-error"
                : "ca-notice ca-notice-success";
        }
    }
}
