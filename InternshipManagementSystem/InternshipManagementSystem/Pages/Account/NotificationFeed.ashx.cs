// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad
//  Live notification feed for the top-bar bell (Assets/js/notifications.js).
//
//  GET  NotificationFeed.ashx                -> latest notifications as JSON
//  POST NotificationFeed.ashx?action=readAll -> marks every one as read
//
//  The bell asks every ~20 seconds, so a company supervisor sees a new
//  application (and a toast pops up) without refreshing the page.
// =============================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.SessionState;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Layout;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;
using InternshipManagementSystem.Services;

namespace InternshipManagementSystem.Pages.AccountArea
{
    public class NotificationFeed : IHttpHandler, IRequiresSessionState
    {
        public bool IsReusable { get { return false; } }

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache);
            context.Response.Cache.SetNoStore();

            Person user = SessionHelper.Current;
            if (user == null)
            {
                Reply(context, 401, new { ok = false, signedOut = true });
                return;
            }

            try
            {
                if (context.Request.HttpMethod == "POST")
                {
                    // A custom header cannot be sent from another site without
                    // permission, so this blocks cross-site form posts.
                    if (context.Request.Headers["X-UIMS-Request"] != "1")
                    {
                        Reply(context, 400, new { ok = false });
                        return;
                    }
                    if (context.Request.QueryString["action"] == "readAll")
                        new NotificationRepository().MarkAllRead(user.Id);
                }

                // Always ask Firebase (not the few-seconds read cache), so notifications
                // saved by another running copy of the app show up too.
                string path = Constants.Paths.Notifications + "/" + user.Id;
                FirebaseContext.Reload(FirebaseRead.Last(path, NotificationBell.CountWindow));
                List<Notification> recent = new NotificationRepository().GetLatest(user.Id, NotificationBell.CountWindow);

                Reply(context, 200, new
                {
                    ok = true,
                    unread = recent.Count(n => !n.IsRead),
                    warning = user.Role == UserRole.Coordinator && NotificationService.BlockedByRules
                        ? L.T("Shared.Notify.SomeNotDelivered") : null,
                    items = recent.Take(NotificationBell.DropdownSize).Select(n => new
                    {
                        id = n.Id,
                        type = n.Type ?? "",
                        typeLabel = NotificationService.TypeLabel(n.Type),
                        title = NotificationService.TitleOf(n),
                        message = NotificationService.MessageOf(n),
                        time = NotificationBell.TimeAgo(n.CreatedAt),
                        createdAt = n.CreatedAt,
                        read = n.IsRead,
                        url = VirtualPathUtility.ToAbsolute("~/Pages/Account/Notifications.aspx") + "?open=" + HttpUtility.UrlEncode(n.Id),
                        icon = NotificationBell.IconSvg(n.Type)
                    }).ToList()
                });
            }
            catch (FirebaseAuthExpiredException)
            {
                Reply(context, 401, new { ok = false, signedOut = true });
            }
            catch (Exception ex)
            {
                bool blocked = ex.Message.IndexOf("Permission denied", StringComparison.OrdinalIgnoreCase) >= 0;
                System.Diagnostics.Trace.TraceError("[UIMS notifications] Feed failed for {0}: {1}", user.Id, ex.Message);
                Reply(context, 200, new
                {
                    ok = false,
                    error = blocked ? L.T("Shared.Notify.BlockedByRules") : L.T("Shared.NotificationBell.NotificationsAreUnavailableRightNow")
                });
            }
        }

        private static void Reply(HttpContext context, int status, object body)
        {
            context.Response.StatusCode = status;
            context.Response.Write(new JavaScriptSerializer().Serialize(body));
        }
    }
}
