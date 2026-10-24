<%@ Page Language="C#" MasterPageFile="~/Layout/Student.master" AutoEventWireup="true" CodeBehind="MyTasks.aspx.cs" Inherits="InternshipManagementSystem.Pages.StudentArea.MyTasks" Title="My Tasks" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
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
.student-tasks-layout{grid-template-columns:minmax(0,1fr)}
.student-task-dialog{position:fixed;inset:0;z-index:99999;display:none;align-items:center;justify-content:center;padding:24px;pointer-events:auto}
.student-task-dialog.is-open{display:flex}
.student-task-dialog-backdrop{position:absolute;inset:0;z-index:0;width:100%;height:100%;border:0;background:rgba(19,43,65,.58);backdrop-filter:blur(3px);cursor:default}
.student-submit-card{position:relative;z-index:1;width:min(640px,100%);max-height:min(78vh,700px);overflow:auto;border-radius:14px;box-shadow:0 24px 72px rgba(14,39,63,.28);animation:studentDialogIn 180ms ease-out}
.student-dialog-close{position:absolute;top:12px;inset-inline-end:14px;z-index:2;display:grid;place-items:center;width:34px;height:34px;border:1px solid var(--th-line-d8e4f1,#d8e4f1);border-radius:50%;background:var(--ui-surface,#fff);color:var(--th-fg-315674,#315674);font-size:21px;line-height:1;cursor:pointer}
.student-dialog-close:hover{background:var(--th-bg-edf5ff,#edf5ff)}
.student-submit-card .student-card-heading{padding:14px 52px 13px 18px}
.student-submit-card .student-card-heading h3{font-size:.98rem}
.student-submit-card .student-card-heading p{font-size:.76rem;line-height:1.45}
.student-submit-card .student-submit-body{padding:14px 18px}
.student-submit-card .student-selected-meta{gap:8px;padding-bottom:10px;margin-bottom:11px}
.student-submit-card .student-selected-meta h4{font-size:.9rem}
.student-submit-card .student-selected-meta p,.student-submit-card .student-detail-block p{font-size:.76rem;line-height:1.45}
.student-submit-card .student-detail-block{margin-bottom:10px}
.student-submit-card .student-detail-block h5{font-size:.72rem;margin-bottom:3px}
.student-submit-card .student-submit-form{padding-top:11px;margin-top:11px}
.student-submit-card .student-submit-form h4{font-size:.9rem}
.student-submit-card .student-submit-form>p{font-size:.74rem;margin-bottom:10px!important}
.student-submit-card .student-submit-form .mb-3{margin-bottom:10px!important}
.student-submit-card .student-submit-form .form-label{font-size:.72rem}
.student-submit-card .student-submit-form .form-control{padding:7px 10px;font-size:.78rem}
.student-submit-card .student-submit-form textarea.form-control{min-height:58px}
.student-submit-card .student-file-help{font-size:.68rem}
.student-submit-card .student-criteria,.student-submit-card .student-history{margin-top:11px;padding-top:10px}
.student-submit-card .student-criteria h4,.student-submit-card .student-history h4{font-size:.82rem}
.student-submit-card .student-criterion,.student-submit-card .student-history-row{padding:6px 0;font-size:.72rem}
.student-submit-card .student-submit-button{padding:8px 14px;font-size:.8rem}
body.student-dialog-active{overflow:hidden}
@keyframes studentDialogIn{from{opacity:0;transform:translateY(10px) scale(.985)}to{opacity:1;transform:translateY(0) scale(1)}}
@media(max-width:600px){.student-task-dialog{padding:10px}.student-submit-card{width:100%;max-height:86vh;border-radius:13px}.student-submit-card .student-card-heading{padding:13px 48px 12px 14px}.student-submit-card .student-submit-body{padding:12px 14px}}
@media(prefers-reduced-motion:reduce){.student-submit-card{animation:none}}
.student-success-dialog{position:fixed;inset:0;z-index:100001;display:none;align-items:center;justify-content:center;padding:20px}
.student-success-dialog.is-open{display:flex}
.student-success-backdrop{position:absolute;inset:0;border:0;background:rgba(19,43,65,.55);backdrop-filter:blur(3px)}
.student-success-card{position:relative;z-index:1;width:min(360px,100%);padding:28px 26px 24px;border:1px solid var(--th-line-d8e4f1,#d8e4f1);border-radius:18px;background:var(--ui-surface,#fff);box-shadow:0 22px 64px rgba(14,39,63,.26);text-align:center;animation:studentDialogIn 180ms ease-out}
.student-success-check{display:grid;place-items:center;width:58px;height:58px;margin:0 auto 15px;border-radius:50%;background:#e8f6ee;color:#18734d}
.student-success-check svg{width:29px;height:29px;fill:none;stroke:currentColor;stroke-width:2.5;stroke-linecap:round;stroke-linejoin:round;stroke-dasharray:30;stroke-dashoffset:30;animation:studentCheckDraw 420ms ease-out 100ms forwards}
.student-success-card h3{margin:0 0 7px;color:var(--th-fg-173f60,#173f60);font-size:1.05rem;font-weight:700}
.student-success-card p{margin:0 0 18px;color:var(--ui-muted);font-size:.84rem;line-height:1.5}
.student-success-close{min-height:36px;padding:8px 20px;border:0;border-radius:9px;background:var(--th-fg-27577e,#27577e);color:#fff;font-size:.8rem;font-weight:700;cursor:pointer}
.student-success-close:hover{filter:brightness(1.08)}
@keyframes studentCheckDraw{to{stroke-dashoffset:0}}
@media(prefers-reduced-motion:reduce){.student-success-card,.student-success-check svg{animation:none;stroke-dashoffset:0}}
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
                            <td><asp:LinkButton ID="lnkSelectTask" runat="server" CssClass="student-select-button" Text='<%# L.Value("Ui", Eval("ActionLabel")) %>' CommandName="SelectTask" CommandArgument='<%# Eval("Id") %>' CausesValidation="false" /></td>
                        </tr>
                    </ItemTemplate></asp:Repeater>
                    <asp:PlaceHolder ID="phNoTaskRows" runat="server" Visible="false"><tr><td colspan="5" class="text-center py-4"><%: L.T("Student.MyTasks.NoTasksHaveBeenAssignedTo2") %></td></tr></asp:PlaceHolder>
                </tbody>
            </table></div>
            <asp:Panel ID="pnlNoTasks" runat="server" CssClass="student-empty-selection" Visible="false"><%: L.T("Student.MyTasks.YourSupervisorSTasksWillAppear") %></asp:Panel>
        </section>
        <asp:HiddenField ID="hfTaskDialogOpen" runat="server" ClientIDMode="Static" Value="0" />
        <asp:HiddenField ID="hfTaskSubmitSucceeded" runat="server" ClientIDMode="Static" Value="0" />
        <div id="studentTaskDialog" class="student-task-dialog" aria-hidden="true">
          <button type="button" class="student-task-dialog-backdrop" data-close-task-dialog aria-label="Close task details"></button>
          <section class="student-submit-card" role="dialog" aria-modal="true" aria-labelledby="submitTaskHeading" tabindex="-1">
            <button type="button" class="student-dialog-close" data-close-task-dialog aria-label="Close">&times;</button>
            <asp:Panel ID="pnlSelectTask" runat="server" CssClass="student-empty-selection" Visible="true"><strong><%: L.T("Student.MyTasks.ChooseATask") %></strong><%: L.T("Student.MyTasks.SelectOneOfYourAssignedTasks") %></asp:Panel>
            <asp:Panel ID="pnlSelectedTask" runat="server" Visible="false">
                <div class="student-card-heading"><h3 id="submitTaskHeading"><%: L.T("Student.MyTasks.TaskDetailsAndSubmission") %></h3><p><%: L.T("Student.MyTasks.SubmitYourWorkHereEachResubmission") %></p></div>
                <div class="student-submit-body">
                    <div class="student-selected-meta"><div><h4><asp:Literal ID="litTaskTitle" runat="server" Mode="Encode" /></h4><p><%: L.T("Student.MyTasks.Deadline2") %> <asp:Literal ID="litDeadline" runat="server" Mode="Encode" /></p></div><span class="student-status"><asp:Literal ID="litStatus" runat="server" Mode="Encode" /></span></div>
                    <div class="student-detail-block"><h5><%: L.T("Student.MyTasks.Description") %></h5><p><asp:Literal ID="litDescription" runat="server" Mode="Encode" /></p></div>
                    <div class="student-detail-block"><h5><%: L.T("Student.MyTasks.Instructions") %></h5><p><asp:Literal ID="litInstructions" runat="server" Mode="Encode" /></p><asp:HyperLink ID="lnkTaskAttachment" runat="server" CssClass="student-attachment-link" Target="_blank" Visible="false" /></div>
                    <asp:Panel ID="pnlSubmissionForm" runat="server" CssClass="student-submit-form">
                        <h4><%: L.T("Student.MyTasks.SubmitOrResubmitWork") %></h4><p class="text-muted small mb-3"><%: L.T("Student.MyTasks.AddANoteALinkOr") %></p>
                        <div class="mb-3"><asp:Label ID="lblSubmissionText" runat="server" AssociatedControlID="txtSubmissionText" CssClass="form-label" Text="<%$ Resources:Student, MyTasks.DescriptionOrNoteOptional %>" /><asp:TextBox ID="txtSubmissionText" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" MaxLength="2000" /></div>
                        <div class="mb-3"><asp:Label ID="lblSubmissionLink" runat="server" AssociatedControlID="txtSubmissionLink" CssClass="form-label" Text="<%$ Resources:Student, MyTasks.LinkOptional %>" /><asp:TextBox ID="txtSubmissionLink" runat="server" CssClass="form-control" TextMode="Url" MaxLength="2000" /><div class="student-file-help"><%: L.T("Student.MyTasks.UseAFullLinkBeginningWith") %></div></div>
                        <div class="mb-2"><asp:Label ID="lblSubmissionFile" runat="server" AssociatedControlID="fuSubmission" CssClass="form-label" Text="<%$ Resources:Student, MyTasks.AttachmentOptional %>" /><asp:FileUpload ID="fuSubmission" runat="server" CssClass="form-control" /><div class="student-file-help"><%: L.T("Student.MyTasks.PDFWordZIPOrImageFile") %></div></div>
                        <asp:Label ID="lblSubmitMessage" runat="server" Visible="false" EnableViewState="false" />
                        <asp:Button ID="btnSubmitTask" runat="server" Text="<%$ Resources:Student, MyTasks.SubmitTask2 %>" CssClass="btn btn-brand student-submit-button" OnClick="btnSubmitTask_Click" />
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
        <div id="studentSubmitSuccess" class="student-success-dialog" aria-hidden="true">
          <button type="button" class="student-success-backdrop" data-close-submit-success aria-label="Close confirmation"></button>
          <section class="student-success-card" role="alertdialog" aria-modal="true" aria-labelledby="studentSubmitSuccessTitle" tabindex="-1">
            <span class="student-success-check" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="m5 12.5 4.5 4.5L19 7"/></svg></span>
            <h3 id="studentSubmitSuccessTitle"><%: L.T("Student.MyTasks.SubmissionSavedSuccessfully") %></h3>
            <p><%: L.T("Student.MyTasks.YourTaskWasSubmittedSuccessfully") %></p>
            <button type="button" class="student-success-close" data-close-submit-success><%: L.T("Student.MyTasks.Close") %></button>
          </section>
        </div>
    </div>
</div>
<script>
(function(){
    var dialog=document.getElementById('studentTaskDialog');
    var state=document.getElementById('hfTaskDialogOpen');
    var successState=document.getElementById('hfTaskSubmitSucceeded');
    var successDialog=document.getElementById('studentSubmitSuccess');
    if(!dialog||!state||!successState||!successDialog)return;
    function closeDialog(){dialog.classList.remove('is-open');dialog.setAttribute('aria-hidden','true');document.body.classList.remove('student-dialog-active');state.value='0';}
    function openDialog(){dialog.classList.add('is-open');dialog.setAttribute('aria-hidden','false');document.body.classList.add('student-dialog-active');var panel=dialog.querySelector('[role="dialog"]');if(panel)panel.focus();}
    function openSuccess(){closeDialog();successDialog.classList.add('is-open');successDialog.setAttribute('aria-hidden','false');document.body.classList.add('student-dialog-active');var card=successDialog.querySelector('[role="alertdialog"]');if(card)card.focus();}
    function closeSuccess(){successDialog.classList.remove('is-open');successDialog.setAttribute('aria-hidden','true');document.body.classList.remove('student-dialog-active');successState.value='0';}
    document.addEventListener('click',function(e){if(e.target.closest('.student-select-button'))state.value='1';},true);
    dialog.addEventListener('click',function(e){if(e.target.closest('[data-close-task-dialog]'))closeDialog();});
    successDialog.addEventListener('click',function(e){if(e.target.closest('[data-close-submit-success]'))closeSuccess();});
    document.addEventListener('keydown',function(e){if(e.key==='Escape'){if(successDialog.classList.contains('is-open'))closeSuccess();else if(dialog.classList.contains('is-open'))closeDialog();}});
    if(successState.value==='1')openSuccess();else if(state.value==='1')openDialog();
})();
</script>
</asp:Content>
