<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="CompletionReview.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.CompletionReview" Title="Final Completion Review" %>
<%@ Import Namespace="InternshipManagementSystem.Services" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/coordinator-monitoring.css") %>" />
    <link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/completion-review.css") %>" />
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="monitor-page completion-page">

<% if (!IsDetail) { %>
    <%-- ================= Queue: every placement and its completion stage ================= --%>
    <div class="monitor-heading">
        <div>
            <h2>Final Completion Review</h2>
            <p>Review both final evaluations and the university's requirements, then approve completion. Nothing is marked complete without this approval.</p>
        </div>
    </div>

    <% if (LoadError != null) { %><div class="monitor-error" role="alert"><%: LoadError %> <a href="CompletionReview.aspx">Retry</a></div><% } else { %>
    <div class="monitor-metrics">
        <div class="monitor-metric"><span>Ready for review</span><strong><%: CountWhere(r => r.IsReady) %></strong><small>Both final evaluations submitted</small></div>
        <div class="monitor-metric"><span>Awaiting evaluations</span><strong><%: CountWhere(r => !r.IsApproved && !r.IsReady) %></strong><small>Company or academic form missing</small></div>
        <div class="monitor-metric"><span>Approved</span><strong><%: CountWhere(r => r.IsApproved) %></strong><small>Report released to the student</small></div>
    </div>

    <section class="monitor-panel">
        <div class="monitor-panel-heading"><h3>Completion queue</h3><span><%: Queue.Count %> placements</span></div>
        <% if (Queue.Count == 0) { %><div class="monitor-empty">No confirmed placements yet.</div><% } else { %>
        <div class="monitor-table-scroll"><table class="monitor-table">
            <caption class="visually-hidden">Placements and their completion stage</caption>
            <thead><tr><th scope="col">Student</th><th scope="col">Company</th><th scope="col">Approved hours</th><th scope="col">Final evaluations</th><th scope="col">Stage</th><th scope="col"><span class="visually-hidden">Action</span></th></tr></thead>
            <tbody>
            <% foreach (var row in Queue) { %>
                <tr>
                    <td><strong><%: row.Overview.StudentName %></strong><small><%: row.Overview.StudentNumber %></small></td>
                    <td><%: row.Overview.Placement.CompanyName %><small><%: row.Overview.Placement.OpportunityTitle %></small></td>
                    <td><%: row.Overview.HoursText %><progress value="<%: row.Overview.HoursPercent %>" max="100" aria-label="Approved hours"><%: row.Overview.HoursPercent %>%</progress></td>
                    <td><small class="completion-flag <%: row.CompanySubmitted ? "is-ok" : "" %>">Company: <%: row.CompanySubmitted ? "submitted" : "not yet" %></small>
                        <small class="completion-flag <%: row.AcademicSubmitted ? "is-ok" : "" %>">Academic: <%: row.AcademicSubmitted ? "submitted" : "not yet" %></small></td>
                    <td><span class="<%: StageCss(row) %>"><%: row.StageText %></span></td>
                    <td><a class="completion-open" href="CompletionReview.aspx?id=<%: Server.UrlEncode(row.Overview.Placement.Id) %>"><%: row.IsReady ? "Review" : "View" %></a></td>
                </tr>
            <% } %>
            </tbody>
        </table></div>
        <% } %>
    </section>
    <% } %>

<% } else { %>
    <%-- ================= Review of one placement ================= --%>
    <a href="CompletionReview.aspx">&larr; Completion queue</a>

    <% if (LoadError != null) { %><div class="monitor-error" role="alert" style="margin-top:24px"><%: LoadError %></div><% } else {
           var row = Progress.Overview; var placement = row.Placement; var record = Progress.Completion; %>

    <div class="monitor-heading" style="margin-top:24px">
        <div><h2><%: row.StudentName %></h2><p><%: row.StudentNumber %> &middot; <%: row.Major %> &middot; <%: placement.CompanyName %></p></div>
        <% if (IsApproved) { %><span class="completion-pill is-done">Completion approved</span>
        <% } else if (record != null && record.Status == CompletionStatus.Rejected) { %><span class="completion-pill is-returned">Returned</span>
        <% } else if (Summary.CanApprove) { %><span class="completion-pill is-ready">Ready to approve</span>
        <% } else { %><span class="completion-pill">Requirements not met</span><% } %>
    </div>

    <% if (Message != null) { %><div class="<%: MessageIsError ? "monitor-error" : "completion-success" %>" role="status"><%: Message %></div><% } %>

    <section class="monitor-panel"><div class="monitor-panel-heading"><h3>Internship</h3><a href="PlacementDetails.aspx?id=<%: Server.UrlEncode(placement.Id) %>">Full progress &amp; history</a></div>
        <div class="monitor-panel-body"><dl class="monitor-profile">
            <div><dt>Opportunity</dt><dd><%: placement.OpportunityTitle %></dd></div>
            <div><dt>Company supervisor</dt><dd><%: Progress.CompanySupervisorName %></dd></div>
            <div><dt>Academic supervisor</dt><dd><%: Progress.AcademicSupervisorName %></dd></div>
            <div><dt>Training period</dt><dd><%: Time.DisplayDate(placement.StartDate) %> &ndash; <%: Time.DisplayDate(placement.EndDate) %></dd></div>
            <div><dt>Tasks graded</dt><dd><%: Summary.TasksGraded %> of <%: Summary.TasksTotal %></dd></div>
            <div><dt>Student email</dt><dd><%: row.Student == null ? "Profile unavailable" : row.Student.Email %></dd></div>
        </dl></div>
    </section>

    <%-- University requirements --%>
    <section class="monitor-panel"><div class="monitor-panel-heading"><h3>University requirements</h3><span>All must be met before approval</span></div>
        <ul class="completion-checks">
            <li class="<%: Summary.CompanySubmitted ? "is-ok" : "is-missing" %>"><span aria-hidden="true"><%: Summary.CompanySubmitted ? "✓" : "✕" %></span>
                <div><strong>Company final evaluation submitted</strong><small><%: Summary.CompanySubmitted ? "Submitted " + Time.Display(Progress.CompanyFinal.SubmittedAt) : (Progress.CompanyFinal == null ? "Not started by the company supervisor" : "Saved as a draft, not submitted yet") %></small></div></li>
            <li class="<%: Summary.AcademicSubmitted ? "is-ok" : "is-missing" %>"><span aria-hidden="true"><%: Summary.AcademicSubmitted ? "✓" : "✕" %></span>
                <div><strong>Academic final evaluation submitted</strong><small><%: Summary.AcademicSubmitted ? "Submitted " + Time.Display(Progress.AcademicFinal.SubmittedAt) : (Progress.AcademicFinal == null ? "Not started by the academic supervisor" : "Saved as a draft, not submitted yet") %></small></div></li>
            <li class="<%: Summary.HoursMet ? "is-ok" : "is-missing" %>"><span aria-hidden="true"><%: Summary.HoursMet ? "✓" : "✕" %></span>
                <div><strong>Required training hours approved</strong><small><%: Summary.ApprovedHours %> of <%: Summary.RequiredHours %> hours approved<%: row.PendingHours > 0 ? " · " + row.PendingHours + " h still awaiting approval" : "" %>. Only approved entries count.</small></div></li>
            <li class="<%: Summary.Passing ? "is-ok" : "is-missing" %>"><span aria-hidden="true"><%: Summary.Passing ? "✓" : "✕" %></span>
                <div><strong>Passing final result (<%: GradingPolicy.PassMarkPercent %>% or more)</strong><small><%: Summary.EvaluationsReady ? "Final score " + Percent(Summary.FinalPercent) : "Calculated once both final evaluations are submitted" %></small></div></li>
        </ul>
    </section>

    <%-- Both final evaluations (confidential: coordinator access only) --%>
    <div class="monitor-evaluation-grid">
        <section class="monitor-panel"><div class="monitor-panel-heading"><h3>Company final evaluation</h3><span>Confidential</span></div>
            <% if (!Summary.CompanySubmitted) { %><div class="monitor-empty">The company final evaluation has not been submitted.</div><% } else { var final = Progress.CompanyFinal; %>
            <div class="monitor-entry"><h4><%: Score(final.TotalScore, final.MaxScore) %> &middot; <%: Percent(Summary.CompanyPercent) %></h4><small><%: Progress.CompanySupervisorName %> &middot; <%: final.ReportedTotalHours %> h reported by the company</small>
                <table class="completion-criteria"><tbody>
                <% foreach (var c in Components(final.Components)) { %><tr><td><%: c.Name %></td><td><%: Score(c.Score, c.MaxScore) %></td><td><%: c.Weight %>%</td></tr><% } %>
                </tbody></table>
                <p><strong>Strengths:</strong> <%: Text(final.Strengths) %></p>
                <p><strong>Areas for improvement:</strong> <%: Text(final.AreasForImprovement) %></p>
                <p><strong>Overall comment:</strong> <%: Text(final.OverallComment) %></p>
            </div><% } %>
        </section>
        <section class="monitor-panel"><div class="monitor-panel-heading"><h3>Academic final evaluation</h3><span>Confidential</span></div>
            <% if (!Summary.AcademicSubmitted) { %><div class="monitor-empty">The academic final evaluation has not been submitted.</div><% } else { var final = Progress.AcademicFinal; %>
            <div class="monitor-entry"><h4><%: Score(final.TotalScore, final.MaxScore) %> &middot; <%: Percent(Summary.AcademicPercent) %></h4><small><%: Progress.AcademicSupervisorName %></small>
                <table class="completion-criteria"><tbody>
                <% foreach (var c in Components(final.Components)) { %><tr><td><%: c.Name %></td><td><%: Score(c.Score, c.MaxScore) %></td><td><%: c.Weight %>%</td></tr><% } %>
                </tbody></table>
                <p><strong>Academic comments:</strong> <%: Text(final.AcademicComments) %></p>
                <p><strong>Remarks on the company evaluation:</strong> <%: Text(final.CompanyEvaluationRemarks) %></p>
            </div><% } %>
        </section>
    </div>

    <%-- Final result --%>
    <section class="monitor-panel"><div class="monitor-panel-heading"><h3>Final result</h3><span>Calculated with the university grading policy</span></div>
        <div class="monitor-table-scroll"><table class="monitor-table">
            <thead><tr><th scope="col">Component</th><th scope="col">Score</th><th scope="col">Weight</th><th scope="col">Points</th></tr></thead>
            <tbody>
                <tr><td>Graded tasks</td><td><%: Percent(Summary.TaskPercent) %></td><td><%: GradingPolicy.TaskComponentWeight %>%</td><td><%: Weighted(Summary.TaskPercent, GradingPolicy.TaskComponentWeight) %></td></tr>
                <tr><td>Company final evaluation</td><td><%: Summary.CompanySubmitted ? Percent(Summary.CompanyPercent) : "—" %></td><td><%: GradingPolicy.CompanyFinalWeight %>%</td><td><%: Weighted(Summary.CompanyPercent, GradingPolicy.CompanyFinalWeight) %></td></tr>
                <tr><td>Academic final evaluation</td><td><%: Summary.AcademicSubmitted ? Percent(Summary.AcademicPercent) : "—" %></td><td><%: GradingPolicy.AcademicFinalWeight %>%</td><td><%: Weighted(Summary.AcademicPercent, GradingPolicy.AcademicFinalWeight) %></td></tr>
            </tbody>
        </table></div>
        <div class="completion-result">
            <div><span>Final score</span><strong><%: Percent(Summary.FinalPercent) %></strong></div>
            <div><span>Result</span><strong class="<%: Summary.Passing ? "is-pass" : "is-fail" %>"><%: Summary.EvaluationsReady ? Summary.Result : "Pending" %></strong></div>
            <p class="monitor-note">Pass mark <%: GradingPolicy.PassMarkPercent %>%. The student sees only the final score and result, never the two evaluation forms.</p>
        </div>
    </section>

    <%-- Decision / official documents --%>
    <section class="monitor-panel"><div class="monitor-panel-heading"><h3><%: IsApproved ? "Official documents" : "Coordinator decision" %></h3>
        <% if (record != null) { %><span>Last decision by <%: CoordinatorName(record.ReviewedByCoordinatorId) %></span><% } %></div>
        <div class="monitor-panel-body">
        <% if (IsApproved) { %>
            <p>Approved on <strong><%: Time.Display(record.ApprovedAt) %></strong> with a final result of <strong><%: record.Result %></strong> (<%: Percent(record.FinalScore) %>).</p>
            <% if (!string.IsNullOrWhiteSpace(record.CoordinatorNote)) { %><p class="monitor-note">Note on the report: <%: record.CoordinatorNote %></p><% } %>
            <div class="completion-actions">
                <a class="btn btn-brand" href="<%: ResolveUrl(PdfReportService.ReportUrl(record.Id)) %>" target="_blank" rel="noopener">Open completion report (PDF)</a>
                <a class="btn btn-outline-secondary" href="<%: ResolveUrl(PdfReportService.CertificateUrl(record.Id)) %>" target="_blank" rel="noopener">Print certificate (PDF)</a>
            </div>
            <p class="monitor-note">The report has been sent to the student. They can download and print it from their Progress page.</p>
        <% } else { %>
            <% if (record != null && record.Status == CompletionStatus.Rejected) { %><p class="monitor-note">Returned on the last review: <%: record.CoordinatorNote %></p><% } %>
            <% if (!Summary.CanApprove) { %><p class="monitor-note">Approval is locked until every requirement above is met. You can still return the completion with a note.</p><% } %>
        <% } %>
        <asp:Panel ID="pnlDecision" runat="server">
            <label for="<%= txtNote.ClientID %>" class="completion-label">Note to the student</label>
            <asp:TextBox ID="txtNote" runat="server" TextMode="MultiLine" Rows="3" MaxLength="1000" CssClass="form-control"
                placeholder="Optional when approving (shown on the report). Required when returning." />
            <div class="completion-actions">
                <asp:Button ID="btnApprove" runat="server" Text="Approve completion" CssClass="btn btn-brand" OnClick="Approve_Click"
                    OnClientClick="return confirm('Approve internship completion? The official report will be released to the student.');"  data-ui-action="approve" data-loading-label="Approving…"/>
                <asp:Button ID="btnReturn" runat="server" Text="Return to student" CssClass="btn btn-outline-secondary" OnClick="Return_Click"  data-ui-action="return" data-loading-label="Returning…"/>
            </div>
        </asp:Panel>
        </div>
    </section>
    <% } %>
<% } %>
</div>
</asp:Content>
