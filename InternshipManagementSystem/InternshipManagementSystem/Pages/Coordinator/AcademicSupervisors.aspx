<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="AcademicSupervisors.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.AcademicSupervisors" Title="Academic Supervisors" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <h2 class="mb-4">Academic Supervisors</h2>
    <div class="card shadow-sm mb-4"><div class="card-body p-4">
        <h4 class="mb-3">Create academic supervisor</h4>
        <p class="text-muted">Share the login email and temporary password privately. The supervisor changes the password on first sign-in.</p>
        <asp:Label ID="lblCreateMessage" runat="server" Visible="false" role="alert" />
        <div class="row g-3">
            <div class="col-md-6"><label for="<%= txtFullName.ClientID %>" class="form-label">Full name</label><asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" MaxLength="120" /></div>
            <div class="col-md-6"><label for="<%= txtEmail.ClientID %>" class="form-label">Login email</label><asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" MaxLength="254" /></div>
            <div class="col-md-6"><label for="<%= txtPhone.ClientID %>" class="form-label">Phone (optional)</label><asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" TextMode="Phone" MaxLength="40" /></div>
            <div class="col-md-6"><label for="<%= txtDepartment.ClientID %>" class="form-label">Department</label><asp:TextBox ID="txtDepartment" runat="server" CssClass="form-control" MaxLength="120" /></div>
            <div class="col-md-6"><label for="<%= txtAcademicRank.ClientID %>" class="form-label">Academic rank (optional)</label><asp:TextBox ID="txtAcademicRank" runat="server" CssClass="form-control" MaxLength="80" /></div>
            <div class="col-md-6"><label for="<%= txtPassword.ClientID %>" class="form-label">Temporary password</label><asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" MaxLength="128" /></div>
            <div class="col-md-6"><label for="<%= txtConfirmPassword.ClientID %>" class="form-label">Confirm temporary password</label><asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-control" TextMode="Password" MaxLength="128" /></div>
            <div class="col-12"><asp:Button ID="btnCreate" runat="server" Text="Create supervisor" CssClass="btn btn-primary" OnClick="btnCreate_Click" /></div>
        </div>

    </div></div>
    <div class="card shadow-sm"><div class="card-body p-4">
        <h4 class="mb-3">Academic supervisor records</h4>
        <asp:Label ID="lblListMessage" runat="server" Visible="false" role="alert" />
        <div class="row g-2 mb-3">
            <div class="col-md-6"><label for="<%= txtSearch.ClientID %>" class="form-label">Search by name, email, department, or rank</label><asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" MaxLength="120" /></div>
            <div class="col-md-auto align-self-end"><asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-outline-primary" OnClick="btnSearch_Click" CausesValidation="false" /></div>
            <div class="col-md-auto align-self-end"><asp:Button ID="btnClearSearch" runat="server" Text="Clear" CssClass="btn btn-outline-secondary" OnClick="btnClearSearch_Click" CausesValidation="false" /></div>
        </div>
        <div class="table-responsive">
            <table class="table table-striped table-hover align-middle">
                <thead><tr><th scope="col">Name</th><th scope="col">Email</th><th scope="col">Department</th><th scope="col">Academic rank</th><th scope="col">Phone</th><th scope="col"></th></tr></thead>
                <tbody>
                    <asp:Repeater ID="rptSupervisors" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td><%#: Eval("FullName") %></td><td><%#: Eval("Email") %></td><td><%#: Eval("Department") %></td><td><%#: Eval("AcademicRank") %></td><td><%#: Eval("PhoneNumber") %></td>
                                <td><asp:LinkButton ID="btnEdit" runat="server" Text="Details / Edit" CssClass="btn btn-sm btn-outline-primary" CommandArgument='<%# Eval("Id") %>' OnClick="btnEdit_Click" CausesValidation="false" /></td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
        <asp:Label ID="lblNoSupervisors" runat="server" Visible="false" CssClass="text-muted" />

        <asp:Panel ID="pnlDetails" runat="server" Visible="false" CssClass="card mt-4">
            <div class="card-body">
                <h3 class="h5 mb-3">Supervisor details</h3>
                <asp:Label ID="lblDetailsMessage" runat="server" Visible="false" role="alert" />
                <p class="mb-1"><strong>Login email:</strong> <asp:Label ID="lblDetailsEmail" runat="server" /></p>
                <p class="mb-3"><strong>Assigned groups:</strong> <asp:Label ID="lblGroupCount" runat="server" /></p>
                <div class="row g-3">
                    <div class="col-md-6"><label for="<%= txtEditFullName.ClientID %>" class="form-label">Full name</label><asp:TextBox ID="txtEditFullName" runat="server" CssClass="form-control" MaxLength="120" /></div>
                    <div class="col-md-6"><label for="<%= txtEditPhone.ClientID %>" class="form-label">Phone (optional)</label><asp:TextBox ID="txtEditPhone" runat="server" CssClass="form-control" TextMode="Phone" MaxLength="40" /></div>
                    <div class="col-md-6"><label for="<%= txtEditDepartment.ClientID %>" class="form-label">Department</label><asp:TextBox ID="txtEditDepartment" runat="server" CssClass="form-control" MaxLength="120" /></div>
                    <div class="col-md-6"><label for="<%= txtEditAcademicRank.ClientID %>" class="form-label">Academic rank (optional)</label><asp:TextBox ID="txtEditAcademicRank" runat="server" CssClass="form-control" MaxLength="80" /></div>
                    <div class="col-12"><asp:Button ID="btnSaveDetails" runat="server" Text="Save changes" CssClass="btn btn-primary" OnClick="btnSaveDetails_Click" /></div>
                </div>
            </div>
        </asp:Panel>
    </div></div>
</asp:Content>
