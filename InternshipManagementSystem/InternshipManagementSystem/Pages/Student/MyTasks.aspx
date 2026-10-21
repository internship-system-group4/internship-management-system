<%@ Page Language="C#" MasterPageFile="~/Layout/Student.master" AutoEventWireup="true" CodeBehind="MyTasks.aspx.cs" Inherits="InternshipManagementSystem.Pages.StudentArea.MyTasks" Title="My Tasks" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

    <%-- ===================================================================
         My Tasks
         Owner : Fatima
         Cards : F03, F04
         Delete the placeholder below and build the page here.
         =================================================================== --%>

    <div class="uims-stub">
        <span class="uims-stub-badge">F03, F04</span>
        <h2>My Tasks</h2>
        <p>The student's own tasks with deadlines and statuses, and the submission form for text, a link or a file. Each submission is a new Submission record with an incremented AttemptNumber - never overwrite the previous attempt.</p>
        <p class="uims-stub-owner">Assigned to <strong>Fatima</strong></p>
    </div>

</asp:Content>
