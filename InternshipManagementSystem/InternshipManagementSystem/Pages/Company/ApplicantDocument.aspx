<%@ Page Language="C#" MasterPageFile="~/Layout/Company.master" AutoEventWireup="true" CodeBehind="ApplicantDocument.aspx.cs" Inherits="InternshipManagementSystem.Pages.CompanyArea.ApplicantDocument" Title="Applicant Document" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"><link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/applications.css") %>" /></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="application-page company-applications">
    <a class="application-back" href="Applications.aspx">&larr; Back to applications</a>
    <div class="application-message" role="alert"><asp:Literal ID="MessageText" runat="server" Mode="Encode" /></div>
</div>
</asp:Content>
