using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;
using Newtonsoft.Json;

namespace InternshipManagementSystem.Pages.CoordinatorArea
{
    public class StudentDirectoryRow
    {
        public string Id, FullName, Email, Phone, StudentNumber, University, College, Major, MajorKey;
        public string Initials, StatusText, HoursText, CreatedText, GroupName, SupervisorName, PlacementText, ProfileUrl, SearchText;
        public int ApprovedHours, RequiredHours, HoursPercent;
        public bool IsActive;

        public static List<StudentDirectoryRow> Build(List<Student> students, List<Person> people, string profileBase)
        {
            Dictionary<string, StudentGroup> groups = new Dictionary<string, StudentGroup>();
            foreach (StudentGroup group in new GroupRepository().GetAll())
            {
                if (group != null && !string.IsNullOrEmpty(group.Id)) groups[group.Id] = group;
            }

            Dictionary<string, Placement> placements = new Dictionary<string, Placement>();
            foreach (Placement placement in new PlacementRepository().GetAll())
            {
                if (placement != null && !string.IsNullOrEmpty(placement.StudentId)) placements[placement.StudentId] = placement;
            }

            Dictionary<string, string> supervisors = new Dictionary<string, string>();
            foreach (AcademicSupervisor supervisor in people.OfType<AcademicSupervisor>())
            {
                supervisors[supervisor.Id] = supervisor.FullName;
            }

            List<StudentDirectoryRow> rows = new List<StudentDirectoryRow>();
            foreach (Student student in students)
            {
                groups.TryGetValue(student.GroupId ?? "", out StudentGroup group);
                placements.TryGetValue(student.Id, out Placement placement);
                supervisors.TryGetValue(student.AcademicSupervisorId ?? "", out string supervisorName);
                rows.Add(From(student, group, supervisorName, placement, profileBase));
            }
            return rows;
        }

        public static StudentDirectoryRow From(Student s, StudentGroup group, string supervisorName, Placement placement, string profileBase)
        {
            string none = L.T("Coordinator.ManageStudents.NotRecorded");
            AcademicProgram program = AcademicPrograms.Find(s.Major);
            MajorQuality quality = AcademicPrograms.Quality(s.Major);

            int required = s.RequiredHours > 160 ? 160 : s.RequiredHours;
            int approved = s.ApprovedHours;

            var row = new StudentDirectoryRow
            {
                Id = s.Id,
                FullName = s.FullName ?? none,
                Email = s.Email ?? none,
                Phone = string.IsNullOrWhiteSpace(s.PhoneNumber) ? none : s.PhoneNumber,
                StudentNumber = string.IsNullOrWhiteSpace(s.StudentNumber) ? none : s.StudentNumber,
                University = string.IsNullOrWhiteSpace(s.University) ? none : s.University,
                College = string.IsNullOrWhiteSpace(s.College) ? none : s.College,
                Major = string.IsNullOrWhiteSpace(s.Major) ? none : s.Major,
                MajorKey = program != null ? program.Key : (quality == MajorQuality.Missing ? AcademicPrograms.MissingKey : AcademicPrograms.UnrecognizedKey),
                IsActive = s.IsActive,
                StatusText = s.IsActive ? L.T("Coordinator.ManageStudents.StatusActive") : L.T("Coordinator.ManageStudents.StatusInactive"),
                ApprovedHours = approved,
                RequiredHours = required,
                HoursPercent = required <= 0 ? 0 : Math.Min(100, approved * 100 / required),
                HoursText = approved + " / " + required + " " + L.T("Workspace.UnitH"),
                CreatedText = s.CreatedAt > 0 ? s.CreatedAtUtc.ToString("dd MMM yyyy") : none,
                GroupName = group == null ? L.T("Coordinator.ManageStudents.NoGroup") : group.Name,
                SupervisorName = string.IsNullOrEmpty(supervisorName) ? L.T("Coordinator.ManageStudents.NotAssigned") : supervisorName,
                PlacementText = placement == null ? L.T("Coordinator.ManageStudents.NoPlacement")
                    : string.IsNullOrWhiteSpace(placement.CompanyName) ? L.Value("PlacementStatus", placement.Status)
                    : placement.CompanyName + " · " + L.Value("PlacementStatus", placement.Status),
                ProfileUrl = profileBase + Uri.EscapeDataString(s.Id),
                Initials = MakeInitials(s.FullName)
            };

            row.SearchText = string.Join(" ", new[] { s.FullName, s.Email, s.StudentNumber, s.Major, s.University, s.College }).ToLowerInvariant();

            return row;
        }

