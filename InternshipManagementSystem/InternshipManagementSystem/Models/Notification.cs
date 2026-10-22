// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad (Trello card X02 - shared data model)
//  One message in a user's notification bell (top bar of every portal).
//  Add fields freely; never rename or delete one without telling the team.
// =============================================================================

using System;
using System.Web.Script.Serialization;
using InternshipManagementSystem.Common;

namespace InternshipManagementSystem.Models
{
    /// <summary>
    /// Stored at notifications/{recipientUid}/{id}. Keeping each person's
    /// notifications under their own UID means the bell needs one read and no
    /// index, and the database rules can let people read only their own.
    /// Create these through Services/NotificationService, not by hand.
    /// </summary>
    public class Notification
    {
        public string Id { get; set; }
        public string RecipientId { get; set; }

        /// <summary>Short category used for the icon: Task, Group, Application,
        /// Placement, Hours, Evaluation, Comment, Meeting, Opportunity, Completion.</summary>
        public string Type { get; set; }

        public string Title { get; set; }
        public string Message { get; set; }

        /// <summary>App-relative page to open, for example "~/Pages/Student/MyTasks.aspx".</summary>
        public string Link { get; set; }

        public bool IsRead { get; set; }
        public long CreatedAt { get; set; }

        [ScriptIgnore]
        public DateTime CreatedDate
        {
            get { return Time.FromUnixMs(CreatedAt); }
        }

        public Notification()
        {
            CreatedAt = Time.NowMs();
        }
    }
}
