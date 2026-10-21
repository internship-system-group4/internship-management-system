<%@ Page Language="C#" MasterPageFile="~/Layout/Public.master" AutoEventWireup="true" CodeBehind="ChangePassword.aspx.cs" Inherits="InternshipManagementSystem.Pages.AccountArea.ChangePassword" Title="Change Password" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

    <%-- ===================================================================
         Change Password
         Owner : Ahmad
         Cards : A04
         Delete the placeholder below and build the page here.
         =================================================================== --%>

    <div class="uims-stub">
        <span class="uims-stub-badge">A04</span>
        <h2>Change Password</h2>
        <p>Forced on first login. This is the one page that overrides AllowWhilePasswordChangePending, otherwise the guard would redirect to itself for ever. After AuthService.ChangePassword succeeds, call UserRepository.ClearMustChangePassword and refresh the session copy.</p>
        <p class="uims-stub-owner">Assigned to <strong>Ahmad</strong></p>
    </div>

</asp:Content>
