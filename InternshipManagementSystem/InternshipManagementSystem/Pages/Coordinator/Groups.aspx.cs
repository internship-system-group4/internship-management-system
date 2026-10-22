using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI.WebControls;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.CoordinatorArea
{
    public partial class Groups : CoordinatorPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) BindPage();
        }

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            LinkButton button = sender as LinkButton;
            if (button == null) return;
            try
            {
                StudentGroup group = new GroupRepository().GetById(button.CommandArgument);
                if (group == null) { ShowMessage("Group not found.", false); return; }
                ViewState["EditingGroupId"] = group.Id;
                BindChoices(group.Id);
                txtName.Text = group.Name;
                txtAcademicYear.Text = group.AcademicYear;
                txtSemester.Text = group.Semester;
                if (ddlSupervisor.Items.FindByValue(group.AcademicSupervisorId) != null)
                    ddlSupervisor.SelectedValue = group.AcademicSupervisorId;
                foreach (ListItem item in cblStudents.Items)
                    item.Selected = group.StudentIds != null && group.StudentIds.Contains(item.Value);
                lblEditorTitle.Text = "Edit group";
                btnSave.Text = "Save changes";
                btnCancel.Visible = true;
                lblMessage.Visible = false;
            }
            catch (FirebaseException) { ShowMessage("Could not load this group. Please try again.", false); }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string name = InternshipManagementSystem.Common.Validators.Clean(txtName.Text);
            string year = InternshipManagementSystem.Common.Validators.Clean(txtAcademicYear.Text);
            string semester = InternshipManagementSystem.Common.Validators.Clean(txtSemester.Text);
            if (name == null || name.Length > 120 || (year != null && year.Length > 30)
                || (semester != null && semester.Length > 40))
            {
                ShowMessage("Enter a group name of at most 120 characters and check the academic fields.", false);
                return;
            }
            if (string.IsNullOrEmpty(ddlSupervisor.SelectedValue))
            {
                ShowMessage("Choose an academic supervisor.", false);
                return;
            }

            StudentGroup group = new StudentGroup
            {
                Id = ViewState["EditingGroupId"] as string,
                Name = name,
                AcademicYear = year,
                Semester = semester,
                AcademicSupervisorId = ddlSupervisor.SelectedValue
            };
            List<string> selected = cblStudents.Items.Cast<ListItem>()
                .Where(item => item.Selected).Select(item => item.Value).ToList();
            try
            {
                new GroupRepository().SaveAssignments(group, selected);
                ResetEditor();
                if (BindPage()) ShowMessage("Group and assignments saved.", true);
            }
            catch (InvalidOperationException ex) { ShowMessage(ex.Message, false); }
            catch (FirebaseException) { ShowMessage("Could not save the group. Please try again.", false); }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            ResetEditor();
            BindPage();
        }

        private bool BindPage()
        {
            try
            {
                BindChoices(null);
                List<StudentGroup> groups = new GroupRepository().GetAll();
                groups.Sort((a, b) => string.Compare(a.Name, b.Name, StringComparison.OrdinalIgnoreCase));
                rptGroups.DataSource = groups;
                rptGroups.DataBind();
                lblNoGroups.Visible = groups.Count == 0;
                return true;
            }
            catch (FirebaseException)
            {
                ShowMessage("Could not load groups and account records. Please try again.", false);
                return false;
            }
        }

        private void BindChoices(string editingGroupId)
        {
            List<Person> people = new UserRepository().GetAllPeople();
            Dictionary<string, string> groupNames = new GroupRepository().GetAll()
                .ToDictionary(group => group.Id, group => group.Name);
            ddlSupervisor.Items.Clear();
            ddlSupervisor.Items.Add(new ListItem("Select a supervisor", ""));
            foreach (AcademicSupervisor supervisor in people.OfType<AcademicSupervisor>().OrderBy(p => p.FullName))
                if (supervisor.IsActive) ddlSupervisor.Items.Add(new ListItem(supervisor.FullName + " (" + supervisor.Email + ")", supervisor.Id));

            cblStudents.Items.Clear();
            foreach (Student student in people.OfType<Student>().OrderBy(p => p.FullName))
            {
                if (!student.IsActive && student.GroupId != editingGroupId) continue;
                string label = student.FullName + " (" + student.StudentNumber + ")";
                if (!student.IsActive) label += " — inactive";
                if (!string.IsNullOrEmpty(student.GroupId) && student.GroupId != editingGroupId)
                {
                    string currentGroup;
                    groupNames.TryGetValue(student.GroupId, out currentGroup);
                    label += " — currently in " + (currentGroup ?? "another group");
                }
                cblStudents.Items.Add(new ListItem(label, student.Id));
            }
            lblNoAvailableStudents.Visible = cblStudents.Items.Count == 0;
        }

        private void ResetEditor()
        {
            ViewState["EditingGroupId"] = null;
            txtName.Text = txtAcademicYear.Text = txtSemester.Text = "";
            lblEditorTitle.Text = "Create group";
            btnSave.Text = "Create group";
            btnCancel.Visible = false;
            lblMessage.Visible = false;
        }

        private void ShowMessage(string message, bool success)
        {
            lblMessage.Text = InternshipManagementSystem.Common.Validators.Safe(message);
            lblMessage.CssClass = success ? "alert alert-success d-block" : "alert alert-danger d-block";
            lblMessage.Visible = true;
        }
    }
}
