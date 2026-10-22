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
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.2);
        }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

    <%-- F03: Student tasks / F04: Submission form and attempt history --%>

    <div class="mb-4">
        <h2 class="mb-1">My Tasks</h2>
        <p class="text-muted mb-0">
            View your assigned tasks, deadlines, and submission status.
        </p>
    </div>


   <!-- <div class="alert alert-info">
        Design preview: the task below is an example and is not loaded from the database.
    </div>
    -->
    <div class="uims-card">
        <h3 class="mb-3">Assigned Tasks</h3>

        <div class="table-responsive">
            <table class="uims-table">
                <thead>
                    <tr>
                        <th>Task</th>
                        <th>Deadline</th>
                        <th>Status</th>
                        <th>Attempts</th>
                        <th>Action</th>
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
                        .UtcDateTime.ToString("yyyy-MM-dd HH:mm") %> UTC
                </td>
                <td><%#: Eval("Status") %></td>
                <td>—</td>
                <td>
                   <asp:LinkButton ID="lnkViewDetails"
                runat="server"
                CssClass="btn btn-outline-secondary btn-sm"
                Text="View Details"
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
    No tasks have been assigned to you yet.
</asp:Panel>
    </div>

    <!-- Task details and submission popup -->
    <div id="taskDetailsModal"
         class="task-details-overlay"
         style="display: none;"
         role="dialog"
         aria-modal="true"
         aria-labelledby="taskDetailsTitle"
         aria-hidden="true">

        <div class="task-details-dialog uims-card">

            <div class="d-flex justify-content-between align-items-start gap-3 mb-4">
                <div>
                    <h3 id="taskDetailsTitle" class="mb-1">Example Task
                        <asp:Literal ID="litTaskTitle" runat="server" Mode="Encode" />
                    </h3>
                    <p class="text-muted mb-0">Task details and submission</p>
                </div>

                <button type="button"
                        class="btn btn-outline-secondary"
                        aria-label="Close"
                        onclick="closeTaskDetails()">
                    &times;
                </button>
            </div>

            <div class="row mb-3">
                <div class="col-md-6 mb-2">
                    <strong>Deadline</strong>
                    <asp:Literal ID="litDeadline" runat="server" Mode="Encode" />
                    <div class="text-muted">To be set by supervisor</div>
                </div>

                <div class="col-md-6 mb-2">
                    <strong>Status</strong>
                    <asp:Literal ID="litStatus" runat="server" Mode="Encode" />
                    <div>
                        <span class="badge bg-secondary">Not submitted</span>
                    </div>
                </div>
            </div>

            <div class="mb-3">
                <h4 class="h6">Description
                    <asp:Literal ID="litDescription" runat="server" Mode="Encode" />
                </h4>
                <p class="text-muted mb-0">
                    The task description will appear here.
                </p>
            </div>

            <div class="mb-3">
                <h4 class="h6">Instructions and Requirements
                    <asp:Literal ID="litInstructions" runat="server" Mode="Encode" />
                </h4>
                <p class="text-muted mb-0">
                    The supervisor's instructions will appear here.
                </p>
            </div>

            <div class="mb-3">
                <h4 class="h6">Evaluation Criteria</h4>
                <asp:Repeater ID="rptCriteria" runat="server">
    <ItemTemplate>
        <div class="text-muted mb-2">
            <strong><%#: Eval("Name") %></strong>
            — <%#: Eval("Description") %>
            <div class="small">
                Maximum score: <%#: Eval("MaxScore") %>
                | Weight: <%#: Eval("Weight") %>%
            </div>
        </div>
    </ItemTemplate>
</asp:Repeater>

<asp:Label ID="lblNoCriteria"
           runat="server"
           CssClass="text-muted"
           Text="No evaluation criteria provided."
           Visible="false" />
            </div>

            <hr class="my-4" />

            <h4 class="mb-2">Submit Your Work</h4>
            <p class="text-muted">
                You can provide text, a link, or a file. Each new submission
                will be kept as a separate attempt.
            </p>

            <div class="mb-3">
                <asp:Label
                    ID="lblSubmissionText"
                    runat="server"
                    AssociatedControlID="txtSubmissionText"
                    CssClass="form-label"
                    Text="Submission Text" />

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
                    Text="Submission Link" />

                <asp:TextBox
                    ID="txtSubmissionLink"
                    runat="server"
                    CssClass="form-control"
                    TextMode="Url" />
            </div>

           <div class="alert alert-info">
    File uploads are not available yet. Submit text or a shareable link.
</div>

           <asp:Button ID="btnSubmitTask"
            runat="server"
            Text="Submit Task"
            CssClass="btn btn-brand"
            OnClick="btnSubmitTask_Click" />

<asp:Label ID="lblSubmitMessage"
           runat="server"
           Visible="false"
           EnableViewState="false" />

            

            <hr class="my-4" />

            <h4 class="mb-3">Submission History</h4>

            <div class="table-responsive">
                <table class="uims-table">
                    <thead>
                        <tr>
                            <th>Attempt</th>
                            <th>Submitted At</th>
                            <th>Status</th>
                            <th>Feedback</th>
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
                        .UtcDateTime.ToString("yyyy-MM-dd HH:mm") %> UTC
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
                No submission attempts yet.
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
                    Close
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