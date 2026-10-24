using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.CoordinatorArea
{
    /// <summary>One supervisor's profile for the coordinator
    /// (SupervisorProfile.aspx?id=...). Works for both academic supervisors
    /// (groups and supervised students) and company supervisors (company and
    /// interns). Opened from "View profile" in the supervisor pop-ups.</summary>
    public partial class SupervisorProfile : CoordinatorPage
    {
        protected Person Person;
        protected AcademicSupervisor Academic;
        protected CompanySupervisor CompanyPerson;
        protected Company Company;
        protected List<string> GroupNames = new List<string>();
        protected List<StudentDirectoryRow> StudentRows = new List<StudentDirectoryRow>();
        protected string LoadError;

        protected bool IsAcademic { get { return Academic != null; } }

        /// <summary>The supervisor list this profile belongs to.</summary>
        protected string BackUrl
        {
            get { return ResolveUrl(CompanyPerson != null ? "~/Pages/Coordinator/Companies.aspx" : "~/Pages/Coordinator/AcademicSupervisors.aspx"); }
        }

        protected string BackText
        {
            get { return CompanyPerson != null ? L.T("Coordinator.SupervisorProfile.AllCompanySupervisors") : L.T("Coordinator.SupervisorProfile.AllAcademicSupervisors"); }
        }

        protected int PlacedCount
        {
            get { return StudentRows.Count(r => r.PlacementText != L.T("Coordinator.ManageStudents.NoPlacement")); }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            string id = Request.QueryString["id"];
            if (string.IsNullOrEmpty(id) || !Regex.IsMatch(id, @"\A[A-Za-z0-9_-]{1,128}\z"))
            {
                Response.Redirect(ResolveUrl("~/Pages/Coordinator/AcademicSupervisors.aspx"), false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            try
            {
                UserRepository users = new UserRepository();
                Person = users.GetPerson(id);
                Academic = Person as AcademicSupervisor;
                CompanyPerson = Person as CompanySupervisor;
                if (Academic == null && CompanyPerson == null)
                {
                    Person = null;
                    LoadError = L.T("Coordinator.SupervisorProfile.NotFound");
                    return;
                }

                string profileBase = ResolveUrl("~/Pages/Coordinator/Students.aspx?id=");
                if (IsAcademic)
                {
                    GroupNames = new GroupRepository().GetAll()
                        .Where(g => g != null && g.AcademicSupervisorId == id)
                        .Select(g => g.Name).OrderBy(n => n).ToList();
                    List<Student> students = users.GetStudentsBySupervisor(id);
                    StudentRows = StudentDirectoryRow.Build(students, new List<Person> { Academic }, profileBase)
                        .OrderBy(r => r.FullName, StringComparer.OrdinalIgnoreCase).ToList();
                }
                else
                {
                    if (!string.IsNullOrEmpty(CompanyPerson.CompanyId))
                        Company = new CompanyRepository().GetById(CompanyPerson.CompanyId);

                    // Interns: students whose placement names this company supervisor.
                    HashSet<string> internIds = new HashSet<string>(new PlacementRepository().GetAll()
                        .Where(p => p != null && p.CompanySupervisorId == id && !string.IsNullOrEmpty(p.StudentId))
                        .Select(p => p.StudentId));
                    List<Person> people = users.GetAllPeople();
                    List<Student> interns = people.OfType<Student>().Where(s => internIds.Contains(s.Id)).ToList();
                    StudentRows = StudentDirectoryRow.Build(interns, people, profileBase)
                        .OrderBy(r => r.FullName, StringComparer.OrdinalIgnoreCase).ToList();
                }
                Page.Title = Person.FullName;
            }
            catch (FirebaseException)
            {
                Person = null;
                LoadError = L.T("Coordinator.SupervisorProfile.LoadError");
            }
        }

        protected static string Show(string value)
        {
            return string.IsNullOrWhiteSpace(value) ? L.T("Coordinator.ManageStudents.NotRecorded") : value;
        }

        protected string CreatedText
        {
            get { return Person == null || Person.CreatedAt <= 0 ? L.T("Coordinator.ManageStudents.NotRecorded") : Time.DisplayDate(Person.CreatedAt); }
        }

        protected string StatusText
        {
            get { return Person != null && Person.IsActive ? L.T("Coordinator.ManageStudents.StatusActive") : L.T("Coordinator.ManageStudents.StatusInactive"); }
        }

        /// <summary>Only http(s) company websites become links.</summary>
        protected static bool IsWebLink(string url)
        {
            return !string.IsNullOrWhiteSpace(url)
                && (url.StartsWith("http://", StringComparison.OrdinalIgnoreCase) || url.StartsWith("https://", StringComparison.OrdinalIgnoreCase));
        }
    }
}
