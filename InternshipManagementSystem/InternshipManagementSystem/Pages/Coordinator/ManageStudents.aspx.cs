using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.CoordinatorArea
{
    public partial class ManageStudents : CoordinatorPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;
            foreach (string program in Constants.Programs)
                ddlEditMajor.Items.Add(new System.Web.UI.WebControls.ListItem(program, program));
            BindStudents();
            string id = Request.QueryString["id"];
            if (IsValidStudentId(id)) LoadStudent(id);
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            ClearSelection();
            BindStudents();
        }

        protected void btnClearSearch_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ClearSelection();
            BindStudents();
        }

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            var button = sender as System.Web.UI.WebControls.LinkButton;
            if (button != null && IsValidStudentId(button.CommandArgument)) LoadStudent(button.CommandArgument);
        }

        protected void btnSaveDetails_Click(object sender, EventArgs e)
        {
            string id = ViewState["EditingStudentId"] as string;
            pnlDetails.Visible = IsValidStudentId(id);
            if (!pnlDetails.Visible)
            {
                ShowListMessage("Select a student before saving changes.");
                return;
            }

           string university = InternshipManagementSystem.Common.Validators.Clean(txtEditUniversity.Text);
            string college = InternshipManagementSystem.Common.Validators.Clean(txtEditCollege.Text);
            string major = InternshipManagementSystem.Common.Validators.Clean(ddlEditMajor.SelectedValue);
            int requiredHours;
            if (university == null || college == null || major == null)
            {
                ShowDetailsMessage("Complete all academic information fields.", false);
                return;
            }
            if (university.Length > 120 || college.Length > 120 || major.Length > 120)
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
                if (users.GetStudent(id) == null)
                {
                    ClearSelection();
                    BindStudents();
                    ShowListMessage("Student record not found.");
                    return;
                }
                users.Update(id, new Dictionary<string, object>
                {
                    { "University", university },
                    { "College", college }, { "Major", major }, { "RequiredHours", requiredHours }
                });
               txtEditUniversity.Text = university;
                txtEditCollege.Text = college;
                ddlEditMajor.SelectedValue = major;
                txtEditRequiredHours.Text = requiredHours.ToString();
                BindStudents();
                ShowDetailsMessage("Student academic information saved.", true);
            }
            catch (FirebaseException)
            {
                ShowDetailsMessage("Could not save student information. Please try again.", false);
            }
        }

        protected void btnToggleAccess_Click(object sender, EventArgs e)
        {
            string id = ViewState["EditingStudentId"] as string;
            if (!IsValidStudentId(id))
            {
                ClearSelection();
                ShowListMessage("Select a student before changing access.");
                return;
            }
            try
            {
                UserRepository users = new UserRepository();
                Student student = users.GetStudent(id);
                if (student == null)
                {
                    ClearSelection();
                    BindStudents();
                    ShowListMessage("Student record not found.");
                    return;
                }
                bool activate = !student.IsActive;
                users.SetActive(id, activate);
                student.IsActive = activate;
                ShowDetails(student);
                BindStudents();
                ShowDetailsMessage(activate ? "Student access restored." : "Student access removed. The record and training history are retained.", true);
            }
            catch (FirebaseException)
            {
                pnlDetails.Visible = true;
                ShowDetailsMessage("Could not change student access. Please try again.", false);
            }
        }

        private void LoadStudent(string id)
        {
            try
            {
                Student student = new UserRepository().GetStudent(id);
                if (student == null)
                {
                    ClearSelection();
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

        private void ShowDetails(Student student)
        {
            ViewState["EditingStudentId"] = student.Id;
            pnlDetails.Visible = true;
            lblDetailsMessage.Visible = false;
            lblStudentName.Text = InternshipManagementSystem.Common.Validators.Safe(student.FullName);
            lblStudentEmail.Text = InternshipManagementSystem.Common.Validators.Safe(student.Email);
            txtEditStudentNumber.Text = student.StudentNumber;
            txtEditUniversity.Text = student.University;
            txtEditCollege.Text = student.College;
            if (ddlEditMajor.Items.FindByValue(student.Major) == null && !string.IsNullOrEmpty(student.Major))
                ddlEditMajor.Items.Add(new System.Web.UI.WebControls.ListItem(student.Major, student.Major));
            ddlEditMajor.SelectedValue = student.Major;
            txtEditRequiredHours.Text = student.RequiredHours.ToString();
            lnkRecord.NavigateUrl = ResolveUrl("~/Pages/Coordinator/Students.aspx?id=" + Server.UrlEncode(student.Id));
            btnToggleAccess.Text = student.IsActive ? "Remove access" : "Restore access";
            btnToggleAccess.CssClass = student.IsActive ? "btn btn-outline-danger" : "btn btn-outline-success";
            btnToggleAccess.OnClientClick = student.IsActive
                ? "return confirm('Remove this student’s access? Their record and training history will be retained.');"
                : "";
            lblAccessDescription.Text = student.IsActive
                ? "Removing access blocks sign in while keeping the record and training history. You can restore access later."
                : "This student cannot sign in. Restore access when needed.";
        }

        private void ClearSelection()
        {
            ViewState["EditingStudentId"] = null;
            pnlDetails.Visible = false;
        }

        private void BindStudents()
        {
            lblListMessage.Visible = false;
            try
            {
                var students = new List<Student>();
                string search = (txtSearch.Text ?? "").Trim();
                foreach (Person person in new UserRepository().GetByRole(UserRole.Student))
                {
                    Student student = person as Student;
                    if (student != null && (search.Length == 0 || Matches(student.FullName, search)
                        || Matches(student.StudentNumber, search) || Matches(student.Email, search)
                        || Matches(student.University, search) || Matches(student.College, search)
                        || Matches(student.Major, search))) students.Add(student);
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
            return !string.IsNullOrEmpty(value) && value.IndexOf(search, StringComparison.OrdinalIgnoreCase) >= 0;
        }

        private static bool IsValidStudentId(string id)
        {
            return !string.IsNullOrEmpty(id) && Regex.IsMatch(id, @"\A[A-Za-z0-9_-]{1,128}\z");
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
    }
}
