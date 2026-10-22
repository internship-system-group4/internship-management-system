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

    <style>
        .contact-page {
            --contact-navy: #153e69;
            --contact-border: #dce6f1;
            max-width: 1100px;
            margin: 45px auto 75px;
            padding: 0 20px;
            font-family: "Segoe UI", Arial, sans-serif;
            color: #173d68;
        }

        .contact-heading {
            text-align: center;
            margin-bottom: 35px;
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

        .contact-card {
            background: #fff;
            border: 1px solid var(--contact-border);
            border-radius: 15px;
            box-shadow: 0 8px 30px rgba(17, 57, 100, 0.06);
            padding: 35px;
            max-width: 780px;
            margin: auto;
        }

        .contact-card-title {
            font-size: 21px;
            font-weight: 700;
            margin-bottom: 24px;
            color: #123d68;
        }

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
            background: #fff;
            font-size: 14px;
            color: #173d68;
            box-sizing: border-box;
        }

        .contact-input:focus {
            border-color: #245b91;
            outline: none;
            box-shadow: 0 0 0 3px rgba(36, 91, 145, 0.10);
        }

        .contact-textarea {
            min-height: 145px;
            resize: vertical;
        }

        .contact-send {
            background: #194a78;
            border: 1px solid #194a78;
            border-radius: 7px;
            color: white;
            padding: 13px 30px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            width: 100%;
        }

        .contact-send:hover {
            background: #10365b;
        }

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

        @media (max-width: 768px) {
            .contact-page {
                margin-top: 25px;
            }

            .contact-card {
                padding: 22px;
            }

            .contact-heading h1 {
                font-size: 27px;
            }
        }
    </style>

</asp:Content>

<asp:Content ID="Body"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="contact-page">

        <div class="contact-heading">
            <h1>Contact Us</h1>

            <p>
                Have a question about internship opportunities
                or the internship management system?
                We're here to help.
            </p>
        </div>

        <div class="contact-card">

            <h2 class="contact-card-title">
                Send Us a Message
            </h2>

            <asp:Label ID="lblMessage"
                runat="server"
                Visible="false" />

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

    </div>

 main
</asp:Content>
