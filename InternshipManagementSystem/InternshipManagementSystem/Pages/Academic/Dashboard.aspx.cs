using System;
using System.Collections.Generic;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.AcademicArea
{
    public partial class Dashboard : AcademicPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;
            try
            {
                List<Student> students = new UserRepository().GetStudentsBySupervisor(CurrentSupervisor.Id);
                List<string> groupIds = CurrentSupervisor.GroupIds ?? new List<string>();
                students.RemoveAll(student => !groupIds.Contains(student.GroupId));
                students.Sort((a, b) => string.Compare(a.FullName, b.FullName, StringComparison.OrdinalIgnoreCase));
                rptStudents.DataSource = students;
                rptStudents.DataBind();
                lblNoStudents.Visible = students.Count == 0;
            }
            catch (FirebaseException)
            {
                lblMessage.Text = "Could not load your assigned students. Please try again.";
                lblMessage.Visible = true;
            }
        }
    }
}
