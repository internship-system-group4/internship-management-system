<%@ Page Title="My Account" Language="C#" MasterPageFile="~/Layout/Academic.master" AutoEventWireup="true" CodeBehind="Account.aspx.cs" Inherits="InternshipManagementSystem.Pages.Academic.Account" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .cover-photo { background: linear-gradient(135deg, var(--th-bg-1e5a8c,#1e5a8c), var(--th-bg-0a3457,#0a3457)); height: 130px; border-start-start-radius: var(--radius); border-start-end-radius: var(--radius); }
        
        /* Profile Avatar with Edit Badge */
        .profile-avatar-wrapper { position: relative; width: 100px; height: 100px; margin-top: -50px; margin-inline-start: 2rem; margin-bottom: 1rem; }
        .profile-avatar { width: 100px; height: 100px; border-radius: 50%; background-color: var(--th-bg-e8f0f7,#e8f0f7); color: var(--brand-text,var(--brand-dark)); display: flex; align-items: center; justify-content: center; font-size: 2.5rem; font-weight: 700; border: 4px solid var(--surface); box-shadow: 0 4px 6px rgba(0,0,0,0.1); overflow: hidden; }
        .profile-avatar img { width: 100%; height: 100%; object-fit: cover; }
        .edit-badge { position: absolute; bottom: 0; inset-inline-end: 0; background-color: var(--brand); color: #fff; width: 32px; height: 32px; border-radius: 50%; display: flex; align-items: center; justify-content: center; border: 2px solid var(--th-line-ffffff,#fff); cursor: pointer; font-size: 0.9rem; box-shadow: 0 2px 4px rgba(0,0,0,0.2); }
        .edit-badge:hover { background-color: var(--brand-dark); }
        
        .section-icon { width: 36px; height: 36px; background-color: var(--th-bg-f1f5f9,#f1f5f9); color: var(--brand-text,var(--brand-dark)); border-radius: 8px; display: inline-flex; align-items: center; justify-content: center; margin-inline-end: 1rem; font-size: 1.2rem; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert mb-4">
        <asp:Literal ID="litMessage" runat="server"></asp:Literal>
    </asp:Panel>

    <!-- Top Profile Banner (Clean Professional Layout) -->
    <div class="uims-card p-0 mb-4" style="border: 1px solid var(--line); overflow: hidden;">
        <div class="cover-photo"></div>
        
        <!-- Avatar overlapping cover nicely -->
        <div class="profile-avatar-wrapper">
            <div class="profile-avatar">
                <% if (CurrentSupervisor != null && !string.IsNullOrEmpty(CurrentSupervisor.ProfileImageUrl) && CurrentSupervisor.ProfileImageUrl.StartsWith("~/Assets/Uploads/", System.StringComparison.Ordinal)) { %>
                <img src="<%: ResolveUrl(CurrentSupervisor.ProfileImageUrl) %>" alt="" />
                <% } else { %>
                <asp:Literal ID="litAvatarInitials" runat="server">Dr</asp:Literal>
                <% } %>
            </div>
            <!-- Clickable Pencil Icon -->
            <label for="<%= fuProfileImage.ClientID %>" class="edit-badge" title="<%: L.T("Academic.Account.ChangeProfilePhoto") %>">
                ✎
            </label>
            <!-- Hidden file upload triggered by pencil -->
            <asp:FileUpload ID="fuProfileImage" runat="server" style="display:none;" accept="image/jpeg,image/png" />
        </div>

        <!-- Supervisor Info placed cleanly BELOW the cover -->
        <div class="px-4 pb-4">
            <h2 class="mb-1" style="color: var(--brand-text,var(--brand-dark)); font-weight: 700; font-size: 1.4rem;">
                <%: L.T("Academic.Account.Dr") %> <asp:Literal ID="litProfileName" runat="server"></asp:Literal>
            </h2>
            <div class="text-muted" style="font-size: 0.9rem;">
                <asp:Literal ID="litProfileDept" runat="server" Text="<%$ Resources:Academic, Account.AcademicSupervisorPlaceholder %>" /> <%: L.T("Academic.Account.GermanJordanianUniversity") %>
            </div>
            <!-- Hidden upload button for backend handling if needed -->
            <asp:Button ID="btnUploadPhoto" runat="server" Text="<%$ Resources:Academic, Account.Upload %>" CssClass="d-none" CausesValidation="false" formnovalidate="true" data-ui-action="upload" data-loading-label="<%$ Resources:Shared, I18n.Uploading %>" data-ui-validation="none" />
        </div>
    </div>

    <!-- Section 1: Personal Information -->
    <div class="uims-card mb-4">
        <div class="d-flex align-items-center justify-content-between mb-4 pb-3" style="border-bottom: 1px solid var(--line);">
            <div class="d-flex align-items-center">
                <div class="section-icon">☺</div>
                <div>
                    <h3 class="mb-1" style="color: var(--brand-text,var(--brand-dark)); font-weight: 700; font-size: 1.1rem;"><%: L.T("Academic.Account.PersonalInformation") %></h3>
                    <div class="text-muted" style="font-size: 0.85rem;"><%: L.T("Academic.Account.UpdateYourPersonalAndContactInformation") %></div>
                </div>
            </div>
            <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-toggle="modal" data-bs-target="#passwordModal" style="font-weight: 600;">
                <%: L.T("Academic.Account.ChangePassword") %>
            </button>
        </div>

        <div class="row">
            <div class="col-md-6 mb-4">
                <label class="form-label" style="font-weight: 700; font-size: 0.9rem;"><%: L.T("Academic.Account.FullName") %></label>
                <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" style="background-color: var(--th-bg-f8fafc,#f8fafc);" Enabled="false"></asp:TextBox>
            </div>
            <div class="col-md-6 mb-4">
                <label class="form-label" style="font-weight: 700; font-size: 0.9rem;"><%: L.T("Academic.Account.AccountEmail") %></label>
                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" style="background-color: var(--th-bg-f8fafc,#f8fafc);" Enabled="false"></asp:TextBox>
            </div>
            <div class="col-md-6 mb-3">
                <label class="form-label" style="font-weight: 700; font-size: 0.9rem;"><%: L.T("Academic.Account.Age") %></label>
                <asp:TextBox ID="txtAge" runat="server" CssClass="form-control" type="number"></asp:TextBox>
            </div>
            <div class="col-md-6 mb-3">
                <label class="form-label" style="font-weight: 700; font-size: 0.9rem;"><%: L.T("Academic.Account.PhoneNumber") %></label>
                <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" placeholder="<%$ Resources:Academic, Account.9627XXXXXXXX %>"></asp:TextBox>
            </div>
        </div>
    </div>

    <!-- Section 2: Academic Information (READ-ONLY) -->
    <div class="uims-card mb-4">
        <div class="d-flex align-items-center mb-4 pb-3" style="border-bottom: 1px solid var(--line);">
            <div class="section-icon">🎓</div>
            <div>
                <h3 class="mb-1" style="color: var(--brand-text,var(--brand-dark)); font-weight: 700; font-size: 1.1rem;"><%: L.T("Academic.Account.AcademicInformation") %></h3>
                <div class="text-muted" style="font-size: 0.85rem;"><%: L.T("Academic.Account.YourOfficialUniversityDetailsManagedBy") %></div>
            </div>
        </div>
        <div class="row">
            <div class="col-md-6 mb-4">
                <label class="form-label" style="font-weight: 700; font-size: 0.9rem;"><%: L.T("Academic.Account.SupervisorID") %></label>
                <asp:TextBox ID="txtSupervisorId" runat="server" CssClass="form-control bg-light" Enabled="false"></asp:TextBox>
            </div>
            <div class="col-md-6 mb-4">
                <label class="form-label" style="font-weight: 700; font-size: 0.9rem;"><%: L.T("Academic.Account.University") %></label>
                <asp:TextBox ID="txtUniversity" runat="server" CssClass="form-control bg-light" Enabled="false"></asp:TextBox>
            </div>
            <div class="col-md-4 mb-3">
                <label class="form-label" style="font-weight: 700; font-size: 0.9rem;"><%: L.T("Academic.Account.College") %></label>
                <asp:TextBox ID="txtCollege" runat="server" CssClass="form-control bg-light" Enabled="false"></asp:TextBox>
            </div>
            <div class="col-md-4 mb-3">
                <label class="form-label" style="font-weight: 700; font-size: 0.9rem;"><%: L.T("Academic.Account.Major") %></label>
                <asp:TextBox ID="txtMajor" runat="server" CssClass="form-control bg-light" Enabled="false"></asp:TextBox>
            </div>
            <div class="col-md-4 mb-3">
                <label class="form-label" style="font-weight: 700; font-size: 0.9rem;"><%: L.T("Academic.Account.EnrollmentYear") %></label>
                <asp:TextBox ID="txtEnrollmentYear" runat="server" CssClass="form-control bg-light" Enabled="false"></asp:TextBox>
            </div>
        </div>
    </div>

    <div class="text-end mb-4">
        <asp:Button ID="btnSaveChanges" runat="server" Text="<%$ Resources:Academic, Account.SaveChanges %>" CssClass="btn btn-brand" style="padding: 0.5rem 1.5rem; font-weight: 600;" OnClick="btnSaveChanges_Click" CausesValidation="false" formnovalidate="true" data-ui-action="save" data-loading-label="<%$ Resources:Shared, I18n.Saving %>" data-ui-validation="none" />
    </div>

    <!-- Change Password Modal -->
    <div class="modal fade" id="passwordModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header" style="background-color: var(--brand-light);">
                    <h5 class="modal-title" style="color: var(--brand-text,var(--brand-dark)); font-weight: 700;"><%: L.T("Academic.Account.ChangePassword") %></h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="<%: L.T("Academic.Account.Close") %>"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label" style="font-weight: 600;"><%: L.T("Academic.Account.NewPassword") %></label>
                        <asp:TextBox ID="txtNewPassword" runat="server" CssClass="form-control" TextMode="Password" required="true"></asp:TextBox>
                    </div>
                    <div class="mb-3">
                        <label class="form-label" style="font-weight: 600;"><%: L.T("Academic.Account.ConfirmNewPassword") %></label>
                        <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-control" TextMode="Password" required="true"></asp:TextBox>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal"><%: L.T("Academic.Account.Cancel") %></button>
                    <asp:Button ID="btnSavePassword" runat="server" Text="<%$ Resources:Academic, Account.UpdatePassword %>" CssClass="btn btn-brand" OnClick="btnSavePassword_Click" CausesValidation="false" formnovalidate="true" data-ui-action="update" data-loading-label="<%$ Resources:Shared, I18n.Updating %>" data-ui-validation="none" />
                </div>
            </div>
        </div>
    </div>

</asp:Content>
