<%@ Page Language="C#"
    MasterPageFile="~/Layout/Coordinator.master"
    AutoEventWireup="true"
    CodeBehind="Account.aspx.cs"
    Inherits="InternshipManagementSystem.Pages.CoordinatorArea.Account"
    Title="My Account" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <style>
        .ca-page {
            color: var(--th-fg-143d61,#143d61);
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
            color: var(--th-fg-66809a,#66809a);
            margin: 0;
        }

        .ca-card {
            background: var(--ui-surface,#fff);
            border: 1px solid var(--th-line-dbe5f1,#dbe5f1);
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
            border: 1px solid var(--th-line-dce6f2,#dce6f2);
            border-radius: 6px;
        }

        .ca-card .form-control:focus {
            border-color: var(--th-line-315d84,#315d84);
            box-shadow: 0 0 0 .16rem rgba(37, 78, 116, .13);
        }

        .ca-readonly {
            background: var(--th-bg-eaf1fc,#eaf1fc) !important;
            color: var(--th-fg-50627a,#50627a);
        }

        .ca-status {
            border-radius: 16px;
            background: var(--th-bg-e8f5ed,#e8f5ed);
            color: var(--th-fg-27734c,#27734c);
            font-size: 11px;
            font-weight: 700;
            padding: 5px 10px;
            white-space: nowrap;
        }

        .ca-footer {
            border-top: 1px solid var(--th-line-dce6f2,#dce6f2);
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
            color: var(--th-fg-69819c,#69819c);
        }

        .ca-page .btn-primary {
            background: var(--th-bg-254e75,#254e75);
            border-color: var(--th-line-254e75,#254e75);
           
        }
        
/* Space above Update Password button */
.ca-page .password-update-btn {
    margin-top: 15px !important;
}

        .ca-page .btn-primary:hover {
            background: var(--th-bg-173b5e,#173b5e);
            border-color: var(--th-line-173b5e,#173b5e);
        }

        .ca-page .btn-outline-primary {
            color: var(--th-fg-254e75,#254e75);
            border-color: var(--th-line-254e75,#254e75);
            
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
            background: var(--th-bg-e0edff,#e0edff);
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
            color: var(--th-fg-435971,#435971);
        }

        .ca-notice {
            display: block;
            padding: 11px 14px;
            border-radius: 6px;
            margin-bottom: 16px;
            font-size: 13px;
        }

        .ca-notice-error {
            background: var(--th-bg-fff0f0,#fff0f0);
            color: var(--th-fg-a42121,#a42121);
        }

        .ca-notice-success {
            background: var(--th-bg-e8f6ef,#e8f6ef);
            color: var(--th-fg-216d47,#216d47);
        }

        .ca-error {
            font-size: 11px;
            color: var(--th-fg-b42318,#b42318);
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
            <h2><%: L.T("Coordinator.Account.AccountSettings") %></h2>
            <p><%: L.T("Coordinator.Account.ManageYourProfileInformationAndAccount") %></p>
        </div>

        <asp:Label ID="lblNotice" runat="server"
            EnableViewState="false" />

        <div class="row g-3">

            <!-- PROFILE INFORMATION -->
            <div class="col-lg-7">
                <section class="ca-card">

                    <div class="d-flex justify-content-between align-items-start gap-2">
                        <div>
                            <h3><%: L.T("Coordinator.Account.ProfileInformation") %></h3>
                            <p><%: L.T("Coordinator.Account.UpdateYourNameAndContactInformation") %></p>
                        </div>

                        <asp:Label ID="lblStatus" runat="server"
                            CssClass="ca-status" />
                    </div>

                    <div class="row g-3 mt-1">

                        <div class="col-md-6">
                            <label for="<%= txtName.ClientID %>"><%: L.T("Coordinator.Account.FullName") %></label>
                            <asp:TextBox ID="txtName" runat="server"
                                CssClass="form-control" MaxLength="100" />

                            <asp:RequiredFieldValidator
                                ID="valName"
                                runat="server"
                                ControlToValidate="txtName"
                                ValidationGroup="profile"
                                ErrorMessage="<%$ Resources:Coordinator, Account.FullNameIsRequired %>"
                                CssClass="ca-error"
                                Display="Dynamic" />
                        </div>

                        <div class="col-md-6">
                            <label for="<%= txtPhone.ClientID %>"><%: L.T("Coordinator.Account.PhoneNumber") %></label>
                            <asp:TextBox ID="txtPhone" runat="server"
                                CssClass="form-control"
                                MaxLength="25"
                                placeholder="<%$ Resources:Coordinator, Account.EnterPhoneNumber %>" />
                        </div>

                        <div class="col-md-6">
                            <label><%: L.T("Coordinator.Account.EmailAddress") %></label>
                            <asp:TextBox ID="txtEmail" runat="server"
                                CssClass="form-control ca-readonly"
                                ReadOnly="true" />
                        </div>

                        <div class="col-md-6">
                            <label><%: L.T("Coordinator.Account.StaffID") %></label>
                            <asp:TextBox ID="txtStaffId" runat="server"
                                CssClass="form-control ca-readonly"
                                ReadOnly="true" />
                        </div>

                        <div class="col-md-6">
                            <label><%: L.T("Coordinator.Account.University") %></label>
                            <asp:TextBox ID="txtUniversity" runat="server"
                                CssClass="form-control ca-readonly"
                                ReadOnly="true" />
                        </div>

                        <div class="col-md-6">
                            <label><%: L.T("Coordinator.Account.College") %></label>
                            <asp:TextBox ID="txtCollege" runat="server"
                                CssClass="form-control ca-readonly"
                                ReadOnly="true" />
                        </div>

                    </div>

                    <div class="ca-footer">
                        <small>
                            <%: L.T("Coordinator.Account.UniversityAndRoleInformationAreManaged") %>
                        </small>

                        <div class="d-flex gap-2">
                            <asp:Button ID="btnCancel" runat="server"
                                Text="<%$ Resources:Coordinator, Account.Cancel %>"
                                CssClass="btn btn-outline-primary"
                                CausesValidation="false"
                                OnClick="btnCancel_Click" />

                            <asp:Button ID="btnSave" runat="server"
                                Text="<%$ Resources:Coordinator, Account.SaveChanges %>"
                                CssClass="btn btn-primary"
                                ValidationGroup="profile"
                                OnClick="btnSave_Click"  data-ui-action="save" data-loading-label="Saving…"/>
                        </div>
                    </div>

                </section>
            </div>

            <!-- CHANGE PASSWORD -->
            <div class="col-lg-5">

                <section class="ca-card">
                    <h3><%: L.T("Coordinator.Account.ChangePassword") %></h3>
                    <p><%: L.T("Coordinator.Account.EnterYourCurrentPasswordToSet") %></p>

                    <div class="ca-field">
                        <label for="<%= txtCurrentPassword.ClientID %>">
                            <%: L.T("Coordinator.Account.CurrentPassword") %>
                        </label>

                        <asp:TextBox ID="txtCurrentPassword"
                            runat="server"
                            TextMode="Password"
                            CssClass="form-control"
                            autocomplete="current-password" />
                    </div>

                    <div class="ca-field">
                        <label for="<%= txtNewPassword.ClientID %>">
                            <%: L.T("Coordinator.Account.NewPassword") %>
                        </label>

                        <asp:TextBox ID="txtNewPassword"
                            runat="server"
                            TextMode="Password"
                            CssClass="form-control"
                            autocomplete="new-password" />

                        <small><%: L.T("Coordinator.Account.UseAtLeast8Characters") %></small>
                    </div>

                    <div class="ca-field">
                        <label for="<%= txtConfirmPassword.ClientID %>">
                            <%: L.T("Coordinator.Account.ConfirmNewPassword") %>
                        </label>

                        <asp:TextBox ID="txtConfirmPassword"
                            runat="server"
                            TextMode="Password"
                            CssClass="form-control"
                            autocomplete="new-password" />
                    </div>

                    <asp:Button ID="btnChangePassword"
                        runat="server"
                        Text="<%$ Resources:Coordinator, Account.UpdatePassword %>"
                        CssClass="btn btn-primary password-update-btn"
                        CausesValidation="false"
                        OnClick="btnChangePassword_Click"  data-ui-action="update" data-loading-label="Updating…" data-ui-validation="none"/>

                </section>

                

            </div>
        </div>
    </div>
</asp:Content>



<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server">

<script type="text/javascript">

    document.addEventListener("DOMContentLoaded", function () {

        var buttonId = "<%= btnChangePassword.ClientID %>";
        var currentId = "<%= txtCurrentPassword.ClientID %>";
        var newId = "<%= txtNewPassword.ClientID %>";
        var confirmId = "<%= txtConfirmPassword.ClientID %>";

        var button = document.getElementById(buttonId);

        if (button === null) {
            return;
        }

        button.addEventListener("click", function (event) {

            // Get current input values directly by ID.
            // No nullable Element variables or implicit any parameters.

            var currentInput = document.querySelector(
                "input[id='" + currentId + "']"
            );

            var newInput = document.querySelector(
                "input[id='" + newId + "']"
            );

            var confirmInput = document.querySelector(
                "input[id='" + confirmId + "']"
            );

            if (
                currentInput === null ||
                newInput === null ||
                confirmInput === null
            ) {
                event.preventDefault();
                alert(window.uimsT('PwFieldsMissing'));
                return;
            }

            // HTMLInputElement type assertions for Visual Studio.
            var currentValue =
                /** @type {HTMLInputElement} */ (currentInput).value;

            var newValue =
                /** @type {HTMLInputElement} */ (newInput).value;

            var confirmValue =
                /** @type {HTMLInputElement} */ (confirmInput).value;

            var message = "";

            if (!currentValue || !newValue || !confirmValue) {
                message = window.uimsT('PwCompleteAll');
            }
            else if (newValue.length < 8 || newValue.length > 128) {
                message = "Password must contain 8 to 128 characters.";
            }
            else if (newValue !== confirmValue) {
                message = window.uimsT('PwNewMismatch');
            }
            else if (currentValue === newValue) {
                message = window.uimsT('PwChooseDifferent');
            }

            if (message !== "") {
                event.preventDefault();
                alert(message);
            }

        });

    });

</script>

</asp:Content>

