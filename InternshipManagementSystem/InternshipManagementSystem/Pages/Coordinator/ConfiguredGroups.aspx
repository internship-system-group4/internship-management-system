<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="ConfiguredGroups.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.ConfiguredGroups" Title="Configured groups" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="students-page dir-page">
        <header class="dir-head">
            <div>
                <div class="dir-crumb"><%: L.T("Coordinator.ConfiguredGroups.CoordinatorGroups") %></div>
                <h2><%: L.T("Coordinator.ConfiguredGroups.ConfiguredGroups") %></h2>
                <p><%: L.T("Coordinator.ConfiguredGroups.ReviewGroupMembershipAndSupervisorAssignments") %></p>
            </div>
            <a class="btn btn-brand dir-add" href="<%= ResolveUrl("~/Pages/Coordinator/Groups.aspx") %>"><span data-ui-icon="plus" aria-hidden="true"></span> <%: L.T("Coordinator.ConfiguredGroups.CreateGroupLabel") %></a>
        </header>
        <nav class="students-tabs" aria-label="<%: L.T("Coordinator.ConfiguredGroups.GroupPages") %>">
            <a href="<%= ResolveUrl("~/Pages/Coordinator/Groups.aspx") %>"><span data-ui-icon="edit" aria-hidden="true"></span><%: L.T("Coordinator.ConfiguredGroups.CreateEditGroup") %></a>
            <a class="active" aria-current="page" href="<%= ResolveUrl("~/Pages/Coordinator/ConfiguredGroups.aspx") %>"><span data-ui-icon="people" aria-hidden="true"></span><%: L.T("Coordinator.ConfiguredGroups.ConfiguredGroups") %></a>
        </nav>

        <asp:Label ID="lblMessage" runat="server" Visible="false" role="alert" />
        <section class="dir-card" aria-labelledby="groups-heading">
            <div class="dir-toolbar">
                <div class="dir-title"><h3 id="groups-heading"><%: L.T("Coordinator.ConfiguredGroups.Groups") %> <span class="dir-count" title="<%: L.T("Coordinator.ConfiguredGroups.TotalGroups") %>"><asp:Literal ID="litTotalGroups" runat="server" Text="0" /></span></h3><p><%: L.T("Coordinator.ConfiguredGroups.SearchByGroupNameAcademicYear") %></p></div>
                <asp:Panel ID="pnlSearch" runat="server" CssClass="dir-filters" DefaultButton="btnSearch">
                    <label class="dir-search"><span class="visually-hidden"><%: L.T("Coordinator.ConfiguredGroups.SearchConfiguredGroups") %></span><span data-ui-icon="search" aria-hidden="true"></span><asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" TextMode="Search" MaxLength="120" placeholder="<%$ Resources:Coordinator, ConfiguredGroups.SearchPlaceholder %>" /></label>
                    <label><span class="visually-hidden"><%: L.T("Coordinator.ConfiguredGroups.AcademicYear") %></span><asp:DropDownList ID="ddlYear" runat="server" CssClass="form-select" /></label>
                    <label><span class="visually-hidden"><%: L.T("Coordinator.ConfiguredGroups.Semester") %></span><asp:DropDownList ID="ddlSemester" runat="server" CssClass="form-select" /></label>
                    <label><span class="visually-hidden"><%: L.T("Coordinator.ConfiguredGroups.Supervisor") %></span><asp:DropDownList ID="ddlSupervisor" runat="server" CssClass="form-select" /></label>
                    <asp:LinkButton ID="btnSearch" runat="server" CssClass="btn btn-brand" OnClick="btnSearch_Click" CausesValidation="false"><span data-ui-icon="search" aria-hidden="true"></span> <%: L.T("Coordinator.ConfiguredGroups.Search") %></asp:LinkButton>
                    <asp:LinkButton ID="btnClearSearch" runat="server" CssClass="dir-btn" OnClick="btnClearSearch_Click" CausesValidation="false"><span data-ui-icon="close" aria-hidden="true"></span> <%: L.T("Coordinator.ConfiguredGroups.Clear") %></asp:LinkButton>
                </asp:Panel>
            </div>

            <div class="table-responsive">
                <table class="dir-table">
                    <thead><tr><th scope="col">#</th><th scope="col"><%: L.T("Coordinator.ConfiguredGroups.Group") %></th><th scope="col"><%: L.T("Coordinator.ConfiguredGroups.AcademicYear") %></th><th scope="col"><%: L.T("Coordinator.ConfiguredGroups.Semester") %></th><th scope="col"><%: L.T("Coordinator.ConfiguredGroups.Supervisor") %></th><th scope="col"><%: L.T("Coordinator.ConfiguredGroups.Students") %></th><th scope="col" class="dir-actions-col"><%: L.T("Coordinator.ConfiguredGroups.Actions") %></th></tr></thead>
                    <tbody><asp:Repeater ID="rptGroups" runat="server"><ItemTemplate><tr style="--dir-i:<%# Container.ItemIndex %>">
                        <td class="dir-num"><%# PageIndex * PageSize + Container.ItemIndex + 1 %></td>
                        <td><div class="dir-person"><span class="dir-avatar" aria-hidden="true"><%#: GroupInitials((string)Eval("Name")) %></span><div><strong><%#: Eval("Name") %></strong></div></div></td>
                        <td><%#: DisplayValue((string)Eval("AcademicYear")) %></td>
                        <td><%#: DisplayValue((string)Eval("Semester")) %></td>
                        <td><%#: DisplayValue((string)Eval("AcademicSupervisorName")) %></td>
                        <td><div class="dir-tally"><span><b><%#: ((InternshipManagementSystem.Models.StudentGroup)Container.DataItem).StudentIds == null ? 0 : ((InternshipManagementSystem.Models.StudentGroup)Container.DataItem).StudentIds.Count %></b> <%# L.T("Coordinator.ConfiguredGroups.Students") %></span></div></td>
                        <td><div class="dir-actions">
                            <asp:LinkButton ID="btnView" runat="server" CssClass="dir-btn" CommandArgument='<%# Eval("Id") %>' OnClick="btnView_Click" CausesValidation="false"><span data-ui-icon="eye" aria-hidden="true"></span> <%# L.T("Coordinator.ConfiguredGroups.View") %></asp:LinkButton>
                            <asp:LinkButton ID="btnEdit" runat="server" CssClass="dir-btn dir-btn-primary" CommandArgument='<%# Eval("Id") %>' OnClick="btnEdit_Click" CausesValidation="false"><span data-ui-icon="edit" aria-hidden="true"></span> <%# L.T("Coordinator.ConfiguredGroups.Edit") %></asp:LinkButton>
                        </div></td>
                    </tr></ItemTemplate></asp:Repeater></tbody>
                </table>
            </div>
            <asp:Label ID="lblNoGroups" runat="server" CssClass="dir-empty" Visible="false" />
            <div class="dir-foot"><asp:Label ID="lblResults" runat="server" role="status" /><nav aria-label="<%: L.T("Coordinator.ConfiguredGroups.Pagination") %>"><asp:LinkButton ID="btnPrevious" runat="server" CssClass="dir-btn dir-btn-icon" OnClick="btnPrevious_Click" CausesValidation="false" ToolTip="<%$ Resources:Coordinator, ConfiguredGroups.Previous %>"><span data-ui-icon="back" aria-hidden="true"></span></asp:LinkButton><span class="dir-page-no" aria-current="page"><asp:Literal ID="litPage" runat="server" Text="1" /></span><asp:LinkButton ID="btnNext" runat="server" CssClass="dir-btn dir-btn-icon" OnClick="btnNext_Click" CausesValidation="false" ToolTip="<%$ Resources:Coordinator, ConfiguredGroups.Next %>"><span data-ui-icon="next" aria-hidden="true"></span></asp:LinkButton></nav></div>
        </section>

        <asp:Panel ID="pnlView" runat="server" Visible="false" CssClass="modal fade dir-modal" ClientIDMode="Static" tabindex="-1" aria-labelledby="groupModalTitle" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable modal-xl"><div class="modal-content">
                <div class="modal-header dir-modal-hero">
                    <span class="dir-avatar dir-avatar-lg" aria-hidden="true"><span data-ui-icon="people"></span></span>
                    <div class="dir-hero-text"><span class="dir-eyebrow"><%: L.T("Coordinator.ConfiguredGroups.GroupDetails") %></span><h3 class="modal-title" id="groupModalTitle"><asp:Label ID="lblViewName" runat="server" /></h3><p><asp:Label ID="lblViewSummary" runat="server" /></p></div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="<%: L.T("Coordinator.ConfiguredGroups.Close") %>"></button>
                </div>
                <div class="modal-body">
                    <div class="dir-info-grid mb-3">
                        <section class="dir-info-wide"><dl class="dir-dl-3">
                            <div><dt><%: L.T("Coordinator.ConfiguredGroups.AcademicSupervisor") %></dt><dd><asp:Label ID="lblViewSupervisor" runat="server" /><small class="d-block text-muted fw-normal"><asp:Label ID="lblViewSupervisorEmail" runat="server" /></small></dd></div>
                            <div><dt><%: L.T("Coordinator.ConfiguredGroups.AcademicYearSemester") %></dt><dd><asp:Label ID="lblViewTerm" runat="server" /></dd></div>
                            <div><dt><%: L.T("Coordinator.ConfiguredGroups.Created") %></dt><dd><asp:Label ID="lblViewCreated" runat="server" /></dd></div>
                        </dl></section>
                    </div>
                    <h4 class="dir-form-title"><span data-ui-icon="people" aria-hidden="true"></span><%: L.T("Coordinator.ConfiguredGroups.Students") %></h4>
                    <div class="table-responsive">
                        <table class="dir-table dir-table-plain">
                            <thead><tr><th scope="col"><%: L.T("Coordinator.ConfiguredGroups.Name") %></th><th scope="col"><%: L.T("Coordinator.ConfiguredGroups.StudentID") %></th><th scope="col"><%: L.T("Coordinator.ConfiguredGroups.Major") %></th><th scope="col"><%: L.T("Coordinator.ConfiguredGroups.Internship") %></th><th scope="col"><%: L.T("Coordinator.ConfiguredGroups.ApprovedHours") %></th><th scope="col"><%: L.T("Coordinator.ConfiguredGroups.Account") %></th><th scope="col" class="dir-actions-col"><span class="visually-hidden"><%: L.T("Coordinator.ConfiguredGroups.Actions") %></span></th></tr></thead>
                            <tbody><asp:Repeater ID="rptViewStudents" runat="server"><ItemTemplate><tr>
                                <td><div class="dir-person"><span class="dir-avatar" aria-hidden="true"><%#: InternshipManagementSystem.Pages.CoordinatorArea.StudentDirectoryRow.MakeInitials((string)Eval("Name")) %></span><div><strong><%#: Eval("Name") %></strong><small><%#: Eval("Email") %></small></div></div></td>
                                <td><span class="dir-id"><%#: Eval("StudentNumber") %></span></td>
                                <td><%#: Eval("Major") %></td>
                                <td><%#: Eval("Internship") %></td>
                                <td class="dir-num"><%#: Eval("Hours") %></td>
                                <td><span class='<%# (bool)Eval("IsActive") ? "dir-status is-active" : "dir-status is-inactive" %>'><%#: (bool)Eval("IsActive") ? L.T("Coordinator.ManageStudents.StatusActive") : L.T("Coordinator.ManageStudents.StatusInactive") %></span></td>
                                <td><div class="dir-actions"><a class="dir-btn dir-btn-primary" href="<%#: ResolveUrl("~/Pages/Coordinator/Students.aspx?id=" + Uri.EscapeDataString((string)Eval("Id"))) %>"><span data-ui-icon="person" aria-hidden="true"></span> <%# L.T("Coordinator.ManageStudents.ViewProfile") %></a></div></td>
                            </tr></ItemTemplate></asp:Repeater></tbody>
                        </table>
                    </div>
                    <asp:Label ID="lblViewNoStudents" runat="server" CssClass="dir-empty" Visible="false" Text="<%$ Resources:Coordinator, ConfiguredGroups.NoStudentsAreAssignedToThis %>" />
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
