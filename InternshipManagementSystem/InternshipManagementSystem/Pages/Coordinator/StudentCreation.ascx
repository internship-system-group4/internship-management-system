<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="StudentCreation.ascx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.StudentCreation" %>
<asp:Label ID="lblSuccess" runat="server" Visible="false" EnableViewState="false" CssClass="alert alert-success d-block" role="status" />
<div class="modal fade creation-modal" id="addStudentModal" data-bs-backdrop="static" tabindex="-1" aria-labelledby="addStudentTitle" aria-hidden="true" data-open-on-load="<%= OpenOnLoad ? "true" : "false" %>">
    <div class="modal-dialog modal-lg modal-dialog-scrollable">
        <asp:Panel ID="pnlCreateContent" runat="server" DefaultButton="btnCreate" CssClass="modal-content rounded-4 border-0 shadow-lg">
            <div class="modal-header border-bottom-0 pb-0 pt-4 px-4">
                <div><h5 id="addStudentTitle" class="fw-bold mb-1"><%: L.T("Coordinator.StudentCreation.AddStudent") %></h5><p class="text-muted small mb-0"><%: L.T("Coordinator.StudentCreation.CreateAnAccountAndEnterThe") %></p></div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="<%: L.T("Coordinator.StudentCreation.Close") %>"></button>
            </div>
            <div class="modal-body p-4">
                <asp:Label ID="lblMessage" runat="server" Visible="false" EnableViewState="false" role="alert" />
        <section class="creation-section" aria-labelledby="personal-heading">
            <div class="mb-3"><div><h6 class="fw-bold" id="personal-heading"><%: L.T("Coordinator.StudentCreation.PersonalInformation") %></h6><p><%: L.T("Coordinator.StudentCreation.UseTheStudentSOfficialName") %></p></div></div>
            <div class="row g-3">
                <div class="col-md-6"><label for="<%= txtFullName.ClientID %>" class="form-label"><%: L.T("Coordinator.StudentCreation.FullName") %> <span class="text-danger">*</span></label><asp:TextBox ID="txtFullName" runat="server" CssClass="form-control bg-light" MaxLength="120" /></div>
                <div class="col-md-6"><span class="form-label d-block"><%: L.T("Coordinator.StudentCreation.StudentID") %></span><p class="form-control-plaintext text-muted mb-0"><%: L.T("Coordinator.StudentCreation.GeneratedAutomaticallyWhenTheAccountIs") %></p></div>
                <div class="col-md-6"><label for="<%= txtEmail.ClientID %>" class="form-label"><%: L.T("Coordinator.StudentCreation.LoginEmail") %> <span class="text-danger">*</span></label><asp:TextBox ID="txtEmail" runat="server" CssClass="form-control bg-light" TextMode="Email" MaxLength="254" /></div>
                <div class="col-md-6"><label for="<%= txtPhone.ClientID %>" class="form-label"><%: L.T("Coordinator.StudentCreation.PhoneNumber") %> <span class="text-muted"><%: L.T("Coordinator.StudentCreation.Optional") %></span></label><asp:TextBox ID="txtPhone" runat="server" CssClass="form-control bg-light" TextMode="Phone" MaxLength="40" /></div>
            </div>
        </section>
        <section class="creation-section" aria-labelledby="academic-heading">
            <div class="mb-3"><div><h6 class="fw-bold" id="academic-heading"><%: L.T("Coordinator.StudentCreation.AcademicInformation") %></h6><p><%: L.T("Coordinator.StudentCreation.TheseDetailsAppearInTheStudent") %></p></div></div>
            <div class="row g-3">
                <div class="col-md-6"><label for="<%= txtUniversity.ClientID %>" class="form-label"><%: L.T("Coordinator.StudentCreation.University") %> <span class="text-danger">*</span></label><asp:TextBox ID="txtUniversity" runat="server" CssClass="form-control bg-light" MaxLength="120" /></div>
                <div class="col-md-6"><label for="<%= txtCollege.ClientID %>" class="form-label"><%: L.T("Coordinator.StudentCreation.College") %> <span class="text-danger">*</span></label><asp:TextBox ID="txtCollege" runat="server" CssClass="form-control bg-light" MaxLength="120" /></div>
                <div class="col-md-6"><label for="<%= ddlMajor.ClientID %>" class="form-label"><%: L.T("Coordinator.StudentCreation.Major") %> <span class="text-danger">*</span></label><asp:DropDownList ID="ddlMajor" runat="server" CssClass="form-select bg-light" /></div>
                <div class="col-md-6"><label for="<%= txtRequiredHours.ClientID %>" class="form-label"><%: L.T("Coordinator.StudentCreation.RequiredTrainingHours") %> <span class="text-danger">*</span></label><asp:TextBox ID="txtRequiredHours" runat="server" CssClass="form-control bg-light" TextMode="Number" /></div>
            </div>
        </section>
        <section class="creation-section" aria-labelledby="access-heading">
            <div class="mb-3"><div><h6 class="fw-bold" id="access-heading"><%: L.T("Coordinator.StudentCreation.AccountAccess") %></h6><p><%: L.T("Coordinator.StudentCreation.ShareTheEmailAndTemporaryPassword") %></p></div></div>
            <div class="row g-3">
                <div class="col-md-6"><label for="<%= txtPassword.ClientID %>" class="form-label"><%: L.T("Coordinator.StudentCreation.TemporaryPassword") %> <span class="text-danger">*</span></label><asp:TextBox ID="txtPassword" runat="server" CssClass="form-control bg-light" TextMode="Password" MaxLength="128" /></div>
                <div class="col-md-6"><label for="<%= txtConfirmPassword.ClientID %>" class="form-label"><%: L.T("Coordinator.StudentCreation.ConfirmTemporaryPassword") %> <span class="text-danger">*</span></label><asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-control bg-light" TextMode="Password" MaxLength="128" /></div>
            </div>
        </section>
            </div>
            <div class="modal-footer bg-light px-4 border-top-0">
                <button type="button" class="btn btn-outline-secondary rounded-pill px-4" data-bs-dismiss="modal"><%: L.T("Coordinator.StudentCreation.Cancel") %></button>
                <asp:Button ID="btnCreate" runat="server" Text="<%$ Resources:Coordinator, StudentCreation.CreateStudent %>" CssClass="btn btn-primary rounded-pill px-4" OnClick="btnCreate_Click" />
            </div>
        </asp:Panel>
    </div>
</div>
<script src="<%= ResolveUrl("~/Assets/js/account-creation-modal.js") %>" defer></script>
