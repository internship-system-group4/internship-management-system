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
            border: 1px solid #dee2e6;
            border-radius: 8px;
            padding: 16px;
        }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="meeting-page">
        <h2 class="mb-1">Meetings</h2>
        <p class="text-muted mb-4">
            Schedule a meeting and share a Zoom link with its participants.
        </p>

        <div class="uims-card mb-4">
            <h3 class="mb-3">Schedule a Meeting</h3>

            <div class="mb-3">
                <label class="form-label" for="<%= ddlPlacement.ClientID %>">
                    Internship
                </label>
                <asp:DropDownList ID="ddlPlacement" runat="server"
                    CssClass="form-select"
                    AutoPostBack="true"
                    OnSelectedIndexChanged="ddlPlacement_SelectedIndexChanged" />
            </div>

            <div class="mb-3">
                <label class="form-label" for="<%= txtTitle.ClientID %>">
                    Meeting Title
                </label>
                <asp:TextBox ID="txtTitle" runat="server"
                    CssClass="form-control" />
            </div>

            <div class="mb-3">
                <label class="form-label" for="<%= txtAgenda.ClientID %>">
                    Agenda
                </label>
                <asp:TextBox ID="txtAgenda" runat="server"
                    CssClass="form-control" TextMode="MultiLine" Rows="3" />
            </div>

            <div class="row">
                <div class="col-md-6 mb-3">
                    <label class="form-label" for="<%= txtScheduledAt.ClientID %>">
                        Date and Time
                    </label>
                    <asp:TextBox ID="txtScheduledAt" runat="server"
                        CssClass="form-control" TextMode="DateTimeLocal" />
                    <small class="text-muted">
                        Use the local time on your device.
                    </small>
                </div>

                <div class="col-md-6 mb-3">
                    <label class="form-label" for="<%= ddlDuration.ClientID %>">
                        Duration
                    </label>
                    <asp:DropDownList ID="ddlDuration" runat="server"
                        CssClass="form-select">
                        <asp:ListItem Text="30 minutes" Value="30" />
                        <asp:ListItem Text="45 minutes" Value="45" />
                        <asp:ListItem Text="60 minutes" Value="60" />
                    </asp:DropDownList>
                </div>
            </div>

            <div class="mb-3">
                <span class="form-label d-block">Participants</span>
                <div class="meeting-participants">
                    <asp:CheckBoxList ID="cblParticipants" runat="server" />
                </div>
            </div>

            <div class="mb-3">
                <label class="form-label" for="<%= txtJoinUrl.ClientID %>">
                    Zoom Meeting Link
                </label>
                <asp:TextBox ID="txtJoinUrl" runat="server"
                    CssClass="form-control" TextMode="Url"
                    placeholder="https://zoom.us/j/..." />
                <small class="text-muted">
                    Create the meeting in Zoom, then paste its link here.
                </small>
            </div>

            <asp:HiddenField ID="hfTimezoneOffset" runat="server" ClientIDMode="Static" />

            <asp:Button ID="btnSchedule" runat="server"
                Text="Schedule Meeting"
                CssClass="btn btn-brand"
                OnClick="btnSchedule_Click"
                OnClientClick="setMeetingTimezone();"  data-ui-action="schedule" data-loading-label="Scheduling…"/>

            <asp:Label ID="lblMessage" runat="server"
                EnableViewState="false" />
        </div>

        <div class="uims-card">
            <h3 class="mb-3">My Meetings</h3>

            <asp:Repeater ID="rptMeetings" runat="server"
                OnItemCommand="rptMeetings_ItemCommand">
                <HeaderTemplate>
                    <div class="table-responsive">
                        <table class="uims-table">
                            <thead>
                                <tr>
                                    <th>Meeting</th>
                                    <th>Scheduled At (UTC)</th>
                                    <th>Duration</th>
                                    <th></th>
                                </tr>
                            </thead>
                            <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td><%#: Eval("Title") %></td>
                        <td><%# FormatDate(Eval("ScheduledAt")) %></td>
                        <td><%#: Eval("DurationMinutes") %> min</td>
                        <td>
                            <asp:LinkButton ID="btnView" runat="server"
                                Text="View Details"
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
                Text="No meetings to show."
                CssClass="text-muted" />
        </div>

        <asp:Panel ID="pnlMeetingDetails" runat="server"
            Visible="false" CssClass="uims-card mt-4">
            <h3>Meeting Details</h3>
            <p><strong>Title:</strong>
                <asp:Label ID="lblDetailTitle" runat="server" /></p>
            <p><strong>Agenda:</strong>
                <asp:Label ID="lblDetailAgenda" runat="server" /></p>
            <p><strong>Scheduled At (UTC):</strong>
                <asp:Label ID="lblDetailDate" runat="server" /></p>
            <p><strong>Duration:</strong>
                <asp:Label ID="lblDetailDuration" runat="server" /></p>
            <asp:HyperLink ID="lnkJoin" runat="server"
                Text="Join Zoom Meeting"
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