// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad (Trello card X02 - shared data model)
//  A task a company supervisor assigns to a trainee (cards F01-F02).
//  Add fields freely; never rename or delete one without telling the team.
// =============================================================================

using System.Collections.Generic;
using System.Web.Script.Serialization;
using InternshipManagementSystem.Common;

namespace InternshipManagementSystem.Models
{
    /// <summary>
    /// Named InternshipTask, not Task: "Task" is System.Threading.Tasks.Task
    /// and shadowing it breaks every async call in the file.
    /// </summary>
    public class InternshipTask
    {
        public string Id { get; set; }

        public string PlacementId { get; set; }
        public string StudentId { get; set; }
        public string CompanyId { get; set; }
        public string CreatedBySupervisorId { get; set; }

        public string Title { get; set; }
        public string Description { get; set; }
        public string Instructions { get; set; }

        public long Deadline { get; set; }

        /// <summary>The criteria this task is graded against, with their weights.
        /// Not every task is out of 100 - the requirements document forbids
        /// assuming that (cards F01, A11).</summary>
        public List<GradeComponent> Criteria { get; set; }

        /// <summary>Maximum mark for this task, taken from the university's
        /// documented method, not hard-coded to 100.</summary>
        public double MaxScore { get; set; }

        /// <summary>Weight of this task inside the task component of the final
        /// grade. See Services/GradingService.cs.</summary>
        public double Weight { get; set; }

        /// <summary>Hours the supervisor expects this task to take. Reported
        /// hours still need separate approval (card S04).</summary>
        public int EstimatedHours { get; set; }

        public bool RequiresFileUpload { get; set; }

        public InternshipTaskStatus Status { get; set; }
        public long CreatedAt { get; set; }

        public InternshipTask()
        {
            Criteria = new List<GradeComponent>();
            Status = InternshipTaskStatus.Assigned;
            CreatedAt = Time.NowMs();
            Weight = 1;
        }

        [ScriptIgnore]
        public bool IsOverdue
        {
            get
            {
                return Deadline > 0
                       && Time.IsPast(Deadline)
                       && Status != InternshipTaskStatus.Graded;
            }
        }

        [ScriptIgnore]
        public bool AcceptsSubmission
        {
            get
            {
                return Status == InternshipTaskStatus.Assigned
                       || Status == InternshipTaskStatus.RevisionRequested;
            }
        }
    }
}
