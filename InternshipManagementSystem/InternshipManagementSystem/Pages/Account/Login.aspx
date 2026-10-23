<%@ Page Language="C#" MasterPageFile="~/Layout/Public.master" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="InternshipManagementSystem.Pages.AccountArea.Login" Title="Login | UIMS" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
<link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/login-campus.css?v=20261023-security-1") %>" />
<script type="importmap">{"imports":{"three":"<%= ResolveUrl("~/Assets/js/vendor/three.module.min.js") %>"}}</script>
<% if (VerifiedDestination != null) { %><meta name="robots" content="noindex" /><% } %>
</asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="login-campus" data-login-campus data-destination="<%: VerifiedDestination ?? "" %>" data-logo="<%: ResolveUrl("~/Assets/images/gju-logo.png") %>">
 <div class="login-campus-layout">
 <section class="public-form login-campus-form" data-public-form="login" aria-labelledby="login-title">
 <h1 id="login-title"><%: L.T("Account.Login.WelcomeBack") %></h1><p class="public-form-intro"><%: L.T("Account.Login.YourNextStepStartsHereSign") %></p>
 <input type="hidden" name="campusAnimation" value="0" data-campus-animation />
 <asp:Label ID="lblError" runat="server" CssClass="alert alert-danger d-block" Visible="false" role="alert" />
 <div class="public-field"><label for="<%= txtEmail.ClientID %>"><%: L.T("Account.Login.EmailAddress") %></label><asp:TextBox ID="txtEmail" runat="server" TextMode="Email" autocomplete="username" MaxLength="254" placeholder="you@example.com" aria-required="true" data-public-required="" data-required-message="<%$ Resources:Account, Login.EnterYourEmailAddress %>" aria-describedby="emailError" /><span id="emailError" class="public-field-error" aria-live="polite"></span></div>
 <div class="public-field"><div class="login-password-heading"><label for="<%= txtPassword.ClientID %>"><%: L.T("Account.Login.Password") %></label></div><div class="public-password"><asp:TextBox ID="txtPassword" runat="server" TextMode="Password" autocomplete="current-password" aria-required="true" data-public-required="" data-required-message="<%$ Resources:Account, Login.EnterYourPassword %>" aria-describedby="passwordError" /><button id="toggleButton" type="button" aria-label="<%: L.T("Account.Login.ShowPassword") %>" aria-pressed="false" aria-controls="<%= txtPassword.ClientID %>"><%: L.T("Account.Login.Show") %></button></div><asp:HyperLink ID="lnkForgotPassword" runat="server" NavigateUrl="~/Pages/Account/ForgotPassword.aspx" Text="<%$ Resources:Account, Login.ForgotPassword %>" /><span id="passwordError" class="public-field-error" aria-live="polite"></span></div>
 <asp:Button ID="btnLogin" runat="server" Text="<%$ Resources:Account, Login.LogIn %>" CssClass="public-button" OnClientClick="return validateLogin();" OnClick="btnLogin_Click" />
 <p class="login-campus-status" data-campus-status role="status" aria-live="polite"><%: VerifiedDestination == null ? "" : L.T("Shared.Js.LoginOpening") %></p>
 <p class="login-campus-privacy"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" aria-hidden="true"><rect x="5" y="10" width="14" height="11" rx="2" /><path d="M8 10V7a4 4 0 0 1 8 0v3" /></svg><%: L.T("Account.Login.YourAccountStaysPrivate") %></p>
 <p class="public-form-note"><%: L.T("Account.Login.NeedAnAccount") %> <a href="<%: ResolveUrl("~/Pages/Public/Contact.aspx") %>"><%: L.T("Account.Login.ContactYourCoordinator") %></a>.</p>
 <% if (VerifiedDestination != null) { %><a class="login-campus-continue" href="<%: VerifiedDestination %>"><%: L.T("Account.Login.ContinueToYourPortal") %></a><% } %>
 </section>
 <% if (VerifiedDestination != null) { %><p class="login-campus-welcome" aria-hidden="true"><%: L.T("Account.Login.WelcomeYourEntryIsVerified") %></p><% } %>
 <figure class="login-campus-visual" data-campus-photo>
  <div class="login-campus-scene"><div class="login-campus-canvas" data-campus-canvas aria-hidden="true"></div><img class="login-campus-photo" src="<%: ResolveUrl("~/Assets/images/about/about-gate-1.jpg") %>" alt="<%: L.T("Account.Login.GermanJordanianUniversityGate1") %>" width="1080" height="810" fetchpriority="high" decoding="async" /></div>
  <figcaption class="login-campus-caption"><span><%: L.T("Account.Login.GermanJordanianUniversityGate1") %></span><button type="button" data-campus-pause data-pause-label="<%: L.T("Account.Login.PauseMotion") %>" data-resume-label="<%: L.T("Account.Login.ResumeMotion") %>" aria-pressed="false" hidden><%: L.T("Account.Login.PauseMotion") %></button></figcaption>
 </figure>
 </div>
</div>
</asp:Content>
<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server"><script src="<%: ResolveUrl("~/Assets/js/public-forms.js?v=20261021-4") %>"></script><script defer src="<%: ResolveUrl("~/Assets/js/login-campus.js?v=20261023-security-1") %>"></script></asp:Content>
