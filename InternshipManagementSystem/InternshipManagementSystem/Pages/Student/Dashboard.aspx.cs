using System;
using System.Linq;
using System.Web;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Security;
namespace InternshipManagementSystem.Pages.StudentArea
{
 public partial class Dashboard : StudentPage
 {
  protected WorkspaceStudentData Workspace;
  protected void Page_Load(object sender, EventArgs e)
  {
   litStudentName.Text=HttpUtility.HtmlEncode(CurrentStudent.FullName);
   litApplications.Text=litTasks.Text=litEvaluations.Text=litHours.Text=litProgressHours.Text=litPercent.Text="—";
   try {
    Workspace=new WorkspaceDashboardRepository().LoadStudent(CurrentStudent);Journey.Model=Workspace.Journey;Charts.Model=WorkspaceChartFactory.Student(Workspace);
    litApplications.Text=Workspace.Applications.Count.ToString();litTasks.Text=Workspace.Tasks.Count.ToString();litEvaluations.Text=Workspace.EvaluatedTasks.ToString();litHours.Text=Workspace.ApprovedHours.ToString();
    rptApplications.DataSource=Workspace.Applications.Take(3).Select(a=>new {Title=a.OpportunityTitle,Company=a.CompanyName,Date=Time.DisplayDate(a.SubmittedAt),Status=a.Status.ToString()});rptApplications.DataBind();pnlNoApplications.Visible=Workspace.Applications.Count==0;
    var work=Workspace.Tasks.Where(t=>t.Status!=InternshipTaskStatus.Graded).OrderBy(t=>t.Deadline<=0?long.MaxValue:t.Deadline).Take(4).Select(t=>new {Title=t.Title,DeadlineText=t.Deadline>0?Time.DisplayDate(t.Deadline):"No deadline",Status=t.Status.ToString()}).ToList();rptTasks.DataSource=work;rptTasks.DataBind();pnlNoTasks.Visible=work.Count==0;
    int percent=Workspace.RequiredHours>0?(int)Math.Min(100,Workspace.ApprovedHours*100/Workspace.RequiredHours):0;
    litProgressHours.Text=Workspace.RequiredHours>0?Workspace.ApprovedHours+" / "+Workspace.RequiredHours+" hours":Workspace.ApprovedHours+" hours · target not set";litPercent.Text=Workspace.RequiredHours>0?percent+"%":"Target not set";
    progressFill.Style["width"]=percent+"%";progressFill.Attributes["data-ui-progress"]="";progressFill.Attributes["data-ui-approved"]=Workspace.ApprovedHours.ToString();progressFill.Attributes["data-ui-target"]=Workspace.RequiredHours.ToString();
    pnlError.Visible=false;
   } catch(Exception ex) {System.Diagnostics.Trace.TraceError("Student workspace: "+ex.Message);pnlError.Visible=true;pnlNoApplications.Visible=pnlNoTasks.Visible=false;}
  }
 }
}
