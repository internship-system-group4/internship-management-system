<%@ Page Language="C#" MasterPageFile="~/Layout/Company.master" AutoEventWireup="true" CodeBehind="Trainees.aspx.cs" Inherits="InternshipManagementSystem.Pages.CompanyArea.Trainees" Title="My Trainees" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">

    <style>
        /* الألوان الأساسية وتوحيد الثيم */
        .text-brand { color: var(--th-fg-0f4c81,#0f4c81) !important; }
        .bg-brand-light { background-color: var(--th-bg-f0f4f8,#f0f4f8) !important; color: var(--th-fg-0f4c81,#0f4c81) !important; border: 1px solid var(--th-line-e3e8ee,#e3e8ee); }
        .page-header-title { font-size: 1.75rem; font-weight: 700; color: var(--th-fg-0f4c81,#0f4c81); }

        /* تأثيرات البطاقات */
        .hover-card { transition: all 0.2s ease-in-out; border: 1px solid var(--th-line-e3e8ee,#e3e8ee); cursor: default; background: var(--ui-surface,#fff); }
        .hover-card:hover { transform: translateY(-3px); border-color: var(--th-line-0f4c81,#0f4c81) !important; box-shadow: 0 4px 15px rgba(15, 76, 129, 0.08) !important; }

        /* تصميم الجدول النظيف والمتناسق */
        .clean-table { width: 100%; border-collapse: collapse; }
        .clean-table th { padding: 1rem; border-bottom: 2px solid var(--th-line-e2e8f0,#e2e8f0); color: var(--th-fg-64748b,#64748b); font-size: 0.75rem; text-transform: uppercase; font-weight: 700; text-align: start; letter-spacing: 0.5px; }
        .clean-table td { padding: 1rem; border-bottom: 1px solid var(--th-line-f1f5f9,#f1f5f9); color: var(--th-fg-334155,#334155); font-size: 0.875rem; font-weight: 500; vertical-align: middle; }
        .clean-table tr:hover td { background-color: var(--th-bg-f8fafc,#f8fafc); }

        /* تم تصغير الزر ومنع انقسام النص على سطرين */
        .btn-view-details { background-color: var(--th-bg-f1f5f9,#f1f5f9); color: var(--th-fg-0f4c81,#0f4c81); font-weight: 700; padding: 5px 16px; border-radius: 50px; border: 1px solid var(--th-line-e2e8f0,#e2e8f0); transition: 0.2s; text-decoration: none; display: inline-block; font-size: 0.8rem; white-space: nowrap; }
        .btn-view-details:hover { background-color: var(--th-bg-e2e8f0,#e2e8f0); color: var(--th-fg-0a365c,#0a365c); border-color: var(--th-line-cbd5e1,#cbd5e1); }

        /* أدوات الفلترة */
        .filter-input { background-color: var(--th-bg-f8fafc,#f8fafc); border: 1px solid var(--th-line-e3e8ee,#e3e8ee); color: var(--th-fg-1d2733,#1d2733); font-size: 0.85rem; padding: 0.5rem 1rem; border-radius: 50px; transition: 0.2s; }
        .filter-input:focus { border-color: var(--th-line-0f4c81,#0f4c81); box-shadow: none; background-color: var(--ui-surface,#fff); }

        .student-avatar { width: 40px; height: 40px; border-radius: 50%; background-color: var(--th-bg-f0f4f8,#f0f4f8); color: var(--th-fg-0f4c81,#0f4c81); font-weight: 700; display: flex; align-items: center; justify-content: center; border: 1px solid var(--th-line-e3e8ee,#e3e8ee); }

        .progress-container { width: 100px; background-color: var(--th-bg-e2e8f0,#e2e8f0); border-radius: 10px; height: 6px; overflow: hidden; margin-top: 4px; }
        .progress-fill { height: 100%; background-color: var(--th-bg-0f4c81,#0f4c81); border-radius: 10px; }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container-fluid px-4 py-4">

        <!-- عنوان الصفحة -->
        <div class="mb-4 d-flex justify-content-between align-items-end border-bottom pb-3">
            <div>
                <h2 class="page-header-title mb-1"><%: L.T("Company.Trainees.MyTrainees") %></h2>
                <p class="text-muted mb-0"><%: L.T("Company.Trainees.TrackAcceptedStudentsTrainingInformationAnd") %></p>
            </div>
        </div>

        <asp:Label ID="lblMessage" runat="server" EnableViewState="false" CssClass="d-block mb-3"></asp:Label>

        <!-- البطاقات الإحصائية -->
        <div class="row mb-4">
            <div class="col-md-4 mb-3">
                <div class="card border-0 shadow-sm rounded-4 hover-card h-100 p-2">
                    <div class="card-body d-flex justify-content-between align-items-start">
                        <div>
                            <p class="text-muted small fw-bold mb-1 letter-spacing-1 text-uppercase"><%: L.T("Company.Trainees.ActiveTraining") %></p>
                            <h2 class="fw-bold text-dark mb-1"><asp:Literal ID="litActiveTrainees" runat="server">0</asp:Literal></h2>
                            <small class="text-muted"><%: L.T("Company.Trainees.CurrentlyInProgress") %></small>
                        </div>
                        <div class="bg-brand-light rounded-3 p-2"><i class="bi bi-people fs-5"></i></div>
                    </div>
                </div>
            </div>

            <div class="col-md-4 mb-3">
                <div class="card border-0 shadow-sm rounded-4 hover-card h-100 p-2">
                    <div class="card-body d-flex justify-content-between align-items-start">
                        <div>
                            <p class="text-muted small fw-bold mb-1 letter-spacing-1 text-uppercase"><%: L.T("Company.Trainees.NearCompletion") %></p>
                            <h2 class="fw-bold text-dark mb-1"><asp:Literal ID="litNearCompletion" runat="server">0</asp:Literal></h2>
                            <small class="text-muted"><%: L.T("Company.Trainees.Above80Progress") %></small>
                        </div>
                        <div class="bg-brand-light rounded-3 p-2"><i class="bi bi-graph-up fs-5"></i></div>
                    </div>
                </div>
            </div>

            <div class="col-md-4 mb-3">
                <div class="card border-0 shadow-sm rounded-4 hover-card h-100 p-2">
                    <div class="card-body d-flex justify-content-between align-items-start">
                        <div>
                            <p class="text-muted small fw-bold mb-1 letter-spacing-1 text-uppercase"><%: L.T("Company.Trainees.Completed") %></p>
                            <h2 class="fw-bold text-dark mb-1"><asp:Literal ID="litCompleted" runat="server">0</asp:Literal></h2>
                            <small class="text-muted"><%: L.T("Company.Trainees.SuccessfullyFinished") %></small>
                        </div>
                        <div class="bg-brand-light rounded-3 p-2"><i class="bi bi-check-lg fs-5"></i></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- قسم الجدول والبحث -->
        <div class="card border-0 shadow-sm rounded-4 p-4 border border-light">

            <!-- عنوان الجدول مع زر الطي (Hide/Show) -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h5 class="fw-bold text-brand mb-1"><%: L.T("Company.Trainees.TraineeDirectory") %></h5>
                    <p class="text-muted small mb-0"><asp:Literal ID="litTotalCount" runat="server">0</asp:Literal> <%: L.T("Company.Trainees.AcceptedStudents") %></p>
                </div>
                <button type="button" class="btn btn-sm btn-light border rounded-pill px-3 fw-bold text-muted" data-bs-toggle="collapse" data-bs-target="#tableCollapse" aria-expanded="true" onclick="toggleTableVisibility(this)">
                    <i class="bi bi-eye-slash-fill me-1"></i><span class="toggle-text"><%: L.T("Company.Trainees.HideList") %></span>
                </button>
            </div>

            <!-- تغليف الفلاتر والجدول بـ Collapse -->
            <div class="collapse show" id="tableCollapse">
                <!-- أدوات الفلترة الدائرية الأنيقة -->
                <div class="d-flex gap-3 flex-wrap mb-4">
                    <div class="position-relative flex-grow-1" style="max-width: 300px;">
                        <i class="bi bi-search position-absolute text-muted" style="top: 50%; transform: translateY(-50%); inset-inline-start: 16px; font-size: 0.85rem;"></i>
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control filter-input ps-5" placeholder="<%$ Resources:Company, Trainees.SearchByName %>" AutoPostBack="true" OnTextChanged="Filter_Changed"></asp:TextBox>
                    </div>

                    <asp:DropDownList ID="ddlDepartment" runat="server" CssClass="form-select filter-input w-auto pe-5" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed">
                        <asp:ListItem Text="<%$ Resources:Company, Trainees.AllDepartments %>" Value="All"></asp:ListItem>
                        <asp:ListItem Text="<%$ Resources:Company, Trainees.SoftwareEngineering %>" Value="Software Engineering"></asp:ListItem>
                        <asp:ListItem Text="<%$ Resources:Company, Trainees.ComputerScience %>" Value="Computer Science"></asp:ListItem>
                        <asp:ListItem Text="<%$ Resources:Company, Trainees.ComputerInformationSystems %>" Value="Computer Information Systems"></asp:ListItem>
                    </asp:DropDownList>

                    <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-select filter-input w-auto pe-5" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed">
                        <asp:ListItem Text="<%$ Resources:Company, Trainees.AllTrainingStatuses %>" Value="All"></asp:ListItem>
                        <asp:ListItem Text="<%$ Resources:Company, Trainees.InProgress079 %>" Value="InProgress"></asp:ListItem>
                        <asp:ListItem Text="<%$ Resources:Company, Trainees.NearFinish8099 %>" Value="NearFinish"></asp:ListItem>
                        <asp:ListItem Text="<%$ Resources:Company, Trainees.Completed100 %>" Value="Completed"></asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div class="table-responsive">
                    <asp:GridView ID="gvTrainees" runat="server" CssClass="clean-table" AutoGenerateColumns="False" EmptyDataText="<%$ Resources:Company, Trainees.NoTraineesMatchYourSearchCriteria %>" GridLines="None">
                        <HeaderStyle CssClass="bg-light text-muted small text-uppercase" />
                        <Columns>

                            <asp:TemplateField HeaderText="<%$ Resources:Company, Trainees.Trainee %>">
                                <ItemTemplate>
                                    <div class="d-flex align-items-center gap-3">
                                        <div class="student-avatar shadow-sm"><%# GetInitials(Eval("StudentName").ToString()) %></div>
                                        <div>
                                            <div class="fw-bold text-dark"><%# Eval("StudentName") %></div>
                                            <div class="text-muted" style="font-size: 0.75rem;"><%# Eval("StudentMajor") %></div>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="<%$ Resources:Company, Trainees.Opportunity %>">
                                <ItemTemplate>
                                    <div class="fw-bold text-dark"><%# Eval("OpportunityTitle") %></div>
                                    <div class="text-muted" style="font-size: 0.75rem;"><%: L.T("Company.Trainees.InternshipProgram") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="<%$ Resources:Company, Trainees.TrainingPeriod %>">
                                <ItemTemplate>
                                    <span class="text-muted fw-semibold" style="font-size: 0.85rem;"><i class="bi bi-calendar-event me-1"></i><%# FormatDate(Eval("StartDate")) %> - <%# FormatDate(Eval("EndDate")) %></span>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="<%$ Resources:Company, Trainees.Progress %>">
                                <ItemTemplate>
                                    <div class="d-flex align-items-center gap-2">
                                        <div class="progress-container">
                                            <div class="progress-fill" style='width: <%# Eval("ProgressPercentage") %>%;'></div>
                                        </div>
                                        <span class="small text-dark fw-bold"><%# Eval("ProgressPercentage") %>%</span>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="<%$ Resources:Company, Trainees.Status %>">
                                <ItemTemplate>
                                    <span class='<%# GetStatusCss(Eval("ProgressPercentage").ToString()) %> fw-bold'>
                                        <i class="bi bi-circle-fill me-1" style="font-size: 0.4rem;"></i><%# GetStatusText(Eval("ProgressPercentage").ToString()) %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="<%$ Resources:Company, Trainees.Action %>">
                                <ItemTemplate>
                                    <a href='TraineeDetails.aspx?id=<%# Eval("Id") %>' class="btn-view-details"><%: L.T("Company.Trainees.ViewDetails") %></a>
                                </ItemTemplate>
                            </asp:TemplateField>

                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>

    </div>

    <!-- سكريبت تبديل الأيقونة والكلمة لزر الإخفاء/الإظهار -->
    <script>
function toggleTableVisibility(btn) {
    setTimeout(function() {
        var isExpanded = btn.getAttribute('aria-expanded') === 'true';
        var icon = btn.querySelector('i');
        var text = btn.querySelector('.toggle-text');

        if (isExpanded) {
            icon.className = 'bi bi-eye-slash-fill me-1';
            text.innerText = window.uimsT('HideList');
        } else {
            icon.className = 'bi bi-eye-fill me-1';
            text.innerText = window.uimsT('ShowList');
        }
    }, 50);
        }
    </script>
</asp:Content>