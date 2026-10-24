<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="SupervisorProfile.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.SupervisorProfile" Title="Supervisor profile" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="InternshipManagementSystem.Pages.CoordinatorArea" %>
<%-- Supervisor profile (opened from "View profile" on Academic supervisors and Manage companies). --%>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="students-page dir-page dir-profile">
        <a class="dir-back" href="<%= BackUrl %>"><span data-ui-icon="back" aria-hidden="true"></span> <%: BackText %></a>

        <% if (LoadError != null) { %>
        <div class="dir-card dir-empty-card"><span data-ui-icon="warning" aria-hidden="true"></span><p role="alert"><%: LoadError %></p><a class="btn btn-brand" href="<%= BackUrl %>"><%: BackText %></a></div>
        <% } else if (Person != null) { %>
        <section class="dir-card dir-profile-hero" aria-labelledby="profileName">
            <span class="dir-avatar dir-avatar-xl" aria-hidden="true"><%: StudentDirectoryRow.MakeInitials(Person.FullName) %></span>
            <div class="dir-hero-text">
                <span class="dir-eyebrow"><%: IsAcademic ? L.T("Coordinator.SupervisorProfile.AcademicProfile") : L.T("Coordinator.SupervisorProfile.CompanyProfile") %></span>
                <h2 id="profileName"><%: Show(Person.FullName) %></h2>
                <p><span data-ui-icon="mail" aria-hidden="true"></span> <%: Show(Person.Email) %> <span class='<%: Person.IsActive ? "dir-status is-active" : "dir-status is-inactive" %>'><%: StatusText %></span></p>
            </div>
            <% if (!string.IsNullOrWhiteSpace(Person.Email)) { %>
            <div class="dir-hero-actions">
                <a class="btn dir-ghost" href="mailto:<%: Person.Email %>"><span data-ui-icon="mail" aria-hidden="true"></span> <%: L.T("Coordinator.SupervisorProfile.SendEmail") %></a>
            </div>
            <% } %>
        </section>

        <% if (IsAcademic) { %>
        <ul class="dir-profile-stats">
            <li style="--dir-i:0"><span class="dir-stat-icon" data-ui-icon="people" aria-hidden="true"></span><div><span class="dir-label"><%: L.T("Coordinator.SupervisorProfile.Groups") %></span><strong><%: GroupNames.Count %></strong></div></li>
            <li style="--dir-i:1"><span class="dir-stat-icon" data-ui-icon="person" aria-hidden="true"></span><div><span class="dir-label"><%: L.T("Coordinator.SupervisorProfile.Students") %></span><strong><%: StudentRows.Count %></strong></div></li>
            <li style="--dir-i:2"><span class="dir-stat-icon" data-ui-icon="briefcase" aria-hidden="true"></span><div><span class="dir-label"><%: L.T("Coordinator.SupervisorProfile.WithPlacement") %></span><strong><%: PlacedCount %></strong></div></li>
            <li style="--dir-i:3"><span class="dir-stat-icon" data-ui-icon="study" aria-hidden="true"></span><div><span class="dir-label"><%: L.T("Coordinator.SupervisorProfile.Department") %></span><strong><%: Show(Academic.Department) %></strong></div></li>
        </ul>
        <% } else { %>
        <ul class="dir-profile-stats">
            <li style="--dir-i:0"><span class="dir-stat-icon" data-ui-icon="building" aria-hidden="true"></span><div><span class="dir-label"><%: L.T("Coordinator.SupervisorProfile.Company") %></span><strong><%: Show(Company != null ? Company.Name : CompanyPerson.CompanyName) %></strong></div></li>
            <li style="--dir-i:1"><span class="dir-stat-icon" data-ui-icon="briefcase" aria-hidden="true"></span><div><span class="dir-label"><%: L.T("Coordinator.SupervisorProfile.JobTitle") %></span><strong><%: Show(CompanyPerson.JobTitle) %></strong></div></li>
            <li style="--dir-i:2"><span class="dir-stat-icon" data-ui-icon="people" aria-hidden="true"></span><div><span class="dir-label"><%: L.T("Coordinator.SupervisorProfile.Interns") %></span><strong><%: StudentRows.Count %></strong></div></li>
            <li style="--dir-i:3"><span class="dir-stat-icon" data-ui-icon="calendar" aria-hidden="true"></span><div><span class="dir-label"><%: L.T("Coordinator.SupervisorProfile.CreatedOn") %></span><strong><%: CreatedText %></strong></div></li>
        </ul>
        <% } %>

        <div class="dir-profile-grid">
            <section class="dir-card"><h3><span data-ui-icon="person" aria-hidden="true"></span><%: L.T("Coordinator.SupervisorProfile.ContactInformation") %></h3><dl class="dir-facts">
                <div><dt><%: L.T("Coordinator.SupervisorProfile.LoginEmail") %></dt><dd><%: Show(Person.Email) %></dd></div>
                <div><dt><%: L.T("Coordinator.SupervisorProfile.Phone") %></dt><dd><%: Show(Person.PhoneNumber) %></dd></div>
                <div><dt><%: L.T("Coordinator.SupervisorProfile.AccountStatus") %></dt><dd><%: StatusText %></dd></div>
                <div><dt><%: L.T("Coordinator.SupervisorProfile.CreatedOn") %></dt><dd><%: CreatedText %></dd></div>
            </dl></section>

            <% if (IsAcademic) { %>
            <section class="dir-card"><h3><span data-ui-icon="study" aria-hidden="true"></span><%: L.T("Coordinator.SupervisorProfile.AcademicInformation") %></h3><dl class="dir-facts">
                <div><dt><%: L.T("Coordinator.SupervisorProfile.Department") %></dt><dd><%: Show(Academic.Department) %></dd></div>
                <div><dt><%: L.T("Coordinator.SupervisorProfile.AcademicRank") %></dt><dd><%: Show(Academic.AcademicRank) %></dd></div>
                <div><dt><%: L.T("Coordinator.SupervisorProfile.Groups") %></dt><dd>
                    <% if (GroupNames.Count == 0) { %><%: L.T("Coordinator.SupervisorProfile.NoGroups") %><% } else { %>
                    <ul class="dir-chip-list"><% foreach (string name in GroupNames) { %><li><%: name %></li><% } %></ul><% } %>
                </dd></div>
            </dl></section>
            <% } else { %>
            <section class="dir-card"><h3><span data-ui-icon="building" aria-hidden="true"></span><%: L.T("Coordinator.SupervisorProfile.CompanyInformation") %></h3><dl class="dir-facts">
                <div><dt><%: L.T("Coordinator.SupervisorProfile.Company") %></dt><dd><%: Show(Company != null ? Company.Name : CompanyPerson.CompanyName) %></dd></div>
                <div><dt><%: L.T("Coordinator.SupervisorProfile.Industry") %></dt><dd><%: Show(Company == null ? null : Company.Industry) %></dd></div>
                <div><dt><%: L.T("Coordinator.SupervisorProfile.Address") %></dt><dd><%: Show(Company == null ? null : Company.Address) %></dd></div>
                <div><dt><%: L.T("Coordinator.SupervisorProfile.Website") %></dt><dd><% if (Company != null && IsWebLink(Company.Website)) { %><a href="<%: Company.Website %>" target="_blank" rel="noopener noreferrer"><%: Company.Website %></a><% } else { %><%: Show(Company == null ? null : Company.Website) %><% } %></dd></div>
                <div><dt><%: L.T("Coordinator.SupervisorProfile.CompanyContact") %></dt><dd><%: Show(Company == null ? null : string.Join(" · ", new[] { Company.ContactEmail, Company.ContactPhone }.Where(v => !string.IsNullOrWhiteSpace(v)))) %></dd></div>
            </dl></section>
            <% } %>

            <section class="dir-card dir-profile-wide" aria-labelledby="supervisedTitle">
                <div class="dir-card-head">
                    <div><h3 id="supervisedTitle"><%: IsAcademic ? L.T("Coordinator.SupervisorProfile.SupervisedStudents") : L.T("Coordinator.SupervisorProfile.CompanyInterns") %> <span class="dir-count"><%: StudentRows.Count %></span></h3>
                    <p><%: IsAcademic ? L.T("Coordinator.SupervisorProfile.SupervisedStudentsHelp") : L.T("Coordinator.SupervisorProfile.CompanyInternsHelp") %></p></div>
                </div>
                <% if (StudentRows.Count == 0) { %>
                <p class="dir-empty"><span data-ui-icon="people" aria-hidden="true"></span><%: IsAcademic ? L.T("Coordinator.SupervisorProfile.NoStudents") : L.T("Coordinator.SupervisorProfile.NoInterns") %></p>
                <% } else { %>
                <div class="table-responsive">
                    <table class="dir-table">
                        <thead><tr><th scope="col"><%: L.T("Coordinator.SupervisorProfile.Student") %></th><th scope="col"><%: L.T("Coordinator.SupervisorProfile.StudentNumber") %></th><th scope="col"><%: L.T("Coordinator.SupervisorProfile.Placement") %></th><th scope="col"><%: L.T("Coordinator.SupervisorProfile.TrainingHours") %></th><th scope="col" class="dir-actions-col"><%: L.T("Coordinator.SupervisorProfile.Action") %></th></tr></thead>
                        <tbody>
                        <% foreach (var row in StudentRows) { %>
                            <tr>
                                <td><div class="dir-person"><span class="dir-avatar" aria-hidden="true"><%: row.Initials %></span><div><strong><%: row.FullName %></strong><small><%: row.Email %></small></div></div></td>
                                <td><span class="dir-id" title="<%: row.StudentNumber %>"><%: row.StudentNumber %></span></td>
                                <td><%: row.PlacementText %></td>
                                <td><div class="dir-hours"><div class="dir-progress" aria-hidden="true"><span style="--dir-p:<%: row.HoursPercent %>%"></span></div><small><%: row.HoursText %></small></div></td>
                                <td><div class="dir-actions"><a class="dir-btn dir-btn-primary" href="<%: row.ProfileUrl %>"><span data-ui-icon="person" aria-hidden="true"></span> <%: L.T("Coordinator.ManageStudents.ViewProfile") %><span class="visually-hidden">: <%: row.FullName %></span></a></div></td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
                <% } %>
            </section>
        </div>
        <% } %>
    </div>
</asp:Content>
