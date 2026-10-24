<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="AcademicSupervisors.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.AcademicSupervisors" Title="Academic Supervisors" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"><link rel="stylesheet" href="<%= ResolveUrl("~/Assets/css/students.css?v=20261022-creation-modal") %>" /></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="students-page">
        <div class="students-intro"><div><span class="students-eyebrow"><%: L.T("Coordinator.AcademicSupervisors.CoordinatorAcademicSupervisors") %></span><h2><%: L.T("Coordinator.AcademicSupervisors.AcademicSupervisors") %></h2><p><%: L.T("Coordinator.AcademicSupervisors.ReviewRecordsCreateAccountsAndManage") %></p></div><button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addAcademicSupervisorModal"><%: L.T("Coordinator.AcademicSupervisors.AddSupervisor") %></button></div>
        <asp:Label ID="lblCreateSuccess" runat="server" Visible="false" EnableViewState="false" CssClass="alert alert-success d-block" role="status" />
        <asp:HiddenField ID="hdnActiveTab" runat="server" Value="records" />
        <div class="students-tabs" role="tablist" aria-label="<%: L.T("Coordinator.AcademicSupervisors.SupervisorSections") %>">
            <button type="button" id="supervisor-records-tab" role="tab" data-tab="records" aria-controls="supervisor-records"><%: L.T("Coordinator.AcademicSupervisors.ViewRecords") %></button>
            <button type="button" id="supervisor-manage-tab" role="tab" data-tab="manage" aria-controls="supervisor-manage"><%: L.T("Coordinator.AcademicSupervisors.ManageSupervisors") %></button>
        </div>

        <section id="supervisor-records" class="supervisor-tab-panel" role="tabpanel" aria-labelledby="supervisor-records-tab">
            <div class="students-card">
                <div class="students-card-heading"><div><h3><%: L.T("Coordinator.AcademicSupervisors.SupervisorRecords") %></h3><p><%: L.T("Coordinator.AcademicSupervisors.SearchAndViewAccountAndAssignment") %></p></div></div>
                <asp:Label ID="lblListMessage" runat="server" Visible="false" role="alert" />
                <div class="students-search">
                    <label for="<%= txtSearch.ClientID %>" class="visually-hidden"><%: L.T("Coordinator.AcademicSupervisors.SearchSupervisorRecords") %></label>
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" MaxLength="120" placeholder="<%$ Resources:Coordinator, AcademicSupervisors.SearchNameEmailDepartmentOrRank %>" />
                    <asp:Button ID="btnSearch" runat="server" Text="<%$ Resources:Coordinator, AcademicSupervisors.Search %>" CssClass="btn btn-primary" OnClick="btnSearch_Click" CausesValidation="false" />
                    <asp:Button ID="btnClearSearch" runat="server" Text="<%$ Resources:Coordinator, AcademicSupervisors.Clear %>" CssClass="btn btn-outline-secondary" OnClick="btnClearSearch_Click" CausesValidation="false" />
                </div>
                <div class="table-responsive"><table class="table students-table align-middle">
                    <thead><tr><th scope="col"><%: L.T("Coordinator.AcademicSupervisors.Supervisor") %></th><th scope="col"><%: L.T("Coordinator.AcademicSupervisors.Department") %></th><th scope="col"><%: L.T("Coordinator.AcademicSupervisors.AcademicRank") %></th><th scope="col"><%: L.T("Coordinator.AcademicSupervisors.Status") %></th><th scope="col"><%: L.T("Coordinator.AcademicSupervisors.Actions") %></th></tr></thead>
                    <tbody><asp:Repeater ID="rptSupervisors" runat="server"><ItemTemplate><tr>
                        <td><strong><%#: Eval("FullName") %></strong><small><%#: Eval("Email") %></small></td>
                        <td><%#: Eval("Department") %></td><td><%#: Eval("AcademicRank") %></td>
                        <td><span class='<%# (bool)Eval("IsActive") ? "students-status is-active" : "students-status is-inactive" %>'><%# (bool)Eval("IsActive") ? "Active" : "Inactive" %></span></td>
                        <td class="text-nowrap"><asp:LinkButton ID="btnView" runat="server" Text="<%$ Resources:Coordinator, AcademicSupervisors.View %>" CssClass="btn btn-sm btn-outline-primary me-1" CommandArgument='<%# Eval("Id") %>' OnClick="btnView_Click" CausesValidation="false" /><asp:LinkButton ID="btnEdit" runat="server" Text="<%$ Resources:Coordinator, AcademicSupervisors.Manage %>" CssClass="btn btn-sm btn-outline-secondary" CommandArgument='<%# Eval("Id") %>' OnClick="btnEdit_Click" CausesValidation="false" /></td>
                    </tr></ItemTemplate></asp:Repeater></tbody>
                </table></div>
                <asp:Label ID="lblNoSupervisors" runat="server" Visible="false" CssClass="students-empty" />
            </div>
            <asp:Panel ID="pnlRecord" runat="server" Visible="false" CssClass="students-card students-detail">
                <div class="students-card-heading"><div><span class="students-eyebrow"><%: L.T("Coordinator.AcademicSupervisors.SelectedRecord") %></span><h3><asp:Label ID="lblRecordName" runat="server" /></h3></div></div>
                <dl class="students-facts">
                    <div><dt><%: L.T("Coordinator.AcademicSupervisors.LoginEmail") %></dt><dd><asp:Label ID="lblRecordEmail" runat="server" /></dd></div>
                    <div><dt><%: L.T("Coordinator.AcademicSupervisors.Phone") %></dt><dd><asp:Label ID="lblRecordPhone" runat="server" /></dd></div>
                    <div><dt><%: L.T("Coordinator.AcademicSupervisors.Department") %></dt><dd><asp:Label ID="lblRecordDepartment" runat="server" /></dd></div>
                    <div><dt><%: L.T("Coordinator.AcademicSupervisors.AcademicRank") %></dt><dd><asp:Label ID="lblRecordRank" runat="server" /></dd></div>
                    <div><dt><%: L.T("Coordinator.AcademicSupervisors.AssignedGroups") %></dt><dd><asp:Label ID="lblRecordGroups" runat="server" /></dd></div>
                    <div><dt><%: L.T("Coordinator.AcademicSupervisors.AccountStatus") %></dt><dd><asp:Label ID="lblRecordStatus" runat="server" /></dd></div>
                </dl>
            </asp:Panel>
        </section>

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
                        <asp:Button ID="btnCreate" runat="server" Text="<%$ Resources:Coordinator, AcademicSupervisors.CreateSupervisor %>" CssClass="btn btn-primary rounded-pill px-4" OnClick="btnCreate_Click" data-ui-action="create" data-loading-label="<%$ Resources:Shared, I18n.Creating %>" />
                    </div>
                </asp:Panel>
            </div>
        </div>

        <section id="supervisor-manage" class="supervisor-tab-panel" role="tabpanel" aria-labelledby="supervisor-manage-tab" hidden>
            <div class="students-card">
                <div class="students-card-heading"><div><h3><%: L.T("Coordinator.AcademicSupervisors.ManageSupervisors") %></h3><p><%: L.T("Coordinator.AcademicSupervisors.ChooseAnAccountToUpdateIts") %></p></div></div>
                <asp:Label ID="lblManageMessage" runat="server" Visible="false" role="alert" />
                <div class="students-search">
                    <label for="<%= txtManageSearch.ClientID %>" class="visually-hidden"><%: L.T("Coordinator.AcademicSupervisors.SearchSupervisorsToManage") %></label>
                    <asp:TextBox ID="txtManageSearch" runat="server" CssClass="form-control" MaxLength="120" placeholder="<%$ Resources:Coordinator, AcademicSupervisors.SearchSupervisors %>" />
                    <asp:Button ID="btnManageSearch" runat="server" Text="<%$ Resources:Coordinator, AcademicSupervisors.Search %>" CssClass="btn btn-primary" OnClick="btnManageSearch_Click" CausesValidation="false" />
                    <asp:Button ID="btnClearManageSearch" runat="server" Text="<%$ Resources:Coordinator, AcademicSupervisors.Clear %>" CssClass="btn btn-outline-secondary" OnClick="btnClearManageSearch_Click" CausesValidation="false" />
                </div>
                <div class="table-responsive"><table class="table students-table align-middle">
                    <thead><tr><th scope="col"><%: L.T("Coordinator.AcademicSupervisors.Supervisor") %></th><th scope="col"><%: L.T("Coordinator.AcademicSupervisors.Department") %></th><th scope="col"><%: L.T("Coordinator.AcademicSupervisors.AcademicRank") %></th><th scope="col"><%: L.T("Coordinator.AcademicSupervisors.Status") %></th><th scope="col"><%: L.T("Coordinator.AcademicSupervisors.Action") %></th></tr></thead>
                    <tbody><asp:Repeater ID="rptManageSupervisors" runat="server"><ItemTemplate><tr>
                        <td><strong><%#: Eval("FullName") %></strong><small><%#: Eval("Email") %></small></td>
                        <td><%#: Eval("Department") %></td><td><%#: Eval("AcademicRank") %></td>
                        <td><span class='<%# (bool)Eval("IsActive") ? "students-status is-active" : "students-status is-inactive" %>'><%# (bool)Eval("IsActive") ? "Active" : "Inactive" %></span></td>
                        <td><asp:LinkButton ID="btnEdit" runat="server" Text="<%$ Resources:Coordinator, AcademicSupervisors.Manage %>" CssClass="btn btn-sm btn-outline-primary" CommandArgument='<%# Eval("Id") %>' OnClick="btnEdit_Click" CausesValidation="false" /></td>
                    </tr></ItemTemplate></asp:Repeater></tbody>
                </table></div>
                <asp:Label ID="lblNoManageSupervisors" runat="server" Visible="false" CssClass="students-empty" />
            </div>
        </section>

        <asp:Panel ID="pnlDetails" runat="server" Visible="false" CssClass="modal fade" ClientIDMode="Static" tabindex="-1" aria-labelledby="supervisorModalTitle" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable modal-lg"><div class="modal-content students-modal-content">
                <div class="modal-header"><div><span class="students-eyebrow"><%: L.T("Coordinator.AcademicSupervisors.ManageSupervisor") %></span><h3 class="modal-title h5 mb-0" id="supervisorModalTitle"><asp:Label ID="lblDetailsName" runat="server" /></h3><p class="text-muted mb-0"><asp:Label ID="lblDetailsEmail" runat="server" /></p></div><button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="<%: L.T("Coordinator.AcademicSupervisors.Close") %>"></button></div>
                <div class="modal-body">
                    <asp:Label ID="lblDetailsMessage" runat="server" Visible="false" role="alert" />
                    <p class="text-muted"><%: L.T("Coordinator.AcademicSupervisors.AssignedGroups2") %> <strong><asp:Label ID="lblGroupCount" runat="server" /></strong></p>
                    <div class="row g-3">
                        <div class="col-md-6"><label for="<%= txtEditFullName.ClientID %>" class="form-label"><%: L.T("Coordinator.AcademicSupervisors.FullName") %></label><asp:TextBox ID="txtEditFullName" runat="server" CssClass="form-control" MaxLength="120" /></div>
                        <div class="col-md-6"><label for="<%= txtEditPhone.ClientID %>" class="form-label"><%: L.T("Coordinator.AcademicSupervisors.Phone") %> <span class="text-muted"><%: L.T("Coordinator.AcademicSupervisors.Optional") %></span></label><asp:TextBox ID="txtEditPhone" runat="server" CssClass="form-control" TextMode="Phone" MaxLength="40" /></div>
                        <div class="col-md-6"><label for="<%= txtEditDepartment.ClientID %>" class="form-label"><%: L.T("Coordinator.AcademicSupervisors.Department") %></label><asp:TextBox ID="txtEditDepartment" runat="server" CssClass="form-control" MaxLength="120" /></div>
                        <div class="col-md-6"><label for="<%= txtEditAcademicRank.ClientID %>" class="form-label"><%: L.T("Coordinator.AcademicSupervisors.AcademicRank") %> <span class="text-muted"><%: L.T("Coordinator.AcademicSupervisors.Optional") %></span></label><asp:TextBox ID="txtEditAcademicRank" runat="server" CssClass="form-control" MaxLength="80" /></div>
                    </div>
                    <div class="students-access"><div><h4><%: L.T("Coordinator.AcademicSupervisors.AccountAccess") %></h4><p><asp:Label ID="lblAccessDescription" runat="server" /></p></div><asp:Button ID="btnToggleAccess" runat="server" CausesValidation="false" OnClick="btnToggleAccess_Click" data-ui-action="update" data-loading-label="<%$ Resources:Shared, I18n.Updating %>" data-ui-validation="none" /></div>
                </div>
                <div class="modal-footer"><button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal"><%: L.T("Coordinator.AcademicSupervisors.Close") %></button><asp:Button ID="btnSaveDetails" runat="server" Text="<%$ Resources:Coordinator, AcademicSupervisors.SaveChanges %>" CssClass="btn btn-primary" OnClick="btnSaveDetails_Click" data-ui-action="save" data-loading-label="<%$ Resources:Shared, I18n.Saving %>" /></div>
            </div></div>
        </asp:Panel>
    </div>
