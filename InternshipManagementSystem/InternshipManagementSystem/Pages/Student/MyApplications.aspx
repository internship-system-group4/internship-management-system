<%@ Page Language="C#" MasterPageFile="~/Layout/Student.master" AutoEventWireup="true" CodeBehind="MyApplications.aspx.cs" Inherits="InternshipManagementSystem.Pages.StudentArea.MyApplications" Title="My Applications" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

    <%-- ===================================================================
         My Applications
         Owner : Osama
         Cards : O02, O03
         Delete the placeholder below and build the page here.
         =================================================================== --%>

    <div class="uims-stub">
        <span class="uims-stub-badge">O02, O03</span>
        <h2>My Applications</h2>
        <p>List the student's applications with status and rejection reasons, and let them confirm one accepted offer. Use PlacementRepository.Confirm(studentUid, placement); Exists(studentUid) checks for an internship and GetById(studentUid) loads it. Confirmation never replaces an existing placement.</p>
        <p class="uims-stub-owner">Assigned to <strong>Osama</strong></p>
    </div>

</asp:Content>
