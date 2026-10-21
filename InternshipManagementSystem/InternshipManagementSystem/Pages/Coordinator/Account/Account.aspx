
<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master"
    AutoEventWireup="true"
    CodeBehind="Account.aspx.cs"
    Inherits="InternshipManagementSystem.Pages.CoordinatorArea.Account"
    Title="My Account" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <style>
        .ca-page {
            color: #143d61;
            font-family: "Segoe UI", Arial, sans-serif;
        }

        .ca-heading {
            margin-bottom: 22px;
        }

        .ca-heading h2 {
            font-size: 24px;
            font-weight: 700;
            margin: 0 0 6px;
        }

        .ca-heading p,
        .ca-card p {
            font-size: 13px;
            color: #66809a;
            margin: 0;
        }

        .ca-card {
            background: #fff;
            border: 1px solid #dbe5f1;
            border-radius: 9px;
            padding: 22px;
        }

        .ca-card h3 {
            font-size: 16px;
            font-weight: 700;
            margin: 0 0 5px;
        }

        .ca-card label {
            display: block;
            font-size: 12px;
            font-weight: 600;
            margin-bottom: 7px;
        }

        .ca-card .form-control {
            font-size: 13px;
            min-height: 40px;
            border: 1px solid #dce6f2;
            border-radius: 6px;
        }

        .ca-card .form-control:focus {
            border-color: #315d84;
            box-shadow: 0 0 0 .16rem rgba(37, 78, 116, .13);
        }

        .ca-readonly {
            background: #eaf1fc !important;
            color: #50627a;
        }

        .ca-status {
            border-radius: 16px;
            background: #e8f5ed;
            color: #27734c;
            font-size: 11px;
            font-weight: 700;
            padding: 5px 10px;
            white-space: nowrap;
        }

        .ca-footer {
            border-top: 1px solid #dce6f2;
            margin-top: 22px;
            padding-top: 19px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
        }

        .ca-footer small,
        .ca-field small {
            font-size: 11px;
            color: #69819c;
        }

        .ca-page .btn-primary {
            background: #254e75;
            border-color: #254e75;
        }

        .ca-page .btn-primary:hover {
            background: #173b5e;
            border-color: #173b5e;
        }

        .ca-page .btn-outline-primary {
            color: #254e75;
            border-color: #254e75;
        }

        .ca-page .btn {
            font-size: 12px;
            font-weight: 600;
            padding: 9px 15px;
        }

        .ca-field {
            margin-top: 17px;
        }

        .ca-field small {
            display: block;
            margin-top: 7px;
        }

        .ca-field + .btn {
            margin-top: 17px;
        }

        .ca-info {
            background: #e0edff;
            border-radius: 7px;
            margin-top: 15px;
            padding: 16px;
            display: flex;
            gap: 12px;
            font-size: 12px;
        }

        .ca-info span {
            font-size: 19px;
        }

        .ca-info strong {
            font-weight: 700;
        }

        .ca-info p {
            margin: 4px 0 0;
            color: #435971;
        }

        .ca-notice {
            display: block;
            padding: 11px 14px;
            border-radius: 6px;
            margin-bottom: 16px;
            font-size: 13px;
        }

        .ca-notice-error {
            background: #fff0f0;
            color: #a42121;
        }

        .ca-notice-success {
            background: #e8f6ef;
            color: #216d47;
        }

        .ca-error {
            font-size: 11px;
            color: #b42318;
            display: block;
            margin-top: 5px;
        }

        @media (max-width: 650px) {
            .ca-footer {
                align-items: stretch;
                flex-direction: column;
            }

            .ca-footer .d-flex {
                justify-content: flex-end;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="ca-page">

        <div class="ca-heading">
            <h2>Account settings</h2>
            <p>Manage your profile information and account security.</p>
        </div>

        <asp:Label ID="lblNotice" runat="server"
            EnableViewState="false" />

        <div class="row g-3">

            <!-- PROFILE INFORMATION -->
            <div class="col-lg-7">
                <section class="ca-card">

                    <div class="d-flex justify-content-between align-items-start gap-2">
                        <div>
                            <h3>Profile information</h3>
                            <p>Update your name and contact information.</p>
                        </div>

                        <asp:Label ID="lblStatus" runat="server"
                            CssClass="ca-status" />
                    </div>

                    <div class="row g-3 mt-1">

                        <div class="col-md-6">
                            <label for="<%= txtName.ClientID %>">Full name *</label>
                            <asp:TextBox ID="txtName" runat="server"
                                CssClass="form-control" MaxLength="100" />

                            <asp:RequiredFieldValidator
                                ID="valName"
                                runat="server"
                                ControlToValidate="txtName"
                                ValidationGroup="profile"
                                ErrorMessage="Full name is required."
                                CssClass="ca-error"
                                Display="Dynamic" />
                        </div>

                        <div class="col-md-6">
                            <label for="<%= txtPhone.ClientID %>">Phone number</label>
                            <asp:TextBox ID="txtPhone" runat="server"
                                CssClass="form-control"
                                MaxLength="25"
                                placeholder="Enter phone number" />
                        </div>

                        <div class="col-md-6">
                            <label>Email address</label>
                            <asp:TextBox ID="txtEmail" runat="server"
                                CssClass="form-control ca-readonly"
                                ReadOnly="true" />
                        </div>

                        <div class="col-md-6">
                            <label>Staff ID</label>
                            <asp:TextBox ID="txtStaffId" runat="server"
                                CssClass="form-control ca-readonly"
                                ReadOnly="true" />
                        </div>

                        <div class="col-md-6">
                            <label>University</label>
                            <asp:TextBox ID="txtUniversity" runat="server"
                                CssClass="form-control ca-readonly"
                                ReadOnly="true" />
                        </div>

                        <div class="col-md-6">
                            <label>College</label>
                            <asp:TextBox ID="txtCollege" runat="server"
                                CssClass="form-control ca-readonly"
                                ReadOnly="true" />
                        </div>

                    </div>

                    <div class="ca-footer">
                        <small>
                            University and role information are managed by the system.
                        </small>

                        <div class="d-flex gap-2">
                            <asp:Button ID="btnCancel" runat="server"
                                Text="Cancel"
                                CssClass="btn btn-outline-primary"
                                CausesValidation="false"
                                OnClick="btnCancel_Click" />

                            <asp:Button ID="btnSave" runat="server"
                                Text="Save changes"
                                CssClass="btn btn-primary"
                                ValidationGroup="profile"
                                OnClick="btnSave_Click" />
                        </div>
                    </div>

                </section>
            </div>

            <!-- CHANGE PASSWORD -->
            <div class="col-lg-5">

                <section class="ca-card">
                    <h3>Change password</h3>
                    <p>Enter your current password to set a new one.</p>

                    <div class="ca-field">
                        <label for="<%= txtCurrentPassword.ClientID %>">
                            Current password *
                        </label>

                        <asp:TextBox ID="txtCurrentPassword"
                            runat="server"
                            TextMode="Password"
                            CssClass="form-control"
                            autocomplete="current-password" />
                    </div>

                    <div class="ca-field">
                        <label for="<%= txtNewPassword.ClientID %>">
                            New password *
                        </label>

                        <asp:TextBox ID="txtNewPassword"
                            runat="server"
                            TextMode="Password"
                            CssClass="form-control"
                            autocomplete="new-password" />

                        <small>Use at least 8 characters.</small>
                    </div>

                    <div class="ca-field">
                        <label for="<%= txtConfirmPassword.ClientID %>">
                            Confirm new password *
                        </label>

                        <asp:TextBox ID="txtConfirmPassword"
                            runat="server"
                            TextMode="Password"
                            CssClass="form-control"
                            autocomplete="new-password" />
                    </div>

                    <asp:Button ID="btnChangePassword"
                        runat="server"
                        Text="Update password"
                        CssClass="btn btn-primary w-100"
                        CausesValidation="false"
                        OnClick="btnChangePassword_Click" />

                </section>

                <!-- ACCOUNT ADMINISTRATION -->
                <div class="ca-info">
                    <span>ⓘ</span>

                    <div>
                        <strong>Account administration</strong>
                        <p>
                            Create student and supervisor accounts with the Add
                            buttons on their management pages.
                        </p>
                    </div>
                </div>

            </div>
        </div>
    </div>
</asp:Content>


<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server">

    <script type="text/javascript">

        document.addEventListener("DOMContentLoaded", function () {

            // Password update button
            var button = document.querySelector(
                '[id$="btnChangePassword"]'
            );

            if (!button) return;

            button.addEventListener("click", function (event) {

                var current = document.querySelector(
                    '[id$="txtCurrentPassword"]'
                );

                var newPassword = document.querySelector(
                    '[id$="txtNewPassword"]'
                );

                var confirmPassword = document.querySelector(
                    '[id$="txtConfirmPassword"]'
                );

                if (!current || !newPassword || !confirmPassword) {
                    return;
                }

                var message = "";

                // Check empty fields
                if (
                    !current.value ||
                    !newPassword.value ||
                    !confirmPassword.value
                ) {
                    message = "Please complete all password fields.";
                }

                // Check password length
                else if (newPassword.value.length < 8) {
                    message = "Password must contain at least 8 characters.";
                }

                // Check maximum length
                else if (newPassword.value.length > 128) {
                    message = "Password must not exceed 128 characters.";
                }

                // Check password confirmation
                else if (newPassword.value !== confirmPassword.value) {
                    message = "New passwords do not match.";
                }

                // Check same password
                else if (current.value === newPassword.value) {
                    message = "New password must differ from current password.";
                }

                // Stop submission if invalid
                if (message !== "") {
                    event.preventDefault();
                    alert(message);
                    return false;
                }

            });

        });

    </script>

</asp:Content>


