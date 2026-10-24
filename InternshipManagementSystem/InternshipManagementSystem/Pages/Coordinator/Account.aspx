
<%@ Page Language="C#"
    MasterPageFile="~/Layout/Coordinator.master"
    AutoEventWireup="true"
    CodeBehind="Account.aspx.cs"
    Inherits="InternshipManagementSystem.Pages.CoordinatorArea.Account"
    Title="My Account" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">

<style>

/* ==============================
   PAGE
============================== */

.ca-page {
    max-width: 1395px;
    margin: 40px auto 65px;
    font-family: 'Segoe UI', Arial, sans-serif;
    color: #123f65;
}

.ca-heading {
    border-bottom: 1px solid #dce3ed;
    padding-bottom: 17px;
    margin-bottom: 22px;
}

.ca-heading h2 {
    font-size: 40px;
    font-weight: 700;
    margin: 0 0 5px;
    color: #073e69;
}

.ca-heading p {
    font-size: 17px;
    color: #58708d;
    margin: 0;
}

/* ==============================
   PROFILE CARD
============================== */

.ca-profile {
    background: #fff;
    border-radius: 20px;
    overflow: hidden;
    box-shadow: 0 7px 25px rgba(29,55,89,.05);
}

.ca-banner {
    height: 142px;
    background: linear-gradient(110deg,#2a5276,#2b455f);
    position: relative;
}

.ca-edit {
    position: absolute;
    right: 16px;
    top: 16px;
    background: #fff;
    border: 1px solid #dce6f0;
    border-radius: 7px;
    color: #164b78;
    font-size: 16px;
    font-weight: 650;
    padding: 12px 20px;
    cursor: pointer;
    transition: .2s;
}

.ca-edit:hover {
    background: #eef5fb;
    transform: translateY(-2px);
}

.ca-profile-body {
    padding: 0 45px 65px;
}

.ca-avatar {
    width: 132px;
    height: 132px;
    border: 4px solid #fff;
    border-radius: 50%;
    background: #e7eff7;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 39px;
    font-weight: 700;
    color: #2b5274;
    margin: -66px auto 14px;
    position: relative;
    box-shadow: 0 6px 15px rgba(23,63,98,.09);
}

.ca-identity {
    text-align: center;
    margin-bottom: 22px;
}

.ca-identity h3 {
    font-size: 24px;
    margin: 0 0 6px;
    font-weight: 700;
}

.ca-role {
    display: inline-block;
    background: #e9edf1;
    color: #174b79;
    padding: 6px 17px;
    border-radius: 22px;
    font-size: 12px;
    font-weight: 700;
}

.ca-status {
    display: inline-block;
    background: #e8f5ed;
    color: #27734c;
    border-radius: 16px;
    padding: 5px 10px;
    font-size: 11px;
    font-weight: 700;
    margin-top: 12px;
}

/* ==============================
   INFORMATION GRID
============================== */

.ca-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 23px;
}

.ca-info-box {
    border: 1px solid #dce4ec;
    border-radius: 12px;
    background: #f7f9fc;
    padding: 20px 26px;
    min-height: 94px;
    box-sizing: border-box;
}

.ca-info-box label {
    display: block;
    color: #667b91;
    font-size: 11px;
    font-weight: 750;
    letter-spacing: .5px;
    text-transform: uppercase;
    margin-bottom: 10px;
}

.ca-info-value {
    color: #071d35;
    font-size: 16px;
    font-weight: 600;
    overflow-wrap: anywhere;
}

.ca-info-value svg {
    width: 18px;
    height: 18px;
    stroke: #28577e;
    stroke-width: 1.8;
    fill: none;
    vertical-align: middle;
    margin-right: 9px;
}

/* ==============================
   PASSWORD CARD
============================== */

.ca-password-box {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 12px;
}

.ca-password-icon {
    margin-right: 7px;
    font-size: 17px;
}

.ca-password-change {
    background: #ffffff;
    border: 1px solid #c8d7e6;
    color: #254e75;
    font-size: 13px;
    font-weight: 700;
    padding: 10px 17px;
    border-radius: 8px;
    cursor: pointer;
    transition: .2s ease;
    white-space: nowrap;
}

.ca-password-change:hover {
    background: #254e75;
    color: #ffffff;
    border-color: #254e75;
    transform: translateY(-2px);
}

