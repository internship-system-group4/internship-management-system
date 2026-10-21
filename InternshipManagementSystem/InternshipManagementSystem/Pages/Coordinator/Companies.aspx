<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="Companies.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.Companies" Title="Manage Companies" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

    <%-- ===================================================================
         Manage Companies
         Owner : Nada
         Cards : N03, N04
         Delete the placeholder below and build the page here.
         =================================================================== --%>

    <div class="uims-stub">
        <span class="uims-stub-badge">N03, N04</span>
        <h2>Manage Companies</h2>
        <p>The coordinator - not the company - creates company supervisor accounts here, and activates or deactivates them. Use the same AuthService + UserRepository pair as Manage Students so every account is provisioned identically.</p>
        <p class="uims-stub-owner">Assigned to <strong>Nada</strong></p>
    </div>

</asp:Content>
