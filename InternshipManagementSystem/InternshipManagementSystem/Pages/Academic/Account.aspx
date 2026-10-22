<%@ Page Title="My Account" Language="C#" MasterPageFile="~/Layout/Academic.master" AutoEventWireup="true" CodeBehind="Account.aspx.cs" Inherits="InternshipManagementSystem.Pages.Academic.Account" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <!-- No extra styles needed, relying on Figma shared styles -->
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <!-- Topbar -->
    <div class="uims-topbar mb-4">
        <h1 class="uims-page-title">Academic Supervisor Portal <span class="text-muted mx-2">></span> My account</h1>
    </div>

    <div class="row">
        <div class="col-lg-8">
            <!-- Account Form Card -->
            <div class="uims-card">
                <h3 style="color: var(--brand-dark); border-bottom: 1px solid var(--line); padding-bottom: 1rem; margin-bottom: 1.5rem;">
                    Profile Information
                </h3>
                
                <!-- Display Success/Error Messages -->
                <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="mb-4 p-3" style="border-radius: var(--radius); background-color: #e3f6ea; color: #1b6b3a; border-left: 4px solid #1b6b3a;">
                    <strong style="font-size: 0.9rem;"><asp:Literal ID="litMessage" runat="server"></asp:Literal></strong>
                </asp:Panel>

                <!-- Form Fields -->
                <div class="row">
                    <!-- Full Name -->
                    <div class="col-md-12 mb-3">
                        <label class="form-label" style="font-weight: 600; color: var(--ink);">Full Name</label>
                        <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" required="true"></asp:TextBox>
                    </div>

                    <!-- Email (Read-Only) -->
                    <div class="col-md-12 mb-3">
                        <label class="form-label" style="font-weight: 600; color: var(--ink);">Email Address</label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control bg-light" Enabled="false"></asp:TextBox>
                        <small class="text-muted mt-1 d-block">Your email address cannot be changed from this portal.</small>
                    </div>

                    <!-- Department -->
                    <div class="col-md-6 mb-3">
                        <label class="form-label" style="font-weight: 600; color: var(--ink);">Department</label>
                        <asp:TextBox ID="txtDepartment" runat="server" CssClass="form-control"></asp:TextBox>
                    </div>

                    <!-- Academic Rank -->
                    <div class="col-md-6 mb-4">
                        <label class="form-label" style="font-weight: 600; color: var(--ink);">Academic Rank</label>
                        <asp:TextBox ID="txtRank" runat="server" CssClass="form-control" placeholder="e.g. Assistant Professor"></asp:TextBox>
                    </div>
                </div>

                <!-- Submit Button -->
                <div class="text-end pt-3" style="border-top: 1px solid var(--line);">
                    <asp:Button ID="btnSaveChanges" runat="server" Text="Save changes" CssClass="btn btn-brand" OnClick="btnSaveChanges_Click" />
                </div>
            </div>
        </div>
        
        <!-- Side Info Card -->
        <div class="col-lg-4">
            <div class="uims-card" style="background-color: var(--canvas);">
                <h3 style="color: var(--brand-dark); font-size: 1rem;">Account Security</h3>
                <p class="text-muted" style="font-size: 0.85rem; line-height: 1.6;">
                    If you need to change your password, please use the "Forgot Password" link on the login page, or contact the University Internship Coordinator for assistance.
                </p>
            </div>
        </div>
    </div>

</asp:Content>