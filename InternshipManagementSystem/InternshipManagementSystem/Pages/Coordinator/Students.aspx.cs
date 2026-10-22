using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.CoordinatorArea
{
    public partial class Students : CoordinatorPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;
            BindStudents();
            string id = Request.QueryString["id"];
            if (IsValidStudentId(id)) LoadStudent(id);
        }

        protected void StudentCreator_Created(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            pnlDetails.Visible = false;
            BindStudents();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            pnlDetails.Visible = false;
            BindStudents();
        }

        protected void btnClearSearch_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            pnlDetails.Visible = false;
            BindStudents();
        }

        protected void btnView_Click(object sender, EventArgs e)
        {
            var button = sender as System.Web.UI.WebControls.LinkButton;
            if (button == null || !IsValidStudentId(button.CommandArgument)) return;
            LoadStudent(button.CommandArgument);
        }

        private void LoadStudent(string id)
        {
            try
            {
                Student student = new UserRepository().GetStudent(id);
                if (student == null)
                {
                    ShowError("Student record not found.");
                    return;
                }
                lblStudentName.Text = InternshipManagementSystem.Common.Validators.Safe(student.FullName);
                lblStudentNumber.Text = InternshipManagementSystem.Common.Validators.Safe(student.StudentNumber);
                lblStudentEmail.Text = InternshipManagementSystem.Common.Validators.Safe(student.Email);
                lblStudentPhone.Text = InternshipManagementSystem.Common.Validators.Safe(student.PhoneNumber ?? "—");
                lblUniversity.Text = InternshipManagementSystem.Common.Validators.Safe(student.University);
                lblCollege.Text = InternshipManagementSystem.Common.Validators.Safe(student.College);
                lblMajor.Text = InternshipManagementSystem.Common.Validators.Safe(student.Major);
                lblApprovedHours.Text = student.ApprovedHours.ToString();
                lblRequiredHours.Text = student.RequiredHours.ToString();
                lblStatus.Text = student.IsActive ? "Active" : "Inactive";
                lnkManage.NavigateUrl = ResolveUrl("~/Pages/Coordinator/ManageStudents.aspx?id=" + Server.UrlEncode(student.Id));
                pnlDetails.Visible = true;
            }
            catch (FirebaseException)
            {
                ShowError("Could not load this student. Please try again.");
            }
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
                lblNoStudents.Text = search.Length == 0 ? "No students found. Add a student to get started." : "No students match your search.";
                lblNoStudents.Visible = students.Count == 0;
            }
            catch (FirebaseException)
            {
                rptStudents.DataSource = new List<Student>();
                rptStudents.DataBind();
                lblNoStudents.Visible = false;
                ShowError("Could not load student records. Please try again.");
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

        private void ShowError(string message)
        {
            lblListMessage.Text = InternshipManagementSystem.Common.Validators.Safe(message);
            lblListMessage.CssClass = "alert alert-danger d-block";
            lblListMessage.Visible = true;
        }
    }
}
