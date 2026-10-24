<%@ Page Title="Notifications" Language="C#" MasterPageFile="~/Layout/Student.master" AutoEventWireup="true" CodeBehind="Notifications.aspx.cs" Inherits="InternshipManagementSystem.Pages.AccountArea.Notifications" %>
<%@ Import Namespace="InternshipManagementSystem.Layout" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server" />

<asp:Content ID="Main" ContentPlaceHolderID="MainContent" runat="server">
    <section class="uims-notify-page" aria-labelledby="notificationsHeading">
        <div class="uims-notify-page-head">
            <div>
                <h2 id="notificationsHeading"><%: L.T("Account.Notifications.Notifications") %></h2>
                <p><%: UnreadCount == 0 ? "No unread notifications." : UnreadCount + (UnreadCount == 1 ? " unread notification." : " unread notifications.") %></p>
            </div>
            <asp:Button ID="btnMarkAllRead" runat="server" Text="<%$ Resources:Account, Notifications.MarkAllAsRead %>" CssClass="btn btn-outline-secondary btn-sm"
                        OnClick="btnMarkAllRead_Click" CausesValidation="false"  data-ui-action="mark" data-loading-label="<%$ Resources:Shared, I18n.Updating %>" data-ui-validation="none"/>
        </div>

        <asp:Label ID="lblMessage" runat="server" CssClass="uims-notify-page-message" Visible="false" role="status" />

        <% if (Entries.Count == 0) { %>
            <p class="uims-notify-empty"><%: L.T("Account.Notifications.YouReAllCaughtUpNew") %></p>
        <% } else { %>
            <ul class="uims-notify-page-list">
            <% foreach (var item in Entries) { %>
                <li>
                    <a class="uims-notify-item<%= item.IsRead ? "" : " is-unread" %>" href="<%: OpenUrl(item) %>">
                        <span class="uims-notify-icon" data-type="<%: item.Type %>"><%= NotificationBell.IconSvg(item.Type) %></span>
                        <span class="uims-notify-text">
                            <strong><%: item.Title %></strong>
                            <span><%: item.Message %></span>
                            <small><%: NotificationBell.TimeAgo(item.CreatedAt) %><%= item.IsRead ? "" : " &middot; <em>New</em>" %></small>
                        </span>
                    </a>
                </li>
            <% } %>
            </ul>
        <% } %>
    </section>
</asp:Content>
