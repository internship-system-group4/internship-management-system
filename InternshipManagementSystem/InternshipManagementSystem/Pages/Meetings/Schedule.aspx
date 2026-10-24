<%@ Page Language="C#" MasterPageFile="~/Layout/Public.master" AutoEventWireup="true" CodeBehind="Schedule.aspx.cs" Inherits="InternshipManagementSystem.Pages.MeetingsArea.Schedule" Title="Schedule a Meeting" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

    <div class="container py-4" style="max-width:850px">
        <div class="d-flex justify-content-between align-items-center mb-3"><h1 class="h3 mb-0"><%: L.T("Meetings.Schedule.ScheduleAZoomMeeting") %></h1><a href="MyMeetings.aspx"><%: L.T("Meetings.Schedule.MyMeetings2") %></a></div>
        <asp:Label ID="lblMessage" runat="server" Visible="false" role="alert" />
        <div class="card"><div class="card-body row g-3">
            <div class="col-12"><label for="<%= txtTitle.ClientID %>" class="form-label"><%: L.T("Meetings.Schedule.Title2") %></label><asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" MaxLength="200" /></div>
            <div class="col-12"><label for="<%= txtAgenda.ClientID %>" class="form-label"><%: L.T("Meetings.Schedule.AgendaOptional") %></label><asp:TextBox ID="txtAgenda" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" MaxLength="2000" /></div>
            <div class="col-md-6"><label for="<%= txtStart.ClientID %>" class="form-label"><%: L.T("Meetings.Schedule.DateAndTimeYourLocalTime") %></label><asp:TextBox ID="txtStart" runat="server" CssClass="form-control" TextMode="DateTimeLocal" /></div>
            <div class="col-md-6"><label for="<%= txtDuration.ClientID %>" class="form-label"><%: L.T("Meetings.Schedule.DurationMinutes") %></label><asp:TextBox ID="txtDuration" runat="server" CssClass="form-control" TextMode="Number" Text="30" /></div>
            <div class="col-12"><label class="form-label"><%: L.T("Meetings.Schedule.Participants2") %></label><p class="text-muted small mb-2"><%: L.T("Meetings.Schedule.SelectThePeopleWhoShouldSee") %></p><asp:CheckBoxList ID="lstParticipants" runat="server" RepeatLayout="Flow" /></div>
            <asp:HiddenField ID="hdnOffset" runat="server" />
            <div class="col-12"><asp:Button ID="btnCreate" runat="server" Text="<%$ Resources:Meetings, Schedule.CreateZoomMeeting %>" CssClass="btn btn-primary" OnClick="btnCreate_Click" /></div>
        </div></div>
    </div>

</asp:Content>
<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server">
    <script>document.getElementById('<%= hdnOffset.ClientID %>').value = new Date().getTimezoneOffset();</script>
</asp:Content>
