// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad  (Trello card X02)
//  Accounts. The key is always the Firebase Auth UID.
// =============================================================================

using System.Collections.Generic;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Data
{
    /// <summary>
    /// All four roles live in one collection, users/{uid}, with a Role field.
    ///
    /// Why one collection rather than students/, supervisors/, coordinators/:
    /// login and the role guard need the account on every single request, and
    /// one node means one read and no chance of two nodes drifting apart. The
    /// subclass is rebuilt from the Role field by Models/PersonFactory.cs.
    /// </summary>
    public class UserRepository : NotifyingRepositoryBase<Person>
    {
        protected override string Collection
        {
            get { return Constants.Paths.Users; }
        }

        protected override void SetId(Person entity, string id)
        {
            entity.Id = id;
        }

        // ------------------------------------------------------------------
        //  Person is abstract, so the generic base implementations cannot work
        //  here: a deserialiser has no way to instantiate it and would throw
        //  "Cannot create an abstract class" at run time. These three overrides
        //  route to the PersonFactory path instead, so calling the familiar
        //  GetById / GetAll on this repository does the right thing rather than
        //  failing in a way that takes an afternoon to understand.
        // ------------------------------------------------------------------

        public override Person GetById(string id)
        {
            return GetPerson(id);
        }

        public override List<Person> GetAll()
        {
            return GetAllPeople();
        }

        /// <summary>Blocked on purpose. An account's key must be the Firebase
        /// Authentication UID, never a generated push key, or the account and
        /// its credentials drift apart and nothing can look the user up at
        /// sign-in. Use AuthService.CreateAccount, then SavePerson.</summary>
        public override string Insert(Person entity)
        {
            throw new System.InvalidOperationException(
                "Do not Insert an account. Call Services.AuthService.CreateAccount to get the " +
                "UID, set it on the Person, then call SavePerson. See cards A05, A07 and N03.");
        }

        public override List<Person> GetWhere(string field, string value)
        {
            List<Person> matches = new List<Person>();
            if (string.IsNullOrEmpty(value)) return matches;

            // Filtered in memory rather than by Firebase, because the result
            // has to pass through PersonFactory to become the right subclass.
            // Fine at this project's scale.
            foreach (Person person in GetAllPeople())
            {
                if (Matches(person, field, value)) matches.Add(person);
            }
            return matches;
        }

        private static bool Matches(Person person, string field, string value)
        {
            switch (field)
            {
                case "Email": return person.Email == value;
                case "FullName": return person.FullName == value;
                case "Role": return ((int)person.Role).ToString() == value;
                default:
                    Student student = person as Student;
                    if (student == null) return false;
                    if (field == "GroupId") return student.GroupId == value;
                    if (field == "AcademicSupervisorId") return student.AcademicSupervisorId == value;
                    return false;
            }
        }

        /// <summary>Reads one account and rebuilds the right subclass.</summary>
        public Person GetPerson(string uid)
        {
            if (string.IsNullOrEmpty(uid)) return null;
            Person person = PersonFactory.FromJson(FirebaseContext.Get(Collection + "/" + uid));
            if (person != null) person.Id = uid;
            return person;
        }

        /// <summary>Typed convenience reads. They return null when the uid
        /// exists but holds a different role, which is exactly what a page
        /// wants - a company supervisor's uid must not load as a Student.</summary>
        public Student GetStudent(string uid)
        {
            return GetPerson(uid) as Student;
        }

        public CompanySupervisor GetCompanySupervisor(string uid)
        {
            return GetPerson(uid) as CompanySupervisor;
        }

        public AcademicSupervisor GetAcademicSupervisor(string uid)
        {
            return GetPerson(uid) as AcademicSupervisor;
        }

        /// <summary>Creates or replaces an account record. Call this right
        /// after Services/AuthService.CreateAccount so the UID matches.</summary>
        public void SavePerson(Person person)
        {
            if (person == null || string.IsNullOrEmpty(person.Id)) return;
            Save(person.Id, person);
        }

        public List<Person> GetByRole(UserRole role)
        {
            List<Person> all = GetAllPeople();
            List<Person> filtered = new List<Person>();
            foreach (Person person in all)
            {
                if (person.Role == role) filtered.Add(person);
            }
            return filtered;
        }

        public List<Student> GetStudentsByGroup(string groupId)
        {
            List<Student> students = new List<Student>();
            if (string.IsNullOrEmpty(groupId)) return students;
            foreach (Person person in GetByRole(UserRole.Student))
            {
                Student student = person as Student;
                if (student != null && student.GroupId == groupId) students.Add(student);
            }
            return students;
        }

        /// <summary>Students assigned to one academic supervisor (card S01).</summary>
        public List<Student> GetStudentsBySupervisor(string academicSupervisorId)
        {
            List<Student> students = new List<Student>();
            if (string.IsNullOrEmpty(academicSupervisorId)) return students;
            foreach (Person person in GetByRole(UserRole.Student))
            {
                Student student = person as Student;
                if (student != null && student.AcademicSupervisorId == academicSupervisorId)
                {
                    students.Add(student);
                }
            }
            return students;
        }

        /// <summary>Reads every account, rebuilding each one as its subclass.
        /// Fine at this project's scale; if the user count ever grows, add
        /// a role index in Firebase and switch to GetWhere.</summary>
        public List<Person> GetAllPeople()
        {
            List<Person> people = new List<Person>();
            string json = FirebaseContext.Get(Collection);
            if (string.IsNullOrWhiteSpace(json) || json == "null") return people;

            Dictionary<string, object> raw = Json.ToMap(json);
            foreach (KeyValuePair<string, object> pair in raw)
            {
                Person person = PersonFactory.FromJson(Json.Serialize(pair.Value));
                if (person == null) continue;
                person.Id = pair.Key;
                people.Add(person);
            }
            return people;
        }

        /// <summary>Activate / deactivate without rewriting the record (card N04).</summary>
        public void SetActive(string uid, bool isActive)
        {
            Update(uid, new Dictionary<string, object> { { "IsActive", isActive } });
        }

        public void ClearMustChangePassword(string uid)
        {
            Update(uid, new Dictionary<string, object> { { "MustChangePassword", false } });
        }
    }
}
