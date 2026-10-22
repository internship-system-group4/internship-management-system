<%@ Page Language="C#" MasterPageFile="~/Layout/Student.master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="InternshipManagementSystem.Pages.StudentArea.Dashboard" Title="Student Dashboard" %>
<%@ Register Src="~/Layout/WorkspaceJourney.ascx" TagPrefix="uims" TagName="WorkspaceJourney" %>
<%@ Register Src="~/Layout/WorkspaceChart.ascx" TagPrefix="uims" TagName="WorkspaceChart" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="ws-dashboard ws-reference ws-student" data-workspace-role="student">
 <header class="ws-page-heading" data-ws-enter="header"><div><h2>Your internship</h2><p><asp:Literal ID="litStudentName" runat="server" />, keep your next step in view.</p></div><a class="btn btn-brand" href="Opportunities.aspx">Explore opportunities <span data-ui-icon="next" aria-hidden="true"></span></a></header>
 <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="alert alert-danger" role="alert">We could not load your internship record. <a href="Dashboard.aspx">Refresh to try again</a>.</asp:Panel>
 <uims:WorkspaceJourney ID="Journey" runat="server" />
 <uims:WorkspaceChart ID="Charts" runat="server" />
 <dl class="ws-metric-band" hidden aria-hidden="true" aria-label="Your training record" data-ws-enter="metrics">
  <div><dt>Applications</dt><dd><asp:Literal ID="litApplications" runat="server" /></dd><small>Your submitted applications</small></div>
  <div><dt>Training tasks</dt><dd><asp:Literal ID="litTasks" runat="server" /></dd><small>Linked to your placement</small></div>
  <div><dt>Tasks evaluated</dt><dd><asp:Literal ID="litEvaluations" runat="server" /></dd><small>Feedback available to you</small></div>
  <div><dt>Approved hours</dt><dd><asp:Literal ID="litHours" runat="server" /></dd><small>Pending hours are separate</small></div>
 </dl>
 <div class="ws-student-work" data-ws-enter="work">
  <section class="ws-work-panel ws-next-work"><div class="ws-section-heading"><div><h3>Your next work</h3><p>Tasks and submissions in your current placement.</p></div><a href="MyTasks.aspx">Open tasks <span data-ui-icon="next" aria-hidden="true"></span></a></div>
   <asp:Repeater ID="rptTasks" runat="server"><ItemTemplate><a class="ws-task-row" href="MyTasks.aspx"><span class="ws-task-icon" data-ui-icon="document" aria-hidden="true"></span><span><strong><%#: Eval("Title") %></strong><small>Due <%#: Eval("DeadlineText") %></small></span><span class="badge"><%#: Eval("Status") %></span><span class="ws-row-arrow" data-ui-icon="next" aria-hidden="true"></span></a></ItemTemplate></asp:Repeater>
   <asp:Panel ID="pnlNoTasks" runat="server" Visible="false" CssClass="ws-empty"><span data-ui-icon="document" aria-hidden="true"></span><h4>No open training tasks</h4><p>Tasks from your company supervisor will appear here once assigned.</p><a href="MyTasks.aspx">View your task record</a></asp:Panel>
  </section>
  <section class="ws-hours" aria-label="Approved training hours"><div class="ws-section-heading"><h3>Training hours</h3><span data-ui-icon="clock" aria-hidden="true"></span></div>
   <div class="ws-hours-number"><%: Workspace == null ? "—" : Workspace.ApprovedHours.ToString() %><span>approved hours</span></div>
   <div class="ws-hours-target"><asp:Literal ID="litProgressHours" runat="server" /><span><asp:Literal ID="litPercent" runat="server" /></span></div>
   <div class="ws-progress-track"><div id="progressFill" runat="server" class="ws-progress-fill"></div></div>
   <div class="ws-hours-pending"><span data-ui-icon="clock" aria-hidden="true"></span><strong><%: Workspace == null ? "—" : Workspace.PendingHours.ToString() %> h</strong> awaiting approval</div>
   <p>Only approved entries count toward your requirement. Completion still needs coordinator approval.</p><a href="Progress.aspx">View hours and feedback <span data-ui-icon="next" aria-hidden="true"></span></a>
  </section>
 </div>
 <section class="ws-application-history" data-ws-enter="support"><div class="ws-section-heading"><div><h3>Applications &amp; placement</h3><p>Recent decisions, with your original submission dates.</p></div><a href="MyApplications.aspx">All applications</a></div>
  <asp:Repeater ID="rptApplications" runat="server"><ItemTemplate><a href="MyApplications.aspx" class="ws-history-row"><span><strong><%#: Eval("Title") %></strong><small><%#: Eval("Company") %></small></span><time><%#: Eval("Date") %></time><span class="badge"><%#: Eval("Status") %></span><span data-ui-icon="next" aria-hidden="true"></span></a></ItemTemplate></asp:Repeater>
  <asp:Panel ID="pnlNoApplications" runat="server" Visible="false" CssClass="ws-empty ws-empty-inline"><p>You have not submitted an application yet.</p><a href="Opportunities.aspx">Find an eligible opportunity</a></asp:Panel>
 </section>
 <nav class="ws-utility-links" aria-label="Student resources"><a href="Profile.aspx"><span data-ui-icon="person" aria-hidden="true"></span> Your profile</a><a href="StudentCVPortfolio.aspx"><span data-ui-icon="document" aria-hidden="true"></span> CV &amp; portfolio</a><a href="../Meetings/MyMeetings.aspx"><span data-ui-icon="calendar" aria-hidden="true"></span> Meetings</a></nav>
</div>
</asp:Content>
