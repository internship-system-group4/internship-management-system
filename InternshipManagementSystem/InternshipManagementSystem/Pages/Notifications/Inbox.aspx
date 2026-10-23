<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Inbox.aspx.cs" Inherits="InternshipManagementSystem.Pages.Notifications.Inbox" Title="Notifications" %>
<%@ Register TagPrefix="uims" Namespace="InternshipManagementSystem.Layout" Assembly="InternshipManagementSystem" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="notice-intro"><span class="notice-eyebrow">STAY IN THE LOOP</span><h2>Your internship, up to date.</h2><p>Assignments, submissions, feedback and milestones — together in one place.</p></div>
    <uims:NotificationBell ID="InboxFeed" runat="server" Expanded="true" />
    <p class="notice-retention">Showing your latest 100 notifications. New activity refreshes automatically.</p>
</asp:Content>
