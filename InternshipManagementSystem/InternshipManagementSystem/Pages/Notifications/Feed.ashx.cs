using System;
using System.Linq;
using System.Web;
using System.Web.SessionState;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.Notifications
{
    public class Feed : IHttpHandler, IRequiresSessionState
    {
        public bool IsReusable { get { return false; } }
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache);
            context.Response.Cache.SetNoStore();
            try
            {
                var current = SessionHelper.Current;
                var user = current == null ? null : new UserRepository().GetPerson(current.Id);
                if (user == null || !user.CanLogin() || user.MustChangePassword) { context.Response.StatusCode = 401; return; }
                SessionHelper.Refresh(user);
                var repository = new NotificationRepository();
                if (context.Request.HttpMethod == "POST")
                {
                    string csrf = context.Session["UIMS_NotificationCsrf"] as string;
                    if (string.IsNullOrEmpty(csrf) || context.Request.Headers["X-UIMS-CSRF"] != csrf)
                    { context.Response.StatusCode = 403; return; }
                    repository.MarkRead(context.Request.Form["id"] ?? "");
                }
                else if (context.Request.HttpMethod != "GET") { context.Response.StatusCode = 405; return; }
                var items = repository.GetMine();
                context.Response.Write(Json.Serialize(new { items = items.Select(n => new {
                    n.Id, n.Title, n.Detail, n.CreatedAt, n.IsRead,
                    Url = SafePage(n.Page) ? VirtualPathUtility.ToAbsolute("~/" + n.Page) : VirtualPathUtility.ToAbsolute("~/Pages/Notifications/Inbox.aspx")
                }), unread = items.Count(n => !n.IsRead) }));
            }
            catch (Exception ex)
            {
                Services.EmailNotificationService.LogFailure(ex);
                context.Response.StatusCode = 503;
                context.Response.TrySkipIisCustomErrors = true;
                context.Response.Write("{\"error\":\"Notifications are temporarily unavailable. Please try again.\"}");
            }
        }

        private static bool SafePage(string page)
        {
            return !string.IsNullOrEmpty(page) && page.StartsWith("Pages/", StringComparison.Ordinal) &&
                !page.Contains("..") && !page.Contains("\\") && !page.Contains(":") && !page.Contains("#") &&
                !page.Contains("\r") && !page.Contains("\n");
        }
    }
}
