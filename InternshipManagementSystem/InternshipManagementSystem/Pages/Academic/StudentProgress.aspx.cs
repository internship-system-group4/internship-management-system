using System;
using System.Collections.Generic;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;
using InternshipManagementSystem.Data;
using System.Linq;

namespace InternshipManagementSystem.Pages.Academic
{
    public partial class StudentProgress : AcademicPage
    {
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
                    LoadTasks();
                    LoadComments();
                }
            }
        }

        private void LoadStudentsTable()
        {
            UserRepository userRepo = new UserRepository();
            List<Student> myStudents = userRepo.GetStudentsBySupervisor(CurrentSupervisor.Id);

            if (myStudents != null && myStudents.Count > 0)
            {
                rptStudentsList.DataSource = myStudents;
                rptStudentsList.DataBind();
                litNoStudents.Visible = false;
            }
            else
            {
                litNoStudents.Visible = true;
            }
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
            lblCommentStatus.Text = "Comment saved successfully!";
            lblCommentStatus.Visible = true;

            LoadComments();
        }

        protected void btnFinalEvaluation_Click(object sender, EventArgs e)
        {
            Response.Redirect("FinalEvaluation.aspx?id=" + CurrentStudentId);
        }
    }
}