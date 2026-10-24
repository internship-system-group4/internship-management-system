<%@ Page Language="C#" MasterPageFile="~/Layout/Company.master" AutoEventWireup="true" CodeBehind="TraineeDetails.aspx.cs" Inherits="InternshipManagementSystem.Pages.CompanyArea.TraineeDetails" Title="Trainee Details" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <style>
        .dashboard-header { padding-bottom: 1rem; margin-bottom: 1.5rem; display: flex; justify-content: space-between; align-items: flex-end; flex-wrap: wrap; gap: 1rem; border-bottom: 1px solid var(--th-line-e3e8ee, #e3e8ee); }
        .dashboard-header h3 { font-size: 1.4rem; font-weight: 700; color: var(--th-fg-0f4c81,#0f4c81); margin-bottom: 0.2rem; }
        
        .card-custom { border: none; border-radius: 16px; box-shadow: 0 4px 15px rgba(0,0,0,0.03); background: #fff; margin-bottom: 1.5rem; overflow: hidden; }

        .student-avatar-large { width: 48px; height: 48px; border-radius: 50%; background-color: var(--th-bg-f0f4f8,#f0f4f8); color: var(--th-fg-0f4c81,#0f4c81); font-weight: 700; font-size: 1rem; display: flex; align-items: center; justify-content: center; border: 1px solid var(--th-line-e3e8ee,#e3e8ee); flex-shrink: 0; }
        
        .progress-container { width: 100%; background-color: var(--th-bg-e2e8f0,#e2e8f0); border-radius: 10px; height: 5px; overflow: hidden; margin-top: 5px; }
        .progress-fill { height: 100%; background-color: var(--th-bg-0f4c81,#0f4c81); border-radius: 10px; }

        .info-label { font-size: 0.7rem; color: var(--th-fg-64748b,#64748b); text-transform: uppercase; font-weight: 700; margin-bottom: 0.2rem; letter-spacing: 0.5px; }
        .info-value { font-size: 0.85rem; color: var(--th-fg-334155,#334155); font-weight: 600; margin-bottom: 0; }

        .clean-table { width: 100%; border-collapse: collapse; }
        .clean-table th { padding: 0.75rem 1rem; border-bottom: 2px solid var(--th-line-e2e8f0,#e2e8f0); color: var(--th-fg-64748b,#64748b); font-size: 0.7rem; text-transform: uppercase; font-weight: 700; text-align: start; letter-spacing: 0.5px; }
        .clean-table td { padding: 0.75rem 1rem; border-bottom: 1px solid var(--th-line-f1f5f9,#f1f5f9); color: var(--th-fg-334155,#334155); font-size: 0.85rem; font-weight: 500; vertical-align: middle; }
        .clean-table tr:hover td { background-color: var(--th-bg-f8fafc,#f8fafc); }

        /* كلاس موحد قياسي يفرس نفس المقاس والحجم تماماً لكل أزرار الصفحة بدون استثناء */
        .btn-exact-match {
            font-size: 0.72rem !important;
            padding: 4px 14px !important;
            height: 28px !important;
            min-height: 28px !important;
            display: inline-flex !important;
            align-items: center !important;
            justify-content: center !important;
            font-weight: 600 !important;
            border-radius: 50px !important;
            text-decoration: none !important;
            white-space: nowrap !important;
            line-height: 1 !important;
            box-sizing: border-box !important;
        }

        /* أنماط أزرار الـ Action والـ Review والـ CV */
        .btn-style-light {
            background-color: var(--th-bg-f1f5f9,#f1f5f9) !important;
            color: var(--th-fg-0f4c81,#0f4c81) !important;
            border: 1px solid var(--th-line-e2e8f0,#e2e8f0) !important;
        }
        .btn-style-light:hover {
            background-color: var(--th-bg-e2e8f0,#e2e8f0) !important;
            color: var(--th-fg-0a365c,#0a365c) !important;
            border-color: var(--th-line-cbd5e1,#cbd5e1) !important;
        }

        .btn-style-primary {
            background-color: var(--th-bg-0f4c81,#0f4c81) !important;
            color: white !important;
            border: 1px solid var(--th-bg-0f4c81,#0f4c81) !important;
        }
        .btn-style-primary:hover {
            background-color: var(--th-bg-0a365c,#0a365c) !important;
            color: white !important;
        }

        .status-assigned { background-color: var(--th-bg-eff6ff,#eff6ff); color: var(--th-fg-1d4ed8,#1d4ed8); border: 1px solid var(--th-line-bfdbfe,#bfdbfe); font-size: 0.7rem; padding: 2px 8px; border-radius: 50px; font-weight: 600; display: inline-block; }
        .status-submitted { background-color: var(--th-bg-e0f2fe,#e0f2fe); color: var(--th-fg-0369a1,#0369a1); border: 1px solid var(--th-line-bae6fd,#bae6fd); font-size: 0.7rem; padding: 2px 8px; border-radius: 50px; font-weight: 600; display: inline-block; }
        .status-graded { background-color: var(--th-bg-f0fdf4,#f0fdf4); color: var(--th-fg-15803d,#15803d); border: 1px solid var(--th-line-bbf7d0,#bbf7d0); font-size: 0.7rem; padding: 2px 8px; border-radius: 50px; font-weight: 600; display: inline-block; }
        .status-revision { background-color: var(--th-bg-fef2f2,#fef2f2); color: var(--th-fg-b91c1c,#b91c1c); border: 1px solid var(--th-line-fecaca,#fecaca); font-size: 0.7rem; padding: 2px 8px; border-radius: 50px; font-weight: 600; display: inline-block; }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container-fluid px-3 px-md-4 py-4">

        <!-- الترويسة وزر العودة -->
        <div class="dashboard-header">
            <div>
                <div class="text-muted small mb-1" style="font-size: 0.75rem;">
                    <%: L.T("Company.TraineeDetails.CompanyPortal") %> <a href="Trainees.aspx" class="text-decoration-none text-muted"><%: L.T("Company.TraineeDetails.MyTrainees") %></a> &gt; <span class="text-dark fw-bold"><%: L.T("Company.TraineeDetails.TraineeDetails") %></span>
                </div>
                <h3><i class="bi bi-person-badge-fill me-2 text-primary"></i><%: L.T("Company.TraineeDetails.TraineeDetailsProgress") %></h3>
            </div>
            <div>
                <a href="Trainees.aspx" class="btn btn-exact-match btn-style-light shadow-sm">
                    <i class="bi bi-arrow-left me-1"></i><%: L.T("Company.TraineeDetails.BackToList") %>
                </a>
            </div>
        </div>

        <asp:Label ID="lblMessage" runat="server" EnableViewState="false" CssClass="d-block mb-3"></asp:Label>

        <!-- بطاقة بيانات المتدرب -->
        <div class="card card-custom p-3 border border-light">
            <div class="row align-items-center">
                <div class="col-md-12 d-flex align-items-start gap-3 mb-1">
                    <div class="student-avatar-large shadow-sm">
                        <asp:Literal ID="litStudentInitials" runat="server">ST</asp:Literal>
                    </div>
                    <div class="flex-grow-1">
                        <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                            <div>
                                <h5 class="fw-bold mb-1 text-dark" style="font-size: 0.95rem;"><asp:Literal ID="litStudentName" runat="server" Text="<%$ Resources:Company, TraineeDetails.TraineeNamePlaceholder %>" /></h5>
                                <div class="text-muted small mb-1" style="font-size: 0.7rem;">
                                    <i class="bi bi-book me-1 text-primary"></i><asp:Literal ID="litStudentMajor" runat="server" Text="<%$ Resources:Company, TraineeDetails.MajorPlaceholder %>" /> | 
                                    <i class="bi bi-envelope me-1 text-primary"></i><asp:Literal ID="litStudentEmail" runat="server">email@example.com</asp:Literal>
                                </div>
                            </div>
                            
                            <!-- زر الـ CV -->
                            <button type="button" class="btn btn-exact-match btn-style-light shadow-sm" data-bs-toggle="modal" data-bs-target="#cvModal">
                                <i class="bi bi-file-earmark-person me-1"></i> <%: L.T("Company.TraineeDetails.ViewTraineeCV") %>
                            </button>
                        </div>

                        <!-- شريط التقدم تحت الاسم -->
                        <div class="mt-2">
                            <div class="d-flex justify-content-between align-items-center mb-1">
                                <span class="info-label mb-0" style="font-size: 0.7rem;"><%: L.T("Company.TraineeDetails.OverallProgress") %> (<asp:Literal ID="litApprovedHours" runat="server">0</asp:Literal> / <asp:Literal ID="litRequiredHours" runat="server">160</asp:Literal> <%: L.T("Company.TraineeDetails.Hrs") %>)</span>
                                <span class="fw-bold text-dark" style="font-size: 0.7rem;"><asp:Literal ID="litProgressPercentage" runat="server">0</asp:Literal>%</span>
                            </div>
                            <div class="progress-container shadow-sm">
                                <div id="divProgressBar" runat="server" class="progress-fill" style="width: 0%;"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- معلومات التدريب -->
        <div class="card card-custom p-3 border border-light">
            <h6 class="fw-bold text-dark mb-3" style="font-size: 0.9rem;"><i class="bi bi-info-circle me-2 text-primary"></i><%: L.T("Company.TraineeDetails.InternshipInformation") %></h6>
            <div class="row g-3">
                <div class="col-md-4">
                    <div class="info-label"><%: L.T("Company.TraineeDetails.Opportunity") %></div>
                    <div class="info-value"><asp:Literal ID="litOpportunityTitle" runat="server">-</asp:Literal></div>
                </div>
                <div class="col-md-4">
                    <div class="info-label"><%: L.T("Company.TraineeDetails.StartDate") %></div>
                    <div class="info-value"><i class="bi bi-calendar me-1 text-muted"></i><asp:Literal ID="litStartDate" runat="server">-</asp:Literal></div>
                </div>
                <div class="col-md-4">
                    <div class="info-label"><%: L.T("Company.TraineeDetails.EndDate") %></div>
                    <div class="info-value"><i class="bi bi-calendar-check me-1 text-muted"></i><asp:Literal ID="litEndDate" runat="server">-</asp:Literal></div>
                </div>
                <div class="col-md-4 mt-2">
                    <div class="info-label"><%: L.T("Company.TraineeDetails.AcademicSupervisor") %></div>
                    <div class="info-value"><i class="bi bi-person-badge me-1 text-muted"></i><asp:Literal ID="litAcademicSupervisor" runat="server" Text="<%$ Resources:Company, TraineeDetails.NotAssigned %>" /></div>
                </div>
                <div class="col-md-4 mt-2">
                    <div class="info-label mb-1"><%: L.T("Company.TraineeDetails.PlacementStatus") %></div>
                    <div>
                        <span class="badge bg-success bg-opacity-10 text-success rounded-pill px-2 py-1 fw-bold" style="font-size: 0.7rem;">
                            <i class="bi bi-check-circle-fill me-1"></i><asp:Literal ID="litPlacementStatus" runat="server" Text="<%$ Resources:Company, TraineeDetails.ConfirmedStatus %>" />
                        </span>
                    </div>
                </div>
            </div>
        </div>

        <!-- جدول المهام -->
        <div class="card card-custom border border-light">
            <div class="card-header bg-white border-bottom d-flex justify-content-between align-items-center py-2 px-3">
                <h6 class="fw-bold text-dark mb-0" style="font-size: 0.9rem;"><i class="bi bi-list-check me-2 text-primary"></i><%: L.T("Company.TraineeDetails.AssignedTasks") %></h6>
                
                <!-- زر تعيين مهمة جديدة -->
                <a href="Tasks.aspx" class="btn btn-exact-match btn-style-primary shadow-sm">
                    <i class="bi bi-plus-lg me-1"></i><%: L.T("Company.TraineeDetails.AssignNewTask") %>
                </a>
            </div>

            <div class="card-body p-0 table-responsive">
                <asp:GridView ID="gvTraineeTasks" runat="server" CssClass="clean-table" AutoGenerateColumns="False" EmptyDataText="<%$ Resources:Company, TraineeDetails.NoTasksAssignedToThisTrainee %>" GridLines="None">
                    <HeaderStyle CssClass="bg-light text-muted" />
                    <Columns>
                        <asp:BoundField DataField="Title" HeaderText="<%$ Resources:Company, TraineeDetails.TaskTitle %>" ItemStyle-CssClass="fw-bold text-dark" />
                        <asp:TemplateField HeaderText="<%$ Resources:Company, TraineeDetails.Deadline %>">
                            <ItemTemplate>
                                <span class="text-muted fw-semibold" style="font-size: 0.75rem;"><i class="bi bi-calendar-event me-1"></i><%# FormatDate(Eval("Deadline")) %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="<%$ Resources:Company, TraineeDetails.Status %>">
                            <ItemTemplate>
                                <span class='<%# GetTaskStatusCss(Eval("Status") != null ? Eval("Status").ToString() : "") %>'>
                                    <%# Eval("Status") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="<%$ Resources:Company, TraineeDetails.Action %>">
                            <ItemTemplate>
                                <a href='TaskReview.aspx?id=<%# Eval("Id") %>' class="btn btn-exact-match btn-style-light shadow-sm"><%: L.T("Company.TraineeDetails.Review") %></a>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>

    <!-- نافذة منبثقة للـ CV -->
    <div class="modal fade" id="cvModal" tabindex="-1" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4 border-0 shadow-lg p-3">
          <div class="modal-header border-bottom-0 pb-0 pt-2 px-3">
            <h5 class="modal-title fw-bold text-dark" style="font-size: 0.95rem;"><i class="bi bi-file-earmark-pdf me-2 text-primary"></i><%: L.T("Company.TraineeDetails.TraineeCVPortfolio") %></h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="<%: L.T("Company.TraineeDetails.Close") %>"></button>
          </div>
          <div class="modal-body p-3 text-center">
              <div class="mb-2 text-primary" style="font-size: 2rem;"><i class="bi bi-file-earmark-pdf-fill"></i></div>
              <p class="text-muted small mb-3" style="font-size: 0.75rem;"><%: L.T("Company.TraineeDetails.YouCanAccessTheTraineeS") %></p>

              <div class="mt-2">
                  <a id="btnOpenRealCv" href="#" target="_blank" class="cv-btn-theme shadow-sm" style="display:none;">
                      <i class="bi bi-box-arrow-up-right me-1"></i> <%: L.T("Company.TraineeDetails.OpenCVInNewTab") %>
                  </a>
                  <div id="divNoCv" class="text-muted fst-italic p-2 bg-light rounded-3 border" style="font-size: 0.75rem; display:none;">
                      <%: L.T("Company.TraineeDetails.NoCVOrPortfolioWasProvided") %>
                  </div>
              </div>
          </div>
          <div class="modal-footer border-top-0 px-3 pb-2 justify-content-center">
            <button type="button" class="btn btn-light border rounded-pill text-muted" data-bs-dismiss="modal" style="font-size: 0.7rem; height: 26px; padding: 0 14px;"><%: L.T("Company.TraineeDetails.Close") %></button>
          </div>
        </div>
      </div>
    </div>
</asp:Content>