 osamabanihani
<%@ Page Language="C#" MasterPageFile="~/Layout/Public.master" AutoEventWireup="true" CodeBehind="Contact.aspx.cs" Inherits="InternshipManagementSystem.Pages.PublicArea.Contact" Title="Contact | GJU Internship Management System" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="public-page public-contact">
 <section aria-labelledby="contact-title"><h1 id="contact-title">A little guidance.<br />A clear next step.</h1><p class="public-lead">Questions about access or the internship process? Send a message to the coordination team.</p>
 <details><summary>I need an internship account.</summary><p>Accounts are provided for your role. Include your name and student number, if applicable, so your coordinator can understand your request.</p></details>
 <details><summary>I forgot my password.</summary><p>You can <a href="<%: ResolveUrl("~/Pages/Account/ForgotPassword.aspx") %>">request a reset link</a> using your account email. If you cannot access that inbox, explain the issue in your message.</p></details>
 <details><summary>I have a question about my training.</summary><p>For task feedback or training decisions, start with your assigned company or academic supervisor. Contact the coordinator for general process or access questions.</p></details>
 <p class="public-form-note">Do not include passwords, sign-in codes or confidential evaluation documents.</p></section>
 <section class="public-form" data-public-form="contact" aria-labelledby="message-title"><h2 id="message-title">Send a message</h2><p class="public-form-intro">Required fields are marked with an asterisk (*).</p>
 <asp:Label ID="lblMessage" runat="server" Visible="false" role="alert" />
 <div class="public-field"><label for="<%= txtName.ClientID %>">Full name *</label><asp:TextBox ID="txtName" runat="server" MaxLength="100" minlength="2" autocomplete="name" dir="auto" aria-required="true" data-public-required="" data-required-message="Enter your full name." aria-describedby="nameError" /><span id="nameError" class="public-field-error" aria-live="polite"></span></div>
 <div class="public-field"><label for="<%= txtEmail.ClientID %>">Email address *</label><asp:TextBox ID="txtEmail" runat="server" TextMode="Email" MaxLength="254" autocomplete="email" placeholder="you@example.com" aria-required="true" data-public-required="" data-required-message="Enter your email address." aria-describedby="contactEmailError" /><span id="contactEmailError" class="public-field-error" aria-live="polite"></span></div>
 <div class="public-field"><label for="<%= txtSubject.ClientID %>">Subject *</label><asp:TextBox ID="txtSubject" runat="server" MaxLength="150" minlength="5" dir="auto" aria-required="true" data-public-required="" data-required-message="Enter a subject for your message." aria-describedby="subjectError" /><span id="subjectError" class="public-field-error" aria-live="polite"></span></div>
 <div class="public-field"><label for="<%= txtMessage.ClientID %>">Message *</label><asp:TextBox ID="txtMessage" runat="server" TextMode="MultiLine" Rows="6" maxlength="4000" minlength="20" dir="auto" aria-required="true" data-public-required="" data-required-message="Enter your message." aria-describedby="messageError messageHint" /><span id="messageError" class="public-field-error" aria-live="polite"></span><small id="messageHint" class="public-hint">20&ndash;4,000 characters. Share enough detail to help the team understand your question.</small></div>
 <div class="public-honeypot" aria-hidden="true"><label for="<%= Website.ClientID %>">Leave this field empty</label><asp:TextBox ID="Website" runat="server" tabindex="-1" autocomplete="off" /></div>
 <asp:Button ID="btnSend" runat="server" Text="Send message" CssClass="public-button" OnClientClick="return validateContact();" OnClick="btnSend_Click" />
 <p data-submit-status="" role="status" aria-live="polite" class="public-form-note"></p>
 <p class="public-form-note">Your message and email address are saved for the coordination team to review and follow up.</p></section>
</div>
=======

<%@ Page Language="C#"
    MasterPageFile="~/Layout/Public.master"
    AutoEventWireup="true"
    Async="true"
    CodeBehind="Contact.aspx.cs"
    Inherits="InternshipManagementSystem.Pages.PublicArea.Contact"
    Title="Contact Us" %>

