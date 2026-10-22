<%@ Page Language="C#" MasterPageFile="~/Layout/Company.master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="InternshipManagementSystem.Pages.CompanyArea.Dashboard" Title="Company Dashboard" %>
<%@ Import Namespace="System.Linq" %>
<%@ Register Src="~/Layout/WorkspaceJourney.ascx" TagPrefix="uims" TagName="WorkspaceJourney" %>
<%@ Register Src="~/Layout/WorkspaceChart.ascx" TagPrefix="uims" TagName="WorkspaceChart" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="ws-dashboard ws-reference ws-company" data-workspace-role="company">
 <header class="ws-page-heading" data-ws-enter="header"><div><h2>Company workspace</h2><p>Review candidates. Support trainees. Keep decisions moving.</p></div><a class="btn btn-brand" href="Opportunities.aspx"><span data-ui-icon="plus" aria-hidden="true"></span>Create opportunity</a></header>
 <asp:Label ID="lblMessage" runat="server" />
 <uims:WorkspaceJourney ID="Journey" runat="server" />
 <uims:WorkspaceChart ID="Charts" runat="server" />
 <dl class="ws-metric-band" hidden aria-hidden="true" data-ws-enter="metrics"><div><dt>Openings &amp; opportunities</dt><dd><asp:Literal ID="litTotalOpportunities" runat="server" /></dd><small>All company opportunities</small></div><div><dt>Applications</dt><dd><asp:Literal ID="litTotalApplications" runat="server" /></dd><small><asp:Literal ID="litPendingApps" runat="server" /> awaiting a decision</small></div><div><dt>Confirmed trainees</dt><dd><asp:Literal ID="litTotalTrainees" runat="server" /></dd><small><asp:Literal ID="litActiveTrainees" runat="server" /> confirmed placement records</small></div><div><dt>Work to review</dt><dd><%: Workspace == null ? "—" : Workspace.PendingSubmissions.ToString() %></dd><small>Submitted training work</small></div></dl>
 <div class="ws-company-work" data-ws-enter="work">
  <section class="ws-work-panel"><div class="ws-section-heading"><div><h3>Application review</h3><p>Pending decisions first, then recent applications.</p></div><a href="Applications.aspx">Open review queue <span data-ui-icon="next" aria-hidden="true"></span></a></div>
   <asp:GridView ID="gvRecentApplications" runat="server" CssClass="table ws-applicant-table" AutoGenerateColumns="False" EmptyDataText="No applications yet. New candidates for your company will appear here." GridLines="None"><Columns>
    <asp:TemplateField HeaderText="Candidate"><ItemTemplate><strong><%#: Eval("StudentName") %></strong><small><%#: Eval("Major") %></small></ItemTemplate></asp:TemplateField>
    <asp:BoundField DataField="OpportunityTitle" HeaderText="Opportunity" />
    <asp:TemplateField HeaderText="Decision"><ItemTemplate><span class="badge"><%#: Eval("Status") %></span></ItemTemplate></asp:TemplateField>
   </Columns></asp:GridView>
  </section>
  <aside class="ws-review-desk"><h3>Review desk</h3><p>Go directly to the work that needs your attention.</p>
   <a href="TaskReview.aspx"><span data-ui-icon="document" aria-hidden="true"></span><span><strong>Submitted work</strong><small><%: Workspace == null ? "—" : Workspace.PendingSubmissions.ToString() %> submissions waiting</small></span><span data-ui-icon="next" aria-hidden="true"></span></a>
   <a href="Trainees.aspx"><span data-ui-icon="clock" aria-hidden="true"></span><span><strong>Reported hours</strong><small><%: Workspace == null ? "—" : Workspace.PendingHours.ToString() %> h awaiting approval</small></span><span data-ui-icon="next" aria-hidden="true"></span></a>
   <a href="FinalEvaluation.aspx"><span data-ui-icon="approved" aria-hidden="true"></span><span><strong>Final assessments</strong><small><%: Workspace == null ? "—" : Workspace.PendingFinals.ToString() %> not yet submitted</small></span><span data-ui-icon="next" aria-hidden="true"></span></a>
  </aside>
 </div>
 <section class="ws-trainee-section" data-ws-enter="support"><div class="ws-section-heading"><div><h3>Training in your company</h3><p>Approved progress stays separate from reported hours.</p></div><a href="Trainees.aspx">All trainees</a></div>
 <% if(Workspace != null && Workspace.Trainees.Count > 0) { %><div class="ws-trainee-list"><% foreach(var row in Workspace.Trainees.Take(4)) { %><a href="TraineeDetails.aspx?id=<%: Server.UrlEncode(row.Placement.Id) %>"><span class="ws-person-initial" aria-hidden="true"><%: GetInitials(row.StudentName) %></span><span><strong><%: row.StudentName %></strong><small><%: row.Placement.OpportunityTitle %></small></span><span class="ws-trainee-hours"><strong><%: row.HoursText %></strong><small><%: row.PendingHours %> h pending</small></span><span data-ui-icon="next" aria-hidden="true"></span></a><% } %></div><% } else { %><div class="ws-empty ws-empty-inline"><p>Confirmed trainees will appear after a student accepts your offer.</p><a href="Applications.aspx">Review applications</a></div><% } %>
 </section>
</div>
</asp:Content>
