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
   <p class="contact-eyebrow"><%: L.T("Public.Contact.ContactUIMS") %></p>
   <h1 id="contact-title"><%: L.T("Public.Contact.LetSStartAConversation") %></h1>
   <p class="contact-lead"><%: L.T("Public.Contact.HaveAQuestionAboutUsingUIMS") %></p>
  </div>

  <figure class="contact-figure">
   <img src="<%: ResolveUrl("~/Assets/images/contact/contact-walkway.jpg") %>" alt="<%: L.T("Public.Contact.APavedWalkwayBetweenLimestoneBuildings") %>" width="1000" height="678" fetchpriority="high" />
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
   <h2 id="university-info-title"><%: L.T("Public.Contact.UniversityInformation") %></h2>
   <p><%: L.T("Public.Contact.ThisFormReachesTheUIMSCoordination") %></p>
   <ul>
    <li><a href="<%: Constants.UniversityWebsite %>" target="_blank" rel="noopener noreferrer"><%: L.T("Public.Contact.OfficialGJUWebsite") %><span class="visually-hidden"> <%: L.T("Public.Contact.OpensInANewTab") %></span> <span aria-hidden="true">&#8599;</span></a></li>
    <li><a href="<%: Constants.UniversityMapUrl %>" target="_blank" rel="noopener noreferrer"><%: L.T("Public.Contact.MainCampusLocationAmmanMadabaStreet") %><span class="visually-hidden"> <%: L.T("Public.Contact.OpensGoogleMapsInANew") %></span> <span aria-hidden="true">&#8599;</span></a></li>
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
    <h2 id="message-title" tabindex="-1"><%: L.T("Public.Contact.MessageSent") %></h2>
    <p><%: L.T("Public.Contact.YourMessageHasBeenReceivedThank") %></p>
    <a class="public-button" href="<%: ResolveUrl("~/Pages/Public/Contact.aspx") %>#contact-form"><%: L.T("Public.Contact.SendAnotherMessage") %></a>
   </div>
