<%@ Page Language="C#" MasterPageFile="~/Layout/Company.master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="InternshipManagementSystem.Pages.CompanyArea.Dashboard" Title="Company Dashboard" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

    <%-- ===================================================================
         Company Dashboard
         Owner : Nada
         Cards : N05
         Delete the placeholder below and build the page here.
         =================================================================== --%>

    <div class="uims-stub">
        <span class="uims-stub-badge">N05</span>
        <h2>Company Dashboard</h2>
        <p>Counts for this company only: opportunities, applications, students, tasks, submissions and evaluations. Filter everything by CurrentSupervisor.CompanyId.</p>
        <p class="uims-stub-owner">Assigned to <strong>Nada</strong></p>
    </div>

</asp:Content>
