<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="Companies.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.Companies" Title="Manage Companies" %>
<%@ Import Namespace="InternshipManagementSystem.Pages.CoordinatorArea" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <style>
        /* Company choice inside "Add supervisor" (existing company tab). */
        body.uims-portal .company-list-container { max-height:260px; overflow-y:auto; padding:6px; border:1px solid var(--ui-border); border-radius:14px; background:var(--ui-surface); }
        body.uims-portal .company-item { display:flex; justify-content:space-between; align-items:center; gap:12px; padding:10px 12px; border-radius:12px; cursor:pointer; transition:background-color .15s; }
        body.uims-portal .company-item:hover { background:var(--ui-neutral-soft); }
        body.uims-portal .company-item strong { display:block; color:var(--ui-ink); }
        body.uims-portal .company-item small { display:block; color:var(--ui-muted); }
        body.uims-portal #addSupervisorModal .nav-tabs .nav-link { color:var(--ui-muted); font-weight:650; border:0; border-bottom:3px solid transparent; background:transparent; }
        body.uims-portal #addSupervisorModal .nav-tabs .nav-link.active { color:var(--ui-primary-text,var(--ui-primary)); border-bottom-color:var(--ui-primary); }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="students-page dir-page">
        <header class="dir-head">
            <div>
                <div class="dir-crumb"><%: L.T("Coordinator.Companies.Crumb") %></div>
                <h2><%: L.T("Coordinator.Companies.ManageCompaniesSupervisors") %></h2>
                <p><%: L.T("Coordinator.Companies.DirectoryIntro") %></p>
            </div>
            <button type="button" class="btn btn-brand dir-add" data-bs-toggle="modal" data-bs-target="#addSupervisorModal" onclick="resetFormState()"><span data-ui-icon="plus" aria-hidden="true"></span> <%: L.T("Coordinator.Companies.AddSupervisor") %></button>
        </header>

        <section class="dir-card" aria-labelledby="dirHeading" data-dir>
            <div class="dir-toolbar">
                <div class="dir-title"><h3 id="dirHeading"><%: L.T("Coordinator.Companies.ExistingCompanySupervisors") %> <span class="dir-count" data-dir-count><%: gvSupervisors.Rows.Count %></span></h3><p><%: L.T("Coordinator.Companies.DirectoryHelp") %></p></div>
                <div class="dir-filters">
                    <label class="dir-search"><span class="visually-hidden"><%: L.T("Coordinator.Companies.SearchPlaceholder") %></span><span data-ui-icon="search" aria-hidden="true"></span><input type="search" class="form-control" data-dir-search autocomplete="off" placeholder="<%: L.T("Coordinator.Companies.SearchPlaceholder") %>" /></label>
                    <label><span class="visually-hidden"><%: L.T("Coordinator.Companies.Status") %></span><select class="form-select" data-dir-filter="status">
                        <option value=""><%: L.T("Coordinator.ManageStudents.AllStatuses") %></option>
                        <option value="active"><%: L.T("Coordinator.ManageStudents.StatusActive") %></option>
                        <option value="inactive"><%: L.T("Coordinator.ManageStudents.StatusInactive") %></option>
                    </select></label>
                </div>
            </div>

            <div class="table-responsive">
                <asp:GridView ID="gvSupervisors" runat="server" CssClass="dir-table" AutoGenerateColumns="False" OnRowCommand="gvSupervisors_RowCommand" DataKeyNames="Id" GridLines="None" CellSpacing="-1" EmptyDataText="<%$ Resources:Coordinator, Companies.NoSupervisorsYet %>">
                    <Columns>
                        <asp:TemplateField HeaderText="<%$ Resources:Coordinator, Companies.Supervisor %>">
                            <ItemTemplate>
                                <div class="dir-person"><span class="dir-avatar" aria-hidden="true"><%#: StudentDirectoryRow.MakeInitials((string)Eval("FullName")) %></span><div><strong><%#: Eval("FullName") %></strong><small><%#: Eval("Email") %></small></div></div>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="<%$ Resources:Coordinator, Companies.CompanyRole %>">
                            <ItemTemplate>
                                <strong><%#: Eval("CompanyName") %></strong><small><%#: Eval("JobTitle") %></small>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="<%$ Resources:Coordinator, Companies.Status %>">
                            <ItemTemplate>
                                <span class='<%# (bool)Eval("IsActive") ? "dir-status is-active" : "dir-status is-inactive" %>' data-row-status='<%# (bool)Eval("IsActive") ? "active" : "inactive" %>'><%#: (bool)Eval("IsActive") ? L.T("Coordinator.ManageStudents.StatusActive") : L.T("Coordinator.ManageStudents.StatusInactive") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="<%$ Resources:Coordinator, Companies.Actions %>" HeaderStyle-CssClass="dir-actions-col">
                            <ItemTemplate>
                                <div class="dir-actions">
                                    <asp:LinkButton ID="btnView" runat="server" CommandName="ViewDetails" CommandArgument='<%# Eval("Id") %>' CssClass="dir-btn" CausesValidation="false"><span data-ui-icon="eye" aria-hidden="true"></span> <%# L.T("Coordinator.AcademicSupervisors.ViewDetails") %></asp:LinkButton>
                                    <a class="dir-btn dir-btn-primary" href="<%#: ResolveUrl("~/Pages/Coordinator/SupervisorProfile.aspx?id=" + Uri.EscapeDataString((string)Eval("Id"))) %>"><span data-ui-icon="person" aria-hidden="true"></span> <%# L.T("Coordinator.ManageStudents.ViewProfile") %></a>
                                    <button type="button" class='<%# (bool)Eval("IsActive") ? "dir-btn dir-toggle is-on" : "dir-btn dir-toggle" %>' role="switch" aria-checked='<%# (bool)Eval("IsActive") ? "true" : "false" %>'
                                        title='<%#: (bool)Eval("IsActive") ? L.T("Coordinator.Toggle.ClickToDeactivate") : L.T("Coordinator.Toggle.ClickToActivate") %>'
                                        data-status-toggle="confirmToggleModal" data-id='<%#: Eval("Id") %>' data-name='<%#: Eval("FullName") %>' data-active='<%# (bool)Eval("IsActive") ? "true" : "false" %>'><span class="dir-switch" aria-hidden="true"></span><%#: (bool)Eval("IsActive") ? L.T("Coordinator.ManageStudents.StatusActive") : L.T("Coordinator.ManageStudents.StatusInactive") %><span class="visually-hidden">: <%#: Eval("FullName") %></span></button>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
                <script>
                    // Give each supervisor row the data the shared search and status filter read (Assets/js/directory.js).
                    (function () {
                        var table = document.getElementById('<%= gvSupervisors.ClientID %>');
                        if (!table) return;
                        Array.prototype.forEach.call(table.querySelectorAll('tbody tr'), function (row, i) {
                            var status = row.querySelector('[data-row-status]');
                            if (!status) return;
                            row.setAttribute('data-dir-row', '');
                            row.setAttribute('data-search', row.textContent.replace(/\s+/g, ' ').trim().toLowerCase());
                            row.setAttribute('data-status', status.getAttribute('data-row-status'));
                            row.style.setProperty('--dir-i', i);
                        });
                    }());
                </script>
            </div>
            <p class="dir-empty" data-dir-empty hidden><span data-ui-icon="search" aria-hidden="true"></span><%: L.T("Coordinator.Companies.NoMatch") %></p>
        </section>
    </div>

    <asp:HiddenField ID="hfToggleSupervisorId" runat="server" />

    <%-- Add a company supervisor (new or existing company). --%>
    <div class="modal fade creation-modal dir-modal" id="addSupervisorModal" data-bs-backdrop="static" tabindex="-1" aria-labelledby="addSupervisorTitle" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header dir-modal-hero">
                    <span class="dir-avatar dir-avatar-lg" aria-hidden="true"><span data-ui-icon="building"></span></span>
                    <div class="dir-hero-text"><span class="dir-eyebrow"><%: L.T("Coordinator.Companies.Crumb") %></span><h3 class="modal-title" id="addSupervisorTitle"><%: L.T("Coordinator.Companies.AddCompanySupervisor") %></h3><p><%: L.T("Coordinator.Companies.CreateASupervisorAccountAndLink") %></p></div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" onclick="resetFormState()" aria-label="<%: L.T("Coordinator.Companies.Close") %>"></button>
                </div>

                <div class="modal-body">
                    <asp:HiddenField ID="hfCompanyMode" runat="server" Value="New" />
                    <asp:HiddenField ID="hfExistingCompId" runat="server" />
                    <asp:HiddenField ID="hfExistingCompName" runat="server" />

                    <div class="creation-section">
                        <h4 class="dir-form-title"><span data-ui-icon="building" aria-hidden="true"></span><%: L.T("Coordinator.Companies.CompanyInformation") %></h4>
                        <ul class="nav nav-tabs mb-3">
                            <li class="nav-item"><button class="nav-link active" id="tab-new" data-bs-toggle="tab" data-bs-target="#newCompany" type="button" onclick="setMode('New')"><%: L.T("Coordinator.Companies.NewCompany") %></button></li>
                            <li class="nav-item"><button class="nav-link" id="tab-existing" data-bs-toggle="tab" data-bs-target="#existingCompany" type="button" onclick="setMode('Existing')"><%: L.T("Coordinator.Companies.ExistingCompany") %></button></li>
                        </ul>

                        <div class="tab-content">
                            <div class="tab-pane fade show active" id="newCompany">
                                <div class="row g-3">
                                    <div class="col-md-6"><label class="form-label" for="<%= txtCompanyName.ClientID %>"><%: L.T("Coordinator.Companies.CompanyName") %></label><asp:TextBox ID="txtCompanyName" runat="server" CssClass="form-control" placeholder="<%$ Resources:Coordinator, Companies.EGTechSolutions %>"></asp:TextBox></div>
                                    <div class="col-md-6"><label class="form-label" for="<%= txtIndustry.ClientID %>"><%: L.T("Coordinator.Companies.Industry") %></label><asp:TextBox ID="txtIndustry" runat="server" CssClass="form-control" placeholder="<%$ Resources:Coordinator, Companies.EGSoftwareDevelopment %>"></asp:TextBox></div>
                                    <div class="col-md-6"><label class="form-label" for="<%= txtCity.ClientID %>"><%: L.T("Coordinator.Companies.City") %></label><asp:TextBox ID="txtCity" runat="server" CssClass="form-control" placeholder="<%$ Resources:Coordinator, Companies.EGAmman %>"></asp:TextBox></div>
                                    <div class="col-md-6"><label class="form-label" for="<%= txtWebsite.ClientID %>"><%: L.T("Coordinator.Companies.Website") %></label><asp:TextBox ID="txtWebsite" runat="server" CssClass="form-control" placeholder="<%$ Resources:Coordinator, Companies.Https %>"></asp:TextBox></div>
                                    <div class="col-md-6"><label class="form-label" for="<%= txtCompanyEmail.ClientID %>"><%: L.T("Coordinator.Companies.CompanyEmail") %></label><asp:TextBox ID="txtCompanyEmail" runat="server" CssClass="form-control" TextMode="Email" placeholder="info@company.com"></asp:TextBox></div>
                                    <div class="col-md-6"><label class="form-label" for="<%= txtCompanyPhone.ClientID %>"><%: L.T("Coordinator.Companies.CompanyPhone") %></label><asp:TextBox ID="txtCompanyPhone" runat="server" CssClass="form-control" placeholder="+962..."></asp:TextBox></div>
                                    <div class="col-12"><label class="form-label" for="<%= txtAddress.ClientID %>"><%: L.T("Coordinator.Companies.FullAddress") %></label><asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" placeholder="<%$ Resources:Coordinator, Companies.BuildingStreet %>"></asp:TextBox></div>
                                </div>
                            </div>

                            <div class="tab-pane fade" id="existingCompany">
                                <div class="alert alert-success d-none d-flex justify-content-between align-items-center mb-3" id="selectedCompanyAlert">
                                    <span><%: L.T("Coordinator.Companies.Selected") %> <strong id="lblSelectedCompanyNameDisplay"></strong></span>
                                    <button type="button" class="dir-btn" onclick="clearExistingSelection()"><%: L.T("Coordinator.Companies.Change") %></button>
                                </div>
                                <div id="existingCompanyListArea">
                                    <div class="company-list-container">
                                        <asp:Repeater ID="rptExistingCompanies" runat="server">
                                            <ItemTemplate>
                                                <div class="company-item" onclick="selectCompany('<%# Eval("Id") %>', '<%# HttpUtility.JavaScriptStringEncode(Convert.ToString(Eval("Name"))) %>')">
                                                    <div><strong><%#: Eval("Name") %></strong><small><%#: Eval("Industry") %> &bull; <%#: Eval("Address") %></small></div>
                                                    <span class="dir-btn"><%: L.T("Coordinator.Companies.Select") %></span>
                                                </div>
                                            </ItemTemplate>
                                        </asp:Repeater>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="creation-section">
                        <h4 class="dir-form-title"><span data-ui-icon="person" aria-hidden="true"></span><%: L.T("Coordinator.Companies.SupervisorDetails") %></h4>
                        <div class="row g-3">
                            <div class="col-md-6"><label class="form-label" for="<%= txtSupervisorName.ClientID %>"><%: L.T("Coordinator.Companies.FullName") %></label><asp:TextBox ID="txtSupervisorName" runat="server" CssClass="form-control" placeholder="<%$ Resources:Coordinator, Companies.EGAhmadKhaled %>"></asp:TextBox></div>
                            <div class="col-md-6"><label class="form-label" for="<%= txtJobTitle.ClientID %>"><%: L.T("Coordinator.Companies.JobTitle") %></label><asp:TextBox ID="txtJobTitle" runat="server" CssClass="form-control" placeholder="<%$ Resources:Coordinator, Companies.EGHRManager %>"></asp:TextBox></div>
                            <div class="col-md-6"><label class="form-label" for="<%= txtSupervisorEmail.ClientID %>"><%: L.T("Coordinator.Companies.EmailAddress") %></label><asp:TextBox ID="txtSupervisorEmail" runat="server" CssClass="form-control" TextMode="Email" placeholder="name@company.com"></asp:TextBox></div>
                            <div class="col-md-6"><label class="form-label" for="<%= txtSupervisorPhone.ClientID %>"><%: L.T("Coordinator.Companies.PhoneNumber") %> <span class="text-danger">*</span></label><asp:TextBox ID="txtSupervisorPhone" runat="server" CssClass="form-control" TextMode="Phone" MaxLength="10" inputmode="numeric" pattern="[0-9]{10}" title="<%$ Resources:Coordinator, Phone.Hint %>" placeholder="07XXXXXXXX" aria-describedby="supPhoneHint"></asp:TextBox><span id="supPhoneHint" class="dir-field-hint"><%: L.T("Coordinator.Phone.Hint") %></span></div>
                        </div>
                    </div>

                    <div class="creation-section">
                        <h4 class="dir-form-title"><span data-ui-icon="person" aria-hidden="true"></span><%: L.T("Coordinator.Companies.AccountAccess") %></h4>
                        <div class="row g-3">
                            <div class="col-md-6"><label class="form-label" for="<%= txtTempPassword.ClientID %>"><%: L.T("Coordinator.Companies.TemporaryPassword") %></label><asp:TextBox ID="txtTempPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="<%$ Resources:Coordinator, Companies.Minimum6Characters %>"></asp:TextBox></div>
                            <div class="col-md-6"><label class="form-label" for="companyRole"><%: L.T("Coordinator.Companies.AccountRole") %></label><input id="companyRole" type="text" class="form-control" value="<%: L.T("Coordinator.Companies.CompanySupervisorRole") %>" readonly="readonly" /></div>
                        </div>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal" onclick="resetFormState()"><%: L.T("Coordinator.Companies.Cancel") %></button>
                    <asp:Button ID="btnSave" runat="server" Text="<%$ Resources:Coordinator, Companies.CreateAccount %>" CssClass="btn btn-brand" OnClientClick="return validateAndConfirm();" OnClick="btnSave_Click" CausesValidation="false" data-ui-action="create" data-loading-label="<%$ Resources:Shared, I18n.Creating %>" />
                </div>
            </div>
        </div>
    </div>

    <%-- View details (filled by the server after "View details"). --%>
    <div class="modal fade dir-modal" id="viewDetailsModal" tabindex="-1" aria-labelledby="viewSupervisorTitle" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg modal-dialog-scrollable"><div class="modal-content">
            <div class="modal-header dir-modal-hero">
                <span class="dir-avatar dir-avatar-lg" aria-hidden="true"><asp:Literal ID="litViewInitials" runat="server" /></span>
                <div class="dir-hero-text"><span class="dir-eyebrow"><%: L.T("Coordinator.Companies.SupervisorDetails2") %></span><h3 class="modal-title" id="viewSupervisorTitle"><asp:Literal ID="litViewSupName" runat="server" /></h3><p><asp:Literal ID="litViewEmailHero" runat="server" /></p></div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="<%: L.T("Coordinator.Companies.Close") %>"></button>
            </div>
            <div class="modal-body">
                <div class="dir-info-grid">
                    <section><h4><span data-ui-icon="person" aria-hidden="true"></span><%: L.T("Coordinator.Companies.PersonalInfo") %></h4><dl>
                        <div><dt><%: L.T("Coordinator.Companies.JobTitle2") %></dt><dd><asp:Literal ID="litViewJobTitle" runat="server" /></dd></div>
                        <div><dt><%: L.T("Coordinator.Companies.EmailAddress2") %></dt><dd><asp:Literal ID="litViewEmail" runat="server" /></dd></div>
                        <div><dt><%: L.T("Coordinator.Companies.PhoneNumber2") %></dt><dd><asp:Literal ID="litViewPhone" runat="server" /></dd></div>
                    </dl></section>
                    <section><h4><span data-ui-icon="building" aria-hidden="true"></span><%: L.T("Coordinator.Companies.CompanyInfo") %></h4><dl>
                        <div><dt><%: L.T("Coordinator.Companies.CompanyName2") %></dt><dd><asp:Literal ID="litViewCompName" runat="server" /></dd></div>
                        <div><dt><%: L.T("Coordinator.Companies.Industry2") %></dt><dd><asp:Literal ID="litViewIndustry" runat="server" /></dd></div>
                    </dl></section>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal"><%: L.T("Coordinator.Companies.Close") %></button>
                <asp:HyperLink ID="lnkViewProfile" runat="server" CssClass="btn btn-brand"><span data-ui-icon="person" aria-hidden="true"></span> <%: L.T("Coordinator.ManageStudents.ViewProfile") %></asp:HyperLink>
            </div>
        </div></div>
    </div>

    <%-- Confirm before changing a supervisor's access. --%>
    <%-- Confirm before changing a supervisor's access (filled by Assets/js/coordinator-pages.js). --%>
    <div class="modal fade dir-modal dir-confirm" id="confirmToggleModal" tabindex="-1" aria-labelledby="confirmToggleTitle" aria-hidden="true"
         data-hidden-id="<%= hfToggleSupervisorId.ClientID %>"
         data-title-on="<%: L.T("Coordinator.Toggle.ActivateTitle") %>" data-title-off="<%: L.T("Coordinator.Toggle.DeactivateTitle") %>"
         data-text-on="<%: L.T("Coordinator.Toggle.ActivateText") %>" data-text-off="<%: L.T("Coordinator.Toggle.DeactivateText") %>"
         data-btn-on="<%: L.T("Coordinator.Toggle.ActivateButton") %>" data-btn-off="<%: L.T("Coordinator.Toggle.DeactivateButton") %>">
        <div class="modal-dialog modal-dialog-centered"><div class="modal-content">
            <div class="modal-body dir-confirm-body">
                <div class="dir-result-icon is-danger" data-confirm-icon><span data-ui-icon="people" aria-hidden="true"></span></div>
                <h3 id="confirmToggleTitle" data-confirm-title><%: L.T("Coordinator.Companies.ConfirmAction") %></h3>
                <p data-confirm-text><%: L.T("Coordinator.Companies.AreYouSureYouWantTo") %></p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal"><%: L.T("Coordinator.Companies.Cancel") %></button>
                <asp:Button ID="btnConfirmToggle" runat="server" Text="<%$ Resources:Coordinator, Companies.YesIMSure %>" CssClass="btn btn-danger" OnClick="btnConfirmToggle_Click" CausesValidation="false" formnovalidate="formnovalidate" data-confirm-go="true" />
            </div>
        </div></div>
    </div>

    <%-- Result of a server action. --%>
    <div class="modal fade dir-modal dir-confirm" id="serverMessageModal" tabindex="-1" aria-labelledby="serverMessageTitle" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered"><div class="modal-content">
            <div class="modal-body dir-confirm-body">
                <asp:Literal ID="litModalIcon" runat="server"></asp:Literal>
                <h3 id="serverMessageTitle"><asp:Literal ID="litModalTitle" runat="server"></asp:Literal></h3>
                <p><asp:Literal ID="litModalMessage" runat="server"></asp:Literal></p>
            </div>
            <div class="modal-footer justify-content-center"><button type="button" class="btn btn-brand" data-bs-dismiss="modal"><%: L.T("Coordinator.Companies.Okay") %></button></div>
        </div></div>
    </div>

    <%-- Defined inside the form: the server calls openSystemModal() from a startup script. --%>
    <script>
        function openSystemModal(modalId) {
            function show() {
                var el = document.getElementById(modalId);
                if (el && window.bootstrap) bootstrap.Modal.getOrCreateInstance(el).show();
            }
            // Bootstrap loads after the form, so a pop-up opened by the server waits for the page.
            if (window.bootstrap) setTimeout(show, 50); else window.addEventListener('load', show);
        }
        function hideSystemModal(modalId) {
            var el = document.getElementById(modalId);
            var m = el && window.bootstrap ? bootstrap.Modal.getInstance(el) : null;
            if (m) m.hide();
        }

        function setMode(mode) { document.getElementById('<%= hfCompanyMode.ClientID %>').value = mode; }

        function selectCompany(id, name) {
            document.getElementById('<%= hfExistingCompId.ClientID %>').value = id;
            document.getElementById('<%= hfExistingCompName.ClientID %>').value = name;
            document.getElementById('lblSelectedCompanyNameDisplay').innerText = name;
            document.getElementById('selectedCompanyAlert').classList.remove('d-none');
            document.getElementById('existingCompanyListArea').classList.add('d-none');
        }

        function clearExistingSelection() {
            document.getElementById('<%= hfExistingCompId.ClientID %>').value = '';
            document.getElementById('<%= hfExistingCompName.ClientID %>').value = '';
            document.getElementById('selectedCompanyAlert').classList.add('d-none');
            document.getElementById('existingCompanyListArea').classList.remove('d-none');
        }

        function validateAndConfirm() {
            var mode = document.getElementById('<%= hfCompanyMode.ClientID %>').value;
            var existingId = document.getElementById('<%= hfExistingCompId.ClientID %>').value;
            if (mode === 'Existing' && existingId === '') {
                alert(window.uimsT('SelectCompanyFirst'));
                return false;
            }
            return true;
        }

        function resetFormState() {
            clearExistingSelection(); setMode('New');
            document.getElementById('<%= txtCompanyName.ClientID %>').value = '';
            document.getElementById('<%= txtSupervisorName.ClientID %>').value = '';
            document.getElementById('<%= txtSupervisorEmail.ClientID %>').value = '';
            document.getElementById('<%= txtTempPassword.ClientID %>').value = '';
            if (window.bootstrap) new bootstrap.Tab(document.getElementById('tab-new')).show();
        }

    </script>
</asp:Content>

<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server">
    <script src="<%= ResolveUrl("~/Assets/js/directory.js?v=20261024-1") %>" defer></script>
</asp:Content>
