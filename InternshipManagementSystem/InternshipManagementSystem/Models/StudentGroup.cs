// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad (Trello card X02 - shared data model)
//  A set of students assigned to one academic supervisor (cards A08, A09).
//  Add fields freely; never rename or delete one without telling the team.
// =============================================================================

using System.Collections.Generic;

namespace InternshipManagementSystem.Models
{
    public class StudentGroup
    {
        public string Id { get; set; }
        public string Name { get; set; }

        /// <summary>Exactly one academic supervisor per group - the project
        /// requirements are explicit about this.</summary>
        public string AcademicSupervisorId { get; set; }
        public string AcademicSupervisorName { get; set; }

        public List<string> StudentIds { get; set; }

        public string AcademicYear { get; set; }
        public string Semester { get; set; }
        public long CreatedAt { get; set; }

        public StudentGroup()
        {
            StudentIds = new List<string>();
            CreatedAt = Common.Time.NowMs();
        }
    }
}
