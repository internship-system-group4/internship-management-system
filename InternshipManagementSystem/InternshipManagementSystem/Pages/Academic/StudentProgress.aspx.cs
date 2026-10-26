using System;
using InternshipManagementSystem.Common;
using System.Collections.Generic;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;
using InternshipManagementSystem.Data;
using System.Linq;
using System.Web.UI.WebControls;
using InternshipManagementSystem.Services;

namespace InternshipManagementSystem.Pages.Academic
{
    public partial class StudentProgress : AcademicPage
    {
        protected int ApprovedHours, RequiredHours, PendingHours, HoursPercent;
        public class PendingHourRow
        {
            public string Id { get; set; }
            public int Hours { get; set; }
            public string Date { get; set; }
            public string Description { get; set; }
        }

        private string CurrentStudentId
        {
            get { return Request.QueryString["id"]; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(CurrentStudentId))
            {
                // Sidebar clicked: Show the students list table
                pnlStudentList.Visible = true;
                pnlProgressDetails.Visible = false;

                if (!IsPostBack)
                {
                    LoadStudentsTable();
                }
            }
            else
            {
                // Student Selected: Show their progress details
                pnlStudentList.Visible = false;
                pnlProgressDetails.Visible = true;

                if (!IsPostBack)
                {
                    LoadStudentAndPlacementData();
                    LoadHours();
                    LoadTasks();
                    LoadComments();
                }
            }
        }

        // دالة تحميل الطلاب مع الفلترة حسب الخيار المحدد بالـ Dropdown ونص البحث
        private void LoadStudentsTable()
        {
            UserRepository userRepo = new UserRepository();
            List<Student> myStudents = userRepo.GetStudentsBySupervisor(CurrentSupervisor.Id);

            if (myStudents != null && myStudents.Count > 0)
            {
                // تطبيق الفلتر حسب التخصص
                string selectedFilter = ddlMajorFilter.SelectedValue;
                if (selectedFilter != "All")
                {
                    myStudents = myStudents.Where(s => s.Major == selectedFilter).ToList();
                }

                // تطبيق البحث بالاسم أو الرقم الجامعي
                string searchQuery = txtSearch.Text.Trim().ToLower();
                if (!string.IsNullOrEmpty(searchQuery))
                {
                    myStudents = myStudents.Where(s =>
                        s.FullName.ToLower().Contains(searchQuery) ||
                        s.StudentNumber.ToLower().Contains(searchQuery)
                    ).ToList();
                }

                rptStudentsList.DataSource = myStudents;
                rptStudentsList.DataBind();
                litNoStudents.Visible = myStudents.Count == 0;
            }
            else
            {
                litNoStudents.Visible = true;
            }
        }

        // حدث التغيير عند اختيار الفلتر
        protected void ddlMajorFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadStudentsTable();
        }

