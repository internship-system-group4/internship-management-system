<%@ Page Language="C#" MasterPageFile="~/Layout/Student.master" AutoEventWireup="true" CodeBehind="Progress.aspx.cs" Inherits="InternshipManagementSystem.Pages.StudentArea.Progress" Title="My Progress & Evaluation" %>
<%-- ===================================================================
     My Progress & Evaluation
     Owner : Ahmad
     Cards : A15, A16
     Journey, task grades and feedback, submission/revision history,
     approved hours, requirement and document status, and the report once
     the coordinator approves completion. The confidential final evaluation
     forms are never shown here.
     =================================================================== --%>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <script>document.documentElement.classList.add('rv-js');setTimeout(function(){if(!window.UimsReview)document.documentElement.classList.remove('rv-js');},2500);</script>
    <link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/review-system.css?v=20261024-qa-20261024-8") %>" />
    <link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/student-progress.css?v=20261024-qa-20261024-8") %>" />
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="rv-scope pg-page">

    <header class="rv-heading student-workspace-hero" data-rv-reveal>
        <div>
            <span class="rv-eyebrow"><%: L.T("Student.Progress.Eyebrow") %></span>
            <h2><%: L.T("Student.Progress.MyProgressEvaluation") %></h2>
            <p><%: L.T("Student.Progress.YourTaskGradesSupervisorFeedbackApproved") %></p>
        </div>
        <span class="student-hero-metric"><strong><bdi dir="ltr"><%: CompletedRun %> / <%: Journey.Count %></bdi></strong><span><%: L.T("Student.Workspace.JourneyCompletion") %></span></span>
    </header>

    <% if (LoadFailed) { %>
        <div class="rv-alert is-error" role="alert"><div><%: L.T("Student.Progress.YourProgressCouldNotBeLoaded") %><% if (LoadErrorDetail != null) { %><div class="small mt-2"><%: LoadErrorDetail %></div><% } %></div></div>
    <% } else if (!HasPlacement) { %>
        <section class="rv-card pg-empty" data-rv-reveal>
            <span class="pg-empty-art" aria-hidden="true"><svg viewBox="0 0 24 24"><rect x="3" y="7" width="18" height="14" rx="2"/><path d="M8 7V5a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/><path d="M3 13h18"/></svg></span>
            <div>
                <h3><%: L.T("Student.Progress.NoConfirmedInternshipYet") %></h3>
                <p><%: L.T("Student.Progress.YourProgressAndEvaluationsWillAppear") %></p>
                <a class="btn btn-brand" href="<%: ResolveUrl("~/Pages/Student/MyApplications.aspx") %>"><%: L.T("Student.Progress.GoToMyApplications") %></a>
            </div>
        </section>
    <% } else { %>

    <% if (Problems.Count > 0) { %>
        <div class="rv-alert is-warning" role="status"><div><%: L.T("Student.Progress.SomeSectionsCouldNotBeLoaded") %><ul class="mb-0 mt-1"><% foreach (var p in Problems) { %><li><%: p %></li><% } %></ul></div></div>
    <% } %>

    <%-- ================= My Internship Journey ================= --%>
    <section class="rv-card pg-journey" aria-labelledby="pgJourneyTitle" data-rv-reveal>
        <div class="rv-card-head">
            <div><h3 id="pgJourneyTitle"><%: L.T("Student.Progress.JourneyTitle") %></h3><p><%: L.T("Student.Progress.JourneyNote") %></p></div>
            <span class="rv-badge is-<%: CurrentStep.State == StepDone ? "done" : CurrentStep.State == StepRejected ? "rejected" : CurrentStep.State == StepAttention ? "attention" : CurrentStep.State == StepActive ? "active" : "pending" %>"><%: L.T("Student.Progress.Now") %>: <%: CurrentStep.Title %></span>
        </div>
        <div class="rv-card-body">
            <div class="pg-track" style="--pg-steps:<%: Journey.Count %>">
                <div class="pg-line" aria-hidden="true"><span style="--pg-fill:<%: (JourneyPercent / 100.0).ToString(System.Globalization.CultureInfo.InvariantCulture) %>"></span></div>
                <ol class="pg-steps" aria-label="<%: L.F("Student.Progress.JourneyAria", CompletedRun, Journey.Count) %>">
                <% for (int i = 0; i < Journey.Count; i++) { var step = Journey[i]; %>
                    <li class="pg-step is-<%: step.State %>" data-rv-reveal style="--rv-i:<%: i + 1 %>" tabindex="0" aria-describedby="pgHint<%: i %>">
                        <span class="pg-node" aria-hidden="true">
                            <svg class="pg-glyph" viewBox="0 0 24 24"><%= Glyph(step.Key) %></svg>
                            <span class="pg-state-dot"><svg viewBox="0 0 16 16"><%= StateGlyph(step.State) %></svg></span>
                        </span>
                        <span class="pg-step-text">
                            <span class="pg-step-index"><%: L.F("Student.Progress.StepNumber", i + 1) %></span>
                            <strong><%: step.Title %></strong>
                            <span class="pg-step-state"><%: StepLabel(step.State) %></span>
                            <small><%: step.Detail %></small>
                        </span>
                        <span class="pg-hint" id="pgHint<%: i %>" role="tooltip"><%: step.Hint %></span>
                    </li>
                <% } %>
                </ol>
            </div>
            <p class="rv-note pg-journey-note"><%: L.T("Student.Progress.JourneyDisclaimer") %></p>
        </div>
    </section>

    <%-- ================= Summary ================= --%>
    <div class="pg-stats">
        <div class="rv-card is-lift pg-stat" data-rv-reveal>
            <span class="rv-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></svg></span>
            <span class="pg-stat-label"><%: L.T("Student.Progress.ApprovedHours") %></span>
            <strong class="rv-num"><% if (IsInternational) { %><bdi dir="ltr"><%: Weeks.ToString("0.#") %><small> / <%: InternshipRules.InternationalMinimumWeeks %></small></bdi><small> <%: L.T("Student.Progress.WeeksUnit") %></small><% } else { %><bdi dir="ltr"><span data-rv-count="<%: ApprovedHours %>"><%: ApprovedHours %></span><small> / <%: RequiredHours %> h</small></bdi><% } %></strong>
            <% if (!IsInternational) { %><div class="rv-meter is-thin <%: TrainingMet ? "is-complete" : "" %>" role="progressbar" aria-label="<%: L.T("Student.Progress.ApprovedHoursProgress") %>" aria-valuemin="0" aria-valuemax="<%: RequiredHours %>" aria-valuenow="<%: Math.Min(ApprovedHours, Math.Max(RequiredHours, 0)) %>" aria-valuetext="<%: L.F("Student.Progress.HoursValueText", ApprovedHours, RequiredHours, HoursPercent) %>" data-rv-value="<%: HoursPercent %>" data-rv-pending><span></span></div><% } %>
            <small class="pg-stat-note"><%: IsInternational ? L.T("Student.Progress.WeeksFromDates") : L.F("Student.Progress.PercentOfRequired", HoursPercent) %></small>
        </div>
        <div class="rv-card is-lift pg-stat" data-rv-reveal>
            <span class="rv-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M9 11l3 3 8-8"/><path d="M20 12v7a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h9"/></svg></span>
            <span class="pg-stat-label"><%: L.T("Student.Progress.TasksGraded") %></span>
            <strong class="rv-num"><bdi dir="ltr"><span data-rv-count="<%: TasksGraded %>"><%: TasksGraded %></span><small> / <%: TasksTotal %></small></bdi></strong>
            <small class="pg-stat-note"><%: L.T("Student.Progress.GradedOutOfAssigned") %></small>
        </div>
        <div class="rv-card is-lift pg-stat <%: OpenRevisions > 0 ? "is-attention" : "" %>" data-rv-reveal>
            <span class="rv-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M3 12a9 9 0 1 0 3-6.7"/><path d="M3 4v5h5"/></svg></span>
            <span class="pg-stat-label"><%: L.T("Student.Progress.OpenRevisions") %></span>
            <strong class="rv-num"><span data-rv-count="<%: OpenRevisions %>"><%: OpenRevisions %></span></strong>
            <small class="pg-stat-note"><%: L.T("Student.Progress.TasksWaitingForYourResubmission") %></small>
        </div>
        <div class="rv-card is-lift pg-stat" data-rv-reveal>
            <span class="rv-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M4 20V10"/><path d="M10 20V4"/><path d="M16 20v-7"/><path d="M22 20H2"/></svg></span>
            <span class="pg-stat-label"><%: L.T("Student.Progress.TaskGradeAverage") %></span>
            <strong class="rv-num"><%: AverageText %></strong>
            <small class="pg-stat-note"><%: L.T("Student.Progress.AverageNote") %></small>
        </div>
    </div>

    <%-- ================= My Internship ================= --%>
    <section class="rv-card" aria-labelledby="pgInternshipTitle" data-rv-reveal>
        <div class="rv-card-head"><h3 id="pgInternshipTitle"><span class="rv-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><rect x="3" y="7" width="18" height="14" rx="2"/><path d="M8 7V5a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg></span><%: L.T("Student.Progress.MyInternship") %></h3></div>
        <div class="rv-card-body">
            <dl class="rv-kv">
                <div><dt><%: L.T("Student.Progress.InternshipType") %></dt><dd><%: TypeLabel %><% if (TypeIsDefault) { %><small><%: L.T("Student.Progress.TypeDefault") %></small><% } %></dd></div>
                <div><dt><%: L.T("Student.Progress.AcademicProgram") %></dt><dd><%: ProgramLabel %><% if (Program != null && !IsInternational) { %><small><%: L.F("Student.Progress.CourseCode", Program.LocalCourse) %></small><% } else if (Program == null) { %><small><%: L.T("Student.Progress.ProgramCheck") %></small><% } %></dd></div>
                <div><dt><%: L.T("Student.Progress.Opportunity") %></dt><dd><%: Placement.OpportunityTitle ?? "—" %></dd></div>
                <div><dt><%: L.T("Student.Progress.Company") %></dt><dd><%: Placement.CompanyName ?? "—" %></dd></div>
                <div><dt><%: L.T("Student.Progress.CompanySupervisor") %></dt><dd><%: Placement.CompanySupervisorName ?? "—" %></dd></div>
                <div><dt><%: L.T("Student.Progress.AcademicSupervisor") %></dt><dd><%: AcademicSupervisorName %></dd></div>
                <div><dt><%: L.T("Student.Progress.TrainingPeriod") %></dt><dd><%: Time.DisplayDate(Placement.StartDate) %> &ndash; <%: Time.DisplayDate(Placement.EndDate) %><% if (Weeks > 0) { %><small><%: L.F("Student.Progress.WeeksValue", Weeks.ToString("0.#")) %></small><% } %></dd></div>
                <div><dt><%: L.T("Student.Progress.PlacementStatus") %></dt><dd><%: L.Value("PlacementStatus", Placement.Status) %><small><%: L.F("Student.Progress.ConfirmedOn", Time.DisplayDate(Placement.ConfirmedAt)) %></small></dd></div>
                <div><dt><%: L.T("Student.Progress.CurrentStatus") %></dt><dd><%: CurrentStep.Title %><small><%: StepLabel(CurrentStep.State) %></small></dd></div>
                <div><dt><%: L.T("Student.Progress.ApplicableRequirement") %></dt><dd><%: RequirementLabel %><small><%: IsInternational ? L.T("Student.Progress.RequirementSourceIntl") : L.T("Student.Progress.RequirementSourceLocal") %></small></dd></div>
            </dl>
        </div>
    </section>

    <%-- ================= Task evaluations ================= --%>
    <section class="rv-card" aria-labelledby="pgTasksTitle" data-rv-reveal>
        <div class="rv-card-head">
            <div><h3 id="pgTasksTitle"><span class="rv-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M9 11l3 3 8-8"/><path d="M20 12v7a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h9"/></svg></span><%: L.T("Student.Progress.TaskEvaluationsFeedback") %></h3><p><%: L.T("Student.Progress.EachTaskIsGradedOutOf") %></p></div>
            <a class="rv-link" href="<%: ResolveUrl("~/Pages/Student/MyTasks.aspx") %>"><%: L.T("Student.Progress.OpenMyTasks") %></a>
        </div>
        <% if (Tasks.Count == 0) { %>
            <div class="rv-card-body"><div class="rv-empty"><%: L.T("Student.Progress.NoTasksHaveBeenAssignedTo") %></div></div>
        <% } else { %>
        <div class="rv-table-scroll" tabindex="0" role="region" aria-labelledby="pgTasksTitle">
            <table class="rv-table pg-task-table">
                <thead><tr>
                    <th scope="col"><%: L.T("Student.Progress.Task") %></th>
                    <th scope="col"><%: L.T("Student.Progress.Deadline") %></th>
                    <th scope="col"><%: L.T("Student.Progress.Status") %></th>
                    <th scope="col"><%: L.T("Student.Progress.Attempts") %></th>
                    <th scope="col"><%: L.T("Student.Progress.Grade") %></th>
                    <th scope="col"><%: L.T("Student.Progress.SupervisorFeedback") %></th>
                </tr></thead>
                <tbody>
                <% foreach (var row in Tasks) { %>
                    <tr>
                        <td><strong><%: row.Title %></strong></td>
                        <td class="rv-num"><%: row.Deadline %><% if (!string.IsNullOrEmpty(row.DueText)) { %><small class="pg-due <%: row.DueCss %>"><%: row.DueText %></small><% } %></td>
                        <td><span class="<%: row.StatusCss %>"><%: row.Status %></span></td>
                        <td class="rv-num"><%: row.Attempts %></td>
                        <td class="pg-grade">
                            <strong class="rv-num"><%: row.Grade %></strong><% if (!string.IsNullOrEmpty(row.GradePercent)) { %> <span class="pg-percent rv-num"><%: row.GradePercent %></span><% } %>
                            <% if (!string.IsNullOrEmpty(row.Scale)) { %><small><%: row.Scale %></small><% } %>
                            <% if (row.Criteria.Count > 0) { %><ul class="pg-criteria"><% foreach (var c in row.Criteria) { %><li><%: c %></li><% } %></ul><% } %>
                        </td>
                        <td class="pg-feedback">
                            <% if (row.Feedback == null) { %><span class="pg-muted"><%: L.T("Student.Progress.NoFeedbackYet") %></span>
                            <% } else if (row.IsRevision) { %><span class="pg-revision"><b><%: L.T("Student.Progress.RevisionRequested") %>:</b> <%: row.Feedback %></span>
                            <% } else { %><%: row.Feedback %><% } %>
                        </td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </div>
        <% } %>
    </section>

    <%-- ================= Submission & revision history ================= --%>
    <section class="rv-card" aria-labelledby="pgHistoryTitle" data-rv-reveal>
        <div class="rv-card-head"><div><h3 id="pgHistoryTitle"><span class="rv-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M3 12a9 9 0 1 0 3-6.7"/><path d="M3 4v5h5"/><path d="M12 7v5l3 2"/></svg></span><%: L.T("Student.Progress.SubmissionsRevisionHistory") %></h3><p><%: L.F("Student.Progress.HistoryNote", Attempts.Count) %></p></div></div>
        <div class="rv-card-body">
        <% if (Attempts.Count == 0) { %>
            <div class="rv-empty"><div><%: L.T("Student.Progress.YouHaveNotSubmittedAnyWork") %> <a href="<%: ResolveUrl("~/Pages/Student/MyTasks.aspx") %>"><%: L.T("Student.Progress.MyTasks") %></a>.</div></div>
        <% } else { %>
            <ol class="pg-timeline">
            <% for (int i = 0; i < Attempts.Count; i++) { var a = Attempts[i]; %>
                <li class="is-<%: a.Tone %>" data-rv-reveal style="--rv-i:<%: Math.Min(i, 8) %>">
                    <span class="pg-timeline-dot" aria-hidden="true"></span>
                    <div class="pg-timeline-card">
                        <div class="pg-timeline-head"><strong><%: a.TaskTitle %></strong><span class="pg-attempt rv-num"><%: L.F("Student.Progress.AttemptNumber", a.Attempt) %></span><span class="rv-badge is-<%: a.Tone %>"><%: a.Outcome %></span></div>
                        <small class="rv-num"><%: L.T("Student.Progress.Submitted") %> <%: a.SubmittedAt %></small>
                        <% if (!string.IsNullOrEmpty(a.Details)) { %><p><%: a.Details %></p><% } %>
                        <% if (!string.IsNullOrWhiteSpace(a.Feedback)) { %><p class="pg-muted"><%: a.Feedback %></p><% } %>
                    </div>
                </li>
            <% } %>
            </ol>
        <% } %>
        </div>
    </section>

    <%-- ================= Training hours ================= --%>
    <section class="rv-card" aria-labelledby="pgHoursTitle" data-rv-reveal>
        <div class="rv-card-head"><div><h3 id="pgHoursTitle"><span class="rv-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></svg></span><%: L.T("Student.Progress.TrainingHours") %></h3><p><%: L.T("Student.Progress.OnlyHoursApprovedByYourSupervisor") %></p></div></div>
        <div class="rv-card-body">
            <div class="pg-hours">
                <div class="pg-hours-main">
                    <strong class="rv-num"><%: L.F("Student.Progress.HoursOfRequired", ApprovedHours, RequiredHours) %></strong>
                    <p><%: RequiredHours > 0 ? L.F("Student.Progress.PercentOfRequired", HoursPercent) : L.T("Student.Progress.TargetNotSet") %></p>
                    <div class="rv-meter <%: RequiredHours > 0 && ApprovedHours >= RequiredHours ? "is-complete" : "" %>" role="progressbar" aria-label="<%: L.T("Student.Progress.ApprovedHoursProgress") %>" aria-valuemin="0" aria-valuemax="<%: RequiredHours %>" aria-valuenow="<%: Math.Min(ApprovedHours, Math.Max(RequiredHours, 0)) %>" aria-valuetext="<%: L.F("Student.Progress.HoursValueText", ApprovedHours, RequiredHours, HoursPercent) %>" data-rv-value="<%: HoursPercent %>" data-rv-pending><span></span></div>
                    <% if (IsInternational) { %><p class="rv-note pg-intl-note"><%: L.T("Student.Progress.HoursInternationalNote") %></p><% } %>
                </div>
                <dl class="pg-hours-split">
                    <div class="is-done"><dt><%: L.T("Student.Progress.Approved") %></dt><dd class="rv-num"><%: ApprovedHours %> h</dd></div>
                    <div class="is-pending"><dt><%: L.T("Student.Progress.PendingApproval") %></dt><dd class="rv-num"><%: PendingHours %> h</dd></div>
                    <div class="is-rejected"><dt><%: L.T("Student.Progress.Rejected") %></dt><dd class="rv-num"><%: RejectedHours %> h</dd></div>
                </dl>
            </div>
            <% if (CanReportHours) { %>
            <div class="pg-report-hours">
                <div><h4><%: L.T("Student.Progress.LogHours") %></h4><p><%: L.T("Student.Progress.LogHoursHint") %></p></div>
                <div class="pg-report-hours-grid">
                    <div><asp:Label ID="lblWorkDate" runat="server" AssociatedControlID="txtWorkDate" Text="<%$ Resources:Student, Progress.WorkDate %>" /><asp:TextBox ID="txtWorkDate" runat="server" TextMode="Date" CssClass="form-control" required="required" /></div>
                    <div><asp:Label ID="lblWorkedHours" runat="server" AssociatedControlID="txtWorkedHours" Text="<%$ Resources:Student, Progress.HoursWorked %>" /><asp:TextBox ID="txtWorkedHours" runat="server" TextMode="Number" CssClass="form-control" min="1" max="24" required="required" /></div>
                    <div class="pg-report-description"><asp:Label ID="lblWorkDescription" runat="server" AssociatedControlID="txtWorkDescription" Text="<%$ Resources:Student, Progress.WorkDescription %>" /><asp:TextBox ID="txtWorkDescription" runat="server" TextMode="MultiLine" Rows="2" MaxLength="500" CssClass="form-control" required="required" /></div>
                    <div class="pg-report-submit"><asp:Button ID="btnReportHours" runat="server" Text="<%$ Resources:Student, Progress.SubmitHours %>" CssClass="btn btn-primary" OnClick="btnReportHours_Click" /></div>
                </div>
                <asp:Label ID="lblHoursMessage" runat="server" Visible="false" EnableViewState="false" role="status" />
            </div>
            <% } else { %>
            <p class="rv-note pg-intl-note"><%: L.T("Student.Progress.HoursReportingClosed") %></p>
            <% } %>
            <% if (HoursLog.Count == 0) { %>
                <div class="rv-empty"><%: L.T("Student.Progress.NoTrainingHoursHaveBeenRecorded") %></div>
            <% } else { %>
            <details class="pg-log" <%: HoursLog.Count <= 6 ? "open" : "" %>>
                <summary><%: L.F("Student.Progress.HoursLog", HoursLog.Count) %></summary>
                <div class="rv-table-scroll" tabindex="0" role="region" aria-labelledby="pgHoursTitle">
                    <table class="rv-table">
                        <thead><tr><th scope="col"><%: L.T("Student.Progress.Date") %></th><th scope="col"><%: L.T("Student.Progress.Hours") %></th><th scope="col"><%: L.T("Student.Progress.Description") %></th><th scope="col"><%: L.T("Student.Progress.Status") %></th><th scope="col"><%: L.T("Student.Progress.ReviewerNote") %></th></tr></thead>
                        <tbody>
                        <% foreach (var h in HoursLog) { %>
                            <tr><td class="rv-num"><%: h.Date %></td><td class="rv-num"><%: h.Hours %></td><td><%: h.Description %></td><td><span class="<%: h.StatusCss %>"><%: h.Status %></span></td><td><%: h.Note %></td></tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </details>
            <% } %>
        </div>
    </section>

    <%-- ================= Requirements & documents ================= --%>
    <section class="rv-card" aria-labelledby="pgDocsTitle" data-rv-reveal>
        <div class="rv-card-head"><div><h3 id="pgDocsTitle"><span class="rv-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M14 3H6a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z"/><path d="M14 3v6h6"/><path d="m9 15 2 2 4-4"/></svg></span><%: L.T("Student.Progress.DocsTitle") %></h3><p><%: L.T("Student.Progress.DocsNote") %></p></div></div>
        <ul class="pg-docs">
        <% foreach (var d in Docs) { %>
            <li class="is-<%: d.State %>">
                <span class="pg-doc-mark" aria-hidden="true"></span>
                <div><strong><%: d.Title %></strong><% if (!string.IsNullOrEmpty(d.Detail)) { %><small><%: d.Detail %></small><% } %></div>
                <span class="<%: DocCss(d.State) %>"><%: DocLabel(d.State) %></span>
            </li>
        <% } %>
        </ul>
    </section>

    <%-- ================= Completion & official report ================= --%>
    <section class="rv-card pg-final <%: Released ? "is-released" : "" %>" aria-labelledby="pgFinalTitle" data-rv-reveal>
        <div class="rv-card-head"><div><h3 id="pgFinalTitle"><span class="rv-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><circle cx="12" cy="9" r="6"/><path d="M8.5 14.5 7 22l5-3 5 3-1.5-7.5"/></svg></span><%: L.T("Student.Progress.InternshipCompletionOfficialReport") %></h3><p><%: L.T("Student.Progress.FinalNote") %></p></div></div>
        <div class="rv-card-body">
            <dl class="pg-final-grid">
                <div><dt><%: L.T("Student.Progress.TileProgress") %></dt><dd><%: L.F("Student.Progress.JourneyAria", CompletedRun, Journey.Count) %></dd></div>
                <div><dt><%: L.T("Student.Progress.TileProvisional") %></dt><dd><%: Released ? L.T("Student.Progress.ProvisionalReleased") : L.T("Student.Progress.ProvisionalHidden") %></dd></div>
                <div><dt><%: L.T("Student.Progress.TileApproval") %></dt><dd><%: CompletionApprovalText %></dd></div>
                <div class="<%: Released ? "is-result" : "" %>"><dt><%: L.T("Student.Progress.TileResult") %></dt><dd><%: ResultText %></dd></div>
            </dl>

            <% if (!Released) { %>
                <% if (Completion != null && Completion.Status == CompletionStatus.Rejected && !string.IsNullOrWhiteSpace(Completion.CoordinatorNote)) { %>
                    <div class="rv-alert <%: Completion.IsRejectedFinal ? "is-error" : "is-warning" %>" role="note"><div><strong><%: Completion.IsRejectedFinal ? L.T("Student.Progress.ApprovalRejected") : L.T("Student.Progress.ApprovalCorrections") %></strong><br /><%: L.T("Student.Progress.CoordinatorNote") %>: <%: Completion.CoordinatorNote %></div></div>
                <% } %>
                <p class="rv-note"><%: L.T("Student.Progress.YourFinalResultAndTheOfficial") %></p>
            <% } else { %>
                <div class="pg-release">
                    <div class="pg-release-mark" aria-hidden="true"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="m7.5 12.5 3 3 6-6"/></svg></div>
                    <div>
                        <strong><%: L.T("Student.Progress.YourInternshipCompletionHasBeenApproved") %></strong>
                        <p class="rv-note"><%: L.F("Student.Progress.ReleasedLine", ResultText, Completion.FinalScore.ToString("0.#", System.Globalization.CultureInfo.InvariantCulture), Time.DisplayDate(Completion.ApprovedAt)) %></p>
                        <p class="rv-note"><%: L.T("Student.Progress.ScoreMethodNote") %></p>
                    </div>
                </div>
                <% if (ReportUrl != null) { %>
                    <div class="rv-actions">
                        <a class="btn btn-brand rv-btn-icon" href="<%: ReportDownloadUrl %>"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 3v12"/><path d="m7 10 5 5 5-5"/><path d="M5 21h14"/></svg><%: L.T("Student.Progress.DownloadReport") %></a>
                        <a class="btn btn-outline-secondary rv-btn-icon" href="<%: ReportUrl %>" target="_blank" rel="noopener" data-rv-print><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M6 9V3h12v6"/><rect x="3" y="9" width="18" height="8" rx="2"/><path d="M6 14h12v7H6z"/></svg><%: L.T("Student.Progress.PrintReport") %></a>
                    </div>
                <% } else { %>
                    <div class="rv-alert is-info"><%: L.T("Student.Progress.TheOfficialCompletionReportIsBeing") %></div>
                <% } %>
            <% } %>
        </div>
    </section>

    <% } %>
</div>
</asp:Content>

<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server">
    <script src="<%: ResolveUrl("~/Assets/js/review-system.js?v=20261023-rv6") %>"></script>
</asp:Content>
