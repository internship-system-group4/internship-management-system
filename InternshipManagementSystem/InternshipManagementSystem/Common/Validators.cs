// =============================================================================
//  University Internship Management System (UIMS)  -  Group 4
//  Shared input validation so all 40 pages behave the same way.
//  Owner: Ahmad  (Trello card X02 - Shared Firebase Data Structure)
//  Do not edit without telling the owner: every page in the system depends on
//  these types. Add new fields, never rename or remove existing ones.
// =============================================================================

using System;
using System.Text.RegularExpressions;

namespace InternshipManagementSystem.Common
{
    public static class Validators
    {
        private static readonly Regex EmailPattern =
            new Regex(@"^[^@\s]+@[^@\s]+\.[^@\s]{2,}$", RegexOptions.Compiled);

        public static bool IsEmail(string value)
        {
            return !string.IsNullOrWhiteSpace(value) && EmailPattern.IsMatch(value.Trim());
        }

        /// <summary>Firebase Authentication rejects anything under 6 characters.</summary>
        public static bool IsStrongEnoughPassword(string value)
        {
            return !string.IsNullOrEmpty(value) && value.Length >= 6;
        }

        public static bool IsUrl(string value)
        {
            if (string.IsNullOrWhiteSpace(value)) return false;
            Uri parsed;
            return Uri.TryCreate(value.Trim(), UriKind.Absolute, out parsed)
                   && (parsed.Scheme == Uri.UriSchemeHttp || parsed.Scheme == Uri.UriSchemeHttps);
        }

        public static bool IsRequired(string value)
        {
            return !string.IsNullOrWhiteSpace(value);
        }

        /// <summary>Trims and collapses whitespace; returns null for blank input.</summary>
        public static string Clean(string value)
        {
            if (string.IsNullOrWhiteSpace(value)) return null;
            return Regex.Replace(value.Trim(), @"\s+", " ");
        }

        /// <summary>HTML-encodes user text for safe rendering in a Literal.</summary>
        public static string Safe(string value)
        {
            return System.Web.HttpUtility.HtmlEncode(value ?? string.Empty);
        }
    }
}
