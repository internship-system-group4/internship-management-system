<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="false" OnLoad="DashboardExperience_Load" CodeBehind="Dashboard.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.Dashboard" Title="Coordinator Dashboard" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="InternshipManagementSystem.Common" %>
<%-- The first request renders the workspace; the read-only content request calls
     the existing code-behind handler through the same CoordinatorPage guard.
     Full rendering remains available when JavaScript is unavailable. --%>
<script runat="server">
    protected void DashboardExperience_Load(object sender, EventArgs e)
    {
        Response.Cache.SetCacheability(System.Web.HttpCacheability.NoCache);
        Response.Cache.SetNoStore();
        if (IsPostBack) return;
        string view = Request.QueryString["dashboardView"];
        if (view == "content" || view == "full") Page_Load(sender, e);
    }
</script>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="<%: ResolveUrl("~/Assets/theme.css?v=20261023-motion-1") %>" />
    <link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/coordinator-dashboard.css?v=20261023-motion-1") %>" />
</asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <svg width="0" height="0" style="position:absolute;overflow:hidden" aria-hidden="true" focusable="false">
        <defs>
            <symbol id="icon-grid" viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7" rx="1.5"/><rect x="14" y="3" width="7" height="7" rx="1.5"/><rect x="3" y="14" width="7" height="7" rx="1.5"/><rect x="14" y="14" width="7" height="7" rx="1.5"/></symbol>
            <symbol id="icon-users" viewBox="0 0 24 24"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2m20 0v-2a4 4 0 0 0-3-3.87M15 3.13a4 4 0 0 1 0 7.75"/><circle cx="9" cy="7" r="4"/></symbol>
            <symbol id="icon-plus" viewBox="0 0 24 24"><path d="M12 5v14M5 12h14"/></symbol>
            <symbol id="icon-building" viewBox="0 0 24 24"><rect x="4" y="3" width="16" height="18" rx="2"/><path d="M9 21v-4h6v4M8 7h1m6 0h1m-8 4h1m6 0h1"/></symbol>
            <symbol id="icon-cap" viewBox="0 0 24 24"><path d="m2 9 10-5 10 5-10 5L2 9Zm4 2v6c4 3 8 3 12 0v-6m4-2v7"/></symbol>
            <symbol id="icon-briefcase" viewBox="0 0 24 24"><rect x="3" y="7" width="18" height="14" rx="2"/><path d="M8 7V4h8v3M3 12c6 4 12 4 18 0m-9 0v4"/></symbol>
            <symbol id="icon-check" viewBox="0 0 24 24"><path d="m8 12 3 3 5-6"/><rect x="4" y="3" width="16" height="18" rx="2"/></symbol>
            <symbol id="icon-chart" viewBox="0 0 24 24"><path d="M4 3v17h17M9 16v-4m5 4V8m5 8V4"/></symbol>
            <symbol id="icon-mail" viewBox="0 0 24 24"><rect x="3" y="5" width="18" height="14" rx="2"/><path d="m3 6 9 7 9-7"/></symbol>
            <symbol id="icon-calendar" viewBox="0 0 24 24"><rect x="3" y="5" width="18" height="16" rx="2"/><path d="M7 3v4m10-4v4M3 11h18m-12 4h1m4 0h1"/></symbol>
            <symbol id="icon-user" viewBox="0 0 24 24"><circle cx="12" cy="8" r="4"/><path d="M4 21v-2a8 8 0 0 1 16 0v2"/></symbol>
            <symbol id="icon-arrow" viewBox="0 0 24 24"><path d="M5 12h14m-5-5 5 5-5 5"/></symbol>
            <symbol id="icon-shield" viewBox="0 0 24 24"><path d="m12 3 8 3v6c0 5-8 9-8 9s-8-4-8-9V6l8-3Z"/><path d="m8 12 3 3 5-6"/></symbol>
        </defs>
    </svg>
    <div class="coordinator-dashboard">