<asp:Content ID="Head"
    ContentPlaceHolderID="head"
    runat="server">

    <!-- Bootstrap Icons -->
    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" />

    <style>

        /* ===============================
           CONTACT PAGE BACKGROUND
        =============================== */

        .contact-page {
            --contact-navy: #153e69;
            --contact-border: #dce6f1;

            width: 100%;
            max-width: none;
            min-height: 100vh;
            margin: 0;
            padding: 45px max(24px, calc((100% - 1200px) / 2)) 75px;

            background: #f3f7fc;
            box-sizing: border-box;

            font-family: "Segoe UI", Arial, sans-serif;
            color: #173d68;
        }

        /* ===============================
           PAGE HEADING
        =============================== */

        .contact-heading {
            text-align: center;
            max-width: 1200px;
            margin: 0 auto 35px;
        }

        .contact-heading h1 {
            font-size: 34px;
            font-weight: 700;
            color: #123d68;
            margin-bottom: 12px;
        }

        .contact-heading p {
            color: #607c9b;
            font-size: 15px;
            line-height: 1.7;
        }

        /* ===============================
           PAGE LAYOUT
        =============================== */

        .contact-layout {
            display: grid;
            grid-template-columns:
                minmax(0, 1.6fr)
                minmax(270px, 1fr);

            gap: 25px;
            align-items: start;

            width: 100%;
            max-width: 1200px;
            margin: 0 auto;
        }

        /* ===============================
           CONTACT FORM CARD
        =============================== */

        .contact-card {
            background: #ffffff;
            border: 1px solid var(--contact-border);
            border-radius: 15px;

            box-shadow:
                0 8px 30px rgba(17, 57, 100, 0.06);

            padding: 35px;
            width: 100%;
            min-width: 0;
            box-sizing: border-box;
        }

        .contact-card-title {
            font-size: 21px;
            font-weight: 700;
            margin-bottom: 24px;
            color: #123d68;
        }

        /* ===============================
           FORM FIELDS
        =============================== */

        .contact-field {
            margin-bottom: 21px;
        }

        .contact-field label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: #244e78;
            margin-bottom: 8px;
        }

        .contact-input {
            display: block;
            width: 100%;
            padding: 12px 14px;
            min-height: 46px;

            border: 1px solid #d1deed;
            border-radius: 7px;

            background: #ffffff;
            font-size: 14px;
            color: #173d68;
            box-sizing: border-box;
        }

        .contact-input:focus {
            border-color: #245b91;
            outline: none;

            box-shadow:
                0 0 0 3px rgba(36, 91, 145, 0.10);
        }

        .contact-textarea {
            min-height: 145px;
            resize: vertical;
        }

        /* ===============================
           SEND BUTTON
        =============================== */

        .contact-send {
            background: #194a78;
            border: 1px solid #194a78;
            border-radius: 7px;

            color: #ffffff;
            padding: 13px 30px;

            font-size: 14px;
            font-weight: 600;

            cursor: pointer;
            width: 100%;
        }

        .contact-send:hover {
            background: #10365b;
        }

        /* ===============================
           SUCCESS / ERROR MESSAGES
        =============================== */

        .contact-alert {
            display: block;
            padding: 14px 17px;
            border-radius: 8px;
            margin-bottom: 22px;
            font-size: 14px;
        }

        .contact-alert-success {
            background: #e3f6ed;
            color: #13734c;
            border: 1px solid #b8e5cf;
        }

        .contact-alert-error {
            background: #fff0f0;
            color: #a52929;
            border: 1px solid #f3c4c4;
        }

        .contact-note {
            font-size: 12px;
            color: #7c8fa5;
            margin-top: 14px;
            text-align: center;
        }

        /* ===============================
           CONTACT INFORMATION CARD
        =============================== */

        .contact-info-card {
            background: #ffffff;
            border: 1px solid #dce6f1;
            border-radius: 15px;

            padding: 30px 25px;

            box-shadow:
                0 8px 30px rgba(17, 57, 100, 0.06);

            box-sizing: border-box;
            min-width: 0;
        }

        .contact-info-card h2 {
            font-size: 21px;
            font-weight: 700;
            color: #123d68;
            margin: 0 0 12px;
        }

        .contact-info-intro {
            color: #607c9b;
            font-size: 14px;
            line-height: 1.7;
            margin-bottom: 25px;
        }

        /* ===============================
           CONTACT INFORMATION ITEMS
        =============================== */

        .contact-info-item {
            margin-bottom: 20px;
        }

        .contact-info-heading {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 8px;
        }

        /* Icons */

        .contact-info-icon {
            display: flex;
            align-items: center;
            justify-content: center;

            width: 36px;
            height: 36px;
            min-width: 36px;

            background: #edf4fb;
            color: #194a78;

            border-radius: 9px;
            font-size: 17px;
        }

        .contact-info-heading h3 {
            margin: 0;
            font-size: 14px;
            font-weight: 600;
            color: #173d68;
        }

        .contact-info-details {
            margin-left: 46px;
        }

        .contact-info-details p,
        .contact-info-details a {
            color: #607c9b;
            font-size: 13px;
            line-height: 1.8;
            overflow-wrap: anywhere;
        }

        .contact-info-details p {
            margin: 0;
        }

        .contact-info-details a {
            text-decoration: none;
        }

        .contact-info-details a:hover {
            color: #194a78;
            text-decoration: underline;
        }

        .contact-info-divider {
            border: 0;
            border-top: 1px solid #dce6f1;
            margin: 20px 0;
        }

        /* ===============================
           RESPONSIVE DESIGN
        =============================== */

        @media (max-width: 850px) {

            .contact-layout {
                grid-template-columns: 1fr;
            }

            .contact-card,
            .contact-info-card {
                padding: 22px;
            }
        }

        @media (max-width: 768px) {

            .contact-page {
                padding: 30px 16px 50px;
            }

            .contact-heading h1 {
                font-size: 27px;
            }
        }

