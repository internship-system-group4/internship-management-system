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
        <h2 class="mb-1"><%: L.T("Student.Progress.MyProgressEvaluation") %></h2>
        <p class="text-muted mb-0"><%: L.T("Student.Progress.YourTaskGradesSupervisorFeedbackApproved") %></p>
    </div>

    <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="alert alert-danger">
        <%: L.T("Student.Progress.YourProgressCouldNotBeLoaded") %>
        <div class="small mt-2"><asp:Literal ID="litErrorDetail" runat="server" Mode="Encode" /></div>
    </asp:Panel>

    <asp:Panel ID="pnlWarning" runat="server" Visible="false" CssClass="alert alert-warning">
        <%: L.T("Student.Progress.SomeSectionsCouldNotBeLoaded") %>
        <ul class="mb-0 mt-1">
            <asp:Repeater ID="rptProblems" runat="server">
                <ItemTemplate><li><%#: Container.DataItem %></li></ItemTemplate>
            </asp:Repeater>
        </ul>
    </asp:Panel>

    <asp:Panel ID="pnlNoPlacement" runat="server" Visible="false" CssClass="uims-card">
        <h3><%: L.T("Student.Progress.NoConfirmedInternshipYet") %></h3>
        <p class="text-muted mb-3"><%: L.T("Student.Progress.YourProgressAndEvaluationsWillAppear") %></p>
        <a class="btn btn-brand btn-sm" href="<%: ResolveUrl("~/Pages/Student/MyApplications.aspx") %>"><%: L.T("Student.Progress.GoToMyApplications") %></a>
    </asp:Panel>

    <asp:Panel ID="pnlContent" runat="server">

        <%-- Summary --%>
        <div class="row g-3 pe-section">
            <div class="col-sm-6 col-lg-3">
                <div class="uims-card pe-stat">
                    <div class="pe-label"><%: L.T("Student.Progress.ApprovedHours") %></div>
                    <div class="pe-value"><asp:Literal ID="litSumHours" runat="server" /></div>
                    <div class="progress mt-2" style="height: 6px;">
                        <div id="hoursBar" runat="server" class="progress-bar" role="progressbar"
                             style="width: 0%; background-color: var(--brand);"
                             aria-valuemin="0" aria-valuemax="100" aria-label="<%$ Resources:Student, Progress.ApprovedHoursProgress %>"></div>
                    </div>
                    <div class="pe-muted mt-1"><asp:Literal ID="litSumHoursPercent" runat="server" /><%: L.T("Student.Progress.OfRequiredHours") %></div>
                </div>
            </div>
            <div class="col-sm-6 col-lg-3">
                <div class="uims-card pe-stat">
                    <div class="pe-label"><%: L.T("Student.Progress.TasksGraded") %></div>
                    <div class="pe-value"><asp:Literal ID="litSumTasks" runat="server" /></div>
                    <div class="pe-muted"><%: L.T("Student.Progress.GradedOutOfAssigned") %></div>
                </div>
            </div>
            <div class="col-sm-6 col-lg-3">
                <div class="uims-card pe-stat">
                    <div class="pe-label"><%: L.T("Student.Progress.OpenRevisions") %></div>
                    <div class="pe-value"><asp:Literal ID="litSumRevisions" runat="server" /></div>
                    <div class="pe-muted"><%: L.T("Student.Progress.TasksWaitingForYourResubmission") %></div>
                </div>
            </div>
            <div class="col-sm-6 col-lg-3">
                <div class="uims-card pe-stat">
                    <div class="pe-label"><%: L.T("Student.Progress.TaskGradeAverage") %></div>
                    <div class="pe-value"><asp:Literal ID="litSumAverage" runat="server" /></div>
                    <div class="pe-muted"><%: L.T("Student.Progress.WeightedByEachTaskSWeight") %></div>
                </div>
            </div>
        </div>

        <%-- Internship details --%>
        <div class="uims-card pe-section">
            <h3><%: L.T("Student.Progress.MyInternship") %></h3>
            <div class="row g-3">
                <div class="col-md-4"><div class="pe-muted"><%: L.T("Student.Progress.Opportunity") %></div><asp:Literal ID="litOpportunity" runat="server" Mode="Encode" /></div>
                <div class="col-md-4"><div class="pe-muted"><%: L.T("Student.Progress.Company") %></div><asp:Literal ID="litCompany" runat="server" Mode="Encode" /></div>
                <div class="col-md-4"><div class="pe-muted"><%: L.T("Student.Progress.CompanySupervisor") %></div><asp:Literal ID="litSupervisor" runat="server" Mode="Encode" /></div>
                <div class="col-md-4"><div class="pe-muted"><%: L.T("Student.Progress.TrainingPeriod") %></div><asp:Literal ID="litDates" runat="server" Mode="Encode" /></div>
                <div class="col-md-4"><div class="pe-muted"><%: L.T("Student.Progress.PlacementStatus") %></div><asp:Literal ID="litPlacementStatus" runat="server" Mode="Encode" /></div>
            </div>
        </div>

        <%-- Task grades and feedback --%>
        <div class="uims-card pe-section">
            <h3><%: L.T("Student.Progress.TaskEvaluationsFeedback") %></h3>
            <div class="table-responsive">
                <table class="uims-table">
                    <thead>
                        <tr>
                            <th><%: L.T("Student.Progress.Task") %></th>
                            <th><%: L.T("Student.Progress.Deadline") %></th>
                            <th><%: L.T("Student.Progress.Status") %></th>
                            <th><%: L.T("Student.Progress.Attempts") %></th>
                            <th><%: L.T("Student.Progress.Grade") %></th>
                            <th><%: L.T("Student.Progress.SupervisorFeedback") %></th>
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
                <%: L.T("Student.Progress.NoTasksHaveBeenAssignedTo") %>
            </asp:Panel>
            <p class="pe-muted mt-3 mb-0"><%: L.T("Student.Progress.EachTaskIsGradedOutOf") %></p>
        </div>

        <%-- Submission and revision history --%>
        <div class="uims-card pe-section">
            <h3><%: L.T("Student.Progress.SubmissionsRevisionHistory") %></h3>
            <div class="table-responsive">
                <table class="uims-table">
                    <thead>
                        <tr>
                            <th><%: L.T("Student.Progress.Task") %></th>
                            <th><%: L.T("Student.Progress.Attempt") %></th>
                            <th><%: L.T("Student.Progress.Submitted") %></th>
                            <th><%: L.T("Student.Progress.Outcome") %></th>
                            <th><%: L.T("Student.Progress.Details") %></th>
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
                <%: L.T("Student.Progress.YouHaveNotSubmittedAnyWork") %> <a href="<%: ResolveUrl("~/Pages/Student/MyTasks.aspx") %>"><%: L.T("Student.Progress.MyTasks") %></a>.
            </asp:Panel>
        </div>

        <%-- Training hours --%>
        <div class="uims-card pe-section">
            <h3><%: L.T("Student.Progress.TrainingHours") %></h3>
            <div class="d-flex flex-wrap gap-4 mb-3">
                <div><div class="pe-muted"><%: L.T("Student.Progress.Approved") %></div><strong><asp:Literal ID="litHoursApproved" runat="server" /> h</strong></div>
                <div><div class="pe-muted"><%: L.T("Student.Progress.PendingApproval") %></div><strong><asp:Literal ID="litHoursPending" runat="server" /> h</strong></div>
                <div><div class="pe-muted"><%: L.T("Student.Progress.Rejected") %></div><strong><asp:Literal ID="litHoursRejected" runat="server" /> h</strong></div>
            </div>
            <div class="table-responsive">
                <table class="uims-table">
                    <thead>
                        <tr>
                            <th><%: L.T("Student.Progress.Date") %></th>
                            <th><%: L.T("Student.Progress.Hours") %></th>
                            <th><%: L.T("Student.Progress.Description") %></th>
                            <th><%: L.T("Student.Progress.Status") %></th>
                            <th><%: L.T("Student.Progress.ReviewerNote") %></th>
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
                <%: L.T("Student.Progress.NoTrainingHoursHaveBeenRecorded") %>
            </asp:Panel>
            <p class="pe-muted mt-3 mb-0"><%: L.T("Student.Progress.OnlyHoursApprovedByYourSupervisor") %></p>
        </div>

        <%-- Completion and official report --%>
        <div class="uims-card pe-section">
            <h3><%: L.T("Student.Progress.InternshipCompletionOfficialReport") %></h3>

            <asp:Panel ID="pnlNotApproved" runat="server" Visible="false">
                <p class="mb-1"><asp:Literal ID="litCompletionStage" runat="server" Mode="Encode" /></p>
                <p class="pe-muted mb-0"><%: L.T("Student.Progress.YourFinalResultAndTheOfficial") %></p>
            </asp:Panel>

            <asp:Panel ID="pnlApproved" runat="server" Visible="false">
                <div class="alert alert-success"><%: L.T("Student.Progress.YourInternshipCompletionHasBeenApproved") %></div>
                <div class="row g-3 mb-3">
                    <div class="col-md-4"><div class="pe-muted"><%: L.T("Student.Progress.FinalScore") %></div><strong><asp:Literal ID="litFinalScore" runat="server" Mode="Encode" /></strong></div>
                    <div class="col-md-4"><div class="pe-muted"><%: L.T("Student.Progress.Result") %></div><strong><asp:Literal ID="litFinalResult" runat="server" Mode="Encode" /></strong></div>
                    <div class="col-md-4"><div class="pe-muted"><%: L.T("Student.Progress.ApprovedOn") %></div><strong><asp:Literal ID="litApprovedAt" runat="server" Mode="Encode" /></strong></div>
                </div>
                <asp:HyperLink ID="lnkReport" runat="server" Visible="false" Target="_blank"
                               CssClass="btn btn-brand" Text="<%$ Resources:Student, Progress.DownloadPrintCompletionReportPDF %>" />
                <asp:Panel ID="pnlReportPending" runat="server" Visible="false" CssClass="alert alert-info mb-0">
                    <%: L.T("Student.Progress.TheOfficialCompletionReportIsBeing") %>
                </asp:Panel>
            </asp:Panel>
        </div>

    </asp:Panel>

</asp:Content>
