// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad
//  Notifications shown in the top-bar bell of every portal.
// =============================================================================

using System.Collections.Generic;
using System.Linq;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Data
{
    /// <summary>
    /// Each person has their own list: notifications/{uid}/{id}. That is why
    /// this class does not extend RepositoryBase - the path changes per user.
    /// To send a notification, call Services/NotificationService instead.
    /// </summary>
    public class NotificationRepository
    {
        private static string UserPath(string userId)
        {
            return Constants.Paths.Notifications + "/" + userId;
        }

        /// <summary>Saves a new notification and returns its id.</summary>
        public string Add(Notification notification)
        {
            if (notification == null || string.IsNullOrEmpty(notification.RecipientId)) return null;

            // One request only: the Id is not stored inside the record because
            // every read below fills it in from the key. That keeps sending to a
            // whole group of students fast.
            string id = FirebaseContext.Push(UserPath(notification.RecipientId), notification);
            notification.Id = id;
            return id;
        }

        /// <summary>The newest notifications first.</summary>
        public List<Notification> GetLatest(string userId, int count)
        {
            List<Notification> list = new List<Notification>();
            if (string.IsNullOrEmpty(userId)) return list;

            string json = FirebaseContext.GetLast(UserPath(userId), count);
            if (string.IsNullOrWhiteSpace(json) || json == "null") return list;

            Dictionary<string, object> map = Json.ToMap(json);
            foreach (KeyValuePair<string, object> pair in map)
            {
                Notification item = Json.Deserialize<Notification>(Json.Serialize(pair.Value));
                if (item == null) continue;
                item.Id = pair.Key;
                list.Add(item);
            }
            return list.OrderByDescending(n => n.CreatedAt).ToList();
        }

        public Notification GetById(string userId, string id)
        {
            if (string.IsNullOrEmpty(userId) || string.IsNullOrEmpty(id)) return null;
            Notification item = Json.Deserialize<Notification>(FirebaseContext.Get(UserPath(userId) + "/" + id));
            if (item != null) item.Id = id;
            return item;
        }

        public void MarkRead(string userId, string id)
        {
            if (string.IsNullOrEmpty(userId) || string.IsNullOrEmpty(id)) return;
            FirebaseContext.Patch(UserPath(userId) + "/" + id,
                new Dictionary<string, object> { { "IsRead", true } });
        }

        /// <summary>Marks every unread notification as read in one request.</summary>
        public void MarkAllRead(string userId)
        {
            if (string.IsNullOrEmpty(userId)) return;

            Dictionary<string, object> changes = new Dictionary<string, object>();
            foreach (Notification item in GetLatest(userId, 200))
            {
                if (!item.IsRead) changes[item.Id + "/IsRead"] = true;
            }
            if (changes.Count > 0) FirebaseContext.Patch(UserPath(userId), changes);
        }
    }
}
