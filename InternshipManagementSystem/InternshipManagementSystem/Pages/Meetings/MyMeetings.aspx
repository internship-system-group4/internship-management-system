<%@ Page Language="C#" MasterPageFile="~/Layout/Public.master" AutoEventWireup="true" CodeBehind="MyMeetings.aspx.cs" Inherits="InternshipManagementSystem.Pages.MeetingsArea.MyMeetings" Title="My Meetings" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

    <div class="container py-4" style="max-width:950px">
        <div class="d-flex justify-content-between align-items-center mb-3"><h1 class="h3 mb-0">My meetings</h1><a class="btn btn-primary" href="Schedule.aspx">Schedule meeting</a></div>
        <asp:Label ID="lblMessage" runat="server" Visible="false" role="alert" />
        <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="alert alert-info">No meetings are scheduled for you yet.</asp:Panel>
        <asp:Repeater ID="rptMeetings" runat="server">
            <ItemTemplate>
                <div class="card mb-3"><div class="card-body">
                    <div class="d-flex justify-content-between gap-2 flex-wrap"><h2 class="h5"><%#: Eval("Title") %></h2><span class="badge text-bg-light"><%#: Eval("Status") %></span></div>
                    <p class="mb-1"><strong>When:</strong> <time class="meeting-time" data-utc="<%#: Eval("ScheduledAt") %>"><%#: Eval("When") %></time> &middot; <%#: Eval("Duration") %> minutes</p>
                    <p class="mb-1"><strong>Participants:</strong> <%#: Eval("Participants") %></p>
                    <p class="text-muted mb-3"><%#: Eval("Agenda") %></p>
                    <asp:HyperLink runat="server" CssClass="btn btn-outline-primary" NavigateUrl='<%# Eval("JoinUrl") %>' Visible='<%# Eval("CanJoin") %>' Target="_blank" rel="noopener noreferrer" Text="Join Zoom meeting" />
                </div></div>
            </ItemTemplate>
        </asp:Repeater>
    </div>

</asp:Content>
<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server">
    <script>document.querySelectorAll('.meeting-time').forEach(function (el) { var ms = Number(el.dataset.utc); if (ms > 0) el.textContent = new Date(ms).toLocaleString(); });</script>
</asp:Content>
