<%@ Page Language="C#" MasterPageFile="~/Layout/Student.master" AutoEventWireup="true" CodeBehind="MyTasks.aspx.cs" Inherits="InternshipManagementSystem.Pages.StudentArea.MyTasks" Title="My Tasks" %>
<%-- ===================================================================
     My Tasks
     Owner : Fatima
     Cards : F03, F04
     Delete the placeholder below and build the page here.
     =================================================================== --%>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <style>
        .task-details-overlay {
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

        .task-details-dialog {
            width: 100%;
            max-width: 800px;
            max-height: calc(100vh - 32px);
            overflow-y: auto;
            background: var(--ui-surface,#fff);
            border-radius: 12px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.2);
        }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

    <%-- F03: Student tasks / F04: Submission form and attempt history --%>

    <div class="mb-4">
        <h2 class="mb-1"><%: L.T("Student.MyTasks.MyTasks") %></h2>
        <p class="text-muted mb-0">
            <%: L.T("Student.MyTasks.ViewYourAssignedTasksDeadlinesAnd") %>
        </p>
    </div>


   <!-- <div class="alert alert-info">
        Design preview: the task below is an example and is not loaded from the database.
    </div>
    -->
    <div class="uims-card">
        <h3 class="mb-3"><%: L.T("Student.MyTasks.AssignedTasks") %></h3>

        <div class="table-responsive">
            <table class="uims-table">
                <thead>
                    <tr>
                        <th><%: L.T("Student.MyTasks.Task") %></th>
                        <th><%: L.T("Student.MyTasks.Deadline") %></th>
                        <th><%: L.T("Student.MyTasks.Status") %></th>
                        <th><%: L.T("Student.MyTasks.Attempts") %></th>
                        <th><%: L.T("Student.MyTasks.Action") %></th>
                    </tr>
                </thead>
                <tbody>
   <asp:Repeater ID="rptTasks"
              runat="server"
              OnItemCommand="rptTasks_ItemCommand">

        <ItemTemplate>
            <tr>
                <td><strong><%#: Eval("Title") %></strong></td>
                <td>
                    <%# DateTimeOffset
                        .FromUnixTimeMilliseconds(Convert.ToInt64(Eval("Deadline")))
                        .UtcDateTime.ToString("yyyy-MM-dd HH:mm") %> <%: L.T("Student.MyTasks.UTC") %>
                </td>
                <td><%#: Eval("Status") %></td>
                <td>—</td>
                <td>
                   <asp:LinkButton ID="lnkViewDetails"
                runat="server"
                CssClass="btn btn-outline-secondary btn-sm"
                Text="<%$ Resources:Student, MyTasks.ViewDetails %>"
                CommandName="ViewDetails"
                CommandArgument='<%# Eval("Id") %>' />
                </td>
            </tr>
        </ItemTemplate>
    </asp:Repeater>
</tbody>
            </table>
        </div>
        <asp:Panel ID="pnlNoTasks"
           runat="server"
           CssClass="alert alert-info mt-3"
           Visible="false">
    <%: L.T("Student.MyTasks.NoTasksHaveBeenAssignedTo") %>
</asp:Panel>
    </div>

    <!-- Task details and submission popup -->
    <div id="taskDetailsModal" data-ui-dialog="" data-ui-close="closeTaskDetails"
         class="task-details-overlay"
         style="display: none;"
         role="dialog"
         aria-modal="true"
         aria-labelledby="taskDetailsTitle"
         aria-hidden="true">

        <div class="task-details-dialog uims-card">

            <div class="d-flex justify-content-between align-items-start gap-3 mb-4">
                <div>
                    <h3 id="taskDetailsTitle" class="mb-1"><%: L.T("Student.MyTasks.ExampleTask") %>
                        <asp:Literal ID="litTaskTitle" runat="server" Mode="Encode" />
                    </h3>
                    <p class="text-muted mb-0"><%: L.T("Student.MyTasks.TaskDetailsAndSubmission") %></p>
                </div>

                <button type="button"
                        class="btn btn-outline-secondary"
                        aria-label="<%: L.T("Student.MyTasks.Close") %>"
                        onclick="closeTaskDetails()">
                    &times;
                </button>
            </div>

            <div class="row mb-3">
                <div class="col-md-6 mb-2">
                    <strong><%: L.T("Student.MyTasks.Deadline") %></strong>
                    <asp:Literal ID="litDeadline" runat="server" Mode="Encode" />
                    <div class="text-muted"><%: L.T("Student.MyTasks.ToBeSetBySupervisor") %></div>
                </div>

                <div class="col-md-6 mb-2">
                    <strong><%: L.T("Student.MyTasks.Status") %></strong>
                    <asp:Literal ID="litStatus" runat="server" Mode="Encode" />
                    <div>
                        <span class="badge bg-secondary"><%: L.T("Student.MyTasks.NotSubmitted") %></span>
                    </div>
                </div>
            </div>

            <div class="mb-3">
                <h4 class="h6"><%: L.T("Student.MyTasks.Description") %>
                    <asp:Literal ID="litDescription" runat="server" Mode="Encode" />
                </h4>
                <p class="text-muted mb-0">
                    <%: L.T("Student.MyTasks.TheTaskDescriptionWillAppearHere") %>
                </p>
            </div>

            <div class="mb-3">
                <h4 class="h6"><%: L.T("Student.MyTasks.InstructionsAndRequirements") %>
                    <asp:Literal ID="litInstructions" runat="server" Mode="Encode" />
                </h4>
                <p class="text-muted mb-0">
                    <%: L.T("Student.MyTasks.TheSupervisorSInstructionsWillAppear") %>
                </p>
            </div>

            <div class="mb-3">
                <h4 class="h6"><%: L.T("Student.MyTasks.EvaluationCriteria") %></h4>
                <asp:Repeater ID="rptCriteria" runat="server">
    <ItemTemplate>
        <div class="text-muted mb-2">
            <strong><%#: Eval("Name") %></strong>
            — <%#: Eval("Description") %>
            <div class="small">
                <%#: Eval("MaxScore", "{0:0.##}") %> <%: L.T("Student.MyTasks.Points") %><%#: Eval("Weight", "{0:0}") %><%: L.T("Student.MyTasks.OfTheTask") %>
            </div>
        </div>
    </ItemTemplate>
</asp:Repeater>

<asp:Label ID="lblNoCriteria"
           runat="server"
           CssClass="text-muted"
           Text="<%$ Resources:Student, MyTasks.NoEvaluationCriteriaProvided %>"
           Visible="false" />
            </div>

            <hr class="my-4" />

            <h4 class="mb-2"><%: L.T("Student.MyTasks.SubmitYourWork") %></h4>
            <p class="text-muted">
                <%: L.T("Student.MyTasks.YouCanProvideTextALink") %>
            </p>

            <div class="mb-3">
                <asp:Label
                    ID="lblSubmissionText"
                    runat="server"
                    AssociatedControlID="txtSubmissionText"
                    CssClass="form-label"
                    Text="<%$ Resources:Student, MyTasks.SubmissionText %>" />

                <asp:TextBox
                    ID="txtSubmissionText"
                    runat="server"
                    CssClass="form-control"
                    TextMode="MultiLine"
                    Rows="4" />
            </div>

            <div class="mb-3">
                <asp:Label
                    ID="lblSubmissionLink"
                    runat="server"
                    AssociatedControlID="txtSubmissionLink"
                    CssClass="form-label"
                    Text="<%$ Resources:Student, MyTasks.SubmissionLink %>" />

                <asp:TextBox
                    ID="txtSubmissionLink"
                    runat="server"
                    CssClass="form-control"
                    TextMode="Url" />
            </div>

           <div class="alert alert-info">
    <%: L.T("Student.MyTasks.FileUploadsAreNotAvailableYet") %>
</div>

           <asp:Button ID="btnSubmitTask"
            runat="server"
            Text="<%$ Resources:Student, MyTasks.SubmitTask %>"
            CssClass="btn btn-brand"
            OnClick="btnSubmitTask_Click"  data-ui-action="submit" data-loading-label="Submitting…"/>

<asp:Label ID="lblSubmitMessage"
           runat="server"
           Visible="false"
           EnableViewState="false" />

            

            <hr class="my-4" />

            <h4 class="mb-3"><%: L.T("Student.MyTasks.SubmissionHistory") %></h4>

            <div class="table-responsive">
                <table class="uims-table">
                    <thead>
                        <tr>
                            <th><%: L.T("Student.MyTasks.Attempt") %></th>
                            <th><%: L.T("Student.MyTasks.SubmittedAt") %></th>
                            <th><%: L.T("Student.MyTasks.Status") %></th>
                            <th><%: L.T("Student.MyTasks.Feedback") %></th>
                        </tr>
                    </thead>
                   <tbody>
    <asp:Repeater ID="rptHistory" runat="server">
        <ItemTemplate>
            <tr>
                <td><%#: Eval("AttemptNumber") %></td>
                <td>
                    <%# DateTimeOffset
                        .FromUnixTimeMilliseconds(Convert.ToInt64(Eval("SubmittedAt")))
                        .UtcDateTime.ToString("yyyy-MM-dd HH:mm") %> <%: L.T("Student.MyTasks.UTC") %>
                </td>
                <td><%#: Eval("Status") %></td>
                <td>—</td>
            </tr>
        </ItemTemplate>
    </asp:Repeater>

    <asp:PlaceHolder ID="phNoAttempts"
                     runat="server"
                     Visible="false">
        <tr>
            <td colspan="4" class="text-center text-muted py-4">
                <%: L.T("Student.MyTasks.NoSubmissionAttemptsYet") %>
            </td>
        </tr>
    </asp:PlaceHolder>
</tbody>
                </table>
            </div>

            <div class="text-end mt-4">
                <button type="button"
                        class="btn btn-outline-secondary"
                        onclick="closeTaskDetails()">
                    <%: L.T("Student.MyTasks.Close") %>
                </button>
            </div>

        </div>
    </div>

    <script>
function showTaskDetails() {
    var modal = document.getElementById("taskDetailsModal");

    if (modal) {
        modal.style.display = "flex";
        modal.setAttribute("aria-hidden", "false");
        document.body.style.overflow = "hidden";
    }
}

function closeTaskDetails() {
    var modal = document.getElementById("taskDetailsModal");

    if (modal) {
        modal.style.display = "none";
        modal.setAttribute("aria-hidden", "true");
        document.body.style.overflow = "";
    }
}

function showSubmissionNotice() {
    var notice = document.getElementById("submissionNotice");

    if (notice) {
        notice.style.display = "block";
    }
}

document.addEventListener("keydown", function (event) {
    if (event.key === "Escape") {
        closeTaskDetails();
    }
});
</script>

</asp:Content>