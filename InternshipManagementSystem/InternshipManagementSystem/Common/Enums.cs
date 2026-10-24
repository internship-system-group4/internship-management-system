// =============================================================================
//  University Internship Management System (UIMS)  -  Group 4
//  Every status value used across the system.
//  Owner: Ahmad  (Trello card X02 - Shared Firebase Data Structure)
//  Do not edit without telling the owner: every page in the system depends on
//  these types. Add new fields, never rename or remove existing ones.
// =============================================================================

namespace InternshipManagementSystem.Common
{
    /// <summary>The four roles defined by the project requirements.</summary>
    public enum UserRole
    {
        Student = 1,
        CompanySupervisor = 2,
        AcademicSupervisor = 3,
        Coordinator = 4
    }

    public enum OpportunityStatus
    {
        Draft = 0,
        Open = 1,
        Closed = 2
    }

    public enum ApplicationStatus
    {
        Pending = 0,
        Accepted = 1,
        Rejected = 2,
        Withdrawn = 3
    }

    /// <summary>A placement is a student's one confirmed internship.</summary>
    public enum PlacementStatus
    {
        Offered = 0,
        Confirmed = 1,
        Active = 2,
        AwaitingCompletion = 3,
        Completed = 4,
        Cancelled = 5
    }

    /// <summary>Named InternshipTaskStatus on purpose: TaskStatus collides with
    /// System.Threading.Tasks.TaskStatus.</summary>
    public enum InternshipTaskStatus
    {
        Assigned = 0,
        Submitted = 1,
        UnderReview = 2,
        RevisionRequested = 3,
        Resubmitted = 4,
        Graded = 5
    }

    public enum SubmissionStatus
    {
        Submitted = 0,
        UnderReview = 1,
        RevisionRequested = 2,
        Accepted = 3
    }

    /// <summary>Business rule: finishing a task never approves hours by itself.
    /// Hours start as Reported and only a supervisor moves them to Approved.</summary>
    public enum HoursStatus
    {
        Reported = 0,
        Approved = 1,
        Rejected = 2
    }

    public enum CompletionStatus
    {
        NotReady = 0,
        AwaitingCompanyEvaluation = 1,
        AwaitingAcademicEvaluation = 2,
        UnderCoordinatorReview = 3,
        Approved = 4,
        Rejected = 5,
        NeedsCorrections = 6
    }

    public enum ContactMessageStatus
    {
        New = 0,
        Reviewed = 1
    }

    public enum MeetingStatus
    {
        Scheduled = 0,
        Completed = 1,
        Cancelled = 2
    }
}
