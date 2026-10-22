<%@ Page Language="C#" MasterPageFile="~/Layout/Company.master" AutoEventWireup="true" CodeBehind="FinalEvaluation.aspx.cs" Inherits="InternshipManagementSystem.Pages.CompanyArea.FinalEvaluation" Title="Reports & Final Evaluation" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <style>
        .fe-stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(160px, 1fr)); gap: 1rem; margin-bottom: 1.5rem; }
        .fe-stat { background: var(--surface); border: 1px solid var(--line); border-radius: var(--radius); padding: 1rem 1.25rem; box-shadow: var(--shadow); }
        .fe-stat small { display: block; color: var(--muted); font-size: .8rem; font-weight: 600; text-transform: uppercase; letter-spacing: .03em; }
        .fe-stat strong { display: block; font-size: 1.75rem; color: var(--brand-dark); line-height: 1.3; }
        .fe-muted { color: var(--muted); font-size: .85rem; }
        .fe-bar { height: 6px; background: var(--line); border-radius: 3px; overflow: hidden; min-width: 80px; }
        .fe-bar span { display: block; height: 100%; background: var(--brand); }
        .fe-notice { border-left: 4px solid var(--accent); background: #fbf6ea; padding: .75rem 1rem; border-radius: 6px; margin-bottom: 1.5rem; font-size: .9rem; }
        .fe-back { color: var(--muted); text-decoration: none; font-weight: 600; font-size: .9rem; }
        .fe-back:hover { color: var(--brand); }
        .fe-head { display: flex; flex-wrap: wrap; justify-content: space-between; gap: 1rem; align-items: flex-start; }
        .fe-head h2 { font-size: 1.4rem; margin: 0 0 .25rem; color: var(--brand-dark); }
        .fe-facts { display: grid; grid-template-columns: repeat(auto-fit, minmax(170px, 1fr)); gap: 1rem; margin-top: 1rem; }
        .fe-facts small { display: block; color: var(--muted); font-size: .75rem; font-weight: 600; text-transform: uppercase; }
        .fe-criterion { border: 1px solid var(--line); border-radius: var(--radius); padding: 1rem; margin-bottom: .75rem; }
        .fe-criterion h4 { font-size: 1rem; margin: 0; color: var(--ink); }
        .fe-weight { font-size: .75rem; font-weight: 700; color: var(--brand); background: var(--brand-light); border-radius: 999px; padding: .15rem .6rem; white-space: nowrap; }
        .fe-score { background: var(--brand-light); border-radius: var(--radius); padding: 1rem 1.25rem; display: flex; flex-wrap: wrap; justify-content: space-between; align-items: center; gap: .5rem; margin: 1rem 0 1.5rem; }
        .fe-score strong { font-size: 1.75rem; color: var(--brand-dark); }
        .fe-scale { font-size: .8rem; color: var(--muted); margin-bottom: 1rem; }
        @media print {
            .uims-sidebar, .uims-topbar, .student-nav-backdrop, .no-print { display: none !important; }
            .uims-content, .uims-main, .uims-main-inner { margin: 0 !important; padding: 0 !important; }
            .uims-card, .fe-criterion { break-inside: avoid; box-shadow: none !important; }
            select, input, textarea { border: 0 !important; background: none !important; -webkit-appearance: none; appearance: none; }
        }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

    <%-- ===================================================================
         Reports & Final Evaluation   |   Cards N08, N09
         No ?id  : report of every trainee in the supervisor's company.
         ?id=... : the confidential final evaluation of one placement.
         CONFIDENTIAL: the student may never see this form.
         =================================================================== --%>

    <asp:Label ID="lblMessage" runat="server" EnableViewState="false" Visible="false" CssClass="d-block mb-3" role="status"></asp:Label>

    <%-- ============================ REPORTS LIST ============================ --%>
    <asp:Panel ID="pnlReports" runat="server">
        <p class="fe-muted mb-3">Training evidence and final evaluation status for every trainee placed at your company.</p>

        <div class="fe-stats">
            <div class="fe-stat"><small>Trainees</small><strong><asp:Literal ID="litTotal" runat="server">0</asp:Literal></strong></div>
            <div class="fe-stat"><small>Not started</small><strong><asp:Literal ID="litNotStarted" runat="server">0</asp:Literal></strong></div>
            <div class="fe-stat"><small>Drafts</small><strong><asp:Literal ID="litDrafts" runat="server">0</asp:Literal></strong></div>
            <div class="fe-stat"><small>Sent to university</small><strong><asp:Literal ID="litSent" runat="server">0</asp:Literal></strong></div>
        </div>

        <div class="uims-card">
            <h3>Trainee reports</h3>
            <div class="table-responsive">
                <asp:GridView ID="gvReports" runat="server" AutoGenerateColumns="False" GridLines="None"
                    CssClass="uims-table w-100" EmptyDataText="No trainees are placed at your company yet.">
                    <Columns>
                        <asp:TemplateField HeaderText="Trainee">
                            <ItemTemplate>
                                <strong><%#: Eval("StudentName") %></strong>
                                <div class="fe-muted"><%#: Eval("OpportunityTitle") %></div>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Approved hours">
                            <ItemTemplate>
                                <div><%# Eval("ApprovedHours") %> / <%# Eval("RequiredHours") %></div>
                                <div class="fe-bar"><span style='width: <%# Eval("HoursPercent") %>%'></span></div>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Tasks graded">
                            <ItemTemplate><%# Eval("GradedTasks") %> / <%# Eval("TotalTasks") %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Avg. task score">
                            <ItemTemplate><%#: Eval("TaskScoreText") %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Final evaluation">
                            <ItemTemplate>
                                <span class='<%# Eval("StatusCss") %>'><%#: Eval("StatusText") %></span>
                                <div class="fe-muted"><%#: Eval("ScoreText") %></div>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="">
                            <ItemTemplate>
                                <a class="btn btn-sm btn-brand" href='<%# "FinalEvaluation.aspx?id=" + HttpUtility.UrlEncode((string)Eval("PlacementId")) %>'><%#: Eval("ActionText") %></a>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </asp:Panel>

    <%-- ========================== ONE EVALUATION =========================== --%>
    <asp:Panel ID="pnlEvaluation" runat="server" Visible="false">
        <div class="d-flex justify-content-between align-items-center mb-3 no-print">
            <a href="FinalEvaluation.aspx" class="fe-back">&larr; All trainee reports</a>
            <button type="button" class="btn btn-outline-secondary btn-sm" onclick="window.print()">Print report</button>
        </div>

        <div class="fe-notice">
            <strong>Confidential.</strong> This evaluation is shared only with the student's academic supervisor and the internship coordinator. The student never sees this form, only the final result released by the coordinator.
        </div>

        <%-- Trainee summary --%>
        <div class="uims-card mb-4">
            <div class="fe-head">
                <div>
                    <h2><asp:Literal ID="litStudentName" runat="server" Mode="Encode" /></h2>
                    <div class="fe-muted"><asp:Literal ID="litOpportunity" runat="server" Mode="Encode" /> &middot; <asp:Literal ID="litCompany" runat="server" Mode="Encode" /></div>
                </div>
                <asp:Label ID="lblStatus" runat="server" CssClass="uims-pill uims-pill-pending">Not started</asp:Label>
            </div>
            <div class="fe-facts">
                <div><small>Training period</small><asp:Literal ID="litPeriod" runat="server" Mode="Encode" /></div>
                <div><small>Company supervisor</small><asp:Literal ID="litCompanySupervisor" runat="server" Mode="Encode" /></div>
                <div><small>Academic supervisor</small><asp:Literal ID="litAcademicSupervisor" runat="server" Mode="Encode" /></div>
                <div><small>Placement status</small><asp:Literal ID="litPlacementStatus" runat="server" Mode="Encode" /></div>
            </div>
        </div>

        <%-- Evidence: tasks and hours support the judgement, they do not set the score --%>
        <div class="uims-card mb-4">
            <h3>Training evidence</h3>
            <p class="fe-muted">Recorded work to support your ratings. These numbers do not set the evaluation score by themselves.</p>
            <div class="fe-stats mb-0">
                <div class="fe-stat"><small>Approved hours</small><strong><asp:Literal ID="litHours" runat="server" /></strong></div>
                <div class="fe-stat"><small>Tasks graded</small><strong><asp:Literal ID="litTasks" runat="server" /></strong></div>
                <div class="fe-stat"><small>Avg. task score</small><strong><asp:Literal ID="litTaskScore" runat="server" /></strong></div>
                <div class="fe-stat"><small>Overdue tasks</small><strong><asp:Literal ID="litOverdue" runat="server" /></strong></div>
                <div class="fe-stat"><small>Revisions requested</small><strong><asp:Literal ID="litRevisions" runat="server" /></strong></div>
            </div>
            <asp:Panel ID="pnlHoursWarning" runat="server" Visible="false" CssClass="alert alert-warning mt-3 mb-0">
                The student has not reached the required training hours yet. You can still save a draft and complete it at the end of the internship.
            </asp:Panel>
        </div>

        <%-- The evaluation form --%>
        <div class="uims-card mb-4">
            <h3>Final performance evaluation</h3>
            <p class="fe-scale">
                Rate each criterion from 1 to 5:
                1 Unsatisfactory &middot; 2 Needs Improvement &middot; 3 Meets Expectations &middot; 4 Exceeds Expectations &middot; 5 Outstanding.
                Weights are provisional university defaults (awaiting confirmation).
            </p>

            <asp:Repeater ID="rptCriteria" runat="server" OnItemDataBound="rptCriteria_ItemDataBound">
                <ItemTemplate>
                    <div class="fe-criterion">
                        <div class="d-flex justify-content-between align-items-start gap-2 mb-1">
                            <h4><%#: Eval("Name") %></h4>
                            <span class="fe-weight"><%# Eval("Weight") %>%</span>
                        </div>
                        <p class="fe-muted mb-2"><%#: Eval("Description") %></p>
                        <div class="row g-2">
                            <div class="col-md-4">
                                <asp:DropDownList ID="ddlRating" runat="server" CssClass="form-select fe-rating" />
                            </div>
                            <div class="col-md-8">
                                <asp:TextBox ID="txtComment" runat="server" CssClass="form-control" MaxLength="500" placeholder="Evidence or comment (optional)" />
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

            <div class="fe-score" aria-live="polite">
                <div>
                    <div class="fe-muted">Weighted performance score</div>
                    <strong><span id="feScore"><asp:Literal ID="litScore" runat="server">0.0</asp:Literal></span> / 100</strong>
                </div>
                <div class="fe-muted" id="feRated">Supports your judgement; it does not replace it.</div>
            </div>

            <div class="mb-3">
                <label class="form-label fw-semibold" for="<%= txtStrengths.ClientID %>">Strengths <span class="text-danger">*</span></label>
                <asp:TextBox ID="txtStrengths" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" MaxLength="2000" />
            </div>
            <div class="mb-3">
                <label class="form-label fw-semibold" for="<%= txtImprovements.ClientID %>">Areas for improvement <span class="text-danger">*</span></label>
                <asp:TextBox ID="txtImprovements" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" MaxLength="2000" />
            </div>
            <div class="mb-3">
                <label class="form-label fw-semibold" for="<%= txtOverall.ClientID %>">Overall comment and development recommendations</label>
                <asp:TextBox ID="txtOverall" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" MaxLength="2000" />
            </div>

            <asp:Panel ID="pnlActions" runat="server" CssClass="d-flex flex-wrap justify-content-end gap-2 border-top pt-3 no-print">
                <asp:Button ID="btnSaveDraft" runat="server" Text="Save draft" CssClass="btn btn-outline-secondary" OnClick="btnSaveDraft_Click" />
                <asp:Button ID="btnSubmit" runat="server" Text="Send to academic supervisor" CssClass="btn btn-brand" OnClick="btnSubmit_Click"
                    OnClientClick="return confirm('Send this evaluation to the academic supervisor? It cannot be changed after it is sent.');" />
            </asp:Panel>
            <asp:Panel ID="pnlSubmitted" runat="server" Visible="false" CssClass="alert alert-success mb-0 mt-3">
                <asp:Literal ID="litSubmitted" runat="server" Mode="Encode" />
            </asp:Panel>
        </div>
    </asp:Panel>

    <script>
        // Live preview of the weighted score: sum of (rating / 5) x weight.
        (function () {
            var selects = document.querySelectorAll('select.fe-rating');
            if (!selects.length) return;
            function update() {
                var total = 0, rated = 0;
                for (var i = 0; i < selects.length; i++) {
                    var rating = parseInt(selects[i].value, 10);
                    var weight = parseFloat(selects[i].getAttribute('data-weight')) || 0;
                    if (rating > 0) { total += (rating / 5) * weight; rated++; }
                }
                document.getElementById('feScore').textContent = total.toFixed(1);
                document.getElementById('feRated').textContent = rated + ' of ' + selects.length + ' criteria rated';
            }
            for (var i = 0; i < selects.length; i++) selects[i].addEventListener('change', update);
            update();
        })();
    </script>

</asp:Content>
