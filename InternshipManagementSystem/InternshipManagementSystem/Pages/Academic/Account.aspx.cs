using System;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;
using InternshipManagementSystem.Data;

namespace InternshipManagementSystem.Pages.Academic
{
    public partial class Account : AcademicPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadAccountData();
            }
        }

        private void LoadAccountData()
        {
            // Populate form with current supervisor's details
            if (CurrentSupervisor != null)
            {
                txtFullName.Text = CurrentSupervisor.FullName;
                txtEmail.Text = CurrentSupervisor.Email;
                txtDepartment.Text = CurrentSupervisor.Department;
                txtRank.Text = CurrentSupervisor.AcademicRank;
            }
        }

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtFullName.Text))
            {
                ShowMessage("Full Name is required.", false);
                return;
            }

            // Update the current supervisor object
            CurrentSupervisor.FullName = txtFullName.Text.Trim();
            CurrentSupervisor.Department = txtDepartment.Text.Trim();
            CurrentSupervisor.AcademicRank = txtRank.Text.Trim();

            try
            {
                // Save changes to Firebase
                UserRepository userRepo = new UserRepository();
                userRepo.SavePerson(CurrentSupervisor);

                // Refresh the session so the new name appears in the topbar immediately
                SessionHelper.Refresh(CurrentSupervisor);

                ShowMessage("Your profile information has been updated successfully.", true);
            }
            catch (Exception ex)
            {
                ShowMessage("An error occurred while saving. Please try again.", false);
            }
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            pnlMessage.Visible = true;
            litMessage.Text = message;

            if (isSuccess)
            {
                // Success styling (Green)
                pnlMessage.Style["background-color"] = "#e3f6ea";
                pnlMessage.Style["color"] = "#1b6b3a";
                pnlMessage.Style["border-left"] = "4px solid #1b6b3a";
            }
            else
            {
                // Error styling (Red)
                pnlMessage.Style["background-color"] = "#fdeaea";
                pnlMessage.Style["color"] = "#9b1c1c";
                pnlMessage.Style["border-left"] = "4px solid #9b1c1c";
            }
        }
    }
}
