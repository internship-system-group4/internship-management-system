<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="AcademicSupervisors.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.AcademicSupervisors" Title="Academic Supervisors" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"><link rel="stylesheet" href="<%= ResolveUrl("~/Assets/css/students.css?v=20261022-tabs-2") %>" /></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="students-page">
        <div class="students-intro"><div><span class="students-eyebrow">Coordinator / Academic supervisors</span><h2>Academic supervisors</h2><p>Review records, create accounts, and manage supervisor information.</p></div></div>
        <asp:HiddenField ID="hdnActiveTab" runat="server" Value="records" />
        <div class="students-tabs" role="tablist" aria-label="Supervisor sections">
            <button type="button" id="supervisor-records-tab" role="tab" data-tab="records" aria-controls="supervisor-records">View records</button>
            <button type="button" id="supervisor-add-tab" role="tab" data-tab="add" aria-controls="supervisor-add">Add supervisor</button>
            <button type="button" id="supervisor-manage-tab" role="tab" data-tab="manage" aria-controls="supervisor-manage">Manage supervisors</button>
        </div>

        <section id="supervisor-records" class="supervisor-tab-panel" role="tabpanel" aria-labelledby="supervisor-records-tab">
            <div class="students-card">
                <div class="students-card-heading"><div><h3>Supervisor records</h3><p>Search and view account and assignment information.</p></div></div>
                <asp:Label ID="lblListMessage" runat="server" Visible="false" role="alert" />
                <div class="students-search">
                    <label for="<%= txtSearch.ClientID %>" class="visually-hidden">Search supervisor records</label>
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" MaxLength="120" placeholder="Search name, email, department, or rank" />
                    <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-primary" OnClick="btnSearch_Click" CausesValidation="false" />
                    <asp:Button ID="btnClearSearch" runat="server" Text="Clear" CssClass="btn btn-outline-secondary" OnClick="btnClearSearch_Click" CausesValidation="false" />
                </div>
                <div class="table-responsive"><table class="table students-table align-middle">
                    <thead><tr><th scope="col">Supervisor</th><th scope="col">Department</th><th scope="col">Academic rank</th><th scope="col">Status</th><th scope="col">Actions</th></tr></thead>
                    <tbody><asp:Repeater ID="rptSupervisors" runat="server"><ItemTemplate><tr>
                        <td><strong><%#: Eval("FullName") %></strong><small><%#: Eval("Email") %></small></td>
                        <td><%#: Eval("Department") %></td><td><%#: Eval("AcademicRank") %></td>
                        <td><span class='<%# (bool)Eval("IsActive") ? "students-status is-active" : "students-status is-inactive" %>'><%# (bool)Eval("IsActive") ? "Active" : "Inactive" %></span></td>
                        <td class="text-nowrap"><asp:LinkButton ID="btnView" runat="server" Text="View" CssClass="btn btn-sm btn-outline-primary me-1" CommandArgument='<%# Eval("Id") %>' OnClick="btnView_Click" CausesValidation="false" /><asp:LinkButton ID="btnEdit" runat="server" Text="Manage" CssClass="btn btn-sm btn-outline-secondary" CommandArgument='<%# Eval("Id") %>' OnClick="btnEdit_Click" CausesValidation="false" /></td>
                    </tr></ItemTemplate></asp:Repeater></tbody>
                </table></div>
                <asp:Label ID="lblNoSupervisors" runat="server" Visible="false" CssClass="students-empty" />
            </div>
            <asp:Panel ID="pnlRecord" runat="server" Visible="false" CssClass="students-card students-detail">
                <div class="students-card-heading"><div><span class="students-eyebrow">Selected record</span><h3><asp:Label ID="lblRecordName" runat="server" /></h3></div></div>
                <dl class="students-facts">
                    <div><dt>Login email</dt><dd><asp:Label ID="lblRecordEmail" runat="server" /></dd></div>
                    <div><dt>Phone</dt><dd><asp:Label ID="lblRecordPhone" runat="server" /></dd></div>
                    <div><dt>Department</dt><dd><asp:Label ID="lblRecordDepartment" runat="server" /></dd></div>
                    <div><dt>Academic rank</dt><dd><asp:Label ID="lblRecordRank" runat="server" /></dd></div>
                    <div><dt>Assigned groups</dt><dd><asp:Label ID="lblRecordGroups" runat="server" /></dd></div>
                    <div><dt>Account status</dt><dd><asp:Label ID="lblRecordStatus" runat="server" /></dd></div>
                </dl>
            </asp:Panel>
        </section>

        <section id="supervisor-add" class="supervisor-tab-panel" role="tabpanel" aria-labelledby="supervisor-add-tab" hidden>
            <div class="students-card">
                <div class="students-card-heading"><div><h3>Create supervisor account</h3><p>Share the login email and temporary password privately. The supervisor changes the password on first sign-in.</p></div></div>
                <asp:Label ID="lblCreateMessage" runat="server" Visible="false" role="alert" />
                <div class="row g-3">
                    <div class="col-md-6"><label for="<%= txtFullName.ClientID %>" class="form-label">Full name <span class="text-danger">*</span></label><asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" MaxLength="120" /></div>
                    <div class="col-md-6"><label for="<%= txtEmail.ClientID %>" class="form-label">Login email <span class="text-danger">*</span></label><asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" MaxLength="254" /></div>
                    <div class="col-md-6"><label for="<%= txtPhone.ClientID %>" class="form-label">Phone <span class="text-muted">(optional)</span></label><asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" TextMode="Phone" MaxLength="40" /></div>
                    <div class="col-md-6"><label for="<%= txtDepartment.ClientID %>" class="form-label">Department <span class="text-danger">*</span></label><asp:TextBox ID="txtDepartment" runat="server" CssClass="form-control" MaxLength="120" /></div>
                    <div class="col-md-6"><label for="<%= txtAcademicRank.ClientID %>" class="form-label">Academic rank <span class="text-muted">(optional)</span></label><asp:TextBox ID="txtAcademicRank" runat="server" CssClass="form-control" MaxLength="80" /></div>
                    <div class="col-md-6"><label for="<%= txtPassword.ClientID %>" class="form-label">Temporary password <span class="text-danger">*</span></label><asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" MaxLength="128" /></div>
                    <div class="col-md-6"><label for="<%= txtConfirmPassword.ClientID %>" class="form-label">Confirm temporary password <span class="text-danger">*</span></label><asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-control" TextMode="Password" MaxLength="128" /></div>
                    <div class="col-12"><asp:Button ID="btnCreate" runat="server" Text="Create supervisor" CssClass="btn btn-primary" OnClick="btnCreate_Click"  data-ui-action="create" data-loading-label="Creating…"/></div>
                </div>
            </div>
        </section>

        <section id="supervisor-manage" class="supervisor-tab-panel" role="tabpanel" aria-labelledby="supervisor-manage-tab" hidden>
            <div class="students-card">
                <div class="students-card-heading"><div><h3>Manage supervisors</h3><p>Choose an account to update its details or change access.</p></div></div>
                <asp:Label ID="lblManageMessage" runat="server" Visible="false" role="alert" />
                <div class="students-search">
                    <label for="<%= txtManageSearch.ClientID %>" class="visually-hidden">Search supervisors to manage</label>
                    <asp:TextBox ID="txtManageSearch" runat="server" CssClass="form-control" MaxLength="120" placeholder="Search supervisors" />
                    <asp:Button ID="btnManageSearch" runat="server" Text="Search" CssClass="btn btn-primary" OnClick="btnManageSearch_Click" CausesValidation="false" />
                    <asp:Button ID="btnClearManageSearch" runat="server" Text="Clear" CssClass="btn btn-outline-secondary" OnClick="btnClearManageSearch_Click" CausesValidation="false" />
                </div>
                <div class="table-responsive"><table class="table students-table align-middle">
                    <thead><tr><th scope="col">Supervisor</th><th scope="col">Department</th><th scope="col">Academic rank</th><th scope="col">Status</th><th scope="col">Action</th></tr></thead>
                    <tbody><asp:Repeater ID="rptManageSupervisors" runat="server"><ItemTemplate><tr>
                        <td><strong><%#: Eval("FullName") %></strong><small><%#: Eval("Email") %></small></td>
                        <td><%#: Eval("Department") %></td><td><%#: Eval("AcademicRank") %></td>
                        <td><span class='<%# (bool)Eval("IsActive") ? "students-status is-active" : "students-status is-inactive" %>'><%# (bool)Eval("IsActive") ? "Active" : "Inactive" %></span></td>
                        <td><asp:LinkButton ID="btnEdit" runat="server" Text="Manage" CssClass="btn btn-sm btn-outline-primary" CommandArgument='<%# Eval("Id") %>' OnClick="btnEdit_Click" CausesValidation="false" /></td>
                    </tr></ItemTemplate></asp:Repeater></tbody>
                </table></div>
                <asp:Label ID="lblNoManageSupervisors" runat="server" Visible="false" CssClass="students-empty" />
            </div>
        </section>

        <asp:Panel ID="pnlDetails" runat="server" Visible="false" CssClass="modal fade" ClientIDMode="Static" tabindex="-1" aria-labelledby="supervisorModalTitle" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable modal-lg"><div class="modal-content students-modal-content">
                <div class="modal-header"><div><span class="students-eyebrow">Manage supervisor</span><h3 class="modal-title h5 mb-0" id="supervisorModalTitle"><asp:Label ID="lblDetailsName" runat="server" /></h3><p class="text-muted mb-0"><asp:Label ID="lblDetailsEmail" runat="server" /></p></div><button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button></div>
                <div class="modal-body">
                    <asp:Label ID="lblDetailsMessage" runat="server" Visible="false" role="alert" />
                    <p class="text-muted">Assigned groups: <strong><asp:Label ID="lblGroupCount" runat="server" /></strong></p>
                    <div class="row g-3">
                        <div class="col-md-6"><label for="<%= txtEditFullName.ClientID %>" class="form-label">Full name</label><asp:TextBox ID="txtEditFullName" runat="server" CssClass="form-control" MaxLength="120" /></div>
                        <div class="col-md-6"><label for="<%= txtEditPhone.ClientID %>" class="form-label">Phone <span class="text-muted">(optional)</span></label><asp:TextBox ID="txtEditPhone" runat="server" CssClass="form-control" TextMode="Phone" MaxLength="40" /></div>
                        <div class="col-md-6"><label for="<%= txtEditDepartment.ClientID %>" class="form-label">Department</label><asp:TextBox ID="txtEditDepartment" runat="server" CssClass="form-control" MaxLength="120" /></div>
                        <div class="col-md-6"><label for="<%= txtEditAcademicRank.ClientID %>" class="form-label">Academic rank <span class="text-muted">(optional)</span></label><asp:TextBox ID="txtEditAcademicRank" runat="server" CssClass="form-control" MaxLength="80" /></div>
                    </div>
                    <div class="students-access"><div><h4>Account access</h4><p><asp:Label ID="lblAccessDescription" runat="server" /></p></div><asp:Button ID="btnToggleAccess" runat="server" CausesValidation="false" OnClick="btnToggleAccess_Click"  data-ui-action="update" data-loading-label="Updating…" data-ui-validation="none"/></div>
                </div>
                <div class="modal-footer"><button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Close</button><asp:Button ID="btnSaveDetails" runat="server" Text="Save changes" CssClass="btn btn-primary" OnClick="btnSaveDetails_Click"  data-ui-action="save" data-loading-label="Saving…"/></div>
            </div></div>
        </asp:Panel>
    </div>
</asp:Content>
<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server">
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var state = document.getElementById('<%= hdnActiveTab.ClientID %>');
            var tabs = document.querySelectorAll('.students-tabs button[data-tab]');
            function activate(name) {
                if (['records', 'add', 'manage'].indexOf(name) < 0) name = 'records';
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
