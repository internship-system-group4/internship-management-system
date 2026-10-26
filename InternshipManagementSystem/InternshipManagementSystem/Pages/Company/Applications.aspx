<%@ Page Language="C#" MasterPageFile="~/Layout/Company.master" AutoEventWireup="true" CodeBehind="Applications.aspx.cs" Inherits="InternshipManagementSystem.Pages.CompanyArea.Applications" Title="Applications Review" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"><link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/applications.css?v=20261025-review-redesign-1") %>" /></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="application-page company-applications" data-draft-warning="<%: L.T("Company.Applications.DraftWarning") %>" data-position-template="<%: L.T("Company.Applications.ApplicationPosition") %>" data-details-loading="<%: L.T("Company.Applications.LoadingDetails") %>" data-details-error="<%: L.T("Company.Applications.DetailsLoadFailed") %>" data-initial-search="<%: ReviewSearch %>" data-initial-filter="<%: ReviewFilter %>" data-initial-selection="<%: ReviewSelection %>">
    <input type="hidden" name="reviewSelection" value="" />
    <div class="application-heading"><h2><%: L.T("Company.Applications.ApplicationsReview") %></h2><p><%: L.T("Company.Applications.ReviewDeskIntro") %></p></div>
    <asp:Panel ID="NoticePanel" runat="server" Visible="false" CssClass="application-message application-success review-notice" role="status"><span class="review-notice-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path pathLength="1" d="m6 12.5 4 4 8-9" /></svg></span><span class="review-notice-text"><asp:Literal ID="NoticeText" runat="server" Mode="Encode" /></span></asp:Panel>
    <asp:Panel ID="ErrorPanel" runat="server" Visible="false" CssClass="application-message" role="alert"><asp:Literal ID="ErrorText" runat="server" Mode="Encode" /> <a href="Applications.aspx"><%: L.T("Company.Applications.RefreshApplications") %></a></asp:Panel>
    <div class="application-list">
        <div class="review-toolbar" data-no-dirty hidden>
            <label class="review-search" for="applicationReviewSearch">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" aria-hidden="true"><circle cx="10.5" cy="10.5" r="6.5" /><path d="m16 16 5 5" /></svg>
                <input id="applicationReviewSearch" name="reviewSearch" type="search" maxlength="200" autocomplete="off" placeholder="<%: L.T("Company.Applications.SearchPlaceholder") %>" aria-label="<%: L.T("Company.Applications.SearchPlaceholder") %>" />
            </label>
            <fieldset class="review-filters">
                <legend class="visually-hidden"><%: L.T("Company.Applications.FilterByStatus") %></legend>
                <label><input type="radio" name="review-status-filter" value="all" checked /><span><%: L.T("Company.Applications.AllApplications") %><span data-filter-count="all">0</span></span></label>
                <label><input type="radio" name="review-status-filter" value="Pending" /><span><%: L.Value("ApplicationStatus", ApplicationStatus.Pending) %><span data-filter-count="Pending">0</span></span></label>
                <label><input type="radio" name="review-status-filter" value="Accepted" /><span><%: L.Value("ApplicationStatus", ApplicationStatus.Accepted) %><span data-filter-count="Accepted">0</span></span></label>
                <label><input type="radio" name="review-status-filter" value="Rejected" /><span><%: L.Value("ApplicationStatus", ApplicationStatus.Rejected) %><span data-filter-count="Rejected">0</span></span></label>
            </fieldset>
        </div>
        <div class="review-list-heading"><h3><%: L.T("Company.Applications.StudentApplications") %></h3><span><asp:Literal ID="ApplicationCount" runat="server" /> <%: L.T("Company.Applications.Total") %></span></div>
        <p class="review-results-note" role="status" aria-live="polite" aria-atomic="true" data-count-template="<%: L.T("Company.Applications.ShowingApplications") %>" hidden></p>
        <div class="review-workspace">
        <div class="review-queue">
        <div class="review-filter-empty" hidden><p><%: L.T("Company.Applications.NoMatchingApplications") %></p><button type="button" class="btn" data-clear-review-filters><%: L.T("Company.Applications.ClearFilters") %></button></div>
        <asp:Panel ID="EmptyPanel" runat="server" Visible="false" CssClass="application-empty">
            <svg class="review-empty-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M8 4H5v17h14V4h-3M9 3h6v4H9zM8 12h8M8 16h5" /></svg>
            <p><%: L.T("Company.Applications.NoApplicationsYetNewStudentApplications") %></p>
        </asp:Panel>
        <asp:Repeater ID="ApplicationRepeater" runat="server" OnItemCommand="Application_Command">
            <ItemTemplate>
                <article class="application-row" data-application-id="<%#: Eval("Id") %>" data-application-status="<%#: Eval("Status") %>">
                    <div class="application-row-top">
                        <div class="review-identity">
                            <span class="review-avatar" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="4" /><path d="M4 21v-2a8 8 0 0 1 16 0v2" /></svg></span>
                        <div class="review-applicant">
                            <h3 id="applicant-<%#: Eval("Id") %>"><%#: Eval("StudentName") %></h3>
                            <p class="review-applied-for"><span><%: L.T("Company.Applications.AppliedFor") %></span><strong dir="auto"><%#: Eval("OpportunityTitle") %></strong></p>
                            <p class="review-meta"><span><%#: OrDash(Eval("StudentMajor")) %></span><span><%: L.T("Company.Applications.Submitted") %> <%#: Time.Display((long)Eval("SubmittedAt")) %></span></p>
                            <asp:PlaceHolder runat="server" Visible='<%# (ApplicationStatus)Eval("Status") == ApplicationStatus.Accepted %>'><span class="review-confirmation"><%#: L.T((bool)Eval("IsConfirmedByStudent") ? "Company.Applications.PlacementConfirmed" : "Company.Applications.AwaitingStudentConfirmation") %></span></asp:PlaceHolder>
                        </div>
                        </div>
                        <div class="review-card-actions">
                            <span class="<%# StatusClass(Eval("Status")) %>"><%#: L.Value("ApplicationStatus", Eval("Status")) %></span>
                            <button type="button" class="btn review-details-toggle <%# (ApplicationStatus)Eval("Status") == ApplicationStatus.Pending ? "review-details-primary" : "" %>" aria-expanded="false" aria-controls="candidate-<%#: Eval("Id") %>" aria-describedby="applicant-<%#: Eval("Id") %>" hidden>
                                <span class="candidate-toggle-show"><%# L.T((ApplicationStatus)Eval("Status") == ApplicationStatus.Pending ? "Company.Applications.ReviewApplication" : "Company.Applications.ViewApplication") %></span>
                                <span class="candidate-toggle-hide"><%: L.T("Company.Applications.HideCandidateDetails") %></span>
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 5 7 7-7 7" /></svg>
                            </button>
                        </div>
                    </div>
                    <details <%# (bool)Eval("DetailsLoaded") ? "open" : "" %> class="review-application-details" id="candidate-<%#: Eval("Id") %>" aria-labelledby="applicant-<%#: Eval("Id") %>">
                        <summary><span class="candidate-toggle-label candidate-toggle-show"><%: L.T("Company.Applications.ViewCandidateDetails") %></span><span class="candidate-toggle-label candidate-toggle-hide"><%: L.T("Company.Applications.HideCandidateDetails") %></span><span class="candidate-toggle-hint"><%: L.T("Company.Applications.ProfileCoverLetterAndCV") %></span></summary>
                        <div class="candidate-panel" data-details-loaded="<%# (bool)Eval("DetailsLoaded") ? "true" : "false" %>">
                        <asp:PlaceHolder runat="server" Visible='<%# !(bool)Eval("DetailsLoaded") %>'>
                            <p class="application-help" role="status" data-details-status></p>
                            <a class="candidate-link" data-load-candidate href="Applications.aspx?candidate=<%#: System.Uri.EscapeDataString((string)Eval("Id")) %>"><%: L.T("Company.Applications.ViewCandidateDetails") %></a>
                        </asp:PlaceHolder>
                        <asp:PlaceHolder runat="server" Visible='<%# (bool)Eval("DetailsLoaded") %>'>
                            <div class="candidate-profile">
                            <div class="candidate-section">
                                <h4 class="candidate-heading"><%: L.T("Company.Applications.StudentProfile") %></h4>
                                <dl class="candidate-details">
                                    <div><dt><%: L.T("Company.Applications.StudentNumber") %></dt><dd dir="auto"><%#: OrDash(Eval("StudentNumber")) %></dd></div>
                                    <div><dt><%: L.T("Company.Applications.Major") %></dt><dd dir="auto"><%#: OrDash(Eval("StudentMajor")) %></dd></div>
                                    <div><dt><%: L.T("Company.Applications.College") %></dt><dd dir="auto"><%#: OrDash(Eval("College")) %></dd></div>
                                    <div><dt><%: L.T("Company.Applications.University") %></dt><dd dir="auto"><%#: OrDash(Eval("University")) %></dd></div>
                                    <div><dt><%: L.T("Company.Applications.Email") %></dt><dd dir="ltr"><%#: OrDash(Eval("Email")) %></dd></div>
                                    <div><dt><%: L.T("Company.Applications.Phone") %></dt><dd dir="ltr"><%#: OrDash(Eval("Phone")) %></dd></div>
                                </dl>
                            </div>
                            <div class="candidate-section">
                                <h4 class="candidate-heading"><%: L.T("Company.Applications.Skills") %></h4>
                                <dl class="candidate-skills">
                                    <div><dt><%: L.T("Company.Applications.TechnicalSkills") %></dt><dd class="candidate-skill-list" dir="auto"><%#: OrDash(Eval("TechnicalSkills")) %></dd></div>
                                    <div><dt><%: L.T("Company.Applications.SoftSkills") %></dt><dd class="candidate-skill-list" dir="auto"><%#: OrDash(Eval("SoftSkills")) %></dd></div>
                                </dl>
                            </div>
                            </div>
                            <div class="candidate-support">
                            <div class="candidate-section">
                                <h4 class="candidate-heading"><%: L.T("Company.Applications.CoverLetter") %></h4>
                                <p class="candidate-letter" dir="auto"><%#: Eval("CoverLetter") %></p>
                            </div>
                            <div class="candidate-section">
                                <h4 class="candidate-heading"><%: L.T("Company.Applications.DocumentsAndLinks") %></h4>
                                <div class="candidate-documents">
                                    <asp:HyperLink runat="server" NavigateUrl='<%# DocumentUrl(Eval("Id"), "cv") %>' Visible='<%# (bool)Eval("HasCv") %>' Target="_blank" rel="noopener noreferrer" CssClass="candidate-link candidate-link-primary" Text="<%$ Resources:Company, Applications.OpenCV %>" />
                                    <asp:HyperLink runat="server" NavigateUrl='<%# DocumentUrl(Eval("Id"), "portfolio") %>' Visible='<%# (bool)Eval("HasPortfolio") %>' Target="_blank" rel="noopener noreferrer" CssClass="candidate-link" Text="<%$ Resources:Company, Applications.OpenPortfolio %>" />
                                    <asp:HyperLink runat="server" NavigateUrl='<%# Eval("LinkedInUrl") %>' Visible='<%# !string.IsNullOrEmpty((string)Eval("LinkedInUrl")) %>' Target="_blank" rel="noopener noreferrer" CssClass="candidate-link" Text="<%$ Resources:Company, Applications.LinkedInProfile %>" />
                                    <asp:PlaceHolder runat="server" Visible='<%# (bool)Eval("HasInlineCv") %>'>
                                        <button type="button" class="candidate-link review-preview-toggle" aria-expanded="false" data-show-label="<%: L.T("Company.Applications.PreviewCv") %>" data-hide-label="<%: L.T("Company.Applications.HideCvPreview") %>" hidden><%: L.T("Company.Applications.PreviewCv") %></button>
                                        <a class="candidate-link" href="<%#: DocumentUrl(Eval("Id"), "cv") + "&download=1" %>"><%: L.T("Company.Applications.DownloadCv") %></a>
                                    </asp:PlaceHolder>
                                    <asp:PlaceHolder runat="server" Visible='<%# !(bool)Eval("HasCv") %>'><span class="application-help"><%: L.T("Company.Applications.ThisStudentHasNotSharedA") %></span></asp:PlaceHolder>
                                </div>
                                <asp:PlaceHolder runat="server" Visible='<%# (bool)Eval("HasInlineCv") %>'>
                                    <div class="review-cv-preview" hidden><p class="application-help"><%: L.T("Company.Applications.PdfPreviewHelp") %></p><iframe title="<%#: L.F("Company.Applications.CvPreviewFor", Eval("StudentName")) %>" data-src="<%#: DocumentUrl(Eval("Id"), "cv") + "&preview=1" %>" loading="lazy" referrerpolicy="no-referrer"></iframe></div>
                                </asp:PlaceHolder>
                                <asp:PlaceHolder runat="server" Visible='<%# (bool)Eval("HasCv") && !(bool)Eval("HasInlineCv") %>'><p class="application-help"><%: L.T("Company.Applications.ExternalCvHelp") %></p></asp:PlaceHolder>
                            </div>
                        </div>
                        </asp:PlaceHolder>
                        </div>
                    <asp:PlaceHolder runat="server" Visible='<%# (ApplicationStatus)Eval("Status") == ApplicationStatus.Pending %>'>
                        <div class="review-decision">
                            <div class="review-decision-bar">
                                <div><strong><%: L.T("Company.Applications.ReadyToMakeADecision") %></strong><p class="application-help"><%: L.T("Company.Applications.AcceptanceOffersAPlaceTheStudent") %></p></div>
                                <div class="review-decision-actions">
                                    <button type="button" class="btn review-reject-toggle" aria-expanded="false" aria-controls="reject-<%#: Eval("Id") %>"><%: L.T("Company.Applications.Reject") %></button>
                                    <asp:Button runat="server" CommandName="Accept" CommandArgument='<%# Eval("Id") %>' Text="<%$ Resources:Company, Applications.AcceptApplication %>" CssClass="btn btn-brand review-accept-button"  data-ui-action="accept" data-loading-label="<%$ Resources:Shared, I18n.Accepting %>"/>
                                </div>
                            </div>
                            <div class="review-reject-fields" id="reject-<%#: Eval("Id") %>" hidden>
                                <asp:Label runat="server" AssociatedControlID="RejectionReason" Text="<%$ Resources:Company, Applications.ReasonForRejectionRequired %>" CssClass="application-label" />
                                <asp:TextBox ID="RejectionReason" runat="server" TextMode="MultiLine" Rows="3" MaxLength="2000" CssClass="form-control" placeholder="<%$ Resources:Company, Applications.ExplainTheDecisionSoTheStudent %>" />
                                <p class="application-help"><%: L.T("Company.Applications.ThisReasonWillBeVisibleTo") %></p>
                                <div class="review-reject-actions">
                                    <button type="button" class="btn review-cancel-button" data-reject-cancel><%: L.T("Company.Applications.Cancel") %></button>
                                    <asp:Button runat="server" CommandName="Reject" CommandArgument='<%# Eval("Id") %>' Text="<%$ Resources:Company, Applications.ConfirmRejection %>" CssClass="btn review-reject-button"  data-ui-action="confirm" data-loading-label="<%$ Resources:Shared, I18n.Confirming %>"/>
                                </div>
                            </div>
                        </div>
                    </asp:PlaceHolder>
                    </details>
                    <asp:PlaceHolder runat="server" Visible='<%# (ApplicationStatus)Eval("Status") == ApplicationStatus.Accepted || (ApplicationStatus)Eval("Status") == ApplicationStatus.Rejected %>'>
                        <div class="review-outcome review-outcome-<%#: Eval("Status").ToString().ToLowerInvariant() %>">
                            <p class="review-outcome-title"><span><%#: L.Value("ApplicationStatus", Eval("Status")) %></span><span class="review-outcome-date"><%: L.T("Company.Applications.On") %> <bdi dir="ltr"><%#: Time.Display((long)Eval("DecidedAt")) %></bdi></span></p>
                            <asp:PlaceHolder runat="server" Visible='<%# (ApplicationStatus)Eval("Status") == ApplicationStatus.Accepted %>'><p class="application-help"><%#: L.T((bool)Eval("IsConfirmedByStudent") ? "Company.Applications.StudentConfirmedOffer" : "Company.Applications.StudentMustConfirmOffer") %></p></asp:PlaceHolder>
                            <asp:PlaceHolder runat="server" Visible='<%# (ApplicationStatus)Eval("Status") == ApplicationStatus.Rejected %>'><p class="review-rejection-reason"><strong><%: L.T("Company.Applications.ReasonGiven") %></strong> <%#: Eval("RejectionReason") %></p></asp:PlaceHolder>
                        </div>
                    </asp:PlaceHolder>
                </article>
            </ItemTemplate>
        </asp:Repeater>
        </div>
        <section class="review-detail-pane" role="region" aria-labelledby="reviewPaneTitle" hidden>
            <header class="review-pane-header">
                <span class="review-pane-avatar" aria-hidden="true"></span>
                <div class="review-pane-heading"><h3 id="reviewPaneTitle" tabindex="-1"></h3><p class="review-pane-opportunity" dir="auto"></p></div>
                <span class="review-pane-status"></span>
                <div class="review-pane-tools">
                    <nav class="review-pane-navigation" aria-label="<%: L.T("Company.Applications.ApplicationNavigation") %>">
                        <button type="button" class="btn" data-review-step="-1"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m15 5-7 7 7 7" /></svg><span><%: L.T("Company.Applications.PreviousApplication") %></span></button>
                        <span class="review-pane-position" role="status" aria-live="polite"></span>
                        <button type="button" class="btn" data-review-step="1"><span><%: L.T("Company.Applications.NextApplication") %></span><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 5 7 7-7 7" /></svg></button>
                    </nav>
                    <button type="button" class="review-pane-close btn" aria-label="<%: L.T("Company.Applications.CloseApplication") %>"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" aria-hidden="true"><path d="m6 6 12 12M18 6 6 18" /></svg></button>
                </div>
            </header>
            <div class="review-pane-content"></div>
            <div class="review-pane-actions"></div>
        </section>
        <div class="ar-confirm" data-ar-confirm hidden
            data-accept-title="<%: L.T("Company.Applications.ConfirmAcceptTitle") %>" data-accept-text="<%: L.T("Company.Applications.ConfirmAcceptText") %>"
            data-accept-point1="<%: L.T("Company.Applications.ConfirmAcceptPoint1") %>" data-accept-point2="<%: L.T("Company.Applications.ConfirmAcceptPoint2") %>"
            data-accept-go="<%: L.T("Company.Applications.AcceptApplication") %>"
            data-reject-title="<%: L.T("Company.Applications.ConfirmRejectTitle") %>" data-reject-text="<%: L.T("Company.Applications.ConfirmRejectText") %>"
            data-reject-point1="<%: L.T("Company.Applications.ConfirmRejectPoint1") %>" data-reject-point2="<%: L.T("Company.Applications.ConfirmRejectPoint2") %>"
            data-reject-go="<%: L.T("Company.Applications.ConfirmRejection") %>">
            <div class="ar-confirm-card" role="alertdialog" aria-modal="true" aria-labelledby="arConfirmTitle" aria-describedby="arConfirmText">
                <div class="ar-confirm-icon" aria-hidden="true">
                    <svg data-ar-icon="accept" viewBox="0 0 24 24"><path pathLength="1" d="m6 12.5 4 4 8-9" /></svg>
                    <svg data-ar-icon="reject" viewBox="0 0 24 24"><path pathLength="1" d="M7.5 7.5l9 9M16.5 7.5l-9 9" /></svg>
                </div>
                <h3 id="arConfirmTitle" data-ar-title></h3>
                <p id="arConfirmText" data-ar-text></p>
                <div class="ar-confirm-person"><span class="ar-confirm-avatar" data-ar-avatar aria-hidden="true"></span><span><strong data-ar-name dir="auto"></strong><small data-ar-opportunity dir="auto"></small></span></div>
                <ul class="ar-confirm-points" data-ar-points></ul>
                <div class="ar-confirm-note" data-ar-note hidden><span><%: L.T("Company.Applications.YourReason") %></span><p data-ar-note-text dir="auto"></p></div>
                <div class="ar-confirm-actions">
                    <button type="button" class="btn ar-confirm-cancel" data-ar-cancel><%: L.T("Company.Applications.GoBack") %></button>
                    <button type="button" class="btn ar-confirm-go" data-ar-go></button>
                </div>
            </div>
        </div>
        <div class="review-pane-placeholder" hidden><svg class="review-empty-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" aria-hidden="true"><path d="M8 4H5v17h14V4h-3M9 3h6v4H9zM8 12h8M8 16h5" /></svg><h3><%: L.T("Company.Applications.SelectApplication") %></h3><p><%: L.T("Company.Applications.SelectApplicationHelp") %></p></div>
        </div>
    </div>
</div>
</asp:Content>
<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server">
<script src="<%: ResolveUrl("~/Assets/js/company-applications.js?v=20261025-review-redesign-1") %>"></script>
</asp:Content>
