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
            item.Message = item.Detail;
            item.Link = "~/" + item.Page;
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
                .Select(p => {
                    p.Value.Id = p.Key;
                    p.Value.Detail = p.Value.Detail ?? p.Value.Message;
                    p.Value.Page = p.Value.Page ?? (p.Value.Link ?? "").TrimStart('~', '/');
                    return p.Value;
                })
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

        // Compatibility for existing portal controls and bookmarked notification links.
        public List<Notification> GetLatest(string userId, int count)
        {
            RequireMine(userId);
            return GetMine().Take(Math.Max(0, Math.Min(100, count))).Select(n => new Notification {
                Id = n.Id, RecipientId = n.RecipientId, Title = n.Title, Message = n.Detail,
                Link = "~/" + n.Page, IsRead = n.IsRead, CreatedAt = n.CreatedAt
            }).ToList();
        }
        public Notification GetById(string userId, string id) { return GetLatest(userId, 100).FirstOrDefault(n => n.Id == id); }
        public void MarkRead(string userId, string id) { RequireMine(userId); MarkRead(id); }
        public void MarkAllRead(string userId) { RequireMine(userId); MarkRead("all"); }
        private static void RequireMine(string id)
        {
            if (SessionHelper.Current == null || SessionHelper.Current.Id != id) throw new UnauthorizedAccessException();
        }
    }
}
