// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad  (Trello card A02)
//  Company supervisor pages. Always filter data by CurrentSupervisor.CompanyId.
// =============================================================================

using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Security
{
    public abstract class CompanyPage : SecurePage
    {
        protected override UserRole[] AllowedRoles
        {
            get { return new[] { UserRole.CompanySupervisor }; }
        }

        /// <summary>The signed-in account, already the right type. Never null
        /// inside Page_Load: SecurePage redirects before the page runs.</summary>
        protected CompanySupervisor CurrentSupervisor
        {
            get { return CurrentUser as CompanySupervisor; }
        }
    }
}
