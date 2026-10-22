<%@ Control Language="C#" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="InternshipManagementSystem.Security" %>
<%@ Import Namespace="InternshipManagementSystem.Common" %>
<script runat="server">
    protected string NavigationAttributes(string path)
    {
        string current = Request.AppRelativeCurrentExecutionFilePath;
        // Exact aliases for detail/edit destinations already grouped by the existing masters.
        switch (current.ToLowerInvariant())
        {
            case "~/pages/student/apply.aspx": current = "~/Pages/Student/MyApplications.aspx"; break;
            case "~/pages/student/opportunitydetails.aspx": current = "~/Pages/Student/Opportunities.aspx"; break;
            case "~/pages/company/traineedetails.aspx": current = "~/Pages/Company/Trainees.aspx"; break;
            case "~/pages/coordinator/placementdetails.aspx": current = "~/Pages/Coordinator/Placements.aspx"; break;
            case "~/pages/meetings/schedule.aspx": current = "~/Pages/Meetings/Schedule.aspx"; break;
        }
        return string.Equals(current, path, StringComparison.OrdinalIgnoreCase) ? "aria-current=\"page\"" : "";
    }
    protected string AccountPath
    {
        get
        {
            var user = SessionHelper.Current;
            if (user == null) return Constants.Routes.Login;
            switch (user.Role)
            {
                case UserRole.Student: return "~/Pages/Student/Profile.aspx";
                case UserRole.CompanySupervisor: return "~/Pages/Company/Account.aspx";
                case UserRole.AcademicSupervisor: return "~/Pages/Academic/Account.aspx";
                case UserRole.Coordinator: return "~/Pages/Coordinator/Account.aspx";
                default: return Constants.Routes.Login;
            }
        }
    }
    protected string Initials
    {
        get
        {
            var user = SessionHelper.Current;
            if (user == null || string.IsNullOrWhiteSpace(user.FullName)) return "U";
            return string.Concat(user.FullName.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries)
                .Take(2).Select(part => System.Globalization.StringInfo.GetNextTextElement(part))).ToUpperInvariant();
        }
    }
    protected string ProfileImage
    {
        get
        {
            var user = SessionHelper.Current;
            var value = user == null ? null : user.ProfileImageUrl;
            Uri uri;
            if (string.IsNullOrWhiteSpace(value)) return "";
            if (value.StartsWith("~/", StringComparison.Ordinal)) return ResolveUrl(value);
            return Uri.TryCreate(value, UriKind.Absolute, out uri) && uri.Scheme == Uri.UriSchemeHttps ? value : "";
        }
    }
</script>
<%-- Shared content of the single desktop/mobile panel. The masters retain their existing logout control and handler. --%>
<div class="uims-sidebar-heading">
    <div class="uims-sidebar-brand">
        <img src="<%: ResolveUrl("~/Assets/images/gju-logo.png") %>" alt="German Jordanian University" width="88" height="65" />
        <div class="uims-sidebar-label uims-sidebar-identity"><strong>German Jordanian University</strong><small>Internship Management System</small></div>
    </div>
    <button type="button" class="student-nav-close" aria-label="Close navigation"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" aria-hidden="true"><path d="m6 6 12 12M18 6 6 18" /></svg></button>
