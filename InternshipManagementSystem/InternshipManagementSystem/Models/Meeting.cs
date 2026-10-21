// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad (Trello card X02 - shared data model)
//  OPTIONAL - a scheduled Zoom meeting (cards F08-F10).
//  Add fields freely; never rename or delete one without telling the team.
// =============================================================================

using System.Collections.Generic;
using InternshipManagementSystem.Common;

namespace InternshipManagementSystem.Models
{
    /// <summary>
    /// Optional feature. Scope note from the plan: UIMS stores a Zoom join link
    /// that someone pasted in - it does not create meetings through the Zoom
    /// API. Do not let this block any core card.
    /// </summary>
    public class Meeting
    {
        public string Id { get; set; }

        public string Title { get; set; }
        public string Agenda { get; set; }

        public string CreatedById { get; set; }
        public string PlacementId { get; set; }

        /// <summary>Person ids allowed to see this meeting. Card F10 enforces
        /// access on the back end against this list.</summary>
        public List<string> ParticipantIds { get; set; }

        public long ScheduledAt { get; set; }
        public int DurationMinutes { get; set; }

        public string JoinUrl { get; set; }

        public MeetingStatus Status { get; set; }
        public long CreatedAt { get; set; }

        public Meeting()
        {
            ParticipantIds = new List<string>();
            Status = MeetingStatus.Scheduled;
            DurationMinutes = 30;
            CreatedAt = Time.NowMs();
        }

        public bool CanBeViewedBy(string personId)
        {
            return !string.IsNullOrEmpty(personId)
                   && (personId == CreatedById
                       || (ParticipantIds != null && ParticipantIds.Contains(personId)));
        }
    }
}
