// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad  (Trello card A02)
//  The only place that reads or writes the signed-in user.
// =============================================================================

using System.Web;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Security
{
    /// <summary>
    /// Do not touch Session["..."] anywhere else. Going through one helper
    /// means a change to how sign-in is stored is a change to one file.
    /// </summary>
    public static class SessionHelper
    {
        /// <summary>The signed-in person, or null when nobody is signed in.</summary>
        public static Person Current
        {
            get
            {
                if (HttpContext.Current == null || HttpContext.Current.Session == null) return null;
                return HttpContext.Current.Session[Constants.SessionUserKey] as Person;
            }
        }

        public static bool IsSignedIn
        {
            get { return Current != null; }
        }

        /// <summary>Called by Login.aspx once Firebase has verified the
        /// password (card A02).</summary>
        public static void SignIn(Person person, string idToken)
        {
            if (HttpContext.Current == null || person == null) return;
            HttpContext.Current.Session[Constants.SessionUserKey] = person;
            HttpContext.Current.Session[Constants.SessionTokenKey] = idToken;
        }

        /// <summary>Refreshes the cached copy after the user edits their own
        /// profile, so the header stops showing stale data.</summary>
        public static void Refresh(Person person)
        {
            if (HttpContext.Current == null || person == null) return;
            HttpContext.Current.Session[Constants.SessionUserKey] = person;
        }

        public static void SignOut()
        {
            if (HttpContext.Current == null) return;
            HttpContext.Current.Session.Clear();
            HttpContext.Current.Session.Abandon();
        }

        public static bool IsInRole(UserRole role)
        {
            Person person = Current;
            return person != null && person.Role == role;
        }

        private const string FlashPrefix = "UIMS_Flash_";

        /// <summary>Stores a one-time value for the next request, for example
        /// "this approval just succeeded" so a success animation plays once and
        /// never again on refresh.</summary>
        public static void SetFlash(string key, string value)
        {
            if (HttpContext.Current == null || HttpContext.Current.Session == null) return;
            HttpContext.Current.Session[FlashPrefix + key] = value;
        }

        /// <summary>Reads and removes a one-time value.</summary>
        public static string TakeFlash(string key)
        {
            if (HttpContext.Current == null || HttpContext.Current.Session == null) return null;
            string value = HttpContext.Current.Session[FlashPrefix + key] as string;
            HttpContext.Current.Session.Remove(FlashPrefix + key);
            return value;
        }
    }
}
