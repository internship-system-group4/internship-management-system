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
            <h2><%: L.T("Coordinator.CompletionReview.FinalCompletionReview") %></h2>
            <p><%: L.T("Coordinator.CompletionReview.ReviewBothFinalEvaluationsAndThe") %></p>
        </div>
    </div>

    <% if (LoadError != null) { %><div class="monitor-error" role="alert"><%: LoadError %> <a href="CompletionReview.aspx"><%: L.T("Coordinator.CompletionReview.Retry") %></a></div><% } else { %>
    <div class="monitor-metrics">
        <div class="monitor-metric"><span><%: L.T("Coordinator.CompletionReview.ReadyForReview") %></span><strong><%: CountWhere(r => r.IsReady) %></strong><small><%: L.T("Coordinator.CompletionReview.BothFinalEvaluationsSubmitted") %></small></div>
        <div class="monitor-metric"><span><%: L.T("Coordinator.CompletionReview.AwaitingEvaluations") %></span><strong><%: CountWhere(r => !r.IsApproved && !r.IsReady) %></strong><small><%: L.T("Coordinator.CompletionReview.CompanyOrAcademicFormMissing") %></small></div>
        <div class="monitor-metric"><span><%: L.T("Coordinator.CompletionReview.Approved") %></span><strong><%: CountWhere(r => r.IsApproved) %></strong><small><%: L.T("Coordinator.CompletionReview.ReportReleasedToTheStudent") %></small></div>
    </div>

    <section class="monitor-panel">
        <div class="monitor-panel-heading"><h3><%: L.T("Coordinator.CompletionReview.CompletionQueue") %></h3><span><%: Queue.Count %> <%: L.T("Coordinator.CompletionReview.Placements") %></span></div>
        <% if (Queue.Count == 0) { %><div class="monitor-empty"><%: L.T("Coordinator.CompletionReview.NoConfirmedPlacementsYet") %></div><% } else { %>
        <div class="monitor-table-scroll"><table class="monitor-table">
            <caption class="visually-hidden"><%: L.T("Coordinator.CompletionReview.PlacementsAndTheirCompletionStage") %></caption>
            <thead><tr><th scope="col"><%: L.T("Coordinator.CompletionReview.Student") %></th><th scope="col"><%: L.T("Coordinator.CompletionReview.Company") %></th><th scope="col"><%: L.T("Coordinator.CompletionReview.ApprovedHours") %></th><th scope="col"><%: L.T("Coordinator.CompletionReview.FinalEvaluations") %></th><th scope="col"><%: L.T("Coordinator.CompletionReview.Stage") %></th><th scope="col"><span class="visually-hidden"><%: L.T("Coordinator.CompletionReview.Action") %></span></th></tr></thead>
            <tbody>
            <% foreach (var row in Queue) { %>
                <tr>
                    <td><strong><%: row.Overview.StudentName %></strong><small><%: row.Overview.StudentNumber %></small></td>
                    <td><%: row.Overview.Placement.CompanyName %><small><%: row.Overview.Placement.OpportunityTitle %></small></td>
                    <td><%: row.Overview.HoursText %><progress value="<%: row.Overview.HoursPercent %>" max="100" aria-label="<%: L.T("Coordinator.CompletionReview.ApprovedHours") %>"><%: row.Overview.HoursPercent %>%</progress></td>
                    <td><small class="completion-flag <%: row.CompanySubmitted ? "is-ok" : "" %>"><%: L.T("Coordinator.CompletionReview.Company2") %> <%: row.CompanySubmitted ? "submitted" : "not yet" %></small>
                        <small class="completion-flag <%: row.AcademicSubmitted ? "is-ok" : "" %>"><%: L.T("Coordinator.CompletionReview.Academic") %> <%: row.AcademicSubmitted ? "submitted" : "not yet" %></small></td>
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
    <a href="CompletionReview.aspx"><%: L.T("Coordinator.CompletionReview.CompletionQueue2") %></a>

    <% if (LoadError != null) { %><div class="monitor-error" role="alert" style="margin-top:24px"><%: LoadError %></div><% } else {
           var row = Progress.Overview; var placement = row.Placement; var record = Progress.Completion; %>

    <div class="monitor-heading" style="margin-top:24px">
        <div><h2><%: row.StudentName %></h2><p><%: row.StudentNumber %> &middot; <%: row.Major %> &middot; <%: placement.CompanyName %></p></div>
        <% if (IsApproved) { %><span class="completion-pill is-done"><%: L.T("Coordinator.CompletionReview.CompletionApproved") %></span>
        <% } else if (record != null && record.Status == CompletionStatus.Rejected) { %><span class="completion-pill is-returned"><%: L.T("Coordinator.CompletionReview.Returned") %></span>
        <% } else if (Summary.CanApprove) { %><span class="completion-pill is-ready"><%: L.T("Coordinator.CompletionReview.ReadyToApprove") %></span>
        <% } else { %><span class="completion-pill"><%: L.T("Coordinator.CompletionReview.RequirementsNotMet") %></span><% } %>
    </div>

    <% if (Message != null) { %><div class="<%: MessageIsError ? "monitor-error" : "completion-success" %>" role="status"><%: Message %></div><% } %>

    <section class="monitor-panel"><div class="monitor-panel-heading"><h3><%: L.T("Coordinator.CompletionReview.Internship") %></h3><a href="PlacementDetails.aspx?id=<%: Server.UrlEncode(placement.Id) %>"><%: L.T("Coordinator.CompletionReview.FullProgressHistory") %></a></div>
        <div class="monitor-panel-body"><dl class="monitor-profile">
            <div><dt><%: L.T("Coordinator.CompletionReview.Opportunity") %></dt><dd><%: placement.OpportunityTitle %></dd></div>
            <div><dt><%: L.T("Coordinator.CompletionReview.CompanySupervisor") %></dt><dd><%: Progress.CompanySupervisorName %></dd></div>
            <div><dt><%: L.T("Coordinator.CompletionReview.AcademicSupervisor") %></dt><dd><%: Progress.AcademicSupervisorName %></dd></div>
            <div><dt><%: L.T("Coordinator.CompletionReview.TrainingPeriod") %></dt><dd><%: Time.DisplayDate(placement.StartDate) %> &ndash; <%: Time.DisplayDate(placement.EndDate) %></dd></div>
            <div><dt><%: L.T("Coordinator.CompletionReview.TasksGraded") %></dt><dd><%: Summary.TasksGraded %> <%: L.T("Coordinator.CompletionReview.Of") %> <%: Summary.TasksTotal %></dd></div>
            <div><dt><%: L.T("Coordinator.CompletionReview.StudentEmail") %></dt><dd><%: row.Student == null ? "Profile unavailable" : row.Student.Email %></dd></div>
        </dl></div>
    </section>

    <%-- University requirements --%>
    <section class="monitor-panel"><div class="monitor-panel-heading"><h3><%: L.T("Coordinator.CompletionReview.UniversityRequirements") %></h3><span><%: L.T("Coordinator.CompletionReview.AllMustBeMetBeforeApproval") %></span></div>
        <ul class="completion-checks">
            <li class="<%: Summary.CompanySubmitted ? "is-ok" : "is-missing" %>"><span aria-hidden="true"><%: Summary.CompanySubmitted ? "✓" : "✕" %></span>
                <div><strong><%: L.T("Coordinator.CompletionReview.CompanyFinalEvaluationSubmitted") %></strong><small><%: Summary.CompanySubmitted ? "Submitted " + Time.Display(Progress.CompanyFinal.SubmittedAt) : (Progress.CompanyFinal == null ? "Not started by the company supervisor" : "Saved as a draft, not submitted yet") %></small></div></li>
            <li class="<%: Summary.AcademicSubmitted ? "is-ok" : "is-missing" %>"><span aria-hidden="true"><%: Summary.AcademicSubmitted ? "✓" : "✕" %></span>
                <div><strong><%: L.T("Coordinator.CompletionReview.AcademicFinalEvaluationSubmitted") %></strong><small><%: Summary.AcademicSubmitted ? "Submitted " + Time.Display(Progress.AcademicFinal.SubmittedAt) : (Progress.AcademicFinal == null ? "Not started by the academic supervisor" : "Saved as a draft, not submitted yet") %></small></div></li>
            <li class="<%: Summary.HoursMet ? "is-ok" : "is-missing" %>"><span aria-hidden="true"><%: Summary.HoursMet ? "✓" : "✕" %></span>
                <div><strong><%: L.T("Coordinator.CompletionReview.RequiredTrainingHoursApproved") %></strong><small><%: Summary.ApprovedHours %> <%: L.T("Coordinator.CompletionReview.Of") %> <%: Summary.RequiredHours %> <%: L.T("Coordinator.CompletionReview.HoursApproved") %><%: row.PendingHours > 0 ? " · " + row.PendingHours + " h still awaiting approval" : "" %><%: L.T("Coordinator.CompletionReview.OnlyApprovedEntriesCount") %></small></div></li>
            <li class="<%: Summary.Passing ? "is-ok" : "is-missing" %>"><span aria-hidden="true"><%: Summary.Passing ? "✓" : "✕" %></span>
                <div><strong><%: L.T("Coordinator.CompletionReview.PassingFinalResult") %><%: GradingPolicy.PassMarkPercent %><%: L.T("Coordinator.CompletionReview.OrMore") %></strong><small><%: Summary.EvaluationsReady ? "Final score " + Percent(Summary.FinalPercent) : "Calculated once both final evaluations are submitted" %></small></div></li>
        </ul>
    </section>

    <%-- Both final evaluations (confidential: coordinator access only) --%>
    <div class="monitor-evaluation-grid">
        <section class="monitor-panel"><div class="monitor-panel-heading"><h3><%: L.T("Coordinator.CompletionReview.CompanyFinalEvaluation") %></h3><span><%: L.T("Coordinator.CompletionReview.Confidential") %></span></div>
            <% if (!Summary.CompanySubmitted) { %><div class="monitor-empty"><%: L.T("Coordinator.CompletionReview.TheCompanyFinalEvaluationHasNot") %></div><% } else { var final = Progress.CompanyFinal; %>
            <div class="monitor-entry"><h4><%: Score(final.TotalScore, final.MaxScore) %> &middot; <%: Percent(Summary.CompanyPercent) %></h4><small><%: Progress.CompanySupervisorName %> &middot; <%: final.ReportedTotalHours %> <%: L.T("Coordinator.CompletionReview.HReportedByTheCompany") %></small>
                <table class="completion-criteria"><tbody>
                <% foreach (var c in Components(final.Components)) { %><tr><td><%: c.Name %></td><td><%: Score(c.Score, c.MaxScore) %></td><td><%: c.Weight %>%</td></tr><% } %>
                </tbody></table>
                <p><strong><%: L.T("Coordinator.CompletionReview.Strengths") %></strong> <%: Text(final.Strengths) %></p>
                <p><strong><%: L.T("Coordinator.CompletionReview.AreasForImprovement") %></strong> <%: Text(final.AreasForImprovement) %></p>
                <p><strong><%: L.T("Coordinator.CompletionReview.OverallComment") %></strong> <%: Text(final.OverallComment) %></p>
            </div><% } %>
        </section>
        <section class="monitor-panel"><div class="monitor-panel-heading"><h3><%: L.T("Coordinator.CompletionReview.AcademicFinalEvaluation") %></h3><span><%: L.T("Coordinator.CompletionReview.Confidential") %></span></div>
            <% if (!Summary.AcademicSubmitted) { %><div class="monitor-empty"><%: L.T("Coordinator.CompletionReview.TheAcademicFinalEvaluationHasNot") %></div><% } else { var final = Progress.AcademicFinal; %>
            <div class="monitor-entry"><h4><%: Score(final.TotalScore, final.MaxScore) %> &middot; <%: Percent(Summary.AcademicPercent) %></h4><small><%: Progress.AcademicSupervisorName %></small>
                <table class="completion-criteria"><tbody>
                <% foreach (var c in Components(final.Components)) { %><tr><td><%: c.Name %></td><td><%: Score(c.Score, c.MaxScore) %></td><td><%: c.Weight %>%</td></tr><% } %>
                </tbody></table>
                <p><strong><%: L.T("Coordinator.CompletionReview.AcademicComments") %></strong> <%: Text(final.AcademicComments) %></p>
                <p><strong><%: L.T("Coordinator.CompletionReview.RemarksOnTheCompanyEvaluation") %></strong> <%: Text(final.CompanyEvaluationRemarks) %></p>
            </div><% } %>
        </section>
    </div>

    <%-- Final result --%>
    <section class="monitor-panel"><div class="monitor-panel-heading"><h3><%: L.T("Coordinator.CompletionReview.FinalResult") %></h3><span><%: L.T("Coordinator.CompletionReview.CalculatedWithTheUniversityGradingPolicy") %></span></div>
        <div class="monitor-table-scroll"><table class="monitor-table">
            <thead><tr><th scope="col"><%: L.T("Coordinator.CompletionReview.Component") %></th><th scope="col"><%: L.T("Coordinator.CompletionReview.Score") %></th><th scope="col"><%: L.T("Coordinator.CompletionReview.Weight") %></th><th scope="col"><%: L.T("Coordinator.CompletionReview.Points") %></th></tr></thead>
            <tbody>
                <tr><td><%: L.T("Coordinator.CompletionReview.GradedTasks") %></td><td><%: Percent(Summary.TaskPercent) %></td><td><%: GradingPolicy.TaskComponentWeight %>%</td><td><%: Weighted(Summary.TaskPercent, GradingPolicy.TaskComponentWeight) %></td></tr>
                <tr><td><%: L.T("Coordinator.CompletionReview.CompanyFinalEvaluation") %></td><td><%: Summary.CompanySubmitted ? Percent(Summary.CompanyPercent) : "—" %></td><td><%: GradingPolicy.CompanyFinalWeight %>%</td><td><%: Weighted(Summary.CompanyPercent, GradingPolicy.CompanyFinalWeight) %></td></tr>
                <tr><td><%: L.T("Coordinator.CompletionReview.AcademicFinalEvaluation") %></td><td><%: Summary.AcademicSubmitted ? Percent(Summary.AcademicPercent) : "—" %></td><td><%: GradingPolicy.AcademicFinalWeight %>%</td><td><%: Weighted(Summary.AcademicPercent, GradingPolicy.AcademicFinalWeight) %></td></tr>
            </tbody>
        </table></div>
        <div class="completion-result">
            <div><span><%: L.T("Coordinator.CompletionReview.FinalScore") %></span><strong><%: Percent(Summary.FinalPercent) %></strong></div>
            <div><span><%: L.T("Coordinator.CompletionReview.Result") %></span><strong class="<%: Summary.Passing ? "is-pass" : "is-fail" %>"><%: Summary.EvaluationsReady ? Summary.Result : "Pending" %></strong></div>
            <p class="monitor-note"><%: L.T("Coordinator.CompletionReview.PassMark") %> <%: GradingPolicy.PassMarkPercent %><%: L.T("Coordinator.CompletionReview.TheStudentSeesOnlyTheFinal") %></p>
        </div>
    </section>

    <%-- Decision / official documents --%>
    <section class="monitor-panel"><div class="monitor-panel-heading"><h3><%: IsApproved ? "Official documents" : "Coordinator decision" %></h3>
        <% if (record != null) { %><span><%: L.T("Coordinator.CompletionReview.LastDecisionBy") %> <%: CoordinatorName(record.ReviewedByCoordinatorId) %></span><% } %></div>
        <div class="monitor-panel-body">
        <% if (IsApproved) { %>
            <p><%: L.T("Coordinator.CompletionReview.ApprovedOn") %> <strong><%: Time.Display(record.ApprovedAt) %></strong> <%: L.T("Coordinator.CompletionReview.WithAFinalResultOf") %> <strong><%: record.Result %></strong> (<%: Percent(record.FinalScore) %>).</p>
            <% if (!string.IsNullOrWhiteSpace(record.CoordinatorNote)) { %><p class="monitor-note"><%: L.T("Coordinator.CompletionReview.NoteOnTheReport") %> <%: record.CoordinatorNote %></p><% } %>
            <div class="completion-actions">
                <a class="btn btn-brand" href="<%: ResolveUrl(PdfReportService.ReportUrl(record.Id)) %>" target="_blank" rel="noopener"><%: L.T("Coordinator.CompletionReview.OpenCompletionReportPDF") %></a>
                <a class="btn btn-outline-secondary" href="<%: ResolveUrl(PdfReportService.CertificateUrl(record.Id)) %>" target="_blank" rel="noopener"><%: L.T("Coordinator.CompletionReview.PrintCertificatePDF") %></a>
            </div>
            <p class="monitor-note"><%: L.T("Coordinator.CompletionReview.TheReportHasBeenSentTo") %></p>
        <% } else { %>
            <% if (record != null && record.Status == CompletionStatus.Rejected) { %><p class="monitor-note"><%: L.T("Coordinator.CompletionReview.ReturnedOnTheLastReview") %> <%: record.CoordinatorNote %></p><% } %>
            <% if (!Summary.CanApprove) { %><p class="monitor-note"><%: L.T("Coordinator.CompletionReview.ApprovalIsLockedUntilEveryRequirement") %></p><% } %>
        <% } %>
        <asp:Panel ID="pnlDecision" runat="server">
            <label for="<%= txtNote.ClientID %>" class="completion-label"><%: L.T("Coordinator.CompletionReview.NoteToTheStudent") %></label>
            <asp:TextBox ID="txtNote" runat="server" TextMode="MultiLine" Rows="3" MaxLength="1000" CssClass="form-control"
                placeholder="<%$ Resources:Coordinator, CompletionReview.OptionalWhenApprovingShownOnThe %>" />
            <div class="completion-actions">
                <asp:Button ID="btnApprove" runat="server" Text="<%$ Resources:Coordinator, CompletionReview.ApproveCompletion %>" CssClass="btn btn-brand" OnClick="Approve_Click"
                    OnClientClick="return confirm('Approve internship completion? The official report will be released to the student.');"  data-ui-action="approve" data-loading-label="Approving…"/>
                <asp:Button ID="btnReturn" runat="server" Text="<%$ Resources:Coordinator, CompletionReview.ReturnToStudent %>" CssClass="btn btn-outline-secondary" OnClick="Return_Click"  data-ui-action="return" data-loading-label="Returning…"/>
            </div>
        </asp:Panel>
        </div>
    </section>
    <% } %>
<% } %>
</div>
</asp:Content>
