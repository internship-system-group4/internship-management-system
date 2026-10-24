<%@ Page Language="C#" MasterPageFile="~/Layout/Public.master" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="InternshipManagementSystem.Pages.AccountArea.Login" Title="Login | UIMS" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
<script type="importmap">{"imports":{"three":"<%= ResolveUrl("~/Assets/js/vendor/three.module.min.js") %>"}}</script>
<link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/login-campus.css?v=20261024-perf-1") %>" />
<%-- The scene's module graph and the shared character model start downloading with the page (the model at low priority,
     behind the form's own resources) instead of after a chain of imports. URLs match the imports exactly. --%>
<link rel="modulepreload" href="<%: ResolveUrl("~/Assets/js/vendor/three.module.min.js") %>" />
<link rel="modulepreload" href="<%: ResolveUrl("~/Assets/js/vendor/three.core.min.js") %>" />
<link rel="modulepreload" href="<%: ResolveUrl("~/Assets/js/vendor/addons/loaders/GLTFLoader.js") %>" />
<link rel="modulepreload" href="<%: ResolveUrl("~/Assets/js/vendor/addons/utils/BufferGeometryUtils.js") %>" />
<link rel="modulepreload" href="<%: ResolveUrl("~/Assets/js/login-campus-scene.js?v=20261024-perf-1") %>" />
<link rel="modulepreload" href="<%: ResolveUrl("~/Assets/js/login-campus-actors.js?v=20261024-perf-1") %>" />
<link rel="modulepreload" href="<%: ResolveUrl("~/Assets/js/home-gate-model.js") %>" />
<link rel="modulepreload" href="<%: ResolveUrl("~/Assets/js/home-campus-materials.js") %>" />
<link rel="preload" as="fetch" crossorigin="anonymous" fetchpriority="low" href="<%: ResolveUrl("~/Assets/models/people/Male_Adult_17_Animated.web.glb") %>" />
<% if (VerifiedDestination != null) { %><meta name="robots" content="noindex" /><% } %>
</asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="login-campus" data-login-campus data-destination="<%: VerifiedDestination ?? "" %>" data-logo="<%: ResolveUrl("~/Assets/images/gju-logo.png") %>">
 <div class="login-campus-scene" aria-hidden="true"><picture><source type="image/webp" srcset="<%: ResolveUrl("~/Assets/images/university/b1138b1f-421a-4fb1-9003-2d233d57c05c.webp") %>" /><img class="login-campus-photo" src="<%: ResolveUrl("~/Assets/images/university/b1138b1f-421a-4fb1-9003-2d233d57c05c.png") %>" alt="" width="1080" height="810" fetchpriority="high" decoding="async" /></picture><div data-campus-canvas></div></div>
 <div class="login-campus-layout">
 <section class="public-form login-campus-form" data-public-form="login" aria-labelledby="login-title">
 <span class="login-id-slot" aria-hidden="true"></span>
 <header class="login-id-header">
 <img class="login-campus-logo" src="<%: ResolveUrl("~/Assets/images/gju-logo.png") %>" alt="" width="94" height="70" />
 <div><strong lang="en" dir="ltr">German Jordanian University</strong><span lang="ar" dir="rtl">الجامعة الألمانية الأردنية</span></div>
 <span class="login-id-holo" aria-hidden="true"><img src="<%: ResolveUrl("~/Assets/images/gju-logo.png") %>" alt="" width="22" height="17" /></span>
 </header>
 <div class="login-id-body">
 <p class="login-id-kind"><%: L.T("Account.Login.UniversityAccessCard") %><span aria-hidden="true">UIMS</span></p>
 <h1 id="login-title"><%: L.T("Account.Login.WelcomeBack") %></h1><p class="public-form-intro"><%: L.T("Account.Login.YourNextStepStartsHereSign") %></p>
