// =============================================================================
//  University Internship Management System (UIMS)  -  Group 4
//  The abstract base of every account in the system.
//  Owner: Ahmad  (Trello card X02 - Shared Firebase Data Structure)
//  Do not edit without telling the owner: every page in the system depends on
//  these types. Add new fields, never rename or remove existing ones.
// =============================================================================

using System.Web.Script.Serialization;
using InternshipManagementSystem.Common;

namespace InternshipManagementSystem.Models
{
    /// <summary>
    /// Base type for the four account kinds. The fields here are the ones every
    /// account has; anything role-specific belongs on the subclass.
    ///
    /// Why this is a class hierarchy and not one flat User class with a role
    /// field: the two members at the bottom - DashboardUrl and CanLogin - turn
    /// login (card A02) and the role guard (Security/SecurePage.cs) into a
    /// single line each, and stay correct when a new role is added later.
    ///
    /// Role is a settable property, NOT an abstract read-only one, because the
    /// JSON deserializer needs a setter to rebuild an object coming back out of
    /// Firebase. Each subclass pins the value in its constructor.
    /// </summary>
    public abstract class Person
    {
        /// <summary>Firebase Authentication UID. This is the single identifier
        /// used as the key everywhere - users/{Id}, placements/{...}/studentId,
        /// and so on. Never invent a second id for a person.</summary>
        public string Id { get; set; }

        public string FullName { get; set; }
        public string Email { get; set; }
        public string PhoneNumber { get; set; }

        public UserRole Role { get; set; }

        /// <summary>Coordinator can deactivate an account (card N04). A
        /// deactivated account must not pass the role guard.</summary>
        public bool IsActive { get; set; }

        /// <summary>True while the account still has its temporary password
        /// (card A04). SecurePage forces the change-password page until the
        /// user clears this flag.</summary>
        public bool MustChangePassword { get; set; }

        public string ProfileImageUrl { get; set; }

        /// <summary>Unix milliseconds. See Common/Time.cs.</summary>
        public long CreatedAt { get; set; }

        [ScriptIgnore]
        public System.DateTime CreatedAtUtc
        {
            get { return Time.FromUnixMs(CreatedAt); }
        }

        /// <summary>Sort key for "newest first" lists. A record saved without
        /// CreatedAt gets "now" from the constructor when it is loaded, so any
        /// value at or after <paramref name="loadedAt"/> means "unknown" (sorted last).</summary>
        public long CreatedSortKey(long loadedAt)
        {
            return CreatedAt >= loadedAt ? 0 : CreatedAt;
        }

        protected Person(UserRole role)
        {
            Role = role;
            IsActive = true;
            CreatedAt = Time.NowMs();
        }

        /// <summary>Where this person lands after signing in. Card A02 becomes:
        /// Response.Redirect(user.DashboardUrl).</summary>
        [ScriptIgnore]
        public abstract string DashboardUrl { get; }

        /// <summary>Human-readable role name for the UI.</summary>
        [ScriptIgnore]
        public abstract string RoleDisplayName { get; }

        public virtual bool CanLogin()
        {
            return IsActive;
        }

        /// <summary>First name only - for "Welcome, Ahmad" headers.</summary>
        [ScriptIgnore]
        public string FirstName
        {
            get
            {
                if (string.IsNullOrWhiteSpace(FullName)) return string.Empty;
                return FullName.Trim().Split(' ')[0];
            }
        }
    }
}
