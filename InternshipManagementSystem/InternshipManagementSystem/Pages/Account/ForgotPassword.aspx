<%@ Page Language="C#"
    MasterPageFile="~/Layout/Public.master"
    AutoEventWireup="true"
    CodeBehind="ForgotPassword.aspx.cs"
    Inherits="InternshipManagementSystem.Pages.AccountArea.ForgotPassword"
    Title="Password Recovery | UIMS" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <style>
        .recovery-experience {
            position: relative;
            isolation: isolate;
            display: grid;
            grid-template-columns: 1.05fr 1fr;
            align-items: center;
            gap: clamp(36px, 6vw, 90px);
            width: min(1100px, 100%);
            margin: 30px auto;
            padding: 32px 20px;
            color: var(--ui-ink);
        }

        .recovery-experience *,
        .recovery-experience *::before,
        .recovery-experience *::after {
            box-sizing: border-box;
        }

        .recovery-story {
            position: relative;
            text-align: start;
            animation: recoveryReveal .85s ease both;
        }

        .recovery-story h1 {
            margin: 0 0 18px;
            color: var(--ui-ink);
            font-size: clamp(32px, 4vw, 48px);
            font-weight: 750;
            line-height: 1.16;
            letter-spacing: -.035em;
        }

        .recovery-story p {
            color: var(--ui-muted);
            line-height: 1.8;
            max-width: 440px;
        }

        .recovery-story .public-lead {
            font-size: 17px;
            margin-bottom: 14px;
        }

        .recovery-experience .public-text-link {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            color: var(--ui-ink);
            text-underline-offset: 5px;
            transition: color .2s ease;
        }

        .recovery-experience .public-text-link:hover {
            color: var(--ui-primary-text,var(--ui-primary));
        }

        /* Animated illustration */

        .mail-scene {
            position: relative;
            display: grid;
            place-items: center;
            width: min(360px, 100%);
            height: 300px;
            margin: 0 auto 24px;
            perspective: 900px;
            direction: ltr;
        }

        .mail-halo {
            position: absolute;
            width: 250px;
            height: 250px;
            border-radius: 50%;
            background: radial-gradient(
                circle,
                var(--ui-primary-soft) 0%,
                transparent 70%
            );
            animation: haloBreathe 6s ease-in-out infinite;
        }

        .mail-orbit {
            position: absolute;
            width: 270px;
            height: 270px;
            border: 1px solid var(--ui-border);
            border-radius: 50%;
            transform: rotateX(58deg) rotate(-24deg);
        }

        .mail-orbit::before {
            content: "";
            position: absolute;
            top: 34px;
            left: 34px;
            width: 9px;
            height: 9px;
            border-radius: 50%;
            background: var(--ui-accent);
            box-shadow: 0 0 0 6px var(--ui-primary-soft);
        }

        .mail-orbit-secondary {
            width: 320px;
            height: 320px;
            transform: rotateX(58deg) rotate(42deg);
            opacity: .5;
        }

        .mail-orbit-secondary::before {
            width: 5px;
            height: 5px;
            background: var(--ui-primary);
        }

        .mail-float {
            position: relative;
            width: 220px;
            height: 160px;
            transform-style: preserve-3d;
            animation: mailFloat 6s ease-in-out infinite;
        }

        .mail-back {
            position: absolute;
            inset: 0;
            border-radius: 15px;
            background: var(--ui-primary);
            box-shadow: 0 24px 45px -24px var(--ui-primary);
        }

        .mail-flap {
            position: absolute;
            inset: 0 0 auto;
            height: 95px;
            background: var(--ui-primary-hover);
            clip-path: polygon(0 0, 100% 0, 50% 100%);
            transform-origin: top center;
            transform: rotateX(180deg);
        }

        .mail-letter {
            position: absolute;
            z-index: 1;
            top: -12px;
            left: 25px;
            width: 170px;
            height: 160px;
            padding: 24px 20px;
            border: 1px solid var(--ui-border);
            border-radius: 12px;
            background: var(--ui-surface);
            box-shadow: 0 -8px 30px -18px var(--ui-primary);
            animation: letterRise 6s ease-in-out infinite;
        }

        .letter-emblem {
            display: grid;
            place-items: center;
            width: 38px;
            height: 38px;
            margin-bottom: 17px;
            border-radius: 12px;
            background: var(--ui-primary-soft);
            color: var(--ui-ink);
        }

        .letter-emblem svg {
            width: 21px;
            height: 21px;
        }

        .letter-line {
            display: block;
            height: 5px;
            margin-top: 9px;
            border-radius: 20px;
            background: var(--ui-border);
        }

        .letter-line-short {
            width: 65%;
        }

        .mail-front {
            position: absolute;
            z-index: 2;
            inset: 0;
            border-radius: 0 0 15px 15px;
            background: linear-gradient(
                135deg,
                var(--ui-primary),
                var(--ui-primary-hover)
            );
            clip-path: polygon(
                0 0,
                50% 49%,
                100% 0,
                100% 100%,
                0 100%
            );
        }

        .mail-front::after {
            content: "";
            position: absolute;
            inset: 0;
            background: linear-gradient(
                145deg,
                transparent 48%,
                rgba(255,255,255,.12) 49%,
                transparent 50%
            );
        }

        .mail-seal {
            position: absolute;
            z-index: 3;
            top: 91px;
            left: 91px;
            display: grid;
            place-items: center;
            width: 38px;
            height: 38px;
            border: 4px solid var(--ui-primary);
            border-radius: 50%;
            background: var(--ui-accent);
            color: #173f62; /* Navy on the gold seal in both themes. */
        }

        .mail-seal svg {
            width: 17px;
            height: 17px;
        }

        .mail-shadow {
            position: absolute;
            bottom: 23px;
            width: 155px;
            height: 15px;
            border-radius: 50%;
            background: var(--ui-primary);
            filter: blur(13px);
            opacity: .15;
            animation: shadowBreathe 6s ease-in-out infinite;
        }

        .mail-spark {
            position: absolute;
            width: 6px;
            height: 6px;
            border-radius: 50%;
            background: var(--ui-accent);
            animation: sparkFloat 5s ease-in-out infinite;
        }

        .mail-spark-one {
            top: 54px;
            right: 48px;
        }

        .mail-spark-two {
            bottom: 75px;
            left: 36px;
            width: 4px;
            height: 4px;
            animation-delay: -2s;
        }

        .mail-spark-three {
            top: 92px;
            left: 52px;
            width: 5px;
            height: 5px;
            background: var(--ui-primary);
            animation-delay: -3s;
        }

        /* Form card */

        .recovery-experience .recovery-card {
            position: relative;
            width: 100%;
            min-width: 0;
            margin: 0;
            padding: clamp(26px, 4vw, 44px);
            overflow: hidden;
            border: 1px solid var(--ui-border);
            border-radius: 26px;
            background: var(--ui-surface);
            box-shadow:
                0 24px 65px -35px rgba(19,61,97,.3),
                0 4px 14px -8px rgba(19,61,97,.12);
            animation: cardReveal .9s cubic-bezier(.16,1,.3,1) .12s both;
        }

        .recovery-card::before {
            content: "";
            position: absolute;
            top: 0;
            inset-inline: 30px;
            height: 2px;
            background: linear-gradient(
                90deg,
                transparent,
                var(--ui-accent),
                transparent
            );
        }

        .recovery-card::after {
            content: "";
            position: absolute;
            top: -90px;
            inset-inline-end: -90px;
            width: 200px;
            height: 200px;
            border-radius: 50%;
            background: radial-gradient(
                circle,
                var(--ui-primary-soft),
                transparent 70%
            );
            opacity: .65;
            pointer-events: none;
        }

        .recovery-card > * {
            position: relative;
            z-index: 1;
        }

        .recovery-icon {
            display: grid;
            place-items: center;
            width: 52px;
            height: 52px;
            margin-bottom: 24px;
            border: 1px solid var(--ui-border);
            border-radius: 16px;
            color: var(--ui-ink);
            background: var(--ui-primary-soft);
        }

        .recovery-icon svg {
            width: 25px;
            height: 25px;
        }

        .recovery-card h2 {
            margin: 0 0 12px;
            color: var(--ui-ink);
            font-size: clamp(25px, 3vw, 32px);
            font-weight: 750;
            letter-spacing: -.025em;
        }

        .recovery-card .public-form-intro {
            margin-bottom: 28px;
            color: var(--ui-muted);
            line-height: 1.75;
        }

        .recovery-card .public-field {
            margin-bottom: 22px;
        }

        .recovery-card .public-field label {
            display: block;
            margin-bottom: 9px;
            color: var(--ui-ink);
            font-weight: 600;
        }

        .recovery-input-wrap {
            position: relative;
            border-radius: 14px;
            transition: box-shadow .25s ease;
        }

        .recovery-input-wrap:focus-within {
            box-shadow: 0 0 0 4px var(--ui-primary-soft);
        }

        .recovery-input-wrap > svg {
            position: absolute;
            z-index: 1;
            top: 50%;
            inset-inline-start: 17px;
            width: 20px;
            height: 20px;
            color: var(--ui-muted);
            transform: translateY(-50%);
            pointer-events: none;
            transition: color .2s ease;
        }

        .recovery-input-wrap:focus-within > svg {
            color: var(--ui-ink);
        }

        .recovery-card .recovery-input-wrap input {
            display: block;
            width: 100%;
            min-height: 56px;
            margin: 0;
            padding: 14px 16px;
            padding-inline-start: 49px;
            border: 1px solid var(--ui-control-border);
            border-radius: 14px;
            outline: none;
            color: var(--ui-ink);
            background: var(--ui-canvas);
            box-shadow: none;
            transition:
                border-color .2s ease,
                background-color .2s ease;
        }

        .recovery-card .recovery-input-wrap input:focus {
            border-color: var(--ui-primary);
            background: var(--ui-surface);
        }

        .recovery-card .recovery-input-wrap input[aria-invalid="true"] {
            border-color: var(--ui-danger);
        }

        .recovery-card .public-hint {
            display: block;
            margin-top: 10px;
            color: var(--ui-muted);
            font-size: 12px;
            line-height: 1.7;
        }

        .recovery-card .public-field-error {
            display: block;
            margin-top: 7px;
            color: var(--ui-danger);
            font-size: 13px;
        }

        .recovery-submit {
            position: relative;
            overflow: hidden;
            border-radius: 14px;
        }

        .recovery-card .public-button {
            display: block;
            width: 100%;
            min-height: 54px;
            margin: 0;
            padding: 14px 20px;
            border: 0;
            border-radius: 14px;
            color: #fff;
            background: var(--ui-primary);
            font-size: 15px;
            font-weight: 650;
            cursor: pointer;
            transition:
                background-color .2s ease,
                transform .2s ease;
        }

        .recovery-card .public-button:hover {
            background: var(--ui-primary-hover);
        }

        .recovery-card .public-button:active {
            transform: scale(.985);
        }

        .recovery-card .public-button:focus-visible {
            outline: 3px solid var(--ui-accent);
            outline-offset: 3px;
        }

        .recovery-submit::after {
            content: "";
            position: absolute;
            top: 0;
            left: -75%;
            width: 45%;
            height: 100%;
            background: linear-gradient(
                110deg,
                transparent,
                rgba(255,255,255,.2),
                transparent
            );
            transform: skewX(-18deg);
            pointer-events: none;
        }

        .recovery-submit:hover::after {
            animation: buttonSweep .75s ease;
        }

        .recovery-card[data-submitting="true"] .recovery-submit::after {
            animation: buttonSweep 1.5s ease infinite;
        }

        .recovery-card[data-submitting="true"] .public-button {
            cursor: wait;
        }

        .recovery-card .public-form-note {
            margin: 18px 0 24px;
            color: var(--ui-muted);
            font-size: 12px;
            line-height: 1.8;
        }

        .recovery-return {
            padding-top: 21px;
            border-top: 1px solid var(--ui-border);
            text-align: center;
        }

        .recovery-return svg {
            width: 17px;
            height: 17px;
        }

        html[dir="rtl"] .recovery-return svg {
            transform: rotate(180deg);
        }

        .recovery-card .alert {
            display: block;
            margin-bottom: 20px;
            border-radius: 12px;
            line-height: 1.7;
            animation: recoveryReveal .4s ease both;
        }

        .recovery-card .alert-success {
            border: 1px solid var(--ui-success);
            color: var(--ui-success);
            background: var(--ui-success-soft);
        }

        .recovery-card .alert-danger {
            border: 1px solid var(--ui-danger);
            color: var(--ui-danger);
            background: var(--ui-danger-soft);
        }

        .recovery-card .recovery-icon,
        .recovery-card h2,
        .recovery-card .public-form-intro,
        .recovery-card .public-field,
        .recovery-card .recovery-submit,
        .recovery-card .public-form-note,
        .recovery-card .recovery-return {
            animation: recoveryReveal .65s ease backwards;
        }

        .recovery-card .recovery-icon { animation-delay: .2s; }
        .recovery-card h2 { animation-delay: .26s; }
        .recovery-card .public-form-intro { animation-delay: .32s; }
        .recovery-card .public-field { animation-delay: .38s; }
        .recovery-card .recovery-submit { animation-delay: .44s; }
        .recovery-card .public-form-note { animation-delay: .5s; }
        .recovery-card .recovery-return { animation-delay: .56s; }

        @keyframes recoveryReveal {
            from {
                opacity: 0;
                transform: translateY(16px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @keyframes cardReveal {
            from {
                opacity: 0;
                transform: translateY(32px) scale(.97);
            }
            to {
                opacity: 1;
                transform: translateY(0) scale(1);
            }
        }

        @keyframes mailFloat {
            0%, 100% {
                transform: translateY(10px) rotate(-7deg) rotateY(-8deg);
            }
            50% {
                transform: translateY(-5px) rotate(-3deg) rotateY(5deg);
            }
        }

        @keyframes letterRise {
            0%, 100% {
                transform: translateY(3px);
            }
            45%, 60% {
                transform: translateY(-30px);
            }
        }

        @keyframes haloBreathe {
            0%, 100% {
                opacity: .65;
                transform: scale(.9);
            }
            50% {
                opacity: 1;
                transform: scale(1.1);
            }
        }

        @keyframes shadowBreathe {
            0%, 100% {
                opacity: .18;
                transform: scaleX(1);
            }
            50% {
                opacity: .09;
                transform: scaleX(.8);
            }
        }

        @keyframes sparkFloat {
            0%, 100% {
                opacity: .4;
                transform: translateY(0);
            }
            50% {
                opacity: 1;
                transform: translateY(-12px);
            }
        }

        @keyframes buttonSweep {
            from { left: -75%; }
            to { left: 135%; }
        }

        @media (max-width: 800px) {
            .recovery-experience {
                grid-template-columns: 1fr;
                gap: 28px;
                max-width: 540px;
                margin: 12px auto;
                padding: 20px 16px;
            }

            .recovery-story {
                text-align: center;
            }

            .recovery-story p {
                margin-inline: auto;
            }

            .mail-scene {
                height: 240px;
                margin-bottom: 12px;
                transform: scale(.85);
            }

            .mail-shadow {
                bottom: 0;
            }

            .recovery-story h1 {
                font-size: 34px;
            }
        }

        @media (prefers-reduced-motion: reduce) {
            .recovery-experience *,
            .recovery-experience *::before,
            .recovery-experience *::after {
                animation: none !important;
                transition: none !important;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

    <div class="recovery-experience">

        <div class="recovery-story">

            <div class="mail-scene" aria-hidden="true">
                <div class="mail-halo"></div>
                <div class="mail-orbit"></div>
                <div class="mail-orbit mail-orbit-secondary"></div>

                <span class="mail-spark mail-spark-one"></span>
                <span class="mail-spark mail-spark-two"></span>
                <span class="mail-spark mail-spark-three"></span>

                <div class="mail-float">
                    <div class="mail-back"></div>
                    <div class="mail-flap"></div>

                    <div class="mail-letter">
                        <div class="letter-emblem">
                            <svg viewBox="0 0 24 24" fill="none"
                                stroke="currentColor" stroke-width="1.7"
                                stroke-linecap="round" stroke-linejoin="round">
                                <rect x="5" y="10" width="14" height="11" rx="3"></rect>
                                <path d="M8 10V7a4 4 0 0 1 8 0v3"></path>
                                <path d="M12 14v3"></path>
                            </svg>
                        </div>
                        <span class="letter-line"></span>
                        <span class="letter-line letter-line-short"></span>
                    </div>

                    <div class="mail-front"></div>

                    <div class="mail-seal">
                        <svg viewBox="0 0 24 24" fill="none"
                            stroke="currentColor" stroke-width="2"
                            stroke-linecap="round" stroke-linejoin="round">
                            <path d="m8 12 3 3 5-6"></path>
                        </svg>
                    </div>
                </div>

                <div class="mail-shadow"></div>
            </div>

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

        <section class="public-form recovery-card"
            data-public-form="recovery"
            aria-labelledby="recovery-title">

            <div class="recovery-icon" aria-hidden="true">
                <svg viewBox="0 0 24 24" fill="none"
                    stroke="currentColor" stroke-width="1.7"
                    stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="8" cy="9" r="4"></circle>
                    <path d="m11 12 9 9m-4-4 3-3m-6 0 3-3"></path>
                </svg>
            </div>

            <h2 id="recovery-title">
                <%: L.T("Account.ForgotPassword.ResetYourPassword") %>
            </h2>

            <p class="public-form-intro">
                <%: L.T("Account.ForgotPassword.EnterYourAccountEmailToRequest") %>
            </p>

            <asp:Label ID="lblMessage"
                runat="server"
                Visible="false"
                role="alert" />

            <div class="public-field">

                <label for="<%= txtEmail.ClientID %>">
                    <%: L.T("Account.ForgotPassword.EmailAddress") %>
                </label>

                <div class="recovery-input-wrap">
                    <svg viewBox="0 0 24 24" fill="none"
                        stroke="currentColor" stroke-width="1.7"
                        stroke-linecap="round" stroke-linejoin="round"
                        aria-hidden="true">
                        <rect x="3" y="5" width="18" height="14" rx="3"></rect>
                        <path d="m4 7 8 6 8-6"></path>
                    </svg>

                    <asp:TextBox ID="txtEmail"
                        runat="server"
                        TextMode="Email"
                        autocomplete="email"
                        MaxLength="254"
                        placeholder="you@example.com"
                        aria-required="true"
                        data-public-required=""
                        data-required-message="<%$ Resources:Account, ForgotPassword.EnterYourEmailAddress %>"
                        aria-describedby="emailError recoveryHint" />
                </div>

                <span id="emailError"
                    class="public-field-error"
                    aria-live="polite"></span>

                <small id="recoveryHint" class="public-hint">
                    <%: L.T("Account.ForgotPassword.CheckYourInboxAndSpamFolder") %>
                </small>
            </div>

            <div class="recovery-submit">
                <asp:Button ID="btnSend"
                    runat="server"
                    Text="<%$ Resources:Account, ForgotPassword.SendResetLink %>"
                    CssClass="public-button"
                    OnClientClick="return validateEmail();"
                    OnClick="btnSend_Click" />
            </div>

            <p class="public-form-note">
                <%: L.T("Account.ForgotPassword.ForYourPrivacyTheResponseWill") %>
            </p>

            <div class="recovery-return">
                <a class="public-text-link"
                    href="<%: ResolveUrl("~/Pages/Account/Login.aspx") %>">
                    <svg viewBox="0 0 24 24" fill="none"
                        stroke="currentColor" stroke-width="1.7"
                        stroke-linecap="round" stroke-linejoin="round"
                        aria-hidden="true">
                        <path d="m10 6-6 6 6 6M4 12h16"></path>
                    </svg>
                    <%: L.T("Account.ForgotPassword.BackToLogin") %>
                </a>
            </div>

        </section>
    </div>
</asp:Content>

<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server">
    <script src="<%: ResolveUrl("~/Assets/js/public-forms.js?v=20261021-4") %>"></script>
</asp:Content>