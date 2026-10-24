using System;
using System.Linq;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.CompanyArea
{
    public partial class Dashboard : CompanyPage
    {
        protected WorkspaceCompanyData Workspace;

        protected void Page_Load(object sender, EventArgs e)
        {
            litTotalOpportunities.Text = litTotalApplications.Text = litTotalTrainees.Text = litPendingApps.Text = litActiveTrainees.Text = "—";

            try
            {
                if (string.IsNullOrWhiteSpace(CurrentSupervisor.CompanyId))
                    throw new InvalidOperationException("Company assignment is missing.");

                Workspace = new WorkspaceDashboardRepository().LoadCompany(CurrentSupervisor.CompanyId);

                if (Workspace != null)
                {
                    litTotalOpportunities.Text = Workspace.Opportunities.ToString();
                    litTotalApplications.Text = (Workspace.Applications?.Count ?? 0).ToString();
                    litTotalTrainees.Text = (Workspace.Trainees?.Count ?? 0).ToString();
                    litPendingApps.Text = Workspace.PendingApplications.ToString();
                    litActiveTrainees.Text = (Workspace.Trainees?.Count ?? 0).ToString();

                    if (Workspace.Applications != null)
                    {
                        var recentApps = Workspace.Applications
                            .OrderBy(a => a.Status == InternshipManagementSystem.Common.ApplicationStatus.Pending ? 0 : 1)
                            .ThenByDescending(a => a.SubmittedAt)
                            .Take(3)
                            .Select(a => new RecentAppViewModel
                            {
                                StudentName = a.StudentName ?? L.T("Company.Dashboard.Unknown"),
                                Major = a.StudentMajor ?? "N/A",
                                OpportunityTitle = a.OpportunityTitle ?? "N/A",
                                Status = a.Status.ToString(),
                                SubmittedAt = a.SubmittedAt
                            }).ToList();

                        gvRecentApplications.DataSource = recentApps;
                        gvRecentApplications.DataBind();
                    }
                }

                lblMessage.Visible = false;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Company workspace error: " + ex.Message);
                lblMessage.Text = L.T("Company.Dashboard.WeCouldNotLoadYourCompany");
                lblMessage.CssClass = "alert alert-danger d-block mt-3";
                lblMessage.Attributes["role"] = "alert";
            }
        }

        protected string GetStatusCss(string status)
        {
            if (string.IsNullOrEmpty(status)) return "badge bg-secondary bg-opacity-10 text-secondary rounded-pill px-3 py-2";
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