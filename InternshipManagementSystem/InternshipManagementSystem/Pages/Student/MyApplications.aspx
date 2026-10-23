<%@ Page Language="C#" MasterPageFile="~/Layout/Student.master" AutoEventWireup="true" CodeBehind="MyApplications.aspx.cs" Inherits="InternshipManagementSystem.Pages.StudentArea.MyApplications" Title="My Applications" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"><link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/applications.css") %>" /></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="application-page">
    <div class="application-heading"><h2><%: L.T("Student.MyApplications.MyApplications") %></h2><p><%: L.T("Student.MyApplications.TrackYourApplicationsAndChooseOne") %></p></div>
    <asp:Panel ID="NoticePanel" runat="server" Visible="false" CssClass="application-message application-success" role="status"><asp:Literal ID="NoticeText" runat="server" Mode="Encode" /></asp:Panel>
    <asp:Panel ID="ErrorPanel" runat="server" Visible="false" CssClass="application-message" role="alert"><asp:Literal ID="ErrorText" runat="server" Mode="Encode" /> <a href="MyApplications.aspx"><%: L.T("Student.MyApplications.RefreshApplications") %></a></asp:Panel>
    <asp:Panel ID="PlacementPanel" runat="server" Visible="false" CssClass="confirmed-placement">
        <div><span class="application-status status-accepted"><%: L.T("Student.MyApplications.ConfirmedInternship") %></span><h3><asp:Literal ID="PlacementTitle" runat="server" Mode="Encode" /></h3><p><asp:Literal ID="PlacementCompany" runat="server" Mode="Encode" /></p></div>
        <p class="application-help"><%: L.T("Student.MyApplications.YourPlacementIsSavedYouCannot") %></p>
    </asp:Panel>
    <div class="application-list">
        <asp:Panel ID="EmptyPanel" runat="server" Visible="false" CssClass="application-empty"><%: L.T("Student.MyApplications.NoApplicationsYet") %> <a href="Opportunities.aspx"><%: L.T("Student.MyApplications.ExploreOpportunities") %></a> <%: L.T("Student.MyApplications.ToFindYourInternship") %></asp:Panel>
        <asp:Repeater ID="ApplicationRepeater" runat="server" OnItemCommand="Application_Command"><ItemTemplate>
            <article class="application-row" data-application-id="<%#: Eval("Id") %>">
                <div class="application-row-top"><div><h3><%#: Eval("OpportunityTitle") %></h3><div><%#: Eval("CompanyName") %></div><p class="application-help"><%: L.T("Student.MyApplications.Submitted") %> <%#: Time.Display((long)Eval("SubmittedAt")) %></p></div><span class="application-status status-<%#: Eval("Status").ToString().ToLowerInvariant() %>"><%#: Eval("Status") %></span></div>
                <asp:PlaceHolder runat="server" Visible='<%# (ApplicationStatus)Eval("Status") == ApplicationStatus.Rejected %>'><p class="review-rejection-reason"><strong><%: L.T("Student.MyApplications.RejectionReason") %></strong> <%#: Eval("RejectionReason") %></p></asp:PlaceHolder>
                <a class="application-view-link" href="Apply.aspx?opportunityId=<%#: Server.UrlEncode(Convert.ToString(Eval("OpportunityId"))) %>"><%: L.T("Student.MyApplications.ViewApplication") %></a>
                <asp:PlaceHolder runat="server" Visible='<%# CanConfirm(Container.DataItem) %>'>
                    <div class="offer-confirmation"><strong><%: L.T("Student.MyApplications.ReadyToJoinThisCompany") %></strong><p class="application-help"><%: L.T("Student.MyApplications.YouCanConfirmOnlyOneInternship") %></p>
                        <div class="offer-consent"><asp:CheckBox ID="ConfirmConsent" runat="server" Text="<%$ Resources:Student, MyApplications.IUnderstandThatICanConfirm %>" /></div>
                        <asp:Button runat="server" CommandName="Confirm" CommandArgument='<%# Eval("Id") %>' Text="<%$ Resources:Student, MyApplications.ConfirmOffer %>" CssClass="btn btn-brand"  data-ui-action="confirm" data-loading-label="Confirming…"/>
                    </div>
                </asp:PlaceHolder>
                <asp:PlaceHolder runat="server" Visible='<%# IsConfirmed(Container.DataItem) %>'><p class="confirmed-offer-label"><%: L.T("Student.MyApplications.ThisIsYourConfirmedInternship") %></p></asp:PlaceHolder>
                <asp:PlaceHolder runat="server" Visible='<%# NeedsSync(Container.DataItem) %>'><asp:Button runat="server" CommandName="Sync" CommandArgument='<%# Eval("Id") %>' Text="<%$ Resources:Student, MyApplications.SyncConfirmation %>" CssClass="btn btn-outline-secondary"  data-ui-action="sync" data-loading-label="Synchronizing…"/></asp:PlaceHolder>
            </article>
        </ItemTemplate></asp:Repeater>
    </div>
</div>
</asp:Content>
