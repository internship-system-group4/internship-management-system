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
            // أخذ الـ ID الممرر في الرابط (وهو معرّف الـ Placement)
            string placementId = Request.QueryString["id"];

            if (string.IsNullOrEmpty(placementId))
            {
                ShowError("Invalid trainee ID.");
                return;
            }

            try
            {
                // 1. جلب بيانات التدريب (Placement)
                Placement placement = _placementRepo.GetById(placementId);

                if (placement == null)
                {
                    ShowError("Trainee record not found.");
                    return;
                }

                // 2. الحماية: التأكد أن هذا المتدرب يتبع لشركة المشرف المسجل حالياً
                if (placement.CompanyId != CurrentSupervisor.CompanyId)
                {
                    ShowError("Access denied. This trainee belongs to another company.");
                    return;
                }

                // 3. جلب بيانات الطالب من جدول المستخدمين
                Student student = _userRepo.GetStudent(placement.StudentId);

                if (student != null)
                {
                    litStudentName.Text = student.FullName;
                    litStudentMajor.Text = student.Major;
                    litStudentEmail.Text = student.Email;
                    litStudentInitials.Text = GetInitials(student.FullName);
                }

                // 4. تعبئة معلومات التدريب 
                litOpportunityTitle.Text = placement.OpportunityTitle;
                litStartDate.Text = FormatDate(placement.StartDate);
                litEndDate.Text = FormatDate(placement.EndDate);
                litPlacementStatus.Text = placement.Status.ToString();

                // جلب اسم المشرف الأكاديمي إن وُجد
                if (!string.IsNullOrEmpty(placement.AcademicSupervisorId))
                {
                    var academicSup = _userRepo.GetAcademicSupervisor(placement.AcademicSupervisorId);
                    if (academicSup != null) litAcademicSupervisor.Text = academicSup.FullName;
                }

                // حساب نسبة التقدم في الساعات
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

                // 5. جلب المهام المرتبطة بهذا المتدرب (مع تجاوز خطأ الفايربيس)
                List<InternshipTask> allTasks = _taskRepo.GetAll();
                List<InternshipTask> traineeTasks = new List<InternshipTask>();

                foreach (InternshipTask t in allTasks)
                {
                    // نأخذ فقط المهام التابعة لهذا الـ Placement
                    if (t.PlacementId == placement.Id)
                    {
                        traineeTasks.Add(t);
                    }
                }

                // ترتيب المهام من الأحدث للأقدم
                traineeTasks.Sort((a, b) => b.CreatedAt.CompareTo(a.CreatedAt));

                // ربط الجدول بالبيانات
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

        // ألوان حالات المهام مطابقة لستايل الموقع
        protected string GetTaskStatusCss(string status)
        {
            if (status == "Assigned") return "badge bg-primary bg-opacity-10 text-primary px-3 py-2 rounded-pill";
            if (status == "Submitted") return "badge bg-warning bg-opacity-10 text-warning px-3 py-2 rounded-pill";
            if (status == "Graded") return "badge bg-success bg-opacity-10 text-success px-3 py-2 rounded-pill";
            if (status == "RevisionRequested") return "badge bg-danger bg-opacity-10 text-danger px-3 py-2 rounded-pill";

            return "badge bg-secondary bg-opacity-10 text-secondary px-3 py-2 rounded-pill";
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