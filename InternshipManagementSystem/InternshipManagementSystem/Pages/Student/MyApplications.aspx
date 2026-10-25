<%@ Page Language="C#" MasterPageFile="~/Layout/Student.master" AutoEventWireup="true" CodeBehind="MyApplications.aspx.cs" Inherits="InternshipManagementSystem.Pages.StudentArea.MyApplications" Title="My Applications" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"><link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/applications.css") %>" /></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="application-page student-applications-page">
    <header class="application-heading student-workspace-hero"><div class="student-hero-copy"><span class="student-hero-kicker"><%: L.T("Student.Workspace.StudentJourney") %></span><h2><%: L.T("Student.MyApplications.MyApplications") %></h2><p><%: L.T("Student.MyApplications.TrackYourApplicationsAndChooseOne") %></p></div><span class="student-hero-metric"><strong><%= ApplicationCount %></strong><span><%: L.T("Student.Workspace.ApplicationsLabel") %></span></span></header>
    <asp:Panel ID="NoticePanel" runat="server" Visible="false" CssClass="application-message application-success" role="status"><asp:Literal ID="NoticeText" runat="server" Mode="Encode" /></asp:Panel>
    <asp:Panel ID="ErrorPanel" runat="server" Visible="false" CssClass="application-message" role="alert"><asp:Literal ID="ErrorText" runat="server" Mode="Encode" /> <a href="MyApplications.aspx"><%: L.T("Student.MyApplications.RefreshApplications") %></a></asp:Panel>
    <asp:Panel ID="PlacementPanel" runat="server" Visible="false" CssClass="confirmed-placement">
        <div><span class="application-status status-accepted"><%: L.T("Student.MyApplications.ConfirmedInternship") %></span><h3><asp:Literal ID="PlacementTitle" runat="server" Mode="Encode" /></h3><p><asp:Literal ID="PlacementCompany" runat="server" Mode="Encode" /></p></div>
        <p class="application-help"><%: L.T("Student.MyApplications.YourPlacementIsSavedYouCannot") %></p>
    </asp:Panel>
    <div class="student-section-heading"><span class="student-section-number" aria-hidden="true">01</span><div><h3><%: L.T("Student.Workspace.ApplicationHistory") %></h3><p><%: L.T("Student.Workspace.OneApplicationPerOpportunity") %></p></div></div>
    <div class="application-list">
        <asp:Panel ID="EmptyPanel" runat="server" Visible="false" CssClass="application-empty"><%: L.T("Student.MyApplications.NoApplicationsYet") %> <a href="Opportunities.aspx"><%: L.T("Student.MyApplications.ExploreOpportunities") %></a> <%: L.T("Student.MyApplications.ToFindYourInternship") %></asp:Panel>
        <asp:Repeater ID="ApplicationRepeater" runat="server" OnItemCommand="Application_Command"><ItemTemplate>
            <article class="application-row" data-application-id="<%#: Eval("Id") %>">
                <div class="application-row-top"><div class="application-row-identity"><span class="application-row-mark" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="7" width="18" height="14" rx="2"/><path d="M8 7V5a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2M3 13h18"/></svg></span><div><h3><%#: Eval("OpportunityTitle") %></h3><div class="application-company-name"><%#: CompanyNameFor(Container.DataItem) %></div><p class="application-help"><%: L.T("Student.MyApplications.Submitted") %> <%#: Time.Display((long)Eval("SubmittedAt")) %></p></div></div><span class="application-status status-<%#: Eval("Status").ToString().ToLowerInvariant() %>"><%#: L.Value("Ui", Eval("Status")) %></span></div>
                <asp:PlaceHolder runat="server" Visible='<%# (ApplicationStatus)Eval("Status") == ApplicationStatus.Rejected %>'><p class="review-rejection-reason"><strong><%: L.T("Student.MyApplications.RejectionReason") %></strong> <%#: Eval("RejectionReason") %></p></asp:PlaceHolder>
                <a class="application-view-link" href="Apply.aspx?opportunityId=<%#: Server.UrlEncode(Convert.ToString(Eval("OpportunityId"))) %>"><%: L.T("Student.MyApplications.ViewApplication") %></a>
                <asp:PlaceHolder runat="server" Visible='<%# CanConfirm(Container.DataItem) %>'>
                    <div class="offer-confirmation"><strong><%: L.T("Student.MyApplications.ReadyToJoinThisCompany") %></strong><p class="application-help"><%: L.T("Student.MyApplications.YouCanConfirmOnlyOneInternship") %></p>
                        <div class="offer-consent"><asp:CheckBox ID="ConfirmConsent" runat="server" Text="<%$ Resources:Student, MyApplications.IUnderstandThatICanConfirm %>" /></div>
                        <asp:Button runat="server" CommandName="Confirm" CommandArgument='<%# Eval("Id") %>' Text="<%$ Resources:Student, MyApplications.ConfirmOffer %>" CssClass="btn btn-brand"  data-ui-action="confirm" data-loading-label="<%$ Resources:Shared, I18n.Confirming %>"/>
                    </div>
                </asp:PlaceHolder>
                <asp:PlaceHolder runat="server" Visible='<%# IsConfirmed(Container.DataItem) %>'><p class="confirmed-offer-label"><%: L.T("Student.MyApplications.ThisIsYourConfirmedInternship") %></p></asp:PlaceHolder>
                <asp:PlaceHolder runat="server" Visible='<%# NeedsSync(Container.DataItem) %>'><asp:Button runat="server" CommandName="Sync" CommandArgument='<%# Eval("Id") %>' Text="<%$ Resources:Student, MyApplications.SyncConfirmation %>" CssClass="btn btn-outline-secondary"  data-ui-action="sync" data-loading-label="<%$ Resources:Shared, I18n.Synchronizing %>"/></asp:PlaceHolder>
            </article>
        </ItemTemplate></asp:Repeater>
    </div>
</div>
</asp:Content>
