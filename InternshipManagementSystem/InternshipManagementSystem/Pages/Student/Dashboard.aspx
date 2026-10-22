<%@ Page Language="C#" MasterPageFile="~/Layout/Student.master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="InternshipManagementSystem.Pages.StudentArea.Dashboard" Title="Student Dashboard" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
<style>
.student-dashboard .welcome {background:linear-gradient(115deg,var(--brand-dark),var(--brand));color:white;border-radius:var(--radius);padding:26px;margin-bottom:22px}
.student-dashboard .welcome h2 {font-weight:700;font-size:1.65rem;margin:0 0 8px}
.student-dashboard .welcome p {margin:0;opacity:.9}
.student-dashboard .metric,.student-dashboard .panel {background:var(--surface);border:1px solid var(--line);border-radius:var(--radius);box-shadow:var(--shadow)}
.student-dashboard .metric {padding:22px;height:100%;border-top:3px solid var(--brand)}
.student-dashboard .metric-label {color:var(--muted);font-size:.9rem;margin-bottom:10px}
.student-dashboard .metric-value {color:var(--ink);font-size:1.9rem;font-weight:750;line-height:1.2}
.student-dashboard .panel {padding:22px;height:100%}
.student-dashboard .panel h3 {font-size:1.1rem;font-weight:700;margin:0}
.student-dashboard .subtle {color:var(--muted);font-size:.9rem}
.student-dashboard .progress {height:11px;background:var(--brand-light)}
.student-dashboard .progress-bar {background:var(--brand)}
.student-dashboard .table {--bs-table-bg:transparent;margin-bottom:0}
.student-dashboard .table th {font-size:.8rem;color:var(--muted);font-weight:600}
.student-dashboard .table td {vertical-align:middle}
.student-dashboard .tag {display:inline-block;padding:4px 9px;border-radius:20px;background:var(--brand-light);color:var(--brand-dark);font-size:.78rem;font-weight:600}
.student-dashboard .empty {padding:24px 6px;color:var(--muted);text-align:center}
.student-dashboard .quick-link {color:var(--brand);font-weight:600;text-decoration:none}
.student-dashboard .quick-link:hover {text-decoration:underline}
</style>
</asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<section class="student-dashboard">
 <div class="welcome"><h2>Welcome back, <asp:Literal ID="litStudentName" runat="server" />!</h2><p>Here's your internship overview and upcoming work.</p></div>
 <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="alert alert-warning" role="alert">Dashboard data could not be loaded. Please try again later.</asp:Panel>
 <div class="row g-3 mb-4">
  <div class="col-sm-6 col-xl-3"><div class="metric"><div class="metric-label">My Applications</div><div class="metric-value"><asp:Literal ID="litApplications" runat="server" /></div></div></div>
  <div class="col-sm-6 col-xl-3"><div class="metric"><div class="metric-label">Assigned Tasks</div><div class="metric-value"><asp:Literal ID="litTasks" runat="server" /></div></div></div>
  <div class="col-sm-6 col-xl-3"><div class="metric"><div class="metric-label">Evaluated Tasks</div><div class="metric-value"><asp:Literal ID="litEvaluations" runat="server" /></div></div></div>
  <div class="col-sm-6 col-xl-3"><div class="metric"><div class="metric-label">Approved Hours</div><div class="metric-value"><asp:Literal ID="litHours" runat="server" /></div></div></div>
 </div>
 <div class="row g-4 mb-4">
  <div class="col-lg-7"><div class="panel"><div class="d-flex justify-content-between align-items-center mb-3"><h3>Upcoming Tasks</h3><a class="quick-link" href="<%: ResolveUrl("~/Pages/Student/MyTasks.aspx") %>">View all</a></div>
   <div class="table-responsive"><asp:Repeater ID="rptTasks" runat="server"><HeaderTemplate><table class="table"><thead><tr><th>Task</th><th>Deadline</th><th>Status</th></tr></thead><tbody></HeaderTemplate><ItemTemplate><tr><td><%#: Eval("Title") %></td><td><%#: Eval("DeadlineText") %></td><td><span class="tag"><%#: Eval("Status") %></span></td></tr></ItemTemplate><FooterTemplate></tbody></table></FooterTemplate></asp:Repeater></div>
   <asp:Panel ID="pnlNoTasks" runat="server" CssClass="empty" Visible="false">No upcoming tasks right now.</asp:Panel>
  </div></div>
  <div class="col-lg-5"><div class="panel"><h3 class="mb-3">Training Progress</h3><p class="subtle mb-2">Approved training hours</p><div class="d-flex justify-content-between mb-2"><strong><asp:Literal ID="litProgressHours" runat="server" /></strong><strong><asp:Literal ID="litPercent" runat="server" />%</strong></div><div class="progress" role="progressbar" aria-label="Approved training hours progress" aria-valuemin="0" aria-valuemax="100"><div id="progressFill" runat="server" class="progress-bar"></div></div><p class="subtle mt-3 mb-0">Only approved hours count toward your progress.</p></div></div>
 </div>
 <div class="panel"><div class="d-flex justify-content-between align-items-center mb-3"><h3>Recent Applications</h3><a class="quick-link" href="<%: ResolveUrl("~/Pages/Student/MyApplications.aspx") %>">View all</a></div>
  <div class="table-responsive"><asp:Repeater ID="rptApplications" runat="server"><HeaderTemplate><table class="table"><thead><tr><th>Opportunity</th><th>Company</th><th>Applied</th><th>Status</th></tr></thead><tbody></HeaderTemplate><ItemTemplate><tr><td><%#: Eval("Title") %></td><td><%#: Eval("Company") %></td><td><%#: Eval("Date") %></td><td><span class="tag"><%#: Eval("Status") %></span></td></tr></ItemTemplate><FooterTemplate></tbody></table></FooterTemplate></asp:Repeater></div>
  <asp:Panel ID="pnlNoApplications" runat="server" CssClass="empty" Visible="false">No applications yet. <a class="quick-link" href="<%: ResolveUrl("~/Pages/Student/Opportunities.aspx") %>">Explore opportunities</a>.</asp:Panel>
 </div>
</section>
</asp:Content>
