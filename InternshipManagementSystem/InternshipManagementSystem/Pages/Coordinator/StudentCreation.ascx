<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="StudentCreation.ascx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.StudentCreation" %>
<asp:Label ID="lblSuccess" runat="server" Visible="false" EnableViewState="false" CssClass="alert alert-success d-block" role="status" />
<div class="modal fade creation-modal" id="addStudentModal" data-bs-backdrop="static" tabindex="-1" aria-labelledby="addStudentTitle" aria-hidden="true" data-open-on-load="<%= OpenOnLoad ? "true" : "false" %>">
    <div class="modal-dialog modal-lg modal-dialog-scrollable">
        <asp:Panel ID="pnlCreateContent" runat="server" DefaultButton="btnCreate" CssClass="modal-content rounded-4 border-0 shadow-lg">
            <div class="modal-header border-bottom-0 pb-0 pt-4 px-4">
                <div><h5 id="addStudentTitle" class="fw-bold mb-1">Add student</h5><p class="text-muted small mb-0">Create an account and enter the student's academic information.</p></div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body p-4">
                <asp:Label ID="lblMessage" runat="server" Visible="false" EnableViewState="false" role="alert" />
        <section class="creation-section" aria-labelledby="personal-heading">
            <div class="mb-3"><div><h6 class="fw-bold" id="personal-heading">Personal information</h6><p>Use the student's official name and login email.</p></div></div>
            <div class="row g-3">
                <div class="col-md-6"><label for="<%= txtFullName.ClientID %>" class="form-label">Full name <span class="text-danger">*</span></label><asp:TextBox ID="txtFullName" runat="server" CssClass="form-control bg-light" MaxLength="120" /></div>
                <div class="col-md-6"><span class="form-label d-block">Student ID</span><p class="form-control-plaintext text-muted mb-0">Generated automatically when the account is created.</p></div>
                <div class="col-md-6"><label for="<%= txtEmail.ClientID %>" class="form-label">Login email <span class="text-danger">*</span></label><asp:TextBox ID="txtEmail" runat="server" CssClass="form-control bg-light" TextMode="Email" MaxLength="254" /></div>
                <div class="col-md-6"><label for="<%= txtPhone.ClientID %>" class="form-label">Phone number <span class="text-muted">(optional)</span></label><asp:TextBox ID="txtPhone" runat="server" CssClass="form-control bg-light" TextMode="Phone" MaxLength="40" /></div>
            </div>
        </section>
        <section class="creation-section" aria-labelledby="academic-heading">
            <div class="mb-3"><div><h6 class="fw-bold" id="academic-heading">Academic information</h6><p>These details appear in the student's record.</p></div></div>
            <div class="row g-3">
                <div class="col-md-6"><label for="<%= txtUniversity.ClientID %>" class="form-label">University <span class="text-danger">*</span></label><asp:TextBox ID="txtUniversity" runat="server" CssClass="form-control bg-light" MaxLength="120" /></div>
                <div class="col-md-6"><label for="<%= txtCollege.ClientID %>" class="form-label">College <span class="text-danger">*</span></label><asp:TextBox ID="txtCollege" runat="server" CssClass="form-control bg-light" MaxLength="120" /></div>
                <div class="col-md-6"><label for="<%= ddlMajor.ClientID %>" class="form-label">Major <span class="text-danger">*</span></label><asp:DropDownList ID="ddlMajor" runat="server" CssClass="form-select bg-light" /></div>
                <div class="col-md-6"><label for="<%= txtRequiredHours.ClientID %>" class="form-label">Required training hours <span class="text-danger">*</span></label><asp:TextBox ID="txtRequiredHours" runat="server" CssClass="form-control bg-light" TextMode="Number" /></div>
            </div>
        </section>
        <section class="creation-section" aria-labelledby="access-heading">
            <div class="mb-3"><div><h6 class="fw-bold" id="access-heading">Account access</h6><p>Share the email and temporary password privately. The student must change the password after signing in.</p></div></div>
            <div class="row g-3">
                <div class="col-md-6"><label for="<%= txtPassword.ClientID %>" class="form-label">Temporary password <span class="text-danger">*</span></label><asp:TextBox ID="txtPassword" runat="server" CssClass="form-control bg-light" TextMode="Password" MaxLength="128" /></div>
                <div class="col-md-6"><label for="<%= txtConfirmPassword.ClientID %>" class="form-label">Confirm temporary password <span class="text-danger">*</span></label><asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-control bg-light" TextMode="Password" MaxLength="128" /></div>
            </div>
        </section>
            </div>
            <div class="modal-footer bg-light px-4 border-top-0">
                <button type="button" class="btn btn-outline-secondary rounded-pill px-4" data-bs-dismiss="modal">Cancel</button>
                <asp:Button ID="btnCreate" runat="server" Text="Create student" CssClass="btn btn-primary rounded-pill px-4" OnClick="btnCreate_Click" />
            </div>
        </asp:Panel>
    </div>
</div>
<script src="<%= ResolveUrl("~/Assets/js/account-creation-modal.js") %>" defer></script>
