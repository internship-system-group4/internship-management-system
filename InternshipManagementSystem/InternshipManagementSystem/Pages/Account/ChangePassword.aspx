<%@ Page Language="C#" MasterPageFile="~/Layout/Public.master" AutoEventWireup="true" CodeBehind="ChangePassword.aspx.cs" Inherits="InternshipManagementSystem.Pages.AccountArea.ChangePassword" Title="Change Password" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <style>
        .password-card {
            max-width: 450px;
            margin: auto;
            border-radius: 12px;
        }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

    <%-- Change Password - Owner: Ahmad - Card: A04 --%>

    <div class="container py-5">

        <div class="card password-card shadow-sm">
            <div class="card-body p-4">

                <h2 class="text-center mb-3"><%: L.T("Account.ChangePassword.ChangePassword") %></h2>

                <!-- Shown when the user still has the temporary password -->
                <asp:Panel ID="pnlTemporary" runat="server" Visible="false" CssClass="alert alert-warning">
                    <%: L.T("Account.ChangePassword.YouAreUsingATemporaryPassword") %>
                </asp:Panel>

                <!-- Error message from the server -->
                <asp:Label ID="lblError" runat="server" CssClass="alert alert-danger d-block" Visible="false"></asp:Label>

                <!-- Current password -->
                <div class="mb-3">
                    <label for="<%= txtCurrentPassword.ClientID %>" class="form-label"><%: L.T("Account.ChangePassword.CurrentPassword") %></label>
                    <asp:TextBox ID="txtCurrentPassword" runat="server" TextMode="Password" CssClass="form-control"></asp:TextBox>
                </div>

                <!-- New password -->
                <div class="mb-3">
                    <label for="<%= txtNewPassword.ClientID %>" class="form-label"><%: L.T("Account.ChangePassword.NewPassword") %></label>
                    <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password" CssClass="form-control"></asp:TextBox>
                    <small class="text-muted"><%: L.T("Account.ChangePassword.AtLeast6Characters") %></small>
                </div>

                <!-- Confirm new password -->
                <div class="mb-3">
                    <label for="<%= txtConfirmPassword.ClientID %>" class="form-label"><%: L.T("Account.ChangePassword.ConfirmNewPassword") %></label>
                    <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" CssClass="form-control"></asp:TextBox>
                </div>

                <small id="passwordError" class="text-danger d-block mb-2"></small>

                <asp:Button ID="btnChange" data-ui-action="save" data-loading-label="<%$ Resources:Shared, I18n.Changingpassword %>" runat="server"
                    Text="<%$ Resources:Account, ChangePassword.ChangePassword %>"
                    CssClass="btn btn-primary w-100"
                    OnClientClick="return validatePasswords();"
                    OnClick="btnChange_Click" />

                <!-- Log out (for example, if this is not your account) -->
                <div class="text-center mt-3">
                    <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" Text="<%$ Resources:Shared, Portal.LogOut %>" />
                </div>

            </div>
        </div>

    </div>

    <script>
        // Check the passwords before sending them to the server
        function validatePasswords() {
            var current = document.getElementById('<%= txtCurrentPassword.ClientID %>').value;
            var newPassword = document.getElementById('<%= txtNewPassword.ClientID %>').value;
            var confirm = document.getElementById('<%= txtConfirmPassword.ClientID %>').value;
            var error = document.getElementById("passwordError");

            error.textContent = "";

            if (current === "" || newPassword === "" || confirm === "") {
                error.textContent = window.uimsT('PwFillAll');
                return false;
            }

            if (newPassword.length < 6) {
                error.textContent = window.uimsT('PwMin6');
                return false;
            }

            if (newPassword !== confirm) {
                error.textContent = window.uimsT('PwMismatch');
                return false;
            }

            if (newPassword === current) {
                error.textContent = window.uimsT('PwDifferent');
                return false;
            }

            return true;
        }
    </script>

</asp:Content>
