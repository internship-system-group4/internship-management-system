<%@ Page Language="C#" MasterPageFile="~/Layout/Student.master" AutoEventWireup="true" CodeBehind="Progress.aspx.cs" Inherits="InternshipManagementSystem.Pages.StudentArea.Progress" Title="My Progress & Evaluation" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

    <%-- ===================================================================
         My Progress & Evaluation
         Owner : Ahmad
         Cards : A15, A16
         Delete the placeholder below and build the page here.
         =================================================================== --%>

    <div class="uims-stub">
        <span class="uims-stub-badge">A15, A16</span>
        <h2>My Progress & Evaluation</h2>
        <p>Task grades, supervisor feedback, submission and revision history, APPROVED training hours and overall progress - plus the final result and report download once the coordinator approves. The confidential final evaluation forms must never appear here; use the EvaluationRepository methods named for task evaluations only.</p>
        <p class="uims-stub-owner">Assigned to <strong>Ahmad</strong></p>
    </div>

</asp:Content>
