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
 <div class="public-field"><label for="<%= txtMessage.ClientID %>">Message *</label><asp:TextBox ID="txtMessage" runat="server" TextMode="MultiLine" Rows="6" maxlength="4000" minlength="20" dir="auto" aria-required="true" data-public-required="" data-required-message="Enter your message." aria-describedby="messageError messageHint" /><span id="messageError" class="public-field-error" aria-live="polite"></span><small id="messageHint" class="public-hint">20–4,000 characters. Share enough detail to help the team understand your question.</small></div>
 <div class="public-honeypot" aria-hidden="true"><label for="<%= Website.ClientID %>">Leave this field empty</label><asp:TextBox ID="Website" runat="server" tabindex="-1" autocomplete="off" /></div>
 <asp:Button ID="btnSend" runat="server" Text="Send message" CssClass="public-button" OnClientClick="return validateContact();" OnClick="btnSend_Click" />
 <p data-submit-status="" role="status" aria-live="polite" class="public-form-note"></p>
 <p class="public-form-note">Your message and email address are saved for the coordination team to review and follow up.</p></section>
</div>
</asp:Content>
<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server"><script src="<%: ResolveUrl("~/Assets/js/public-forms.js?v=20261021-4") %>"></script></asp:Content>
