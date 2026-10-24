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
        <h2>My Progress &amp; Evaluation</h2>
        <p class="mb-0">Follow your task submissions, feedback, approved hours and final result.</p>
    </div>

    <asp:Panel ID="pnlNoPlacement" runat="server" Visible="false" CssClass="uims-card">
        <h3>No confirmed internship yet</h3>
        <p class="progress-muted">Your progress will appear after you confirm an accepted internship offer.</p>
        <a class="btn btn-brand" href="<%: ResolveUrl("~/Pages/Student/MyApplications.aspx") %>">View my applications</a>
    </asp:Panel>

    <asp:Panel ID="pnlProgress" runat="server" Visible="false">
        <section class="uims-card" aria-label="Internship placement">
            <h3 class="mb-1"><asp:Literal ID="litPlacement" runat="server" /></h3>
            <p class="progress-muted mb-0"><asp:Literal ID="litCompany" runat="server" /></p>
        </section>

        <div class="progress-summary" aria-label="Task progress summary">
            <div class="uims-card progress-stat"><strong><asp:Literal ID="litTaskCount" runat="server" /></strong><span>Assigned tasks</span></div>
            <div class="uims-card progress-stat"><strong><asp:Literal ID="litSubmittedCount" runat="server" /></strong><span>Tasks submitted</span></div>
            <div class="uims-card progress-stat"><strong><asp:Literal ID="litRevisionCount" runat="server" /></strong><span>Need revision</span></div>
            <div class="uims-card progress-stat"><strong><asp:Literal ID="litGradedCount" runat="server" /></strong><span>Graded tasks</span></div>
        </div>

        <section class="uims-card" aria-labelledby="taskHeading">
            <div class="progress-section-title">
                <h3 id="taskHeading">Tasks and evaluations</h3>
                <a href="<%: ResolveUrl("~/Pages/Student/MyTasks.aspx") %>">Go to My Tasks</a>
            </div>
            <asp:Panel ID="pnlNoTasks" runat="server" Visible="false">
                <p class="progress-muted mb-0">No tasks have been assigned to this internship yet.</p>
            </asp:Panel>
            <asp:Repeater ID="rptTasks" runat="server">
                <ItemTemplate>
                    <article class="progress-task">
                        <div class="progress-task-head">
                            <div>
                                <h4><%#: Eval("Title") %></h4>
                                <div class="progress-task-meta">Deadline: <%#: Eval("Deadline") %></div>
                            </div>
                            <span class='uims-pill <%# Eval("StatusClass") %>'><%#: Eval("Status") %></span>
                        </div>
                        <div class="progress-task-score">Latest grade: <%#: Eval("Grade") %></div>
                        <ul class="progress-history" aria-label="Submission and feedback history">
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
            <h3 id="hoursHeading">Approved training hours</h3>
            <div class="progress-hours-count"><asp:Literal ID="litHours" runat="server" /> <small>/ <asp:Literal ID="litRequiredHours" runat="server" /> required hours</small></div>
            <div id="hoursProgress" runat="server" class="progress d-flex mt-2" role="progressbar" aria-label="Approved hours progress" aria-valuemin="0" aria-valuemax="100">
                <div id="hoursBar" runat="server" class="progress-bar btn-brand" style="width:0%"></div>
            </div>
            <p class="progress-hours-note"><asp:Literal ID="litHoursPercent" runat="server" /> complete · <asp:Literal ID="litPendingHours" runat="server" /> reported hours awaiting review. Only approved hours count.</p>
            <div class="table-responsive">
                <table class="uims-table">
                    <thead><tr><th scope="col">Work date</th><th scope="col">Approved entry</th><th scope="col">Hours</th></tr></thead>
                    <tbody>
                        <asp:Repeater ID="rptHours" runat="server">
                            <ItemTemplate><tr><td><%#: Eval("Date") %></td><td><%#: Eval("Description") %></td><td><%#: Eval("Hours") %></td></tr></ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>
            <asp:Panel ID="pnlNoHours" runat="server" Visible="false"><p class="progress-muted mt-2 mb-0">No training hours have been approved yet.</p></asp:Panel>
        </section>

        <section class="uims-card" aria-labelledby="commentsHeading">
            <h3 id="commentsHeading">Academic supervisor feedback</h3>
            <asp:Panel ID="pnlNoComments" runat="server" Visible="false"><p class="progress-muted mb-0">No academic comments have been shared with you yet.</p></asp:Panel>
            <asp:Repeater ID="rptComments" runat="server">
                <ItemTemplate><div class="border-top pt-2 mt-2"><small class="progress-muted"><%#: Eval("Date") %></small><p class="progress-comment mb-0"><%#: Eval("Text") %></p></div></ItemTemplate>
            </asp:Repeater>
        </section>

        <section class="uims-card" aria-labelledby="resultHeading">
            <h3 id="resultHeading">Final result and completion report</h3>
            <asp:Panel ID="pnlAdministrativeDecision" runat="server" Visible="false">
                <p>Completion review: <strong><asp:Literal ID="litCompletionStatus" runat="server" /></strong></p>
                <p class="progress-muted"><asp:Literal ID="litCompletionNote" runat="server" /></p>
            </asp:Panel>
            <asp:Panel ID="pnlAwaitingResult" runat="server">
                <p class="progress-muted mb-0">Your completion decision and permitted evaluation result will appear after coordinator review. The completion PDF is released only after approval.</p>
            </asp:Panel>
            <asp:Panel ID="pnlFinalResult" runat="server" Visible="false">
                <div class="progress-result"><strong><asp:Literal ID="litFinalResult" runat="server" /></strong></div>
                <asp:Panel ID="pnlApprovedDate" runat="server" Visible="false"><p class="progress-muted mt-2">Approved on <asp:Literal ID="litApprovedDate" runat="server" />.</p></asp:Panel>
                <asp:Panel ID="pnlFailedResult" runat="server" Visible="false"><p class="progress-muted mt-2">The coordinator completed the review. Internship completion was not approved.</p></asp:Panel>
                <asp:Panel ID="pnlReportReady" runat="server" Visible="false">
                    <asp:LinkButton ID="btnReport" runat="server" CssClass="btn btn-brand" Text="View or download official PDF" OnClick="btnReport_Click" CausesValidation="false" />
                    <p class="progress-muted small mt-2 mb-0">Open the PDF to download or print it from your browser.</p>
                </asp:Panel>
                <asp:Panel ID="pnlReportPending" runat="server" Visible="false"><p class="progress-muted mb-0">Your result is approved. The official PDF has not been published yet.</p></asp:Panel>
            </asp:Panel>
            <asp:Literal ID="litReportError" runat="server" />
        </section>
    </asp:Panel>
</asp:Content>
