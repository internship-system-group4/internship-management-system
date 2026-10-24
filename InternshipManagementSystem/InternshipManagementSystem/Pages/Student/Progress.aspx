<%@ Page Language="C#" MasterPageFile="~/Layout/Student.master" AutoEventWireup="true" CodeBehind="Progress.aspx.cs" Inherits="InternshipManagementSystem.Pages.StudentArea.Progress" Title="My Progress & Evaluation" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <style>
        .progress-intro { margin-bottom: 1.5rem; }
        .progress-intro h2 { font-size: 1.45rem; margin: 0 0 .3rem; }
        .progress-intro p, .progress-muted { color: var(--muted); }
        .progress-summary { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 1rem; margin-bottom: 1.25rem; }
        .progress-stat { margin: 0; }
        .progress-stat strong { display: block; font-size: 1.6rem; line-height: 1.2; color: var(--brand-text,var(--brand-dark)); }
        .progress-stat span { display: block; color: var(--muted); font-size: .84rem; margin-top: .3rem; }
        .progress-section-title { display: flex; justify-content: space-between; align-items: baseline; gap: 1rem; flex-wrap: wrap; }
        .progress-section-title h3 { margin: 0 0 1rem; }
        .progress-section-title a { font-size: .88rem; }
        .progress-task { border-top: 1px solid var(--line); padding: 1rem 0; }
        .progress-task:first-of-type { border-top: 0; padding-top: 0; }
        .progress-task:last-child { padding-bottom: 0; }
        .progress-task-head { display: flex; justify-content: space-between; gap: 1rem; flex-wrap: wrap; }
        .progress-task h4 { font-size: 1rem; margin: 0 0 .35rem; }
        .progress-task-meta { color: var(--muted); font-size: .85rem; }
        .progress-task-score { font-weight: 600; margin: .75rem 0; }
        .progress-history { margin: .5rem 0 0; padding: 0 0 0 1.25rem; border-left: 2px solid var(--line); list-style: none; }
        .progress-history li { padding: .3rem 0 .85rem; }
        .progress-history li:last-child { padding-bottom: 0; }
        .progress-history-head { display: flex; align-items: baseline; justify-content: space-between; flex-wrap: wrap; gap: .3rem 1rem; }
        .progress-history-head strong { font-size: .88rem; }
        .progress-history time, .progress-history small { color: var(--muted); font-size: .8rem; }
        .progress-history p, .progress-comment { white-space: pre-wrap; overflow-wrap: anywhere; margin: .25rem 0; font-size: .9rem; }
        .progress-hours-count { font-size: 1.3rem; font-weight: 700; color: var(--brand-text,var(--brand-dark)); }
        .progress-hours-count small { font-size: .85rem; font-weight: 400; color: var(--muted); }
        .progress-hours-note { margin: .7rem 0 1rem; font-size: .85rem; color: var(--muted); }
        .progress-result { display: flex; gap: 1rem; align-items: center; flex-wrap: wrap; }
        .progress-result strong { font-size: 1.3rem; }
        .progress-result-score { color: var(--muted); }
        @media (max-width: 700px) { .progress-summary { grid-template-columns: repeat(2, minmax(0, 1fr)); } }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="progress-intro">
        <h2><%: L.T("Student.Progress.MyProgressEvaluation") %></h2>
        <p class="mb-0"><%: L.T("Student.Progress.FollowYourTaskSubmissionsFeedbackApproved") %></p>
    </div>

    <asp:Panel ID="pnlNoPlacement" runat="server" Visible="false" CssClass="uims-card">
        <h3><%: L.T("Student.Progress.NoConfirmedInternshipYet") %></h3>
        <p class="progress-muted"><%: L.T("Student.Progress.YourProgressWillAppearAfterYou") %></p>
        <a class="btn btn-brand" href="<%: ResolveUrl("~/Pages/Student/MyApplications.aspx") %>"><%: L.T("Student.Progress.ViewMyApplications") %></a>
    </asp:Panel>

    <asp:Panel ID="pnlProgress" runat="server" Visible="false">
        <section class="uims-card" aria-label="<%: L.T("Student.Progress.InternshipPlacement") %>">
            <h3 class="mb-1"><asp:Literal ID="litPlacement" runat="server" /></h3>
            <p class="progress-muted mb-0"><asp:Literal ID="litCompany" runat="server" /></p>
        </section>

        <div class="progress-summary" aria-label="<%: L.T("Student.Progress.TaskProgressSummary") %>">
            <div class="uims-card progress-stat"><strong><asp:Literal ID="litTaskCount" runat="server" /></strong><span><%: L.T("Student.Progress.AssignedTasks") %></span></div>
            <div class="uims-card progress-stat"><strong><asp:Literal ID="litSubmittedCount" runat="server" /></strong><span><%: L.T("Student.Progress.TasksSubmitted") %></span></div>
            <div class="uims-card progress-stat"><strong><asp:Literal ID="litRevisionCount" runat="server" /></strong><span><%: L.T("Student.Progress.NeedRevision") %></span></div>
            <div class="uims-card progress-stat"><strong><asp:Literal ID="litGradedCount" runat="server" /></strong><span><%: L.T("Student.Progress.GradedTasks") %></span></div>
        </div>

        <section class="uims-card" aria-labelledby="taskHeading">
            <div class="progress-section-title">
                <h3 id="taskHeading"><%: L.T("Student.Progress.TasksAndEvaluations") %></h3>
                <a href="<%: ResolveUrl("~/Pages/Student/MyTasks.aspx") %>"><%: L.T("Student.Progress.GoToMyTasks") %></a>
            </div>
            <asp:Panel ID="pnlNoTasks" runat="server" Visible="false">
                <p class="progress-muted mb-0"><%: L.T("Student.Progress.NoTasksHaveBeenAssignedTo2") %></p>
            </asp:Panel>
            <asp:Repeater ID="rptTasks" runat="server">
                <ItemTemplate>
                    <article class="progress-task">
                        <div class="progress-task-head">
                            <div>
                                <h4><%#: Eval("Title") %></h4>
                                <div class="progress-task-meta"><%: L.T("Student.Progress.Deadline2") %> <%#: Eval("Deadline") %></div>
                            </div>
                            <span class='uims-pill <%# Eval("StatusClass") %>'><%#: L.Value("Ui", Eval("Status")) %></span>
                        </div>
                        <div class="progress-task-score"><%: L.T("Student.Progress.LatestGrade") %> <%#: Eval("Grade") %></div>
                        <ul class="progress-history" aria-label="<%: L.T("Student.Progress.SubmissionAndFeedbackHistory") %>">
                            <asp:Repeater ID="rptHistory" runat="server" DataSource='<%# Eval("History") %>'>
                                <ItemTemplate>
                                    <li>
                                        <div class="progress-history-head"><strong><%#: Eval("Label") %></strong><time><%#: Eval("Date") %></time></div>
                                        <p><%#: Eval("Detail") %></p>
                                        <small><%#: Eval("Meta") %></small>
                                    </li>
                                </ItemTemplate>
                            </asp:Repeater>
                        </ul>
                    </article>
                </ItemTemplate>
            </asp:Repeater>
        </section>

        <section class="uims-card" aria-labelledby="hoursHeading">
            <h3 id="hoursHeading"><%: L.T("Student.Progress.ApprovedTrainingHours") %></h3>
            <div class="progress-hours-count"><asp:Literal ID="litHours" runat="server" /> <small>/ <asp:Literal ID="litRequiredHours" runat="server" /> <%: L.T("Student.Progress.RequiredHours") %></small></div>
            <div id="hoursProgress" runat="server" class="progress d-flex mt-2" role="progressbar" aria-label="<%$ Resources:Student, Progress.ApprovedHoursProgress %>" aria-valuemin="0" aria-valuemax="100">
                <div id="hoursBar" runat="server" class="progress-bar btn-brand" style="width:0%"></div>
            </div>
            <p class="progress-hours-note"><asp:Literal ID="litHoursPercent" runat="server" /> <%: L.T("Student.Progress.Complete") %> <asp:Literal ID="litPendingHours" runat="server" /> <%: L.T("Student.Progress.ReportedHoursAwaitingReviewOnlyApproved") %></p>
            <div class="table-responsive">
                <table class="uims-table">
                    <thead><tr><th scope="col"><%: L.T("Student.Progress.WorkDate") %></th><th scope="col"><%: L.T("Student.Progress.ApprovedEntry") %></th><th scope="col"><%: L.T("Student.Progress.Hours") %></th></tr></thead>
                    <tbody>
                        <asp:Repeater ID="rptHours" runat="server">
                            <ItemTemplate><tr><td><%#: Eval("Date") %></td><td><%#: Eval("Description") %></td><td><%#: Eval("Hours") %></td></tr></ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>
            <asp:Panel ID="pnlNoHours" runat="server" Visible="false"><p class="progress-muted mt-2 mb-0"><%: L.T("Student.Progress.NoTrainingHoursHaveBeenApproved") %></p></asp:Panel>
        </section>

        <section class="uims-card" aria-labelledby="commentsHeading">
            <h3 id="commentsHeading"><%: L.T("Student.Progress.AcademicSupervisorFeedback") %></h3>
            <asp:Panel ID="pnlNoComments" runat="server" Visible="false"><p class="progress-muted mb-0"><%: L.T("Student.Progress.NoAcademicCommentsHaveBeenShared") %></p></asp:Panel>
            <asp:Repeater ID="rptComments" runat="server">
                <ItemTemplate><div class="border-top pt-2 mt-2"><small class="progress-muted"><%#: Eval("Date") %></small><p class="progress-comment mb-0"><%#: Eval("Text") %></p></div></ItemTemplate>
            </asp:Repeater>
        </section>

        <section class="uims-card" aria-labelledby="resultHeading">
            <h3 id="resultHeading"><%: L.T("Student.Progress.FinalResultAndCompletionReport") %></h3>
            <asp:Panel ID="pnlAdministrativeDecision" runat="server" Visible="false">
                <p><%: L.T("Student.Progress.CompletionReview") %> <strong><asp:Literal ID="litCompletionStatus" runat="server" /></strong></p>
                <p class="progress-muted"><asp:Literal ID="litCompletionNote" runat="server" /></p>
            </asp:Panel>
            <asp:Panel ID="pnlAwaitingResult" runat="server">
                <p class="progress-muted mb-0"><%: L.T("Student.Progress.YourCompletionDecisionAndPermittedEvaluation") %></p>
            </asp:Panel>
            <asp:Panel ID="pnlFinalResult" runat="server" Visible="false">
                <div class="progress-result"><strong><asp:Literal ID="litFinalResult" runat="server" /></strong></div>
                <asp:Panel ID="pnlApprovedDate" runat="server" Visible="false"><p class="progress-muted mt-2"><%: L.T("Student.Progress.ApprovedOn") %> <asp:Literal ID="litApprovedDate" runat="server" />.</p></asp:Panel>
                <asp:Panel ID="pnlFailedResult" runat="server" Visible="false"><p class="progress-muted mt-2"><%: L.T("Student.Progress.TheCoordinatorCompletedTheReviewInternship") %></p></asp:Panel>
                <asp:Panel ID="pnlReportReady" runat="server" Visible="false">
                    <asp:LinkButton ID="btnReport" runat="server" CssClass="btn btn-brand" Text="<%$ Resources:Student, Progress.ViewOrDownloadOfficialPDF %>" OnClick="btnReport_Click" CausesValidation="false" />
                    <p class="progress-muted small mt-2 mb-0"><%: L.T("Student.Progress.OpenThePDFToDownloadOr") %></p>
                </asp:Panel>
                <asp:Panel ID="pnlReportPending" runat="server" Visible="false"><p class="progress-muted mb-0"><%: L.T("Student.Progress.YourResultIsApprovedTheOfficial") %></p></asp:Panel>
            </asp:Panel>
            <asp:Literal ID="litReportError" runat="server" />
        </section>
    </asp:Panel>
</asp:Content>
