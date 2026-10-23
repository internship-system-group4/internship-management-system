using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Data
{
    // A recipient's inbox is a separate node; never read all recipients' data.
    public class NotificationRepository
    {
        private static string Path(string uid)
        {
            if (string.IsNullOrEmpty(uid) || !Regex.IsMatch(uid, @"^[A-Za-z0-9_-]+$"))
                throw new InvalidOperationException("Invalid notification recipient.");
            return "notifications/" + uid;
        }

        public void Add(UserNotification item)
        {
            item.Id = Guid.NewGuid().ToString("N");
            FirebaseContext.Put(Path(item.RecipientId) + "/" + item.Id, item);
        }

        internal void SetEmailStatus(UserNotification item, string status)
        {
            FirebaseContext.Patch(Path(item.RecipientId) + "/" + item.Id,
                new Dictionary<string, object> { { "EmailStatus", status } });
        }

        public List<UserNotification> GetMine()
        {
            var user = SessionHelper.Current;
            if (user == null || !user.IsActive) throw new UnauthorizedAccessException();
            var map = Json.Deserialize<Dictionary<string, UserNotification>>(FirebaseContext.GetRecent(Path(user.Id), 100));
            if (map == null) return new List<UserNotification>();
            return map.Where(p => p.Value != null && p.Value.RecipientId == user.Id)
                .Select(p => { p.Value.Id = p.Key; return p.Value; })
                .OrderByDescending(n => n.CreatedAt).ThenByDescending(n => n.Id).ToList();
        }

        public void MarkRead(string id)
        {
            var mine = GetMine();
            var changes = new Dictionary<string, object>();
            foreach (var item in mine.Where(n => !n.IsRead && (id == "all" || n.Id == id)))
                changes[item.Id + "/IsRead"] = true;
            if (changes.Count > 0) FirebaseContext.Patch(Path(SessionHelper.Current.Id), changes);
        }
    }
}
