<%@ Page Language="C#" MasterPageFile="~/Layout/Public.master" AutoEventWireup="true" CodeBehind="Schedule.aspx.cs" Inherits="InternshipManagementSystem.Pages.MeetingsArea.Schedule" Title="Schedule a Meeting" %>
<%-- ===================================================================
     Schedule a Meeting
     Owner : Fatima
     Cards : F08, F10 (OPTIONAL)
     Delete the placeholder below and build the page here.
     =================================================================== --%>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <style>
        .meeting-form {
            max-width: 800px;
            margin: 0 auto;
        }

        .meeting-participants {
            border: 1px solid #dee2e6;
            border-radius: 8px;
            padding: 16px;
        }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

    <div class="meeting-form">
        <div class="mb-4">
            <h2>Schedule a Meeting</h2>
            <p class="text-muted">
                Arrange a meeting and share its Zoom link with the participants.
            </p>
        </div>

        <div class="uims-card">

            <div class="mb-3">
                <asp:Label ID="lblTitle" runat="server"
                    AssociatedControlID="txtTitle"
                    CssClass="form-label"
                    Text="Meeting Title" />

                <asp:TextBox ID="txtTitle" runat="server"
                    CssClass="form-control"
                    placeholder="e.g. Internship Progress Meeting" />
            </div>

            <div class="mb-3">
                <asp:Label ID="lblAgenda" runat="server"
                    AssociatedControlID="txtAgenda"
                    CssClass="form-label"
                    Text="Agenda" />

                <asp:TextBox ID="txtAgenda" runat="server"
                    CssClass="form-control"
                    TextMode="MultiLine"
                    Rows="3"
                    placeholder="What will you discuss?" />
            </div>

            <div class="row">
                <div class="col-md-6 mb-3">
                    <asp:Label ID="lblScheduledAt" runat="server"
                        AssociatedControlID="txtScheduledAt"
                        CssClass="form-label"
                        Text="Date and Time" />

                    <asp:TextBox ID="txtScheduledAt" runat="server"
                        CssClass="form-control"
                        TextMode="DateTimeLocal" />
                </div>

                <div class="col-md-6 mb-3">
                    <asp:Label ID="lblDuration" runat="server"
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
                <asp:Label ID="lblParticipants" runat="server"
                    CssClass="form-label"
                    Text="Participants" />

                <div class="meeting-participants">
                    <asp:CheckBoxList ID="cblParticipants" runat="server"
                        CssClass="mb-2" />

                    <p class="text-muted mb-0">
                        Available students and supervisors will appear here
                        when we connect the page to the project data.
                    </p>
                </div>
            </div>

            <div class="mb-4">
                <asp:Label ID="lblJoinUrl" runat="server"
                    AssociatedControlID="txtJoinUrl"
                    CssClass="form-label"
                    Text="Zoom Meeting Link" />

                <asp:TextBox ID="txtJoinUrl" runat="server"
                    CssClass="form-control"
                    TextMode="Url"
                    placeholder="https://zoom.us/j/..." />

                <small class="text-muted">
                    Create the meeting in Zoom, then paste its join link here.
                </small>
            </div>

            <asp:Button ID="btnSchedule" runat="server"
                Text="Schedule Meeting"
                CssClass="btn btn-brand"
                OnClientClick="showMeetingPreview(); return false;" />

            <div id="meetingPreviewNotice"
                class="alert alert-info mt-3"
                style="display: none;"
                role="status">
                This is a design preview. The meeting has not been saved yet.
            </div>

        </div>
    </div>

    <script>
function showMeetingPreview() {
    document.getElementById("meetingPreviewNotice").style.display = "block";
}
</script>

</asp:Content>
