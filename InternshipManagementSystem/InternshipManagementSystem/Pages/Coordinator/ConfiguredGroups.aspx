<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="ConfiguredGroups.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.ConfiguredGroups" Title="Configured groups" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Assets/css/students.css?v=20261024-theme-7") %>" />
    <link rel="stylesheet" href="<%= ResolveUrl("~/Assets/css/configured-groups.css?v=20261024-theme-7") %>" />
</asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="students-page configured-groups">
        <div class="groups-intro">
            <div class="groups-title"><span class="groups-title-icon" aria-hidden="true"><i class="groups-icon groups-icon-people"></i></span><div><h2><%: L.T("Coordinator.ConfiguredGroups.ConfiguredGroups") %></h2><p><%: L.T("Coordinator.ConfiguredGroups.ReviewGroupMembershipAndSupervisorAssignments") %></p></div></div>
            <a class="btn groups-primary groups-create" href="<%= ResolveUrl("~/Pages/Coordinator/Groups.aspx") %>"><i data-ui-icon="plus" aria-hidden="true"></i><%: L.T("Coordinator.ConfiguredGroups.CreateGroupLabel") %></a>
        </div>
        <nav class="students-tabs" aria-label="<%: L.T("Coordinator.ConfiguredGroups.GroupPages") %>">
            <a href="<%= ResolveUrl("~/Pages/Coordinator/Groups.aspx") %>"><i data-ui-icon="edit" aria-hidden="true"></i><%: L.T("Coordinator.ConfiguredGroups.CreateEditGroup") %></a>
            <a class="active" aria-current="page" href="<%= ResolveUrl("~/Pages/Coordinator/ConfiguredGroups.aspx") %>"><i class="groups-icon groups-icon-people" aria-hidden="true"></i><%: L.T("Coordinator.ConfiguredGroups.ConfiguredGroups") %></a>
        </nav>

        <section class="students-card" aria-labelledby="groups-heading">
            <div class="students-card-heading"><div><h3 id="groups-heading"><%: L.T("Coordinator.ConfiguredGroups.Groups") %></h3><p><%: L.T("Coordinator.ConfiguredGroups.SearchByGroupNameAcademicYear") %></p></div><div class="groups-total"><span class="groups-total-icon" aria-hidden="true"><i class="groups-icon groups-icon-people"></i></span><div><span><%: L.T("Coordinator.ConfiguredGroups.TotalGroups") %></span><strong><asp:Literal ID="litTotalGroups" runat="server" Text="0" /></strong></div></div></div>
            <asp:Label ID="lblMessage" runat="server" Visible="false" role="alert" />
            <asp:Panel ID="pnlSearch" runat="server" CssClass="groups-filters" DefaultButton="btnSearch">
                <div class="groups-search-field">
                <label for="<%= txtSearch.ClientID %>" class="visually-hidden"><%: L.T("Coordinator.ConfiguredGroups.SearchConfiguredGroups") %></label>
                <i data-ui-icon="search" aria-hidden="true"></i><asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" MaxLength="120" placeholder="<%$ Resources:Coordinator, ConfiguredGroups.SearchPlaceholder %>" />
                </div>
                <div class="groups-filter"><label for="<%= ddlYear.ClientID %>"><%: L.T("Coordinator.ConfiguredGroups.AcademicYear") %></label><asp:DropDownList ID="ddlYear" runat="server" CssClass="form-select" /></div>
                <div class="groups-filter"><label for="<%= ddlSemester.ClientID %>"><%: L.T("Coordinator.ConfiguredGroups.Semester") %></label><asp:DropDownList ID="ddlSemester" runat="server" CssClass="form-select" /></div>
                <div class="groups-filter"><label for="<%= ddlSupervisor.ClientID %>"><%: L.T("Coordinator.ConfiguredGroups.Supervisor") %></label><asp:DropDownList ID="ddlSupervisor" runat="server" CssClass="form-select" /></div>
                <asp:LinkButton ID="btnSearch" runat="server" CssClass="btn groups-primary" OnClick="btnSearch_Click" CausesValidation="false"><i data-ui-icon="search" aria-hidden="true"></i><%: L.T("Coordinator.ConfiguredGroups.Search") %></asp:LinkButton>
                <asp:LinkButton ID="btnClearSearch" runat="server" CssClass="btn groups-clear" OnClick="btnClearSearch_Click" CausesValidation="false"><i class="groups-icon groups-icon-refresh" aria-hidden="true"></i><%: L.T("Coordinator.ConfiguredGroups.Clear") %></asp:LinkButton>
            </asp:Panel>
            <div class="table-responsive">
                <table class="table students-table groups-table align-middle">
                    <thead><tr><th scope="col">#</th><th scope="col"><%: L.T("Coordinator.ConfiguredGroups.Group") %></th><th scope="col"><%: L.T("Coordinator.ConfiguredGroups.AcademicYear") %></th><th scope="col"><%: L.T("Coordinator.ConfiguredGroups.Semester") %></th><th scope="col"><%: L.T("Coordinator.ConfiguredGroups.Supervisor") %></th><th scope="col"><%: L.T("Coordinator.ConfiguredGroups.Students") %></th><th scope="col"><%: L.T("Coordinator.ConfiguredGroups.Actions") %></th></tr></thead>
                    <tbody><asp:Repeater ID="rptGroups" runat="server"><ItemTemplate><tr>
                        <td><%# PageIndex * PageSize + Container.ItemIndex + 1 %></td>
                        <td><div class="groups-name"><span class='groups-initials tone-<%# Container.ItemIndex % 3 %>' aria-hidden="true"><%#: GroupInitials((string)Eval("Name")) %></span><strong><%#: Eval("Name") %></strong></div></td>
                        <td class="groups-term"><%#: DisplayValue((string)Eval("AcademicYear")) %></td>
                        <td class="groups-term"><%#: DisplayValue((string)Eval("Semester")) %></td>
                        <td><div class="groups-supervisor"><span class="groups-person" aria-hidden="true"><i class="groups-icon groups-icon-person"></i></span><span><%#: DisplayValue((string)Eval("AcademicSupervisorName")) %></span></div></td>
                        <td><span class="groups-student-count"><i class="groups-icon groups-icon-people" aria-hidden="true"></i><%#: ((InternshipManagementSystem.Models.StudentGroup)Container.DataItem).StudentIds == null ? 0 : ((InternshipManagementSystem.Models.StudentGroup)Container.DataItem).StudentIds.Count %></span></td>
                        <td><div class="groups-actions">
                            <asp:LinkButton ID="btnView" runat="server" CssClass="btn groups-view" CommandArgument='<%# Eval("Id") %>' OnClick="btnView_Click" CausesValidation="false"><i data-ui-icon="eye" aria-hidden="true"></i><%: L.T("Coordinator.ConfiguredGroups.View") %></asp:LinkButton>
                            <asp:LinkButton ID="btnEdit" runat="server" CssClass="btn groups-edit" CommandArgument='<%# Eval("Id") %>' OnClick="btnEdit_Click" CausesValidation="false"><i data-ui-icon="edit" aria-hidden="true"></i><%: L.T("Coordinator.ConfiguredGroups.Edit") %></asp:LinkButton>
                            <asp:LinkButton ID="btnDelete" runat="server" CssClass="btn groups-delete" CommandArgument='<%# Eval("Id") %>' OnClick="btnDelete_Click" CausesValidation="false" OnClientClick="return confirm('Delete this group? Its students will become unassigned.');" data-ui-action="delete" data-loading-label="Deleting…" data-ui-validation="none"><i data-ui-icon="trash" aria-hidden="true"></i><%: L.T("Coordinator.ConfiguredGroups.Delete") %></asp:LinkButton>
                        </div></td>
                    </tr></ItemTemplate></asp:Repeater></tbody>
                </table>
            </div>
            <asp:Label ID="lblNoGroups" runat="server" CssClass="students-empty" Visible="false" />
            <div class="groups-footer"><asp:Label ID="lblResults" runat="server" role="status" /><nav class="groups-pagination" aria-label="<%: L.T("Coordinator.ConfiguredGroups.Pagination") %>"><asp:LinkButton ID="btnPrevious" runat="server" CssClass="btn groups-page-arrow" OnClick="btnPrevious_Click" CausesValidation="false" ToolTip="<%$ Resources:Coordinator, ConfiguredGroups.Previous %>"><i class="groups-icon groups-icon-back" aria-hidden="true"></i></asp:LinkButton><span class="groups-current-page" aria-current="page"><asp:Literal ID="litPage" runat="server" Text="1" /></span><asp:LinkButton ID="btnNext" runat="server" CssClass="btn groups-page-arrow" OnClick="btnNext_Click" CausesValidation="false" ToolTip="<%$ Resources:Coordinator, ConfiguredGroups.Next %>"><i data-ui-icon="next" aria-hidden="true"></i></asp:LinkButton></nav></div>
        </section>

        <asp:Panel ID="pnlView" runat="server" Visible="false" CssClass="modal fade" ClientIDMode="Static" tabindex="-1" aria-labelledby="groupModalTitle" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable modal-xl"><div class="modal-content students-modal-content">
                <div class="modal-header"><div><span class="students-eyebrow"><%: L.T("Coordinator.ConfiguredGroups.GroupDetails") %></span><h3 class="modal-title h5 mb-0" id="groupModalTitle"><asp:Label ID="lblViewName" runat="server" /></h3><p class="text-muted mb-0"><asp:Label ID="lblViewSummary" runat="server" /></p></div><button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="<%: L.T("Coordinator.ConfiguredGroups.Close") %>"></button></div>
                <div class="modal-body">
                    <div class="row g-3 mb-3">
                        <div class="col-md-4"><div class="students-section-label"><%: L.T("Coordinator.ConfiguredGroups.AcademicSupervisor") %></div><div><asp:Label ID="lblViewSupervisor" runat="server" /></div><small class="text-muted"><asp:Label ID="lblViewSupervisorEmail" runat="server" /></small></div>
                        <div class="col-md-4"><div class="students-section-label"><%: L.T("Coordinator.ConfiguredGroups.AcademicYearSemester") %></div><div><asp:Label ID="lblViewTerm" runat="server" /></div></div>
                        <div class="col-md-4"><div class="students-section-label"><%: L.T("Coordinator.ConfiguredGroups.Created") %></div><div><asp:Label ID="lblViewCreated" runat="server" /></div></div>
                    </div>
                    <div class="students-section-label"><%: L.T("Coordinator.ConfiguredGroups.Students") %></div>
                    <div class="table-responsive">
                        <table class="table students-table align-middle mb-0">
                            <thead><tr><th scope="col"><%: L.T("Coordinator.ConfiguredGroups.Name") %></th><th scope="col"><%: L.T("Coordinator.ConfiguredGroups.StudentID") %></th><th scope="col"><%: L.T("Coordinator.ConfiguredGroups.Email") %></th><th scope="col"><%: L.T("Coordinator.ConfiguredGroups.Major") %></th><th scope="col"><%: L.T("Coordinator.ConfiguredGroups.Internship") %></th><th scope="col"><%: L.T("Coordinator.ConfiguredGroups.ApprovedHours") %></th><th scope="col"><%: L.T("Coordinator.ConfiguredGroups.Account") %></th></tr></thead>
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
                    <asp:Label ID="lblViewNoStudents" runat="server" CssClass="students-empty" Visible="false" Text="<%$ Resources:Coordinator, ConfiguredGroups.NoStudentsAreAssignedToThis %>" />
                </div>
                <div class="modal-footer"><button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal"><%: L.T("Coordinator.ConfiguredGroups.Close") %></button></div>
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
