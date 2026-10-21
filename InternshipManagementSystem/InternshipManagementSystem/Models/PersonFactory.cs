// =============================================================================
//  University Internship Management System (UIMS)  -  Group 4
//  Turns a Firebase users/{uid} node into the right Person subclass.
//  Owner: Ahmad  (Trello card X02 - Shared Firebase Data Structure)
//  Do not edit without telling the owner: every page in the system depends on
//  these types. Add new fields, never rename or remove existing ones.
// =============================================================================

using System.Collections.Generic;
using InternshipManagementSystem.Common;

namespace InternshipManagementSystem.Models
{
    /// <summary>
    /// Firebase hands back plain JSON with no type information, so something has
    /// to read the role field and pick the subclass. That is this class, and it
    /// is the ONLY place in the system that should switch on UserRole to build
    /// an object. Everywhere else works with Person.
    /// </summary>
    public static class PersonFactory
    {
        /// <summary>Reads the "role" value out of a deserialised users/{uid}
        /// node and rebuilds the correct subclass.</summary>
        public static Person FromJson(string json)
        {
            if (string.IsNullOrWhiteSpace(json) || json == "null") return null;

            Dictionary<string, object> raw = Data.Json.Deserialize<Dictionary<string, object>>(json);
            if (raw == null || !raw.ContainsKey("Role")) return null;

            UserRole role = (UserRole)System.Convert.ToInt32(raw["Role"]);
            switch (role)
            {
                case UserRole.Student:
                    return Data.Json.Deserialize<Student>(json);
                case UserRole.CompanySupervisor:
                    return Data.Json.Deserialize<CompanySupervisor>(json);
                case UserRole.AcademicSupervisor:
                    return Data.Json.Deserialize<AcademicSupervisor>(json);
                case UserRole.Coordinator:
                    return Data.Json.Deserialize<Coordinator>(json);
                default:
                    return null;
            }
        }

        /// <summary>Empty instance of the right subclass - used by the
        /// coordinator's account-creation forms (cards A05, A07, N03).</summary>
        public static Person Create(UserRole role)
        {
            switch (role)
            {
                case UserRole.Student: return new Student();
                case UserRole.CompanySupervisor: return new CompanySupervisor();
                case UserRole.AcademicSupervisor: return new AcademicSupervisor();
                case UserRole.Coordinator: return new Coordinator();
                default: return null;
            }
        }
    }
}
