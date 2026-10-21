<%@ Page Language="C#" MasterPageFile="~/Layout/Public.master" AutoEventWireup="true" CodeBehind="AccessDenied.aspx.cs" Inherits="InternshipManagementSystem.Pages.PublicArea.AccessDenied" Title="Access Denied" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

    <%-- Access Denied - Owner: Ahmad - Card: A02 --%>

    <div class="container py-5 text-center">
        <h2 class="mb-3">Access Denied</h2>
        <p class="text-muted mb-4">You do not have permission to open this page.</p>

        <asp:HyperLink ID="lnkBack" runat="server" CssClass="btn btn-primary"></asp:HyperLink>
    </div>

</asp:Content>
