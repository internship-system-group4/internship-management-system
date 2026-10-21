// =============================================================================
//  Manage Students
//  Owner : Ahmad
//  Cards : A05, A06
//
//  A05: the coordinator creates a student account.
//    1. AuthService.CreateAccount creates the Firebase Authentication login.
//    2. The student record is saved at users/{uid} with MustChangePassword = true,
//       so the student must change the temporary password at first login (A04).
//  A06 (searchable list with edit) is not built yet.
//
//  Namespace note: these page namespaces end in "Area" on purpose. A namespace
//  called ...Pages.Student would hide the Student model class and every file in
//  the folder would fail to compile with "Student is a namespace but is used
//  like a type". Keep the suffix.
// =============================================================================
using System;
using System.Web.UI.WebControls;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Services;

namespace InternshipManagementSystem.Pages.CoordinatorArea
{
    public partial class Students : InternshipManagementSystem.Security.CoordinatorPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            // Fill the major list from the programs in Common/Constants.cs
            ddlMajor.Items.Add(new ListItem("-- Select major --", ""));
            foreach (string program in Constants.Programs)
            {
                ddlMajor.Items.Add(new ListItem(program, program));
            }

            FillDefaults();
        }

        protected void btnCreate_Click(object sender, EventArgs e)
        {
            string fullName = txtFullName.Text.Trim();
            string studentNumber = txtStudentNumber.Text.Trim();
            string email = txtEmail.Text.Trim();
            string phone = txtPhone.Text.Trim();
            string university = txtUniversity.Text.Trim();
            string college = txtCollege.Text.Trim();
            string major = ddlMajor.SelectedValue;
            string password = txtPassword.Text;
            int requiredHours;

            // Check the input on the server
            if (fullName == "" || studentNumber == "" || university == "" || college == "" || major == "")
            {
                ShowMessage("Please fill in all required fields.", false);
                return;
            }

            if (!Common.Validators.IsEmail(email))
            {
                ShowMessage("Please enter a valid email address.", false);
                return;
            }

            if (!int.TryParse(txtRequiredHours.Text.Trim(), out requiredHours) || requiredHours <= 0)
            {
                ShowMessage("Required training hours must be a whole number greater than 0.", false);
                return;
            }

            if (!Common.Validators.IsStrongEnoughPassword(password))
            {
                ShowMessage("The temporary password must be at least 6 characters.", false);
                return;
            }

            // 1. Create the login in Firebase Authentication
            AuthResult account = AuthService.CreateAccount(email, password);
            if (!account.Success)
            {
                ShowMessage(account.ErrorMessage, false);
                return;
            }

            // 2. Save the student record at users/{uid}
            Student student = new Student();
            student.Id = account.Uid;
            student.FullName = fullName;
            student.Email = email;
            student.PhoneNumber = phone;
            student.StudentNumber = studentNumber;
            student.University = university;
            student.College = college;
            student.Major = major;
            student.RequiredHours = requiredHours;
            student.MustChangePassword = true; // must change the temporary password at first login

            try
            {
                new UserRepository().SavePerson(student);
            }
            catch (FirebaseException)
            {
                // Remove the new login again, so the coordinator can simply retry
                AuthService.DeleteAccount(account.IdToken);
                ShowMessage("The student could not be saved. Please try again.", false);
                return;
            }

            ShowMessage("Student account created for " + email + ". Give the student this email and the "
                + "temporary password. They will be asked to change it at first login.", true);
            ClearForm();
        }

        private void FillDefaults()
        {
            txtUniversity.Text = Constants.UniversityName;
            txtCollege.Text = Constants.CollegeName;
            txtRequiredHours.Text = Constants.DefaultRequiredHours.ToString();
        }

        private void ClearForm()
        {
            txtFullName.Text = "";
            txtStudentNumber.Text = "";
            txtEmail.Text = "";
            txtPhone.Text = "";
            txtPassword.Text = "";
            ddlMajor.SelectedIndex = 0;
            FillDefaults();
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            lblMessage.Text = Server.HtmlEncode(message);
            lblMessage.CssClass = isSuccess ? "alert alert-success d-block" : "alert alert-danger d-block";
            lblMessage.Visible = true;
        }
    }
}
