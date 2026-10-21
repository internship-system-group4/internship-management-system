// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad (Trello card X02 - shared data model)
//  A Contact Us message (cards D01-D03).
//  Add fields freely; never rename or delete one without telling the team.
// =============================================================================

using InternshipManagementSystem.Common;

namespace InternshipManagementSystem.Models
{
    public class ContactMessage
    {
        public string Id { get; set; }

        public string SenderName { get; set; }
        public string SenderEmail { get; set; }
        public string Subject { get; set; }
        public string Message { get; set; }

        public ContactMessageStatus Status { get; set; }
        public string ReviewedByCoordinatorId { get; set; }
        public long ReviewedAt { get; set; }

        public long SubmittedAt { get; set; }

        public ContactMessage()
        {
            Status = ContactMessageStatus.New;
            SubmittedAt = Time.NowMs();
        }
    }
}
