<%@ Page Title="Student Progress" Language="C#" MasterPageFile="~/Layout/Academic.master" AutoEventWireup="true" CodeBehind="StudentProgress.aspx.cs" Inherits="InternshipManagementSystem.Pages.Academic.StudentProgress" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .back-link {
            text-decoration: none;
            color: var(--muted);
            font-weight: 600;
            font-size: 0.9rem;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            margin-bottom: 1rem;
        }
        .back-link:hover {
            color: var(--brand);
        }
        .section-header {
            color: var(--brand-dark);
            font-weight: 700;
            margin-bottom: 1rem;
            border-bottom: 2px solid var(--line);
            padding-bottom: 0.5rem;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <!-- Back Navigation -->
    <a href="Dashboard.aspx" class="back-link">
        <span>&larr;</span> Back to Dashboard
    </a>

    <!-- Student Header Summary -->
    <div class="uims-card mb-4" style="border-top: 4px solid var(--brand);">
        <div class="d-flex justify-content-between align-items-center">
            <div>
                <h2 class="mb-1" style="color: var(--brand-dark); font-weight: 700;">
                    <asp:Literal ID="litStudentName" runat="server"></asp:Literal>
                </h2>
                <div class="text-muted">
                    #<asp:Literal ID="litStudentId" runat="server"></asp:Literal> &bull; 
                    <asp:Literal ID="litMajor" runat="server"></asp:Literal>
                </div>
            </div>
            <div class="text-end">
                <div class="text-muted" style="font-size: 0.85rem; font-weight: 600;">Training Hours</div>
                <h3 style="color: var(--accent); font-weight: 700; margin: 0;">
                    <asp:Literal ID="litApprovedHours" runat="server">0</asp:Literal> / 
                    <asp:Literal ID="litRequiredHours" runat="server">0</asp:Literal> h
                </h3>
            </div>
        </div>
    </div>

    <!-- Accordion for detailed sections -->
    <div class="accordion" id="progressAccordion">
        
        <!-- Section 1: Placement & Company Details -->
        <div class="accordion-item mb-3" style="border: 1px solid var(--line); border-radius: var(--radius); overflow: hidden;">
            <h2 class="accordion-header" id="headingCompany">
                <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#collapseCompany" aria-expanded="true" aria-controls="collapseCompany" style="font-weight: 600; color: var(--brand-dark);">
                    Placement & Company Details
                </button>
            </h2>
            <div id="collapseCompany" class="accordion-collapse collapse show" aria-labelledby="headingCompany" data-bs-parent="#progressAccordion">
                <div class="accordion-body">
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <strong class="text-muted d-block" style="font-size: 0.8rem;">Company Name</strong>
                            <asp:Literal ID="litCompanyName" runat="server"></asp:Literal>
                        </div>
                        <div class="col-md-6 mb-3">
                            <strong class="text-muted d-block" style="font-size: 0.8rem;">Company Supervisor</strong>
                            <asp:Literal ID="litCompanySupervisor" runat="server"></asp:Literal>
                        </div>
                        <div class="col-md-6 mb-3">
                            <strong class="text-muted d-block" style="font-size: 0.8rem;">Opportunity Title</strong>
                            <asp:Literal ID="litOpportunityTitle" runat="server"></asp:Literal>
                        </div>
                        <div class="col-md-6 mb-3">
                            <strong class="text-muted d-block" style="font-size: 0.8rem;">Status</strong>
                            <span class="uims-pill uims-pill-accepted"><asp:Literal ID="litPlacementStatus" runat="server"></asp:Literal></span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Section 2: Tasks & Progress -->
        <div class="accordion-item mb-3" style="border: 1px solid var(--line); border-radius: var(--radius); overflow: hidden;">
            <h2 class="accordion-header" id="headingTasks">
                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#collapseTasks" aria-expanded="false" aria-controls="collapseTasks" style="font-weight: 600; color: var(--brand-dark);">
                    Tasks & Submissions
                </button>
            </h2>
            <div id="collapseTasks" class="accordion-collapse collapse" aria-labelledby="headingTasks" data-bs-parent="#progressAccordion">
                <div class="accordion-body p-0">
                    <div class="table-responsive">
                        <table class="uims-table mb-0">
                            <thead style="background-color: var(--canvas);">
                                <tr>
                                    <th>Task Title</th>
                                    <th>Status</th>
                                    <th>Max Score</th>
                                    <th>Estimated Hours</th>
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
                                <asp:Literal ID="litNoTasks" runat="server" Visible="false">
                                    <tr><td colspan="4" class="text-center text-muted py-3">No tasks assigned yet.</td></tr>
                                </asp:Literal>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <!-- Section 3: Academic Comments (Task S03) -->
        <div class="accordion-item mb-3" style="border: 1px solid var(--line); border-radius: var(--radius); overflow: hidden;">
            <h2 class="accordion-header" id="headingComments">
                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#collapseComments" aria-expanded="false" aria-controls="collapseComments" style="font-weight: 600; color: var(--brand-dark);">
                    Academic Comments & Feedback
                </button>
            </h2>
            <div id="collapseComments" class="accordion-collapse collapse" aria-labelledby="headingComments" data-bs-parent="#progressAccordion">
                <div class="accordion-body">
                    
                    <!-- Display existing comments -->
                    <div class="mb-4">
                        <asp:Repeater ID="rptComments" runat="server">
                            <ItemTemplate>
                                <div class="p-3 mb-2" style="background-color: var(--canvas); border-radius: var(--radius); border-left: 3px solid var(--accent);">
                                    <div class="text-muted mb-1" style="font-size: 0.8rem;">
                                        <strong><%# Eval("IsVisibleToStudent").ToString() == "True" ? "Visible to Student" : "Private Note" %></strong>
                                    </div>
                                    <div><%# Eval("Comment") %></div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                        <asp:Literal ID="litNoComments" runat="server" Visible="false">
                            <p class="text-muted">No comments added yet.</p>
                        </asp:Literal>
                    </div>

                    <!-- Add new comment form -->
                    <div class="form-group mb-3">
                        <label class="form-label" style="font-weight: 600;">Add a New Comment</label>
                        <asp:TextBox ID="txtNewComment" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" placeholder="Write your observation or feedback here..."></asp:TextBox>
                    </div>
                    <div class="form-check mb-3">
                        <asp:CheckBox ID="chkVisibleToStudent" runat="server" CssClass="form-check-input" />
                        <label class="form-check-label text-muted" for="chkVisibleToStudent">Make this comment visible to the student</label>
                    </div>
                    <asp:Button ID="btnSaveComment" runat="server" Text="Save Comment" CssClass="btn btn-brand" OnClick="btnSaveComment_Click" />
                    
                    <div class="mt-2">
                        <asp:Label ID="lblCommentStatus" runat="server" CssClass="text-success" style="font-weight: 600;" Visible="false"></asp:Label>
                    </div>

                </div>
            </div>
        </div>

    </div>
    
    <!-- Proceed to Final Evaluation Button -->
    <div class="text-end mt-4">
        <asp:Button ID="btnFinalEvaluation" runat="server" Text="Proceed to Final Evaluation" CssClass="btn btn-brand" OnClick="btnFinalEvaluation_Click" />
    </div>

</asp:Content>
