<%@ Page Language="C#" MasterPageFile="~/Layout/Company.master" AutoEventWireup="true" CodeBehind="Tasks.aspx.cs" Inherits="InternshipManagementSystem.Pages.CompanyArea.Tasks" Title="Manage Tasks" %>
 
 <%-- 
     Manage Tasks
     Owner : Fatima
     Cards : F01, F02
     Delete the placeholder below and build the page here.
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
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

    <%-- F01: Create Task / F02: Display and Manage Tasks --%>

    <!-- Manage Tasks stays visible behind the popup -->
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

    <div class="uims-card">
        <h3 class="mb-3">Assigned Tasks</h3>

        <div class="table-responsive">
            <table class="uims-table">
                <thead>
                    <tr>
                        <th>Task</th>
                        <th>Trainee</th>
                        <th>Deadline</th>
                        <th>Max Score</th>
                        <th>Weight</th>
                        <th>Task Status</th>
                        <th>Submission Status</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
    <asp:Repeater ID="rptCompanyTasks" runat="server">
        <ItemTemplate>
            <tr>
                <td><%#: Eval("Title") %></td>
                <td><%#: Eval("Trainee") %></td>
                <td><%#: Eval("Deadline") %></td>
                <td><%#: Eval("MaxScore") %></td>
                <td><%#: Eval("Weight") %></td>
                <td><%#: Eval("TaskStatus") %></td>
                <td><%#: Eval("SubmissionStatus") %></td>
                <td>
                    <asp:HyperLink runat="server"
                        NavigateUrl="~/Pages/Company/TaskReview.aspx"
                        Text="View Submissions"
                        CssClass="btn btn-outline-secondary btn-sm" />
                </td>
            </tr>
        </ItemTemplate>
    </asp:Repeater>
