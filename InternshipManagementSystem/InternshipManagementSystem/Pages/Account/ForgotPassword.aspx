
<%@ Page Language="C#" MasterPageFile="~/Layout/Public.master" AutoEventWireup="true" CodeBehind="ForgotPassword.aspx.cs" Inherits="InternshipManagementSystem.Pages.AccountArea.ForgotPassword" Title="Password Recovery | UIMS" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">

<style>
/*  Forgot Password - UI Improvements- Design only  */

/* Page layout */
.public-auth.forgot-password-page {
    width: 100%;
    box-sizing: border-box;
    align-items: center;
    column-gap: clamp(24px, 4vw, 60px);
}

/* Left introduction */
.forgot-password-page .public-auth-intro {
    animation: forgotIntroEnter 0.55s ease-out both;
}

.forgot-password-page .public-auth-intro h1 {
    line-height: 1.2;
    letter-spacing: -0.5px;
}

.forgot-password-page .public-auth-intro p {
    line-height: 1.65;
}

/* Form card */
.forgot-password-page .public-form {
    box-sizing: border-box;
    min-width: 0;

    background: #ffffff;
    border: 2px solid #bfd0e2;
    border-radius: 16px;

    padding: clamp(24px, 3vw, 36px);

    box-shadow:
        0 8px 28px rgba(23, 52, 81, 0.08);

    animation: forgotFormEnter 0.55s ease-out both;

    transition:
        border-color 0.25s ease,
        box-shadow 0.25s ease;
}

.forgot-password-page .public-form:hover {
    border-color: #a9bfd6;

    box-shadow:
        0 12px 32px rgba(23, 52, 81, 0.11);
}

/* Form heading */
.forgot-password-page .public-form h2 {
    margin-top: 0;
    margin-bottom: 10px;
    line-height: 1.3;
}

.forgot-password-page .public-form-intro {
    line-height: 1.6;
    margin-bottom: 22px;
}

/* Form fields */
.forgot-password-page .public-field {
    margin-bottom: 18px;
}

.forgot-password-page .public-field label {
    display: block;
    margin-bottom: 8px;
    font-weight: 600;
}

/* Email input */
.forgot-password-page .public-field input {
    width: 100%;
    box-sizing: border-box;

    border: 1.5px solid #cbd8e6;
    border-radius: 9px;

    transition:
        border-color 0.2s ease,
        box-shadow 0.2s ease,
        background-color 0.2s ease;
}

.forgot-password-page .public-field input:hover {
    border-color: #9fb8d2;
}

.forgot-password-page .public-field input:focus {
    outline: none;
    border-color: #4979a8;

    box-shadow:
        0 0 0 3px rgba(73, 121, 168, 0.13);
}

/* Hint */
.forgot-password-page .public-hint {
    display: block;
    margin-top: 9px;
    line-height: 1.5;
}

/* Reset button */
.forgot-password-page .public-button {
    border-radius: 9px;

    transition:
        transform 0.2s ease,
        box-shadow 0.2s ease,
        filter 0.2s ease;
}

.forgot-password-page .public-button:hover {
    transform: translateY(-2px);

    box-shadow:
        0 7px 18px rgba(36, 79, 119, 0.19);

    filter: brightness(1.04);
}

.forgot-password-page .public-button:active {
    transform: translateY(0);
    box-shadow: none;
}

.forgot-password-page .public-button:focus-visible {
    outline: 3px solid rgba(73, 121, 168, 0.35);
    outline-offset: 3px;
}

/* Notes and links */
.forgot-password-page .public-form-note {
    line-height: 1.6;
}

.forgot-password-page .public-text-link {
    transition:
        color 0.2s ease,
        text-decoration-color 0.2s ease;
}

.forgot-password-page .public-text-link:hover {
    color: #174a78;
    text-decoration: underline;
}

/* Success and error messages */
.forgot-password-page .alert {
    border-radius: 9px;

    animation:
        forgotMessageEnter 0.35s ease-out both;
}

/* Entrance animations */
@keyframes forgotIntroEnter {
    from {
        opacity: 0;
        transform: translateX(-14px);
    }

    to {
        opacity: 1;
        transform: translateX(0);
    }
}

@keyframes forgotFormEnter {
    from {
        opacity: 0;
        transform: translateY(16px);
    }

    to {
        opacity: 1;
        transform: translateY(0);
    }
}

@keyframes forgotMessageEnter {
    from {
        opacity: 0;
        transform: translateY(6px);
    }

    to {
        opacity: 1;
        transform: translateY(0);
    }
}

/* Responsive improvements */
@media (max-width: 900px) {
    .public-auth.forgot-password-page {
        column-gap: 24px;
    }

    .forgot-password-page .public-form {
        padding: 24px;
    }
}

@media (max-width: 650px) {
    .public-auth.forgot-password-page {
        width: 100%;
    }

    .forgot-password-page .public-form {
        width: 100%;
        padding: 22px 18px;
        border-radius: 12px;
    }

    .forgot-password-page .public-auth-intro h1 {
        letter-spacing: normal;
    }
}

