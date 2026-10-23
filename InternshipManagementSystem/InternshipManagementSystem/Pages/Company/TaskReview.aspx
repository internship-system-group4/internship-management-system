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
            background: var(--ui-surface,#fff);
            border-radius: 16px;
        }

        .review-choice {
            border: 1px solid var(--th-line-dee2e6,#dee2e6);
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
            border-top: 1px solid var(--th-line-dee2e6,#dee2e6);
            padding-top: 22px;
        }

        .review-history details {
            padding: 12px 0;
            border-bottom: 1px solid var(--th-line-eeeeee,#eee);
        }

        .review-history summary {
            cursor: pointer;
            font-weight: 600;
        }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

    <div class="uims-card">
        <h2><%: L.T("Company.TaskReview.ReviewSubmissions") %></h2>
        <p class="text-muted">
            <%: L.T("Company.TaskReview.OpenASubmissionToEvaluateIt") %>
        </p>

        <%-- Example data for the frontend preview. Later: load company submissions from Firebase. --%>
        <div class="table-responsive">
            <table class="uims-table">
                <thead>
                    <tr>
                        <th><%: L.T("Company.TaskReview.Task") %></th>
                        <th><%: L.T("Company.TaskReview.Trainee") %></th>
                        <th><%: L.T("Company.TaskReview.Attempt") %></th>
                        <th><%: L.T("Company.TaskReview.Status") %></th>
                        <th><%: L.T("Company.TaskReview.Submitted") %></th>
                        <th></th>
                    </tr>
                </thead>
              <asp:Repeater ID="rptSubmissions" runat="server"
    OnItemCommand="rptSubmissions_ItemCommand">
    <ItemTemplate>
       <td>
    <asp:LinkButton ID="btnViewDetails" runat="server"
        Text="<%$ Resources:Company, TaskReview.ViewDetails %>"
        CssClass="btn btn-outline-primary btn-sm"
        CommandName="ViewDetails"
        CommandArgument='<%# Eval("Id") %>' />
</td>
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
                    <h2 id="reviewTitle"><%: L.T("Company.TaskReview.WeeklyProgressReport") %></h2>
                    <p class="text-muted mb-0">
                        <%: L.T("Company.TaskReview.ExampleStudentAttempt2PendingReview") %>
                    </p>
                </div>
                <button type="button" class="btn btn-outline-secondary"
                    onclick="closeReview()" aria-label="<%: L.T("Company.TaskReview.CloseReview") %>">
                    <%: L.T("Company.TaskReview.Close") %>
                </button>
            </div>

            <hr />

            <h4><%: L.T("Company.TaskReview.SubmittedWork") %></h4>
            <p><strong><%: L.T("Company.TaskReview.StudentSText") %></strong></p>
            <p class="text-muted">
                <%: L.T("Company.TaskReview.ExampleSubmissionTextWillAppearHere") %>
            </p>
            <p>
                <strong><%: L.T("Company.TaskReview.Link") %></strong>
                <span class="text-muted"><%: L.T("Company.TaskReview.NoLinkInThisExample") %></span>
            </p>
            <p>
                <strong><%: L.T("Company.TaskReview.File") %></strong>
                <span class="text-muted"><%: L.T("Company.TaskReview.NoFileInThisExample") %></span>
            </p>

            <hr />

            <%-- The supervisor chooses one action. --%>
            <div id="reviewChoices">
                <h4><%: L.T("Company.TaskReview.WhatWouldYouLikeToDo") %></h4>

                <div class="row g-3 mt-1">
                    <div class="col-md-6">
                        <div class="review-choice">
                            <h4><%: L.T("Company.TaskReview.EvaluateSubmission") %></h4>
                            <p class="text-muted">
                                <%: L.T("Company.TaskReview.EnterScoresForTheTaskCriteria") %>
                            </p>
                            <button type="button" class="btn btn-brand"
                                onclick="showReviewSection('grade')">
                                <%: L.T("Company.TaskReview.StartEvaluation") %>
                            </button>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="review-choice">
                            <h4><%: L.T("Company.TaskReview.RequestRevision") %></h4>
                            <p class="text-muted">
                                <%: L.T("Company.TaskReview.ExplainWhatTheStudentNeedsTo") %>
                            </p>
                            <button type="button" class="btn btn-outline-secondary"
                                onclick="showReviewSection('revision')">
                                <%: L.T("Company.TaskReview.RequestRevision") %>
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <%-- F05: grading fields --%>
            <div id="gradeSection" class="review-section">
                <button type="button" class="btn btn-link px-0"
                    onclick="showReviewChoices()">
                    <%: L.T("Company.TaskReview.BackToChoices") %>
                </button>

                <h4><%: L.T("Company.TaskReview.EvaluateSubmission") %></h4>
                <p class="text-muted">
                    <%: L.T("Company.TaskReview.TheCriteriaAndMaximumScoresWill") %>
                </p>

                <div class="table-responsive">
                    <table class="uims-table">
                        <thead>
                            <tr>
                                <th><%: L.T("Company.TaskReview.Criterion") %></th>
                                <th><%: L.T("Company.TaskReview.MaximumScore") %></th>
                                <th><%: L.T("Company.TaskReview.Score") %></th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td><%: L.T("Company.TaskReview.ReportQualityExample") %></td>
                                <td>20</td>
                                <td>
                                    <asp:TextBox ID="txtCriterionScore" runat="server"
                                        CssClass="form-control" TextMode="Number" />
                                </td>
                            </tr>
                        </tbody>
                    </table>
                   <asp:Panel ID="pnlSubmissionDetails" runat="server"
    Visible="false" CssClass="uims-card mt-4">

    <h3><%: L.T("Company.TaskReview.SubmissionDetails") %></h3>

    <p><strong><%: L.T("Company.TaskReview.Task2") %></strong>
        <asp:Label ID="lblDetailTask" runat="server" /></p>

    <p><strong><%: L.T("Company.TaskReview.Attempt2") %></strong>
        <asp:Label ID="lblDetailAttempt" runat="server" /></p>

    <p><strong><%: L.T("Company.TaskReview.StudentSText") %></strong><br />
        <asp:Label ID="lblDetailText" runat="server" /></p>

    <p><asp:HyperLink ID="lnkDetailWork" runat="server"
        Text="<%$ Resources:Company, TaskReview.OpenSubmittedLink %>" Target="_blank" Visible="false" /></p>

    <p><asp:HyperLink ID="lnkDetailFile" runat="server"
        Text="<%$ Resources:Company, TaskReview.OpenAttachedFile %>" Target="_blank" Visible="false" /></p>

    <hr class="my-4" />

    <h4><%: L.T("Company.TaskReview.Evaluation") %></h4>
    <p class="text-muted"><%: L.T("Company.TaskReview.EnterAScoreForEachCriterion") %></p>

    <asp:Repeater ID="rptReviewCriteria" runat="server">
        <ItemTemplate>
            <div class="mb-3">
                <label class="form-label">
                    <%#: Eval("Name") %>
                    <%: L.T("Company.TaskReview.Max") %> <%#: Eval("MaxScore") %>
                    <%: L.T("Company.TaskReview.Weight") %> <%#: Eval("Weight") %>%
                </label>

                <asp:TextBox ID="txtScore" runat="server"
                    TextMode="Number"
                    CssClass="form-control"
                    min="0"
                    step="0.01" />
            </div>
        </ItemTemplate>
    </asp:Repeater>

    <div class="mb-3">
        <asp:Label ID="Label1" runat="server"
            AssociatedControlID="txtFeedback"
            CssClass="form-label"
            Text="<%$ Resources:Company, TaskReview.FeedbackForStudent %>" />

        <asp:TextBox ID="TextBox1" runat="server"
            TextMode="MultiLine"
            Rows="4"
            CssClass="form-control" />
    </div>
    <div class="d-flex gap-2">
        <asp:Button ID="btnSaveGrade" runat="server"
            Text="<%$ Resources:Company, TaskReview.SaveGrade %>"
            CssClass="btn btn-brand"
            OnClick="btnSaveGrade_Click"
            Enabled="false"  data-ui-action="save" data-loading-label="Saving…"/>

        <asp:Button ID="Button1" runat="server"
            Text="<%$ Resources:Company, TaskReview.RequestRevision %>"
            CssClass="btn btn-outline-secondary"
            Enabled="false" />
    </div>
                       <asp:Label ID="lblReviewMessage" runat="server"
    CssClass="d-block mt-3" />
</asp:Panel>
                </div>

                <div class="mb-3 mt-3">
                    <asp:Label ID="lblFeedback" runat="server"
                        AssociatedControlID="txtFeedback"
                        CssClass="form-label" Text="<%$ Resources:Company, TaskReview.Feedback %>" />
                    <asp:TextBox ID="txtFeedback" runat="server"
                        CssClass="form-control" TextMode="MultiLine" Rows="4" />

                </div>

                <asp:Button ID="btnSaveEvaluation" runat="server"
                    Text="<%$ Resources:Company, TaskReview.SaveEvaluation %>" CssClass="btn btn-brand"
                    OnClientClick="showReviewNotice(); return false;" />
            </div>

            <%-- F06: revision fields --%>
            <div id="revisionSection" class="review-section">
                <button type="button" class="btn btn-link px-0"
                    onclick="showReviewChoices()">
                    <%: L.T("Company.TaskReview.BackToChoices") %>
                </button>

                <h4><%: L.T("Company.TaskReview.RequestRevision") %></h4>
                <p class="text-muted">
                    <%: L.T("Company.TaskReview.TellTheStudentExactlyWhatTo") %>
                </p>

                <div class="mb-3">
                    <asp:Label ID="lblRevisionInstructions" runat="server"
                        AssociatedControlID="txtRevisionInstructions"
                        CssClass="form-label" Text="<%$ Resources:Company, TaskReview.RevisionInstructions %>" />
                    <asp:TextBox ID="txtRevisionInstructions" runat="server"
                        CssClass="form-control" TextMode="MultiLine" Rows="5" />
                </div>

                <asp:Button ID="btnRequestRevision" runat="server"
                    Text="<%$ Resources:Company, TaskReview.SendRevisionRequest %>"
                    CssClass="btn btn-brand"
                    OnClientClick="showReviewNotice(); return false;" />
            </div>

            <div id="reviewNotice" class="alert alert-info mt-3"
                style="display: none;" role="status">
                <%: L.T("Company.TaskReview.ThisIsADesignPreviewNothing") %>
            </div>

            <%-- F07: all previous attempts remain readable. --%>
            <div class="review-history">
                <h4><%: L.T("Company.TaskReview.SubmissionHistory") %></h4>
                <p class="text-muted">
                    <%: L.T("Company.TaskReview.PreviousAttemptsWillStayHereEven") %>
                </p>

                <details>
                    <summary><%: L.T("Company.TaskReview.Attempt2PendingReview") %></summary>
                    <p class="mt-2 mb-0">
                        <%: L.T("Company.TaskReview.ExampleTextForTheStudentS") %>
                    </p>
                </details>

                <details>
                    <summary><%: L.T("Company.TaskReview.Attempt1RevisionRequested") %></summary>
                    <p class="mt-2">
                        <%: L.T("Company.TaskReview.ExampleTextForTheStudentS2") %>
                    </p>
                    <p class="mb-0">
                        <strong><%: L.T("Company.TaskReview.RevisionInstructions2") %></strong>
                        <%: L.T("Company.TaskReview.PleaseAddMoreDetailToThe") %>
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