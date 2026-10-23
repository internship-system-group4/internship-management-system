<%@ Page Language="C#" MasterPageFile="~/Layout/Company.master" AutoEventWireup="true" CodeBehind="Tasks.aspx.cs" Inherits="InternshipManagementSystem.Pages.CompanyArea.Tasks" Title="Manage Tasks" %>

<%-- ===================================================================
     Manage Tasks
     Owner : Fatima
     Cards : F01, F02
     Grading is set with one number per criterion ("points"). The task's
     total points and each criterion's share are worked out for you.
     =================================================================== --%>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <style>
        .task-modal-overlay {
            position: fixed;
            inset: 0;
            z-index: 2000;
            align-items: center;
            justify-content: center;
            padding: 16px;
            background: rgba(17, 24, 39, 0.45);
            -webkit-backdrop-filter: blur(5px);
            backdrop-filter: blur(5px);
        }

        .task-modal-dialog {
            width: 100%;
            max-width: 820px;
            max-height: calc(100vh - 32px);
            overflow-y: auto;
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.2);
        }

        .task-step {
            display: flex;
            align-items: center;
            gap: 10px;
            margin: 0 0 6px;
            font-size: 1.1rem;
        }

        .task-step-number {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 26px;
            height: 26px;
            border-radius: 50%;
            background: #1f3a5f;
            color: #fff;
            font-size: 0.85rem;
            font-weight: 600;
        }

        .criteria-add {
            padding: 16px;
            border: 1px dashed #c8cfd8;
            border-radius: 10px;
            background: #f8fafc;
        }

        .criteria-total {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 8px;
            padding: 10px 14px;
            border-radius: 8px;
            background: #eef3f8;
            font-weight: 600;
        }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

    <%-- F01: Create Task / F02: Display and Manage Tasks --%>

    <div class="d-flex justify-content-between align-items-center flex-wrap gap-3 mb-4">
        <div>
            <h2 class="mb-1">Manage Tasks</h2>
            <p class="text-muted mb-0">
                View and manage tasks assigned to your trainees.
            </p>
        </div>

        <button type="button"
                id="btnOpenCreateTask"
                class="btn btn-brand"
                onclick="showTaskForm()">
            + Create New Task
        </button>
    </div>

    <asp:Label ID="lblPageMessage" runat="server" EnableViewState="false" Visible="false" />

    <div class="uims-card">
        <h3 class="mb-3">Assigned Tasks</h3>

        <div class="table-responsive">
            <asp:GridView
                ID="gvTasks"
                runat="server"
                AutoGenerateColumns="false"
                CssClass="uims-table"
                GridLines="None"
                ShowHeaderWhenEmpty="true"
                EmptyDataText="No tasks created yet.">
                <Columns>
                    <asp:BoundField DataField="Title" HeaderText="Task" HtmlEncode="true" />
                    <asp:BoundField DataField="Trainee" HeaderText="Trainee" HtmlEncode="true" />
                    <asp:BoundField DataField="Deadline" HeaderText="Deadline" />
                    <asp:BoundField DataField="Points" HeaderText="Total Points" />
                    <asp:BoundField DataField="Counts" HeaderText="Counts As" />
                    <asp:BoundField DataField="Status" HeaderText="Status" />
                </Columns>
            </asp:GridView>
        </div>
    </div>

    <!-- Popup with blurred background -->
    <div id="taskModal"
         class="task-modal-overlay"
         style="display: none;"
         role="dialog"
         aria-modal="true"
         aria-labelledby="taskModalTitle"
         aria-hidden="true">

        <div class="task-modal-dialog uims-card">

            <div class="d-flex justify-content-between align-items-start gap-3 mb-4">
                <div>
                    <h3 id="taskModalTitle" class="mb-1">Create Task</h3>
                    <p class="text-muted mb-0">
                        Two steps: describe the task, then list what you will grade.
                    </p>
                </div>

                <button type="button"
                        class="btn btn-outline-secondary"
                        aria-label="Close"
                        onclick="showTasksList()">
                    &times;
                </button>
            </div>

            <%-- ========== Step 1: task details ========== --%>
            <h4 class="task-step"><span class="task-step-number">1</span> Task details</h4>
            <p class="text-muted small mb-3">Fields marked * are required.</p>

            <div class="mb-3">
                <asp:Label ID="lblTaskTitle" runat="server" AssociatedControlID="txtTitle"
                    CssClass="form-label" Text="Task Title *" />
                <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" MaxLength="150"
                    placeholder="e.g. Build the login page" />
            </div>

            <div class="mb-3">
                <asp:Label ID="lblDescription" runat="server" AssociatedControlID="txtDescription"
                    CssClass="form-label" Text="Description" />
                <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control"
                    TextMode="MultiLine" Rows="2"
                    placeholder="What is the task about?" />
            </div>

            <div class="mb-3">
                <asp:Label ID="lblInstructions" runat="server" AssociatedControlID="txtInstructions"
                    CssClass="form-label" Text="Instructions" />
                <asp:TextBox ID="txtInstructions" runat="server" CssClass="form-control"
                    TextMode="MultiLine" Rows="3"
                    placeholder="Steps, links and what the trainee should hand in." />
            </div>

            <div class="row">
                <div class="col-md-6 mb-3">
                    <asp:Label ID="lblTrainee" runat="server" AssociatedControlID="ddlTrainee"
                        CssClass="form-label" Text="Assigned Trainee *" />
                    <asp:DropDownList ID="ddlTrainee" runat="server" CssClass="form-select" />
                </div>

                <div class="col-md-6 mb-3">
                    <asp:Label ID="lblDeadline" runat="server" AssociatedControlID="txtDeadline"
                        CssClass="form-label" Text="Deadline *" />
                    <asp:TextBox ID="txtDeadline" runat="server" CssClass="form-control"
                        TextMode="DateTimeLocal" />
                </div>
            </div>

            <div class="mb-3">
                <asp:Label ID="lblWeight" runat="server" AssociatedControlID="ddlWeight"
                    CssClass="form-label" Text="How much does this task count?" />
                <asp:DropDownList ID="ddlWeight" runat="server" CssClass="form-select">
                    <asp:ListItem Text="Normal - counts once" Value="1" Selected="True" />
                    <asp:ListItem Text="Important - counts twice" Value="2" />
                    <asp:ListItem Text="Major - counts three times" Value="3" />
                </asp:DropDownList>
                <div class="form-text">
                    Compared with this trainee's other tasks. Choose Normal for most tasks.
                </div>
            </div>

            <hr class="my-4" />

            <%-- ========== Step 2: grading ========== --%>
            <h4 class="task-step"><span class="task-step-number">2</span> How will you grade it?</h4>
            <p class="text-muted small mb-3">
                Add each thing you will check and how many points it is worth.
                The task total is the sum of the points.
            </p>

            <div class="criteria-add mb-3">
                <div class="row g-2 align-items-end">
                    <div class="col-md-6">
                        <asp:Label ID="lblCriterionName" runat="server" AssociatedControlID="txtCriterionName"
                            CssClass="form-label" Text="What will you check?" />
                        <asp:TextBox ID="txtCriterionName" runat="server" CssClass="form-control"
                            MaxLength="100" placeholder="e.g. Code quality" />
                    </div>

                    <div class="col-6 col-md-3">
                        <asp:Label ID="lblCriterionPoints" runat="server" AssociatedControlID="txtCriterionPoints"
                            CssClass="form-label" Text="Points" />
                        <asp:TextBox ID="txtCriterionPoints" runat="server" CssClass="form-control"
                            TextMode="Number" min="1" max="100" step="1" placeholder="e.g. 10" />
                    </div>

                    <div class="col-6 col-md-3">
                        <asp:Button ID="btnAddCriterion" runat="server" Text="+ Add"
                            CssClass="btn btn-outline-secondary w-100"
                            CausesValidation="false"
                            OnClientClick="rememberTaskForm();"
                            OnClick="btnAddCriterion_Click" />
                    </div>
                </div>

                <div class="mt-2">
                    <asp:Label ID="lblCriterionDescription" runat="server" AssociatedControlID="txtCriterionDescription"
                        CssClass="form-label small text-muted mb-1" Text="Short note for the trainee (optional)" />
                    <asp:TextBox ID="txtCriterionDescription" runat="server" CssClass="form-control form-control-sm"
                        MaxLength="250" placeholder="e.g. Clean, readable and commented code" />
                </div>
            </div>

            <asp:Panel ID="pnlStarter" runat="server" CssClass="mb-3">
                <span class="text-muted small">Not sure where to start?</span>
                <asp:LinkButton ID="btnUseStarter" runat="server" CssClass="small ms-1"
                    CausesValidation="false"
                    OnClientClick="rememberTaskForm();"
                    OnClick="btnUseStarter_Click"
                    Text="Use a simple starter set (Quality 10, Completeness 5, On time 5)" />
            </asp:Panel>

            <div class="table-responsive">
                <asp:GridView
                    ID="gvCriteria"
                    runat="server"
                    AutoGenerateColumns="false"
                    CssClass="uims-table"
                    GridLines="None"
                    EmptyDataText="No criteria yet. Add at least one above."
                    ShowHeaderWhenEmpty="true"
                    OnRowCommand="gvCriteria_RowCommand">
                    <Columns>
                        <asp:BoundField DataField="Name" HeaderText="Criterion" HtmlEncode="true" />
                        <asp:BoundField DataField="Description" HeaderText="Note" HtmlEncode="true" />
                        <asp:BoundField DataField="MaxScore" HeaderText="Points" DataFormatString="{0:0}" />
                        <asp:BoundField DataField="Weight" HeaderText="Share of Task" DataFormatString="{0:0}%" />
                        <asp:TemplateField HeaderText="">
                            <ItemTemplate>
                                <asp:LinkButton runat="server"
                                    CommandName="RemoveCriterion"
                                    CommandArgument="<%# Container.DataItemIndex %>"
                                    CausesValidation="false"
                                    OnClientClick="rememberTaskForm();"
                                    CssClass="text-danger small"
                                    Text="Remove" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>

            <div class="criteria-total">
                <span>Task total</span>
                <asp:Label ID="lblTotalPoints" runat="server" Text="0 points" />
            </div>

            <div class="mt-3">
                <asp:Label ID="lblMessage" runat="server" EnableViewState="false" />
            </div>

            <div class="d-flex justify-content-end gap-2 mt-4">
                <button type="button"
                        class="btn btn-outline-secondary"
                        onclick="showTasksList()">
                    Cancel
                </button>

                <asp:Button ID="btnCreateTask" runat="server" Text="Create Task"
                    CssClass="btn btn-brand"
                    OnClientClick="rememberTaskForm();"
                    OnClick="btnCreateTask_Click" />
            </div>

        </div>
    </div>

    <script>
        function showTaskForm() {
            var modal = document.getElementById("taskModal");

            if (modal) {
                modal.style.display = "flex";
                modal.setAttribute("aria-hidden", "false");
                document.body.style.overflow = "hidden";
            }
        }

        function showTasksList() {
            var modal = document.getElementById("taskModal");

            if (modal) {
                modal.style.display = "none";
                modal.setAttribute("aria-hidden", "true");
                document.body.style.overflow = "";
            }

            sessionStorage.removeItem("manageTasksReturnToForm");
        }

        function rememberTaskForm() {
            // Keep the popup open after an ASP.NET postback.
            sessionStorage.setItem("manageTasksReturnToForm", "1");
        }

        if (sessionStorage.getItem("manageTasksReturnToForm") === "1") {
            sessionStorage.removeItem("manageTasksReturnToForm");
            showTaskForm();
        }
    </script>

</asp:Content>
