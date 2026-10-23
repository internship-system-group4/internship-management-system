<%@ Page Language="C#" MasterPageFile="~/Layout/Public.master" AutoEventWireup="true" CodeBehind="ForgotPassword.aspx.cs" Inherits="InternshipManagementSystem.Pages.AccountArea.ForgotPassword" Title="Password Recovery | UIMS" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="public-auth">
 <div class="public-auth-intro"><h1><%: L.T("Account.ForgotPassword.LetSGetYou") %><br /><%: L.T("Account.ForgotPassword.BackOnTrack") %></h1><p class="public-lead"><%: L.T("Account.ForgotPassword.ForgotYourPasswordRequestAReset") %></p><p><%: L.T("Account.ForgotPassword.IfYouCannotAccessThatEmail") %></p><a class="public-text-link" href="<%: ResolveUrl("~/Pages/Public/Contact.aspx") %>"><%: L.T("Account.ForgotPassword.ContactTheCoordinationTeam") %></a></div>
 <section class="public-form" data-public-form="recovery" aria-labelledby="recovery-title"><h2 id="recovery-title"><%: L.T("Account.ForgotPassword.ResetYourPassword") %></h2><p class="public-form-intro"><%: L.T("Account.ForgotPassword.EnterYourAccountEmailToRequest") %></p>
 <asp:Label ID="lblMessage" runat="server" Visible="false" role="alert" />
 <div class="public-field"><label for="<%= txtEmail.ClientID %>"><%: L.T("Account.ForgotPassword.EmailAddress") %></label><asp:TextBox ID="txtEmail" runat="server" TextMode="Email" autocomplete="email" MaxLength="254" placeholder="you@example.com" aria-required="true" data-public-required="" data-required-message="<%$ Resources:Account, ForgotPassword.EnterYourEmailAddress %>" aria-describedby="emailError recoveryHint" /><span id="emailError" class="public-field-error" aria-live="polite"></span><small id="recoveryHint" class="public-hint"><%: L.T("Account.ForgotPassword.CheckYourInboxAndSpamFolder") %></small></div>
 <asp:Button ID="btnSend" runat="server" Text="<%$ Resources:Account, ForgotPassword.SendResetLink %>" CssClass="public-button" OnClientClick="return validateEmail();" OnClick="btnSend_Click" />
 <p class="public-form-note"><%: L.T("Account.ForgotPassword.ForYourPrivacyTheResponseWill") %></p><a class="public-text-link" href="<%: ResolveUrl("~/Pages/Account/Login.aspx") %>"><%: L.T("Account.ForgotPassword.BackToLogin") %></a>
 </section>
</div>
</asp:Content>
<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server"><script src="<%: ResolveUrl("~/Assets/js/public-forms.js?v=20261021-4") %>"></script></asp:Content>
