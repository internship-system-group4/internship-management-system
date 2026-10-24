<%@ Page Language="C#" MasterPageFile="~/Layout/Company.master" AutoEventWireup="true" CodeBehind="TraineeDetails.aspx.cs" Inherits="InternshipManagementSystem.Pages.CompanyArea.TraineeDetails" Title="Trainee Details" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">

    <style>
        .text-brand { color: var(--th-fg-0f4c81,#0f4c81) !important; }
        .bg-brand { background-color: var(--th-bg-0f4c81,#0f4c81) !important; color: white; border: none; transition: 0.2s; }
        .bg-brand:hover { background-color: var(--th-bg-0a365c,#0a365c) !important; color: white; transform: translateY(-1px); }
        .page-header-title { font-size: 1.75rem; font-weight: 700; color: var(--th-fg-0f4c81,#0f4c81); }

        .student-avatar-large { width: 70px; height: 70px; border-radius: 50%; background-color: var(--th-bg-f0f4f8,#f0f4f8); color: var(--th-fg-0f4c81,#0f4c81); font-weight: 700; font-size: 1.75rem; display: flex; align-items: center; justify-content: center; border: 2px solid var(--th-line-e3e8ee,#e3e8ee); }
        .progress-wrapper { background-color: var(--th-bg-e2e8f0,#e2e8f0); border-radius: 50px; height: 8px; overflow: hidden; width: 100%; }
        .progress-fill { height: 100%; background-color: var(--th-bg-0f4c81,#0f4c81); border-radius: 50px; transition: width 0.5s ease; }

        .info-label { font-size: 0.75rem; color: var(--ui-muted); text-transform: uppercase; font-weight: 700; margin-bottom: 0.25rem; letter-spacing: 0.5px; }
        .info-value { font-size: 0.95rem; color: var(--th-fg-1e293b,#1e293b); font-weight: 600; margin-bottom: 0; }

        .clean-table { width: 100%; border-collapse: collapse; }
        .clean-table th { padding: 1rem; border-bottom: 2px solid var(--th-line-e2e8f0,#e2e8f0); color: var(--ui-muted); font-size: 0.75rem; text-transform: uppercase; font-weight: 700; text-align: start; letter-spacing: 0.5px; }
        .clean-table td { padding: 1rem; border-bottom: 1px solid var(--th-line-f1f5f9,#f1f5f9); color: var(--th-fg-334155,#334155); font-size: 0.875rem; font-weight: 500; vertical-align: middle; }
        .clean-table tr:hover td { background-color: var(--th-bg-f8fafc,#f8fafc); }

        .btn-table-action { background-color: var(--th-bg-f1f5f9,#f1f5f9); color: var(--th-fg-0f4c81,#0f4c81); font-weight: 700; padding: 6px 18px; border-radius: 50px; border: 1px solid var(--th-line-e2e8f0,#e2e8f0); transition: 0.2s; text-decoration: none; display: inline-block; font-size: 0.85rem; white-space: nowrap; }
        .btn-table-action:hover { background-color: var(--th-bg-e2e8f0,#e2e8f0); color: var(--th-fg-0a365c,#0a365c); border-color: var(--th-line-cbd5e1,#cbd5e1); }

        .status-assigned { background-color: var(--th-bg-eff6ff,#eff6ff); color: var(--th-fg-1d4ed8,#1d4ed8); border: 1px solid var(--th-line-bfdbfe,#bfdbfe); }
        .status-submitted { background-color: var(--th-bg-e0f2fe,#e0f2fe); color: var(--th-fg-0369a1,#0369a1); border: 1px solid var(--th-line-bae6fd,#bae6fd); }
        .status-graded { background-color: var(--th-bg-f0fdf4,#f0fdf4); color: var(--th-fg-15803d,#15803d); border: 1px solid var(--th-line-bbf7d0,#bbf7d0); }
        .status-revision { background-color: var(--th-bg-fef2f2,#fef2f2); color: var(--th-fg-b91c1c,#b91c1c); border: 1px solid var(--th-line-fecaca,#fecaca); }

        .cv-btn-theme { background-color: var(--th-bg-0f4c81,#0f4c81) !important; color: white !important; font-weight: 700; padding: 10px 24px; border-radius: 50px; text-decoration: none; display: inline-block; box-shadow: 0 4px 10px rgba(15, 76, 129, 0.2); transition: 0.2s; }
        .cv-btn-theme:hover { background-color: var(--th-bg-0a365c,#0a365c) !important; color: white !important; transform: translateY(-1px); }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container-fluid px-4 py-4">

        <!-- الترويسة وزر العودة -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                 <div class="text-muted small mb-1">
                     <%: L.T("Company.TraineeDetails.CompanyPortal") %> <a href="Trainees.aspx" class="text-decoration-none text-muted"><%: L.T("Company.TraineeDetails.MyTrainees") %></a> &gt; <span class="text-dark fw-bold"><%: L.T("Company.TraineeDetails.TraineeDetails") %></span>
                 </div>
                 <h2 class="fw-bold text-brand mb-0 fs-3"><%: L.T("Company.TraineeDetails.TraineeDetailsProgress") %></h2>
            </div>
            <a href="Trainees.aspx" class="btn btn-light border rounded-pill px-4 py-2 fw-bold text-muted shadow-sm transition-02">
                <i class="bi bi-arrow-left me-2"></i><%: L.T("Company.TraineeDetails.BackToList") %>
            </a>
        </div>

        <asp:Label ID="lblMessage" runat="server" EnableViewState="false" CssClass="d-block mb-3"></asp:Label>

        <!-- بطاقة بيانات المتدرب -->
        <div class="card border-0 shadow-sm rounded-4 p-4 p-md-5 mb-4 border-light">
            <div class="row align-items-center">

                <div class="col-md-7 d-flex align-items-start gap-4">
                    <div class="student-avatar-large shadow-sm mt-1">
                        <asp:Literal ID="litStudentInitials" runat="server">ST</asp:Literal>
                    </div>
                    <div>
                        <h4 class="fw-bold mb-1 text-dark"><asp:Literal ID="litStudentName" runat="server" Text="<%$ Resources:Company, TraineeDetails.TraineeNamePlaceholder %>" /></h4>
                        <div class="text-muted small mb-1"><i class="bi bi-book me-2 text-brand"></i><asp:Literal ID="litStudentMajor" runat="server" Text="<%$ Resources:Company, TraineeDetails.MajorPlaceholder %>" /></div>
                        <div class="text-muted small mb-3"><i class="bi bi-envelope me-2 text-brand"></i><asp:Literal ID="litStudentEmail" runat="server">email@example.com</asp:Literal></div>

                        <!-- زر الـ CV -->
                        <button type="button" class="btn btn-sm btn-light border rounded-pill px-3 fw-semibold text-brand shadow-sm" data-bs-toggle="modal" data-bs-target="#cvModal">
                            <i class="bi bi-file-earmark-person me-1 text-brand"></i> <%: L.T("Company.TraineeDetails.ViewTraineeCV") %>
                        </button>
                    </div>
                </div>

                <div class="col-md-5 border-start ps-md-5 mt-4 mt-md-0">
                    <div class="d-flex justify-content-between align-items-end mb-2">
                        <span class="info-label mb-0"><%: L.T("Company.TraineeDetails.OverallProgress") %></span>
                        <h4 class="fw-bold text-brand mb-0"><asp:Literal ID="litProgressPercentage" runat="server">0</asp:Literal>%</h4>
                    </div>
                    <div class="progress-wrapper mb-2 shadow-sm">
                        <div id="divProgressBar" runat="server" class="progress-fill" style="width: 0%;"></div>
                    </div>
                    <div class="d-flex justify-content-between text-muted small fw-semibold">
                        <span><asp:Literal ID="litApprovedHours" runat="server">0</asp:Literal> <%: L.T("Company.TraineeDetails.HrsApproved") %></span>
                        <span><asp:Literal ID="litRequiredHours" runat="server">0</asp:Literal> <%: L.T("Company.TraineeDetails.HrsRequired") %></span>
                    </div>
                </div>

            </div>
        </div>

        <!-- معلومات التدريب -->
        <div class="card border-0 shadow-sm rounded-4 p-4 mb-4 border-light">
            <h5 class="fw-bold text-brand mb-4"><%: L.T("Company.TraineeDetails.InternshipInformation") %></h5>
            <div class="row g-4">
                <div class="col-md-4">
                    <div class="info-label"><%: L.T("Company.TraineeDetails.Opportunity") %></div>
                    <div class="info-value"><asp:Literal ID="litOpportunityTitle" runat="server">-</asp:Literal></div>
                </div>
                <div class="col-md-4">
                    <div class="info-label"><%: L.T("Company.TraineeDetails.StartDate") %></div>
                    <div class="info-value"><i class="bi bi-calendar me-2 text-muted"></i><asp:Literal ID="litStartDate" runat="server">-</asp:Literal></div>
                </div>
                <div class="col-md-4">
                    <div class="info-label"><%: L.T("Company.TraineeDetails.EndDate") %></div>
                    <div class="info-value"><i class="bi bi-calendar-check me-2 text-muted"></i><asp:Literal ID="litEndDate" runat="server">-</asp:Literal></div>
                </div>
                <div class="col-md-4 mt-4">
                    <div class="info-label"><%: L.T("Company.TraineeDetails.AcademicSupervisor") %></div>
                    <div class="info-value"><i class="bi bi-person-badge me-2 text-muted"></i><asp:Literal ID="litAcademicSupervisor" runat="server" Text="<%$ Resources:Company, TraineeDetails.NotAssigned %>" /></div>
                </div>
                <div class="col-md-4 mt-4">
                    <div class="info-label mb-2"><%: L.T("Company.TraineeDetails.PlacementStatus") %></div>
                    <div>
                        <span class="badge status-graded px-3 py-2 rounded-pill fw-bold">
                            <i class="bi bi-check-circle-fill me-1"></i><asp:Literal ID="litPlacementStatus" runat="server" Text="<%$ Resources:Company, TraineeDetails.ConfirmedStatus %>" />
                        </span>
                    </div>
                </div>
            </div>
        </div>

        <!-- جدول المهام -->
        <div class="card border-0 shadow-sm rounded-4 border-light mb-4">
            <div class="card-header bg-white border-bottom d-flex justify-content-between align-items-center p-4 rounded-top-4">
                <h5 class="fw-bold text-brand mb-0"><%: L.T("Company.TraineeDetails.AssignedTasks") %></h5>
                <a href="Tasks.aspx" class="btn bg-brand rounded-pill px-4 shadow-sm fw-bold">
                    <i class="bi bi-plus-lg me-2"></i><%: L.T("Company.TraineeDetails.AssignNewTask") %>
                </a>
            </div>

            <div class="card-body p-0 table-responsive">
                <asp:GridView ID="gvTraineeTasks" runat="server" CssClass="clean-table" AutoGenerateColumns="False" EmptyDataText="<%$ Resources:Company, TraineeDetails.NoTasksAssignedToThisTrainee %>" GridLines="None">
                    <HeaderStyle CssClass="bg-light text-muted small text-uppercase" />
                    <Columns>
                        <asp:BoundField DataField="Title" HeaderText="<%$ Resources:Company, TraineeDetails.TaskTitle %>" ItemStyle-CssClass="fw-bold text-dark px-4" HeaderStyle-CssClass="px-4" />

                        <asp:TemplateField HeaderText="<%$ Resources:Company, TraineeDetails.Deadline %>">
                            <ItemTemplate>
                                <span class="text-muted fw-semibold"><i class="bi bi-calendar-event me-2"></i><%# FormatDate(Eval("Deadline")) %></span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="<%$ Resources:Company, TraineeDetails.EstHours %>">
                            <ItemTemplate>
                                <span class="fw-bold text-dark"><%# Eval("EstimatedHours") %> <%: L.T("Company.TraineeDetails.Hrs") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="<%$ Resources:Company, TraineeDetails.Status %>">
                            <ItemTemplate>
                                <span class='<%# GetTaskStatusCss(Eval("Status").ToString()) %>'>
                                    <%#: L.Value("Ui", Eval("Status")) %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="<%$ Resources:Company, TraineeDetails.Action %>">
                            <ItemTemplate>
                                <a href='TaskReview.aspx?id=<%# Eval("Id") %>' class="btn-table-action"><%: L.T("Company.TraineeDetails.Review") %></a>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>

    </div>

    <!-- نافذة منبثقة للـ CV مع تباعد مرتب -->
    <div class="modal fade" id="cvModal" tabindex="-1" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4 border-0 shadow-lg p-3">
          <div class="modal-header border-bottom-0 pb-0 pt-3 px-3">
            <h5 class="modal-title fw-bold text-brand"><%: L.T("Company.TraineeDetails.TraineeCVPortfolio") %></h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="<%: L.T("Company.TraineeDetails.Close") %>"></button>
          </div>
          <div class="modal-body p-4 text-center">
              <div class="mb-3 text-brand" style="font-size: 3rem;"><i class="bi bi-file-earmark-pdf-fill"></i></div>
              <p class="text-muted small mb-4"><%: L.T("Company.TraineeDetails.YouCanAccessTheTraineeS") %></p>

              <!-- تم إضافة مسافة وعنصر يظهر فقط عند عدم توفر الرابط -->
              <div class="mt-3 mb-2">
                  <a id="btnOpenRealCv" href="#" target="_blank" class="cv-btn-theme shadow-sm btn bg-brand rounded-pill px-4 py-2 text-white fw-bold text-decoration-none" style="display:none;">
                      <i class="bi bi-box-arrow-up-right me-2"></i><%: L.T("Company.TraineeDetails.OpenCVInNewTab") %>
                  </a>
                  <div id="divNoCv" class="text-muted fst-italic p-3 bg-light rounded-3 d-block border mt-2" style="display:none;">
                      <%: L.T("Company.TraineeDetails.NoCVOrPortfolioWasProvided") %>
                  </div>
              </div>
          </div>
          <div class="modal-footer border-top-0 px-4 pb-3 justify-content-center">
            <button type="button" class="btn btn-light border rounded-pill px-4 fw-semibold text-muted" data-bs-dismiss="modal"><%: L.T("Company.TraineeDetails.Close") %></button>
          </div>
        </div>
      </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</asp:Content>