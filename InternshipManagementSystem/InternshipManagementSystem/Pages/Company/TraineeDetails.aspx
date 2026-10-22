<%@ Page Language="C#" MasterPageFile="~/Layout/Company.master" AutoEventWireup="true" CodeBehind="TraineeDetails.aspx.cs" Inherits="InternshipManagementSystem.Pages.CompanyArea.TraineeDetails" Title="Trainee Details" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <!-- مكتبة الأيقونات -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container-fluid px-4 py-4">
        
        <!-- الترويسة وزر العودة -->
        <div class="d-flex justify-content-between align-items-end mb-4 border-bottom pb-3">
            <div>
                 <div class="text-muted small mb-1">
                     Company portal &gt; <a href="Trainees.aspx" class="text-decoration-none text-muted">My trainees</a> &gt; <span class="text-dark fw-bold">Trainee details</span>
                 </div>
                 <h2 class="fw-bold mb-0" style="color: var(--ui-primary); font-size: 1.75rem;">Trainee Details & Progress</h2>
            </div>
            <a href="Trainees.aspx" class="btn btn-outline-secondary px-4 py-2 rounded-3 shadow-sm"><i class="bi bi-arrow-left me-2"></i>Back to list</a>
        </div>

        <asp:Label ID="lblMessage" runat="server" EnableViewState="false" CssClass="d-block mb-3"></asp:Label>

        <!-- بطاقة بيانات الطالب الأساسية ونسبة الإنجاز -->
        <div class="card border-0 shadow-sm rounded-4 border p-4 mb-4">
            <div class="row align-items-center">
                
                <!-- معلومات الطالب -->
                <div class="col-md-7 d-flex align-items-center gap-4">
                    <div class="bg-light text-primary fw-bold rounded-circle d-flex align-items-center justify-content-center border shadow-sm" style="width: 70px; height: 70px; font-size: 1.5rem;">
                        <asp:Literal ID="litStudentInitials" runat="server">ST</asp:Literal>
                    </div>
                    <div>
                        <h4 class="fw-bold mb-1" style="color: #1d2733;"><asp:Literal ID="litStudentName" runat="server">Student Name</asp:Literal></h4>
                        <p class="text-muted mb-1"><i class="bi bi-mortarboard me-2"></i><asp:Literal ID="litStudentMajor" runat="server">Major</asp:Literal></p>
                        <p class="text-muted small mb-0"><i class="bi bi-envelope me-2"></i><asp:Literal ID="litStudentEmail" runat="server">email@example.com</asp:Literal></p>
                    </div>
                </div>
                
                <!-- شريط التقدم (استخدام Bootstrap Progress Bar) -->
                <div class="col-md-5 border-start ps-4">
                    <div class="d-flex justify-content-between align-items-end mb-2">
                        <span class="text-muted small fw-bold text-uppercase">Overall Progress</span>
                        <h4 class="fw-bold mb-0" style="color: var(--ui-primary);"><asp:Literal ID="litProgressPercentage" runat="server">0</asp:Literal>%</h4>
                    </div>
                    <div class="progress mb-2" style="height: 8px;">
                        <div id="divProgressBar" runat="server" class="progress-bar" style="background-color: var(--ui-primary); width: 0%;"></div>
                    </div>
                    <div class="d-flex justify-content-between text-muted small">
                        <span><asp:Literal ID="litApprovedHours" runat="server">0</asp:Literal> hrs approved</span>
                        <span><asp:Literal ID="litRequiredHours" runat="server">0</asp:Literal> hrs required</span>
                    </div>
                </div>

            </div>
        </div>

        <!-- معلومات التدريب -->
        <div class="card border-0 shadow-sm rounded-4 border p-4 mb-4">
            <h5 class="fw-bold mb-4" style="color: var(--ui-primary);">Internship Information</h5>
            <div class="row g-4">
                <div class="col-md-4">
                    <div class="text-muted small fw-bold text-uppercase mb-1">Opportunity</div>
                    <div class="fw-semibold text-dark"><asp:Literal ID="litOpportunityTitle" runat="server">-</asp:Literal></div>
                </div>
                <div class="col-md-4">
                    <div class="text-muted small fw-bold text-uppercase mb-1">Start Date</div>
                    <div class="fw-semibold text-dark"><i class="bi bi-calendar me-2 text-muted"></i><asp:Literal ID="litStartDate" runat="server">-</asp:Literal></div>
                </div>
                <div class="col-md-4">
                    <div class="text-muted small fw-bold text-uppercase mb-1">End Date</div>
                    <div class="fw-semibold text-dark"><i class="bi bi-calendar-check me-2 text-muted"></i><asp:Literal ID="litEndDate" runat="server">-</asp:Literal></div>
                </div>
                <div class="col-md-4">
                    <div class="text-muted small fw-bold text-uppercase mb-1">Academic Supervisor</div>
                    <div class="fw-semibold text-dark"><i class="bi bi-person me-2 text-muted"></i><asp:Literal ID="litAcademicSupervisor" runat="server">Not Assigned</asp:Literal></div>
                </div>
                <div class="col-md-4">
                    <div class="text-muted small fw-bold text-uppercase mb-1">Placement Status</div>
                    <div>
                        <span class="badge bg-success bg-opacity-10 text-success px-3 py-2 rounded-pill"><asp:Literal ID="litPlacementStatus" runat="server">Confirmed</asp:Literal></span>
                    </div>
                </div>
            </div>
        </div>

        <!-- جدول المهام الخاصة بهذا المتدرب -->
        <div class="card border-0 shadow-sm rounded-4 border mb-4">
            <div class="card-header bg-white border-bottom d-flex justify-content-between align-items-center p-4">
                <h5 class="fw-bold mb-0" style="color: var(--ui-primary);">Assigned Tasks</h5>
                <a href="Tasks.aspx" class="btn px-4 py-2 rounded-3 shadow-sm" style="background-color: var(--ui-primary); color: white;"><i class="bi bi-plus-lg me-2"></i>Assign New Task</a>
            </div>
            
            <div class="card-body p-0 table-responsive">
                <asp:GridView ID="gvTraineeTasks" runat="server" CssClass="table table-hover align-middle mb-0" AutoGenerateColumns="False" EmptyDataText="No tasks assigned to this trainee yet." GridLines="None">
                    <HeaderStyle CssClass="bg-light text-muted small text-uppercase" />
                    <Columns>
                        <asp:BoundField DataField="Title" HeaderText="Task Title" ItemStyle-CssClass="fw-bold text-dark px-4" HeaderStyle-CssClass="px-4" />
                        
                        <asp:TemplateField HeaderText="Deadline">
                            <ItemTemplate>
                                <span class="text-muted"><i class="bi bi-calendar-event me-2"></i><%# FormatDate(Eval("Deadline")) %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        
                        <asp:TemplateField HeaderText="Est. Hours">
                            <ItemTemplate>
                                <span class="fw-semibold text-dark"><%# Eval("EstimatedHours") %> hrs</span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <span class='<%# GetTaskStatusCss(Eval("Status").ToString()) %>'>
                                    <%# Eval("Status") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        
                        <asp:TemplateField HeaderText="Action">
                            <ItemTemplate>
                                <a href='TaskReview.aspx?id=<%# Eval("Id") %>' class="btn btn-sm btn-outline-primary px-3 py-1 rounded-pill fw-semibold">Review</a>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>

    </div>
</asp:Content>