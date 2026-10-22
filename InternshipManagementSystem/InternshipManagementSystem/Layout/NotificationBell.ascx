<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="NotificationBell.ascx.cs" Inherits="InternshipManagementSystem.Layout.NotificationBell" %>
<%-- Notification bell in the top bar of every portal master. The list is
     loaded in NotificationBell.ascx.cs; clicking an item opens it through
     Pages/Account/Notifications.aspx, which marks it read. --%>
<div class="uims-notify dropdown">
    <button type="button" class="uims-notify-button" data-bs-toggle="dropdown" data-bs-display="static" aria-expanded="false"
            aria-label="<%: UnreadCount > 0 ? "Notifications, " + UnreadCount + " unread" : "Notifications" %>" title="Notifications">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M6 16v-5a6 6 0 0 1 12 0v5l2 2H4z"/><path d="M10 20a2 2 0 0 0 4 0"/></svg>
        <% if (UnreadCount > 0) { %><span class="uims-notify-badge" aria-hidden="true"><%: BadgeText %></span><% } %>
    </button>
    <div class="dropdown-menu dropdown-menu-end uims-notify-menu">
        <div class="uims-notify-head">
            <strong>Notifications</strong>
            <% if (UnreadCount > 0) { %><span><%: UnreadCount %> new</span><% } %>
        </div>
        <div class="uims-notify-list">
        <% if (!Loaded) { %>
            <p class="uims-notify-empty">Notifications are unavailable right now.</p>
        <% } else if (Items.Count == 0) { %>
            <p class="uims-notify-empty">You're all caught up. New tasks, decisions and updates will appear here.</p>
        <% } else { foreach (var item in Items) { %>
            <a class="uims-notify-item<%= item.IsRead ? "" : " is-unread" %>" href="<%: OpenUrl(item) %>">
                <span class="uims-notify-icon" data-type="<%: item.Type %>"><%= IconSvg(item.Type) %></span>
                <span class="uims-notify-text">
                    <strong><%: item.Title %></strong>
                    <span><%: item.Message %></span>
                    <small><%: TimeAgo(item.CreatedAt) %></small>
                </span>
            </a>
        <% } } %>
        </div>
        <a class="uims-notify-all" href="<%: ResolveUrl("~/Pages/Account/Notifications.aspx") %>">View all notifications</a>
    </div>
</div>
