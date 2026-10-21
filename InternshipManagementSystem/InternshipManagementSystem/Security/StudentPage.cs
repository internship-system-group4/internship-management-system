// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad  (Trello card A02)
//  Student pages. CurrentStudent is the signed-in trainee.
// =============================================================================

using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Security
{
    public abstract class StudentPage : SecurePage
    {
        protected override UserRole[] AllowedRoles
        {
            get { return new[] { UserRole.Student }; }
        }

        /// <summary>The signed-in account, already the right type. Never null
        /// inside Page_Load: SecurePage redirects before the page runs.</summary>
        protected Student CurrentStudent
        {
            get { return CurrentUser as Student; }
        }
    }
}
