<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="StudentCreation.ascx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.StudentCreation" %>
<asp:Label ID="lblSuccess" runat="server" Visible="false" EnableViewState="false" CssClass="alert alert-success d-block" role="status" />
<div class="modal fade creation-modal dir-modal" id="addStudentModal" data-bs-backdrop="static" tabindex="-1" aria-labelledby="addStudentTitle" aria-hidden="true" data-open-on-load="<%= OpenOnLoad ? "true" : "false" %>">
    <div class="modal-dialog modal-lg modal-dialog-scrollable">
        <asp:Panel ID="pnlCreateContent" runat="server" DefaultButton="btnCreate" CssClass="modal-content">
            <div class="modal-header dir-modal-hero">
                <span class="dir-avatar dir-avatar-lg" aria-hidden="true"><span data-ui-icon="people"></span></span>
                <div class="dir-hero-text"><h3 id="addStudentTitle" class="modal-title"><%: L.T("Coordinator.StudentCreation.AddStudent") %></h3><p><%: L.T("Coordinator.StudentCreation.CreateAnAccountAndEnterThe") %></p></div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="<%: L.T("Coordinator.StudentCreation.Close") %>"></button>
            </div>
            <div class="modal-body">
                <asp:Label ID="lblMessage" runat="server" Visible="false" EnableViewState="false" role="alert" />
        <section class="creation-section" aria-labelledby="personal-heading">
            <div class="mb-3"><div><h4 class="dir-form-title" id="personal-heading"><%: L.T("Coordinator.StudentCreation.PersonalInformation") %></h4><p><%: L.T("Coordinator.StudentCreation.UseTheStudentSOfficialName") %></p></div></div>
            <div class="row g-3">
                <div class="col-md-6"><label for="<%= txtFullName.ClientID %>" class="form-label"><%: L.T("Coordinator.StudentCreation.FullName") %> <span class="text-danger">*</span></label><asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" MaxLength="120" /></div>
                <div class="col-md-6"><span class="form-label d-block"><%: L.T("Coordinator.StudentCreation.StudentID") %></span><p class="form-control-plaintext text-muted mb-0"><%: L.T("Coordinator.StudentCreation.GeneratedAutomaticallyWhenTheAccountIs") %></p></div>
                <div class="col-md-6"><label for="<%= txtEmail.ClientID %>" class="form-label"><%: L.T("Coordinator.StudentCreation.LoginEmail") %> <span class="text-danger">*</span></label><asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" MaxLength="254" /></div>
                <div class="col-md-6"><label for="<%= txtPhone.ClientID %>" class="form-label"><%: L.T("Coordinator.StudentCreation.PhoneNumber") %> <span class="text-muted"><%: L.T("Coordinator.StudentCreation.Optional") %></span></label><asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" TextMode="Phone" MaxLength="40" /></div>
            </div>
        </section>
        <section class="creation-section" aria-labelledby="academic-heading">
            <div class="mb-3"><div><h4 class="dir-form-title" id="academic-heading"><%: L.T("Coordinator.StudentCreation.AcademicInformation") %></h4><p><%: L.T("Coordinator.StudentCreation.TheseDetailsAppearInTheStudent") %></p></div></div>
            <div class="row g-3">
                <div class="col-md-6"><label for="<%= txtUniversity.ClientID %>" class="form-label"><%: L.T("Coordinator.StudentCreation.University") %> <span class="text-danger">*</span></label><asp:TextBox ID="txtUniversity" runat="server" CssClass="form-control" MaxLength="120" /></div>
                <div class="col-md-6"><label for="<%= txtCollege.ClientID %>" class="form-label"><%: L.T("Coordinator.StudentCreation.College") %> <span class="text-danger">*</span></label><asp:TextBox ID="txtCollege" runat="server" CssClass="form-control" MaxLength="120" /></div>
                <div class="col-md-6"><label for="<%= ddlMajor.ClientID %>" class="form-label"><%: L.T("Coordinator.StudentCreation.Major") %> <span class="text-danger">*</span></label><asp:DropDownList ID="ddlMajor" runat="server" CssClass="form-select" /></div>
                <div class="col-md-6"><label for="<%= txtRequiredHours.ClientID %>" class="form-label"><%: L.T("Coordinator.StudentCreation.RequiredTrainingHours") %> <span class="text-danger">*</span></label><asp:TextBox ID="txtRequiredHours" runat="server" CssClass="form-control" TextMode="Number" /></div>
            </div>
        </section>
        <section class="creation-section" aria-labelledby="access-heading">
            <div class="mb-3"><div><h4 class="dir-form-title" id="access-heading"><%: L.T("Coordinator.StudentCreation.AccountAccess") %></h4><p><%: L.T("Coordinator.StudentCreation.ShareTheEmailAndTemporaryPassword") %></p></div></div>
            <div class="row g-3">
                <div class="col-md-6"><label for="<%= txtPassword.ClientID %>" class="form-label"><%: L.T("Coordinator.StudentCreation.TemporaryPassword") %> <span class="text-danger">*</span></label><asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" MaxLength="128" /></div>
                <div class="col-md-6"><label for="<%= txtConfirmPassword.ClientID %>" class="form-label"><%: L.T("Coordinator.StudentCreation.ConfirmTemporaryPassword") %> <span class="text-danger">*</span></label><asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-control" TextMode="Password" MaxLength="128" /></div>
            </div>
        </section>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal"><%: L.T("Coordinator.StudentCreation.Cancel") %></button>
                <asp:Button ID="btnCreate" runat="server" Text="<%$ Resources:Coordinator, StudentCreation.CreateStudent %>" CssClass="btn btn-brand" data-ui-action="create" OnClick="btnCreate_Click" />
            </div>
        </asp:Panel>
    </div>
</div>
<% if (lblSuccess.Visible) { %>
<%-- Animated "student created" popup (SweetAlert2). Rendered only after a successful create.
     The plain success message is hidden once the popup shows, and stays as a fallback if the CDN is unreachable. --%>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.14.5/dist/sweetalert2.all.min.js"></script>
<script>
(function () {
    function celebrate() {
        var label = document.getElementById('<%= lblSuccess.ClientID %>');
        if (!label || !window.Swal) return;
        label.classList.remove('d-block');
        label.classList.add('d-none');
        var root = document.documentElement, theme = root.getAttribute('data-theme');
        var dark = theme === 'dark' || (!theme && window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches);
        window.Swal.fire({
            icon: 'success',
            title: '<%= HttpUtility.JavaScriptStringEncode(L.T("Coordinator.StudentCreation.CreatedSuccessTitle")) %>',
            text: label.textContent,
            confirmButtonText: '<%= HttpUtility.JavaScriptStringEncode(L.T("Coordinator.StudentCreation.CreatedSuccessDone")) %>',
            buttonsStyling: false,
            customClass: { confirmButton: 'btn btn-primary rounded-pill px-4' },
            background: dark ? '#1e2330' : undefined,
            color: dark ? '#e8eaf0' : undefined
        });
    }
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', celebrate);
    else celebrate();
}());
</script>
<% } %>
<script src="<%= ResolveUrl("~/Assets/js/account-creation-modal.js") %>" defer></script>
