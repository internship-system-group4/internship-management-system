<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="CompletionReview.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.CompletionReview" Title="Final Completion Review" %>
<%@ Import Namespace="InternshipManagementSystem.Services" %>
<%@ Import Namespace="InternshipManagementSystem.Data" %>
<%-- ===================================================================
     Final Completion Review  -  Owner: Ahmad  -  Cards A10 - A14
     Queue (no ?id) and the review of one internship (?id={placementId}).
     The review shows only what the decision needs: requirements, scores,
     internship type and the decision. Full history, task evidence and the
     evaluation comments live on the progress page (PlacementDetails.aspx).
     Final evaluations shown here are confidential: coordinator only.
     =================================================================== --%>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <script>document.documentElement.classList.add('rv-js');setTimeout(function(){if(!window.UimsReview)document.documentElement.classList.remove('rv-js');},2500);</script>
    <link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/review-system.css?v=20261024-theme-7") %>" />
    <link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/completion-review.css?v=20261024-theme-7") %>" />
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="rv-scope cr-page students-page dir-page">

<% if (!IsDetail) { %>
    <%-- ================= Queue ================= --%>
    <header class="dir-head">
        <div>
            <div class="dir-crumb"><%: L.T("Coordinator.CompletionReview.Crumb") %></div>
            <h2><%: L.T("Coordinator.CompletionReview.FinalCompletionReview") %></h2>
            <p><%: L.T("Coordinator.Review.QueueIntro") %></p>
        </div>
        <% if (LoadError == null && Queue != null && Queue.Count > 0) { %>
        <a class="btn btn-brand dir-add" href="CompletionReview.aspx?export=xlsx" download data-ui-action="export"><span data-ui-icon="download" aria-hidden="true"></span> <%: L.T("Coordinator.Export.Button") %></a>
        <% } %>
    </header>
    <% if (Message != null) { %><div class="alert alert-danger" role="alert"><%: Message %></div><% } %>

    <% if (LoadError != null) { %>
        <div class="alert alert-danger d-flex flex-wrap align-items-center gap-2" role="alert"><%: LoadError %> <a class="dir-btn" href="CompletionReview.aspx"><%: L.T("Coordinator.CompletionReview.Retry") %></a></div>
    <% } else { %>
    <ul class="dir-stats">
        <li style="--dir-i:0"><span class="dir-stat-icon is-success" data-ui-icon="approved" aria-hidden="true"></span><div><span class="dir-label"><%: L.T("Coordinator.Review.StatusReady") %></span><strong class="rv-num"><%: CountStatus(CompletionQueueRow.ReviewReady) %></strong><small><%: L.T("Coordinator.Review.MetricReady") %></small></div></li>
        <li style="--dir-i:1"><span class="dir-stat-icon is-warning" data-ui-icon="warning" aria-hidden="true"></span><div><span class="dir-label"><%: L.T("Coordinator.Review.StatusCorrections") %></span><strong class="rv-num"><%: CountStatus(CompletionQueueRow.ReviewCorrections) %></strong><small><%: L.T("Coordinator.Review.MetricCorrections") %></small></div></li>
        <li style="--dir-i:2"><span class="dir-stat-icon" data-ui-icon="clock" aria-hidden="true"></span><div><span class="dir-label"><%: L.T("Coordinator.Review.StatusAwaiting") %></span><strong class="rv-num"><%: CountStatus(CompletionQueueRow.ReviewAwaitingEvaluations) %></strong><small><%: L.T("Coordinator.Review.MetricAwaiting") %></small></div></li>
        <li style="--dir-i:3"><span class="dir-stat-icon is-success" data-ui-icon="study" aria-hidden="true"></span><div><span class="dir-label"><%: L.T("Coordinator.Review.StatusApproved") %></span><strong class="rv-num"><%: CountStatus(CompletionQueueRow.ReviewApproved) %></strong><small><%: L.T("Coordinator.Review.MetricApproved") %></small></div></li>
    </ul>

    <section class="dir-card" aria-labelledby="crQueueTitle" data-cr-queue>
        <div class="dir-toolbar">
            <div class="dir-title"><h3 id="crQueueTitle"><%: L.T("Coordinator.Review.QueueTitle") %> <span class="dir-count"><span data-cr-visible><%: Queue.Count %></span><% if (Queue.Count > 0) { %>&nbsp;/&nbsp;<%: Queue.Count %><% } %></span></h3><p><%: L.T("Coordinator.Review.QueueNote") %></p></div>
            <% if (Queue.Count > 0) { %>
            <div class="dir-filters">
                <label class="dir-search"><span class="visually-hidden"><%: L.T("Coordinator.Review.SearchLabel") %></span><span data-ui-icon="search" aria-hidden="true"></span><input id="crSearch" type="search" class="form-control" autocomplete="off" placeholder="<%: L.T("Coordinator.Review.SearchPlaceholder") %>" data-cr-search /></label>
            </div>
            <% } %>
        </div>
        <% if (Queue.Count == 0) { %>
            <p class="dir-empty"><span data-ui-icon="approved" aria-hidden="true"></span><%: L.T("Coordinator.CompletionReview.NoConfirmedPlacementsYet") %></p>
        <% } else { %>
        <div class="cr-chips mb-3" role="group" aria-label="<%: L.T("Coordinator.Review.FilterLabel") %>">
            <button type="button" class="cr-chip" aria-pressed="true" data-cr-filter="all"><%: L.T("Coordinator.Review.FilterAll") %> <b><%: Queue.Count %></b></button>
            <% foreach (var status in new[] { CompletionQueueRow.ReviewReady, CompletionQueueRow.ReviewCorrections, CompletionQueueRow.ReviewAwaitingEvaluations, CompletionQueueRow.ReviewInProgress, CompletionQueueRow.ReviewApproved, CompletionQueueRow.ReviewRejected }) { %>
                <button type="button" class="cr-chip" aria-pressed="false" data-cr-filter="<%: status %>"><%: ReviewLabel(status) %> <b><%: CountStatus(status) %></b></button>
            <% } %>
        </div>
        <p class="visually-hidden" role="status" aria-live="polite" data-cr-announce></p>
        <div class="table-responsive">
            <table class="dir-table cr-queue-table">
                <caption class="visually-hidden"><%: L.T("Coordinator.Review.QueueCaption") %></caption>
                <thead><tr>
                    <th scope="col"><%: L.T("Coordinator.CompletionReview.Student") %></th>
                    <th scope="col"><%: L.T("Coordinator.CompletionReview.Company") %></th>
                    <th scope="col"><%: L.T("Coordinator.Review.Program") %></th>
                    <th scope="col"><%: L.T("Coordinator.Review.EvaluationStatus") %></th>
                    <th scope="col"><%: L.T("Coordinator.Review.ReviewStatus") %></th>
                    <th scope="col" class="dir-actions-col"><%: L.T("Coordinator.CompletionReview.Action") %></th>
                </tr></thead>
                <tbody>
                <% int i = 0; foreach (var row in Queue) { var student = row.Overview.Student; bool actionable = row.ReviewStatus == CompletionQueueRow.ReviewReady || row.ReviewStatus == CompletionQueueRow.ReviewCorrections; %>
                    <tr data-cr-row data-status="<%: row.ReviewStatus %>" data-search="<%: SearchText(row) %>" style="--dir-i:<%: i++ %>">
                        <td><div class="dir-person"><span class="dir-avatar" aria-hidden="true"><%: Initials(row.Overview.StudentName) %></span><div><strong><%: row.Overview.StudentName %></strong><small class="dir-num"><%: row.Overview.StudentNumber %></small></div></div></td>
                        <td><strong><%: Text(row.Overview.Placement.CompanyName) %></strong><small><%: Text(row.Overview.Placement.OpportunityTitle) %></small></td>
                        <td><%: ProgramName(student) %><small><%: TypeLabel(InternshipTypes.Of(row.Overview.Placement)) %></small><% if (ProgramNeedsCheck(student)) { %><small class="dir-flag"><%: L.T("Coordinator.Review.ProgramCheck") %></small><% } %></td>
                        <td><span class="cr-evals"><i class="<%: row.CompanySubmitted ? "is-ok" : "" %>" title="<%: L.T("Coordinator.CompletionReview.CompanyFinalEvaluation") %>"></i><i class="<%: row.AcademicSubmitted ? "is-ok" : "" %>" title="<%: L.T("Coordinator.CompletionReview.AcademicFinalEvaluation") %>"></i></span><%: EvaluationLabel(row) %><small class="dir-num"><%: InternshipTypes.Of(row.Overview.Placement) == InternshipTypes.International ? L.F("Coordinator.Review.WeeksValue", InternshipRules.Weeks(row.Overview.Placement).ToString("0.#")) : row.Overview.HoursText %></small></td>
                        <td><span class="<%: ReviewCss(row.ReviewStatus) %>"><%: ReviewLabel(row.ReviewStatus) %></span></td>
                        <td><div class="dir-actions"><a class="<%: actionable ? "dir-btn dir-btn-primary" : "dir-btn" %>" href="CompletionReview.aspx?id=<%: Server.UrlEncode(row.Overview.Placement.Id) %>"><span data-ui-icon="<%: actionable ? "approved" : "eye" %>" aria-hidden="true"></span> <%: actionable ? L.T("Coordinator.Review.Review") : L.T("Coordinator.Review.Open") %><span class="visually-hidden">: <%: row.Overview.StudentName %></span></a></div></td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </div>
        <p class="dir-empty" data-cr-nomatch hidden><span data-ui-icon="search" aria-hidden="true"></span><%: L.T("Coordinator.Review.NoMatch") %></p>
        <p class="dir-note"><%: L.T("Coordinator.Review.StatusDisclaimer") %></p>
        <% } %>
    </section>
    <% } %>

<% } else { %>
    <%-- ================= Review of one internship ================= --%>
    <a class="dir-back" href="CompletionReview.aspx"><span data-ui-icon="back" aria-hidden="true"></span> <%: L.T("Coordinator.Review.BackToQueue") %></a>

    <% if (LoadError != null) { %>
        <div class="alert alert-danger" role="alert"><%: LoadError %></div>
    <% } else {
           var overview = Progress.Overview; var placement = overview.Placement; var student = overview.Student; var record = Record;
           string courseCode = CourseCode(student, Summary.InternshipType); %>

    <section class="dir-card dir-profile-hero" aria-labelledby="crStudentName">
        <span class="dir-avatar dir-avatar-xl" aria-hidden="true"><%: Initials(overview.StudentName) %></span>
        <div class="dir-hero-text">
            <span class="dir-eyebrow"><%: L.T("Coordinator.CompletionReview.FinalCompletionReview") %></span>
            <h2 id="crStudentName"><%: overview.StudentName %></h2>
            <p><span class="dir-num"><%: overview.StudentNumber %></span> &middot; <%: ProgramName(student) %><% if (courseCode != null) { %> (<%: courseCode %>)<% } %> &middot; <%: Text(placement.CompanyName) %> <span class="<%: ReviewCss(DetailStatus) %>"><%: ReviewLabel(DetailStatus) %></span></p>
        </div>
        <div class="dir-hero-actions">
            <% if (!string.IsNullOrEmpty(placement.StudentId)) { %><a class="btn dir-ghost" href="Students.aspx?id=<%: Server.UrlEncode(placement.StudentId) %>"><span data-ui-icon="person" aria-hidden="true"></span> <%: L.T("Coordinator.ManageStudents.ViewProfile") %></a><% } %>
            <a class="btn dir-ghost" href="PlacementDetails.aspx?id=<%: Server.UrlEncode(placement.Id) %>"><span data-ui-icon="chart" aria-hidden="true"></span> <%: L.T("Coordinator.CompletionReview.FullProgressHistory") %></a>
        </div>
    </section>

    <% if (ProgramNeedsCheck(student)) { %><div class="alert alert-warning" role="note"><%: L.T("Coordinator.Review.ProgramCheckLong") %></div><% } %>
    <% if (Message != null) { %><div class="alert <%: MessageIsError ? "alert-danger" : "alert-success" %>" role="<%: MessageIsError ? "alert" : "status" %>"><%: Message %></div><% } %>

    <%-- At a glance: the four figures the decision depends on. --%>
    <ul class="dir-profile-stats">
        <li style="--dir-i:0"><span class="dir-stat-icon <%: Summary.CanApprove ? "is-success" : "is-warning" %>" data-ui-icon="approved" aria-hidden="true"></span><div><span class="dir-label"><%: L.T("Coordinator.Review.RequirementsMet") %></span><strong class="dir-num"><bdi dir="ltr"><%: Summary.MandatoryMet %> / <%: Summary.MandatoryTotal %></bdi></strong><div class="dir-progress" aria-hidden="true"><span style="--dir-p:<%: RequirementsPercent %>%"></span></div></div></li>
        <li style="--dir-i:1"><span class="dir-stat-icon" data-ui-icon="clock" aria-hidden="true"></span><div><span class="dir-label"><%: L.T("Coordinator.Review.TrainingTitle") %></span>
            <% if (Summary.IsInternational) { %><strong class="dir-num"><bdi dir="ltr"><%: Summary.Weeks.ToString("0.#") %> / <%: InternshipRules.InternationalMinimumWeeks %></bdi> <%: L.T("Coordinator.Review.Weeks") %></strong>
            <% } else { %><strong class="dir-num"><bdi dir="ltr"><%: Summary.ApprovedHours %> / <%: Summary.RequiredHours %></bdi> <%: L.T("Workspace.UnitH") %></strong><% } %>
            <div class="dir-progress" aria-hidden="true"><span style="--dir-p:<%: TrainingPercent %>%"></span></div></div></li>
        <li style="--dir-i:2"><span class="dir-stat-icon" data-ui-icon="document" aria-hidden="true"></span><div><span class="dir-label"><%: L.T("Coordinator.CompletionReview.TasksGraded") %></span><strong class="dir-num"><bdi dir="ltr"><%: Summary.TasksGraded %> / <%: Summary.TasksTotal %></bdi></strong><div class="dir-progress" aria-hidden="true"><span style="--dir-p:<%: Summary.TasksTotal == 0 ? 0 : Summary.TasksGraded * 100 / Summary.TasksTotal %>%"></span></div></div></li>
        <li style="--dir-i:3"><span class="dir-stat-icon <%: !Summary.EvaluationsReady ? "" : Summary.Passing ? "is-success" : "is-danger" %>" data-ui-icon="chart" aria-hidden="true"></span><div><span class="dir-label"><%: L.T("Coordinator.Review.ProvisionalScore") %></span><strong class="dir-num"><%: Summary.EvaluationsReady ? Percent(Summary.FinalPercent) : "—" %></strong><span class="<%: !Summary.EvaluationsReady ? "dir-status is-neutral" : Summary.Passing ? "dir-status is-active" : "dir-status is-inactive" %>"><%: Summary.EvaluationsReady ? (Summary.Passing ? L.T("Coordinator.Review.Pass") : L.T("Coordinator.Review.Fail")) : L.T("Coordinator.Review.Pending") %></span></div></li>
    </ul>

    <div class="cr-layout">
    <div class="cr-main">

    <%-- Requirement checklist: what must be true before approval. --%>
    <section class="rv-card" aria-labelledby="crChecksTitle">
        <div class="rv-card-head">
            <div><h3 id="crChecksTitle"><span class="rv-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M9 11l3 3 8-8"/><path d="M20 12v7a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h9"/></svg></span><%: L.F("Coordinator.Review.ChecksTitle", TypeLabel(Summary.InternshipType)) %></h3><p><%: L.T("Coordinator.Review.ChecksNote") %></p></div>
            <span class="rv-badge <%: Summary.CanApprove ? "is-done" : "is-pending" %>"><%: L.F("Coordinator.Review.RequirementsValue", Summary.MandatoryMet, Summary.MandatoryTotal) %></span>
        </div>
        <ol class="cr-checks">
        <% foreach (var item in Summary.Items.Where(i => !i.Manual)) { %>
            <li class="<%: item.Satisfied ? "is-ok" : "is-missing" %>">
                <span class="cr-check-mark" aria-hidden="true"></span>
                <div class="cr-check-body">
                    <div class="cr-check-title"><strong><%: item.Title %></strong><span class="cr-auto"><%: L.T("Coordinator.Review.Automatic") %></span></div>
                    <small><%: item.Detail %></small>
                </div>
                <span class="<%: StateCss(item.State) %>"><%: StateLabel(item.State) %></span>
            </li>
        <% } %>
        <% if (!IsEditable) { foreach (var item in Summary.Items.Where(i => i.Manual)) { %>
            <li class="<%: item.Satisfied ? "is-ok" : "is-missing" %>">
                <span class="cr-check-mark" aria-hidden="true"></span>
                <div class="cr-check-body">
                    <div class="cr-check-title"><strong><%: item.Title %></strong></div>
                    <small><%: L.T("Coordinator.Review.Evidence") %>: <%: Text(item.Check == null ? null : item.Check.Evidence) %></small>
                    <% if (CheckedBy(item).Length > 0) { %><small><%: CheckedBy(item) %></small><% } %>
                </div>
                <span class="<%: StateCss(item.State) %>"><%: StateLabel(item.State) %></span>
            </li>
        <% } } %>
        </ol>

        <asp:Panel ID="pnlChecks" runat="server" CssClass="cr-manual">
            <h4 class="cr-subtitle"><%: L.T("Coordinator.Review.ManualTitle") %></h4>
            <p class="rv-note"><%: L.T("Coordinator.Review.ManualNote") %></p>
            <asp:Repeater ID="rptChecks" runat="server" OnItemDataBound="Checks_ItemDataBound">
                <HeaderTemplate><ol class="cr-checks is-manual"></HeaderTemplate>
                <ItemTemplate>
                    <li class='<%# ((RequirementItem)Container.DataItem).Satisfied ? "is-ok" : ((RequirementItem)Container.DataItem).State == "NeedsCorrections" ? "is-attention" : "is-missing" %>'>
                        <span class="cr-check-mark" aria-hidden="true"></span>
                        <div class="cr-check-body">
                            <div class="cr-check-title"><strong><%#: ((RequirementItem)Container.DataItem).Title %></strong></div>
                            <small><%#: ((RequirementItem)Container.DataItem).Hint %></small>
                            <small class="cr-checked-by"><%#: CheckedBy((RequirementItem)Container.DataItem) %></small>
                            <div class="cr-check-inputs">
                                <asp:HiddenField ID="hidKey" runat="server" />
                                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-select form-select-sm">
                                    <asp:ListItem Value="Pending" Text="<%$ Resources:Coordinator, Review.StatePending %>" />
                                    <asp:ListItem Value="Verified" Text="<%$ Resources:Coordinator, Review.StateVerified %>" />
                                    <asp:ListItem Value="NeedsCorrections" Text="<%$ Resources:Coordinator, Review.StateCorrections %>" />
                                    <asp:ListItem Value="NotApplicable" Text="<%$ Resources:Coordinator, Review.StateNotApplicable %>" />
                                </asp:DropDownList>
                                <asp:TextBox ID="txtEvidence" runat="server" CssClass="form-control form-control-sm" MaxLength="300" placeholder="<%$ Resources:Coordinator, Review.EvidencePlaceholder %>" />
                            </div>
                        </div>
                        <span class='<%#: StateCss(((RequirementItem)Container.DataItem).State) %>'><%#: StateLabel(((RequirementItem)Container.DataItem).State) %></span>
                    </li>
                </ItemTemplate>
                <FooterTemplate></ol></FooterTemplate>
            </asp:Repeater>
            <div class="rv-actions cr-manual-actions">
                <asp:Button ID="btnSaveChecks" runat="server" CssClass="btn btn-brand" Text="<%$ Resources:Coordinator, Review.SaveChecks %>" OnClick="SaveChecks_Click" data-ui-action="save" data-ui-validation="none" />
                <small class="rv-note"><%: L.T("Coordinator.Review.SaveChecksNote") %></small>
            </div>
        </asp:Panel>
    </section>

    <%-- Score: three weighted parts and the provisional result. --%>
    <section class="rv-card" aria-labelledby="crResultTitle">
        <div class="rv-card-head">
            <div><h3 id="crResultTitle"><span class="rv-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M4 20V10"/><path d="M10 20V4"/><path d="M16 20v-7"/><path d="M22 20H2"/></svg></span><%: L.T("Coordinator.Review.ResultTitle") %></h3><p><%: L.T("Coordinator.Review.ResultNote") %></p></div>
            <a class="dir-btn" href="PlacementDetails.aspx?id=<%: Server.UrlEncode(placement.Id) %>"><span data-ui-icon="eye" aria-hidden="true"></span> <%: L.T("Coordinator.CompletionReview.ReadEvaluations") %></a>
        </div>
        <div class="table-responsive">
            <table class="dir-table dir-table-plain">
                <thead><tr><th scope="col"><%: L.T("Coordinator.CompletionReview.Component") %></th><th scope="col"><%: L.T("Coordinator.Review.Status") %></th><th scope="col"><%: L.T("Coordinator.CompletionReview.Score") %></th><th scope="col"><%: L.T("Coordinator.CompletionReview.Weight") %></th><th scope="col"><%: L.T("Coordinator.CompletionReview.Points") %></th></tr></thead>
                <tbody>
                    <tr>
                        <td><strong><%: L.T("Coordinator.CompletionReview.GradedTasks") %></strong><small><%: L.T("Coordinator.Review.ScaleTasks") %></small></td>
                        <td><span class="<%: Summary.TasksComplete ? "dir-status is-active" : "dir-status is-warning" %>"><bdi dir="ltr"><%: Summary.TasksGraded %> / <%: Summary.TasksTotal %></bdi></span></td>
                        <td class="dir-num"><%: Summary.TasksGraded > 0 ? Percent(Summary.TaskPercent) : "—" %></td>
                        <td class="dir-num"><%: GradingPolicy.TaskComponentWeight %>%</td>
                        <td class="dir-num"><strong><%: Weighted(Summary.TaskPercent, GradingPolicy.TaskComponentWeight) %></strong></td>
                    </tr>
                    <tr>
                        <td><strong><%: L.T("Coordinator.CompletionReview.CompanyFinalEvaluation") %></strong><small><%: Text(Progress.CompanySupervisorName) %></small></td>
                        <td><span class="<%: Summary.CompanySubmitted ? "dir-status is-active" : Progress.CompanyFinal == null ? "dir-status is-neutral" : "dir-status is-warning" %>"><%: Summary.CompanySubmitted ? L.T("Coordinator.Review.Submitted") : Progress.CompanyFinal == null ? L.T("Coordinator.Review.NotStarted") : L.T("Coordinator.Review.Draft") %></span></td>
                        <td class="dir-num"><%: Summary.CompanySubmitted ? Score(Progress.CompanyFinal.TotalScore, Progress.CompanyFinal.MaxScore) + " · " + Percent(Summary.CompanyPercent) : "—" %></td>
                        <td class="dir-num"><%: GradingPolicy.CompanyFinalWeight %>%</td>
                        <td class="dir-num"><strong><%: Weighted(Summary.CompanyPercent, GradingPolicy.CompanyFinalWeight) %></strong></td>
                    </tr>
                    <tr>
                        <td><strong><%: L.T("Coordinator.CompletionReview.AcademicFinalEvaluation") %></strong><small><%: Text(Progress.AcademicSupervisorName) %></small></td>
                        <td><span class="<%: Summary.AcademicSubmitted ? "dir-status is-active" : Progress.AcademicFinal == null ? "dir-status is-neutral" : "dir-status is-warning" %>"><%: Summary.AcademicSubmitted ? L.T("Coordinator.Review.Submitted") : Progress.AcademicFinal == null ? L.T("Coordinator.Review.NotStarted") : L.T("Coordinator.Review.Draft") %></span></td>
                        <td class="dir-num"><%: Summary.AcademicSubmitted ? Score(Progress.AcademicFinal.TotalScore, Progress.AcademicFinal.MaxScore) + " · " + Percent(Summary.AcademicPercent) : "—" %></td>
                        <td class="dir-num"><%: GradingPolicy.AcademicFinalWeight %>%</td>
                        <td class="dir-num"><strong><%: Weighted(Summary.AcademicPercent, GradingPolicy.AcademicFinalWeight) %></strong></td>
                    </tr>
                </tbody>
            </table>
        </div>
        <div class="cr-result">
            <div><span><%: L.T("Coordinator.Review.ProvisionalScore") %></span><strong class="rv-num"><%: Summary.EvaluationsReady ? Percent(Summary.FinalPercent) : "—" %></strong></div>
            <div><span><%: L.T("Coordinator.Review.ProvisionalResult") %></span><strong class="<%: !Summary.EvaluationsReady ? "" : Summary.Passing ? "is-pass" : "is-fail" %>"><%: Summary.EvaluationsReady ? (Summary.Passing ? L.T("Coordinator.Review.Pass") : L.T("Coordinator.Review.Fail")) : L.T("Coordinator.Review.Pending") %></strong></div>
            <p class="rv-note"><%: L.F("Coordinator.Review.ResultExplain", GradingPolicy.PassMarkPercent) %></p>
        </div>
    </section>

    </div><%-- /cr-main --%>
    <aside class="cr-aside">

    <%-- Decision and documents --%>
    <section class="rv-card cr-decision <%: IsApproved ? "is-approved" : IsRejectedFinal ? "is-rejected" : "" %>" id="crDecision" aria-labelledby="crDecisionTitle">
        <div class="rv-card-head">
            <div><h3 id="crDecisionTitle"><span class="rv-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M12 3l7 4v5c0 4.5-3 8-7 9-4-1-7-4.5-7-9V7l7-4z"/><path d="m9 12 2 2 4-4"/></svg></span><%: IsApproved ? L.T("Coordinator.Review.DocumentsTitle") : L.T("Coordinator.Review.DecisionTitle") %></h3>
            <% if (record != null && record.DecidedAt > 0) { %><p><%: L.F("Coordinator.Review.LastDecision", CoordinatorName(record.ReviewedByCoordinatorId), Time.Display(record.DecidedAt)) %></p><% } %></div>
        </div>
        <div class="rv-card-body">
        <% if (IsApproved) { %>
            <div class="cr-approved">
                <div class="cr-seal" aria-hidden="true">
                    <svg viewBox="0 0 200 200"><defs><path id="crRingPath" d="M100,100 m-72,0 a72,72 0 1,1 144,0 a72,72 0 1,1 -144,0"/></defs>
                        <circle cx="100" cy="100" r="92" class="cr-seal-outer"/><circle cx="100" cy="100" r="82" class="cr-seal-inner"/>
                        <text class="cr-seal-ring"><textPath href="#crRingPath" startOffset="0" textLength="440" lengthAdjust="spacing">UIMS &#183; INTERNSHIP COMPLETION VERIFIED &#183; UIMS &#183;</textPath></text>
                        <line x1="44" y1="86" x2="156" y2="86"/><line x1="44" y1="118" x2="156" y2="118"/>
                        <text x="100" y="109" class="cr-seal-word" text-anchor="middle">APPROVED</text>
                    </svg>
                </div>
                <div>
                    <p class="cr-approved-title"><%: L.T("Coordinator.Review.ApprovedHeadline") %></p>
                    <dl class="rv-kv cr-decision-kv">
                        <div><dt><%: L.T("Coordinator.Review.DecidedBy") %></dt><dd><%: Text(record.CoordinatorName ?? CoordinatorName(record.ReviewedByCoordinatorId)) %></dd></div>
                        <div><dt><%: L.T("Coordinator.CompletionReview.ApprovedOn") %></dt><dd class="rv-num"><%: Time.Display(record.ApprovedAt) %></dd></div>
                        <div><dt><%: L.T("Coordinator.Review.ReleasedResult") %></dt><dd><%: Text(record.Result) %><small class="rv-num"><%: L.F("Coordinator.Review.SupportingScore", Percent(record.FinalScore)) %></small></dd></div>
                        <div><dt><%: L.T("Coordinator.Review.Reference") %></dt><dd class="rv-num"><%: PdfReportService.Reference(record) %></dd></div>
                    </dl>
                    <% if (!string.IsNullOrWhiteSpace(record.CoordinatorNote)) { %><p class="rv-note"><%: L.T("Coordinator.CompletionReview.NoteOnTheReport") %> <%: record.CoordinatorNote %></p><% } %>
                </div>
            </div>
            <div class="cr-docs" data-cr-docs>
                <div class="cr-doc">
                    <span class="rv-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M14 3H6a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z"/><path d="M14 3v6h6"/><path d="M8 13h8M8 17h5"/></svg></span>
                    <div><strong><%: L.T("Coordinator.Review.ReportDoc") %></strong><small><%: L.T("Coordinator.Review.ReportDocNote") %></small></div>
                    <div class="rv-actions">
                        <a class="btn btn-brand btn-sm rv-btn-icon" href="<%: ResolveUrl(PdfReportService.DownloadUrl(PdfReportService.ReportUrl(record.Id))) %>"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 3v12"/><path d="m7 10 5 5 5-5"/><path d="M5 21h14"/></svg><%: L.T("Coordinator.Review.DownloadPdf") %></a>
                        <a class="btn btn-outline-secondary btn-sm rv-btn-icon" href="<%: ResolveUrl(PdfReportService.ReportUrl(record.Id)) %>" target="_blank" rel="noopener" data-rv-print><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M6 9V3h12v6"/><rect x="3" y="9" width="18" height="8" rx="2"/><path d="M6 14h12v7H6z"/></svg><%: L.T("Coordinator.Review.Print") %></a>
                    </div>
                </div>
                <div class="cr-doc">
                    <span class="rv-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><circle cx="12" cy="9" r="6"/><path d="M8.5 14.5 7 22l5-3 5 3-1.5-7.5"/></svg></span>
                    <div><strong><%: L.T("Coordinator.Review.CertificateDoc") %></strong><small><%: L.T("Coordinator.Review.CertificateDocNote") %></small></div>
                    <div class="rv-actions">
                        <a class="btn btn-brand btn-sm rv-btn-icon" href="<%: ResolveUrl(PdfReportService.DownloadUrl(PdfReportService.CertificateUrl(record.Id))) %>"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 3v12"/><path d="m7 10 5 5 5-5"/><path d="M5 21h14"/></svg><%: L.T("Coordinator.Review.DownloadPdf") %></a>
                        <a class="btn btn-outline-secondary btn-sm rv-btn-icon" href="<%: ResolveUrl(PdfReportService.CertificateUrl(record.Id)) %>" target="_blank" rel="noopener" data-rv-print><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M6 9V3h12v6"/><rect x="3" y="9" width="18" height="8" rx="2"/><path d="M6 14h12v7H6z"/></svg><%: L.T("Coordinator.Review.Print") %></a>
                    </div>
                </div>
                <p class="rv-note"><%: L.T("Coordinator.Review.DocsDisclaimer") %></p>
            </div>
        <% } else if (IsRejectedFinal) { %>
            <div class="rv-alert is-error" role="note"><div><strong><%: L.T("Coordinator.Review.RejectedHeadline") %></strong><br /><%: L.T("Coordinator.Review.Reason") %>: <%: Text(record.CoordinatorNote) %></div></div>
            <p class="rv-note"><%: L.T("Coordinator.Review.ReadOnlyNote") %></p>
        <% } else { %>
            <% if (record != null && record.NeedsCorrections) { %><div class="rv-alert is-warning" role="note"><div><strong><%: L.T("Coordinator.Review.CorrectionsHeadline") %></strong><br /><%: Text(record.CoordinatorNote) %></div></div><% } %>
            <% if (!Summary.CanApprove) { %>
                <div class="rv-alert is-info" role="note"><div><strong><%: L.T("Coordinator.Review.LockedHeadline") %></strong>
                    <ul class="cr-missing"><% foreach (var item in Summary.Items.Where(i => i.Mandatory && !i.Satisfied)) { %><li><%: item.Title %></li><% } %></ul></div></div>
            <% } %>
        <% } %>
        <asp:Panel ID="pnlDecision" runat="server" CssClass="cr-decision-form">
            <label for="<%= txtNote.ClientID %>" class="cr-label"><%: L.T("Coordinator.Review.DecisionNote") %></label>
            <asp:TextBox ID="txtNote" runat="server" TextMode="MultiLine" Rows="3" MaxLength="1000" CssClass="form-control"
                placeholder="<%$ Resources:Coordinator, Review.DecisionNotePlaceholder %>" />
            <small class="rv-note"><%: L.T("Coordinator.Review.DecisionNoteHelp") %></small>
            <div class="rv-actions cr-decision-actions">
                <asp:Button ID="btnApprove" runat="server" Text="<%$ Resources:Coordinator, Review.Approve %>" CssClass="btn btn-brand cr-approve" OnClick="Approve_Click" data-ui-action="approve" data-ui-validation="none" />
                <asp:Button ID="btnReturn" runat="server" Text="<%$ Resources:Coordinator, Review.ReturnForCorrections %>" CssClass="btn btn-outline-warning" OnClick="Return_Click" data-ui-action="return" data-ui-validation="none" />
                <asp:Button ID="btnReject" runat="server" Text="<%$ Resources:Coordinator, Review.RejectCompletion %>" CssClass="btn btn-outline-danger" OnClick="Reject_Click" data-ui-action="reject" data-ui-validation="none" />
            </div>
        </asp:Panel>
        </div>
    </section>

    <%-- Internship type: decides which requirement list applies. --%>
    <section class="rv-card" aria-labelledby="crTypeTitle">
        <div class="rv-card-head">
            <div><h3 id="crTypeTitle"><span class="rv-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3a14 14 0 0 1 0 18M12 3a14 14 0 0 0 0 18"/></svg></span><%: L.T("Coordinator.Review.Type") %>: <%: TypeLabel(Summary.InternshipType) %></h3>
            <p><%: Summary.InternshipTypeIsDefault ? L.T("Coordinator.Review.TypeDefaultLong") : L.T("Coordinator.Review.TypeHelp") %></p></div>
        </div>
        <asp:Panel ID="pnlType" runat="server" CssClass="rv-card-body cr-type-form">
            <label for="<%= ddlType.ClientID %>"><%: L.T("Coordinator.Review.ChangeType") %></label>
            <asp:DropDownList ID="ddlType" runat="server" CssClass="form-select">
                <asp:ListItem Value="Local" Text="<%$ Resources:Coordinator, Review.TypeLocal %>" />
                <asp:ListItem Value="International" Text="<%$ Resources:Coordinator, Review.TypeInternational %>" />
            </asp:DropDownList>
            <asp:Button ID="btnSaveType" runat="server" CssClass="btn btn-outline-secondary" Text="<%$ Resources:Coordinator, Review.SaveType %>" OnClick="SaveType_Click" data-ui-action="save" data-ui-validation="none" />
        </asp:Panel>
    </section>

    </aside>
    </div><%-- /cr-layout --%>

    <% if (PlayStamp) { %>
    <%-- Plays once, only after the server saved the approval (one-time session flag). --%>
    <div class="cr-stamp-stage" role="dialog" aria-modal="true" aria-labelledby="crStampTitle" aria-describedby="crStampText" data-cr-stamp>
        <div class="cr-stamp-sheet">
            <div class="cr-sheet-head" aria-hidden="true"><span></span><span></span></div>
            <div class="cr-sheet-lines" aria-hidden="true"><i></i><i></i><i></i><i></i><i></i></div>
            <div class="cr-stamp-impact" aria-hidden="true"></div>
            <div class="cr-stamp" aria-hidden="true">
                <svg viewBox="0 0 200 200"><defs>
                    <filter id="crInk" x="-10%" y="-10%" width="120%" height="120%"><feTurbulence type="fractalNoise" baseFrequency="0.85" numOctaves="2" seed="7" result="noise"/><feDisplacementMap in="SourceGraphic" in2="noise" scale="2.2"/></filter>
                    <path id="crStampRing" d="M100,100 m-72,0 a72,72 0 1,1 144,0 a72,72 0 1,1 -144,0"/></defs>
                    <g filter="url(#crInk)">
                        <circle cx="100" cy="100" r="92" class="cr-seal-outer"/><circle cx="100" cy="100" r="82" class="cr-seal-inner"/>
                        <text class="cr-seal-ring"><textPath href="#crStampRing" startOffset="0" textLength="440" lengthAdjust="spacing">UIMS &#183; INTERNSHIP COMPLETION VERIFIED &#183; UIMS &#183;</textPath></text>
                        <line x1="44" y1="86" x2="156" y2="86"/><line x1="44" y1="118" x2="156" y2="118"/>
                        <text x="100" y="109" class="cr-seal-word" text-anchor="middle">APPROVED</text>
                    </g>
                </svg>
            </div>
            <h2 id="crStampTitle"><%: L.T("Coordinator.Review.StampTitle") %></h2>
            <p id="crStampText"><%: overview.StudentName %> &middot; <span class="rv-num"><%: PdfReportService.Reference(record) %></span> &middot; <%: Time.Display(record.ApprovedAt) %></p>
            <button type="button" class="btn btn-brand" data-cr-stamp-close><%: L.T("Coordinator.Review.StampContinue") %></button>
        </div>
    </div>
    <% } %>
    <% } %>
<% } %>
</div>
</asp:Content>

<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server">
    <script src="<%: ResolveUrl("~/Assets/js/review-system.js?v=20261023-rv6") %>"></script>
    <script src="<%: ResolveUrl("~/Assets/js/completion-review.js?v=20261023-rv6") %>"></script>
</asp:Content>
