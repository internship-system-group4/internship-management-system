<%@ Page Language="C#" MasterPageFile="~/Layout/Public.master"
    AutoEventWireup="true" CodeBehind="Schedule.aspx.cs"
    Inherits="InternshipManagementSystem.Pages.MeetingsArea.Schedule"
    Title="Meetings" %>

<%-- ===================================================================
     Schedule a Meeting
     Owner : Fatima
     Cards : F08, F10 (OPTIONAL)
     Delete the placeholder below and build the page here.
     =================================================================== --%>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <style>
        .meeting-page { max-width: 850px; margin: 0 auto; }
        .meeting-participants {
            border: 1px solid var(--th-line-dee2e6,#dee2e6);
            border-radius: 8px;
            padding: 16px;
        }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="meeting-page">
        <h2 class="mb-1"><%: L.T("Meetings.Schedule.Meetings") %></h2>
        <p class="text-muted mb-4">
            <%: L.T("Meetings.Schedule.ScheduleAMeetingAndShareA") %>
        </p>

        <div class="uims-card mb-4">
            <h3 class="mb-3"><%: L.T("Meetings.Schedule.ScheduleAMeeting") %></h3>

            <div class="mb-3">
                <label class="form-label" for="<%= ddlPlacement.ClientID %>">
                    <%: L.T("Meetings.Schedule.Internship") %>
                </label>
                <asp:DropDownList ID="ddlPlacement" runat="server"
                    CssClass="form-select"
                    AutoPostBack="true"
                    OnSelectedIndexChanged="ddlPlacement_SelectedIndexChanged" />
            </div>

            <div class="mb-3">
                <label class="form-label" for="<%= txtTitle.ClientID %>">
                    <%: L.T("Meetings.Schedule.MeetingTitle") %>
                </label>
                <asp:TextBox ID="txtTitle" runat="server"
                    CssClass="form-control" />
            </div>

            <div class="mb-3">
                <label class="form-label" for="<%= txtAgenda.ClientID %>">
                    <%: L.T("Meetings.Schedule.Agenda") %>
                </label>
                <asp:TextBox ID="txtAgenda" runat="server"
                    CssClass="form-control" TextMode="MultiLine" Rows="3" />
            </div>

            <div class="row">
                <div class="col-md-6 mb-3">
                    <label class="form-label" for="<%= txtScheduledAt.ClientID %>">
                        <%: L.T("Meetings.Schedule.DateAndTime") %>
                    </label>
                    <asp:TextBox ID="txtScheduledAt" runat="server"
                        CssClass="form-control" TextMode="DateTimeLocal" />
                    <small class="text-muted">
                        <%: L.T("Meetings.Schedule.UseTheLocalTimeOnYour") %>
                    </small>
                </div>

                <div class="col-md-6 mb-3">
                    <label class="form-label" for="<%= ddlDuration.ClientID %>">
                        <%: L.T("Meetings.Schedule.Duration") %>
                    </label>
                    <asp:DropDownList ID="ddlDuration" runat="server"
                        CssClass="form-select">
                        <asp:ListItem Text="<%$ Resources:Meetings, Schedule.30Minutes %>" Value="30" />
                        <asp:ListItem Text="<%$ Resources:Meetings, Schedule.45Minutes %>" Value="45" />
                        <asp:ListItem Text="<%$ Resources:Meetings, Schedule.60Minutes %>" Value="60" />
                    </asp:DropDownList>
                </div>
            </div>

            <div class="mb-3">
                <span class="form-label d-block"><%: L.T("Meetings.Schedule.Participants") %></span>
                <div class="meeting-participants">
                    <asp:CheckBoxList ID="cblParticipants" runat="server" />
                </div>
            </div>

            <div class="mb-3">
                <label class="form-label" for="<%= txtJoinUrl.ClientID %>">
                    <%: L.T("Meetings.Schedule.ZoomMeetingLink") %>
                </label>
                <asp:TextBox ID="txtJoinUrl" runat="server"
                    CssClass="form-control" TextMode="Url"
                    placeholder="https://zoom.us/j/..." />
                <small class="text-muted">
                    <%: L.T("Meetings.Schedule.CreateTheMeetingInZoomThen") %>
                </small>
            </div>

            <asp:HiddenField ID="hfTimezoneOffset" runat="server" ClientIDMode="Static" />

            <asp:Button ID="btnSchedule" runat="server"
                Text="<%$ Resources:Meetings, Schedule.ScheduleMeeting %>"
                CssClass="btn btn-brand"
                OnClick="btnSchedule_Click"
                OnClientClick="setMeetingTimezone();"  data-ui-action="schedule" data-loading-label="Scheduling…"/>

            <asp:Label ID="lblMessage" runat="server"
                EnableViewState="false" />
        </div>

        <div class="uims-card">
            <h3 class="mb-3"><%: L.T("Meetings.Schedule.MyMeetings") %></h3>

            <asp:Repeater ID="rptMeetings" runat="server"
                OnItemCommand="rptMeetings_ItemCommand">
                <HeaderTemplate>
                    <div class="table-responsive">
                        <table class="uims-table">
                            <thead>
                                <tr>
                                    <th><%: L.T("Meetings.Schedule.Meeting") %></th>
                                    <th><%: L.T("Meetings.Schedule.ScheduledAtUTC") %></th>
                                    <th><%: L.T("Meetings.Schedule.Duration") %></th>
                                    <th></th>
                                </tr>
                            </thead>
                            <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td><%#: Eval("Title") %></td>
                        <td><%# FormatDate(Eval("ScheduledAt")) %></td>
                        <td><%#: Eval("DurationMinutes") %> <%: L.T("Meetings.Schedule.Min") %></td>
                        <td>
                            <asp:LinkButton ID="btnView" runat="server"
                                Text="<%$ Resources:Meetings, Schedule.ViewDetails %>"
                                CssClass="btn btn-outline-secondary btn-sm"
                                CommandName="ViewMeeting"
                                CommandArgument='<%# Eval("Id") %>' />
                        </td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                            </tbody>
                        </table>
                    </div>
                </FooterTemplate>
            </asp:Repeater>

            <asp:Label ID="lblNoMeetings" runat="server"
                Text="<%$ Resources:Meetings, Schedule.NoMeetingsToShow %>"
                CssClass="text-muted" />
        </div>

        <asp:Panel ID="pnlMeetingDetails" runat="server"
            Visible="false" CssClass="uims-card mt-4">
            <h3><%: L.T("Meetings.Schedule.MeetingDetails") %></h3>
            <p><strong><%: L.T("Meetings.Schedule.Title") %></strong>
                <asp:Label ID="lblDetailTitle" runat="server" /></p>
            <p><strong><%: L.T("Meetings.Schedule.Agenda2") %></strong>
                <asp:Label ID="lblDetailAgenda" runat="server" /></p>
            <p><strong><%: L.T("Meetings.Schedule.ScheduledAtUTC2") %></strong>
                <asp:Label ID="lblDetailDate" runat="server" /></p>
            <p><strong><%: L.T("Meetings.Schedule.Duration2") %></strong>
                <asp:Label ID="lblDetailDuration" runat="server" /></p>
            <asp:HyperLink ID="lnkJoin" runat="server"
                Text="<%$ Resources:Meetings, Schedule.JoinZoomMeeting %>"
                CssClass="btn btn-brand"
                Target="_blank"
                Visible="false" />
        </asp:Panel>
    </div>

   <script>
    function setMeetingTimezone() {
        document.getElementById("hfTimezoneOffset").value =
            new Date().getTimezoneOffset();
    }
</script>
</asp:Content>