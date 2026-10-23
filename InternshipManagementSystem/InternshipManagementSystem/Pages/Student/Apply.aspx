<%@ Page Language="C#" MasterPageFile="~/Layout/Student.master" AutoEventWireup="true" CodeBehind="Apply.aspx.cs" Inherits="InternshipManagementSystem.Pages.StudentArea.Apply" Title="Internship Application" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/applications.css") %>" />
    <link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/apply-theme.css") %>" />
</asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="application-page application-theme">
    <% if (IsViewMode) { %>
    <a href="MyApplications.aspx" class="application-back">&larr; My applications</a>
    <div class="application-heading"><h2>Your application</h2><p>This is what you sent to the company. Track its status here.</p></div>
    <% } else { %>
    <a href="Opportunities.aspx" class="application-back">&larr; Explore opportunities</a>
    <div class="application-heading"><h2>Apply for an internship</h2><p>Review the opportunity and tell the company why you would be a good fit.</p></div>
    <% } %>
    <asp:Panel ID="ErrorPanel" runat="server" Visible="false" CssClass="application-message" role="alert">
        <asp:Literal ID="ErrorText" runat="server" /> <a href="MyApplications.aspx">My Applications &rarr;</a>
    </asp:Panel>
    <div class="application-layout">
        <asp:Panel ID="FormPanel" runat="server" Visible="false" CssClass="application-sheet">
            <section class="application-section">
                <h3><span>Your details</span></h3><p class="application-help">From your student profile. <a href="Profile.aspx">Update profile</a></p>
                <dl class="application-details">
                    <div><dt>Full name</dt><dd><%: CurrentStudent.FullName %></dd></div>
                    <div><dt>Student number</dt><dd><%: CurrentStudent.StudentNumber %></dd></div>
                    <div><dt>Email address</dt><dd><%: CurrentStudent.Email %></dd></div>
                    <div><dt>Major</dt><dd><%: CurrentStudent.Major %></dd></div>
                </dl>
            </section>
            <section class="application-section">
                <h3><span>Your application</span></h3>
                <asp:Label runat="server" AssociatedControlID="CvUrl" CssClass="application-label" Text="CV link (required)" />
                <asp:TextBox ID="CvUrl" runat="server" CssClass="form-control" MaxLength="2048" TextMode="Url" aria-describedby="cv-help" required="required" placeholder="https://drive.google.com/..." />
                <p id="cv-help" class="application-help">Use an HTTPS link to your CV. Make sure the company can open it without requesting access.</p>
                <asp:Label runat="server" AssociatedControlID="CoverLetter" CssClass="application-label" Text="Cover letter (required)" />
                <asp:TextBox ID="CoverLetter" runat="server" CssClass="form-control application-letter" TextMode="MultiLine" Rows="7" MaxLength="4000" ClientIDMode="Static" aria-describedby="letter-help letter-count" required="required" placeholder="Share relevant skills, projects, and what you hope to learn." />
                <div class="application-field-footer"><p id="letter-help" class="application-help">50–4,000 characters. Keep it specific to this opportunity.</p><span id="letter-count" class="application-help">0 / 4,000</span></div>
            </section>
            <div class="application-submit">
                <div class="application-confirm"><asp:CheckBox ID="Confirm" runat="server" Text=" I confirm that my information is accurate and my CV link is accessible." /></div>
                <p class="application-help">Your application will be marked Pending until the company reviews it.</p>
                <div class="application-actions"><a href="Opportunities.aspx">Cancel</a><asp:Button ID="SubmitApplication" runat="server" Text="Submit application →" OnClick="Submit_Click" CssClass="btn btn-brand" /></div>
            </div>
        </asp:Panel>
        <asp:Panel ID="ViewPanel" runat="server" Visible="false" CssClass="application-sheet">
            <% if (ExistingApplication != null) { %>
            <section class="application-section">
                <h3><span>Status</span></h3>
                <p><span class="application-status status-<%: ExistingApplication.Status.ToString().ToLowerInvariant() %>"><%: ExistingApplication.Status %></span></p>
                <p class="application-help">Submitted <%: Time.Display(ExistingApplication.SubmittedAt) %></p>
                <% if (ExistingApplication.Status == ApplicationStatus.Rejected && !string.IsNullOrEmpty(ExistingApplication.RejectionReason)) { %>
                <p class="review-rejection-reason"><strong>Rejection reason:</strong> <%: ExistingApplication.RejectionReason %></p>
                <% } %>
                <% if (ExistingApplication.Status == ApplicationStatus.Accepted) { %>
                <p class="application-help">To confirm this offer, go to <a href="MyApplications.aspx">My Applications</a>.</p>
                <% } %>
            </section>
            <section class="application-section">
                <h3><span>Your details</span></h3>
                <dl class="application-details">
                    <div><dt>Full name</dt><dd><%: CurrentStudent.FullName %></dd></div>
                    <div><dt>Student number</dt><dd><%: CurrentStudent.StudentNumber %></dd></div>
                    <div><dt>Email address</dt><dd><%: CurrentStudent.Email %></dd></div>
                    <div><dt>Major</dt><dd><%: CurrentStudent.Major %></dd></div>
                </dl>
            </section>
            <section class="application-section">
                <h3><span>Your application</span></h3>
                <span class="application-label">CV link</span>
                <% if (!string.IsNullOrEmpty(ExistingCvUrl)) { %>
                <p><a href="<%: ExistingCvUrl %>" target="_blank" rel="noopener noreferrer">Open CV &#8599;</a></p>
                <% } else { %>
                <p class="application-help">No CV link available.</p>
                <% } %>
                <span class="application-label">Cover letter</span>
                <p class="application-letter-view"><%: ExistingApplication.CoverLetter %></p>
            </section>
            <% } %>
        </asp:Panel>
        <asp:Panel ID="OpportunityPanel" runat="server" Visible="false" CssClass="application-opportunity">
            <% if (SelectedOpportunity != null) { %>
            <span class="application-eyebrow">Selected internship</span>
            <h3><%: SelectedOpportunity.Title %></h3><p class="application-company"><%: SelectedOpportunity.CompanyName %></p>
            <dl class="application-facts">
                <div><dt>Location</dt><dd><%: SelectedOpportunity.Location %></dd></div>
                <div><dt>Duration</dt><dd><%: SelectedOpportunity.DurationWeeks > 0 ? SelectedOpportunity.DurationWeeks + " weeks" : "Not specified" %></dd></div>
                <div><dt>Starts</dt><dd><%: Time.DisplayDate(SelectedOpportunity.StartDate) %></dd></div>
                <div><dt>Apply by</dt><dd><%: SelectedOpportunity.ApplicationDeadline > 0 ? Time.DisplayDate(SelectedOpportunity.ApplicationDeadline) : "No deadline set" %></dd></div>
                <div><dt>Available seats</dt><dd><%: SelectedOpportunity.RemainingSeats %></dd></div>
            </dl>
            <h4>About the internship</h4><p class="application-description"><%: SelectedOpportunity.Description %></p>
            <h4>Requirements</h4><p class="application-description"><%: SelectedOpportunity.Requirements %></p>
            <a href="OpportunityDetails.aspx?id=<%: Server.UrlEncode(OpportunityId) %>">View opportunity details &rarr;</a>
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
