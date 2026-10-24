<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="Students.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.Students" Title="Student profile" %>
<%-- Student profile (opened from "View profile" on the Students page). --%>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Assets/css/students.css?v=20261024-theme-7") %>" />
</asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="students-page dir-page dir-profile">
        <a class="dir-back" href="<%= ResolveUrl("~/Pages/Coordinator/ManageStudents.aspx") %>"><span data-ui-icon="back" aria-hidden="true"></span> <%: L.T("Coordinator.Students.AllStudents") %></a>

        <% if (LoadError != null) { %>
        <div class="dir-card dir-empty-card"><span data-ui-icon="warning" aria-hidden="true"></span><p role="alert"><%: LoadError %></p><a class="btn btn-brand" href="<%= ResolveUrl("~/Pages/Coordinator/ManageStudents.aspx") %>"><%: L.T("Coordinator.Students.AllStudents") %></a></div>
        <% } else if (Row != null) { %>
        <section class="dir-card dir-profile-hero" aria-labelledby="profileName">
            <span class="dir-avatar dir-avatar-xl" aria-hidden="true"><%: Row.Initials %></span>
            <div class="dir-hero-text">
                <span class="dir-eyebrow"><%: L.T("Coordinator.Students.StudentProfile") %></span>
                <h2 id="profileName"><%: Row.FullName %></h2>
                <p><span data-ui-icon="mail" aria-hidden="true"></span> <%: Row.Email %> <span class='<%: Row.IsActive ? "dir-status is-active" : "dir-status is-inactive" %>'><%: Row.StatusText %></span></p>
            </div>
            <div class="dir-hero-actions">
                <% if (HasPlacement) { %><a class="btn btn-outline-primary" href="<%= ResolveUrl("~/Pages/Coordinator/PlacementDetails.aspx?id=" + Server.UrlEncode(Row.Id)) %>"><span data-ui-icon="chart" aria-hidden="true"></span> <%: L.T("Coordinator.Students.TrainingProgress") %></a><% } %>
                <a class="btn btn-brand" href="<%= ResolveUrl("~/Pages/Coordinator/ManageStudents.aspx?id=" + Server.UrlEncode(Row.Id)) %>"><span data-ui-icon="edit" aria-hidden="true"></span> <%: L.T("Coordinator.Students.ManageThisStudent") %></a>
            </div>
        </section>

        <ul class="dir-profile-stats">
            <li style="--dir-i:0"><span class="dir-stat-icon" data-ui-icon="clock" aria-hidden="true"></span><div><span class="dir-label"><%: L.T("Coordinator.Students.TrainingHours") %></span><strong><%: Row.HoursText %></strong><div class="dir-progress" aria-hidden="true"><span style="--dir-p:<%: Row.HoursPercent %>%"></span></div></div></li>
            <li style="--dir-i:1"><span class="dir-stat-icon" data-ui-icon="briefcase" aria-hidden="true"></span><div><span class="dir-label"><%: L.T("Coordinator.Students.Placement") %></span><strong><%: Row.PlacementText %></strong></div></li>
            <li style="--dir-i:2"><span class="dir-stat-icon" data-ui-icon="people" aria-hidden="true"></span><div><span class="dir-label"><%: L.T("Coordinator.Students.Group") %></span><strong><%: Row.GroupName %></strong></div></li>
            <li style="--dir-i:3"><span class="dir-stat-icon" data-ui-icon="study" aria-hidden="true"></span><div><span class="dir-label"><%: L.T("Coordinator.Students.AcademicSupervisor") %></span><strong><%: Row.SupervisorName %></strong></div></li>
        </ul>

        <div class="dir-profile-grid">
            <section class="dir-card"><h3><span data-ui-icon="person" aria-hidden="true"></span><%: L.T("Coordinator.Students.PersonalInformation") %></h3><dl class="dir-facts">
                <div><dt><%: L.T("Coordinator.Students.StudentNumber") %></dt><dd class="dir-id"><%: Row.StudentNumber %></dd></div>
                <div><dt><%: L.T("Coordinator.Students.LoginEmail") %></dt><dd><%: Row.Email %></dd></div>
                <div><dt><%: L.T("Coordinator.Students.Phone") %></dt><dd><%: Row.Phone %></dd></div>
                <div><dt><%: L.T("Coordinator.Students.AccountStatus") %></dt><dd><%: Row.StatusText %></dd></div>
                <div><dt><%: L.T("Coordinator.Students.CreatedOn") %></dt><dd><%: Row.CreatedText %></dd></div>
            </dl></section>
            <section class="dir-card"><h3><span data-ui-icon="study" aria-hidden="true"></span><%: L.T("Coordinator.Students.AcademicInformation") %></h3><dl class="dir-facts">
                <div><dt><%: L.T("Coordinator.Students.University") %></dt><dd><%: Row.University %></dd></div>
                <div><dt><%: L.T("Coordinator.Students.College") %></dt><dd><%: Row.College %></dd></div>
                <div><dt><%: L.T("Coordinator.Students.Major") %></dt><dd><%: Row.Major %></dd></div>
                <div><dt><%: L.T("Coordinator.Students.ApprovedHours") %></dt><dd><%: Row.ApprovedHours %></dd></div>
                <div><dt><%: L.T("Coordinator.Students.RequiredHours") %></dt><dd><%: Row.RequiredHours %></dd></div>
            </dl></section>
            <section class="dir-card dir-profile-wide"><h3><span data-ui-icon="briefcase" aria-hidden="true"></span><%: L.T("Coordinator.Students.InternshipPlacement") %></h3>
                <% if (!HasPlacement) { %>
                <p class="dir-muted"><%: L.T("Coordinator.Students.NoPlacementYet") %></p>
                <% } else { %>
                <dl class="dir-facts dir-facts-3">
                    <div><dt><%: L.T("Coordinator.Students.Company") %></dt><dd><%: Placement.CompanyName %></dd></div>
                    <div><dt><%: L.T("Coordinator.Students.Opportunity") %></dt><dd><%: Show(Placement.OpportunityTitle) %></dd></div>
                    <div><dt><%: L.T("Coordinator.Students.Status") %></dt><dd><%: L.Value("PlacementStatus", Placement.Status) %></dd></div>
                    <div><dt><%: L.T("Coordinator.Students.CompanySupervisor") %></dt><dd><%: Show(Placement.CompanySupervisorName) %></dd></div>
                    <div><dt><%: L.T("Coordinator.Students.StartDate") %></dt><dd><%: DateText(Placement.StartDate) %></dd></div>
                    <div><dt><%: L.T("Coordinator.Students.EndDate") %></dt><dd><%: DateText(Placement.EndDate) %></dd></div>
                </dl>
                <% } %>
            </section>
        </div>
        <% } %>
    </div>
</asp:Content>
