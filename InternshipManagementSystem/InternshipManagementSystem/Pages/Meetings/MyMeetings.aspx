<%@ Page Language="C#" MasterPageFile="~/Layout/Public.master" AutoEventWireup="true" CodeBehind="MyMeetings.aspx.cs" Inherits="InternshipManagementSystem.Pages.MeetingsArea.MyMeetings" Title="My Meetings" %>
<%-- ===================================================================
     My Meetings
     Owner : Fatima
     Cards : F09 (OPTIONAL)
     Delete the placeholder below and build the page here.
     =================================================================== --%>


<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <style>
        .meeting-overlay {
            display: none;
            position: fixed;
            inset: 0;
            z-index: 2000;
            align-items: center;
            justify-content: center;
            padding: 16px;
            background: rgba(17, 24, 39, 0.45);
            -webkit-backdrop-filter: blur(5px);
            backdrop-filter: blur(5px);
        }

        .meeting-dialog {
            width: 100%;
            max-width: 800px;
            max-height: calc(100vh - 32px);
            overflow-y: auto;
            padding: 28px;
            background: var(--ui-surface,#fff);
            border-radius: 12px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.2);
        }

        .meeting-participants {
            border: 1px solid var(--th-line-dee2e6,#dee2e6);
            border-radius: 8px;
            padding: 16px;
        }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

    <div class="d-flex justify-content-between align-items-center flex-wrap gap-3 mb-4">
        <div>
            <h2 class="mb-1"><%: L.T("Meetings.MyMeetings.MyMeetings") %></h2>
            <p class="text-muted mb-0">
                <%: L.T("Meetings.MyMeetings.ViewYourScheduledMeetingsAndJoin") %>
            </p>
        </div>

        <button type="button" class="btn btn-brand"
            onclick="openMeetingForm()">
            <%: L.T("Meetings.MyMeetings.ScheduleMeeting") %>
        </button>
    </div>

    <div class="uims-card mb-4">
        <h3><%: L.T("Meetings.MyMeetings.UpcomingMeetings") %></h3>
        <p class="text-muted mb-0">
            <%: L.T("Meetings.MyMeetings.YouHaveNoUpcomingMeetingsYet") %>
        </p>
    </div>

    <div class="uims-card">
        <h3><%: L.T("Meetings.MyMeetings.PastMeetings") %></h3>
        <p class="text-muted mb-0">
            <%: L.T("Meetings.MyMeetings.YourPastMeetingsWillAppearHere") %>
        </p>
    </div>

    <%-- Schedule Meeting popup --%>
    <div id="meetingOverlay" class="meeting-overlay"
        role="dialog" aria-modal="true"
        aria-labelledby="meetingFormTitle"
        aria-hidden="true">

        <div class="meeting-dialog">
            <div class="d-flex justify-content-between align-items-start mb-4">
                <div>
                    <h2 id="meetingFormTitle" class="mb-1">
                        <%: L.T("Meetings.MyMeetings.ScheduleAMeeting") %>
                    </h2>
                    <p class="text-muted mb-0">
                        <%: L.T("Meetings.MyMeetings.EnterTheMeetingDetailsAndPaste") %>
                    </p>
                </div>

                <button type="button" class="btn btn-outline-secondary"
                    onclick="closeMeetingForm()" aria-label="<%: L.T("Meetings.MyMeetings.CloseForm") %>">
                    <%: L.T("Meetings.MyMeetings.Close") %>
                </button>
            </div>

            <div class="mb-3">
                <asp:Label ID="lblTitle" runat="server"
                    AssociatedControlID="txtTitle"
                    CssClass="form-label" Text="<%$ Resources:Meetings, MyMeetings.MeetingTitle %>" />
                <asp:TextBox ID="txtTitle" runat="server"
                    CssClass="form-control"
                    placeholder="<%$ Resources:Meetings, MyMeetings.EGInternshipProgressMeeting %>" />
            </div>

            <div class="mb-3">
                <asp:Label ID="lblAgenda" runat="server"
                    AssociatedControlID="txtAgenda"
                    CssClass="form-label" Text="<%$ Resources:Meetings, MyMeetings.Agenda %>" />
                <asp:TextBox ID="txtAgenda" runat="server"
                    CssClass="form-control" TextMode="MultiLine"
                    Rows="3" placeholder="<%$ Resources:Meetings, MyMeetings.WhatWillYouDiscuss %>" />
            </div>

            <div class="row">
                <div class="col-md-6 mb-3">
                    <asp:Label ID="lblScheduledAt" runat="server"
                        AssociatedControlID="txtScheduledAt"
                        CssClass="form-label" Text="<%$ Resources:Meetings, MyMeetings.DateAndTime %>" />
                    <asp:TextBox ID="txtScheduledAt" runat="server"
                        CssClass="form-control"
                        TextMode="DateTimeLocal" />
                </div>

                <div class="col-md-6 mb-3">
                    <asp:Label ID="lblDuration" runat="server"
                        AssociatedControlID="ddlDuration"
                        CssClass="form-label" Text="<%$ Resources:Meetings, MyMeetings.Duration %>" />
                    <asp:DropDownList ID="ddlDuration" runat="server"
                        CssClass="form-select">
                        <asp:ListItem Text="<%$ Resources:Meetings, MyMeetings.30Minutes %>" Value="30" />
                        <asp:ListItem Text="<%$ Resources:Meetings, MyMeetings.45Minutes %>" Value="45" />
                        <asp:ListItem Text="<%$ Resources:Meetings, MyMeetings.60Minutes %>" Value="60" />
                    </asp:DropDownList>
                </div>
            </div>

            <div class="mb-3">
                <asp:Label ID="lblParticipants" runat="server"
                    CssClass="form-label" Text="<%$ Resources:Meetings, MyMeetings.Participants %>" />

                <div class="meeting-participants">
                    <asp:CheckBoxList ID="cblParticipants"
                        runat="server" />

                    <p class="text-muted mb-0">
                        <%: L.T("Meetings.MyMeetings.AvailableParticipantsWillAppearHereAfter") %>
                    </p>
                </div>
            </div>

            <div class="mb-4">
                <asp:Label ID="lblJoinUrl" runat="server"
                    AssociatedControlID="txtJoinUrl"
                    CssClass="form-label" Text="<%$ Resources:Meetings, MyMeetings.ZoomMeetingLink %>" />
                <asp:TextBox ID="txtJoinUrl" runat="server"
                    CssClass="form-control" TextMode="Url"
                    placeholder="https://zoom.us/j/..." />
            </div>

            <div class="d-flex gap-2">
                <asp:Button ID="btnSchedule" runat="server"
                    Text="<%$ Resources:Meetings, MyMeetings.ScheduleMeeting2 %>"
                    CssClass="btn btn-brand"
                    OnClientClick="showMeetingPreview(); return false;" />

                <button type="button"
                    class="btn btn-outline-secondary"
                    onclick="closeMeetingForm()">
                    <%: L.T("Meetings.MyMeetings.Cancel") %>
                </button>
            </div>

            <div id="meetingPreviewNotice"
                class="alert alert-info mt-3"
                style="display: none;" role="status">
                <%: L.T("Meetings.MyMeetings.ThisIsADesignPreviewNo") %>
            </div>
        </div>
    </div>

    <script>
function openMeetingForm() {
    var overlay = document.getElementById("meetingOverlay");
    if (!overlay) return;

    overlay.style.display = "flex";
    overlay.setAttribute("aria-hidden", "false");
    document.body.style.overflow = "hidden";
}

function closeMeetingForm() {
    var overlay = document.getElementById("meetingOverlay");
    if (!overlay) return;

    overlay.style.display = "none";
    overlay.setAttribute("aria-hidden", "true");
    document.body.style.overflow = "";

    var notice = document.getElementById("meetingPreviewNotice");
    if (notice) notice.style.display = "none";
}

function showMeetingPreview() {
    var notice = document.getElementById("meetingPreviewNotice");
    if (notice) notice.style.display = "block";
}

document.addEventListener("keydown", function (event) {
    if (event.key === "Escape") closeMeetingForm();
});
</script>

</asp:Content>