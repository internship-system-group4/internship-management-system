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

                <h2 class="text-center mb-3">Change Password</h2>

                <!-- Shown when the user still has the temporary password -->
                <asp:Panel ID="pnlTemporary" runat="server" Visible="false" CssClass="alert alert-warning">
                    You are using a temporary password. Please choose a new password to continue.
                </asp:Panel>

                <!-- Error message from the server -->
                <asp:Label ID="lblError" runat="server" CssClass="alert alert-danger d-block" Visible="false"></asp:Label>

                <!-- Current password -->
                <div class="mb-3">
                    <label for="<%= txtCurrentPassword.ClientID %>" class="form-label">Current password</label>
                    <asp:TextBox ID="txtCurrentPassword" runat="server" TextMode="Password" CssClass="form-control"></asp:TextBox>
                </div>

                <!-- New password -->
                <div class="mb-3">
                    <label for="<%= txtNewPassword.ClientID %>" class="form-label">New password</label>
                    <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password" CssClass="form-control"></asp:TextBox>
                    <small class="text-muted">At least 6 characters.</small>
                </div>

                <!-- Confirm new password -->
                <div class="mb-3">
                    <label for="<%= txtConfirmPassword.ClientID %>" class="form-label">Confirm new password</label>
                    <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" CssClass="form-control"></asp:TextBox>
                </div>

                <small id="passwordError" class="text-danger d-block mb-2"></small>

                <asp:Button ID="btnChange" data-ui-action="save" data-loading-label="Changing password&#8230;" runat="server"
                    Text="Change Password"
                    CssClass="btn btn-primary w-100"
                    OnClientClick="return validatePasswords();"
                    OnClick="btnChange_Click" />

                <!-- Log out (for example, if this is not your account) -->
                <div class="text-center mt-3">
                    <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click">Log out</asp:LinkButton>
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
                error.textContent = "Please fill in all fields.";
                return false;
            }

            if (newPassword.length < 6) {
                error.textContent = "The new password must be at least 6 characters.";
                return false;
            }

            if (newPassword !== confirm) {
                error.textContent = "The new passwords do not match.";
                return false;
            }

            if (newPassword === current) {
                error.textContent = "The new password must be different from the current password.";
                return false;
            }

            return true;
        }
    </script>

</asp:Content>
