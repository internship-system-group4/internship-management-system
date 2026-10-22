<%@ Page Language="C#" MasterPageFile="~/Layout/Public.master" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="InternshipManagementSystem.Pages.AccountArea.Login" Title="Login | UIMS" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
<link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/login-campus.css") %>" />
<% if (VerifiedDestination != null) { %><meta name="robots" content="noindex" /><% } %>
</asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="login-campus" data-login-campus data-destination="<%: VerifiedDestination ?? "" %>" data-logo="<%: ResolveUrl("~/Assets/images/gju-logo.png") %>">
 <div class="login-campus-scene" aria-hidden="true"><img class="login-campus-photo" src="<%: ResolveUrl("~/Assets/images/university/b1138b1f-421a-4fb1-9003-2d233d57c05c.png") %>" alt="" /><div data-campus-canvas></div></div>
 <div class="login-campus-layout">
 <section class="public-form login-campus-form" data-public-form="login" aria-labelledby="login-title">
 <img class="login-campus-logo" src="<%: ResolveUrl("~/Assets/images/gju-logo.png") %>" alt="German Jordanian University" width="94" height="70" />
 <h1 id="login-title">Welcome back.</h1><p class="public-form-intro">Your next step starts here. Sign in to your internship portal.</p>
 <input type="hidden" name="campusAnimation" value="0" data-campus-animation />
 <asp:Label ID="lblError" runat="server" CssClass="alert alert-danger d-block" Visible="false" role="alert" />
 <div class="public-field"><label for="<%= txtEmail.ClientID %>">Email address</label><asp:TextBox ID="txtEmail" runat="server" TextMode="Email" autocomplete="username" MaxLength="254" placeholder="you@example.com" aria-required="true" data-public-required="" data-required-message="Enter your email address." aria-describedby="emailError" /><span id="emailError" class="public-field-error" aria-live="polite"></span></div>
 <div class="public-field"><label for="<%= txtPassword.ClientID %>">Password</label><div class="public-password"><asp:TextBox ID="txtPassword" runat="server" TextMode="Password" autocomplete="current-password" aria-required="true" data-public-required="" data-required-message="Enter your password." aria-describedby="passwordError" /><button id="toggleButton" type="button" aria-label="Show password" aria-pressed="false" aria-controls="<%= txtPassword.ClientID %>">Show</button></div><span id="passwordError" class="public-field-error" aria-live="polite"></span></div>
 <div class="public-form-links"><span>Your account stays private.</span><asp:HyperLink ID="lnkForgotPassword" runat="server" NavigateUrl="~/Pages/Account/ForgotPassword.aspx">Forgot password?</asp:HyperLink></div>
 <asp:Button ID="btnLogin" runat="server" Text="Log in" CssClass="public-button" OnClientClick="return validateLogin();" OnClick="btnLogin_Click" />
 <p class="login-campus-status" data-campus-status role="status" aria-live="polite"><%: VerifiedDestination == null ? "" : "Welcome. Opening your portal…" %></p>
 <p class="public-form-note">Need an account? <a href="<%: ResolveUrl("~/Pages/Public/Contact.aspx") %>">Contact your coordinator</a>.</p>
 <% if (VerifiedDestination != null) { %><a class="login-campus-continue" href="<%: VerifiedDestination %>">Continue to your portal</a><% } %>
 </section>
 <% if (VerifiedDestination != null) { %><p class="login-campus-welcome" aria-hidden="true">Welcome. Your entry is verified.</p><% } %>
 <div class="login-campus-caption"><span>German Jordanian University · Gate 1</span><button type="button" data-campus-pause aria-pressed="false" hidden>Pause scene</button></div>
 </div>
</div>
</asp:Content>
<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server"><script src="<%: ResolveUrl("~/Assets/js/public-forms.js?v=20261021-4") %>"></script><script defer src="<%: ResolveUrl("~/Assets/js/login-campus.js") %>"></script></asp:Content>
