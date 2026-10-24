<%@ Page Language="C#" MasterPageFile="~/Layout/Student.master" AutoEventWireup="true" CodeBehind="MyTasks.aspx.cs" Inherits="InternshipManagementSystem.Pages.StudentArea.MyTasks" Title="My Tasks" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
<style>
.student-tasks-page{color:#183f60}.student-tasks-heading{margin-bottom:22px}.student-tasks-heading h2{margin:0 0 6px;font-size:1.8rem;font-weight:700;color:#123d60}.student-tasks-heading p{margin:0;color:#627b94}
.student-tasks-layout{display:grid;grid-template-columns:minmax(0,1.45fr) minmax(320px,.85fr);gap:18px;align-items:start}.student-task-card,.student-submit-card{background:#fff;border:1px solid #d8e4f1;border-radius:12px;overflow:hidden}
.student-card-heading{padding:18px 20px;border-bottom:1px solid #e4ecf5}.student-card-heading h3{margin:0 0 4px;font-size:1.12rem;font-weight:700;color:#173f60}.student-card-heading p{margin:0;font-size:.88rem;color:#71869b}
.student-task-table{width:100%;border-collapse:collapse}.student-task-table th{padding:11px 14px;background:#eef4fb;color:#315674;text-align:left;font-size:.78rem;font-weight:700}.student-task-table td{padding:13px 14px;border-top:1px solid #e7edf4;vertical-align:middle;color:#536a7e;font-size:.86rem}.student-task-table tr.is-selected td{background:#f0f6ff}
.student-task-title{display:block;color:#173f60;font-weight:700;margin-bottom:3px}.student-task-subtitle{display:block;color:#7a8ea1;font-size:.76rem}.student-status{display:inline-flex;align-items:center;border-radius:20px;padding:4px 9px;background:#edf2f7;color:#54697d;font-size:.72rem;font-weight:700;white-space:nowrap}.student-status:before{content:'';width:6px;height:6px;margin-right:6px;border-radius:50%;background:currentColor}.status-action,.status-revision{background:#fff1df;color:#975400}.status-submitted{background:#e5f0ff;color:#285b88}.status-done{background:#e8f0f8;color:#315674}
.student-select-button{padding:6px 10px;border:1px solid #b7c9dc;border-radius:7px;background:#fff;color:#27577e;font-size:.78rem;font-weight:700}.student-select-button:hover,.student-select-button:focus{background:#edf5ff;border-color:#7ea3c8}
.student-submit-body{padding:18px 20px}.student-selected-meta{display:flex;justify-content:space-between;gap:12px;align-items:start;padding-bottom:14px;margin-bottom:15px;border-bottom:1px solid #e7edf4}.student-selected-meta h4{margin:0 0 5px;font-size:1rem;font-weight:700;color:#173f60}.student-selected-meta p{margin:0;color:#71869b;font-size:.8rem}
.student-detail-block{margin:0 0 14px}.student-detail-block h5{margin:0 0 5px;font-size:.8rem;color:#315674;font-weight:700}.student-detail-block p{margin:0;color:#60788d;font-size:.84rem;white-space:pre-line;overflow-wrap:anywhere}.student-attachment-link{display:inline-block;margin-top:7px;color:#27577e;font-size:.82rem;font-weight:700}
.student-submit-form{border-top:1px solid #e7edf4;padding-top:15px;margin-top:15px}.student-submit-form h4{margin:0 0 4px;font-size:1rem;color:#173f60;font-weight:700}.student-submit-form .form-label{margin-bottom:5px;color:#355b79;font-size:.8rem;font-weight:700}.student-submit-form .form-control{border-color:#d2dfed;font-size:.85rem}.student-submit-form textarea.form-control{min-height:72px}.student-file-help{margin-top:5px;color:#788da1;font-size:.74rem}
.student-criteria,.student-history{margin-top:16px;padding-top:14px;border-top:1px solid #e7edf4}.student-criteria h4,.student-history h4{margin:0 0 9px;font-size:.92rem;font-weight:700;color:#173f60}.student-criterion,.student-history-row{padding:8px 0;border-bottom:1px solid #edf1f6;font-size:.79rem;color:#627b90}.student-criterion:last-child,.student-history-row:last-child{border-bottom:0}.student-history-row strong{color:#355b79}
.student-empty-selection{padding:28px 20px;text-align:center;color:#71869b}.student-empty-selection strong{display:block;margin-bottom:5px;color:#315674}.student-submit-button{width:100%;margin-top:12px}
@media(max-width:900px){.student-tasks-layout{grid-template-columns:1fr}}@media(max-width:600px){.student-task-table th,.student-task-table td{padding:9px 8px;font-size:.75rem}.student-task-table th:nth-child(3),.student-task-table td:nth-child(3){display:none}.student-card-heading,.student-submit-body{padding-left:14px;padding-right:14px}.student-selected-meta{flex-direction:column}}
</style>
</asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="student-tasks-page">
    <div class="student-tasks-heading"><h2>My tasks</h2><p>Review the tasks assigned to you and submit your work before the deadline.</p></div>
    <div class="student-tasks-layout">
        <section class="student-task-card" aria-labelledby="assignedTasksHeading">
            <div class="student-card-heading"><h3 id="assignedTasksHeading">Assigned tasks</h3><p>Select a task to view its instructions and submission options.</p></div>
            <div class="table-responsive"><table class="student-task-table">
                <thead><tr><th>Task</th><th>Deadline</th><th>Status</th><th>Attempts</th><th></th></tr></thead>
                <tbody>
                    <asp:Repeater ID="rptTasks" runat="server" OnItemCommand="rptTasks_ItemCommand"><ItemTemplate>
                        <tr class='<%# Eval("RowClass") %>'>
                            <td><span class="student-task-title"><%#: Eval("Title") %></span><span class="student-task-subtitle"><%#: Eval("StartLabel") %></span></td>
                            <td><%#: Eval("DeadlineLabel") %></td><td><span class='student-status <%#: Eval("StatusClass") %>'><%#: Eval("StatusLabel") %></span></td><td><%#: Eval("AttemptsLabel") %></td>
                            <td><asp:LinkButton ID="lnkSelectTask" runat="server" CssClass="student-select-button" Text='<%# Eval("ActionLabel") %>' CommandName="SelectTask" CommandArgument='<%# Eval("Id") %>' CausesValidation="false" /></td>
                        </tr>
                    </ItemTemplate></asp:Repeater>
                    <asp:PlaceHolder ID="phNoTaskRows" runat="server" Visible="false"><tr><td colspan="5" class="text-center py-4">No tasks have been assigned to your placement yet.</td></tr></asp:PlaceHolder>
                </tbody>
            </table></div>
            <asp:Panel ID="pnlNoTasks" runat="server" CssClass="student-empty-selection" Visible="false">Your supervisor's tasks will appear here when they are assigned.</asp:Panel>
        </section>
        <section class="student-submit-card" aria-labelledby="submitTaskHeading">
            <asp:Panel ID="pnlSelectTask" runat="server" CssClass="student-empty-selection" Visible="true"><strong>Choose a task</strong>Select one of your assigned tasks to see its details and submit your work.</asp:Panel>
            <asp:Panel ID="pnlSelectedTask" runat="server" Visible="false">
                <div class="student-card-heading"><h3 id="submitTaskHeading">Task details and submission</h3><p>Submit your work here. Each resubmission is saved as a new attempt.</p></div>
                <div class="student-submit-body">
                    <div class="student-selected-meta"><div><h4><asp:Literal ID="litTaskTitle" runat="server" Mode="Encode" /></h4><p>Deadline: <asp:Literal ID="litDeadline" runat="server" Mode="Encode" /></p></div><span class="student-status"><asp:Literal ID="litStatus" runat="server" Mode="Encode" /></span></div>
                    <div class="student-detail-block"><h5>Description</h5><p><asp:Literal ID="litDescription" runat="server" Mode="Encode" /></p></div>
                    <div class="student-detail-block"><h5>Instructions</h5><p><asp:Literal ID="litInstructions" runat="server" Mode="Encode" /></p><asp:HyperLink ID="lnkTaskAttachment" runat="server" CssClass="student-attachment-link" Target="_blank" Visible="false" /></div>
                    <asp:Panel ID="pnlSubmissionForm" runat="server" CssClass="student-submit-form">
                        <h4>Submit or resubmit work</h4><p class="text-muted small mb-3">Add a note, a link, or an attachment as requested.</p>
                        <div class="mb-3"><asp:Label ID="lblSubmissionText" runat="server" AssociatedControlID="txtSubmissionText" CssClass="form-label" Text="Description or note (optional)" /><asp:TextBox ID="txtSubmissionText" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" MaxLength="2000" /></div>
                        <div class="mb-3"><asp:Label ID="lblSubmissionLink" runat="server" AssociatedControlID="txtSubmissionLink" CssClass="form-label" Text="Link (optional)" /><asp:TextBox ID="txtSubmissionLink" runat="server" CssClass="form-control" TextMode="Url" MaxLength="2000" /><div class="student-file-help">Use a full link beginning with https:// or http://.</div></div>
                        <div class="mb-2"><asp:Label ID="lblSubmissionFile" runat="server" AssociatedControlID="fuSubmission" CssClass="form-label" Text="Attachment (optional)" /><asp:FileUpload ID="fuSubmission" runat="server" CssClass="form-control" /><div class="student-file-help">PDF, Word, ZIP, or image file. Maximum size: 10 MB.</div><asp:Literal ID="litFileRequirement" runat="server" Mode="Encode" /></div>
                        <asp:Label ID="lblSubmitMessage" runat="server" Visible="false" EnableViewState="false" />
                        <asp:Button ID="btnSubmitTask" runat="server" Text="Submit task" CssClass="btn btn-brand student-submit-button" OnClick="btnSubmitTask_Click" />
                    </asp:Panel>
                    <asp:Panel ID="pnlSubmissionClosed" runat="server" CssClass="alert alert-info mt-3" Visible="false">This task is not accepting submissions right now. Check the status above or contact your supervisor.</asp:Panel>
                    <div class="student-criteria"><h4>Task criteria</h4><asp:Repeater ID="rptCriteria" runat="server"><ItemTemplate><div class="student-criterion"><strong><%#: Eval("Name") %></strong> <span><%#: Eval("Description") %></span><div><%#: Eval("MaxScore", "{0:0.##}") %> points</div></div></ItemTemplate></asp:Repeater><asp:Label ID="lblNoCriteria" runat="server" CssClass="text-muted small" Text="No additional criteria were provided." Visible="false" /></div>
                    <div class="student-history"><h4>Submission history</h4><asp:Repeater ID="rptHistory" runat="server"><ItemTemplate>
                        <div class="student-history-row"><strong>Attempt <%#: Eval("AttemptLabel") %></strong><span> · <%#: Eval("SubmittedLabel") %> · <%#: Eval("StatusLabel") %></span><div><%#: Eval("Feedback") %></div>
                            <asp:HyperLink ID="lnkSubmissionFile" runat="server" NavigateUrl='<%# Eval("FileUrl") %>' Text='<%# Eval("FileName") %>' Target="_blank" Visible='<%# Eval("HasFile") %>' CssClass="student-attachment-link" />
                            <asp:HyperLink ID="lnkSubmissionLink" runat="server" NavigateUrl='<%# Eval("LinkUrl") %>' Text="Open submitted link" Target="_blank" Visible='<%# Eval("HasLink") %>' CssClass="student-attachment-link" />
                        </div>
                    </ItemTemplate></asp:Repeater><asp:PlaceHolder ID="phNoAttempts" runat="server" Visible="true"><p class="text-muted small mb-0">No submissions yet.</p></asp:PlaceHolder></div>
                </div>
            </asp:Panel>
        </section>
    </div>
</div>
</asp:Content>