/* Full Page Background */

html,
body {
    min-height: 100%;
}

body {
    background-color: #f3f7fc !important;
}

/* Fill the entire Contact Us page */
.contact-page {
    background-color: #f3f7fc !important;

    width: 100%;
    max-width: none;
    min-height: 100vh;

    margin: 0;
    padding: 45px max(24px, calc((100% - 1200px) / 2)) 75px;

    box-sizing: border-box;
}

/* Keep the form and information centered */
.contact-layout {
    width: 100%;
    max-width: 1200px;
    margin: 0 auto;
}

/* Keep cards white */
.contact-card,
.contact-info-card {
    background-color: #ffffff;
}

/* Mobile */
@media (max-width: 768px) {
    .contact-page {
        padding: 30px 16px 50px;
    }
}

    </style>

</asp:Content>


<asp:Content ID="Body"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="contact-page">

        <!-- PAGE HEADING -->

        <div class="contact-heading">

            <h1>Contact Us</h1>

            <p>
                Have a question about internship opportunities
                or the internship management system?
                We're here to help.
            </p>

        </div>


        <div class="contact-layout">

            <!-- =========================
                 LEFT: CONTACT FORM
            ========================== -->

            <div class="contact-card">

                <h2 class="contact-card-title">
                    Send Us a Message
                </h2>

                <asp:Label ID="lblMessage"
                    runat="server"
                    Visible="false" />


                <!-- Full Name -->

                <div class="contact-field">

                    <label for="<%= txtName.ClientID %>">
                        Full Name *
                    </label>

                    <asp:TextBox ID="txtName"
                        runat="server"
                        CssClass="contact-input"
                        MaxLength="100"
                        placeholder="Enter your full name" />

                </div>


                <!-- Email Address -->

                <div class="contact-field">

                    <label for="<%= txtEmail.ClientID %>">
                        Email Address *
                    </label>

                    <asp:TextBox ID="txtEmail"
                        runat="server"
                        TextMode="Email"
                        CssClass="contact-input"
                        MaxLength="254"
                        placeholder="Enter your email address" />

                </div>


                <!-- Subject -->

                <div class="contact-field">

                    <label for="<%= txtSubject.ClientID %>">
                        Subject *
                    </label>

                    <asp:TextBox ID="txtSubject"
                        runat="server"
                        CssClass="contact-input"
                        MaxLength="150"
                        placeholder="Enter message subject" />

                </div>


                <!-- Message -->

                <div class="contact-field">

                    <label for="<%= txtMessage.ClientID %>">
                        Message *
                    </label>

                    <asp:TextBox ID="txtMessage"
                        runat="server"
                        TextMode="MultiLine"
                        Rows="6"
                        CssClass="contact-input contact-textarea"
                        placeholder="Write your message here..." />

                </div>


                <!-- Send Message Button -->

                <asp:Button ID="btnSend"
                    runat="server"
                    Text="Send Message"
                    CssClass="contact-send"
                    OnClick="btnSend_Click" />


                <p class="contact-note">
                    All fields are required.
                    Your message will be reviewed by the internship coordinator.
                </p>

            </div>


            <!-- =========================
                 RIGHT: CONTACT INFORMATION
            ========================== -->

            <div class="contact-info-card">

                <h2>Contact Information</h2>

                <p class="contact-info-intro">
                    Get in touch with German Jordanian University
                    for general inquiries and internship-related support.
                </p>


                <!-- University Address -->

                <div class="contact-info-item">

                    <div class="contact-info-heading">

                        <span class="contact-info-icon">
                            <i class="bi bi-geo-alt"></i>
                        </span>

                        <h3>University Address</h3>

                    </div>

                    <div class="contact-info-details">
                        <p>
                            German Jordanian University (GJU)<br />
                            Amman-Madaba Street<br />
                            Jordan
                        </p>
                    </div>

                </div>


                <hr class="contact-info-divider" />


                <!-- Phone Number -->

                <div class="contact-info-item">

                    <div class="contact-info-heading">

                        <span class="contact-info-icon">
                            <i class="bi bi-telephone"></i>
                        </span>

                        <h3>Phone Number</h3>

                    </div>

                    <div class="contact-info-details">

                        <a href="tel:+96264294444">
                            +962 6 429 4444
                        </a>

                    </div>

                </div>


                <hr class="contact-info-divider" />


                <!-- General Email -->

                <div class="contact-info-item">

                    <div class="contact-info-heading">

                        <span class="contact-info-icon">
                            <i class="bi bi-envelope"></i>
                        </span>

                        <h3>General Email</h3>

                    </div>

                    <div class="contact-info-details">

                        <a href="mailto:info@gju.edu.jo">
                            info@gju.edu.jo
                        </a>

                    </div>

                </div>


                <hr class="contact-info-divider" />


                <!-- Internship Support -->

                <div class="contact-info-item">

                    <div class="contact-info-heading">

                        <span class="contact-info-icon">
                            <i class="bi bi-mortarboard"></i>
                        </span>

                        <h3>Internship Support</h3>

                    </div>

                    <div class="contact-info-details">

                        <a href="mailto:IO.Internship.Team@gju.edu.jo">
                            IO.Internship.Team@gju.edu.jo
                        </a>

                    </div>

                </div>


                <hr class="contact-info-divider" />


                <!-- Official Website -->

                <div class="contact-info-item">

                    <div class="contact-info-heading">

                        <span class="contact-info-icon">
                            <i class="bi bi-globe"></i>
                        </span>

                        <h3>Official Website</h3>

                    </div>

                    <div class="contact-info-details">

                        <a href="https://www.gju.edu.jo/"
                           target="_blank"
                           rel="noopener noreferrer">

                            www.gju.edu.jo

                        </a>

                    </div>

                </div>

            </div>

        </div>

    </div>

 main
</asp:Content>
