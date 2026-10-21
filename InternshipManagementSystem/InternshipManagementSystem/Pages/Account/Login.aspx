<%@ Page Language="C#" MasterPageFile="~/Layout/Public.master" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="InternshipManagementSystem.Pages.AccountArea.Login" Title="Login" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

    <%-- ===================================================================
         Login
         Owner : Ahmad
         Cards : A01, A02
         Delete the placeholder below and build the page here.
         =================================================================== --%>

    <div class="uims-stub">
        <span class="uims-stub-badge">A01, A02</span>
        <h2>Login</h2>
        <p>Email and password, show/hide password, validation, clear errors. On success call AuthService.SignIn, load the account with UserRepository.GetPerson, then SessionHelper.SignIn and redirect to user.DashboardUrl.</p>
        <p class="uims-stub-owner">Assigned to <strong>Ahmad</strong></p>
    </div>

</asp:Content>
