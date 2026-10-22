<%@ Page Language="C#" MasterPageFile="~/Layout/Public.master" AutoEventWireup="true" Async="true" CodeBehind="Contact.aspx.cs" Inherits="InternshipManagementSystem.Pages.PublicArea.Contact" Title="Contact | GJU Internship Management System" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
<meta name="description" content="Send a question about using UIMS, the GJU internship management student project." />
<link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/contact.css?v=20261023-3") %>" />
</asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<%-- Contact Us. Messages are saved to Firebase /ContactMessages (Name, Email, Subject, Message, Status "New", SubmittedAt)
     and read by Pages/Coordinator/ContactMessages.aspx. Styles: Assets/css/contact.css; behaviour: Assets/js/contact.js
     on top of the shared Assets/js/public-forms.js (validation, busy state, duplicate-send guard). --%>
<div class="public-page contact-page">
 <div class="contact-layout">
  <div class="contact-intro">
   <p class="contact-eyebrow">Contact UIMS</p>
   <h1 id="contact-title">Let&rsquo;s Start a Conversation</h1>
   <p class="contact-lead">Have a question about using UIMS? Send us a message and tell us how we can help.</p>
  </div>

  <figure class="contact-figure">
   <img src="<%: ResolveUrl("~/Assets/images/contact/contact-walkway.jpg") %>" alt="A paved walkway between limestone buildings at the German Jordanian University, with the courtyard waterwheel" width="1000" height="678" fetchpriority="high" />
   <%-- Decorative: the letter rises as the form becomes ready (contact.js sets --ready). --%>
   <span class="contact-envelope-tile" aria-hidden="true">
    <svg class="contact-envelope" data-contact-envelope viewBox="0 0 96 72" focusable="false">
     <path class="contact-envelope-flap" d="M10 31 48 6l38 25z" />
     <rect class="contact-envelope-back" x="10" y="30" width="76" height="38" rx="4" />
     <g class="contact-envelope-letter"><rect x="20" y="16" width="56" height="42" rx="2" /><path d="M28 26h40M28 33h40M28 40h26" /></g>
     <path class="contact-envelope-front" d="M10 33 48 53l38-20v31a4 4 0 0 1-4 4H14a4 4 0 0 1-4-4z" />
    </svg>
   </span>
  </figure>

  <aside class="contact-university" aria-labelledby="university-info-title">
   <h2 id="university-info-title">University information</h2>
   <p>This form reaches the UIMS coordination team, not the university&rsquo;s own offices. To reach German Jordanian University directly, use its official channels.</p>
   <ul>
    <li><a href="<%: Constants.UniversityWebsite %>" target="_blank" rel="noopener noreferrer">Official GJU website<span class="visually-hidden"> (opens in a new tab)</span> <span aria-hidden="true">&#8599;</span></a></li>
    <li><a href="<%: Constants.UniversityMapUrl %>" target="_blank" rel="noopener noreferrer">Main campus location, Amman Madaba Street<span class="visually-hidden"> (opens Google Maps in a new tab)</span> <span aria-hidden="true">&#8599;</span></a></li>
   </ul>
  </aside>

  <section class="public-form contact-card" id="contact-form" data-public-form="contact" data-contact-form aria-labelledby="message-title">
