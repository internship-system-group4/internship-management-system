<%@ Page Language="C#" MasterPageFile="~/Layout/Public.master" AutoEventWireup="true" CodeBehind="ForgotPassword.aspx.cs" Inherits="InternshipManagementSystem.Pages.AccountArea.ForgotPassword" Title="Password Recovery | UIMS" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="public-auth">
 <div class="public-auth-intro"><h1>Let's get you<br />back on track.</h1><p class="public-lead">Forgot your password? Request a reset link using the email address associated with your internship account.</p><p>If you cannot access that email address, your university coordinator can help you with the next step.</p><a class="public-text-link" href="<%: ResolveUrl("~/Pages/Public/Contact.aspx") %>">Contact the coordination team</a></div>
 <section class="public-form" data-public-form="recovery" aria-labelledby="recovery-title"><h2 id="recovery-title">Reset your password</h2><p class="public-form-intro">Enter your account email to request a reset link.</p>
 <asp:Label ID="lblMessage" runat="server" Visible="false" role="alert" />
 <div class="public-field"><label for="<%= txtEmail.ClientID %>">Email address</label><asp:TextBox ID="txtEmail" runat="server" TextMode="Email" autocomplete="email" MaxLength="254" placeholder="you@example.com" aria-required="true" data-public-required="" data-required-message="Enter your email address." aria-describedby="emailError recoveryHint" /><span id="emailError" class="public-field-error" aria-live="polite"></span><small id="recoveryHint" class="public-hint">Check your inbox and spam folder after requesting a link.</small></div>
 <asp:Button ID="btnSend" runat="server" Text="Send Reset Link" CssClass="public-button" OnClientClick="return validateEmail();" OnClick="btnSend_Click" />
 <p class="public-form-note">For your privacy, the response will not confirm whether an account exists for an email address.</p><a class="public-text-link" href="<%: ResolveUrl("~/Pages/Account/Login.aspx") %>">Back to Login</a>
 </section>
</div>
</asp:Content>
<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server"><script src="<%: ResolveUrl("~/Assets/js/public-forms.js?v=20261021-4") %>"></script></asp:Content>
