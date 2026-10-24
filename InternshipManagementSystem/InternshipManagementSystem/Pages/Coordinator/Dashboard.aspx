<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.Dashboard" Title="Coordinator Dashboard" %>
<%@ Import Namespace="System.Linq" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/coordinator-dashboard.css?v=20261024-theme-7") %>" />

    <style>
        .dashboard-header { padding-bottom: 1rem; margin-bottom: 1rem; display: flex; justify-content: space-between; align-items: flex-end; flex-wrap: wrap; gap: 1rem; }
        .dashboard-header h3 { font-size: 1.4rem; font-weight: 700; color: var(--th-fg-0f4c81,#0f4c81); margin-bottom: 0.2rem; }
        .dashboard-header p { font-size: 0.85rem; margin-bottom: 0; color: var(--th-fg-0f4c81,#0f4c81); opacity: 0.8; }

        /* تم توحيد لون الحدود الجانبية لجميع البطاقات لتكون باللون الكحلي الداكن */
        .metric-card { border: none; border-radius: 12px; box-shadow: 0 2px 10px rgba(0,0,0,0.03); border-inline-start: 4px solid var(--th-fg-1d2733,#1d2733) !important; transition: transform 0.2s; background-color: #fff; cursor: pointer; text-align: left; width: 100%; display: block; }
        .metric-card:hover { transform: translateY(-3px); }
        .metric-card .title { font-size: 0.7rem; font-weight: 700; text-transform: uppercase; color: var(--th-fg-0f4c81,#0f4c81); letter-spacing: 0.5px; margin-bottom: 0.5rem; }
        .metric-card .value { font-size: 1.5rem; font-weight: 800; color: var(--th-fg-1d2733,#1d2733); margin-bottom: 0.2rem; }
        .metric-card .desc { font-size: 0.75rem; color: var(--th-fg-0f4c81,#0f4c81); opacity: 0.9; }

        .card-custom { border: none; border-radius: 16px; box-shadow: 0 4px 15px rgba(0,0,0,0.03); overflow: hidden; margin-bottom: 1.5rem; background-color: #fff; }
        .card-custom-header { background: var(--ui-surface,#fff); padding: 1.25rem 1.5rem 0.5rem; border-bottom: none; display: flex; justify-content: space-between; align-items: center; }
        .card-custom-header h6 { font-size: 1rem; font-weight: 700; color: var(--th-fg-0f4c81,#0f4c81); margin: 0; text-transform: none; }
        .card-custom-header a { font-size: 0.8rem; text-decoration: none; font-weight: 600; color: var(--th-fg-0f4c81,#0f4c81); }

        .workflow-link { background: var(--ui-surface,#fff); border: 1px solid var(--th-line-e3e8ee, #e3e8ee); border-radius: 12px; padding: 1rem; display: flex; align-items: center; justify-content: space-between; text-decoration: none; transition: 0.2s; margin-bottom: 0.75rem; width: 100%; text-align: left; }
        .workflow-link:hover { border-color: var(--th-bg-0f4c81,#0f4c81); background: var(--th-bg-f8fafc,#f8fafc); }
        .workflow-icon { width: 40px; height: 40px; border-radius: 10px; display: flex; justify-content: center; align-items: center; font-size: 1.2rem; flex-shrink: 0; }
        
        .progress-slim { height: 6px; border-radius: 3px; background-color: var(--th-bg-e8f0f7,#e8f0f7); margin-top: 6px; }
        .progress-slim .progress-bar { background-color: var(--th-bg-0f4c81,#0f4c81); border-radius: 3px; }
        
        .section-overline { font-size: 0.75rem; font-weight: 700; color: var(--th-fg-0f4c81,#0f4c81); text-transform: uppercase; letter-spacing: 0.5px; opacity: 0.9; }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="container-fluid px-3 px-md-4 py-4 coordination-desk" data-coordination-desk>
    
    <header class="dashboard-header border-bottom pb-3 mb-4">
        <div>
            <div class="section-overline mb-1">University Portal > <span class="fw-bolder">Overview</span></div>
            <h3><i class="bi bi-grid-1x2-fill me-2 text-primary"></i><%: Text("CoordinationDesk") %></h3>
            <p><%: Text("DeskDescription") %></p>
        </div>
        <div>
            <a class="btn btn-primary rounded-pill px-4 shadow-sm" style="background-color: var(--th-bg-0f4c81,#0f4c81); font-size: 0.85rem; font-weight: 600;" href="<%: ResolveUrl("~/Pages/Coordinator/CompletionReview.aspx") %>">
                <i class="bi bi-check2-circle me-1"></i><%: Text("OpenCompletionReview") %>
            </a>
        </div>
    </header>

    <% if(Model == null) { %>
        <div class="alert alert-warning rounded-4 shadow-sm border-0" role="alert">
            <i class="bi bi-exclamation-triangle me-2"></i><%: Text("WeCouldNotLoadTheProgramme") %> 
            <a href="<%: ResolveUrl("~/Pages/Coordinator/Dashboard.aspx") %>" class="alert-link ms-2"><%: Text("Retry") %></a>
        </div>
    <% } else { %>
        <script type="application/json" data-coordination-model><%= SafeJson %></script>
        
        <div class="d-flex justify-content-between align-items-center mb-3">
            <div class="section-overline m-0"><%: Text("CurrentOverview") %> - <%: Text("SnapshotScope") %></div>
            <span class="text-muted" style="font-size: 0.75rem; color: var(--th-fg-0f4c81,#0f4c81) !important; opacity: 0.8;"><i class="bi bi-clock me-1"></i><%: Text("UpdatedOnPageLoad") %> <%: DateTimeOffset.FromUnixTimeMilliseconds(Model.Now).UtcDateTime.ToString("dd MMM yyyy HH:mm") %></span>
        </div>

        <div class="row g-3 mb-4">
            <% for(int i=0;i<Model.Kpis.Count;i++) { var kpi=Model.Kpis[i]; %>
            <div class="col-6 col-lg-3">
                <button type="button" class="card metric-card h-100 p-3" data-desk-kpi="<%: i %>" aria-haspopup="dialog" aria-controls="deskRecords">
                    <div class="title"><%: kpi.Label %></div>
                    <div class="value"><%: KpiValue(i) %></div>
                    <div class="desc"><%: kpi.Context %></div>
                    <% if(kpi.Flow && !string.IsNullOrEmpty(Comparison)) { %>
                        <div class="desc fw-bold mt-1" style="font-size: 0.7rem; color: #1e7e34 !important;"><i class="bi bi-arrow-up-right"></i> <%: Comparison %></div>
                    <% } %>
                </button>
            </div>
            <% } %>
        </div>

        <div class="row g-4">
            <div class="col-lg-8">
                
                <div class="card card-custom">
                    <div class="card-custom-header">
                        <h6><i class="bi bi-person-badge me-2"></i><%: Text("RecentPlacements") %></h6>
                        <a href="<%: ResolveUrl("~/Pages/Coordinator/Placements.aspx") %>"><%: Text("AllPlacements") %> <i class="bi bi-arrow-right ms-1"></i></a>
                    </div>
                    <div class="card-body px-4 pt-3 pb-4">
                        <% if(Summary.Recent.Count == 0) { %>
                            <div class="text-center py-4 small" style="color: var(--th-fg-0f4c81,#0f4c81); opacity: 0.8;"><%: Text("StudentsAppearHereAfterConfirmingOne") %></div>
                        <% } else { %>
                        <div class="table-responsive">
                            <table class="table table-hover align-middle border-top mb-0">
                                <thead class="bg-light text-uppercase" style="font-size: 0.75rem; color: var(--th-fg-0f4c81,#0f4c81);">
                                    <tr>
                                        <th><%: Text("StudentCompany") %></th>
                                        <th><%: Text("ApprovedHours") %></th>
                                        <th><%: Text("PlacementStatus") %></th>
                                    </tr>
                                </thead>
                                <tbody>
                                <% foreach(var placement in Summary.Recent) { %>
                                    <tr>
                                        <td>
                                            <a href="<%: ResolveUrl("~/Pages/Coordinator/PlacementDetails.aspx?id=" + Uri.EscapeDataString(placement.Placement.Id)) %>" class="fw-bold text-dark text-decoration-none" style="font-size: 0.9rem;"><%: placement.StudentName %></a>
                                            <div style="font-size: 0.75rem; color: var(--th-fg-0f4c81,#0f4c81); opacity: 0.8;"><i class="bi bi-building me-1"></i><%: placement.Placement.CompanyName %></div>
                                        </td>
                                        <td><div class="fw-bold text-dark" style="font-size: 0.85rem;"><bdi><%: placement.HoursText %></bdi></div></td>
                                        <td><span class="badge bg-primary bg-opacity-10 text-primary rounded-pill"><%: placement.StatusText %></span></td>
                                    </tr>
                                <% } %>
                                </tbody>
                            </table>
                        </div>
                        <% } %>
                    </div>
                </div>

                <div class="card card-custom">
                    <div class="card-custom-header border-bottom pb-3">
                        <h6><i class="bi bi-graph-up me-2"></i><%: Model.TrendTitle %></h6>
                        <span style="font-size: 0.75rem; color: var(--th-fg-0f4c81,#0f4c81); opacity: 0.8;"><%: RangeCaption %></span>
                    </div>
                    <div class="card-body p-4">
                        <% if(Months.Sum(m => m.Value) > 0) { %>
                            <div style="height: 250px;"><canvas data-desk-chart="approvals" role="img" aria-label="<%: Model.TrendTitle %>"></canvas></div>
                        <% } else { %>
                            <div class="text-center py-5" style="color: var(--th-fg-0f4c81,#0f4c81); opacity: 0.7;">
                                <i class="bi bi-calendar-x fs-1 mb-2"></i>
                                <div class="fw-bold"><%: Text("NoDatedApprovals") %></div>
                                <div class="small"><%: Text("ApprovalEmptyHelp") %></div>
                            </div>
                        <% } %>
                    </div>
                </div>

                <div class="card card-custom mb-0">
                    <div class="card-custom-header">
                        <h6><i class="bi bi-bar-chart-steps me-2"></i><%: Text("StudentsByMajor") %></h6>
                        <span class="badge bg-light text-dark border"><%: Model.Kpis[0].Value %> <%: Text("Students") %></span>
                    </div>
                    <div class="card-body p-4 pt-2">
                        <div class="row g-3">
                            <% for(int i=0;i<Model.Bars.Count;i++) { var major=Model.Bars[i]; %>
                            <div class="col-md-6">
                                <button type="button" class="btn w-100 text-start p-2 border-0 bg-transparent" data-desk-major="<%: i %>" aria-haspopup="dialog" aria-controls="deskRecords" <%= major.Value == 0 ? "disabled" : "" %>>
                                    <div class="d-flex justify-content-between align-items-center mb-1">
                                        <span class="fw-semibold text-dark" style="font-size: 0.8rem;"><%: major.Label %></span>
                                        <span style="font-size: 0.75rem; color: var(--th-fg-0f4c81,#0f4c81);"><strong><%: major.Value %></strong> (<%: Percent(major.Value) %>%)</span>
                                    </div>
                                    <div class="progress progress-slim">
                                        <div class="progress-bar" style="width:<%: Percent(major.Value) %>%"></div>
                                    </div>
                                </button>
                            </div>
                            <% } %>
                        </div>
                    </div>
                </div>

            </div>

            <div class="col-lg-4">
                
                <div class="card card-custom bg-light border border-light shadow-sm">
                    <div class="card-body p-4">
                        <h6 class="fw-bold mb-3 pb-2 border-bottom" style="color: var(--th-fg-0f4c81,#0f4c81);"><i class="bi bi-bell-fill me-2 text-warning"></i><%: Text("FollowUpTitle") %></h6>
                        
                        <% if(FollowUps.All(item => item.Value == 0)) { %>
                            <div class="text-center py-4">
                                <i class="bi bi-check-circle-fill text-success fs-1 mb-2"></i>
                                <p class="mb-0 fw-bold text-dark"><%: Text("AllClearTitle") %></p>
                                <p class="small" style="color: var(--th-fg-0f4c81,#0f4c81); opacity: 0.8;"><%: Text("AllClearHelp") %></p>
                            </div>
                        <% } else { %>
                            <% for(int i=0;i<FollowUps.Count;i++) { var item=FollowUps[i]; %>
                            <button type="button" class="workflow-link shadow-sm" data-desk-followup="<%: i %>" data-state="<%: item.Value > 0 ? "attention" : "clear" %>" aria-haspopup="dialog" aria-controls="deskRecords" <%= item.Value == 0 ? "disabled" : "" %>>
                                <div class="d-flex align-items-center gap-3">
                                    <div class="workflow-icon <%: item.Value > 0 ? "bg-warning bg-opacity-10 text-warning" : "bg-success bg-opacity-10 text-success" %>">
                                        <i class="bi <%: item.Value > 0 ? "bi-exclamation-triangle" : "bi-check-lg" %>"></i>
                                    </div>
                                    <div>
                                        <div class="fw-bold text-dark" style="font-size: 0.85rem;"><%: item.Label %></div>
                                        <div style="font-size: 0.75rem; color: var(--th-fg-0f4c81,#0f4c81); opacity: 0.9;"><strong class="text-dark"><%: item.Value.ToString("N0") %></strong> <%: item.Context %></div>
                                    </div>
                                </div>
                                <% if(item.Value > 0) { %><i class="bi bi-chevron-right small" style="color: var(--th-fg-0f4c81,#0f4c81); opacity: 0.6;"></i><% } %>
                            </button>
                            <% } %>
                        <% } %>
                    </div>
                </div>

                <div class="card card-custom">
                    <div class="card-custom-header">
                        <h6><i class="bi bi-pie-chart-fill me-2"></i><%: Text("CompletionStages") %></h6>
                    </div>
                    <div class="card-body p-0">
                        <div class="list-group list-group-flush">
                            <% for(int i=0;i<Model.Breakdown.Count;i++) { var category=Model.Breakdown[i]; %>
                            <button type="button" class="list-group-item list-group-item-action d-flex justify-content-between align-items-center p-3" data-desk-stage="<%: i %>" data-tone="<%: category.Tone %>" aria-haspopup="dialog" aria-controls="deskRecords" <%= category.Value == 0 ? "disabled" : "" %>>
                                <span style="font-size: 0.85rem; font-weight: 500; color: var(--th-fg-2b4560,#2b4560);"><%: category.Label %></span>
                                <span class="badge bg-light text-dark border rounded-pill"><%: category.Value %> <i class="bi bi-chevron-right ms-1" style="font-size: 0.6rem; color: var(--th-fg-0f4c81,#0f4c81); opacity: 0.5;"></i></span>
                            </button>
                            <% } %>
                        </div>
                        <% if(Model.Breakdown.Sum(c => c.Value) == 0) { %>
                            <p class="text-center small py-4 m-0" style="color: var(--th-fg-0f4c81,#0f4c81); opacity: 0.8;"><%: Text("NoConfirmedPlacementsYet") %></p>
                        <% } %>
                    </div>
                </div>

            </div>
        </div>

        <div class="modal fade desk-record-modal" id="deskRecords" tabindex="-1" aria-labelledby="desk-record-title" aria-describedby="desk-record-context" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable modal-lg">
                <div class="modal-content border-0 shadow-lg rounded-4">
                    <div class="modal-header bg-light border-bottom-0">
                        <div>
                            <h5 class="modal-title fw-bold text-dark" id="desk-record-title" style="font-size: 1.1rem;"></h5>
                            <p id="desk-record-context" class="mb-0" style="font-size: 0.8rem; color: var(--th-fg-0f4c81,#0f4c81); opacity: 0.9;"></p>
                        </div>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="<%: L.T("Shared.WorkspaceChart.CloseDetails") %>"></button>
                    </div>
                    <div class="modal-body p-4">
                        <ol class="desk-record-list ps-3 m-0" style="font-size: 0.9rem; line-height: 1.8; color: var(--th-fg-0f4c81,#0f4c81);"></ol>
                        <p data-desk-no-records hidden class="text-center m-0" style="color: var(--th-fg-0f4c81,#0f4c81); opacity: 0.8;"><%: L.T("Shared.WorkspaceChart.NoMatchingRecordsInThisScope") %></p>
                    </div>
                    <div class="modal-footer border-top-0 bg-light d-flex justify-content-between align-items-center">
                        <div class="desk-record-pagination d-flex gap-2 align-items-center">
                            <button type="button" class="btn btn-sm btn-outline-secondary rounded-pill px-3" data-desk-page="-1"><%: L.T("Shared.WorkspaceChart.Previous") %></button>
                            <span data-desk-page-label role="status" aria-live="polite" class="fw-semibold" style="font-size: 0.8rem; color: var(--th-fg-0f4c81,#0f4c81);"></span>
                            <button type="button" class="btn btn-sm btn-outline-secondary rounded-pill px-3" data-desk-page="1"><%: L.T("Shared.WorkspaceChart.Next") %></button>
                        </div>
                        <button type="button" class="btn btn-primary rounded-pill px-4" data-bs-dismiss="modal" style="background-color: var(--th-bg-0f4c81,#0f4c81);"><%: L.T("Shared.WorkspaceChart.Done") %></button>
                    </div>
                </div>
            </div>
        </div>

    <% } %>
</div>
</asp:Content>

<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server">
    <script src="<%: ResolveUrl("~/Assets/js/chart.umd.js") %>"></script>
    <script src="<%: ResolveUrl("~/Assets/js/coordinator-dashboard.js?v=20261024-desk-live-3") %>"></script>
</asp:Content>