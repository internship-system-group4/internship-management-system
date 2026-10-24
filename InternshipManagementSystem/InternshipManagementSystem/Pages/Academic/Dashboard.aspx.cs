using System;
using System.Linq;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.Academic
{
    public partial class Dashboard : AcademicPage
    {
        protected WorkspaceAcademicData Workspace;
        protected string LoadError;

        public bool ShowAllStudents
        {
            get { return ViewState["ShowAll"] != null ? (bool)ViewState["ShowAll"] : false; }
            set { ViewState["ShowAll"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            litSupervisorName.Text = System.Web.HttpUtility.HtmlEncode(CurrentSupervisor.FullName);
            litTotalStudents.Text = litCompletedStudents.Text = "—";

            LoadDashboardData();
        }

        private void LoadDashboardData()
        {
            try
            {
                Workspace = new WorkspaceDashboardRepository().LoadAcademic(CurrentSupervisor.Id);
                Journey.Model = Workspace.Journey;
                Charts.Model = WorkspaceChartFactory.Academic(Workspace);

                litTotalStudents.Text = Workspace.Students.Count.ToString();
                litCompletedStudents.Text = Workspace.HoursMet.ToString();

                var studentsToDisplay = ShowAllStudents ? Workspace.Students : Workspace.Students.Take(3).ToList();

                rptStudents.DataSource = studentsToDisplay;
                rptStudents.DataBind();

                litNoData.Visible = Workspace.Students.Count == 0;

                // التحكم بظهور الأزرار بناءً على حالة العرض
                btnSeeMore.Visible = Workspace.Students.Count > 3 && !ShowAllStudents;
                btnSeeLess.Visible = Workspace.Students.Count > 3 && ShowAllStudents;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Academic workspace: " + ex.Message);
                LoadError = L.T("Academic.Dashboard.WeCouldNotLoadYourAssigned");
            }
        }

        protected void btnSeeMore_Click(object sender, EventArgs e)
        {
            ShowAllStudents = true;
            LoadDashboardData();
        }

        protected void btnSeeLess_Click(object sender, EventArgs e)
        {
            ShowAllStudents = false;
            LoadDashboardData();
        }
    }
}