/* ==============================
   POPUP OVERLAY
============================== */

.ca-edit-area {
    position: fixed;
    inset: 0;
    z-index: 99999;
    display: none;
    align-items: center;
    justify-content: center;
    background: rgba(9,28,48,.55);
    backdrop-filter: blur(6px);
    padding: 20px;
    margin: 0;
    box-sizing: border-box;
}

.ca-edit-area.ca-open {
    display: flex;
}

/* ==============================
   POPUP MODAL
============================== */

.ca-modal {
    position: relative;
    background: #fff;
    width: 100%;
    max-width: 500px;
    padding: 34px;
    border-radius: 18px;
    box-shadow: 0 24px 70px rgba(10,35,60,.25);
    animation: caModalIn .3s ease;
    max-height: 90vh;
    overflow-y: auto;
}

@keyframes caModalIn {
    from {
        opacity: 0;
        transform: translateY(22px) scale(.96);
    }
    to {
        opacity: 1;
        transform: translateY(0) scale(1);
    }
}

.ca-modal-close {
    position: absolute;
    top: 18px;
    right: 20px;
    border: none;
    background: #edf2f7;
    color: #315572;
    width: 34px;
    height: 34px;
    border-radius: 9px;
    font-size: 22px;
    cursor: pointer;
}

.ca-modal-close:hover {
    background: #dfeaf4;
}

.ca-modal-icon {
    width: 52px;
    height: 52px;
    border-radius: 14px;
    background: #e9f1fa;
    color: #254e75;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 25px;
    margin-bottom: 18px;
}

.ca-modal h3 {
    font-size: 23px;
    font-weight: 700;
    color: #123f65;
    margin: 0 0 7px;
}

.ca-modal p {
    color: #718399;
    font-size: 14px;
    margin: 0 0 26px;
}

/* ==============================
   FORM FIELDS
============================== */

.ca-modal .ca-field {
    margin-bottom: 20px;
}

.ca-modal .ca-field label {
    display: block;
    font-size: 13px;
    font-weight: 650;
    color: #294760;
    margin-bottom: 9px;
}

.ca-page .form-control {
    width: 100%;
    min-height: 46px;
    border: 1px solid #dbe4ef;
    border-radius: 9px;
    padding: 10px 14px;
    background: #f8fafc;
    font-size: 14px;
    box-sizing: border-box;
}

.ca-page .form-control:focus {
    background: #fff;
    border-color: #315d84;
    box-shadow: 0 0 0 3px rgba(49,93,132,.12);
    outline: none;
}

.ca-password-hint {
    display: block;
    color: #788ba0;
    font-size: 11px;
    margin-top: 7px;
}

/* ==============================
   BUTTONS
============================== */

.ca-modal-actions {
    display: flex;
    justify-content: flex-end;
    gap: 12px;
    padding-top: 20px;
    margin-top: 10px;
    border-top: 1px solid #e5ebf2;
}

.ca-page .btn {
    font-size: 13px;
    font-weight: 650;
    padding: 11px 20px;
    border-radius: 8px;
    cursor: pointer;
}

.ca-page .btn-primary {
    background: #254e75;
    border: 1px solid #254e75;
    color: #fff;
}

.ca-page .btn-primary:hover {
    background: #173b5e;
    border-color: #173b5e;
}

.ca-page .btn-outline-primary {
    background: #fff;
    border: 1px solid #254e75;
    color: #254e75;
}

.ca-page .btn-outline-primary:hover {
    background: #eef5fb;
    color: #254e75;
}

body.ca-modal-active {
    overflow: hidden;
}

/* ==============================
   NOTIFICATIONS
============================== */

.ca-notice {
    display: block;
    margin-bottom: 16px;
    padding: 12px;
    border-radius: 7px;
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
    display: block;
    color: #b42318;
    font-size: 11px;
    margin-top: 5px;
}

/* ==============================
   RESPONSIVE
============================== */

@media (max-width: 760px) {

    .ca-page {
        margin: 20px 12px;
    }

    .ca-heading h2 {
        font-size: 30px;
    }

    .ca-profile-body {
        padding: 0 20px 30px;
    }

    .ca-grid {
        grid-template-columns: 1fr;
        gap: 14px;
    }

    .ca-edit {
        font-size: 13px;
        padding: 10px;
    }

    .ca-modal {
        padding: 25px 20px;
    }
}

