<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="ConfiguredGroups.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.ConfiguredGroups" Title="Configured groups" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Assets/css/students.css") %>" />
</asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="students-page">
        <div class="students-intro">
            <div><span class="students-eyebrow">Coordinator / Groups</span><h2>Configured groups</h2><p>Review group membership and supervisor assignments.</p></div>
            <a class="btn btn-primary" href="<%= ResolveUrl("~/Pages/Coordinator/Groups.aspx") %>">+ Create group</a>
        </div>
        <nav class="students-tabs" aria-label="Group pages">
            <a href="<%= ResolveUrl("~/Pages/Coordinator/Groups.aspx") %>">Create / edit group</a>
            <a class="active" aria-current="page" href="<%= ResolveUrl("~/Pages/Coordinator/ConfiguredGroups.aspx") %>">Configured groups</a>
        </nav>

        <section class="students-card" aria-labelledby="groups-heading">
            <div class="students-card-heading"><div><h3 id="groups-heading">Groups</h3><p>Search by group name, academic year, semester, or supervisor.</p></div></div>
            <asp:Label ID="lblMessage" runat="server" Visible="false" role="alert" />
            <div class="students-search">
                <label for="<%= txtSearch.ClientID %>" class="visually-hidden">Search configured groups</label>
                <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" MaxLength="120" placeholder="Search configured groups" />
                <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-primary" OnClick="btnSearch_Click" CausesValidation="false" />
                <asp:Button ID="btnClearSearch" runat="server" Text="Clear" CssClass="btn btn-outline-secondary" OnClick="btnClearSearch_Click" CausesValidation="false" />
            </div>
            <div class="table-responsive">
                <table class="table students-table align-middle">
                    <thead><tr><th scope="col">Group</th><th scope="col">Academic year</th><th scope="col">Semester</th><th scope="col">Supervisor</th><th scope="col">Students</th><th scope="col">Actions</th></tr></thead>
                    <tbody><asp:Repeater ID="rptGroups" runat="server"><ItemTemplate><tr>
                        <td><strong><%#: Eval("Name") %></strong></td>
                        <td><%#: Eval("AcademicYear") %></td>
                        <td><%#: Eval("Semester") %></td>
                        <td><%#: Eval("AcademicSupervisorName") %></td>
                        <td><%#: ((InternshipManagementSystem.Models.StudentGroup)Container.DataItem).StudentIds == null ? 0 : ((InternshipManagementSystem.Models.StudentGroup)Container.DataItem).StudentIds.Count %></td>
                        <td><div class="d-flex flex-wrap gap-2">
                            <asp:LinkButton ID="btnView" runat="server" Text="View" CssClass="btn btn-sm btn-outline-secondary" CommandArgument='<%# Eval("Id") %>' OnClick="btnView_Click" CausesValidation="false" />
                            <asp:LinkButton ID="btnEdit" runat="server" Text="Edit group" CssClass="btn btn-sm btn-outline-primary" CommandArgument='<%# Eval("Id") %>' OnClick="btnEdit_Click" CausesValidation="false" />
                            <asp:LinkButton ID="btnDelete" runat="server" Text="Delete" CssClass="btn btn-sm btn-outline-danger" CommandArgument='<%# Eval("Id") %>' OnClick="btnDelete_Click" CausesValidation="false" OnClientClick="return confirm('Delete this group? Its students will become unassigned.');"  data-ui-action="delete" data-loading-label="Deleting…" data-ui-validation="none"/>
                        </div></td>
                    </tr></ItemTemplate></asp:Repeater></tbody>
                </table>
            </div>
            <asp:Label ID="lblNoGroups" runat="server" CssClass="students-empty" Visible="false" />
        </section>

        <asp:Panel ID="pnlView" runat="server" Visible="false" CssClass="modal fade" ClientIDMode="Static" tabindex="-1" aria-labelledby="groupModalTitle" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable modal-xl"><div class="modal-content students-modal-content">
                <div class="modal-header"><div><span class="students-eyebrow">Group details</span><h3 class="modal-title h5 mb-0" id="groupModalTitle"><asp:Label ID="lblViewName" runat="server" /></h3><p class="text-muted mb-0"><asp:Label ID="lblViewSummary" runat="server" /></p></div><button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button></div>
                <div class="modal-body">
                    <div class="row g-3 mb-3">
                        <div class="col-md-4"><div class="students-section-label">Academic supervisor</div><div><asp:Label ID="lblViewSupervisor" runat="server" /></div><small class="text-muted"><asp:Label ID="lblViewSupervisorEmail" runat="server" /></small></div>
                        <div class="col-md-4"><div class="students-section-label">Academic year / semester</div><div><asp:Label ID="lblViewTerm" runat="server" /></div></div>
                        <div class="col-md-4"><div class="students-section-label">Created</div><div><asp:Label ID="lblViewCreated" runat="server" /></div></div>
                    </div>
                    <div class="students-section-label">Students</div>
                    <div class="table-responsive">
                        <table class="table students-table align-middle mb-0">
                            <thead><tr><th scope="col">Name</th><th scope="col">Student ID</th><th scope="col">Email</th><th scope="col">Major</th><th scope="col">Internship</th><th scope="col">Approved hours</th><th scope="col">Account</th></tr></thead>
                            <tbody><asp:Repeater ID="rptViewStudents" runat="server"><ItemTemplate><tr>
                                <td><strong><%#: Eval("Name") %></strong></td>
                                <td><%#: Eval("StudentNumber") %></td>
                                <td><%#: Eval("Email") %></td>
                                <td><%#: Eval("Major") %></td>
                                <td><%#: Eval("Internship") %></td>
                                <td><%#: Eval("Hours") %></td>
                                <td><span class='<%# (bool)Eval("IsActive") ? "badge text-bg-success" : "badge text-bg-secondary" %>'><%# (bool)Eval("IsActive") ? "Active" : "Inactive" %></span></td>
                            </tr></ItemTemplate></asp:Repeater></tbody>
                        </table>
                    </div>
                    <asp:Label ID="lblViewNoStudents" runat="server" CssClass="students-empty" Visible="false" Text="No students are assigned to this group." />
                </div>
                <div class="modal-footer"><button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Close</button></div>
            </div></div>
        </asp:Panel>
    </div>
</asp:Content>
<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server">
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var modal = document.getElementById('pnlView');
            if (modal && window.bootstrap) new bootstrap.Modal(modal).show();
        });
    </script>
</asp:Content>
