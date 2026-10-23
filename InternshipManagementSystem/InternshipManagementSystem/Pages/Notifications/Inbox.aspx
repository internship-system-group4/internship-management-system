<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Inbox.aspx.cs" Inherits="InternshipManagementSystem.Pages.Notifications.Inbox" Title="Notifications" %>
<%@ Register TagPrefix="uims" Namespace="InternshipManagementSystem.Layout" Assembly="InternshipManagementSystem" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="notice-intro"><span class="notice-eyebrow"><%: InternshipManagementSystem.Common.L.IsArabic ? "ابقَ على اطلاع" : "STAY IN THE LOOP" %></span><h2><%: InternshipManagementSystem.Common.L.IsArabic ? "كل جديد في رحلتك التدريبية." : "Your internship, up to date." %></h2><p><%: InternshipManagementSystem.Common.L.IsArabic ? "المهام والتسليمات والملاحظات وأهم المستجدات، في مكان واحد." : "Assignments, submissions, feedback and milestones — together in one place." %></p></div>
    <uims:ActivityBell ID="InboxFeed" runat="server" Expanded="true" />
    <p class="notice-retention"><%: InternshipManagementSystem.Common.L.IsArabic ? "نعرض آخر 100 إشعار. يتم تحديث النشاطات تلقائيًا." : "Showing your latest 100 notifications. New activity refreshes automatically." %></p>
</asp:Content>
