<%@ Page Language="C#" MasterPageFile="~/Layout/Public.master"
    AutoEventWireup="true" CodeBehind="Schedule.aspx.cs"
    Inherits="InternshipManagementSystem.Pages.MeetingsArea.Schedule"
    Title="Meetings" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <style>
        .meeting-page {
            max-width: 850px;
            margin: 0 auto;
        }

        .meeting-participants {
            border: 1px solid var(--th-line-dee2e6,#dee2e6);
            border-radius: 8px;
            padding: 16px;
        }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

    <div class="meeting-page">
        <h2 class="mb-1">Meetings</h2>
        <p class="text-muted mb-4">
            Schedule a meeting with people involved in the student's internship.
        </p>

        <div class="uims-card mb-4">
            <h3 class="mb-3">Schedule a Meeting</h3>

            <div class="mb-3">
                <asp:Label runat="server"
                    AssociatedControlID="ddlPlacement"
                    CssClass="form-label"
                    Text="Student" />

                <asp:DropDownList ID="ddlPlacement" runat="server"
                    CssClass="form-select"
                    AutoPostBack="true"
                    OnSelectedIndexChanged="ddlPlacement_SelectedIndexChanged" />

                <small class="text-muted">
                    If you are a student, your internship is selected automatically.
                </small>
            </div>

            <div class="mb-3">
                <asp:Label runat="server"
                    AssociatedControlID="txtTitle"
                    CssClass="form-label"
                    Text="Meeting Title" />

                <asp:TextBox ID="txtTitle" runat="server"
                    CssClass="form-control" />
            </div>

            <div class="mb-3">
                <asp:Label runat="server"
                    AssociatedControlID="txtAgenda"
                    CssClass="form-label"
                    Text="Agenda" />

                <asp:TextBox ID="txtAgenda" runat="server"
                    CssClass="form-control"
                    TextMode="MultiLine"
                    Rows="3" />
            </div>

            <div class="row">
                <div class="col-md-6 mb-3">
                    <asp:Label runat="server"
                        AssociatedControlID="txtScheduledAt"
                        CssClass="form-label"
                        Text="Date and Time (UTC)" />

                    <asp:TextBox ID="txtScheduledAt" runat="server"
                        CssClass="form-control"
                        TextMode="DateTimeLocal" />

                    <small class="text-muted">
                        Enter the meeting time in UTC.
                    </small>
                </div>

                <div class="col-md-6 mb-3">
                    <asp:Label runat="server"
                        AssociatedControlID="ddlDuration"
                        CssClass="form-label"
                        Text="Duration" />

                    <asp:DropDownList ID="ddlDuration" runat="server"
                        CssClass="form-select">
                        <asp:ListItem Text="30 minutes" Value="30" />
                        <asp:ListItem Text="45 minutes" Value="45" />
                        <asp:ListItem Text="60 minutes" Value="60" />
                    </asp:DropDownList>
                </div>
            </div>

            <div class="mb-3">
                <span class="form-label d-block">Invite participants</span>

                <div class="meeting-participants">
                    <asp:CheckBoxList ID="cblParticipants"
                        runat="server" />

                    <asp:Label ID="lblNoParticipants"
                        runat="server"
                        CssClass="text-muted"
                        Text="Choose a student to see participants." />
                </div>
            </div>

            <div class="mb-3">
                <asp:Label runat="server"
                    AssociatedControlID="txtJoinUrl"
                    CssClass="form-label"
                    Text="Zoom Meeting Link" />

                <asp:TextBox ID="txtJoinUrl" runat="server"
                    CssClass="form-control"
                    TextMode="Url"
                    placeholder="https://zoom.us/j/..." />

                <small class="text-muted">
                    Create the meeting in Zoom and paste its join link here.
                </small>
            </div>

            <asp:Button ID="btnSchedule" runat="server"
                Text="Schedule Meeting"
                CssClass="btn btn-brand"
                OnClick="btnSchedule_Click" data-ui-action="schedule" data-loading-label="Scheduling…" />

            <asp:Label ID="lblMessage" runat="server"
                EnableViewState="false" />
        </div>

        <div class="uims-card">
            <h3 class="mb-3">My Meetings</h3>

            <asp:Repeater ID="rptMeetings" runat="server"
                OnItemCommand="rptMeetings_ItemCommand">
                <ItemTemplate>
                    <div class="border rounded p-3 mb-3">
                        <strong><%#: Eval("Title") %></strong>

                        <div class="text-muted small mt-1">
                            <%# FormatDate(Eval("ScheduledAt")) %>
                            · <%#: Eval("DurationMinutes") %> minutes
                        </div>

                        <asp:LinkButton ID="btnView" runat="server"
                            Text="View Details"
                            CssClass="btn btn-outline-secondary btn-sm mt-2"
                            CommandName="ViewMeeting"
                            CommandArgument='<%# Eval("Id") %>' />
                    </div>
                </ItemTemplate>
            </asp:Repeater>

            <asp:Label ID="lblNoMeetings" runat="server"
                Text="No meetings to show."
                CssClass="text-muted" />
        </div>

        <asp:Panel ID="pnlMeetingDetails" runat="server"
            Visible="false"
            CssClass="uims-card mt-4">

            <h3>Meeting Details</h3>

            <p><strong>Title:</strong>
                <asp:Label ID="lblDetailTitle" runat="server" /></p>

            <p><strong>Agenda:</strong>
                <asp:Label ID="lblDetailAgenda" runat="server" /></p>

            <p><strong>Scheduled At:</strong>
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

</asp:Content>