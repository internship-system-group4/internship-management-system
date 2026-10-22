// =============================================================================
//  University Internship Management System (UIMS)  -  Group 4
//  A university-side supervisor account.
//  Owner: Ahmad  (Trello card X02 - Shared Firebase Data Structure)
//  Do not edit without telling the owner: every page in the system depends on
//  these types. Add new fields, never rename or remove existing ones.
// =============================================================================

using System.Collections.Generic;
using InternshipManagementSystem.Common;

namespace InternshipManagementSystem.Models
{
    public class AcademicSupervisor : Person
    {
        public AcademicSupervisor() : base(UserRole.AcademicSupervisor) { }

        public string Department { get; set; }
        public string AcademicRank { get; set; }

        /// <summary>Groups the coordinator assigned to this supervisor
        /// (cards A08, A09). Monitoring pages must only show students whose
        /// GroupId is in this list.</summary>
        public List<string> GroupIds { get; set; }

        public override string DashboardUrl
        {
            get { return "~/Pages/Academic/Dashboard.aspx"; }
        }

        public override string RoleDisplayName
        {
            get { return "Academic Supervisor"; }
        }
        public int Age { get; set; }
        // PhoneNumber comes from Person.
        public string SupervisorNumber { get; set; }
        public string University { get; set; }
        public string College { get; set; }
        public string Major { get; set; }
        public int EnrollmentYear { get; set; }
        public string TechnicalSkills { get; set; }
        public string SoftSkills { get; set; }
        public string CvUrl { get; set; }
        public string PortfolioUrl { get; set; }
        public string LinkedInUrl { get; set; }
    }
}
