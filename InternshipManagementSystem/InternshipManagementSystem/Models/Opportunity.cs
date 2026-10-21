// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad (Trello card X02 - shared data model)
//  An internship opportunity published by a company (cards R01, R02).
//  Add fields freely; never rename or delete one without telling the team.
// =============================================================================

using System.Collections.Generic;
using System.Web.Script.Serialization;
using InternshipManagementSystem.Common;

namespace InternshipManagementSystem.Models
{
    public class Opportunity
    {
        public string Id { get; set; }

        public string CompanyId { get; set; }
        public string CompanyName { get; set; }

        /// <summary>The supervisor who created it. Only this company's
        /// supervisors may edit or close it (card R02).</summary>
        public string CreatedBySupervisorId { get; set; }

        public string Title { get; set; }
        public string Description { get; set; }
        public string Requirements { get; set; }
        public string Location { get; set; }

        /// <summary>Which students may apply. Explore Opportunities (card R03)
        /// filters on these against the student's own College and Major.</summary>
        public string EligibleCollege { get; set; }
        public List<string> EligibleMajors { get; set; }

        public int TotalSeats { get; set; }
        public int FilledSeats { get; set; }

        public int DurationWeeks { get; set; }
        public long StartDate { get; set; }
        public long ApplicationDeadline { get; set; }

        public OpportunityStatus Status { get; set; }
        public long CreatedAt { get; set; }

        public Opportunity()
        {
            EligibleMajors = new List<string>();
            Status = OpportunityStatus.Draft;
            CreatedAt = Time.NowMs();
        }

        [ScriptIgnore]
        public int RemainingSeats
        {
            get
            {
                int left = TotalSeats - FilledSeats;
                return left < 0 ? 0 : left;
            }
        }

        /// <summary>Visible on Explore Opportunities only when this is true.</summary>
        [ScriptIgnore]
        public bool IsOpenForApplications
        {
            get
            {
                return Status == OpportunityStatus.Open
                       && RemainingSeats > 0
                       && (ApplicationDeadline <= 0 || !Time.IsPast(ApplicationDeadline));
            }
        }

        /// <summary>Eligibility check used by card R03.</summary>
        public bool IsEligible(Student student)
        {
            if (student == null) return false;
            if (!string.IsNullOrEmpty(EligibleCollege)
                && !string.Equals(EligibleCollege, student.College,
                                  System.StringComparison.OrdinalIgnoreCase))
            {
                return false;
            }
            if (EligibleMajors == null || EligibleMajors.Count == 0) return true;
            return EligibleMajors.Exists(m =>
                string.Equals(m, student.Major, System.StringComparison.OrdinalIgnoreCase));
        }
    }
}
