<%@ Page Language="C#" MasterPageFile="~/Layout/Public.master" AutoEventWireup="true" CodeBehind="AccessDenied.aspx.cs" Inherits="InternshipManagementSystem.Pages.PublicArea.AccessDenied" Title="Access Denied | UIMS" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<section class="public-status" aria-labelledby="denied-title"><h1 id="denied-title">This page needs<br />different access.</h1><p class="public-lead">You do not have permission to open this page with your current account.</p><p>Return to the portal for your role, or contact your coordinator if you believe you should have access.</p><div class="public-actions"><asp:HyperLink ID="lnkBack" runat="server" CssClass="public-button" /><a class="public-text-link" href="<%: ResolveUrl("~/Pages/Public/Contact.aspx") %>">Get help with access</a></div></section>
</asp:Content>
