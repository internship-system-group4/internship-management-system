<%@ Page Language="C#" MasterPageFile="~/Layout/Company.master" AutoEventWireup="true" CodeBehind="Account.aspx.cs" Inherits="InternshipManagementSystem.Pages.CompanyArea.Account" Title="My Account" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

    <%-- ===================================================================
         My Account
         Owner : Nada
         Cards : N10
         Delete the placeholder below and build the page here.
         =================================================================== --%>

    <div class="uims-stub">
        <span class="uims-stub-badge">N10</span>
        <h2>My Account</h2>
        <p>Permitted profile fields only. A supervisor must not be able to change their own role or company association.</p>
        <p class="uims-stub-owner">Assigned to <strong>Nada</strong></p>
    </div>

</asp:Content>
