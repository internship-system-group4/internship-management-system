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
    public partial class ConfiguredGroups : CoordinatorPage
    {
        protected const int PageSize = 10;
        protected int PageIndex
        {
            get { return (int)(ViewState["GroupPageIndex"] ?? 0); }
            set { ViewState["GroupPageIndex"] = Math.Max(0, value); }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // The details pop-up only opens for the View click that asked for it.
            pnlView.Visible = false;
            if (IsPostBack) return;
            if (BindGroups() && Request.QueryString["saved"] == "1")
                ShowMessage(L.T("Coordinator.ConfiguredGroups.GroupAndAssignmentsSaved"), true);
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            PageIndex = 0;
            BindGroups();
        }

        protected void btnClearSearch_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlYear.ClearSelection();
            ddlSemester.ClearSelection();
            ddlSupervisor.ClearSelection();
            PageIndex = 0;
            BindGroups();
        }

        protected void btnPrevious_Click(object sender, EventArgs e) { PageIndex--; BindGroups(); }
        protected void btnNext_Click(object sender, EventArgs e) { PageIndex++; BindGroups(); }

        protected string DisplayValue(string value) { return string.IsNullOrWhiteSpace(value) ? "—" : value; }

        protected string GroupInitials(string name)
        {
            string[] words = (name ?? "").Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (words.Length == 0) return "—";
            return (words.Length > 1 ? words[0].Substring(0, 1) + words[1].Substring(0, 1)
                : words[0].Substring(0, Math.Min(2, words[0].Length))).ToUpperInvariant();
        }

        private void BindFilter(DropDownList control, IEnumerable<string> values, string label)
        {
            string selected = control.SelectedValue;
            control.Items.Clear();
            control.Items.Add(new ListItem(L.T("Coordinator.ConfiguredGroups." + label), ""));
            foreach (string value in values.Where(v => !string.IsNullOrWhiteSpace(v)).Distinct(StringComparer.OrdinalIgnoreCase).OrderBy(v => v))
                control.Items.Add(new ListItem(value, value));
            if (control.Items.FindByValue(selected) != null) control.SelectedValue = selected;
        }

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            LinkButton button = sender as LinkButton;
            if (button == null || !Regex.IsMatch(button.CommandArgument ?? "", @"^[A-Za-z0-9_-]+$"))
            {
                ShowMessage(L.T("Coordinator.ConfiguredGroups.InvalidGroupLink"), false);
                return;
            }
            Response.Redirect(ResolveUrl("~/Pages/Coordinator/Groups.aspx?edit=" + Server.UrlEncode(button.CommandArgument)), false);
            Context.ApplicationInstance.CompleteRequest();
        }

        protected void btnView_Click(object sender, EventArgs e)
        {
            string id = GetGroupId(sender);
            if (id == null) return;
            try
            {
                StudentGroup group = new GroupRepository().GetById(id);
                if (group == null)
                {
                    ShowMessage(L.T("Coordinator.ConfiguredGroups.GroupNotFoundItMayHave"), false);
                    BindGroups();
                    return;
                }
                ShowGroupDetails(group);
            }
            catch (FirebaseException) { ShowMessage(L.T("Coordinator.ConfiguredGroups.CouldNotLoadTheGroupDetails"), false); }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            string id = GetGroupId(sender);
            if (id == null) return;
            try
            {
                new GroupRepository().DeleteGroup(id);
                ShowMessage(L.T("Coordinator.ConfiguredGroups.GroupDeletedItsStudentsAreNow"), true);
            }
            catch (InvalidOperationException ex) { ShowMessage(ex.Message, false); }
            catch (FirebaseException) { ShowMessage(L.T("Coordinator.ConfiguredGroups.CouldNotDeleteTheGroupPlease"), false); }
            BindGroups();
        }

        private void ShowGroupDetails(StudentGroup group)
        {
            List<Person> people = new UserRepository().GetAllPeople();
            Dictionary<string, Placement> placements = new PlacementRepository().GetAll()
                .Where(p => !string.IsNullOrEmpty(p.Id) && p.Status != PlacementStatus.Cancelled)
                .GroupBy(p => p.Id)
                .ToDictionary(g => g.Key, g => g.First());

            List<Student> members = people.OfType<Student>()
                .Where(s => s.GroupId == group.Id || (group.StudentIds != null && group.StudentIds.Contains(s.Id)))
                .OrderBy(s => s.FullName)
                .ToList();

            var rows = members.Select(student =>
            {
                Placement placement;
                placements.TryGetValue(student.Id, out placement);
                string internship = placement == null
                    ? L.T("Coordinator.ConfiguredGroups.NoInternshipYet")
                    : (placement.CompanyName ?? "Company") + " (" + placement.Status + ")";
                return new
                {
                    Name = student.FullName,
                    student.StudentNumber,
                    student.Email,
                    Major = string.IsNullOrEmpty(student.Major) ? "-" : student.Major,
                    Internship = internship,
                    Hours = student.ApprovedHours + " / " + student.RequiredHours,
                    student.IsActive
                };
            }).ToList();

            AcademicSupervisor supervisor = people.OfType<AcademicSupervisor>()
                .FirstOrDefault(p => p.Id == group.AcademicSupervisorId);
            int placed = members.Count(s => placements.ContainsKey(s.Id));

            lblViewName.Text = group.Name;
            lblViewSummary.Text = members.Count + (members.Count == 1 ? " student" : " students")
                + ", " + placed + " with an internship";
            lblViewSupervisor.Text = supervisor != null ? supervisor.FullName : (group.AcademicSupervisorName ?? L.T("Coordinator.ConfiguredGroups.NotAssigned"));
            lblViewSupervisorEmail.Text = supervisor != null ? supervisor.Email : "";
            lblViewTerm.Text = (string.IsNullOrEmpty(group.AcademicYear) ? "-" : group.AcademicYear)
                + " / " + (string.IsNullOrEmpty(group.Semester) ? "-" : group.Semester);
            lblViewCreated.Text = group.CreatedAt > 0 ? Time.DisplayDate(group.CreatedAt) : "-";

            rptViewStudents.DataSource = rows;
            rptViewStudents.DataBind();
            lblViewNoStudents.Visible = rows.Count == 0;
            pnlView.Visible = true;
        }

        private string GetGroupId(object sender)
        {
            LinkButton button = sender as LinkButton;
            if (button == null || !Regex.IsMatch(button.CommandArgument ?? "", @"^[A-Za-z0-9_-]+$"))
            {
                ShowMessage(L.T("Coordinator.ConfiguredGroups.InvalidGroupLink"), false);
                return null;
            }
            return button.CommandArgument;
        }

        private bool BindGroups()
        {
            try
            {
                List<StudentGroup> groups = new GroupRepository().GetAll();
                litTotalGroups.Text = groups.Count.ToString();
                BindFilter(ddlYear, groups.Select(g => g.AcademicYear), "AllYears");
                BindFilter(ddlSemester, groups.Select(g => g.Semester), "AllSemesters");
                // Use IDs so supervisors with the same display name remain distinct.
                string selectedSupervisor = ddlSupervisor.SelectedValue;
                ddlSupervisor.Items.Clear();
                ddlSupervisor.Items.Add(new ListItem(L.T("Coordinator.ConfiguredGroups.AllSupervisors"), ""));
                foreach (var supervisor in groups.Where(g => !string.IsNullOrWhiteSpace(g.AcademicSupervisorId))
                    .GroupBy(g => g.AcademicSupervisorId).Select(g => g.First()).OrderBy(g => g.AcademicSupervisorName))
                    ddlSupervisor.Items.Add(new ListItem(DisplayValue(supervisor.AcademicSupervisorName), supervisor.AcademicSupervisorId));
                if (ddlSupervisor.Items.FindByValue(selectedSupervisor) != null) ddlSupervisor.SelectedValue = selectedSupervisor;
                string search = (txtSearch.Text ?? "").Trim();
                if (search.Length > 0)
                    groups = groups.Where(group => Contains(group.Name, search)
                        || Contains(group.AcademicYear, search)
                        || Contains(group.Semester, search)
                        || Contains(group.AcademicSupervisorName, search)).ToList();
                groups = groups.Where(g => (ddlYear.SelectedValue == "" || g.AcademicYear == ddlYear.SelectedValue)
                    && (ddlSemester.SelectedValue == "" || g.Semester == ddlSemester.SelectedValue)
                    && (ddlSupervisor.SelectedValue == "" || g.AcademicSupervisorId == ddlSupervisor.SelectedValue)).ToList();
                groups.Sort((a, b) => string.Compare(a.Name, b.Name, StringComparison.OrdinalIgnoreCase));
                PageIndex = Math.Min(PageIndex, Math.Max(0, (groups.Count - 1) / PageSize));
                rptGroups.DataSource = groups.Skip(PageIndex * PageSize).Take(PageSize).ToList();
                rptGroups.DataBind();
                bool filtered = search.Length > 0 || ddlYear.SelectedValue != "" || ddlSemester.SelectedValue != "" || ddlSupervisor.SelectedValue != "";
                lblNoGroups.Text = filtered ? L.T("Coordinator.ConfiguredGroups.NoGroupsMatchYourSearch") : L.T("Coordinator.ConfiguredGroups.NoGroupsHaveBeenCreatedYet");
                lblNoGroups.Visible = groups.Count == 0;
                lblResults.Text = string.Format(L.T("Coordinator.ConfiguredGroups.ShowingGroups"), groups.Count == 0 ? 0 : PageIndex * PageSize + 1,
                    Math.Min((PageIndex + 1) * PageSize, groups.Count), groups.Count);
                litPage.Text = (PageIndex + 1).ToString();
                btnPrevious.Enabled = PageIndex > 0;
                btnNext.Enabled = (PageIndex + 1) * PageSize < groups.Count;
                return true;
            }
            catch (FirebaseException)
            {
                rptGroups.DataSource = new List<StudentGroup>();
                rptGroups.DataBind();
                litTotalGroups.Text = "—";
                lblResults.Text = "";
                btnPrevious.Enabled = btnNext.Enabled = false;
                ShowMessage(L.T("Coordinator.ConfiguredGroups.CouldNotLoadConfiguredGroupsPlease"), false);
                return false;
            }
        }

        private static bool Contains(string value, string search)
        {
            return value != null && value.IndexOf(search, StringComparison.OrdinalIgnoreCase) >= 0;
        }

        private void ShowMessage(string message, bool success)
        {
            lblMessage.Text = InternshipManagementSystem.Common.Validators.Safe(message);
            lblMessage.CssClass = success ? "alert alert-success d-block" : "alert alert-danger d-block";
            lblMessage.Visible = true;
        }
    }
}
