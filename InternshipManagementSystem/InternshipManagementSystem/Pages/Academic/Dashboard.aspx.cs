using System;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Security;
namespace InternshipManagementSystem.Pages.Academic
{
 public partial class Dashboard : AcademicPage
 {
  protected WorkspaceAcademicData Workspace;protected string LoadError;
  protected void Page_Load(object sender,EventArgs e)
  {
   litSupervisorName.Text=System.Web.HttpUtility.HtmlEncode(CurrentSupervisor.FullName);litTotalStudents.Text=litCompletedStudents.Text="—";
   try {Workspace=new WorkspaceDashboardRepository().LoadAcademic(CurrentSupervisor.Id);Journey.Model=Workspace.Journey;Charts.Model=WorkspaceChartFactory.Academic(Workspace);litTotalStudents.Text=Workspace.Students.Count.ToString();litCompletedStudents.Text=Workspace.HoursMet.ToString();rptStudents.DataSource=Workspace.Students;rptStudents.DataBind();litNoData.Visible=Workspace.Students.Count==0;}
   catch(Exception ex){System.Diagnostics.Trace.TraceError("Academic workspace: "+ex.Message);LoadError=L.T("Academic.Dashboard.WeCouldNotLoadYourAssigned");}
  }
 }
}
