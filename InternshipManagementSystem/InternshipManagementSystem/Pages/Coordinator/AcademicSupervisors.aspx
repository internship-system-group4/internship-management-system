<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="AcademicSupervisors.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.AcademicSupervisors" Title="Academic Supervisors" %>
<%@ Import Namespace="InternshipManagementSystem.Pages.CoordinatorArea" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"><link rel="stylesheet" href="<%= ResolveUrl("~/Assets/css/students.css?v=20261024-theme-7") %>" /></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="students-page dir-page">
        <header class="dir-head">
            <div>
                <div class="dir-crumb"><%: L.T("Coordinator.AcademicSupervisors.CoordinatorAcademicSupervisors") %></div>
                <h2><%: L.T("Coordinator.AcademicSupervisors.AcademicSupervisors") %></h2>
                <p><%: L.T("Coordinator.AcademicSupervisors.DirectoryIntro") %></p>
            </div>
            <button type="button" class="btn btn-brand dir-add" data-bs-toggle="modal" data-bs-target="#addAcademicSupervisorModal"><span data-ui-icon="plus" aria-hidden="true"></span> <%: L.T("Coordinator.AcademicSupervisors.AddSupervisorShort") %></button>
        </header>
        <asp:Label ID="lblCreateSuccess" runat="server" Visible="false" EnableViewState="false" CssClass="alert alert-success d-block" role="status" />
        <asp:Label ID="lblListMessage" runat="server" Visible="false" EnableViewState="false" role="alert" />

        <section class="dir-card" aria-labelledby="dirHeading" data-dir>
            <div class="dir-toolbar">
                <div class="dir-title"><h3 id="dirHeading"><%: L.T("Coordinator.AcademicSupervisors.SupervisorDirectory") %> <span class="dir-count" data-dir-count><%: Rows.Count %></span></h3><p><%: L.T("Coordinator.AcademicSupervisors.DirectoryHelp") %></p></div>
                <div class="dir-filters">
                    <label class="dir-search"><span class="visually-hidden"><%: L.T("Coordinator.AcademicSupervisors.SearchSupervisorRecords") %></span><span data-ui-icon="search" aria-hidden="true"></span><input type="search" class="form-control" data-dir-search autocomplete="off" placeholder="<%: L.T("Coordinator.AcademicSupervisors.SearchNameEmailDepartmentOrRank") %>" /></label>
                    <label><span class="visually-hidden"><%: L.T("Coordinator.AcademicSupervisors.Status") %></span><select class="form-select" data-dir-filter="status">
                        <option value=""><%: L.T("Coordinator.ManageStudents.AllStatuses") %></option>
                        <option value="active"><%: L.T("Coordinator.ManageStudents.StatusActive") %></option>
                        <option value="inactive"><%: L.T("Coordinator.ManageStudents.StatusInactive") %></option>
                    </select></label>
                </div>
            </div>

            <div class="table-responsive">
                <table class="dir-table">
                    <thead><tr><th scope="col"><%: L.T("Coordinator.AcademicSupervisors.Supervisor") %></th><th scope="col"><%: L.T("Coordinator.AcademicSupervisors.Department") %></th><th scope="col"><%: L.T("Coordinator.AcademicSupervisors.Supervision") %></th><th scope="col"><%: L.T("Coordinator.AcademicSupervisors.Status") %></th><th scope="col" class="dir-actions-col"><%: L.T("Coordinator.AcademicSupervisors.Actions") %></th></tr></thead>
                    <tbody><asp:Repeater ID="rptSupervisors" runat="server"><ItemTemplate>
                        <tr data-dir-row data-search="<%#: ((SupervisorDirectoryRow)Container.DataItem).SearchText %>" data-status="<%# ((SupervisorDirectoryRow)Container.DataItem).IsActive ? "active" : "inactive" %>" style="--dir-i:<%# Container.ItemIndex %>">
                            <td><div class="dir-person"><span class="dir-avatar" aria-hidden="true"><%#: ((SupervisorDirectoryRow)Container.DataItem).Initials %></span><div><strong><%#: ((SupervisorDirectoryRow)Container.DataItem).FullName %></strong><small><%#: ((SupervisorDirectoryRow)Container.DataItem).Email %></small></div></div></td>
                            <td><%#: ((SupervisorDirectoryRow)Container.DataItem).Department %></td>
                            <td><div class="dir-tally"><span><b><%#: ((SupervisorDirectoryRow)Container.DataItem).GroupCount %></b> <%# L.T("Coordinator.AcademicSupervisors.AssignedGroups") %></span><span><b><%#: ((SupervisorDirectoryRow)Container.DataItem).StudentCount %></b> <%# L.T("Coordinator.AcademicSupervisors.Students") %></span></div></td>
                            <td><span class='<%# ((SupervisorDirectoryRow)Container.DataItem).IsActive ? "dir-status is-active" : "dir-status is-inactive" %>'><%#: ((SupervisorDirectoryRow)Container.DataItem).StatusText %></span></td>
                            <td><div class="dir-actions">
                                <button type="button" class="dir-btn" data-dir-view="<%# Container.ItemIndex %>" aria-haspopup="dialog"><span data-ui-icon="eye" aria-hidden="true"></span> <%# L.T("Coordinator.AcademicSupervisors.ViewDetails") %><span class="visually-hidden">: <%#: ((SupervisorDirectoryRow)Container.DataItem).FullName %></span></button>
                                <asp:LinkButton ID="btnEdit" runat="server" CssClass="dir-btn dir-btn-primary" CommandArgument='<%# ((SupervisorDirectoryRow)Container.DataItem).Id %>' OnClick="btnEdit_Click" CausesValidation="false"><span data-ui-icon="edit" aria-hidden="true"></span> <%# L.T("Coordinator.AcademicSupervisors.Manage") %></asp:LinkButton>
                                <button type="button" class="dir-btn dir-btn-danger" data-delete-supervisor="<%# Container.ItemIndex %>" aria-haspopup="dialog"><span data-ui-icon="trash" aria-hidden="true"></span> <%# L.T("Coordinator.AcademicSupervisors.Delete") %><span class="visually-hidden">: <%#: ((SupervisorDirectoryRow)Container.DataItem).FullName %></span></button>
                            </div></td>
                        </tr>
                    </ItemTemplate></asp:Repeater></tbody>
                </table>
            </div>
            <p class="dir-empty" data-dir-empty hidden><span data-ui-icon="search" aria-hidden="true"></span><%: L.T("Coordinator.AcademicSupervisors.NoSupervisorsMatchYourSearch") %></p>
            <asp:Label ID="lblNoSupervisors" runat="server" Visible="false" CssClass="dir-empty" />
            <script type="application/json" data-dir-data><%= RowsJson %></script>
        </section>

        <%-- View details (filled in the browser from the row data). --%>
        <div class="modal fade dir-modal" id="supervisorViewModal" tabindex="-1" aria-labelledby="supervisorViewTitle" aria-hidden="true" data-dir-view-modal>
            <div class="modal-dialog modal-dialog-centered modal-lg modal-dialog-scrollable"><div class="modal-content">
                <div class="modal-header dir-modal-hero">
                    <span class="dir-avatar dir-avatar-lg" data-field="Initials" aria-hidden="true"></span>
                    <div class="dir-hero-text"><span class="dir-eyebrow"><%: L.T("Coordinator.AcademicSupervisors.SupervisorDetails") %></span><h3 class="modal-title" id="supervisorViewTitle" data-field="FullName"></h3><p><span data-field="Email"></span> <span class="dir-status" data-field="StatusText" data-status-field="IsActive"></span></p></div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="<%: L.T("Coordinator.AcademicSupervisors.Close") %>"></button>
                </div>
                <div class="modal-body">
                    <div class="dir-info-grid">
                        <section><h4><span data-ui-icon="person" aria-hidden="true"></span><%: L.T("Coordinator.AcademicSupervisors.ContactInformation") %></h4><dl>
                            <div><dt><%: L.T("Coordinator.AcademicSupervisors.LoginEmail") %></dt><dd data-field="Email"></dd></div>
                            <div><dt><%: L.T("Coordinator.AcademicSupervisors.Phone") %></dt><dd data-field="Phone"></dd></div>
                            <div><dt><%: L.T("Coordinator.ManageStudents.CreatedOn") %></dt><dd data-field="CreatedText"></dd></div>
                        </dl></section>
                        <section><h4><span data-ui-icon="study" aria-hidden="true"></span><%: L.T("Coordinator.AcademicSupervisors.AcademicInformation") %></h4><dl>
                            <div><dt><%: L.T("Coordinator.AcademicSupervisors.Department") %></dt><dd data-field="Department"></dd></div>
                            <div><dt><%: L.T("Coordinator.AcademicSupervisors.AcademicRank") %></dt><dd data-field="AcademicRank"></dd></div>
                        </dl></section>
                        <section class="dir-info-wide"><h4><span data-ui-icon="people" aria-hidden="true"></span><%: L.T("Coordinator.AcademicSupervisors.Supervision") %></h4><dl class="dir-dl-3">
                            <div><dt><%: L.T("Coordinator.AcademicSupervisors.AssignedGroups") %></dt><dd><ul class="dir-chip-list" data-field-list="GroupNames"></ul><span data-field-list-empty><%: L.T("Coordinator.AcademicSupervisors.NoGroupsYet") %></span></dd></div>
                            <div><dt><%: L.T("Coordinator.AcademicSupervisors.Students") %></dt><dd data-field="StudentCount"></dd></div>
                            <div><dt><%: L.T("Coordinator.AcademicSupervisors.AccountStatus") %></dt><dd data-field="StatusText"></dd></div>
                        </dl></section>
                    </div>
                </div>
                <div class="modal-footer"><button type="button" class="btn btn-brand" data-bs-dismiss="modal"><%: L.T("Coordinator.AcademicSupervisors.Close") %></button></div>
            </div></div>
        </div>

        <%-- Delete confirmation. --%>
        <div class="modal fade dir-modal" id="deleteSupervisorModal" tabindex="-1" aria-labelledby="deleteSupervisorTitle" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered"><div class="modal-content">
                <div class="modal-body text-center p-4">
                    <div class="dir-delete-icon"><span data-ui-icon="trash" aria-hidden="true"></span></div>
                    <h3 class="h5 fw-bold mb-2" id="deleteSupervisorTitle"><%: L.T("Coordinator.AcademicSupervisors.DeleteSupervisorQuestion") %></h3>
                    <p class="fw-semibold mb-2" data-delete-name></p>
                    <p class="text-muted small mb-0" data-delete-ok><%: L.T("Coordinator.AcademicSupervisors.DeleteExplanation") %></p>
                    <p class="alert alert-warning small mb-0 mt-2 text-start" data-delete-blocked hidden><%: L.T("Coordinator.AcademicSupervisors.DeleteBlocked") %> <a href="<%= ResolveUrl("~/Pages/Coordinator/ConfiguredGroups.aspx") %>"><%: L.T("Coordinator.AcademicSupervisors.OpenGroups") %></a></p>
                </div>
                <div class="modal-footer justify-content-center">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal"><%: L.T("Coordinator.AcademicSupervisors.Cancel") %></button>
                    <asp:Button ID="btnConfirmDelete" runat="server" CssClass="btn btn-danger" Text="<%$ Resources:Coordinator, AcademicSupervisors.DeletePermanently %>" OnClick="btnConfirmDelete_Click" CausesValidation="false" data-ui-action="delete" data-loading-label="Deleting…" data-ui-validation="none" />
                </div>
            </div></div>
        </div>
        <asp:HiddenField ID="hfDeleteId" runat="server" />

        <div class="modal fade creation-modal" id="addAcademicSupervisorModal" data-bs-backdrop="static" tabindex="-1" aria-labelledby="addAcademicSupervisorTitle" aria-hidden="true" data-open-on-load="<%= ShowCreationModal ? "true" : "false" %>">
            <div class="modal-dialog modal-lg modal-dialog-scrollable">
                <asp:Panel ID="pnlCreateContent" runat="server" DefaultButton="btnCreate" CssClass="modal-content rounded-4 border-0 shadow-lg">
                    <div class="modal-header border-bottom-0 pb-0 pt-4 px-4">
                        <div><h5 id="addAcademicSupervisorTitle" class="fw-bold mb-1"><%: L.T("Coordinator.AcademicSupervisors.AddAcademicSupervisor") %></h5><p class="text-muted small mb-0"><%: L.T("Coordinator.AcademicSupervisors.CreateASupervisorAccountAndEnter") %></p></div>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="<%: L.T("Coordinator.AcademicSupervisors.Close") %>"></button>
                    </div>
                    <div class="modal-body p-4">
                        <asp:Label ID="lblCreateMessage" runat="server" Visible="false" EnableViewState="false" role="alert" />
                        <div class="row g-3">
                            <div class="col-md-6"><label for="<%= txtFullName.ClientID %>" class="form-label"><%: L.T("Coordinator.AcademicSupervisors.FullName") %> <span class="text-danger">*</span></label><asp:TextBox ID="txtFullName" runat="server" CssClass="form-control bg-light" MaxLength="120" /></div>
                            <div class="col-md-6"><label for="<%= txtEmail.ClientID %>" class="form-label"><%: L.T("Coordinator.AcademicSupervisors.LoginEmail") %> <span class="text-danger">*</span></label><asp:TextBox ID="txtEmail" runat="server" CssClass="form-control bg-light" TextMode="Email" MaxLength="254" /></div>
                            <div class="col-md-6"><label for="<%= txtPhone.ClientID %>" class="form-label"><%: L.T("Coordinator.AcademicSupervisors.Phone") %> <span class="text-muted"><%: L.T("Coordinator.AcademicSupervisors.Optional") %></span></label><asp:TextBox ID="txtPhone" runat="server" CssClass="form-control bg-light" TextMode="Phone" MaxLength="40" /></div>
                            <div class="col-md-6"><label for="<%= txtDepartment.ClientID %>" class="form-label"><%: L.T("Coordinator.AcademicSupervisors.Department") %> <span class="text-danger">*</span></label><asp:TextBox ID="txtDepartment" runat="server" CssClass="form-control bg-light" MaxLength="120" /></div>
                            <div class="col-md-6"><label for="<%= txtAcademicRank.ClientID %>" class="form-label"><%: L.T("Coordinator.AcademicSupervisors.AcademicRank") %> <span class="text-muted"><%: L.T("Coordinator.AcademicSupervisors.Optional") %></span></label><asp:TextBox ID="txtAcademicRank" runat="server" CssClass="form-control bg-light" MaxLength="80" /></div>
                            <div class="col-md-6"><label for="<%= txtPassword.ClientID %>" class="form-label"><%: L.T("Coordinator.AcademicSupervisors.TemporaryPassword") %> <span class="text-danger">*</span></label><asp:TextBox ID="txtPassword" runat="server" CssClass="form-control bg-light" TextMode="Password" MaxLength="128" /></div>
                            <div class="col-md-6"><label for="<%= txtConfirmPassword.ClientID %>" class="form-label"><%: L.T("Coordinator.AcademicSupervisors.ConfirmTemporaryPassword") %> <span class="text-danger">*</span></label><asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-control bg-light" TextMode="Password" MaxLength="128" /></div>
                        </div>
                        <p class="text-muted small mt-3 mb-0"><%: L.T("Coordinator.AcademicSupervisors.ShareTheLoginEmailAndTemporary") %></p>
                    </div>
                    <div class="modal-footer bg-light px-4 border-top-0">
                        <button type="button" class="btn btn-outline-secondary rounded-pill px-4" data-bs-dismiss="modal"><%: L.T("Coordinator.AcademicSupervisors.Cancel") %></button>
                        <asp:Button ID="btnCreate" runat="server" Text="<%$ Resources:Coordinator, AcademicSupervisors.CreateSupervisor %>" CssClass="btn btn-primary rounded-pill px-4" OnClick="btnCreate_Click" data-ui-action="create" data-loading-label="Creating…" />
                    </div>
                </asp:Panel>
            </div>
        </div>

        <%-- Manage: edit details and account access (server side). --%>
        <asp:Panel ID="pnlDetails" runat="server" Visible="false" CssClass="modal fade dir-modal" ClientIDMode="Static" tabindex="-1" aria-labelledby="supervisorModalTitle" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable modal-lg"><div class="modal-content">
                <div class="modal-header dir-modal-hero">
                    <span class="dir-avatar dir-avatar-lg" aria-hidden="true"><asp:Literal ID="litInitials" runat="server" /></span>
                    <div class="dir-hero-text"><span class="dir-eyebrow"><%: L.T("Coordinator.AcademicSupervisors.ManageSupervisor") %></span><h3 class="modal-title" id="supervisorModalTitle"><asp:Label ID="lblDetailsName" runat="server" /></h3><p><asp:Label ID="lblDetailsEmail" runat="server" /> · <%: L.T("Coordinator.AcademicSupervisors.AssignedGroups2") %> <strong><asp:Label ID="lblGroupCount" runat="server" /></strong></p></div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="<%: L.T("Coordinator.AcademicSupervisors.Close") %>"></button>
                </div>
                <div class="modal-body">
                    <asp:Label ID="lblDetailsMessage" runat="server" Visible="false" role="alert" />
                    <h4 class="dir-form-title"><span data-ui-icon="edit" aria-hidden="true"></span><%: L.T("Coordinator.AcademicSupervisors.SupervisorInformation") %></h4>
                    <div class="row g-3">
                        <div class="col-md-6"><label for="<%= txtEditFullName.ClientID %>" class="form-label"><%: L.T("Coordinator.AcademicSupervisors.FullName") %></label><asp:TextBox ID="txtEditFullName" runat="server" CssClass="form-control" MaxLength="120" /></div>
                        <div class="col-md-6"><label for="<%= txtEditPhone.ClientID %>" class="form-label"><%: L.T("Coordinator.AcademicSupervisors.Phone") %> <span class="text-muted"><%: L.T("Coordinator.AcademicSupervisors.Optional") %></span></label><asp:TextBox ID="txtEditPhone" runat="server" CssClass="form-control" TextMode="Phone" MaxLength="40" /></div>
                        <div class="col-md-6"><label for="<%= txtEditDepartment.ClientID %>" class="form-label"><%: L.T("Coordinator.AcademicSupervisors.Department") %></label><asp:TextBox ID="txtEditDepartment" runat="server" CssClass="form-control" MaxLength="120" /></div>
                        <div class="col-md-6"><label for="<%= txtEditAcademicRank.ClientID %>" class="form-label"><%: L.T("Coordinator.AcademicSupervisors.AcademicRank") %> <span class="text-muted"><%: L.T("Coordinator.AcademicSupervisors.Optional") %></span></label><asp:TextBox ID="txtEditAcademicRank" runat="server" CssClass="form-control" MaxLength="80" /></div>
                    </div>
                    <div class="dir-access"><div><h4><%: L.T("Coordinator.AcademicSupervisors.AccountAccess") %></h4><p><asp:Label ID="lblAccessDescription" runat="server" /></p></div><asp:Button ID="btnToggleAccess" runat="server" CausesValidation="false" OnClick="btnToggleAccess_Click" data-ui-action="update" data-loading-label="Updating…" data-ui-validation="none" /></div>
                </div>
                <div class="modal-footer"><button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal"><%: L.T("Coordinator.AcademicSupervisors.Close") %></button><asp:Button ID="btnSaveDetails" runat="server" Text="<%$ Resources:Coordinator, AcademicSupervisors.SaveChanges %>" CssClass="btn btn-brand" OnClick="btnSaveDetails_Click" data-ui-action="save" data-loading-label="Saving…" /></div>
            </div></div>
        </asp:Panel>
    </div>
