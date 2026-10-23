<%@ Page Language="C#" MasterPageFile="~/Layout/Public.master" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="InternshipManagementSystem.Pages.AccountArea.Login" Title="Login" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container py-5" style="max-width: 480px">
        <h1 class="h3 mb-3">Sign in</h1>
        <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="alert alert-danger d-block" role="alert" />
        <div class="mb-3"><label for="<%= txtEmail.ClientID %>" class="form-label">Email</label><asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" MaxLength="254" /></div>
        <div class="mb-3"><label for="<%= txtPassword.ClientID %>" class="form-label">Password</label><asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" /></div>
        <asp:Button ID="btnSignIn" runat="server" Text="Sign in" CssClass="btn btn-primary" OnClick="btnSignIn_Click" />
        <p class="mt-3"><a href="<%: ResolveUrl("~/Pages/Account/ForgotPassword.aspx") %>">Forgot your password?</a></p>
    </div>
</asp:Content>
