<%@ Page Language="C#" MasterPageFile="~/Layout/Public.master" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="InternshipManagementSystem.Pages.AccountArea.Login" Title="Login | UIMS" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="public-auth">
 <div class="public-auth-intro"><h1>Welcome back.</h1><p class="public-lead">Your next step is waiting in your internship portal.</p><p>Sign in with the account provided for your student, company, academic or coordinator role.</p><img class="public-photo" src="<%: ResolveUrl("~/Assets/images/home-students.jpg") %>" alt="The GJU campus with students outside university buildings" width="960" height="685" /><p class="public-form-note">Need an account? <a href="<%: ResolveUrl("~/Pages/Public/Contact.aspx") %>">Contact your coordinator</a>.</p></div>
 <section class="public-form" data-public-form="login" aria-labelledby="login-title"><h2 id="login-title">Log in to UIMS</h2><p class="public-form-intro">Use your university internship account.</p>
 <asp:Label ID="lblError" runat="server" CssClass="alert alert-danger d-block" Visible="false" role="alert" />
 <div class="public-field"><label for="<%= txtEmail.ClientID %>">Email address</label><asp:TextBox ID="txtEmail" runat="server" TextMode="Email" autocomplete="username" MaxLength="254" placeholder="you@example.com" aria-required="true" data-public-required="" data-required-message="Enter your email address." aria-describedby="emailError" /><span id="emailError" class="public-field-error" aria-live="polite"></span></div>
 <div class="public-field"><label for="<%= txtPassword.ClientID %>">Password</label><div class="public-password"><asp:TextBox ID="txtPassword" runat="server" TextMode="Password" autocomplete="current-password" aria-required="true" data-public-required="" data-required-message="Enter your password." aria-describedby="passwordError" /><button id="toggleButton" type="button" aria-label="Show password" aria-pressed="false" aria-controls="<%= txtPassword.ClientID %>">Show</button></div><span id="passwordError" class="public-field-error" aria-live="polite"></span></div>
 <div class="public-form-links"><span>Your account stays private.</span><asp:HyperLink ID="lnkForgotPassword" runat="server" NavigateUrl="~/Pages/Account/ForgotPassword.aspx">Forgot password?</asp:HyperLink></div>
 <asp:Button ID="btnLogin" runat="server" Text="Login" CssClass="public-button" OnClientClick="return validateLogin();" OnClick="btnLogin_Click" />
 <p class="public-form-note">Your portal opens automatically based on your account role.</p></section>
</div>
</asp:Content>
<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server"><script src="<%: ResolveUrl("~/Assets/js/public-forms.js?v=20261021-4") %>"></script></asp:Content>
