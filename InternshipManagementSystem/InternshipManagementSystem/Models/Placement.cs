// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad (Trello card X02 - shared data model)
//  THE central entity: one student's confirmed internship.
//  Add fields freely; never rename or delete one without telling the team.
// =============================================================================

using System.Web.Script.Serialization;
using InternshipManagementSystem.Common;

namespace InternshipManagementSystem.Models
{
    /// <summary>
    /// Read this before building any page that deals with tasks, evaluations or
    /// hours.
    ///
    /// A Placement is created when a student confirms an accepted offer. Tasks,
    /// submissions, training hours, both final evaluations and the completion
    /// record all hang off PlacementId - NOT off ApplicationId and NOT off
    /// StudentId alone. A student has many applications but at most one
    /// placement, so anchoring on the placement is what keeps the one-internship
    /// rule true throughout the system.
    /// </summary>
    public class Placement
    {

      
        public int EvalTech { get; set; }
        public int EvalWork { get; set; }
        public int EvalProf { get; set; }
        public int EvalComm { get; set; }
        public int ActualHours { get; set; }
        public string EvalPerformance { get; set; }
        public string CompanyRecommendation { get; set; }
        public string EvalStrengths { get; set; }
        public string EvalImprovements { get; set; }


        public string Id { get; set; }

        public string StudentId { get; set; }
        public string StudentName { get; set; }

        public string ApplicationId { get; set; }
        public string OpportunityId { get; set; }
        public string OpportunityTitle { get; set; }

        public string CompanyId { get; set; }
        public string CompanyName { get; set; }
        public string CompanySupervisorId { get; set; }
        public string CompanySupervisorName { get; set; }

        /// <summary>Copied from the student's group assignment so the academic
        /// supervisor's pages (cards S01, S02) need one read, not three.</summary>
        public string AcademicSupervisorId { get; set; }

        public long StartDate { get; set; }
        public long EndDate { get; set; }

        public int RequiredHours { get; set; }
        public int ApprovedHours { get; set; }

        public PlacementStatus Status { get; set; }
        public long ConfirmedAt { get; set; }

        /// <summary>"Local" (field training in Jordan) or "International"
        /// (German Year internship). Optional: older placements have no value
        /// and are treated as local. See Common/InternshipRequirements.cs.</summary>
        public string InternshipType { get; set; }

        public Placement()
        {
            Status = PlacementStatus.Confirmed;
            ConfirmedAt = Time.NowMs();
        }

        [ScriptIgnore]
        public bool HoursRequirementMet
        {
            get { return ApprovedHours >= InternshipRules.RequiredHours(RequiredHours, 0); }
        }
    }
}