@media (max-width: 480px) {

    .ca-password-box {
        flex-wrap: wrap;
    }

    .ca-modal-actions {
        flex-wrap: wrap;
    }
}

@media (prefers-reduced-motion: reduce) {
    .ca-modal {
        animation: none;
    }
}

</style>

</asp:Content>


<asp:Content ID="Body"
    ContentPlaceHolderID="MainContent"
    runat="server">

<div class="ca-page">

    <!-- PAGE HEADING -->

    <div class="ca-heading">
        <h2>My Account</h2>
        <p>
            Manage your personal profile and view your system associations.
        </p>
    </div>

    <asp:Label
        ID="lblNotice"
        runat="server"
        EnableViewState="false" />

    <!-- PROFILE CARD -->

    <section class="ca-profile">

        <div class="ca-banner">

            <button
                type="button"
                class="ca-edit"
                onclick="caOpenEdit()">
                &#9998; &nbsp; Edit Profile
            </button>

        </div>

        <div class="ca-profile-body">

            <!-- AVATAR -->

            <div class="ca-avatar" id="caAvatar">
                --
            </div>

            <!-- PROFILE NAME -->

            <div class="ca-identity">

                <h3 id="caDisplayName">
                    My Profile
                </h3>

                <span class="ca-role">
                    University Coordinator
                </span>

                <div>
                    <asp:Label
                        ID="lblStatus"
                        runat="server"
                        CssClass="ca-status" />
                </div>

            </div>

            <!-- INFORMATION GRID -->

            <div class="ca-grid">

                <!-- EMAIL -->

                <div class="ca-info-box">

                    <label>
                        EMAIL ADDRESS (READ-ONLY)
                    </label>

                    <div class="ca-info-value">

                        <svg viewBox="0 0 24 24">
                            <rect x="3" y="5" width="18" height="14" rx="2"/>
                            <path d="m3 7 9 6 9-6"/>
                        </svg>

                        <span id="caDisplayEmail"></span>

                    </div>

                </div>

                <!-- UNIVERSITY -->

                <div class="ca-info-box">

                    <label>
                        UNIVERSITY (READ-ONLY)
                    </label>

                    <div class="ca-info-value">

                        <svg viewBox="0 0 24 24">
                            <path d="M3 21V7l9-4 9 4v14"/>
                            <path d="M9 21v-7h6v7"/>
                            <path d="M7 9h2M15 9h2"/>
                        </svg>

                        <span id="caDisplayUniversity"></span>

                    </div>

                </div>

                <!-- PHONE -->

                <div class="ca-info-box">

                    <label>
                        PHONE NUMBER
                    </label>

                    <div class="ca-info-value">

                        <svg viewBox="0 0 24 24">
                            <path d="M22 16.9v3a2 2 0 0 1-2.2 2
                                19.8 19.8 0 0 1-8.6-3.1
                                19.5 19.5 0 0 1-6-6
                                19.8 19.8 0 0 1-3.1-8.7
                                A2 2 0 0 1 4.1 2h3
                                a2 2 0 0 1 2 1.7
                                l.5 3a2 2 0 0 1-.6 1.7L7.1 10
                                a16 16 0 0 0 6 6l1.6-1.9
                                a2 2 0 0 1 1.7-.6l3 .5
                                a2 2 0 0 1 1.6 2.9z"/>
                        </svg>

                        <span id="caDisplayPhone"></span>

                    </div>

                </div>

                <!-- COLLEGE -->

                <div class="ca-info-box">

                    <label>
                        COLLEGE
                    </label>

                    <div class="ca-info-value">

                        <svg viewBox="0 0 24 24">
                            <rect x="3" y="7" width="18" height="14" rx="2"/>
                            <path d="M8 7V5a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>
                            <path d="M3 12h18"/>
                        </svg>

                        <span id="caDisplayCollege"></span>

                    </div>

                </div>

                <!-- STAFF ID -->

                <div class="ca-info-box">

                    <label>
                        STAFF ID (READ-ONLY)
                    </label>

                    <div class="ca-info-value">
                        <span id="caDisplayStaff"></span>
                    </div>

                </div>

                <!-- PASSWORD CARD -->

                <div class="ca-info-box ca-password-box">

                    <div>

                        <label>
                            ACCOUNT SECURITY
                        </label>

                        <div class="ca-info-value">

                            <span class="ca-password-icon">
                                &#128274;
                            </span>

                            Password

                        </div>

                    </div>

                    <button
                        type="button"
                        class="ca-password-change"
                        onclick="caOpenPassword()">
                        Change
                    </button>

                </div>

            </div>

        </div>

    </section>


    <!-- ==========================================
         EDIT PROFILE POPUP
    ========================================== -->

    <div id="caEditArea"
         class="ca-edit-area"
         role="dialog"
         aria-modal="true"
         aria-labelledby="caModalTitle"
         onclick="caOverlayClick(event)">

        <div class="ca-modal">

            <button
                type="button"
                class="ca-modal-close"
                aria-label="Close"
                onclick="caCloseEdit()">
                &times;
            </button>

            <div class="ca-modal-icon">
                &#9998;
            </div>

            <h3 id="caModalTitle">
                Edit Profile
            </h3>

            <p>
                Update your personal information below.
            </p>

            <!-- FULL NAME -->

            <div class="ca-field">

                <label for="<%= txtName.ClientID %>">
                    Full Name
                </label>

                <asp:TextBox
                    ID="txtName"
                    runat="server"
                    CssClass="form-control"
                    MaxLength="100" />

                <asp:RequiredFieldValidator
                    ID="valName"
                    runat="server"
                    ControlToValidate="txtName"
                    ValidationGroup="profile"
                    ErrorMessage="<%$ Resources:Coordinator, Account.FullNameIsRequired %>"
                    CssClass="ca-error"
                    Display="Dynamic" />

            </div>

            <!-- PHONE NUMBER -->

            <div class="ca-field">

                <label for="<%= txtPhone.ClientID %>">
                    Phone Number
                </label>

                <asp:TextBox
                    ID="txtPhone"
                    runat="server"
                    CssClass="form-control"
                    MaxLength="25"
                    placeholder="<%$ Resources:Coordinator, Account.EnterPhoneNumber %>" />

            </div>

            <!-- EXISTING BACKEND FIELDS -->

            <div style="display:none;">

                <asp:TextBox
                    ID="txtEmail"
                    runat="server"
                    ReadOnly="true" />

                <asp:TextBox
                    ID="txtStaffId"
                    runat="server"
                    ReadOnly="true" />

                <asp:TextBox
                    ID="txtUniversity"
                    runat="server"
                    ReadOnly="true" />

                <asp:TextBox
                    ID="txtCollege"
                    runat="server"
                    ReadOnly="true" />

            </div>

            <!-- BUTTONS -->

            <div class="ca-modal-actions">

                <button
                    type="button"
                    class="btn btn-outline-primary"
                    onclick="caCloseEdit()">
                    Cancel
                </button>

                <asp:Button
                    ID="btnSave"
                    runat="server"
                    Text="<%$ Resources:Coordinator, Account.SaveChanges %>"
                    CssClass="btn btn-primary"
                    ValidationGroup="profile"
                    OnClick="btnSave_Click"
                    OnClientClick="return caValidateProfile();"
                    data-ui-action="save"
                    data-loading-label="Saving..." />

            </div>

            <!-- PRESERVE SERVER CONTROL -->

            <asp:Button
                ID="btnCancel"
                runat="server"
                Text="<%$ Resources:Coordinator, Account.Cancel %>"
                CausesValidation="false"
                OnClick="btnCancel_Click"
                Style="display:none;" />

        </div>

    </div>


    <!-- ==========================================
         CHANGE PASSWORD POPUP
    ========================================== -->

    <div id="caPasswordOverlay"
         class="ca-edit-area"
         role="dialog"
         aria-modal="true"
         aria-labelledby="caPasswordTitle"
         onclick="caPasswordOverlayClick(event)">

        <div class="ca-modal">

            <!-- CLOSE -->

            <button
                type="button"
                class="ca-modal-close"
                aria-label="Close"
                onclick="caClosePassword()">
                &times;
            </button>

            <!-- ICON -->

            <div class="ca-modal-icon">
                &#128274;
            </div>

            <h3 id="caPasswordTitle">
                Change Password
            </h3>

            <p>
                Keep your account secure by updating your password.
            </p>

            <!-- CURRENT PASSWORD -->

            <div class="ca-field">

                <label for="<%= txtCurrentPassword.ClientID %>">
                    Current Password
                </label>

                <asp:TextBox
                    ID="txtCurrentPassword"
                    runat="server"
                    TextMode="Password"
                    CssClass="form-control"
                    autocomplete="current-password" />

            </div>

            <!-- NEW PASSWORD -->

            <div class="ca-field">

                <label for="<%= txtNewPassword.ClientID %>">
                    New Password
                </label>

                <asp:TextBox
                    ID="txtNewPassword"
                    runat="server"
                    TextMode="Password"
                    CssClass="form-control"
                    autocomplete="new-password" />

                <small class="ca-password-hint">
                    Use 8–128 characters.
                </small>

            </div>

            <!-- CONFIRM PASSWORD -->

            <div class="ca-field">

                <label for="<%= txtConfirmPassword.ClientID %>">
                    Confirm New Password
                </label>

                <asp:TextBox
                    ID="txtConfirmPassword"
                    runat="server"
                    TextMode="Password"
                    CssClass="form-control"
                    autocomplete="new-password" />

            </div>

            <!-- BUTTONS -->

            <div class="ca-modal-actions">

                <button
                    type="button"
                    class="btn btn-outline-primary"
                    onclick="caClosePassword()">
                    Cancel
                </button>

                <asp:Button
                    ID="btnChangePassword"
                    runat="server"
                    Text="<%$ Resources:Coordinator, Account.UpdatePassword %>"
                    CssClass="btn btn-primary password-update-btn"
                    CausesValidation="false"
                    OnClick="btnChangePassword_Click"
                    data-ui-action="update"
                    data-loading-label="Updating..."
                    data-ui-validation="none" />

            </div>

        </div>

    </div>

