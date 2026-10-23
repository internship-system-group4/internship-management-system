<%@ Page Language="C#" MasterPageFile="~/Layout/Company.master"
    AutoEventWireup="true" CodeBehind="Tasks.aspx.cs"
    Inherits="InternshipManagementSystem.Pages.CompanyArea.Tasks"
    Title="Manage &amp; Review Tasks" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <style>
        .tasks-page {
            padding: 4px 0;
            color: #123c5d;
        }

        .tasks-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            margin-bottom: 22px;
        }

        .tasks-header h2 {
            margin: 0;
            color: #123c5d;
            font-size: 1.65rem;
            font-weight: 750;
        }

        .tasks-header p {
            margin: 6px 0 0;
            color: #617993;
        }

        .tasks-primary-button {
            min-height: 40px;
            padding: 9px 15px;
            border-radius: 7px;
            font-weight: 650;
        }

        .tasks-summary {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 18px;
            margin: 24px 0;
        }

        .tasks-summary-card {
            padding: 16px 19px;
            background: #fff;
            border: 1px solid #dce6f1;
            border-radius: 11px;
        }

        .tasks-summary-top {
            display: flex;
            align-items: center;
            justify-content: space-between;
            color: #315779;
            font-size: .84rem;
        }

        .tasks-summary-icon {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 30px;
            height: 30px;
            color: #244f73;
            background: #edf4ff;
            border-radius: 7px;
            font-size: 1rem;
        }

        .tasks-summary-number {
            display: block;
            margin: 3px 0;
            color: #123c5d;
            font-size: 1.7rem;
            font-weight: 750;
            line-height: 1.2;
        }

        .tasks-summary-card small {
            color: #71869b;
            font-size: .72rem;
        }

        .tasks-reminder {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 20px;
            padding: 12px 15px;
            color: #244f73;
            background: #e4f0ff;
            border-radius: 8px;
            font-size: .82rem;
        }

        .tasks-reminder-icon {
            flex: 0 0 auto;
            font-size: 1rem;
        }

        .tasks-reminder strong {
            display: block;
            margin-bottom: 2px;
        }

        .tasks-panel {
            overflow: hidden;
            background: #fff;
            border: 1px solid #dce6f1;
            border-radius: 11px;
        }

        .tasks-panel-heading {
            padding: 18px 19px 11px;
        }

        .tasks-panel-heading h3 {
            margin: 0;
            color: #123c5d;
            font-size: 1.12rem;
            font-weight: 700;
        }

        .tasks-panel-heading p {
            margin: 4px 0 0;
            color: #71869b;
            font-size: .78rem;
        }

        .tasks-toolbar {
            display: grid;
            grid-template-columns: minmax(220px, 1.5fr) repeat(2, minmax(145px, .9fr));
            gap: 10px;
            padding: 0 19px 15px;
        }

        .tasks-toolbar label {
            display: block;
            margin-bottom: 5px;
            color: #60778d;
            font-size: .75rem;
            font-weight: 600;
        }

        .tasks-toolbar .form-control,
        .tasks-toolbar .form-select {
            min-height: 36px;
            border-color: #d9e3ed;
            border-radius: 7px;
            font-size: .78rem;
        }

        .tasks-table-wrap {
            overflow-x: auto;
            border-top: 1px solid #e2eaf2;
        }

        .tasks-table {
            width: 100%;
            min-width: 790px;
            border-collapse: collapse;
            font-size: .78rem;
        }

        .tasks-table th {
            padding: 10px 12px;
            color: #173f61;
            background: #edf4ff;
            border-bottom: 1px solid #dce6f1;
            text-align: left;
            white-space: nowrap;
            font-size: .72rem;
            font-weight: 700;
        }

        .tasks-table td {
            padding: 10px 12px;
            color: #46515c;
            border-bottom: 1px solid #e4ebf2;
            vertical-align: middle;
        }

        .tasks-row:last-child td {
            border-bottom: 0;
        }

        .tasks-title,
        .tasks-trainee {
            display: block;
        }

        .tasks-title {
            margin-bottom: 3px;
            color: #123c5d;
            font-weight: 700;
        }

        .tasks-trainee {
            color: #71869b;
            font-size: .68rem;
        }

        .tasks-status-badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 20px;
            font-size: .68rem;
            font-weight: 650;
            white-space: nowrap;
        }

        .tasks-status-pending,
        .tasks-status-progress {
            color: #245b91;
            background: #e4f0ff;
        }

        .tasks-status-reviewed {
            color: #26734d;
            background: #e8f5ed;
        }

        .tasks-status-revision {
            color: #925113;
            background: #fff0df;
        }

        .tasks-status-neutral {
            color: #53677a;
            background: #eff2f5;
        }

        .tasks-action {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 75px;
            min-height: 30px;
            padding: 5px 10px;
            border-radius: 6px;
            font-size: .72rem;
            font-weight: 650;
            text-decoration: none;
            white-space: nowrap;
        }

        .tasks-action-primary {
            color: #fff;
            background: #244f73;
            border: 1px solid #244f73;
        }

        .tasks-action-primary:hover {
            color: #fff;
            background: #193e5f;
        }

        .tasks-action-outline {
            color: #244f73;
            background: #fff;
            border: 1px solid #557b9c;
        }

        .tasks-action-outline:hover {
            color: #173b5b;
            background: #f4f8fc;
        }

        .tasks-empty {
            display: block;
            padding: 28px 18px;
            color: #71869b;
            text-align: center;
        }

        .tasks-filtered-out,
        .tasks-page-hidden {
            display: none !important;
        }

        .tasks-pagination {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            padding: 9px 12px;
            color: #617a92;
            border-top: 1px solid #e4ebf2;
            font-size: .74rem;
        }

        .tasks-pagination-controls {
            display: flex;
            align-items: center;
            gap: 4px;
        }

        .tasks-pagination button {
            min-width: 30px;
            height: 30px;
            padding: 0 8px;
            color: #244f73;
            background: #fff;
            border: 1px solid #dce6f1;
            border-radius: 6px;
            cursor: pointer;
        }

        .tasks-pagination button.active {
            color: #fff;
            background: #244f73;
            border-color: #244f73;
        }

        .tasks-pagination button:disabled {
            opacity: .45;
            cursor: default;
        }

        /* Create-task dialog */
        .task-modal-overlay {
            position: fixed;
            inset: 0;
            z-index: 2000;
            display: none;
            align-items: center;
            justify-content: center;
            padding: 16px;
            background: rgba(15, 23, 42, .55);
            -webkit-backdrop-filter: blur(5px);
            backdrop-filter: blur(5px);
        }

        .task-modal-dialog {
            width: 100%;
            max-width: 820px;
            max-height: calc(100vh - 32px);
            overflow-y: auto;
            color: #123c5d;
            background: #fff;
            border: 1px solid #dce6f1;
            border-radius: 13px;
            box-shadow: 0 24px 65px rgba(0, 0, 0, .24);
        }

        .task-modal-header,
        .task-modal-body {
            padding: 20px;
        }

        .task-modal-header {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 14px;
            border-bottom: 1px solid #e2eaf2;
        }

        .task-modal-header h3 {
            margin: 0 0 5px;
            font-size: 1.15rem;
        }

        .task-modal-header p {
            margin: 0;
            color: #71869b;
            font-size: .82rem;
        }

        .task-close {
            width: 36px;
            height: 36px;
            color: #244f73;
            background: #fff;
            border: 1px solid #dce6f1;
            border-radius: 7px;
            font-size: 1.3rem;
            cursor: pointer;
        }

        .task-section + .task-section {
            margin-top: 20px;
            padding-top: 18px;
            border-top: 1px solid #e2eaf2;
        }

        .task-section h4 {
            margin: 0 0 5px;
            font-size: .98rem;
            font-weight: 700;
        }

        .task-section-description {
            margin: 0 0 13px;
            color: #71869b;
            font-size: .8rem;
        }

        .task-field {
            margin-bottom: 12px;
        }

        .task-fields-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 12px;
        }

        .task-criteria-editor {
            padding: 13px;
            background: #f6f8fb;
            border: 1px solid #dce6f1;
            border-radius: 8px;
        }

        .task-criteria-table {
            margin-top: 12px;
            overflow-x: auto;
        }

        .task-modal-footer {
            display: flex;
            justify-content: flex-end;
            gap: 9px;
            margin-top: 16px;
            padding-top: 15px;
            border-top: 1px solid #e2eaf2;
        }

        @media (max-width: 760px) {
            .tasks-header {
                align-items: stretch;
                flex-direction: column;
            }

            .tasks-summary {
                gap: 10px;
            }

            .tasks-toolbar {
                grid-template-columns: 1fr 1fr;
            }

            .tasks-toolbar > div:first-child {
                grid-column: 1 / -1;
            }
        }

        @media (max-width: 520px) {
            .tasks-summary {
                grid-template-columns: 1fr;
            }

            .tasks-toolbar,
            .task-fields-grid {
                grid-template-columns: 1fr;
            }

            .tasks-toolbar > div:first-child {
                grid-column: auto;
            }

            .tasks-pagination {
                align-items: flex-start;
                flex-direction: column;
            }

            .task-modal-overlay {
                padding: 8px;
            }

            .task-modal-dialog {
                max-height: calc(100vh - 16px);
            }

            .task-modal-header,
            .task-modal-body {
                padding: 15px;
            }

            .task-modal-footer > .btn {
                flex: 1;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="tasks-page">

        <div class="tasks-header">
            <div>
                <h2>Manage &amp; review tasks</h2>
                <p>Create tasks, review submissions, and track trainee progress.</p>
            </div>

            <button type="button"
                class="btn btn-brand tasks-primary-button"
                onclick="showTaskForm()">
                + &nbsp; Create new task
            </button>
        </div>

        <div class="tasks-summary">
            <div class="tasks-summary-card">
                <div class="tasks-summary-top">
                    <span>Pending review</span>
                    <span class="tasks-summary-icon">&#9711;</span>
                </div>
                <strong class="tasks-summary-number">
                    <asp:Literal ID="litPendingReview" runat="server" />
                </strong>
                <small>Awaiting your evaluation</small>
            </div>

            <div class="tasks-summary-card">
                <div class="tasks-summary-top">
                    <span>Reviewed</span>
                    <span class="tasks-summary-icon">&#10003;</span>
                </div>
                <strong class="tasks-summary-number">
                    <asp:Literal ID="litReviewedTasks" runat="server" />
                </strong>
                <small>Evaluations completed</small>
            </div>

            <div class="tasks-summary-card">
                <div class="tasks-summary-top">
                    <span>Overdue tasks</span>
                    <span class="tasks-summary-icon">!</span>
                </div>
                <strong class="tasks-summary-number">
                    <asp:Literal ID="litOverdueTasks" runat="server" />
                </strong>
                <small>Past their due date</small>
            </div>
        </div>

        <div class="tasks-reminder">
            <span class="tasks-reminder-icon">&#9432;</span>
            <div>
                <strong>Review reminder</strong>
                Evaluate submissions using university criteria, give constructive
                feedback, and request revisions when needed.
            </div>
        </div>

        <section class="tasks-panel" aria-label="Task directory">
            <div class="tasks-panel-heading">
                <h3>Task directory</h3>
                <p>
                    <asp:Literal ID="litTaskCount" runat="server" />
                    tasks · assignments, deadlines, submissions, and feedback
                </p>
            </div>

            <div class="tasks-toolbar">
                <div>
                    <label for="taskSearch">Search tasks or trainees</label>
                    <input type="search"
                        id="taskSearch"
                        class="form-control"
                        placeholder="Search tasks or trainees"
                        autocomplete="off" />
                </div>

                <div>
                    <label for="taskTraineeFilter">Department</label>
                    <select id="taskTraineeFilter" class="form-select">
                        <option value="">All departments</option>
                    </select>
                </div>

                <div>
                    <label for="taskSubmissionFilter">Status</label>
                    <select id="taskSubmissionFilter" class="form-select">
                        <option value="">All task statuses</option>
                    </select>
                </div>
            </div>

            <div class="tasks-table-wrap">
                <table class="tasks-table">
                    <thead>
                        <tr>
                            <th>Task / trainee</th>
                            <th>Due date</th>
                            <th>Submission</th>
                            <th>Status</th>
                            <th>Evaluation</th>
                            <th class="text-end">Action</th>
                        </tr>
                    </thead>

                    <tbody id="companyTaskList">
                        <asp:Repeater ID="rptCompanyTasks" runat="server">
                            <ItemTemplate>
                                <tr class="tasks-row"
                                    data-department="<%#: Eval("Department") %>"
                                    data-task-status="<%#: Eval("TaskStatusLabel") %>">
                                    <td>
                                        <strong class="tasks-title">
                                            <%#: Eval("Title") %>
                                        </strong>
                                        <span class="tasks-trainee">
                                            <%#: Eval("Trainee") %> ·
                                            <%#: Eval("Department") %>
                                        </span>
                                    </td>

                                    <td><%#: Eval("Deadline") %></td>

                                    <td>
                                        <span class="tasks-submission">
                                            <%#: Eval("SubmissionStatus") %>
                                        </span>
                                    </td>

                                    <td>
                                        <span class='<%#: Eval("TaskStatusCss") %>'>
                                            <%#: Eval("TaskStatusLabel") %>
                                        </span>
                                    </td>

                                    <td><%#: Eval("EvaluationSummary") %></td>

                                    <td class="text-end">
                                        <asp:HyperLink runat="server"
                                            NavigateUrl='<%# ResolveUrl("~/Pages/Company/TaskReview.aspx") + "?taskId=" + System.Web.HttpUtility.UrlEncode(Convert.ToString(Eval("TaskId"))) %>'
                                            Text='<%# Convert.ToBoolean(Eval("NeedsReview")) ? "Review" : "View details" %>'
                                            CssClass='<%# Convert.ToBoolean(Eval("NeedsReview")) ? "tasks-action tasks-action-primary" : "tasks-action tasks-action-outline" %>' />
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>

            <asp:Label ID="lblNoCompanyTasks"
                runat="server"
                CssClass="tasks-empty"
                Text="No tasks yet. Create your first task to get started." />

            <div id="taskNoMatches" class="tasks-empty" hidden="hidden">
                No matching tasks. Try changing the search or filters.
            </div>

            <div class="tasks-pagination">
                <span id="tasksPageSummary">Showing 0 of 0 tasks</span>

                <div class="tasks-pagination-controls">
                    <button type="button" id="tasksPrev"
                        aria-label="Previous page">‹</button>
                    <span id="tasksPageButtons"></span>
                    <button type="button" id="tasksNext"
                        aria-label="Next page">›</button>
                </div>
            </div>
        </section>

        <div id="taskModal"
            class="task-modal-overlay"
            role="dialog"
            aria-modal="true"
            aria-labelledby="taskModalTitle"
            aria-hidden="true">

            <div class="task-modal-dialog">
                <div class="task-modal-header">
                    <div>
                        <h3 id="taskModalTitle">Create new task</h3>
                        <p>Set the assignment details and evaluation criteria.</p>
                    </div>

                    <button type="button"
                        class="task-close"
                        aria-label="Close"
                        onclick="showTasksList()">
                        &times;
                    </button>
                </div>

                <div class="task-modal-body">
                    <section class="task-section">
                        <h4>Task details</h4>
                        <p class="task-section-description">
                            Describe the work and what the trainee should submit.
                        </p>

                        <div class="task-field">
                            <asp:Label ID="lblTaskTitle" runat="server"
                                AssociatedControlID="txtTitle"
                                CssClass="form-label"
                                Text="Task title" />
                            <asp:TextBox ID="txtTitle" runat="server"
                                CssClass="form-control"
                                placeholder="Enter a clear task title" />
                        </div>

                        <div class="task-field">
                            <asp:Label ID="lblDescription" runat="server"
                                AssociatedControlID="txtDescription"
                                CssClass="form-label"
                                Text="Description" />
                            <asp:TextBox ID="txtDescription" runat="server"
                                CssClass="form-control"
                                TextMode="MultiLine"
                                Rows="3" />
                        </div>

                        <div class="task-field">
                            <asp:Label ID="lblInstructions" runat="server"
                                AssociatedControlID="txtInstructions"
                                CssClass="form-label"
                                Text="Instructions" />
                            <asp:TextBox ID="txtInstructions" runat="server"
                                CssClass="form-control"
                                TextMode="MultiLine"
                                Rows="3" />
                        </div>
                    </section>

                    <section class="task-section">
                        <h4>Assignment &amp; scoring</h4>
                        <p class="task-section-description">
                            Select a trainee and set the deadline and scoring.
                        </p>

                        <div class="task-fields-grid">
                            <div class="task-field">
                                <asp:Label ID="lblTrainee" runat="server"
                                    AssociatedControlID="ddlTrainee"
                                    CssClass="form-label"
                                    Text="Assigned trainee" />
                                <asp:DropDownList ID="ddlTrainee" runat="server"
                                    CssClass="form-select">
                                    <asp:ListItem Text="Select a trainee" Value="" />
                                </asp:DropDownList>
                            </div>

                            <div class="task-field">
                                <asp:Label ID="lblDeadline" runat="server"
                                    AssociatedControlID="txtDeadline"
                                    CssClass="form-label"
                                    Text="Deadline" />
                                <asp:TextBox ID="txtDeadline" runat="server"
                                    CssClass="form-control"
                                    TextMode="DateTimeLocal" />
                            </div>

                            <div class="task-field">
                                <asp:Label ID="lblMaxScore" runat="server"
                                    AssociatedControlID="txtMaxScore"
                                    CssClass="form-label"
                                    Text="Maximum score" />
                                <asp:TextBox ID="txtMaxScore" runat="server"
                                    CssClass="form-control"
                                    TextMode="Number"
                                    min="0.01"
                                    step="0.01" />
                            </div>

                            <div class="task-field">
                                <asp:Label ID="lblWeight" runat="server"
                                    AssociatedControlID="txtWeight"
                                    CssClass="form-label"
                                    Text="Task weight" />
                                <asp:TextBox ID="txtWeight" runat="server"
                                    CssClass="form-control"
                                    TextMode="Number"
                                    min="0.01"
                                    step="0.01" />
                            </div>
                        </div>
                    </section>

                    <section class="task-section">
                        <h4>Evaluation criteria</h4>
                        <p class="task-section-description">
                            Add criteria. Their weights must total 100%.
                        </p>

                        <div class="task-criteria-editor">
                            <div class="task-field">
                                <asp:Label ID="lblCriterionName" runat="server"
                                    AssociatedControlID="txtCriterionName"
                                    CssClass="form-label"
                                    Text="Criterion name" />
                                <asp:TextBox ID="txtCriterionName" runat="server"
                                    CssClass="form-control" />
                            </div>

                            <div class="task-field">
                                <asp:Label ID="lblCriterionDescription" runat="server"
                                    AssociatedControlID="txtCriterionDescription"
                                    CssClass="form-label"
                                    Text="Criterion description" />
                                <asp:TextBox ID="txtCriterionDescription"
                                    runat="server"
                                    CssClass="form-control"
                                    TextMode="MultiLine"
                                    Rows="2" />
                            </div>

                            <div class="task-fields-grid">
                                <div class="task-field">
                                    <asp:Label ID="lblCriterionMaxScore" runat="server"
                                        AssociatedControlID="txtCriterionMaxScore"
                                        CssClass="form-label"
                                        Text="Maximum score" />
                                    <asp:TextBox ID="txtCriterionMaxScore"
                                        runat="server"
                                        CssClass="form-control"
                                        TextMode="Number"
                                        min="0.01"
                                        step="0.01" />
                                </div>

                                <div class="task-field">
                                    <asp:Label ID="lblCriterionWeight" runat="server"
                                        AssociatedControlID="txtCriterionWeight"
                                        CssClass="form-label"
                                        Text="Criterion weight (%)" />
                                    <asp:TextBox ID="txtCriterionWeight"
                                        runat="server"
                                        CssClass="form-control"
                                        TextMode="Number"
                                        min="0.01"
                                        max="100"
                                        step="0.01" />
                                </div>
                            </div>

                            <asp:Button ID="btnAddCriterion" runat="server"
                                Text="+ Add criterion"
                                CssClass="btn btn-outline-secondary"
                                CausesValidation="false"
                                OnClientClick="rememberTaskForm();"
                                OnClick="btnAddCriterion_Click"
                                data-ui-action="add"
                                data-loading-label="Updating."
                                data-ui-validation="none" />

                            <div class="task-criteria-table">
                                <asp:GridView ID="gvCriteria" runat="server"
                                    AutoGenerateColumns="false"
                                    CssClass="uims-table"
                                    GridLines="None"
                                    EmptyDataText="No criteria added yet."
                                    ShowHeaderWhenEmpty="true">
                                    <Columns>
                                        <asp:BoundField DataField="Name"
                                            HeaderText="Criterion"
                                            HtmlEncode="true" />
                                        <asp:BoundField DataField="Description"
                                            HeaderText="Description"
                                            HtmlEncode="true" />
                                        <asp:BoundField DataField="MaxScore"
                                            HeaderText="Max score" />
                                        <asp:BoundField DataField="Weight"
                                            HeaderText="Weight (%)" />
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </div>
                    </section>

                    <div class="task-modal-footer">
                        <button type="button"
                            class="btn btn-outline-secondary"
                            onclick="showTasksList()">
                            Cancel
                        </button>

                        <asp:Button ID="btnCreateTask" runat="server"
                            Text="Create task"
                            CssClass="btn btn-brand tasks-primary-button"
                            OnClientClick="rememberTaskForm();"
                            OnClick="btnCreateTask_Click"
                            data-ui-action="create"
                            data-loading-label="Creating." />
                    </div>

                    <div class="mt-3" role="status">
                        <asp:Label ID="lblMessage" runat="server"
                            EnableViewState="false" />
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        function showTaskForm() {
            var modal = document.getElementById("taskModal");
            if (!modal) return;

            modal.style.display = "flex";
            modal.setAttribute("aria-hidden", "false");
            document.body.style.overflow = "hidden";
        }

        function showTasksList() {
            var modal = document.getElementById("taskModal");
            if (!modal) return;

            modal.style.display = "none";
            modal.setAttribute("aria-hidden", "true");
            document.body.style.overflow = "";

            try {
                sessionStorage.removeItem("manageTasksReturnToForm");
            } catch (error) { }
        }

        function rememberTaskForm() {
            try {
                sessionStorage.setItem("manageTasksReturnToForm", "1");
            } catch (error) { }
        }

        (function () {
            var list = document.getElementById("companyTaskList");
            var search = document.getElementById("taskSearch");
            var department = document.getElementById("taskTraineeFilter");
            var status = document.getElementById("taskSubmissionFilter");
            var previousButton = document.getElementById("tasksPrev");
            var nextButton = document.getElementById("tasksNext");
            var pageButtons = document.getElementById("tasksPageButtons");
            var pageSummary = document.getElementById("tasksPageSummary");
            var noMatches = document.getElementById("taskNoMatches");

            if (!list || !search || !department || !status ||
                !previousButton || !nextButton || !pageButtons ||
                !pageSummary || !noMatches) {
                return;
            }

            var pageSize = 5;
            var currentPage = 1;
            var rows = Array.prototype.slice.call(
                list.querySelectorAll(".tasks-row")
            );

            function addOptions(select, values) {
                var uniqueValues = [];

                values.forEach(function (value) {
                    value = (value || "").trim();

                    if (value && uniqueValues.indexOf(value) < 0) {
                        uniqueValues.push(value);
                    }
                });

                uniqueValues.sort();

                uniqueValues.forEach(function (value) {
                    var option = document.createElement("option");
                    option.value = value;
                    option.textContent = value;
                    select.appendChild(option);
                });
            }

            addOptions(department, rows.map(function (row) {
                return row.getAttribute("data-department");
            }));

            addOptions(status, rows.map(function (row) {
                return row.getAttribute("data-task-status");
            }));

            function render() {
                var query = search.value.trim().toLocaleLowerCase();
                var selectedDepartment = department.value;
                var selectedStatus = status.value;

                var matches = rows.filter(function (row) {
                    var rowText = row.textContent.toLocaleLowerCase();
                    var rowDepartment =
                        row.getAttribute("data-department") || "";
                    var rowStatus =
                        row.getAttribute("data-task-status") || "";

                    return (!query || rowText.indexOf(query) >= 0) &&
                        (!selectedDepartment ||
                            rowDepartment === selectedDepartment) &&
                        (!selectedStatus || rowStatus === selectedStatus);
                });

                var pageCount = Math.max(
                    1, Math.ceil(matches.length / pageSize)
                );

                if (currentPage > pageCount) currentPage = pageCount;

                rows.forEach(function (row) {
                    row.classList.add("tasks-page-hidden");
                });

                var startIndex = (currentPage - 1) * pageSize;
                var visibleRows = matches.slice(
                    startIndex, startIndex + pageSize
                );

                visibleRows.forEach(function (row) {
                    row.classList.remove("tasks-page-hidden");
                });

                noMatches.hidden = matches.length > 0;

                var firstShown = matches.length === 0 ? 0 : startIndex + 1;
                var lastShown = Math.min(
                    startIndex + pageSize, matches.length
                );

                pageSummary.textContent =
                    "Showing " + firstShown + "-" + lastShown +
                    " of " + matches.length + " tasks";

                previousButton.disabled = currentPage <= 1;
                nextButton.disabled = currentPage >= pageCount;
                pageButtons.innerHTML = "";

                for (var page = 1; page <= pageCount; page++) {
                    var button = document.createElement("button");
                    button.type = "button";
                    button.textContent = String(page);

                    if (page === currentPage) {
                        button.className = "active";
                    }

                    (function (pageNumber) {
                        button.addEventListener("click", function () {
                            currentPage = pageNumber;
                            render();
                        });
                    }(page));

                    pageButtons.appendChild(button);
                }
            }

            search.addEventListener("input", function () {
                currentPage = 1;
                render();
            });

            department.addEventListener("change", function () {
                currentPage = 1;
                render();
            });

            status.addEventListener("change", function () {
                currentPage = 1;
                render();
            });

            previousButton.addEventListener("click", function () {
                if (currentPage > 1) {
                    currentPage--;
                    render();
                }
            });

            nextButton.addEventListener("click", function () {
                currentPage++;
                render();
            });

            render();
        }());

        document.addEventListener("keydown", function (event) {
            if (event.key === "Escape") {
                showTasksList();
            }
        });

        try {
            if (sessionStorage.getItem("manageTasksReturnToForm") === "1") {
                sessionStorage.removeItem("manageTasksReturnToForm");
                showTaskForm();
            }
        } catch (error) { }
    </script>
</asp:Content>