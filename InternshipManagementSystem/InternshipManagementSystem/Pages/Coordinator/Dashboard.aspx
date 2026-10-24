<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.Dashboard" Title="Coordinator Dashboard" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="<%: ResolveUrl("~/Assets/theme.css") %>" />
    <link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/coordinator-dashboard.css?v=20261024-6") %>" />
</asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="coordinator-dashboard uims-theme">
        <section class="dashboard-heading" aria-labelledby="dashboard-title">
            <div>
                <div class="theme-eyebrow">Your coordinator workspace</div>
                <h2 id="dashboard-title">Good to see you, <%: FirstName %>.</h2>
                <p>A clear view of your students, their progress, and what comes next.</p>
            </div>
            <div class="dashboard-heading-actions">
                <a class="btn btn-outline-secondary" href="<%: ResolveUrl("~/Pages/Reports/Grades.aspx") %>"><svg class="theme-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" aria-hidden="true"><use href="#icon-chart" /></svg>View results</a>
                <a class="btn btn-brand" href="<%: ResolveUrl("~/Pages/Coordinator/AddStudent.aspx") %>"><svg class="theme-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" aria-hidden="true"><use href="#icon-plus" /></svg>Add student</a>
            </div>
        </section>
        <% if (!string.IsNullOrEmpty(LoadError)) { %>
        <div class="theme-alert" role="alert"><%: LoadError %> <a class="theme-link" href="<%: ResolveUrl("~/Pages/Coordinator/Dashboard.aspx") %>">Try again</a></div>
        <% } %>
        <section class="dashboard-hero" aria-labelledby="hero-title">
            <div class="dashboard-hero-copy">
                <div class="theme-eyebrow">From classroom to career</div>
                <h3 id="hero-title">Great futures start with good guidance.</h3>
                <p>Keep every internship moving forward. Connect the right people, follow their progress, and celebrate the milestones.</p>
                <a class="theme-link" href="<%: ResolveUrl("~/Pages/Coordinator/Placements.aspx") %>">Explore placements &nbsp; &rarr;</a>
            </div>
            <svg class="dashboard-hero-art" viewBox="0 0 220 160" fill="none" aria-hidden="true">
                <circle cx="121" cy="82" r="69" fill="#d6e7d9" />
                <path d="M25 138h177M43 138V83h38v55m15 0V57h38v81m15 0V27h38v111" stroke="#699887" stroke-width="1.3" />
                <path d="M44 84h36v54H44z" fill="#c0dacb" /><path d="M97 58h36v80H97z" fill="#9bc4af" /><path d="M150 28h36v110h-36z" fill="#4d9680" />
                <path d="m42 62 44-29 36 4 47-29m-15-1 16-1-2 16" stroke="#264e40" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" />
                <rect x="20" y="89" width="103" height="53" rx="8" fill="white" stroke="#c6d9ce" transform="rotate(-8 20 89)" />
                <circle cx="40" cy="106" r="9" fill="#edf5ef" /><path d="m36 106 3 3 5-6" stroke="#087f75" stroke-width="1.6" stroke-linecap="round" />
                <path d="m59 101 42-6m-42 15 28-4m-53 22 69-10" stroke="#a7bfb3" stroke-width="3" stroke-linecap="round" />
                <circle cx="185" cy="44" r="18" fill="#edb669" /><path d="m178 44 5 5 9-10" stroke="#614318" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
                <path d="M31 30v10m-5-5h10m164 65v8m-4-4h8" stroke="#87aa91" stroke-width="1.5" stroke-linecap="round" />
            </svg>
        </section>
        <section aria-labelledby="overview-title">
            <div class="dashboard-section-heading"><h3 id="overview-title">Your program at a glance</h3><span>Current program overview</span></div>
            <div class="dashboard-stats">
                <a class="theme-card dashboard-stat" href="<%: ResolveUrl("~/Pages/Coordinator/Students.aspx") %>">
                    <div class="dashboard-stat-top"><span>Total students</span><span class="stat-icon teal"><svg class="theme-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" aria-hidden="true"><use href="#icon-users" /></svg></span></div>
                    <strong class="dashboard-stat-number"><%: StudentCount %></strong>
                    <span class="dashboard-stat-note">Student accounts</span>
                </a>
                <a class="theme-card dashboard-stat" href="<%: ResolveUrl("~/Pages/Coordinator/Placements.aspx") %>">
                    <div class="dashboard-stat-top"><span>Active placements</span><span class="stat-icon blue"><svg class="theme-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" aria-hidden="true"><use href="#icon-briefcase" /></svg></span></div>
                    <strong class="dashboard-stat-number"><%: ActivePlacementCount %></strong>
                    <span class="dashboard-stat-note">Confirmed & in progress</span>
                </a>
                <a class="theme-card dashboard-stat" href="<%: ResolveUrl("~/Pages/Coordinator/Companies.aspx") %>">
                    <div class="dashboard-stat-top"><span>Partner companies</span><span class="stat-icon amber"><svg class="theme-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" aria-hidden="true"><use href="#icon-building" /></svg></span></div>
                    <strong class="dashboard-stat-number"><%: CompanyCount %></strong>
                    <span class="dashboard-stat-note">Registered companies</span>
                </a>
                <article class="theme-card dashboard-stat">
                    <div class="dashboard-stat-top"><span>Open opportunities</span><span class="stat-icon green"><svg class="theme-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" aria-hidden="true"><use href="#icon-cap" /></svg></span></div>
                    <strong class="dashboard-stat-number"><%: OpportunityCount %></strong>
                    <span class="dashboard-stat-note">Available to students</span>
                </article>
            </div>
        </section>
        <div class="dashboard-columns">
            <section class="theme-card dashboard-panel" aria-labelledby="placements-title">
                <div class="dashboard-panel-head">
                    <div><h3 id="placements-title">Recent placements</h3><p>Small steps. Real progress.</p></div>
                    <a class="theme-link" href="<%: ResolveUrl("~/Pages/Coordinator/Placements.aspx") %>">View all &nbsp; &rarr;</a>
                </div>
                <% if (RecentPlacements.Count > 0) { %>
                <div class="theme-table-scroll" role="region" aria-label="Recent placements" tabindex="0">
                    <table class="uims-table">
                        <thead><tr><th scope="col">Student</th><th scope="col">Company</th><th scope="col">Hours</th><th scope="col">Status</th><th scope="col"><span class="visually-hidden">Details</span></th></tr></thead>
                        <tbody>
                            <% foreach (var placement in RecentPlacements) { %>
                            <tr>
                                <td><div class="dashboard-student"><span class="dashboard-student-avatar"><%: Initials(placement.StudentName) %></span><div><strong><%: placement.StudentName %></strong><small><%: placement.OpportunityTitle %></small></div></div></td>
                                <td><span class="dashboard-company"><%: placement.CompanyName %></span></td>
                                <td><div class="dashboard-progress"><progress max="100" value="<%: Progress(placement) %>" aria-label="<%: placement.StudentName + " approved hours progress" %>"></progress><span><%: Progress(placement) %>%</span></div></td>
                                <td><span class="theme-badge <%: StatusClass(placement.Status) %>"><%: StatusLabel(placement.Status) %></span></td>
                                <td><a class="dashboard-placement-link" href="<%: ResolveUrl("~/Pages/Coordinator/PlacementDetails.aspx?id=" + Server.UrlEncode(placement.Id)) %>" aria-label="<%: "View placement for " + placement.StudentName %>"><svg class="theme-icon" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" aria-hidden="true"><use href="#icon-arrow" /></svg></a></td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
                <p class="dashboard-table-caption">Latest <%: RecentPlacements.Count %> placements &middot; Progress reflects approved training hours.</p>
                <% } else { %>
                <div class="theme-empty">
                    <svg class="theme-icon" width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" aria-hidden="true"><use href="#icon-briefcase" /></svg>
                    <h3><%: HasData ? "Every journey has a first step" : "Your overview will be here" %></h3>
                    <p><%: HasData ? "Confirmed internships will appear here as students begin their placements." : "We could not load placements. Try refreshing this page." %></p>
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
                    <h3><%: ReviewHeading %></h3>
                    <p><%: ReviewDescription %></p>
                    <a class="theme-link" href="<%: ResolveUrl("~/Pages/Coordinator/CompletionReview.aspx") %>">Open completion review &nbsp; &rarr;</a>
                </section>
            </aside>
        </div>
        <footer class="dashboard-footer"><span>UIMS &middot; A better path from learning to doing.</span><span><svg class="theme-icon" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" aria-hidden="true"><use href="#icon-shield" /></svg>Coordinator workspace</span></footer>
    </div>
</asp:Content>