</asp:Content>
<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server">
    <script src="<%= ResolveUrl("~/Assets/js/account-creation-modal.js") %>" defer></script>
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var state = document.getElementById('<%= hdnActiveTab.ClientID %>');
            var tabs = document.querySelectorAll('.students-tabs button[data-tab]');
            function activate(name) {
                if (['records', 'manage'].indexOf(name) < 0) name = 'records';
                tabs.forEach(function (tab) {
                    var active = tab.getAttribute('data-tab') === name;
                    tab.classList.toggle('active', active);
                    tab.setAttribute('aria-selected', active ? 'true' : 'false');
                    tab.tabIndex = active ? 0 : -1;
                    document.getElementById('supervisor-' + tab.getAttribute('data-tab')).hidden = !active;
                });
                state.value = name;
            }
            tabs.forEach(function (tab, index) {
                tab.addEventListener('click', function () { activate(tab.getAttribute('data-tab')); });
                tab.addEventListener('keydown', function (event) {
                    if (event.key !== 'ArrowRight' && event.key !== 'ArrowLeft') return;
                    event.preventDefault();
                    var next = tabs[(index + (event.key === 'ArrowRight' ? 1 : tabs.length - 1)) % tabs.length];
                    activate(next.getAttribute('data-tab'));
                    next.focus();
                });
            });
            activate(state.value);
            var modal = document.getElementById('pnlDetails');
            if (modal && window.bootstrap) new bootstrap.Modal(modal).show();
        });
    </script>
</asp:Content>
