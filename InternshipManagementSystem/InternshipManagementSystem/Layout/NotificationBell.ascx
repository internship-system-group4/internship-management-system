<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="NotificationBell.ascx.cs" Inherits="InternshipManagementSystem.Layout.NotificationBell" %>
<%@ Import Namespace="InternshipManagementSystem.Services" %>
<%-- Notification bell in the top bar of every portal master. The first list
     is rendered here (NotificationBell.ascx.cs); Assets/js/notifications.js then
     refreshes it every ~20 s from Pages/Account/NotificationFeed.ashx and shows a
     toast for anything new. Clicking an item opens it through
     Pages/Account/Notifications.aspx?open={id}, which marks it read. --%>
<div class="uims-notify dropdown" data-notify-feed="<%: ResolveUrl("~/Pages/Account/NotificationFeed.ashx") %>"
     data-notify-all="<%: ResolveUrl("~/Pages/Account/Notifications.aspx") %>"
     data-notify-user="<%: UserKey %>"
     data-notify-empty="<%: L.T("Shared.NotificationBell.YouReAllCaughtUpNew") %>">
    <button type="button" class="uims-notify-button" data-bs-toggle="dropdown" data-bs-display="static" data-bs-auto-close="outside" aria-expanded="false"
            aria-label="<%: UnreadCount > 0 ? L.F("Shared.Js.NotifyBellLabel", UnreadCount) : L.T("Shared.NotificationBell.Notifications") %>" title="<%: L.T("Shared.NotificationBell.Notifications") %>">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M6 16v-5a6 6 0 0 1 12 0v5l2 2H4z"/><path d="M10 20a2 2 0 0 0 4 0"/></svg>
        <span class="uims-notify-badge" aria-hidden="true"<%= UnreadCount > 0 ? "" : " hidden" %>><%: BadgeText %></span>
    </button>
    <div class="dropdown-menu dropdown-menu-end uims-notify-menu">
        <div class="uims-notify-head">
            <div class="uims-notify-head-title">
                <strong><%: L.T("Shared.NotificationBell.Notifications") %></strong>
                <span class="uims-notify-count"<%= UnreadCount > 0 ? "" : " hidden" %>><%: L.F("Shared.Js.NotifyUnread", UnreadCount) %></span>
            </div>
            <button type="button" class="uims-notify-readall"<%= UnreadCount > 0 ? "" : " hidden" %>><%: L.T("Shared.Notify.MarkAllRead") %></button>
        </div>
        <p class="uims-notify-warning" role="status"<%= string.IsNullOrEmpty(Warning) ? " hidden" : "" %>><%: Warning %></p>
        <div class="uims-notify-list" aria-live="polite">
        <% if (!Loaded) { %>
            <p class="uims-notify-empty"><%: LoadError %></p>
        <% } else if (Items.Count == 0) { %>
            <p class="uims-notify-empty"><%: L.T("Shared.NotificationBell.YouReAllCaughtUpNew") %></p>
        <% } else { foreach (var item in Items) { %>
            <a class="uims-notify-item<%= item.IsRead ? "" : " is-unread" %>" href="<%: OpenUrl(item) %>" data-created="<%= item.CreatedAt %>">
                <span class="uims-notify-icon" data-type="<%: item.Type %>"><%= IconSvg(item.Type) %></span>
                <span class="uims-notify-text">
                    <span class="uims-notify-meta"><span class="uims-notify-type" data-type="<%: item.Type %>"><%: NotificationService.TypeLabel(item.Type) %></span><small><%: TimeAgo(item.CreatedAt) %></small></span>
                    <strong><%: NotificationService.TitleOf(item) %></strong>
                    <span class="uims-notify-msg"><%: NotificationService.MessageOf(item) %></span>
                </span>
            </a>
        <% } } %>
        </div>
        <a class="uims-notify-all" href="<%: ResolveUrl("~/Pages/Account/Notifications.aspx") %>"><%: L.T("Shared.NotificationBell.ViewAllNotifications") %></a>
    </div>
</div>
