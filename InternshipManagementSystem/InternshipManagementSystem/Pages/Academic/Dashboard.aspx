<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/Layout/Academic.master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="InternshipManagementSystem.Pages.Academic.Dashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <!-- Custom styles to perfectly match Figma components -->
    <style>
        .student-avatar {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background-color: var(--brand-light);
            color: var(--brand);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            font-size: 0.9rem;
        }
        .progress-text {
            font-size: 0.75rem;
            color: var(--muted);
            font-weight: 600;
        }
        .btn-outline-brand {
            border: 1px solid var(--brand);
            color: var(--brand);
            background: transparent;
            font-weight: 600;
            padding: 0.4rem 1rem;
            border-radius: 6px;
        }
        .btn-outline-brand:hover {
            background-color: var(--brand-light);
            color: var(--brand-dark);
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Topbar & Welcome -->
    <div class="uims-topbar mb-4">
        <h1 class="uims-page-title">Academic Supervisor Portal <span class="text-muted mx-2">></span> Academic dashboard</h1>
        <div class="uims-user">
            <div class="uims-user-meta">
                <strong>Dr. <asp:Literal ID="litSupervisorName" runat="server"></asp:Literal></strong>
                <small>Academic supervisor</small>
            </div>
        </div>
    </div>

    <!-- Summary Cards -->
    <div class="row mb-4">
        <div class="col-md-4 mb-3 mb-md-0">
            <div class="uims-card h-100 d-flex align-items-center justify-content-between">
                <div>
                    <h3 class="text-muted mb-1" style="font-size: 0.85rem; font-weight: 600;">Assigned students</h3>
                    <h2 class="display-5 mb-0" style="color: var(--brand); font-weight: 700;">
                        <asp:Literal ID="litTotalStudents" runat="server"></asp:Literal>
                    </h2>
                </div>
                <div class="p-3" style="background-color: var(--brand-light); border-radius: 8px;">
                    <!-- Placeholder icon -->
                    <span style="color: var(--brand); font-size: 1.2rem;">👥</span>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="uims-card h-100 d-flex align-items-center justify-content-between">
                <div>
                    <h3 class="text-muted mb-1" style="font-size: 0.85rem; font-weight: 600;">Completed students</h3>
                    <h2 class="display-5 mb-0" style="color: var(--accent); font-weight: 700;">
                        <asp:Literal ID="litCompletedStudents" runat="server"></asp:Literal>
                    </h2>
                </div>
                <div class="p-3" style="background-color: #fcf6e8; border-radius: 8px;">
                    <!-- Placeholder icon -->
                    <span style="color: var(--accent); font-size: 1.2rem;">🎓</span>
                </div>
            </div>
        </div>
    </div>

    <!-- Assigned Students Table -->
    <div class="uims-card">
        <div class="table-responsive">
            <table class="uims-table align-middle">
                <thead>
                    <tr>
                        <th colspan="2">Student Details</th>
                        <th>Major</th>
                        <th>Progress</th>
                        <th class="text-end">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptStudents" runat="server">
                        <ItemTemplate>
                            <tr>
                                <!-- Avatar -->
                                <td style="width: 50px;">
                                    <div class="student-avatar">
                                        <!-- Displays the first letter of the student's name safely -->
                                        <%# Eval("FullName") != null && Eval("FullName").ToString().Length > 0 ? Eval("FullName").ToString().Substring(0, 1).ToUpper() : "S" %>
                                    </div>
                                </td>
                                
                                <!-- Name and ID -->
                                <td>
                                    <div style="font-weight: 600; color: var(--brand-dark); font-size: 0.95rem;">
                                        <%# Eval("FullName") %>
                                    </div>
                                    <div style="font-size: 0.75rem; color: var(--muted);">
                                        #<%# Eval("StudentNumber") %>
                                    </div>
                                </td>

                                <!-- Major -->
                                <td style="font-size: 0.9rem; color: var(--muted);">
                                    <%# Eval("Major") %>
                                </td>

                                <!-- Hours Progress -->
                                <td>
                                    <div class="d-flex justify-content-between align-items-center mb-1">
                                        <span class="progress-text"><%# Eval("ApprovedHours") %> / <%# Eval("RequiredHours") %> h</span>
                                        <span class="progress-text"><%# Eval("HoursProgressPercent") %>%</span>
                                    </div>
                                    <div class="progress" style="height: 6px; border-radius: 10px; background-color: var(--brand-light);">
                                        <div class="progress-bar" role="progressbar" 
                                             style='width: <%# Eval("HoursProgressPercent") %>%; background-color: var(--brand);' 
                                             aria-valuenow='<%# Eval("HoursProgressPercent") %>' aria-valuemin="0" aria-valuemax="100">
                                        </div>
                                    </div>
                                </td>

                                <!-- Action Button -->
                                <td class="text-end">
                                    <a href="StudentProgress.aspx?id=<%# Eval("Id") %>" class="btn btn-sm btn-outline-brand">View progress</a>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                    
                    <!-- Empty State -->
                    <asp:Literal ID="litNoData" runat="server" Visible="false">
                        <tr><td colspan="5" class="text-center text-muted py-4">No students are currently assigned to you.</td></tr>
                    </asp:Literal>
                </tbody>
            </table>
        </div>
    </div>
</asp:Content>  
