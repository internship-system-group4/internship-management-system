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

        protected void StudentCreator_Created(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            pnlDetails.Visible = false;
            BindStudents();
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
                ShowListMessage(L.T("Coordinator.ManageStudents.SelectAStudentBeforeSavingChanges"));
                return;
            }

           string university = InternshipManagementSystem.Common.Validators.Clean(txtEditUniversity.Text);
            string college = InternshipManagementSystem.Common.Validators.Clean(txtEditCollege.Text);
            string major = InternshipManagementSystem.Common.Validators.Clean(ddlEditMajor.SelectedValue);
            int requiredHours;
            if (university == null || college == null || major == null)
            {
                ShowDetailsMessage(L.T("Coordinator.ManageStudents.CompleteAllAcademicInformationFields"), false);
                return;
            }
            if (university.Length > 120 || college.Length > 120 || major.Length > 120)
            {
                ShowDetailsMessage(L.T("Coordinator.ManageStudents.OneOrMoreAcademicInformationFields"), false);
                return;
            }
            if (!int.TryParse(txtEditRequiredHours.Text, out requiredHours) || requiredHours <= 0)
            {
                ShowDetailsMessage(L.T("Coordinator.ManageStudents.RequiredTrainingHoursMustBeA"), false);
                return;
            }

            try
            {
                UserRepository users = new UserRepository();
                if (users.GetStudent(id) == null)
                {
                    ClearSelection();
                    BindStudents();
                    ShowListMessage(L.T("Coordinator.ManageStudents.StudentRecordNotFound"));
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
                ShowDetailsMessage(L.T("Coordinator.ManageStudents.StudentAcademicInformationSaved"), true);
            }
            catch (FirebaseException)
            {
                ShowDetailsMessage(L.T("Coordinator.ManageStudents.CouldNotSaveStudentInformationPlease"), false);
            }
        }

        protected void btnToggleAccess_Click(object sender, EventArgs e)
        {
            string id = ViewState["EditingStudentId"] as string;
            if (!IsValidStudentId(id))
            {
                ClearSelection();
                ShowListMessage(L.T("Coordinator.ManageStudents.SelectAStudentBeforeChangingAccess"));
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
                    ShowListMessage(L.T("Coordinator.ManageStudents.StudentRecordNotFound"));
                    return;
                }
                bool activate = !student.IsActive;
                users.SetActive(id, activate);
                student.IsActive = activate;
                ShowDetails(student);
                BindStudents();
                ShowDetailsMessage(activate ? L.T("Coordinator.ManageStudents.StudentAccessRestored") : L.T("Coordinator.ManageStudents.StudentAccessRemovedTheRecordAnd"), true);
            }
            catch (FirebaseException)
            {
                pnlDetails.Visible = true;
                ShowDetailsMessage(L.T("Coordinator.ManageStudents.CouldNotChangeStudentAccessPlease"), false);
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
                    ShowListMessage(L.T("Coordinator.ManageStudents.StudentRecordNotFound"));
                    return;
                }
                ShowDetails(student);
            }
            catch (FirebaseException)
            {
                ShowListMessage(L.T("Coordinator.ManageStudents.CouldNotLoadThisStudentPlease"));
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
            btnToggleAccess.Text = student.IsActive ? L.T("Coordinator.ManageStudents.RemoveAccess") : L.T("Coordinator.ManageStudents.RestoreAccess");
            btnToggleAccess.CssClass = student.IsActive ? "btn btn-outline-danger" : "btn btn-outline-success";
            btnToggleAccess.OnClientClick = student.IsActive
                ? "return confirm('Remove this student’s access? Their record and training history will be retained.');"
                : "";
            lblAccessDescription.Text = student.IsActive
                ? L.T("Coordinator.ManageStudents.RemovingAccessBlocksSignInWhile")
                : L.T("Coordinator.ManageStudents.ThisStudentCannotSignInRestore");
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
                lblNoStudents.Text = search.Length == 0 ? L.T("Coordinator.ManageStudents.NoStudentsFound") : L.T("Coordinator.ManageStudents.NoStudentsMatchYourSearch");
                lblNoStudents.Visible = students.Count == 0;
            }
            catch (FirebaseException)
            {
                rptStudents.DataSource = new List<Student>();
                rptStudents.DataBind();
                lblNoStudents.Visible = false;
                ShowListMessage(L.T("Coordinator.ManageStudents.CouldNotLoadStudentRecordsPlease"));
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
