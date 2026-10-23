using System;
using InternshipManagementSystem.Common;
using System.Linq;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Security;
namespace InternshipManagementSystem.Pages.CompanyArea
{
 public partial class Dashboard : CompanyPage
 {
  protected WorkspaceCompanyData Workspace;
  protected void Page_Load(object sender, EventArgs e)
  {
   litTotalOpportunities.Text=litTotalApplications.Text=litTotalTrainees.Text=litPendingApps.Text=litActiveTrainees.Text="—";
   try {
    if(string.IsNullOrWhiteSpace(CurrentSupervisor.CompanyId))throw new InvalidOperationException("Company assignment is missing.");
    Workspace=new WorkspaceDashboardRepository().LoadCompany(CurrentSupervisor.CompanyId);Journey.Model=Workspace.Journey;Charts.Model=WorkspaceChartFactory.Company(Workspace);
    litTotalOpportunities.Text=Workspace.Opportunities.ToString();litTotalApplications.Text=Workspace.Applications.Count.ToString();litTotalTrainees.Text=Workspace.Trainees.Count.ToString();litPendingApps.Text=Workspace.PendingApplications.ToString();litActiveTrainees.Text=Workspace.Trainees.Count.ToString();
    gvRecentApplications.DataSource=Workspace.Applications.OrderBy(a=>a.Status==InternshipManagementSystem.Common.ApplicationStatus.Pending?0:1).ThenByDescending(a=>a.SubmittedAt).Take(5).Select(a=>new RecentAppViewModel { StudentName=a.StudentName,Major=a.StudentMajor,OpportunityTitle=a.OpportunityTitle,Status=a.Status.ToString(),SubmittedAt=a.SubmittedAt });gvRecentApplications.DataBind();lblMessage.Visible=false;
   }catch(Exception ex){System.Diagnostics.Trace.TraceError("Company workspace: "+ex.Message);lblMessage.Text=L.T("Company.Dashboard.WeCouldNotLoadYourCompany");lblMessage.CssClass="alert alert-danger d-block";lblMessage.Attributes["role"]="alert";}
  }
        protected string GetStatusCss(string status)
        {
            if (status == "Accepted") return "badge bg-success bg-opacity-10 text-success rounded-pill px-3 py-2";
            if (status == "Rejected") return "badge bg-danger bg-opacity-10 text-danger rounded-pill px-3 py-2";
            return "badge bg-primary bg-opacity-10 text-primary rounded-pill px-3 py-2";
        }

        protected string GetInitials(string fullName)
        {
            if (string.IsNullOrWhiteSpace(fullName)) return "S";
            var parts = fullName.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 1) return parts[0].Substring(0, 1).ToUpper();
            return (parts[0].Substring(0, 1) + parts[parts.Length - 1].Substring(0, 1)).ToUpper();
        }
    }

    public class RecentAppViewModel
    {
        public string StudentName { get; set; }
        public string Major { get; set; }
        public string OpportunityTitle { get; set; }
        public string Status { get; set; }
        public long SubmittedAt { get; set; }
    }
}