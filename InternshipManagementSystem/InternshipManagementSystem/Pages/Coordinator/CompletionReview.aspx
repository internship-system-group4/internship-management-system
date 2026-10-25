<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="CompletionReview.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.CompletionReview" Title="Final Completion Review" %>
<%@ Import Namespace="InternshipManagementSystem.Services" %>
<%@ Import Namespace="InternshipManagementSystem.Data" %>
<%@ Register Src="~/Layout/FinalEvaluations.ascx" TagPrefix="uims" TagName="FinalEvaluations" %>
<%-- ===================================================================
     Final Completion Review  -  Owner: Ahmad  -  Cards A10 - A14
     Queue (no ?id) and the review of one internship (?id={placementId}).
     The review shows only what the decision needs: requirements, scores,
     internship type and the decision. Full history, task evidence and the
     evaluation comments live on the progress page (PlacementDetails.aspx).
     Final evaluations shown here are confidential: coordinator only.
     =================================================================== --%>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <script>document.documentElement.classList.add('rv-js');setTimeout(function(){if(!window.UimsReview)document.documentElement.classList.remove('rv-js');},2500);</script>
    <link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/review-system.css?v=20261024-theme-7") %>" />
    <link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/completion-review.css?v=20261024-theme-7") %>" />
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="rv-scope cr-page students-page dir-page">

