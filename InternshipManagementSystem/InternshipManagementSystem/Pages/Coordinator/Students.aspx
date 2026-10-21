<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="Students.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.Students" Title="Manage Students" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

    <%-- ===================================================================
         Manage Students
         Owner : Ahmad
         Cards : A05, A06
         Delete the placeholder below and build the page here.
         =================================================================== --%>

    <div class="uims-stub">
        <span class="uims-stub-badge">A05, A06</span>
        <h2>Manage Students</h2>
        <p>Create student accounts with a temporary password through AuthService.CreateAccount, save the profile at users/{uid}, and provide a searchable list with edit. Set MustChangePassword = true on creation.</p>
        <p class="uims-stub-owner">Assigned to <strong>Ahmad</strong></p>
    </div>

</asp:Content>
