<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="PlacementDetails.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.PlacementDetails" Title="Placement Details" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Register Src="~/Layout/FinalEvaluations.ascx" TagPrefix="uims" TagName="FinalEvaluations" %>
<%-- Training progress of one student (coordinator). Same look as Manage Companies:
     slim header, four summary tiles, then tabs so each part is easy to read.
     Styles: Assets/css/coordinator-pages.css (.cx-*, .pdx-*, .fe-*). --%>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="students-page dir-page">
    <a class="dir-back" href="Placements.aspx"><span data-ui-icon="back" aria-hidden="true"></span> <%: L.T("Coordinator.PlacementDetails.PlacementsProgress") %></a>
    <% if (LoadError != null) { %><div class="alert alert-danger" role="alert"><%: LoadError %></div><% } else if (Progress != null) { var row = Progress.Overview; var placement = row.Placement; %>

    <section class="cx-head" aria-labelledby="progressName">
        <span class="dir-avatar" aria-hidden="true"><%: InternshipManagementSystem.Pages.CoordinatorArea.StudentDirectoryRow.MakeInitials(row.StudentName) %></span>
        <div class="cx-head-text">
            <div class="cx-head-title"><h2 id="progressName"><%: row.StudentName %></h2><span class="<%: InternshipManagementSystem.Pages.CoordinatorArea.PlacementStatusStyle.Css(placement.Status) %>"><%: row.StatusText %></span></div>
            <div class="cx-head-meta"><span class="dir-num"><%: row.StudentNumber %></span><span><%: row.Major %></span><span><%: Show(placement.CompanyName) %></span></div>
        </div>
        <div class="cx-head-actions">
            <% if (!string.IsNullOrEmpty(placement.StudentId)) { %><a class="dir-btn" href="Students.aspx?id=<%: Server.UrlEncode(placement.StudentId) %>"><span data-ui-icon="person" aria-hidden="true"></span> <%: L.T("Coordinator.ManageStudents.ViewProfile") %></a><% } %>
            <a class="dir-btn dir-btn-primary" href="CompletionReview.aspx?id=<%: Server.UrlEncode(placement.Id) %>"><span data-ui-icon="approved" aria-hidden="true"></span> <%: L.T("Coordinator.PlacementDetails.OpenCompletionReview") %></a>
        </div>
    </section>

    <ul class="dir-stats pdx-stats">
        <li style="--dir-i:0"><span class="dir-stat-icon <%: row.HoursPercent >= 100 ? "is-success" : "" %>" data-ui-icon="clock" aria-hidden="true"></span><div><span class="dir-label"><%: L.T("Coordinator.PlacementDetails.ApprovedTrainingHours") %></span><strong class="dir-num"><%: row.HoursText %></strong><div class="dir-progress" aria-hidden="true"><span style="--dir-p:<%: row.HoursPercent %>%"></span></div></div></li>
        <li style="--dir-i:1"><span class="dir-stat-icon <%: GradedCount == Progress.Tasks.Count && Progress.Tasks.Count > 0 ? "is-success" : "" %>" data-ui-icon="document" aria-hidden="true"></span><div><span class="dir-label"><%: L.T("Coordinator.PlacementDetails.TaskProgress") %></span><strong class="dir-num"><%: GradedCount %> / <%: Progress.Tasks.Count %></strong><small><%: L.T("Coordinator.Pd.TasksGraded") %></small></div></li>
        <li style="--dir-i:2"><span class="dir-stat-icon <%: row.PendingHours > 0 ? "is-warning" : "" %>" data-ui-icon="warning" aria-hidden="true"></span><div><span class="dir-label"><%: L.T("Coordinator.Pd.WaitingHours") %></span><strong class="dir-num"><%: row.PendingHours %> <%: L.T("Workspace.UnitH") %></strong><small><%: L.T("Coordinator.Pd.WaitingHoursNote") %></small></div></li>
        <li style="--dir-i:3"><span class="dir-stat-icon <%: FinalsSubmitted == 2 ? "is-success" : "" %>" data-ui-icon="study" aria-hidden="true"></span><div><span class="dir-label"><%: L.T("Coordinator.Final.SectionTitle") %></span><strong class="dir-num"><%: FinalsSubmitted %> / 2</strong><small><%: L.T("Coordinator.Pd.FinalsNote") %></small></div></li>
    </ul>

    <div class="pdx-tabs" role="tablist" aria-label="<%: L.T("Coordinator.Pd.Sections") %>" data-pdx-tabs>
        <button type="button" class="pdx-tab" role="tab" id="tab-overview" aria-controls="panel-overview" data-pdx-tab="overview"><span data-ui-icon="info" aria-hidden="true"></span><%: L.T("Coordinator.Pd.TabOverview") %></button>
        <button type="button" class="pdx-tab" role="tab" id="tab-tasks" aria-controls="panel-tasks" data-pdx-tab="tasks"><span data-ui-icon="document" aria-hidden="true"></span><%: L.T("Coordinator.PlacementDetails.Tasks") %> <b><%: Progress.Tasks.Count %></b></button>
        <button type="button" class="pdx-tab" role="tab" id="tab-submissions" aria-controls="panel-submissions" data-pdx-tab="submissions"><span data-ui-icon="chat" aria-hidden="true"></span><%: L.T("Coordinator.Pd.TabSubmissions") %> <b><%: Progress.Submissions.Count %></b></button>
        <button type="button" class="pdx-tab" role="tab" id="tab-hours" aria-controls="panel-hours" data-pdx-tab="hours"><span data-ui-icon="clock" aria-hidden="true"></span><%: L.T("Coordinator.Pd.TabHours") %> <b><%: Progress.Hours.Count %></b></button>
        <button type="button" class="pdx-tab" role="tab" id="tab-final" aria-controls="panel-final" data-pdx-tab="final"><span data-ui-icon="study" aria-hidden="true"></span><%: L.T("Coordinator.Final.SectionTitle") %> <b><%: FinalsSubmitted %>/2</b></button>
    </div>

    <%-- Overview --%>
    <div class="pdx-panel" role="tabpanel" id="panel-overview" aria-labelledby="tab-overview">
        <div class="pdx-overview">
            <section class="dir-card" aria-labelledby="internshipTitle">
                <div class="cx-section-title"><h3 id="internshipTitle"><span class="dir-stat-icon" data-ui-icon="briefcase" aria-hidden="true"></span><%: L.T("Coordinator.PlacementDetails.InternshipDetails") %></h3><span class="cx-section-note"><%: L.F("Coordinator.Pd.ConfirmedOn", InternshipManagementSystem.Common.Time.FriendlyDate(placement.ConfirmedAt)) %></span></div>
                <div class="dir-info-grid">
                    <section><h4><span data-ui-icon="building" aria-hidden="true"></span><%: L.T("Coordinator.PlacementDetails.Company") %></h4><dl>
                        <div><dt><%: L.T("Coordinator.PlacementDetails.Company") %></dt><dd><%: Show(placement.CompanyName) %></dd></div>
                        <div><dt><%: L.T("Coordinator.PlacementDetails.Opportunity") %></dt><dd><%: Show(placement.OpportunityTitle) %></dd></div>
                        <div><dt><%: L.T("Coordinator.PlacementDetails.TrainingPeriod") %></dt><dd><%: InternshipManagementSystem.Common.Time.FriendlyDate(placement.StartDate) %> – <%: InternshipManagementSystem.Common.Time.FriendlyDate(placement.EndDate) %></dd></div>
                    </dl></section>
                    <section><h4><span data-ui-icon="people" aria-hidden="true"></span><%: L.T("Coordinator.Pd.People") %></h4><dl>
                        <div><dt><%: L.T("Coordinator.PlacementDetails.CompanySupervisor") %></dt><dd><%: Show(Progress.CompanySupervisorName) %></dd></div>
                        <div><dt><%: L.T("Coordinator.PlacementDetails.AcademicSupervisor") %></dt><dd><%: Show(Progress.AcademicSupervisorName) %></dd></div>
                        <div><dt><%: L.T("Coordinator.PlacementDetails.StudentEmail") %></dt><dd><%: row.Student == null ? "—" : Show(row.Student.Email) %></dd></div>
                    </dl></section>
                </div>
            </section>
            <div class="d-grid gap-3">
                <section class="dir-card" aria-labelledby="completionTitle">
                    <div class="cx-section-title"><h3 id="completionTitle"><span class="dir-stat-icon" data-ui-icon="approved" aria-hidden="true"></span><%: L.T("Coordinator.PlacementDetails.CompletionOfficialResult") %></h3></div>
                    <% if (Progress.Completion == null) { %>
                        <p class="cx-section-note mb-0"><%: L.T("Coordinator.PlacementDetails.NoCompletionReviewRecordYetTraining") %></p>
                    <% } else { %>
                        <p class="mb-2"><span class="<%: Progress.Completion.Status == InternshipManagementSystem.Common.CompletionStatus.Approved ? "dir-status is-active" : "dir-status is-info" %>"><%: L.Value("CompletionStatus", Progress.Completion.Status) %></span></p>
                        <% if (Progress.Completion.Status == InternshipManagementSystem.Common.CompletionStatus.Approved) { %>
                            <p class="mb-2"><%: L.T("Coordinator.PlacementDetails.RecordedFinalResult") %> <strong><%: Progress.Completion.Result %></strong> · <%: Progress.Completion.FinalScore.ToString("0.##") %>%</p>
                            <a href="<%: ResolveUrl(InternshipManagementSystem.Services.PdfReportService.ReportUrl(Progress.Completion.Id)) %>" target="_blank" rel="noopener noreferrer" class="dir-btn dir-btn-primary"><span data-ui-icon="document" aria-hidden="true"></span><%: L.T("Coordinator.PlacementDetails.OpenOfficialCompletionReport") %></a>
                        <% } else { %>
                            <p class="cx-section-note mb-0"><%: L.T("Coordinator.PlacementDetails.FinalResultAndReportAreAwaiting") %></p>
                        <% } %>
                    <% } %>
                </section>
                <section class="dir-card" aria-labelledby="followTitle">
                    <div class="cx-section-title"><h3 id="followTitle"><span class="dir-stat-icon" data-ui-icon="chat" aria-hidden="true"></span><%: L.T("Coordinator.PlacementDetails.AcademicFollowUp") %></h3><span class="dir-count"><%: Progress.Comments.Count %></span></div>
                    <% if (Progress.Comments.Count == 0) { %><p class="cx-section-note mb-0"><%: L.T("Coordinator.PlacementDetails.NoAcademicCommentsHaveBeenRecorded") %></p><% } %>
                    <ul class="pdx-feed">
                    <% foreach (var comment in Progress.Comments) { %>
                        <li class="pdx-item"><div class="pdx-item-head"><span class="pdx-chip"><%: comment.IsVisibleToStudent ? L.T("Coordinator.Pd.VisibleToStudent") : L.T("Coordinator.Pd.HiddenFromStudent") %></span><span class="pdx-when"><span data-ui-icon="calendar" aria-hidden="true"></span><%: InternshipManagementSystem.Common.Time.Friendly(comment.CreatedAt) %></span></div><p class="pdx-text"><%: comment.Comment %></p></li>
                    <% } %>
                    </ul>
                </section>
            </div>
        </div>
    </div>

    <%-- Tasks --%>
    <div class="pdx-panel" role="tabpanel" id="panel-tasks" aria-labelledby="tab-tasks" hidden>
        <section class="dir-card">
            <div class="dir-title mb-3"><h3><%: L.T("Coordinator.PlacementDetails.Tasks") %> <span class="dir-count"><%: Progress.Tasks.Count %></span></h3><p><%: L.T("Coordinator.PlacementDetails.TasksAndHoursAreSeparateCompleting") %></p></div>
            <% if (Progress.Tasks.Count == 0) { %><p class="dir-empty"><span data-ui-icon="document" aria-hidden="true"></span><%: L.T("Coordinator.PlacementDetails.NoTasksHaveBeenAssignedTo") %></p><% } else { %>
            <div class="table-responsive"><table class="dir-table">
                <caption class="visually-hidden"><%: L.T("Coordinator.PlacementDetails.TasksAssignedToThisStudentPlacement") %></caption>
                <thead><tr><th scope="col"><%: L.T("Coordinator.PlacementDetails.Task") %></th><th scope="col"><%: L.T("Coordinator.PlacementDetails.Deadline") %></th><th scope="col"><%: L.T("Coordinator.PlacementDetails.Status") %></th><th scope="col"><%: L.T("Coordinator.Pd.Grade") %></th><th scope="col"><%: L.T("Coordinator.PlacementDetails.Attempts") %></th></tr></thead>
                <tbody>
                <% int ti = 0; foreach (var task in Progress.Tasks) { %>
                    <tr style="--dir-i:<%: ti++ %>">
                        <td><strong><%: task.Title %></strong><small><%: task.Description %></small></td>
                        <td><span class="dir-num"><%: InternshipManagementSystem.Common.Time.Friendly(task.Deadline) %></span><% if (task.IsOverdue) { %><small class="dir-flag"><%: L.T("Coordinator.PlacementDetails.PastDeadline") %></small><% } %></td>
                        <td><span class="<%: TaskCss(task.Status) %>"><%: L.Value("TaskStatus", task.Status) %></span></td>
                        <td class="dir-num"><strong><%: TaskGrade(task) %></strong></td>
                        <td class="dir-num"><%: Progress.Submissions.Count(s => s.TaskId == task.Id) %></td>
                    </tr>
                <% } %>
                </tbody>
            </table></div>
            <% } %>
        </section>
    </div>

    <%-- Submissions with the supervisor's feedback under each attempt --%>
    <div class="pdx-panel" role="tabpanel" id="panel-submissions" aria-labelledby="tab-submissions" hidden>
        <section class="dir-card">
            <div class="dir-title mb-3"><h3><%: L.T("Coordinator.Pd.TabSubmissions") %> <span class="dir-count"><%: Progress.Submissions.Count %></span></h3><p><%: L.T("Coordinator.PlacementDetails.AllAttemptsNewestFirst") %></p></div>
            <% if (Progress.Submissions.Count == 0) { %><p class="dir-empty"><span data-ui-icon="document" aria-hidden="true"></span><%: L.T("Coordinator.PlacementDetails.NoSubmissionsHaveBeenRecordedFor") %></p><% } %>
            <ul class="pdx-feed">
            <% foreach (var submission in Progress.Submissions) { var feedback = FeedbackFor(submission.Id); %>
                <li class="pdx-item">
                    <div class="pdx-item-head"><strong><%: TaskTitle(submission.TaskId) %></strong><span class="pdx-chip"><%: L.F("Coordinator.Pd.AttemptN", submission.AttemptNumber) %></span><span class="pdx-when"><span data-ui-icon="calendar" aria-hidden="true"></span><%: InternshipManagementSystem.Common.Time.Friendly(submission.SubmittedAt) %></span></div>
                    <% if (!string.IsNullOrWhiteSpace(submission.DescriptionText)) { %><p class="pdx-text"><%: submission.DescriptionText %></p><% } %>
                    <% if (SafeLink(submission.LinkUrl) || SafeLink(submission.FileUrl)) { %><div class="pdx-links">
                        <% if (SafeLink(submission.LinkUrl)) { %><a class="dir-btn" href="<%: submission.LinkUrl %>" target="_blank" rel="noopener noreferrer"><span data-ui-icon="eye" aria-hidden="true"></span><%: L.T("Coordinator.PlacementDetails.OpenSubmittedLink") %></a><% } %>
                        <% if (SafeLink(submission.FileUrl)) { %><a class="dir-btn" href="<%: submission.FileUrl %>" target="_blank" rel="noopener noreferrer"><span data-ui-icon="document" aria-hidden="true"></span><%: L.T("Coordinator.PlacementDetails.OpenAttachment") %> <%: submission.FileName %></a><% } %>
                    </div><% } %>
                    <% if (feedback == null) { %>
                        <div class="pdx-feedback"><div class="pdx-feedback-head"><span><%: L.T("Coordinator.Pd.NoFeedbackYet") %></span></div></div>
                    <% } else if (feedback.RevisionRequested) { %>
                        <div class="pdx-feedback is-revision"><div class="pdx-feedback-head"><span><%: L.T("Coordinator.PlacementDetails.RequestedChanges") %></span><span class="pdx-when"><%: InternshipManagementSystem.Common.Time.Friendly(feedback.EvaluatedAt) %></span></div><p class="pdx-text"><%: string.IsNullOrWhiteSpace(feedback.RevisionInstructions) ? feedback.Feedback : feedback.RevisionInstructions %></p></div>
                    <% } else { %>
                        <div class="pdx-feedback"><div class="pdx-feedback-head"><span><%: L.T("Coordinator.Pd.Feedback") %> · <b><%: Score(feedback.TotalScore, feedback.MaxScore) %></b></span><span class="pdx-when"><%: InternshipManagementSystem.Common.Time.Friendly(feedback.EvaluatedAt) %></span></div>
                            <% if (!string.IsNullOrWhiteSpace(feedback.Feedback)) { %><p class="pdx-text"><%: feedback.Feedback %></p><% } %>
                            <% if (feedback.Components != null && feedback.Components.Count > 0) { %><div class="pdx-crit"><% foreach (var c in feedback.Components.Where(x => x != null)) { %><span><%: c.Name %>: <%: Score(c.Score, c.MaxScore) %></span><% } %></div><% } %>
                        </div>
                    <% } %>
                </li>
            <% } %>
            </ul>
        </section>
    </div>

    <%-- Training hours --%>
    <div class="pdx-panel" role="tabpanel" id="panel-hours" aria-labelledby="tab-hours" hidden>
        <section class="dir-card">
            <div class="dir-title mb-3"><h3><%: L.T("Coordinator.PlacementDetails.TrainingHoursLog") %> <span class="dir-count"><%: Progress.Hours.Count %></span></h3><p><%: row.PendingHours %> <%: L.T("Coordinator.PlacementDetails.HReportedAwaitingApprovalOnlyApproved") %></p></div>
            <% if (Progress.Hours.Count == 0) { %><p class="dir-empty"><span data-ui-icon="clock" aria-hidden="true"></span><%: L.T("Coordinator.PlacementDetails.NoTrainingHoursHaveBeenReported") %></p><% } else { %>
            <div class="table-responsive"><table class="dir-table">
                <caption class="visually-hidden"><%: L.T("Coordinator.PlacementDetails.ReportedHoursAndReviewDecisions") %></caption>
                <thead><tr><th scope="col"><%: L.T("Coordinator.PlacementDetails.WorkDate") %></th><th scope="col"><%: L.T("Coordinator.PlacementDetails.Description") %></th><th scope="col"><%: L.T("Coordinator.PlacementDetails.Hours") %></th><th scope="col"><%: L.T("Coordinator.PlacementDetails.Status") %></th><th scope="col"><%: L.T("Coordinator.PlacementDetails.ReviewNote") %></th></tr></thead>
                <tbody>
                <% int hi = 0; foreach (var entry in Progress.Hours) { %>
                    <tr style="--dir-i:<%: hi++ %>"><td class="dir-num"><%: InternshipManagementSystem.Common.Time.FriendlyDate(entry.WorkDate) %></td><td><%: entry.Description %></td><td class="dir-num"><strong><%: entry.Hours %> <%: L.T("Workspace.UnitH") %></strong></td><td><span class="<%: HoursCss(entry.Status) %>"><%: L.Value("HoursStatus", entry.Status) %></span></td><td><%: Show(entry.ReviewNote) %></td></tr>
                <% } %>
                </tbody>
            </table></div>
            <% } %>
        </section>
    </div>

    <%-- Final evaluations (confidential, coordinator only) --%>
    <div class="pdx-panel" role="tabpanel" id="panel-final" aria-labelledby="tab-final" hidden>
        <uims:FinalEvaluations ID="ucFinal" runat="server" ShowWeights="true" />
    </div>
    <% } %>
</div>
</asp:Content>
