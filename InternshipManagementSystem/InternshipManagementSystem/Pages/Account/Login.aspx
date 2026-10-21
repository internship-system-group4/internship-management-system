<%@ Page Language="C#" MasterPageFile="~/Layout/Public.master"
    AutoEventWireup="true" CodeBehind="Login.aspx.cs"
    Inherits="InternshipManagementSystem.Pages.AccountArea.Login"
    Title="Login" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <style>
        .login-card {
            max-width: 450px;
            margin: auto;
            border-radius: 12px;
        }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

    <div class="container py-5">

        <div class="card login-card shadow-sm">
            <div class="card-body p-4">

                <h2 class="text-center mb-2">Login</h2>
                <p class="text-center text-muted mb-4">
                    Welcome to the Internship Management System
                </p>

                <!-- Server error -->
                <asp:Label ID="lblError" runat="server"
                    CssClass="alert alert-danger d-block"
                    Visible="false">
                </asp:Label>

                <!-- Email -->
                <div class="mb-3">
                    <label for="<%= txtEmail.ClientID %>"
                        class="form-label">Email</label>

                    <asp:TextBox ID="txtEmail" runat="server"
                        TextMode="Email"
                        CssClass="form-control"
                        placeholder="Enter your email">
                    </asp:TextBox>

                    <small id="emailError" class="text-danger"></small>
                </div>

                <!-- Password -->
                <div class="mb-3">
                    <label for="<%= txtPassword.ClientID %>"
                        class="form-label">Password</label>

                    <div class="input-group">
                        <asp:TextBox ID="txtPassword" runat="server"
                            TextMode="Password"
                            CssClass="form-control"
                            placeholder="Enter your password">
                        </asp:TextBox>

                        <button type="button"
                            class="btn btn-outline-secondary"
                            onclick="togglePassword()"
                            id="toggleButton">
                            Show
                        </button>
                    </div>

                    <small id="passwordError" class="text-danger"></small>
                </div>

                <!-- Forgot password -->
                <div class="text-end mb-3">
                    <asp:HyperLink ID="lnkForgotPassword"
                        runat="server"
                        NavigateUrl="~/Pages/Account/ForgotPassword.aspx">
                        Forgot password?
                    </asp:HyperLink>
                </div>

                <!-- Login button -->
                <asp:Button ID="btnLogin" runat="server"
                    Text="Login"
                    CssClass="btn btn-primary w-100"
                    OnClientClick="return validateLogin();"
                    OnClick="btnLogin_Click" />

            </div>
        </div>

    </div>

    <script>
        // Show or hide password
        function togglePassword() {
            var password = document.getElementById(
                '<%= txtPassword.ClientID %>'
            );

            var button = document.getElementById("toggleButton");

            if (password.type === "password") {
                password.type = "text";
                button.textContent = "Hide";
            } else {
                password.type = "password";
                button.textContent = "Show";
            }
        }

        // Validate login inputs
        function validateLogin() {
            var email = document.getElementById(
                '<%= txtEmail.ClientID %>'
            ).value.trim();

            var password = document.getElementById(
                '<%= txtPassword.ClientID %>'
            ).value;

            var emailError = document.getElementById("emailError");
            var passwordError = document.getElementById("passwordError");

            emailError.textContent = "";
            passwordError.textContent = "";

            var valid = true;

            if (email === "") {
                emailError.textContent = "Email is required.";
                valid = false;
            } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
                emailError.textContent = "Enter a valid email address.";
                valid = false;
            }

            if (password === "") {
                passwordError.textContent = "Password is required.";
                valid = false;
            }

            return valid;
        }
    </script>

</asp:Content>