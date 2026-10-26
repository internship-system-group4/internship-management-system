using System;
using System.Collections.Generic;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.CompanyArea
{
    public partial class TraineeDetails : InternshipManagementSystem.Security.CompanyPage
    {
        private readonly PlacementRepository _placementRepo = new PlacementRepository();
        private readonly UserRepository _userRepo = new UserRepository();
        private readonly TaskRepository _taskRepo = new TaskRepository();

        protected string CvDocumentUrl
        {
            get { return ViewState["CvDocumentUrl"] as string ?? ""; }
            private set { ViewState["CvDocumentUrl"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack == false)
            {
                if (CurrentSupervisor == null || string.IsNullOrWhiteSpace(CurrentSupervisor.CompanyId))
                {
                    Response.Redirect("~/Login.aspx");
                    return;
                }

                LoadTraineeData();
            }
        }

        private void LoadTraineeData()
        {
            string placementId = Request.QueryString["id"];

            if (string.IsNullOrEmpty(placementId))
            {
                ShowError(L.T("Company.TraineeDetails.InvalidTraineeID"));
                return;
            }

            try
            {
                Placement placement = _placementRepo.GetById(placementId);

                if (placement == null)
                {
                    ShowError(L.T("Company.TraineeDetails.TraineeRecordNotFound"));
                    return;
                }

                if (placement.CompanyId != CurrentSupervisor.CompanyId)
                {
                    ShowError(L.T("Company.TraineeDetails.AccessDeniedThisTraineeBelongsTo"));
                    return;
                }

                Student student = _userRepo.GetStudent(placement.StudentId);

                if (student != null)
                {
                    litStudentName.Text = student.FullName;
                    litStudentMajor.Text = student.Major;
                    litStudentEmail.Text = student.Email;
                    litStudentInitials.Text = GetInitials(student.FullName);

                    // Render one server-owned document state. CSS and startup scripts
                    // must not decide whether an unavailable document can be opened.
                    CvDocumentUrl = Services.StudentDocumentService.IsExternalLink(student.CvUrl)
                        ? student.CvUrl
                        : Services.StudentDocumentService.IsExternalLink(student.PortfolioUrl)
                            ? student.PortfolioUrl : "";
                }

                litOpportunityTitle.Text = placement.OpportunityTitle;
                litStartDate.Text = FormatDate(placement.StartDate);
                litEndDate.Text = FormatDate(placement.EndDate);
                litPlacementStatus.Text = L.Value("PlacementStatus", placement.Status);

                if (!string.IsNullOrEmpty(placement.AcademicSupervisorId))
                {
                    var academicSup = _userRepo.GetAcademicSupervisor(placement.AcademicSupervisorId);
                    if (academicSup != null) litAcademicSupervisor.Text = academicSup.FullName;
                }

                litRequiredHours.Text = placement.RequiredHours.ToString();
                litApprovedHours.Text = placement.ApprovedHours.ToString();

                int progress = 0;
                if (placement.RequiredHours > 0)
                {
                    progress = (int)Math.Round((double)placement.ApprovedHours / placement.RequiredHours * 100);
                    if (progress > 100) progress = 100;
                }

                litProgressPercentage.Text = progress.ToString();
                divProgressBar.Style["width"] = progress + "%";

                List<InternshipTask> allTasks = _taskRepo.GetAll();
                List<InternshipTask> traineeTasks = new List<InternshipTask>();

                if (allTasks != null)
                {
                    foreach (InternshipTask t in allTasks)
                    {
                        if (t.PlacementId == placement.Id)
                        {
                            traineeTasks.Add(t);
                        }
                    }
                }

                traineeTasks.Sort((a, b) => b.CreatedAt.CompareTo(a.CreatedAt));

                gvTraineeTasks.DataSource = traineeTasks;
                gvTraineeTasks.DataBind();
            }
            catch (Exception ex)
            {
                ShowError(L.F("Company.TraineeDetails.ErrorLoadingDetails", ex.Message));
            }
        }

        private void ShowError(string msg)
        {
            lblMessage.Text = msg;
            lblMessage.CssClass = "alert alert-danger d-block";
        }

        protected string FormatDate(object timestampObj)
        {
            if (timestampObj == null) return "N/A";
            long ms = Convert.ToInt64(timestampObj);
            if (ms <= 0) return "N/A";

            return Time.FromUnixMs(ms).ToString("d MMM yyyy");
        }

        protected string GetTaskStatusCss(string status)
        {
            if (status == "Assigned") return "badge status-assigned px-3 py-2 rounded-pill fw-bold";
            if (status == "Submitted") return "badge status-submitted px-3 py-2 rounded-pill fw-bold";
            if (status == "Graded") return "badge status-graded px-3 py-2 rounded-pill fw-bold";
            if (status == "RevisionRequested") return "badge status-revision px-3 py-2 rounded-pill fw-bold";

            return "badge bg-secondary bg-opacity-10 text-secondary px-3 py-2 rounded-pill fw-bold";
        }

        protected string GetInitials(string fullName)
        {
            if (string.IsNullOrWhiteSpace(fullName)) return "ST";
            var parts = fullName.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 1) return parts[0].Substring(0, 1).ToUpper();
            return (parts[0].Substring(0, 1) + parts[parts.Length - 1].Substring(0, 1)).ToUpper();
        }
    }
}