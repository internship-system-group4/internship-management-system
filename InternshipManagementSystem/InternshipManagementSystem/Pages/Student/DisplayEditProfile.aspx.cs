using System;
using System.Collections.Generic;
using System.Linq;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.StudentArea
{
    public partial class DisplayEditProfile : StudentPage
    {
        private string UserPath { get { return "users/" + CurrentStudent.Id; } }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) LoadProfile();
        }

        private void LoadProfile()
        {
            try
            {
                Student student = new UserRepository().GetStudent(CurrentStudent.Id);
                if (student == null) { ShowMessage("Student record was not found.", false); btnSave.Enabled = false; return; }
                txtName.Text = student.FullName;
                txtEmail.Text = student.Email;
                txtPhone.Text = student.PhoneNumber;
                txtStudentNumber.Text = student.StudentNumber;
                txtUniversity.Text = student.University;
                txtCollege.Text = student.College;
                txtMajor.Text = student.Major;
                txtRequiredHours.Text = student.RequiredHours.ToString();
                Dictionary<string, object> fields = Json.ToMap(FirebaseContext.Get(UserPath));
                txtTechnical.Text = ReadSkills(fields, "TechnicalSkills");
                txtSoft.Text = ReadSkills(fields, "SoftSkills");
            }
            catch (Exception) { ShowMessage("Unable to load your profile. Please try again.", false); btnSave.Enabled = false; }
        }

        private static string ReadSkills(Dictionary<string, object> fields, string key)
        {
            object value;
            if (!fields.TryGetValue(key, out value) || value == null) return "";
            object[] items = value as object[];
            if (items != null) return string.Join(", ", items.Select(x => Convert.ToString(x)));
            return Convert.ToString(value);
        }

        private static string[] ParseSkills(string input)
        {
            return (input ?? "").Split(new[] { ',', '\n', '\r' }, StringSplitOptions.RemoveEmptyEntries)
                .Select(s => s.Trim()).Where(s => s.Length > 0).Distinct(StringComparer.OrdinalIgnoreCase)
                .Take(30).ToArray();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string phone = (txtPhone.Text ?? "").Trim();
            if (phone.Length > 25 || phone.Any(c => !(char.IsDigit(c) || " +()-".Contains(c))))
            { ShowMessage("Enter a valid phone number (digits, spaces, +, -, or parentheses).", false); return; }
            if ((txtTechnical.Text ?? "").Length > 1000 || (txtSoft.Text ?? "").Length > 1000)
            { ShowMessage("Each skills section must be 1000 characters or less.", false); return; }
            try
            {
                // Only allow-listed fields are written. Academic fields are never sent to Firebase.
                var updates = new Dictionary<string, object> {
                    { "PhoneNumber", phone },
                    { "TechnicalSkills", ParseSkills(txtTechnical.Text) },
                    { "SoftSkills", ParseSkills(txtSoft.Text) }
                };
                FirebaseContext.Patch(UserPath, updates);
                LoadProfile();
                ShowMessage("Your profile has been updated successfully.", true);
            }
            catch (Exception) { ShowMessage("Changes could not be saved. Please try again.", false); }
        }

        protected void btnCancel_Click(object sender, EventArgs e) { LoadProfile(); }

        private void ShowMessage(string message, bool success)
        {
            lblStatus.Text = Server.HtmlEncode(message);
            lblStatus.CssClass = "profile-alert alert " + (success ? "alert-success" : "alert-danger");
        }
    }
}
