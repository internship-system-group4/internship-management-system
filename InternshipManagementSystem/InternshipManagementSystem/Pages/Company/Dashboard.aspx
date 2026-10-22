<%@ Page Language="C#" MasterPageFile="~/Layout/Company.master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="InternshipManagementSystem.Pages.CompanyArea.Dashboard" Title="Company Dashboard" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
    <style>
        .page-header-title { font-size: 1.75rem; font-weight: 700; color: #0f4c81; }
        .hover-card { transition: transform 0.2s ease-in-out; }
        .hover-card:hover { transform: translateY(-5px); border-color: #0f4c81 !important; }
        .student-avatar { width: 35px; height: 35px; }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container-fluid px-4 py-4">

        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="fw-bold mb-1" style="color: #0f4c81; font-size: 1.75rem;">Welcome back</h2>
                <p class="text-muted mb-0">An overview of your company's internship activity.</p>
            </div>
            <div>
                <a href="Opportunities.aspx" class="btn btn-primary px-4 py-2 rounded-3 shadow-sm" style="background-color: #0f4c81; border-color: #0f4c81;">
                    <i class="bi bi-plus-lg me-2"></i>Add opportunity
                </a>
            </div>
        </div>

        <asp:Label ID="lblMessage" runat="server" EnableViewState="false" CssClass="d-block mb-3"></asp:Label>

        <!-- البطاقات الإحصائية -->
        <div class="row mb-4">
            <div class="col-md-4 mb-3">
                <div class="card border-0 shadow-sm rounded-4 hover-card h-100 p-2 border">
                    <div class="card-body d-flex justify-content-between align-items-start">
                        <div>
                            <p class="text-muted small fw-bold mb-1">TOTAL OPPORTUNITIES</p>
                            <h2 class="fw-bold text-dark mb-1"><asp:Literal ID="litTotalOpportunities" runat="server">0</asp:Literal></h2>
                            <small class="text-muted">Active postings</small>
                        </div>
                        <div class="bg-light text-primary rounded-3 p-2 border"><i class="bi bi-briefcase fs-5"></i></div>
                    </div>
                </div>
            </div>

            <div class="col-md-4 mb-3">
                <div class="card border-0 shadow-sm rounded-4 hover-card h-100 p-2 border">
                    <div class="card-body d-flex justify-content-between align-items-start">
                        <div>
                            <p class="text-muted small fw-bold mb-1">APPLICATIONS</p>
                            <h2 class="fw-bold text-dark mb-1"><asp:Literal ID="litTotalApplications" runat="server">0</asp:Literal></h2>
                            <small class="text-muted">Total submissions</small>
                        </div>
                        <div class="bg-light text-primary rounded-3 p-2 border"><i class="bi bi-envelope fs-5"></i></div>
                    </div>
                </div>
            </div>

            <div class="col-md-4 mb-3">
                <div class="card border-0 shadow-sm rounded-4 hover-card h-100 p-2 border">
                    <div class="card-body d-flex justify-content-between align-items-start">
                        <div>
                            <p class="text-muted small fw-bold mb-1">MY TRAINEES</p>
                            <h2 class="fw-bold text-dark mb-1"><asp:Literal ID="litTotalTrainees" runat="server">0</asp:Literal></h2>
                            <small class="text-muted">Currently in training</small>
                        </div>
                        <div class="bg-light text-primary rounded-3 p-2 border"><i class="bi bi-people fs-5"></i></div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <!-- جدول الطلبات الحديثة -->
            <div class="col-lg-8 mb-4">
                <div class="card border-0 shadow-sm rounded-4 h-100 border">
                    <div class="card-header bg-white border-bottom d-flex justify-content-between align-items-center p-4">
                        <div>
                            <h5 class="fw-bold mb-1" style="color: #0f4c81;">Recent applications</h5>
                            <p class="text-muted small mb-0">Review and manage your latest student applications.</p>
                        </div>
                        <a href="Applications.aspx" class="btn btn-sm btn-light border fw-semibold text-primary">View all</a>
                    </div>
                    
                    <div class="card-body p-0 table-responsive">
                        <asp:GridView ID="gvRecentApplications" runat="server" CssClass="table table-hover align-middle mb-0" AutoGenerateColumns="False" EmptyDataText="No recent applications found." GridLines="None">
                            <HeaderStyle CssClass="bg-light text-muted small text-uppercase" />
                            <Columns>
                                <asp:TemplateField HeaderText="Student">
                                    <ItemTemplate>
                                        <div class="d-flex align-items-center px-3 py-2">
                                            <div class="bg-light text-primary fw-bold rounded-circle d-flex align-items-center justify-content-center student-avatar me-3 border">
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
                                        <span class='<%# GetStatusCss(Eval("Status").ToString()) %>'>
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
                <div class="card border-0 shadow-sm rounded-4 h-100 border p-4">
                    <div class="mb-4">
                        <h5 class="fw-bold mb-1" style="color: #0f4c81;">Upcoming tasks</h5>
                        <p class="text-muted small mb-0">Stay on top of your deadlines.</p>
                    </div>

                    <div class="list-group list-group-flush border-0 gap-3">
                        <a href="Applications.aspx" class="list-group-item list-group-item-action border shadow-sm rounded-3 p-3 hover-card">
                            <div class="d-flex justify-content-between align-items-center mb-1">
                                <div class="fw-bold text-dark"><i class="bi bi-envelope text-primary me-2"></i>Review applications</div>
                                <small class="text-muted">Action required</small>
                            </div>
                            <small class="text-muted ms-4 ps-1"><asp:Literal ID="litPendingApps" runat="server">0</asp:Literal> applications waiting</small>
                        </a>

                        <a href="Trainees.aspx" class="list-group-item list-group-item-action border shadow-sm rounded-3 p-3 hover-card">
                            <div class="d-flex justify-content-between align-items-center mb-1">
                                <div class="fw-bold text-dark"><i class="bi bi-journal-check text-primary me-2"></i>Submit evaluations</div>
                                <small class="text-muted">Ongoing</small>
                            </div>
                            <small class="text-muted ms-4 ps-1"><asp:Literal ID="litActiveTrainees" runat="server">0</asp:Literal> active trainees</small>
                        </a>

                        <a href="Opportunities.aspx" class="list-group-item list-group-item-action border shadow-sm rounded-3 p-3 hover-card">
                            <div class="d-flex justify-content-between align-items-center mb-1">
                                <div class="fw-bold text-dark"><i class="bi bi-briefcase text-primary me-2"></i>Manage opportunities</div>
                                <small class="text-muted">As needed</small>
                            </div>
                            <small class="text-muted ms-4 ps-1">Check available seats</small>
                        </a>
                    </div>
                    
                    <div class="text-center mt-4 pt-3 border-top">
                        <small class="text-muted">Need help? Contact university support.</small>
                    </div>
                </div>
            </div>
        </div>

    </div>
</asp:Content>