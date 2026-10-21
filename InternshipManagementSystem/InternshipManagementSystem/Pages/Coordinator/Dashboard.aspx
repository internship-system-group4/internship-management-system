<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.Dashboard" Title="Coordinator Dashboard" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"><link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/coordinator-monitoring.css") %>" /></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="monitor-page">
    <div class="monitor-heading"><div><h2>Coordinator dashboard</h2><p>Follow students, training partners and internship progress.</p></div><a class="btn btn-brand" href="Placements.aspx">View placements</a></div>
    <% if (LoadError != null) { %><div class="monitor-error" role="alert"><%: LoadError %> <a href="Dashboard.aspx">Retry</a></div><% } else if (Summary != null) { %>
    <p class="monitor-freshness">Loaded from Firebase on page refresh &middot; <%: DateTime.UtcNow.ToString("yyyy-MM-dd HH:mm") %> UTC</p>
    <div class="monitor-metrics" aria-label="System statistics">
        <a href="Students.aspx" class="monitor-metric" data-metric="students"><span>Students</span><strong><%: Summary.Students %></strong><small><%: Summary.ActiveStudents %> active accounts</small></a>
        <a href="Companies.aspx" class="monitor-metric" data-metric="companies"><span>Companies</span><strong><%: Summary.Companies %></strong><small><%: Summary.ActiveCompanies %> active partners</small></a>
        <div class="monitor-metric" data-metric="opportunities"><span>Opportunities</span><strong><%: Summary.Opportunities %></strong><small><%: Summary.OpenOpportunities %> accepting applications</small></div>
        <a href="Placements.aspx" class="monitor-metric" data-metric="placements"><span>Confirmed placements</span><strong><%: Summary.Placements %></strong><small><%: Summary.ActivePlacements %> confirmed or active</small></a>
        <div class="monitor-metric" data-metric="task-evaluations"><span>Task evaluations</span><strong><%: Summary.TaskEvaluations %></strong><small>Linked to confirmed placements</small></div>
        <div class="monitor-metric" data-metric="final-evaluations"><span>Submitted final evaluations</span><strong><%: Summary.CompanyFinals + Summary.AcademicFinals %></strong><small><%: Summary.CompanyFinals %> company &middot; <%: Summary.AcademicFinals %> academic</small></div>
    </div>
    <div class="monitor-attention"><h3>Needs attention</h3><div><a href="Placements.aspx?status=3"><strong><%: Summary.AwaitingCompletion %></strong> placements awaiting completion</a><span><strong><%: Summary.OverdueTasks %></strong> tasks past deadline and not graded</span><span><strong><%: Summary.PendingHours %> h</strong> reported, awaiting approval</span></div></div>
    <section class="monitor-panel"><div class="monitor-panel-heading"><h3>Recent placements</h3><a href="Placements.aspx">View all placements</a></div>
        <% if (Summary.Recent.Count == 0) { %><div class="monitor-empty">No confirmed internships yet. Placements appear here after a student confirms an accepted offer.</div><% } else { %>
        <div class="monitor-table-scroll"><table class="monitor-table"><caption class="visually-hidden">Five most recently confirmed student placements</caption><thead><tr><th scope="col">Student</th><th scope="col">Company</th><th scope="col">Status</th><th scope="col">Approved hours</th><th scope="col">Action</th></tr></thead><tbody>
        <% foreach (var row in Summary.Recent) { %><tr><td><strong><%: row.StudentName %></strong><small><%: row.StudentNumber %></small></td><td><%: row.Placement.CompanyName %></td><td><span class="monitor-status"><%: row.StatusText %></span></td><td><%: row.HoursText %></td><td><a href="PlacementDetails.aspx?id=<%: Server.UrlEncode(row.Placement.Id) %>" aria-label="View internship for <%: row.StudentName %>">View details</a></td></tr><% } %>
        </tbody></table></div><% } %>
    </section>
    <% } %>
</div>
</asp:Content>
