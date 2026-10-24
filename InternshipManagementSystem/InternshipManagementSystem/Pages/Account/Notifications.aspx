<%@ Page Title="Notifications" Language="C#" MasterPageFile="~/Layout/Student.master" AutoEventWireup="true" CodeBehind="Notifications.aspx.cs" Inherits="InternshipManagementSystem.Pages.AccountArea.Notifications" %>
<%@ Import Namespace="InternshipManagementSystem.Layout" %>
<%@ Import Namespace="InternshipManagementSystem.Services" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server" />

<asp:Content ID="Main" ContentPlaceHolderID="MainContent" runat="server">
    <section class="uims-notify-page" aria-labelledby="notificationsHeading">
        <div class="uims-notify-page-head">
            <div>
                <h2 id="notificationsHeading"><%: L.T("Account.Notifications.Notifications") %></h2>
                <p><%: L.T("Shared.Notify.PageIntro") %></p>
            </div>
            <asp:Button ID="btnMarkAllRead" runat="server" Text="<%$ Resources:Shared, Notify.MarkAllRead %>" CssClass="btn btn-outline-secondary btn-sm"
                        OnClick="btnMarkAllRead_Click" CausesValidation="false"  data-ui-action="mark" data-loading-label="<%$ Resources:Shared, I18n.Updating %>" data-ui-validation="none"/>
        </div>

        <% if (Entries.Count > 0) { %>
        <div class="uims-notify-filters" role="group" aria-label="<%: L.T("Account.Notifications.Notifications") %>">
            <button type="button" class="uims-notify-filter" data-notify-filter="all" aria-pressed="true"><%: L.T("Shared.Notify.FilterAll") %> (<%: Entries.Count %>)</button>
            <button type="button" class="uims-notify-filter" data-notify-filter="unread" aria-pressed="false"><%: L.T("Shared.Notify.FilterUnread") %> (<%: UnreadCount %>)</button>
        </div>
        <% } %>

        <asp:Label ID="lblMessage" runat="server" CssClass="uims-notify-page-message" Visible="false" role="status" />

        <% if (Entries.Count == 0) { %>
            <p class="uims-notify-empty"><%: L.T("Account.Notifications.YouReAllCaughtUpNew") %></p>
        <% } else { %>
            <ul class="uims-notify-page-list">
            <% foreach (var item in Entries) { %>
                <li data-read="<%= item.IsRead ? "true" : "false" %>">
                    <a class="uims-notify-item<%= item.IsRead ? "" : " is-unread" %>" href="<%: OpenUrl(item) %>">
                        <span class="uims-notify-icon" data-type="<%: item.Type %>"><%= NotificationBell.IconSvg(item.Type) %></span>
                        <span class="uims-notify-text">
                            <span class="uims-notify-meta"><span class="uims-notify-type" data-type="<%: item.Type %>"><%: NotificationService.TypeLabel(item.Type) %></span><small><%: NotificationBell.TimeAgo(item.CreatedAt) %></small></span>
                            <strong><%: NotificationService.TitleOf(item) %></strong>
                            <span class="uims-notify-msg"><%: NotificationService.MessageOf(item) %></span>
                        </span>
                        <span class="uims-notify-go"><%: L.T("Shared.Notify.Open") %></span>
                    </a>
                </li>
            <% } %>
            </ul>
            <p class="uims-notify-empty" data-notify-none hidden><%: L.T("Shared.Notify.NoUnread") %></p>
        <% } %>
    </section>
    <script>
    (function () {
        var buttons = document.querySelectorAll('[data-notify-filter]');
        var rows = document.querySelectorAll('.uims-notify-page-list li');
        var none = document.querySelector('[data-notify-none]');
        buttons.forEach(function (button) {
            button.addEventListener('click', function () {
                var unreadOnly = button.getAttribute('data-notify-filter') === 'unread';
                var shown = 0;
                buttons.forEach(function (b) { b.setAttribute('aria-pressed', b === button ? 'true' : 'false'); });
                rows.forEach(function (row) {
                    var hide = unreadOnly && row.getAttribute('data-read') === 'true';
                    row.hidden = hide;
                    if (!hide) shown++;
                });
                if (none) none.hidden = shown > 0;
            });
        });
    }());
    </script>
</asp:Content>
