<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="ManageStudents.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.ManageStudents" Title="Manage students" %>
<%@ Register Src="StudentCreation.ascx" TagPrefix="uims" TagName="StudentCreation" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"><link rel="stylesheet" href="<%= ResolveUrl("~/Assets/css/students.css?v=20261022-creation-modal") %>" /></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="students-page">
        <div class="students-intro"><div><span class="students-eyebrow"><%: L.T("Coordinator.ManageStudents.CoordinatorStudents") %></span><h2><%: L.T("Coordinator.ManageStudents.ManageStudents") %></h2><p><%: L.T("Coordinator.ManageStudents.UpdateAcademicDetailsOrRemoveAnd") %></p></div><button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addStudentModal"><%: L.T("Coordinator.ManageStudents.AddStudent") %></button></div>
        <uims:StudentCreation ID="StudentCreator" runat="server" OnCreated="StudentCreator_Created" />
        <nav class="students-tabs" aria-label="<%: L.T("Coordinator.ManageStudents.StudentPages") %>">
            <a href="<%= ResolveUrl("~/Pages/Coordinator/Students.aspx") %>"><%: L.T("Coordinator.ManageStudents.ViewRecords") %></a>
            <button type="button" data-bs-toggle="modal" data-bs-target="#addStudentModal"><%: L.T("Coordinator.ManageStudents.AddStudent2") %></button>
            <a class="active" aria-current="page" href="<%= ResolveUrl("~/Pages/Coordinator/ManageStudents.aspx") %>"><%: L.T("Coordinator.ManageStudents.ManageStudents") %></a>
        </nav>
        <section class="students-card" aria-labelledby="select-heading">
            <div class="students-card-heading"><div><h3 id="select-heading"><%: L.T("Coordinator.ManageStudents.SelectAStudent") %></h3><p><%: L.T("Coordinator.ManageStudents.ChooseARecordToEditInactive") %></p></div></div>
            <asp:Label ID="lblListMessage" runat="server" Visible="false" role="alert" />
            <div class="students-search">
                <label for="<%= txtSearch.ClientID %>" class="visually-hidden"><%: L.T("Coordinator.ManageStudents.SearchStudentsToManage") %></label>
                <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" MaxLength="120" placeholder="<%$ Resources:Coordinator, ManageStudents.SearchStudents %>" />
                <asp:Button ID="btnSearch" runat="server" Text="<%$ Resources:Coordinator, ManageStudents.Search %>" CssClass="btn btn-primary" OnClick="btnSearch_Click" CausesValidation="false" />
                <asp:Button ID="btnClearSearch" runat="server" Text="<%$ Resources:Coordinator, ManageStudents.Clear %>" CssClass="btn btn-outline-secondary" OnClick="btnClearSearch_Click" CausesValidation="false" />
            </div>
            <div class="table-responsive">
                <table class="table students-table align-middle">
                    <thead><tr><th scope="col"><%: L.T("Coordinator.ManageStudents.Student") %></th><th scope="col"><%: L.T("Coordinator.ManageStudents.StudentNumber") %></th><th scope="col"><%: L.T("Coordinator.ManageStudents.Major") %></th><th scope="col"><%: L.T("Coordinator.ManageStudents.Status") %></th><th scope="col"><%: L.T("Coordinator.ManageStudents.Action") %></th></tr></thead>
                    <tbody><asp:Repeater ID="rptStudents" runat="server"><ItemTemplate><tr>
                        <td><strong><%#: Eval("FullName") %></strong><small><%#: Eval("Email") %></small></td>
                        <td><%#: Eval("StudentNumber") %></td><td><%#: Eval("Major") %></td>
                        <td><span class='<%# (bool)Eval("IsActive") ? "students-status is-active" : "students-status is-inactive" %>'><%# (bool)Eval("IsActive") ? "Active" : "Inactive" %></span></td>
                        <td><asp:LinkButton ID="btnEdit" runat="server" data-ui-modal-opener="pnlDetails" Text="<%$ Resources:Coordinator, ManageStudents.Manage %>" CssClass="btn btn-sm btn-outline-primary" CommandArgument='<%# Eval("Id") %>' OnClick="btnEdit_Click" CausesValidation="false" /></td>
                    </tr></ItemTemplate></asp:Repeater></tbody>
                </table>
            </div>
            <asp:Label ID="lblNoStudents" runat="server" Visible="false" CssClass="students-empty" />
        </section>

        <asp:Panel ID="pnlDetails" runat="server" Visible="false" CssClass="modal fade" ClientIDMode="Static" tabindex="-1" aria-labelledby="studentModalTitle" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable modal-lg"><div class="modal-content students-modal-content">
                <div class="modal-header"><div><span class="students-eyebrow"><%: L.T("Coordinator.ManageStudents.ManageStudent") %></span><h3 class="modal-title h5 mb-0" id="studentModalTitle"><asp:Label ID="lblStudentName" runat="server" /></h3><p class="text-muted mb-0"><asp:Label ID="lblStudentEmail" runat="server" /></p></div><button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="<%: L.T("Coordinator.ManageStudents.Close") %>"></button></div>
                <div class="modal-body">
                    <asp:Label ID="lblDetailsMessage" runat="server" Visible="false" role="alert" />
                    <div class="students-section-label"><%: L.T("Coordinator.ManageStudents.AcademicInformation") %></div>
                    <div class="row g-3">
                        <div class="col-md-6"><label for="<%= txtEditStudentNumber.ClientID %>" class="form-label"><%: L.T("Coordinator.ManageStudents.StudentID") %></label><asp:TextBox ID="txtEditStudentNumber" runat="server" CssClass="form-control" ReadOnly="true" /><small class="text-muted"><%: L.T("Coordinator.ManageStudents.AssignedWhenTheAccountIsCreated") %></small></div>
                        <div class="col-md-6"><label for="<%= txtEditRequiredHours.ClientID %>" class="form-label"><%: L.T("Coordinator.ManageStudents.RequiredTrainingHours") %></label><asp:TextBox ID="txtEditRequiredHours" runat="server" CssClass="form-control" TextMode="Number" /></div>
                        <div class="col-md-6"><label for="<%= txtEditUniversity.ClientID %>" class="form-label"><%: L.T("Coordinator.ManageStudents.University") %></label><asp:TextBox ID="txtEditUniversity" runat="server" CssClass="form-control" MaxLength="120" /></div>
                        <div class="col-md-6"><label for="<%= txtEditCollege.ClientID %>" class="form-label"><%: L.T("Coordinator.ManageStudents.College") %></label><asp:TextBox ID="txtEditCollege" runat="server" CssClass="form-control" MaxLength="120" /></div>
                        <div class="col-md-6"><label for="<%= ddlEditMajor.ClientID %>" class="form-label"><%: L.T("Coordinator.ManageStudents.Major") %></label><asp:DropDownList ID="ddlEditMajor" runat="server" CssClass="form-select" /></div>
                    </div>
                    <div class="students-access"><div><h4><%: L.T("Coordinator.ManageStudents.AccountAccess") %></h4><p><asp:Label ID="lblAccessDescription" runat="server" /></p></div><asp:Button ID="btnToggleAccess" runat="server" CausesValidation="false" OnClick="btnToggleAccess_Click"  data-ui-action="update" data-loading-label="Updating…" data-ui-validation="none"/></div>
                </div>
                <div class="modal-footer"><asp:HyperLink ID="lnkRecord" runat="server" CssClass="btn btn-outline-secondary me-auto" Text="<%$ Resources:Coordinator, ManageStudents.ViewRecord %>" /><button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal"><%: L.T("Coordinator.ManageStudents.Close") %></button><asp:Button ID="btnSaveDetails" runat="server" Text="<%$ Resources:Coordinator, ManageStudents.SaveChanges %>" CssClass="btn btn-primary" OnClick="btnSaveDetails_Click"  data-ui-action="save" data-loading-label="Saving…"/></div>
            </div></div>
        </asp:Panel>
    </div>
</asp:Content>
<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server">
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var modal = document.getElementById('pnlDetails');
            var creating = document.querySelector('.creation-modal[data-open-on-load="true"]');
            if (modal && window.bootstrap && !creating) new bootstrap.Modal(modal).show();
        });
    </script>
</asp:Content>