</tbody>
            </table>
            <asp:Label ID="lblNoCompanyTasks" runat="server"
    Text="No tasks created yet."
    CssClass="text-muted" />
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
                        Enter the task details and evaluation criteria.
                    </p>
                </div>

                <button type="button"
                        class="btn btn-outline-secondary"
                        aria-label="Close"
                        onclick="showTasksList()">
                    &times;
                </button>
            </div>

            <div class="mb-3">
                <asp:Label
                    ID="lblTaskTitle"
                    runat="server"
                    AssociatedControlID="txtTitle"
                    CssClass="form-label"
                    Text="Task Title" />

                <asp:TextBox
                    ID="txtTitle"
                    runat="server"
                    CssClass="form-control" />
            </div>

            <div class="mb-3">
                <asp:Label
                    ID="lblDescription"
                    runat="server"
                    AssociatedControlID="txtDescription"
                    CssClass="form-label"
                    Text="Description" />

                <asp:TextBox
                    ID="txtDescription"
                    runat="server"
                    CssClass="form-control"
                    TextMode="MultiLine"
                    Rows="3" />
            </div>

            <div class="mb-3">
                <asp:Label
                    ID="lblInstructions"
                    runat="server"
                    AssociatedControlID="txtInstructions"
                    CssClass="form-label"
                    Text="Instructions" />

                <asp:TextBox
                    ID="txtInstructions"
                    runat="server"
                    CssClass="form-control"
                    TextMode="MultiLine"
                    Rows="3" />
            </div>

            <div class="row">
                <div class="col-md-6 mb-3">
                    <asp:Label
                        ID="lblDeadline"
                        runat="server"
                        AssociatedControlID="txtDeadline"
                        CssClass="form-label"
                        Text="Deadline" />

                    <asp:TextBox
                        ID="txtDeadline"
                        runat="server"
                        CssClass="form-control"
                        TextMode="DateTimeLocal" />
                </div>

                <div class="col-md-6 mb-3">
                    <asp:Label
                        ID="lblTrainee"
                        runat="server"
                        AssociatedControlID="ddlTrainee"
                        CssClass="form-label"
                        Text="Assigned Trainee" />

                    <asp:DropDownList
                        ID="ddlTrainee"
                        runat="server"
                        CssClass="form-select">
                        <asp:ListItem Text="Select a trainee" Value="" />
                    </asp:DropDownList>
                </div>
            </div>

            <div class="row">
                <div class="col-md-6 mb-3">
                    <asp:Label
                        ID="lblMaxScore"
                        runat="server"
                        AssociatedControlID="txtMaxScore"
                        CssClass="form-label"
                        Text="Maximum Score" />

                    <asp:TextBox
                        ID="txtMaxScore"
                        runat="server"
                        CssClass="form-control"
                        TextMode="Number"
                        min="0.01"
                        step="0.01" />
                </div>

                <div class="col-md-6 mb-3">
                    <asp:Label
                        ID="lblWeight"
                        runat="server"
                        AssociatedControlID="txtWeight"
                        CssClass="form-label"
                        Text="Task Weight" />

                    <asp:TextBox
                        ID="txtWeight"
                        runat="server"
                        CssClass="form-control"
                        TextMode="Number"
                        min="0.01"
                        step="0.01" />
                </div>
            </div>

            <hr class="my-4" />

            <h4 class="mb-3">Evaluation Criteria</h4>

            <div class="row">
                <div class="col-md-6 mb-3">
                    <asp:Label
                        ID="lblCriterionName"
                        runat="server"
                        AssociatedControlID="txtCriterionName"
                        CssClass="form-label"
                        Text="Criterion Name" />

                    <asp:TextBox
                        ID="txtCriterionName"
                        runat="server"
                        CssClass="form-control" />
                </div>

                <div class="col-md-6 mb-3">
                    <asp:Label
                        ID="lblCriterionMaxScore"
                        runat="server"
                        AssociatedControlID="txtCriterionMaxScore"
                        CssClass="form-label"
                        Text="Criterion Maximum Score" />

                    <asp:TextBox
                        ID="txtCriterionMaxScore"
                        runat="server"
                        CssClass="form-control"
                        TextMode="Number"
                        min="0.01"
                        step="0.01" />
                </div>
            </div>

            <div class="mb-3">
                <asp:Label
                    ID="lblCriterionDescription"
                    runat="server"
                    AssociatedControlID="txtCriterionDescription"
                    CssClass="form-label"
                    Text="Criterion Description" />

                <asp:TextBox
                    ID="txtCriterionDescription"
                    runat="server"
                    CssClass="form-control"
                    TextMode="MultiLine"
                    Rows="2" />
            </div>

            <div class="mb-3">
                <asp:Label
                    ID="lblCriterionWeight"
                    runat="server"
                    AssociatedControlID="txtCriterionWeight"
                    CssClass="form-label"
                    Text="Criterion Weight (%)" />

                <asp:TextBox
                    ID="txtCriterionWeight"
                    runat="server"
                    CssClass="form-control"
                    TextMode="Number"
                    min="0.01"
                    max="100"
                    step="0.01" />
            </div>

            <asp:Button
                ID="btnAddCriterion"
                runat="server"
                Text="Add Criterion"
                CssClass="btn btn-outline-secondary mb-3"
                CausesValidation="false"
                OnClientClick="rememberTaskForm();"
                OnClick="btnAddCriterion_Click" />

            <div class="table-responsive">
                <asp:GridView
                    ID="gvCriteria"
                    runat="server"
                    AutoGenerateColumns="false"
                    CssClass="uims-table"
                    GridLines="None"
                    EmptyDataText="No criteria added yet."
                    ShowHeaderWhenEmpty="true">

                    <Columns>
                        <asp:BoundField
                            DataField="Name"
                            HeaderText="Criterion"
                            HtmlEncode="true" />

                        <asp:BoundField
                            DataField="Description"
                            HeaderText="Description"
                            HtmlEncode="true" />

                        <asp:BoundField
                            DataField="MaxScore"
                            HeaderText="Maximum Score" />

                        <asp:BoundField
                            DataField="Weight"
                            HeaderText="Weight (%)" />
                    </Columns>
                </asp:GridView>
            </div>

            <div class="d-flex justify-content-end gap-2 mt-4">
                <button type="button"
                        class="btn btn-outline-secondary"
                        onclick="showTasksList()">
                    Cancel
                </button>

                <asp:Button
                    ID="btnCreateTask"
                    runat="server"
                    Text="Create Task"
                    CssClass="btn btn-brand"
                    OnClientClick="rememberTaskForm();"
                    OnClick="btnCreateTask_Click" />
            </div>

            <div class="mt-3">
                <asp:Label
                    ID="lblMessage"
                    runat="server"
                    EnableViewState="false" />
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
