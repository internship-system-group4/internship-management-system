<%@ Page Language="C#" MasterPageFile="~/Layout/Company.master" AutoEventWireup="true" CodeBehind="TaskReview.aspx.cs" Inherits="InternshipManagementSystem.Pages.CompanyArea.TaskReview" Title="Review Submissions" %>
 <%-- ===================================================================
      Review Submissions
      Owner : Fatima
      Cards : F05, F06, F07
      Delete the placeholder below and build the page here.
      =================================================================== --%>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <style>
        .review-overlay {
            display: none;
            position: fixed;
            inset: 0;
            z-index: 2000;
            background: rgba(20, 30, 45, .45);
            backdrop-filter: blur(4px);
            padding: 24px;
            overflow-y: auto;
        }

        .review-dialog {
            max-width: 850px;
            margin: 30px auto;
            padding: 28px;
            background: #fff;
            border-radius: 16px;
        }

        .review-choice {
            border: 1px solid #dee2e6;
            border-radius: 12px;
            padding: 20px;
            height: 100%;
        }

        .review-choice h4 {
            margin-bottom: 8px;
        }

        .review-section {
            display: none;
        }

        .review-history {
            margin-top: 28px;
            border-top: 1px solid #dee2e6;
            padding-top: 22px;
        }

        .review-history details {
            padding: 12px 0;
            border-bottom: 1px solid #eee;
        }

        .review-history summary {
            cursor: pointer;
            font-weight: 600;
        }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

    <div class="uims-card">
        <h2>Review Submissions</h2>
        <p class="text-muted">
            Open a submission to evaluate it or request a new attempt.
        </p>

        <%-- Example data for the frontend preview. Later: load company submissions from Firebase. --%>
        <div class="table-responsive">
            <table class="uims-table">
                <thead>
                    <tr>
                        <th>Task</th>
                        <th>Trainee</th>
                        <th>Attempt</th>
                        <th>Status</th>
                        <th>Submitted</th>
                        <th></th>
                    </tr>
                </thead>
                <asp:Repeater ID="rptSubmissions" runat="server">
    <ItemTemplate>
        <tr>
            <td><%#: Eval("TaskId") %></td>
            <td><%#: Eval("StudentId") %></td>
            <td><%#: Eval("AttemptNumber") %></td>
            <td><%#: Eval("Status") %></td>
            <td><%#: Eval("SubmittedAt") %></td>
            <td>—</td>
        </tr>
    </ItemTemplate>
