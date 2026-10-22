<%@ Page Language="C#" MasterPageFile="~/Layout/Academic.master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="InternshipManagementSystem.Pages.Academic.Dashboard" Title="Academic Dashboard" %>
<%@ Import Namespace="System.Linq" %>
<%@ Register Src="~/Layout/WorkspaceJourney.ascx" TagPrefix="uims" TagName="WorkspaceJourney" %>
<%@ Register Src="~/Layout/WorkspaceChart.ascx" TagPrefix="uims" TagName="WorkspaceChart" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="ws-dashboard ws-reference ws-academic" data-workspace-role="academic">
 <header class="ws-page-heading" data-ws-enter="header"><div><h2>Student oversight</h2><p><asp:Literal ID="litSupervisorName" runat="server" />, follow your assigned students and academic work.</p></div><a class="btn btn-brand" href="StudentProgress.aspx">Review student records <span data-ui-icon="next" aria-hidden="true"></span></a></header>
 <% if(LoadError != null) { %><div class="alert alert-danger" role="alert"><%: LoadError %> <a href="Dashboard.aspx">Retry</a></div><% } %>
 <uims:WorkspaceJourney ID="Journey" runat="server" />
 <uims:WorkspaceChart ID="Charts" runat="server" />
 <dl class="ws-metric-band" hidden aria-hidden="true" data-ws-enter="metrics"><div><dt>Assigned students</dt><dd><asp:Literal ID="litTotalStudents" runat="server" /></dd><small>Your supervision group</small></div><div><dt>Hours requirement met</dt><dd><asp:Literal ID="litCompletedStudents" runat="server" /></dd><small>Approved entries only</small></div><div><dt>Company assessments</dt><dd><%: Workspace == null ? "—" : Workspace.CompanyFeedback.ToString() %></dd><small>Submitted for your students</small></div><div><dt>Academic follow-up</dt><dd><%: Workspace == null ? "—" : Workspace.PendingEvaluations.ToString() %></dd><small>Company assessment received</small></div></dl>
 <div class="ws-academic-work" data-ws-enter="work">
  <section class="ws-work-panel"><div class="ws-section-heading"><div><h3>Assigned students</h3><p>Placement, approved hours and the next academic action.</p></div></div>
   <table class="ws-student-table"><caption class="visually-hidden">Students assigned to the signed-in academic supervisor</caption><thead><tr><th>Student</th><th>Placement</th><th>Approved hours</th><th>Follow-up</th></tr></thead><tbody>
   <asp:Repeater ID="rptStudents" runat="server"><ItemTemplate><tr data-workspace-row='<%# Eval("Id") %>'><td><strong><%#: Eval("FullName") %></strong><small><%#: Eval("StudentNumber") %></small></td><td><strong><%#: Eval("CompanyName") %></strong><small><%#: Eval("Major") %></small></td><td><span><%#: Eval("HoursText") %></span><div class="ws-mini-progress"><div id='academic-hours-<%# Eval("Id") %>' data-ui-progress="" data-ui-approved='<%# Eval("ApprovedHours") %>' data-ui-target='<%# Eval("RequiredHours") %>'></div></div><small><%#: Eval("PendingHours") %> h pending</small></td><td><span class="ws-followup"><%#: Eval("NextAction") %></span><a class="ws-text-action" href='StudentProgress.aspx?id=<%# Server.UrlEncode(Eval("Id").ToString()) %>'>View progress <span data-ui-icon="next" aria-hidden="true"></span></a></td></tr></ItemTemplate></asp:Repeater>
   </tbody></table>
   <asp:Literal ID="litNoData" runat="server" Visible="false" Text="<div class='ws-empty'><h4>No students assigned yet</h4><p>Your coordinator manages academic supervision assignments. Assigned students will appear here.</p></div>" />
  </section>
  <aside class="ws-academic-followup"><h3>Academic work</h3><p>Assessment and follow-up stay linked to each assigned student.</p>
   <% if(Workspace != null && Workspace.PendingEvaluations > 0) { foreach(var row in Workspace.Students.Where(s => s.CompanySubmitted && !s.AcademicSubmitted).Take(3)) { %><a class="ws-evaluation-person" href="FinalEvaluation.aspx?id=<%: Server.UrlEncode(row.Id) %>"><span class="ws-person-initial" aria-hidden="true"><%: row.FullName.Substring(0,1) %></span><span><strong><%: row.FullName %></strong><small>Company assessment received</small></span><span data-ui-icon="next" aria-hidden="true"></span></a><% } } else { %><p class="ws-inline-note">No received company assessments are waiting for your academic submission.</p><% } %>
   <a class="ws-text-action" href="FinalEvaluation.aspx">Open academic evaluations <span data-ui-icon="next" aria-hidden="true"></span></a><div class="ws-privacy-note"><span data-ui-icon="info" aria-hidden="true"></span><p>Internal evaluation forms remain restricted. Students see the released result only after coordinator approval.</p></div>
  </aside>
 </div>
</div>
</asp:Content>
