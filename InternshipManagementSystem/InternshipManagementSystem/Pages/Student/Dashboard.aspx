<%@ Page Language="C#" MasterPageFile="~/Layout/Student.master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="InternshipManagementSystem.Pages.StudentArea.Dashboard" Title="Student Dashboard" %>
<%@ Register Src="~/Layout/WorkspaceJourney.ascx" TagPrefix="uims" TagName="WorkspaceJourney" %>
<%@ Register Src="~/Layout/WorkspaceChart.ascx" TagPrefix="uims" TagName="WorkspaceChart" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="ws-dashboard ws-reference ws-student" data-workspace-role="student">
 <header class="ws-page-heading" data-ws-enter="header"><div><h2><%: L.T("Student.Dashboard.YourInternship") %></h2><p><asp:Literal ID="litStudentName" runat="server" /><%: L.T("Student.Dashboard.KeepYourNextStepInView") %></p></div><a class="btn btn-brand" href="Opportunities.aspx"><%: L.T("Student.Dashboard.ExploreOpportunities") %> <span data-ui-icon="next" aria-hidden="true"></span></a></header>
 <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="alert alert-danger" role="alert"><%: L.T("Student.Dashboard.WeCouldNotLoadYourInternship") %> <a href="Dashboard.aspx"><%: L.T("Student.Dashboard.RefreshToTryAgain") %></a>.</asp:Panel>
 <uims:WorkspaceJourney ID="Journey" runat="server" />
 <uims:WorkspaceChart ID="Charts" runat="server" />
 <dl class="ws-metric-band" hidden aria-hidden="true" aria-label="<%: L.T("Student.Dashboard.YourTrainingRecord") %>" data-ws-enter="metrics">
  <div><dt><%: L.T("Student.Dashboard.Applications") %></dt><dd><asp:Literal ID="litApplications" runat="server" /></dd><small><%: L.T("Student.Dashboard.YourSubmittedApplications") %></small></div>
  <div><dt><%: L.T("Student.Dashboard.TrainingTasks") %></dt><dd><asp:Literal ID="litTasks" runat="server" /></dd><small><%: L.T("Student.Dashboard.LinkedToYourPlacement") %></small></div>
  <div><dt><%: L.T("Student.Dashboard.TasksEvaluated") %></dt><dd><asp:Literal ID="litEvaluations" runat="server" /></dd><small><%: L.T("Student.Dashboard.FeedbackAvailableToYou") %></small></div>
  <div><dt><%: L.T("Student.Dashboard.ApprovedHours") %></dt><dd><asp:Literal ID="litHours" runat="server" /></dd><small><%: L.T("Student.Dashboard.PendingHoursAreSeparate") %></small></div>
 </dl>
 <div class="ws-student-work" data-ws-enter="work">
  <section class="ws-work-panel ws-next-work"><div class="ws-section-heading"><div><h3><%: L.T("Student.Dashboard.YourNextWork") %></h3><p><%: L.T("Student.Dashboard.TasksAndSubmissionsInYourCurrent") %></p></div><a href="MyTasks.aspx"><%: L.T("Student.Dashboard.OpenTasks") %> <span data-ui-icon="next" aria-hidden="true"></span></a></div>
   <asp:Repeater ID="rptTasks" runat="server"><ItemTemplate><a class="ws-task-row" href="MyTasks.aspx"><span class="ws-task-icon" data-ui-icon="document" aria-hidden="true"></span><span><strong><%#: Eval("Title") %></strong><small><%: L.T("Student.Dashboard.Due") %> <%#: Eval("DeadlineText") %></small></span><span class="badge"><%#: L.Value("TaskStatus", Eval("Status")) %></span><span class="ws-row-arrow" data-ui-icon="next" aria-hidden="true"></span></a></ItemTemplate></asp:Repeater>
   <asp:Panel ID="pnlNoTasks" runat="server" Visible="false" CssClass="ws-empty"><span data-ui-icon="document" aria-hidden="true"></span><h4><%: L.T("Student.Dashboard.NoOpenTrainingTasks") %></h4><p><%: L.T("Student.Dashboard.TasksFromYourCompanySupervisorWill") %></p><a href="MyTasks.aspx"><%: L.T("Student.Dashboard.ViewYourTaskRecord") %></a></asp:Panel>
  </section>
  <section class="ws-hours" aria-label="<%: L.T("Student.Dashboard.ApprovedTrainingHours") %>"><div class="ws-section-heading"><h3><%: L.T("Student.Dashboard.TrainingHours") %></h3><span data-ui-icon="clock" aria-hidden="true"></span></div>
   <div class="ws-hours-number"><%: Workspace == null ? "—" : Workspace.ApprovedHours.ToString() %><span><%: L.T("Student.Dashboard.ApprovedHours2") %></span></div>
   <div class="ws-hours-target"><asp:Literal ID="litProgressHours" runat="server" /><span><asp:Literal ID="litPercent" runat="server" /></span></div>
   <div class="ws-progress-track"><div id="progressFill" runat="server" class="ws-progress-fill"></div></div>
   <div class="ws-hours-pending"><span data-ui-icon="clock" aria-hidden="true"></span><strong><%: Workspace == null ? "—" : Workspace.PendingHours.ToString() %> h</strong> <%: L.T("Student.Dashboard.AwaitingApproval") %></div>
   <p><%: L.T("Student.Dashboard.OnlyApprovedEntriesCountTowardYour") %></p><a href="Progress.aspx"><%: L.T("Student.Dashboard.ViewHoursAndFeedback") %> <span data-ui-icon="next" aria-hidden="true"></span></a>
  </section>
 </div>
 <section class="ws-application-history" data-ws-enter="support"><div class="ws-section-heading"><div><h3><%: L.T("Student.Dashboard.ApplicationsPlacement") %></h3><p><%: L.T("Student.Dashboard.RecentDecisionsWithYourOriginalSubmission") %></p></div><a href="MyApplications.aspx"><%: L.T("Student.Dashboard.AllApplications") %></a></div>
  <asp:Repeater ID="rptApplications" runat="server"><ItemTemplate><a href="MyApplications.aspx" class="ws-history-row"><span><strong><%#: Eval("Title") %></strong><small><%#: Eval("Company") %></small></span><time><%#: Eval("Date") %></time><span class="badge"><%#: L.Value("ApplicationStatus", Eval("Status")) %></span><span data-ui-icon="next" aria-hidden="true"></span></a></ItemTemplate></asp:Repeater>
  <asp:Panel ID="pnlNoApplications" runat="server" Visible="false" CssClass="ws-empty ws-empty-inline"><p><%: L.T("Student.Dashboard.YouHaveNotSubmittedAnApplication") %></p><a href="Opportunities.aspx"><%: L.T("Student.Dashboard.FindAnEligibleOpportunity") %></a></asp:Panel>
 </section>
 <nav class="ws-utility-links" aria-label="<%: L.T("Student.Dashboard.StudentResources") %>"><a href="Profile.aspx"><span data-ui-icon="person" aria-hidden="true"></span> <%: L.T("Student.Dashboard.YourProfile") %></a><a href="StudentCVPortfolio.aspx"><span data-ui-icon="document" aria-hidden="true"></span> <%: L.T("Student.Dashboard.CVPortfolio") %></a><a href="../Meetings/MyMeetings.aspx"><span data-ui-icon="calendar" aria-hidden="true"></span> <%: L.T("Student.Dashboard.Meetings") %></a></nav>
</div>
</asp:Content>
