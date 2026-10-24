<%@ Page Language="C#"
    MasterPageFile="~/Layout/Public.master"
    AutoEventWireup="true"
    CodeBehind="MyMeetings.aspx.cs"
    Inherits="InternshipManagementSystem.Pages.MeetingsArea.MyMeetings"
    Title="My Meetings" %>

<asp:Content ID="MeetingHead"
    ContentPlaceHolderID="head"
    runat="server">

    <style>
        .meetings-page {
            --ink: var(--th-fg-1b3046,#1b3046);
            --muted: var(--ui-muted);
            --primary: #28567e;
            --primary-text: var(--ink,#28567e);
            --border: var(--th-line-e0e8ef,#e0e8ef);
            color: var(--ink);
            max-width: 1240px;
            margin: auto;
            padding: 12px 0 36px;
            font-family: inherit;
        }

        .meetings-page * {
            box-sizing: border-box;
        }

        .meeting-hero {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 24px;
            padding: 30px;
            margin-bottom: 24px;
            border: 1px solid var(--th-line-d9e5f2,#d9e5f2);
            border-radius: 22px;
            background: linear-gradient(120deg, var(--th-bg-edf4fd,#edf4fd), var(--th-bg-f5f8ff,#f5f8ff));
        }

        .meeting-eyebrow {
            font-size: 11px;
            font-weight: 750;
            letter-spacing: .15em;
            text-transform: uppercase;
            color: var(--primary-text);
            margin: 0 0 8px;
        }

        .meeting-hero h1 {
            font-size: clamp(27px, 3vw, 37px);
            font-weight: 750;
            margin: 0 0 10px;
        }

        .meeting-hero p:last-child {
            color: var(--muted);
            max-width: 600px;
            line-height: 1.7;
            margin: 0;
        }

        .meeting-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
            min-height: 43px;
            padding: 10px 16px;
            border: 1px solid var(--border);
            border-radius: 10px;
            background: var(--ui-surface,#fff);
            color: var(--ink);
            font: inherit;
            font-size: 13px;
            font-weight: 650;
            text-decoration: none;
            cursor: pointer;
            white-space: nowrap;
        }

        .meeting-btn:hover {
            background: var(--th-bg-f0f5f7,#f0f5f7);
            color: var(--ink);
        }

        .meeting-btn-primary {
            background: var(--primary);
            border-color: var(--primary);
            color: #fff;
        }

        .meeting-btn-primary:hover {
            background: var(--th-bg-194568,#194568);
            color: #fff;
        }

        .meeting-btn-danger {
            color: var(--th-fg-a13a4a,#a13a4a);
            border-color: var(--th-line-eed5db,#eed5db);
        }

        .meeting-btn-small {
            font-size: 12px;
            min-height: 35px;
            padding: 7px 10px;
        }

        .meeting-btn:disabled {
            opacity: .5;
            cursor: wait;
        }

        .meetings-page :is(button, input, textarea, select, a):focus-visible {
            outline: 3px solid var(--th-line-8db8df,#8db8df);
            outline-offset: 3px;
        }

        .meeting-stats {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 14px;
            margin-bottom: 24px;
        }

        .meeting-stat {
            padding: 20px 22px;
            background: var(--ui-surface,#fff);
            border: 1px solid var(--border);
            border-radius: 15px;
        }

        .meeting-stat-number {
            display: block;
            font-size: 30px;
            font-weight: 750;
            line-height: 1.2;
            margin-bottom: 8px;
        }

        .meeting-stat-label {
            display: block;
            font-size: 13px;
            font-weight: 650;
        }

        .meeting-stat small {
            display: block;
            color: var(--muted);
            font-size: 12px;
            margin-top: 6px;
        }

        .meeting-stat:first-child .meeting-stat-number {
            color: var(--th-fg-946511,#946511);
        }

        .meeting-stat:nth-child(3) .meeting-stat-number {
            color: var(--th-fg-28567e,#28567e);
        }

        .meeting-panel {
            border: 1px solid var(--border);
            border-radius: 18px;
            background: var(--ui-surface,#fff);
            overflow: hidden;
            box-shadow: 0 6px 24px #1b304606;
        }

        .meeting-panel-heading {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 20px;
            padding: 24px;
            border-bottom: 1px solid var(--border);
        }

        .meeting-panel-heading h2 {
            font-size: 20px;
            font-weight: 700;
            margin: 0 0 7px;
        }

        .meeting-panel-heading p {
            font-size: 13px;
            color: var(--muted);
            margin: 0;
            line-height: 1.7;
        }

        .meeting-toolbar {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }

        .meeting-view-bar {
            display: flex;
            justify-content: space-between;
            gap: 15px;
            align-items: center;
            padding: 16px 24px;
            background: var(--th-bg-fbfcfe,#fbfcfe);
            border-bottom: 1px solid var(--border);
            font-size: 13px;
        }

        .meeting-view-bar strong {
            font-weight: 650;
        }

        .meeting-live-note {
            color: var(--muted);
            font-size: 12px;
        }

        .meeting-table-wrap {
            overflow-x: auto;
        }

        .meeting-table {
            width: 100%;
            min-width: 950px;
            border: 0 !important;
            border-collapse: collapse;
            font-size: 13px;
        }

        .meeting-table th {
            padding: 15px 19px;
            background: var(--th-bg-f4f7fa,#f4f7fa);
            border: 0 !important;
            border-bottom: 1px solid var(--border) !important;
            color: var(--th-fg-5b6c80,#5b6c80);
            text-align: left;
            font-size: 12px;
            font-weight: 700;
        }

        .meeting-table td {
            padding: 20px 19px;
            vertical-align: top;
            border: 0 !important;
            border-bottom: 1px solid var(--th-line-edf1f5,#edf1f5) !important;
            overflow-wrap: anywhere;
        }

        .meeting-table tr:last-child td {
            border-bottom: 0 !important;
        }

        .meeting-table tr:hover td {
            background: var(--th-bg-fcfdfd,#fcfdfd);
        }

        .meeting-subtext {
            margin-top: 6px;
            color: var(--muted);
            font-size: 12px;
            line-height: 1.6;
        }

        .meeting-actions {
            display: flex;
            gap: 7px;
            flex-wrap: wrap;
            max-width: 285px;
            min-width: 160px;
        }

        .meeting-status {
            display: inline-block;
            padding: 6px 10px;
            border-radius: 8px;
            background: var(--th-bg-eff3f7,#eff3f7);
            color: var(--th-fg-56677c,#56677c);
            font-size: 11px;
            font-weight: 700;
            max-width: 180px;
        }

        .meeting-status[data-state="Pending approval"] {
            background: var(--th-bg-fff2d6,#fff2d6);
            color: var(--th-fg-825b0d,#825b0d);
        }

        .meeting-status[data-state="Approved"] {
            background: var(--th-bg-e3efff,#e3efff);
            color: var(--th-fg-24547c,#24547c);
        }

        .meeting-status[data-state="Declined"],
        .meeting-status[data-state="Cancelled"] {
            background: var(--th-bg-fdecef,#fdecef);
            color: var(--th-fg-a13a4a,#a13a4a);
        }

        .meeting-status[data-state="Completed"] {
            background: var(--th-bg-eaf0ff,#eaf0ff);
            color: var(--th-fg-3e5e9b,#3e5e9b);
        }

        .meeting-empty {
            text-align: center;
            padding: 42px 20px;
            color: var(--muted);
        }

        .meeting-empty strong {
            display: block;
            font-size: 17px;
            color: var(--ink);
            margin-bottom: 9px;
        }

        .meeting-footer-note {
            padding: 17px 24px;
            margin: 0;
            font-size: 12px;
            color: var(--muted);
            line-height: 1.8;
            background: var(--th-bg-fcfdfe,#fcfdfe);
        }

        .meeting-dialog {
            color: var(--ink);
            width: min(760px, calc(100% - 28px));
            max-height: 90vh;
            padding: 0;
            margin: auto;
            border: 1px solid var(--border);
            border-radius: 20px;
            background: var(--ui-surface,#fff);
            overflow: auto;
            box-shadow: 0 30px 100px #10203040;
        }

        .meeting-dialog::backdrop {
            background: var(--th-bg-12263970,#12263970);
            backdrop-filter: blur(7px);
            -webkit-backdrop-filter: blur(7px);
        }

        .meeting-dialog[open] {
            animation: meetingEnter .16s ease-out;
        }

        .meeting-dialog-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 18px;
            padding: 21px 24px;
            border-bottom: 1px solid var(--border);
        }

        .meeting-dialog-header h2 {
            font-size: 21px;
            font-weight: 700;
            margin: 0;
        }

        .meeting-dialog-header p {
            margin: 6px 0 0;
            font-size: 13px;
            color: var(--muted);
            line-height: 1.6;
        }

        .meeting-close {
            display: grid;
            place-items: center;
            flex: 0 0 38px;
            width: 38px;
            height: 38px;
            border: 1px solid var(--border);
            border-radius: 10px;
            background: var(--ui-surface,#fff);
            font-size: 24px;
            color: var(--th-fg-53667b,#53667b);
            cursor: pointer;
        }

        .meeting-close:hover {
            background: var(--th-bg-f3f7fa,#f3f7fa);
        }

        .meeting-form {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            padding: 24px;
        }

        .meeting-wide {
            grid-column: 1 / -1;
        }

        .meeting-label {
            display: block;
            font-size: 13px;
            font-weight: 650;
            margin-bottom: 8px;
        }

        .meeting-control {
            width: 100%;
            min-height: 45px;
            border: 1px solid var(--th-line-cfdbe4,#cfdbe4);
            border-radius: 10px;
            background: var(--ui-surface,#fff);
            padding: 11px 12px;
            font: inherit;
            font-size: 14px;
            color: var(--ink);
        }

        textarea.meeting-control {
            min-height: 110px;
            resize: vertical;
        }

        .meeting-hint {
            display: block;
            font-size: 12px;
            color: var(--muted);
            margin: 7px 0 0;
            line-height: 1.7;
        }

        .meeting-dialog-actions {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            flex-wrap: wrap;
            padding: 20px 24px;
            border-top: 1px solid var(--border);
        }

        .meeting-help {
            padding: 13px 16px;
            border-radius: 10px;
            background: var(--th-bg-edf4fd,#edf4fd);
            font-size: 12px;
            color: var(--th-fg-345d81,#345d81);
            line-height: 1.8;
        }

        .meeting-dialog-small {
            width: min(470px, calc(100% - 28px));
        }

        .meeting-dialog-body {
            padding: 24px;
            line-height: 1.8;
        }

        .meeting-dialog-body p {
            margin: 0;
            color: var(--muted);
        }

        .meeting-details dl {
            display: grid;
            grid-template-columns: 100px 1fr;
            gap: 13px;
            margin: 0;
        }

        .meeting-details dt {
            color: var(--muted);
            font-size: 13px;
            font-weight: 600;
        }

        .meeting-details dd {
            margin: 0;
            font-size: 14px;
            overflow-wrap: anywhere;
        }

        .meeting-agenda {
            white-space: pre-wrap;
        }

        .meeting-room-dialog {
            width: min(1280px, calc(100% - 22px));
        }

        .meeting-room-host {
            height: 68vh;
            min-height: 320px;
            background: var(--th-bg-182b40,#182b40);
        }

        .meeting-room-note {
            padding: 12px 24px;
            margin: 0;
            font-size: 12px;
            line-height: 1.7;
            color: var(--muted);
        }

        .meeting-room-footer {
            display: flex;
            justify-content: space-between;
            gap: 15px;
            align-items: center;
            padding: 12px 24px;
            border-top: 1px solid var(--border);
        }

        body:has(.meeting-dialog[open]) {
            overflow: hidden;
        }

        @keyframes meetingEnter {
            from {
                opacity: 0;
                transform: translateY(9px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @media (max-width: 760px) {
            .meeting-hero,
            .meeting-panel-heading {
                flex-direction: column;
                align-items: flex-start;
                padding: 22px;
            }

            .meeting-stats {
                grid-template-columns: 1fr 1fr;
                gap: 10px;
            }

            .meeting-form {
                grid-template-columns: 1fr;
                padding: 20px;
            }

            .meeting-view-bar {
                align-items: flex-start;
                flex-direction: column;
            }

            .meeting-dialog-header {
                padding: 18px 20px;
            }

            .meeting-stat {
                padding: 17px;
            }

            .meeting-room-host {
                height: 62vh;
            }

            .meeting-room-footer {
                align-items: flex-start;
                flex-direction: column;
            }
        }

        @media (prefers-reduced-motion: reduce) {
            .meeting-dialog[open] {
                animation: none;
            }
        }
    </style>

</asp:Content>

<asp:Content ID="MeetingContent"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="meetings-page"
        id="meetingWorkspace"
        data-display-name="<%: CurrentUser.FullName %>">

        <header class="meeting-hero">
            <div>
                <p class="meeting-eyebrow">Internship workspace</p>

                <h1>My Meetings</h1>

                <p>
                    Request a conversation, respond to invitations,
                    and keep your meeting history in one place.
                </p>
            </div>

            <button type="button"
                class="meeting-btn meeting-btn-primary"
                onclick="showMeetingDialog('requestDialog')">
                + Request a meeting
            </button>
        </header>

        <div class="meeting-stats" aria-label="Meeting overview">

            <div class="meeting-stat">
                <asp:Label ID="IncomingCount"
                    runat="server"
                    CssClass="meeting-stat-number"
                    Text="0" />

                <span class="meeting-stat-label">Waiting for you</span>

                <small>Requests needing your response</small>
            </div>

            <div class="meeting-stat">
                <asp:Label ID="SentCount"
                    runat="server"
                    CssClass="meeting-stat-number"
                    Text="0" />

                <span class="meeting-stat-label">Requests sent</span>

                <small>Waiting for the other person</small>
            </div>

            <div class="meeting-stat">
                <asp:Label ID="UpcomingCount"
                    runat="server"
                    CssClass="meeting-stat-number"
                    Text="0" />

                <span class="meeting-stat-label">Approved meetings</span>

                <small>Upcoming or in progress</small>
            </div>

            <div class="meeting-stat">
                <asp:Label ID="HistoryCount"
                    runat="server"
                    CssClass="meeting-stat-number"
                    Text="0" />

                <span class="meeting-stat-label">In your history</span>

                <small>Past, completed, or closed</small>
            </div>

        </div>

        <section class="meeting-panel"
            aria-labelledby="meetingListTitle">

            <div class="meeting-panel-heading">
                <div>
                    <h2 id="meetingListTitle">Meetings &amp; requests</h2>

                    <p>
                        Open the details, respond to a request,
                        or join an approved meeting.
                    </p>
                </div>

                <div class="meeting-toolbar">
                    <button type="button"
                        class="meeting-btn"
                        onclick="showMeetingDialog('filterDialog')">
                        Change view
                    </button>

                    <asp:Button ID="RefreshButton"
                        runat="server"
                        Text="Refresh list"
                        CssClass="meeting-btn"
                        OnClick="Refresh_Click"
                        OnClientClick="return confirmMeetingAction(this,'refresh');"
                        CausesValidation="false" />
                </div>
            </div>

            <div class="meeting-view-bar">
                <strong>
                    <asp:Label ID="MeetingViewName"
                        runat="server"
                        Text="All my meetings" />
                </strong>

                <span class="meeting-live-note">
                    Times shown in Jordan local time.
                    Refresh to update availability.
                </span>
            </div>

            <div class="meeting-table-wrap">

                <asp:GridView ID="MeetingGrid"
                    runat="server"
                    AutoGenerateColumns="false"
                    GridLines="None"
                    CssClass="meeting-table"
                    OnRowCommand="MeetingGrid_RowCommand">

                    <Columns>

                        <asp:TemplateField HeaderText="Meeting">
                            <ItemTemplate>
                                <strong><%#: Eval("Title") %></strong>

                                <div class="meeting-subtext">
                                    <%#: Eval("DurationText") %>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="People">
                            <ItemTemplate>
                                <div>
                                    <strong>From:</strong>
                                    <%#: Eval("FromName") %>
                                </div>

                                <div class="meeting-subtext">
                                    <strong>To:</strong>
                                    <%#: Eval("ToName") %>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField DataField="DateText"
                            HeaderText="Date &amp; time"
                            HtmlEncode="true" />

                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <span class="meeting-status"
                                    data-state='<%#: Eval("StateText") %>'>
                                    <%#: Eval("StateText") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>

                                <div class="meeting-actions">

                                    <asp:LinkButton runat="server"
                                        Text="Details"
                                        CssClass="meeting-btn meeting-btn-small"
                                        CommandName="Details"
                                        CommandArgument='<%# Eval("Id") %>'
                                        CausesValidation="false" />

                                    <asp:LinkButton runat="server"
                                        Text="Accept"
                                        CssClass="meeting-btn meeting-btn-small meeting-btn-primary"
                                        CommandName="Accept"
                                        CommandArgument='<%# Eval("Id") %>'
                                        Visible='<%# Eval("CanRespond") %>'
                                        OnClientClick="return confirmMeetingAction(this,'accept');"
                                        CausesValidation="false" />

                                    <asp:LinkButton runat="server"
                                        Text="Decline"
                                        CssClass="meeting-btn meeting-btn-small meeting-btn-danger"
                                        CommandName="Reject"
                                        CommandArgument='<%# Eval("Id") %>'
                                        Visible='<%# Eval("CanRespond") %>'
                                        OnClientClick="return confirmMeetingAction(this,'reject');"
                                        CausesValidation="false" />

                                    <asp:LinkButton runat="server"
                                        Text="Join meeting"
                                        CssClass="meeting-btn meeting-btn-small meeting-btn-primary"
                                        CommandName="Join"
                                        CommandArgument='<%# Eval("Id") %>'
                                        Visible='<%# Eval("CanJoin") %>'
                                        CausesValidation="false" />

                                    <asp:LinkButton runat="server"
                                        Text="Mark completed"
                                        CssClass="meeting-btn meeting-btn-small"
                                        CommandName="Complete"
                                        CommandArgument='<%# Eval("Id") %>'
                                        Visible='<%# Eval("CanComplete") %>'
                                        OnClientClick="return confirmMeetingAction(this,'complete');"
                                        CausesValidation="false" />

                                    <asp:LinkButton runat="server"
                                        Text="Cancel meeting"
                                        CssClass="meeting-btn meeting-btn-small meeting-btn-danger"
                                        CommandName="CancelMeeting"
                                        CommandArgument='<%# Eval("Id") %>'
                                        Visible='<%# Eval("CanCancel") %>'
                                        OnClientClick="return confirmMeetingAction(this,'cancel');"
                                        CausesValidation="false" />

                                </div>

                            </ItemTemplate>
                        </asp:TemplateField>

                    </Columns>

                    <EmptyDataTemplate>
                        <div class="meeting-empty">
                            <strong>No meetings in this view</strong>

                            Choose another view or send your first meeting request.

                            <br />

                            <button type="button"
                                class="meeting-btn"
                                style="margin-top: 16px"
                                onclick="showMeetingDialog('requestDialog')">
                                Request a meeting
                            </button>
                        </div>
                    </EmptyDataTemplate>

                </asp:GridView>

            </div>

            <p class="meeting-footer-note">
                Requests need the invited person's approval.
                Join opens 15 minutes before an approved meeting and remains
                available until its scheduled end.
                Passing the scheduled end does not automatically confirm
                attendance or completion.
            </p>

        </section>

        <!-- نافذة إنشاء طلب ميتنج -->

        <dialog id="requestDialog"
            class="meeting-dialog"
            aria-labelledby="requestTitle">

            <div class="meeting-dialog-header">
                <div>
                    <h2 id="requestTitle">Request a meeting</h2>

                    <p>
                        Choose a person and suggest a time.
                        The request needs their approval.
                    </p>
                </div>

                <button type="button"
                    class="meeting-close"
                    onclick="closeMeetingDialog('requestDialog')"
                    aria-label="Close request form">
                    ×
                </button>
            </div>

            <div class="meeting-form">

                <div>
                    <asp:Label runat="server"
                        AssociatedControlID="MeetingTitle"
                        CssClass="meeting-label"
                        Text="Meeting title" />

                    <asp:TextBox ID="MeetingTitle"
                        runat="server"
                        CssClass="meeting-control"
                        MaxLength="150"
                        placeholder="e.g. Internship progress review" />
                </div>

                <div>
                    <asp:Label runat="server"
                        AssociatedControlID="Recipient"
                        CssClass="meeting-label"
                        Text="Who would you like to meet?" />

                    <asp:DropDownList ID="Recipient"
                        runat="server"
                        CssClass="meeting-control" />
                </div>

                <div>
                    <asp:Label runat="server"
                        AssociatedControlID="MeetingDate"
                        CssClass="meeting-label"
                        Text="Date and time" />

                    <asp:TextBox ID="MeetingDate"
                        runat="server"
                        TextMode="DateTimeLocal"
                        CssClass="meeting-control"
                        aria-describedby="dateHint" />

                    <span id="dateHint" class="meeting-hint">
                        Use Jordan local time.
                    </span>
                </div>

                <div>
                    <asp:Label runat="server"
                        AssociatedControlID="Duration"
                        CssClass="meeting-label"
                        Text="Duration" />

                    <asp:DropDownList ID="Duration"
                        runat="server"
                        CssClass="meeting-control">

                        <asp:ListItem Value="15">15 minutes</asp:ListItem>

                        <asp:ListItem Value="30" Selected="True">
                            30 minutes
                        </asp:ListItem>

                        <asp:ListItem Value="45">45 minutes</asp:ListItem>

                        <asp:ListItem Value="60">60 minutes</asp:ListItem>

                    </asp:DropDownList>
                </div>

                <div class="meeting-wide">
                    <asp:Label runat="server"
                        AssociatedControlID="Agenda"
                        CssClass="meeting-label"
                        Text="Agenda (optional)" />

                    <asp:TextBox ID="Agenda"
                        runat="server"
                        TextMode="MultiLine"
                        Rows="3"
                        CssClass="meeting-control"
                        placeholder="What would you like to discuss?" />
                </div>

                <div class="meeting-wide meeting-help">
                    Only people linked to your internship or academic supervision assignment are listed.
                    Each request invites one person and stays pending until they accept.
                </div>

            </div>

            <div class="meeting-dialog-actions">
                <button type="button"
                    class="meeting-btn"
                    onclick="closeMeetingDialog('requestDialog')">
                    Keep editing later
                </button>

                <asp:Button ID="SendRequest"
                    runat="server"
                    Text="Send request"
                    CssClass="meeting-btn meeting-btn-primary"
                    OnClick="SendRequest_Click"
                    OnClientClick="return confirmMeetingAction(this,'send');"
                    CausesValidation="false" />
            </div>

        </dialog>

        <!-- نافذة اختيار نوع العرض -->

        <dialog id="filterDialog"
            class="meeting-dialog meeting-dialog-small"
            aria-labelledby="filterTitle">

            <div class="meeting-dialog-header">
                <h2 id="filterTitle">Choose a view</h2>

                <button type="button"
                    class="meeting-close"
                    onclick="closeMeetingDialog('filterDialog')"
                    aria-label="Close view selector">
                    ×
                </button>
            </div>

            <div class="meeting-dialog-body">
                <asp:Label runat="server"
                    AssociatedControlID="MeetingFilter"
                    CssClass="meeting-label"
                    Text="Show meetings" />

                <asp:DropDownList ID="MeetingFilter"
                    runat="server"
                    CssClass="meeting-control">

                    <asp:ListItem Value="all">
                        All my meetings and requests
                    </asp:ListItem>

                    <asp:ListItem Value="incoming">
                        Waiting for my approval
                    </asp:ListItem>

                    <asp:ListItem Value="sent">
                        Requests I sent - pending
                    </asp:ListItem>

                    <asp:ListItem Value="upcoming">
                        Approved meetings
                    </asp:ListItem>

                    <asp:ListItem Value="history">
                        Meeting history
                    </asp:ListItem>

                </asp:DropDownList>
            </div>

            <div class="meeting-dialog-actions">
                <button type="button"
                    class="meeting-btn"
                    onclick="closeMeetingDialog('filterDialog')">
                    Cancel
                </button>

                <asp:Button ID="ApplyFilter"
                    runat="server"
                    Text="Apply view"
                    CssClass="meeting-btn meeting-btn-primary"
                    OnClick="ApplyFilter_Click"
                    CausesValidation="false" />
            </div>

        </dialog>

        <!-- نافذة تأكيد الأكشن -->

        <dialog id="confirmDialog"
            class="meeting-dialog meeting-dialog-small"
            aria-labelledby="confirmTitle"
            aria-describedby="confirmText">

            <div class="meeting-dialog-header">
                <h2 id="confirmTitle">Confirm action</h2>

                <button type="button"
                    class="meeting-close"
                    onclick="closeMeetingDialog('confirmDialog')"
                    aria-label="Close confirmation">
                    ×
                </button>
            </div>

            <div class="meeting-dialog-body">
                <p id="confirmText"></p>
            </div>

            <div class="meeting-dialog-actions">
                <button type="button"
                    class="meeting-btn"
                    onclick="closeMeetingDialog('confirmDialog')">
                    Go back
                </button>

                <button type="button"
                    id="confirmProceed"
                    class="meeting-btn meeting-btn-primary"
                    onclick="proceedMeetingAction()">
                    Confirm
                </button>
            </div>

        </dialog>

        <!-- نافذة تفاصيل الميتنج -->

        <dialog id="detailsDialog"
            class="meeting-dialog"
            aria-labelledby="detailsHeading">

            <div class="meeting-dialog-header">
                <h2 id="detailsHeading">Meeting details</h2>

                <button type="button"
                    class="meeting-close"
                    onclick="closeMeetingDialog('detailsDialog')"
                    aria-label="Close meeting details">
                    ×
                </button>
            </div>

            <div class="meeting-dialog-body meeting-details">
                <dl>
                    <dt>Title</dt>
                    <dd>
                        <asp:Label ID="DetailTitle" runat="server" />
                    </dd>

                    <dt>People</dt>
                    <dd>
                        <asp:Label ID="DetailPeople" runat="server" />
                    </dd>

                    <dt>When</dt>
                    <dd>
                        <asp:Label ID="DetailTime" runat="server" />
                    </dd>

                    <dt>Status</dt>
                    <dd>
                        <asp:Label ID="DetailState" runat="server" />
                    </dd>

                    <dt>Agenda</dt>
                    <dd class="meeting-agenda">
                        <asp:Label ID="DetailAgenda" runat="server" />
                    </dd>
                </dl>
            </div>

            <div class="meeting-dialog-actions">
                <button type="button"
                    class="meeting-btn meeting-btn-primary"
                    onclick="closeMeetingDialog('detailsDialog')">
                    Close details
                </button>
            </div>

        </dialog>

        <!-- نافذة رسائل النجاح والأخطاء -->

        <dialog id="noticeDialog"
            class="meeting-dialog meeting-dialog-small"
            aria-labelledby="noticeHeading"
            aria-describedby="noticeBody">

            <div class="meeting-dialog-header">
                <h2 id="noticeHeading">
                    <asp:Label ID="NoticeTitle" runat="server" />
                </h2>

                <button type="button"
                    class="meeting-close"
                    onclick="closeMeetingDialog('noticeDialog')"
                    aria-label="Close message">
                    ×
                </button>
            </div>

            <div class="meeting-dialog-body">
                <p id="noticeBody" role="status">
                    <asp:Label ID="NoticeText" runat="server" />
                </p>
            </div>

            <div class="meeting-dialog-actions">
                <button type="button"
                    class="meeting-btn meeting-btn-primary"
                    onclick="closeMeetingDialog('noticeDialog')">
                    Got it
                </button>
            </div>

        </dialog>

        <!-- نافذة الروم -->

        <dialog id="roomDialog"
            class="meeting-dialog meeting-room-dialog"
            aria-labelledby="roomHeading">

            <div class="meeting-dialog-header">
                <div>
                    <h2 id="roomHeading">Meeting room</h2>

                    <p>
                        Review your camera and microphone settings before joining.
                    </p>
                </div>

                <button type="button"
                    class="meeting-close"
                    onclick="closeMeetingDialog('roomDialog')"
                    aria-label="Leave and close meeting">
                    ×
                </button>
            </div>

            <p id="roomMessage"
                class="meeting-room-note"
                role="status"
                aria-live="polite">
                Preparing the meeting…
            </p>

            <div id="meetingRoomHost"
                class="meeting-room-host"></div>

            <div class="meeting-room-footer">
                <span class="meeting-hint">
                    The person starting the Jitsi room may need to sign in.
                </span>

                <a id="roomFallback"
                    class="meeting-btn meeting-btn-small"
                    target="_blank"
                    rel="noopener noreferrer">
                    Open separately if needed ↗
                </a>
            </div>

        </dialog>

        <script>
            (function () {
                'use strict';

                let pendingButton = null;

                const approvedButtons = new WeakSet();

                let apiPromise = null;

                let activeApi = null;

                let roomVersion = 0;

                window.showMeetingDialog = function (id) {
                    const dialog = document.getElementById(id);

                    if (dialog && !dialog.open) {
                        dialog.showModal();
                    }
                };

                window.closeMeetingDialog = function (id) {
                    const dialog = document.getElementById(id);

                    if (dialog && dialog.open) {
                        dialog.close();
                    }
                };

                const messages = {
                    send: [
                        'Send this request?',
                        'The invited person will receive your request. It stays pending until they approve.',
                        'Send request'
                    ],

                    accept: [
                        'Accept this meeting?',
                        'The requester will see your acceptance. Join becomes available during the joining window.',
                        'Accept meeting'
                    ],

                    reject: [
                        'Decline this request?',
                        'The request will move to your history and the requester will see your response.',
                        'Decline request'
                    ],

                    complete: [
                        'Mark meeting completed?',
                        'Confirm that the meeting actually took place and has finished. This is a manual completion record.',
                        'Mark completed'
                    ],

                    cancel: [
                        'Cancel this meeting?',
                        'The meeting will be cancelled for both people and kept in your history.',
                        'Cancel meeting'
                    ],

                    refresh: [
                        'Refresh the list?',
                        'Load the latest requests, responses, and join availability.',
                        'Refresh list'
                    ]
                };

                window.confirmMeetingAction = function (button, action) {
                    if (approvedButtons.has(button)) {
                        approvedButtons.delete(button);

                        return true;
                    }

                    const message = messages[action];

                    if (!message) {
                        return false;
                    }

                    pendingButton = button;

                    document.getElementById('confirmTitle')
                        .textContent = message[0];

                    document.getElementById('confirmText')
                        .textContent = message[1];

                    document.getElementById('confirmProceed')
                        .textContent = message[2];

                    showMeetingDialog('confirmDialog');

                    return false;
                };

                window.proceedMeetingAction = function () {
                    const button = pendingButton;

                    closeMeetingDialog('confirmDialog');

                    if (!button) {
                        return;
                    }

                    approvedButtons.add(button);

                    button.click();
                };

                document.getElementById('confirmDialog')
                    .addEventListener('close', function () {
                        pendingButton = null;
                    });

                document.querySelectorAll('.meeting-dialog')
                    .forEach(function (dialog) {
                        if (dialog.id === 'roomDialog') {
                            return;
                        }

                        dialog.addEventListener('click', function (event) {
                            const rectangle = dialog.getBoundingClientRect();

                            const outside =
                                event.clientX < rectangle.left ||
                                event.clientX > rectangle.right ||
                                event.clientY < rectangle.top ||
                                event.clientY > rectangle.bottom;

                            if (event.target === dialog && outside) {
                                dialog.close();
                            }
                        });
                    });

                function loadApi() {
                    if (window.JitsiMeetExternalAPI) {
                        return Promise.resolve();
                    }

                    if (!apiPromise) {
                        apiPromise = new Promise(function (resolve, reject) {
                            const script = document.createElement('script');

                            script.src =
                                'https://meet.jit.si/external_api.js';

                            script.onload = resolve;

                            script.onerror = function () {
                                script.remove();

                                reject(
                                    new Error('Meeting service unavailable')
                                );
                            };

                            document.head.appendChild(script);
                        }).catch(function (error) {
                            apiPromise = null;

                            throw error;
                        });
                    }

                    return apiPromise;
                }

                window.openMeetingRoom = async function (room) {
                    if (!/^UIMS-[a-f0-9]{32}$/.test(room)) {
                        return;
                    }

                    const version = ++roomVersion;

                    const message =
                        document.getElementById('roomMessage');

                    document.getElementById('roomFallback').href =
                        'https://meet.jit.si/' + encodeURIComponent(room);

                    message.textContent = 'Preparing the meeting…';

                    showMeetingDialog('roomDialog');

                    try {
                        await loadApi();

                        if (
                            version !== roomVersion ||
                            !document.getElementById('roomDialog').open
                        ) {
                            return;
                        }

                        if (activeApi) {
                            activeApi.dispose();
                        }

                        activeApi = new JitsiMeetExternalAPI(
                            'meet.jit.si',
                            {
                                roomName: room,

                                parentNode:
                                    document.getElementById('meetingRoomHost'),

                                width: '100%',

                                height: '100%',

                                userInfo: {
                                    displayName:
                                        document.getElementById(
                                            'meetingWorkspace'
                                        ).dataset.displayName
                                },

                                configOverwrite: {
                                    startWithAudioMuted: true,

                                    startWithVideoMuted: true
                                }
                            }
                        );

                        message.textContent =
                            'Follow the joining instructions below. The person starting the room may need to sign in.';

                        activeApi.addListener(
                            'videoConferenceJoined',
                            function () {
                                if (version === roomVersion) {
                                    message.textContent =
                                        'You have joined the meeting.';
                                }
                            }
                        );

                        activeApi.addListener(
                            'readyToClose',
                            function () {
                                if (version === roomVersion) {
                                    closeMeetingDialog('roomDialog');
                                }
                            }
                        );
                    } catch (error) {
                        if (version === roomVersion) {
                            message.textContent =
                                'Could not load the room. Try again or use Open separately if needed.';
                        }
                    }
                };

                document.getElementById('roomDialog')
                    .addEventListener('close', function () {
                        roomVersion++;

                        const api = activeApi;

                        activeApi = null;

                        if (api) {
                            api.dispose();
                        }

                        document.getElementById('meetingRoomHost')
                            .replaceChildren();
                    });

            }());
        </script>

    </div>

</asp:Content>

