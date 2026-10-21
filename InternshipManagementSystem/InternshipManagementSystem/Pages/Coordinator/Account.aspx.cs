
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
                ? "● Active"
                : "● Inactive";
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            LoadProfile();
            Notice("Changes discarded.", false);
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
                    "Enter a valid full name (2–100 characters).",
                    true
                );
                return;
            }

            if (phone.Length > 0 &&
                !Regex.IsMatch(phone, @"^\+?[0-9\s()\-]{7,25}$"))
            {
                Notice("Enter a valid phone number.", true);
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

                Notice("Profile updated successfully.", false);
            }
            catch (Exception)
            {
                Notice(
                    "Could not save profile. Please try again.",
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
                Notice("Complete all password fields.", true);
                return;
            }

            if (next.Length < 8 || next.Length > 128)
            {
                Notice(
                    "New password must contain 8–128 characters.",
                    true
                );
                return;
            }

            if (next != confirm)
            {
                Notice(
                    "New passwords do not match.",
                    true
                );
                return;
            }

            if (current == next)
            {
                Notice(
                    "Choose a password different from the current one.",
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
                        "Current password is incorrect. Please try again.",
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
                        updated.ErrorMessage ?? "Password update failed.",
                        true
                    );
                    return;
                }

                Notice(
                    "Password updated successfully.",
                    false
                );
            }
            catch (Exception)
            {
                Notice(
                    "Could not change password. Please try again.",
                    true
                );
            }
        }

        private void Notice(string message, bool error)
        {
            lblNotice.Text = HttpUtility.HtmlEncode(message);

            lblNotice.CssClass = error
                ? "ca-notice ca-notice-error"
                : "ca-notice ca-notice-success";
        }
    }
}
