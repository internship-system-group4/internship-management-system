<%@ Page Language="C#" MasterPageFile="~/Layout/Public.master" AutoEventWireup="true" CodeBehind="ForgotPassword.aspx.cs" Inherits="InternshipManagementSystem.Pages.AccountArea.ForgotPassword" Title="Password Recovery" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <style>
        .forgot-card {
            max-width: 450px;
            margin: auto;
            border-radius: 12px;
        }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

    <%-- Password Recovery - Owner: Ahmad - Card: A03 --%>

    <div class="container py-5">

        <div class="card forgot-card shadow-sm">
            <div class="card-body p-4">

                <h2 class="text-center mb-2">Forgot Password</h2>
                <p class="text-center text-muted mb-4">
                    Enter your email and we will send you a link to reset your password.
                </p>

                <!-- Success or error message from the server -->
                <asp:Label ID="lblMessage" runat="server" Visible="false"></asp:Label>

                <!-- Email -->
                <div class="mb-3">
                    <label for="<%= txtEmail.ClientID %>" class="form-label">Email</label>

                    <asp:TextBox ID="txtEmail" runat="server"
                        TextMode="Email"
                        CssClass="form-control"
                        placeholder="Enter your email">
                    </asp:TextBox>

                    <small id="emailError" class="text-danger"></small>
                </div>

                <!-- Send button -->
                <asp:Button ID="btnSend" runat="server"
                    Text="Send Reset Link"
                    CssClass="btn btn-primary w-100"
                    OnClientClick="return validateEmail();"
                    OnClick="btnSend_Click" />

                <!-- Back to login -->
                <div class="text-center mt-3">
                    <a href="<%: ResolveUrl("~/Pages/Account/Login.aspx") %>">Back to Login</a>
                </div>

            </div>
        </div>

    </div>

    <script>
        // Check the email before sending it to the server
        function validateEmail() {
            var email = document.getElementById('<%= txtEmail.ClientID %>').value.trim();
            var emailError = document.getElementById("emailError");

            emailError.textContent = "";

            if (email === "") {
                emailError.textContent = "Email is required.";
                return false;
            }

            if (!/^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(email)) {
                emailError.textContent = "Enter a valid email address.";
                return false;
            }

            return true;
        }
    </script>

</asp:Content>
