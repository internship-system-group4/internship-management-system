using System;
using System.Collections.Generic;
using System.Linq;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.AcademicArea
{
    public partial class Dashboard : AcademicPage
    {
        protected bool Loaded;
        protected int StudentCount, GroupCount, HoursMetCount;
        protected long TotalApprovedHours;
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;
            try
            {
                List<Student> students = new UserRepository().GetStudentsBySupervisor(CurrentSupervisor.Id);
                List<string> groupIds = CurrentSupervisor.GroupIds ?? new List<string>();
                students.RemoveAll(student => !groupIds.Contains(student.GroupId));
                students.Sort((a, b) => string.Compare(a.FullName, b.FullName, StringComparison.OrdinalIgnoreCase));
                StudentCount = students.Count;
                GroupCount = students.Select(student => student.GroupId).Where(id => !string.IsNullOrWhiteSpace(id)).Distinct().Count();
                TotalApprovedHours = students.Sum(student => (long)student.ApprovedHours);
                HoursMetCount = students.Count(student => student.RequiredHours > 0 && student.ApprovedHours >= student.RequiredHours);
                rptStudents.DataSource = students;
                rptStudents.DataBind();
                lblNoStudents.Visible = students.Count == 0;
                pnlStudentTable.Visible = students.Count > 0;
                Loaded = true;
            }
            catch (FirebaseException)
            {
                lblMessage.Text = L.T("Academic.Dashboard.WeCouldNotLoadYourAssigned");
                lblMessage.Visible = true;
                pnlStudentTable.Visible = false;
            }
        }
    }
}
