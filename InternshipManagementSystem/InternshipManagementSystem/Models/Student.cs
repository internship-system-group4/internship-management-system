// =============================================================================
//  University Internship Management System (UIMS)  -  Group 4
//  A trainee account.
//  Owner: Ahmad  (Trello card X02 - Shared Firebase Data Structure)
//  Do not edit without telling the owner: every page in the system depends on
//  these types. Add new fields, never rename or remove existing ones.
// =============================================================================

using System.Web.Script.Serialization;
using InternshipManagementSystem.Common;

namespace InternshipManagementSystem.Models
{
    public class Student : Person
    {
        public Student() : base(UserRole.Student)
        {
            RequiredHours = Constants.DefaultRequiredHours;
        }

        public string StudentNumber { get; set; }
        public string University { get; set; }
        public string College { get; set; }
        public string Major { get; set; }

        /// <summary>Hours the university requires for this student (card A05).</summary>
        public int RequiredHours { get; set; }

        /// <summary>Approved hours only. Reported-but-unapproved hours are NOT
        /// counted here - see Services/HoursService.cs and card S04.</summary>
        public int ApprovedHours { get; set; }

        /// <summary>Group assigned by the coordinator (cards A08, A09).</summary>
        public string GroupId { get; set; }

        /// <summary>Denormalised from the group so the academic supervisor's
        /// dashboard (card S01) can query students in one read.</summary>
        public string AcademicSupervisorId { get; set; }

        public string CvUrl { get; set; }
        public string PortfolioUrl { get; set; }

        /// <summary>The one confirmed internship. Null means the student has
        /// not confirmed an offer yet, and this single field is what enforces
        /// the "a student cannot confirm more than one offer" rule (card O03).
        /// Write it inside a conditional update so two simultaneous clicks
        /// cannot both win - see Data/PlacementRepository.cs.</summary>
        public string ConfirmedPlacementId { get; set; }

        public override string DashboardUrl
        {
            get { return "~/Pages/Student/Dashboard.aspx"; }
        }

        public override string RoleDisplayName
        {
            get { return "Student"; }
        }

        [ScriptIgnore]
        public bool HasConfirmedPlacement
        {
            get { return !string.IsNullOrEmpty(ConfirmedPlacementId); }
        }

        /// <summary>0-100, for progress bars on the dashboards.</summary>
        [ScriptIgnore]
        public int HoursProgressPercent
        {
            get
            {
                if (RequiredHours <= 0) return 0;
                int percent = (int)((ApprovedHours * 100L) / RequiredHours);
                return percent > 100 ? 100 : percent;
            }
        }
    }
}
