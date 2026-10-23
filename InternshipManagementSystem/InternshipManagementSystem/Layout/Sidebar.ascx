<%@ Control Language="C#" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="InternshipManagementSystem.Security" %>
<%@ Import Namespace="InternshipManagementSystem.Common" %>
<%@ Register Src="~/Layout/LanguageSelector.ascx" TagPrefix="uims" TagName="LanguageSelector" %>
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
            case "~/pages/meetings/schedule.aspx": current = "~/Pages/Meetings/MyMeetings.aspx"; break;
                
             case "~/pages/company/opportunities.aspx":
               current = "~/Pages/Company/ManageOpportunities.aspx";
                break;

             case "~/pages/company/viewopportunity.aspx":
               current = "~/Pages/Company/ManageOpportunities.aspx";
                break;

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
        <img src="<%: ResolveUrl("~/Assets/images/gju-logo.png") %>" alt="<%: L.T("Shared.Sidebar.GermanJordanianUniversity") %>" width="88" height="65" />
        <div class="uims-sidebar-label uims-sidebar-identity"><strong><%: L.T("Shared.Sidebar.GermanJordanianUniversity") %></strong><small><%: L.T("Shared.Sidebar.InternshipManagementSystem") %></small></div>
    </div>
    <button type="button" class="student-nav-close" aria-label="<%: L.T("Shared.Sidebar.CloseNavigation") %>"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" aria-hidden="true"><path d="m6 6 12 12M18 6 6 18" /></svg></button>
