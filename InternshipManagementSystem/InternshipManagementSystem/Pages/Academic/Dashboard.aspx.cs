using System;
using System.Collections.Generic;
using System.Linq;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;
using InternshipManagementSystem.Data;

namespace InternshipManagementSystem.Pages.Academic
{
    // Inherit from AcademicPage to secure this page (Trello S01 requirement)
    public partial class Dashboard : AcademicPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadDashboardData();
            }
        }

        private void LoadDashboardData()
        {
            // 1. Display the currently logged-in supervisor's full name
            litSupervisorName.Text = CurrentSupervisor.FullName;

            // 2. Fetch students assigned to this supervisor
            UserRepository userRepo = new UserRepository();

            // Fetch students using the exact method in UserRepository
            List<Student> myStudents = userRepo.GetStudentsBySupervisor(CurrentSupervisor.Id);

            // 3. Calculate and display statistics
            litTotalStudents.Text = myStudents.Count.ToString();

            // Count students who have completed 100% of their required hours
            int completedCount = myStudents.Count(s => s.HoursProgressPercent >= 100);
            litCompletedStudents.Text = completedCount.ToString();

            // 4. Bind the student list to the HTML Repeater
            if (myStudents.Count > 0)
            {
                rptStudents.DataSource = myStudents;
                rptStudents.DataBind();
            }
            else
            {
                // Show the empty state message if no students are found
                litNoData.Visible = true;
            }
        }
    }
}
