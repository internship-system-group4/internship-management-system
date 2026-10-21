using System;
using System.Collections.Generic;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;
using InternshipManagementSystem.Services;

namespace InternshipManagementSystem.Pages.CoordinatorArea
{
    public partial class Students : CoordinatorPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ddlMajor.Items.Add(new System.Web.UI.WebControls.ListItem("-- Select major --", ""));
                foreach (string program in Constants.Programs)
                    ddlMajor.Items.Add(new System.Web.UI.WebControls.ListItem(program, program));
                txtUniversity.Text = Constants.UniversityName;
                txtCollege.Text = Constants.CollegeName;
                txtRequiredHours.Text = Constants.DefaultRequiredHours.ToString();
                BindStudents();
            }
        }

        protected void btnCreate_Click(object sender, EventArgs e)
        {
            string name = InternshipManagementSystem.Common.Validators.Clean(txtFullName.Text);
            string number = InternshipManagementSystem.Common.Validators.Clean(txtStudentNumber.Text);
            string email = (txtEmail.Text ?? "").Trim();
            string university = InternshipManagementSystem.Common.Validators.Clean(txtUniversity.Text);
            string college = InternshipManagementSystem.Common.Validators.Clean(txtCollege.Text);
            string major = InternshipManagementSystem.Common.Validators.Clean(ddlMajor.SelectedValue);
            int requiredHours;

            if (name == null || number == null || university == null || college == null || major == null || string.IsNullOrEmpty(email))
            {
                ShowMessage("Complete all required fields.", false);
                return;
            }
            if (!InternshipManagementSystem.Common.Validators.IsEmail(email))
            {
                ShowMessage("Enter a valid email address.", false);
                return;
            }
            string phone = InternshipManagementSystem.Common.Validators.Clean(txtPhone.Text);
            if (name.Length > 120 || number.Length > 40 || email.Length > 254
                || university.Length > 120 || college.Length > 120 || major.Length > 120
                || (phone != null && phone.Length > 40)
                || Array.IndexOf(Constants.Programs, major) < 0)
            {
                ShowMessage("Check the length of each field and select a listed major.", false);
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
                StudentNumber = number,
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
                new UserRepository().SavePerson(student);
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
                else
                {
                    ShowMessage("The student could not be saved. Please try again.", false);
                }
                return;
            }

            ShowMessage("Student account created. Share the login email and temporary password privately.", true);
            txtFullName.Text = txtStudentNumber.Text = txtEmail.Text = txtPhone.Text = "";
            ddlMajor.SelectedIndex = 0;
            txtPassword.Text = "";
            BindStudents();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            pnlDetails.Visible = false;
            ViewState["EditingStudentId"] = null;
            BindStudents();
        }

        protected void btnClearSearch_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            pnlDetails.Visible = false;
            ViewState["EditingStudentId"] = null;
            BindStudents();
        }

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            var button = sender as System.Web.UI.WebControls.LinkButton;
            if (button == null) return;

            try
            {
                Student student = new UserRepository().GetStudent(button.CommandArgument);
                if (student == null)
                {
                    ShowListMessage("Student record not found.");
                    return;
                }
                ShowDetails(student);
            }
            catch (FirebaseException)
            {
                ShowListMessage("Could not load this student. Please try again.");
            }
        }

        protected void btnSaveDetails_Click(object sender, EventArgs e)
        {
            string id = ViewState["EditingStudentId"] as string;
            pnlDetails.Visible = !string.IsNullOrEmpty(id);
            if (string.IsNullOrEmpty(id))
            {
                ShowListMessage("Select a student before saving changes.");
                return;
            }

            string number = InternshipManagementSystem.Common.Validators.Clean(txtEditStudentNumber.Text);
            string university = InternshipManagementSystem.Common.Validators.Clean(txtEditUniversity.Text);
            string college = InternshipManagementSystem.Common.Validators.Clean(txtEditCollege.Text);
            string major = InternshipManagementSystem.Common.Validators.Clean(txtEditMajor.Text);
            int requiredHours;

            if (number == null || university == null || college == null || major == null)
            {
                ShowDetailsMessage("Complete all academic information fields.", false);
                return;
            }
            if (number.Length > 40 || university.Length > 120 || college.Length > 120 || major.Length > 120)
            {
                ShowDetailsMessage("One or more academic information fields are too long.", false);
                return;
            }
            if (!int.TryParse(txtEditRequiredHours.Text, out requiredHours) || requiredHours <= 0)
            {
                ShowDetailsMessage("Required training hours must be a positive whole number.", false);
                return;
            }

            try
            {
                UserRepository users = new UserRepository();
                Student student = users.GetStudent(id);
                if (student == null)
                {
                    pnlDetails.Visible = false;
                    ViewState["EditingStudentId"] = null;
                    BindStudents();
                    ShowListMessage("Student record not found.");
                    return;
                }

                // Update only coordinator-owned academic fields. Other profile data
                // may have changed since the details form was opened.
                users.Update(id, new Dictionary<string, object>
                {
                    { "StudentNumber", number },
                    { "University", university },
                    { "College", college },
                    { "Major", major },
                    { "RequiredHours", requiredHours }
                });

                txtEditStudentNumber.Text = number;
                txtEditUniversity.Text = university;
                txtEditCollege.Text = college;
                txtEditMajor.Text = major;
                txtEditRequiredHours.Text = requiredHours.ToString();
                ShowDetailsMessage("Student academic information saved.", true);
                BindStudents();
            }
            catch (FirebaseException)
            {
                ShowDetailsMessage("Could not save student information. Please try again.", false);
            }
        }

        private void BindStudents()
        {
            lblListMessage.Visible = false;
            try
            {
                List<Student> students = new List<Student>();
                string search = (txtSearch.Text ?? "").Trim();
                foreach (Person person in new UserRepository().GetByRole(UserRole.Student))
                {
                    Student student = person as Student;
                    if (student == null) continue;
                    if (search.Length == 0 || Matches(student.FullName, search)
                        || Matches(student.StudentNumber, search) || Matches(student.Email, search)
                        || Matches(student.University, search) || Matches(student.College, search)
                        || Matches(student.Major, search))
                    {
                        students.Add(student);
                    }
                }
                students.Sort((a, b) => string.Compare(a.FullName, b.FullName, StringComparison.OrdinalIgnoreCase));
                rptStudents.DataSource = students;
                rptStudents.DataBind();
                lblNoStudents.Text = search.Length == 0 ? "No students found." : "No students match your search.";
                lblNoStudents.Visible = students.Count == 0;
            }
            catch (FirebaseException)
            {
                rptStudents.DataSource = new List<Student>();
                rptStudents.DataBind();
                lblNoStudents.Visible = false;
                ShowListMessage("Could not load student records. Please try again.");
            }
        }

        private static bool Matches(string value, string search)
        {
            return !string.IsNullOrEmpty(value)
                && value.IndexOf(search, StringComparison.OrdinalIgnoreCase) >= 0;
        }

        private void ShowDetails(Student student)
        {
            ViewState["EditingStudentId"] = student.Id;
            pnlDetails.Visible = true;
            lblDetailsMessage.Visible = false;
            lblStudentName.Text = InternshipManagementSystem.Common.Validators.Safe(student.FullName);
            lblStudentEmail.Text = InternshipManagementSystem.Common.Validators.Safe(student.Email);
            lblStudentPhone.Text = InternshipManagementSystem.Common.Validators.Safe(student.PhoneNumber);
            lblApprovedHours.Text = student.ApprovedHours.ToString();
            txtEditStudentNumber.Text = student.StudentNumber;
            txtEditUniversity.Text = student.University;
            txtEditCollege.Text = student.College;
            txtEditMajor.Text = student.Major;
            txtEditRequiredHours.Text = student.RequiredHours.ToString();
        }

        private void ShowListMessage(string message)
        {
            lblListMessage.Text = InternshipManagementSystem.Common.Validators.Safe(message);
            lblListMessage.CssClass = "alert alert-danger d-block";
            lblListMessage.Visible = true;
        }

        private void ShowDetailsMessage(string message, bool success)
        {
            lblDetailsMessage.Text = InternshipManagementSystem.Common.Validators.Safe(message);
            lblDetailsMessage.CssClass = success ? "alert alert-success d-block" : "alert alert-danger d-block";
            lblDetailsMessage.Visible = true;
        }

        private void ShowMessage(string message, bool success)
        {
            lblMessage.Text = InternshipManagementSystem.Common.Validators.Safe(message);
            lblMessage.CssClass = success ? "alert alert-success d-block" : "alert alert-danger d-block";
            lblMessage.Visible = true;
        }
    }
}