        public static string MakeInitials(string name)
        {
            string[] parts = (name ?? "").Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 0) return "?";
            string initials = parts[0].Substring(0, 1);
            if (parts.Length > 1) initials += parts[parts.Length - 1].Substring(0, 1);
            return initials.ToUpperInvariant();
        }
    }

    public partial class ManageStudents : InternshipManagementSystem.Security.CoordinatorPage
    {
        private readonly UserRepository _userRepo = new UserRepository();
        protected List<StudentDirectoryRow> Rows = new List<StudentDirectoryRow>();

        protected string RowsJson
        {
            get { return JsonConvert.SerializeObject(Rows, new JsonSerializerSettings { StringEscapeHandling = StringEscapeHandling.EscapeHtml }); }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                foreach (AcademicProgram program in AcademicPrograms.All)
                {
                    ddlEditMajor.Items.Add(new System.Web.UI.WebControls.ListItem(program.Name, program.Name));
                }
            }
            BindStudents();
            if (IsPostBack) return;
            string id = Request.QueryString["id"];
            if (IsValidStudentId(id)) LoadStudent(id);
        }

        protected void StudentCreator_Created(object sender, EventArgs e)
        {
            pnlDetails.Visible = false;
            BindStudents();
        }

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            var button = sender as System.Web.UI.WebControls.LinkButton;
            if (button != null && IsValidStudentId(button.CommandArgument)) LoadStudent(button.CommandArgument);
        }

        protected void btnSaveDetails_Click(object sender, EventArgs e)
        {
            string id = ViewState["EditingStudentId"] as string;
            pnlDetails.Visible = IsValidStudentId(id);
            if (!pnlDetails.Visible)
            {
                ShowListMessage(L.T("Coordinator.ManageStudents.SelectAStudentBeforeSavingChanges"));
                return;
            }

            string major = InternshipManagementSystem.Common.Validators.Clean(ddlEditMajor.SelectedValue);

            if (string.IsNullOrEmpty(major))
            {
                ShowDetailsMessage(L.T("Coordinator.ManageStudents.CompleteAllAcademicInformationFields"), false);
                return;
            }

            try
            {
                if (_userRepo.GetStudent(id) == null)
                {
                    ClearSelection();
                    BindStudents();
                    ShowListMessage(L.T("Coordinator.ManageStudents.StudentRecordNotFound"));
                    return;
                }

                _userRepo.Update(id, new Dictionary<string, object>
                {
                    { "Major", major }
                });

                ddlEditMajor.SelectedValue = major;
                BindStudents();
                ShowDetailsMessage(L.T("Coordinator.ManageStudents.StudentAcademicInformationSaved"), true);
            }
            catch (Exception)
            {
                ShowDetailsMessage(L.T("Coordinator.ManageStudents.CouldNotSaveStudentInformationPlease"), false);
            }
        }

        private void LoadStudent(string id)
        {
            try
            {
                Student student = _userRepo.GetStudent(id);
                if (student == null)
                {
                    ClearSelection();
                    ShowListMessage(L.T("Coordinator.ManageStudents.StudentRecordNotFound"));
                    return;
                }
                ShowDetails(student);
            }
            catch (Exception)
            {
                ShowListMessage(L.T("Coordinator.ManageStudents.CouldNotLoadThisStudentPlease"));
            }
        }

        private void ShowDetails(Student student)
        {
            ViewState["EditingStudentId"] = student.Id;
            pnlDetails.Visible = true;
            lblDetailsMessage.Visible = false;
            litInitials.Text = InternshipManagementSystem.Common.Validators.Safe(StudentDirectoryRow.MakeInitials(student.FullName));
            lblStudentName.Text = InternshipManagementSystem.Common.Validators.Safe(student.FullName);
            lblStudentEmail.Text = InternshipManagementSystem.Common.Validators.Safe(student.Email);
            txtEditStudentNumber.Text = student.StudentNumber;
            txtEditUniversity.Text = student.University;
            txtEditCollege.Text = student.College;

            if (ddlEditMajor.Items.FindByValue(student.Major) == null && !string.IsNullOrEmpty(student.Major))
                ddlEditMajor.Items.Add(new System.Web.UI.WebControls.ListItem(student.Major, student.Major));
            if (!string.IsNullOrEmpty(student.Major)) ddlEditMajor.SelectedValue = student.Major;
        }

        private void ClearSelection()
        {
            ViewState["EditingStudentId"] = null;
            pnlDetails.Visible = false;
        }

        private void BindStudents()
        {
            lblListMessage.Visible = false;
            try
            {
                List<Person> people = _userRepo.GetAllPeople();
                List<Student> students = people.OfType<Student>()
                    .OrderBy(s => s.FullName ?? "", StringComparer.OrdinalIgnoreCase).ToList();
                Rows = StudentDirectoryRow.Build(students, people, ResolveUrl("~/Pages/Coordinator/Students.aspx?id="));
                rptStudents.DataSource = Rows;
                rptStudents.DataBind();
                lblNoStudents.Text = L.T("Coordinator.ManageStudents.NoStudentsFound");
                lblNoStudents.Visible = Rows.Count == 0;
            }
            catch (Exception)
            {
                Rows = new List<StudentDirectoryRow>();
                rptStudents.DataSource = Rows;
                rptStudents.DataBind();
                lblNoStudents.Visible = false;
                ShowListMessage(L.T("Coordinator.ManageStudents.CouldNotLoadStudentRecordsPlease"));
            }
        }

        protected string MajorFilter
        {
            get
            {
                string value = (Request.QueryString["major"] ?? "").Trim().ToLowerInvariant();
                if (value == AcademicPrograms.MissingKey || value == AcademicPrograms.UnrecognizedKey) return value;
                return AcademicPrograms.ByKey(value) != null ? value : null;
            }
        }

        private static bool IsValidStudentId(string id)
        {
            return !string.IsNullOrEmpty(id) && Regex.IsMatch(id, @"\A[A-Za-z0-9_-]{1,128}\z");
        }

        private void ShowListMessage(string message)
        {
            lblListMessage.Text = InternshipManagementSystem.Common.Validators.Safe(message);
            lblListMessage.CssClass = "alert alert-danger d-block";
            lblListMessage.Visible = true;
        }

        private void ShowDetailsMessage(string message, bool success)
        {
            lblDetailsMessage.Text = InternshipManagementSystem.Common.Validators.Safe(message);
            lblDetailsMessage.CssClass = success ? "alert alert-success d-block" : "alert alert-danger d-block";
            lblDetailsMessage.Visible = true;
        }
    }
}