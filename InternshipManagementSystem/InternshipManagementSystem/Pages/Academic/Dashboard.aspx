<%@ Page Language="C#" MasterPageFile="~/Layout/Academic.master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="InternshipManagementSystem.Pages.AcademicArea.Dashboard" Title="Academic Dashboard" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

    <%-- ===================================================================
         Academic Dashboard
         Owner : Suja
         Cards : S01
         Delete the placeholder below and build the page here.
         =================================================================== --%>

    <div class="uims-stub">
        <span class="uims-stub-badge">S01</span>
        <h2>Academic Dashboard</h2>
        <p>Students assigned to this supervisor by the coordinator, with internship status and progress. UserRepository.GetStudentsBySupervisor does the filtering.</p>
        <p class="uims-stub-owner">Assigned to <strong>Suja</strong></p>
    </div>

</asp:Content>