</div>

</asp:Content>


<asp:Content ID="Scripts"
    ContentPlaceHolderID="scripts"
    runat="server">

<script type="text/javascript">

/* ==========================================
   EDIT PROFILE POPUP
========================================== */

var caPreviousFocus = null;
var caOriginalName = "";
var caOriginalPhone = "";

function caOpenEdit() {

    var modal = document.getElementById("caEditArea");

    if (!modal) return;

    caPreviousFocus = document.activeElement;

    var nameInput = document.getElementById(
        "<%= txtName.ClientID %>"
    );

    var phoneInput = document.getElementById(
        "<%= txtPhone.ClientID %>"
    );

    caOriginalName = nameInput ? nameInput.value : "";
    caOriginalPhone = phoneInput ? phoneInput.value : "";

    modal.classList.add("ca-open");
    document.body.classList.add("ca-modal-active");

    if (nameInput) {
        nameInput.focus();
    }
}

function caCloseEdit() {

    var modal = document.getElementById("caEditArea");

    if (!modal) return;

    var nameInput = document.getElementById(
        "<%= txtName.ClientID %>"
    );

    var phoneInput = document.getElementById(
        "<%= txtPhone.ClientID %>"
    );

    if (nameInput) {
        nameInput.value = caOriginalName;
    }

    if (phoneInput) {
        phoneInput.value = caOriginalPhone;
    }

    modal.classList.remove("ca-open");
    document.body.classList.remove("ca-modal-active");

    if (caPreviousFocus && caPreviousFocus.focus) {
        caPreviousFocus.focus();
    }
}

