using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
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
            if (IsPostBack) return;
            string editId = Request.QueryString["edit"];
            try
            {
                if (string.IsNullOrEmpty(editId)) BindChoices(null);
                else if (Regex.IsMatch(editId, @"^[A-Za-z0-9_-]+$")) LoadGroup(editId);
                else
                {
                    BindChoices(null);
                    ShowMessage(L.T("Coordinator.Groups.InvalidGroupLink"), false);
                }
            }
            catch (FirebaseException) { ShowMessage(L.T("Coordinator.Groups.CouldNotLoadGroupsAndAccount"), false); }
        }

        private void LoadGroup(string id)
        {
            StudentGroup group = new GroupRepository().GetById(id);
            if (group == null)
            {
                BindChoices(null);
                ShowMessage(L.T("Coordinator.Groups.GroupNotFound"), false);
                return;
            }
            ViewState["EditingGroupId"] = group.Id;
            BindChoices(group.Id);
            txtName.Text = group.Name;
            txtAcademicYear.Text = group.AcademicYear;
            txtSemester.Text = group.Semester;
            if (rblSupervisor.Items.FindByValue(group.AcademicSupervisorId) != null)
                rblSupervisor.SelectedValue = group.AcademicSupervisorId;
            foreach (ListItem item in cblStudents.Items)
                item.Selected = group.StudentIds != null && group.StudentIds.Contains(item.Value);
            lblEditorTitle.Text = L.T("Coordinator.Groups.EditGroup");
            btnSave.Text = L.T("Coordinator.Groups.SaveChanges");
            btnCancel.Visible = true;
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string name = InternshipManagementSystem.Common.Validators.Clean(txtName.Text);
            string year = InternshipManagementSystem.Common.Validators.Clean(txtAcademicYear.Text);
            string semester = InternshipManagementSystem.Common.Validators.Clean(txtSemester.Text);
            if (name == null || name.Length > 120 || (year != null && year.Length > 30)
                || (semester != null && semester.Length > 40))
            {
                ShowMessage(L.T("Coordinator.Groups.EnterAGroupNameOfAt"), false);
                return;
            }
            if (string.IsNullOrEmpty(rblSupervisor.SelectedValue))
            {
                ShowMessage(L.T("Coordinator.Groups.ChooseAnAcademicSupervisor"), false);
                return;
            }

            StudentGroup group = new StudentGroup
            {
                Id = ViewState["EditingGroupId"] as string,
                Name = name,
                AcademicYear = year,
                Semester = semester,
                AcademicSupervisorId = rblSupervisor.SelectedValue
            };
            List<string> selected = cblStudents.Items.Cast<ListItem>()
                .Where(item => item.Selected).Select(item => item.Value).ToList();
            try
            {
                new GroupRepository().SaveAssignments(group, selected);
                Response.Redirect(ResolveUrl("~/Pages/Coordinator/ConfiguredGroups.aspx?saved=1"), false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (InvalidOperationException ex) { ShowMessage(ex.Message, false); }
            catch (FirebaseException) { ShowMessage(L.T("Coordinator.Groups.CouldNotSaveTheGroupPlease"), false); }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect(ResolveUrl("~/Pages/Coordinator/ConfiguredGroups.aspx"), false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private void BindChoices(string editingGroupId)
        {
            List<Person> people = new UserRepository().GetAllPeople();
            List<StudentGroup> groups = new GroupRepository().GetAll();
            rblSupervisor.Items.Clear();
            foreach (AcademicSupervisor supervisor in people.OfType<AcademicSupervisor>().OrderBy(p => p.FullName))
                if (supervisor.IsActive) rblSupervisor.Items.Add(new ListItem(supervisor.FullName + " (" + supervisor.Email + ")", supervisor.Id));

            cblStudents.Items.Clear();
            foreach (Student student in people.OfType<Student>().OrderBy(p => p.FullName))
            {
                if (!GroupRepository.IsAvailableForGroup(student, groups, editingGroupId)) continue;
                string label = student.FullName + " (" + student.StudentNumber + ")";
                if (!student.IsActive) label += " — inactive";
                cblStudents.Items.Add(new ListItem(label, student.Id));
            }
            lblNoAvailableStudents.Visible = cblStudents.Items.Count == 0;
        }

        private void ShowMessage(string message, bool success)
        {
            lblMessage.Text = InternshipManagementSystem.Common.Validators.Safe(message);
            lblMessage.CssClass = success ? "alert alert-success d-block" : "alert alert-danger d-block";
            lblMessage.Visible = true;
        }
    }
}
