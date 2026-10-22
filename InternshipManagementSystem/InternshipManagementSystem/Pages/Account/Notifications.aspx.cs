// =============================================================================
//  Notifications
//  Owner : Ahmad
//
//  Every signed-in role can open this page. It lists the user's latest
//  notifications, marks them as read, and opens a notification's page
//  (Notifications.aspx?open={id}) - the bell in the top bar links here.
// =============================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.AccountArea
{
    public partial class Notifications : AuthenticatedPage
    {
        private const int PageSize = 100;

        protected List<Notification> Entries = new List<Notification>();
        protected int UnreadCount;
        private bool redirecting;

        // Show the page inside the signed-in person's own portal layout.
        protected override void OnPreInit(EventArgs e)
        {
            base.OnPreInit(e);
            if (CurrentUser == null) return;

            switch (CurrentUser.Role)
            {
                case UserRole.Student: MasterPageFile = "~/Layout/Student.master"; break;
                case UserRole.CompanySupervisor: MasterPageFile = "~/Layout/Company.master"; break;
                case UserRole.AcademicSupervisor: MasterPageFile = "~/Layout/Academic.master"; break;
                case UserRole.Coordinator: MasterPageFile = "~/Layout/Coordinator.master"; break;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            string openId = Request.QueryString["open"];
            if (!IsPostBack && !string.IsNullOrEmpty(openId))
            {
                OpenNotification(openId);
            }
        }

        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);
            if (!redirecting) LoadList();
        }

        /// <summary>Marks one notification read, then goes to the page it points to.</summary>
        private void OpenNotification(string id)
        {
            string target = null;
            try
            {
                NotificationRepository repository = new NotificationRepository();
                Notification item = repository.GetById(CurrentUser.Id, id);
                if (item != null)
                {
                    if (!item.IsRead) repository.MarkRead(CurrentUser.Id, id);
                    target = item.Link;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceWarning("Could not open notification: " + ex.Message);
            }

            // Only follow links inside this application.
            if (IsLocalLink(target))
            {
                redirecting = true;
                Response.Redirect(ResolveUrl(target), false);
                Context.ApplicationInstance.CompleteRequest();
            }
        }

        private static bool IsLocalLink(string link)
        {
            return !string.IsNullOrEmpty(link) && link.StartsWith("~/", StringComparison.Ordinal)
                && !link.Contains("//") && !link.Contains("\\");
        }

        protected void btnMarkAllRead_Click(object sender, EventArgs e)
        {
            try
            {
                new NotificationRepository().MarkAllRead(CurrentUser.Id);
                ShowMessage("All notifications are marked as read.");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceWarning("Could not mark notifications read: " + ex.Message);
                ShowMessage("Could not update notifications. Please try again.");
            }
        }

        private void LoadList()
        {
            try
            {
                Entries = new NotificationRepository().GetLatest(CurrentUser.Id, PageSize);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceWarning("Could not load notifications: " + ex.Message);
                Entries = new List<Notification>();
                ShowMessage("Notifications are unavailable right now.");
            }
            UnreadCount = Entries.Count(n => !n.IsRead);
            btnMarkAllRead.Visible = UnreadCount > 0;
        }

        private void ShowMessage(string text)
        {
            lblMessage.Text = HttpUtility.HtmlEncode(text);
            lblMessage.Visible = true;
        }

        protected string OpenUrl(Notification item)
        {
            return ResolveUrl("~/Pages/Account/Notifications.aspx?open=" + HttpUtility.UrlEncode(item.Id));
        }
    }
}
