using System;
using System.Collections.Generic;
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
                if (CurrentSupervisor != null)
                {
                    LoadTraineesData();
                }
            }
        }

        protected void Filter_Changed(object sender, EventArgs e)
        {
            LoadTraineesData();
        }

        private void LoadTraineesData()
        {
            string companyId = CurrentSupervisor.CompanyId;
            if (string.IsNullOrEmpty(companyId)) return;

            try
            {
                List<Placement> allPlacements = _placementRepo.GetAll();
                List<Placement> companyPlacements = new List<Placement>();

                foreach (Placement p in allPlacements)
                {
                    if (p.CompanyId == companyId)
                    {
                        companyPlacements.Add(p);
                    }
                }

                int activeCount = 0;
                int nearCompleteCount = 0;
                int completedCount = 0;

                List<TraineeViewModel> allTraineesList = new List<TraineeViewModel>();

                // Speed: read every trainee's profile at the same time before the loop.
                List<FirebaseRead> profiles = new List<FirebaseRead>();
                foreach (Placement p in companyPlacements)
                {
                    if (ApplicationRepository.IsValidKey(p.StudentId))
                        profiles.Add(FirebaseRead.Node(Constants.Paths.Users + "/" + p.StudentId));
                }
                FirebaseContext.Prefetch(profiles);

                foreach (Placement p in companyPlacements)
                {
                    var student = _userRepo.GetStudent(p.StudentId);
                    string major = student != null ? student.Major : "General";

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
                        StudentName = p.StudentName,
                        StudentMajor = major,
                        OpportunityTitle = p.OpportunityTitle,
                        StartDate = p.StartDate,
                        EndDate = p.EndDate,
                        ProgressPercentage = progress
                    });
                }

                litTotalCount.Text = companyPlacements.Count.ToString();
                litActiveTrainees.Text = activeCount.ToString();
                litNearCompletion.Text = nearCompleteCount.ToString();
                litCompleted.Text = completedCount.ToString();

                string searchText = txtSearch.Text.ToLower().Trim();
                string selectedDept = ddlDepartment.SelectedValue;
                string selectedStatus = ddlStatus.SelectedValue;

                List<TraineeViewModel> filteredList = new List<TraineeViewModel>();

                foreach (TraineeViewModel t in allTraineesList)
                {
                    bool nameMatches = true;
                    if (searchText != "")
                    {
                        if (t.StudentName.ToLower().Contains(searchText) == false) nameMatches = false;
                    }

                    bool deptMatches = true;
                    if (selectedDept != "All")
                    {
                        if (t.StudentMajor != selectedDept) deptMatches = false;
                    }

                    bool statusMatches = true;
                    if (selectedStatus == "Completed" && t.ProgressPercentage != 100) statusMatches = false;
                    if (selectedStatus == "NearFinish" && (t.ProgressPercentage < 80 || t.ProgressPercentage == 100)) statusMatches = false;
                    if (selectedStatus == "InProgress" && t.ProgressPercentage >= 80) statusMatches = false;

                    if (nameMatches && deptMatches && statusMatches)
                    {
                        filteredList.Add(t);
                    }
                }

                gvTrainees.DataSource = filteredList;
                gvTrainees.DataBind();
            }
            catch (Exception ex)
            {
                lblMessage.Text = L.F("Company.Trainees.ErrorLoadingTrainees", ex.Message);
                lblMessage.CssClass = "alert alert-danger d-block";
            }
        }

        protected string FormatDate(object timestampObj)
        {
            long ms = Convert.ToInt64(timestampObj);
            if (ms <= 0) return "N/A";

            return Time.FromUnixMs(ms).ToString("d MMM yyyy");
        }

        protected string GetStatusText(string progressStr)
        {
            int progress = Convert.ToInt32(progressStr);
            if (progress == 100) return "Completed";
            if (progress >= 80) return L.T("Company.Trainees.NearFinish");
            return L.T("Company.Trainees.InProgress");
        }

        protected string GetStatusCss(string progressStr)
        {
            int progress = Convert.ToInt32(progressStr);
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