function caOverlayClick(event) {

    if (event.target.id === "caEditArea") {
        caCloseEdit();
    }
}

function caValidateProfile() {

    if (typeof Page_ClientValidate === "function") {

        if (!Page_ClientValidate("profile")) {
            return false;
        }
    }

    return true;
}


/* ==========================================
   PASSWORD POPUP
========================================== */

var caPasswordPreviousFocus = null;

function caOpenPassword() {

    var modal = document.getElementById(
        "caPasswordOverlay"
    );

    if (!modal) return;

    caPasswordPreviousFocus = document.activeElement;

    modal.classList.add("ca-open");

    document.body.classList.add(
        "ca-modal-active"
    );

    var currentPassword = document.getElementById(
        "<%= txtCurrentPassword.ClientID %>"
    );

    if (currentPassword) {
        currentPassword.focus();
    }
}

function caClosePassword() {

    var modal = document.getElementById(
        "caPasswordOverlay"
    );

    if (!modal) return;

    modal.classList.remove("ca-open");

    document.body.classList.remove(
        "ca-modal-active"
    );

    var passwordIds = [
        "<%= txtCurrentPassword.ClientID %>",
        "<%= txtNewPassword.ClientID %>",
        "<%= txtConfirmPassword.ClientID %>"
    ];

    passwordIds.forEach(function(id) {

        var input = document.getElementById(id);

        if (input) {
            input.value = "";
        }

    });

    if (
        caPasswordPreviousFocus &&
        caPasswordPreviousFocus.focus
    ) {
        caPasswordPreviousFocus.focus();
    }
}

