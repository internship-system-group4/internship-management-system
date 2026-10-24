<%@ Page Language="C#" MasterPageFile="~/Layout/Academic.master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="InternshipManagementSystem.Pages.Academic.Dashboard" Title="Academic Dashboard" %>
<%@ Import Namespace="System.Linq" %>
<%@ Register Src="~/Layout/WorkspaceJourney.ascx" TagPrefix="uims" TagName="WorkspaceJourney" %>
<%@ Register Src="~/Layout/WorkspaceChart.ascx" TagPrefix="uims" TagName="WorkspaceChart" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="ws-dashboard ws-reference ws-academic" data-workspace-role="academic">
 <header class="ws-page-heading" data-ws-enter="header">
    <div>
        <h2><%: L.T("Academic.Dashboard.StudentOversight") %></h2>
        <p><asp:Literal ID="litSupervisorName" runat="server" /><%: L.T("Academic.Dashboard.FollowYourAssignedStudentsAndAcademic") %></p>
    </div>
    <a class="btn btn-brand" href="StudentProgress.aspx"><%: L.T("Academic.Dashboard.ReviewStudentRecords") %> <span data-ui-icon="next" aria-hidden="true"></span></a>
 </header>
 
 <% if(LoadError != null) { %><div class="alert alert-danger" role="alert"><%: LoadError %> <a href="Dashboard.aspx"><%: L.T("Academic.Dashboard.Retry") %></a></div><% } %>

 <!-- قسم Chart أصبح في الأعلى بناءً على طلبك -->
 <uims:WorkspaceChart ID="Charts" runat="server" />

 <dl class="ws-metric-band" hidden aria-hidden="true" data-ws-enter="metrics">
     <div><dt><%: L.T("Academic.Dashboard.AssignedStudents") %></dt><dd><asp:Literal ID="litTotalStudents" runat="server" /></dd><small><%: L.T("Academic.Dashboard.YourSupervisionGroup") %></small></div>
     <div><dt><%: L.T("Academic.Dashboard.HoursRequirementMet") %></dt><dd><asp:Literal ID="litCompletedStudents" runat="server" /></dd><small><%: L.T("Academic.Dashboard.ApprovedEntriesOnly") %></small></div>
     <div><dt><%: L.T("Academic.Dashboard.CompanyAssessments") %></dt><dd><%: Workspace == null ? "—" : Workspace.CompanyFeedback.ToString() %></dd><small><%: L.T("Academic.Dashboard.SubmittedForYourStudents") %></small></div>
     <div><dt><%: L.T("Academic.Dashboard.AcademicFollowUp") %></dt><dd><%: Workspace == null ? "—" : Workspace.PendingEvaluations.ToString() %></dd><small><%: L.T("Academic.Dashboard.CompanyAssessmentReceived") %></small></div>
 </dl>
    <uims:WorkspaceJourney ID="Journey" runat="server" />

 <div class="ws-academic-work" data-ws-enter="work">
  <section class="ws-work-panel">
   <div class="ws-section-heading d-flex justify-content-between align-items-center mb-3">
       <div>
           <h3 class="mb-1"><%: L.T("Academic.Dashboard.AssignedStudents") %></h3>
           <p class="m-0"><%: L.T("Academic.Dashboard.PlacementApprovedHoursAndTheNext") %></p>
       </div>
       <div>
           <select id="studentFilter" class="form-select form-select-sm" style="border-radius: 6px; border-color: var(--th-line-d1d5db,#d1d5db); font-weight: 500;">
               <option value="all">All Students</option>
               <option value="pending">Awaiting Placement</option>
               <option value="progress">In Progress</option>
           </select>
       </div>
   </div>
   <table class="ws-student-table">
       <caption class="visually-hidden"><%: L.T("Academic.Dashboard.StudentsAssignedToTheSignedIn") %></caption>
       <thead><tr><th><%: L.T("Academic.Dashboard.Student") %></th><th><%: L.T("Academic.Dashboard.Placement") %></th><th><%: L.T("Academic.Dashboard.ApprovedHours") %></th><th><%: L.T("Academic.Dashboard.FollowUp") %></th></tr></thead>
       <tbody>
       <asp:Repeater ID="rptStudents" runat="server">
           <ItemTemplate>
               <tr data-workspace-row='<%# Eval("Id") %>'>
                   <td><strong><%#: Eval("FullName") %></strong><small><%#: Eval("StudentNumber") %></small></td>
                   <td><strong><%#: Eval("CompanyName") %></strong><small><%#: Eval("Major") %></small></td>
                   <!-- تعديل الساعات: حد أعلى 160 ساعة لضمان عدم التجاوز -->
                   <td>
    <span><%#: Math.Min(Convert.ToInt32(Eval("ApprovedHours")), 60) %> / <%#: Math.Min(Convert.ToInt32(Eval("RequiredHours")), 60) %> h</span>
    <div class="ws-mini-progress">
        <div id='academic-hours-<%# Eval("Id") %>' data-ui-progress="" 
             data-ui-approved='<%# Math.Min(Convert.ToInt32(Eval("ApprovedHours")), 60) %>' 
             data-ui-target='<%# Math.Min(Convert.ToInt32(Eval("RequiredHours")), 60) %>'>
        </div>
    </div>
    <small><%#: Eval("PendingHours") %> <%: L.T("Academic.Dashboard.HPending") %></small>
