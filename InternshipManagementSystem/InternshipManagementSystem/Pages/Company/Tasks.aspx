<%@ Page Language="C#" MasterPageFile="~/Layout/Company.master" AutoEventWireup="true" CodeBehind="Tasks.aspx.cs" Inherits="InternshipManagementSystem.Pages.CompanyArea.Tasks" Title="Manage Tasks" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
<style>
.tasks-page{color:var(--th-fg-123f63,#123f63)}
.tasks-page-header{display:flex;align-items:center;justify-content:space-between;gap:16px;margin-bottom:24px}
.tasks-page-title{margin:0 0 5px;color:var(--th-fg-123f63,#123f63);font-size:clamp(1.5rem,2.4vw,2rem);font-weight:750}
.tasks-page-subtitle{margin:0;color:var(--th-fg-59728d,#59728d);font-size:.95rem}
.tasks-create-button{flex:0 0 auto;padding:10px 18px;color:#fff;background:var(--th-bg-28567e,#28567e);border:1px solid var(--th-line-28567e,#28567e);border-radius:8px;font-weight:650}
.tasks-create-button:hover,.tasks-create-button:focus-visible{color:#fff;background:var(--th-bg-194568,#194568);border-color:var(--th-line-194568,#194568)}
.tasks-stats{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:18px;margin-bottom:24px}
.tasks-stat-card{display:flex;align-items:flex-start;justify-content:space-between;gap:12px;min-height:108px;padding:18px 20px;background:var(--ui-surface,#fff);border:1px solid var(--th-line-d9e5f2,#d9e5f2);border-radius:11px}
.tasks-stat-label{margin:0 0 4px;color:var(--th-fg-345d81,#345d81);font-size:.87rem}
.tasks-stat-number{margin:0;color:var(--th-fg-073b61,#073b61);font-size:1.85rem;font-weight:750;line-height:1.15}
.tasks-stat-note{margin:5px 0 0;color:var(--th-fg-59728d,#59728d);font-size:.76rem}
.tasks-stat-icon{display:grid;width:38px;height:38px;flex:0 0 38px;place-items:center;color:var(--th-fg-28567e,#28567e);background:var(--th-bg-edf4ff,#edf4ff);border-radius:9px;font-size:1.1rem;font-weight:700}
.tasks-reminder{margin-bottom:24px;padding:13px 16px;color:var(--th-fg-244c72,#244c72);background:var(--th-bg-e4f0ff,#e4f0ff);border:1px solid var(--th-line-d7e8fc,#d7e8fc);border-radius:9px}
.tasks-reminder-title{margin:0 0 2px;font-size:.86rem;font-weight:700}
.tasks-reminder-text{margin:0;color:var(--th-fg-4b5e70,#4b5e70);font-size:.82rem}
.tasks-directory{overflow:hidden;background:var(--ui-surface,#fff);border:1px solid var(--th-line-d9e5f2,#d9e5f2);border-radius:11px}
.tasks-directory-header{padding:18px 20px 15px}
.tasks-directory-title{margin:0 0 4px;color:var(--th-fg-123f63,#123f63);font-size:1.25rem;font-weight:700}
.tasks-directory-description{margin:0 0 14px;color:var(--th-fg-59728d,#59728d);font-size:.82rem}
.tasks-filters{display:grid;grid-template-columns:minmax(220px,1.4fr) minmax(150px,.9fr) minmax(160px,.9fr);gap:10px;max-width:720px}
.tasks-filter-control{min-height:40px;color:var(--th-fg-344b60,#344b60);background:var(--ui-surface,#fff);border:1px solid var(--th-line-d9e5f2,#d9e5f2);border-radius:7px;font-size:.82rem}
.tasks-search-wrap{position:relative}
.tasks-search-wrap:before{position:absolute;top:13px;inset-inline-start:12px;width:10px;height:10px;content:"";border:1.5px solid var(--th-line-496b8c,#496b8c);border-radius:50%;pointer-events:none}
.tasks-search-wrap:after{position:absolute;top:24px;inset-inline-start:22px;width:6px;height:1.5px;content:"";background:var(--th-bg-496b8c,#496b8c);transform:rotate(45deg);pointer-events:none}
.tasks-search{width:100%;padding:8px 12px 8px 36px}
.tasks-table-wrap{overflow-x:auto;border-top:1px solid var(--th-line-d9e5f2,#d9e5f2)}
.tasks-table{width:100%;min-width:780px;margin:0;border-collapse:collapse}
.tasks-table thead th{padding:11px 13px;color:var(--th-fg-123f63,#123f63);background:var(--th-bg-edf4fd,#edf4fd);border-bottom:1px solid var(--th-line-d9e5f2,#d9e5f2);font-size:.77rem;font-weight:700;text-align:start;white-space:nowrap}
.tasks-table tbody td{padding:11px 13px;color:var(--th-fg-4b5563,#4b5563);border-bottom:1px solid var(--th-line-e2eaf3,#e2eaf3);font-size:.79rem;vertical-align:middle}
.tasks-table tbody tr:last-child td{border-bottom:0}
.tasks-table tbody tr:hover{background:var(--th-bg-fbfdff,#fbfdff)}
.tasks-title-cell{min-width:185px;color:var(--th-fg-123f63,#123f63);font-weight:700}
.tasks-trainee-name{color:var(--th-fg-123f63,#123f63);font-weight:650}
.tasks-trainee-department{margin-top:3px;color:var(--th-fg-59728d,#59728d);font-size:.72rem}
.tasks-status-badge{display:inline-flex;align-items:center;gap:6px;padding:4px 9px;border-radius:999px;font-size:.72rem;font-weight:650;white-space:nowrap}
.tasks-status-badge:before{width:6px;height:6px;background:currentColor;border-radius:50%;content:""}
.tasks-status-pending{color:var(--th-fg-24547c,#24547c);background:var(--th-bg-e3efff,#e3efff)}
.tasks-status-reviewed{color:var(--th-fg-176447,#176447);background:var(--th-bg-e7f5ec,#e7f5ec)}
.tasks-status-revision{color:var(--th-fg-8a4b00,#8a4b00);background:var(--th-bg-fff1df,#fff1df)}
.tasks-status-progress{color:var(--th-fg-596b7c,#596b7c);background:var(--th-bg-edf1f5,#edf1f5)}
.tasks-submission-status{color:var(--th-fg-4b5563,#4b5563);white-space:nowrap}
.tasks-evaluation{color:var(--th-fg-345d81,#345d81);white-space:nowrap}
.tasks-review-button,.tasks-details-button{display:inline-block;padding:7px 12px;border:1px solid var(--th-line-28567e,#28567e);border-radius:7px;font-size:.76rem;font-weight:650;text-decoration:none;white-space:nowrap}
.tasks-review-button{color:#fff;background:var(--th-bg-28567e,#28567e)}
.tasks-review-button:hover,.tasks-review-button:focus-visible{color:#fff;background:var(--th-bg-194568,#194568)}
.tasks-details-button{color:var(--th-fg-214e75,#214e75);background:var(--ui-surface,#fff)}
.tasks-details-button:hover,.tasks-details-button:focus-visible{color:#fff;background:var(--th-bg-28567e,#28567e)}
.tasks-directory-footer{display:flex;align-items:center;justify-content:space-between;gap:12px;min-height:48px;padding:8px 13px;color:var(--th-fg-59728d,#59728d);border-top:1px solid var(--th-line-d9e5f2,#d9e5f2);font-size:.77rem}
.tasks-pagination{display:flex;align-items:center;gap:6px}
.tasks-page-button{min-width:30px;height:30px;padding:3px 8px;color:var(--th-fg-214e75,#214e75);background:var(--ui-surface,#fff);border:1px solid var(--th-line-d9e5f2,#d9e5f2);border-radius:6px;font-size:.76rem}
.tasks-page-button[aria-current="page"]{color:#fff;background:var(--th-bg-28567e,#28567e);border-color:var(--th-line-28567e,#28567e)}
.tasks-page-button:disabled{color:#9aabba;cursor:default}
.tasks-empty{padding:18px 20px;color:var(--th-fg-59728d,#59728d);font-size:.86rem}
.task-modal-overlay{position:fixed;inset:0;z-index:2000;align-items:center;justify-content:center;padding:16px;background:rgba(17,35,53,.46);-webkit-backdrop-filter:blur(4px);backdrop-filter:blur(4px)}
.task-modal-dialog{width:100%;max-width:820px;max-height:calc(100vh - 32px);overflow-y:auto;padding:26px;color:var(--th-fg-123f63,#123f63);background:var(--ui-surface,#fff);border:1px solid var(--th-line-d9e5f2,#d9e5f2);border-radius:16px;box-shadow:0 24px 65px rgba(0,0,0,.24)}
.task-modal-dialog .form-control,.task-modal-dialog .form-select{border-color:var(--th-line-d9e5f2,#d9e5f2);border-radius:7px}
.task-modal-dialog .form-label{color:var(--th-fg-294e70,#294e70);font-size:.84rem;font-weight:650}
.task-details-dialog{max-width:760px}
.task-details-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:12px;margin:20px 0;padding:16px;background:var(--th-bg-f5f8ff,#f5f8ff);border:1px solid var(--th-line-e1eaf4,#e1eaf4);border-radius:10px}
.task-details-grid div{display:flex;flex-direction:column;gap:4px}
.task-details-grid span,.task-details-section h3{color:var(--th-fg-59728d,#59728d);font-size:.78rem;font-weight:600}
.task-details-grid strong{color:var(--th-fg-173e61,#173e61);font-size:.9rem;font-weight:650}
.task-details-section{margin-top:16px;padding-top:14px;border-top:1px solid var(--th-line-e7edf4,#e7edf4)}
.task-details-section h3{margin:0 0 7px;color:var(--th-fg-294e70,#294e70);font-size:.88rem}
.task-details-section p{margin:0;color:var(--th-fg-45596e,#45596e);white-space:pre-wrap;overflow-wrap:anywhere}
.task-details-section a{color:var(--th-fg-215b8b,#215b8b);font-weight:650}
@media(max-width:576px){.task-details-grid{grid-template-columns:1fr}}
@media(max-width:760px){.tasks-stats{grid-template-columns:1fr;gap:11px}.tasks-stat-card{min-height:90px}.tasks-filters{grid-template-columns:1fr}.tasks-page-header{align-items:flex-start;flex-direction:column}.tasks-directory-footer{align-items:flex-start;flex-direction:column}}
@media(max-width:576px){.task-modal-dialog{padding:18px;border-radius:12px}}
.student-filter-banner{display:flex;align-items:center;justify-content:space-between;gap:12px;margin:0 0 18px;padding:12px 15px;color:var(--th-fg-244c72,#244c72);background:var(--th-bg-eaf3ff,#eaf3ff);border:1px solid var(--th-line-d7e8fc,#d7e8fc);border-radius:8px;font-size:.86rem}
.student-filter-banner a{color:var(--th-fg-214e75,#214e75);font-weight:650;text-decoration:none}
.student-filter-banner a:hover{text-decoration:underline}
.create-task-page{min-height:100vh;margin:-20px;padding:28px;background:var(--th-bg-f5f8ff,#f5f8ff);color:var(--th-fg-173b5c,#173b5c)}
.create-task-back{display:inline-block;margin-bottom:14px;color:var(--th-fg-315d83,#315d83);text-decoration:none;font-size:13px}
.create-task-title{margin:0 0 4px;color:var(--th-fg-123b5e,#123b5e);font-size:26px;font-weight:700}
.create-task-subtitle{margin:0 0 18px;color:var(--th-fg-58718a,#58718a);font-size:13px}
.create-task-card{width:100%;max-width:700px;padding:22px;background:var(--ui-surface,#fff);border:1px solid var(--th-line-e1e9f2,#e1e9f2);border-radius:10px;box-shadow:0 4px 16px rgba(26,62,94,.04)}
.create-task-section-title{margin:0 0 3px;color:var(--th-fg-173e61,#173e61);font-size:15px;font-weight:700}
.create-task-section-note{margin:0 0 14px;color:var(--ui-muted);font-size:11px}
.create-task-page .form-label{display:block;margin-bottom:5px;color:var(--th-fg-274a68,#274a68);font-size:11px;font-weight:600}
.create-task-page .form-control,.create-task-page .form-select{min-height:38px;border:1px solid var(--th-line-d9e3ed,#d9e3ed);border-radius:6px;color:var(--th-fg-344b60,#344b60);font-size:12px;box-shadow:none}
.create-task-page textarea.form-control{min-height:76px;resize:vertical}
.create-task-divider{margin:18px 0;border:0;border-top:1px solid var(--th-line-e8edf3,#e8edf3)}
.create-task-footer{display:flex;align-items:center;justify-content:space-between;gap:12px;margin-top:17px;padding-top:14px;border-top:1px solid var(--th-line-edf1f5,#edf1f5)}
.create-task-required{color:var(--ui-muted);font-size:10px}
@media(max-width:600px){.create-task-page{margin:-12px;padding:18px 12px}.create-task-card{padding:16px}}
.create-task-overlay{position:fixed;inset:0;z-index:2500;display:none;align-items:center;justify-content:center;padding:22px;background:rgba(16,35,55,.48);-webkit-backdrop-filter:blur(7px);backdrop-filter:blur(7px)}
.task-success-overlay{position:fixed;inset:0;z-index:2600;display:none;align-items:center;justify-content:center;padding:20px;background:rgba(16,35,55,.48);-webkit-backdrop-filter:blur(7px);backdrop-filter:blur(7px)}
.task-success-dialog{width:100%;max-width:380px;padding:30px 26px;text-align:center;background:var(--ui-surface,#fff);border:1px solid var(--th-line-e1e9f2,#e1e9f2);border-radius:14px;box-shadow:0 18px 55px rgba(19,50,77,.22)}
.task-success-check{width:64px;height:64px;margin:0 auto 16px;border-radius:50%;display:flex;align-items:center;justify-content:center;background:var(--th-bg-e8f6ee,#e8f6ee);color:var(--th-fg-198754,#198754)}
.task-success-check svg{width:34px;height:34px;fill:none;stroke:currentColor;stroke-width:2.6;stroke-linecap:round;stroke-linejoin:round}
.task-success-dialog h2{margin:0 0 8px;color:var(--th-fg-173e61,#173e61);font-size:22px;font-weight:700}
.task-success-dialog p{margin:0 0 22px;color:var(--th-fg-61758a,#61758a);font-size:14px}
.create-task-dialog{position:relative;width:100%;max-width:760px;max-height:calc(100vh - 44px);overflow-y:auto;padding:24px;background:var(--ui-surface,#fff);border:1px solid var(--th-line-dce6f0,#dce6f0);border-radius:12px;box-shadow:0 24px 70px rgba(15,40,65,.24)}
.create-task-dialog .form-label{display:block;margin-bottom:5px;color:var(--th-fg-274a68,#274a68);font-size:12px;font-weight:650}
.create-task-dialog .form-control,.create-task-dialog .form-select{min-height:38px;border:1px solid var(--th-line-d9e3ed,#d9e3ed);border-radius:6px;color:var(--th-fg-344b60,#344b60);font-size:13px;box-shadow:none}
.create-task-dialog textarea.form-control{min-height:74px;resize:vertical}
@media(max-width:600px){.create-task-overlay{padding:10px}.create-task-dialog{max-height:calc(100vh - 20px);padding:16px}}
.create-task-dialog .create-task-card{width:auto;max-width:none;padding:0;background:transparent;border:0;border-radius:0;box-shadow:none}
</style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div id="tasksListView" class="tasks-page">
    <div class="tasks-page-header">
        <div>
            <h2 class="tasks-page-title"><%: L.T("Company.Tasks.ManageReviewTasks") %></h2>
            <p class="tasks-page-subtitle"><%: L.T("Company.Tasks.CreateTasksReviewSubmissionsAndTrack") %></p>
        </div>
        <button type="button" id="btnOpenCreateTask" class="btn tasks-create-button" onclick="showTaskForm()">
            <span aria-hidden="true">+</span> <%: L.T("Company.Tasks.CreateNewTask2") %>
        </button>
    </div>

    <asp:Panel ID="pnlStudentTaskFilter" runat="server" Visible="false" CssClass="student-filter-banner">
        <span><%: L.T("Company.Tasks.ShowingAllTasksFor") %> <strong><asp:Label ID="lblStudentTaskFilterName" runat="server" /></strong></span>
        <a href="Tasks.aspx"><%: L.T("Company.Tasks.ShowAllCompanyTasks") %></a>
    </asp:Panel>

    <section class="tasks-stats" aria-label="<%: L.T("Company.Tasks.TaskSummary") %>">
        <article class="tasks-stat-card">
            <div>
                <p class="tasks-stat-label"><%: L.T("Company.Tasks.PendingReview") %></p>
                <p class="tasks-stat-number"><asp:Literal ID="litPendingReview" runat="server" /></p>
                <p class="tasks-stat-note"><%: L.T("Company.Tasks.AwaitingYourEvaluation") %></p>
            </div>
            <span class="tasks-stat-icon" aria-hidden="true">&#9719;</span>
        </article>
        <article class="tasks-stat-card">
            <div>
                <p class="tasks-stat-label"><%: L.T("Company.Tasks.Reviewed") %></p>
                <p class="tasks-stat-number"><asp:Literal ID="litReviewedTasks" runat="server" /></p>
                <p class="tasks-stat-note"><%: L.T("Company.Tasks.EvaluationsCompleted") %></p>
            </div>
            <span class="tasks-stat-icon" aria-hidden="true">&#10003;</span>
        </article>
        <article class="tasks-stat-card">
            <div>
                <p class="tasks-stat-label"><%: L.T("Company.Tasks.OverdueTasks") %></p>
                <p class="tasks-stat-number"><asp:Literal ID="litOverdueTasks" runat="server" /></p>
                <p class="tasks-stat-note"><%: L.T("Company.Tasks.PastTheirDueDate") %></p>
            </div>
            <span class="tasks-stat-icon" aria-hidden="true">!</span>
        </article>
    </section>

    <aside class="tasks-reminder">
        <p class="tasks-reminder-title"><%: L.T("Company.Tasks.ReviewReminder") %></p>
        <p class="tasks-reminder-text"><%: L.T("Company.Tasks.EvaluateSubmissionsUsingTheUniversityCriteria") %></p>
    </aside>

    <section class="tasks-directory" aria-labelledby="tasksDirectoryTitle">
        <div class="tasks-directory-header">
            <h3 id="tasksDirectoryTitle" class="tasks-directory-title"><%: L.T("Company.Tasks.TaskDirectory") %></h3>
            <p class="tasks-directory-description">
                <asp:Literal ID="litTaskCount" runat="server" /> <%: L.T("Company.Tasks.Tasks") %>
                <span aria-hidden="true">&middot;</span>
                <%: L.T("Company.Tasks.AssignmentsDeadlinesSubmissionsAndFeedback") %>
            </p>

            <div class="tasks-filters">
                <div class="tasks-search-wrap">
                    <input id="tasksSearch" type="search" class="tasks-filter-control tasks-search"
                           placeholder="<%: L.T("Company.Tasks.SearchTasksOrTrainees") %>" aria-label="<%: L.T("Company.Tasks.SearchTasksOrTrainees") %>"
                           oninput="filterCompanyTasks()" />
                </div>
                <select id="tasksDepartmentFilter" class="form-select tasks-filter-control"
                        aria-label="<%: L.T("Company.Tasks.FilterByDepartment") %>" onchange="filterCompanyTasks()">
                    <option value=""><%: L.T("Company.Trainees.AllDepartments") %></option>
                </select>
                <select id="tasksStatusFilter" class="form-select tasks-filter-control"
                        aria-label="<%: L.T("Company.Tasks.FilterByTaskStatus") %>" onchange="filterCompanyTasks()">
                    <option value=""><%: L.T("Company.I18n.Alltaskstatuses") %></option>
                    <option value="Pending review"><%: L.T("Company.Tasks.PendingReview") %></option>
                    <option value="Reviewed"><%: L.T("Company.Tasks.Reviewed") %></option>
                    <option value="Revision needed"><%: L.T("Company.I18n.Revisionneeded") %></option>
                    <option value="In progress"><%: L.T("Company.Trainees.InProgress") %></option>
                </select>
            </div>
        </div>

        <div class="tasks-table-wrap">
            <table class="tasks-table">
                <thead>
                    <tr>
                        <th scope="col"><%: L.T("Company.Tasks.TaskTrainee") %></th>
                        <th scope="col"><%: L.T("Company.Tasks.DueDate") %></th>
                        <th scope="col"><%: L.T("Company.Tasks.Submission") %></th>
                        <th scope="col"><%: L.T("Company.Tasks.Status2") %></th>
                        <th scope="col"><%: L.T("Company.Tasks.Evaluation") %></th>
                        <th scope="col"><%: L.T("Company.Tasks.Action") %></th>
                    </tr>
                </thead>
                <tbody id="companyTasksBody">
                    <asp:Repeater ID="rptCompanyTasks" runat="server">
                        <ItemTemplate>
                            <tr data-task-status='<%#: Eval("TaskStatusLabel") %>'
                                data-department='<%#: Eval("Department") %>'
                                data-task-title='<%#: Eval("Title") %>'
                                data-task-trainee='<%#: Eval("Trainee") %>'
                                data-task-department='<%#: Eval("Department") %>'
                                data-task-description='<%#: Eval("Description") %>'
                                data-task-instructions='<%#: Eval("Instructions") %>'
                                data-task-start='<%#: Eval("StartDate") %>'
                                data-task-deadline='<%#: Eval("Deadline") %>'
                                data-task-status-label='<%#: L.Value("Ui", Eval("TaskStatusLabel")) %>'
                                data-task-submission-status='<%#: L.Value("Ui", Eval("SubmissionStatus")) %>'
                                data-task-evaluation='<%#: Eval("EvaluationSummary") %>'
                                data-task-max-score='<%#: Eval("MaxScore") %>'
                                data-task-attachment-name='<%#: Eval("AttachmentName") %>'
                                data-task-attachment-url='<%#: Eval("AttachmentUrl") %>'>
                                <td>
                                    <div class="tasks-title-cell"><%#: Eval("Title") %></div>
                                    <div class="tasks-trainee-name"><%#: Eval("Trainee") %></div>
                                    <div class="tasks-trainee-department"><%#: Eval("Department") %></div>
                                </td>
                                <td><%#: Eval("Deadline") %></td>
                                <td><span class="tasks-submission-status"><%#: L.Value("Ui", Eval("SubmissionStatus")) %></span></td>
                                <td><span class="<%#: Eval("TaskStatusCss") %>"><%#: L.Value("Ui", Eval("TaskStatusLabel")) %></span></td>
                                <td><span class="tasks-evaluation"><%#: Eval("EvaluationSummary") %></span></td>
                                <td>
                                    <asp:HyperLink runat="server"
                                        Visible='<%# Convert.ToBoolean(Eval("NeedsReview")) %>'
                                        NavigateUrl='<%# "TaskReview.aspx?taskId=" + Eval("TaskId") %>'
                                        Text="<%$ Resources:Company, Tasks.Review %>"
                                        CssClass="tasks-review-button" />
                                    <a href="#" class="tasks-details-button"
                                       style='<%# Convert.ToBoolean(Eval("NeedsReview")) ? "display:none" : "" %>'
                                       onclick="return showTaskDetails(this);"><%: L.T("Company.Tasks.ViewDetails") %></a>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>

        <asp:Label ID="lblNoCompanyTasks" runat="server"
            Text="<%$ Resources:Company, Tasks.NoTasksCreatedYet %>" CssClass="tasks-empty" Visible="false" />

        <div id="tasksFilteredEmpty" class="tasks-empty" style="display:none">
            <%: L.T("Company.Tasks.NoTasksMatchYourSearchOr") %>
        </div>

        <div class="tasks-directory-footer">
            <span id="tasksPageSummary"><%: L.T("Company.Tasks.Showing0Tasks") %></span>
            <nav class="tasks-pagination" aria-label="<%: L.T("Company.Tasks.TaskPages") %>">
                <button type="button" class="tasks-page-button" id="tasksPrevPage"
                        onclick="changeTasksPage(-1)" aria-label="<%: L.T("Company.Tasks.PreviousPage") %>">&lsaquo;</button>
                <span id="tasksPageButtons"></span>
                <button type="button" class="tasks-page-button" id="tasksNextPage"
                        onclick="changeTasksPage(1)" aria-label="<%: L.T("Company.Tasks.NextPage") %>">&rsaquo;</button>
            </nav>
        </div>
    </section>
</div>

<div id="taskCreateView" class="create-task-overlay" style="display:none;"
     role="dialog" aria-modal="true" aria-labelledby="createTaskTitle"
     onclick="if(event.target===this){showTasksList();}">
    <div class="create-task-dialog">
        <a href="javascript:void(0)" class="create-task-back" onclick="showTasksList()"><%: L.T("Company.Tasks.AllTasks") %></a>
        <button type="button" class="btn-close float-end" aria-label="<%: L.T("Company.Tasks.Close2") %>" onclick="showTasksList()"></button>
        <h1 id="createTaskTitle" class="create-task-title"><%: L.T("Company.Tasks.CreateNewTask2") %></h1>
        <p class="create-task-subtitle"><%: L.T("Company.Tasks.CreateATaskSetItsDeadline") %></p>

        <div class="create-task-card">
            <h2 class="create-task-section-title"><%: L.T("Company.Tasks.TaskInformation") %></h2>
            <p class="create-task-section-note"><%: L.T("Company.Tasks.EnterTheMainDetailsForThis") %></p>

            <div class="mb-3">
                <asp:Label ID="lblTaskTitle" runat="server" AssociatedControlID="txtTitle" CssClass="form-label" Text="<%$ Resources:Company, Tasks.TaskTitle2 %>" />
                <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" MaxLength="120" placeholder="<%$ Resources:Company, Tasks.EnterTaskTitle %>" />
            </div>
            <div class="mb-3">
                <asp:Label ID="lblDescription" runat="server" AssociatedControlID="txtDescription" CssClass="form-label" Text="<%$ Resources:Company, Tasks.TaskDescription %>" />
                <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" placeholder="<%$ Resources:Company, Tasks.DescribeWhatTheTraineeNeedsTo %>" />
            </div>

            <div class="row">
                <div class="col-md-4 mb-3">
                    <asp:Label ID="lblTrainee" runat="server" AssociatedControlID="ddlTrainee" CssClass="form-label" Text="<%$ Resources:Company, Tasks.AssignTrainee %>" />
                    <asp:DropDownList ID="ddlTrainee" runat="server" CssClass="form-select">
                        <asp:ListItem Text="<%$ Resources:Company, Tasks.SelectTrainee %>" Value="" />
                    </asp:DropDownList>
                </div>
                <div class="col-md-4 mb-3">
                    <asp:Label ID="lblStartDate" runat="server" AssociatedControlID="txtStartDate" CssClass="form-label" Text="<%$ Resources:Company, Tasks.StartDateTime %>" />
                    <asp:TextBox ID="txtStartDate" runat="server" CssClass="form-control" TextMode="DateTimeLocal" />
                </div>
                <div class="col-md-4 mb-3">
                    <asp:Label ID="lblDeadline" runat="server" AssociatedControlID="txtDeadline" CssClass="form-label" Text="<%$ Resources:Company, Tasks.DeadlineTime %>" />
                    <asp:TextBox ID="txtDeadline" runat="server" CssClass="form-control" TextMode="DateTimeLocal" />
                </div>
            </div>

            <hr class="create-task-divider" />
            <h2 class="create-task-section-title"><%: L.T("Company.Tasks.EvaluationCriteria") %></h2>
            <p class="create-task-section-note"><%: L.T("Company.Tasks.DefineHowTheTaskWillBe") %></p>

            <div class="mb-3">
                <asp:Label ID="lblMaxScore" runat="server" AssociatedControlID="txtMaxScore" CssClass="form-label" Text="<%$ Resources:Company, Tasks.TotalScore %>" />
                <asp:TextBox ID="txtMaxScore" runat="server" CssClass="form-control" TextMode="Number" min="1" step="1" placeholder="<%$ Resources:Company, Tasks.100Points %>" />
            </div>
            <div class="mb-3">
                <asp:Label ID="lblInstructions" runat="server" AssociatedControlID="txtInstructions" CssClass="form-label" Text="<%$ Resources:Company, Tasks.CriteriaAndInstructions %>" />
                <asp:TextBox ID="txtInstructions" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="4" placeholder="<%$ Resources:Company, Tasks.AddGradingCriteriaExpectedOutcomesAnd %>" />
            </div>

            <div class="mb-3">
                <asp:Label ID="lblTaskAttachment" runat="server" AssociatedControlID="fuTaskAttachment" CssClass="form-label" Text="<%$ Resources:Company, Tasks.TaskAttachmentOptional %>" />
                <asp:FileUpload ID="fuTaskAttachment" runat="server" CssClass="form-control" accept=".pdf,.doc,.docx" />
                <small class="text-muted"><%: L.T("Company.Tasks.PDFOrWordDocumentUpTo") %></small>
            </div>

            <asp:Label ID="lblMessage" runat="server" EnableViewState="false" CssClass="d-block mt-2" />
            <div class="create-task-footer">
                <span class="create-task-required"><%: L.T("Company.Tasks.RequiredFields") %></span>
                <div class="d-flex gap-2">
                    <button type="button" class="btn btn-outline-secondary btn-sm" onclick="showTasksList()"><%: L.T("Company.Tasks.Cancel2") %></button>
                    <asp:Button ID="btnCreateTask" runat="server" Text="<%$ Resources:Company, Tasks.CreateTask2 %>" CssClass="btn tasks-create-button btn-sm"
                        OnClientClick="rememberTaskForm();" OnClick="btnCreateTask_Click" />
                </div>
            </div>
        </div>

        <asp:Panel ID="pnlLegacyCriteria" runat="server" Visible="false">
            <asp:TextBox ID="txtWeight" runat="server" Text="1" />
            <asp:TextBox ID="txtCriterionName" runat="server" />
            <asp:TextBox ID="txtCriterionDescription" runat="server" />
            <asp:TextBox ID="txtCriterionMaxScore" runat="server" />
            <asp:TextBox ID="txtCriterionWeight" runat="server" />
            <asp:Button ID="btnAddCriterion" runat="server" OnClick="btnAddCriterion_Click" />
            <asp:GridView ID="gvCriteria" runat="server" />
        </asp:Panel>
    </div>
</div>

<div id="taskDetailsOverlay" class="task-modal-overlay" style="display:none;" role="dialog" aria-modal="true" aria-labelledby="taskDetailsTitle" onclick="if(event.target===this){closeTaskDetails();}">
    <section class="task-modal-dialog task-details-dialog">
        <button type="button" class="btn-close float-end" aria-label="<%: L.T("Company.Tasks.CloseTaskDetails") %>" onclick="closeTaskDetails()"></button>
        <span class="tasks-stat-label"><%: L.T("Company.Tasks.TaskDetails") %></span>
        <h2 id="taskDetailsTitle" class="tasks-directory-title"></h2>
        <p id="taskDetailsTrainee" class="tasks-page-subtitle"></p>
        <div class="task-details-grid">
            <div><span><%: L.T("Company.Tasks.TaskStatus") %></span><strong id="taskDetailsStatus"></strong></div>
            <div><span><%: L.T("Company.Tasks.SubmissionStatus") %></span><strong id="taskDetailsSubmissionStatus"></strong></div>
            <div><span><%: L.T("Company.Tasks.Evaluation") %></span><strong id="taskDetailsEvaluation"></strong></div>
            <div><span><%: L.T("Company.Tasks.TotalScore2") %></span><strong id="taskDetailsMaxScore"></strong></div>
            <div><span><%: L.T("Company.Tasks.StartDateAndTime") %></span><strong id="taskDetailsStart"></strong></div>
            <div><span><%: L.T("Company.Tasks.Deadline3") %></span><strong id="taskDetailsDeadline"></strong></div>
        </div>
        <div class="task-details-section"><h3><%: L.T("Company.Tasks.Description2") %></h3><p id="taskDetailsDescription"></p></div>
        <div class="task-details-section"><h3><%: L.T("Company.Tasks.CriteriaAndInstructions2") %></h3><p id="taskDetailsInstructions"></p></div>
        <div id="taskDetailsAttachmentArea" class="task-details-section" style="display:none"><h3><%: L.T("Company.Tasks.TaskAttachment") %></h3><a id="taskDetailsAttachment" target="_blank" rel="noopener noreferrer"></a></div>
        <div class="text-end mt-4"><button type="button" class="btn btn-outline-secondary" onclick="closeTaskDetails()"><%: L.T("Company.Tasks.Close2") %></button></div>
    </section>
</div>

<div id="taskSuccessOverlay" class="task-success-overlay" style="display:none;" role="alertdialog" aria-modal="true" aria-labelledby="taskSuccessTitle" aria-describedby="taskSuccessMessage">
    <div class="task-success-dialog">
        <div class="task-success-check" aria-hidden="true">
            <svg viewBox="0 0 24 24" focusable="false"><path d="m5 12.5 4.2 4.2L19 7" /></svg>
        </div>
        <h2 id="taskSuccessTitle"><%: L.T("Company.Tasks.TaskCreated") %></h2>
        <p id="taskSuccessMessage"><%: L.T("Company.Tasks.TheTaskWasSuccessfullyAssignedTo") %></p>
        <button type="button" class="btn tasks-create-button" onclick="closeTaskSuccessDialog()"><%: L.T("Company.Tasks.Done") %></button>
    </div>
</div>

<script>
    function showTaskDetails(link) {
        var row = link.closest("tr");
        if (!row) return false;
        var data = row.dataset;
        document.getElementById("taskDetailsTitle").textContent = data.taskTitle || uimsT('ArabicTaskdetails');
        document.getElementById("taskDetailsTrainee").textContent = (data.taskTrainee || "") + (data.taskDepartment ? " - " + data.taskDepartment : "");
        document.getElementById("taskDetailsStatus").textContent = data.taskStatusLabel || uimsT('ArabicNotset');
        document.getElementById("taskDetailsSubmissionStatus").textContent = data.taskSubmissionStatus || uimsT('ArabicNotsubmitted');
        document.getElementById("taskDetailsEvaluation").textContent = data.taskEvaluation || uimsT('ArabicNotevaluated');
        document.getElementById("taskDetailsMaxScore").textContent = data.taskMaxScore ? data.taskMaxScore + uimsT('Arabicpoints') : uimsT('ArabicNotset');
        document.getElementById("taskDetailsStart").textContent = data.taskStart || uimsT('ArabicNotset');
        document.getElementById("taskDetailsDeadline").textContent = data.taskDeadline || uimsT('ArabicNotset');
        document.getElementById("taskDetailsDescription").textContent = data.taskDescription || uimsT('ArabicNodescriptionprovided');
        document.getElementById("taskDetailsInstructions").textContent = data.taskInstructions || uimsT('ArabicNoadditionalinstructions');
        var attachmentArea = document.getElementById("taskDetailsAttachmentArea");
        var attachmentLink = document.getElementById("taskDetailsAttachment");
        var safeUrl = null;
        try { safeUrl = new URL(data.taskAttachmentUrl || "", window.location.href); } catch (ignore) { safeUrl = null; }
        if (safeUrl && (safeUrl.protocol === "https:" || safeUrl.protocol === "http:") && data.taskAttachmentUrl) {
            attachmentLink.href = safeUrl.href;
            attachmentLink.textContent = data.taskAttachmentName || uimsT('ArabicOpentaskattachment');
            attachmentArea.style.display = "";
        } else {
            attachmentLink.removeAttribute("href");
            attachmentArea.style.display = "none";
        }
        document.getElementById("taskDetailsOverlay").style.display = "flex";
        document.body.style.overflow = "hidden";
        return false;
    }
    function closeTaskDetails() {
        document.getElementById("taskDetailsOverlay").style.display = "none";
        document.body.style.overflow = "";
    }

    var companyTasksPage = 1;
    var companyTasksPageSize = 5;

    function getCompanyTaskRows() {
        var body = document.getElementById("companyTasksBody");
        var rows = [];

        if (!(body instanceof HTMLTableSectionElement)) {
            return rows;
        }

        var tableRows = body.getElementsByTagName("tr");
        for (var i = 0; i < tableRows.length; i++) {
            rows.push(tableRows[i]);
        }
        return rows;
    }

    function filterCompanyTasks() {
        companyTasksPage = 1;
        renderCompanyTasks();
    }

    /** @param {number} direction */
    function changeTasksPage(direction) {
        companyTasksPage = companyTasksPage + direction;
        renderCompanyTasks();
    }

    function renderCompanyTasks() {
        var rows = getCompanyTaskRows();
        var searchElement = document.getElementById("tasksSearch");
        var departmentElement = document.getElementById("tasksDepartmentFilter");
        var statusElement = document.getElementById("tasksStatusFilter");

        var query = searchElement instanceof HTMLInputElement ? searchElement.value.toLowerCase() : "";
        var department = departmentElement instanceof HTMLSelectElement ? departmentElement.value : "";
        var status = statusElement instanceof HTMLSelectElement ? statusElement.value : "";
        var matchingRows = [];

        for (var i = 0; i < rows.length; i++) {
            var row = rows[i];
            var rowText = row.textContent || "";
            var rowDepartment = row.getAttribute("data-department") || "";
            var rowStatus = row.getAttribute("data-task-status") || "";

            var matchesSearch = query === "" || rowText.toLowerCase().indexOf(query) !== -1;
            var matchesDepartment = department === "" || rowDepartment === department;
            var matchesStatus = status === "" || rowStatus === status;

            if (matchesSearch && matchesDepartment && matchesStatus) {
                matchingRows.push(row);
            }
            row.style.display = "none";
        }

        var pageCount = Math.ceil(matchingRows.length / companyTasksPageSize);
        if (pageCount < 1) pageCount = 1;
        if (companyTasksPage > pageCount) companyTasksPage = pageCount;
        if (companyTasksPage < 1) companyTasksPage = 1;

        var start = (companyTasksPage - 1) * companyTasksPageSize;
        var end = start + companyTasksPageSize;

        for (var j = start; j < end && j < matchingRows.length; j++) {
            matchingRows[j].style.display = "";
        }

        var summary = document.getElementById("tasksPageSummary");
        var emptyMessage = document.getElementById("tasksFilteredEmpty");
        var previousButton = document.getElementById("tasksPrevPage");
        var nextButton = document.getElementById("tasksNextPage");
        var pageButtons = document.getElementById("tasksPageButtons");

        if (summary) {
            if (matchingRows.length === 0) {
                summary.textContent = uimsT('ArabicShowing0tasks');
            } else {
                summary.textContent = uimsT('TasksShowingRange', start + 1, Math.min(end, matchingRows.length), matchingRows.length);
            }
        }

        if (emptyMessage) {
            emptyMessage.style.display =
                matchingRows.length === 0 && rows.length > 0 ? "block" : "none";
        }

        if (previousButton instanceof HTMLButtonElement) {
            previousButton.disabled = companyTasksPage <= 1;
        }
        if (nextButton instanceof HTMLButtonElement) {
            nextButton.disabled = companyTasksPage >= pageCount;
        }

        if (pageButtons) {
            pageButtons.innerHTML = "";

            for (var page = 1; page <= pageCount; page++) {
                var button = document.createElement("button");
                button.type = "button";
                button.className = "tasks-page-button";
                button.textContent = String(page);

                if (page === companyTasksPage) {
                    button.setAttribute("aria-current", "page");
                }

                button.onclick = (function (selectedPage) {
                    return function () {
                        companyTasksPage = selectedPage;
                        renderCompanyTasks();
                    };
                })(page);

                pageButtons.appendChild(button);
            }
        }
    }

    function populateDepartmentFilter() {
        var select = document.getElementById("tasksDepartmentFilter");

        if (!(select instanceof HTMLSelectElement)) {
            return;
        }

        var rows = getCompanyTaskRows();

        for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) {
            var value = rows[rowIndex].getAttribute("data-department");

            if (!value || value === "-") {
                continue;
            }

            var exists = false;
            for (var optionIndex = 0; optionIndex < select.options.length; optionIndex++) {
                if (select.options[optionIndex].value === value) {
                    exists = true;
                    break;
                }
            }

            if (!exists) {
                var option = document.createElement("option");
                option.value = value;
                option.textContent = value;
                select.appendChild(option);
            }
        }
    }

    function showTaskForm() {
        document.getElementById("taskCreateView").style.display = "flex";
        document.body.style.overflow = "hidden";
        sessionStorage.setItem("manageTasksReturnToForm", "1");
    }

    function showTasksList() {
        document.getElementById("taskCreateView").style.display = "none";
        document.body.style.overflow = "";
        sessionStorage.removeItem("manageTasksReturnToForm");
    }

    function rememberTaskForm() {
        sessionStorage.setItem("manageTasksReturnToForm", "1");
    }

    function showTaskSuccessDialog(taskCount) {
        showTasksList();
        document.getElementById("taskSuccessMessage").textContent = taskCount === 1
            ? uimsT('ArabicThetaskwassuccessfullyassignedtothetrainee')
            : uimsT('TasksCreatedMany', taskCount);
        document.getElementById("taskSuccessOverlay").style.display = "flex";
        document.body.style.overflow = "hidden";
    }

    function closeTaskSuccessDialog() {
        document.getElementById("taskSuccessOverlay").style.display = "none";
        document.body.style.overflow = "";
    }

    populateDepartmentFilter();
    renderCompanyTasks();

    if (sessionStorage.getItem("manageTasksReturnToForm") === "1") {
        sessionStorage.removeItem("manageTasksReturnToForm");
        showTaskForm();
    }
</script>
</asp:Content>




