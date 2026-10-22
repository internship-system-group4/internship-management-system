<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.Dashboard" Title="Coordinator Dashboard" %>
<%@ Import Namespace="System.Linq" %>
<%@ Register Src="~/Layout/WorkspaceJourney.ascx" TagPrefix="uims" TagName="WorkspaceJourney" %>
<%@ Register Src="~/Layout/WorkspaceChart.ascx" TagPrefix="uims" TagName="WorkspaceChart" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"><link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/coordinator-monitoring.css") %>" /></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="ws-dashboard ws-reference ws-coordinator" data-workspace-role="coordinator">
 <header class="ws-page-heading" data-ws-enter="header"><div><h2>Coordination desk</h2><p>Keep assignments, training exceptions and completion decisions in view.</p></div><a class="btn btn-brand" href="CompletionReview.aspx">Open completion review <span data-ui-icon="next" aria-hidden="true"></span></a></header>
 <% if(LoadError != null) { %><div class="alert alert-danger" role="alert"><%: LoadError %> <a href="Dashboard.aspx">Retry</a></div><% } %>
 <uims:WorkspaceJourney ID="Journey" runat="server" />
 <uims:WorkspaceChart ID="Charts" runat="server" />
 <% if(Summary != null) { %>
 <dl class="ws-metric-band" hidden aria-hidden="true" data-ws-enter="metrics"><div data-metric="students"><dt>Students</dt><dd><strong><%: Summary.Students %></strong></dd><small><%: Summary.ActiveStudents %> active accounts</small></div><div data-metric="placements"><dt>Confirmed placements</dt><dd><strong><%: Summary.Placements %></strong></dd><small><%: Summary.ActivePlacements %> confirmed or active</small></div><div data-metric="final-evaluations"><dt>Final assessments received</dt><dd><strong><%: Summary.CompanyFinals + Summary.AcademicFinals %></strong></dd><small><%: Summary.CompanyFinals %> company · <%: Summary.AcademicFinals %> academic</small></div><div><dt>Ready for review</dt><dd><%: Workspace.Queue.Count(q => q.IsReady) %></dd><small>Both evaluations; not yet approved</small></div></dl>
 <div class="ws-coordination-work" data-ws-enter="work">
  <section class="ws-work-panel"><div class="ws-section-heading"><div><h3>Completion queue</h3><p>Each student needs an individual coordinator decision.</p></div><a href="CompletionReview.aspx">View queue</a></div>
   <% if(Workspace.Queue.Count == 0) { %><div class="ws-empty"><h4>No confirmed placements yet</h4><p>Students appear here after confirming one accepted offer.</p><a href="ManageStudents.aspx">Manage student records</a></div><% } else { %>
   <table class="ws-completion-table"><caption class="visually-hidden">Completion work and approved hours for confirmed placements</caption><thead><tr><th>Student &amp; company</th><th>Approved hours</th><th>Review stage</th><th>Action</th></tr></thead><tbody>
    <% foreach(var row in Workspace.Queue.Take(5)) { %><tr data-workspace-row="<%: row.Overview.Placement.Id %>" data-workspace-status="<%: row.StageText %>"><td><strong><%: row.Overview.StudentName %></strong><small><%: row.Overview.Placement.CompanyName %></small></td><td><%: row.Overview.HoursText %></td><td><span class="monitor-status"><%: row.StageText %></span></td><td><a class="ws-text-action" href="CompletionReview.aspx?id=<%: Server.UrlEncode(row.Overview.Placement.Id) %>">Review <span data-ui-icon="next" aria-hidden="true"></span></a></td></tr><% } %>
   </tbody></table><% } %>
  </section>
  <aside class="ws-assignment-desk"><span data-ui-icon="people" aria-hidden="true"></span><h3>Assignments</h3><div class="ws-assignment-number"><%: Workspace.UnassignedStudents %></div><p>active student profiles have no academic supervisor recorded.</p><a class="btn btn-light" href="Groups.aspx">Manage groups &amp; assignments <span data-ui-icon="next" aria-hidden="true"></span></a><a href="AcademicSupervisors.aspx">Academic supervisors</a></aside>
 </div>
 <section class="ws-exceptions" data-ws-enter="support"><div class="ws-section-heading"><h3>Training exceptions</h3><a href="Placements.aspx">Open placements</a></div><div class="ws-exception-band"><a href="Placements.aspx?status=3"><strong><%: Summary.AwaitingCompletion %></strong><span>placements awaiting completion</span></a><div><strong><%: Summary.OverdueTasks %></strong><span>ungraded tasks past their deadline</span></div><div><strong><%: Summary.PendingHours %> h</strong><span>reported, awaiting company approval</span></div></div></section>
 <div class="ws-programme-totals"><span data-metric="companies"><strong><%: Summary.Companies %></strong> companies · <%: Summary.ActiveCompanies %> active</span><span data-metric="opportunities"><strong><%: Summary.Opportunities %></strong> opportunities · <%: Summary.OpenOpportunities %> open</span><span data-metric="task-evaluations"><strong><%: Summary.TaskEvaluations %></strong> linked task evaluations</span><small>Updated on page load · <%: DateTime.UtcNow.ToString("dd MMM yyyy HH:mm") %> UTC</small></div>
 <% } %>
</div>
</asp:Content>