/* Accessibility: reduced motion */
@media (prefers-reduced-motion: reduce) {
    .forgot-password-page .public-auth-intro,
    .forgot-password-page .public-form,
    .forgot-password-page .alert {
        animation: none !important;
    }

    .forgot-password-page .public-form,
    .forgot-password-page .public-button,
    .forgot-password-page .public-field input,
    .forgot-password-page .public-text-link {
        transition: none !important;
    }

    .forgot-password-page .public-button:hover {
        transform: none;
    }
}

/* Interactive button effect */

.forgot-password-page .public-button {
    position: relative;
    overflow: hidden;
    isolation: isolate;
}

.forgot-password-page .public-button::after {
    content: "";
    position: absolute;
    inset: 0;
    pointer-events: none;
    background: radial-gradient(
        circle at var(--mouse-x, 50%) var(--mouse-y, 50%),
        rgba(255, 255, 255, 0.22),
        transparent 65%
    );
    opacity: 0;
    transition: opacity 0.25s ease;
}

.forgot-password-page .public-button:hover::after {
    opacity: 1;
}

@media (prefers-reduced-motion: reduce) {
    .forgot-password-page .public-button::after {
        display: none;
    }
}

/* Forgot Password - Enhanced Button Hover */

.forgot-password-page input.public-button {
    cursor: pointer;
    transform: translateY(0) scale(1);
    transition:
        transform 0.25s ease,
        box-shadow 0.25s ease,
        filter 0.25s ease;
}

.forgot-password-page input.public-button:hover,
.forgot-password-page input.public-button.js-hover {
    transform: translateY(-4px) scale(1.035);
    box-shadow:
        0 10px 24px rgba(35, 84, 135, 0.28),
        0 0 0 4px rgba(73, 121, 168, 0.12);
    filter: brightness(1.1);
}

.forgot-password-page input.public-button:active {
    transform: translateY(0) scale(0.98);
    box-shadow: 0 3px 8px rgba(35, 84, 135, 0.15);
}

@media (prefers-reduced-motion: reduce) {
    .forgot-password-page input.public-button {
        transition: none;
    }

    .forgot-password-page input.public-button:hover,
    .forgot-password-page input.public-button.js-hover {
        transform: none;
    }
}


</style>

</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

<div class="public-auth forgot-password-page">

    <div class="public-auth-intro">

        <h1>
            <%: L.T("Account.ForgotPassword.LetSGetYou") %>
            <br />
            <%: L.T("Account.ForgotPassword.BackOnTrack") %>
        </h1>

        <p class="public-lead">
            <%: L.T("Account.ForgotPassword.ForgotYourPasswordRequestAReset") %>
        </p>

        <p>
            <%: L.T("Account.ForgotPassword.IfYouCannotAccessThatEmail") %>
        </p>

        <a class="public-text-link"
           href="<%: ResolveUrl("~/Pages/Public/Contact.aspx") %>">
            <%: L.T("Account.ForgotPassword.ContactTheCoordinationTeam") %>
        </a>

    </div>

    <section class="public-form"
             data-public-form="recovery"
             aria-labelledby="recovery-title">

        <h2 id="recovery-title">
            <%: L.T("Account.ForgotPassword.ResetYourPassword") %>
        </h2>

        <p class="public-form-intro">
            <%: L.T("Account.ForgotPassword.EnterYourAccountEmailToRequest") %>
        </p>

        <asp:Label
            ID="lblMessage"
            runat="server"
            Visible="false"
            role="alert" />

        <div class="public-field">

            <label for="<%= txtEmail.ClientID %>">
                <%: L.T("Account.ForgotPassword.EmailAddress") %>
            </label>

            <asp:TextBox
                ID="txtEmail"
                runat="server"
                TextMode="Email"
                autocomplete="email"
                MaxLength="254"
                placeholder="you@example.com"
                aria-required="true"
                data-public-required=""
                data-required-message="<%$ Resources:Account, ForgotPassword.EnterYourEmailAddress %>"
                aria-describedby="emailError recoveryHint" />

            <span id="emailError"
                  class="public-field-error"
                  aria-live="polite"></span>

            <small id="recoveryHint" class="public-hint">
                <%: L.T("Account.ForgotPassword.CheckYourInboxAndSpamFolder") %>
            </small>

        </div>

        <asp:Button
            ID="btnSend"
            runat="server"
            Text="<%$ Resources:Account, ForgotPassword.SendResetLink %>"
            CssClass="public-button"
            OnClientClick="return validateEmail();"
            OnClick="btnSend_Click" />

        <p class="public-form-note">
            <%: L.T("Account.ForgotPassword.ForYourPrivacyTheResponseWill") %>
        </p>

        <a class="public-text-link"
           href="<%: ResolveUrl("~/Pages/Account/Login.aspx") %>">
            <%: L.T("Account.ForgotPassword.BackToLogin") %>
        </a>

    </section>

</div>

</asp:Content>

<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server">

<script src="<%: ResolveUrl("~/Assets/js/public-forms.js?v=20261021-4") %>">
    

<script type="text/javascript">
document.addEventListener("DOMContentLoaded", function () {

    var button = document.querySelector(
        ".forgot-password-page input.public-button"
    );

    if (!button) return;

    button.addEventListener("mouseenter", function () {
        button.classList.add("js-hover");
    });

    button.addEventListener("mouseleave", function () {
        button.classList.remove("js-hover");
    });

});
</script>




</asp:Content>
