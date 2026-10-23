<%@ Page Language="C#" MasterPageFile="~/Layout/Student.master" AutoEventWireup="true" CodeBehind="Apply.aspx.cs" Inherits="InternshipManagementSystem.Pages.StudentArea.Apply" Title="Internship Application" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/applications.css") %>" />
    <link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/apply-theme.css") %>" />
</asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="application-page application-theme">
    <% if (IsViewMode) { %>
    <a href="MyApplications.aspx" class="application-back"><%: L.T("Student.Apply.MyApplications") %></a>
    <div class="application-heading"><h2><%: L.T("Student.Apply.YourApplication") %></h2><p><%: L.T("Student.Apply.ThisIsWhatYouSentTo") %></p></div>
    <% } else { %>
    <a href="Opportunities.aspx" class="application-back"><%: L.T("Student.Apply.ExploreOpportunities") %></a>
    <div class="application-heading"><h2><%: L.T("Student.Apply.ApplyForAnInternship") %></h2><p><%: L.T("Student.Apply.ReviewTheOpportunityAndTellThe") %></p></div>
    <% } %>
    <asp:Panel ID="ErrorPanel" runat="server" Visible="false" CssClass="application-message" role="alert">
        <asp:Literal ID="ErrorText" runat="server" /> <a href="MyApplications.aspx"><%: L.T("Student.Apply.MyApplications2") %></a>
    </asp:Panel>
    <div class="application-layout">
        <asp:Panel ID="FormPanel" runat="server" Visible="false" CssClass="application-sheet">
            <section class="application-section">
                <h3><span><%: L.T("Student.Apply.YourDetails") %></span></h3><p class="application-help"><%: L.T("Student.Apply.FromYourStudentProfile") %> <a href="Profile.aspx"><%: L.T("Student.Apply.UpdateProfile") %></a></p>
                <dl class="application-details">
                    <div><dt><%: L.T("Student.Apply.FullName") %></dt><dd><%: CurrentStudent.FullName %></dd></div>
                    <div><dt><%: L.T("Student.Apply.StudentNumber") %></dt><dd><%: CurrentStudent.StudentNumber %></dd></div>
                    <div><dt><%: L.T("Student.Apply.EmailAddress") %></dt><dd><%: CurrentStudent.Email %></dd></div>
                    <div><dt><%: L.T("Student.Apply.Major") %></dt><dd><%: CurrentStudent.Major %></dd></div>
                </dl>
            </section>
            <section class="application-section">
                <h3><span><%: L.T("Student.Apply.YourApplication") %></span></h3>
                <asp:Label runat="server" AssociatedControlID="CvUrl" CssClass="application-label" Text="<%$ Resources:Student, Apply.CVLinkRequired %>" />
                <asp:TextBox ID="CvUrl" runat="server" CssClass="form-control" MaxLength="2048" TextMode="Url" aria-describedby="cv-help" required="required" placeholder="https://drive.google.com/..." />
                <p id="cv-help" class="application-help"><%: L.T("Student.Apply.UseAnHTTPSLinkToYour") %></p>
                <asp:Label runat="server" AssociatedControlID="CoverLetter" CssClass="application-label" Text="<%$ Resources:Student, Apply.CoverLetterRequired %>" />
                <asp:TextBox ID="CoverLetter" runat="server" CssClass="form-control application-letter" TextMode="MultiLine" Rows="7" MaxLength="4000" ClientIDMode="Static" aria-describedby="letter-help letter-count" required="required" placeholder="<%$ Resources:Student, Apply.ShareRelevantSkillsProjectsAndWhat %>" />
                <div class="application-field-footer"><p id="letter-help" class="application-help"><%: L.T("Student.Apply.504000CharactersKeepIt") %></p><span id="letter-count" class="application-help">0 / 4,000</span></div>
            </section>
            <div class="application-submit">
                <div class="application-confirm"><asp:CheckBox ID="Confirm" runat="server" Text="<%$ Resources:Student, Apply.IConfirmThatMyInformationIs %>" /></div>
                <p class="application-help"><%: L.T("Student.Apply.YourApplicationWillBeMarkedPending") %></p>
                <div class="application-actions"><a href="Opportunities.aspx"><%: L.T("Student.Apply.Cancel") %></a><asp:Button ID="SubmitApplication" runat="server" Text="<%$ Resources:Student, Apply.SubmitApplication %>" OnClick="Submit_Click" CssClass="btn btn-brand"  data-ui-action="submit" data-loading-label="Submitting…"/></div>
            </div>
        </asp:Panel>
        <asp:Panel ID="ViewPanel" runat="server" Visible="false" CssClass="application-sheet">
            <% if (ExistingApplication != null) { %>
            <section class="application-section">
                <h3><span><%: L.T("Student.Apply.Status") %></span></h3>
                <p><span class="application-status status-<%: ExistingApplication.Status.ToString().ToLowerInvariant() %>"><%: ExistingApplication.Status %></span></p>
                <p class="application-help"><%: L.T("Student.Apply.Submitted") %> <%: Time.Display(ExistingApplication.SubmittedAt) %></p>
                <% if (ExistingApplication.Status == ApplicationStatus.Rejected && !string.IsNullOrEmpty(ExistingApplication.RejectionReason)) { %>
                <p class="review-rejection-reason"><strong><%: L.T("Student.Apply.RejectionReason") %></strong> <%: ExistingApplication.RejectionReason %></p>
                <% } %>
                <% if (ExistingApplication.Status == ApplicationStatus.Accepted) { %>
                <p class="application-help"><%: L.T("Student.Apply.ToConfirmThisOfferGoTo") %> <a href="MyApplications.aspx"><%: L.T("Student.Apply.MyApplications3") %></a>.</p>
                <% } %>
            </section>
            <section class="application-section">
                <h3><span><%: L.T("Student.Apply.YourDetails") %></span></h3>
                <dl class="application-details">
                    <div><dt><%: L.T("Student.Apply.FullName") %></dt><dd><%: CurrentStudent.FullName %></dd></div>
                    <div><dt><%: L.T("Student.Apply.StudentNumber") %></dt><dd><%: CurrentStudent.StudentNumber %></dd></div>
                    <div><dt><%: L.T("Student.Apply.EmailAddress") %></dt><dd><%: CurrentStudent.Email %></dd></div>
                    <div><dt><%: L.T("Student.Apply.Major") %></dt><dd><%: CurrentStudent.Major %></dd></div>
                </dl>
            </section>
            <section class="application-section">
                <h3><span><%: L.T("Student.Apply.YourApplication") %></span></h3>
                <span class="application-label"><%: L.T("Student.Apply.CVLink") %></span>
                <% if (!string.IsNullOrEmpty(ExistingCvUrl)) { %>
                <p><a href="<%: ExistingCvUrl %>" target="_blank" rel="noopener noreferrer"><%: L.T("Student.Apply.OpenCV") %></a></p>
                <% } else { %>
                <p class="application-help"><%: L.T("Student.Apply.NoCVLinkAvailable") %></p>
                <% } %>
                <span class="application-label"><%: L.T("Student.Apply.CoverLetter") %></span>
                <p class="application-letter-view"><%: ExistingApplication.CoverLetter %></p>
            </section>
            <% } %>
        </asp:Panel>
        <asp:Panel ID="OpportunityPanel" runat="server" Visible="false" CssClass="application-opportunity">
            <% if (SelectedOpportunity != null) { %>
            <span class="application-eyebrow"><%: L.T("Student.Apply.SelectedInternship") %></span>
            <h3><%: SelectedOpportunity.Title %></h3><p class="application-company"><%: SelectedOpportunity.CompanyName %></p>
            <dl class="application-facts">
                <div><dt><%: L.T("Student.Apply.Location") %></dt><dd><%: SelectedOpportunity.Location %></dd></div>
                <div><dt><%: L.T("Student.Apply.Duration") %></dt><dd><%: SelectedOpportunity.DurationWeeks > 0 ? SelectedOpportunity.DurationWeeks + " weeks" : "Not specified" %></dd></div>
                <div><dt><%: L.T("Student.Apply.Starts") %></dt><dd><%: Time.DisplayDate(SelectedOpportunity.StartDate) %></dd></div>
                <div><dt><%: L.T("Student.Apply.ApplyBy") %></dt><dd><%: SelectedOpportunity.ApplicationDeadline > 0 ? Time.DisplayDate(SelectedOpportunity.ApplicationDeadline) : "No deadline set" %></dd></div>
                <div><dt><%: L.T("Student.Apply.AvailableSeats") %></dt><dd><%: SelectedOpportunity.RemainingSeats %></dd></div>
            </dl>
            <h4><%: L.T("Student.Apply.AboutTheInternship") %></h4><p class="application-description"><%: SelectedOpportunity.Description %></p>
            <h4><%: L.T("Student.Apply.Requirements") %></h4><p class="application-description"><%: SelectedOpportunity.Requirements %></p>
            <a href="OpportunityDetails.aspx?id=<%: Server.UrlEncode(OpportunityId) %>"><%: L.T("Student.Apply.ViewOpportunityDetails") %></a>
            <% } %>
        </asp:Panel>
    </div>
</div>
</asp:Content>
<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server">
<script>
(function () {
    var letter = document.getElementById('CoverLetter');
    if (!letter) return;
    letter.setAttribute('maxlength', '4000');
    function update() { document.getElementById('letter-count').textContent = letter.value.length.toLocaleString() + ' / 4,000'; }
    letter.addEventListener('input', update); update();
}());
</script>
</asp:Content>
