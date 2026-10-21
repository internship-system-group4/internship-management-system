<%@ Page Language="C#" MasterPageFile="~/Layout/Student.master" AutoEventWireup="true" CodeBehind="MyApplications.aspx.cs" Inherits="InternshipManagementSystem.Pages.StudentArea.MyApplications" Title="My Applications" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"><link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/applications.css") %>" /></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="application-page">
    <div class="application-heading"><h2>My applications</h2><p>Track your applications and choose one accepted internship offer.</p></div>
    <asp:Panel ID="NoticePanel" runat="server" Visible="false" CssClass="application-message application-success" role="status"><asp:Literal ID="NoticeText" runat="server" Mode="Encode" /></asp:Panel>
    <asp:Panel ID="ErrorPanel" runat="server" Visible="false" CssClass="application-message" role="alert"><asp:Literal ID="ErrorText" runat="server" Mode="Encode" /> <a href="MyApplications.aspx">Refresh applications</a></asp:Panel>
    <asp:Panel ID="PlacementPanel" runat="server" Visible="false" CssClass="confirmed-placement">
        <div><span class="application-status status-accepted">Confirmed internship</span><h3><asp:Literal ID="PlacementTitle" runat="server" Mode="Encode" /></h3><p><asp:Literal ID="PlacementCompany" runat="server" Mode="Encode" /></p></div>
        <p class="application-help">Your placement is saved. You cannot confirm another offer.</p>
    </asp:Panel>
    <div class="application-list">
        <asp:Panel ID="EmptyPanel" runat="server" Visible="false" CssClass="application-empty">No applications yet. <a href="Opportunities.aspx">Explore opportunities</a> to find your internship.</asp:Panel>
        <asp:Repeater ID="ApplicationRepeater" runat="server" OnItemCommand="Application_Command"><ItemTemplate>
            <article class="application-row" data-application-id="<%#: Eval("Id") %>">
                <div class="application-row-top"><div><h3><%#: Eval("OpportunityTitle") %></h3><div><%#: Eval("CompanyName") %></div><p class="application-help">Submitted <%#: Time.Display((long)Eval("SubmittedAt")) %></p></div><span class="application-status status-<%#: Eval("Status").ToString().ToLowerInvariant() %>"><%#: Eval("Status") %></span></div>
                <asp:PlaceHolder runat="server" Visible='<%# (ApplicationStatus)Eval("Status") == ApplicationStatus.Rejected %>'><p class="review-rejection-reason"><strong>Rejection reason:</strong> <%#: Eval("RejectionReason") %></p></asp:PlaceHolder>
                <details><summary>View application</summary><p><%#: Eval("CoverLetter") %></p><asp:HyperLink runat="server" NavigateUrl='<%# SafeCvUrl(Eval("CvUrl")) %>' Visible='<%# !string.IsNullOrEmpty(SafeCvUrl(Eval("CvUrl"))) %>' Target="_blank" rel="noopener noreferrer" Text="Open CV" /></details>
                <asp:PlaceHolder runat="server" Visible='<%# CanConfirm(Container.DataItem) %>'>
                    <div class="offer-confirmation"><strong>Ready to join this company?</strong><p class="application-help">You can confirm only one internship. Choose carefully before continuing.</p>
                        <div class="offer-consent"><asp:CheckBox ID="ConfirmConsent" runat="server" Text=" I understand that I can confirm only one internship offer." /></div>
                        <asp:Button runat="server" CommandName="Confirm" CommandArgument='<%# Eval("Id") %>' Text="Confirm offer" CssClass="btn btn-brand" />
                    </div>
                </asp:PlaceHolder>
                <asp:PlaceHolder runat="server" Visible='<%# IsConfirmed(Container.DataItem) %>'><p class="confirmed-offer-label">This is your confirmed internship.</p></asp:PlaceHolder>
                <asp:PlaceHolder runat="server" Visible='<%# NeedsSync(Container.DataItem) %>'><asp:Button runat="server" CommandName="Sync" CommandArgument='<%# Eval("Id") %>' Text="Sync confirmation" CssClass="btn btn-outline-secondary" /></asp:PlaceHolder>
            </article>
        </ItemTemplate></asp:Repeater>
    </div>
</div>
</asp:Content>
