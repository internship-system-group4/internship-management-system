<%@ Page Title="Student Progress" Language="C#" MasterPageFile="~/Layout/Academic.master" AutoEventWireup="true" CodeBehind="StudentProgress.aspx.cs" Inherits="InternshipManagementSystem.Pages.Academic.StudentProgress" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .back-link { text-decoration: none; color: var(--muted); font-weight: 600; font-size: 0.9rem; display: inline-flex; align-items: center; gap: 0.5rem; margin-bottom: 1rem; }
        .back-link:hover { color: var(--brand-text,var(--brand)); }
        .btn-outline-brand { border: 1px solid var(--brand); color: var(--brand-text,var(--brand)); background: transparent; font-weight: 600; padding: 0.4rem 1rem; border-radius: 6px; }
        .btn-outline-brand:hover { background-color: var(--brand-light); color: var(--brand-text,var(--brand-dark)); }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <!-- Panel 1: Students List (Shown when clicked from Sidebar) -->
    <asp:Panel ID="pnlStudentList" runat="server" Visible="false">
        <div class="uims-topbar mb-4" style="border-radius: var(--radius);">
            <h1 class="uims-page-title"><%: L.T("Academic.StudentProgress.StudentProgressMonitor") %></h1>
            <div class="text-muted"><%: L.T("Academic.StudentProgress.SelectAStudentToViewTheir") %></div>
        </div>

        <div class="uims-card">
            <div class="table-responsive">
                <table class="uims-table align-middle">
                    <thead>
                        <tr>
                            <th><%: L.T("Academic.StudentProgress.StudentName") %></th>
                            <th><%: L.T("Academic.StudentProgress.UniversityID") %></th>
                            <th><%: L.T("Academic.StudentProgress.Major") %></th>
                            <th class="text-end"><%: L.T("Academic.StudentProgress.Action") %></th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptStudentsList" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td><strong><%# Eval("FullName") %></strong></td>
                                    <td>#<%# Eval("StudentNumber") %></td>
                                    <td><%# Eval("Major") %></td>
                                    <td class="text-end">
                                        <a href="StudentProgress.aspx?id=<%# Eval("Id") %>" class="btn btn-sm btn-outline-brand"><%: L.T("Academic.StudentProgress.ViewProgress") %></a>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                        
                        <asp:PlaceHolder ID="litNoStudents" runat="server" Visible="false">
                            <tr><td colspan="4" class="text-center text-muted py-4"><%: L.T("Academic.StudentProgress.NoStudentsAssigned") %></td></tr>
                        </asp:PlaceHolder>
                    </tbody>
                </table>
            </div>
        </div>
    </asp:Panel>

    <!-- Panel 2: Progress Details (Shown when a student is selected) -->
    <asp:Panel ID="pnlProgressDetails" runat="server" Visible="false">
        
        <a href="StudentProgress.aspx" class="back-link">
            <span>&larr;</span> <%: L.T("Academic.StudentProgress.BackToStudentsList") %>
        </a>

        <!-- Student Header Summary -->
        <div class="uims-card mb-4" style="border-top: 4px solid var(--brand);">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h2 class="mb-1" style="color: var(--brand-text,var(--brand-dark)); font-weight: 700;">
                        <asp:Literal ID="litStudentName" runat="server"></asp:Literal>
                    </h2>
                    <div class="text-muted">
                        #<asp:Literal ID="litStudentId" runat="server"></asp:Literal> &bull; 
                        <asp:Literal ID="litMajor" runat="server"></asp:Literal>
                    </div>
                </div>
                <div class="text-end">
                    <div class="text-muted" style="font-size: 0.85rem; font-weight: 600;"><%: L.T("Academic.StudentProgress.TrainingHours") %></div>
                    <h3 style="color: var(--accent); font-weight: 700; margin: 0;">
                        <asp:Literal ID="litApprovedHours" runat="server">0</asp:Literal> / 
                        <asp:Literal ID="litRequiredHours" runat="server">0</asp:Literal> h
                    </h3>
                </div>
            </div>
        </div>

        <!-- Accordion for detailed sections -->
        <div class="accordion" id="progressAccordion">
            <!-- Interactive Progress Summary Card (Bonus Feature) -->
