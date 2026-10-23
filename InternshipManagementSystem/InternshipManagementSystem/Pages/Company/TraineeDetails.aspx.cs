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

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack == false)
            {
                LoadTraineeData();
            }
        }

        private void LoadTraineeData()
        {
            string placementId = Request.QueryString["id"];

            if (string.IsNullOrEmpty(placementId))
            {
                ShowError("Invalid trainee ID.");
                return;
            }

            try
            {
                Placement placement = _placementRepo.GetById(placementId);

                if (placement == null)
                {
                    ShowError("Trainee record not found.");
                    return;
                }

                if (placement.CompanyId != CurrentSupervisor.CompanyId)
                {
                    ShowError("Access denied. This trainee belongs to another company.");
                    return;
                }

                Student student = _userRepo.GetStudent(placement.StudentId);

                if (student != null)
                {
                    litStudentName.Text = student.FullName;
                    litStudentMajor.Text = student.Major;
                    litStudentEmail.Text = student.Email;
                    litStudentInitials.Text = GetInitials(student.FullName);

                    // فحص رابط السيرة الذاتية أو البورتفوليو
                    string cvLink = "";
                    try
                    {
                        cvLink = !string.IsNullOrEmpty(student.CvUrl) ? student.CvUrl :
                                (!string.IsNullOrEmpty(student.PortfolioUrl) ? student.PortfolioUrl : "");
                    }
                    catch { }

                    if (!string.IsNullOrEmpty(cvLink))
                    {
                        string safeLink = cvLink.Replace("'", "\\'");
                        string script = $"document.getElementById('btnOpenRealCv').href = '{safeLink}'; document.getElementById('btnOpenRealCv').style.display = 'inline-block'; document.getElementById('divNoCv').style.display = 'none';";
                        ClientScript.RegisterStartupScript(this.GetType(), "SetCvLink", script, true);
                    }
                    else
                    {
                        string script = "document.getElementById('btnOpenRealCv').style.display = 'none'; document.getElementById('divNoCv').style.display = 'block';";
                        ClientScript.RegisterStartupScript(this.GetType(), "HideCvLink", script, true);
                    }
                }

                litOpportunityTitle.Text = placement.OpportunityTitle;
                litStartDate.Text = FormatDate(placement.StartDate);
                litEndDate.Text = FormatDate(placement.EndDate);
                litPlacementStatus.Text = placement.Status.ToString();

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

                foreach (InternshipTask t in allTasks)
                {
                    if (t.PlacementId == placement.Id)
                    {
                        traineeTasks.Add(t);
                    }
                }

                traineeTasks.Sort((a, b) => b.CreatedAt.CompareTo(a.CreatedAt));

                gvTraineeTasks.DataSource = traineeTasks;
                gvTraineeTasks.DataBind();
            }
            catch (Exception ex)
            {
                ShowError("Error loading details: " + ex.Message);
            }
        }

        private void ShowError(string msg)
        {
            lblMessage.Text = msg;
            lblMessage.CssClass = "alert alert-danger d-block";
        }

        protected string FormatDate(object timestampObj)
        {
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