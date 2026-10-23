// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad  (Trello card A08)
//  Student groups and their academic supervisor (cards A08, A09).
// =============================================================================

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Data
{
    public class GroupRepository : RepositoryBase<StudentGroup>
    {
        protected override string Collection
        {
            get { return Constants.Paths.Groups; }
        }

        protected override void SetId(StudentGroup entity, string id)
        {
            entity.Id = id;
        }

        /// <summary>Save the group and all three relationship views in one
        /// Firebase multi-path update. An empty student list is allowed.</summary>
        public void SaveAssignments(StudentGroup requested, List<string> selectedIds)
        {
            if (requested == null || string.IsNullOrWhiteSpace(requested.Name))
                throw new InvalidOperationException("Enter a group name.");
            if (requested.Name.Length > 120 || (requested.AcademicYear != null && requested.AcademicYear.Length > 30)
                || (requested.Semester != null && requested.Semester.Length > 40))
                throw new InvalidOperationException("One or more group fields are too long.");
            if (!SafeKey(requested.AcademicSupervisorId)
                || (!string.IsNullOrEmpty(requested.Id) && !SafeKey(requested.Id)))
                throw new InvalidOperationException("Select a valid group and academic supervisor.");

            UserRepository users = new UserRepository();
            List<Person> people = users.GetAllPeople();
            AcademicSupervisor supervisor = people.OfType<AcademicSupervisor>()
                .FirstOrDefault(p => p.Id == requested.AcademicSupervisorId && p.IsActive);
            if (supervisor == null) throw new InvalidOperationException("Select an active academic supervisor.");

            List<StudentGroup> existingGroups = GetAll();
            bool creating = string.IsNullOrEmpty(requested.Id);
            StudentGroup previous = creating ? null : existingGroups.FirstOrDefault(group => group.Id == requested.Id);
            if (!creating && previous == null) throw new InvalidOperationException("Group no longer exists. Reload the page.");
            string id = creating ? Guid.NewGuid().ToString("N") : previous.Id;
            List<string> chosen = (selectedIds ?? new List<string>()).Distinct().ToList();
            HashSet<string> chosenSet = new HashSet<string>(chosen);
            Dictionary<string, Student> students = people.OfType<Student>().ToDictionary(p => p.Id);
            foreach (string studentId in chosen)
            {
                Student student;
                if (!SafeKey(studentId) || !students.TryGetValue(studentId, out student)
                    || !IsAvailableForGroup(student, existingGroups, id))
                    throw new InvalidOperationException("A selected student is no longer available. Reload the page.");
            }

            Dictionary<string, object> updates = new Dictionary<string, object>();
            List<Student> affected = new List<Student>();
            string groupPath = Constants.Paths.Groups + "/" + id + "/";
            updates[groupPath + "Id"] = id;
            updates[groupPath + "Name"] = requested.Name;
            updates[groupPath + "AcademicYear"] = requested.AcademicYear;
            updates[groupPath + "Semester"] = requested.Semester;
            updates[groupPath + "AcademicSupervisorId"] = supervisor.Id;
            updates[groupPath + "AcademicSupervisorName"] = supervisor.FullName;
            updates[groupPath + "StudentIds"] = chosen;
            if (creating) updates[groupPath + "CreatedAt"] = requested.CreatedAt;

            PlacementRepository placements = new PlacementRepository();
            foreach (Student student in students.Values)
            {
                bool selected = chosenSet.Contains(student.Id);
                if (!selected && student.GroupId != id) continue;
                affected.Add(student);
                string studentPath = Constants.Paths.Users + "/" + student.Id + "/";
                updates[studentPath + "GroupId"] = selected ? id : null;
                updates[studentPath + "AcademicSupervisorId"] = selected ? supervisor.Id : null;

                // Placements cache this ID for academic progress queries. Do
                // not create a placement for a student who has none yet.
                Placement placement = placements.GetById(student.Id);
                if (placement != null)
                    updates[Constants.Paths.Placements + "/" + student.Id + "/AcademicSupervisorId"] =
                        selected ? supervisor.Id : null;
            }

            if (previous != null && previous.AcademicSupervisorId != supervisor.Id)
            {
                AcademicSupervisor former = people.OfType<AcademicSupervisor>()
                    .FirstOrDefault(p => p.Id == previous.AcademicSupervisorId);
                if (former != null)
                {
                    List<string> formerIds = new List<string>(former.GroupIds ?? new List<string>());
                    formerIds.RemoveAll(groupId => groupId == id);
                    updates[Constants.Paths.Users + "/" + former.Id + "/GroupIds"] = formerIds;
                }
            }
            List<string> newIds = new List<string>(supervisor.GroupIds ?? new List<string>());
            if (!newIds.Contains(id)) newIds.Add(id);
            updates[Constants.Paths.Users + "/" + supervisor.Id + "/GroupIds"] = newIds;

            FirebaseContext.Patch("", updates);
            requested.Id = id;
            // The multi-path write bypasses UserRepository; emit only after it succeeds.
            foreach (Student student in affected)
            {
                var updated = Json.Deserialize<Student>(Json.Serialize(student));
                updated.AcademicSupervisorId = chosenSet.Contains(student.Id) ? supervisor.Id : null;
                Services.EmailNotificationService.Saved(student, updated);
            }
        }

        /// <summary>Unassigned students can join a group; its existing members
        /// remain selectable while that group is being edited.</summary>
        public static bool IsAvailableForGroup(Student student, IEnumerable<StudentGroup> groups, string groupId)
        {
            if (student == null) return false;
            if (!string.IsNullOrEmpty(student.GroupId) && student.GroupId != groupId) return false;

            bool belongsToThisGroup = false;
            foreach (StudentGroup group in groups)
            {
                if (group.StudentIds == null || !group.StudentIds.Contains(student.Id)) continue;
                if (group.Id != groupId) return false;
                belongsToThisGroup = true;
            }

            return student.IsActive || (groupId != null &&
                (student.GroupId == groupId || belongsToThisGroup));
        }

        private static bool SafeKey(string value)
        {
            return !string.IsNullOrWhiteSpace(value) && Regex.IsMatch(value, @"^[A-Za-z0-9_-]+$");
        }
    }
}