<% if (SentConfirmed) { %>
   <%-- Shown only after Firebase confirmed the save (post/redirect/get with a one-time session flag). --%>
   <div class="contact-sent" role="status">
    <svg class="contact-sent-envelope" viewBox="0 0 96 72" aria-hidden="true" focusable="false">
     <rect class="contact-sent-back" x="10" y="14" width="76" height="50" rx="4" />
     <path class="contact-sent-flap" d="M10 15 48 42l38-27" />
     <circle class="contact-sent-badge" cx="78" cy="58" r="13" />
     <path class="contact-sent-check" d="M71.5 58.5 76 63l8.5-9" />
    </svg>
    <h2 id="message-title" tabindex="-1">Message sent</h2>
    <p>Your message has been received. Thank you for contacting us.</p>
    <a class="public-button" href="<%: ResolveUrl("~/Pages/Public/Contact.aspx") %>#contact-form">Send another message</a>
   </div>
<% } else { %>
   <div class="contact-card-head">
    <h2 id="message-title">Send a message</h2>
    <p id="requiredNote">All fields are required<span aria-hidden="true"> (*)</span>.</p>
   </div>
   <div class="contact-readiness" data-contact-readiness hidden>
    <span class="contact-readiness-label">Form readiness</span>
    <span class="contact-readiness-bar" aria-hidden="true"><i></i><i></i><i></i><i></i></span>
    <span class="contact-readiness-count" data-readiness-text>0 of 4 fields ready</span>
   </div>
   <asp:Label ID="lblMessage" runat="server" Visible="false" role="alert" />
   <div class="public-field">
    <label for="<%= txtName.ClientID %>">Full Name <span class="contact-required" aria-hidden="true">*</span></label>
    <asp:TextBox ID="txtName" runat="server" MaxLength="100" minlength="2" autocomplete="name" dir="auto" placeholder="Your full name" aria-required="true" data-public-required="" data-required-message="Enter your full name." data-short-message="Your name needs at least 2 characters." aria-describedby="nameError" />
    <span id="nameError" class="public-field-error" aria-live="polite"><%: NameError %></span>
   </div>
   <div class="public-field">
    <label for="<%= txtEmail.ClientID %>">Email Address <span class="contact-required" aria-hidden="true">*</span></label>
    <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" MaxLength="254" autocomplete="email" inputmode="email" spellcheck="false" placeholder="you@example.com" aria-required="true" data-public-required="" data-required-message="Enter your email address." data-invalid-message="Enter an email address like name@example.com." aria-describedby="contactEmailError" />
    <span id="contactEmailError" class="public-field-error" aria-live="polite"><%: EmailError %></span>
   </div>
   <div class="public-field">
    <label for="<%= txtSubject.ClientID %>">Subject <span class="contact-required" aria-hidden="true">*</span></label>
    <asp:TextBox ID="txtSubject" runat="server" MaxLength="150" minlength="5" dir="auto" placeholder="What would you like to discuss?" aria-required="true" data-public-required="" data-required-message="Enter a subject for your message." data-short-message="Your subject needs at least 5 characters." aria-describedby="subjectError" />
    <span id="subjectError" class="public-field-error" aria-live="polite"><%: SubjectError %></span>
   </div>
   <div class="public-field">
    <label for="<%= txtMessage.ClientID %>">Message <span class="contact-required" aria-hidden="true">*</span></label>
    <asp:TextBox ID="txtMessage" runat="server" TextMode="MultiLine" Rows="7" maxlength="4000" minlength="20" dir="auto" aria-required="true" data-public-required="" data-required-message="Enter your message." data-short-message="Your message needs at least 20 characters." aria-describedby="messageError messageHint" />
    <span id="messageError" class="public-field-error" aria-live="polite"><%: MessageError %></span>
    <span class="contact-message-meta">
     <small id="messageHint" class="public-hint">20&ndash;4,000 characters. Share enough detail to help the team understand your question.</small>
     <span class="contact-counter" data-contact-counter aria-hidden="true" hidden>0 / 4,000</span>
    </span>
   </div>
   <div class="public-honeypot" aria-hidden="true"><label for="<%= Website.ClientID %>">Leave this field empty</label><asp:TextBox ID="Website" runat="server" tabindex="-1" autocomplete="off" /></div>
   <p class="contact-sensitive"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><rect x="5" y="10.5" width="14" height="10" rx="2" /><path d="M8.5 10.5V8a3.5 3.5 0 0 1 7 0v2.5" /></svg>Please do not include passwords or sensitive account information.</p>
   <span class="contact-submit">
    <asp:Button ID="btnSend" runat="server" Text="Send message" CssClass="public-button" OnClientClick="return validateContact();" OnClick="btnSend_Click" />
   </span>
   <p data-submit-status="" role="status" aria-live="polite" class="public-form-note"></p>
   <p class="public-form-note">Your message and email address are saved for the UIMS coordination team to review and follow up.</p>
<% } %>
  </section>
 </div>

 <section class="contact-help" aria-labelledby="help-title">
  <h2 id="help-title">Before you write</h2>
  <div class="contact-help-list">
   <details><summary>I need an internship account.</summary><p>Accounts are provided for your role. Include your name and student number, if applicable, so your coordinator can understand your request.</p></details>
   <details><summary>I forgot my password.</summary><p>You can <a href="<%: ResolveUrl("~/Pages/Account/ForgotPassword.aspx") %>">request a reset link</a> using your account email. If you cannot access that inbox, explain the issue in your message.</p></details>
   <details><summary>I have a question about my training.</summary><p>For task feedback or training decisions, start with your assigned company or academic supervisor. Contact the coordinator for general process or access questions.</p></details>
  </div>
 </section>
</div>
</asp:Content>
<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server">
<script src="<%: ResolveUrl("~/Assets/js/public-forms.js?v=20261022-1") %>"></script>
<script src="<%: ResolveUrl("~/Assets/js/contact.js?v=20261022-2") %>"></script>
</asp:Content>
