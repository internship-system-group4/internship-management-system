<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="Companies.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.Companies" Title="Manage Companies" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <style>
        .page-header-title { font-size: 1.75rem; font-weight: 700; color: #0f4c81; }
        .card-container { background: #ffffff; border: 1px solid #e3e8ee; border-radius: 8px; padding: 1.5rem; box-shadow: 0 1px 2px rgba(0,0,0,0.05); }
        .card-title-custom { font-size: 1.1rem; font-weight: 700; color: #0f4c81; margin-bottom: 1.5rem; }
        
        .table-custom { width: 100%; border-collapse: collapse; font-size: 0.875rem; border: 1px solid #e3e8ee; }
        .table-custom th { color: #6b7786; font-size: 0.75rem; text-transform: uppercase; font-weight: 600; padding: 1rem; border-bottom: 1px solid #e3e8ee; }
        .table-custom td { padding: 1rem; border-bottom: 1px solid #e3e8ee; color: #1d2733; vertical-align: middle; }
        
        .nav-tabs-custom { border-bottom: 1px solid #e3e8ee; margin-bottom: 1.5rem; }
        .nav-tabs-custom .nav-link { color: #6b7786; font-weight: 500; font-size: 0.9rem; border: none; padding: 0.5rem 1.5rem; background: transparent; }
        .nav-tabs-custom .nav-link.active { color: #0f4c81; font-weight: 600; border-bottom: 2px solid #0f4c81; }
        .form-label-custom { font-size: 0.85rem; font-weight: 600; color: #1d2733; margin-bottom: 0.35rem; }
        
        .list-item-hover { border: 1px solid #e3e8ee; border-radius: 6px; padding: 0.75rem; margin-bottom: 0.5rem; cursor: pointer; transition: 0.2s; }
        .list-item-hover:hover { border-color: #0f4c81; background-color: #f8fafc; }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container-fluid px-4 py-4">
        
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <div class="text-muted small mb-1">Coordinator workspace &gt; <span class="text-dark">Manage companies</span></div>
                <h2 class="page-header-title mb-0">Manage Companies & Supervisors</h2>
            </div>
            <button type="button" class="btn btn-brand" data-bs-toggle="modal" data-bs-target="#addSupervisorModal">
                Add Company Supervisor
            </button>
        </div>

        <asp:Label ID="lblMessage" runat="server" EnableViewState="false" CssClass="d-block mb-3"></asp:Label>

        <div class="card-container">
            <h5 class="card-title-custom">Existing Company Supervisors</h5>
            
            <div class="table-responsive">
                <asp:GridView ID="gvSupervisors" runat="server" CssClass="table-custom" AutoGenerateColumns="False" OnRowCommand="gvSupervisors_RowCommand" DataKeyNames="Id" GridLines="None">
                    <Columns>
                        <asp:BoundField DataField="FullName" HeaderText="SUPERVISOR NAME" />
                        <asp:BoundField DataField="Email" HeaderText="EMAIL" />
                        <asp:BoundField DataField="CompanyName" HeaderText="COMPANY" />
                        <asp:BoundField DataField="JobTitle" HeaderText="JOB TITLE" />
                        <asp:TemplateField HeaderText="STATUS">
                            <ItemTemplate>
                                <span class='<%# (bool)Eval("IsActive") ? "badge bg-success" : "badge bg-danger" %>'>
                                    <%# (bool)Eval("IsActive") ? "Active" : "Inactive" %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="ACTIONS">
                            <ItemTemplate>
                                <asp:Button ID="btnToggle" runat="server" Text='<%# (bool)Eval("IsActive") ? "Deactivate" : "Activate" %>' CommandName="ToggleStatus" CommandArgument='<%# Eval("Id") %>' CssClass='<%# (bool)Eval("IsActive") ? "btn btn-sm btn-outline-danger" : "btn btn-sm btn-outline-success" %>' OnClientClick="return confirm('Are you sure you want to change this supervisor status?');" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>

    </div>

    <div class="modal fade" id="addSupervisorModal" data-bs-backdrop="static" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-scrollable">
            <div class="modal-content border-0 shadow-lg">
                
                <div class="modal-header bg-light border-bottom-0 pb-0 pt-4 px-4 d-flex justify-content-between align-items-start">
                    <div>
                        <h5 class="fw-bold mb-1" style="color: #0f4c81;">Add company supervisor</h5>
                        <p class="text-muted small mb-0">Create a supervisor account and link it to a training company.</p>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" onclick="resetFormState()"></button>
                </div>

                <div class="modal-body p-4">
                    <asp:HiddenField ID="hfCompanyMode" runat="server" Value="New" />
                    <asp:HiddenField ID="hfExistingCompId" runat="server" />
                    <asp:HiddenField ID="hfExistingCompName" runat="server" />

                    <div class="mb-4">
                        <h6 class="fw-bold" style="color: #0f4c81;">Company information</h6>
                        
                        <ul class="nav nav-tabs nav-tabs-custom" role="tablist">
                            <li class="nav-item">
                                <button class="nav-link active" id="tab-new" data-bs-toggle="tab" data-bs-target="#newCompany" type="button" onclick="setMode('New')">New company</button>
                            </li>
                            <li class="nav-item">
                                <button class="nav-link" id="tab-existing" data-bs-toggle="tab" data-bs-target="#existingCompany" type="button" onclick="setMode('Existing')">Existing company</button>
                            </li>
                        </ul>

                        <div class="tab-content">
                            <div class="tab-pane fade show active" id="newCompany">
                                <div class="row mb-3">
                                    <div class="col-md-6">
                                        <label class="form-label-custom">Company name <span class="required-star">*</span></label>
                                        <asp:TextBox ID="txtCompanyName" runat="server" CssClass="form-control form-control-sm" placeholder="Enter company name"></asp:TextBox>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label-custom">Industry <span class="required-star">*</span></label>
                                        <asp:TextBox ID="txtIndustry" runat="server" CssClass="form-control form-control-sm" placeholder="Select industry"></asp:TextBox>
                                    </div>
                                </div>
                                <div class="row mb-3">
                                    <div class="col-md-6">
                                        <label class="form-label-custom">City <span class="required-star">*</span></label>
                                        <asp:TextBox ID="txtCity" runat="server" CssClass="form-control form-control-sm" placeholder="Enter city"></asp:TextBox>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label-custom">Company website</label>
                                        <asp:TextBox ID="txtWebsite" runat="server" CssClass="form-control form-control-sm" placeholder="https://example.com"></asp:TextBox>
                                    </div>
                                </div>
                                <div class="row mb-3">
                                    <div class="col-md-6">
                                        <label class="form-label-custom">Company Email</label>
                                        <asp:TextBox ID="txtCompanyEmail" runat="server" CssClass="form-control form-control-sm" TextMode="Email" placeholder="company@domain.com"></asp:TextBox>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label-custom">Company Phone</label>
                                        <asp:TextBox ID="txtCompanyPhone" runat="server" CssClass="form-control form-control-sm" placeholder="Enter phone number"></asp:TextBox>
                                    </div>
                                </div>
                                <div>
                                    <label class="form-label-custom">Company address</label>
                                    <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control form-control-sm" placeholder="Enter street, building, and location details"></asp:TextBox>
                                </div>
                            </div>

                            <div class="tab-pane fade" id="existingCompany">
                                <div class="alert alert-success d-none d-flex justify-content-between align-items-center mb-3 py-2" id="selectedCompanyAlert">
                                    <span class="small"><i class="bi bi-check-circle-fill me-2"></i> Selected: <strong id="lblSelectedCompanyNameDisplay"></strong></span>
                                    <button type="button" class="btn btn-sm btn-outline-success bg-white py-0" onclick="clearExistingSelection()">Change</button>
                                </div>
                                
                                <div id="existingCompanyListArea">
                                    <p class="text-muted small mb-2">Select a company from the database.</p>
                                    <div class="border rounded p-2 bg-light" style="max-height: 200px; overflow-y: auto;">
                                        <asp:Repeater ID="rptExistingCompanies" runat="server">
                                            <ItemTemplate>
                                                <div class="list-item-hover bg-white d-flex justify-content-between align-items-center" onclick="selectCompany('<%# Eval("Id") %>', '<%# Eval("Name").ToString().Replace("'", "\\'") %>')">
                                                    <div>
                                                        <div class="fw-bold text-dark small"><%# Eval("Name") %></div>
                                                        <div class="text-muted" style="font-size: 0.75rem;"><%# Eval("Industry") %></div>
                                                    </div>
                                                    <span class="btn btn-sm btn-light border text-muted" style="font-size: 0.75rem;">Select</span>
                                                </div>
                                            </ItemTemplate>
                                        </asp:Repeater>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <hr class="my-4" />

                    <div class="mb-4">
                        <h6 class="fw-bold" style="color: #0f4c81;">Supervisor details</h6>
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label-custom">Full name <span class="required-star">*</span></label>
                                <asp:TextBox ID="txtSupervisorName" runat="server" CssClass="form-control form-control-sm" placeholder="Enter supervisor's full name"></asp:TextBox>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label-custom">Job title</label>
                                <asp:TextBox ID="txtJobTitle" runat="server" CssClass="form-control form-control-sm" placeholder="e.g. Engineering team lead"></asp:TextBox>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-6">
                                <label class="form-label-custom">Email address <span class="required-star">*</span></label>
                                <asp:TextBox ID="txtSupervisorEmail" runat="server" CssClass="form-control form-control-sm" TextMode="Email" placeholder="supervisor@company.com"></asp:TextBox>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label-custom">Phone number</label>
                                <asp:TextBox ID="txtSupervisorPhone" runat="server" CssClass="form-control form-control-sm" placeholder="Enter phone number"></asp:TextBox>
                            </div>
                        </div>
                    </div>

                    <hr class="my-4" />

                    <div class="mb-2">
                        <h6 class="fw-bold" style="color: #0f4c81;">Account access</h6>
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label-custom">Temporary password <span class="required-star">*</span></label>
                                <asp:TextBox ID="txtTempPassword" runat="server" CssClass="form-control form-control-sm" TextMode="Password" placeholder="Enter temporary password"></asp:TextBox>
                                <small class="text-muted" style="font-size: 0.7rem;">Use at least 6 characters.</small>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label-custom">Account role</label>
                                <input type="text" class="form-control form-control-sm bg-light text-muted" value="Company supervisor" readonly />
                            </div>
                        </div>
                    </div>
                </div>

                <div class="modal-footer bg-light px-4 border-top-0">
                    <button type="button" class="btn btn-outline-secondary btn-sm px-4" data-bs-dismiss="modal" onclick="resetFormState()">Cancel</button>
                    <asp:Button ID="btnSave" runat="server" Text="Create account" CssClass="btn btn-brand btn-sm px-4" OnClientClick="return validateAndConfirm();" OnClick="btnSave_Click" />
                </div>

            </div>
        </div>
    </div>

    <script>
        function setMode(mode) {
            document.getElementById('<%= hfCompanyMode.ClientID %>').value = mode;
        }

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
            if (mode === "Existing" && document.getElementById('<%= hfExistingCompId.ClientID %>').value === "") {
                alert("Please select a company from the list first.");
                return false;
            }
            return confirm("Are you sure you want to create this account?");
        }

        function resetFormState() {
            clearExistingSelection();
            setMode('New');
            var newTab = new bootstrap.Tab(document.getElementById('tab-new'));
            newTab.show();
        }
    </script>
</asp:Content>