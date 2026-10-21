using System;
using System.Collections.Generic;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.CompanyArea
{
    public partial class Dashboard : InternshipManagementSystem.Security.CompanyPage
    {
        private readonly OpportunityRepository _opportunityRepo = new OpportunityRepository();
        private readonly ApplicationRepository _applicationRepo = new ApplicationRepository();
        private readonly PlacementRepository _placementRepo = new PlacementRepository();
        private readonly UserRepository _userRepo = new UserRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (CurrentSupervisor != null)
                {
                    LoadCompanyDashboardData();
                }
            }
        }

        private void LoadCompanyDashboardData()
        {
            string companyId = CurrentSupervisor.CompanyId;
            if (string.IsNullOrEmpty(companyId)) return;

            try
            {
                // 1. حساب إحصائيات الفرص (تجاوز خطأ الفايربيس)
                List<Opportunity> allOpportunities = _opportunityRepo.GetAll();
                List<Opportunity> companyOpportunities = new List<Opportunity>();
                List<string> oppIds = new List<string>();

                foreach (Opportunity opp in allOpportunities)
                {
                    if (opp.CompanyId == companyId)
                    {
                        companyOpportunities.Add(opp);
                        if (!string.IsNullOrEmpty(opp.Id)) oppIds.Add(opp.Id);
                    }
                }
                litTotalOpportunities.Text = companyOpportunities.Count.ToString();

                // 2. حساب إحصائيات الطلبات
                List<InternshipApplication> allApps = _applicationRepo.GetAll();
                int totalApps = 0;
                int pendingAppsCount = 0;
                var recentAppsList = new List<RecentAppViewModel>();

                foreach (InternshipApplication app in allApps)
                {
                    if (app.CompanyId == companyId)
                    {
                        totalApps++;
                        if (app.Status.ToString() == "Pending")
                        {
                            pendingAppsCount++;
                        }

                        var student = _userRepo.GetStudent(app.StudentId);
                        string studentName = student != null ? student.FullName : "Student";
                        string oppTitle = companyOpportunities.Find(o => o.Id == app.OpportunityId)?.Title ?? "Opportunity";

                        recentAppsList.Add(new RecentAppViewModel
                        {
                            StudentName = studentName,
                            Major = app.StudentMajor,
                            OpportunityTitle = oppTitle,
                            Status = app.Status.ToString(),
                            SubmittedAt = app.SubmittedAt
                        });
                    }
                }

                // 3. حساب إحصائيات المتدربين المقبولين
                List<Placement> allPlacements = _placementRepo.GetAll();
                int totalTrainees = 0;

                foreach (Placement p in allPlacements)
                {
                    if (p.CompanyId == companyId)
                    {
                        totalTrainees++;
                    }
                }

                // تعبئة الأرقام في البطاقات
                litTotalApplications.Text = totalApps.ToString();
                litTotalTrainees.Text = totalTrainees.ToString();
                litPendingApps.Text = pendingAppsCount.ToString();
                litActiveTrainees.Text = totalTrainees.ToString();

                // 4. ترتيب أحدث 5 طلبات
                recentAppsList.Sort((a, b) => b.SubmittedAt.CompareTo(a.SubmittedAt));

                List<RecentAppViewModel> top5Apps = new List<RecentAppViewModel>();
                for (int i = 0; i < recentAppsList.Count; i++)
                {
                    if (i < 5) top5Apps.Add(recentAppsList[i]);
                }

                gvRecentApplications.DataSource = top5Apps;
                gvRecentApplications.DataBind();
            }
            catch (Exception ex)
            {
                lblMessage.Text = "Error: " + ex.Message;
                lblMessage.CssClass = "alert alert-danger d-block";
            }
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