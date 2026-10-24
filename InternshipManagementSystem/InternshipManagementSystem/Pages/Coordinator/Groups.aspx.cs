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
        /// <summary>One student in the group's student picker. The value in
        /// brackets in the old list was StudentNumber (the student ID).</summary>
        protected class StudentChoice
        {
            public string Id, FullName, Email, StudentNumber, Major, MajorKey, Initials, SearchText;
            public bool IsActive, Selected;
        }

        protected List<StudentChoice> Choices = new List<StudentChoice>();

        protected void Page_Load(object sender, EventArgs e)
        {
            string editId = ViewState["EditingGroupId"] as string;
            if (IsPostBack)
            {
                // Rebuild the picker and keep what the coordinator ticked.
                try { BindStudentChoices(editId, PostedStudentIds(), null); }
                catch (FirebaseException) { ShowMessage(L.T("Coordinator.Groups.CouldNotLoadGroupsAndAccount"), false); }
                return;
            }

            editId = Request.QueryString["edit"];
            try
            {
                if (string.IsNullOrEmpty(editId)) BindChoices(null, null);
                else if (Regex.IsMatch(editId, @"^[A-Za-z0-9_-]+$")) LoadGroup(editId);
                else
                {
                    BindChoices(null, null);
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
                BindChoices(null, null);
                ShowMessage(L.T("Coordinator.Groups.GroupNotFound"), false);
                return;
            }
            ViewState["EditingGroupId"] = group.Id;
            BindChoices(group.Id, group.StudentIds ?? new List<string>());
            txtName.Text = group.Name;
            txtAcademicYear.Text = group.AcademicYear;
            txtSemester.Text = group.Semester;
            if (ddlSupervisor.Items.FindByValue(group.AcademicSupervisorId) != null)
                ddlSupervisor.SelectedValue = group.AcademicSupervisorId;
            lblEditorTitle.Text = L.T("Coordinator.Groups.EditGroup");
            btnSave.Text = L.T("Coordinator.Groups.SaveChanges");
            btnCancel.Visible = true;
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string name = InternshipManagementSystem.Common.Validators.Clean(txtName.Text);
            string year = InternshipManagementSystem.Common.Validators.Clean(txtAcademicYear.Text);
            string semester = InternshipManagementSystem.Common.Validators.Clean(txtSemester.Text);
            if (name == null || name.Length > 120 || year == null || year.Length > 30
                || semester == null || semester.Length > 40)
            {
                ShowMessage(L.T("Coordinator.Groups.EnterAGroupNameOfAt"), false);
                return;
            }
            if (string.IsNullOrEmpty(ddlSupervisor.SelectedValue))
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
                AcademicSupervisorId = ddlSupervisor.SelectedValue
            };
            // Only students that were offered in the picker can be saved.
            HashSet<string> offered = new HashSet<string>(Choices.Select(c => c.Id));
            List<string> selected = PostedStudentIds().Where(offered.Contains).ToList();
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

        /// <summary>First load: supervisors drop-down and the student picker.</summary>
        private void BindChoices(string editingGroupId, List<string> selectedIds)
        {
            List<Person> people = new UserRepository().GetAllPeople();
            ddlSupervisor.Items.Clear();
            ddlSupervisor.Items.Add(new ListItem(L.T("Coordinator.Groups.SelectASupervisor"), ""));
            foreach (AcademicSupervisor supervisor in people.OfType<AcademicSupervisor>().OrderBy(p => p.FullName))
                if (supervisor.IsActive) ddlSupervisor.Items.Add(new ListItem(supervisor.FullName + " (" + supervisor.Email + ")", supervisor.Id));
            BindStudentChoices(editingGroupId, selectedIds, people);
        }

        private void BindStudentChoices(string editingGroupId, List<string> selectedIds, List<Person> people)
        {
            if (people == null) people = new UserRepository().GetAllPeople();
            List<StudentGroup> groups = new GroupRepository().GetAll();
            HashSet<string> selected = new HashSet<string>(selectedIds ?? new List<string>());
            string none = L.T("Coordinator.ManageStudents.NotRecorded");
            Choices = new List<StudentChoice>();
            foreach (Student student in people.OfType<Student>().OrderBy(p => p.FullName))
            {
                if (!GroupRepository.IsAvailableForGroup(student, groups, editingGroupId)) continue;
                AcademicProgram program = AcademicPrograms.Find(student.Major);
                Choices.Add(new StudentChoice
                {
                    Id = student.Id,
                    FullName = student.FullName ?? none,
                    Email = student.Email ?? "",
                    StudentNumber = string.IsNullOrWhiteSpace(student.StudentNumber) ? none : student.StudentNumber,
                    Major = string.IsNullOrWhiteSpace(student.Major) ? none : student.Major,
                    MajorKey = program != null ? program.Key
                        : AcademicPrograms.Quality(student.Major) == MajorQuality.Missing ? AcademicPrograms.MissingKey : AcademicPrograms.UnrecognizedKey,
                    Initials = StudentDirectoryRow.MakeInitials(student.FullName),
                    IsActive = student.IsActive,
                    Selected = selected.Contains(student.Id),
                    SearchText = string.Join(" ", new[] { student.FullName, student.Email, student.StudentNumber, student.Major }).ToLowerInvariant()
                });
            }
        }

        /// <summary>The ticked students in the picker (plain checkboxes named groupStudents).</summary>
        private List<string> PostedStudentIds()
        {
            string[] values = Request.Form.GetValues("groupStudents") ?? new string[0];
            return values.Where(v => !string.IsNullOrEmpty(v) && Regex.IsMatch(v, @"^[A-Za-z0-9_-]+$")).Distinct().ToList();
        }

        private void ShowMessage(string message, bool success)
        {
            lblMessage.Text = InternshipManagementSystem.Common.Validators.Safe(message);
            lblMessage.CssClass = success ? "alert alert-success d-block" : "alert alert-danger d-block";
            lblMessage.Visible = true;
        }
    }
}
