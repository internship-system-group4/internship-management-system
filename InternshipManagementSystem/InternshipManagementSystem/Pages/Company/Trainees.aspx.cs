using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI.WebControls;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.CompanyArea
{
    public partial class Trainees : InternshipManagementSystem.Security.CompanyPage
    {
        private readonly PlacementRepository _placementRepo = new PlacementRepository();
        private readonly UserRepository _userRepo = new UserRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (CurrentSupervisor != null && !string.IsNullOrWhiteSpace(CurrentSupervisor.CompanyId))
                {
                    LoadTraineesData();
                }
                else
                {
                    lblMessage.Text = "User session expired or Company assignment is missing.";
                    lblMessage.CssClass = "alert alert-danger d-block";
                }
            }
        }

        protected void Filter_Changed(object sender, EventArgs e)
        {
            LoadTraineesData();
        }

        private void LoadTraineesData()
        {
            if (CurrentSupervisor == null || string.IsNullOrWhiteSpace(CurrentSupervisor.CompanyId)) return;
            string companyId = CurrentSupervisor.CompanyId;

            try
            {
                var allPlacements = _placementRepo.GetAll() ?? new List<Placement>();
                var companyPlacements = allPlacements.Where(p => p.CompanyId == companyId).ToList();

                var allTraineesList = new List<TraineeViewModel>();
                int activeCount = 0, nearCompleteCount = 0, completedCount = 0;

                // Speed: read every trainee's profile at the same time before the loop.
                List<FirebaseRead> profiles = new List<FirebaseRead>();
                foreach (Placement p in companyPlacements)
                {
                    if (ApplicationRepository.IsValidKey(p.StudentId))
                        profiles.Add(FirebaseRead.Node(Constants.Paths.Users + "/" + p.StudentId));
                }
                FirebaseContext.Prefetch(profiles);

                // Live approved hours, including hours earned through accepted tasks.
                var liveHours = new HoursRepository().ApprovedTotalsByPlacement();

                foreach (Placement p in companyPlacements)
                {
                    int live;
                    if (liveHours != null && liveHours.TryGetValue(p.Id, out live)) p.ApprovedHours = live;
                    var student = _userRepo.GetStudent(p.StudentId);
                    string major = student != null && !string.IsNullOrWhiteSpace(student.Major) ? student.Major : "General";

                    int progress = 0;
                    if (p.RequiredHours > 0)
                    {
                        progress = (int)Math.Round((double)p.ApprovedHours / p.RequiredHours * 100);
                        if (progress > 100) progress = 100;
                    }

                    if (progress == 100) completedCount++;
                    else if (progress >= 80) { nearCompleteCount++; activeCount++; }
                    else activeCount++;

                    allTraineesList.Add(new TraineeViewModel
                    {
                        Id = p.Id,
                        StudentName = p.StudentName ?? "Unknown Student",
                        StudentMajor = major,
                        OpportunityTitle = p.OpportunityTitle ?? "N/A",
                        StartDate = p.StartDate,
                        EndDate = p.EndDate,
                        ProgressPercentage = progress
                    });
                }

                // تحديث البطاقات الإحصائية (تمت إزالة litTotalCount لتطابق الواجهة الجديدة)
                litActiveTrainees.Text = activeCount.ToString();
                litNearCompletion.Text = nearCompleteCount.ToString();
                litCompleted.Text = completedCount.ToString();

                string searchText = txtSearch.Text.ToLower().Trim();
                string selectedDept = ddlDepartment.SelectedValue;
                string selectedStatus = ddlStatus.SelectedValue;

                var filteredList = allTraineesList.Where(t =>
                    (string.IsNullOrEmpty(searchText) || t.StudentName.ToLower().Contains(searchText)) &&
                    (selectedDept == "All" || t.StudentMajor == selectedDept) &&
                    (selectedStatus == "All" ||
                    (selectedStatus == "Completed" && t.ProgressPercentage == 100) ||
                    (selectedStatus == "NearFinish" && t.ProgressPercentage >= 80 && t.ProgressPercentage < 100) ||
                    (selectedStatus == "InProgress" && t.ProgressPercentage < 80))
                ).ToList();

                gvTrainees.DataSource = filteredList;
                gvTrainees.DataBind();
                lblMessage.Visible = false;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Trainees error: " + ex.Message);
                lblMessage.Text = L.F("Company.Trainees.ErrorLoadingTrainees", ex.Message);
                lblMessage.CssClass = "alert alert-danger d-block mt-3";
                lblMessage.Visible = true;
            }
        }

        protected string FormatDate(object timestampObj)
        {
            if (timestampObj == null) return "N/A";

            long ms = Convert.ToInt64(timestampObj);
            if (ms <= 0) return "N/A";

            return Time.FromUnixMs(ms).ToString("d MMM yyyy");
        }

        protected string GetStatusText(string progressStr)
        {
            if (!int.TryParse(progressStr, out int progress)) return "Unknown";

            if (progress == 100) return "Completed";
            if (progress >= 80) return L.T("Company.Trainees.NearFinish");
            return L.T("Company.Trainees.InProgress");
        }

        protected string GetStatusCss(string progressStr)
        {
            if (!int.TryParse(progressStr, out int progress)) return "badge bg-secondary bg-opacity-10 text-secondary rounded-pill px-3 py-2";

            if (progress == 100) return "badge bg-success bg-opacity-10 text-success rounded-pill px-3 py-2";
            if (progress >= 80) return "badge bg-warning bg-opacity-10 text-warning rounded-pill px-3 py-2";
            return "badge bg-primary bg-opacity-10 text-primary rounded-pill px-3 py-2";
        }

        protected string GetInitials(string fullName)
        {
            if (string.IsNullOrWhiteSpace(fullName)) return "ST";
            var parts = fullName.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 1) return parts[0].Substring(0, 1).ToUpper();
            return (parts[0].Substring(0, 1) + parts[parts.Length - 1].Substring(0, 1)).ToUpper();
        }
    }

    public class TraineeViewModel
    {
        public string Id { get; set; }
        public string StudentName { get; set; }
        public string StudentMajor { get; set; }
        public string OpportunityTitle { get; set; }
        public long StartDate { get; set; }
        public long EndDate { get; set; }
        public int ProgressPercentage { get; set; }
    }
}