<%@ Page Language="C#" MasterPageFile="~/Layout/Student.master" AutoEventWireup="true" CodeBehind="Apply.aspx.cs" Inherits="InternshipManagementSystem.Pages.StudentArea.Apply" Title="Application Form" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

    <%-- ===================================================================
         Application Form
         Owner : Osama
         Cards : O01
         Delete the placeholder below and build the page here.
         =================================================================== --%>

    <div class="uims-stub">
        <span class="uims-stub-badge">O01</span>
        <h2>Application Form</h2>
        <p>Read the opportunity from the query string, validate the form, and create an InternshipApplication with status Pending. It must then appear in both My Applications and the company's Applications Review.</p>
        <p class="uims-stub-owner">Assigned to <strong>Osama</strong></p>
    </div>

</asp:Content>
