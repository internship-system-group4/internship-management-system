<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.Dashboard" Title="Coordinator Dashboard" %>
<%@ Import Namespace="System.Linq" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/coordinator-dashboard.css?v=20261024-desk-live-4") %>" />
</asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="coordination-desk" data-coordination-desk>
    <header class="desk-heading">
        <div class="desk-title"><span class="desk-title-icon" aria-hidden="true"><i class="desk-icon icon-cap"></i></span><div><h2><%: Text("CoordinationDesk") %></h2><p><%: Text("DeskDescription") %></p></div></div>
        <a class="desk-review-link" href="<%: ResolveUrl("~/Pages/Coordinator/CompletionReview.aspx") %>"><%: Text("OpenCompletionReview") %><i class="desk-icon icon-next" aria-hidden="true"></i></a>
    </header>
    <% if(Model == null) { %>
    <div class="alert alert-warning" role="alert"><%: Text("WeCouldNotLoadTheProgramme") %> <a href="<%: ResolveUrl("~/Pages/Coordinator/Dashboard.aspx") %>"><%: Text("Retry") %></a></div>
    <% } else { %>
    <script type="application/json" data-coordination-model><%= SafeJson %></script>
    <section aria-labelledby="programme-title">
        <div class="desk-section-heading"><div><h3 id="programme-title"><%: Text("CurrentOverview") %></h3><p><%: Text("SnapshotScope") %></p></div><span class="desk-updated"><%: Text("UpdatedOnPageLoad") %> <%: DateTimeOffset.FromUnixTimeMilliseconds(Model.Now).UtcDateTime.ToString("dd MMM yyyy HH:mm", System.Globalization.CultureInfo.GetCultureInfo(L.IsArabic ? "ar-JO" : "en-US")) %> UTC</span></div>
        <div class="desk-stats">
            <% for(int i=0;i<Model.Kpis.Count;i++) { var kpi=Model.Kpis[i]; %>
            <article class="desk-stat">
                <div class="desk-stat-body"><span class="desk-stat-icon" aria-hidden="true"><i class="desk-icon <%: KpiIcons[i] %>"></i></span><div><h4><%: kpi.Label %></h4><strong class="desk-stat-number"><%: KpiValue(i) %></strong><p><%: kpi.Context %></p><% if(kpi.Flow && !string.IsNullOrEmpty(Comparison)) { %><p class="desk-comparison"><%: Comparison %></p><% } %></div></div>
                <button type="button" class="desk-stat-action" data-desk-kpi="<%: i %>" aria-haspopup="dialog" aria-controls="deskRecords"><%: KpiActions[i] %><i class="desk-icon icon-next" aria-hidden="true"></i></button>
            </article>
            <% } %>
        </div>
    </section>
    <section class="desk-followups" aria-labelledby="followup-title">
        <div class="desk-section-heading"><div><h3 id="followup-title"><%: Text("FollowUpTitle") %></h3><p><%: Text("FollowUpDescription") %></p></div></div>
        <% if(FollowUps.All(item => item.Value == 0)) { %><div class="desk-empty desk-all-clear"><strong><%: Text("AllClearTitle") %></strong><span><%: Text("AllClearHelp") %></span></div><% } else { %>
        <div class="desk-followup-grid">
        <% for(int i=0;i<FollowUps.Count;i++) { var item=FollowUps[i]; %>
            <button type="button" class="desk-followup" data-desk-followup="<%: i %>" data-state="<%: item.Value > 0 ? "attention" : "clear" %>" aria-haspopup="dialog" aria-controls="deskRecords" <%= item.Value == 0 ? "disabled" : "" %>>
                <span class="desk-followup-top"><strong><%: item.Value.ToString("N0") %><% if(!string.IsNullOrEmpty(item.Unit)) { %><small> <%: item.Unit %></small><% } %></strong><span class="desk-state"><%: Text(item.Value > 0 ? "NeedsAttention" : "NoFollowUp") %></span></span>
                <span class="desk-followup-label"><%: item.Label %></span><span class="desk-followup-context"><%: item.Context %></span>
                <% if(item.Value > 0) { %><span class="desk-followup-action"><%: Text("ViewAffectedRecords") %><i class="desk-icon icon-next" aria-hidden="true"></i></span><% } %>
            </button>
        <% } %>
        </div>
        <% } %>
    </section>
    <div class="desk-charts">
        <section class="desk-chart-card" aria-labelledby="major-chart-title">
            <header class="desk-chart-heading"><div><h3 id="major-chart-title"><%: Text("StudentsByMajor") %></h3><p><%: Text("MajorScopeDescription") %></p></div><span class="desk-total"><%: Model.Kpis[0].Value %> <%: Text("Students") %></span></header>
            <ul class="desk-major-list">
            <% for(int i=0;i<Model.Bars.Count;i++) { var major=Model.Bars[i]; %>
                <li><button type="button" class="desk-major" data-desk-major="<%: i %>" aria-haspopup="dialog" aria-controls="deskRecords" <%= major.Value == 0 ? "disabled" : "" %>>
                    <span class="desk-major-heading"><span class="desk-major-name"><%: major.Label %></span><span class="desk-major-count"><strong><%: major.Value %></strong><span><%: Percent(major.Value) %>%</span></span></span>
                    <span class="desk-major-track" aria-hidden="true"><span style="width:<%: Percent(major.Value) %>%"></span></span>
                    <span class="desk-major-action"><%: Text(major.Value > 0 ? "ViewStudents" : "NoStudents") %><% if(major.Value > 0) { %><i class="desk-icon icon-next" aria-hidden="true"></i><% } %></span>
                </button></li>
            <% } %>
            </ul>
        </section>
        <section class="desk-chart-card" aria-labelledby="completion-status-title">
            <header class="desk-chart-heading"><div><h3 id="completion-status-title"><%: Text("CompletionStages") %></h3><p><%: Text("CompletionStageHelp") %></p></div></header>
            <ul class="desk-stage-list">
            <% for(int i=0;i<Model.Breakdown.Count;i++) { var category=Model.Breakdown[i]; %>
                <li><button type="button" class="desk-stage" data-desk-stage="<%: i %>" data-tone="<%: category.Tone %>" aria-haspopup="dialog" aria-controls="deskRecords" <%= category.Value == 0 ? "disabled" : "" %>><span class="desk-stage-dot" aria-hidden="true"></span><span><%: category.Label %></span><strong><%: category.Value %></strong><i class="desk-icon icon-next" aria-hidden="true"></i></button></li>
            <% } %>
            </ul>
            <% if(Model.Breakdown.Sum(c => c.Value) == 0) { %><p class="desk-empty"><%: Text("NoConfirmedPlacementsYet") %></p><% } %>
        </section>
    </div>
    <section class="desk-chart-card desk-history" aria-labelledby="approval-chart-title">
        <header class="desk-chart-heading"><div><h3 id="approval-chart-title"><%: Model.TrendTitle %></h3><p><%: RangeCaption %></p></div></header>
        <% if(Months.Sum(m => m.Value) > 0) { %>
        <div class="desk-chart-canvas"><canvas data-desk-chart="approvals" role="img" aria-label="<%: Model.TrendTitle %>"><%: Text("ChartTableAlternative") %></canvas></div>
        <% } else { %><div class="desk-empty"><i class="desk-icon icon-calendar" aria-hidden="true"></i><strong><%: Text("NoDatedApprovals") %></strong><span><%: Text("ApprovalEmptyHelp") %></span></div><% } %>
        <details class="desk-history-details"><summary><%: Text("MonthlyApprovalData") %></summary><div class="desk-data-table"><table><caption class="visually-hidden"><%: Model.TrendTitle %></caption><thead><tr><th scope="col"><%: L.T("Shared.WorkspaceChart.Month") %></th><th scope="col"><%: Model.TrendUnit %></th><th scope="col"><%: Text("Action") %></th></tr></thead><tbody><% for(int i=0;i<Months.Count;i++) { var month=Months[i]; %><tr><th scope="row"><%: month.Label %></th><td><%: month.Value %></td><td><% if(month.Value > 0) { %><button type="button" class="desk-table-action" data-desk-month="<%: i %>" aria-haspopup="dialog" aria-controls="deskRecords"><%: Text("ViewApprovals") %><span class="visually-hidden">: <%: month.Label %></span></button><% } else { %>&mdash;<% } %></td></tr><% } %></tbody></table></div></details>
        <p class="desk-history-note"><i class="desk-icon icon-info" aria-hidden="true"></i><span><%: HistoryNote %></span></p>
    </section>
    <section class="desk-chart-card desk-recent" aria-labelledby="recent-title">
        <header class="desk-chart-heading"><div><h3 id="recent-title"><%: Text("RecentPlacements") %></h3><p><%: Text("RecentPlacementHelp") %></p></div><a class="desk-text-link" href="<%: ResolveUrl("~/Pages/Coordinator/Placements.aspx") %>"><%: Text("AllPlacements") %><i class="desk-icon icon-next" aria-hidden="true"></i></a></header>
        <% if(Summary.Recent.Count == 0) { %><p class="desk-empty"><%: Text("StudentsAppearHereAfterConfirmingOne") %></p><% } else { %>
        <div class="desk-data-table"><table><caption class="visually-hidden"><%: Text("RecentPlacements") %></caption><thead><tr><th scope="col"><%: Text("StudentCompany") %></th><th scope="col"><%: Text("ApprovedHours") %></th><th scope="col"><%: Text("PlacementStatus") %></th></tr></thead><tbody>
        <% foreach(var placement in Summary.Recent) { %><tr><th scope="row"><a href="<%: ResolveUrl("~/Pages/Coordinator/PlacementDetails.aspx?id=" + Uri.EscapeDataString(placement.Placement.Id)) %>"><%: placement.StudentName %></a><small><%: placement.Placement.CompanyName %></small></th><td><bdi><%: placement.HoursText %></bdi></td><td><%: placement.StatusText %></td></tr><% } %>
        </tbody></table></div><% } %>
    </section>
    <div class="desk-programme-facts"><span><%: Text("ProgrammeDirectory") %></span><a href="<%: ResolveUrl("~/Pages/Coordinator/Companies.aspx") %>"><%: string.Format(Text("CompanyCount"), Summary.Companies, Summary.ActiveCompanies) %></a><span><%: string.Format(Text("OpportunityCount"), Summary.Opportunities, Summary.OpenOpportunities) %></span></div>
    <div class="modal fade desk-record-modal" id="deskRecords" tabindex="-1" aria-labelledby="desk-record-title" aria-describedby="desk-record-context" aria-hidden="true"><div class="modal-dialog modal-dialog-centered modal-dialog-scrollable"><div class="modal-content"><div class="modal-header"><div><h3 class="modal-title" id="desk-record-title"></h3><p id="desk-record-context"></p></div><button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="<%: L.T("Shared.WorkspaceChart.CloseDetails") %>"></button></div><div class="modal-body"><ol class="desk-record-list"></ol><p data-desk-no-records hidden><%: L.T("Shared.WorkspaceChart.NoMatchingRecordsInThisScope") %></p></div><div class="modal-footer"><div class="desk-record-pagination"><button type="button" class="btn btn-outline-primary" data-desk-page="-1"><%: L.T("Shared.WorkspaceChart.Previous") %></button><span data-desk-page-label role="status" aria-live="polite"></span><button type="button" class="btn btn-outline-primary" data-desk-page="1"><%: L.T("Shared.WorkspaceChart.Next") %></button></div><button type="button" class="btn btn-primary" data-bs-dismiss="modal"><%: L.T("Shared.WorkspaceChart.Done") %></button></div></div></div></div>
    <noscript><p><%: Text("ScriptHelp") %></p><style>.coordination-desk .desk-stat-action,.coordination-desk .desk-followup-action,.coordination-desk .desk-major-action{display:none}.coordination-desk .desk-followup,.coordination-desk .desk-major,.coordination-desk .desk-stage{pointer-events:none}</style></noscript>
    <% } %>
</div>
</asp:Content>
<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server">
    <script src="<%: ResolveUrl("~/Assets/js/chart.umd.js") %>"></script>
    <script src="<%: ResolveUrl("~/Assets/js/coordinator-dashboard.js?v=20261024-desk-live-3") %>"></script>
</asp:Content>
