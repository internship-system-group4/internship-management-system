<%@ Page Language="C#" MasterPageFile="~/Layout/Company.master" AutoEventWireup="true" CodeBehind="Trainees.aspx.cs" Inherits="InternshipManagementSystem.Pages.CompanyArea.Trainees" Title="My Trainees" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
    <style>
        .page-header-title { font-size: 1.75rem; font-weight: 700; color: #0f4c81; }
        
        .stat-card-box { background: #ffffff; border: 1px solid #e3e8ee; border-radius: 12px; padding: 1.5rem; box-shadow: 0 1px 3px rgba(16, 24, 40, 0.04); display: flex; flex-direction: column; justify-content: space-between; position: relative; transition: transform 0.2s; cursor: default; }
        .stat-card-box:hover { transform: translateY(-3px); border-color: #0f4c81; box-shadow: 0 4px 12px rgba(15, 76, 129, 0.06); }
        .stat-card-title { font-size: 0.85rem; color: #6b7786; font-weight: 600; margin-bottom: 0.25rem; }
        .stat-card-value { font-size: 2.2rem; font-weight: 700; color: #1d2733; margin-bottom: 0.25rem; line-height: 1; }
        .stat-card-sub { font-size: 0.8rem; color: #6b7786; }
        .stat-card-icon { position: absolute; top: 1.5rem; right: 1.5rem; width: 35px; height: 35px; display: flex; align-items: center; justify-content: center; border-radius: 8px; background-color: #f8fafc; color: #0f4c81; border: 1px solid #e3e8ee; font-size: 1.1rem; }

        .section-box { background: #ffffff; border: 1px solid #e3e8ee; border-radius: 12px; padding: 1.5rem; box-shadow: 0 1px 3px rgba(16, 24, 40, 0.04); }
        .table-custom { width: 100%; border-collapse: collapse; font-size: 0.875rem; }
        .table-custom th { color: #6b7786; font-size: 0.75rem; font-weight: 600; padding: 1rem; border-bottom: 1px solid #e3e8ee; background-color: #f8fafc; text-transform: uppercase;}
        .table-custom td { padding: 1rem; border-bottom: 1px solid #e3e8ee; color: #1d2733; vertical-align: middle; }
        
        .student-initials { display: inline-flex; align-items: center; justify-content: center; width: 36px; height: 36px; border-radius: 50%; background-color: #e8f0f7; color: #0f4c81; font-weight: 600; font-size: 0.85rem; margin-right: 0.75rem; border: 1px solid #d9e2ec; }
        
        .progress-container { width: 120px; background-color: #e3e8ee; border-radius: 10px; height: 6px; margin-top: 6px; overflow: hidden; display: inline-block; }
        .progress-fill { height: 100%; background-color: #0f4c81; border-radius: 10px; }
        
        .filter-input { background-color: #f8fafc; border: 1px solid #e3e8ee; color: #1d2733; font-size: 0.85rem; padding: 0.5rem 1rem; border-radius: 6px; }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container-fluid px-4 py-4">
        
        <!-- عنوان الصفحة -->
        <div class="mb-4">
            <h2 class="page-header-title mb-1">My trainees</h2>
            <p class="text-muted mb-0">Track accepted students, training information, and their progress.</p>
        </div>

        <asp:Label ID="lblMessage" runat="server" EnableViewState="false" CssClass="d-block mb-3"></asp:Label>

        <!-- البطاقات الإحصائية -->
        <div class="row mb-4">
            <div class="col-md-4 mb-3">
                <div class="stat-card-box">
                    <div>
                        <div class="stat-card-title">Active training</div>
                        <div class="stat-card-value"><asp:Literal ID="litActiveTrainees" runat="server">0</asp:Literal></div>
                        <div class="stat-card-sub">Currently in progress</div>
                    </div>
                    <div class="stat-card-icon"><i class="bi bi-people"></i></div>
                </div>
            </div>

            <div class="col-md-4 mb-3">
                <div class="stat-card-box">
                    <div>
                        <div class="stat-card-title">Near completion</div>
                        <div class="stat-card-value"><asp:Literal ID="litNearCompletion" runat="server">0</asp:Literal></div>
                        <div class="stat-card-sub">Above 80% progress</div>
                    </div>
                    <div class="stat-card-icon"><i class="bi bi-graph-up"></i></div>
                </div>
            </div>

            <div class="col-md-4 mb-3">
                <div class="stat-card-box">
                    <div>
                        <div class="stat-card-title">Completed</div>
                        <div class="stat-card-value"><asp:Literal ID="litCompleted" runat="server">0</asp:Literal></div>
                        <div class="stat-card-sub">Successfully finished</div>
                    </div>
                    <div class="stat-card-icon"><i class="bi bi-check-lg"></i></div>
                </div>
            </div>
        </div>

        <!-- قسم الجدول والبحث -->
        <div class="section-box">
            <div class="mb-4">
                <h5 class="fw-bold mb-1" style="color: #0f4c81; font-size: 1.1rem;">Trainee directory</h5>
                <p class="text-muted small mb-3"><asp:Literal ID="litTotalCount" runat="server">0</asp:Literal> accepted students</p>
                
                <!-- أدوات الفلترة الفعالة برمجياً -->
                <div class="d-flex gap-3 flex-wrap">
                    <div class="position-relative flex-grow-1" style="max-width: 300px;">
                        <i class="bi bi-search position-absolute text-muted" style="top: 50%; transform: translateY(-50%); left: 12px; font-size: 0.85rem;"></i>
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control filter-input ps-5" placeholder="Search by name..." AutoPostBack="true" OnTextChanged="Filter_Changed"></asp:TextBox>
                    </div>
                    
                    <asp:DropDownList ID="ddlDepartment" runat="server" CssClass="form-select filter-input w-auto pe-4" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed">
                        <asp:ListItem Text="All departments" Value="All"></asp:ListItem>
                        <asp:ListItem Text="Software Engineering" Value="Software Engineering"></asp:ListItem>
                        <asp:ListItem Text="Computer Science" Value="Computer Science"></asp:ListItem>
                        <asp:ListItem Text="Computer Information Systems" Value="Computer Information Systems"></asp:ListItem>
                    </asp:DropDownList>

                    <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-select filter-input w-auto pe-4" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed">
                        <asp:ListItem Text="All training statuses" Value="All"></asp:ListItem>
                        <asp:ListItem Text="In progress (0-79%)" Value="InProgress"></asp:ListItem>
                        <asp:ListItem Text="Near finish (80-99%)" Value="NearFinish"></asp:ListItem>
                        <asp:ListItem Text="Completed (100%)" Value="Completed"></asp:ListItem>
                    </asp:DropDownList>
                </div>
            </div>
            
            <div class="table-responsive border-top pt-2">
                <asp:GridView ID="gvTrainees" runat="server" CssClass="table-custom align-middle" AutoGenerateColumns="False" EmptyDataText="No trainees match your search." GridLines="None">
                    <Columns>
                        
                        <asp:TemplateField HeaderText="Trainee">
                            <ItemTemplate>
                                <div class="d-flex align-items-center">
                                    <span class="student-initials"><%# GetInitials(Eval("StudentName").ToString()) %></span>
                                    <div>
                                        <div class="fw-bold text-dark"><%# Eval("StudentName") %></div>
                                        <div class="text-muted" style="font-size: 0.75rem;"><%# Eval("StudentMajor") %></div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Opportunity">
                            <ItemTemplate>
                                <div class="fw-semibold text-dark"><%# Eval("OpportunityTitle") %></div>
                                <div class="text-muted" style="font-size: 0.75rem;">Internship Program</div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Training period">
                            <ItemTemplate>
                                <span class="text-muted"><%# FormatDate(Eval("StartDate")) %> - <%# FormatDate(Eval("EndDate")) %></span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Progress">
                            <ItemTemplate>
                                <div class="small text-dark mb-1">Overall progress</div>
                                <div class="d-flex align-items-center gap-2">
                                    <div class="progress-container">
                                        <div class="progress-fill" style='width: <%# Eval("ProgressPercentage") %>%;'></div>
                                    </div>
                                    <span class="small text-muted fw-bold"><%# Eval("ProgressPercentage") %>%</span>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <span class='<%# GetStatusCss(Eval("ProgressPercentage").ToString()) %>'>
                                    <i class="bi bi-circle-fill me-1" style="font-size: 0.4rem;"></i><%# GetStatusText(Eval("ProgressPercentage").ToString()) %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Action">
                            <ItemTemplate>
                                <a href='TraineeDetails.aspx?id=<%# Eval("Id") %>' class="btn btn-sm btn-outline-secondary px-3 py-1 rounded-3 fw-semibold">View details</a>
                            </ItemTemplate>
                        </asp:TemplateField>

                    </Columns>
                </asp:GridView>
            </div>
            
        </div>

    </div>
</asp:Content>