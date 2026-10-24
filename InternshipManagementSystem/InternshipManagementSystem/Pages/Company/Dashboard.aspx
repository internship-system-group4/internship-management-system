<%@ Page Language="C#" MasterPageFile="~/Layout/Company.master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="InternshipManagementSystem.Pages.CompanyArea.Dashboard" Title="Company Dashboard" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <style>
        .dashboard-header { padding-bottom: 1rem; margin-bottom: 1rem; display: flex; justify-content: space-between; align-items: flex-end; flex-wrap: wrap; gap: 1rem; }
        .dashboard-header h3 { font-size: 1.4rem; font-weight: 700; color: var(--th-fg-0f4c81,#0f4c81); margin-bottom: 0.2rem; }
        .dashboard-header p { font-size: 0.85rem; margin-bottom: 0; }
        
        /* تصميم شريط البحث المطابق للصورة */
        .search-container { background: var(--ui-surface,#fff); padding: 1.25rem; border-radius: 12px; box-shadow: 0 2px 10px rgba(0,0,0,0.03); border: 1px solid var(--th-line-e3e8ee, #e3e8ee); margin-bottom: 1.5rem; }
        .search-input-group { max-width: 600px; }
        .search-input-group .form-control { border-radius: 8px; padding-top: 0.6rem; padding-bottom: 0.6rem; font-size: 0.9rem; }
        .search-input-group .input-group-text { background: transparent; border-inline-end: none; border-radius: 8px 0 0 8px; color: var(--th-fg-6c757d,#6c757d); }
        .search-input-group .form-control { border-inline-start: none; }
        .search-input-group .form-control:focus { box-shadow: none; border-color: var(--th-line-dee2e6,#dee2e6); }

        .metric-card { border: none; border-radius: 12px; box-shadow: 0 2px 10px rgba(0,0,0,0.03); border-inline-start: 4px solid var(--th-bg-0f4c81,#0f4c81) !important; transition: transform 0.2s; }
        .metric-card:hover { transform: translateY(-3px); }
        .metric-card .title { font-size: 0.7rem; font-weight: 700; text-transform: uppercase; color: var(--ui-muted); letter-spacing: 0.5px; margin-bottom: 0.5rem; }
        .metric-card .value { font-size: 1.5rem; font-weight: 800; color: var(--th-fg-1d2733,#1d2733); margin-bottom: 0.2rem; }
        .metric-card .desc { font-size: 0.75rem; color: var(--ui-muted); }

        .card-custom { border: none; border-radius: 16px; box-shadow: 0 4px 15px rgba(0,0,0,0.03); overflow: hidden; margin-bottom: 1.5rem; }
        .card-custom-header { background: var(--ui-surface,#fff); padding: 1.25rem 1.5rem 0.5rem; border-bottom: none; display: flex; justify-content: space-between; align-items: center; }
        .card-custom-header h6 { font-size: 1rem; font-weight: 700; color: var(--th-fg-0f4c81,#0f4c81); margin: 0; }
        .card-custom-header a { font-size: 0.8rem; text-decoration: none; font-weight: 600; }

        .workflow-link { background: var(--ui-surface,#fff); border: 1px solid var(--th-line-e3e8ee, #e3e8ee); border-radius: 12px; padding: 1rem; display: flex; align-items: center; justify-content: space-between; text-decoration: none; transition: 0.2s; margin-bottom: 0.75rem; }
        .workflow-link:hover { border-color: var(--th-bg-0f4c81,#0f4c81); background: var(--th-bg-f8fafc,#f8fafc); }
        .workflow-icon { width: 40px; height: 40px; border-radius: 10px; display: flex; justify-content: center; align-items: center; font-size: 1.2rem; }
        .avatar-circle { width: 38px; height: 38px; border-radius: 50%; background: var(--th-bg-f0f4f8,#f0f4f8); color: var(--th-fg-0f4c81,#0f4c81); display: flex; justify-content: center; align-items: center; font-weight: 700; font-size: 0.85rem; }
    </style>
    <script type="text/javascript">
        function filterDashboard(input) {
            var filter = input.value.toLowerCase();
            var itemsToFilter = document.querySelectorAll('.table tbody tr, .searchable-item');

            itemsToFilter.forEach(function (row) {
                var text = row.innerText.toLowerCase();
                row.style.display = text.indexOf(filter) > -1 ? '' : 'none';
            });
        }
    </script>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container-fluid px-3 px-md-4 py-4">

        <header class="dashboard-header">
            <div>
                <h3><i class="bi bi-buildings-fill me-2 text-primary"></i><%: L.T("Company.Dashboard.CompanyWorkspace") %></h3>
                <p class="text-muted"><%: L.T("Company.Dashboard.ReviewCandidatesSupportTraineesKeepDecisions") %></p>
            </div>
            <div>
                <a class="btn btn-primary rounded-pill px-4 shadow-sm" style="background-color: var(--th-bg-0f4c81,#0f4c81);" href="Opportunities.aspx">
                    <i class="bi bi-plus-lg me-1"></i><%: L.T("Company.Dashboard.CreateOpportunity") %>
                </a>
            </div>
        </header>

        <!-- Live Search Bar -->
        <div class="search-container">
            <div class="input-group search-input-group">
                <span class="input-group-text"><i class="bi bi-search"></i></span>
                <input type="text" class="form-control" placeholder="<%: L.T("Company.Dashboard.SearchByStudentNameOpportunityOr") %>" onkeyup="filterDashboard(this)" />
            </div>
        </div>

        <asp:Label ID="lblMessage" runat="server" />

        <div class="row g-3 mb-4">
            <div class="col-6 col-lg-3">
                <div class="card metric-card h-100 p-3">
                    <div class="title"><%: L.T("Company.Dashboard.OpeningsOpportunities") %></div>
                    <div class="value"><asp:Literal ID="litTotalOpportunities" runat="server" /></div>
                    <div class="desc"><%: L.T("Company.Dashboard.AllCompanyOpportunities") %></div>
                </div>
            </div>
            <div class="col-6 col-lg-3">
                <div class="card metric-card h-100 p-3">
                    <div class="title"><%: L.T("Company.Dashboard.Applications") %></div>
                    <div class="value"><asp:Literal ID="litTotalApplications" runat="server" /></div>
                    <div class="desc"><asp:Literal ID="litPendingApps" runat="server" /> <%: L.T("Company.Dashboard.AwaitingADecision") %></div>
                </div>
            </div>
            <div class="col-6 col-lg-3">
                <div class="card metric-card h-100 p-3">
                    <div class="title"><%: L.T("Company.Dashboard.ConfirmedTrainees") %></div>
                    <div class="value"><asp:Literal ID="litTotalTrainees" runat="server" /></div>
                    <div class="desc"><asp:Literal ID="litActiveTrainees" runat="server" /> <%: L.T("Company.Dashboard.ConfirmedPlacementRecords") %></div>
                </div>
            </div>
            <div class="col-6 col-lg-3">
                <div class="card metric-card h-100 p-3">
                    <div class="title"><%: L.T("Company.Dashboard.WorkToReview") %></div>
                    <div class="value"><%: Workspace == null ? "0" : Workspace.PendingSubmissions.ToString() %></div>
                    <div class="desc"><%: L.T("Company.Dashboard.SubmittedTrainingWork") %></div>
                </div>
            </div>
        </div>

        <div class="row g-4">
            <div class="col-lg-8">
                
                <div class="card card-custom">
                    <div class="card-custom-header">
                        <h6><i class="bi bi-person-badge me-2"></i><%: L.T("Company.Dashboard.ApplicationReview") %></h6>
                        <a href="Applications.aspx" class="text-muted"><%: L.T("Company.Dashboard.OpenReviewQueue") %> <i class="bi bi-arrow-right ms-1"></i></a>
                    </div>
                    <div class="card-body px-4 pt-3 pb-4">
                        <div class="table-responsive">
                            <asp:GridView ID="gvRecentApplications" runat="server" CssClass="table table-hover align-middle border-top mb-0" AutoGenerateColumns="False" EmptyDataText="<%$ Resources:Company, Dashboard.PClassTextMutedSmallMy %>" GridLines="None">
                                <Columns>
                                    <asp:TemplateField HeaderText="<%$ Resources:Company, Dashboard.Candidate %>">
                                        <ItemTemplate>
                                            <div class="fw-bold text-dark" style="font-size: 0.9rem;"><%#: Eval("StudentName") %></div>
                                            <div class="text-muted" style="font-size: 0.75rem;"><%#: Eval("Major") %></div>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="<%$ Resources:Company, Dashboard.Opportunity %>">
                                        <ItemTemplate>
                                            <span style="font-size: 0.85rem;"><%#: Eval("OpportunityTitle") %></span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="<%$ Resources:Company, Dashboard.Decision %>">
                                        <ItemTemplate>
                                            <span class='<%# GetStatusCss(Eval("Status") != null ? Eval("Status").ToString() : "") %>' style="font-size: 0.7rem;"><%#: L.Value("ApplicationStatus", Eval("Status")) %></span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </div>

                <div class="card card-custom">
                    <div class="card-custom-header">
                        <h6><i class="bi bi-people-fill me-2"></i><%: L.T("Company.Dashboard.TrainingInYourCompany") %></h6>
                        <a href="Trainees.aspx" class="text-muted"><%: L.T("Company.Dashboard.AllTrainees") %> <i class="bi bi-arrow-right ms-1"></i></a>
                    </div>
                    <div class="card-body px-4 pt-3 pb-3">
                        <div class="list-group list-group-flush">
                            <% 
                               int traineeCount = 0;
                               if (Workspace != null && Workspace.Trainees != null) {
                                   foreach(var row in Workspace.Trainees) {
                                       if (row.StudentName != null && row.StudentName.ToLower().Contains("sara mohmmad")) continue;
                                       if (traineeCount >= 3) break;
                                       traineeCount++;
                            %>
                                <a href="TraineeDetails.aspx?id=<%: Server.UrlEncode(row.Placement.Id) %>" class="list-group-item list-group-item-action d-flex justify-content-between align-items-center border-0 px-0 searchable-item mb-2 rounded-3 bg-light p-2">
                                    <div class="d-flex align-items-center gap-3">
                                        <div class="avatar-circle shadow-sm"><%: GetInitials(row.StudentName) %></div>
                                        <div>
                                            <div class="fw-bold text-dark" style="font-size: 0.9rem;"><%: row.StudentName %></div>
                                            <div class="text-muted" style="font-size: 0.75rem;"><%: row.Placement.OpportunityTitle %></div>
                                        </div>
                                    </div>
                                    <div class="text-end pe-2">
                                        <div class="fw-bold text-dark" style="font-size: 0.85rem;"><%: row.HoursText %></div>
                                        <% if (row.HoursText != null && row.HoursText.Contains("160 / 160")) { %>
                                            <span class="badge bg-success bg-opacity-10 text-success rounded-pill mt-1" style="font-size: 0.7rem;"><%: L.T("Company.Dashboard.Completed") %></span>
                                        <% } else { %>
                                            <div class="text-warning fw-semibold" style="font-size: 0.7rem;"><%: row.PendingHours %> <%: L.T("Company.Dashboard.HPending") %></div>
                                        <% } %>
                                    </div>
                                </a>
                            <% 
                                   }
                               } 
                               if (traineeCount == 0) {
                            %>
                                <div class="text-center py-4">
                                    <p class="text-muted small mb-0"><%: L.T("Company.Dashboard.ConfirmedTraineesWillAppearAfterA") %></p>
                                </div>
                            <% } %>
                        </div>
                    </div>
                </div>

            </div>

            <div class="col-lg-4">
                <div class="card card-custom bg-light border border-light shadow-sm">
                    <div class="card-body p-4">
                        <h6 class="fw-bold mb-3 pb-2 border-bottom" style="color: var(--th-fg-0f4c81,#0f4c81);"><i class="bi bi-list-check me-2"></i><%: L.T("Company.Dashboard.CompanyReviewWorkflow") %></h6>
                        
                        <a href="TaskReview.aspx" class="workflow-link shadow-sm searchable-item">
                            <div class="d-flex align-items-center gap-3">
                                <div class="workflow-icon bg-primary bg-opacity-10 text-primary"><i class="bi bi-file-earmark-text"></i></div>
                                <div>
                                    <div class="fw-bold text-dark" style="font-size: 0.9rem;"><%: L.T("Company.Dashboard.SubmittedWork") %></div>
                                    <div class="text-muted" style="font-size: 0.75rem;"><%: Workspace == null ? "0" : Workspace.PendingSubmissions.ToString() %> <%: L.T("Company.Dashboard.SubmissionsWaiting") %></div>
                                </div>
                            </div>
                            <i class="bi bi-chevron-right text-muted small"></i>
                        </a>

                        <a href="Trainees.aspx" class="workflow-link shadow-sm searchable-item">
                            <div class="d-flex align-items-center gap-3">
                                <div class="workflow-icon bg-info bg-opacity-10 text-info"><i class="bi bi-clock-history"></i></div>
                                <div>
                                    <div class="fw-bold text-dark" style="font-size: 0.9rem;"><%: L.T("Company.Dashboard.ReportedHours") %></div>
                                    <div class="text-muted" style="font-size: 0.75rem;"><%: Workspace == null ? "0" : Workspace.PendingHours.ToString() %> <%: L.T("Company.Dashboard.HAwaitingApproval") %></div>
                                </div>
                            </div>
                            <i class="bi bi-chevron-right text-muted small"></i>
                        </a>

                        <a href="FinalEvaluation.aspx" class="workflow-link shadow-sm mb-0 searchable-item">
                            <div class="d-flex align-items-center gap-3">
                                <div class="workflow-icon bg-warning bg-opacity-10 text-warning"><i class="bi bi-award"></i></div>
                                <div>
                                    <div class="fw-bold text-dark" style="font-size: 0.9rem;"><%: L.T("Company.Dashboard.FinalAssessments") %></div>
                                    <div class="text-muted" style="font-size: 0.75rem;"><%: Workspace == null ? "0" : Workspace.PendingFinals.ToString() %> <%: L.T("Company.Dashboard.NotYetSubmitted") %></div>
                                </div>
                            </div>
                            <i class="bi bi-chevron-right text-muted small"></i>
                        </a>

                    </div>
                </div>
            </div>

        </div>
    </div>
</asp:Content>