</div>
<button type="button" class="uims-sidebar-pin" aria-pressed="false" aria-expanded="false" aria-label="<%: L.T("Shared.Sidebar.PinNavigationOpen") %>" title="<%: L.T("Shared.Sidebar.PinNavigationOpen") %>">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="4" width="18" height="16" rx="2"/><path d="M9 4v16M14 9l3 3-3 3"/></svg><span class="uims-sidebar-label"><%: L.T("Shared.Sidebar.PinNavigation") %></span>
</button>
<nav class="uims-sidebar-navigation" aria-label="<%: L.T("Shared.Sidebar.Portal") %>">
    <ul class="uims-side-nav">
    <% if (SessionHelper.IsInRole(UserRole.Student)) { %>
<li><a class="uims-side-link" title="<%: L.T("Shared.Sidebar.Dashboard") %>" href="<%: ResolveUrl("~/Pages/Student/Dashboard.aspx") %>" <%= NavigationAttributes("~/Pages/Student/Dashboard.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/></svg><span class="uims-sidebar-label"><%: L.T("Shared.Sidebar.Dashboard") %></span></a></li>
<li><a class="uims-side-link" title="<%: L.T("Shared.Sidebar.ExploreOpportunities") %>" href="<%: ResolveUrl("~/Pages/Student/Opportunities.aspx") %>" <%= NavigationAttributes("~/Pages/Student/Opportunities.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="10.5" cy="10.5" r="6.5"/><path d="m16 16 5 5"/></svg><span class="uims-sidebar-label"><%: L.T("Shared.Sidebar.ExploreOpportunities") %></span></a></li>
<li><a class="uims-side-link" title="<%: L.T("Shared.Sidebar.MyApplications") %>" href="<%: ResolveUrl("~/Pages/Student/MyApplications.aspx") %>" <%= NavigationAttributes("~/Pages/Student/MyApplications.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M6 3h8l4 4v14H6zM14 3v5h4M9 12h6M9 16h6"/></svg><span class="uims-sidebar-label"><%: L.T("Shared.Sidebar.MyApplications") %></span></a></li>
<li><a class="uims-side-link" title="<%: L.T("Shared.Sidebar.MyTasks") %>" href="<%: ResolveUrl("~/Pages/Student/MyTasks.aspx") %>" <%= NavigationAttributes("~/Pages/Student/MyTasks.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="5" y="4" width="14" height="17" rx="2"/><path d="M9 3h6v4H9zM9 12l2 2 4-4M9 18h6"/></svg><span class="uims-sidebar-label"><%: L.T("Shared.Sidebar.MyTasks") %></span></a></li>
<li><a class="uims-side-link" title="<%: L.T("Shared.Sidebar.MyProgressEvaluation") %>" href="<%: ResolveUrl("~/Pages/Student/Progress.aspx") %>" <%= NavigationAttributes("~/Pages/Student/Progress.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 3v17h17M8 15l4-5 4 2 5-6"/></svg><span class="uims-sidebar-label"><%: L.T("Shared.Sidebar.MyProgressEvaluation") %></span></a></li>
<li><a class="uims-side-link" title="<%: L.T("Shared.Sidebar.Meetings") %>" href="<%: ResolveUrl("~/Pages/Meetings/MyMeetings.aspx") %>" <%= NavigationAttributes("~/Pages/Meetings/MyMeetings.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="5" width="18" height="16" rx="2"/><path d="M7 3v4M17 3v4M3 11h18"/></svg><span class="uims-sidebar-label"><%: L.T("Shared.Sidebar.Meetings") %></span></a></li>
    <% } %>
    <% if (SessionHelper.IsInRole(UserRole.CompanySupervisor)) { %>
<li><a class="uims-side-link" title="<%: L.T("Shared.Sidebar.Dashboard") %>" href="<%: ResolveUrl("~/Pages/Company/Dashboard.aspx") %>" <%= NavigationAttributes("~/Pages/Company/Dashboard.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/></svg><span class="uims-sidebar-label"><%: L.T("Shared.Sidebar.Dashboard") %></span></a></li>
<li><a class="uims-side-link" title="<%: L.T("Shared.Sidebar.ManageOpportunities") %>" href="<%: ResolveUrl("~/Pages/Company/ManageOpportunities.aspx") %>" <%= NavigationAttributes("~/Pages/Company/ManageOpportunities.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="7" r="4"/><path d="M4 21v-2a8 8 0 0 1 16 0v2"/></svg><span class="uims-sidebar-label"><%: L.T("Shared.Sidebar.ManageOpportunities") %></span></a></li>
<li><a class="uims-side-link" title="<%: L.T("Shared.Sidebar.ApplicationsReview") %>" href="<%: ResolveUrl("~/Pages/Company/Applications.aspx") %>" <%= NavigationAttributes("~/Pages/Company/Applications.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="10.5" cy="10.5" r="6.5"/><path d="m16 16 5 5"/></svg><span class="uims-sidebar-label"><%: L.T("Shared.Sidebar.ApplicationsReview") %></span></a></li>
<li><a class="uims-side-link" title="<%: L.T("Shared.Sidebar.MyTrainees") %>" href="<%: ResolveUrl("~/Pages/Company/Trainees.aspx") %>" <%= NavigationAttributes("~/Pages/Company/Trainees.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M6 3h8l4 4v14H6zM14 3v5h4M9 12h6M9 16h6"/></svg><span class="uims-sidebar-label"><%: L.T("Shared.Sidebar.MyTrainees") %></span></a></li>
<li><a class="uims-side-link" title="<%: L.T("Shared.Sidebar.ManageTasks") %>" href="<%: ResolveUrl("~/Pages/Company/Tasks.aspx") %>" <%= NavigationAttributes("~/Pages/Company/Tasks.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="5" y="4" width="14" height="17" rx="2"/><path d="M9 3h6v4H9zM9 12l2 2 4-4M9 18h6"/></svg><span class="uims-sidebar-label"><%: L.T("Shared.Sidebar.ManageTasks") %></span></a></li>
<li><a class="uims-side-link" title="<%: L.T("Shared.Sidebar.ReviewSubmissions") %>" href="<%: ResolveUrl("~/Pages/Company/TaskReview.aspx") %>" <%= NavigationAttributes("~/Pages/Company/TaskReview.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 3v17h17M8 15l4-5 4 2 5-6"/></svg><span class="uims-sidebar-label"><%: L.T("Shared.Sidebar.ReviewSubmissions") %></span></a></li>
<li><a class="uims-side-link" title="<%: L.T("Shared.Sidebar.FinalEvaluation") %>" href="<%: ResolveUrl("~/Pages/Company/FinalEvaluation.aspx") %>" <%= NavigationAttributes("~/Pages/Company/FinalEvaluation.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="5" width="18" height="16" rx="2"/><path d="M7 3v4M17 3v4M3 11h18"/></svg><span class="uims-sidebar-label"><%: L.T("Shared.Sidebar.FinalEvaluation") %></span></a></li>
<li><a class="uims-side-link" title="<%: L.T("Shared.Sidebar.Meetings") %>" href="<%: ResolveUrl("~/Pages/Meetings/MyMeetings.aspx") %>" <%= NavigationAttributes("~/Pages/Meetings/MyMeetings.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="7" r="4"/><path d="M4 21v-2a8 8 0 0 1 16 0v2"/></svg><span class="uims-sidebar-label"><%: L.T("Shared.Sidebar.Meetings") %></span></a></li>
    <% } %>
    <% if (SessionHelper.IsInRole(UserRole.AcademicSupervisor)) { %>
<li><a class="uims-side-link" title="<%: L.T("Shared.Sidebar.Dashboard") %>" href="<%: ResolveUrl("~/Pages/Academic/Dashboard.aspx") %>" <%= NavigationAttributes("~/Pages/Academic/Dashboard.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/></svg><span class="uims-sidebar-label"><%: L.T("Shared.Sidebar.Dashboard") %></span></a></li>
<li><a class="uims-side-link" title="<%: L.T("Shared.Sidebar.StudentProgress") %>" href="<%: ResolveUrl("~/Pages/Academic/StudentProgress.aspx") %>" <%= NavigationAttributes("~/Pages/Academic/StudentProgress.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="7" r="4"/><path d="M4 21v-2a8 8 0 0 1 16 0v2"/></svg><span class="uims-sidebar-label"><%: L.T("Shared.Sidebar.StudentProgress") %></span></a></li>
<li><a class="uims-side-link" title="<%: L.T("Shared.Sidebar.FinalAcademicEvaluation") %>" href="<%: ResolveUrl("~/Pages/Academic/FinalEvaluation.aspx") %>" <%= NavigationAttributes("~/Pages/Academic/FinalEvaluation.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="10.5" cy="10.5" r="6.5"/><path d="m16 16 5 5"/></svg><span class="uims-sidebar-label"><%: L.T("Shared.Sidebar.FinalAcademicEvaluation") %></span></a></li>
<li><a class="uims-side-link" title="<%: L.T("Shared.Sidebar.Meetings") %>" href="<%: ResolveUrl("~/Pages/Meetings/MyMeetings.aspx") %>" <%= NavigationAttributes("~/Pages/Meetings/MyMeetings.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="5" y="4" width="14" height="17" rx="2"/><path d="M9 3h6v4H9zM9 12l2 2 4-4M9 18h6"/></svg><span class="uims-sidebar-label"><%: L.T("Shared.Sidebar.Meetings") %></span></a></li>
    <% } %>
    <% if (SessionHelper.IsInRole(UserRole.Coordinator)) { %>
<li><a class="uims-side-link" title="<%: L.T("Shared.Sidebar.Dashboard") %>" href="<%: ResolveUrl("~/Pages/Coordinator/Dashboard.aspx") %>" <%= NavigationAttributes("~/Pages/Coordinator/Dashboard.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/></svg><span class="uims-sidebar-label"><%: L.T("Shared.Sidebar.Dashboard") %></span></a></li>
<li><a class="uims-side-link" title="<%: L.T("Shared.Sidebar.ManageStudents") %>" href="<%: ResolveUrl("~/Pages/Coordinator/ManageStudents.aspx") %>" <%= NavigationAttributes("~/Pages/Coordinator/ManageStudents.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="9" cy="8" r="3.5"/><path d="M2.5 20c0-3.6 2.9-6 6.5-6 1.4 0 2.6.3 3.6.9"/><circle cx="18" cy="17" r="2"/><path d="M18 13.5v1.5M18 19v1.5M14.5 17H16M20 17h1.5M15.5 14.5l1 1M19.5 18.5l1 1M15.5 19.5l1-1M19.5 15.5l1-1"/></svg><span class="uims-sidebar-label"><%: L.T("Shared.Sidebar.ManageStudents") %></span></a></li>
<li><a class="uims-side-link" title="<%: L.T("Shared.Sidebar.ManageCompanies") %>" href="<%: ResolveUrl("~/Pages/Coordinator/Companies.aspx") %>" <%= NavigationAttributes("~/Pages/Coordinator/Companies.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="10.5" cy="10.5" r="6.5"/><path d="m16 16 5 5"/></svg><span class="uims-sidebar-label"><%: L.T("Shared.Sidebar.ManageCompanies") %></span></a></li>
<li><a class="uims-side-link" title="<%: L.T("Shared.Sidebar.AcademicSupervisors") %>" href="<%: ResolveUrl("~/Pages/Coordinator/AcademicSupervisors.aspx") %>" <%= NavigationAttributes("~/Pages/Coordinator/AcademicSupervisors.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M6 3h8l4 4v14H6zM14 3v5h4M9 12h6M9 16h6"/></svg><span class="uims-sidebar-label"><%: L.T("Shared.Sidebar.AcademicSupervisors") %></span></a></li>
<li><a class="uims-side-link" title="<%: L.T("Shared.Sidebar.GroupsAssignments") %>" href="<%: ResolveUrl("~/Pages/Coordinator/Groups.aspx") %>" <%= NavigationAttributes("~/Pages/Coordinator/Groups.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="5" y="4" width="14" height="17" rx="2"/><path d="M9 3h6v4H9zM9 12l2 2 4-4M9 18h6"/></svg><span class="uims-sidebar-label"><%: L.T("Shared.Sidebar.GroupsAssignments") %></span></a></li>
<li><a class="uims-side-link" title="<%: L.T("Shared.Sidebar.PlacementsProgress") %>" href="<%: ResolveUrl("~/Pages/Coordinator/Placements.aspx") %>" <%= NavigationAttributes("~/Pages/Coordinator/Placements.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 3v17h17M8 15l4-5 4 2 5-6"/></svg><span class="uims-sidebar-label"><%: L.T("Shared.Sidebar.PlacementsProgress") %></span></a></li>
<li><a class="uims-side-link" title="<%: L.T("Shared.Sidebar.FinalCompletionReview") %>" href="<%: ResolveUrl("~/Pages/Coordinator/CompletionReview.aspx") %>" <%= NavigationAttributes("~/Pages/Coordinator/CompletionReview.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="5" width="18" height="16" rx="2"/><path d="M7 3v4M17 3v4M3 11h18"/></svg><span class="uims-sidebar-label"><%: L.T("Shared.Sidebar.FinalCompletionReview") %></span></a></li>
<li><a class="uims-side-link" title="<%: L.T("Shared.Sidebar.ContactMessages") %>" href="<%: ResolveUrl("~/Pages/Coordinator/ContactMessages.aspx") %>" <%= NavigationAttributes("~/Pages/Coordinator/ContactMessages.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/></svg><span class="uims-sidebar-label"><%: L.T("Shared.Sidebar.ContactMessages") %></span></a></li>
<li><a class="uims-side-link" title="<%: L.T("Shared.Sidebar.Meetings") %>" href="<%: ResolveUrl("~/Pages/Meetings/MyMeetings.aspx") %>" <%= NavigationAttributes("~/Pages/Meetings/MyMeetings.aspx") %>><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="7" r="4"/><path d="M4 21v-2a8 8 0 0 1 16 0v2"/></svg><span class="uims-sidebar-label"><%: L.T("Shared.Sidebar.Meetings") %></span></a></li>
    <% } %>
    </ul>
</nav>
<%-- On drawer-sized screens the language choice lives here instead of the header (Assets/css/i18n.css). --%>
<div class="uims-sidebar-lang"><uims:LanguageSelector runat="server" Variant="inline" /></div>
<% if (SessionHelper.Current != null) { %>
<a class="uims-sidebar-account" href="<%: ResolveUrl(AccountPath) %>" <%= NavigationAttributes(AccountPath) %> title="<%: SessionHelper.Current.FullName %> &mdash; <%: L.T("Shared.Sidebar.MyAccountTitle") %>">
    <span class="uims-sidebar-avatar" aria-hidden="true"><span><%: Initials %></span><% if (!string.IsNullOrEmpty(ProfileImage)) { %><img src="<%: ProfileImage %>" alt="" width="28" height="28" /><% } %></span>
    <span class="uims-sidebar-label uims-sidebar-account-meta"><strong><%: SessionHelper.Current.FullName %></strong><small><%: L.Role(SessionHelper.Current.Role) %></small><span><%: L.T(SessionHelper.IsInRole(UserRole.Student) ? "Shared.Sidebar.MyProfile" : "Shared.Sidebar.MyAccount") %></span></span>
</a>
<% } %>
