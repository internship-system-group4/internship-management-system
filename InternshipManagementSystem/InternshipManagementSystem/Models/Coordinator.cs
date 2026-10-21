// =============================================================================
//  University Internship Management System (UIMS)  -  Group 4
//  The university internship coordinator account.
//  Owner: Ahmad  (Trello card X02 - Shared Firebase Data Structure)
//  Do not edit without telling the owner: every page in the system depends on
//  these types. Add new fields, never rename or remove existing ones.
// =============================================================================

using InternshipManagementSystem.Common;

namespace InternshipManagementSystem.Models
{
    /// <summary>
    /// The only role that creates other accounts and the only role that gives
    /// final approval on internship completion.
    /// </summary>
    public class Coordinator : Person
    {
        public Coordinator() : base(UserRole.Coordinator) { }

        public string College { get; set; }
        public string OfficeLocation { get; set; }

        public override string DashboardUrl
        {
            get { return "~/Pages/Coordinator/Dashboard.aspx"; }
        }

        public override string RoleDisplayName
        {
            get { return "Internship Coordinator"; }
        }
    }
}
