// =============================================================================
//  University Internship Management System (UIMS)  -  Group 4
//  A company-side supervisor account.
//  Owner: Ahmad  (Trello card X02 - Shared Firebase Data Structure)
//  Do not edit without telling the owner: every page in the system depends on
//  these types. Add new fields, never rename or remove existing ones.
// =============================================================================

using InternshipManagementSystem.Common;

namespace InternshipManagementSystem.Models
{
    public class CompanySupervisor : Person
    {
        public CompanySupervisor() : base(UserRole.CompanySupervisor) { }

        /// <summary>Every company page must filter by this value. A supervisor
        /// may never see another company's applications, trainees or tasks.</summary>
        public string CompanyId { get; set; }

        /// <summary>Denormalised for display so dashboards avoid a second read.</summary>
        public string CompanyName { get; set; }

        public string JobTitle { get; set; }

        /// <summary>Profile photo saved with the account by the company profile page.</summary>
        public string ProfileImageBase64 { get; set; }

        public override string DashboardUrl
        {
            get { return "~/Pages/Company/Dashboard.aspx"; }
        }

        public override string RoleDisplayName
        {
            get { return "Company Supervisor"; }
        }
    }
}
