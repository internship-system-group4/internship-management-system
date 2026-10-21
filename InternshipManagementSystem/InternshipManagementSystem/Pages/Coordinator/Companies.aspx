<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="Companies.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.Companies" Title="Add company supervisor" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <style>
        .form-section-title {
            font-size: 1.05rem;
            font-weight: 600;
            color: #1d2733;
            margin-bottom: 1rem;
            padding-bottom: 0.4rem;
            border-bottom: 1px solid #e3e8ee;
        }
        .uims-form-card {
            background: #ffffff;
            border: 1px solid #e3e8ee;
            border-radius: 10px;
            padding: 2rem;
            box-shadow: 0 1px 3px rgba(16, 24, 40, 0.04);
        }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container-fluid py-2 px-4">
        
        <!-- مسار التنقل (Breadcrumb) مطابق لفيغما -->
        <div class="mb-4">
            <nav aria-label="breadcrumb">
                <small class="text-muted">Coordinator workspace &gt; <span class="text-dark fw-bold">Add company supervisor</span></small>
            </nav>
            <h2 class="fw-bold mt-2" style="color: #0f4c81;">Add company supervisor</h2>
            <p class="text-muted">Create a supervisor account and link it to a training company.</p>
        </div>

        <asp:Label ID="lblMessage" runat="server" EnableViewState="false" CssClass="d-block mb-3"></asp:Label>

        <!-- زر الإضافة السريعة للشركات الـ 10 التي طلبها أحمد -->
        <div class="card bg-light border-0 mb-4 p-3 shadow-sm">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h6 class="fw-bold mb-1">Quick Setup (Ahmad's 10 Companies)</h6>
                    <p class="text-muted small mb-0">Click to automatically provision all 10 partner companies and their supervisor accounts[cite: 22].</p>
                </div>
                <asp:Button ID="btnSeed" runat="server" Text="Seed 10 Companies" CssClass="btn btn-brand btn-sm" OnClick="SeedAhmadCompanies_Click" />
            </div>
        </div>

        <!-- نموذج إضافة شركة ومشرف (مطابق لفيغما حرفياً) -->
        <div class="uims-form-card mb-4">
            
            <!-- 1. Company information -->
            <div class="mb-4">
                <h5 class="form-section-title">Company information</h5>
                
                <div class="row mb-3">
                    <div class="col-md-6">
                        <label class="form-label small fw-bold">Company name *</label>
                        <input type="text" id="txtCompanyName" runat="server" class="form-control" placeholder="Enter company name" required />
                    </div>
                    <div class="col-md-6">
                        <label class="form-label small fw-bold">Industry *</label>
                        <input type="text" id="txtIndustry" runat="server" class="form-control" placeholder="Select or enter industry" required />
                    </div>
                </div>

                <div class="row mb-3">
                    <div class="col-md-6">
                        <label class="form-label small fw-bold">City / Address *</label>
                        <input type="text" id="txtAddress" runat="server" class="form-control" placeholder="Enter city or address" required />
                    </div>
                    <div class="col-md-6">
                        <label class="form-label small fw-bold">Company website</label>
                        <input type="url" id="txtWebsite" runat="server" class="form-control" placeholder="https://example.com" />
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6">
                        <label class="form-label small fw-bold">Company Email</label>
                        <input type="email" id="txtCompanyEmail" runat="server" class="form-control" placeholder="company@domain.com" />
                    </div>
                    <div class="col-md-6">
                        <label class="form-label small fw-bold">Company Phone</label>
                        <input type="text" id="txtCompanyPhone" runat="server" class="form-control" placeholder="Enter phone number" />
                    </div>
                </div>
            </div>

            <!-- 2. Supervisor details -->
            <div class="mb-4">
                <h5 class="form-section-title">Supervisor details</h5>

                <div class="row mb-3">
                    <div class="col-md-6">
                        <label class="form-label small fw-bold">Full name *</label>
                        <input type="text" id="txtSupervisorName" runat="server" class="form-control" placeholder="Enter supervisor's full name" required />
                    </div>
                    <div class="col-md-6">
                        <label class="form-label small fw-bold">Job title</label>
                        <input type="text" id="txtJobTitle" runat="server" class="form-control" placeholder="e.g. Engineering team lead" />
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6">
                        <label class="form-label small fw-bold">Email address *</label>
                        <input type="email" id="txtSupervisorEmail" runat="server" class="form-control" placeholder="supervisor@company.com" required />
                    </div>
                    <div class="col-md-6">
                        <label class="form-label small fw-bold">Phone number</label>
                        <input type="text" id="txtSupervisorPhone" runat="server" class="form-control" placeholder="Enter phone number" />
                    </div>
                </div>
            </div>

            <!-- 3. Account access -->
            <div class="mb-4">
                <h5 class="form-section-title">Account access</h5>

                <div class="row mb-3">
                    <div class="col-md-6">
                        <label class="form-label small fw-bold">Temporary password *</label>
                        <input type="password" id="txtTempPassword" runat="server" class="form-control" placeholder="Enter temporary password" required minlength="6" />
                        <small class="text-muted">Use at least 6 characters.</small>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label small fw-bold">Account role</label>
                        <input type="text" class="form-control bg-light" value="Company supervisor" readonly />
                    </div>
                </div>

                <div class="alert alert-info py-2 small" role="alert">
                    <i class="bi bi-info-circle me-1"></i> The account will be active and linked to the selected company. The supervisor signs in with this email and temporary password[cite: 10, 25].
                </div>
            </div>

            <!-- Buttons -->
            <div class="d-flex justify-content-end gap-2 pt-3 border-top">
                <button type="reset" class="btn btn-outline-secondary px-4">Cancel</button>
                <asp:Button ID="btnSave" runat="server" Text="Create account" CssClass="btn btn-brand px-4" OnClick="btnSave_Click" />
            </div>

        </div>

        <!-- جدول المراقبة والتفعيل (Card N04) -->
        <div class="uims-form-card mt-4">
            <h5 class="form-section-title">Existing Company Supervisors</h5>
            <div class="table-responsive">
                <asp:GridView ID="gvSupervisors" runat="server" CssClass="uims-table" AutoGenerateColumns="False" OnRowCommand="gvSupervisors_RowCommand" DataKeyNames="Id">
                    <Columns>
                        <asp:BoundField DataField="FullName" HeaderText="Supervisor Name" />
                        <asp:BoundField DataField="Email" HeaderText="Email" />
                        <asp:BoundField DataField="CompanyName" HeaderText="Company" />
                        <asp:BoundField DataField="JobTitle" HeaderText="Job Title" />
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <span class='<%# (bool)Eval("IsActive") ? "uims-pill uims-pill-accepted" : "uims-pill uims-pill-rejected" %>'>
                                    <%# (bool)Eval("IsActive") ? "Active" : "Inactive" %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <asp:Button ID="btnToggle" runat="server" 
                                            Text='<%# (bool)Eval("IsActive") ? "Deactivate" : "Activate" %>' 
                                            CommandName="ToggleStatus" 
                                            CommandArgument='<%# Eval("Id") %>' 
                                            CssClass='<%# (bool)Eval("IsActive") ? "btn btn-sm btn-outline-danger" : "btn btn-sm btn-outline-success" %>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>

    </div>
</asp:Content>