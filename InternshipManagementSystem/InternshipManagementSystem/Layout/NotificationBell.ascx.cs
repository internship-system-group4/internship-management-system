// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad   (shared layout - tell the team before editing)
//  The notification bell shown in the top bar of all four portals.
// =============================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Layout
{
    public partial class NotificationBell : UserControl
    {
        /// <summary>How many recent notifications the dropdown shows.</summary>
        public const int DropdownSize = 8;

        /// <summary>How many recent notifications are counted for the badge.</summary>
        public const int CountWindow = 30;

        protected List<Notification> Items = new List<Notification>();
        protected int UnreadCount;
        protected bool Loaded;
        protected string LoadError;

        /// <summary>Lets the script remember, per person, which notifications already popped up.</summary>
        protected string UserKey;

        /// <summary>Shown to coordinators when Firebase refused a notification.</summary>
        protected string Warning;

        protected string BadgeText
        {
            get { return UnreadCount > 9 ? "9+" : UnreadCount.ToString(); }
        }

        // PreRender runs after the page's button handlers, so a notification
        // created or read during this request already shows correctly.
        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);

            Person user = SessionHelper.Current;
            if (user == null || Response.IsRequestBeingRedirected)
            {
                Visible = false;
                return;
            }

            UserKey = user.Id;
            try
            {
                List<Notification> recent = new NotificationRepository().GetLatest(user.Id, CountWindow);
                UnreadCount = recent.Count(n => !n.IsRead);
                Items = recent.Take(DropdownSize).ToList();
                Loaded = true;
            }
            catch (Exception ex)
            {
                // Usually the database rules for "notifications" are missing.
                // The page must still work, so only the bell is affected.
                System.Diagnostics.Trace.TraceError("[UIMS notifications] Could not load notifications: " + ex.Message);
                Loaded = false;
                LoadError = ex.Message.IndexOf("Permission denied", StringComparison.OrdinalIgnoreCase) >= 0
                    ? L.T("Shared.Notify.BlockedByRules")
                    : L.T("Shared.NotificationBell.NotificationsAreUnavailableRightNow");
            }

            if (user.Role == UserRole.Coordinator && Services.NotificationService.BlockedByRules)
                Warning = L.T("Shared.Notify.SomeNotDelivered");
        }

        protected string OpenUrl(Notification item)
        {
            return ResolveUrl("~/Pages/Account/Notifications.aspx?open=" + HttpUtility.UrlEncode(item.Id));
        }

        // ------------------------------------------------------------------
        //  Shared helpers - the full Notifications page uses these too.
        // ------------------------------------------------------------------

        /// <summary>"Just now", "5 min ago", "3 h ago", "Yesterday" or a date.</summary>
        public static string TimeAgo(long createdAt)
        {
            if (createdAt <= 0) return "";
            TimeSpan age = TimeSpan.FromMilliseconds(Math.Max(0, Time.NowMs() - createdAt));
            if (age.TotalMinutes < 1) return L.T("Shared.NotificationBell.JustNow");
            if (age.TotalHours < 1) return L.F("Shared.Notify.MinutesAgo", (int)age.TotalMinutes);
            if (age.TotalDays < 1) return L.F("Shared.Notify.HoursAgo", (int)age.TotalHours);
            if (age.TotalDays < 2) return L.T("Shared.Notify.Yesterday");
            return Time.DisplayDate(createdAt);
        }

        /// <summary>Icon for a notification type. Returns fixed markup only, never user text.</summary>
        public static string IconSvg(string type)
        {
            string path;
            switch (type)
            {
                case "Task": path = "<rect x=\"5\" y=\"4\" width=\"14\" height=\"17\" rx=\"2\"/><path d=\"M9 3h6v4H9zM9 13l2 2 4-4\"/>"; break;
                case "Group": path = "<circle cx=\"9\" cy=\"8\" r=\"3.5\"/><path d=\"M2.5 20v-1a6.5 6.5 0 0 1 13 0v1M16 4.5a3.5 3.5 0 0 1 0 7M18 14a6 6 0 0 1 3.5 5.5V20\"/>"; break;
                case "Application": path = "<path d=\"M6 3h8l4 4v14H6zM14 3v5h4M9 12h6M9 16h6\"/>"; break;
                case "Placement": path = "<rect x=\"3\" y=\"7\" width=\"18\" height=\"13\" rx=\"2\"/><path d=\"M9 7V4h6v3M3 13h18\"/>"; break;
                case "Hours": path = "<circle cx=\"12\" cy=\"12\" r=\"9\"/><path d=\"M12 7v5l3 2\"/>"; break;
                case "Evaluation": path = "<path d=\"M4 3v17h17M8 15l4-5 4 2 5-6\"/>"; break;
                case "Comment": path = "<path d=\"M4 5h16v11H9l-5 4z\"/>"; break;
                case "Meeting": path = "<rect x=\"3\" y=\"5\" width=\"18\" height=\"16\" rx=\"2\"/><path d=\"M7 3v4M17 3v4M3 11h18\"/>"; break;
                case "Opportunity": path = "<circle cx=\"10.5\" cy=\"10.5\" r=\"6.5\"/><path d=\"m16 16 5 5\"/>"; break;
                case "Account": path = "<circle cx=\"12\" cy=\"8\" r=\"4\"/><path d=\"M4 21v-1a8 8 0 0 1 16 0v1\"/>"; break;
                case "Completion": path = "<circle cx=\"12\" cy=\"9\" r=\"6\"/><path d=\"M8.5 14 7 21l5-3 5 3-1.5-7\"/>"; break;
                default: path = "<path d=\"M6 16v-5a6 6 0 0 1 12 0v5l2 2H4z\"/><path d=\"M10 20a2 2 0 0 0 4 0\"/>"; break;
            }
            return "<svg viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"1.6\" " +
                   "stroke-linecap=\"round\" stroke-linejoin=\"round\" aria-hidden=\"true\">" + path + "</svg>";
        }
    }
}