<% if (!IsDetail) { %>
    <%-- ================= Queue =================
         Summary tiles are also the filters. One clean row per internship:
         student, company, the two final evaluations, training, status, action. --%>
    <header class="dir-head">
        <div>
            <div class="dir-crumb"><%: L.T("Coordinator.CompletionReview.Crumb") %></div>
            <h2><%: L.T("Coordinator.CompletionReview.FinalCompletionReview") %></h2>
            <p><%: L.T("Coordinator.Queue.Intro") %></p>
        </div>
        <% if (LoadError == null && Queue != null && Queue.Count > 0) { %>
        <a class="btn dir-ghost" href="CompletionReview.aspx?export=xlsx" download data-ui-action="export"><span data-ui-icon="download" aria-hidden="true"></span> <%: L.T("Coordinator.Export.Button") %></a>
        <% } %>
    </header>
    <% if (Message != null) { %><div class="alert alert-danger" role="alert"><%: Message %></div><% } %>

    <% if (LoadError != null) { %>
        <div class="alert alert-danger d-flex flex-wrap align-items-center gap-2" role="alert"><%: LoadError %> <a class="dir-btn" href="CompletionReview.aspx"><%: L.T("Coordinator.CompletionReview.Retry") %></a></div>
    <% } else { %>
    <div data-cr-queue>
    <div class="crq-tiles" role="group" aria-label="<%: L.T("Coordinator.Review.FilterLabel") %>">
        <button type="button" class="crq-tile" aria-pressed="true" data-cr-filter="all"><span class="dir-stat-icon" data-ui-icon="people" aria-hidden="true"></span><span class="crq-tile-text"><strong><%: Queue.Count %></strong><span><%: L.T("Coordinator.Queue.All") %></span></span></button>
        <% foreach (var tile in QueueTiles) { %>
        <button type="button" class="crq-tile <%: tile.Css %>" aria-pressed="false" data-cr-filter="<%: tile.Status %>"><span class="dir-stat-icon <%: tile.IconCss %>" data-ui-icon="<%: tile.Icon %>" aria-hidden="true"></span><span class="crq-tile-text"><strong><%: tile.Count %></strong><span><%: ReviewLabel(tile.Status) %></span></span></button>
        <% } %>
    </div>

    <section class="dir-card crq-card" aria-labelledby="crQueueTitle">
        <div class="dir-toolbar">
            <div class="dir-title"><h3 id="crQueueTitle"><%: L.T("Coordinator.Review.QueueTitle") %> <span class="dir-count" data-cr-visible><%: Queue.Count %></span></h3><p><%: L.T("Coordinator.Queue.Help") %></p></div>
            <% if (Queue.Count > 0) { %>
            <div class="dir-filters">
                <label class="dir-search"><span class="visually-hidden"><%: L.T("Coordinator.Review.SearchLabel") %></span><span data-ui-icon="search" aria-hidden="true"></span><input id="crSearch" type="search" class="form-control" autocomplete="off" placeholder="<%: L.T("Coordinator.Queue.Search") %>" data-cr-search /></label>
            </div>
            <% } %>
        </div>
        <% if (Queue.Count == 0) { %>
            <p class="dir-empty"><span data-ui-icon="approved" aria-hidden="true"></span><%: L.T("Coordinator.CompletionReview.NoConfirmedPlacementsYet") %></p>
        <% } else { %>
        <p class="visually-hidden" role="status" aria-live="polite" data-cr-announce></p>
        <ul class="crq-list">
        <% int i = 0; foreach (var row in Queue) { var student = row.Overview.Student; bool actionable = row.ReviewStatus == CompletionQueueRow.ReviewReady || row.ReviewStatus == CompletionQueueRow.ReviewCorrections; bool intl = InternshipTypes.Of(row.Overview.Placement) == InternshipTypes.International; %>
            <li class="crq-row <%: actionable ? "is-actionable" : "" %>" data-cr-row data-status="<%: row.ReviewStatus %>" data-search="<%: SearchText(row) %>" style="--dir-i:<%: i++ %>">
                <div class="crq-who">
                    <span class="dir-avatar" aria-hidden="true"><%: Initials(row.Overview.StudentName) %></span>
                    <div><strong><%: row.Overview.StudentName %></strong><span><%: Text(row.Overview.Placement.CompanyName) %> · <%: ProgramName(student) %></span></div>
                </div>
                <div class="crq-evals" aria-label="<%: L.T("Coordinator.Final.SectionTitle") %>">
                    <span class="crq-eval <%: row.CompanySubmitted ? "is-in" : "" %>"><span data-ui-icon="<%: row.CompanySubmitted ? "approved" : "clock" %>" aria-hidden="true"></span><%: L.T("Coordinator.Queue.Company") %></span>
                    <span class="crq-eval <%: row.AcademicSubmitted ? "is-in" : "" %>"><span data-ui-icon="<%: row.AcademicSubmitted ? "approved" : "clock" %>" aria-hidden="true"></span><%: L.T("Coordinator.Queue.Academic") %></span>
                </div>
                <div class="crq-hours">
                    <% if (intl) { %><span class="dir-num"><%: L.F("Coordinator.Review.WeeksValue", InternshipRules.Weeks(row.Overview.Placement).ToString("0.#")) %></span>
                    <% } else { %><div class="dir-progress" aria-hidden="true"><span style="--dir-p:<%: row.Overview.HoursPercent %>%"></span></div><span class="dir-num"><%: row.Overview.HoursText %></span><% } %>
                </div>
                <div class="crq-status"><span class="<%: QueuePill(row.ReviewStatus) %>"><%: ReviewLabel(row.ReviewStatus) %></span></div>
                <div class="crq-action"><a class="<%: actionable ? "btn btn-brand" : "dir-btn" %>" href="CompletionReview.aspx?id=<%: Server.UrlEncode(row.Overview.Placement.Id) %>"><%: actionable ? L.T("Coordinator.Review.Review") : L.T("Coordinator.Review.Open") %><span class="visually-hidden">: <%: row.Overview.StudentName %></span> <span data-ui-icon="next" aria-hidden="true"></span></a></div>
            </li>
        <% } %>
        </ul>
        <p class="dir-empty" data-cr-nomatch hidden><span data-ui-icon="search" aria-hidden="true"></span><%: L.T("Coordinator.Review.NoMatch") %></p>
        <% } %>
    </section>
    </div>
    <% } %>

<% } else { %>
    <%-- ================= Review of one internship =================
         Order: who (slim header) -> the two final evaluations -> coordinator checks.
         The decision card on the side shows the result, what is still missing and the buttons. --%>
    <a class="dir-back" href="CompletionReview.aspx"><span data-ui-icon="back" aria-hidden="true"></span> <%: L.T("Coordinator.Review.BackToQueue") %></a>

    <% if (LoadError != null) { %>
        <div class="alert alert-danger" role="alert"><%: LoadError %></div>
    <% } else {
           var overview = Progress.Overview; var placement = overview.Placement; var student = overview.Student; var record = Record;
           string courseCode = CourseCode(student, Summary.InternshipType); %>

    <section class="cx-head" aria-labelledby="crStudentName">
        <span class="dir-avatar" aria-hidden="true"><%: Initials(overview.StudentName) %></span>
        <div class="cx-head-text">
            <div class="cx-head-title"><h2 id="crStudentName"><%: overview.StudentName %></h2><span class="<%: ReviewCss(DetailStatus) %>"><%: ReviewLabel(DetailStatus) %></span></div>
            <div class="cx-head-meta"><span class="dir-num"><%: overview.StudentNumber %></span><span><%: ProgramName(student) %><% if (courseCode != null) { %> (<%: courseCode %>)<% } %></span><span><%: Text(placement.CompanyName) %></span></div>
        </div>
        <div class="cx-head-actions">
            <% if (!string.IsNullOrEmpty(placement.StudentId)) { %><a class="dir-btn" href="Students.aspx?id=<%: Server.UrlEncode(placement.StudentId) %>"><span data-ui-icon="person" aria-hidden="true"></span> <%: L.T("Coordinator.ManageStudents.ViewProfile") %></a><% } %>
            <a class="dir-btn dir-btn-primary" href="PlacementDetails.aspx?id=<%: Server.UrlEncode(placement.Id) %>"><span data-ui-icon="chart" aria-hidden="true"></span> <%: L.T("Coordinator.CompletionReview.FullProgressHistory") %></a>
        </div>
    </section>

    <% if (ProgramNeedsCheck(student)) { %><div class="alert alert-warning" role="note"><%: L.T("Coordinator.Review.ProgramCheckLong") %></div><% } %>
    <% if (Message != null) { %><div class="alert <%: MessageIsError ? "alert-danger" : "alert-success" %>" role="<%: MessageIsError ? "alert" : "status" %>"><%: Message %></div><% } %>

    <%-- 1. The two final evaluations, received first. --%>
    <div class="cx-section-title">
        <h3><span class="dir-stat-icon" data-ui-icon="document" aria-hidden="true"></span><%: L.T("Coordinator.Final.SectionTitle") %></h3>
        <span class="cx-section-note"><%: L.F("Coordinator.Final.SectionCount", (Summary.CompanySubmitted ? 1 : 0) + (Summary.AcademicSubmitted ? 1 : 0)) %></span>
    </div>
    <uims:FinalEvaluations ID="ucFinal" runat="server" ShowWeights="true" />

    <div class="crx-layout">
    <div class="crx-main">


        <%-- 2. What the coordinator verifies by hand (documents and rules). --%>
        <details class="crx-checks" <%= ManualMet < ManualTotal && IsEditable ? "open" : "" %>>
            <summary>
                <h3><span class="dir-stat-icon" data-ui-icon="approved" aria-hidden="true"></span><%: L.T("Coordinator.Review.ManualTitle") %></h3>
                <span class="<%: ManualMet >= ManualTotal ? "dir-status is-active" : "dir-status is-warning" %>"><%: L.F("Coordinator.Review.ChecksVerified", ManualMet, ManualTotal) %></span>
                <span class="crx-caret" aria-hidden="true"></span>
            </summary>
            <p class="crx-checks-note"><%: L.T("Coordinator.Review.ManualNote") %></p>
            <% if (!IsEditable) { %>
            <ol class="crx-check-list">
            <% foreach (var item in Summary.Items.Where(i => i.Manual)) { %>
                <li class="crx-check <%: item.Satisfied ? "is-ok" : "is-attention" %>">
                    <span class="crx-mark" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="m5 12.5 4.2 4.2L19 7"/></svg></span>
                    <div><span class="crx-check-title"><%: item.Title %></span><% if (CheckedBy(item).Length > 0) { %><span class="crx-check-by"><%: CheckedBy(item) %></span><% } %></div>
                    <div class="crx-check-read"><span class="<%: StateCss(item.State) %>"><%: StateLabel(item.State) %></span><span><%: Text(item.Check == null ? null : item.Check.Evidence) %></span></div>
                </li>
            <% } %>
            </ol>
            <% } %>
            <asp:Panel ID="pnlChecks" runat="server">
                <asp:Repeater ID="rptChecks" runat="server" OnItemDataBound="Checks_ItemDataBound">
                    <HeaderTemplate><ol class="crx-check-list"></HeaderTemplate>
                    <ItemTemplate>
                        <li class='crx-check <%# ((RequirementItem)Container.DataItem).Satisfied ? "is-ok" : ((RequirementItem)Container.DataItem).State == "NeedsCorrections" ? "is-attention" : "" %>'>
                            <span class="crx-mark" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="m5 12.5 4.2 4.2L19 7"/></svg></span>
                            <div>
                                <span class="crx-check-title"><%#: ((RequirementItem)Container.DataItem).Title %></span>
                                <span class="crx-check-hint"><%#: ((RequirementItem)Container.DataItem).Hint %></span>
                                <span class="crx-check-by"><%#: CheckedBy((RequirementItem)Container.DataItem) %></span>
                            </div>
                            <div class="crx-check-status">
                                <asp:HiddenField ID="hidKey" runat="server" />
                                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-select">
                                    <asp:ListItem Value="Pending" Text="<%$ Resources:Coordinator, Review.StatePending %>" />
                                    <asp:ListItem Value="Verified" Text="<%$ Resources:Coordinator, Review.StateVerified %>" />
                                    <asp:ListItem Value="NeedsCorrections" Text="<%$ Resources:Coordinator, Review.StateCorrections %>" />
                                    <asp:ListItem Value="NotApplicable" Text="<%$ Resources:Coordinator, Review.StateNotApplicable %>" />
                                </asp:DropDownList>
                            </div>
                            <div class="crx-check-evidence"><asp:TextBox ID="txtEvidence" runat="server" CssClass="form-control" MaxLength="300" placeholder="<%$ Resources:Coordinator, Review.EvidencePlaceholder %>" /></div>
                        </li>
                    </ItemTemplate>
                    <FooterTemplate></ol></FooterTemplate>
                </asp:Repeater>
                <div class="crx-checks-foot">
                    <asp:Button ID="btnSaveChecks" runat="server" CssClass="btn btn-brand" Text="<%$ Resources:Coordinator, Review.SaveChecks %>" OnClick="SaveChecks_Click" data-ui-action="save" data-ui-validation="none" />
                    <span class="cx-section-note"><%: L.T("Coordinator.Review.SaveChecksNote") %></span>
                </div>
            </asp:Panel>
        </details>

    </div><%-- /crx-main --%>

    <aside class="crx-aside">
        <%-- 3. The decision: result, what is still missing, the buttons. --%>
        <section class="crx-card crx-decision" id="crDecision" aria-labelledby="crDecisionTitle">
            <div class="cx-section-title"><h3 id="crDecisionTitle"><span class="dir-stat-icon" data-ui-icon="approved" aria-hidden="true"></span><%: IsApproved ? L.T("Coordinator.Review.DocumentsTitle") : L.T("Coordinator.Review.DecisionTitle") %></h3></div>

            <div class="crx-result <%: !Summary.EvaluationsReady ? "" : Summary.Passing ? "is-pass" : "is-fail" %>">
                <div><span class="crx-result-label"><%: L.T("Coordinator.Review.ProvisionalScore") %></span><strong><%: Summary.EvaluationsReady ? Percent(Summary.FinalPercent) : "—" %></strong></div>
                <span class="<%: !Summary.EvaluationsReady ? "dir-status is-neutral is-lg" : Summary.Passing ? "dir-status is-active is-lg" : "dir-status is-inactive is-lg" %>"><%: Summary.EvaluationsReady ? (Summary.Passing ? L.T("Coordinator.Review.Pass") : L.T("Coordinator.Review.Fail")) : L.T("Coordinator.Review.Pending") %></span>
            </div>
            <ul class="crx-parts" aria-label="<%: L.T("Coordinator.Review.ResultTitle") %>">
                <li><span><%: L.F("Coordinator.Review.PartTasks", GradingPolicy.TaskComponentWeight) %></span><b><%: Weighted(Summary.TaskPercent, GradingPolicy.TaskComponentWeight) %> <%: L.T("Coordinator.Review.Points") %></b></li>
                <li><span><%: L.F("Coordinator.Review.PartCompany", GradingPolicy.CompanyFinalWeight) %></span><b><%: Weighted(Summary.CompanyPercent, GradingPolicy.CompanyFinalWeight) %> <%: L.T("Coordinator.Review.Points") %></b></li>
                <li><span><%: L.F("Coordinator.Review.PartAcademic", GradingPolicy.AcademicFinalWeight) %></span><b><%: Weighted(Summary.AcademicPercent, GradingPolicy.AcademicFinalWeight) %> <%: L.T("Coordinator.Review.Points") %></b></li>
            </ul>

            <ul class="crx-ready" aria-label="<%: L.T("Coordinator.Review.ReadyTitle") %>">
                <li class="<%: Summary.CompanySubmitted ? "is-ok" : "is-missing" %>"><span class="crx-mark" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="m5 12.5 4.2 4.2L19 7"/></svg></span><span><%: L.T("Coordinator.CompletionReview.CompanyFinalEvaluation") %></span><b><%: Summary.CompanySubmitted ? L.T("Coordinator.Review.Submitted") : L.T("Coordinator.Review.MissingShort") %></b></li>
                <li class="<%: Summary.AcademicSubmitted ? "is-ok" : "is-missing" %>"><span class="crx-mark" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="m5 12.5 4.2 4.2L19 7"/></svg></span><span><%: L.T("Coordinator.CompletionReview.AcademicFinalEvaluation") %></span><b><%: Summary.AcademicSubmitted ? L.T("Coordinator.Review.Submitted") : L.T("Coordinator.Review.MissingShort") %></b></li>
                <li class="<%: Summary.TrainingRequirementMet ? "is-ok" : "is-missing" %>"><span class="crx-mark" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="m5 12.5 4.2 4.2L19 7"/></svg></span><span><%: L.T("Coordinator.Review.TrainingTitle") %></span><b><% if (Summary.IsInternational) { %><%: Summary.Weeks.ToString("0.#") %> / <%: InternshipRules.InternationalMinimumWeeks %> <%: L.T("Coordinator.Review.Weeks") %><% } else { %><%: Summary.ApprovedHours %> / <%: Summary.RequiredHours %> <%: L.T("Workspace.UnitH") %><% } %></b></li>
                <li class="<%: Summary.TasksComplete ? "is-ok" : "is-missing" %>"><span class="crx-mark" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="m5 12.5 4.2 4.2L19 7"/></svg></span><span><%: L.T("Coordinator.CompletionReview.TasksGraded") %></span><b><%: Summary.TasksGraded %> / <%: Summary.TasksTotal %></b></li>
                <li class="<%: ManualMet >= ManualTotal ? "is-ok" : "is-missing" %>"><span class="crx-mark" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="m5 12.5 4.2 4.2L19 7"/></svg></span><span><%: L.T("Coordinator.Review.ManualTitle") %></span><b><%: ManualMet %> / <%: ManualTotal %></b></li>
            </ul>

        <% if (IsApproved) { %>
            <p class="crx-hint is-ready"><strong><%: L.T("Coordinator.Review.ApprovedHeadline") %></strong><br /><%: L.F("Coordinator.Review.ApprovedLine", Text(record.CoordinatorName ?? CoordinatorName(record.ReviewedByCoordinatorId)), InternshipManagementSystem.Common.Time.Friendly(record.ApprovedAt)) %><br /><span class="dir-num"><%: L.T("Coordinator.Review.Reference") %>: <%: PdfReportService.Reference(record) %></span></p>
            <% if (!string.IsNullOrWhiteSpace(record.CoordinatorNote)) { %><p class="cx-section-note"><%: L.T("Coordinator.CompletionReview.NoteOnTheReport") %> <%: record.CoordinatorNote %></p><% } %>
            <div class="crx-docs" data-cr-docs>
                <div class="crx-doc">
                    <div><strong><%: L.T("Coordinator.Review.ReportDoc") %></strong></div>
                    <a class="btn btn-brand btn-sm" href="<%: ResolveUrl(PdfReportService.DownloadUrl(PdfReportService.ReportUrl(record.Id))) %>"><%: L.T("Coordinator.Review.DownloadPdf") %></a>
                    <a class="btn btn-outline-secondary btn-sm" href="<%: ResolveUrl(PdfReportService.ReportUrl(record.Id)) %>" target="_blank" rel="noopener" data-rv-print><%: L.T("Coordinator.Review.Print") %></a>
                </div>
                <div class="crx-doc">
                    <div><strong><%: L.T("Coordinator.Review.CertificateDoc") %></strong></div>
                    <a class="btn btn-brand btn-sm" href="<%: ResolveUrl(PdfReportService.DownloadUrl(PdfReportService.CertificateUrl(record.Id))) %>"><%: L.T("Coordinator.Review.DownloadPdf") %></a>
                    <a class="btn btn-outline-secondary btn-sm" href="<%: ResolveUrl(PdfReportService.CertificateUrl(record.Id)) %>" target="_blank" rel="noopener" data-rv-print><%: L.T("Coordinator.Review.Print") %></a>
                </div>
            </div>
        <% } else if (IsRejectedFinal) { %>
            <p class="crx-hint"><strong><%: L.T("Coordinator.Review.RejectedHeadline") %></strong><br /><%: L.T("Coordinator.Review.Reason") %>: <%: Text(record.CoordinatorNote) %></p>
            <p class="cx-section-note"><%: L.T("Coordinator.Review.ReadOnlyNote") %></p>
        <% } else { %>
            <% if (record != null && record.NeedsCorrections) { %><p class="crx-hint"><strong><%: L.T("Coordinator.Review.CorrectionsHeadline") %></strong><br /><%: Text(record.CoordinatorNote) %></p><% } %>
            <p class="crx-hint <%: Summary.CanApprove ? "is-ready" : "" %>"><%: Summary.CanApprove ? L.T("Coordinator.Review.ReadyToApprove") : L.T("Coordinator.Review.NotReadyToApprove") %></p>
        <% } %>
            <asp:Panel ID="pnlDecision" runat="server" CssClass="crx-decision-form">
                <label for="<%= txtNote.ClientID %>"><%: L.T("Coordinator.Review.DecisionNote") %></label>
                <asp:TextBox ID="txtNote" runat="server" TextMode="MultiLine" Rows="3" MaxLength="1000" CssClass="form-control"
                    placeholder="<%$ Resources:Coordinator, Review.DecisionNotePlaceholder %>" />
                <span class="crx-small"><%: L.T("Coordinator.Review.DecisionNoteHelp") %></span>
                <div class="crx-buttons">
                    <asp:Button ID="btnApprove" runat="server" Text="<%$ Resources:Coordinator, Review.Approve %>" CssClass="btn btn-brand crx-approve" OnClick="Approve_Click" data-ui-action="approve" data-ui-validation="none" />
                    <asp:Button ID="btnReturn" runat="server" Text="<%$ Resources:Coordinator, Review.ReturnForCorrections %>" CssClass="btn btn-outline-warning" OnClick="Return_Click" data-ui-action="return" data-ui-validation="none" />
                    <asp:Button ID="btnReject" runat="server" Text="<%$ Resources:Coordinator, Review.RejectCompletion %>" CssClass="btn btn-outline-danger" OnClick="Reject_Click" data-ui-action="reject" data-ui-validation="none" />
                </div>
            </asp:Panel>
        </section>

        <%-- Internship type: decides which rules apply. --%>
        <section class="crx-card" aria-labelledby="crTypeTitle">
            <div class="cx-section-title"><h3 id="crTypeTitle"><span class="dir-stat-icon" data-ui-icon="building" aria-hidden="true"></span><%: L.T("Coordinator.Review.Type") %>: <%: TypeLabel(Summary.InternshipType) %></h3></div>
            <p class="cx-section-note"><%: Summary.InternshipTypeIsDefault ? L.T("Coordinator.Review.TypeDefaultLong") : L.T("Coordinator.Review.TypeHelp") %></p>
            <asp:Panel ID="pnlType" runat="server" CssClass="crx-type">
                <label for="<%= ddlType.ClientID %>" class="visually-hidden"><%: L.T("Coordinator.Review.ChangeType") %></label>
                <asp:DropDownList ID="ddlType" runat="server" CssClass="form-select">
                    <asp:ListItem Value="Local" Text="<%$ Resources:Coordinator, Review.TypeLocal %>" />
                    <asp:ListItem Value="International" Text="<%$ Resources:Coordinator, Review.TypeInternational %>" />
                </asp:DropDownList>
                <asp:Button ID="btnSaveType" runat="server" CssClass="btn btn-outline-secondary" Text="<%$ Resources:Coordinator, Review.SaveType %>" OnClick="SaveType_Click" data-ui-action="save" data-ui-validation="none" />
            </asp:Panel>
        </section>
    </aside>
    </div><%-- /crx-layout --%>

    <% if (PlayStamp) { %>
    <%-- Plays once, only after the server saved the approval (one-time session flag). --%>
    <div class="cr-stamp-stage" role="dialog" aria-modal="true" aria-labelledby="crStampTitle" aria-describedby="crStampText" data-cr-stamp>
        <div class="cr-stamp-sheet">
            <div class="cr-sheet-head" aria-hidden="true"><span></span><span></span></div>
            <div class="cr-sheet-lines" aria-hidden="true"><i></i><i></i><i></i><i></i><i></i></div>
            <div class="cr-stamp-impact" aria-hidden="true"></div>
            <div class="cr-stamp" aria-hidden="true">
                <svg viewBox="0 0 200 200"><defs>
                    <filter id="crInk" x="-10%" y="-10%" width="120%" height="120%"><feTurbulence type="fractalNoise" baseFrequency="0.85" numOctaves="2" seed="7" result="noise"/><feDisplacementMap in="SourceGraphic" in2="noise" scale="2.2"/></filter>
                    <path id="crStampRing" d="M100,100 m-72,0 a72,72 0 1,1 144,0 a72,72 0 1,1 -144,0"/></defs>
                    <g filter="url(#crInk)">
                        <circle cx="100" cy="100" r="92" class="cr-seal-outer"/><circle cx="100" cy="100" r="82" class="cr-seal-inner"/>
                        <text class="cr-seal-ring"><textPath href="#crStampRing" startOffset="0" textLength="440" lengthAdjust="spacing">UIMS &#183; INTERNSHIP COMPLETION VERIFIED &#183; UIMS &#183;</textPath></text>
                        <line x1="44" y1="86" x2="156" y2="86"/><line x1="44" y1="118" x2="156" y2="118"/>
                        <text x="100" y="109" class="cr-seal-word" text-anchor="middle">APPROVED</text>
                    </g>
                </svg>
            </div>
            <h2 id="crStampTitle"><%: L.T("Coordinator.Review.StampTitle") %></h2>
            <p id="crStampText"><%: overview.StudentName %> &middot; <span class="rv-num"><%: PdfReportService.Reference(record) %></span> &middot; <%: Time.Display(record.ApprovedAt) %></p>
            <button type="button" class="btn btn-brand" data-cr-stamp-close><%: L.T("Coordinator.Review.StampContinue") %></button>
        </div>
    </div>
    <% } %>
    <% } %>
<% } %>
</div>
</asp:Content>

<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server">
    <script src="<%: ResolveUrl("~/Assets/js/review-system.js?v=20261023-rv6") %>"></script>
    <script src="<%: ResolveUrl("~/Assets/js/completion-review.js?v=20261023-rv6") %>"></script>
</asp:Content>
