using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Layout
{
    public class NotificationBell : WebControl
    {
        public bool Expanded { get; set; }

        protected override void Render(HtmlTextWriter writer)
        {
            if (SessionHelper.Current == null) return;
            var session = Context.Session;
            if (session["UIMS_NotificationCsrf"] == null)
                session["UIMS_NotificationCsrf"] = Guid.NewGuid().ToString("N");
            string attrs = " data-notifications data-endpoint='" + Page.ResolveUrl("~/Pages/Notifications/Feed.ashx") +
                "' data-token='" + session["UIMS_NotificationCsrf"] + "'";
            string icon = "<svg width='21' height='21' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='1.7' aria-hidden='true'><path d='M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9M10 21h4'/></svg>";
            writer.Write(Expanded ? "<section class='notice-center'" + attrs + ">" : "<details class='notice-bell'" + attrs + ">");
            if (!Expanded)
                writer.Write("<summary aria-label='Notifications'>" + icon + "<span data-notice-count class='notice-count' hidden>0</span></summary>");
            writer.Write("<div class='notice-panel'><header class='notice-header'><div><span class='notice-eyebrow'>YOUR WORKSPACE</span><h2>Notifications <span data-notice-total></span></h2></div>" +
                "<button type='button' class='notice-mark' data-notice-mark>Mark all read</button></header>" +
                "<div class='notice-filters' role='group' aria-label='Notification filter'><button type='button' data-notice-filter='all' aria-pressed='true'>All activity</button>" +
                "<button type='button' data-notice-filter='unread' aria-pressed='false'>Unread</button><span data-notice-state role='status' aria-live='polite'></span></div>" +
                "<div class='notice-list' data-notice-list><p class='notice-empty'>Loading your activity…</p></div>");
            if (!Expanded) writer.Write("<footer class='notice-footer'><a href='" + Page.ResolveUrl("~/Pages/Notifications/Inbox.aspx") + "'>View all notifications <span aria-hidden='true'>↗</span></a></footer>");
            writer.Write(Expanded ? "</div></section>" : "</div></details>");
        }
    }
}
