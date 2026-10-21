<%@ Page Language="C#" MasterPageFile="~/Layout/Student.master" AutoEventWireup="true" CodeBehind="MyApplications.aspx.cs" Inherits="InternshipManagementSystem.Pages.StudentArea.MyApplications" Title="My Applications" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"><link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/applications.css") %>" /></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="application-page">
    <div class="application-heading"><h2>My Applications</h2><p>Track the internships you have applied for.</p></div>
    <% if (Submitted) { %><div class="application-message application-success" role="status">Application submitted. Your status is Pending and the company can now review it.</div><% } %>
    <% if (LoadError != null) { %><div class="application-message" role="alert"><%: LoadError %></div><% } else { %>
    <div class="application-list">
        <% if (ApplicationsList.Count == 0) { %><div class="application-empty">No applications yet. Explore opportunities to find your next internship.</div><% } %>
        <% foreach (var item in ApplicationsList) { %>
        <article class="application-row">
            <div class="application-row-top"><div><h3><%: item.OpportunityTitle %></h3><div><%: item.CompanyName %></div><p class="application-help">Submitted <%: Time.Display(item.SubmittedAt) %></p></div><span class="application-status"><%: item.Status %></span></div>
            <% if (!string.IsNullOrWhiteSpace(item.RejectionReason)) { %><p class="application-help">Rejection reason: <%: item.RejectionReason %></p><% } %>
            <details><summary>View application</summary><p><%: item.CoverLetter %></p>
                <% if (InternshipManagementSystem.Data.ApplicationRepository.IsSafeDocumentUrl(item.CvUrl)) { %><a href="<%: item.CvUrl %>" target="_blank" rel="noopener noreferrer">Open CV &nearr;</a><% } %>
            </details>
        </article>
        <% } %>
    </div>
    <% } %>
</div>
</asp:Content>
