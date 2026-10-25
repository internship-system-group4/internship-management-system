<%@ Page Language="C#" MasterPageFile="~/Layout/Student.master" AutoEventWireup="true" CodeBehind="SubmissionDetails.aspx.cs" Inherits="InternshipManagementSystem.Pages.StudentArea.SubmissionDetails" Title="Submission details" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/student-submission.css?v=20261025-1") %>" />
</asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="sd-page">
    <nav class="sd-breadcrumb" aria-label="Breadcrumb">
        <a href="<%: ResolveUrl("~/Pages/Student/MyTasks.aspx") %>"><%: L.T("Student.MyTasks.MyTasks2") %></a>
        <span aria-hidden="true">/</span><span><%: L.T("Student.SubmissionDetails.Title") %></span>
    </nav>
    <% if (LoadFailed || NotFound) { %>
    <section class="sd-empty" role="status">
        <span class="sd-empty-icon" aria-hidden="true">!</span>
        <h2><%: L.T(LoadFailed ? "Student.SubmissionDetails.LoadError" : "Student.SubmissionDetails.NotFound") %></h2>
        <p><%: L.T("Student.SubmissionDetails.NotFoundHint") %></p>
        <a class="sd-button sd-button-primary" href="<%: ResolveUrl("~/Pages/Student/MyTasks.aspx") %>"><%: L.T("Student.SubmissionDetails.BackToTasks") %></a>
    </section>
    <% } else { %>
    <header class="sd-hero">
        <div class="sd-hero-content">
            <span class="sd-eyebrow"><%: L.T("Student.SubmissionDetails.Eyebrow") %></span>
            <h2><%: CurrentTask.Title %></h2>
            <p><%: L.T("Student.SubmissionDetails.Subtitle") %></p>
            <div class="sd-hero-pills">
                <span class="sd-pill sd-pill-attempt"><%: L.F("Student.SubmissionDetails.AttemptNumber", CurrentSubmission.AttemptNumber) %></span>
                <span class="sd-pill sd-pill-status <%: StatusClass %>"><span class="sd-dot" aria-hidden="true"></span><%: StatusLabel %></span>
            </div>
        </div>
        <a class="sd-button sd-button-ghost" href="<%: ResolveUrl("~/Pages/Student/MyTasks.aspx") %>"><span aria-hidden="true">&#8592;</span> <%: L.T("Student.SubmissionDetails.BackToTasks") %></a>
        <div class="sd-hero-facts">
            <div><span><%: L.T("Student.SubmissionDetails.SubmittedOn") %></span><strong><%: SubmittedDate %></strong></div>
            <div><span><%: L.T("Student.SubmissionDetails.Company") %></span><strong><%: CompanyName %></strong></div>
            <div><span><%: L.T("Student.SubmissionDetails.Deadline") %></span><strong><%: DeadlineDate %></strong></div>
        </div>
    </header>

    <div class="sd-grid">
        <main class="sd-main">
            <section class="sd-card" aria-labelledby="sent-title">
                <div class="sd-section-head"><span class="sd-section-icon" aria-hidden="true">01</span><div><span class="sd-section-kicker"><%: L.T("Student.SubmissionDetails.YourRecord") %></span><h3 id="sent-title"><%: L.T("Student.SubmissionDetails.WhatYouSubmitted") %></h3><p><%: L.T("Student.SubmissionDetails.SavedAsAttempt") %></p></div></div>
                <div class="sd-card-body">
                    <div class="sd-field"><span class="sd-field-label"><%: L.T("Student.SubmissionDetails.Description") %></span><div class="sd-prose"><%: string.IsNullOrWhiteSpace(CurrentSubmission.DescriptionText) ? L.T("Student.SubmissionDetails.NoDescription") : CurrentSubmission.DescriptionText %></div></div>
                    <div class="sd-artifact-grid">
                        <div class="sd-artifact"><span class="sd-artifact-icon" aria-hidden="true">&#8599;</span><div><span class="sd-field-label"><%: L.T("Student.SubmissionDetails.SubmittedLink") %></span><% if (HasWorkLink) { %><span class="sd-artifact-value"><%: WorkLink %></span><% if (CanOpenWorkLink) { %><a class="sd-text-link" href="<%: WorkLink %>" target="_blank" rel="noopener noreferrer"><%: L.T("Student.SubmissionDetails.OpenWorkLink") %> <span aria-hidden="true">&#8599;</span></a><% } else { %><small class="sd-artifact-warning"><%: L.T("Student.SubmissionDetails.RestrictedLink") %></small><% } %><% } else { %><span class="sd-artifact-muted"><%: L.T("Student.SubmissionDetails.NoLink") %></span><% } %></div></div>
                        <div class="sd-artifact"><span class="sd-artifact-icon" aria-hidden="true">&#8645;</span><div><span class="sd-field-label"><%: L.T("Student.SubmissionDetails.SubmittedFile") %></span><% if (HasFile) { %><strong class="sd-file-name"><%: FileName %></strong><a class="sd-text-link" href="<%: FileUrl %>"><%: L.T("Student.SubmissionDetails.DownloadFile") %> <span aria-hidden="true">&#8594;</span></a><% } else { %><span class="sd-artifact-muted"><%: L.T("Student.SubmissionDetails.NoFile") %></span><% } %></div></div>
                    </div>
                </div>
            </section>

            <section class="sd-card" aria-labelledby="feedback-title">
                <div class="sd-section-head"><span class="sd-section-icon" aria-hidden="true">02</span><div><span class="sd-section-kicker"><%: L.T("Student.SubmissionDetails.Review") %></span><h3 id="feedback-title"><%: L.T("Student.SubmissionDetails.SupervisorFeedback") %></h3></div></div>
                <div class="sd-card-body"><div class="sd-feedback <%: HasFeedback ? "has-feedback" : "is-pending" %>"><span class="sd-feedback-mark" aria-hidden="true"><%: HasFeedback ? "✓" : "···" %></span><div><strong><%: StatusLabel %></strong><p><%: HasFeedback ? FeedbackText : L.T("Student.SubmissionDetails.AwaitingFeedback") %></p><% if (HasScore) { %><span class="sd-score"><%: ScoreText %></span><% } %></div></div></div>
            </section>

            <section class="sd-card" aria-labelledby="task-title">
                <div class="sd-section-head"><span class="sd-section-icon" aria-hidden="true">03</span><div><span class="sd-section-kicker"><%: L.T("Student.SubmissionDetails.Assignment") %></span><h3 id="task-title"><%: L.T("Student.SubmissionDetails.TaskBrief") %></h3></div></div>
                <div class="sd-card-body sd-brief-grid"><div class="sd-field"><span class="sd-field-label"><%: L.T("Student.MyTasks.Description") %></span><div class="sd-prose"><%: string.IsNullOrWhiteSpace(CurrentTask.Description) ? L.T("Student.MyTasks.NoDescriptionWasProvided") : CurrentTask.Description %></div></div><div class="sd-field"><span class="sd-field-label"><%: L.T("Student.MyTasks.Instructions") %></span><div class="sd-prose"><%: string.IsNullOrWhiteSpace(CurrentTask.Instructions) ? L.T("Student.MyTasks.NoAdditionalInstructionsWereProvided") : CurrentTask.Instructions %></div></div>
                    <% if (Criteria.Count > 0) { %><div class="sd-criteria"><span class="sd-field-label"><%: L.T("Student.MyTasks.TaskCriteria") %></span><% foreach (var criterion in Criteria) { %><div><strong><%: criterion.Name %></strong><span><%: criterion.Description %></span><b><%: criterion.MaxScore.ToString("0.##") %> <%: L.T("Student.MyTasks.Points2") %></b></div><% } %></div><% } %>
                </div>
            </section>
        </main>
        <aside class="sd-aside" aria-label="<%: L.T("Student.SubmissionDetails.AttemptHistory") %>">
            <section class="sd-card sd-timeline-card"><div class="sd-aside-head"><span class="sd-section-kicker"><%: L.T("Student.SubmissionDetails.PreservedHistory") %></span><h3><%: L.T("Student.SubmissionDetails.AttemptHistory") %></h3><p><%: L.T("Student.SubmissionDetails.HistoryHint") %></p></div>
                <ol class="sd-timeline"><% foreach (var item in AttemptHistory) { %><li class="<%: item.IsCurrent ? "is-current" : "" %>"><span class="sd-timeline-node" aria-hidden="true"></span><div><span class="sd-timeline-date"><%: item.Date %></span><strong><%: L.F("Student.SubmissionDetails.AttemptNumber", item.Number) %></strong><span class="sd-timeline-state"><%: item.State %></span><% if (item.IsCurrent) { %><span class="sd-current-tag"><%: L.T("Student.SubmissionDetails.CurrentAttempt") %></span><% } else { %><a href="<%: item.Url %>"><%: L.T("Student.SubmissionDetails.ViewAttempt") %> &#8594;</a><% } %></div></li><% } %></ol>
            </section>
            <a class="sd-aside-back" href="<%: ResolveUrl("~/Pages/Student/MyTasks.aspx") %>"><%: L.T("Student.SubmissionDetails.BackToTasks") %> &#8594;</a>
        </aside>
    </div>
    <% } %>
</div>
</asp:Content>
