<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="false" OnLoad="DashboardExperience_Load" CodeBehind="Dashboard.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.Dashboard" Title="Coordinator Dashboard" %>
<%@ Import Namespace="System.Linq" %>
<%@ Register Src="~/Layout/WorkspaceJourney.ascx" TagPrefix="uims" TagName="WorkspaceJourney" %>
<%@ Register Src="~/Layout/WorkspaceChart.ascx" TagPrefix="uims" TagName="WorkspaceChart" %>
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
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"><link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/coordinator-monitoring.css") %>" /><link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/coordinator-dashboard.css?v=20261023-team-sync") %>" /></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="ws-dashboard ws-reference ws-coordinator" data-workspace-role="coordinator">
 <header class="ws-page-heading" data-ws-enter="header"><div><h2><%: L.T("Coordinator.Dashboard.CoordinationDesk") %></h2><p><%: L.T("Coordinator.Dashboard.KeepAssignmentsTrainingExceptionsAndCompletion") %></p></div><a class="btn btn-brand" href="CompletionReview.aspx"><%: L.T("Coordinator.Dashboard.OpenCompletionReview") %> <span data-ui-icon="next" aria-hidden="true"></span></a><button type="button" class="dashboard-refresh" data-dashboard-refresh aria-label="<%: L.T("Shared.Js.DashboardRefresh") %>" title="<%: L.T("Shared.Js.DashboardRefresh") %>"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" aria-hidden="true"><path d="M20 7v5h-5M4 17v-5h5M6.1 7a7 7 0 0 1 11.6-2L20 8M4 16l2.3 3A7 7 0 0 0 17.9 17" /></svg></button></header>
 <div class="dashboard-load-status" id="dashboard-announcement" role="status" aria-live="polite" aria-atomic="true"><span class="dashboard-status-dot" aria-hidden="true"></span><span data-dashboard-status><%: L.T(Summary != null ? "Shared.Js.DashboardReady" : string.IsNullOrEmpty(LoadError) ? "Shared.Js.DashboardLoading" : "Shared.Js.DashboardUnavailable") %></span></div>
 <div id="dashboard-data" class="dashboard-data" data-load-state="<%: Summary != null ? "ready" : string.IsNullOrEmpty(LoadError) ? "loading" : "error" %>" aria-busy="<%: Summary == null && string.IsNullOrEmpty(LoadError) ? "true" : "false" %>">
 <% if (Summary == null && string.IsNullOrEmpty(LoadError)) { %>
 <div class="dashboard-skeleton" aria-hidden="true"><div class="skeleton-section-title skeleton-block"></div><div class="dashboard-stats"><% for (int i=0;i<3;i++) { %><div class="skeleton-stat"><div class="skeleton-label skeleton-block"></div><div class="skeleton-number skeleton-block"></div><div class="skeleton-note skeleton-block"></div></div><% } %></div><div class="skeleton-panel"><div class="skeleton-table-head skeleton-block"></div><div class="skeleton-row"><span class="skeleton-avatar skeleton-block"></span><span class="skeleton-line skeleton-block"></span></div></div></div>
 <noscript><p class="alert alert-info"><a href="Dashboard.aspx?dashboardView=full"><%: L.T("Shared.Js.DashboardFull") %></a></p><style>.dashboard-skeleton,.dashboard-load-status,.dashboard-refresh{display:none}</style></noscript>
 <% } else { %>

 <% if(LoadError != null) { %><div class="alert alert-danger" role="alert"><%: LoadError %> <a href="Dashboard.aspx"><%: L.T("Coordinator.Dashboard.Retry") %></a></div><% } %>
 <uims:WorkspaceJourney ID="Journey" runat="server" />
 <uims:WorkspaceChart ID="Charts" runat="server" />
 <% if(Summary != null) { %>
 <dl class="ws-metric-band" hidden aria-hidden="true" data-ws-enter="metrics"><div data-metric="students"><dt><%: L.T("Coordinator.Dashboard.Students") %></dt><dd><strong><%: Summary.Students %></strong></dd><small><%: Summary.ActiveStudents %> <%: L.T("Coordinator.Dashboard.ActiveAccounts") %></small></div><div data-metric="placements"><dt><%: L.T("Coordinator.Dashboard.ConfirmedPlacements") %></dt><dd><strong><%: Summary.Placements %></strong></dd><small><%: Summary.ActivePlacements %> <%: L.T("Coordinator.Dashboard.ConfirmedOrActive") %></small></div><div data-metric="final-evaluations"><dt><%: L.T("Coordinator.Dashboard.FinalAssessmentsReceived") %></dt><dd><strong><%: Summary.CompanyFinals + Summary.AcademicFinals %></strong></dd><small><%: Summary.CompanyFinals %> <%: L.T("Coordinator.Dashboard.Company") %> <%: Summary.AcademicFinals %> <%: L.T("Coordinator.Dashboard.Academic") %></small></div><div><dt><%: L.T("Coordinator.Dashboard.ReadyForReview") %></dt><dd><%: Workspace.Queue.Count(q => q.IsReady) %></dd><small><%: L.T("Coordinator.Dashboard.BothEvaluationsNotYetApproved") %></small></div></dl>
 <div class="ws-coordination-work" data-ws-enter="work">
  <section class="ws-work-panel"><div class="ws-section-heading"><div><h3><%: L.T("Coordinator.Dashboard.CompletionQueue") %></h3><p><%: L.T("Coordinator.Dashboard.EachStudentNeedsAnIndividualCoordinator") %></p></div><a href="CompletionReview.aspx"><%: L.T("Coordinator.Dashboard.ViewQueue") %></a></div>
   <% if(Workspace.Queue.Count == 0) { %><div class="ws-empty"><h4><%: L.T("Coordinator.Dashboard.NoConfirmedPlacementsYet") %></h4><p><%: L.T("Coordinator.Dashboard.StudentsAppearHereAfterConfirmingOne") %></p><a href="ManageStudents.aspx"><%: L.T("Coordinator.Dashboard.ManageStudentRecords") %></a></div><% } else { %>
   <table class="ws-completion-table"><caption class="visually-hidden"><%: L.T("Coordinator.Dashboard.CompletionWorkAndApprovedHoursFor") %></caption><thead><tr><th><%: L.T("Coordinator.Dashboard.StudentCompany") %></th><th><%: L.T("Coordinator.Dashboard.ApprovedHours") %></th><th><%: L.T("Coordinator.Dashboard.ReviewStage") %></th><th><%: L.T("Coordinator.Dashboard.Action") %></th></tr></thead><tbody>
    <% foreach(var row in Workspace.Queue.Take(5)) { %><tr data-workspace-row="<%: row.Overview.Placement.Id %>" data-workspace-status="<%: row.StageText %>"><td><strong><%: row.Overview.StudentName %></strong><small><%: row.Overview.Placement.CompanyName %></small></td><td><%: row.Overview.HoursText %></td><td><span class="monitor-status"><%: row.StageText %></span></td><td><a class="ws-text-action" href="CompletionReview.aspx?id=<%: Server.UrlEncode(row.Overview.Placement.Id) %>"><%: L.T("Coordinator.Dashboard.Review") %> <span data-ui-icon="next" aria-hidden="true"></span></a></td></tr><% } %>
   </tbody></table><% } %>
  </section>
  <aside class="ws-assignment-desk"><span data-ui-icon="people" aria-hidden="true"></span><h3><%: L.T("Coordinator.Dashboard.Assignments") %></h3><div class="ws-assignment-number"><%: Workspace.UnassignedStudents %></div><p><%: L.T("Coordinator.Dashboard.ActiveStudentProfilesHaveNoAcademic") %></p><a class="btn btn-light" href="Groups.aspx"><%: L.T("Coordinator.Dashboard.ManageGroupsAssignments") %> <span data-ui-icon="next" aria-hidden="true"></span></a><a href="AcademicSupervisors.aspx"><%: L.T("Coordinator.Dashboard.AcademicSupervisors") %></a></aside>
 </div>
 <section class="ws-exceptions" data-ws-enter="support"><div class="ws-section-heading"><h3><%: L.T("Coordinator.Dashboard.TrainingExceptions") %></h3><a href="Placements.aspx"><%: L.T("Coordinator.Dashboard.OpenPlacements") %></a></div><div class="ws-exception-band"><a href="Placements.aspx?status=3"><strong><%: Summary.AwaitingCompletion %></strong><span><%: L.T("Coordinator.Dashboard.PlacementsAwaitingCompletion") %></span></a><div><strong><%: Summary.OverdueTasks %></strong><span><%: L.T("Coordinator.Dashboard.UngradedTasksPastTheirDeadline") %></span></div><div><strong><%: Summary.PendingHours %> h</strong><span><%: L.T("Coordinator.Dashboard.ReportedAwaitingCompanyApproval") %></span></div></div></section>
 <div class="ws-programme-totals"><span data-metric="companies"><strong><%: Summary.Companies %></strong> <%: L.T("Coordinator.Dashboard.Companies") %> <%: Summary.ActiveCompanies %> <%: L.T("Coordinator.Dashboard.Active") %></span><span data-metric="opportunities"><strong><%: Summary.Opportunities %></strong> <%: L.T("Coordinator.Dashboard.Opportunities") %> <%: Summary.OpenOpportunities %> <%: L.T("Coordinator.Dashboard.Open") %></span><span data-metric="task-evaluations"><strong><%: Summary.TaskEvaluations %></strong> <%: L.T("Coordinator.Dashboard.LinkedTaskEvaluations") %></span><small><%: L.T("Coordinator.Dashboard.UpdatedOnPageLoad") %> <%: DateTime.UtcNow.ToString("dd MMM yyyy HH:mm") %> <%: L.T("Coordinator.Dashboard.UTC") %></small></div>
 <% } %>
<% } %>
 </div>
</div>
</asp:Content>

<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server"><script src="<%: ResolveUrl("~/Assets/js/coordinator-dashboard.js?v=20261023-team-sync") %>"></script></asp:Content>
