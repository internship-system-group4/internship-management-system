<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="Students.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.Students" Title="Student records" %>
<%@ Register Src="StudentCreation.ascx" TagPrefix="uims" TagName="StudentCreation" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Assets/css/students.css?v=20261022-creation-modal") %>" />
</asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="students-page">
        <div class="students-intro">
            <div><span class="students-eyebrow"><%: L.T("Coordinator.Students.CoordinatorStudents") %></span><h2><%: L.T("Coordinator.Students.StudentRecords") %></h2><p><%: L.T("Coordinator.Students.FindAStudentAndReviewTheir") %></p></div>
            <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addStudentModal"><%: L.T("Coordinator.Students.AddStudent") %></button>
        </div>
        <uims:StudentCreation ID="StudentCreator" runat="server" OnCreated="StudentCreator_Created" />
        <nav class="students-tabs" aria-label="<%: L.T("Coordinator.Students.StudentPages") %>">
            <a class="active" aria-current="page" href="<%= ResolveUrl("~/Pages/Coordinator/Students.aspx") %>"><%: L.T("Coordinator.Students.ViewRecords") %></a>
            <button type="button" data-bs-toggle="modal" data-bs-target="#addStudentModal"><%: L.T("Coordinator.Students.AddStudent2") %></button>
            <a href="<%= ResolveUrl("~/Pages/Coordinator/ManageStudents.aspx") %>"><%: L.T("Coordinator.Students.ManageStudents") %></a>
        </nav>

        <section class="students-card" aria-labelledby="records-heading">
            <div class="students-card-heading"><div><h3 id="records-heading"><%: L.T("Coordinator.Students.Directory") %></h3><p><%: L.T("Coordinator.Students.SearchByNameStudentNumberEmail") %></p></div></div>
            <asp:Label ID="lblListMessage" runat="server" Visible="false" role="alert" />
            <div class="students-search">
                <label for="<%= txtSearch.ClientID %>" class="visually-hidden"><%: L.T("Coordinator.Students.SearchStudentRecords") %></label>
                <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" MaxLength="120" placeholder="<%$ Resources:Coordinator, Students.SearchStudentRecords %>" />
                <asp:Button ID="btnSearch" runat="server" Text="<%$ Resources:Coordinator, Students.Search %>" CssClass="btn btn-primary" OnClick="btnSearch_Click" CausesValidation="false" />
                <asp:Button ID="btnClearSearch" runat="server" Text="<%$ Resources:Coordinator, Students.Clear %>" CssClass="btn btn-outline-secondary" OnClick="btnClearSearch_Click" CausesValidation="false" />
            </div>
            <div class="table-responsive">
                <table class="table students-table align-middle">
                    <thead><tr><th scope="col"><%: L.T("Coordinator.Students.Student") %></th><th scope="col"><%: L.T("Coordinator.Students.StudentNumber") %></th><th scope="col"><%: L.T("Coordinator.Students.Major") %></th><th scope="col"><%: L.T("Coordinator.Students.TrainingHours") %></th><th scope="col"><%: L.T("Coordinator.Students.Status") %></th><th scope="col"><%: L.T("Coordinator.Students.Record") %></th></tr></thead>
                    <tbody><asp:Repeater ID="rptStudents" runat="server"><ItemTemplate><tr>
                        <td><strong><%#: Eval("FullName") %></strong><small><%#: Eval("Email") %></small></td>
                        <td><%#: Eval("StudentNumber") %></td><td><%#: Eval("Major") %></td>
                        <td><%#: Eval("ApprovedHours") %> / <%#: Eval("RequiredHours") %></td>
                        <td><span class='<%# (bool)Eval("IsActive") ? "students-status is-active" : "students-status is-inactive" %>'><%# L.T((bool)Eval("IsActive") ? "Coordinator.AccountAccess.Active" : "Coordinator.AccountAccess.Blocked") %></span></td>
                        <td><asp:LinkButton ID="btnView" runat="server" Text="<%$ Resources:Coordinator, Students.ViewRecord %>" CssClass="btn btn-sm btn-outline-primary" CommandArgument='<%# Eval("Id") %>' OnClick="btnView_Click" CausesValidation="false" /><asp:LinkButton ID="btnBlock" runat="server" Text='<%# L.T((bool)Eval("IsActive") ? "Coordinator.AccountAccess.Block" : "Coordinator.AccountAccess.Unblock") %>' CssClass='<%# (bool)Eval("IsActive") ? "btn btn-sm btn-outline-danger ms-1" : "btn btn-sm btn-outline-success ms-1" %>' CommandArgument='<%# Eval("Id") %>' CommandName='<%# (bool)Eval("IsActive") ? "Block" : "Unblock" %>' OnClick="btnToggleAccess_Click" OnClientClick='<%# AccessConfirmation((bool)Eval("IsActive"), (string)Eval("FullName")) %>' CausesValidation="false" data-ui-action="update" data-ui-validation="none" /></td>
                    </tr></ItemTemplate></asp:Repeater></tbody>
                </table>
            </div>
            <asp:Label ID="lblNoStudents" runat="server" Visible="false" CssClass="students-empty" />
        </section>

        <asp:Panel ID="pnlDetails" runat="server" Visible="false" CssClass="students-card students-detail" ClientIDMode="Static">
            <div class="students-card-heading"><div><span class="students-eyebrow"><%: L.T("Coordinator.Students.SelectedRecord") %></span><h3><asp:Label ID="lblStudentName" runat="server" /></h3></div><asp:HyperLink ID="lnkManage" runat="server" CssClass="btn btn-outline-primary" Text="<%$ Resources:Coordinator, Students.ManageThisStudent %>" /></div>
            <dl class="students-facts">
                <div><dt><%: L.T("Coordinator.Students.StudentNumber") %></dt><dd><asp:Label ID="lblStudentNumber" runat="server" /></dd></div>
                <div><dt><%: L.T("Coordinator.Students.LoginEmail") %></dt><dd><asp:Label ID="lblStudentEmail" runat="server" /></dd></div>
                <div><dt><%: L.T("Coordinator.Students.Phone") %></dt><dd><asp:Label ID="lblStudentPhone" runat="server" /></dd></div>
                <div><dt><%: L.T("Coordinator.Students.University") %></dt><dd><asp:Label ID="lblUniversity" runat="server" /></dd></div>
                <div><dt><%: L.T("Coordinator.Students.College") %></dt><dd><asp:Label ID="lblCollege" runat="server" /></dd></div>
                <div><dt><%: L.T("Coordinator.Students.Major") %></dt><dd><asp:Label ID="lblMajor" runat="server" /></dd></div>
                <div><dt><%: L.T("Coordinator.Students.ApprovedHours") %></dt><dd><asp:Label ID="lblApprovedHours" runat="server" /></dd></div>
                <div><dt><%: L.T("Coordinator.Students.RequiredHours") %></dt><dd><asp:Label ID="lblRequiredHours" runat="server" /></dd></div>
                <div><dt><%: L.T("Coordinator.Students.AccountStatus") %></dt><dd><asp:Label ID="lblStatus" runat="server" /></dd></div>
            </dl>
        </asp:Panel>
    </div>
</asp:Content>