<%-- Card face (decorative): printed bilingual labels as on the physical campus card; only the account line is live. --%>
 <div class="login-id-preview" aria-hidden="true" data-id-card>
 <div class="login-id-face-band"><img src="<%: ResolveUrl("~/Assets/images/gju-logo.png") %>" alt="" width="22" height="16" /><b>GJU</b><span>UIMS ACCESS · بطاقة دخول</span></div>
 <div class="login-id-face">
 <div class="login-id-portrait"><svg viewBox="0 0 64 76" fill="none"><circle cx="32" cy="25" r="12"/><path d="M10 67v-6a22 22 0 0 1 44 0v6"/></svg></div>
 <div class="login-id-fields">
 <div class="login-id-writing"><span data-id-label><%: L.T("Account.Login.EmailAddress") %></span><bdi data-id-value data-placeholder="you@example.com">you@example.com</bdi><i class="login-id-ink"><i></i></i></div>
 <dl class="login-id-facts"><div><dt><bdi>ID No.</bdi> · الرقم</dt><dd dir="ltr">•••• ••••</dd></div><div><dt>Valid · صالحة</dt><dd dir="ltr"><%: DateTime.Today.Month >= 9 ? DateTime.Today.Year + "/" + ((DateTime.Today.Year + 1) % 100).ToString("00") : (DateTime.Today.Year - 1) + "/" + (DateTime.Today.Year % 100).ToString("00") %></dd></div></dl>
 </div>
 <svg class="login-id-chip" viewBox="0 0 40 32" fill="none"><rect x="1" y="1" width="38" height="30" rx="6"/><rect x="13" y="8" width="14" height="16" rx="3"/><path d="M1 10h12M1 22h12M27 10h12M27 22h12M20 1v7M20 24v7"/></svg>
 <svg class="login-id-ghost" viewBox="0 0 64 76" fill="none"><circle cx="32" cy="25" r="12"/><path d="M10 67v-6a22 22 0 0 1 44 0v6"/></svg>
 </div>
 <div class="login-id-sign"><span>Signature · التوقيع</span><i></i></div>
 <p class="login-id-micro">GERMAN JORDANIAN UNIVERSITY · الجامعة الألمانية الأردنية · GERMAN JORDANIAN UNIVERSITY · الجامعة الألمانية الأردنية · GERMAN JORDANIAN UNIVERSITY</p>
 <i class="login-id-holostrip"></i><i class="login-id-sheen"></i>
 </div>
 <input type="hidden" name="campusAnimation" value="0" data-campus-animation />
 <asp:Label ID="lblError" runat="server" CssClass="alert alert-danger d-block" Visible="false" role="alert" />
 <div class="public-field"><label for="<%= txtEmail.ClientID %>"><%: L.T("Account.Login.EmailAddress") %></label><asp:TextBox ID="txtEmail" runat="server" TextMode="Email" autocomplete="username" MaxLength="254" placeholder="you@example.com" aria-required="true" data-public-required="" data-required-message="<%$ Resources:Account, Login.EnterYourEmailAddress %>" aria-describedby="emailError" /><span id="emailError" class="public-field-error" aria-live="polite"></span></div>
 <div class="public-field"><label for="<%= txtPassword.ClientID %>"><%: L.T("Account.Login.Password") %></label><div class="public-password"><asp:TextBox ID="txtPassword" runat="server" TextMode="Password" autocomplete="current-password" aria-required="true" data-public-required="" data-required-message="<%$ Resources:Account, Login.EnterYourPassword %>" aria-describedby="passwordError" /><button id="toggleButton" type="button" aria-label="<%: L.T("Account.Login.ShowPassword") %>" aria-pressed="false" aria-controls="<%= txtPassword.ClientID %>"><%: L.T("Account.Login.Show") %></button></div><span id="passwordError" class="public-field-error" aria-live="polite"></span></div>
 <div class="public-form-links"><span><%: L.T("Account.Login.YourAccountStaysPrivate") %></span><asp:HyperLink ID="lnkForgotPassword" runat="server" NavigateUrl="~/Pages/Account/ForgotPassword.aspx" Text="<%$ Resources:Account, Login.ForgotPassword %>" /></div>
 <asp:Button ID="btnLogin" runat="server" Text="<%$ Resources:Account, Login.LogIn %>" CssClass="public-button" OnClientClick="return validateLogin();" OnClick="btnLogin_Click" />
 <p class="login-campus-status" data-campus-status role="status" aria-live="polite"><%: VerifiedDestination == null ? "" : "Welcome. Opening your portal…" %></p>
 <p class="public-form-note"><%: L.T("Account.Login.NeedAnAccount") %> <a href="<%: ResolveUrl("~/Pages/Public/Contact.aspx") %>"><%: L.T("Account.Login.ContactYourCoordinator") %></a>.</p>
 <% if (VerifiedDestination != null) { %><a class="login-campus-continue" href="<%: VerifiedDestination %>"><%: L.T("Account.Login.ContinueToYourPortal") %></a><% } %>
 <div class="login-id-footer" aria-hidden="true"><span class="login-id-barcode"></span><span class="login-id-mrz" dir="ltr">UIMS&lt;GJU&lt;&lt;GATE&lt;1&lt;&lt;&lt;&lt;&lt;&lt;</span></div>
 </div>
 </section>
 <% if (VerifiedDestination != null) { %><p class="login-campus-welcome" aria-hidden="true"><%: L.T("Account.Login.WelcomeYourEntryIsVerified") %></p><% } %>
 <div class="login-campus-caption"><span><%: L.T("Account.Login.GermanJordanianUniversityGate1") %></span><button type="button" data-campus-pause aria-pressed="false" hidden><%: L.T("Account.Login.PauseScene") %></button></div>
 </div>
</div>
<div class="login-campus-veil" aria-hidden="true"></div>
</asp:Content>
<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server"><script src="<%: ResolveUrl("~/Assets/js/public-forms.js?v=20261021-4") %>"></script><script defer src="<%: ResolveUrl("~/Assets/js/login-campus.js?v=20261024-perf-1") %>"></script></asp:Content>
