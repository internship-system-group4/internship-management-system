using System;
using System.Linq;
using System.Text.RegularExpressions;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.CoordinatorArea
{
    /// <summary>One student's profile for the coordinator: personal, academic,
    /// supervision and placement details (Students.aspx?id=...).</summary>
    public partial class Students : CoordinatorPage
    {
        protected StudentDirectoryRow Row;
        protected Placement Placement;
        protected string LoadError;
        protected bool HasPlacement { get { return Placement != null; } }

        protected void Page_Load(object sender, EventArgs e)
        {
            string id = Request.QueryString["id"];
            // Old links (?create=student) and links without a student go to the student list.
            if (string.IsNullOrEmpty(id) || !Regex.IsMatch(id, @"\A[A-Za-z0-9_-]{1,128}\z"))
            {
                string create = Request.QueryString["create"] == "student" ? "?create=student" : "";
                Response.Redirect(ResolveUrl("~/Pages/Coordinator/ManageStudents.aspx" + create), false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            try
            {
                UserRepository users = new UserRepository();
                Student student = users.GetStudent(id);
                if (student == null)
                {
                    LoadError = L.T("Coordinator.Students.StudentRecordNotFound");
                    return;
                }
                StudentGroup group = string.IsNullOrEmpty(student.GroupId) ? null : new GroupRepository().GetById(student.GroupId);
                AcademicSupervisor supervisor = string.IsNullOrEmpty(student.AcademicSupervisorId) ? null : users.GetAcademicSupervisor(student.AcademicSupervisorId);
                Placement = new PlacementRepository().GetById(student.Id);
                Row = StudentDirectoryRow.From(student, group, supervisor == null ? null : supervisor.FullName, Placement,
                    ResolveUrl("~/Pages/Coordinator/Students.aspx?id="));
                Page.Title = student.FullName;
            }
            catch (FirebaseException)
            {
                LoadError = L.T("Coordinator.Students.CouldNotLoadThisStudentPlease");
            }
        }

        protected static string Show(string value)
        {
            return string.IsNullOrWhiteSpace(value) ? L.T("Coordinator.ManageStudents.NotRecorded") : value;
        }

        protected static string DateText(long unixMs)
        {
            if (unixMs <= 0) return L.T("Coordinator.ManageStudents.NotRecorded");
            return Time.DisplayDate(unixMs);
        }
    }
}