</asp:Content>
<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server">
    <script src="<%= ResolveUrl("~/Assets/js/account-creation-modal.js") %>" defer></script>
    <script src="<%= ResolveUrl("~/Assets/js/directory.js?v=20261024-1") %>" defer></script>
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var modal = document.getElementById('pnlDetails');
            if (modal && window.bootstrap) new bootstrap.Modal(modal).show();

            // Delete: fill the confirmation with the chosen supervisor. Anyone
            // who still has groups or students must be reassigned first.
            var rows = [];
            try { rows = JSON.parse(document.querySelector('[data-dir-data]').textContent || '[]'); } catch (e) { }
            var dialog = document.getElementById('deleteSupervisorModal');
            var hidden = document.getElementById('<%= hfDeleteId.ClientID %>');
            var confirmButton = document.getElementById('<%= btnConfirmDelete.ClientID %>');
            document.addEventListener('click', function (event) {
                var button = event.target.closest('[data-delete-supervisor]');
                if (!button || !dialog) return;
                var row = rows[Number(button.dataset.deleteSupervisor)];
                if (!row) return;
                hidden.value = row.Id;
                dialog.querySelector('[data-delete-name]').textContent = row.FullName;
                dialog.querySelector('[data-delete-ok]').hidden = !row.CanDelete;
                dialog.querySelector('[data-delete-blocked]').hidden = row.CanDelete;
                confirmButton.disabled = !row.CanDelete;
                bootstrap.Modal.getOrCreateInstance(dialog).show();
            });
        });
    </script>
</asp:Content>
