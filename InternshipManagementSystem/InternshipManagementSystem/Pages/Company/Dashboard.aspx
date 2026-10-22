<%@ Page Language="C#" MasterPageFile="~/Layout/Company.master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="InternshipManagementSystem.Pages.CompanyArea.Dashboard" Title="Company Dashboard" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
    <style>
        /* توحيد الألوان مع ثيم الموقع الرسمي */
        .text-brand { color: #0f4c81 !important; }
        .bg-brand { background-color: #0f4c81 !important; color: white; border: none; transition: 0.2s; }
        .bg-brand:hover { background-color: #0a365c !important; color: white; transform: translateY(-1px); }
        .bg-brand-light { background-color: #f0f4f8 !important; color: #0f4c81 !important; border: 1px solid #e3e8ee; }

        .page-header-title { font-size: 1.75rem; font-weight: 700; color: #0f4c81; }
        
        /* تأثيرات الكروت عند تمرير الماوس */
        .hover-card { transition: all 0.2s ease-in-out; cursor: pointer; border: 1px solid #e3e8ee; }
        .hover-card:hover { transform: translateY(-3px); border-color: #0f4c81 !important; box-shadow: 0 4px 15px rgba(15, 76, 129, 0.08) !important; }
        
        /* تأثيرات القائمة الجانبية (Upcoming Tasks) */
        .task-item { transition: all 0.2s; border: 1px solid #e3e8ee; }
        .task-item:hover { border-color: #0f4c81; background-color: #f8fafc; transform: translateX(3px); }
        
        .student-avatar { width: 35px; height: 35px; }
        
        /* تصميم الجدول النظيف والمتناسق */
        .clean-table { width: 100%; border-collapse: collapse; }
        .clean-table th { padding: 1rem; border-bottom: 2px solid #e2e8f0; color: #64748b; font-size: 0.75rem; text-transform: uppercase; font-weight: 700; text-align: left; letter-spacing: 0.5px; }
        .clean-table td { padding: 1rem; border-bottom: 1px solid #f1f5f9; color: #334155; font-size: 0.875rem; font-weight: 500; vertical-align: middle; }
        .clean-table tr:hover td { background-color: #f8fafc; }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container-fluid px-4 py-4">

        <!-- الترويسة -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="fw-bold text-brand mb-1 fs-3">Welcome back</h2>
                <p class="text-muted mb-0">An overview of your company's internship activity.</p>
            </div>
            <div>
                <a href="Opportunities.aspx" class="btn bg-brand px-4 py-2 rounded-pill shadow-sm fw-bold">
                    <i class="bi bi-plus-lg me-2"></i>Add opportunity
                </a>
            </div>
        </div>

        <asp:Label ID="lblMessage" runat="server" EnableViewState="false" CssClass="d-block mb-3"></asp:Label>

        <!-- البطاقات الإحصائية العلوية -->
        <div class="row mb-4">
            <div class="col-md-4 mb-3">
                <div class="card border-0 shadow-sm rounded-4 hover-card h-100 p-2">
                    <div class="card-body d-flex justify-content-between align-items-start">
                        <div>
                            <p class="text-muted small fw-bold mb-1 letter-spacing-1">TOTAL OPPORTUNITIES</p>
                            <h2 class="fw-bold text-dark mb-1"><asp:Literal ID="litTotalOpportunities" runat="server">0</asp:Literal></h2>
                            <small class="text-muted">Active postings</small>
                        </div>
                        <div class="bg-brand-light rounded-3 p-2"><i class="bi bi-briefcase fs-5"></i></div>
                    </div>
                </div>
            </div>

            <div class="col-md-4 mb-3">
                <div class="card border-0 shadow-sm rounded-4 hover-card h-100 p-2">
                    <div class="card-body d-flex justify-content-between align-items-start">
                        <div>
                            <p class="text-muted small fw-bold mb-1 letter-spacing-1">APPLICATIONS</p>
                            <h2 class="fw-bold text-dark mb-1"><asp:Literal ID="litTotalApplications" runat="server">0</asp:Literal></h2>
                            <small class="text-muted">Total submissions</small>
                        </div>
                        <div class="bg-brand-light rounded-3 p-2"><i class="bi bi-envelope fs-5"></i></div>
                    </div>
                </div>
            </div>

            <div class="col-md-4 mb-3">
                <div class="card border-0 shadow-sm rounded-4 hover-card h-100 p-2">
                    <div class="card-body d-flex justify-content-between align-items-start">
                        <div>
                            <p class="text-muted small fw-bold mb-1 letter-spacing-1">MY TRAINEES</p>
                            <h2 class="fw-bold text-dark mb-1"><asp:Literal ID="litTotalTrainees" runat="server">0</asp:Literal></h2>
                            <small class="text-muted">Currently in training</small>
                        </div>
                        <div class="bg-brand-light rounded-3 p-2"><i class="bi bi-people fs-5"></i></div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <!-- جدول الطلبات الحديثة -->
            <div class="col-lg-8 mb-4">
                <div class="card border-0 shadow-sm rounded-4 h-100 border border-light">
                    <div class="card-header bg-white border-bottom d-flex justify-content-between align-items-center p-4 rounded-top-4">
                        <div>
                            <h5 class="fw-bold text-brand mb-1">Recent applications</h5>
                            <p class="text-muted small mb-0">Review and manage your latest student applications.</p>
                        </div>
                        <a href="Applications.aspx" class="btn btn-sm bg-brand-light fw-bold px-3 rounded-pill">View all</a>
                    </div>
                    
                    <div class="card-body p-0 table-responsive">
                        <asp:GridView ID="gvRecentApplications" runat="server" CssClass="clean-table" AutoGenerateColumns="False" EmptyDataText="No recent applications found." GridLines="None">
                            <HeaderStyle CssClass="bg-light text-muted small text-uppercase" />
                            <Columns>
                                <asp:TemplateField HeaderText="Student">
                                    <ItemTemplate>
                                        <div class="d-flex align-items-center px-3 py-2 gap-3">
                                            <div class="bg-brand-light fw-bold rounded-circle d-flex align-items-center justify-content-center student-avatar shadow-sm">
                                                <%# GetInitials(Eval("StudentName").ToString()) %>
                                            </div>
                                            <span class="fw-bold text-dark"><%# Eval("StudentName") %></span>
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="Major" HeaderText="Specialization" />
                                <asp:BoundField DataField="OpportunityTitle" HeaderText="Opportunity" />
                                <asp:TemplateField HeaderText="Status">
                                    <ItemTemplate>
                                        <span class='<%# GetStatusCss(Eval("Status").ToString()) %> fw-bold'>
                                            <i class="bi bi-circle-fill me-1" style="font-size: 0.4rem;"></i><%# Eval("Status") %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>

            <!-- قائمة المهام القادمة -->
            <div class="col-lg-4 mb-4">
                <div class="card border-0 shadow-sm rounded-4 h-100 border border-light p-4">
                    <div class="mb-4">
                        <h5 class="fw-bold text-brand mb-1">Upcoming tasks</h5>
                        <p class="text-muted small mb-0">Stay on top of your deadlines.</p>
                    </div>

                    <div class="list-group list-group-flush gap-3">
                        <a href="Applications.aspx" class="list-group-item list-group-item-action shadow-sm rounded-3 p-3 task-item text-decoration-none">
                            <div class="d-flex justify-content-between align-items-center mb-1">
                                <div class="fw-bold text-dark"><i class="bi bi-envelope text-brand me-2"></i>Review applications</div>
                                <small class="text-muted fw-semibold" style="font-size:0.75rem;">Action required</small>
                            </div>
                            <small class="text-muted ms-4 ps-1"><asp:Literal ID="litPendingApps" runat="server">0</asp:Literal> applications waiting</small>
                        </a>

                        <a href="FinalEvaluation.aspx" class="list-group-item list-group-item-action shadow-sm rounded-3 p-3 task-item text-decoration-none">
                            <div class="d-flex justify-content-between align-items-center mb-1">
                                <div class="fw-bold text-dark"><i class="bi bi-journal-check text-brand me-2"></i>Submit evaluations</div>
                                <small class="text-muted fw-semibold" style="font-size:0.75rem;">Ongoing</small>
                            </div>
                            <small class="text-muted ms-4 ps-1"><asp:Literal ID="litActiveTrainees" runat="server">0</asp:Literal> active trainees</small>
                        </a>

                        <a href="Opportunities.aspx" class="list-group-item list-group-item-action shadow-sm rounded-3 p-3 task-item text-decoration-none">
                            <div class="d-flex justify-content-between align-items-center mb-1">
                                <div class="fw-bold text-dark"><i class="bi bi-briefcase text-brand me-2"></i>Manage opportunities</div>
                                <small class="text-muted fw-semibold" style="font-size:0.75rem;">As needed</small>
                            </div>
                            <small class="text-muted ms-4 ps-1">Check available seats</small>
                        </a>
                    </div>
                    
                    <!-- الرابط الفعال للتواصل مع الجامعة بدلاً من النص العادي -->
                    <div class="text-center mt-4 pt-3 border-top">
                        <small class="text-muted">
                            <i class="bi bi-info-circle me-1"></i>Need help? 
                            <a href="mailto:support@gju.edu.jo" class="text-decoration-none fw-bold" style="color: #0f4c81; transition: 0.2s;">Contact university support</a>
                        </small>
                    </div>
                </div>
            </div>
        </div>

    </div>
</asp:Content>