<% } else { %>
   <div class="contact-card-head">
    <h2 id="message-title"><%: L.T("Public.Contact.SendAMessage") %></h2>
    <p id="requiredNote"><%: L.T("Public.Contact.AllFieldsAreRequired") %><span aria-hidden="true"> (*)</span>.</p>
   </div>
   <div class="contact-readiness" data-contact-readiness hidden>
    <span class="contact-readiness-label"><%: L.T("Public.Contact.FormReadiness") %></span>
    <span class="contact-readiness-bar" aria-hidden="true"><i></i><i></i><i></i><i></i></span>
    <span class="contact-readiness-count" data-readiness-text><%: L.T("Public.Contact.0Of4FieldsReady") %></span>
   </div>
   <asp:Label ID="lblMessage" runat="server" Visible="false" role="alert" />
   <div class="public-field">
    <label for="<%= txtName.ClientID %>"><%: L.T("Public.Contact.FullName") %> <span class="contact-required" aria-hidden="true">*</span></label>
    <asp:TextBox ID="txtName" runat="server" MaxLength="100" minlength="2" autocomplete="name" dir="auto" placeholder="<%$ Resources:Public, Contact.YourFullName %>" aria-required="true" data-public-required="" data-required-message="<%$ Resources:Public, Contact.EnterYourFullName %>" data-short-message="<%$ Resources:Public, Contact.YourNameNeedsAtLeast2 %>" aria-describedby="nameError" />
    <span id="nameError" class="public-field-error" aria-live="polite"><%: NameError %></span>
   </div>
   <div class="public-field">
    <label for="<%= txtEmail.ClientID %>"><%: L.T("Public.Contact.EmailAddress") %> <span class="contact-required" aria-hidden="true">*</span></label>
    <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" MaxLength="254" autocomplete="email" inputmode="email" spellcheck="false" placeholder="you@example.com" aria-required="true" data-public-required="" data-required-message="<%$ Resources:Public, Contact.EnterYourEmailAddress %>" data-invalid-message="<%$ Resources:Public, Contact.EnterAnEmailAddressLikeName %>" aria-describedby="contactEmailError" />
    <span id="contactEmailError" class="public-field-error" aria-live="polite"><%: EmailError %></span>
   </div>
   <div class="public-field">
    <label for="<%= txtSubject.ClientID %>"><%: L.T("Public.Contact.Subject") %> <span class="contact-required" aria-hidden="true">*</span></label>
    <asp:TextBox ID="txtSubject" runat="server" MaxLength="150" minlength="5" dir="auto" placeholder="<%$ Resources:Public, Contact.WhatWouldYouLikeToDiscuss %>" aria-required="true" data-public-required="" data-required-message="<%$ Resources:Public, Contact.EnterASubjectForYourMessage %>" data-short-message="<%$ Resources:Public, Contact.YourSubjectNeedsAtLeast5 %>" aria-describedby="subjectError" />
    <span id="subjectError" class="public-field-error" aria-live="polite"><%: SubjectError %></span>
   </div>
   <div class="public-field">
    <label for="<%= txtMessage.ClientID %>"><%: L.T("Public.Contact.Message") %> <span class="contact-required" aria-hidden="true">*</span></label>
    <asp:TextBox ID="txtMessage" runat="server" TextMode="MultiLine" Rows="7" maxlength="4000" minlength="20" dir="auto" aria-required="true" data-public-required="" data-required-message="<%$ Resources:Public, Contact.EnterYourMessage %>" data-short-message="<%$ Resources:Public, Contact.YourMessageNeedsAtLeast20 %>" aria-describedby="messageError messageHint" />
    <span id="messageError" class="public-field-error" aria-live="polite"><%: MessageError %></span>
    <span class="contact-message-meta">
     <small id="messageHint" class="public-hint"><%: L.T("Public.Contact.204000CharactersShareEnough") %></small>
     <span class="contact-counter" data-contact-counter aria-hidden="true" hidden>0 / 4,000</span>
    </span>
   </div>
   <div class="public-honeypot" aria-hidden="true"><label for="<%= Website.ClientID %>"><%: L.T("Public.Contact.LeaveThisFieldEmpty") %></label><asp:TextBox ID="Website" runat="server" tabindex="-1" autocomplete="off" /></div>
   <p class="contact-sensitive"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><rect x="5" y="10.5" width="14" height="10" rx="2" /><path d="M8.5 10.5V8a3.5 3.5 0 0 1 7 0v2.5" /></svg><%: L.T("Public.Contact.PleaseDoNotIncludePasswordsOr") %></p>
   <span class="contact-submit">
    <asp:Button ID="btnSend" runat="server" Text="<%$ Resources:Public, Contact.SendMessage %>" CssClass="public-button" OnClientClick="return validateContact();" OnClick="btnSend_Click" />
   </span>
   <p data-submit-status="" role="status" aria-live="polite" class="public-form-note"></p>
   <p class="public-form-note"><%: L.T("Public.Contact.YourMessageAndEmailAddressAre") %></p>
<% } %>
  </section>
 </div>

 <section class="contact-help" aria-labelledby="help-title">
  <h2 id="help-title"><%: L.T("Public.Contact.BeforeYouWrite") %></h2>
  <div class="contact-help-list">
   <details><summary><%: L.T("Public.Contact.INeedAnInternshipAccount") %></summary><p><%: L.T("Public.Contact.AccountsAreProvidedForYourRole") %></p></details>
   <details><summary><%: L.T("Public.Contact.IForgotMyPassword") %></summary><p><%: L.T("Public.Contact.YouCan") %> <a href="<%: ResolveUrl("~/Pages/Account/ForgotPassword.aspx") %>"><%: L.T("Public.Contact.RequestAResetLink") %></a> <%: L.T("Public.Contact.UsingYourAccountEmailIfYou") %></p></details>
   <details><summary><%: L.T("Public.Contact.IHaveAQuestionAboutMy") %></summary><p><%: L.T("Public.Contact.ForTaskFeedbackOrTrainingDecisions") %></p></details>
  </div>
 </section>
</div>
</asp:Content>
<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server">
<script src="<%: ResolveUrl("~/Assets/js/public-forms.js?v=20261022-1") %>"></script>
<script src="<%: ResolveUrl("~/Assets/js/contact.js?v=20261022-2") %>"></script>
</asp:Content>
