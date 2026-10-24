<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="Companies.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.Companies" Title="Manage Companies" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <style>
        /* تثبيت زر تسجيل الخروج بأسفل الشاشة */
        .sidebar, aside { display: flex; flex-direction: column; height: 100vh; }
        .sidebar-menu { flex-grow: 1; overflow-y: auto; }
        .logout-container, .logout-box { margin-top: auto !important; border-top: 1px solid var(--th-line-e3e8ee,#e3e8ee); padding-top: 1rem; }

        /* الألوان والستايلات */
        .text-brand { color: var(--th-fg-0f4c81,#0f4c81) !important; }
        .bg-brand { background-color: var(--th-bg-0f4c81,#0f4c81) !important; color: white; border: none; transition: 0.2s; }
        .bg-brand:hover { background-color: var(--th-bg-0a365c,#0a365c) !important; color: white; transform: translateY(-1px); }
        .nav-tabs .nav-link { color: var(--ui-muted); font-weight: 500; border: none; background: transparent; }
        .nav-tabs .nav-link.active { color: var(--th-fg-0f4c81,#0f4c81); font-weight: bold; border-bottom: 2px solid var(--th-line-0f4c81,#0f4c81); }

        .company-list-container { max-height: 250px; overflow-y: auto; border: 1px solid var(--th-line-e3e8ee,#e3e8ee); border-radius: 8px; background: var(--ui-surface,#fff); padding: 0.5rem; }
        .company-item { padding: 1rem; border: 1px solid transparent; border-radius: 6px; cursor: pointer; transition: all 0.2s ease; margin-bottom: 0.25rem; display: flex; justify-content: space-between; align-items: center; }
        .company-item:hover { background-color: var(--th-bg-f8fafc,#f8fafc); border-color: var(--th-line-cce5ff,#cce5ff); transform: translateY(-1px); }

        .clean-table { width: 100%; border-collapse: collapse; }
        .clean-table th { padding: 1rem; border-bottom: 2px solid var(--th-line-e2e8f0,#e2e8f0); color: var(--ui-muted); font-size: 0.75rem; text-transform: uppercase; font-weight: 700; text-align: start; letter-spacing: 0.5px; }
        .clean-table td { padding: 1rem; border-bottom: 1px solid var(--th-line-f1f5f9,#f1f5f9); color: var(--th-fg-334155,#334155); font-size: 0.875rem; font-weight: 500; vertical-align: middle; }
        .clean-table tr:hover td { background-color: var(--th-bg-f8fafc,#f8fafc); }

        .btn-table-action { background-color: var(--th-bg-f1f5f9,#f1f5f9); color: var(--th-fg-0f4c81,#0f4c81); font-weight: 600; padding: 6px 16px; border-radius: 50px; border: 1px solid var(--th-line-e2e8f0,#e2e8f0); transition: 0.2s; text-decoration: none; display: inline-flex; align-items: center; justify-content: center; gap: 5px; }
        .btn-table-action:hover { background-color: var(--th-bg-0f4c81,#0f4c81); color: white; border-color: var(--th-line-0f4c81,#0f4c81); }

        /* ستايل نافذة الـ View - تم إضافة خاصية كسر الكلمات الطويلة هنا */
        .view-label { font-size: 0.75rem; color: var(--ui-muted); text-transform: uppercase; font-weight: 700; margin-bottom: 0.2rem; }
        .view-value { font-size: 1rem; color: var(--th-fg-1e293b,#1e293b); font-weight: 600; margin-bottom: 1.25rem; border-bottom: 1px dashed var(--th-line-e2e8f0,#e2e8f0); padding-bottom: 0.5rem; word-wrap: break-word; overflow-wrap: break-word; }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container-fluid px-4 py-4">

        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <div class="text-muted small mb-1"><%: L.T("Coordinator.Companies.CoordinatorWorkspace") %> <span class="text-dark fw-semibold"><%: L.T("Coordinator.Companies.ManageCompanies") %></span></div>
                <h2 class="fw-bold text-brand mb-0 fs-3"><%: L.T("Coordinator.Companies.ManageCompaniesSupervisors") %></h2>
            </div>
            <button type="button" class="btn bg-brand px-4 py-2 rounded-pill shadow-sm" data-bs-toggle="modal" data-bs-target="#addSupervisorModal" onclick="resetFormState()">
                <i class="bi bi-plus-lg me-2"></i><%: L.T("Coordinator.Companies.AddSupervisor") %>
            </button>
        </div>

        <!-- زر التحكم بالجدول (إخفاء / إظهار) -->
        <div class="card border-0 shadow-sm rounded-4 p-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h5 class="fw-bold text-brand mb-0"><%: L.T("Coordinator.Companies.ExistingCompanySupervisors") %></h5>
                <!-- زر طي الجدول (Collapse Button) -->
                <button type="button" class="btn btn-sm btn-light border rounded-pill px-3 fw-bold text-muted" data-bs-toggle="collapse" data-bs-target="#tableCollapse" aria-expanded="true" onclick="toggleTableVisibility(this)">
                    <i class="bi bi-eye-slash-fill me-1"></i><span class="toggle-text"><%: L.T("Coordinator.Companies.HideList") %></span>
                </button>
            </div>

            <!-- تغليف الجدول بالـ Collapse -->
            <div class="collapse show" id="tableCollapse">
                <div class="table-responsive">
                    <asp:GridView ID="gvSupervisors" runat="server" CssClass="clean-table" AutoGenerateColumns="False" OnRowCommand="gvSupervisors_RowCommand" DataKeyNames="Id" GridLines="None">
                        <Columns>
                            <asp:TemplateField HeaderText="<%$ Resources:Coordinator, Companies.Supervisor %>">
                                <ItemTemplate>
                                    <div class="d-flex align-items-center gap-3">
                                        <div class="bg-light text-brand fw-bold rounded-circle d-flex align-items-center justify-content-center border shadow-sm" style="width: 40px; height: 40px;">
                                            <i class="bi bi-person-fill"></i>
                                        </div>
                                        <div>
                                            <div class="text-dark fw-bold"><%# Eval("FullName") %></div>
                                            <div class="text-muted small fw-normal"><%# Eval("Email") %></div>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="<%$ Resources:Coordinator, Companies.CompanyRole %>">
                                <ItemTemplate>
                                    <div class="text-dark fw-bold"><%# Eval("CompanyName") %></div>
                                    <div class="text-muted small fw-normal"><%# Eval("JobTitle") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="<%$ Resources:Coordinator, Companies.Status %>">
                                <ItemTemplate>
                                    <span class='<%# (bool)Eval("IsActive") ? "badge bg-success bg-opacity-10 text-success px-3 py-2 rounded-pill fw-bold" : "badge bg-danger bg-opacity-10 text-danger px-3 py-2 rounded-pill fw-bold" %>'>
                                        <i class='<%# (bool)Eval("IsActive") ? "bi bi-check-circle-fill me-1" : "bi bi-x-circle-fill me-1" %>'></i>
                                        <%# (bool)Eval("IsActive") ? "Active" : "Inactive" %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="<%$ Resources:Coordinator, Companies.Actions %>">
                                <ItemTemplate>
                                    <div class="d-flex gap-2">
                                        <asp:LinkButton ID="btnView" runat="server" CommandName="ViewDetails" CommandArgument='<%# Eval("Id") %>' CssClass="btn-table-action" CausesValidation="false">
                                            <i class="bi bi-eye"></i> <%# L.T("Coordinator.Companies.ViewAction") %>
                                        </asp:LinkButton>

                                        <asp:LinkButton ID="btnToggle" runat="server" CssClass="btn-table-action" CausesValidation="false" OnClientClick='<%# "return openConfirmModal(\"" + Eval("Id") + "\");" %>'>
                                            <i class="bi bi-arrow-repeat"></i> <%# L.T("Coordinator.Companies.ToggleAction") %>
                                        </asp:LinkButton>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>

    <asp:HiddenField ID="hfToggleSupervisorId" runat="server" />

    <!-- 1. النافذة المنبثقة (Modal) لإضافة مشرف -->
    <div class="modal fade" id="addSupervisorModal" data-bs-backdrop="static" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-scrollable">
            <div class="modal-content rounded-4 border-0 shadow-lg">

                <div class="modal-header border-bottom-0 pb-0 pt-4 px-4">
                    <div>
                        <h5 class="fw-bold text-brand mb-1"><%: L.T("Coordinator.Companies.AddCompanySupervisor") %></h5>
                        <p class="text-muted small mb-0"><%: L.T("Coordinator.Companies.CreateASupervisorAccountAndLink") %></p>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" onclick="resetFormState()"></button>
                </div>

                <div class="modal-body p-4">
                    <asp:HiddenField ID="hfCompanyMode" runat="server" Value="New" />
                    <asp:HiddenField ID="hfExistingCompId" runat="server" />
                    <asp:HiddenField ID="hfExistingCompName" runat="server" />

                    <!-- قسم الشركة -->
                    <div class="mb-4">
                        <h6 class="fw-bold text-brand mb-3"><%: L.T("Coordinator.Companies.CompanyInformation") %></h6>
                        <ul class="nav nav-tabs mb-3">
                            <li class="nav-item"><button class="nav-link active" id="tab-new" data-bs-toggle="tab" data-bs-target="#newCompany" type="button" onclick="setMode('New')"><%: L.T("Coordinator.Companies.NewCompany") %></button></li>
                            <li class="nav-item"><button class="nav-link" id="tab-existing" data-bs-toggle="tab" data-bs-target="#existingCompany" type="button" onclick="setMode('Existing')"><%: L.T("Coordinator.Companies.ExistingCompany") %></button></li>
                        </ul>

                        <div class="tab-content">
                            <!-- شركة جديدة -->
                            <div class="tab-pane fade show active" id="newCompany">
                                <div class="row g-3">
                                    <div class="col-md-6"><label class="form-label fw-semibold small"><%: L.T("Coordinator.Companies.CompanyName") %></label><asp:TextBox ID="txtCompanyName" runat="server" CssClass="form-control bg-light" placeholder="<%$ Resources:Coordinator, Companies.EGTechSolutions %>"></asp:TextBox></div>
                                    <div class="col-md-6"><label class="form-label fw-semibold small"><%: L.T("Coordinator.Companies.Industry") %></label><asp:TextBox ID="txtIndustry" runat="server" CssClass="form-control bg-light" placeholder="<%$ Resources:Coordinator, Companies.EGSoftwareDevelopment %>"></asp:TextBox></div>
                                    <div class="col-md-6"><label class="form-label fw-semibold small"><%: L.T("Coordinator.Companies.City") %></label><asp:TextBox ID="txtCity" runat="server" CssClass="form-control bg-light" placeholder="<%$ Resources:Coordinator, Companies.EGAmman %>"></asp:TextBox></div>
                                    <div class="col-md-6"><label class="form-label fw-semibold small"><%: L.T("Coordinator.Companies.Website") %></label><asp:TextBox ID="txtWebsite" runat="server" CssClass="form-control bg-light" placeholder="<%$ Resources:Coordinator, Companies.Https %>"></asp:TextBox></div>
                                    <div class="col-md-6"><label class="form-label fw-semibold small"><%: L.T("Coordinator.Companies.CompanyEmail") %></label><asp:TextBox ID="txtCompanyEmail" runat="server" CssClass="form-control bg-light" TextMode="Email" placeholder="info@company.com"></asp:TextBox></div>
                                    <div class="col-md-6"><label class="form-label fw-semibold small"><%: L.T("Coordinator.Companies.CompanyPhone") %></label><asp:TextBox ID="txtCompanyPhone" runat="server" CssClass="form-control bg-light" placeholder="+962..."></asp:TextBox></div>
                                    <div class="col-12"><label class="form-label fw-semibold small"><%: L.T("Coordinator.Companies.FullAddress") %></label><asp:TextBox ID="txtAddress" runat="server" CssClass="form-control bg-light" placeholder="<%$ Resources:Coordinator, Companies.BuildingStreet %>"></asp:TextBox></div>
                                </div>
                            </div>

                            <!-- شركة موجودة -->
                            <div class="tab-pane fade" id="existingCompany">
                                <div class="alert alert-success d-none d-flex justify-content-between align-items-center mb-3" id="selectedCompanyAlert">
                                    <span><i class="bi bi-check-circle-fill me-2"></i> <%: L.T("Coordinator.Companies.Selected") %> <strong id="lblSelectedCompanyNameDisplay"></strong></span>
                                    <button type="button" class="btn btn-sm btn-light border fw-bold" onclick="clearExistingSelection()"><%: L.T("Coordinator.Companies.Change") %></button>
                                </div>
                                <div id="existingCompanyListArea">
                                    <div class="company-list-container shadow-sm">
                                        <asp:Repeater ID="rptExistingCompanies" runat="server">
                                            <ItemTemplate>
                                                <div class="company-item border-bottom" onclick="selectCompany('<%# Eval("Id") %>', '<%# Eval("Name").ToString().Replace("'", "\\'") %>')">
                                                    <div>
                                                        <div class="fw-bold text-dark"><%# Eval("Name") %></div>
                                                        <div class="text-muted small"><i class="bi bi-building me-1"></i><%# Eval("Industry") %> &bull; <i class="bi bi-geo-alt me-1"></i><%# Eval("Address") %></div>
                                                    </div>
                                                    <span class="btn btn-sm btn-outline-primary rounded-pill px-3 fw-bold"><%: L.T("Coordinator.Companies.Select") %></span>
                                                </div>
                                            </ItemTemplate>
                                        </asp:Repeater>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <hr class="my-4" />

                    <!-- قسم المشرف -->
                    <div class="mb-4">
                        <h6 class="fw-bold text-brand mb-3"><%: L.T("Coordinator.Companies.SupervisorDetails") %></h6>
                        <div class="row g-3">
                            <div class="col-md-6"><label class="form-label fw-semibold small"><%: L.T("Coordinator.Companies.FullName") %></label><asp:TextBox ID="txtSupervisorName" runat="server" CssClass="form-control bg-light" placeholder="<%$ Resources:Coordinator, Companies.EGAhmadKhaled %>"></asp:TextBox></div>
                            <div class="col-md-6"><label class="form-label fw-semibold small"><%: L.T("Coordinator.Companies.JobTitle") %></label><asp:TextBox ID="txtJobTitle" runat="server" CssClass="form-control bg-light" placeholder="<%$ Resources:Coordinator, Companies.EGHRManager %>"></asp:TextBox></div>
                            <div class="col-md-6"><label class="form-label fw-semibold small"><%: L.T("Coordinator.Companies.EmailAddress") %></label><asp:TextBox ID="txtSupervisorEmail" runat="server" CssClass="form-control bg-light" TextMode="Email" placeholder="name@company.com"></asp:TextBox></div>
                            <div class="col-md-6"><label class="form-label fw-semibold small"><%: L.T("Coordinator.Companies.PhoneNumber") %></label><asp:TextBox ID="txtSupervisorPhone" runat="server" CssClass="form-control bg-light" placeholder="+962..."></asp:TextBox></div>
                        </div>
                    </div>

                    <hr class="my-4" />

                    <!-- بيانات الدخول -->
                    <div>
                        <h6 class="fw-bold text-brand mb-3"><%: L.T("Coordinator.Companies.AccountAccess") %></h6>
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label fw-semibold small"><%: L.T("Coordinator.Companies.TemporaryPassword") %></label>
                                <asp:TextBox ID="txtTempPassword" runat="server" CssClass="form-control bg-light" TextMode="Password" placeholder="<%$ Resources:Coordinator, Companies.Minimum6Characters %>"></asp:TextBox>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-semibold small"><%: L.T("Coordinator.Companies.AccountRole") %></label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light border-end-0"><i class="bi bi-shield-lock text-muted"></i></span>
                                    <input type="text" class="form-control bg-light border-start-0 text-muted" value="Company Supervisor" readonly="readonly" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="modal-footer bg-light px-4 border-top-0">
                    <button type="button" class="btn btn-outline-secondary rounded-pill px-4 fw-bold" data-bs-dismiss="modal" onclick="resetFormState()"><%: L.T("Coordinator.Companies.Cancel") %></button>
                    <asp:Button ID="btnSave" runat="server" Text="<%$ Resources:Coordinator, Companies.CreateAccount %>" CssClass="btn bg-brand rounded-pill px-4 shadow-sm fw-bold" OnClientClick="return validateAndConfirm();" OnClick="btnSave_Click" CausesValidation="false" data-ui-action="create" data-loading-label="<%$ Resources:Shared, I18n.Creating %>" />
                </div>

            </div>
        </div>
    </div>

    <!-- 2. النافذة المنبثقة للـ View Mode -->
    <div class="modal fade" id="viewDetailsModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content rounded-4 border-0 shadow-lg">
                <div class="modal-header border-bottom-0 pb-0 pt-4 px-4 d-flex justify-content-between align-items-center">
                    <h5 class="fw-bold text-brand mb-0"><%: L.T("Coordinator.Companies.SupervisorDetails2") %></h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="<%: L.T("Coordinator.Companies.Close") %>"></button>
                </div>
                <div class="modal-body p-4">

                    <h6 class="fw-bold text-muted mb-3 text-uppercase small letter-spacing-1"><i class="bi bi-person-badge text-brand me-2 fs-5"></i><%: L.T("Coordinator.Companies.PersonalInfo") %></h6>
                    <div class="row">
                        <div class="col-md-6">
                            <div class="view-label"><%: L.T("Coordinator.Companies.FullName2") %></div>
                            <div class="view-value"><asp:Literal ID="litViewSupName" runat="server"></asp:Literal></div>
                        </div>
                        <div class="col-md-6">
                            <div class="view-label"><%: L.T("Coordinator.Companies.JobTitle2") %></div>
                            <div class="view-value"><asp:Literal ID="litViewJobTitle" runat="server"></asp:Literal></div>
                        </div>
                        <div class="col-md-6">
                            <div class="view-label"><%: L.T("Coordinator.Companies.EmailAddress2") %></div>
                            <div class="view-value"><asp:Literal ID="litViewEmail" runat="server"></asp:Literal></div>
                        </div>
                        <div class="col-md-6">
                            <div class="view-label"><%: L.T("Coordinator.Companies.PhoneNumber2") %></div>
                            <div class="view-value"><asp:Literal ID="litViewPhone" runat="server"></asp:Literal></div>
                        </div>
                    </div>

                    <div class="bg-light rounded-4 p-4 mt-3 border border-light shadow-sm">
                        <h6 class="fw-bold text-muted mb-3 text-uppercase small letter-spacing-1"><i class="bi bi-building text-brand me-2 fs-5"></i><%: L.T("Coordinator.Companies.CompanyInfo") %></h6>
                        <div class="row">
                            <div class="col-md-6">
                                <div class="view-label"><%: L.T("Coordinator.Companies.CompanyName2") %></div>
                                <div class="view-value mb-md-0 border-0"><asp:Literal ID="litViewCompName" runat="server"></asp:Literal></div>
                            </div>
                            <div class="col-md-6">
                                <div class="view-label"><%: L.T("Coordinator.Companies.Industry2") %></div>
                                <div class="view-value mb-0 border-0"><asp:Literal ID="litViewIndustry" runat="server"></asp:Literal></div>
                            </div>
                        </div>
                    </div>

                </div>
                <div class="modal-footer bg-light border-top-0 px-4 rounded-bottom-4">
                    <button type="button" class="btn bg-brand rounded-pill px-5 fw-bold" data-bs-dismiss="modal"><%: L.T("Coordinator.Companies.Close") %></button>
                </div>
            </div>
        </div>
    </div>

    <!-- 3. نافذة التأكيد (Confirmation Modal) -->
    <div class="modal fade" id="confirmToggleModal" tabindex="-1" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered modal-sm">
        <div class="modal-content rounded-4 border-0 shadow-lg text-center p-4">
          <div class="mb-3"><i class='bi bi-question-circle-fill text-warning' style='font-size: 3.5rem;'></i></div>
          <h5 class="fw-bold mb-2 text-dark"><%: L.T("Coordinator.Companies.ConfirmAction") %></h5>
          <p class="text-muted small mb-4"><%: L.T("Coordinator.Companies.AreYouSureYouWantTo") %></p>
          <div class="d-flex gap-2 justify-content-center">
              <button type="button" class="btn btn-light rounded-pill px-4 fw-bold" data-bs-dismiss="modal"><%: L.T("Coordinator.Companies.Cancel") %></button>
              <asp:Button ID="btnConfirmToggle" runat="server" Text="<%$ Resources:Coordinator, Companies.YesIMSure %>" CssClass="btn btn-danger rounded-pill px-4 fw-bold" OnClick="btnConfirmToggle_Click" CausesValidation="false" />
          </div>
        </div>
      </div>
    </div>

    <!-- 4. نافذة رسائل النظام (Pop-up) -->
    <div class="modal fade" id="serverMessageModal" tabindex="-1" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered modal-sm">
        <div class="modal-content rounded-4 border-0 shadow-lg text-center p-4">
          <div class="mb-3"><asp:Literal ID="litModalIcon" runat="server"></asp:Literal></div>
          <h5 class="fw-bold mb-2 text-dark"><asp:Literal ID="litModalTitle" runat="server"></asp:Literal></h5>
          <p class="text-muted small mb-4"><asp:Literal ID="litModalMessage" runat="server"></asp:Literal></p>
          <button type="button" class="btn bg-brand rounded-pill px-4 w-100 fw-bold" data-bs-dismiss="modal"><%: L.T("Coordinator.Companies.Okay") %></button>
        </div>
      </div>
    </div>

    <script>
        function toggleTableVisibility(btn) {
            setTimeout(function() {
                var isExpanded = btn.getAttribute('aria-expanded') === 'true';
                var icon = btn.querySelector('i');
                var text = btn.querySelector('.toggle-text');

                if (isExpanded) {
                    icon.className = 'bi bi-eye-slash-fill me-1';
                    text.innerText = window.uimsT('HideList');
                } else {
                    icon.className = 'bi bi-eye-fill me-1';
                    text.innerText = window.uimsT('ShowList');
                }
            }, 50);
        }

        function openSystemModal(modalId) {
            setTimeout(function() {
                var el = document.getElementById(modalId);
                if(el) { var m = new bootstrap.Modal(el); m.show(); }
            }, 100);
        }
        function hideSystemModal(modalId) {
            var el = document.getElementById(modalId);
            if(el) {
                var m = bootstrap.Modal.getInstance(el);
                if(m) { m.hide(); }
            }
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
            let mode = document.getElementById('<%= hfCompanyMode.ClientID %>').value;
            let existingId = document.getElementById('<%= hfExistingCompId.ClientID %>').value;
            if (mode === "Existing" && existingId === "") {
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
            new bootstrap.Tab(document.getElementById('tab-new')).show();
        }

        function openConfirmModal(supervisorId) {
            document.getElementById('<%= hfToggleSupervisorId.ClientID %>').value = supervisorId;
            openSystemModal('confirmToggleModal');
            return false;
        }
    </script>
</asp:Content>