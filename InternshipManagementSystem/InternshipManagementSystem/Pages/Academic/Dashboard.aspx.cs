using System;
using System.Collections.Generic;
using System.Linq;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;
using InternshipManagementSystem.Data;

namespace InternshipManagementSystem.Pages.AcademicArea
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
            litSupervisorName.Text = Server.HtmlEncode(CurrentSupervisor.FullName);

            try
            {
                UserRepository userRepo = new UserRepository();
                List<Student> myStudents = userRepo.GetStudentsBySupervisor(CurrentSupervisor.Id);
                List<string> groupIds = CurrentSupervisor.GroupIds ?? new List<string>();
                myStudents.RemoveAll(student => !groupIds.Contains(student.GroupId));
                myStudents.Sort((a, b) => string.Compare(a.FullName, b.FullName, StringComparison.OrdinalIgnoreCase));

                litTotalStudents.Text = myStudents.Count.ToString();
                litCompletedStudents.Text = myStudents.Count(s => s.HoursProgressPercent >= 100).ToString();

                if (myStudents.Count > 0)
                {
                    rptStudents.DataSource = myStudents;
                    rptStudents.DataBind();
                }
                else
                {
                    litNoData.Visible = true;
                }
            }
            catch (FirebaseException)
            {
                lblMessage.Text = "Could not load your assigned students. Please try again.";
                lblMessage.Visible = true;
            }
        }

        protected string GetStudentProgressUrl(object id)
        {
            return ResolveUrl("~/Pages/Academic/StudentProgress.aspx?id=" + Server.UrlEncode(Convert.ToString(id)));
        }
    }
}
