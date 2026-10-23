<%@ Page Language="C#" MasterPageFile="~/Layout/Student.master" AutoEventWireup="true" CodeBehind="Progress.aspx.cs" Inherits="InternshipManagementSystem.Pages.StudentArea.Progress" Title="My Progress & Evaluation" %>
<%-- ===================================================================
     My Progress & Evaluation
     Owner : Ahmad
     Cards : A15, A16
     Task grades, feedback, submission/revision history, approved hours,
     and the official report once the coordinator approves completion.
     The confidential final evaluation forms are never shown here.
     =================================================================== --%>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <style>
        .pe-stat { height: 100%; }
        .pe-stat .pe-label { color: var(--th-fg-6b7280,#6b7280); font-size: .8rem; text-transform: uppercase; letter-spacing: .03em; }
        .pe-stat .pe-value { font-size: 1.6rem; font-weight: 700; color: var(--brand-text,var(--brand-dark)); }
        .pe-muted { color: var(--th-fg-6b7280,#6b7280); font-size: .85rem; }
        .pe-feedback { max-width: 320px; white-space: pre-line; }
        .pe-section { margin-bottom: 1.5rem; }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

    <div class="mb-4">
        <h2 class="mb-1">My Progress &amp; Evaluation</h2>
        <p class="text-muted mb-0">Your task grades, supervisor feedback, approved training hours and completion status.</p>
    </div>

    <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="alert alert-danger">
        Your progress could not be loaded right now. Please refresh the page or try again later.
        <div class="small mt-2"><asp:Literal ID="litErrorDetail" runat="server" Mode="Encode" /></div>
    </asp:Panel>

    <asp:Panel ID="pnlWarning" runat="server" Visible="false" CssClass="alert alert-warning">
        Some sections could not be loaded and may look empty:
        <ul class="mb-0 mt-1">
            <asp:Repeater ID="rptProblems" runat="server">
                <ItemTemplate><li><%#: Container.DataItem %></li></ItemTemplate>
            </asp:Repeater>
        </ul>
    </asp:Panel>

    <asp:Panel ID="pnlNoPlacement" runat="server" Visible="false" CssClass="uims-card">
        <h3>No confirmed internship yet</h3>
        <p class="text-muted mb-3">Your progress and evaluations will appear here after you confirm an accepted internship offer.</p>
        <a class="btn btn-brand btn-sm" href="<%: ResolveUrl("~/Pages/Student/MyApplications.aspx") %>">Go to My Applications</a>
    </asp:Panel>

    <asp:Panel ID="pnlContent" runat="server">

        <%-- Summary --%>
        <div class="row g-3 pe-section">
            <div class="col-sm-6 col-lg-3">
                <div class="uims-card pe-stat">
                    <div class="pe-label">Approved hours</div>
                    <div class="pe-value"><asp:Literal ID="litSumHours" runat="server" /></div>
                    <div class="progress mt-2" style="height: 6px;">
                        <div id="hoursBar" runat="server" class="progress-bar" role="progressbar"
                             style="width: 0%; background-color: var(--brand);"
                             aria-valuemin="0" aria-valuemax="100" aria-label="Approved hours progress"></div>
                    </div>
                    <div class="pe-muted mt-1"><asp:Literal ID="litSumHoursPercent" runat="server" />% of required hours</div>
                </div>
            </div>
            <div class="col-sm-6 col-lg-3">
                <div class="uims-card pe-stat">
                    <div class="pe-label">Tasks graded</div>
                    <div class="pe-value"><asp:Literal ID="litSumTasks" runat="server" /></div>
                    <div class="pe-muted">Graded out of assigned</div>
                </div>
            </div>
            <div class="col-sm-6 col-lg-3">
                <div class="uims-card pe-stat">
                    <div class="pe-label">Open revisions</div>
                    <div class="pe-value"><asp:Literal ID="litSumRevisions" runat="server" /></div>
                    <div class="pe-muted">Tasks waiting for your resubmission</div>
                </div>
            </div>
            <div class="col-sm-6 col-lg-3">
                <div class="uims-card pe-stat">
                    <div class="pe-label">Task grade average</div>
                    <div class="pe-value"><asp:Literal ID="litSumAverage" runat="server" /></div>
                    <div class="pe-muted">Weighted by each task's weight</div>
                </div>
            </div>
        </div>

        <%-- Internship details --%>
        <div class="uims-card pe-section">
            <h3>My internship</h3>
            <div class="row g-3">
                <div class="col-md-4"><div class="pe-muted">Opportunity</div><asp:Literal ID="litOpportunity" runat="server" Mode="Encode" /></div>
                <div class="col-md-4"><div class="pe-muted">Company</div><asp:Literal ID="litCompany" runat="server" Mode="Encode" /></div>
                <div class="col-md-4"><div class="pe-muted">Company supervisor</div><asp:Literal ID="litSupervisor" runat="server" Mode="Encode" /></div>
                <div class="col-md-4"><div class="pe-muted">Training period</div><asp:Literal ID="litDates" runat="server" Mode="Encode" /></div>
                <div class="col-md-4"><div class="pe-muted">Placement status</div><asp:Literal ID="litPlacementStatus" runat="server" Mode="Encode" /></div>
            </div>
        </div>

        <%-- Task grades and feedback --%>
        <div class="uims-card pe-section">
            <h3>Task evaluations &amp; feedback</h3>
            <div class="table-responsive">
                <table class="uims-table">
                    <thead>
                        <tr>
                            <th>Task</th>
                            <th>Deadline</th>
                            <th>Status</th>
                            <th>Attempts</th>
                            <th>Grade</th>
                            <th>Supervisor feedback</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptTasks" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td><strong><%#: Eval("Title") %></strong></td>
                                    <td>
                                        <%#: Eval("Deadline") %>
                                        <%# (bool)Eval("IsOverdue") ? "<div><span class=\"uims-pill uims-pill-rejected\">Overdue</span></div>" : "" %>
                                    </td>
                                    <td><span class="uims-pill <%#: Eval("StatusCss") %>"><%#: Eval("Status") %></span></td>
                                    <td><%#: Eval("Attempts") %></td>
                                    <td>
                                        <strong><%#: Eval("Grade") %></strong>
                                        <div class="pe-muted"><%#: Eval("Criteria") %></div>
                                    </td>
                                    <td class="pe-feedback"><%#: Eval("Feedback") %></td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>
            <asp:Panel ID="pnlNoTasks" runat="server" Visible="false" CssClass="alert alert-info mt-3 mb-0">
                No tasks have been assigned to you yet.
            </asp:Panel>
            <p class="pe-muted mt-3 mb-0">Each task is graded out of its own maximum score set by your company supervisor.</p>
        </div>

        <%-- Submission and revision history --%>
        <div class="uims-card pe-section">
            <h3>Submissions &amp; revision history</h3>
            <div class="table-responsive">
                <table class="uims-table">
                    <thead>
                        <tr>
                            <th>Task</th>
                            <th>Attempt</th>
                            <th>Submitted</th>
                            <th>Outcome</th>
                            <th>Details</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptAttempts" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td><%#: Eval("TaskTitle") %></td>
                                    <td>#<%#: Eval("Attempt") %></td>
                                    <td><%#: Eval("SubmittedAt") %></td>
                                    <td><span class="uims-pill <%#: Eval("OutcomeCss") %>"><%#: Eval("Outcome") %></span></td>
                                    <td class="pe-feedback"><%#: Eval("Details") %></td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>
            <asp:Panel ID="pnlNoAttempts" runat="server" Visible="false" CssClass="alert alert-info mt-3 mb-0">
                You have not submitted any work yet. Submit tasks from <a href="<%: ResolveUrl("~/Pages/Student/MyTasks.aspx") %>">My Tasks</a>.
            </asp:Panel>
        </div>

        <%-- Training hours --%>
        <div class="uims-card pe-section">
            <h3>Training hours</h3>
            <div class="d-flex flex-wrap gap-4 mb-3">
                <div><div class="pe-muted">Approved</div><strong><asp:Literal ID="litHoursApproved" runat="server" /> h</strong></div>
                <div><div class="pe-muted">Pending approval</div><strong><asp:Literal ID="litHoursPending" runat="server" /> h</strong></div>
                <div><div class="pe-muted">Rejected</div><strong><asp:Literal ID="litHoursRejected" runat="server" /> h</strong></div>
            </div>
            <div class="table-responsive">
                <table class="uims-table">
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Hours</th>
                            <th>Description</th>
                            <th>Status</th>
                            <th>Reviewer note</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptHours" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td><%#: Eval("Date") %></td>
                                    <td><%#: Eval("Hours") %></td>
                                    <td><%#: Eval("Description") %></td>
                                    <td><span class="uims-pill <%#: Eval("StatusCss") %>"><%#: Eval("Status") %></span></td>
                                    <td><%#: Eval("Note") %></td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>
            <asp:Panel ID="pnlNoHours" runat="server" Visible="false" CssClass="alert alert-info mt-3 mb-0">
                No training hours have been recorded yet.
            </asp:Panel>
            <p class="pe-muted mt-3 mb-0">Only hours approved by your supervisor count toward your required hours. Completing a task does not approve its hours automatically.</p>
        </div>

        <%-- Completion and official report --%>
        <div class="uims-card pe-section">
            <h3>Internship completion &amp; official report</h3>

            <asp:Panel ID="pnlNotApproved" runat="server" Visible="false">
                <p class="mb-1"><asp:Literal ID="litCompletionStage" runat="server" Mode="Encode" /></p>
                <p class="pe-muted mb-0">Your final result and the official Internship Completion Report (PDF) will appear here after the University Internship Coordinator approves your internship completion.</p>
            </asp:Panel>

            <asp:Panel ID="pnlApproved" runat="server" Visible="false">
                <div class="alert alert-success">Your internship completion has been approved by the University Internship Coordinator.</div>
                <div class="row g-3 mb-3">
                    <div class="col-md-4"><div class="pe-muted">Final score</div><strong><asp:Literal ID="litFinalScore" runat="server" Mode="Encode" /></strong></div>
                    <div class="col-md-4"><div class="pe-muted">Result</div><strong><asp:Literal ID="litFinalResult" runat="server" Mode="Encode" /></strong></div>
                    <div class="col-md-4"><div class="pe-muted">Approved on</div><strong><asp:Literal ID="litApprovedAt" runat="server" Mode="Encode" /></strong></div>
                </div>
                <asp:HyperLink ID="lnkReport" runat="server" Visible="false" Target="_blank"
                               CssClass="btn btn-brand" Text="Download / print completion report (PDF)" />
                <asp:Panel ID="pnlReportPending" runat="server" Visible="false" CssClass="alert alert-info mb-0">
                    The official completion report is being prepared by the coordinator and will be available to download here soon.
                </asp:Panel>
            </asp:Panel>
        </div>

    </asp:Panel>

</asp:Content>