<div class="card shadow-sm mb-4 border-0" style="background-color: #f8f9fa; border-radius: 10px;">
    <div class="card-body">
        <div class="d-flex justify-content-between align-items-center mb-2">
            <h6 class="fw-bold text-dark m-0">Training Hours & Progress Overview</h6>
            <!-- Dynamic Status Badge -->
            <span class="badge bg-warning text-dark px-3 py-2" id="badgeStatus" runat="server">In Progress ⏳</span>
        </div>
        
        <!-- Progress Bar -->
        <div class="progress mb-2" style="height: 12px; border-radius: 6px;">
            <div class="progress-bar bg-warning progress-bar-striped progress-bar-animated" role="progressbar" style="width: 0%;" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100">0%</div>
        </div>
        
        <div class="d-flex justify-content-between text-muted" style="font-size: 0.85rem;">
            <span>Completed Hours: <b>0 hrs</b> / 160 hrs</span>
            <span>Pending Company Verification</span>
        </div>
    </div>
</div>
            
            <!-- Section 1: Placement Details -->
            <div class="accordion-item mb-3" style="border: 1px solid var(--line); border-radius: var(--radius); overflow: hidden;">
                <h2 class="accordion-header" id="headingCompany">
                    <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#collapseCompany" aria-expanded="true" aria-controls="collapseCompany" style="font-weight: 600; color: var(--brand-text,var(--brand-dark));">
                        <%: L.T("Academic.StudentProgress.PlacementCompanyDetails") %>
                    </button>
                </h2>
                <div id="collapseCompany" class="accordion-collapse collapse show" aria-labelledby="headingCompany" data-bs-parent="#progressAccordion">
                    <div class="accordion-body">
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <strong class="text-muted d-block" style="font-size: 0.8rem;"><%: L.T("Academic.StudentProgress.CompanyName") %></strong>
                                <asp:Literal ID="litCompanyName" runat="server"></asp:Literal>
                            </div>
                            <div class="col-md-6 mb-3">
                                <strong class="text-muted d-block" style="font-size: 0.8rem;"><%: L.T("Academic.StudentProgress.CompanySupervisor") %></strong>
                                <asp:Literal ID="litCompanySupervisor" runat="server"></asp:Literal>
                            </div>
                            <div class="col-md-6 mb-3">
                                <strong class="text-muted d-block" style="font-size: 0.8rem;"><%: L.T("Academic.StudentProgress.OpportunityTitle") %></strong>
                                <asp:Literal ID="litOpportunityTitle" runat="server"></asp:Literal>
                            </div>
                            <div class="col-md-6 mb-3">
                                <strong class="text-muted d-block" style="font-size: 0.8rem;"><%: L.T("Academic.StudentProgress.Status") %></strong>
                                <span class="uims-pill uims-pill-accepted"><asp:Literal ID="litPlacementStatus" runat="server"></asp:Literal></span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Section 2: Tasks -->
            <div class="accordion-item mb-3" style="border: 1px solid var(--line); border-radius: var(--radius); overflow: hidden;">
                <h2 class="accordion-header" id="headingTasks">
                    <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#collapseTasks" aria-expanded="false" aria-controls="collapseTasks" style="font-weight: 600; color: var(--brand-text,var(--brand-dark));">
                        <%: L.T("Academic.StudentProgress.TasksSubmissions") %>
                    </button>
                </h2>
                <div id="collapseTasks" class="accordion-collapse collapse" aria-labelledby="headingTasks" data-bs-parent="#progressAccordion">
                    <div class="accordion-body p-0">
                        <div class="table-responsive">
                            <table class="uims-table mb-0">
                                <thead style="background-color: var(--canvas);">
                                    <tr>
                                        <th><%: L.T("Academic.StudentProgress.TaskTitle") %></th>
                                        <th><%: L.T("Academic.StudentProgress.Status") %></th>
                                        <th><%: L.T("Academic.StudentProgress.MaxScore") %></th>
                                        <th><%: L.T("Academic.StudentProgress.EstimatedHours") %></th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <asp:Repeater ID="rptTasks" runat="server">
                                        <ItemTemplate>
                                            <tr>
                                                <td><strong><%# Eval("Title") %></strong></td>
                                                <td><span class="uims-pill uims-pill-info"><%# Eval("Status") %></span></td>
                                                <td><%# Eval("MaxScore") %></td>
                                                <td><%# Eval("EstimatedHours") %> h</td>
                                            </tr>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                    <asp:PlaceHolder ID="litNoTasks" runat="server" Visible="false">
                                        <tr><td colspan="4" class="text-center text-muted py-3"><%: L.T("Academic.StudentProgress.NoTasksAssignedYet") %></td></tr>
                                    </asp:PlaceHolder>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Section 3: Academic Comments -->
            <div class="accordion-item mb-3" style="border: 1px solid var(--line); border-radius: var(--radius); overflow: hidden;">
                <h2 class="accordion-header" id="headingComments">
                    <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#collapseComments" aria-expanded="false" aria-controls="collapseComments" style="font-weight: 600; color: var(--brand-text,var(--brand-dark));">
                        <%: L.T("Academic.StudentProgress.AcademicCommentsFeedback") %>
                    </button>
                </h2>
                <div id="collapseComments" class="accordion-collapse collapse" aria-labelledby="headingComments" data-bs-parent="#progressAccordion">
                    <div class="accordion-body">
                        <div class="mb-4">
                            <asp:Repeater ID="rptComments" runat="server">
                                <ItemTemplate>
                                    <div class="p-3 mb-2" style="background-color: var(--canvas); border-radius: var(--radius); border-inline-start: 3px solid var(--accent);">
                                        <div class="text-muted mb-1" style="font-size: 0.8rem;">
                                            <strong><%# Eval("IsVisibleToStudent").ToString() == "True" ? "Visible to Student" : "Private Note" %></strong>
                                        </div>
                                        <div><%# Eval("Comment") %></div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                            <asp:PlaceHolder ID="litNoComments" runat="server" Visible="false">
                                <p class="text-muted"><%: L.T("Academic.StudentProgress.NoCommentsYet") %></p>
                            </asp:PlaceHolder>
                        </div>

                        <div class="form-group mb-3">
                            <label class="form-label" style="font-weight: 600;"><%: L.T("Academic.StudentProgress.AddANewComment") %></label>
                            <asp:TextBox ID="txtNewComment" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" placeholder="<%$ Resources:Academic, StudentProgress.WriteYourObservationOrFeedbackHere %>"></asp:TextBox>
                        </div>
                        <div class="form-check mb-3">
                            <asp:CheckBox ID="chkVisibleToStudent" runat="server" CssClass="form-check-input" />
                            <label class="form-check-label text-muted" for="chkVisibleToStudent"><%: L.T("Academic.StudentProgress.MakeThisCommentVisibleToThe") %></label>
                        </div>
                        <asp:Button ID="btnSaveComment" runat="server" Text="<%$ Resources:Academic, StudentProgress.SaveComment %>" CssClass="btn btn-brand" OnClick="btnSaveComment_Click"  data-ui-action="save" data-loading-label="Saving…"/>
                        
                        <div class="mt-2">
                            <asp:Label ID="lblCommentStatus" runat="server" CssClass="text-success" style="font-weight: 600;" Visible="false"></asp:Label>
                        </div>
                    </div>
                </div>
            </div>

        </div>
        
        <div class="text-end mt-4">
            <asp:Button ID="btnFinalEvaluation" runat="server" Text="<%$ Resources:Academic, StudentProgress.ProceedToFinalEvaluation %>" CssClass="btn btn-brand" OnClick="btnFinalEvaluation_Click" />
        </div>
    </asp:Panel>

</asp:Content>