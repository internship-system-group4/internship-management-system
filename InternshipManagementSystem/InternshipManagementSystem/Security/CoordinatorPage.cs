// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad  (Trello card A02)
//  Coordinator pages - the only role that creates accounts and approves completion.
// =============================================================================

using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Security
{
    public abstract class CoordinatorPage : SecurePage
    {
        protected override UserRole[] AllowedRoles
        {
            get { return new[] { UserRole.Coordinator }; }
        }

        /// <summary>The signed-in account, already the right type. Never null
        /// inside Page_Load: SecurePage redirects before the page runs.</summary>
        protected Coordinator CurrentCoordinator
        {
            get { return CurrentUser as Coordinator; }
        }
    }
}
