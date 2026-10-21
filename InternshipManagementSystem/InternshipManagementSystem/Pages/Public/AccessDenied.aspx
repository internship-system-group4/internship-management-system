<%@ Page Language="C#" MasterPageFile="~/Layout/Public.master" AutoEventWireup="true" CodeBehind="AccessDenied.aspx.cs" Inherits="InternshipManagementSystem.Pages.PublicArea.AccessDenied" Title="Access Denied" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

    <%-- ===================================================================
         Access Denied
         Owner : Ahmad
         Cards : A02
         Delete the placeholder below and build the page here.
         =================================================================== --%>

    <div class="uims-stub">
        <span class="uims-stub-badge">A02</span>
        <h2>Access Denied</h2>
        <p>Shown when a signed-in user opens a page their role may not see. Already wired up by Security/SecurePage.cs - this page only needs a message and a link back to the user's own dashboard.</p>
        <p class="uims-stub-owner">Assigned to <strong>Ahmad</strong></p>
    </div>

</asp:Content>
