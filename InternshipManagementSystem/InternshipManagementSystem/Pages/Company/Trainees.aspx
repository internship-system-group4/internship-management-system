<%@ Page Language="C#" MasterPageFile="~/Layout/Company.master" AutoEventWireup="true" CodeBehind="Trainees.aspx.cs" Inherits="InternshipManagementSystem.Pages.CompanyArea.Trainees" Title="My Trainees" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <style>
        .dashboard-header { padding-bottom: 1rem; margin-bottom: 1.5rem; display: flex; justify-content: space-between; align-items: flex-end; flex-wrap: wrap; gap: 1rem; border-bottom: 1px solid var(--th-line-e3e8ee, #e3e8ee); }
        .dashboard-header h3 { font-size: 1.4rem; font-weight: 700; color: var(--th-fg-0f4c81,#0f4c81); margin-bottom: 0.2rem; }
        .dashboard-header p { font-size: 0.85rem; margin-bottom: 0; color: #6c757d; }

        .metric-card { border: none; border-radius: 12px; box-shadow: 0 2px 10px rgba(0,0,0,0.03); border-left: 4px solid var(--th-bg-0f4c81,#0f4c81) !important; transition: transform 0.2s; background: #fff; }
        .metric-card:hover { transform: translateY(-3px); }
        .metric-card .title { font-size: 0.7rem; font-weight: 700; text-transform: uppercase; color: var(--th-fg-6b7786,#6b7786); letter-spacing: 0.5px; margin-bottom: 0.5rem; }
        .metric-card .value { font-size: 1.5rem; font-weight: 800; color: var(--th-fg-1d2733,#1d2733); margin-bottom: 0.2rem; }
        .metric-card .desc { font-size: 0.75rem; color: var(--th-fg-888888,#888); }
        .metric-icon { width: 40px; height: 40px; border-radius: 10px; background: var(--th-bg-f0f4f8,#f0f4f8); color: var(--th-fg-0f4c81,#0f4c81); display: flex; align-items: center; justify-content: center; font-size: 1.2rem; border: 1px solid var(--th-line-e3e8ee,#e3e8ee); }

        .card-custom { border: none; border-radius: 16px; box-shadow: 0 4px 15px rgba(0,0,0,0.03); overflow: hidden; margin-bottom: 1.5rem; background: #fff; }

        .clean-table { width: 100%; border-collapse: collapse; }
<<<<<<< HEAD
        .clean-table th { padding: 0.75rem 1rem; border-bottom: 2px solid var(--th-line-e2e8f0,#e2e8f0); color: var(--th-fg-64748b,#64748b); font-size: 0.7rem; text-transform: uppercase; font-weight: 700; text-align: start; letter-spacing: 0.5px; }
        .clean-table td { padding: 0.75rem 1rem; border-bottom: 1px solid var(--th-line-f1f5f9,#f1f5f9); color: var(--th-fg-334155,#334155); font-size: 0.85rem; font-weight: 500; vertical-align: middle; }
=======
        .clean-table th { padding: 1rem; border-bottom: 2px solid var(--th-line-e2e8f0,#e2e8f0); color: var(--ui-muted); font-size: 0.75rem; text-transform: uppercase; font-weight: 700; text-align: start; letter-spacing: 0.5px; }
        .clean-table td { padding: 1rem; border-bottom: 1px solid var(--th-line-f1f5f9,#f1f5f9); color: var(--th-fg-334155,#334155); font-size: 0.875rem; font-weight: 500; vertical-align: middle; }
>>>>>>> 347845ac34e0073173baf41671d1d4290e7bffa8
        .clean-table tr:hover td { background-color: var(--th-bg-f8fafc,#f8fafc); }

        /* قياس موحد لأزرار الصفحة */
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

        /* توحيد عرض وحجم شارات الـ Status لتكون متناسقة ومتساوية تماماً */
        .status-pill-fixed {
            width: 125px !important;
            min-width: 125px !important;
            max-width: 125px !important;
            height: 28px !important;
            display: inline-flex !important;
            align-items: center !important;
            justify-content: center !important;
            gap: 6px !important;
            border-radius: 50px !important;
            font-size: 0.7rem !important;
            font-weight: 600 !important;
            box-sizing: border-box !important;
            white-space: nowrap !important;
        }

        .training-date-text { white-space: nowrap; font-size: 0.75rem; font-weight: 600; color: #64748b; }

        .filter-container { display: flex; flex-wrap: wrap; align-items: center; gap: 0.75rem; margin-bottom: 1rem; }
        
        .filter-input { 
            background-color: var(--th-bg-f8fafc,#f8fafc); 
            border: 1px solid var(--th-line-e3e8ee,#e3e8ee); 
            color: var(--th-fg-1d2733,#1d2733); 
            border-radius: 50px !important; 
            transition: 0.2s; 
            box-shadow: none !important; 
            font-size: 0.8rem; 
            height: 38px;
            padding-top: 0.35rem;
            padding-bottom: 0.35rem;
        }
        .filter-input:focus { border-color: var(--th-line-0f4c81,#0f4c81); background-color: var(--ui-surface,#fff); }
        
        .search-box { position: relative; width: 240px; }
        .search-box .bi-search { position: absolute; top: 50%; transform: translateY(-50%); inset-inline-start: 14px; font-size: 0.75rem; color: #6c757d; }
        .search-box .filter-input { width: 100%; padding-inline-start: 36px !important; padding-inline-end: 14px; }

        .dropdown-box { width: 220px; padding-inline-start: 16px !important; padding-inline-end: 34px !important; }

        .student-avatar { width: 36px; height: 36px; border-radius: 50%; background-color: var(--th-bg-f0f4f8,#f0f4f8); color: var(--th-fg-0f4c81,#0f4c81); font-size: 0.8rem; font-weight: 700; display: flex; align-items: center; justify-content: center; border: 1px solid var(--th-line-e3e8ee,#e3e8ee); }

        .progress-wrapper { display: flex; align-items: center; gap: 8px; }
        .progress-container { width: 80px; background-color: var(--th-bg-e2e8f0,#e2e8f0); border-radius: 10px; height: 5px; overflow: hidden; margin: 0; }
        .progress-fill { height: 100%; background-color: var(--th-bg-0f4c81,#0f4c81); border-radius: 10px; }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container-fluid px-3 px-md-4 py-4">

        <header class="dashboard-header">
            <div>
                <h3><i class="bi bi-people-fill me-2 text-primary"></i><%: L.T("Company.Trainees.MyTrainees") %></h3>
                <p><%: L.T("Company.Trainees.TrackAcceptedStudentsTrainingInformationAnd") %></p>
            </div>
        </header>

        <asp:Label ID="lblMessage" runat="server" EnableViewState="false" CssClass="d-block mb-3"></asp:Label>

        <!-- البطاقات الإحصائية -->
        <div class="row g-3 mb-4">
            <div class="col-12 col-md-4">
                <div class="card metric-card h-100 p-3">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <div class="title"><%: L.T("Company.Trainees.ActiveTraining") %></div>
                            <div class="value"><asp:Literal ID="litActiveTrainees" runat="server">0</asp:Literal></div>
                            <div class="desc"><%: L.T("Company.Trainees.CurrentlyInProgress") %></div>
                        </div>
                        <div class="metric-icon"><i class="bi bi-person-workspace"></i></div>
                    </div>
                </div>
            </div>

            <div class="col-12 col-md-4">
                <div class="card metric-card h-100 p-3">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <div class="title"><%: L.T("Company.Trainees.NearCompletion") %></div>
                            <div class="value"><asp:Literal ID="litNearCompletion" runat="server">0</asp:Literal></div>
                            <div class="desc"><%: L.T("Company.Trainees.Above80Progress") %></div>
                        </div>
                        <div class="metric-icon"><i class="bi bi-graph-up-arrow"></i></div>
                    </div>
                </div>
            </div>

            <div class="col-12 col-md-4">
                <div class="card metric-card h-100 p-3">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <div class="title"><%: L.T("Company.Trainees.Completed") %></div>
                            <div class="value"><asp:Literal ID="litCompleted" runat="server">0</asp:Literal></div>
                            <div class="desc"><%: L.T("Company.Trainees.SuccessfullyFinished") %></div>
                        </div>
                        <div class="metric-icon"><i class="bi bi-check-circle"></i></div>
                    </div>
                </div>
            </div>
        </div>

        <div class="card card-custom p-4 border border-light">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <div>
                    <h6 class="fw-bold text-dark mb-0" style="font-size: 1rem;"><i class="bi bi-card-list me-2"></i><%: L.T("Company.Trainees.TraineeDirectory") %></h6>
                </div>
                <button type="button" class="btn btn-exact-match btn-style-light shadow-sm text-muted" data-bs-toggle="collapse" data-bs-target="#tableCollapse" aria-expanded="true" onclick="toggleTableVisibility(this)">
                    <i class="bi bi-eye-slash-fill me-1"></i><span class="toggle-text"><%: L.T("Company.Trainees.HideList") %></span>
                </button>
            </div>

            <div class="collapse show" id="tableCollapse">
                <!-- الفلاتر -->
                <div class="filter-container">
                    <div class="search-box">
                        <i class="bi bi-search"></i>
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control filter-input" placeholder="<%$ Resources:Company, Trainees.SearchByName %>" AutoPostBack="true" OnTextChanged="Filter_Changed"></asp:TextBox>
                    </div>

                    <asp:DropDownList ID="ddlDepartment" runat="server" CssClass="form-select filter-input dropdown-box" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed">
                        <asp:ListItem Text="<%$ Resources:Company, Trainees.AllDepartments %>" Value="All"></asp:ListItem>
                        <asp:ListItem Text="<%$ Resources:Company, Trainees.SoftwareEngineering %>" Value="Software Engineering"></asp:ListItem>
                        <asp:ListItem Text="<%$ Resources:Company, Trainees.ComputerScience %>" Value="Computer Science"></asp:ListItem>
                        <asp:ListItem Text="<%$ Resources:Company, Trainees.ComputerInformationSystems %>" Value="Computer Information Systems"></asp:ListItem>
                    </asp:DropDownList>

                    <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-select filter-input dropdown-box" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed">
                        <asp:ListItem Text="<%$ Resources:Company, Trainees.AllTrainingStatuses %>" Value="All"></asp:ListItem>
                        <asp:ListItem Text="<%$ Resources:Company, Trainees.InProgress079 %>" Value="InProgress"></asp:ListItem>
                        <asp:ListItem Text="<%$ Resources:Company, Trainees.NearFinish8099 %>" Value="NearFinish"></asp:ListItem>
                        <asp:ListItem Text="<%$ Resources:Company, Trainees.Completed100 %>" Value="Completed"></asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div class="table-responsive">
                    <asp:GridView ID="gvTrainees" runat="server" CssClass="clean-table" AutoGenerateColumns="False" EmptyDataText="<%$ Resources:Company, Trainees.NoTraineesMatchYourSearchCriteria %>" GridLines="None">
                        <HeaderStyle CssClass="bg-light text-muted" />
                        <Columns>
                            <asp:TemplateField HeaderText="<%$ Resources:Company, Trainees.Trainee %>">
                                <ItemTemplate>
                                    <div class="d-flex align-items-center gap-3">
                                        <div class="student-avatar shadow-sm"><%# GetInitials(Eval("StudentName").ToString()) %></div>
                                        <div>
                                            <div class="fw-bold text-dark" style="font-size: 0.85rem;"><%# Eval("StudentName") %></div>
                                            <div class="text-muted" style="font-size: 0.7rem;"><%# Eval("StudentMajor") %></div>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="<%$ Resources:Company, Trainees.Opportunity %>">
                                <ItemTemplate>
                                    <div class="fw-bold text-dark" style="font-size: 0.85rem;"><%# Eval("OpportunityTitle") %></div>
                                    <div class="text-muted" style="font-size: 0.7rem;"><%: L.T("Company.Trainees.InternshipProgram") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="<%$ Resources:Company, Trainees.TrainingPeriod %>">
                                <ItemTemplate>
                                    <span class="training-date-text"><i class="bi bi-calendar-event me-1"></i><%# FormatDate(Eval("StartDate")) %> - <%# FormatDate(Eval("EndDate")) %></span>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="<%$ Resources:Company, Trainees.Progress %>">
                                <ItemTemplate>
                                    <div class="progress-wrapper">
                                        <div class="progress-container">
                                            <div class="progress-fill" style='width: <%# Eval("ProgressPercentage") %>%;'></div>
                                        </div>
                                        <span class="text-dark fw-bold" style="font-size: 0.75rem;"><%# Eval("ProgressPercentage") %>%</span>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="<%$ Resources:Company, Trainees.Status %>">
                                <ItemTemplate>
                                    <!-- تم تطبيق الكلاس الثابت والموحد للعرض والحجم -->
                                    <span class='<%# GetStatusCss(Eval("ProgressPercentage").ToString()) %> status-pill-fixed fw-bold'>
                                        <i class="bi bi-circle-fill" style="font-size: 0.4rem;"></i><%# GetStatusText(Eval("ProgressPercentage").ToString()) %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="<%$ Resources:Company, Trainees.Action %>">
                                <ItemTemplate>
                                    <a href='TraineeDetails.aspx?id=<%# Eval("Id") %>' class="btn btn-exact-match btn-style-light shadow-sm"><%: L.T("Company.Trainees.ViewDetails") %></a>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>

    <script>
        function toggleTableVisibility(btn) {
            setTimeout(function () {
                var isExpanded = btn.getAttribute('aria-expanded') === 'true';
                var icon = btn.querySelector('i');
                var text = btn.querySelector('.toggle-text');

                if (isExpanded) {
                    icon.className = 'bi bi-eye-slash-fill me-1';
                    text.innerText = window.uimsT ? window.uimsT('HideList') : 'Hide List';
                } else {
                    icon.className = 'bi bi-eye-fill me-1';
                    text.innerText = window.uimsT ? window.uimsT('ShowList') : 'Show List';
                }
            }, 50);
        }
    </script>
</asp:Content>