</div>
<button type="button" class="uims-sidebar-pin" aria-pressed="false" aria-expanded="false" aria-label="Pin navigation open" title="Pin navigation open">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="4" width="18" height="16" rx="2"/><path d="M9 4v16M14 9l3 3-3 3"/></svg><span class="uims-sidebar-label">Pin navigation</span>
</button>
<nav class="uims-sidebar-navigation" aria-label="Portal">
    <ul class="uims-side-nav">
    <% if (SessionHelper.IsInRole(UserRole.Student)) { %>
<li><a class="uims-side-link" title="Dashboard" href="<%: ResolveUrl("~/Pages/Student/Dashboard.aspx") %>" <%= NavigationAttributes("~/Pages/Student/Dashboard.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/></svg><span class="uims-sidebar-label">Dashboard</span></a></li>
<li><a class="uims-side-link" title="Explore Opportunities" href="<%: ResolveUrl("~/Pages/Student/Opportunities.aspx") %>" <%= NavigationAttributes("~/Pages/Student/Opportunities.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="10.5" cy="10.5" r="6.5"/><path d="m16 16 5 5"/></svg><span class="uims-sidebar-label">Explore Opportunities</span></a></li>
<li><a class="uims-side-link" title="My Applications" href="<%: ResolveUrl("~/Pages/Student/MyApplications.aspx") %>" <%= NavigationAttributes("~/Pages/Student/MyApplications.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M6 3h8l4 4v14H6zM14 3v5h4M9 12h6M9 16h6"/></svg><span class="uims-sidebar-label">My Applications</span></a></li>
<li><a class="uims-side-link" title="My Tasks" href="<%: ResolveUrl("~/Pages/Student/MyTasks.aspx") %>" <%= NavigationAttributes("~/Pages/Student/MyTasks.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="5" y="4" width="14" height="17" rx="2"/><path d="M9 3h6v4H9zM9 12l2 2 4-4M9 18h6"/></svg><span class="uims-sidebar-label">My Tasks</span></a></li>
<li><a class="uims-side-link" title="My Progress &amp; Evaluation" href="<%: ResolveUrl("~/Pages/Student/Progress.aspx") %>" <%= NavigationAttributes("~/Pages/Student/Progress.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 3v17h17M8 15l4-5 4 2 5-6"/></svg><span class="uims-sidebar-label">My Progress &amp; Evaluation</span></a></li>
<li><a class="uims-side-link" title="Meetings" href="<%: ResolveUrl("~/Pages/Meetings/Schedule.aspx") %>" <%= NavigationAttributes("~/Pages/Meetings/Schedule.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="5" width="18" height="16" rx="2"/><path d="M7 3v4M17 3v4M3 11h18"/></svg><span class="uims-sidebar-label">Meetings</span></a></li>
    <% } %>
    <% if (SessionHelper.IsInRole(UserRole.CompanySupervisor)) { %>
<li><a class="uims-side-link" title="Dashboard" href="<%: ResolveUrl("~/Pages/Company/Dashboard.aspx") %>" <%= NavigationAttributes("~/Pages/Company/Dashboard.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/></svg><span class="uims-sidebar-label">Dashboard</span></a></li>
<li><a class="uims-side-link" title="Manage Opportunities" href="<%: ResolveUrl("~/Pages/Company/Opportunities.aspx") %>" <%= NavigationAttributes("~/Pages/Company/Opportunities.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="7" r="4"/><path d="M4 21v-2a8 8 0 0 1 16 0v2"/></svg><span class="uims-sidebar-label">Manage Opportunities</span></a></li>
<li><a class="uims-side-link" title="Applications Review" href="<%: ResolveUrl("~/Pages/Company/Applications.aspx") %>" <%= NavigationAttributes("~/Pages/Company/Applications.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="10.5" cy="10.5" r="6.5"/><path d="m16 16 5 5"/></svg><span class="uims-sidebar-label">Applications Review</span></a></li>
<li><a class="uims-side-link" title="My Trainees" href="<%: ResolveUrl("~/Pages/Company/Trainees.aspx") %>" <%= NavigationAttributes("~/Pages/Company/Trainees.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M6 3h8l4 4v14H6zM14 3v5h4M9 12h6M9 16h6"/></svg><span class="uims-sidebar-label">My Trainees</span></a></li>
<li><a class="uims-side-link" title="Manage Tasks" href="<%: ResolveUrl("~/Pages/Company/Tasks.aspx") %>" <%= NavigationAttributes("~/Pages/Company/Tasks.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="5" y="4" width="14" height="17" rx="2"/><path d="M9 3h6v4H9zM9 12l2 2 4-4M9 18h6"/></svg><span class="uims-sidebar-label">Manage Tasks</span></a></li>
<li><a class="uims-side-link" title="Review Submissions" href="<%: ResolveUrl("~/Pages/Company/TaskReview.aspx") %>" <%= NavigationAttributes("~/Pages/Company/TaskReview.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 3v17h17M8 15l4-5 4 2 5-6"/></svg><span class="uims-sidebar-label">Review Submissions</span></a></li>
<li><a class="uims-side-link" title="Final Evaluation" href="<%: ResolveUrl("~/Pages/Company/FinalEvaluation.aspx") %>" <%= NavigationAttributes("~/Pages/Company/FinalEvaluation.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="5" width="18" height="16" rx="2"/><path d="M7 3v4M17 3v4M3 11h18"/></svg><span class="uims-sidebar-label">Final Evaluation</span></a></li>
<li><a class="uims-side-link" title="Meetings" href="<%: ResolveUrl("~/Pages/Meetings/Schedule.aspx") %>" <%= NavigationAttributes("~/Pages/Meetings/Schedule.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="7" r="4"/><path d="M4 21v-2a8 8 0 0 1 16 0v2"/></svg><span class="uims-sidebar-label">Meetings</span></a></li>
    <% } %>
    <% if (SessionHelper.IsInRole(UserRole.AcademicSupervisor)) { %>
<li><a class="uims-side-link" title="Dashboard" href="<%: ResolveUrl("~/Pages/Academic/Dashboard.aspx") %>" <%= NavigationAttributes("~/Pages/Academic/Dashboard.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/></svg><span class="uims-sidebar-label">Dashboard</span></a></li>
<li><a class="uims-side-link" title="Student Progress" href="<%: ResolveUrl("~/Pages/Academic/StudentProgress.aspx") %>" <%= NavigationAttributes("~/Pages/Academic/StudentProgress.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="7" r="4"/><path d="M4 21v-2a8 8 0 0 1 16 0v2"/></svg><span class="uims-sidebar-label">Student Progress</span></a></li>
<li><a class="uims-side-link" title="Final Academic Evaluation" href="<%: ResolveUrl("~/Pages/Academic/FinalEvaluation.aspx") %>" <%= NavigationAttributes("~/Pages/Academic/FinalEvaluation.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="10.5" cy="10.5" r="6.5"/><path d="m16 16 5 5"/></svg><span class="uims-sidebar-label">Final Academic Evaluation</span></a></li>
<li><a class="uims-side-link" title="Meetings" href="<%: ResolveUrl("~/Pages/Meetings/Schedule.aspx") %>" <%= NavigationAttributes("~/Pages/Meetings/Schedule.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="5" y="4" width="14" height="17" rx="2"/><path d="M9 3h6v4H9zM9 12l2 2 4-4M9 18h6"/></svg><span class="uims-sidebar-label">Meetings</span></a></li>
    <% } %>
    <% if (SessionHelper.IsInRole(UserRole.Coordinator)) { %>
<li><a class="uims-side-link" title="Dashboard" href="<%: ResolveUrl("~/Pages/Coordinator/Dashboard.aspx") %>" <%= NavigationAttributes("~/Pages/Coordinator/Dashboard.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/></svg><span class="uims-sidebar-label">Dashboard</span></a></li>
<li><a class="uims-side-link" title="Manage Students" href="<%: ResolveUrl("~/Pages/Coordinator/Students.aspx") %>" <%= NavigationAttributes("~/Pages/Coordinator/Students.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="7" r="4"/><path d="M4 21v-2a8 8 0 0 1 16 0v2"/></svg><span class="uims-sidebar-label">Manage Students</span></a></li>
<li><a class="uims-side-link" title="Manage Companies" href="<%: ResolveUrl("~/Pages/Coordinator/Companies.aspx") %>" <%= NavigationAttributes("~/Pages/Coordinator/Companies.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="10.5" cy="10.5" r="6.5"/><path d="m16 16 5 5"/></svg><span class="uims-sidebar-label">Manage Companies</span></a></li>
<li><a class="uims-side-link" title="Academic Supervisors" href="<%: ResolveUrl("~/Pages/Coordinator/AcademicSupervisors.aspx") %>" <%= NavigationAttributes("~/Pages/Coordinator/AcademicSupervisors.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M6 3h8l4 4v14H6zM14 3v5h4M9 12h6M9 16h6"/></svg><span class="uims-sidebar-label">Academic Supervisors</span></a></li>
<li><a class="uims-side-link" title="Groups &amp; Assignments" href="<%: ResolveUrl("~/Pages/Coordinator/Groups.aspx") %>" <%= NavigationAttributes("~/Pages/Coordinator/Groups.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="5" y="4" width="14" height="17" rx="2"/><path d="M9 3h6v4H9zM9 12l2 2 4-4M9 18h6"/></svg><span class="uims-sidebar-label">Groups &amp; Assignments</span></a></li>
<li><a class="uims-side-link" title="Placements &amp; Progress" href="<%: ResolveUrl("~/Pages/Coordinator/Placements.aspx") %>" <%= NavigationAttributes("~/Pages/Coordinator/Placements.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 3v17h17M8 15l4-5 4 2 5-6"/></svg><span class="uims-sidebar-label">Placements &amp; Progress</span></a></li>
<li><a class="uims-side-link" title="Final Completion Review" href="<%: ResolveUrl("~/Pages/Coordinator/CompletionReview.aspx") %>" <%= NavigationAttributes("~/Pages/Coordinator/CompletionReview.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="5" width="18" height="16" rx="2"/><path d="M7 3v4M17 3v4M3 11h18"/></svg><span class="uims-sidebar-label">Final Completion Review</span></a></li>
<li><a class="uims-side-link" title="Contact Messages" href="<%: ResolveUrl("~/Pages/Coordinator/ContactMessages.aspx") %>" <%= NavigationAttributes("~/Pages/Coordinator/ContactMessages.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/></svg><span class="uims-sidebar-label">Contact Messages</span></a></li>
<li><a class="uims-side-link" title="Meetings" href="<%: ResolveUrl("~/Pages/Meetings/Schedule.aspx") %>" <%= NavigationAttributes("~/Pages/Meetings/Schedule.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="7" r="4"/><path d="M4 21v-2a8 8 0 0 1 16 0v2"/></svg><span class="uims-sidebar-label">Meetings</span></a></li>
    <% } %>
    </ul>
</nav>
<% if (SessionHelper.Current != null) { %>
<a class="uims-sidebar-account" href="<%: ResolveUrl(AccountPath) %>" <%= NavigationAttributes(AccountPath) %> title="<%: SessionHelper.Current.FullName %> — My account">
    <span class="uims-sidebar-avatar" aria-hidden="true"><span><%: Initials %></span><% if (!string.IsNullOrEmpty(ProfileImage)) { %><img src="<%: ProfileImage %>" alt="" width="28" height="28" /><% } %></span>
    <span class="uims-sidebar-label uims-sidebar-account-meta"><strong><%: SessionHelper.Current.FullName %></strong><small><%: SessionHelper.Current.RoleDisplayName %></small><span><%: SessionHelper.IsInRole(UserRole.Student) ? "My Profile" : "My Account" %></span></span>
</a>
<% } %>
