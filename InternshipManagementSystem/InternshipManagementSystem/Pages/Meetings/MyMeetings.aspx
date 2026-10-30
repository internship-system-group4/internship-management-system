<%@ Page CodePage="65001" Language="C#"
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
            text-align: start;
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

        /* People picker in the request pop-up: one field that opens a searchable list. */
        .mp-native { position: absolute; width: 1px; height: 1px; opacity: 0; pointer-events: none; }
        .mp { position: relative; }
        .mp-toggle { display: flex; align-items: center; gap: 12px; width: 100%; min-height: 56px; padding: 8px 14px; font: inherit; text-align: start; color: var(--ui-muted); background: var(--ui-surface,#fff); border: 1px solid var(--ui-control-border,var(--border)); border-radius: 14px; cursor: pointer; transition: border-color .2s, box-shadow .2s; }
        .mp-toggle:hover { border-color: var(--ui-primary); }
        .mp.is-open .mp-toggle, .mp-toggle:focus-visible { border-color: var(--ui-primary); box-shadow: 0 0 0 4px var(--ui-primary-soft); outline: none; }
        .mp.has-choice .mp-toggle { color: var(--ui-ink); font-weight: 650; }
        .mp-summary { flex: 1; min-width: 0; overflow: hidden; white-space: nowrap; text-overflow: ellipsis; }
        .mp-avatar { display: grid; place-items: center; flex: none; width: 38px; height: 38px; border-radius: 50%; font-size: 14px; font-weight: 700; color: var(--ui-primary-text,var(--ui-primary)); background: var(--ui-primary-soft); }
        .mp-caret { width: 9px; height: 9px; border-inline-end: 2px solid var(--ui-muted); border-bottom: 2px solid var(--ui-muted); transform: translateY(-2px) rotate(45deg); transition: transform .25s; }
        .mp.is-open .mp-caret { transform: translateY(2px) rotate(-135deg); }
        .mp-panel { margin-top: 8px; padding: 10px; border: 1px solid var(--border); border-radius: 16px; background: var(--ui-surface,#fff); box-shadow: 0 24px 50px -28px rgba(10,30,55,.45); animation: mpOpen .22s cubic-bezier(.16,1,.3,1); }
        .mp-panel[hidden] { display: none; }
        .mp-search { margin-bottom: 8px; }
        .mp-list { max-height: 232px; margin: 0; padding: 0; overflow-y: auto; list-style: none; }
        .mp-list li { display: flex; align-items: center; gap: 12px; padding: 8px 10px; border-radius: 12px; cursor: pointer; transition: background-color .15s; }
        .mp-list li:hover, .mp-list li:focus-visible { background: var(--ui-neutral-soft); outline: none; }
        .mp-list li[aria-selected="true"] { background: var(--ui-primary-soft); }
        .mp-name { min-width: 0; }
        .mp-name strong { display: block; color: var(--ui-ink); font-weight: 650; }
        .mp-name small { display: block; color: var(--ui-muted); }
        .mp-empty { margin: 0; padding: 14px; text-align: center; color: var(--ui-muted); }
        @keyframes mpOpen { from { opacity: 0; transform: translateY(-6px); } to { opacity: 1; transform: none; } }
        @media (prefers-reduced-motion: reduce) { .mp-panel { animation: none; } .mp-caret, .mp-toggle { transition: none; } }

        .meeting-search {
            max-width: 270px;
        }

        .meeting-search-empty {
            padding: 14px 24px;
            color: var(--muted);
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

        /* Pop-ups: same look as the coordinator pop-ups (soft header, rounded fields, pill buttons). */
        body.uims-portal .meeting-dialog { border: 0; border-radius: 22px; box-shadow: 0 30px 80px -24px rgba(10,30,55,.45); }
        body.uims-portal .meeting-dialog[open] { animation: meetingPop .32s cubic-bezier(.16,1,.3,1); }
        body.uims-portal .meeting-dialog-header { padding: 22px 28px; background: linear-gradient(120deg,var(--ui-primary-soft),var(--ui-surface,#fff) 70%); }
        body.uims-portal .uims-main-inner .meeting-dialog-header h2 { font-size: 22px; line-height: 1.3; }
        body.uims-portal .meeting-dialog-header p { font-size: 15px; }
        body.uims-portal .meeting-close { border-radius: 50%; }
        body.uims-portal .meeting-form { padding: 24px 28px; gap: 18px 20px; }
        body.uims-portal .meeting-label { font-size: 15px !important; font-weight: 700; color: var(--ui-ink); }
        body.uims-portal .meeting-control { border-radius: 12px; min-height: 48px; }
        body.uims-portal .meeting-control:focus { border-color: var(--ui-primary); box-shadow: 0 0 0 4px var(--ui-primary-soft); outline: none; }
        body.uims-portal .meeting-hint { font-size: 14px !important; }
        body.uims-portal .meeting-help { border-radius: 12px; font-size: 15px; background: var(--ui-primary-soft); }
        body.uims-portal .meeting-dialog-actions { padding: 16px 28px; background: var(--ui-canvas,var(--ui-neutral-soft)); }
        body.uims-portal .meeting-dialog .meeting-btn { border-radius: 999px; padding-inline: 1.3rem; }
        @keyframes meetingPop { from { opacity: 0; transform: translateY(18px) scale(.97); } to { opacity: 1; transform: none; } }

        @media (prefers-reduced-motion: reduce) {
            .meeting-dialog[open], body.uims-portal .meeting-dialog[open] {
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
                <p class="meeting-eyebrow"><%: L.T("Meetings.MyMeetings.InternshipWorkspace") %></p>

                <h1><%: L.T("Meetings.MyMeetings.MyMeetings") %></h1>

                <p>
                    <%: L.T("Meetings.MyMeetings.RequestAConversationRespondToInvitations") %>
                </p>
            </div>

            <button type="button"
                class="meeting-btn meeting-btn-primary"
                onclick="showMeetingDialog('requestDialog')">
                <%: L.T("Meetings.MyMeetings.RequestAMeeting") %>
            </button>
        </header>

        <div class="meeting-stats" aria-label="<%: L.T("Meetings.MyMeetings.MeetingOverview") %>">

            <div class="meeting-stat">
                <asp:Label ID="IncomingCount"
                    runat="server"
                    CssClass="meeting-stat-number"
                    Text="0" />

                <span class="meeting-stat-label"><%: L.T("Meetings.MyMeetings.WaitingForYou") %></span>

                <small><%: L.T("Meetings.MyMeetings.RequestsNeedingYourResponse") %></small>
            </div>

            <div class="meeting-stat">
                <asp:Label ID="SentCount"
                    runat="server"
                    CssClass="meeting-stat-number"
                    Text="0" />

                <span class="meeting-stat-label"><%: L.T("Meetings.MyMeetings.RequestsSent") %></span>

                <small><%: L.T("Meetings.MyMeetings.WaitingForTheOtherPerson") %></small>
            </div>

            <div class="meeting-stat">
                <asp:Label ID="UpcomingCount"
                    runat="server"
                    CssClass="meeting-stat-number"
                    Text="0" />

                <span class="meeting-stat-label"><%: L.T("Meetings.MyMeetings.ApprovedMeetings") %></span>

                <small><%: L.T("Meetings.MyMeetings.UpcomingOrInProgress") %></small>
            </div>

            <div class="meeting-stat">
                <asp:Label ID="HistoryCount"
                    runat="server"
                    CssClass="meeting-stat-number"
                    Text="0" />

                <span class="meeting-stat-label"><%: L.T("Meetings.MyMeetings.InYourHistory") %></span>

                <small><%: L.T("Meetings.MyMeetings.PastCompletedOrClosed") %></small>
            </div>

        </div>

        <section class="meeting-panel"
            aria-labelledby="meetingListTitle">

            <div class="meeting-panel-heading">
                <div>
                    <h2 id="meetingListTitle"><%: L.T("Meetings.MyMeetings.MeetingsRequests") %></h2>

                    <p>
                        <%: L.T("Meetings.MyMeetings.OpenTheDetailsRespondToA") %>
                    </p>
                </div>

                <div class="meeting-toolbar">
                    <label class="meeting-search">
                        <span class="visually-hidden"><%: L.T("Meetings.MyMeetings.SearchMeetings") %></span>
                        <input id="meetingSearch" type="search" class="meeting-control"
                            autocomplete="off" placeholder="<%: L.T("Meetings.MyMeetings.SearchMeetings") %>" />
                    </label>
                    <button type="button"
                        class="meeting-btn"
                        onclick="showMeetingDialog('filterDialog')">
                        <%: L.T("Meetings.MyMeetings.ChangeView") %>
                    </button>

                    <asp:Button ID="RefreshButton"
                        runat="server"
                        Text="<%$ Resources:Meetings, MyMeetings.RefreshList %>"
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
                        Text="<%$ Resources:Meetings, MyMeetings.AllMyMeetings %>" />
                </strong>

                <span class="meeting-live-note">
                    <%: L.T("Meetings.MyMeetings.TimesShownInJordanLocalTime") %>
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

                        <asp:TemplateField HeaderText="<%$ Resources:Meetings, MyMeetings.Meeting %>">
                            <ItemTemplate>
                                <strong data-meeting-views='<%#: Eval("ViewGroups") %>' data-initial-view='<%#: Eval("MatchesView") %>'><%#: Eval("Title") %></strong>

                                <div class="meeting-subtext">
                                    <%#: Eval("DurationText") %>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="<%$ Resources:Meetings, MyMeetings.People %>">
                            <ItemTemplate>
                                <div>
                                    <strong><%: L.T("Meetings.MyMeetings.From") %></strong>
                                    <%#: Eval("FromName") %>
                                </div>

                                <div class="meeting-subtext">
                                    <strong><%: L.T("Meetings.MyMeetings.To") %></strong>
                                    <%#: Eval("ToName") %>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField DataField="DateText"
                            HeaderText="<%$ Resources:Meetings, MyMeetings.DateTime %>"
                            HtmlEncode="true" />

                        <asp:TemplateField HeaderText="<%$ Resources:Meetings, MyMeetings.Status %>">
                            <ItemTemplate>
                                <span class="meeting-status"
                                    data-state='<%#: Eval("StateText") %>'>
                                    <%#: L.Value("Ui", Eval("StateText")) %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="<%$ Resources:Meetings, MyMeetings.Actions %>">
                            <ItemTemplate>

                                <div class="meeting-actions">

                                    <asp:LinkButton runat="server"
                                        Text="<%$ Resources:Meetings, MyMeetings.Details %>"
                                        CssClass="meeting-btn meeting-btn-small"
                                        CommandName="Details"
                                        CommandArgument='<%# Eval("Id") %>'
                                        CausesValidation="false" />

                                    <asp:LinkButton runat="server"
                                        Text="<%$ Resources:Meetings, MyMeetings.Accept %>"
                                        CssClass="meeting-btn meeting-btn-small meeting-btn-primary"
                                        CommandName="Accept"
                                        CommandArgument='<%# Eval("Id") %>'
                                        Visible='<%# Eval("CanRespond") %>'
                                        OnClientClick="return confirmMeetingAction(this,'accept');"
                                        CausesValidation="false" />

                                    <asp:LinkButton runat="server"
                                        Text="<%$ Resources:Meetings, MyMeetings.Decline %>"
                                        CssClass="meeting-btn meeting-btn-small meeting-btn-danger"
                                        CommandName="Reject"
                                        CommandArgument='<%# Eval("Id") %>'
                                        Visible='<%# Eval("CanRespond") %>'
                                        OnClientClick="return confirmMeetingAction(this,'reject');"
                                        CausesValidation="false" />

                                    <asp:LinkButton runat="server"
                                        Text="<%$ Resources:Meetings, MyMeetings.JoinMeeting %>"
                                        CssClass="meeting-btn meeting-btn-small meeting-btn-primary"
                                        CommandName="Join"
                                        CommandArgument='<%# Eval("Id") %>'
                                        Visible='<%# Eval("CanJoin") %>'
                                        CausesValidation="false" />

                                    <asp:LinkButton runat="server"
                                        Text="<%$ Resources:Meetings, MyMeetings.MarkCompleted %>"
                                        CssClass="meeting-btn meeting-btn-small"
                                        CommandName="Complete"
                                        CommandArgument='<%# Eval("Id") %>'
                                        Visible='<%# Eval("CanComplete") %>'
                                        OnClientClick="return confirmMeetingAction(this,'complete');"
                                        CausesValidation="false" />

                                    <asp:LinkButton runat="server"
                                        Text="<%$ Resources:Meetings, MyMeetings.CancelMeeting %>"
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
                            <strong><%: L.T("Meetings.MyMeetings.NoMeetingsInThisView") %></strong>

                            <%: L.T("Meetings.MyMeetings.ChooseAnotherViewOrSendYour") %>

                            <br />

                            <button type="button"
                                class="meeting-btn"
                                style="margin-top: 16px"
                                onclick="showMeetingDialog('requestDialog')">
                                <%: L.T("Meetings.MyMeetings.RequestAMeeting2") %>
                            </button>
                        </div>
                    </EmptyDataTemplate>

                </asp:GridView>

            </div>

            <p id="meetingSearchEmpty" class="meeting-search-empty" hidden><%: L.T("Meetings.MyMeetings.NoMeetingsMatch") %></p>

            <p class="meeting-footer-note">
                <%: L.T("Meetings.MyMeetings.RequestsNeedTheInvitedPersonS") %>
            </p>

        </section>

        <!-- نافذة إنشاء طلب ميتنج -->

        <dialog id="requestDialog"
            class="meeting-dialog"
            aria-labelledby="requestTitle">

            <div class="meeting-dialog-header">
                <div>
                    <h2 id="requestTitle"><%: L.T("Meetings.MyMeetings.RequestAMeeting2") %></h2>

                    <p>
                        <%: L.T("Meetings.MyMeetings.ChooseAPersonAndSuggestA") %>
                    </p>
                </div>

                <button type="button"
                    class="meeting-close"
                    onclick="closeMeetingDialog('requestDialog')"
                    aria-label="<%: L.T("Meetings.MyMeetings.CloseRequestForm") %>">
                    <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="m6 6 12 12M6 18 18 6" /></svg>
                </button>
            </div>

            <div class="meeting-form">

                <div>
                    <asp:Label runat="server"
                        AssociatedControlID="MeetingTitle"
                        CssClass="meeting-label"
                        Text="<%$ Resources:Meetings, MyMeetings.MeetingTitle2 %>" />

                    <asp:TextBox ID="MeetingTitle"
                        runat="server"
                        CssClass="meeting-control"
                        MaxLength="150"
                        placeholder="<%$ Resources:Meetings, MyMeetings.EGInternshipProgressReview %>" />
                </div>

                <div class="meeting-wide">
                    <span class="meeting-label" id="recipientLabel"><%: L.T("Meetings.MyMeetings.WhoWouldYouLikeToMeet") %></span>

                    <%-- People picker: one field that opens a searchable list. The hidden
                         drop-down below still carries the chosen person to the server. --%>
                    <div class="mp" data-mp>
                        <button type="button" class="mp-toggle" aria-expanded="false" aria-controls="mpPanel" aria-labelledby="recipientLabel mpSummary">
                            <span class="mp-avatar" data-mp-avatar aria-hidden="true">?</span>
                            <span class="mp-summary" id="mpSummary" data-mp-summary><%: L.T("Meetings.MyMeetings.SelectAPerson") %></span>
                            <span class="mp-caret" aria-hidden="true"></span>
                        </button>
                        <div class="mp-panel" id="mpPanel" hidden>
                            <label for="recipientSearch" class="visually-hidden"><%: L.T("Meetings.MyMeetings.SearchPeople") %></label>
                            <input id="recipientSearch" type="search" class="meeting-control mp-search" autocomplete="off" placeholder="<%: L.T("Meetings.MyMeetings.SearchPeople") %>" />
                            <ul class="mp-list" role="listbox" aria-labelledby="recipientLabel" data-mp-list></ul>
                            <p class="mp-empty" data-mp-empty hidden><%: L.T("Meetings.MyMeetings.NoPeopleMatch") %></p>
                        </div>
                    </div>
                    <asp:DropDownList ID="Recipient" runat="server" CssClass="mp-native" tabindex="-1" aria-hidden="true" />
                    <span id="recipientCount" class="meeting-hint" aria-live="polite"></span>
                </div>

                <div>
                    <asp:Label runat="server"
                        AssociatedControlID="MeetingDate"
                        CssClass="meeting-label"
                        Text="<%$ Resources:Meetings, MyMeetings.DateAndTime2 %>" />

                    <asp:TextBox ID="MeetingDate"
                        runat="server"
                        TextMode="DateTimeLocal"
                        CssClass="meeting-control"
                        aria-describedby="dateHint" />

                    <span id="dateHint" class="meeting-hint">
                        <%: L.T("Meetings.MyMeetings.UseJordanLocalTime") %>
                    </span>
                </div>

                <div>
                    <asp:Label runat="server"
                        AssociatedControlID="Duration"
                        CssClass="meeting-label"
                        Text="<%$ Resources:Meetings, MyMeetings.Duration %>" />

                    <asp:DropDownList ID="Duration"
                        runat="server"
                        CssClass="meeting-control">

                        <asp:ListItem Value="15" Text="<%$ Resources:Meetings, I18n.15minutes %>" />

                        <asp:ListItem Value="30" Selected="True" Text="<%$ Resources:Meetings, MyMeetings.30Minutes %>" />

                        <asp:ListItem Value="45" Text="<%$ Resources:Meetings, MyMeetings.45Minutes %>" />

                        <asp:ListItem Value="60" Text="<%$ Resources:Meetings, MyMeetings.60Minutes %>" />

                    </asp:DropDownList>
                </div>

                <div class="meeting-wide">
                    <asp:Label runat="server"
                        AssociatedControlID="Agenda"
                        CssClass="meeting-label"
                        Text="<%$ Resources:Meetings, MyMeetings.AgendaOptional %>" />

                    <asp:TextBox ID="Agenda"
                        runat="server"
                        TextMode="MultiLine"
                        Rows="3"
                        CssClass="meeting-control"
                        placeholder="<%$ Resources:Meetings, MyMeetings.WhatWouldYouLikeToDiscuss %>" />
                </div>

                <div class="meeting-wide meeting-help">
                    <%: L.T("Meetings.MyMeetings.OnlyPeopleLinkedToYourInternship") %>
                </div>

            </div>

            <div class="meeting-dialog-actions">
                <button type="button"
                    class="meeting-btn"
                    onclick="closeMeetingDialog('requestDialog')">
                    <%: L.T("Meetings.MyMeetings.KeepEditingLater") %>
                </button>

                <asp:Button ID="SendRequest"
                    runat="server"
                    Text="<%$ Resources:Meetings, MyMeetings.SendRequest %>"
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
                <h2 id="filterTitle"><%: L.T("Meetings.MyMeetings.ChooseAView") %></h2>

                <button type="button"
                    class="meeting-close"
                    onclick="closeMeetingDialog('filterDialog')"
                    aria-label="<%: L.T("Meetings.MyMeetings.CloseViewSelector") %>">
                    <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="m6 6 12 12M6 18 18 6" /></svg>
                </button>
            </div>

            <div class="meeting-dialog-body">
                <asp:Label runat="server"
                    AssociatedControlID="MeetingFilter"
                    CssClass="meeting-label"
                    Text="<%$ Resources:Meetings, MyMeetings.ShowMeetings %>" />

                <asp:DropDownList ID="MeetingFilter"
                    runat="server"
                    CssClass="meeting-control">

                    <asp:ListItem Value="all" Text="<%$ Resources:Meetings, I18n.Allmymeetingsandrequests %>" />

                    <asp:ListItem Value="incoming" Text="<%$ Resources:Meetings, I18n.Waitingformyapproval %>" />

                    <asp:ListItem Value="sent" Text="<%$ Resources:Meetings, I18n.RequestsIsentpending %>" />

                    <asp:ListItem Value="upcoming" Text="<%$ Resources:Meetings, MyMeetings.ApprovedMeetings %>" />

                    <asp:ListItem Value="history" Text="<%$ Resources:Meetings, I18n.Meetinghistory %>" />

                </asp:DropDownList>
            </div>

            <div class="meeting-dialog-actions">
                <button type="button"
                    class="meeting-btn"
                    onclick="closeMeetingDialog('filterDialog')">
                    <%: L.T("Meetings.MyMeetings.Cancel") %>
                </button>

                <asp:Button ID="ApplyFilter"
                    runat="server"
                    Text="<%$ Resources:Meetings, MyMeetings.ApplyView %>"
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
                <h2 id="confirmTitle"><%: L.T("Meetings.MyMeetings.ConfirmAction") %></h2>

                <button type="button"
                    class="meeting-close"
                    onclick="closeMeetingDialog('confirmDialog')"
                    aria-label="<%: L.T("Meetings.MyMeetings.CloseConfirmation") %>">
                    <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="m6 6 12 12M6 18 18 6" /></svg>
                </button>
            </div>

            <div class="meeting-dialog-body">
                <p id="confirmText"></p>
            </div>

            <div class="meeting-dialog-actions">
                <button type="button"
                    class="meeting-btn"
                    onclick="closeMeetingDialog('confirmDialog')">
                    <%: L.T("Meetings.MyMeetings.GoBack") %>
                </button>

                <button type="button"
                    id="confirmProceed"
                    class="meeting-btn meeting-btn-primary"
                    onclick="proceedMeetingAction()">
                    <%: L.T("Meetings.MyMeetings.Confirm") %>
                </button>
            </div>

        </dialog>

        <!-- نافذة تفاصيل الميتنج -->

        <dialog id="detailsDialog"
            class="meeting-dialog"
            aria-labelledby="detailsHeading">

            <div class="meeting-dialog-header">
                <h2 id="detailsHeading"><%: L.T("Meetings.MyMeetings.MeetingDetails") %></h2>

                <button type="button"
                    class="meeting-close"
                    onclick="closeMeetingDialog('detailsDialog')"
                    aria-label="<%: L.T("Meetings.MyMeetings.CloseMeetingDetails") %>">
                    <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="m6 6 12 12M6 18 18 6" /></svg>
                </button>
            </div>

            <div class="meeting-dialog-body meeting-details">
                <dl>
                    <dt><%: L.T("Meetings.MyMeetings.Title") %></dt>
                    <dd>
                        <asp:Label ID="DetailTitle" runat="server" />
                    </dd>

                    <dt><%: L.T("Meetings.MyMeetings.People") %></dt>
                    <dd>
                        <asp:Label ID="DetailPeople" runat="server" />
                    </dd>

                    <dt><%: L.T("Meetings.MyMeetings.When") %></dt>
                    <dd>
                        <asp:Label ID="DetailTime" runat="server" />
                    </dd>

                    <dt><%: L.T("Meetings.MyMeetings.Status") %></dt>
                    <dd>
                        <asp:Label ID="DetailState" runat="server" />
                    </dd>

                    <dt><%: L.T("Meetings.MyMeetings.Agenda") %></dt>
                    <dd class="meeting-agenda">
                        <asp:Label ID="DetailAgenda" runat="server" />
                    </dd>
                </dl>
            </div>

            <div class="meeting-dialog-actions">
                <button type="button"
                    class="meeting-btn meeting-btn-primary"
                    onclick="closeMeetingDialog('detailsDialog')">
                    <%: L.T("Meetings.MyMeetings.CloseDetails") %>
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
                    aria-label="<%: L.T("Meetings.MyMeetings.CloseMessage") %>">
                    <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="m6 6 12 12M6 18 18 6" /></svg>
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
                    <%: L.T("Meetings.MyMeetings.GotIt") %>
                </button>
            </div>

        </dialog>

        <!-- نافذة الروم -->

        <dialog id="roomDialog"
            class="meeting-dialog meeting-room-dialog"
            aria-labelledby="roomHeading">

            <div class="meeting-dialog-header">
                <div>
                    <h2 id="roomHeading"><%: L.T("Meetings.MyMeetings.MeetingRoom") %></h2>

                    <p>
                        <%: L.T("Meetings.MyMeetings.ReviewYourCameraAndMicrophoneSettings") %>
                    </p>
                </div>

                <button type="button"
                    class="meeting-close"
                    onclick="closeMeetingDialog('roomDialog')"
                    aria-label="<%: L.T("Meetings.MyMeetings.LeaveAndCloseMeeting") %>">
                    <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="m6 6 12 12M6 18 18 6" /></svg>
                </button>
            </div>

            <p id="roomMessage"
                class="meeting-room-note"
                role="status"
                aria-live="polite">
                <%: L.T("Meetings.MyMeetings.PreparingTheMeeting") %>
            </p>

            <div id="meetingRoomHost"
                class="meeting-room-host"></div>

            <div class="meeting-room-footer">
                <span class="meeting-hint">
                    <%: L.T("Meetings.MyMeetings.ThePersonStartingTheJitsiRoom") %>
                </span>

                <a id="roomFallback"
                    class="meeting-btn meeting-btn-small"
                    target="_blank"
                    rel="noopener noreferrer">
                    <%: L.T("Meetings.MyMeetings.OpenSeparatelyIfNeeded") %>
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

                const recipient = document.getElementById('<%= Recipient.ClientID %>');
                const recipientSearch = document.getElementById('recipientSearch');
                const recipientCount = document.getElementById('recipientCount');
                const picker = document.querySelector('[data-mp]');
                const pickerToggle = picker.querySelector('.mp-toggle');
                const pickerPanel = picker.querySelector('.mp-panel');
                const pickerList = picker.querySelector('[data-mp-list]');
                const pickerEmpty = picker.querySelector('[data-mp-empty]');
                const pickerSummary = picker.querySelector('[data-mp-summary]');
                const pickerAvatar = picker.querySelector('[data-mp-avatar]');
                const placeholderText = recipient.options.length ? recipient.options[0].text : '';

                // Each option reads "Full Name - Role".
                function personOf(option) {
                    const cut = option.text.lastIndexOf(' - ');
                    const name = cut > 0 ? option.text.slice(0, cut) : option.text;
                    const role = cut > 0 ? option.text.slice(cut + 3) : '';
                    const parts = name.trim().split(/\s+/).filter(function (w) { return /^\p{L}/u.test(w); });
                    const initials = ((parts[0] || '?').charAt(0) + (parts.length > 1 ? parts[parts.length - 1].charAt(0) : '')).toUpperCase();
                    return { value: option.value, name: name, role: role, initials: initials };
                }
                const people = Array.from(recipient.options).filter(function (o) { return o.value; }).map(personOf);

                function showChoice() {
                    const chosen = people.find(function (p) { return p.value === recipient.value; });
                    picker.classList.toggle('has-choice', !!chosen);
                    pickerAvatar.textContent = chosen ? chosen.initials : '?';
                    pickerSummary.textContent = chosen ? chosen.name + (chosen.role ? ' · ' + chosen.role : '') : placeholderText;
                }

                function openPicker(open) {
                    pickerPanel.hidden = !open;
                    picker.classList.toggle('is-open', open);
                    pickerToggle.setAttribute('aria-expanded', open ? 'true' : 'false');
                    if (open) { recipientSearch.value = ''; filterRecipients(); recipientSearch.focus(); }
                }

                function filterRecipients() {
                    const query = recipientSearch.value.trim().toLocaleLowerCase();
                    pickerList.replaceChildren();
                    let shown = 0;
                    people.forEach(function (person) {
                        if (query && (person.name + ' ' + person.role).toLocaleLowerCase().indexOf(query) < 0) return;
                        shown++;
                        const item = document.createElement('li');
                        item.setAttribute('role', 'option');
                        item.tabIndex = 0;
                        item.dataset.value = person.value;
                        item.setAttribute('aria-selected', person.value === recipient.value ? 'true' : 'false');
                        const avatar = document.createElement('span');
                        avatar.className = 'mp-avatar';
                        avatar.textContent = person.initials;
                        avatar.setAttribute('aria-hidden', 'true');
                        const text = document.createElement('span');
                        text.className = 'mp-name';
                        const strong = document.createElement('strong');
                        strong.textContent = person.name;
                        const small = document.createElement('small');
                        small.textContent = person.role;
                        text.append(strong, small);
                        item.append(avatar, text);
                        pickerList.append(item);
                    });
                    pickerEmpty.hidden = shown > 0;
                    recipientCount.textContent = people.length + ' <%: L.T("Meetings.MyMeetings.PeopleAvailable") %>';
                }

                function choose(item) {
                    recipient.value = item.dataset.value;
                    showChoice();
                    openPicker(false);
                    pickerToggle.focus();
                }

                pickerToggle.addEventListener('click', function () { openPicker(pickerPanel.hidden); });
                pickerList.addEventListener('click', function (event) {
                    const item = event.target.closest('[role="option"]');
                    if (item) choose(item);
                });
                pickerList.addEventListener('keydown', function (event) {
                    const item = event.target.closest('[role="option"]');
                    if (!item) return;
                    if (event.key === 'Enter' || event.key === ' ') { event.preventDefault(); choose(item); }
                    else if (event.key === 'ArrowDown' && item.nextElementSibling) { event.preventDefault(); item.nextElementSibling.focus(); }
                    else if (event.key === 'ArrowUp') { event.preventDefault(); (item.previousElementSibling || recipientSearch).focus(); }
                });
                recipientSearch.addEventListener('keydown', function (event) {
                    if (event.key === 'ArrowDown' && pickerList.firstElementChild) { event.preventDefault(); pickerList.firstElementChild.focus(); }
                    else if (event.key === 'Enter') { event.preventDefault(); if (pickerList.firstElementChild) choose(pickerList.firstElementChild); }
                });
                picker.addEventListener('keydown', function (event) {
                    if (event.key === 'Escape' && !pickerPanel.hidden) { event.preventDefault(); event.stopPropagation(); openPicker(false); pickerToggle.focus(); }
                });
                document.addEventListener('click', function (event) { if (!picker.contains(event.target)) openPicker(false); });

                recipientSearch.addEventListener('input', filterRecipients);
                filterRecipients();
                showChoice();


                const meetingSearch = document.getElementById('meetingSearch');
                const meetingRows = Array.from(document.querySelectorAll('#<%= MeetingGrid.ClientID %> tr'))
                    .filter(function (row) { return row.querySelector('td') && !row.querySelector('.meeting-empty'); });
                const meetingSearchEmpty = document.getElementById('meetingSearchEmpty');
                meetingSearch.addEventListener('input', function () {
                    const query = meetingSearch.value.trim().toLocaleLowerCase();
                    let visible = 0;
                    meetingRows.forEach(function (row) {
                        const matches = row.textContent.toLocaleLowerCase().includes(query);
                        row.hidden = !matches;
                        if (matches) visible++;
                    });
                    meetingSearchEmpty.hidden = !query || visible > 0 || meetingRows.length === 0;
                });


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
                        uimsT('ArabicSendthisrequest'),
                        uimsT('ArabicTheinvitedpersonwillreceiveyourrequestIt'),
                        uimsT('ArabicSendrequest')
                    ],

                    accept: [
                        uimsT('ArabicAcceptthismeeting'),
                        uimsT('ArabicTherequesterwillseeyouracceptanceJoinbecomes'),
                        uimsT('ArabicAcceptmeeting')
                    ],

                    reject: [
                        uimsT('ArabicDeclinethisrequest'),
                        uimsT('ArabicTherequestwillmovetoyourhistoryand'),
                        uimsT('ArabicDeclinerequest')
                    ],

                    complete: [
                        uimsT('ArabicMarkmeetingcompleted'),
                        uimsT('ArabicConfirmthatthemeetingactuallytookplaceand'),
                        uimsT('ArabicMarkcompleted')
                    ],

                    cancel: [
                        uimsT('ArabicCancelthismeeting'),
                        uimsT('ArabicThemeetingwillbecancelledforbothpeople'),
                        uimsT('ArabicCancelmeeting')
                    ],

                    refresh: [
                        uimsT('ArabicRefreshthelist'),
                        uimsT('ArabicLoadthelatestrequestsresponsesandjoinavailability'),
                        uimsT('ArabicRefreshlist')
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
                                    new Error(uimsT('ArabicMeetingserviceunavailable'))
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

                    message.textContent = uimsT('ArabicPreparingthemeeting');

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
                            uimsT('ArabicFollowthejoininginstructionsbelowThepersonstarting');

                        activeApi.addListener(
                            'videoConferenceJoined',
                            function () {
                                if (version === roomVersion) {
                                    message.textContent =
                                        uimsT('ArabicYouhavejoinedthemeeting');
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
                                uimsT('ArabicCouldnotloadtheroomTryagainor');
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

