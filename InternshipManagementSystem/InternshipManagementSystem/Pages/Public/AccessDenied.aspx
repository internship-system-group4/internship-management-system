<%@ Page Language="C#" MasterPageFile="~/Layout/Public.master" AutoEventWireup="true" CodeBehind="AccessDenied.aspx.cs" Inherits="InternshipManagementSystem.Pages.PublicArea.AccessDenied" Title="Access Denied | UIMS" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<section class="public-status" aria-labelledby="denied-title"><h1 id="denied-title"><%: L.T("Public.AccessDenied.ThisPageNeeds") %><br /><%: L.T("Public.AccessDenied.DifferentAccess") %></h1><p class="public-lead"><%: L.T("Public.AccessDenied.YouDoNotHavePermissionTo") %></p><p><%: L.T("Public.AccessDenied.ReturnToThePortalForYour") %></p><div class="public-actions"><asp:HyperLink ID="lnkBack" runat="server" CssClass="public-button" /><a class="public-text-link" href="<%: ResolveUrl("~/Pages/Public/Contact.aspx") %>"><%: L.T("Public.AccessDenied.GetHelpWithAccess") %></a></div></section>
</asp:Content>
