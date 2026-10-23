<%@ Page Language="C#" MasterPageFile="~/Layout/Company.master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="InternshipManagementSystem.Pages.CompanyArea.Dashboard" Title="Company Dashboard" %>
<%@ Import Namespace="System.Linq" %>
<%@ Register Src="~/Layout/WorkspaceJourney.ascx" TagPrefix="uims" TagName="WorkspaceJourney" %>
<%@ Register Src="~/Layout/WorkspaceChart.ascx" TagPrefix="uims" TagName="WorkspaceChart" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="ws-dashboard ws-reference ws-company" data-workspace-role="company">
 <header class="ws-page-heading" data-ws-enter="header"><div><h2><%: L.T("Company.Dashboard.CompanyWorkspace") %></h2><p><%: L.T("Company.Dashboard.ReviewCandidatesSupportTraineesKeepDecisions") %></p></div><a class="btn btn-brand" href="Opportunities.aspx"><span data-ui-icon="plus" aria-hidden="true"></span><%: L.T("Company.Dashboard.CreateOpportunity") %></a></header>
 <asp:Label ID="lblMessage" runat="server" />
 <uims:WorkspaceJourney ID="Journey" runat="server" />
 <uims:WorkspaceChart ID="Charts" runat="server" />
 <dl class="ws-metric-band" hidden aria-hidden="true" data-ws-enter="metrics"><div><dt><%: L.T("Company.Dashboard.OpeningsOpportunities") %></dt><dd><asp:Literal ID="litTotalOpportunities" runat="server" /></dd><small><%: L.T("Company.Dashboard.AllCompanyOpportunities") %></small></div><div><dt><%: L.T("Company.Dashboard.Applications") %></dt><dd><asp:Literal ID="litTotalApplications" runat="server" /></dd><small><asp:Literal ID="litPendingApps" runat="server" /> <%: L.T("Company.Dashboard.AwaitingADecision") %></small></div><div><dt><%: L.T("Company.Dashboard.ConfirmedTrainees") %></dt><dd><asp:Literal ID="litTotalTrainees" runat="server" /></dd><small><asp:Literal ID="litActiveTrainees" runat="server" /> <%: L.T("Company.Dashboard.ConfirmedPlacementRecords") %></small></div><div><dt><%: L.T("Company.Dashboard.WorkToReview") %></dt><dd><%: Workspace == null ? "—" : Workspace.PendingSubmissions.ToString() %></dd><small><%: L.T("Company.Dashboard.SubmittedTrainingWork") %></small></div></dl>
 <div class="ws-company-work" data-ws-enter="work">
  <section class="ws-work-panel"><div class="ws-section-heading"><div><h3><%: L.T("Company.Dashboard.ApplicationReview") %></h3><p><%: L.T("Company.Dashboard.PendingDecisionsFirstThenRecentApplications") %></p></div><a href="Applications.aspx"><%: L.T("Company.Dashboard.OpenReviewQueue") %> <span data-ui-icon="next" aria-hidden="true"></span></a></div>
   <asp:GridView ID="gvRecentApplications" runat="server" CssClass="table ws-applicant-table" AutoGenerateColumns="False" EmptyDataText="<%$ Resources:Company, Dashboard.NoApplicationsYetNewCandidatesFor %>" GridLines="None"><Columns>
    <asp:TemplateField HeaderText="<%$ Resources:Company, Dashboard.Candidate %>"><ItemTemplate><strong><%#: Eval("StudentName") %></strong><small><%#: Eval("Major") %></small></ItemTemplate></asp:TemplateField>
    <asp:BoundField DataField="OpportunityTitle" HeaderText="<%$ Resources:Company, Dashboard.Opportunity %>" />
    <asp:TemplateField HeaderText="<%$ Resources:Company, Dashboard.Decision %>"><ItemTemplate><span class="badge"><%#: L.Value("ApplicationStatus", Eval("Status")) %></span></ItemTemplate></asp:TemplateField>
   </Columns></asp:GridView>
  </section>
  <aside class="ws-review-desk"><h3><%: L.T("Company.Dashboard.ReviewDesk") %></h3><p><%: L.T("Company.Dashboard.GoDirectlyToTheWorkThat") %></p>
   <a href="TaskReview.aspx"><span data-ui-icon="document" aria-hidden="true"></span><span><strong><%: L.T("Company.Dashboard.SubmittedWork") %></strong><small><%: Workspace == null ? "—" : Workspace.PendingSubmissions.ToString() %> <%: L.T("Company.Dashboard.SubmissionsWaiting") %></small></span><span data-ui-icon="next" aria-hidden="true"></span></a>
   <a href="Trainees.aspx"><span data-ui-icon="clock" aria-hidden="true"></span><span><strong><%: L.T("Company.Dashboard.ReportedHours") %></strong><small><%: Workspace == null ? "—" : Workspace.PendingHours.ToString() %> <%: L.T("Company.Dashboard.HAwaitingApproval") %></small></span><span data-ui-icon="next" aria-hidden="true"></span></a>
   <a href="FinalEvaluation.aspx"><span data-ui-icon="approved" aria-hidden="true"></span><span><strong><%: L.T("Company.Dashboard.FinalAssessments") %></strong><small><%: Workspace == null ? "—" : Workspace.PendingFinals.ToString() %> <%: L.T("Company.Dashboard.NotYetSubmitted") %></small></span><span data-ui-icon="next" aria-hidden="true"></span></a>
  </aside>
 </div>
 <section class="ws-trainee-section" data-ws-enter="support"><div class="ws-section-heading"><div><h3><%: L.T("Company.Dashboard.TrainingInYourCompany") %></h3><p><%: L.T("Company.Dashboard.ApprovedProgressStaysSeparateFromReported") %></p></div><a href="Trainees.aspx"><%: L.T("Company.Dashboard.AllTrainees") %></a></div>
 <% if(Workspace != null && Workspace.Trainees.Count > 0) { %><div class="ws-trainee-list"><% foreach(var row in Workspace.Trainees.Take(4)) { %><a href="TraineeDetails.aspx?id=<%: Server.UrlEncode(row.Placement.Id) %>"><span class="ws-person-initial" aria-hidden="true"><%: GetInitials(row.StudentName) %></span><span><strong><%: row.StudentName %></strong><small><%: row.Placement.OpportunityTitle %></small></span><span class="ws-trainee-hours"><strong><%: row.HoursText %></strong><small><%: row.PendingHours %> <%: L.T("Company.Dashboard.HPending") %></small></span><span data-ui-icon="next" aria-hidden="true"></span></a><% } %></div><% } else { %><div class="ws-empty ws-empty-inline"><p><%: L.T("Company.Dashboard.ConfirmedTraineesWillAppearAfterA") %></p><a href="Applications.aspx"><%: L.T("Company.Dashboard.ReviewApplications") %></a></div><% } %>
 </section>
</div>
</asp:Content>
