<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="Companies.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.Companies" Title="Add company supervisor" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <style>
        .uims-breadcrumb {
            font-size: 0.85rem;
            color: #6b7786;
            margin-bottom: 0.5rem;
        }
        .uims-breadcrumb a {
            color: #6b7786;
            text-decoration: none;
        }
        .uims-page-heading h2 {
            font-size: 1.5rem;
            font-weight: 700;
            color: #0f4c81;
            margin-bottom: 0.25rem;
        }
        .uims-page-heading p {
            color: #6b7786;
            font-size: 0.95rem;
            margin-bottom: 1.5rem;
        }
        .form-card-box {
            background: #ffffff;
            border: 1px solid #e3e8ee;
            border-radius: 12px;
            padding: 2rem;
            box-shadow: 0 1px 3px rgba(16, 24, 40, 0.04);
            margin-bottom: 2rem;
        }
        .section-title {
            font-size: 1.05rem;
            font-weight: 600;
            color: #1d2733;
            margin-bottom: 1.25rem;
        }
        .nav-tabs-custom .nav-link {
            border: 1px solid #e3e8ee;
            color: #6b7786;
            font-weight: 500;
            border-radius: 8px 8px 0 0;
            padding: 0.5rem 1.25rem;
        }
        .nav-tabs-custom .nav-link.active {
            background-color: #f6f8fa;
            color: #0f4c81;
            border-bottom-color: #f6f8fa;
            font-weight: 600;
        }
        .form-label-custom {
            font-size: 0.85rem;
            font-weight: 600;
            color: #1d2733;
            margin-bottom: 0.35rem;
        }
        .required-star {
            color: #d93838;
        }
        .alert-info-box {
            background-color: #f0f4f8;
            border: 1px solid #d9e2ec;
            color: #102a43;
            border-radius: 8px;
            padding: 0.75rem 1rem;
            font-size: 0.875rem;
        }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container-fluid px-4 py-3">
        
        <!-- مسار التنقل (Breadcrumb) مطابق لفيغما -->
        <div class="uims-breadcrumb">
            Coordinator workspace &gt; <span class="text-dark fw-semibold">Add company supervisor</span>
        </div>

        <!-- ترويسة الصفحة -->
        <div class="uims-page-heading">
            <h2>Add company supervisor</h2>
            <p>Create a supervisor account and link it to a training company.</p>
        </div>

        <asp:Label ID="lblMessage" runat="server" EnableViewState="false" CssClass="d-block mb-3"></asp:Label>

        <!-- زر الإضافة السريعة للشركات العشر الخاصة بأحمد -->
        <div class="card bg-light border-0 mb-4 p-3 shadow-sm">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h6 class="fw-bold mb-1">Quick Setup (Ahmad's 10 Partner Companies)</h6>
                    <p class="text-muted small mb-0">Click to automatically provision all 10 requested companies and supervisor accounts[cite: 22].</p>
                </div>
                <asp:Button ID="btnSeed" runat="server" Text="Seed 10 Companies" CssClass="btn btn-brand btn-sm px-3" OnClick="SeedAhmadCompanies_Click" />
            </div>
        </div>

        <!-- الحاوية الرئيسية للنموذج (مطابقة لفيغما حرفياً) -->
        <div class="form-card-box">
            
            <!-- تبويبات New company / Existing company -->
            <ul class="nav nav-tabs nav-tabs-custom mb-4" role="tablist">
                <li class="nav-item">
                    <a class="nav-link active" data-bs-toggle="tab" href="#newCompanyTab">New company</a>
                </li>
            </ul>

            <!-- 1. Company information Section -->
            <div class="mb-4">
                <h5 class="section-title">Company information</h5>
                
                <div class="row mb-3">
                    <div class="col-md-6">
                        <label class="form-label-custom">Company name <span class="required-star">*</span></label>
                        <input type="text" id="txtCompanyName" runat="server" class="form-control" placeholder="Enter company name" required />
                    </div>
                    <div class="col-md-6">
                        <label class="form-label-custom">Industry <span class="required-star">*</span></label>
                        <input type="text" id="txtIndustry" runat="server" class="form-control" placeholder="e.g. Software & Technology" required />
                    </div>
                </div>

                <div class="row mb-3">
                    <div class="col-md-6">
                        <label class="form-label-custom">City <span class="required-star">*</span></label>
                        <input type="text" id="txtCity" runat="server" class="form-control" placeholder="Enter city" required />
                    </div>
                    <div class="col-md-6">
                        <label class="form-label-custom">Company website</label>
                        <input type="url" id="txtWebsite" runat="server" class="form-control" placeholder="https://example.com" />
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label-custom">Company address</label>
                    <input type="text" id="txtAddress" runat="server" class="form-control" placeholder="Enter street, building, and location details" />
                </div>

                <div class="row">
                    <div class="col-md-6">
                        <label class="form-label-custom">Company Email</label>
                        <input type="email" id="txtCompanyEmail" runat="server" class="form-control" placeholder="company@domain.com" />
                    </div>
                    <div class="col-md-6">
                        <label class="form-label-custom">Company Phone</label>
                        <input type="text" id="txtCompanyPhone" runat="server" class="form-control" placeholder="Enter phone number" />
                    </div>
                </div>
            </div>

            <hr class="my-4 text-muted" />

            <!-- 2. Supervisor details Section -->
            <div class="mb-4">
                <h5 class="section-title">Supervisor details</h5>

                <div class="row mb-3">
                    <div class="col-md-6">
                        <label class="form-label-custom">Full name <span class="required-star">*</span></label>
                        <input type="text" id="txtSupervisorName" runat="server" class="form-control" placeholder="Enter supervisor's full name" required />
                    </div>
                    <div class="col-md-6">
                        <label class="form-label-custom">Job title</label>
                        <input type="text" id="txtJobTitle" runat="server" class="form-control" placeholder="e.g. Engineering team lead" />
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6">
                        <label class="form-label-custom">Email address <span class="required-star">*</span></label>
                        <input type="email" id="txtSupervisorEmail" runat="server" class="form-control" placeholder="supervisor@company.com" required />
                    </div>
                    <div class="col-md-6">
                        <label class="form-label-custom">Phone number</label>
                        <input type="text" id="txtSupervisorPhone" runat="server" class="form-control" placeholder="Enter phone number" />
                    </div>
                </div>
            </div>

            <hr class="my-4 text-muted" />

            <!-- 3. Account access Section -->
            <div class="mb-4">
                <h5 class="section-title">Account access</h5>

                <div class="row mb-3">
                    <div class="col-md-6">
                        <label class="form-label-custom">Temporary password <span class="required-star">*</span></label>
                        <input type="password" id="txtTempPassword" runat="server" class="form-control" placeholder="Enter temporary password" required minlength="6" />
                        <small class="text-muted" style="font-size: 0.75rem;">Use at least 8 characters.</small>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label-custom">Account role</label>
                        <input type="text" class="form-control bg-light text-muted" value="Company supervisor" readonly />
                    </div>
                </div>

                <!-- رسالة التنبيه الإرشادية المطابقة لفيغما -->
                <div class="alert-info-box d-flex align-items-center mt-3">
                    <i class="bi bi-info-circle-fill me-2 fs-5"></i>
                    <span>The account will be active and linked to the selected company. The supervisor signs in with this email and temporary password[cite: 10, 25].</span>
                </div>
            </div>

            <!-- أزرار الإجراءات (Cancel / Create account) مطابقة لفيغما -->
            <div class="d-flex justify-content-end gap-2 pt-3 border-top">
                <button type="reset" class="btn btn-outline-secondary px-4">Cancel</button>
                <asp:Button ID="btnSave" runat="server" Text="Create account" CssClass="btn btn-brand px-4" OnClick="btnSave_Click" />
            </div>

        </div>

        <!-- جدول متابعة المشرفين والشركات المضافة (Card N04) -->
        <div class="form-card-box">
            <h5 class="section-title">Existing Company Supervisors</h5>
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