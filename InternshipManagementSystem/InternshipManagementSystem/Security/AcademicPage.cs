// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad  (Trello card A02)
//  Academic supervisor pages. Only show students assigned to this supervisor.
// =============================================================================

using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Security
{
    public abstract class AcademicPage : SecurePage
    {
        protected override UserRole[] AllowedRoles
        {
            get { return new[] { UserRole.AcademicSupervisor }; }
        }

        /// <summary>The signed-in account, already the right type. Never null
        /// inside Page_Load: SecurePage redirects before the page runs.</summary>
        protected AcademicSupervisor CurrentSupervisor
        {
            get { return CurrentUser as AcademicSupervisor; }
        }
    }
}
