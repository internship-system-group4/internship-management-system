<%@ Page Language="C#" MasterPageFile="~/Layout/Student.master" AutoEventWireup="true" CodeBehind="MyTasks.aspx.cs" Inherits="InternshipManagementSystem.Pages.StudentArea.MyTasks" Title="My Tasks" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
<link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/task-dialogs.css?v=20261024-3") %>" />
<style>
.student-tasks-page{color:var(--th-fg-183f60,#183f60)}.student-tasks-heading{margin-bottom:22px}.student-tasks-heading h2{margin:0 0 6px;font-size:1.8rem;font-weight:700;color:var(--th-fg-123d60,#123d60)}.student-tasks-heading p{margin:0;color:var(--ui-muted)}
.student-tasks-layout{display:grid;grid-template-columns:minmax(0,1.45fr) minmax(320px,.85fr);gap:18px;align-items:start}.student-task-card,.student-submit-card{background:var(--ui-surface,#fff);border:1px solid var(--th-line-d8e4f1,#d8e4f1);border-radius:12px;overflow:hidden}
.student-card-heading{padding:18px 20px;border-bottom:1px solid var(--th-line-e4ecf5,#e4ecf5)}.student-card-heading h3{margin:0 0 4px;font-size:1.12rem;font-weight:700;color:var(--th-fg-173f60,#173f60)}.student-card-heading p{margin:0;font-size:.88rem;color:var(--ui-muted)}
.student-task-table{width:100%;border-collapse:collapse}.student-task-table th{padding:11px 14px;background:var(--th-bg-eef4fb,#eef4fb);color:var(--th-fg-315674,#315674);text-align:start;font-size:.78rem;font-weight:700}.student-task-table td{padding:13px 14px;border-top:1px solid var(--th-line-e7edf4,#e7edf4);vertical-align:middle;color:var(--th-fg-536a7e,#536a7e);font-size:.86rem}.student-task-table tr.is-selected td{background:var(--th-bg-f0f6ff,#f0f6ff)}
.student-task-title{display:block;color:var(--th-fg-173f60,#173f60);font-weight:700;margin-bottom:3px}.student-task-subtitle{display:block;color:var(--ui-muted);font-size:.76rem}.student-status{display:inline-flex;align-items:center;border-radius:20px;padding:4px 9px;background:var(--th-bg-edf2f7,#edf2f7);color:var(--th-fg-54697d,#54697d);font-size:.72rem;font-weight:700;white-space:nowrap}.student-status:before{content:'';width:6px;height:6px;margin-inline-end:6px;border-radius:50%;background:currentColor}.status-action,.status-revision{background:var(--th-bg-fff1df,#fff1df);color:var(--th-fg-975400,#975400)}.status-submitted{background:var(--th-bg-e5f0ff,#e5f0ff);color:var(--th-fg-285b88,#285b88)}.status-done{background:var(--th-bg-e8f0f8,#e8f0f8);color:var(--th-fg-315674,#315674)}
.student-select-button{padding:6px 10px;border:1px solid var(--th-line-b7c9dc,#b7c9dc);border-radius:7px;background:var(--ui-surface,#fff);color:var(--th-fg-27577e,#27577e);font-size:.78rem;font-weight:700}.student-select-button:hover,.student-select-button:focus{background:var(--th-bg-edf5ff,#edf5ff);border-color:var(--th-line-7ea3c8,#7ea3c8)}
.student-submit-body{padding:18px 20px}.student-selected-meta{display:flex;justify-content:space-between;gap:12px;align-items:start;padding-bottom:14px;margin-bottom:15px;border-bottom:1px solid var(--th-line-e7edf4,#e7edf4)}.student-selected-meta h4{margin:0 0 5px;font-size:1rem;font-weight:700;color:var(--th-fg-173f60,#173f60)}.student-selected-meta p{margin:0;color:var(--ui-muted);font-size:.8rem}
.student-detail-block{margin:0 0 14px}.student-detail-block h5{margin:0 0 5px;font-size:.8rem;color:var(--th-fg-315674,#315674);font-weight:700}.student-detail-block p{margin:0;color:var(--th-fg-60788d,#60788d);font-size:.84rem;white-space:pre-line;overflow-wrap:anywhere}.student-attachment-link{display:inline-block;margin-top:7px;color:var(--th-fg-27577e,#27577e);font-size:.82rem;font-weight:700}
.student-submit-form{border-top:1px solid var(--th-line-e7edf4,#e7edf4);padding-top:15px;margin-top:15px}.student-submit-form h4{margin:0 0 4px;font-size:1rem;color:var(--th-fg-173f60,#173f60);font-weight:700}.student-submit-form .form-label{margin-bottom:5px;color:var(--th-fg-355b79,#355b79);font-size:.8rem;font-weight:700}.student-submit-form .form-control{border-color:var(--th-line-d2dfed,#d2dfed);font-size:.85rem}.student-submit-form textarea.form-control{min-height:72px}.student-file-help{margin-top:5px;color:var(--ui-muted);font-size:.74rem}
.student-criteria,.student-history{margin-top:16px;padding-top:14px;border-top:1px solid var(--th-line-e7edf4,#e7edf4)}.student-criteria h4,.student-history h4{margin:0 0 9px;font-size:.92rem;font-weight:700;color:var(--th-fg-173f60,#173f60)}.student-criterion,.student-history-row{padding:8px 0;border-bottom:1px solid var(--th-line-edf1f6,#edf1f6);font-size:.79rem;color:var(--ui-muted)}.student-criterion:last-child,.student-history-row:last-child{border-bottom:0}.student-history-row strong{color:var(--th-fg-355b79,#355b79)}
.student-empty-selection{padding:28px 20px;text-align:center;color:var(--ui-muted)}.student-empty-selection strong{display:block;margin-bottom:5px;color:var(--th-fg-315674,#315674)}.student-submit-button{width:100%;margin-top:12px}
@media(max-width:900px){.student-tasks-layout{grid-template-columns:1fr}}@media(max-width:600px){.student-task-table th,.student-task-table td{padding:9px 8px;font-size:.75rem}.student-task-table th:nth-child(3),.student-task-table td:nth-child(3){display:none}.student-card-heading,.student-submit-body{padding-inline-start:14px;padding-inline-end:14px}.student-selected-meta{flex-direction:column}}
</style>
</asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="student-tasks-page">
    <div class="student-tasks-heading"><h2><%: L.T("Student.MyTasks.MyTasks2") %></h2><p><%: L.T("Student.MyTasks.ReviewTheTasksAssignedToYou") %></p></div>
    <div class="student-tasks-layout">
        <section class="student-task-card" aria-labelledby="assignedTasksHeading">
            <div class="student-card-heading"><h3 id="assignedTasksHeading"><%: L.T("Student.MyTasks.AssignedTasks2") %></h3><p><%: L.T("Student.MyTasks.SelectATaskToViewIts") %></p></div>
            <div class="table-responsive"><table class="student-task-table">
                <thead><tr><th><%: L.T("Student.MyTasks.Task") %></th><th><%: L.T("Student.MyTasks.Deadline") %></th><th><%: L.T("Student.MyTasks.Status2") %></th><th><%: L.T("Student.MyTasks.Attempts") %></th><th></th></tr></thead>
                <tbody>
                    <asp:Repeater ID="rptTasks" runat="server" OnItemCommand="rptTasks_ItemCommand"><ItemTemplate>
                        <tr class='<%# Eval("RowClass") %>'>
                            <td><span class="student-task-title"><%#: Eval("Title") %></span><span class="student-task-subtitle"><%#: Eval("StartLabel") %></span></td>
                            <td><%#: Eval("DeadlineLabel") %></td><td><span class='student-status <%#: Eval("StatusClass") %>'><%#: L.Value("Ui", Eval("StatusLabel")) %></span></td><td><%#: Eval("AttemptsLabel") %></td>
                            <td><asp:LinkButton ID="lnkSelectTask" runat="server" CssClass="student-select-button" Text='<%# L.Value("Ui", Eval("ActionLabel")) %>' CommandName='<%# Eval("CommandName") %>' CommandArgument='<%# Eval("Id") %>' CausesValidation="false" /></td>
                        </tr>
                    </ItemTemplate></asp:Repeater>
                    <asp:PlaceHolder ID="phNoTaskRows" runat="server" Visible="false"><tr><td colspan="5" class="text-center py-4"><%: L.T("Student.MyTasks.NoTasksHaveBeenAssignedTo2") %></td></tr></asp:PlaceHolder>
                </tbody>
            </table></div>
            <asp:Panel ID="pnlNoTasks" runat="server" CssClass="student-empty-selection" Visible="false"><%: L.T("Student.MyTasks.YourSupervisorSTasksWillAppear") %></asp:Panel>
        </section>
        <section class="student-submit-card" aria-labelledby="submitTaskHeading">
            <asp:Panel ID="pnlSelectTask" runat="server" CssClass="student-empty-selection" Visible="true"><strong><%: L.T("Student.MyTasks.ChooseATask") %></strong><%: L.T("Student.MyTasks.SelectOneOfYourAssignedTasks") %></asp:Panel>
            <asp:Panel ID="pnlSelectedTask" runat="server" Visible="false">
                <div class="student-card-heading"><h3 id="submitTaskHeading"><%: L.T("Student.MyTasks.TaskDetailsAndSubmission") %></h3><p><%: L.T("Student.MyTasks.SubmitYourWorkHereEachResubmission") %></p></div>
                <div class="student-submit-body">
                    <div class="student-selected-meta"><div><h4><asp:Literal ID="litTaskTitle" runat="server" Mode="Encode" /></h4><p><%: L.T("Student.MyTasks.Deadline2") %> <asp:Literal ID="litDeadline" runat="server" Mode="Encode" /></p></div><span class="student-status <%: SelectedStatusClass %>"><asp:Literal ID="litStatus" runat="server" Mode="Encode" /></span></div>
                    <div class="student-detail-block"><h5><%: L.T("Student.MyTasks.Description") %></h5><p><asp:Literal ID="litDescription" runat="server" Mode="Encode" /></p></div>
                    <div class="student-detail-block"><h5><%: L.T("Student.MyTasks.Instructions") %></h5><p><asp:Literal ID="litInstructions" runat="server" Mode="Encode" /></p><asp:HyperLink ID="lnkTaskAttachment" runat="server" CssClass="student-attachment-link" Target="_blank" Visible="false" /></div>
                    <asp:Panel ID="pnlSubmissionForm" runat="server" CssClass="student-submit-form">
                        <h4><%: L.T("Student.MyTasks.SubmitOrResubmitWork") %></h4><p class="text-muted small mb-3"><%: L.T("Student.MyTasks.AddANoteALinkOr") %></p>
                        <asp:PlaceHolder ID="phRevisionNote" runat="server" Visible="false">
                            <div class="task-dialog-callout"><strong><%: L.T("Student.MyTasks.SupervisorRequestedChanges") %></strong><p><asp:Literal ID="litRevisionNote" runat="server" Mode="Encode" /></p></div>
                        </asp:PlaceHolder>
                        <button type="button" id="btnOpenSubmitDialog" class="task-dialog-btn task-dialog-btn-primary task-dialog-open" data-task-dialog="submitWorkDialog">
                            <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 16V4m-5 5 5-5 5 5M4 17v4h16v-4" /></svg>
                            <asp:Literal ID="litOpenSubmitLabel" runat="server" Mode="Encode" />
                        </button>
                    </asp:Panel>
                    <asp:Panel ID="pnlSubmissionClosed" runat="server" CssClass="alert alert-info mt-3" Visible="false"><%: L.T("Student.MyTasks.ThisTaskIsNotAcceptingSubmissions2") %></asp:Panel>
                    <div class="student-criteria"><h4><%: L.T("Student.MyTasks.TaskCriteria") %></h4><asp:Repeater ID="rptCriteria" runat="server"><ItemTemplate><div class="student-criterion"><strong><%#: Eval("Name") %></strong> <span><%#: Eval("Description") %></span><div><%#: Eval("MaxScore", "{0:0.##}") %> <%: L.T("Student.MyTasks.Points2") %></div></div></ItemTemplate></asp:Repeater><asp:Label ID="lblNoCriteria" runat="server" CssClass="text-muted small" Text="<%$ Resources:Student, MyTasks.NoAdditionalCriteriaWereProvided %>" Visible="false" /></div>
                    <div class="student-history"><h4><%: L.T("Student.MyTasks.SubmissionHistory2") %></h4><asp:Repeater ID="rptHistory" runat="server"><ItemTemplate>
                        <div class="student-history-row"><strong><%: L.T("Student.MyTasks.Attempt") %> <%#: Eval("AttemptLabel") %></strong><span> · <%#: Eval("SubmittedLabel") %> · <%#: Eval("StatusLabel") %></span><div><%#: Eval("Feedback") %></div>
                            <asp:HyperLink ID="lnkSubmissionFile" runat="server" NavigateUrl='<%# Eval("FileUrl") %>' Text='<%# Eval("FileName") %>' Target="_blank" Visible='<%# Eval("HasFile") %>' CssClass="student-attachment-link" />
                            <asp:HyperLink ID="lnkSubmissionLink" runat="server" NavigateUrl='<%# Eval("LinkUrl") %>' Text="<%$ Resources:Student, MyTasks.OpenSubmittedLink %>" Target="_blank" Visible='<%# Eval("HasLink") %>' CssClass="student-attachment-link" />
                        </div>
                    </ItemTemplate></asp:Repeater><asp:PlaceHolder ID="phNoAttempts" runat="server" Visible="true"><p class="text-muted small mb-0"><%: L.T("Student.MyTasks.NoSubmissionsYet") %></p></asp:PlaceHolder></div>
                </div>
            </asp:Panel>
        </section>
    </div>
</div>

<%-- Submit / resubmit popup (shared design: Assets/css/task-dialogs.css). --%>
<asp:PlaceHolder ID="phSubmitDialog" runat="server" Visible="false">
<div class="modal fade uims-task-dialog" id="submitWorkDialog" tabindex="-1" aria-labelledby="submitWorkTitle" aria-hidden="true" data-open="<%= OpenDialog == "submit" ? "true" : "false" %>">
    <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content">
            <div class="task-dialog-header">
                <span class="task-dialog-icon <%= IsResubmission ? "is-warning" : "" %>" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M12 16V4m-5 5 5-5 5 5M4 17v4h16v-4" /></svg></span>
                <div class="task-dialog-heading">
                    <span class="task-dialog-eyebrow <%= IsResubmission ? "is-warning" : "" %>"><asp:Literal ID="litDialogEyebrow" runat="server" Mode="Encode" /></span>
                    <h2 class="modal-title" id="submitWorkTitle"><asp:Literal ID="litDialogTitle" runat="server" Mode="Encode" /></h2>
                    <p class="task-dialog-sub"><asp:Literal ID="litDialogTask" runat="server" Mode="Encode" /></p>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="<%: L.T("Student.MyTasks.Cancel") %>"></button>
            </div>
            <div class="modal-body">
                <asp:Label ID="lblSubmitMessage" runat="server" Visible="false" EnableViewState="false" CssClass="task-dialog-alert" role="alert" />
                <asp:PlaceHolder ID="phDialogRevisionNote" runat="server" Visible="false">
                    <div class="task-dialog-callout"><strong><%: L.T("Student.MyTasks.SupervisorRequestedChanges") %></strong><p><asp:Literal ID="litDialogRevisionNote" runat="server" Mode="Encode" /></p></div>
                </asp:PlaceHolder>
                <div class="task-dialog-field"><asp:Label ID="lblSubmissionText" runat="server" AssociatedControlID="txtSubmissionText" CssClass="form-label" Text="<%$ Resources:Student, MyTasks.DescriptionOrNoteOptional %>" /><asp:TextBox ID="txtSubmissionText" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="4" MaxLength="2000" /></div>
                <div class="task-dialog-field"><asp:Label ID="lblSubmissionLink" runat="server" AssociatedControlID="txtSubmissionLink" CssClass="form-label" Text="<%$ Resources:Student, MyTasks.LinkOptional %>" /><asp:TextBox ID="txtSubmissionLink" runat="server" CssClass="form-control" TextMode="Url" MaxLength="2000" /><div class="task-dialog-help"><%: L.T("Student.MyTasks.UseAFullLinkBeginningWith") %></div></div>
                <div class="task-dialog-field"><asp:Label ID="lblSubmissionFile" runat="server" AssociatedControlID="fuSubmission" CssClass="form-label" Text="<%$ Resources:Student, MyTasks.AttachmentOptional %>" /><asp:FileUpload ID="fuSubmission" runat="server" CssClass="form-control" /><div class="task-dialog-help"><%: L.T("Student.MyTasks.PDFWordZIPOrImageFile") %></div><asp:Literal ID="litFileRequirement" runat="server" Mode="PassThrough" /></div>
                <div class="task-dialog-callout is-info"><strong><%: L.T("Student.MyTasks.WhatHappensNext") %></strong><p><asp:Literal ID="litDialogNext" runat="server" Mode="Encode" /></p></div>
            </div>
            <div class="task-dialog-footer">
                <button type="button" class="task-dialog-btn task-dialog-btn-secondary" data-bs-dismiss="modal"><%: L.T("Student.MyTasks.Cancel") %></button>
                <asp:Button ID="btnSubmitTask" runat="server" Text="<%$ Resources:Student, MyTasks.SubmitTask2 %>" CssClass="task-dialog-btn task-dialog-btn-primary" OnClick="btnSubmitTask_Click" data-ui-action="submit" data-loading-label="<%$ Resources:Student, MyTasks.Sending %>" />
            </div>
        </div>
    </div>
</div>
</asp:PlaceHolder>

<%-- Result popup shown after the server saved the submission. --%>
<asp:PlaceHolder ID="phResultDialog" runat="server" Visible="false">
<div class="modal fade uims-task-dialog task-result" id="submitResultDialog" tabindex="-1" aria-labelledby="submitResultTitle" aria-hidden="true" data-open="<%= OpenDialog == "result" ? "true" : "false" %>">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="task-result-body" role="status">
                <span class="task-dialog-icon is-success" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="m5 12.5 4.2 4.2L19 7" /></svg></span>
                <h2 id="submitResultTitle"><asp:Literal ID="litResultTitle" runat="server" Mode="Encode" /></h2>
                <p><asp:Literal ID="litResultMessage" runat="server" Mode="Encode" /></p>
                <ul class="task-result-facts"><li><asp:Literal ID="litResultAttempt" runat="server" Mode="Encode" /></li><li><%: L.T("Student.MyTasks.WaitingForReview") %></li></ul>
                <button type="button" class="task-dialog-btn task-dialog-btn-primary" data-bs-dismiss="modal"><%: L.T("Student.MyTasks.Done") %></button>
            </div>
        </div>
    </div>
</div>
</asp:PlaceHolder>
<script src="<%: ResolveUrl("~/Assets/js/task-dialogs.js?v=20261024-3") %>"></script>
</asp:Content>
