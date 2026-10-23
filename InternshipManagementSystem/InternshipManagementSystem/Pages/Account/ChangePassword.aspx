<%@ Page Language="C#" MasterPageFile="~/Layout/Public.master" AutoEventWireup="true" CodeBehind="ChangePassword.aspx.cs" Inherits="InternshipManagementSystem.Pages.AccountArea.ChangePassword" Title="Change Password" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container py-5" style="max-width: 480px">
        <h1 class="h3 mb-3">Change your password</h1>
        <p>Choose a new password before continuing to your account.</p>
        <asp:Label ID="lblMessage" runat="server" Visible="false" role="alert" />
        <div class="mb-3"><label for="<%= txtNewPassword.ClientID %>" class="form-label">New password</label><asp:TextBox ID="txtNewPassword" runat="server" CssClass="form-control" TextMode="Password" MaxLength="128" /></div>
        <div class="mb-3"><label for="<%= txtConfirmPassword.ClientID %>" class="form-label">Confirm new password</label><asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-control" TextMode="Password" MaxLength="128" /></div>
        <asp:Button ID="btnChange" runat="server" Text="Change password" CssClass="btn btn-primary" OnClick="btnChange_Click" />
    </div>
</asp:Content>
