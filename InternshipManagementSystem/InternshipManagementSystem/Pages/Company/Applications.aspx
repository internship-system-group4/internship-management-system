<%@ Page Language="C#" MasterPageFile="~/Layout/Company.master" AutoEventWireup="true" CodeBehind="Applications.aspx.cs" Inherits="InternshipManagementSystem.Pages.CompanyArea.Applications" Title="Applications Review" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"><link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/applications.css?v=20261022-review-2") %>" /></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="application-page company-applications">
    <div class="application-heading"><h2><%: L.T("Company.Applications.ApplicationsReview") %></h2><p><%: L.T("Company.Applications.ReviewApplicationsForYourCompanyAnd") %></p></div>
    <asp:Panel ID="NoticePanel" runat="server" Visible="false" CssClass="application-message application-success" role="status"><asp:Literal ID="NoticeText" runat="server" Mode="Encode" /></asp:Panel>
    <asp:Panel ID="ErrorPanel" runat="server" Visible="false" CssClass="application-message" role="alert"><asp:Literal ID="ErrorText" runat="server" Mode="Encode" /> <a href="Applications.aspx"><%: L.T("Company.Applications.RefreshApplications") %></a></asp:Panel>
    <div class="application-list">
        <div class="review-list-heading"><h3><%: L.T("Company.Applications.StudentApplications") %></h3><span><asp:Literal ID="ApplicationCount" runat="server" /> <%: L.T("Company.Applications.Total") %></span></div>
        <asp:Panel ID="EmptyPanel" runat="server" Visible="false" CssClass="application-empty"><%: L.T("Company.Applications.NoApplicationsYetNewStudentApplications") %></asp:Panel>
        <asp:Repeater ID="ApplicationRepeater" runat="server" OnItemCommand="Application_Command">
            <ItemTemplate>
                <article class="application-row" data-application-id="<%#: Eval("Id") %>">
                    <div class="application-row-top">
                        <div class="review-applicant">
                            <h3><%#: Eval("StudentName") %></h3>
                            <p class="review-applied-for"><%: L.T("Company.Applications.AppliedFor") %> <strong><%#: Eval("OpportunityTitle") %></strong></p>
                            <p class="review-meta"><span><%#: OrDash(Eval("StudentMajor")) %></span><span><%: L.T("Company.Applications.Submitted") %> <%#: Time.Display((long)Eval("SubmittedAt")) %></span></p>
                        </div>
                        <span class="<%# StatusClass(Eval("Status")) %>"><%#: Eval("Status") %></span>
                    </div>
                    <details class="review-application-details" <%# (ApplicationStatus)Eval("Status") == ApplicationStatus.Pending ? "open" : "" %>>
                        <summary><span class="candidate-toggle-label candidate-toggle-show"><%: L.T("Company.Applications.ViewCandidateDetails") %></span><span class="candidate-toggle-label candidate-toggle-hide"><%: L.T("Company.Applications.HideCandidateDetails") %></span><span class="candidate-toggle-hint"><%: L.T("Company.Applications.ProfileCoverLetterAndCV") %></span></summary>
                        <div class="candidate-panel">
                            <dl class="candidate-details">
                                <div><dt><%: L.T("Company.Applications.StudentNumber") %></dt><dd><%#: OrDash(Eval("StudentNumber")) %></dd></div>
                                <div><dt><%: L.T("Company.Applications.Major") %></dt><dd><%#: OrDash(Eval("StudentMajor")) %></dd></div>
                                <div><dt><%: L.T("Company.Applications.College") %></dt><dd><%#: OrDash(Eval("College")) %></dd></div>
                                <div><dt><%: L.T("Company.Applications.University") %></dt><dd><%#: OrDash(Eval("University")) %></dd></div>
                                <div><dt><%: L.T("Company.Applications.Email") %></dt><dd><%#: OrDash(Eval("Email")) %></dd></div>
                                <div><dt><%: L.T("Company.Applications.Phone") %></dt><dd><%#: OrDash(Eval("Phone")) %></dd></div>
                                <div class="candidate-wide"><dt><%: L.T("Company.Applications.TechnicalSkills") %></dt><dd><%#: OrDash(Eval("TechnicalSkills")) %></dd></div>
                                <div class="candidate-wide"><dt><%: L.T("Company.Applications.SoftSkills") %></dt><dd><%#: OrDash(Eval("SoftSkills")) %></dd></div>
                            </dl>
                            <div class="candidate-section">
                                <h4 class="candidate-heading"><%: L.T("Company.Applications.CoverLetter") %></h4>
                                <p class="candidate-letter"><%#: Eval("CoverLetter") %></p>
                            </div>
                            <div class="candidate-section">
                                <h4 class="candidate-heading"><%: L.T("Company.Applications.DocumentsAndLinks") %></h4>
                                <div class="candidate-documents">
                                    <asp:HyperLink runat="server" NavigateUrl='<%# DocumentUrl(Eval("Id"), "cv") %>' Visible='<%# (bool)Eval("HasCv") %>' Target="_blank" rel="noopener noreferrer" CssClass="candidate-link candidate-link-primary" Text="<%$ Resources:Company, Applications.OpenCV %>" />
                                    <asp:HyperLink runat="server" NavigateUrl='<%# DocumentUrl(Eval("Id"), "portfolio") %>' Visible='<%# (bool)Eval("HasPortfolio") %>' Target="_blank" rel="noopener noreferrer" CssClass="candidate-link" Text="<%$ Resources:Company, Applications.OpenPortfolio %>" />
                                    <asp:HyperLink runat="server" NavigateUrl='<%# Eval("LinkedInUrl") %>' Visible='<%# !string.IsNullOrEmpty((string)Eval("LinkedInUrl")) %>' Target="_blank" rel="noopener noreferrer" CssClass="candidate-link" Text="<%$ Resources:Company, Applications.LinkedInProfile %>" />
                                    <asp:PlaceHolder runat="server" Visible='<%# !(bool)Eval("HasCv") %>'><span class="application-help"><%: L.T("Company.Applications.ThisStudentHasNotSharedA") %></span></asp:PlaceHolder>
                                </div>
                            </div>
                        </div>
                    </details>
                    <asp:PlaceHolder runat="server" Visible='<%# (ApplicationStatus)Eval("Status") == ApplicationStatus.Pending %>'>
                        <div class="review-decision">
                            <div class="review-decision-bar">
                                <div><strong><%: L.T("Company.Applications.ReadyToMakeADecision") %></strong><p class="application-help"><%: L.T("Company.Applications.AcceptanceOffersAPlaceTheStudent") %></p></div>
                                <div class="review-decision-actions">
                                    <button type="button" class="btn review-reject-toggle" aria-expanded="false" aria-controls="reject-<%#: Eval("Id") %>"><%: L.T("Company.Applications.Reject") %></button>
                                    <asp:Button runat="server" CommandName="Accept" CommandArgument='<%# Eval("Id") %>' Text="<%$ Resources:Company, Applications.AcceptApplication %>" CssClass="btn btn-brand review-accept-button"  data-ui-action="accept" data-loading-label="Accepting…"/>
                                </div>
                            </div>
                            <div class="review-reject-fields" id="reject-<%#: Eval("Id") %>" hidden>
                                <asp:Label runat="server" AssociatedControlID="RejectionReason" Text="<%$ Resources:Company, Applications.ReasonForRejectionRequired %>" CssClass="application-label" />
                                <asp:TextBox ID="RejectionReason" runat="server" TextMode="MultiLine" Rows="3" MaxLength="2000" CssClass="form-control" placeholder="<%$ Resources:Company, Applications.ExplainTheDecisionSoTheStudent %>" />
                                <p class="application-help"><%: L.T("Company.Applications.ThisReasonWillBeVisibleTo") %></p>
                                <div class="review-reject-actions">
                                    <button type="button" class="btn review-cancel-button" data-reject-cancel><%: L.T("Company.Applications.Cancel") %></button>
                                    <asp:Button runat="server" CommandName="Reject" CommandArgument='<%# Eval("Id") %>' Text="<%$ Resources:Company, Applications.ConfirmRejection %>" CssClass="btn review-reject-button"  data-ui-action="confirm" data-loading-label="Confirming…"/>
                                </div>
                            </div>
                        </div>
                    </asp:PlaceHolder>
                    <asp:PlaceHolder runat="server" Visible='<%# (ApplicationStatus)Eval("Status") == ApplicationStatus.Accepted || (ApplicationStatus)Eval("Status") == ApplicationStatus.Rejected %>'>
                        <div class="review-outcome review-outcome-<%#: Eval("Status").ToString().ToLowerInvariant() %>">
                            <p class="review-outcome-title"><%#: Eval("Status") %> <%: L.T("Company.Applications.On") %> <%#: Time.Display((long)Eval("DecidedAt")) %></p>
                            <asp:PlaceHolder runat="server" Visible='<%# (ApplicationStatus)Eval("Status") == ApplicationStatus.Accepted %>'><p class="application-help"><%# (bool)Eval("IsConfirmedByStudent") ? "The student has confirmed this offer." : "The student has been offered a place and still needs to confirm it." %></p></asp:PlaceHolder>
                            <asp:PlaceHolder runat="server" Visible='<%# (ApplicationStatus)Eval("Status") == ApplicationStatus.Rejected %>'><p class="review-rejection-reason"><strong><%: L.T("Company.Applications.ReasonGiven") %></strong> <%#: Eval("RejectionReason") %></p></asp:PlaceHolder>
                        </div>
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
