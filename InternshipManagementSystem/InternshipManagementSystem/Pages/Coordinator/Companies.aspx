<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="Companies.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.Companies" Title="Manage Companies" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <style>
        /* 1. تثبيت زر تسجيل الخروج بأسفل الشاشة (للقائمة الجانبية في الماستر بيج) */
        .sidebar, aside { display: flex; flex-direction: column; height: 100vh; }
        .sidebar-menu { flex-grow: 1; overflow-y: auto; }
        .logout-container, .logout-box { margin-top: auto !important; border-top: 1px solid #e3e8ee; padding-top: 1rem; }

        /* 2. اللون الأساسي ولمسات بسيطة */
        .text-brand { color: var(--ui-primary) !important; }
        .bg-brand { background-color: var(--ui-primary) !important; color: white; border: none; }
        .bg-brand:hover { background-color: #0a365c !important; color: white; }
        .nav-tabs .nav-link { color: #6b7786; font-weight: 500; border: none; background: transparent; }
        .nav-tabs .nav-link.active { color: var(--ui-primary); font-weight: bold; border-bottom: 2px solid var(--ui-primary); }
        .hover-item:hover { border-color: var(--ui-primary) !important; background-color: #f8fafc; cursor: pointer; }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container-fluid px-4 py-4">
        
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <div class="text-muted small mb-1">Coordinator workspace &gt; <span class="text-dark">Manage companies</span></div>
                <h2 class="fw-bold text-brand mb-0 fs-3">Manage Companies & Supervisors</h2>
            </div>
            <button type="button" class="btn bg-brand px-4 py-2 rounded-3 shadow-sm" data-bs-toggle="modal" data-bs-target="#addSupervisorModal">
                <i class="bi bi-plus-lg me-2"></i>Add Supervisor
            </button>
        </div>

        <asp:Label ID="lblMessage" runat="server" EnableViewState="false" CssClass="d-block mb-3"></asp:Label>

        <div class="card border-0 shadow-sm rounded-4 p-4">
            <h5 class="fw-bold text-brand mb-4">Existing Company Supervisors</h5>
            
            <div class="table-responsive">
                <asp:GridView ID="gvSupervisors" runat="server" CssClass="table table-hover align-middle mb-0" AutoGenerateColumns="False" OnRowCommand="gvSupervisors_RowCommand" DataKeyNames="Id" GridLines="None">
                    <HeaderStyle CssClass="bg-light text-muted small text-uppercase" />
                    <Columns>
                        <asp:BoundField DataField="FullName" HeaderText="Supervisor Name" ItemStyle-CssClass="fw-bold text-dark" />
                        <asp:BoundField DataField="Email" HeaderText="Email" />
                        <asp:BoundField DataField="CompanyName" HeaderText="Company" />
                        <asp:BoundField DataField="JobTitle" HeaderText="Job Title" />
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <span class='<%# (bool)Eval("IsActive") ? "badge bg-success bg-opacity-10 text-success px-3 py-2 rounded-pill" : "badge bg-danger bg-opacity-10 text-danger px-3 py-2 rounded-pill" %>'>
                                    <%# (bool)Eval("IsActive") ? "Active" : "Inactive" %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <asp:Button ID="btnToggle" runat="server" Text='<%# (bool)Eval("IsActive") ? "Deactivate" : "Activate" %>' CommandName="ToggleStatus" CommandArgument='<%# Eval("Id") %>' CssClass='<%# (bool)Eval("IsActive") ? "btn btn-sm btn-outline-danger rounded-pill px-3" : "btn btn-sm btn-outline-success rounded-pill px-3" %>' OnClientClick="return confirm('Change this supervisor status?');"  data-ui-action="update" data-loading-label="Updating…"/>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>

    <!-- النافذة المنبثقة (Modal) -->
    <div class="modal fade" id="addSupervisorModal" data-bs-backdrop="static" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-scrollable">
            <div class="modal-content rounded-4 border-0 shadow-lg">
                
                <div class="modal-header border-bottom-0 pb-0 pt-4 px-4">
                    <div>
                        <h5 class="fw-bold text-brand mb-1">Add company supervisor</h5>
                        <p class="text-muted small mb-0">Create a supervisor account and link it to a training company.</p>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" onclick="resetFormState()"></button>
                </div>

                <div class="modal-body p-4">
                    <asp:HiddenField ID="hfCompanyMode" runat="server" Value="New" />
                    <asp:HiddenField ID="hfExistingCompId" runat="server" />
                    <asp:HiddenField ID="hfExistingCompName" runat="server" />

                    <!-- قسم الشركة -->
                    <div class="mb-4">
                        <h6 class="fw-bold text-brand mb-3">Company information</h6>
                        <ul class="nav nav-tabs mb-3">
                            <li class="nav-item"><button class="nav-link active" id="tab-new" data-bs-toggle="tab" data-bs-target="#newCompany" type="button" onclick="setMode('New')">New company</button></li>
                            <li class="nav-item"><button class="nav-link" id="tab-existing" data-bs-toggle="tab" data-bs-target="#existingCompany" type="button" onclick="setMode('Existing')">Existing company</button></li>
                        </ul>

                        <div class="tab-content">
                            <!-- شركة جديدة -->
                            <div class="tab-pane fade show active" id="newCompany">
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label class="form-label fw-semibold small">Company name *</label>
                                        <asp:TextBox ID="txtCompanyName" runat="server" CssClass="form-control bg-light" placeholder="Enter company name"></asp:TextBox>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label fw-semibold small">Industry *</label>
                                        <asp:TextBox ID="txtIndustry" runat="server" CssClass="form-control bg-light" placeholder="Select industry"></asp:TextBox>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label fw-semibold small">City *</label>
                                        <asp:TextBox ID="txtCity" runat="server" CssClass="form-control bg-light" placeholder="Enter city"></asp:TextBox>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label fw-semibold small">Website</label>
                                        <asp:TextBox ID="txtWebsite" runat="server" CssClass="form-control bg-light" placeholder="https://example.com"></asp:TextBox>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label fw-semibold small">Company Email</label>
                                        <asp:TextBox ID="txtCompanyEmail" runat="server" CssClass="form-control bg-light" TextMode="Email" placeholder="company@domain.com"></asp:TextBox>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label fw-semibold small">Company Phone</label>
                                        <asp:TextBox ID="txtCompanyPhone" runat="server" CssClass="form-control bg-light" placeholder="Enter phone number"></asp:TextBox>
                                    </div>
                                    <div class="col-12">
                                        <label class="form-label fw-semibold small">Address</label>
                                        <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control bg-light" placeholder="Enter street, building, and location details"></asp:TextBox>
                                    </div>
                                </div>
                            </div>

                            <!-- شركة موجودة -->
                            <div class="tab-pane fade" id="existingCompany">
                                <div class="alert alert-success d-none d-flex justify-content-between align-items-center mb-3" id="selectedCompanyAlert">
                                    <span><i class="bi bi-check-circle-fill me-2"></i> Selected: <strong id="lblSelectedCompanyNameDisplay"></strong></span>
                                    <button type="button" class="btn btn-sm btn-light" onclick="clearExistingSelection()">Change</button>
                                </div>
                                <div id="existingCompanyListArea">
                                    <div class="border rounded p-2 bg-light" style="max-height: 200px; overflow-y: auto;">
                                        <asp:Repeater ID="rptExistingCompanies" runat="server">
                                            <ItemTemplate>
                                                <div class="hover-item border rounded bg-white p-2 mb-2 d-flex justify-content-between align-items-center" onclick="selectCompany('<%# Eval("Id") %>', '<%# Eval("Name").ToString().Replace("'", "\\'") %>')">
                                                    <div><div class="fw-bold small"><%# Eval("Name") %></div><div class="text-muted" style="font-size: 0.75rem;"><%# Eval("Industry") %></div></div>
                                                    <span class="btn btn-sm btn-light border text-muted">Select</span>
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
                        <h6 class="fw-bold text-brand mb-3">Supervisor details</h6>
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label fw-semibold small">Full name *</label>
                                <asp:TextBox ID="txtSupervisorName" runat="server" CssClass="form-control bg-light" placeholder="Enter supervisor's full name"></asp:TextBox>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-semibold small">Job title</label>
                                <asp:TextBox ID="txtJobTitle" runat="server" CssClass="form-control bg-light" placeholder="e.g. Engineering team lead"></asp:TextBox>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-semibold small">Email address *</label>
                                <asp:TextBox ID="txtSupervisorEmail" runat="server" CssClass="form-control bg-light" TextMode="Email" placeholder="supervisor@company.com"></asp:TextBox>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-semibold small">Phone number</label>
                                <asp:TextBox ID="txtSupervisorPhone" runat="server" CssClass="form-control bg-light" placeholder="Enter phone number"></asp:TextBox>
                            </div>
                        </div>
                    </div>

                    <hr class="my-4" />

                    <!-- بيانات الدخول -->
                    <div>
                        <h6 class="fw-bold text-brand mb-3">Account access</h6>
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label fw-semibold small">Temporary password *</label>
                                <asp:TextBox ID="txtTempPassword" runat="server" CssClass="form-control bg-light" TextMode="Password" placeholder="Enter temporary password"></asp:TextBox>
                                <small class="text-muted" style="font-size: 0.7rem;">Use at least 6 characters.</small>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-semibold small">Account role</label>
                                <input type="text" class="form-control bg-light text-muted" value="Company supervisor" readonly />
                            </div>
                        </div>
                    </div>
                </div>

                <div class="modal-footer bg-light px-4 border-top-0">
                    <button type="button" class="btn btn-outline-secondary rounded-pill px-4" data-bs-dismiss="modal" onclick="resetFormState()">Cancel</button>
                    <asp:Button ID="btnSave" runat="server" Text="Create account" CssClass="btn bg-brand rounded-pill px-4" OnClientClick="return validateAndConfirm();" OnClick="btnSave_Click"  data-ui-action="create" data-loading-label="Creating…"/>
                </div>

            </div>
        </div>
    </div>

    <script>
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
            if (document.getElementById('<%= hfCompanyMode.ClientID %>').value === "Existing" && document.getElementById('<%= hfExistingCompId.ClientID %>').value === "") {
                alert("Please select a company from the list first."); return false;
            }
            return confirm("Are you sure you want to create this account?");
        }
        function resetFormState() { clearExistingSelection(); setMode('New'); new bootstrap.Tab(document.getElementById('tab-new')).show(); }
    </script>
</asp:Content>