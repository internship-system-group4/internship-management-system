<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="CompletionReview.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.CompletionReview" Title="Final Completion Review" %>
<%@ Import Namespace="InternshipManagementSystem.Services" %>
<%@ Import Namespace="InternshipManagementSystem.Data" %>
<%-- ===================================================================
     Final Completion Review  -  Owner: Ahmad  -  Cards A10 - A14
     Queue (no ?id) and the review of one internship (?id={placementId}).
     Final evaluations shown here are confidential: coordinator only.
     =================================================================== --%>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <script>document.documentElement.classList.add('rv-js');setTimeout(function(){if(!window.UimsReview)document.documentElement.classList.remove('rv-js');},2500);</script>
    <link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/review-system.css?v=20261023-rv6") %>" />
    <link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/completion-review.css?v=20261023-rv7") %>" />
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="rv-scope cr-page">

<% if (!IsDetail) { %>
    <%-- ================= Queue ================= --%>
    <header class="rv-heading" data-rv-reveal>
        <div>
            <span class="rv-eyebrow"><%: L.T("Coordinator.Review.Eyebrow") %></span>
            <h2><%: L.T("Coordinator.CompletionReview.FinalCompletionReview") %></h2>
            <p><%: L.T("Coordinator.Review.QueueIntro") %></p>
        </div>
        <% if (LoadError == null && Queue != null && Queue.Count > 0) { %>
        <a class="btn btn-outline-success cr-export" href="CompletionReview.aspx?export=xlsx" download data-ui-action="export">
            <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M14 3H6a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z"/><path d="M14 3v6h6"/><path d="m9 13 6 6M15 13l-6 6"/></svg>
            <%: L.T("Coordinator.Export.Button") %>
        </a>
        <% } %>
    </header>
    <% if (Message != null) { %><div class="rv-alert is-error" role="alert"><%: Message %></div><% } %>

    <% if (LoadError != null) { %>
        <div class="rv-alert is-error" role="alert"><%: LoadError %> <a class="btn btn-outline-secondary btn-sm ms-2" href="CompletionReview.aspx"><%: L.T("Coordinator.CompletionReview.Retry") %></a></div>
    <% } else { %>
    <div class="cr-metrics">
        <div class="cr-metric rv-card is-lift" data-rv-reveal><span class="rv-icon is-active" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M9 11l3 3 8-8"/><path d="M20 12v7a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h9"/></svg></span><div><span><%: L.T("Coordinator.Review.StatusReady") %></span><strong class="rv-num" data-rv-count="<%: CountStatus(CompletionQueueRow.ReviewReady) %>"><%: CountStatus(CompletionQueueRow.ReviewReady) %></strong><small><%: L.T("Coordinator.Review.MetricReady") %></small></div></div>
        <div class="cr-metric rv-card is-lift" data-rv-reveal><span class="rv-icon is-attention" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M12 9v4"/><path d="M12 17h.01"/><path d="M10.3 3.9 1.8 18a2 2 0 0 0 1.7 3h17a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0z"/></svg></span><div><span><%: L.T("Coordinator.Review.StatusCorrections") %></span><strong class="rv-num" data-rv-count="<%: CountStatus(CompletionQueueRow.ReviewCorrections) %>"><%: CountStatus(CompletionQueueRow.ReviewCorrections) %></strong><small><%: L.T("Coordinator.Review.MetricCorrections") %></small></div></div>
        <div class="cr-metric rv-card is-lift" data-rv-reveal><span class="rv-icon is-pending" aria-hidden="true"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></svg></span><div><span><%: L.T("Coordinator.Review.StatusAwaiting") %></span><strong class="rv-num" data-rv-count="<%: CountStatus(CompletionQueueRow.ReviewAwaitingEvaluations) %>"><%: CountStatus(CompletionQueueRow.ReviewAwaitingEvaluations) %></strong><small><%: L.T("Coordinator.Review.MetricAwaiting") %></small></div></div>
        <div class="cr-metric rv-card is-lift" data-rv-reveal><span class="rv-icon is-done" aria-hidden="true"><svg viewBox="0 0 24 24"><circle cx="12" cy="9" r="6"/><path d="M8.5 14.5 7 22l5-3 5 3-1.5-7.5"/></svg></span><div><span><%: L.T("Coordinator.Review.StatusApproved") %></span><strong class="rv-num" data-rv-count="<%: CountStatus(CompletionQueueRow.ReviewApproved) %>"><%: CountStatus(CompletionQueueRow.ReviewApproved) %></strong><small><%: L.T("Coordinator.Review.MetricApproved") %></small></div></div>
    </div>

    <section class="rv-card cr-queue" aria-labelledby="crQueueTitle" data-rv-reveal data-cr-queue>
        <div class="rv-card-head">
            <div><h3 id="crQueueTitle"><%: L.T("Coordinator.Review.QueueTitle") %></h3><p><%: L.T("Coordinator.Review.QueueNote") %></p></div>
            <span class="rv-badge is-na"><span data-cr-visible><%: Queue.Count %></span>&nbsp;/&nbsp;<%: Queue.Count %> <%: L.T("Coordinator.Review.Internships") %></span>
        </div>
        <% if (Queue.Count == 0) { %>
            <div class="rv-card-body"><div class="rv-empty"><%: L.T("Coordinator.CompletionReview.NoConfirmedPlacementsYet") %></div></div>
        <% } else { %>
        <div class="cr-toolbar">
            <div class="cr-search">
                <label for="crSearch" class="visually-hidden"><%: L.T("Coordinator.Review.SearchLabel") %></label>
                <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/></svg>
                <input id="crSearch" type="search" class="form-control" autocomplete="off" placeholder="<%: L.T("Coordinator.Review.SearchPlaceholder") %>" data-cr-search />
            </div>
            <div class="cr-chips" role="group" aria-label="<%: L.T("Coordinator.Review.FilterLabel") %>">
                <button type="button" class="cr-chip" aria-pressed="true" data-cr-filter="all"><%: L.T("Coordinator.Review.FilterAll") %> <b><%: Queue.Count %></b></button>
                <% foreach (var status in new[] { CompletionQueueRow.ReviewReady, CompletionQueueRow.ReviewCorrections, CompletionQueueRow.ReviewAwaitingEvaluations, CompletionQueueRow.ReviewInProgress, CompletionQueueRow.ReviewApproved, CompletionQueueRow.ReviewRejected }) { %>
                    <button type="button" class="cr-chip" aria-pressed="false" data-cr-filter="<%: status %>"><%: ReviewLabel(status) %> <b><%: CountStatus(status) %></b></button>
                <% } %>
            </div>
        </div>
        <p class="visually-hidden" role="status" aria-live="polite" data-cr-announce></p>
        <div class="rv-table-scroll" tabindex="0" role="region" aria-labelledby="crQueueTitle">
            <table class="rv-table cr-queue-table">
                <caption class="visually-hidden"><%: L.T("Coordinator.Review.QueueCaption") %></caption>
                <thead><tr>
                    <th scope="col"><%: L.T("Coordinator.CompletionReview.Student") %></th>
                    <th scope="col"><%: L.T("Coordinator.CompletionReview.Company") %></th>
                    <th scope="col"><%: L.T("Coordinator.Review.Program") %></th>
                    <th scope="col"><%: L.T("Coordinator.Review.Type") %></th>
                    <th scope="col"><%: L.T("Coordinator.Review.EvaluationStatus") %></th>
                    <th scope="col"><%: L.T("Coordinator.Review.ReviewStatus") %></th>
                    <th scope="col"><span class="visually-hidden"><%: L.T("Coordinator.CompletionReview.Action") %></span></th>
                </tr></thead>
                <tbody>
                <% foreach (var row in Queue) { var student = row.Overview.Student; %>
                    <tr data-cr-row data-status="<%: row.ReviewStatus %>" data-search="<%: SearchText(row) %>">
                        <td><div class="cr-person"><span class="cr-avatar" aria-hidden="true"><%: Initials(row.Overview.StudentName) %></span><div><strong><%: row.Overview.StudentName %></strong><small class="rv-num"><%: row.Overview.StudentNumber %></small></div></div></td>
                        <td><%: Text(row.Overview.Placement.CompanyName) %><small><%: Text(row.Overview.Placement.OpportunityTitle) %></small></td>
                        <td><%: ProgramName(student) %><% if (ProgramNeedsCheck(student)) { %><small class="cr-flag"><%: L.T("Coordinator.Review.ProgramCheck") %></small><% } %></td>
                        <td><%: TypeLabel(InternshipTypes.Of(row.Overview.Placement)) %><% if (!InternshipTypes.IsSet(row.Overview.Placement)) { %><small><%: L.T("Coordinator.Review.TypeDefault") %></small><% } %></td>
                        <td><span class="cr-evals"><i class="<%: row.CompanySubmitted ? "is-ok" : "" %>" title="<%: L.T("Coordinator.CompletionReview.CompanyFinalEvaluation") %>"></i><i class="<%: row.AcademicSubmitted ? "is-ok" : "" %>" title="<%: L.T("Coordinator.CompletionReview.AcademicFinalEvaluation") %>"></i></span><%: EvaluationLabel(row) %><small class="rv-num"><%: InternshipTypes.Of(row.Overview.Placement) == InternshipTypes.International ? L.F("Coordinator.Review.WeeksValue", InternshipRules.Weeks(row.Overview.Placement).ToString("0.#")) : row.Overview.HoursText %></small></td>
                        <td><span class="<%: ReviewCss(row.ReviewStatus) %>"><%: ReviewLabel(row.ReviewStatus) %></span></td>
                        <td class="cr-action-cell"><a class="btn btn-sm <%: row.ReviewStatus == CompletionQueueRow.ReviewReady || row.ReviewStatus == CompletionQueueRow.ReviewCorrections ? "btn-brand" : "btn-outline-secondary" %>" href="CompletionReview.aspx?id=<%: Server.UrlEncode(row.Overview.Placement.Id) %>"><%: row.ReviewStatus == CompletionQueueRow.ReviewReady || row.ReviewStatus == CompletionQueueRow.ReviewCorrections ? L.T("Coordinator.Review.Review") : L.T("Coordinator.Review.Open") %><span class="visually-hidden">: <%: row.Overview.StudentName %></span></a></td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </div>
        <div class="rv-card-body" data-cr-nomatch hidden><div class="rv-empty"><%: L.T("Coordinator.Review.NoMatch") %></div></div>
        <div class="rv-card-foot"><%: L.T("Coordinator.Review.StatusDisclaimer") %></div>
        <% } %>
    </section>
    <% } %>

<% } else { %>
    <%-- ================= Review of one internship ================= --%>
    <a class="btn btn-outline-secondary cr-back" href="CompletionReview.aspx"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="m11 5-7 7 7 7M4 12h16"/></svg><%: L.T("Coordinator.Review.BackToQueue") %></a>

    <% if (LoadError != null) { %>
        <div class="rv-alert is-error" role="alert"><%: LoadError %></div>
    <% } else {
           var overview = Progress.Overview; var placement = overview.Placement; var student = overview.Student; var record = Record; %>

    <header class="rv-card cr-hero" data-rv-reveal>
        <div class="cr-hero-top">
            <div class="cr-hero-main">
                <span class="cr-avatar is-large" aria-hidden="true"><%: Initials(overview.StudentName) %></span>
                <div>
                    <span class="rv-eyebrow"><%: L.T("Coordinator.Review.Eyebrow") %></span>
                    <h2><%: overview.StudentName %></h2>
                    <ul class="cr-hero-meta">
                        <li><svg viewBox="0 0 24 24" aria-hidden="true"><rect x="3" y="5" width="18" height="14" rx="2"/><path d="M7 10h4M7 14h7"/></svg><span class="rv-num"><%: overview.StudentNumber %></span></li>
                        <li><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M22 10 12 5 2 10l10 5 10-5z"/><path d="M6 12v5c3 2 9 2 12 0v-5"/></svg><%: ProgramName(student) %></li>
                        <li><svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3a14 14 0 0 1 0 18M12 3a14 14 0 0 0 0 18"/></svg><%: TypeLabel(Summary.InternshipType) %></li>
                        <li><svg viewBox="0 0 24 24" aria-hidden="true"><rect x="3" y="7" width="18" height="14" rx="2"/><path d="M8 7V5a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg><%: Text(placement.CompanyName) %></li>
                    </ul>
                </div>
            </div>
            <div class="cr-hero-actions">
                <span class="<%: ReviewCss(DetailStatus) %> cr-status-badge"><%: ReviewLabel(DetailStatus) %></span>
                <a class="btn btn-outline-secondary cr-hero-link" href="PlacementDetails.aspx?id=<%: Server.UrlEncode(placement.Id) %>"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M3 12h4l3-8 4 16 3-8h4"/></svg><%: L.T("Coordinator.CompletionReview.FullProgressHistory") %></a>
            </div>
        </div>

        <%-- At-a-glance figures: everything the coordinator weighs before deciding --%>
        <div class="cr-stats">
            <div class="cr-stat is-ring">
                <svg class="cr-ring <%: Summary.CanApprove ? "is-complete" : "" %>" viewBox="0 0 44 44" aria-hidden="true"><circle class="cr-ring-track" cx="22" cy="22" r="18" pathLength="100"/><circle class="cr-ring-value" cx="22" cy="22" r="18" pathLength="100" stroke-dasharray="<%: RequirementsPercent %> 100"/></svg>
                <div><span><%: L.T("Coordinator.Review.RequirementsMet") %></span><strong class="rv-num"><bdi dir="ltr"><%: Summary.MandatoryMet %> / <%: Summary.MandatoryTotal %></bdi></strong></div>
            </div>
            <div class="cr-stat">
                <span><%: L.T("Coordinator.Review.TrainingTitle") %></span>
                <% if (Summary.IsInternational) { %>
                    <strong class="rv-num"><bdi dir="ltr"><%: Summary.Weeks.ToString("0.#") %> / <%: InternshipRules.InternationalMinimumWeeks %></bdi> <small><%: L.T("Coordinator.Review.Weeks") %></small></strong>
                <% } else { %>
                    <strong class="rv-num"><bdi dir="ltr"><%: Summary.ApprovedHours %> / <%: Summary.RequiredHours %></bdi> <small>h</small></strong>
                <% } %>
                <div class="rv-meter is-thin <%: Summary.TrainingRequirementMet ? "is-complete" : "" %>" aria-hidden="true" data-rv-value="<%: TrainingPercent %>" data-rv-pending><span></span></div>
            </div>
            <div class="cr-stat">
                <span><%: L.T("Coordinator.CompletionReview.TasksGraded") %></span>
                <strong class="rv-num"><bdi dir="ltr"><%: Summary.TasksGraded %> / <%: Summary.TasksTotal %></bdi></strong>
                <div class="rv-meter is-thin <%: Summary.TasksComplete ? "is-complete" : "" %>" aria-hidden="true" data-rv-value="<%: Summary.TasksTotal == 0 ? 0 : Summary.TasksGraded * 100 / Summary.TasksTotal %>" data-rv-pending><span></span></div>
            </div>
            <div class="cr-stat">
                <span><%: L.T("Coordinator.CompletionReview.CompanyFinalEvaluation") %></span>
                <strong class="rv-num"><%: Summary.CompanySubmitted ? Percent(Summary.CompanyPercent) : "—" %></strong>
                <small class="cr-stat-note"><%: Summary.CompanySubmitted ? L.T("Coordinator.Review.Submitted") : L.T("Coordinator.Review.Pending") %></small>
            </div>
            <div class="cr-stat">
                <span><%: L.T("Coordinator.CompletionReview.AcademicFinalEvaluation") %></span>
                <strong class="rv-num"><%: Summary.AcademicSubmitted ? Percent(Summary.AcademicPercent) : "—" %></strong>
                <small class="cr-stat-note"><%: Summary.AcademicSubmitted ? L.T("Coordinator.Review.Submitted") : L.T("Coordinator.Review.Pending") %></small>
            </div>
            <div class="cr-stat is-result <%: !Summary.EvaluationsReady ? "" : Summary.Passing ? "is-pass" : "is-fail" %>">
                <span><%: L.T("Coordinator.Review.ProvisionalScore") %></span>
                <strong class="rv-num"><%: Summary.EvaluationsReady ? Percent(Summary.FinalPercent) : "—" %></strong>
                <small class="cr-stat-note"><%: Summary.EvaluationsReady ? (Summary.Passing ? L.T("Coordinator.Review.Pass") : L.T("Coordinator.Review.Fail")) : L.T("Coordinator.Review.Pending") %></small>
            </div>
        </div>
    </header>

    <% if (Message != null) { %><div class="rv-alert <%: MessageIsError ? "is-error" : "is-success" %>" role="<%: MessageIsError ? "alert" : "status" %>" data-rv-reveal><%: Message %></div><% } %>

    <div class="cr-layout">
    <div class="cr-main">

    <%-- Student & internship --%>
    <section class="rv-card" aria-labelledby="crDetailsTitle" data-rv-reveal>
        <div class="rv-card-head">
            <h3 id="crDetailsTitle"><span class="rv-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></span><%: L.T("Coordinator.Review.DetailsTitle") %></h3>
        </div>
        <div class="rv-card-body">
            <dl class="rv-kv cr-facts">
                <div><dt><%: L.T("Coordinator.Review.StudentNumber") %></dt><dd class="rv-num"><%: overview.StudentNumber %></dd></div>
                <div><dt><%: L.T("Coordinator.Review.Program") %></dt><dd><%: ProgramName(student) %>
                    <% if (CourseCode(student, Summary.InternshipType) != null) { %><small><%: L.F("Coordinator.Review.CourseCode", CourseCode(student, Summary.InternshipType)) %></small><% } %>
                    <% if (ProgramNeedsCheck(student)) { %><small class="cr-flag"><%: L.T("Coordinator.Review.ProgramCheckLong") %></small><% } %></dd></div>
                <div><dt><%: L.T("Coordinator.Review.Type") %></dt><dd><%: TypeLabel(Summary.InternshipType) %><% if (Summary.InternshipTypeIsDefault) { %><small><%: L.T("Coordinator.Review.TypeDefaultLong") %></small><% } %></dd></div>
                <div><dt><%: L.T("Coordinator.CompletionReview.Company") %></dt><dd><%: Text(placement.CompanyName) %><small><%: Text(placement.OpportunityTitle) %></small></dd></div>
                <div><dt><%: L.T("Coordinator.CompletionReview.CompanySupervisor") %></dt><dd><%: Text(Progress.CompanySupervisorName) %></dd></div>
                <div><dt><%: L.T("Coordinator.CompletionReview.AcademicSupervisor") %></dt><dd><%: Text(Progress.AcademicSupervisorName) %></dd></div>
                <div><dt><%: L.T("Coordinator.CompletionReview.TrainingPeriod") %></dt><dd><%: Time.DisplayDate(placement.StartDate) %> &ndash; <%: Time.DisplayDate(placement.EndDate) %><% if (Summary.Weeks > 0) { %><small><%: L.F("Coordinator.Review.WeeksValue", Summary.Weeks.ToString("0.#")) %></small><% } %></dd></div>
                <div><dt><%: Summary.IsInternational ? L.T("Coordinator.Review.RequiredDuration") : L.T("Coordinator.Review.RequiredHours") %></dt><dd><%: Summary.IsInternational ? L.F("Coordinator.Review.MinWeeks", InternshipRules.InternationalMinimumWeeks) : L.F("Coordinator.Review.HoursValue", Summary.RequiredHours) %><small><%: Summary.IsInternational ? L.T("Coordinator.Review.DurationSource") : L.T("Coordinator.Review.HoursSource") %></small></dd></div>
                <div><dt><%: L.T("Coordinator.Review.PlacementApproval") %></dt><dd><%: L.Value("PlacementStatus", placement.Status) %><small><%: L.F("Coordinator.Review.ConfirmedOn", Time.DisplayDate(placement.ConfirmedAt)) %></small></dd></div>
                <div><dt><%: L.T("Coordinator.CompletionReview.StudentEmail") %></dt><dd><%: student == null ? L.T("Coordinator.Review.ProfileUnavailable") : Text(student.Email) %></dd></div>
            </dl>
            <asp:Panel ID="pnlType" runat="server" CssClass="cr-type-form">
                <label for="<%= ddlType.ClientID %>"><%: L.T("Coordinator.Review.ChangeType") %></label>
                <asp:DropDownList ID="ddlType" runat="server" CssClass="form-select">
                    <asp:ListItem Value="Local" Text="<%$ Resources:Coordinator, Review.TypeLocal %>" />
                    <asp:ListItem Value="International" Text="<%$ Resources:Coordinator, Review.TypeInternational %>" />
                </asp:DropDownList>
                <asp:Button ID="btnSaveType" runat="server" CssClass="btn btn-outline-secondary" Text="<%$ Resources:Coordinator, Review.SaveType %>" OnClick="SaveType_Click" data-ui-action="save" data-ui-validation="none" />
                <small><%: L.T("Coordinator.Review.TypeHelp") %></small>
            </asp:Panel>
        </div>
    </section>

    <%-- Training record and task evidence --%>
    <section class="rv-card" aria-labelledby="crTrainingTitle" data-rv-reveal>
        <div class="rv-card-head">
            <h3 id="crTrainingTitle"><span class="rv-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></svg></span><%: L.T("Coordinator.Review.TrainingTitle") %></h3>
        </div>
        <div class="rv-card-body">
            <div class="cr-training">
                <div class="cr-training-figure">
                    <% if (Summary.IsInternational) { %>
                        <strong class="rv-num"><bdi dir="ltr"><%: Summary.Weeks.ToString("0.#") %> / <%: InternshipRules.InternationalMinimumWeeks %></bdi> <span><%: L.T("Coordinator.Review.Weeks") %></span></strong>
                        <p><%: L.T("Coordinator.Review.WeeksNote") %></p>
                    <% } else { %>
                        <strong class="rv-num"><bdi dir="ltr"><%: Summary.ApprovedHours %> / <%: Summary.RequiredHours %></bdi> <span><%: L.T("Coordinator.Review.ApprovedHoursUnit") %></span></strong>
                        <p><%: L.F("Coordinator.Review.HoursPercent", TrainingPercent) %></p>
                    <% } %>
                    <div class="rv-meter <%: Summary.TrainingRequirementMet ? "is-complete" : "" %>" role="progressbar" aria-label="<%: L.T("Coordinator.Review.TrainingTitle") %>" aria-valuemin="0" aria-valuemax="100" aria-valuenow="<%: TrainingPercent %>" data-rv-value="<%: TrainingPercent %>" data-rv-pending><span></span></div>
                </div>
                <% if (!Summary.IsInternational) { %>
                <dl class="cr-hours-split">
                    <div><dt><%: L.T("Coordinator.Review.HoursApproved") %></dt><dd class="rv-num"><%: Summary.ApprovedHours %> h</dd></div>
                    <div><dt><%: L.T("Coordinator.Review.HoursPending") %></dt><dd class="rv-num"><%: Summary.PendingHours %> h</dd></div>
                    <div><dt><%: L.T("Coordinator.Review.HoursRejected") %></dt><dd class="rv-num"><%: RejectedHours %> h</dd></div>
                </dl>
                <% } %>
            </div>
            <h4 class="cr-subtitle"><%: L.F("Coordinator.Review.TaskEvidence", Summary.TasksGraded, Summary.TasksTotal) %></h4>
            <% if (Progress.Tasks.Count == 0) { %>
                <div class="rv-empty"><%: L.T("Coordinator.Req.NoTasks") %></div>
            <% } else { %>
            <div class="rv-table-scroll" tabindex="0" role="region" aria-label="<%: L.T("Coordinator.Review.TaskEvidenceLabel") %>">
                <table class="rv-table">
                    <thead><tr><th scope="col"><%: L.T("Coordinator.Review.Task") %></th><th scope="col"><%: L.T("Coordinator.Review.Deadline") %></th><th scope="col"><%: L.T("Coordinator.Review.Status") %></th><th scope="col"><%: L.T("Coordinator.Review.Attempts") %></th><th scope="col"><%: L.T("Coordinator.Review.Grade") %></th></tr></thead>
                    <tbody>
                    <% foreach (var task in Progress.Tasks) { %>
                        <tr><td><strong><%: Text(task.Title) %></strong></td><td class="rv-num"><%: Time.DisplayDate(task.Deadline) %></td><td><span class="<%: TaskStatusCss(task.Status) %>"><%: TaskStatusLabel(task.Status) %></span></td><td class="rv-num"><%: Attempts(task) %></td><td class="rv-num"><strong><%: TaskGrade(task) %></strong></td></tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
            <% } %>
        </div>
    </section>

    <%-- Both final evaluations (confidential: coordinator access only) --%>
    <div class="cr-eval-grid">
        <section class="rv-card cr-eval" aria-labelledby="crCompanyTitle" data-rv-reveal>
            <div class="rv-card-head">
                <div><h3 id="crCompanyTitle"><span class="rv-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><rect x="3" y="7" width="18" height="14" rx="2"/><path d="M8 7V5a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg></span><%: L.T("Coordinator.CompletionReview.CompanyFinalEvaluation") %></h3><p><%: L.T("Coordinator.Review.Confidential") %></p></div>
                <span class="rv-badge <%: Summary.CompanySubmitted ? "is-done" : Progress.CompanyFinal == null ? "is-pending" : "is-attention" %>"><%: Summary.CompanySubmitted ? L.T("Coordinator.Review.Submitted") : Progress.CompanyFinal == null ? L.T("Coordinator.Review.NotStarted") : L.T("Coordinator.Review.Draft") %></span>
            </div>
            <div class="rv-card-body">
            <% if (!Summary.CompanySubmitted) { %>
                <div class="rv-empty"><%: L.T("Coordinator.CompletionReview.TheCompanyFinalEvaluationHasNot") %></div>
            <% } else { var final = Progress.CompanyFinal; %>
                <div class="cr-score"><strong class="rv-num"><%: Score(final.TotalScore, final.MaxScore) %></strong><span class="rv-num"><%: Percent(Summary.CompanyPercent) %></span></div>
                <p class="rv-note"><%: L.F("Coordinator.Review.EvaluatedBy", Text(Progress.CompanySupervisorName), L.T("Coordinator.Review.RoleCompany"), Time.Display(final.SubmittedAt)) %> &middot; <%: final.ReportedTotalHours %> <%: L.T("Coordinator.CompletionReview.HReportedByTheCompany") %></p>
                <div class="cr-criteria-scroll"><table class="cr-criteria"><thead><tr><th scope="col"><%: L.T("Coordinator.Review.Criterion") %></th><th scope="col"><%: L.T("Coordinator.Review.Rating") %></th><th scope="col"><%: L.T("Coordinator.CompletionReview.Weight") %></th></tr></thead><tbody>
                <% foreach (var c in Components(final.Components)) { %><tr><td><%: c.Name %></td><td class="rv-num cr-crit-score"><%: Score(c.Score, c.MaxScore) %><div class="rv-meter is-thin" aria-hidden="true" data-rv-value="<%: c.MaxScore > 0 ? (int)Math.Min(100, c.Score * 100 / c.MaxScore) : 0 %>" data-rv-pending><span></span></div></td><td class="rv-num"><%: c.Weight %>%</td></tr><% } %>
                </tbody></table></div>
                <dl class="cr-comments">
                    <div><dt><%: L.T("Coordinator.CompletionReview.Strengths") %></dt><dd><%: Text(final.Strengths) %></dd></div>
                    <div><dt><%: L.T("Coordinator.CompletionReview.AreasForImprovement") %></dt><dd><%: Text(final.AreasForImprovement) %></dd></div>
                    <div><dt><%: L.T("Coordinator.CompletionReview.OverallComment") %></dt><dd><%: Text(final.OverallComment) %></dd></div>
                </dl>
            <% } %>
            </div>
        </section>
        <section class="rv-card cr-eval" aria-labelledby="crAcademicTitle" data-rv-reveal>
            <div class="rv-card-head">
                <div><h3 id="crAcademicTitle"><span class="rv-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M22 10 12 5 2 10l10 5 10-5z"/><path d="M6 12v5c3 2 9 2 12 0v-5"/></svg></span><%: L.T("Coordinator.CompletionReview.AcademicFinalEvaluation") %></h3><p><%: L.T("Coordinator.Review.Confidential") %></p></div>
                <span class="rv-badge <%: Summary.AcademicSubmitted ? "is-done" : Progress.AcademicFinal == null ? "is-pending" : "is-attention" %>"><%: Summary.AcademicSubmitted ? L.T("Coordinator.Review.Submitted") : Progress.AcademicFinal == null ? L.T("Coordinator.Review.NotStarted") : L.T("Coordinator.Review.Draft") %></span>
            </div>
            <div class="rv-card-body">
            <% if (!Summary.AcademicSubmitted) { %>
                <div class="rv-empty"><%: L.T("Coordinator.CompletionReview.TheAcademicFinalEvaluationHasNot") %></div>
            <% } else { var final = Progress.AcademicFinal; %>
                <div class="cr-score"><strong class="rv-num"><%: Score(final.TotalScore, final.MaxScore) %></strong><span class="rv-num"><%: Percent(Summary.AcademicPercent) %></span></div>
                <p class="rv-note"><%: L.F("Coordinator.Review.EvaluatedBy", Text(Progress.AcademicSupervisorName), L.T("Coordinator.Review.RoleAcademic"), Time.Display(final.SubmittedAt)) %></p>
                <div class="cr-criteria-scroll"><table class="cr-criteria"><thead><tr><th scope="col"><%: L.T("Coordinator.Review.Criterion") %></th><th scope="col"><%: L.T("Coordinator.Review.Rating") %></th><th scope="col"><%: L.T("Coordinator.CompletionReview.Weight") %></th></tr></thead><tbody>
                <% foreach (var c in Components(final.Components)) { %><tr><td><%: c.Name %></td><td class="rv-num cr-crit-score"><%: Score(c.Score, c.MaxScore) %><div class="rv-meter is-thin" aria-hidden="true" data-rv-value="<%: c.MaxScore > 0 ? (int)Math.Min(100, c.Score * 100 / c.MaxScore) : 0 %>" data-rv-pending><span></span></div></td><td class="rv-num"><%: c.Weight %>%</td></tr><% } %>
                </tbody></table></div>
                <dl class="cr-comments">
                    <div><dt><%: L.T("Coordinator.CompletionReview.AcademicComments") %></dt><dd><%: Text(final.AcademicComments) %></dd></div>
                    <div><dt><%: L.T("Coordinator.CompletionReview.RemarksOnTheCompanyEvaluation") %></dt><dd><%: Text(final.CompanyEvaluationRemarks) %></dd></div>
                </dl>
            <% } %>
            </div>
        </section>
    </div>

    <%-- Provisional result: project-proposed method, separate from approval --%>
    <section class="rv-card" aria-labelledby="crResultTitle" data-rv-reveal>
        <div class="rv-card-head">
            <div><h3 id="crResultTitle"><span class="rv-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M4 20V10"/><path d="M10 20V4"/><path d="M16 20v-7"/><path d="M22 20H2"/></svg></span><%: L.T("Coordinator.Review.ResultTitle") %></h3><p><%: L.T("Coordinator.Review.ResultNote") %></p></div>
            <span class="<%: SourceCss(EvaluationMethod.Source) %>"><%: SourceLabel(EvaluationMethod.Source) %> &middot; <%: EvaluationMethod.Id %></span>
        </div>
        <div class="rv-table-scroll" tabindex="0" role="region" aria-labelledby="crResultTitle">
            <table class="rv-table">
                <thead><tr><th scope="col"><%: L.T("Coordinator.CompletionReview.Component") %></th><th scope="col"><%: L.T("Coordinator.Review.Scale") %></th><th scope="col"><%: L.T("Coordinator.CompletionReview.Score") %></th><th scope="col"><%: L.T("Coordinator.CompletionReview.Weight") %></th><th scope="col"><%: L.T("Coordinator.CompletionReview.Points") %></th></tr></thead>
                <tbody>
                    <tr><td><%: L.T("Coordinator.CompletionReview.GradedTasks") %></td><td><%: L.T("Coordinator.Review.ScaleTasks") %></td><td class="rv-num"><%: Summary.TasksGraded > 0 ? Percent(Summary.TaskPercent) : "—" %></td><td class="rv-num"><%: GradingPolicy.TaskComponentWeight %>%</td><td class="rv-num"><%: Weighted(Summary.TaskPercent, GradingPolicy.TaskComponentWeight) %></td></tr>
                    <tr><td><%: L.T("Coordinator.CompletionReview.CompanyFinalEvaluation") %></td><td class="rv-num"><%: Summary.CompanySubmitted ? Score(Progress.CompanyFinal.TotalScore, Progress.CompanyFinal.MaxScore) : "—" %></td><td class="rv-num"><%: Summary.CompanySubmitted ? Percent(Summary.CompanyPercent) : "—" %></td><td class="rv-num"><%: GradingPolicy.CompanyFinalWeight %>%</td><td class="rv-num"><%: Weighted(Summary.CompanyPercent, GradingPolicy.CompanyFinalWeight) %></td></tr>
                    <tr><td><%: L.T("Coordinator.CompletionReview.AcademicFinalEvaluation") %></td><td class="rv-num"><%: Summary.AcademicSubmitted ? Score(Progress.AcademicFinal.TotalScore, Progress.AcademicFinal.MaxScore) : "—" %></td><td class="rv-num"><%: Summary.AcademicSubmitted ? Percent(Summary.AcademicPercent) : "—" %></td><td class="rv-num"><%: GradingPolicy.AcademicFinalWeight %>%</td><td class="rv-num"><%: Weighted(Summary.AcademicPercent, GradingPolicy.AcademicFinalWeight) %></td></tr>
                </tbody>
            </table>
        </div>
        <div class="cr-result">
            <div><span><%: L.T("Coordinator.Review.ProvisionalScore") %></span><strong class="rv-num"><%: Summary.EvaluationsReady ? Percent(Summary.FinalPercent) : "—" %></strong></div>
            <div><span><%: L.T("Coordinator.Review.ProvisionalResult") %></span><strong class="<%: !Summary.EvaluationsReady ? "" : Summary.Passing ? "is-pass" : "is-fail" %>"><%: Summary.EvaluationsReady ? (Summary.Passing ? L.T("Coordinator.Review.Pass") : L.T("Coordinator.Review.Fail")) : L.T("Coordinator.Review.Pending") %></strong></div>
            <p class="rv-note"><%: L.F("Coordinator.Review.ResultExplain", GradingPolicy.PassMarkPercent) %></p>
        </div>
    </section>

    <%-- Requirement checklist --%>
    <section class="rv-card" aria-labelledby="crChecksTitle" data-rv-reveal>
        <div class="rv-card-head">
            <div><h3 id="crChecksTitle"><span class="rv-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M9 11l3 3 8-8"/><path d="M20 12v7a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h9"/></svg></span><%: L.F("Coordinator.Review.ChecksTitle", TypeLabel(Summary.InternshipType)) %></h3><p><%: L.T("Coordinator.Review.ChecksNote") %></p></div>
            <span class="rv-badge <%: Summary.CanApprove ? "is-done" : "is-pending" %>"><%: L.F("Coordinator.Review.RequirementsValue", Summary.MandatoryMet, Summary.MandatoryTotal) %></span>
        </div>
        <ol class="cr-checks">
        <% foreach (var item in Summary.Items.Where(i => !i.Manual)) { %>
            <li class="<%: item.Satisfied ? "is-ok" : "is-missing" %>">
                <span class="cr-check-mark" aria-hidden="true"></span>
                <div class="cr-check-body">
                    <div class="cr-check-title"><strong><%: item.Title %></strong><span class="<%: SourceCss(item.Source) %>"><%: SourceLabel(item.Source) %></span><span class="cr-auto"><%: L.T("Coordinator.Review.Automatic") %></span></div>
                    <small><%: item.Detail %></small>
                </div>
                <span class="<%: StateCss(item.State) %>"><%: StateLabel(item.State) %></span>
            </li>
        <% } %>
        <% if (!IsEditable) { foreach (var item in Summary.Items.Where(i => i.Manual)) { %>
            <li class="<%: item.Satisfied ? "is-ok" : "is-missing" %>">
                <span class="cr-check-mark" aria-hidden="true"></span>
                <div class="cr-check-body">
                    <div class="cr-check-title"><strong><%: item.Title %></strong><span class="<%: SourceCss(item.Source) %>"><%: SourceLabel(item.Source) %></span></div>
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
                            <div class="cr-check-title"><strong><%#: ((RequirementItem)Container.DataItem).Title %></strong><span class='<%#: SourceCss(((RequirementItem)Container.DataItem).Source) %>'><%#: SourceLabel(((RequirementItem)Container.DataItem).Source) %></span></div>
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
                <asp:Button ID="btnSaveChecks" runat="server" CssClass="btn btn-outline-primary" Text="<%$ Resources:Coordinator, Review.SaveChecks %>" OnClick="SaveChecks_Click" data-ui-action="save" data-ui-validation="none" />
                <small class="rv-note"><%: L.T("Coordinator.Review.SaveChecksNote") %></small>
            </div>
        </asp:Panel>
    </section>

    </div><%-- /cr-main --%>
    <aside class="cr-aside">

    <%-- Decision and documents --%>
    <section class="rv-card cr-decision <%: IsApproved ? "is-approved" : IsRejectedFinal ? "is-rejected" : "" %>" id="crDecision" aria-labelledby="crDecisionTitle" data-rv-reveal>
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
                        <div><dt><%: L.T("Coordinator.Review.Reference") %></dt><dd class="rv-num"><%: PdfReportService.Reference(record) %><small><%: Text(record.EvaluationMethod) %></small></dd></div>
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
