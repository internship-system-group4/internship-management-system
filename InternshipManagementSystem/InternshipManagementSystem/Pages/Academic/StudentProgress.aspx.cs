using System;
using System.Collections.Generic;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;
using InternshipManagementSystem.Data;
using System.Linq;

namespace InternshipManagementSystem.Pages.Academic
{
    // Secure the page by inheriting from AcademicPage
    public partial class StudentProgress : AcademicPage
    {
        // Store the current student ID from the URL
        private string CurrentStudentId
        {
            get { return Request.QueryString["id"]; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(CurrentStudentId))
            {
                // If no ID is provided, send them back to the dashboard
                Response.Redirect("Dashboard.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadStudentAndPlacementData();
                LoadTasks();
                LoadComments();
            }
        }

        private void LoadStudentAndPlacementData()
        {
            // 1. Fetch Student
            UserRepository userRepo = new UserRepository();
            Student student = userRepo.GetStudent(CurrentStudentId);

            // Security check: Ensure the student actually belongs to this supervisor
            if (student == null || student.AcademicSupervisorId != CurrentSupervisor.Id)
            {
                Response.Redirect("Dashboard.aspx");
                return;
            }

            // Populate student header
            litStudentName.Text = student.FullName;
            litStudentId.Text = student.StudentNumber;
            litMajor.Text = student.Major;

            // 2. Fetch Placement (Internship details)
            // The placement ID is identical to the student ID based on the repository rules.
            PlacementRepository placementRepo = new PlacementRepository();
            Placement placement = placementRepo.GetById(student.Id);

            if (placement != null)
            {
                litApprovedHours.Text = placement.ApprovedHours.ToString();
                litRequiredHours.Text = placement.RequiredHours.ToString();
                litCompanyName.Text = placement.CompanyName;
                litCompanySupervisor.Text = placement.CompanySupervisorName;
                litOpportunityTitle.Text = placement.OpportunityTitle;
                litPlacementStatus.Text = placement.Status.ToString();
            }
            else
            {
                litCompanyName.Text = "Not assigned yet";
                litPlacementStatus.Text = "Pending";
            }
        }

        private void LoadTasks()
        {
            TaskRepository taskRepo = new TaskRepository();
            // Fetch all tasks for this specific placement
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
                // Sort comments to show the newest first
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

            // Create and populate the new comment object
            AcademicComment newComment = new AcademicComment
            {
                PlacementId = CurrentStudentId,
                StudentId = CurrentStudentId,
                AcademicSupervisorId = CurrentSupervisor.Id,
                Comment = txtNewComment.Text.Trim(),
                IsVisibleToStudent = chkVisibleToStudent.Checked
            };

            // Save to Firebase
            AcademicCommentRepository commentRepo = new AcademicCommentRepository();
            commentRepo.Insert(newComment);

            // Reset form and show success message
            txtNewComment.Text = string.Empty;
            chkVisibleToStudent.Checked = false;
            lblCommentStatus.Text = "Comment saved successfully!";
            lblCommentStatus.Visible = true;

            // Refresh the comments list
            LoadComments();
        }

        protected void btnFinalEvaluation_Click(object sender, EventArgs e)
        {
            // Redirect to the Final Evaluation page, passing the student ID
            Response.Redirect("FinalEvaluation.aspx?id=" + CurrentStudentId);
        }
    }
}