</asp:Repeater>
            </table>
        </div>
    </div>

    <div id="reviewOverlay" class="review-overlay" role="dialog"
        aria-modal="true" aria-labelledby="reviewTitle">
        <div class="review-dialog">

            <div class="d-flex justify-content-between align-items-start mb-3">
                <div>
                    <h2 id="reviewTitle">Weekly Progress Report</h2>
                    <p class="text-muted mb-0">
                        Example Student · Attempt 2 · Pending Review
                    </p>
                </div>
                <button type="button" class="btn btn-outline-secondary"
                    onclick="closeReview()" aria-label="Close review">
                    Close
                </button>
            </div>

            <hr />

            <h4>Submitted Work</h4>
            <p><strong>Student's text:</strong></p>
            <p class="text-muted">
                Example submission text will appear here.
            </p>
            <p>
                <strong>Link:</strong>
                <span class="text-muted">No link in this example</span>
            </p>
            <p>
                <strong>File:</strong>
                <span class="text-muted">No file in this example</span>
            </p>

            <hr />

            <%-- The supervisor chooses one action. --%>
            <div id="reviewChoices">
                <h4>What would you like to do?</h4>

                <div class="row g-3 mt-1">
                    <div class="col-md-6">
                        <div class="review-choice">
                            <h4>Evaluate Submission</h4>
                            <p class="text-muted">
                                Enter scores for the task criteria and leave feedback.
                            </p>
                            <button type="button" class="btn btn-brand"
                                onclick="showReviewSection('grade')">
                                Start Evaluation
                            </button>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="review-choice">
                            <h4>Request Revision</h4>
                            <p class="text-muted">
                                Explain what the student needs to change before submitting again.
                            </p>
                            <button type="button" class="btn btn-outline-secondary"
                                onclick="showReviewSection('revision')">
                                Request Revision
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <%-- F05: grading fields --%>
            <div id="gradeSection" class="review-section">
                <button type="button" class="btn btn-link px-0"
                    onclick="showReviewChoices()">
                    ← Back to choices
                </button>

                <h4>Evaluate Submission</h4>
                <p class="text-muted">
                    The criteria and maximum scores will come from this task.
                </p>

                <div class="table-responsive">
                    <table class="uims-table">
                        <thead>
                            <tr>
                                <th>Criterion</th>
                                <th>Maximum Score</th>
                                <th>Score</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>Report Quality (example)</td>
                                <td>20</td>
                                <td>
                                    <asp:TextBox ID="txtCriterionScore" runat="server"
                                        CssClass="form-control" TextMode="Number" />
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <div class="mb-3 mt-3">
                    <asp:Label ID="lblFeedback" runat="server"
                        AssociatedControlID="txtFeedback"
                        CssClass="form-label" Text="Feedback" />
                    <asp:TextBox ID="txtFeedback" runat="server"
                        CssClass="form-control" TextMode="MultiLine" Rows="4" />
                </div>

                <asp:Button ID="btnSaveEvaluation" runat="server"
                    Text="Save Evaluation" CssClass="btn btn-brand"
                    OnClientClick="showReviewNotice(); return false;" />
            </div>

            <%-- F06: revision fields --%>
            <div id="revisionSection" class="review-section">
                <button type="button" class="btn btn-link px-0"
                    onclick="showReviewChoices()">
                    ← Back to choices
                </button>

                <h4>Request Revision</h4>
                <p class="text-muted">
                    Tell the student exactly what to improve in the next attempt.
                </p>

                <div class="mb-3">
                    <asp:Label ID="lblRevisionInstructions" runat="server"
                        AssociatedControlID="txtRevisionInstructions"
                        CssClass="form-label" Text="Revision Instructions" />
                    <asp:TextBox ID="txtRevisionInstructions" runat="server"
                        CssClass="form-control" TextMode="MultiLine" Rows="5" />
                </div>

                <asp:Button ID="btnRequestRevision" runat="server"
                    Text="Send Revision Request"
                    CssClass="btn btn-brand"
                    OnClientClick="showReviewNotice(); return false;" />
            </div>

            <div id="reviewNotice" class="alert alert-info mt-3"
                style="display: none;" role="status">
                This is a design preview. Nothing was saved yet.
            </div>

            <%-- F07: all previous attempts remain readable. --%>
            <div class="review-history">
                <h4>Submission History</h4>
                <p class="text-muted">
                    Previous attempts will stay here even after a revision.
                </p>

                <details>
                    <summary>Attempt 2 · Pending Review</summary>
                    <p class="mt-2 mb-0">
                        Example text for the student's second attempt.
                    </p>
                </details>

                <details>
                    <summary>Attempt 1 · Revision Requested</summary>
                    <p class="mt-2">
                        Example text for the student's first attempt.
                    </p>
                    <p class="mb-0">
                        <strong>Revision instructions:</strong>
                        Please add more detail to the report.
                    </p>
                </details>
            </div>
        </div>
    </div>

    <script>
        function openReview() {
            document.getElementById("reviewOverlay").style.display = "block";
            document.body.style.overflow = "hidden";
            showReviewChoices();
        }

        function closeReview() {
            document.getElementById("reviewOverlay").style.display = "none";
            document.body.style.overflow = "";
        }

        function showReviewChoices() {
            document.getElementById("reviewChoices").style.display = "block";
            document.getElementById("gradeSection").style.display = "none";
            document.getElementById("revisionSection").style.display = "none";
            document.getElementById("reviewNotice").style.display = "none";
        }

        function showReviewSection(section) {
            document.getElementById("reviewChoices").style.display = "none";
            document.getElementById("gradeSection").style.display =
                section === "grade" ? "block" : "none";
            document.getElementById("revisionSection").style.display =
                section === "revision" ? "block" : "none";
            document.getElementById("reviewNotice").style.display = "none";
        }

        function showReviewNotice() {
            document.getElementById("reviewNotice").style.display = "block";
        }

        document.addEventListener("keydown", function (event) {
            if (event.key === "Escape") closeReview();
        });
    </script>

</asp:Content>