        // حدث الضغط على زر البحث
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadStudentsTable();
        }

        private void LoadStudentAndPlacementData()
        {
            UserRepository userRepo = new UserRepository();
            Student student = userRepo.GetStudent(CurrentStudentId);

            if (student == null || student.AcademicSupervisorId != CurrentSupervisor.Id)
            {
                Response.Redirect("StudentProgress.aspx");
                return;
            }

            litStudentName.Text = student.FullName;
            litStudentId.Text = student.StudentNumber;
            litMajor.Text = student.Major;

            PlacementRepository placementRepo = new PlacementRepository();
            Placement placement = placementRepo.GetById(student.Id);

            if (placement != null)
            {
                RequiredHours = placement.RequiredHours > 0 ? placement.RequiredHours : student.RequiredHours;
                litRequiredHours.Text = RequiredHours.ToString();
                litCompanyName.Text = placement.CompanyName;
                litCompanySupervisor.Text = placement.CompanySupervisorName;
                litOpportunityTitle.Text = placement.OpportunityTitle;
                litPlacementStatus.Text = L.Value("PlacementStatus", placement.Status);
            }
            else
            {
                litCompanyName.Text = L.T("Academic.StudentProgress.NotAssignedYet");
                litPlacementStatus.Text = L.T("Academic.StudentProgress.Pending");
            }
        }

        private void LoadHours()
        {
            Placement placement = new PlacementRepository().GetById(CurrentStudentId);
            if (placement == null || placement.StudentId != CurrentStudentId ||
                placement.AcademicSupervisorId != CurrentSupervisor.Id)
            {
                rptPendingHours.DataSource = new List<PendingHourRow>();
                rptPendingHours.DataBind();
                phNoPendingHours.Visible = true;
                return;
            }
            var entries = new HoursRepository().GetByPlacement(placement.Id)
                .Where(h => h != null && h.StudentId == CurrentStudentId && h.Hours > 0).ToList();
            ApprovedHours = entries.Where(h => h.Status == HoursStatus.Approved).Sum(h => h.Hours);
            PendingHours = entries.Where(h => h.Status == HoursStatus.Reported).Sum(h => h.Hours);
            HoursPercent = RequiredHours > 0 ? (int)Math.Min(100, ApprovedHours * 100.0 / RequiredHours) : 0;
            litApprovedHours.Text = ApprovedHours.ToString();
            var pending = entries.Where(h => h.Status == HoursStatus.Reported)
                .OrderBy(h => h.WorkDate).Select(h => new PendingHourRow
                {
                    Id = h.Id,
                    Hours = h.Hours,
                    Date = Time.DisplayDate(h.WorkDate),
                    Description = h.Description ?? ""
                }).ToList();
            rptPendingHours.DataSource = pending;
            rptPendingHours.DataBind();
            phNoPendingHours.Visible = pending.Count == 0;
        }

        protected void rptPendingHours_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "ApproveHours" && e.CommandName != "RejectHours") return;
            try
            {
                string entryId = Convert.ToString(e.CommandArgument);
                Placement placement = new PlacementRepository().GetById(CurrentStudentId);
                TrainingHoursEntry entry = new HoursRepository().GetById(entryId);
                if (placement == null || placement.StudentId != CurrentStudentId ||
                    placement.AcademicSupervisorId != CurrentSupervisor.Id ||
                    entry == null || entry.PlacementId != placement.Id ||
                    entry.StudentId != CurrentStudentId || entry.Status != HoursStatus.Reported)
                    throw new InvalidOperationException();
                TextBox noteBox = e.Item.FindControl("txtHoursReviewNote") as TextBox;
                string note = noteBox == null ? "" : (noteBox.Text ?? "").Trim();
                if (note.Length > 500 || (e.CommandName == "RejectHours" && note.Length == 0))
                {
                    lblHoursReviewMessage.Text = L.T("Academic.StudentProgress.RejectNeedsNote");
                    lblHoursReviewMessage.Visible = true;
                    return;
                }
                HoursService.Decide(entryId, e.CommandName == "ApproveHours", CurrentSupervisor.Id, note);
                lblHoursReviewMessage.Text = L.T("Academic.StudentProgress.HoursDecisionSaved");
                lblHoursReviewMessage.Visible = true;
                LoadStudentAndPlacementData();
                LoadHours();
            }
            catch (Exception ex) when (ex is FirebaseException || ex is InvalidOperationException || ex is UnauthorizedAccessException)
            {
                System.Diagnostics.Trace.TraceError("Hours review failed: " + ex);
                lblHoursReviewMessage.Text = L.T("Academic.StudentProgress.HoursDecisionFailed");
                lblHoursReviewMessage.Visible = true;
            }
        }

        private void LoadTasks()
        {
            TaskRepository taskRepo = new TaskRepository();
            List<InternshipTask> tasks = taskRepo.GetWhere("PlacementId", CurrentStudentId).Cast<InternshipTask>().ToList();

            if (tasks != null && tasks.Count > 0)
            {
                rptTasks.DataSource = tasks;
                rptTasks.DataBind();
            }
            else
            {
                litNoTasks.Visible = true;
            }
        }

        private void LoadComments()
        {
            AcademicCommentRepository commentRepo = new AcademicCommentRepository();
            List<AcademicComment> comments = commentRepo.GetByPlacement(CurrentStudentId);

            if (comments != null && comments.Count > 0)
            {
                rptComments.DataSource = comments.OrderByDescending(c => c.CreatedAt).ToList();
                rptComments.DataBind();
                litNoComments.Visible = false;
            }
            else
            {
                litNoComments.Visible = true;
            }
        }

        protected void btnSaveComment_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtNewComment.Text)) return;

            AcademicComment newComment = new AcademicComment
            {
                PlacementId = CurrentStudentId,
                StudentId = CurrentStudentId,
                AcademicSupervisorId = CurrentSupervisor.Id,
                Comment = txtNewComment.Text.Trim(),
                IsVisibleToStudent = chkVisibleToStudent.Checked
            };

            AcademicCommentRepository commentRepo = new AcademicCommentRepository();
            commentRepo.Insert(newComment);

            txtNewComment.Text = string.Empty;
            chkVisibleToStudent.Checked = false;
            lblCommentStatus.Text = L.T("Academic.StudentProgress.CommentSavedSuccessfully");
            lblCommentStatus.Visible = true;

            LoadComments();
        }

        protected void btnFinalEvaluation_Click(object sender, EventArgs e)
        {
            Response.Redirect("FinalEvaluation.aspx?id=" + CurrentStudentId);
        }
    }
}