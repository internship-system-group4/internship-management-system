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
                    <details class="review-application-details"><summary>View application and CV</summary><p><%#: Eval("CoverLetter") %></p><asp:HyperLink runat="server" NavigateUrl='<%# SafeCvUrl(Eval("CvUrl")) %>' Visible='<%# !string.IsNullOrEmpty(SafeCvUrl(Eval("CvUrl"))) %>' Target="_blank" rel="noopener noreferrer" Text="Open CV" /></details>
                    <asp:PlaceHolder runat="server" Visible='<%# (ApplicationStatus)Eval("Status") == ApplicationStatus.Pending %>'>
                        <div class="review-decision">
                            <div class="review-accept"><div><strong>Ready to offer this internship?</strong><p class="application-help">Acceptance offers a place. The student still needs to confirm one offer.</p></div><asp:Button runat="server" CommandName="Accept" CommandArgument='<%# Eval("Id") %>' Text="Accept application" CssClass="btn btn-brand" /></div>
                            <details class="review-reject"><summary>Reject application</summary><div class="review-reject-fields">
                                <asp:Label runat="server" AssociatedControlID="RejectionReason" Text="Reason for rejection (required)" CssClass="application-label" />
                                <asp:TextBox ID="RejectionReason" runat="server" TextMode="MultiLine" Rows="3" MaxLength="2000" CssClass="form-control" placeholder="Explain the decision so the student knows why their application was rejected." />
                                <p class="application-help">This reason will be visible to the student. Up to 2,000 characters.</p>
                                <asp:Button runat="server" CommandName="Reject" CommandArgument='<%# Eval("Id") %>' Text="Confirm rejection" CssClass="btn review-reject-button" />
                            </div></details>
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
    document.querySelectorAll('.review-reject textarea').forEach(function (field) { field.maxLength = 2000; });
    var invalid = document.querySelector('[data-rejection-error]');
    if (invalid) { invalid.closest('details').open = true; invalid.focus(); }
}());
</script>
</asp:Content>
