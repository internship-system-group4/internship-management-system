
<%@ Page Title="Manage Opportunities"
    Language="C#"
    MasterPageFile="~/Layout/Company.master"
    AutoEventWireup="true"
    CodeBehind="ManageOpportunities.aspx.cs"
    Inherits="InternshipManagementSystem.Pages.CompanyArea.ManageOpportunities" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">

<style>
.mo-page {
    max-width: 1200px;
    margin: 0 auto;
    color: var(--th-fg-173451, #173451);
}

.mo-heading {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 15px;
    margin-bottom: 18px;
}

.mo-heading h2 {
    font-size: 26px;
    font-weight: 750;
    margin: 0 0 5px;
}

.mo-muted {
    color: var(--ui-muted);
    font-size: 13px;
    line-height: 1.6;
}

.mo-heading .mo-muted {
    margin: 0;
}

.mo-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 7px;
    padding: 10px 17px;
    border: 1px solid var(--th-line-244f77, #244f77);
    background: var(--th-bg-244f77, #244f77);
    color: #fff;
    text-decoration: none;
    border-radius: 7px;
    font: inherit;
    font-size: 13px;
    font-weight: 700;
    cursor: pointer;
    white-space: nowrap;
    transition:
        background-color .2s ease,
        border-color .2s ease,
        box-shadow .2s ease,
        transform .2s ease;
}

.mo-btn:hover {
    filter: brightness(.95);
    color: #fff;
}

.mo-btn:focus-visible {
    outline: 2px solid #244f77;
    outline-offset: 3px;
}

.mo-btn-light {
    background: var(--ui-surface, #fff);
    color: var(--th-fg-244f77, #244f77);
}

.mo-btn-light:hover {
    color: var(--th-fg-244f77, #244f77);
}

.mo-btn-danger {
    background: #b42318;
    border-color: #b42318;
    color: #fff;
}

.mo-btn-success {
    background: #17603a;
    border-color: #17603a;
    color: #fff;
}

.mo-btn-success:hover {
    background: #124d2e;
    border-color: #124d2e;
}

.mo-small {
    padding: 7px 11px;
    font-size: 12px;
}

.mo-stats {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 14px;
    margin-bottom: 18px;
}

.mo-stat,
.mo-card {
    background: var(--ui-surface, #fff);
    border: 1px solid var(--th-line-dce5ef, #dce5ef);
    border-radius: 11px;
}

.mo-stat {
    padding: 18px 20px;
}

.mo-stat strong {
    display: block;
    font-size: 29px;
    color: var(--th-fg-163e62, #163e62);
    margin: 6px 0;
}

.mo-card {
    padding: 20px;
    margin-bottom: 18px;
}

.mo-card h3 {
    font-size: 17px;
    font-weight: 750;
    margin: 0 0 6px;
}

.mo-card > .mo-muted {
    margin: 0 0 15px;
}

.mo-table-wrap {
    overflow-x: auto;
    border: 1.5px solid #cbd8e5;
    border-radius: 10px;
    background: #fff;
}

.mo-table {
    width: 100%;
    border-collapse: separate;
    border-spacing: 0;
    font-size: 13px;
}

.mo-table th {
    text-align: start;
    background: #edf3f9;
    color: #294966;
    padding: 13px 14px;
    font-weight: 700;
    border-bottom: 1.5px solid #cbd8e5;
    white-space: nowrap;
}

.mo-table td {
    padding: 13px 14px;
    border-bottom: 1px solid #e0e8f0;
    vertical-align: middle;
    line-height: 1.5;
}

.mo-table tbody tr:last-child td {
    border-bottom: 0;
}

.mo-table tbody tr:hover {
    background: #f7fafd;
}

.mo-title {
    font-weight: 750;
    color: var(--th-fg-173451, #173451);
    margin-bottom: 3px;
}

.mo-actions {
    display: flex;
    align-items: center;
    gap: 7px;
    flex-wrap: nowrap;
}

.mo-actions .mo-btn {
    min-width: 58px;
    box-sizing: border-box;
}

.mo-notice {
    background: #e5f5ec;
    color: #17603a;
    padding: 13px 16px;
    border-radius: 8px;
    margin-bottom: 20px;
    font-size: 14px;
}

.mo-notice.error {
    background: #fff0ed;
    color: #a3392b;
}

.mo-form-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 14px 18px;
}

.mo-field {
    margin-bottom: 17px;
    min-width: 0;
}

.mo-field label {
    display: block;
    font-weight: 700;
    font-size: 13px;
    margin-bottom: 7px;
}

.mo-field input,
.mo-field select,
.mo-field textarea {
    width: 100%;
    padding: 11px 12px;
    border: 1px solid var(--th-line-d6e1eb, #d6e1eb);
    border-radius: 7px;
    background: var(--ui-surface, #fff);
    color: var(--th-fg-173451, #173451);
    font: inherit;
    font-size: 14px;
    box-sizing: border-box;
    outline: none;
}

.mo-field input:focus,
.mo-field select:focus,
.mo-field textarea:focus {
    border-color: #244f77;
    box-shadow: 0 0 0 3px rgba(36,79,119,.10);
}

.mo-field input[readonly] {
    background: #f5f7fa;
    color: #526985;
}

.mo-field textarea {
    min-height: 110px;
    resize: vertical;
}

.mo-majors {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    margin: 9px 0 20px;
}

.mo-major {
    display: inline-flex !important;
    align-items: center;
    gap: 7px;
    background: #f7f9fc;
    border: 1px solid #dce5ef;
    padding: 9px 12px;
    border-radius: 7px;
    font-size: 13px;
    font-weight: 500 !important;
    cursor: pointer;
    margin: 0 !important;
}

.mo-major input {
    width: auto;
    margin: 0;
    accent-color: #244f77;
}

.mo-form-footer {
    border-top: 1px solid #e6edf3;
    margin-top: 15px;
    padding-top: 20px;
    display: flex;
    justify-content: flex-end;
    gap: 10px;
}

.mo-dialog {
    position: fixed;
    inset: 0;
    z-index: 10000;
    background: rgba(18,43,69,.48);
    display: none;
    align-items: center;
    justify-content: center;
    padding: 20px;
}

.mo-dialog.show {
    display: flex;
}

.mo-dialog-box {
    width: 100%;
    max-width: 450px;
    padding: 28px;
    border-radius: 14px;
    background: var(--ui-surface, #fff);
    box-shadow: 0 18px 55px rgba(0,0,0,.17);
    box-sizing: border-box;
}

.mo-dialog-icon {
    width: 48px;
    height: 48px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 12px;
    background: #fff3e6;
    color: #a15c16;
    font-size: 23px;
    margin-bottom: 16px;
}

.mo-dialog-icon.activate {
    background: #e5f5ec;
    color: #17603a;
}

.mo-dialog-box h3 {
    font-size: 19px;
    margin: 0 0 10px;
}

.mo-dialog-box p {
    margin: 0;
}

.mo-dialog-actions {
    display: flex;
    justify-content: flex-end;
    gap: 10px;
    margin-top: 24px;
}

.mo-view-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 16px 24px;
    margin-top: 16px;
}

.mo-view-grid p,
.mo-view-block p {
    margin: 4px 0 0;
    font-size: 14px;
    color: var(--th-fg-173451, #173451);
    white-space: pre-line;
    overflow-wrap: anywhere;
}

.mo-view-block {
    margin-top: 20px;
}

.mo-back {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    text-decoration: none;
    margin-bottom: 10px;
}

.mo-required {
    color: #b42318;
    font-weight: 700;
}

.mo-empty {
    text-align: center;
    padding: 35px 20px !important;
    color: #718298;
}

@media (max-width: 750px) {
    .mo-heading {
        flex-wrap: wrap;
    }

    .mo-stats,
    .mo-form-grid,
    .mo-view-grid {
        grid-template-columns: 1fr;
    }

    .mo-form-grid {
        grid-template-columns: 1fr;
    }

    .mo-heading {
        flex-wrap: wrap;
    }
}

/* Compact, professional layout improvements */

.mo-page {
    max-width: 1200px;
}

.mo-heading {
    margin-bottom: 16px;
    gap: 12px;
}

.mo-heading h2 {
    margin-bottom: 3px;
}

.mo-heading .mo-muted {
    margin-bottom: 0;
}

.mo-stats {
    gap: 12px;
    margin-bottom: 16px;
}

.mo-stat {
    padding: 16px 18px;
}

.mo-stat strong {
    font-size: 26px;
    margin: 5px 0;
}

.mo-card {
    padding: 18px 20px;
    margin-bottom: 16px;
}

.mo-card h3 {
    margin-bottom: 5px;
}

.mo-card > .mo-muted {
    margin-bottom: 12px;
}

.mo-table th {
    padding: 12px 14px;
    font-weight: 700;
}

.mo-table td {
    padding: 12px 14px;
    line-height: 1.45;
}

.mo-table tbody tr:hover {
    background: var(--th-bg-f8fafc,#f8fafc);
}

.mo-table td:last-child,
.mo-table th:last-child {
    white-space: nowrap;
}

.mo-actions {
    gap: 6px;
    flex-wrap: nowrap;
}

.mo-actions .mo-btn {
    min-width: 55px;
    text-align: center;
    padding: 7px 11px;
}

.mo-btn {
    transition: background-color .2s ease,
                border-color .2s ease,
                box-shadow .2s ease;
}

.mo-btn:focus-visible {
    outline: 2px solid var(--th-line-244f77,#244f77);
    outline-offset: 2px;
}

.mo-field {
    margin-bottom: 14px;
}

.mo-form-grid {
    gap: 12px 16px;
}

.mo-form-footer {
    margin-top: 12px;
    padding-top: 16px;
}

.mo-view-grid {
    gap: 12px 20px;
}

.mo-view-block {
    margin-top: 16px;
}

@media (max-width: 750px) {

    .mo-card {
        padding: 15px;
    }

    .mo-stat {
        padding: 15px;
    }

    .mo-dialog-box {
        padding: 22px;
    }
}

/* Professional bordered table */

.mo-table-wrap {
    border: 1.5px solid var(--th-line-cbd8e5,#cbd8e5);
    border-radius: 10px;
    overflow-x: auto;
    background: var(--ui-surface,#ffffff);
}

.mo-table {
    width: 100%;
    border-collapse: separate;
    border-spacing: 0;
    font-size: 13px;
}

.mo-table th {
    background: var(--th-bg-edf3f9,#edf3f9);
    color: var(--th-fg-294966,#294966);
    padding: 13px 14px;
    font-weight: 700;
    border-bottom: 1.5px solid var(--th-line-cbd8e5,#cbd8e5);
}

.mo-table td {
    padding: 12px 14px;
    border-bottom: 1px solid var(--th-line-e0e8f0,#e0e8f0);
    vertical-align: middle;
}

.mo-table tbody tr:last-child td {
    border-bottom: none;
}

.mo-table tbody tr:hover {
    background: var(--th-bg-f7fafd,#f7fafd);
}

/* Neatly aligned action buttons */

.mo-actions {
    display: flex;
    align-items: center;
    gap: 6px;
    flex-wrap: nowrap;
}

.mo-actions .mo-btn {
    min-width: 58px;
    padding: 7px 10px;
    text-align: center;
    border-radius: 6px;
    box-sizing: border-box;
    white-space: nowrap;
}

/* Keep the table card compact */

.mo-card {
    padding: 18px;
}

.mo-card h3 {
    margin-bottom: 4px;
}

/* Status badges: one colour family per status, with a dot so the
   state still reads without colour. */

.mo-badge {
    --mo-status-fg: #526985;
    --mo-status-bg: #f1f5fa;
    --mo-status-line: #d5dfeb;
    --mo-status-dot: #8a9bb2;
    display: inline-flex;
    align-items: center;
    gap: 7px;
    min-height: 26px;
    padding: 3px 11px 3px 9px;
    border: 1px solid var(--mo-status-line);
    border-radius: 999px;
    background: var(--mo-status-bg);
    color: var(--mo-status-fg);
    font-size: 12px;
    font-weight: 700;
    line-height: 1;
    letter-spacing: .01em;
    white-space: nowrap;
    box-sizing: border-box;
    vertical-align: middle;
}

.mo-badge-dot {
    position: relative;
    flex: 0 0 auto;
    width: 7px;
    height: 7px;
    border-radius: 50%;
    background: var(--mo-status-dot);
}

.mo-badge.is-open {
    --mo-status-fg: #146c43;
    --mo-status-bg: #e8f7ef;
    --mo-status-line: #bfe6cf;
    --mo-status-dot: #1f9d5c;
}

/* Live pulse on Open: it is the only state students can apply to. */
.mo-badge.is-open .mo-badge-dot::after {
    content: "";
    position: absolute;
    inset: 0;
    border-radius: 50%;
    background: var(--mo-status-dot);
    animation: mo-status-pulse 2s ease-out infinite;
}

.mo-badge.is-draft {
    --mo-status-fg: #4d6582;
    --mo-status-bg: #f1f5fa;
    --mo-status-line: #c9d6e5;
    --mo-status-dot: transparent;
    border-style: dashed;
}

.mo-badge.is-draft .mo-badge-dot {
    box-shadow: inset 0 0 0 1.5px #7d93ad;
}

.mo-badge.is-inactive {
    --mo-status-fg: #9a5310;
    --mo-status-bg: #fff4e8;
    --mo-status-line: #f5d6b3;
    --mo-status-dot: #e08a2e;
}

@keyframes mo-status-pulse {
    0%   { transform: scale(1);   opacity: .55; }
    70%  { transform: scale(2.6); opacity: 0; }
    100% { transform: scale(2.6); opacity: 0; }
}

@media (prefers-reduced-motion: reduce) {
    .mo-badge.is-open .mo-badge-dot::after {
        animation: none;
        display: none;
    }
}

/* Statistic cards pick up the same status colour as a top accent. */

.mo-stat {
    position: relative;
    overflow: hidden;
}

.mo-stat::before {
    content: "";
    position: absolute;
    inset: 0 0 auto 0;
    height: 3px;
    background: var(--mo-stat-accent, transparent);
}

.mo-stat.is-open     { --mo-stat-accent: #1f9d5c; }
.mo-stat.is-draft    { --mo-stat-accent: #8a9bb2; }
.mo-stat.is-inactive { --mo-stat-accent: #e08a2e; }

[data-theme="dark"] .mo-badge {
    --mo-status-fg: #b8c7da;
    --mo-status-bg: #1e2a3a;
    --mo-status-line: #34465c;
    --mo-status-dot: #8295ad;
}

[data-theme="dark"] .mo-badge.is-open {
    --mo-status-fg: #8fe0b2;
    --mo-status-bg: #15291f;
    --mo-status-line: #2a5a3f;
    --mo-status-dot: #3ccf83;
}

[data-theme="dark"] .mo-badge.is-draft {
    --mo-status-fg: #b8c7da;
    --mo-status-bg: #1c2633;
    --mo-status-line: #3e5068;
    --mo-status-dot: transparent;
}

[data-theme="dark"] .mo-badge.is-draft .mo-badge-dot {
    box-shadow: inset 0 0 0 1.5px #8ea3bd;
}

[data-theme="dark"] .mo-badge.is-inactive {
    --mo-status-fg: #f3c58f;
    --mo-status-bg: #33261a;
    --mo-status-line: #5e4427;
    --mo-status-dot: #f0a050;
}

[data-theme="dark"] .mo-stat.is-open     { --mo-stat-accent: #3ccf83; }
[data-theme="dark"] .mo-stat.is-draft    { --mo-stat-accent: #8295ad; }
[data-theme="dark"] .mo-stat.is-inactive { --mo-stat-accent: #f0a050; }

</style>
<link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/opportunity-form.css?v=20261026-1") %>" />

</asp:Content>

<asp:Content ID="Body"
    ContentPlaceHolderID="MainContent"
    runat="server">

<div class="mo-page">

    <% if (!string.IsNullOrEmpty(Notice)) { %>
        <div class='mo-notice <%= IsError ? "error" : "" %>'
             role="alert">
            <%: Notice %>
        </div>
    <% } %>

    <% if (Editing == null && Viewing == null) { %>

        <!-- =============================== -->
        <!-- MANAGE OPPORTUNITIES LIST       -->
        <!-- =============================== -->

        <div class="mo-heading">
            <div>
                <h2>
                    <%: L.T("Company.ManageOpportunities.ManageOpportunities") %>
                </h2>

                <p class="mo-muted">
                    <%: L.T("Company.ManageOpportunities.CreateUpdateAndTrackYourInternship") %>
                </p>
            </div>


             <a href="Opportunities.aspx" class="mo-btn">
                 <%: L.T("Company.ManageOpportunities.AddOpportunity") %>
                   </a>

                </div>

        <!-- STATISTICS -->

        <div class="mo-stats">

            <div class="mo-stat is-open">
                <span class="mo-muted">
                    <%: L.T("Company.ManageOpportunities.OpenOpportunities") %>
                </span>

                <strong><%: OpenCount %></strong>

                <span class="mo-muted">
                    <%: L.T("Company.ManageOpportunities.AcceptingApplications") %>
                </span>
            </div>

            <div class="mo-stat is-draft">
                <span class="mo-muted">
                    <%: L.T("Company.ManageOpportunities.Drafts") %>
                </span>

                <strong><%: DraftCount %></strong>

                <span class="mo-muted">
                    <%: L.T("Company.ManageOpportunities.NotPublished") %>
                </span>
            </div>

            <div class="mo-stat is-inactive">
                <span class="mo-muted">
                    Inactive Opportunities
                </span>

                <strong><%: ClosedCount %></strong>

                <span class="mo-muted">
                    Temporarily hidden from students
                </span>
            </div>

        </div>

        <!-- OPPORTUNITIES TABLE -->

        <div class="mo-card">

            <h3>
                <%: L.T("Company.ManageOpportunities.AllOpportunities") %>
            </h3>

            <p class="mo-muted">
                <%: OpportunityItems.Count %>
                <%: L.T("Company.ManageOpportunities.PostingsInTotal") %>
            </p>

            <div class="mo-table-wrap">

                <table class="mo-table">

                    <thead>
                        <tr>
                            <th>
                                <%: L.T("Company.ManageOpportunities.Opportunity") %>
                            </th>

                            <th>
                                <%: L.T("Company.ManageOpportunities.Specialization") %>
                            </th>

                            <th>
                                <%: L.T("Company.ManageOpportunities.Seats") %>
                            </th>

                            <th>
                                Last Date to Apply
                            </th>

                            <th>
                                <%: L.T("Company.ManageOpportunities.Status") %>
                            </th>

                            <th>
                                <%: L.T("Company.ManageOpportunities.Actions") %>
                            </th>
                        </tr>
                    </thead>

                    <tbody>

                    <% foreach (var item in OpportunityItems) { %>

                        <tr>

                            <td>
                                <div class="mo-title">
                                    <%: item.Title %>
                                </div>

                            </td>

                            <td>
                                <%:
                                    item.EligibleMajors == null
                                    ? ""
                                    : string.Join(", ", item.EligibleMajors)
                                %>
                            </td>

                            <td>
                                <%: item.TotalSeats %>
                            </td>

                            <td>
                                <%: DateText(item.ApplicationDeadline) %>
                            </td>

                            <td>
                                <span class="mo-badge <%= StatusClass(item) %>">
                                    <span class="mo-badge-dot" aria-hidden="true"></span>
                                    <%: StatusText(item) %>
                                </span>
                            </td>

                            <td>

                                <div class="mo-actions">

                                    <!-- VIEW -->

                                    <a class="mo-btn mo-btn-light mo-small"
                                       href="ViewOpportunity.aspx?id=<%: Server.UrlEncode(item.Id) %>">

                                        <%: L.T("Company.ManageOpportunities.View") %>

                                    </a>

                                    <!-- EDIT -->

                                    <a class="mo-btn mo-btn-light mo-small"
                                       href="ManageOpportunities.aspx?edit=<%: Server.UrlEncode(item.Id) %>">

                                        <%: L.T("Company.ManageOpportunities.Edit") %>

                                    </a>

                                    <!-- ACTIVATE / DEACTIVATE -->

                                    <% if (item.Status == OpportunityStatus.Open ||
                                           item.Status == OpportunityStatus.Closed) { %>

                                        <button type="button"
                                            class="mo-btn mo-btn-light mo-small"
                                            data-id="<%: item.Id %>"
                                            data-title="<%: item.Title %>"
                                            data-action="<%= item.Status == OpportunityStatus.Open
                                                ? "deactivate"
                                                : "activate" %>"
                                            onclick="showToggleDialog(
                                                this.getAttribute('data-id'),
                                                this.getAttribute('data-title'),
                                                this.getAttribute('data-action'))">

                                            <%= item.Status == OpportunityStatus.Open
                                                ? "Deactivate"
                                                : "Activate" %>

                                        </button>

                                    <% } %>

                                </div>

                            </td>

                        </tr>

                    <% } %>

                    <% if (OpportunityItems.Count == 0) { %>

                        <tr>
                            <td colspan="6" class="mo-empty">
                                <%: L.T("Company.ManageOpportunities.NoOpportunitiesCreatedYet") %>
                            </td>
                        </tr>

                    <% } %>

                    </tbody>

                </table>

            </div>

        </div>

        <!-- =============================== -->
        <!-- ACTIVATE / DEACTIVATE DIALOG    -->
        <!-- =============================== -->

        <div id="moDialog"
             class="mo-dialog"
             role="dialog"
             aria-modal="true"
             aria-labelledby="moDialogTitle"
             data-activate-title="<%: L.T("Company.ManageOpportunities.ActivateTitle") %>"
             data-deactivate-title="<%: L.T("Company.ManageOpportunities.DeactivateTitle") %>"
             data-activate-label="<%: L.T("Company.ManageOpportunities.ActivateLabel") %>"
             data-deactivate-label="<%: L.T("Company.ManageOpportunities.DeactivateLabel") %>"
             data-activate-message="<%: L.T("Company.ManageOpportunities.ActivateMessage") %>"
             data-deactivate-message="<%: L.T("Company.ManageOpportunities.DeactivateMessage") %>"
             aria-hidden="true">

            <div class="mo-dialog-box">

                <div id="moDialogIcon" class="mo-dialog-icon"
                     aria-hidden="true">
                    <span data-ui-icon="warning" aria-hidden="true"></span>
                </div>

                <h3 id="moDialogTitle">
                    <%: L.T("Company.ManageOpportunities.ConfirmAction") %>
                </h3>

                <p class="mo-muted"
                   id="moDialogMessage">
                </p>

                <div class="mo-dialog-actions">

                    <button type="button"
                            class="mo-btn mo-btn-light"
                            onclick="hideToggleDialog()">

                        <%: L.T("Company.ManageOpportunities.Cancel") %>

                    </button>

                    <button type="submit"

                            class="mo-btn mo-btn-danger"
                            id="moConfirmButton"
                            name="moAction"
                            value="toggle"
                            data-ui-action="toggle"
                            data-ui-validation="none">

                        <%: L.T("Company.ManageOpportunities.ConfirmAction") %>
                    </button>

                </div>

            </div>

        </div>

        <input type="hidden"
               name="moId"
               id="moToggleId"
               value="" />

    <% } else if (Viewing != null) { %>

        <!-- =============================== -->
        <!-- VIEW OPPORTUNITY DETAILS        -->
        <!-- =============================== -->

        <a href="ManageOpportunities.aspx"
           class="mo-muted mo-back">

            <%: L.T("Company.ManageOpportunities.BackToOpportunities") %>

        </a>

        <div class="mo-heading">

            <div>
                <h2><%: Viewing.Title %></h2>
                <p class="mo-muted"><%: Viewing.Id %></p>
            </div>

            <div class="mo-actions">

                <span class="mo-badge <%= StatusClass(Viewing) %>">
                    <span class="mo-badge-dot" aria-hidden="true"></span>
                    <%: StatusText(Viewing) %>
                </span>

                <a class="mo-btn"
                   href="ManageOpportunities.aspx?edit=<%: Server.UrlEncode(Viewing.Id) %>">

                    <%: L.T("Company.ManageOpportunities.Edit") %>

                </a>

            </div>

        </div>

        <div class="mo-card">

            <h3>
                <%: L.T("Company.ManageOpportunities.OpportunityInformation") %>
            </h3>

            <div class="mo-view-grid">

                <div>
                    <span class="mo-muted">
                        <%: L.T("Company.ManageOpportunities.Department") %>
                    </span>
                    <p><%: TextOrDash(Viewing.Department) %></p>
                </div>

                <div>
                    <span class="mo-muted">
                        <%: L.T("Company.ManageOpportunities.TrainingMode") %>
                    </span>
                    <p><%: TextOrDash(Viewing.TrainingMode) %></p>
                </div>

                <div>
                    <span class="mo-muted">
                        <%: L.T("Company.ManageOpportunities.Location") %>
                    </span>
                    <p><%: TextOrDash(Viewing.Location) %></p>
                </div>

                <div>
                    <span class="mo-muted">
                        <%: L.T("Company.ManageOpportunities.EligibleCollege") %>
                    </span>
                    <p><%: TextOrDash(Viewing.EligibleCollege) %></p>
                </div>

                <div>
                    <span class="mo-muted">
                        <%: L.T("Company.ManageOpportunities.EligibleSpecializations") %>
                    </span>

                    <p>
                        <%:
                            Viewing.EligibleMajors == null ||
                            Viewing.EligibleMajors.Count == 0
                            ? "-"
                            : string.Join(", ", Viewing.EligibleMajors)
                        %>
                    </p>
                </div>

                <div>
                    <span class="mo-muted">
                        <%: L.T("Company.ManageOpportunities.TechnologiesUsed") %>
                    </span>
                    <p><%: TextOrDash(Viewing.TechnologiesUsed) %></p>
                </div>

            </div>

            <div class="mo-view-block">
                <span class="mo-muted">
                    <%: L.T("Company.ManageOpportunities.Description") %>
                </span>
                <p><%: TextOrDash(Viewing.Description) %></p>
            </div>

            <div class="mo-view-block">
                <span class="mo-muted">
                    <%: L.T("Company.ManageOpportunities.Requirements") %>
                </span>
                <p><%: TextOrDash(Viewing.Requirements) %></p>
            </div>

        </div>

        <div class="mo-card">

            <h3>
                <%: L.T("Company.ManageOpportunities.SeatsAndDates") %>
            </h3>

            <div class="mo-view-grid">

                <div>
                    <span class="mo-muted">
                        <%: L.T("Company.ManageOpportunities.SeatsFilledTotal") %>
                    </span>
                    <p>
                        <%: Viewing.FilledSeats %> /
                        <%: Viewing.TotalSeats %>
                    </p>
                </div>

                <div>
                    <span class="mo-muted">
                        <%: L.T("Company.ManageOpportunities.Duration") %>
                    </span>
                    <p>
                        <%: InternshipManagementSystem.Services.OpportunityFormRules.DurationLabel(Viewing.DurationWeeks) %>
                    </p>
                </div>

                <div>
                    <span class="mo-muted">
                        Last Date to Apply
                    </span>
                    <p>
                        <%: TextOrDash(DateText(Viewing.ApplicationDeadline)) %>
                    </p>
                </div>

                <div>
                    <span class="mo-muted">
                        <%: L.T("Company.ManageOpportunities.StartDate") %>
                    </span>
                    <p>
                        <%: TextOrDash(DateText(Viewing.StartDate)) %>
                    </p>
                </div>

                <div>
                    <span class="mo-muted">
                        <%: L.T("Company.ManageOpportunities.EndDate") %>
                    </span>
                    <p>
                        <%: TextOrDash(DateText(Viewing.EndDate)) %>
                    </p>
                </div>

            </div>

        </div>

    <% } else { %>

        <!-- =============================== -->
        <!-- EDIT OPPORTUNITY                -->
        <!-- =============================== -->

        <a href="ManageOpportunities.aspx"
           class="mo-muted mo-back">

            <%: L.T("Company.ManageOpportunities.BackToOpportunities") %>

        </a>

        <div class="mo-heading">

            <div>
                <h2>
                    <%: L.T("Company.ManageOpportunities.EditOpportunity") %>
                </h2>

                <p class="mo-muted">
                    <%: L.T("Company.ManageOpportunities.UpdateTheDetailsAndSaveYour") %>
                </p>
            </div>

            <span class="mo-badge <%= StatusClass(Editing) %>">
                <span class="mo-badge-dot" aria-hidden="true"></span>
                <%: StatusText(Editing) %>
            </span>

        </div>

        <div class="mo-card oppf"
             data-opp-form
             data-prefix="mo"
             data-past-rule="changed"
             data-filled="<%: Editing.FilledSeats %>"
             data-today="<%: TodayText %>"
             data-messages="<%: FormMessagesJson %>">

            <div class="oppf-summary" data-summary role="alert" hidden></div>

            <input type="hidden" name="moId" value="<%: Editing.Id %>" />

            <!-- 1. Basic details -->
            <section class="oppf-step">
                <h3><span class="oppf-step-no">1</span><%: L.T("Company.OpportunityForm.StepBasics") %></h3>

                <div class="mo-form-grid">
                    <div class="mo-field op-field<%= EditInvalid("Title") %>" data-field>
                        <label for="moTitle"><%: L.T("Company.ManageOpportunities.OpportunityTitle") %></label>
                        <input id="moTitle" name="moTitle" maxlength="160" value="<%: Editing.Title %>" />
                        <span class="oppf-error" data-error-for="Title" <%= EditHidden("Title") %>><%: EditError("Title") %></span>
                    </div>

                    <div class="mo-field op-field<%= EditInvalid("Department") %>" data-field>
                        <label for="moDepartment"><%: L.T("Company.ManageOpportunities.Department2") %></label>
                        <input id="moDepartment" name="moDepartment" maxlength="120" value="<%: Editing.Department %>" />
                        <span class="oppf-error" data-error-for="Department" <%= EditHidden("Department") %>><%: EditError("Department") %></span>
                    </div>

                    <div class="mo-field op-field<%= EditInvalid("Location") %>" data-field>
                        <label for="moLocation"><%: L.T("Company.ManageOpportunities.Location2") %></label>
                        <input id="moLocation" name="moLocation" maxlength="160" value="<%: Editing.Location %>" />
                        <span class="oppf-error" data-error-for="Location" <%= EditHidden("Location") %>><%: EditError("Location") %></span>
                    </div>

                    <div class="mo-field op-field<%= EditInvalid("Mode") %>" data-field>
                        <label for="moMode"><%: L.T("Company.ManageOpportunities.TrainingMode") %></label>
                        <select id="moMode" name="moMode">
                            <option value="On-site" <%= Editing.TrainingMode == "On-site" || string.IsNullOrEmpty(Editing.TrainingMode) ? "selected" : "" %>><%: L.T("Shared.Value.TrainingMode.Onsite") %></option>
                            <option value="Hybrid" <%= Editing.TrainingMode == "Hybrid" ? "selected" : "" %>><%: L.T("Shared.Value.TrainingMode.Hybrid") %></option>
                            <option value="Remote" <%= Editing.TrainingMode == "Remote" ? "selected" : "" %>><%: L.T("Shared.Value.TrainingMode.Remote") %></option>
                        </select>
                        <span class="oppf-error" data-error-for="Mode" <%= EditHidden("Mode") %>><%: EditError("Mode") %></span>
                    </div>
                </div>
            </section>

            <!-- 2. Who can apply -->
            <section class="oppf-step">
                <h3><span class="oppf-step-no">2</span><%: L.T("Company.OpportunityForm.StepWho") %></h3>
                <p class="mo-muted oppf-lead"><%: L.T("Company.ManageOpportunities.EligibleCollege") %>: <strong><%: CollegeName %></strong></p>

                <div class="mo-field op-field<%= EditInvalid("Majors") %>" data-field>
                    <span class="oppf-label"><%: L.T("Company.ManageOpportunities.EligibleSpecializations2") %></span>
                    <div class="mo-majors">
                        <% foreach (string major in Majors) { %>
                            <label class="mo-major">
                                <input type="checkbox" name="moMajors" value="<%: major %>" <%= IsMajorSelected(major) ? "checked" : "" %> />
                                <%: major %>
                            </label>
                        <% } %>
                    </div>
                    <span class="oppf-error" data-error-for="Majors" <%= EditHidden("Majors") %>><%: EditError("Majors") %></span>
                </div>
            </section>

            <!-- 3. About the role -->
            <section class="oppf-step">
                <h3><span class="oppf-step-no">3</span><%: L.T("Company.OpportunityForm.StepRole") %></h3>

                <div class="mo-field op-field<%= EditInvalid("Description") %>" data-field>
                    <label for="moDescription"><%: L.T("Company.ManageOpportunities.Description2") %></label>
                    <textarea id="moDescription" name="moDescription" maxlength="5000"><%: Editing.Description %></textarea>
                    <span class="mo-muted oppf-hint-small"><%: L.T("Company.OpportunityForm.DescriptionHint") %></span>
                    <span class="oppf-error" data-error-for="Description" <%= EditHidden("Description") %>><%: EditError("Description") %></span>
                </div>

                <div class="mo-form-grid">
                    <div class="mo-field op-field<%= EditInvalid("Requirements") %>" data-field>
                        <label for="moRequirements"><%: L.T("Company.ManageOpportunities.Requirements2") %></label>
                        <textarea id="moRequirements" name="moRequirements" maxlength="3000"><%: Editing.Requirements %></textarea>
                        <span class="oppf-error" data-error-for="Requirements" <%= EditHidden("Requirements") %>><%: EditError("Requirements") %></span>
                    </div>

                    <div class="mo-field op-field<%= EditInvalid("Technologies") %>" data-field>
                        <label for="moTechnologies"><%: L.T("Company.ManageOpportunities.TechnologiesUsed") %></label>
                        <textarea id="moTechnologies" name="moTechnologies" maxlength="1000"><%: Editing.TechnologiesUsed %></textarea>
                        <span class="oppf-error" data-error-for="Technologies" <%= EditHidden("Technologies") %>><%: EditError("Technologies") %></span>
                    </div>
                </div>
            </section>

            <!-- 4. Seats and dates: last date to apply -> start -> end (always 3 months) -->
            <section class="oppf-step">
                <h3><span class="oppf-step-no">4</span><%: L.T("Company.OpportunityForm.StepDates") %></h3>
                <p class="mo-muted oppf-lead"><%: L.T("Company.OpportunityForm.DatesHelp") %></p>

                <div class="oppf-dates">
                    <div class="mo-field op-field<%= EditInvalid("Seats") %>" data-field>
                        <label for="moSeats"><%: L.T("Company.ManageOpportunities.AvailableSeats") %></label>
                        <input id="moSeats" name="moSeats" type="number" min="<%: Math.Max(1, Editing.FilledSeats) %>" max="500" step="1" inputmode="numeric"
                               value="<%: Editing.TotalSeats > 0 ? Editing.TotalSeats.ToString() : "" %>" />
                        <span class="oppf-error" data-error-for="Seats" <%= EditHidden("Seats") %>><%: EditError("Seats") %></span>
                    </div>

                    <div class="mo-field op-field<%= EditInvalid("Deadline") %>" data-field>
                        <label for="moDeadline"><%: L.T("Company.ManageOpportunities.ApplicationDeadline2") %></label>
                        <input id="moDeadline" name="moDeadline" type="date" value="<%: DateText(Editing.ApplicationDeadline) %>" />
                        <span class="oppf-error" data-error-for="Deadline" <%= EditHidden("Deadline") %>><%: EditError("Deadline") %></span>
                    </div>

                    <div class="mo-field op-field<%= EditInvalid("Start") %>" data-field>
                        <label for="moStart"><%: L.T("Company.ManageOpportunities.StartDate2") %></label>
                        <input id="moStart" name="moStart" type="date" value="<%: DateText(Editing.StartDate) %>" />
                        <span class="oppf-error" data-error-for="Start" <%= EditHidden("Start") %>><%: EditError("Start") %></span>
                    </div>

                    <div class="mo-field op-field" data-field>
                        <span class="oppf-label"><%: L.T("Company.ManageOpportunities.EndDate") %></span>
                        <div class="oppf-auto" data-end-date><%: EditEndText %></div>
                        <span class="mo-muted oppf-hint-small"><%: L.T("Company.OpportunityForm.EndAuto") %></span>
                    </div>
                </div>

                <p class="oppf-duration" data-duration data-empty="<%: L.T("Company.OpportunityForm.DurationEmpty") %>" aria-live="polite"><%: EditDurationText %></p>
            </section>

            <!-- FOOTER -->
            <div class="mo-form-footer">
                <a class="mo-btn mo-btn-light" href="ManageOpportunities.aspx">
                    <%: L.T("Company.ManageOpportunities.Cancel") %>
                </a>

                <button type="submit"
                        class="mo-btn"
                        name="moAction"
                        value="save"
                        data-opp-submit="complete"
                        data-ui-action="save"
                        data-ui-validation="none"
                        data-loading-label="<%: L.T("Shared.I18n.Saving") %>">
                    <%: L.T("Company.ManageOpportunities.SaveChanges") %>
                </button>
            </div>

        </div>

    <% } %>

</div>

<script type="text/javascript">

    function showToggleDialog(id, title, action) {

        var dialog =
            document.getElementById("moDialog");

        var dialogTitle =
            document.getElementById("moDialogTitle");

        var message =
            document.getElementById("moDialogMessage");

        var confirmButton =
            document.getElementById("moConfirmButton");

        var hiddenId =
            document.getElementById("moToggleId");

        var dialogIcon =
            document.getElementById("moDialogIcon");

        if (!dialog ||
            !dialogTitle ||
            !message ||
            !confirmButton ||
            !hiddenId) {
            return;
        }

        hiddenId.value = id;

        if (action === "deactivate") {

            dialogTitle.textContent =
                dialog.dataset.deactivateTitle;

            message.textContent =
                dialog.dataset.deactivateMessage.replace('{0}', function () { return title; });

            confirmButton.textContent =
                dialog.dataset.deactivateLabel;

            confirmButton.classList.remove(
                "mo-btn-success"
            );

            confirmButton.classList.add(
                "mo-btn-danger"
            );

            if (dialogIcon) {
                dialogIcon.textContent = "−";
                if (window.UimsUI) dialogIcon.replaceChildren(window.UimsUI.icon('warning'));
                dialogIcon.classList.remove("activate");
            }

        } else {

            dialogTitle.textContent =
                dialog.dataset.activateTitle;

            message.textContent =
                dialog.dataset.activateMessage.replace('{0}', function () { return title; });

            confirmButton.textContent =
                dialog.dataset.activateLabel;

            confirmButton.classList.remove(
                "mo-btn-danger"
            );

            confirmButton.classList.add(
                "mo-btn-success"
            );

            if (dialogIcon) {
                dialogIcon.textContent = "✓";
                if (window.UimsUI) dialogIcon.replaceChildren(window.UimsUI.icon('approved'));
                dialogIcon.classList.add("activate");
            }
        }

        dialog.classList.add("show");
        dialog.setAttribute("aria-hidden", "false");
        // The shared supervisor dialog enhancement manages focus and keyboard navigation.
    }

    function hideToggleDialog() {

        var dialog =
            document.getElementById("moDialog");

        if (dialog) {

            dialog.classList.remove("show");
            dialog.setAttribute("aria-hidden", "true");
        }
    }

    document.addEventListener(
        "keydown",
        function (event) {

            if (event.key === "Escape") {
                hideToggleDialog();
            }
        }
    );

    document.addEventListener(
        "click",
        function (event) {

            var dialog =
                document.getElementById("moDialog");

            if (dialog && event.target === dialog) {
                hideToggleDialog();
            }
        }
    );

</script>

<script src="<%: ResolveUrl("~/Assets/js/opportunity-form.js?v=20261026-2") %>"></script>
</asp:Content>
