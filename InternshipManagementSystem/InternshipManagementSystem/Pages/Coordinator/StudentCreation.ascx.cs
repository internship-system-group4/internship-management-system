using System;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;
using InternshipManagementSystem.Services;

namespace InternshipManagementSystem.Pages.CoordinatorArea
{
    public partial class StudentCreation : System.Web.UI.UserControl
    {
        public event EventHandler Created;
        protected bool OpenOnLoad { get; private set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            txtUniversity.Attributes["data-reset-value"] = Constants.UniversityName;
            txtCollege.Attributes["data-reset-value"] = Constants.CollegeName;
            txtRequiredHours.Attributes["data-reset-value"] = Constants.DefaultRequiredHours.ToString();
            if (IsPostBack) return;
            OpenOnLoad = Request.QueryString["create"] == "student";
            ddlMajor.Items.Add(new System.Web.UI.WebControls.ListItem("Select a major", ""));
            foreach (string program in Constants.Programs)
                ddlMajor.Items.Add(new System.Web.UI.WebControls.ListItem(program, program));
            txtUniversity.Text = Constants.UniversityName;
            txtCollege.Text = Constants.CollegeName;
            txtRequiredHours.Text = Constants.DefaultRequiredHours.ToString();
        }

        protected void btnCreate_Click(object sender, EventArgs e)
        {
            string name = InternshipManagementSystem.Common.Validators.Clean(txtFullName.Text);
            string email = (txtEmail.Text ?? "").Trim();
            string phone = InternshipManagementSystem.Common.Validators.Clean(txtPhone.Text);
            string university = InternshipManagementSystem.Common.Validators.Clean(txtUniversity.Text);
            string college = InternshipManagementSystem.Common.Validators.Clean(txtCollege.Text);
            string major = InternshipManagementSystem.Common.Validators.Clean(ddlMajor.SelectedValue);
            int requiredHours;

            if (name == null || university == null || college == null || major == null || email.Length == 0)
            {
                ShowMessage("Complete all required fields.", false);
                return;
            }
            if (name.Length > 120 || email.Length > 254 || (phone != null && phone.Length > 40)
                || university.Length > 120 || college.Length > 120 || major.Length > 120
                || Array.IndexOf(Constants.Programs, major) < 0)
            {
                ShowMessage("One or more fields are too long.", false);
                return;
            }
            if (!InternshipManagementSystem.Common.Validators.IsEmail(email))
            {
                ShowMessage("Enter a valid email address.", false);
                return;
            }
            if (!int.TryParse(txtRequiredHours.Text, out requiredHours) || requiredHours <= 0)
            {
                ShowMessage("Required training hours must be a positive whole number.", false);
                return;
            }
            if (!InternshipManagementSystem.Common.Validators.IsStrongEnoughPassword(txtPassword.Text))
            {
                ShowMessage("The temporary password must be at least 6 characters.", false);
                return;
            }
            if (txtPassword.Text != txtConfirmPassword.Text)
            {
                ShowMessage("The passwords do not match.", false);
                return;
            }
            if (!FirebaseContext.IsConfigured)
            {
                ShowMessage("Firebase is not configured. Ask the project administrator to check the local settings.", false);
                return;
            }

            AuthResult account = AuthService.CreateAccount(email, txtPassword.Text);
            if (!account.Success || string.IsNullOrEmpty(account.Uid) || string.IsNullOrEmpty(account.IdToken))
            {
                ShowMessage(account.ErrorMessage ?? "Could not create the account.", false);
                return;
            }

            Student student = new Student
            {
                Id = account.Uid,
                FullName = name,
                // The Firebase Auth UID is already unique and is the student's
                // record ID throughout the application.
                StudentNumber = account.Uid,
                Email = email,
                PhoneNumber = phone,
                University = university,
                College = college,
                Major = major,
                RequiredHours = requiredHours,
                MustChangePassword = true
            };

            try
            {
                UserRepository users = new UserRepository();
                foreach (Person person in users.GetByRole(UserRole.Student))
                {
                    Student existing = person as Student;
                    if (existing != null && string.Equals(existing.StudentNumber, student.StudentNumber,
                        StringComparison.OrdinalIgnoreCase))
                        throw new InvalidOperationException("A student already has this generated ID.");
                }
                users.SavePerson(student);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Student profile save failed for UID {0}: {1}", account.Uid, ex);
                AuthResult rollback = AuthService.DeleteAccount(account.IdToken);
                if (!rollback.Success)
                {
                    System.Diagnostics.Trace.TraceError("Student Auth rollback failed for UID {0}: {1}", account.Uid, rollback.ErrorCode);
                    ShowMessage("The account was created but its profile could not be saved. Contact the administrator before retrying.", false);
                }
                else ShowMessage("The student could not be saved. Please try again.", false);
                return;
            }

            ShowMessage("Student account created with ID " + student.StudentNumber
                + ". Share the login email and temporary password privately.", true);
            txtFullName.Text = txtEmail.Text = txtPhone.Text = "";
            ddlMajor.SelectedIndex = 0;
            txtPassword.Text = txtConfirmPassword.Text = "";
            if (Created != null) Created(this, EventArgs.Empty);
        }

        private void ShowMessage(string message, bool success)
        {
            OpenOnLoad = !success;
            var label = success ? lblSuccess : lblMessage;
            label.Text = InternshipManagementSystem.Common.Validators.Safe(message);
            label.CssClass = success ? "alert alert-success d-block" : "alert alert-danger d-block";
            label.Visible = true;
        }
    }
}
