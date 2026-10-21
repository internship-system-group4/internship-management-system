<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="CompletionReview.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.CompletionReview" Title="Final Completion Review" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

    <%-- ===================================================================
         Final Completion Review
         Owner : Ahmad
         Cards : A10 - A14
         Delete the placeholder below and build the page here.
         =================================================================== --%>

    <div class="uims-stub">
        <span class="uims-stub-badge">A10 - A14</span>
        <h2>Final Completion Review</h2>
        <p>The last step of the whole workflow: show both final evaluations, approved hours and the university's conditions; compute the final result with GradingService; approve completion; then generate the official PDF report and the certificate. Nothing may be marked complete without this approval.</p>
        <p class="uims-stub-owner">Assigned to <strong>Ahmad</strong></p>
    </div>

</asp:Content>