<% var viewer = InternshipManagementSystem.Security.SessionHelper.Current; %>
        <section class="dashboard-heading" aria-labelledby="dashboard-title">
            <div>
                <div class="theme-eyebrow"><span class="dashboard-workspace-mark" aria-hidden="true"></span>Your coordinator workspace</div>
                <h2 id="dashboard-title">Good to see you, <%: viewer == null || string.IsNullOrWhiteSpace(viewer.FullName) ? "Coordinator" : viewer.FullName.Trim().Split(' ')[0] %>.</h2>
                <p>A clear view of your students, their progress, and what comes next.</p>
            </div>
            <div class="dashboard-heading-actions">
                <button class="dashboard-refresh" type="button" data-dashboard-refresh aria-label="Refresh program overview" title="Refresh overview"><svg class="theme-icon" width="18" height="18" viewBox="0 0 24 24" aria-hidden="true"><path d="M20 7v5h-5M4 17v-5h5M6.1 7a7 7 0 0 1 11.6-2L20 8M4 16l2.3 3A7 7 0 0 0 17.9 17" /></svg></button>
                <a class="btn btn-outline-secondary" href="<%: ResolveUrl("~/Pages/Coordinator/Placements.aspx") %>"><svg class="theme-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" aria-hidden="true"><use href="#icon-chart" /></svg>View placements</a>
                <a class="btn btn-brand" href="<%: ResolveUrl("~/Pages/Coordinator/AddStudent.aspx") %>"><svg class="theme-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" aria-hidden="true"><use href="#icon-plus" /></svg>Add student</a>
            </div>
        </section>
        <div id="dashboard-announcement" class="dashboard-load-status" role="status" aria-live="polite" aria-atomic="true"><span class="dashboard-status-dot" aria-hidden="true"></span><span data-dashboard-status><%: Summary != null ? "Overview up to date" : string.IsNullOrEmpty(LoadError) ? "Loading your program overview" : "Overview unavailable" %></span></div>
        <div id="dashboard-data" class="dashboard-data" data-load-state="<%: Summary != null ? "ready" : string.IsNullOrEmpty(LoadError) ? "loading" : "error" %>" aria-busy="<%: Summary == null && string.IsNullOrEmpty(LoadError) ? "true" : "false" %>">
        <% if (Summary == null && string.IsNullOrEmpty(LoadError)) { %>
        <div class="dashboard-skeleton" aria-hidden="true">
            <div class="skeleton-section-title skeleton-block"></div>
            <div class="dashboard-stats">
                <% for (int skeletonIndex = 0; skeletonIndex < 6; skeletonIndex++) { %>
                <div class="theme-card dashboard-stat skeleton-stat"><div class="skeleton-label skeleton-block"></div><div class="skeleton-number skeleton-block"></div><div class="skeleton-note skeleton-block"></div></div>
                <% } %>
            </div>
            <div class="theme-card skeleton-attention"><span class="skeleton-block skeleton-label"></span><span class="skeleton-block skeleton-note"></span></div>
            <div class="dashboard-columns"><div class="theme-card skeleton-panel"><div class="skeleton-block skeleton-label"></div><div class="skeleton-block skeleton-table-head"></div><div class="skeleton-row"><span class="skeleton-avatar skeleton-block"></span><span class="skeleton-line skeleton-block"></span></div></div><div class="theme-card skeleton-panel"><span class="skeleton-block skeleton-label"></span><span class="skeleton-block skeleton-action"></span><span class="skeleton-block skeleton-action"></span><span class="skeleton-block skeleton-action"></span></div></div>
        </div>
        <a class="dashboard-full-link theme-link" href="Dashboard.aspx?dashboardView=full">Open full dashboard</a>
        <noscript><p class="theme-alert">JavaScript is off. <a class="theme-link" href="Dashboard.aspx?dashboardView=full">Load the full dashboard</a>.</p><style>.dashboard-skeleton,.dashboard-load-status,.dashboard-refresh,.dashboard-full-link{display:none}</style></noscript>
        <% } %>
        <% if (!string.IsNullOrEmpty(LoadError)) { %>
        <div class="theme-alert" role="alert"><%: LoadError %> <a class="theme-link" href="<%: ResolveUrl("~/Pages/Coordinator/Dashboard.aspx") %>">Try again</a></div>
        <% } %>