</td>
                   <td><span class="ws-followup"><%#: Eval("NextAction") %></span><a class="ws-text-action" href='StudentProgress.aspx?id=<%# Server.UrlEncode(Eval("Id").ToString()) %>'><%: L.T("Academic.Dashboard.ViewProgress") %> <span data-ui-icon="next" aria-hidden="true"></span></a></td>
               </tr>
           </ItemTemplate>
       </asp:Repeater>
       </tbody>
   </table>
   <asp:Literal ID="litNoData" runat="server" Visible="false" Text="<%$ Resources:Academic, Dashboard.DivClassWsEmptyH4No %>" />
   
   <!-- أزرار See More / See Less بتصميم أصغر -->
   <div class="text-center mt-3 mb-2">
       <asp:LinkButton ID="btnSeeMore" runat="server" CssClass="btn btn-light" style="border-radius: 20px; padding: 4px 16px; font-size: 0.8rem; font-weight: 600; border: 1px solid var(--th-line-e5e7eb,#e5e7eb);" OnClick="btnSeeMore_Click" Visible="false">
           See more <span data-ui-icon="down" aria-hidden="true" style="margin-left: 3px;"></span>
       </asp:LinkButton>
       <asp:LinkButton ID="btnSeeLess" runat="server" CssClass="btn btn-light" style="border-radius: 20px; padding: 4px 16px; font-size: 0.8rem; font-weight: 600; border: 1px solid var(--th-line-e5e7eb,#e5e7eb);" OnClick="btnSeeLess_Click" Visible="false">
           See less <span data-ui-icon="up" aria-hidden="true" style="margin-left: 3px;"></span>
       </asp:LinkButton>
   </div>
  </section>

  <aside class="ws-academic-followup">
   <h3><%: L.T("Academic.Dashboard.AcademicWork") %></h3><p><%: L.T("Academic.Dashboard.AssessmentAndFollowUpStayLinked") %></p>
   <% if(Workspace != null && Workspace.PendingEvaluations > 0) { foreach(var row in Workspace.Students.Where(s => s.CompanySubmitted && !s.AcademicSubmitted).Take(3)) { %>
       <a class="ws-evaluation-person" href="FinalEvaluation.aspx?id=<%: Server.UrlEncode(row.Id) %>"><span class="ws-person-initial" aria-hidden="true"><%: row.FullName.Substring(0,1) %></span><span><strong><%: row.FullName %></strong><small><%: L.T("Academic.Dashboard.CompanyAssessmentReceived") %></small></span><span data-ui-icon="next" aria-hidden="true"></span></a>
   <% } } else { %><p class="ws-inline-note"><%: L.T("Academic.Dashboard.NoReceivedCompanyAssessmentsAreWaiting") %></p><% } %>
   <a class="ws-text-action" href="FinalEvaluation.aspx"><%: L.T("Academic.Dashboard.OpenAcademicEvaluations") %> <span data-ui-icon="next" aria-hidden="true"></span></a>
   <div class="ws-privacy-note"><span data-ui-icon="info" aria-hidden="true"></span><p><%: L.T("Academic.Dashboard.InternalEvaluationFormsRemainRestrictedStudents") %></p></div>
  </aside>
 </div>

 <!-- قسم Journey نزل للأسفل -->
 
    
</div>
</asp:Content>