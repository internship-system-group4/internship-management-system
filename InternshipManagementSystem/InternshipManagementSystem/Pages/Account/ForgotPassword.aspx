<%@ Page Language="C#" MasterPageFile="~/Layout/Public.master" AutoEventWireup="true" CodeBehind="ForgotPassword.aspx.cs" Inherits="InternshipManagementSystem.Pages.AccountArea.ForgotPassword" Title="Password Recovery | UIMS" %>
<%-- Password recovery at Gate 1. The page reuses the Login campus scene (login-campus-scene.js in 'recovery' mode) and the
     Login ID-card styles (login-campus.css); recovery-campus.css and recovery-campus.js hold only what differs here.
     The reset request itself is server-side (ForgotPassword.aspx.cs -> AuthService.SendPasswordResetEmail). --%>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
<script type="importmap">{"imports":{"three":"<%= ResolveUrl("~/Assets/js/vendor/three.module.min.js") %>"}}</script>
<link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/login-campus.css?v=20261024-perf-1") %>" />
<link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/recovery-campus.css?v=20261024-recovery-7") %>" />
<link rel="modulepreload" href="<%: ResolveUrl("~/Assets/js/vendor/three.module.min.js") %>" />
<link rel="modulepreload" href="<%: ResolveUrl("~/Assets/js/vendor/three.core.min.js") %>" />
<link rel="modulepreload" href="<%: ResolveUrl("~/Assets/js/vendor/addons/loaders/GLTFLoader.js") %>" />
<link rel="modulepreload" href="<%: ResolveUrl("~/Assets/js/vendor/addons/utils/BufferGeometryUtils.js") %>" />
<link rel="modulepreload" href="<%: ResolveUrl("~/Assets/js/login-campus-scene.js?v=20261024-recovery-7") %>" />
<link rel="modulepreload" href="<%: ResolveUrl("~/Assets/js/login-campus-actors.js?v=20261024-perf-1") %>" />
<link rel="modulepreload" href="<%: ResolveUrl("~/Assets/js/recovery-terminal.js?v=20261024-recovery-7") %>" />
<link rel="modulepreload" href="<%: ResolveUrl("~/Assets/js/home-gate-model.js") %>" />
<link rel="modulepreload" href="<%: ResolveUrl("~/Assets/js/home-campus-materials.js") %>" />
<link rel="preload" as="fetch" crossorigin="anonymous" fetchpriority="low" href="<%: ResolveUrl("~/Assets/models/people/Male_Adult_17_Animated.web.glb") %>" />
<meta name="robots" content="noindex" />
</asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="login-campus recovery-campus" data-recovery-campus data-result="<%: RecoveryResult %>"
     data-logo="<%: ResolveUrl("~/Assets/images/gju-logo.png") %>"
     data-screen-ready="<%: L.T("Account.ForgotPassword.ScreenReady") %>"
     data-screen-ready-hint="<%: L.T("Account.ForgotPassword.ScreenReadyHint") %>"
     data-screen-processing="<%: L.T("Account.ForgotPassword.ScreenProcessing") %>"
     data-screen-sent="<%: L.T("Account.ForgotPassword.ScreenSent") %>"
     data-screen-retry="<%: L.T("Account.ForgotPassword.ScreenRetry") %>">
 <div class="login-campus-scene" aria-hidden="true"><picture><source type="image/webp" srcset="<%: ResolveUrl("~/Assets/images/university/b1138b1f-421a-4fb1-9003-2d233d57c05c.webp") %>" /><img class="login-campus-photo" src="<%: ResolveUrl("~/Assets/images/university/b1138b1f-421a-4fb1-9003-2d233d57c05c.png") %>" alt="" width="1080" height="810" fetchpriority="high" decoding="async" /></picture><div data-campus-canvas></div></div>
 <div class="login-campus-layout recovery-campus-layout">
  <section class="public-form login-campus-form recovery-card" data-public-form="recovery" aria-labelledby="recovery-title">
   <span class="login-id-slot" aria-hidden="true"></span>
   <header class="login-id-header">
    <img class="login-campus-logo" src="<%: ResolveUrl("~/Assets/images/gju-logo.png") %>" alt="" width="94" height="70" />
    <div><strong lang="en" dir="ltr">German Jordanian University</strong><span lang="ar" dir="rtl">الجامعة الألمانية الأردنية</span></div>
    <span class="login-id-holo" aria-hidden="true"><img src="<%: ResolveUrl("~/Assets/images/gju-logo.png") %>" alt="" width="22" height="17" /></span>
   </header>
   <div class="login-id-body recovery-body">
    <p class="login-id-kind"><%: L.T("Account.ForgotPassword.PasswordRecovery") %><span aria-hidden="true">UIMS</span></p>

    <%-- Request state --%>
    <div class="recovery-request" data-recovery-request>
     <h1 id="recovery-title"><%: L.T("Account.ForgotPassword.RecoverYourAccess") %></h1>
     <p class="public-form-intro"><%: L.T("Account.ForgotPassword.EnterYourUniversityEmailAddress") %></p>
     <asp:Label ID="lblMessage" runat="server" Visible="false" role="alert" />
     <div class="public-field">
      <label for="<%= txtEmail.ClientID %>"><%: L.T("Account.ForgotPassword.EmailAddress") %></label>
      <div class="recovery-input">
       <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="5" width="18" height="14" rx="2.5"/><path d="m3.8 6.8 8.2 6.2 8.2-6.2"/></svg>
       <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" autocomplete="email" MaxLength="254" placeholder="you@example.com" spellcheck="false" autocapitalize="off" aria-required="true" data-public-required="" data-required-message="<%$ Resources:Account, ForgotPassword.EnterYourEmailAddress %>" data-invalid-message="<%$ Resources:Account, ForgotPassword.PleaseEnterAValidEmailAddress %>" aria-describedby="emailError recoveryHint" />
      </div>
      <span id="emailError" class="public-field-error" aria-live="polite"></span>
      <small id="recoveryHint" class="public-hint"><%: L.T("Account.ForgotPassword.UseTheEmailRegisteredWithUims") %></small>
     </div>
     <asp:Button ID="btnSend" runat="server" Text="<%$ Resources:Account, ForgotPassword.SendResetLink %>" CssClass="public-button recovery-submit" OnClientClick="return validateEmail();" OnClick="btnSend_Click" />
     <p class="login-campus-status" data-recovery-status role="status" aria-live="polite"></p>
    </div>

    <%-- Sent state: shown after the server has accepted the request (same wording for every address). --%>
    <div class="recovery-sent" data-recovery-sent tabindex="-1" aria-labelledby="recovery-sent-title">
     <span class="recovery-sent-mark" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="m6 12.5 4 4 8-9"/></svg></span>
     <h2 id="recovery-sent-title"><%: L.T("Account.ForgotPassword.CheckYourEmail") %></h2>
     <p><%: L.T("Account.ForgotPassword.IfAnAccountExistsForThis") %></p>
     <div class="recovery-sent-actions">
      <a class="public-button" href="<%: ResolveUrl("~/Pages/Account/Login.aspx") %>"><%: L.T("Account.ForgotPassword.BackToLogin") %></a>
      <button type="button" class="recovery-again" data-recovery-again><%: L.T("Account.ForgotPassword.UseADifferentEmail") %></button>
     </div>
    </div>

    <div class="recovery-info">
     <span class="recovery-info-icon" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"><circle cx="12" cy="12" r="9"/><path d="M12 11v5.5"/><circle cx="12" cy="7.6" r=".6" fill="currentColor"/></svg></span>
     <p><%: L.T("Account.ForgotPassword.CheckYourInboxAndSpamFolder") %> <%: L.T("Account.ForgotPassword.ForYourPrivacyTheResponseWill") %></p>
    </div>
    <p class="recovery-return" data-recovery-return><a href="<%: ResolveUrl("~/Pages/Account/Login.aspx") %>"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m10 6-6 6 6 6M4 12h16"/></svg><%: L.T("Account.ForgotPassword.RememberedItBackToLogin") %></a></p>
   </div>
  </section>
  <div class="login-campus-caption"><span><%: L.T("Account.Login.GermanJordanianUniversityGate1") %></span><button type="button" data-campus-pause aria-pressed="false" hidden><%: L.T("Account.Login.PauseScene") %></button></div>
 </div>
</div>
</asp:Content>
<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server"><script src="<%: ResolveUrl("~/Assets/js/public-forms.js?v=20261021-4") %>"></script><script defer src="<%: ResolveUrl("~/Assets/js/recovery-campus.js?v=20261024-recovery-7") %>"></script></asp:Content>
