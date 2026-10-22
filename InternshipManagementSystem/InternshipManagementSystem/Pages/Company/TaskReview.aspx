<%@ Page Language="C#"
    MasterPageFile="~/Layout/Company.master"
    AutoEventWireup="true"
    CodeBehind="TaskReview.aspx.cs"
    Inherits="InternshipManagementSystem.Pages.CompanyArea.TaskReview"
    Title="Review Submissions" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <style>
        .review-overlay {
            position: fixed;
            inset: 0;
            z-index: 2000;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 16px;
            background: rgba(17, 24, 39, .52);
            -webkit-backdrop-filter: blur(6px);
            backdrop-filter: blur(6px);
        }

        .review-dialog {
            width: 100%;
            max-width: 820px;
            max-height: calc(100vh - 32px);
            overflow-y: auto;
            background: #fff;
            border-radius: 16px;
            padding: 26px;
            box-shadow: 0 24px 65px rgba(0, 0, 0, .24);
        }

        .review-summary {
            padding: 16px;
            background: #f8fafc;
            border: 1px solid #e5e7eb;
            border-radius: 10px;
        }

        .review-tabs > input {
            position: absolute;
            opacity: 0;
            pointer-events: none;
        }

        .review-tab-buttons {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            padding: 6px;
            background: #f3f4f6;
            border-radius: 12px;
            margin: 20px 0;
        }

        .review-tab-buttons label {
            flex: 1;
            min-width: 150px;
            margin: 0;
            padding: 11px 14px;
            border-radius: 9px;
            text-align: center;
            font-weight: 600;
            cursor: pointer;
            color: #475569;
        }

        .review-tab-buttons label:hover {
            background: #e7ebef;
        }

        #reviewTabDetails:checked ~ .review-tab-buttons label[for="reviewTabDetails"],
        #reviewTabGrade:checked ~ .review-tab-buttons label[for="reviewTabGrade"],
        #reviewTabRevision:checked ~ .review-tab-buttons label[for="reviewTabRevision"] {
            background: #fff;
            color: #0b7a75;
            box-shadow: 0 2px 8px rgba(0, 0, 0, .12);
        }

        .review-tab-content {
            display: none;
        }

        #reviewTabDetails:checked ~ #reviewDetailsContent,
        #reviewTabGrade:checked ~ #reviewGradeContent,
        #reviewTabRevision:checked ~ #reviewRevisionContent {
            display: block;
        }

        .review-work-text {
            white-space: pre-wrap;
            overflow-wrap: anywhere;
        }

        @media (max-width: 576px) {
            .review-dialog {
                padding: 18px;
            }

            .review-tab-buttons {
                display: block;
            }

            .review-tab-buttons label {
                display: block;
                width: 100%;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

    <div class="mb-4">
        <h2 class="mb-1">Review Submissions</h2>
        <p class="text-muted mb-0">
            Review student work, give a grade, or request another attempt.
        </p>
    </div>

    <div class="uims-card">
        <h3 class="mb-3">Student Submissions</h3>

        <div class="table-responsive">
            <table class="uims-table">
                <thead>
                    <tr>
                        <th>Task</th>
                        <th>Trainee</th>
                        <th>Attempt</th>
                        <th>Status</th>
                        <th>Submitted At</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptSubmissions"
                        runat="server"
                        OnItemCommand="rptSubmissions_ItemCommand">
                        <ItemTemplate>
                            <tr>
                                <td><%#: Eval("TaskId") %></td>
                                <td><%#: Eval("StudentId") %></td>
                                <td><%#: Eval("AttemptNumber") %></td>
                                <td><%#: Eval("Status") %></td>
                                <td>
                                    <%# DateTimeOffset
                                        .FromUnixTimeMilliseconds(Convert.ToInt64(Eval("SubmittedAt")))
                                        .ToLocalTime()
                                        .ToString("yyyy-MM-dd HH:mm") %>
                                </td>
                                <td>
                                    <asp:LinkButton ID="btnViewDetails"
                                        runat="server"
                                        Text="View Details"
                                        CssClass="btn btn-outline-secondary btn-sm"
                                        CommandName="ViewDetails"
                                        CommandArgument='<%# Eval("Id") %>' />
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </div>

    <asp:Panel ID="pnlSubmissionDetails"
        runat="server"
        Visible="false"
        CssClass="review-overlay">

        <div class="review-dialog">

            <div class="d-flex justify-content-between align-items-start gap-3 mb-4">
                <div>
                    <h3 class="mb-1">Review Submission</h3>
                    <p class="text-muted mb-0">
                        Choose what you want to do with this attempt.
                    </p>
                </div>

                <a href="TaskReview.aspx"
                    class="btn btn-outline-secondary"
                    aria-label="Close">
                    &times;
                </a>
            </div>

            <div class="review-summary">
                <div>
                    <strong>Task:</strong>
                    <asp:Label ID="lblDetailTask" runat="server" />
                </div>

                <div class="mt-1">
                    <strong>Attempt:</strong>
                    <asp:Label ID="lblDetailAttempt" runat="server" />
                </div>
            </div>

            <asp:Label ID="lblReviewMessage"
                runat="server"
                EnableViewState="false"
                CssClass="d-block mt-3" />

            <div class="review-tabs">

                <input type="radio"
                    name="reviewAction"
                    id="reviewTabDetails"
                    checked="checked" />

                <input type="radio"
                    name="reviewAction"
                    id="reviewTabGrade" />

                <input type="radio"
                    name="reviewAction"
                    id="reviewTabRevision" />

                <div class="review-tab-buttons">
                    <label for="reviewTabDetails">View Details</label>
                    <label for="reviewTabGrade">Give Grade</label>
                    <label for="reviewTabRevision">Request Revision</label>
                </div>

                <%-- التبويب الأول: التفاصيل --%>
                <div id="reviewDetailsContent"
                    class="review-tab-content">

                    <h4 class="mb-3">Submitted Work</h4>

                    <div class="border rounded p-3 mb-3">
                        <strong>Student's Text</strong>

                        <div class="review-work-text mt-2">
                            <asp:Label ID="lblDetailText" runat="server" />
                        </div>
                    </div>

                    <div class="mb-2">
                        <asp:HyperLink ID="lnkDetailWork"
                            runat="server"
                            Text="Open submitted link"
                            Target="_blank"
                            Visible="false" />
                    </div>

                    <div>
                        <asp:HyperLink ID="lnkDetailFile"
                            runat="server"
                            Text="Open attached file"
                            Target="_blank"
                            Visible="false" />
                    </div>
                </div>

                <%-- التبويب الثاني: التقييم --%>
                <div id="reviewGradeContent"
                    class="review-tab-content">

                    <h4 class="mb-2">Give Grade</h4>
                    <p class="text-muted">
                        Enter a score for each criterion and leave feedback.
                    </p>

                    <asp:Repeater ID="rptReviewCriteria" runat="server">
                        <ItemTemplate>
                            <div class="border rounded p-3 mb-3">
                                <div class="mb-2">
                                    <strong><%#: Eval("Name") %></strong>
                                    <span class="text-muted">
                                        — Maximum: <%#: Eval("MaxScore") %>,
                                        Weight: <%#: Eval("Weight") %>%
                                    </span>
                                </div>

                                <div class="text-muted mb-2">
                                    <%#: Eval("Description") %>
                                </div>

                                <asp:TextBox ID="txtScore"
                                    runat="server"
                                    CssClass="form-control"
                                    TextMode="Number"
                                    min="0"
                                    step="0.01"
                                    placeholder="Enter score" />
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>

                    <div class="mb-3">
                        <asp:Label ID="lblFeedback"
                            runat="server"
                            AssociatedControlID="txtFeedback"
                            CssClass="form-label"
                            Text="Feedback for Student" />

                        <asp:TextBox ID="txtFeedback"
                            runat="server"
                            CssClass="form-control"
                            TextMode="MultiLine"
                            Rows="4" />
                    </div>

                    <asp:Button ID="btnSaveGrade"
                        runat="server"
                        Text="Save Grade"
                        CssClass="btn btn-brand"
                        OnClick="btnSaveGrade_Click" />
                </div>

                <%-- التبويب الثالث: طلب إعادة التسليم --%>
                <div id="reviewRevisionContent"
                    class="review-tab-content">

                    <h4 class="mb-2">Request Revision</h4>
                    <p class="text-muted">
                        Explain what the student needs to change.
                    </p>

                    <div class="mb-3">
                        <asp:Label ID="lblRevisionInstructions"
                            runat="server"
                            AssociatedControlID="txtRevisionInstructions"
                            CssClass="form-label"
                            Text="Revision Instructions" />

                        <asp:TextBox ID="txtRevisionInstructions"
                            runat="server"
                            CssClass="form-control"
                            TextMode="MultiLine"
                            Rows="4" />
                    </div>

                    <asp:Button ID="btnRequestRevision"
                        runat="server"
                        Text="Send Revision Request"
                        CssClass="btn btn-brand"
                        OnClick="btnRequestRevision_Click" />
                </div>

            </div>

            <div class="text-end mt-4">
                <a href="TaskReview.aspx"
                    class="btn btn-outline-secondary">
                    Close
                </a>
            </div>

        </div>
    </asp:Panel>

</asp:Content>