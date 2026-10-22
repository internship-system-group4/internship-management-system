using System;
using InternshipManagementSystem.Data;
namespace InternshipManagementSystem.Pages.CoordinatorArea
{
 public partial class Dashboard : Security.CoordinatorPage
 {
  protected CoordinatorDashboardData Summary;protected WorkspaceCoordinatorData Workspace;protected string LoadError;
  protected void Page_Load(object sender,EventArgs e)
  {
   try {Workspace=new WorkspaceDashboardRepository().LoadCoordinator();Summary=Workspace.Summary;Journey.Model=Workspace.Journey;Charts.Model=WorkspaceChartFactory.Coordinator(Workspace);}
   catch(Exception ex){System.Diagnostics.Trace.TraceError("Coordinator workspace: "+ex.Message);LoadError="We could not load the programme work queues. Refresh to try again.";}
  }
 }
}