<% if (Summary != null) { %>
<section aria-labelledby="overview-title"><div class="dashboard-section-heading"><h3 id="overview-title">Your program at a glance</h3><span>Current program overview</span></div><div class="dashboard-stats" aria-label="System statistics">
<a class="theme-card dashboard-stat" data-metric="students" href="<%: ResolveUrl("~/Pages/Coordinator/Students.aspx") %>"><div class="dashboard-stat-top"><span>Total students</span><span class="stat-icon teal"><svg class="theme-icon" width="16" height="16" viewBox="0 0 24 24" aria-hidden="true"><use href="#icon-users" /></svg></span></div><strong class="dashboard-stat-number"><%: Summary.Students %></strong><span class="dashboard-stat-note"><%: Summary.ActiveStudents + " active accounts" %></span></a>
<a class="theme-card dashboard-stat" data-metric="companies" href="<%: ResolveUrl("~/Pages/Coordinator/Companies.aspx") %>"><div class="dashboard-stat-top"><span>Partner companies</span><span class="stat-icon amber"><svg class="theme-icon" width="16" height="16" viewBox="0 0 24 24" aria-hidden="true"><use href="#icon-building" /></svg></span></div><strong class="dashboard-stat-number"><%: Summary.Companies %></strong><span class="dashboard-stat-note"><%: Summary.ActiveCompanies + " active partners" %></span></a>
<article class="theme-card dashboard-stat" data-metric="opportunities"><div class="dashboard-stat-top"><span>Open opportunities</span><span class="stat-icon green"><svg class="theme-icon" width="16" height="16" viewBox="0 0 24 24" aria-hidden="true"><use href="#icon-cap" /></svg></span></div><strong class="dashboard-stat-number"><%: Summary.OpenOpportunities %></strong><span class="dashboard-stat-note"><%: Summary.Opportunities + " total opportunities" %></span></article>
<a class="theme-card dashboard-stat" data-metric="placements" href="<%: ResolveUrl("~/Pages/Coordinator/Placements.aspx") %>"><div class="dashboard-stat-top"><span>Confirmed placements</span><span class="stat-icon blue"><svg class="theme-icon" width="16" height="16" viewBox="0 0 24 24" aria-hidden="true"><use href="#icon-briefcase" /></svg></span></div><strong class="dashboard-stat-number"><%: Summary.Placements %></strong><span class="dashboard-stat-note"><%: Summary.ActivePlacements + " confirmed or active" %></span></a>
<article class="theme-card dashboard-stat" data-metric="task-evaluations"><div class="dashboard-stat-top"><span>Task evaluations</span><span class="stat-icon teal"><svg class="theme-icon" width="16" height="16" viewBox="0 0 24 24" aria-hidden="true"><use href="#icon-check" /></svg></span></div><strong class="dashboard-stat-number"><%: Summary.TaskEvaluations %></strong><span class="dashboard-stat-note"><%: "Linked to confirmed placements" %></span></article>
<a class="theme-card dashboard-stat" data-metric="final-evaluations" href="<%: ResolveUrl("~/Pages/Coordinator/CompletionReview.aspx") %>"><div class="dashboard-stat-top"><span>Final evaluations</span><span class="stat-icon amber"><svg class="theme-icon" width="16" height="16" viewBox="0 0 24 24" aria-hidden="true"><use href="#icon-chart" /></svg></span></div><strong class="dashboard-stat-number"><%: Summary.CompanyFinals + Summary.AcademicFinals %></strong><span class="dashboard-stat-note"><%: Summary.CompanyFinals + " company / " + Summary.AcademicFinals + " academic" %></span></a></div></section>
<section class="theme-card dashboard-attention" aria-labelledby="attention-title"><h3 id="attention-title">Needs attention</h3><div><a class="theme-link" href="Placements.aspx?status=3"><strong><%: Summary.AwaitingCompletion %></strong> placements awaiting completion</a><span><strong><%: Summary.OverdueTasks %></strong> tasks past deadline</span><span><strong><%: Summary.PendingHours %> h</strong> awaiting approval</span></div></section>
        <div class="dashboard-columns">
            <section class="theme-card dashboard-panel" aria-labelledby="placements-title">
                <div class="dashboard-panel-head">
                    <div><h3 id="placements-title">Recent placements</h3><p>Small steps. Real progress.</p></div>
                    <a class="theme-link" href="<%: ResolveUrl("~/Pages/Coordinator/Placements.aspx") %>">View all &nbsp; &rarr;</a>
                </div>
                <% if (Summary.Recent.Count > 0) { %>
                <div class="theme-table-scroll" role="region" aria-label="Recent placements" tabindex="0">
                    <table class="uims-table">
                        <thead><tr><th scope="col">Student</th><th scope="col">Company</th><th scope="col">Hours</th><th scope="col">Status</th><th scope="col"><span class="visually-hidden">Details</span></th></tr></thead>
                        <tbody>
                            <% foreach (var row in Summary.Recent) { %>
                            <tr>
                                <td><div class="dashboard-student"><span class="dashboard-student-avatar"><%: string.IsNullOrWhiteSpace(row.StudentName) ? "?" : row.StudentName.Substring(0, 1).ToUpperInvariant() %></span><div><strong><%: row.StudentName %></strong><small><%: row.StudentNumber %></small></div></div></td>
                                <td><span class="dashboard-company"><%: row.Placement.CompanyName %></span></td>
                                <td><div class="dashboard-progress"><progress max="100" value="<%: Math.Max(0, Math.Min(100, row.HoursPercent)) %>" aria-label="<%: row.StudentName + " approved hours progress" %>"></progress><span><%: Math.Max(0, Math.Min(100, row.HoursPercent)) %>%</span></div><small class="dashboard-hours-detail"><%: row.HoursText %></small></td>
                                <td><span class="theme-badge <%: row.Placement.Status == PlacementStatus.Completed || row.Placement.Status == PlacementStatus.Active ? "is-success" : row.Placement.Status == PlacementStatus.Cancelled ? "is-danger" : row.Placement.Status == PlacementStatus.AwaitingCompletion ? "is-warning" : "is-info" %>"><%: row.StatusText %></span></td>
                                <td><a class="dashboard-placement-link" href="<%: ResolveUrl("~/Pages/Coordinator/PlacementDetails.aspx?id=" + Server.UrlEncode(row.Placement.Id)) %>" aria-label="<%: "View placement for " + row.StudentName %>"><svg class="theme-icon" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" aria-hidden="true"><use href="#icon-arrow" /></svg></a></td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
                <p class="dashboard-table-caption">Latest <%: Summary.Recent.Count %> <%: Summary.Recent.Count == 1 ? "placement" : "placements" %> &middot; Progress reflects approved training hours.</p>
                <% } else { %>
                <div class="theme-empty">
                    <svg class="theme-icon" width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" aria-hidden="true"><use href="#icon-briefcase" /></svg>
                    <h3>Every journey has a first step</h3>
                    <p>Confirmed internships will appear here as students begin their placements.</p>
                    <a class="theme-link" href="<%: ResolveUrl("~/Pages/Coordinator/Placements.aspx") %>">Go to placements &rarr;</a>
                </div>
                <% } %>
            </section>
            <aside class="dashboard-aside" aria-label="Coordinator actions">
                <section class="theme-card dashboard-actions">
                    <h3>Make things happen</h3><p>Your everyday actions, one click away.</p>
                    <a class="dashboard-action" href="<%: ResolveUrl("~/Pages/Coordinator/AddStudent.aspx") %>"><span class="stat-icon teal"><svg class="theme-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" aria-hidden="true"><use href="#icon-plus" /></svg></span><span><strong>Add a student</strong><small>Start a new internship journey</small></span><svg class="theme-icon" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" aria-hidden="true"><use href="#icon-arrow" /></svg></a>
                    <a class="dashboard-action" href="<%: ResolveUrl("~/Pages/Coordinator/Groups.aspx") %>"><span class="stat-icon blue"><svg class="theme-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" aria-hidden="true"><use href="#icon-users" /></svg></span><span><strong>Assign student groups</strong><small>Connect students and supervisors</small></span><svg class="theme-icon" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" aria-hidden="true"><use href="#icon-arrow" /></svg></a>
                    <a class="dashboard-action" href="<%: ResolveUrl("~/Pages/Meetings/Schedule.aspx") %>"><span class="stat-icon amber"><svg class="theme-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" aria-hidden="true"><use href="#icon-calendar" /></svg></span><span><strong>Schedule a meeting</strong><small>Make time for a conversation</small></span><svg class="theme-icon" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" aria-hidden="true"><use href="#icon-arrow" /></svg></a>
                </section>
                <section class="theme-card dashboard-review">
                    <div class="theme-eyebrow">The next milestone</div>
                    <h3><%: Summary.AwaitingCompletion > 0 ? Summary.AwaitingCompletion + " placements at the final stage" : "Room for the next milestone" %></h3>
                    <p><%: Summary.AwaitingCompletion > 0 ? "Check the final evaluations and completion requirements to guide each student through the final step." : "Open completion review to follow final evaluations and internship completion." %></p>
                    <a class="theme-link" href="<%: ResolveUrl("~/Pages/Coordinator/CompletionReview.aspx") %>">Open completion review &nbsp; &rarr;</a>
                </section>
            </aside>
        </div>
        <% } %>
        </div>
        <footer class="dashboard-footer"><span>German Jordanian University &middot; Internship management</span><span><svg class="theme-icon" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" aria-hidden="true"><use href="#icon-shield" /></svg>Coordinator workspace</span></footer>
    </div>
</asp:Content>

<asp:Content ID="DashboardScripts" ContentPlaceHolderID="scripts" runat="server">
    <script src="<%: ResolveUrl("~/Assets/js/coordinator-dashboard.js?v=20261023-motion-1") %>"></script>
</asp:Content>