function caPasswordOverlayClick(event) {

    if (event.target.id === "caPasswordOverlay") {
        caClosePassword();
    }
}


/* ==========================================
   KEYBOARD SUPPORT
========================================== */

document.addEventListener("keydown", function(event) {

    var passwordModal = document.getElementById(
        "caPasswordOverlay"
    );

    var profileModal = document.getElementById(
        "caEditArea"
    );

    var activeModal = null;

    if (
        passwordModal &&
        passwordModal.classList.contains("ca-open")
    ) {
        activeModal = passwordModal;
    }
    else if (
        profileModal &&
        profileModal.classList.contains("ca-open")
    ) {
        activeModal = profileModal;
    }

    if (!activeModal) return;

    if (event.key === "Escape") {

        if (activeModal === passwordModal) {
            caClosePassword();
        }
        else {
            caCloseEdit();
        }

        return;
    }

    if (event.key === "Tab") {

        var focusable = Array.prototype.slice.call(
            activeModal.querySelectorAll(
                'button:not([disabled]), input:not([disabled]), ' +
                'a[href], select:not([disabled]), textarea:not([disabled])'
            )
        ).filter(function(el) {
            return el.getClientRects().length > 0;
        });

        if (!focusable.length) return;

        var first = focusable[0];
        var last = focusable[focusable.length - 1];

        if (
            event.shiftKey &&
            document.activeElement === first
        ) {
            event.preventDefault();
            last.focus();
        }
        else if (
            !event.shiftKey &&
            document.activeElement === last
        ) {
            event.preventDefault();
            first.focus();
        }
    }
});


/* ==========================================
   LOAD PROFILE DATA
========================================== */

(function () {

    function init() {

        var ids = {
            name: '<%= txtName.ClientID %>',
            email: '<%= txtEmail.ClientID %>',
            phone: '<%= txtPhone.ClientID %>',
            university: '<%= txtUniversity.ClientID %>',
            college: '<%= txtCollege.ClientID %>',
            staff: '<%= txtStaffId.ClientID %>'
        };

        function value(key) {

            var el = document.getElementById(ids[key]);

            return el ? el.value.trim() : "";
        }

        function show(id, v) {

            var el = document.getElementById(id);

            if (el) {
                el.textContent = v || "Not provided";
            }
        }

        var name = value("name");

        show("caDisplayName", name);
        show("caDisplayEmail", value("email"));
        show("caDisplayPhone", value("phone"));
        show("caDisplayUniversity", value("university"));
        show("caDisplayCollege", value("college"));
        show("caDisplayStaff", value("staff"));

        var initials = (
            name.split(/\s+/)
                .filter(Boolean)
                .slice(0, 2)
                .map(function(w) {
                    return w.charAt(0).toUpperCase();
                })
                .join("")
        ) || "--";

        show("caAvatar", initials);
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", init);
    }
    else {
        init();
    }

})();


/* ==========================================
   PASSWORD VALIDATION
========================================== */

document.addEventListener("DOMContentLoaded", function () {

    var buttonId = "<%= btnChangePassword.ClientID %>";
    var currentId = "<%= txtCurrentPassword.ClientID %>";
    var newId = "<%= txtNewPassword.ClientID %>";
    var confirmId = "<%= txtConfirmPassword.ClientID %>";

    var button = document.getElementById(buttonId);

    if (button === null) {
        return;
    }

    button.addEventListener("click", function(event) {

        var currentInput = document.getElementById(currentId);
        var newInput = document.getElementById(newId);
        var confirmInput = document.getElementById(confirmId);

        if (
            currentInput === null ||
            newInput === null ||
            confirmInput === null
        ) {
            event.preventDefault();
            alert(window.uimsT('PwFieldsMissing'));
            return;
        }

        var currentValue = currentInput.value;
        var newValue = newInput.value;
        var confirmValue = confirmInput.value;

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
