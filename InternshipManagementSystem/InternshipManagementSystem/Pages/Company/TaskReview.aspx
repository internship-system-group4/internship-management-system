<%@ Page Language="C#"
    MasterPageFile="~/Layout/Company.master"
    AutoEventWireup="true"
    CodeBehind="TaskReview.aspx.cs"
    Inherits="InternshipManagementSystem.Pages.CompanyArea.TaskReview"
    Title="Review Submissions" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/task-dialogs.css?v=20261024-3") %>" />
    <style>
        .submission-page {
            color: var(--th-fg-123f63,#123f63);
        }

        .submission-header {
            margin-bottom: 22px;
        }

        .submission-title {
            margin: 0 0 5px;
            color: var(--th-fg-123f63,#123f63);
            font-size: clamp(1.5rem, 2.4vw, 2rem);
            font-weight: 750;
        }

        .submission-subtitle {
            margin: 0;
            color: var(--th-fg-59728d,#59728d);
            font-size: .92rem;
        }

        .submission-card {
            overflow: hidden;
            background: var(--ui-surface,#fff);
            border: 1px solid var(--th-line-d9e5f2,#d9e5f2);
            border-radius: 11px;
        }

        .submission-card-header {
            padding: 18px 20px;
        }

        .submission-card-title {
            margin: 0 0 4px;
            color: var(--th-fg-123f63,#123f63);
            font-size: 1.2rem;
            font-weight: 700;
        }

        .submission-card-description {
            margin: 0;
            color: var(--th-fg-59728d,#59728d);
            font-size: .82rem;
        }

        .submission-table-wrap {
            overflow-x: auto;
            border-top: 1px solid var(--th-line-d9e5f2,#d9e5f2);
        }

        .submission-table {
            width: 100%;
            min-width: 700px;
            margin: 0;
            border-collapse: collapse;
        }

        .submission-table th {
            padding: 11px 13px;
            color: var(--th-fg-123f63,#123f63);
            background: var(--th-bg-edf4fd,#edf4fd);
            border-bottom: 1px solid var(--th-line-d9e5f2,#d9e5f2);
            font-size: .77rem;
            font-weight: 700;
            text-align: start;
            white-space: nowrap;
        }

        .submission-table td {
            padding: 12px 13px;
            color: var(--th-fg-4b5563,#4b5563);
            border-bottom: 1px solid var(--th-line-e2eaf3,#e2eaf3);
            font-size: .8rem;
            vertical-align: middle;
        }

        .submission-table tr:last-child td {
            border-bottom: 0;
        }

        .submission-task-name,
        .submission-trainee-name {
            color: var(--th-fg-123f63,#123f63);
            font-weight: 650;
        }

        .submission-status {
            display: inline-block;
            padding: 4px 9px;
            color: var(--th-fg-24547c,#24547c);
            background: var(--th-bg-e3efff,#e3efff);
            border-radius: 999px;
            font-size: .72rem;
            font-weight: 650;
            white-space: nowrap;
        }

        .submission-view-button {
            padding: 7px 12px;
            color: #fff;
            background: var(--th-bg-28567e,#28567e);
            border: 1px solid var(--th-line-28567e,#28567e);
            border-radius: 7px;
            font-size: .76rem;
            font-weight: 650;
            text-decoration: none;
            white-space: nowrap;
        }

        .status-awaiting { color:var(--th-fg-24547c,#24547c); background:var(--th-bg-e3efff,#e3efff); }
        .status-under-review { color:var(--th-fg-75510a,#75510a); background:var(--th-bg-fff4d6,#fff4d6); }
        .status-revision { color:var(--th-fg-8a4b00,#8a4b00); background:var(--th-bg-fff1df,#fff1df); }
        .status-reviewed { color:var(--th-fg-176447,#176447); background:var(--th-bg-e7f5ec,#e7f5ec); }

        .submission-view-button:hover,
        .submission-view-button:focus-visible {
            color: #fff;
            background: var(--th-bg-194568,#194568);
            border-color: var(--th-line-194568,#194568);
        }

        .submission-empty {
            padding: 18px 20px;
            color: var(--th-fg-59728d,#59728d);
            font-size: .86rem;
        }

        .submission-filters {
            display: grid;
            grid-template-columns: minmax(220px, 1.5fr) minmax(170px, 1fr) minmax(160px, 1fr);
            gap: 10px;
            padding: 0 20px 16px;
        }

        .submission-filter-control {
            width: 100%;
            min-height: 40px;
            padding: 8px 11px;
            color: var(--th-fg-344b60,#344b60);
            background: var(--ui-surface,#fff);
            border: 1px solid var(--th-line-d9e5f2,#d9e5f2);
            border-radius: 7px;
            font-size: .82rem;
        }

        .submission-filter-summary {
            display: flex;
            justify-content: space-between;
            gap: 12px;
            padding: 10px 20px;
            color: var(--th-fg-59728d,#59728d);
            border-top: 1px solid var(--th-line-e2eaf3,#e2eaf3);
            font-size: .78rem;
        }

        @media (max-width: 700px) {
            .submission-filters { grid-template-columns: 1fr; }
        }

        .review-overlay {
            display: block;
            padding: 0;
        }

        .review-dialog {
            width: 100%;
            max-width: 1100px;
            margin: 0 auto;
            padding: 0;
            color: var(--th-fg-123f63,#123f63);
        }

        .review-back-link {
            display: inline-block;
            margin: 0 0 14px;
            color: var(--th-fg-365c7e,#365c7e);
            font-size: .8rem;
            font-weight: 600;
            text-decoration: none;
        }

        .review-back-link:hover { color: var(--th-fg-123f63,#123f63); text-decoration: underline; }

        .review-page-heading { margin-bottom: 18px; }
        .review-page-heading .review-dialog-title { display: inline-block; margin-inline-end: 8px; }
        .review-complete-badge { color: var(--th-fg-176447,#176447); background: var(--th-bg-e7f5ec,#e7f5ec); }
.review-revision-badge { color: var(--th-fg-8a4b00,#8a4b00); background: var(--th-bg-fff1df,#fff1df); }
        .review-pending-badge { display: inline-block; padding: 4px 9px; color: var(--th-fg-24547c,#24547c); background: var(--th-bg-e3efff,#e3efff); border-radius: 999px; font-size: .7rem; font-weight: 650; vertical-align: 3px; }

        .review-columns {
            display: grid;
            grid-template-columns: minmax(0, 1fr) minmax(0, 1.05fr);
            gap: 18px;
            align-items: start;
        }

        .review-card {
            padding: 18px;
            background: var(--ui-surface,#fff);
            border: 1px solid var(--th-line-d9e5f2,#d9e5f2);
            border-radius: 10px;
        }

        .review-card-title { margin: 0 0 4px; color: var(--th-fg-123f63,#123f63); font-size: 1rem; font-weight: 700; }
        .review-card-note { margin: 0 0 15px; color: var(--th-fg-59728d,#59728d); font-size: .76rem; }

        .review-details-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 13px 18px;
            padding-bottom: 14px;
            border-bottom: 1px solid var(--th-line-e2eaf3,#e2eaf3);
        }

        .review-detail-label { display: block; margin-bottom: 3px; color: var(--ui-muted); font-size: .68rem; }
        .review-detail-value { color: var(--th-fg-294e70,#294e70); font-size: .78rem; font-weight: 600; overflow-wrap: anywhere; }
        .review-work-area { padding-top: 13px; }
        .review-work-link { display: inline-block; margin-top: 8px; color: var(--th-fg-215982,#215982); font-size: .8rem; font-weight: 650; }

        .review-rubric-row {
            display: grid;
            grid-template-columns: 1fr 96px;
            gap: 12px;
            align-items: center;
            padding: 9px 0;
            border-bottom: 1px solid var(--th-line-edf1f5,#edf1f5);
        }
        .review-rubric-row:last-of-type { border-bottom: 0; }
        .review-rubric-label { color: var(--th-fg-294e70,#294e70); font-size: .77rem; font-weight: 600; }
        .review-rubric-label span { color: var(--ui-muted); font-size: .68rem; font-weight: 500; }
        .review-score-input { min-height: 34px; padding: 5px 8px; }
        .review-total { display: flex; justify-content: space-between; gap: 12px; margin: 12px 0; padding: 10px 12px; color: var(--th-fg-365c7e,#365c7e); background: var(--th-bg-edf4fd,#edf4fd); border-radius: 7px; font-size: .78rem; font-weight: 700; }
        .review-total small { display: block; color: var(--ui-muted); font-size: .65rem; font-weight: 400; }
        .review-actions { display: flex; flex-wrap: wrap; gap: 8px; justify-content: flex-end; margin-top: 12px; }
        .review-secondary-button { padding: 8px 12px; color: var(--th-fg-28567e,#28567e); background: var(--ui-surface,#fff); border: 1px solid var(--th-line-28567e,#28567e); border-radius: 7px; font-size: .78rem; font-weight: 650; }

        @media (max-width: 760px) {
            .review-columns { grid-template-columns: 1fr; }
        }

        .review-dialog-header {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 16px;
            margin-bottom: 18px;
        }

        .review-dialog-title {
            margin: 0 0 4px;
            color: var(--th-fg-123f63,#123f63);
            font-size: 1.35rem;
            font-weight: 700;
        }

        .review-dialog-subtitle {
            margin: 0;
            color: var(--th-fg-59728d,#59728d);
            font-size: .84rem;
        }

        .review-close-button {
            display: inline-flex;
            width: 36px;
            height: 36px;
            flex: 0 0 36px;
            align-items: center;
            justify-content: center;
            color: var(--th-fg-45627c,#45627c);
            background: var(--ui-surface,#fff);
            border: 1px solid var(--th-line-d9e5f2,#d9e5f2);
            border-radius: 8px;
            font-size: 1.25rem;
            line-height: 1;
            text-decoration: none;
        }

        .review-close-button:hover {
            color: var(--th-fg-123f63,#123f63);
            background: var(--th-bg-f3f7fc,#f3f7fc);
        }

        .review-summary {
            display: flex;
            flex-wrap: wrap;
            gap: 12px 28px;
            padding: 14px 16px;
            background: var(--th-bg-f5f8fc,#f5f8fc);
            border: 1px solid var(--th-line-d9e5f2,#d9e5f2);
            border-radius: 9px;
        }

        .review-summary-item {
            color: var(--th-fg-45627c,#45627c);
            font-size: .85rem;
        }

        .review-summary-item strong {
            margin-inline-end: 5px;
            color: var(--th-fg-123f63,#123f63);
        }

        .review-tabs > input {
            position: absolute;
            width: 1px;
            height: 1px;
            overflow: hidden;
            opacity: 0;
            pointer-events: none;
        }

        .review-tab-buttons {
            display: flex;
            gap: 7px;
            margin: 18px 0;
            padding: 5px;
            background: var(--th-bg-f0f4f8,#f0f4f8);
            border: 1px solid var(--th-line-e1e9f2,#e1e9f2);
            border-radius: 9px;
        }

        .review-tab-buttons label {
            flex: 1;
            margin: 0;
            padding: 10px 12px;
            color: var(--th-fg-526b82,#526b82);
            border-radius: 7px;
            font-size: .82rem;
            font-weight: 650;
            text-align: center;
            cursor: pointer;
        }

        .review-tab-buttons label:hover {
            color: var(--th-fg-123f63,#123f63);
            background: var(--th-bg-e7eef7,#e7eef7);
        }

        #reviewTabDetails:checked ~ .review-tab-buttons label[for="reviewTabDetails"],
        #reviewTabGrade:checked ~ .review-tab-buttons label[for="reviewTabGrade"],
        #reviewTabRevision:checked ~ .review-tab-buttons label[for="reviewTabRevision"] {
            color: var(--th-fg-194568,#194568);
            background: var(--ui-surface,#fff);
            box-shadow: 0 1px 4px rgba(18, 63, 99, .14);
        }

        .review-tab-content {
            display: none;
            padding: 4px 1px;
        }

        #reviewTabDetails:checked ~ #reviewDetailsContent,
        #reviewTabGrade:checked ~ #reviewGradeContent,
        #reviewTabRevision:checked ~ #reviewRevisionContent {
            display: block;
        }

        .review-section-title {
            margin: 0 0 5px;
            color: var(--th-fg-123f63,#123f63);
            font-size: 1rem;
            font-weight: 700;
        }

        .review-section-help {
            margin: 0 0 15px;
            color: var(--th-fg-59728d,#59728d);
            font-size: .82rem;
        }

        .review-work-card,
        .review-criterion-card {
            margin-bottom: 12px;
            padding: 15px;
            background: var(--ui-surface,#fff);
            border: 1px solid var(--th-line-d9e5f2,#d9e5f2);
            border-radius: 9px;
        }

        .review-work-text {
            margin-top: 8px;
            color: var(--th-fg-374b5e,#374b5e);
            white-space: pre-wrap;
            overflow-wrap: anywhere;
        }

        .review-work-link {
            display: inline-block;
            margin-top: 9px;
            color: var(--th-fg-215982,#215982);
            font-size: .84rem;
            font-weight: 650;
        }

        .review-criterion-heading {
            display: flex;
            flex-wrap: wrap;
            justify-content: space-between;
            gap: 5px 14px;
            margin-bottom: 6px;
        }

        .review-criterion-name {
            color: var(--th-fg-123f63,#123f63);
            font-weight: 700;
        }

        .review-criterion-meta,
        .review-criterion-description {
            color: var(--th-fg-59728d,#59728d);
            font-size: .8rem;
        }

        .review-criterion-description {
            margin-bottom: 12px;
        }

        .review-form-label {
            display: block;
            margin-bottom: 6px;
            color: var(--th-fg-294e70,#294e70);
            font-size: .84rem;
            font-weight: 650;
        }

        .review-dialog .form-control {
            border-color: var(--th-line-d9e5f2,#d9e5f2);
            border-radius: 7px;
        }

        .review-primary-button {
            padding: 9px 16px;
            color: #fff;
            background: var(--th-bg-28567e,#28567e);
            border: 1px solid var(--th-line-28567e,#28567e);
            border-radius: 7px;
            font-weight: 650;
        }

        .review-primary-button:hover,
        .review-primary-button:focus-visible {
            color: #fff;
            background: var(--th-bg-194568,#194568);
            border-color: var(--th-line-194568,#194568);
        }

        .review-message {
            display: block;
            margin-top: 12px;
        }

        .review-dialog-footer {
            display: flex;
            justify-content: flex-end;
            margin-top: 18px;
            padding-top: 14px;
            border-top: 1px solid var(--th-line-e2eaf3,#e2eaf3);
        }

        @media (max-width: 600px) {
            .review-summary {
                flex-direction: column;
                gap: 7px;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <asp:Panel ID="pnlSubmissionDirectory" runat="server">
    <div class="submission-page">
        <header class="submission-header">
            <h2 class="submission-title"><%: L.T("Company.TaskReview.ReviewSubmissions2") %></h2>
            <p class="submission-subtitle">
                <%: L.T("Company.TaskReview.ReviewTraineeWorkProvideAnEvaluation") %>
            </p>
        </header>

        <section class="submission-card" aria-labelledby="submissionListTitle">
            <div class="submission-card-header">
                <h3 id="submissionListTitle" class="submission-card-title"><%: L.T("Company.TaskReview.StudentSubmissions") %></h3>
                <p class="submission-card-description">
                    <%: L.T("Company.TaskReview.OpenASubmissionToReviewThe") %>
                </p>
            </div>

            <div class="submission-filters" role="search">
                <input id="submissionSearch" type="search" class="submission-filter-control"
                       placeholder="<%: L.T("Company.TaskReview.SearchTasksOrTrainees") %>" aria-label="<%: L.T("Company.TaskReview.SearchSubmissions") %>"
                       oninput="filterCompanySubmissions()" />
                <select id="submissionTraineeFilter" class="submission-filter-control"
                        aria-label="<%: L.T("Company.TaskReview.FilterByTrainee") %>" onchange="filterCompanySubmissions()">
                    <option value=""><%: L.T("Company.Dashboard.AllTrainees") %></option>
                </select>
                <select id="submissionStatusFilter" class="submission-filter-control" aria-label="<%: L.T("Company.TaskReview.FilterBySubmissionStatus") %>" onchange="filterCompanySubmissions()">
                    <option value=""><%: L.T("Company.I18n.Allstatuses") %></option>
                    <option value="Awaiting review"><%: L.T("Company.TaskReview.AwaitingReview") %></option>
                    <option value="Under review"><%: L.T("Company.Tasks.UnderReview") %></option>
                    <option value="Revision requested"><%: L.T("Company.Tasks.RevisionRequested") %></option>
                    <option value="Reviewed"><%: L.T("Company.Tasks.Reviewed") %></option>
                    <option value="Accepted"><%: L.T("Company.I18n.Accepted") %></option>
                </select>
            </div>

            <div class="submission-table-wrap">
                <table class="submission-table">
                    <thead>
                        <tr>
                            <th scope="col"><%: L.T("Company.TaskReview.Task") %></th>
                            <th scope="col"><%: L.T("Company.TaskReview.Trainee2") %></th>
                            <th scope="col"><%: L.T("Company.TaskReview.Attempt") %></th>
                            <th scope="col"><%: L.T("Company.TaskReview.Status2") %></th>
                            <th scope="col"><%: L.T("Company.TaskReview.SubmittedAt") %></th>
                            <th scope="col"><%: L.T("Company.TaskReview.Action") %></th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptSubmissions"
                            runat="server"
                            OnItemCommand="rptSubmissions_ItemCommand">
                            <ItemTemplate>
                                <tr data-review-task='<%#: Eval("TaskTitle") %>' data-review-trainee='<%#: Eval("TraineeName") %>' data-review-status='<%#: Eval("StatusKey") %>'>
                                    <td class="submission-task-name"><%#: Eval("TaskTitle") %></td>
                                    <td class="submission-trainee-name"><%#: Eval("TraineeName") %></td>
                                    <td><%#: Eval("AttemptNumber") %></td>
                                    <td><span class="<%#: Eval("StatusCss") %>"><%#: L.Value("Ui", Eval("Status")) %></span></td>
                                    <td>
                                        <%# DateTimeOffset
                                            .FromUnixTimeMilliseconds(Convert.ToInt64(Eval("SubmittedAt")))
                                            .ToLocalTime()
                                            .ToString("yyyy-MM-dd HH:mm") %>
                                    </td>
                                    <td>
                                        <asp:LinkButton ID="btnViewDetails"
                                            runat="server"
                                            Text='<%#: L.Value("Ui", Eval("ActionLabel")) %>'
                                            CssClass="submission-view-button"
                                            CommandName="ViewDetails"
                                            CommandArgument='<%# Eval("Id") %>' />
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>
            <div class="submission-filter-summary">
                <span id="submissionFilterSummary" aria-live="polite"></span>
                <span id="submissionNoMatches" hidden><%: L.T("Company.TaskReview.NoSubmissionsMatchTheseFilters") %></span>
            </div>
        </section>
    </div>
    </asp:Panel>

    <asp:Panel ID="pnlSubmissionDetails"
        runat="server"
        Visible="false"
        CssClass="review-overlay">

        <div class="review-dialog">
    <a href="Tasks.aspx" class="review-back-link"><%: L.T("Company.TaskReview.BackToTasks") %></a>
    <div class="review-page-heading">
        <h3 class="review-dialog-title"><%: L.T("Company.TaskReview.ReviewSubmission") %></h3>
        <asp:Label ID="lblReviewStatus" runat="server" CssClass="review-pending-badge" />
        <p class="review-dialog-subtitle"><%: L.T("Company.TaskReview.EvaluateTheTraineeSWorkAnd") %></p>
    </div>
    <asp:Label ID="lblReviewMessage" runat="server" EnableViewState="false" CssClass="review-message" />
    <div class="review-columns">
        <section class="review-card" aria-labelledby="submissionDetailsTitle">
            <h4 id="submissionDetailsTitle" class="review-card-title"><%: L.T("Company.TaskReview.SubmissionDetails2") %></h4>
            <div class="review-details-grid">
                <div><span class="review-detail-label"><%: L.T("Company.TaskReview.Trainee2") %></span><span class="review-detail-value"><asp:Label ID="lblDetailTrainee" runat="server" /></span></div>
                <div><span class="review-detail-label"><%: L.T("Company.TaskReview.TaskTitle") %></span><span class="review-detail-value"><asp:Label ID="lblDetailTask" runat="server" /></span></div>
                <div><span class="review-detail-label"><%: L.T("Company.TaskReview.Submitted2") %></span><span class="review-detail-value"><asp:Label ID="lblDetailSubmittedAt" runat="server" /></span></div>
                <div><span class="review-detail-label"><%: L.T("Company.TaskReview.DueDate") %></span><span class="review-detail-value"><asp:Label ID="lblDetailDeadline" runat="server" /></span></div>
                <div><span class="review-detail-label"><%: L.T("Company.TaskReview.Attempt") %></span><span class="review-detail-value"><asp:Label ID="lblDetailAttempt" runat="server" /></span></div>
            </div>
            <asp:PlaceHolder ID="phResubmission" runat="server" Visible="false">
                <div class="task-dialog-callout mt-3 mb-0">
                    <strong><asp:Literal ID="litResubmissionLabel" runat="server" Mode="Encode" /></strong>
                    <p><asp:Literal ID="litPreviousRequest" runat="server" Mode="Encode" /></p>
                </div>
            </asp:PlaceHolder>
            <div class="review-work-area">
                <span class="review-detail-label"><%: L.T("Company.TaskReview.SubmittedWork2") %></span>
                <div class="review-work-text"><asp:Label ID="lblDetailText" runat="server" /></div>
                <asp:HyperLink ID="lnkDetailWork" runat="server" Text="<%$ Resources:Company, TaskReview.OpenSubmittedLink %>" Target="_blank" Visible="false" CssClass="review-work-link" />
                <asp:HyperLink ID="lnkDetailFile" runat="server" Text="<%$ Resources:Company, TaskReview.OpenAttachedFile %>" Target="_blank" Visible="false" CssClass="review-work-link" />
            </div>
        </section>
        <section class="review-card" aria-labelledby="evaluationTitle">
            <h4 id="evaluationTitle" class="review-card-title"><%: L.T("Company.TaskReview.EvaluationAndFeedback") %></h4>
            <p class="review-card-note"><%: L.T("Company.TaskReview.AssessTheSubmissionWithTheUniversity") %></p>
            <div class="review-rubric-row"><label for="<%= txtCodeQuality.ClientID %>" class="review-rubric-label"><%: L.T("Company.TaskReview.CodeQuality") %> <span>/ 25</span></label><asp:TextBox ID="txtCodeQuality" runat="server" CssClass="form-control review-score-input review-score" TextMode="Number" min="0" max="25" step="0.01" placeholder="-" oninput="updateReviewTotal()" /></div>
            <div class="review-rubric-row"><label for="<%= txtFunctionality.ClientID %>" class="review-rubric-label"><%: L.T("Company.TaskReview.Functionality") %> <span>/ 35</span></label><asp:TextBox ID="txtFunctionality" runat="server" CssClass="form-control review-score-input review-score" TextMode="Number" min="0" max="35" step="0.01" placeholder="-" oninput="updateReviewTotal()" /></div>
            <div class="review-rubric-row"><label for="<%= txtDesignUsability.ClientID %>" class="review-rubric-label"><%: L.T("Company.TaskReview.DesignUsability") %> <span>/ 25</span></label><asp:TextBox ID="txtDesignUsability" runat="server" CssClass="form-control review-score-input review-score" TextMode="Number" min="0" max="25" step="0.01" placeholder="-" oninput="updateReviewTotal()" /></div>
            <div class="review-rubric-row"><label for="<%= txtDocumentation.ClientID %>" class="review-rubric-label"><%: L.T("Company.TaskReview.Documentation") %> <span>/ 15</span></label><asp:TextBox ID="txtDocumentation" runat="server" CssClass="form-control review-score-input review-score" TextMode="Number" min="0" max="15" step="0.01" placeholder="-" oninput="updateReviewTotal()" /></div>
            <div class="review-total"><span><%: L.T("Company.TaskReview.TotalEvaluationScore") %><small><%: L.T("Company.TaskReview.EnterScoresToCalculateTheTotal") %></small></span><span><strong id="reviewComputedScore">-</strong> / <asp:Label ID="lblTaskMaxScore" runat="server" /></span></div>
            <div class="mb-2">
                <asp:Label ID="lblFeedback" runat="server" AssociatedControlID="txtFeedback" CssClass="review-form-label" Text="<%$ Resources:Company, TaskReview.FeedbackForTrainee %>" />
                <asp:TextBox ID="txtFeedback" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="4" placeholder="<%$ Resources:Company, TaskReview.AddFeedbackAndSuggestions %>" />
            </div>
            <div class="review-actions">
                <asp:PlaceHolder ID="phRequestChangesOpen" runat="server">
                    <button type="button" id="btnOpenRequestChanges" class="task-dialog-btn task-dialog-btn-warning" data-task-dialog="requestChangesDialog">
                        <svg viewBox="0 0 24 24" aria-hidden="true"><path d="m15 5 4 4M4 20l4-1L20 7l-4-4L4 15z" /></svg>
                        <%: L.T("Company.TaskReview.RequestChanges") %>
                    </button>
                </asp:PlaceHolder>
                <asp:Button ID="btnSaveGrade" runat="server" Text="<%$ Resources:Company, TaskReview.SubmitEvaluation %>" CssClass="task-dialog-btn task-dialog-btn-primary" OnClick="btnSaveGrade_Click" data-ui-action="save" data-loading-label="<%$ Resources:Company, TaskReview.Saving %>" />
            </div>
        </section>
    </div>
</div>

<%-- Request changes popup (shared design: Assets/css/task-dialogs.css). --%>
<div class="modal fade uims-task-dialog" id="requestChangesDialog" tabindex="-1" aria-labelledby="requestChangesTitle" aria-hidden="true" data-open="<%= OpenDialog == "revision" ? "true" : "false" %>">
    <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content">
            <div class="task-dialog-header">
                <span class="task-dialog-icon is-warning" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="m15 5 4 4M4 20l4-1L20 7l-4-4L4 15z" /></svg></span>
                <div class="task-dialog-heading">
                    <span class="task-dialog-eyebrow is-warning"><asp:Literal ID="litRevisionEyebrow" runat="server" Mode="Encode" /></span>
                    <h2 class="modal-title" id="requestChangesTitle"><%: L.T("Company.TaskReview.RequestChanges") %></h2>
                    <p class="task-dialog-sub"><asp:Literal ID="litRevisionSubtitle" runat="server" Mode="Encode" /></p>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="<%: L.T("Company.TaskReview.Cancel") %>"></button>
            </div>
            <div class="modal-body">
                <asp:Label ID="lblRevisionError" runat="server" Visible="false" EnableViewState="false" CssClass="task-dialog-alert" role="alert" />
                <div class="task-dialog-field">
                    <asp:Label ID="lblRevisionInstructions" runat="server" AssociatedControlID="txtRevisionInstructions" CssClass="form-label" Text="<%$ Resources:Company, TaskReview.ChangesToMake %>" />
                    <asp:TextBox ID="txtRevisionInstructions" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="5" MaxLength="8000" placeholder="<%$ Resources:Company, TaskReview.ChangesPlaceholder %>" />
                    <div class="task-dialog-help"><%: L.T("Company.TaskReview.ChangesHelp") %></div>
                </div>
                <div class="task-dialog-callout is-info"><strong><%: L.T("Company.TaskReview.WhatHappensNext") %></strong><p><%: L.T("Company.TaskReview.RequestChangesNext") %></p></div>
            </div>
            <div class="task-dialog-footer">
                <button type="button" class="task-dialog-btn task-dialog-btn-secondary" data-bs-dismiss="modal"><%: L.T("Company.TaskReview.Cancel") %></button>
                <asp:Button ID="btnRequestRevision" runat="server" Text="<%$ Resources:Company, TaskReview.SendRequest %>" CssClass="task-dialog-btn task-dialog-btn-primary" OnClick="btnRequestRevision_Click" data-ui-action="submit" data-loading-label="<%$ Resources:Company, TaskReview.Saving %>" />
            </div>
        </div>
    </div>
</div>
</asp:Panel>

<%-- Result popup after a grade or a change request was saved. --%>
<asp:PlaceHolder ID="phReviewResult" runat="server" Visible="false">
<div class="modal fade uims-task-dialog task-result" id="reviewResultDialog" tabindex="-1" aria-labelledby="reviewResultTitle" aria-hidden="true" data-open="<%= OpenDialog == "result" ? "true" : "false" %>">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="task-result-body" role="status">
                <span class="task-dialog-icon <%= ResultIsRevision ? "is-warning" : "is-success" %>" aria-hidden="true">
                    <svg viewBox="0 0 24 24"><path d="<%= ResultIsRevision ? "m15 5 4 4M4 20l4-1L20 7l-4-4L4 15z" : "m5 12.5 4.2 4.2L19 7" %>" /></svg>
                </span>
                <h2 id="reviewResultTitle"><asp:Literal ID="litResultTitle" runat="server" Mode="Encode" /></h2>
                <p><asp:Literal ID="litResultMessage" runat="server" Mode="Encode" /></p>
                <ul class="task-result-facts"><li><asp:Literal ID="litResultAttempt" runat="server" Mode="Encode" /></li><li><asp:Literal ID="litResultFact" runat="server" Mode="Encode" /></li></ul>
                <div class="d-flex flex-wrap gap-2 justify-content-center">
                    <a href="TaskReview.aspx" class="task-dialog-btn task-dialog-btn-secondary"><%: L.T("Company.TaskReview.BackToSubmissions") %></a>
                    <button type="button" class="task-dialog-btn task-dialog-btn-primary" data-bs-dismiss="modal"><%: L.T("Company.TaskReview.Done") %></button>
                </div>
            </div>
        </div>
    </div>
</div>
</asp:PlaceHolder>
<script src="<%: ResolveUrl("~/Assets/js/task-dialogs.js?v=20261024-3") %>"></script>
<script type="text/javascript">
    function filterCompanySubmissions() {
        // The list is not on the page while one submission is open.
        if (!document.getElementById("submissionSearch")) return;
        var rows = document.querySelectorAll(".submission-table tbody tr[data-review-task]");
        var search = (document.getElementById("submissionSearch").value || "").toLowerCase().trim();
        var trainee = document.getElementById("submissionTraineeFilter").value;
        var status = document.getElementById("submissionStatusFilter").value;
        var visibleCount = 0;
        var names = {};

        for (var i = 0; i < rows.length; i++) {
            var rowTrainee = rows[i].getAttribute("data-review-trainee") || "";
            var rowTask = rows[i].getAttribute("data-review-task") || "";
            var rowStatus = rows[i].getAttribute("data-review-status") || "";
            names[rowTrainee] = true;
            var matches = (!search || (rowTask + " " + rowTrainee).toLowerCase().indexOf(search) >= 0)
                && (!trainee || trainee === rowTrainee)
                && (!status || status === rowStatus);
            rows[i].style.display = matches ? "" : "none";
            if (matches) visibleCount++;
        }

        var traineeSelect = document.getElementById("submissionTraineeFilter");
        if (traineeSelect.options.length === 1) {
            Object.keys(names).sort().forEach(function (name) {
                var option = document.createElement("option");
                option.value = name;
                option.textContent = name;
                traineeSelect.appendChild(option);
            });
        }

        document.getElementById("submissionFilterSummary").textContent =
            uimsT('SubmissionsShowing', visibleCount, rows.length);
        document.getElementById("submissionNoMatches").hidden =
            visibleCount !== 0;
    }

    function updateReviewTotal() {
        var scores = document.querySelectorAll(".review-score");
        var limits = [25, 35, 25, 15];
        var total = 0;
        var hasValue = false;
        for (var i = 0; i < scores.length; i++) {
            if (scores[i].value !== "") {
                total += Math.min(limits[i], Math.max(0, parseFloat(scores[i].value) || 0));
                hasValue = true;
            }
        }
        var maxLabel = document.getElementById("<%= lblTaskMaxScore.ClientID %>");
        var maxScore = maxLabel ? parseFloat(maxLabel.textContent || maxLabel.innerText) : 100;
        var computedScore = document.getElementById("reviewComputedScore");
        if (!computedScore) return;
        computedScore.textContent = hasValue
            ? (total * maxScore / 100).toFixed(2).replace(/\.00$/, "")
            : "-";
    }
    filterCompanySubmissions();
    updateReviewTotal();
</script>
</asp:Content>









