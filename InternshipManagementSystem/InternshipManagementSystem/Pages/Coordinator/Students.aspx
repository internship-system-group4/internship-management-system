<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="Students.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.Students" Title="Student records" %>
<%@ Register Src="StudentCreation.ascx" TagPrefix="uims" TagName="StudentCreation" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Assets/css/students.css?v=20261022-creation-modal") %>" />
</asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="students-page">
        <div class="students-intro">
            <div><span class="students-eyebrow">Coordinator / Students</span><h2>Student records</h2><p>Find a student and review their account and training information.</p></div>
            <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addStudentModal">+ Add student</button>
        </div>
        <uims:StudentCreation ID="StudentCreator" runat="server" OnCreated="StudentCreator_Created" />
        <nav class="students-tabs" aria-label="Student pages">
            <a class="active" aria-current="page" href="<%= ResolveUrl("~/Pages/Coordinator/Students.aspx") %>">View records</a>
            <button type="button" data-bs-toggle="modal" data-bs-target="#addStudentModal">Add student</button>
            <a href="<%= ResolveUrl("~/Pages/Coordinator/ManageStudents.aspx") %>">Manage students</a>
        </nav>

        <section class="students-card" aria-labelledby="records-heading">
            <div class="students-card-heading"><div><h3 id="records-heading">Directory</h3><p>Search by name, student number, email, university, college, or major.</p></div></div>
            <asp:Label ID="lblListMessage" runat="server" Visible="false" role="alert" />
            <div class="students-search">
                <label for="<%= txtSearch.ClientID %>" class="visually-hidden">Search student records</label>
                <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" MaxLength="120" placeholder="Search student records" />
                <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-primary" OnClick="btnSearch_Click" CausesValidation="false" />
                <asp:Button ID="btnClearSearch" runat="server" Text="Clear" CssClass="btn btn-outline-secondary" OnClick="btnClearSearch_Click" CausesValidation="false" />
            </div>
            <div class="table-responsive">
                <table class="table students-table align-middle">
                    <thead><tr><th scope="col">Student</th><th scope="col">Student number</th><th scope="col">Major</th><th scope="col">Training hours</th><th scope="col">Status</th><th scope="col">Record</th></tr></thead>
                    <tbody><asp:Repeater ID="rptStudents" runat="server"><ItemTemplate><tr>
                        <td><strong><%#: Eval("FullName") %></strong><small><%#: Eval("Email") %></small></td>
                        <td><%#: Eval("StudentNumber") %></td><td><%#: Eval("Major") %></td>
                        <td><%#: Eval("ApprovedHours") %> / <%#: Eval("RequiredHours") %></td>
                        <td><span class='<%# (bool)Eval("IsActive") ? "students-status is-active" : "students-status is-inactive" %>'><%# (bool)Eval("IsActive") ? "Active" : "Inactive" %></span></td>
                        <td><asp:LinkButton ID="btnView" runat="server" Text="View record" CssClass="btn btn-sm btn-outline-primary" CommandArgument='<%# Eval("Id") %>' OnClick="btnView_Click" CausesValidation="false" /></td>
                    </tr></ItemTemplate></asp:Repeater></tbody>
                </table>
            </div>
            <asp:Label ID="lblNoStudents" runat="server" Visible="false" CssClass="students-empty" />
        </section>

        <asp:Panel ID="pnlDetails" runat="server" Visible="false" CssClass="students-card students-detail" ClientIDMode="Static">
            <div class="students-card-heading"><div><span class="students-eyebrow">Selected record</span><h3><asp:Label ID="lblStudentName" runat="server" /></h3></div><asp:HyperLink ID="lnkManage" runat="server" CssClass="btn btn-outline-primary" Text="Manage this student" /></div>
            <dl class="students-facts">
                <div><dt>Student number</dt><dd><asp:Label ID="lblStudentNumber" runat="server" /></dd></div>
                <div><dt>Login email</dt><dd><asp:Label ID="lblStudentEmail" runat="server" /></dd></div>
                <div><dt>Phone</dt><dd><asp:Label ID="lblStudentPhone" runat="server" /></dd></div>
                <div><dt>University</dt><dd><asp:Label ID="lblUniversity" runat="server" /></dd></div>
                <div><dt>College</dt><dd><asp:Label ID="lblCollege" runat="server" /></dd></div>
                <div><dt>Major</dt><dd><asp:Label ID="lblMajor" runat="server" /></dd></div>
                <div><dt>Approved hours</dt><dd><asp:Label ID="lblApprovedHours" runat="server" /></dd></div>
                <div><dt>Required hours</dt><dd><asp:Label ID="lblRequiredHours" runat="server" /></dd></div>
                <div><dt>Account status</dt><dd><asp:Label ID="lblStatus" runat="server" /></dd></div>
            </dl>
        </asp:Panel>
    </div>
</asp:Content>
