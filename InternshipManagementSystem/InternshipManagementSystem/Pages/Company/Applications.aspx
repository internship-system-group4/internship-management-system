<%@ Page Language="C#" MasterPageFile="~/Layout/Company.master" AutoEventWireup="true" CodeBehind="Applications.aspx.cs" Inherits="InternshipManagementSystem.Pages.CompanyArea.Applications" Title="Applications Review" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"><link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/applications.css") %>" /></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="application-page company-applications">
    <div class="application-heading"><h2>Applications review</h2><p>Review applications for your company and let students know your decision.</p></div>
    <asp:Panel ID="NoticePanel" runat="server" Visible="false" CssClass="application-message application-success" role="status"><asp:Literal ID="NoticeText" runat="server" Mode="Encode" /></asp:Panel>
    <asp:Panel ID="ErrorPanel" runat="server" Visible="false" CssClass="application-message" role="alert"><asp:Literal ID="ErrorText" runat="server" Mode="Encode" /> <a href="Applications.aspx">Refresh applications</a></asp:Panel>
    <div class="application-list">
        <div class="review-list-heading"><h3>Student applications</h3><span><asp:Literal ID="ApplicationCount" runat="server" /> total</span></div>
        <asp:Panel ID="EmptyPanel" runat="server" Visible="false" CssClass="application-empty">No applications yet. New student applications for your company will appear here.</asp:Panel>
        <asp:Repeater ID="ApplicationRepeater" runat="server" OnItemCommand="Application_Command">
            <ItemTemplate>
                <article class="application-row" data-application-id="<%#: Eval("Id") %>">
                    <div class="application-row-top"><div><h3><%#: Eval("OpportunityTitle") %></h3><div><%#: Eval("StudentName") %> &middot; <%#: Eval("StudentMajor") %></div><p class="application-help">Submitted <%#: Time.Display((long)Eval("SubmittedAt")) %></p></div><span class="<%# StatusClass(Eval("Status")) %>"><%#: Eval("Status") %></span></div>
                    <details class="review-application-details" <%# (ApplicationStatus)Eval("Status") == ApplicationStatus.Pending ? "open" : "" %>>
                        <summary><span class="candidate-toggle-label">View candidate details</span><span class="candidate-toggle-hint">Profile, cover letter and CV</span></summary>
                        <div class="candidate-panel">
                            <dl class="candidate-details">
                                <div><dt>Student number</dt><dd><%#: OrDash(Eval("StudentNumber")) %></dd></div>
                                <div><dt>Major</dt><dd><%#: OrDash(Eval("StudentMajor")) %></dd></div>
                                <div><dt>College</dt><dd><%#: OrDash(Eval("College")) %></dd></div>
                                <div><dt>University</dt><dd><%#: OrDash(Eval("University")) %></dd></div>
                                <div><dt>Email</dt><dd><%#: OrDash(Eval("Email")) %></dd></div>
                                <div><dt>Phone</dt><dd><%#: OrDash(Eval("Phone")) %></dd></div>
                                <div class="candidate-wide"><dt>Technical skills</dt><dd><%#: OrDash(Eval("TechnicalSkills")) %></dd></div>
                                <div class="candidate-wide"><dt>Soft skills</dt><dd><%#: OrDash(Eval("SoftSkills")) %></dd></div>
                            </dl>
                            <div class="candidate-section">
                                <h4 class="candidate-heading">Cover letter</h4>
                                <p class="candidate-letter"><%#: Eval("CoverLetter") %></p>
                            </div>
                            <div class="candidate-section">
                                <h4 class="candidate-heading">Documents and links</h4>
                                <div class="candidate-documents">
                                    <asp:HyperLink runat="server" NavigateUrl='<%# DocumentUrl(Eval("Id"), "cv") %>' Visible='<%# (bool)Eval("HasCv") %>' Target="_blank" rel="noopener noreferrer" CssClass="candidate-link candidate-link-primary" Text="Open CV" />
                                    <asp:HyperLink runat="server" NavigateUrl='<%# DocumentUrl(Eval("Id"), "portfolio") %>' Visible='<%# (bool)Eval("HasPortfolio") %>' Target="_blank" rel="noopener noreferrer" CssClass="candidate-link" Text="Open portfolio" />
                                    <asp:HyperLink runat="server" NavigateUrl='<%# Eval("LinkedInUrl") %>' Visible='<%# !string.IsNullOrEmpty((string)Eval("LinkedInUrl")) %>' Target="_blank" rel="noopener noreferrer" CssClass="candidate-link" Text="LinkedIn profile" />
                                    <asp:PlaceHolder runat="server" Visible='<%# !(bool)Eval("HasCv") %>'><span class="application-help">This student has not shared a CV that can be opened yet.</span></asp:PlaceHolder>
                                </div>
                            </div>
                        </div>
                    </details>
                    <asp:PlaceHolder runat="server" Visible='<%# (ApplicationStatus)Eval("Status") == ApplicationStatus.Pending %>'>
                        <div class="review-decision">
                            <div class="review-decision-bar">
                                <div><strong>Ready to make a decision?</strong><p class="application-help">Acceptance offers a place. The student still needs to confirm one offer.</p></div>
                                <div class="review-decision-actions">
                                    <button type="button" class="btn review-reject-toggle" aria-expanded="false" aria-controls="reject-<%#: Eval("Id") %>">Reject</button>
                                    <asp:Button runat="server" CommandName="Accept" CommandArgument='<%# Eval("Id") %>' Text="Accept application" CssClass="btn btn-brand review-accept-button" />
                                </div>
                            </div>
                            <div class="review-reject-fields" id="reject-<%#: Eval("Id") %>" hidden>
                                <asp:Label runat="server" AssociatedControlID="RejectionReason" Text="Reason for rejection (required)" CssClass="application-label" />
                                <asp:TextBox ID="RejectionReason" runat="server" TextMode="MultiLine" Rows="3" MaxLength="2000" CssClass="form-control" placeholder="Explain the decision so the student knows why their application was rejected." />
                                <p class="application-help">This reason will be visible to the student. Up to 2,000 characters.</p>
                                <div class="review-reject-actions">
                                    <button type="button" class="btn review-cancel-button" data-reject-cancel>Cancel</button>
                                    <asp:Button runat="server" CommandName="Reject" CommandArgument='<%# Eval("Id") %>' Text="Confirm rejection" CssClass="btn review-reject-button" />
                                </div>
                            </div>
                        </div>
                    </asp:PlaceHolder>
                    <asp:PlaceHolder runat="server" Visible='<%# (ApplicationStatus)Eval("Status") == ApplicationStatus.Accepted || (ApplicationStatus)Eval("Status") == ApplicationStatus.Rejected %>'>
                        <p class="application-help">Reviewed <%#: Time.Display((long)Eval("DecidedAt")) %>. This decision has been recorded.</p>
                        <asp:PlaceHolder runat="server" Visible='<%# (ApplicationStatus)Eval("Status") == ApplicationStatus.Rejected %>'><p class="review-rejection-reason"><strong>Rejection reason:</strong> <%#: Eval("RejectionReason") %></p></asp:PlaceHolder>
                    </asp:PlaceHolder>
                </article>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</div>
</asp:Content>
<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server">
<script>
(function () {
    function setOpen(toggle, open) {
        var panel = document.getElementById(toggle.getAttribute('aria-controls'));
        toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
        toggle.classList.toggle('is-active', open);
        if (panel) panel.hidden = !open;
        return panel;
    }
    document.querySelectorAll('.review-reject-toggle').forEach(function (toggle) {
        toggle.addEventListener('click', function () {
            var panel = setOpen(toggle, toggle.getAttribute('aria-expanded') !== 'true');
            if (panel && !panel.hidden) panel.querySelector('textarea').focus();
        });
    });
    document.querySelectorAll('[data-reject-cancel]').forEach(function (cancel) {
        cancel.addEventListener('click', function () {
            var toggle = cancel.closest('.review-decision').querySelector('.review-reject-toggle');
            setOpen(toggle, false);
            toggle.focus();
        });
    });
    document.querySelectorAll('.review-reject-fields textarea').forEach(function (field) { field.maxLength = 2000; });
    var invalid = document.querySelector('[data-rejection-error]');
    if (invalid) {
        setOpen(invalid.closest('.review-decision').querySelector('.review-reject-toggle'), true);
        invalid.focus();
    }
}());
</script>
</asp:Content>
