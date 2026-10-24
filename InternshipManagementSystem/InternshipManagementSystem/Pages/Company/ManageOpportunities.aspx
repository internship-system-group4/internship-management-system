<%@ Page Title="Manage Opportunities"
    Language="C#"
    MasterPageFile="~/Layout/Company.master"
    AutoEventWireup="true"
    CodeBehind="ManageOpportunities.aspx.cs"
    Inherits="InternshipManagementSystem.Pages.CompanyArea.ManageOpportunities" %>

<asp:Content ID="Head" ContentPlaceHolderID="head"
    runat="server">

<style>
.mo-page {
    max-width: 1150px;
    margin: 0 auto;
    color: var(--th-fg-173451,#173451);
}

.mo-heading {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 15px;
    margin-bottom: 24px;
}

.mo-heading h2 {
    font-size: 26px;
    font-weight: 750;
    margin-bottom: 5px;
}

.mo-muted {
    color: var(--ui-muted);
    font-size: 13px;
}

.mo-btn {
    display: inline-block;
    padding: 10px 17px;
    border: 1px solid var(--th-line-244f77,#244f77);
    background: var(--th-bg-244f77,#244f77);
    color: white;
    text-decoration: none;
    border-radius: 7px;
    font-size: 13px;
    font-weight: 700;
    cursor: pointer;
}

.mo-btn:hover {
    filter: brightness(.94);
    color: white;
}

.mo-btn-light {
    background: var(--ui-surface,#fff);
    color: var(--th-fg-244f77,#244f77);
}

.mo-btn-light:hover {
    color: var(--th-fg-244f77,#244f77);
}

.mo-btn-danger {
    background: var(--th-bg-b42318,#b42318);
    border-color: var(--th-line-b42318,#b42318);
}

.mo-stats {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 18px;
    margin-bottom: 23px;
}

.mo-stat,
.mo-card {
    background: var(--ui-surface,#fff);
    border: 1px solid var(--th-line-dce5ef,#dce5ef);
    border-radius: 11px;
    padding: 20px;
}

.mo-stat strong {
    display: block;
    font-size: 29px;
    color: var(--th-fg-163e62,#163e62);
    margin: 7px 0;
}

.mo-card {
    margin-bottom: 20px;
}

.mo-card h3 {
    font-size: 17px;
    font-weight: 750;
    margin-bottom: 7px;
}

.mo-table-wrap {
    overflow-x: auto;
}

.mo-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 13px;
}

.mo-table th {
    text-align: start;
    background: var(--th-bg-f3f7fb,#f3f7fb);
    color: var(--th-fg-48627d,#48627d);
    padding: 13px;
    white-space: nowrap;
}

.mo-table td {
    border-bottom: 1px solid var(--th-line-e6edf3,#e6edf3);
    padding: 14px 13px;
    vertical-align: middle;
}

.mo-table tr:last-child td {
    border-bottom: 0;
}

.mo-title {
    font-weight: 750;
    color: var(--th-fg-173451,#173451);
}

.mo-badge {
    display: inline-block;
    padding: 5px 10px;
    border-radius: 20px;
    background: var(--th-bg-e5f5ec,#e5f5ec);
    color: var(--th-fg-17603a,#17603a);
    font-size: 12px;
    font-weight: 700;
}

.mo-badge.draft {
    background: var(--th-bg-edf2f8,#edf2f8);
    color: var(--th-fg-526985,#526985);
}

.mo-badge.closed {
    background: var(--th-bg-f2eeee,#f2eeee);
    color: var(--th-fg-815b5b,#815b5b);
}

.mo-actions {
    display: flex;
    gap: 8px;
    align-items: center;
}

.mo-small {
    padding: 7px 12px;
    font-size: 12px;
}

.mo-notice {
    background: var(--th-bg-e5f5ec,#e5f5ec);
    color: var(--th-fg-17603a,#17603a);
    padding: 13px 16px;
    border-radius: 8px;
    margin-bottom: 20px;
}

.mo-notice.error {
    background: var(--th-bg-fff0ed,#fff0ed);
    color: var(--th-fg-a3392b,#a3392b);
}

.mo-form-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 16px;
}

.mo-field {
    margin-bottom: 18px;
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
    border: 1px solid var(--th-line-d6e1eb,#d6e1eb);
    border-radius: 7px;
    font: inherit;
    font-size: 14px;
    box-sizing: border-box;
}

.mo-field textarea {
    min-height: 100px;
    resize: vertical;
}

.mo-majors {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    margin: 9px 0 20px;
}

.mo-major {
    background: var(--th-bg-f7f9fc,#f7f9fc);
    border: 1px solid var(--th-line-dce5ef,#dce5ef);
    padding: 9px 12px;
    border-radius: 7px;
    font-size: 13px;
}

.mo-major input {
    width: auto;
    margin-inline-end: 5px;
}

.mo-form-footer {
    border-top: 1px solid var(--th-line-e6edf3,#e6edf3);
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
    background: rgba(18, 43, 69, .43);
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
    max-width: 420px;
    padding: 25px;
    border-radius: 12px;
    background: var(--ui-surface,#fff);
    box-shadow: 0 12px 40px rgba(0, 0, 0, .15);
}

.mo-dialog-box h3 {
    margin-bottom: 10px;
}

.mo-dialog-actions {
    display: flex;
    justify-content: flex-end;
    gap: 10px;
    margin-top: 20px;
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
    color: var(--th-fg-173451,#173451);
    white-space: pre-line;
    overflow-wrap: anywhere;
}

.mo-view-block {
    margin-top: 20px;
}

@media (max-width: 750px) {
    .mo-stats {
        grid-template-columns: 1fr;
    }

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
        padding: 14px;
    }

    .mo-actions {
        gap: 5px;
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

</style>

</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent"
    runat="server">

<div class="mo-page">

    <% if (!string.IsNullOrEmpty(Notice)) { %>
        <div class='mo-notice <%= IsError ? "error" : "" %>'>
            <%: Notice %>
        </div>
    <% } %>

    <% if (Editing == null && Viewing == null) { %>

        <!-- Manage List -->

        <div class="mo-heading">
            <div>
                <h2><%: L.T("Company.ManageOpportunities.ManageOpportunities") %></h2>
                <p class="mo-muted">
                    <%: L.T("Company.ManageOpportunities.CreateUpdateAndTrackYourInternship") %>
                </p>
            </div>

            <a href="Opportunities.aspx" class="mo-btn">
                <%: L.T("Company.ManageOpportunities.AddOpportunity") %>
            </a>
        </div>

        <div class="mo-stats">

            <div class="mo-stat">
                <span class="mo-muted"><%: L.T("Company.ManageOpportunities.OpenOpportunities") %></span>
                <strong><%: OpenCount %></strong>
                <span class="mo-muted"><%: L.T("Company.ManageOpportunities.AcceptingApplications") %></span>
            </div>

            <div class="mo-stat">
                <span class="mo-muted"><%: L.T("Company.ManageOpportunities.Drafts") %></span>
                <strong><%: DraftCount %></strong>
                <span class="mo-muted"><%: L.T("Company.ManageOpportunities.NotPublished") %></span>
            </div>

            <div class="mo-stat">
                <span class="mo-muted"><%: L.T("Company.ManageOpportunities.ClosedOpportunities") %></span>
                <strong><%: ClosedCount %></strong>
                <span class="mo-muted">
                    <%: L.T("Company.ManageOpportunities.NoLongerAcceptingApplications") %>
                </span>
            </div>

        </div>

        <div class="mo-card">

            <h3><%: L.T("Company.ManageOpportunities.AllOpportunities") %></h3>
            <p class="mo-muted">
                <%: OpportunityItems.Count %>
                <%: L.T("Company.ManageOpportunities.PostingsInTotal") %>
            </p>

            <div class="mo-table-wrap">

                <table class="mo-table">

                    <thead>
                        <tr>
                            <th><%: L.T("Company.ManageOpportunities.Opportunity") %></th>
                            <th><%: L.T("Company.ManageOpportunities.Specialization") %></th>
                            <th><%: L.T("Company.ManageOpportunities.Seats") %></th>
                            <th><%: L.T("Company.ManageOpportunities.Deadline") %></th>
                            <th><%: L.T("Company.ManageOpportunities.Status") %></th>
                            <th><%: L.T("Company.ManageOpportunities.Actions") %></th>
                        </tr>
                    </thead>

                    <tbody>

                    <% foreach (var item in OpportunityItems) { %>

                        <tr>

                            <td>
                                <div class="mo-title">
                                    <%: item.Title %>
                                </div>
                                <span class="mo-muted">
                                    <%: item.Id %>
                                </span>
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
                                <span class='mo-badge <%=
                                    item.Status == OpportunityStatus.Closed
                                    ? "closed"
                                    : item.Status == OpportunityStatus.Draft
                                    ? "draft"
                                    : ""
                                %>'>
                                    <%: StatusText(item) %>
                                </span>
                            </td>

                            <td>
                                
                    <div class="mo-actions">

                             <!-- View Opportunity -->
                                   <a class="mo-btn mo-btn-light mo-small"
                                       href="ViewOpportunity.aspx?id=<%: Server.UrlEncode(item.Id) %>">
                                              <%: L.T("Company.ManageOpportunities.View") %>
                                               </a>

                                        <!-- Edit Opportunity -->
                                               <a class="mo-btn mo-btn-light mo-small"
                                               href="ManageOpportunities.aspx?edit=<%: Server.UrlEncode(item.Id) %>">
                                                     <%: L.T("Company.ManageOpportunities.Edit") %>
                                            </a>


                                    <% if (item.Status != OpportunityStatus.Closed) { %>

                                        <button type="button"
                                           class="mo-btn mo-btn-light mo-small"
                                               data-id="<%: item.Id %>"
                                                       data-title="<%: item.Title %>"
                                             onclick="showCloseDialog(this.getAttribute('data-id'), this.getAttribute('data-title'))">
                                                                <%: L.T("Company.ManageOpportunities.Close") %>
                                                       </button>

                                              <% } %>

                                </div>
                            </td>

                        </tr>

                    <% } %>

                    <% if (OpportunityItems.Count == 0) { %>
                        <tr>
                            <td colspan="6" style="text-align:center;padding:30px;">
                                <%: L.T("Company.ManageOpportunities.NoOpportunitiesCreatedYet") %>
                            </td>
                        </tr>
                    <% } %>

                    </tbody>

                </table>

            </div>

        </div>

        <!-- Close Confirmation Dialog -->

        <div id="moDialog" data-ui-dialog="" data-ui-close="hideCloseDialog" class="mo-dialog"
            role="dialog" aria-modal="true"
            aria-labelledby="moDialogTitle">

            <div class="mo-dialog-box">

                <h3 id="moDialogTitle">
                    <%: L.T("Company.ManageOpportunities.CloseThisOpportunity") %>
                </h3>

                <p class="mo-muted">
                    <strong id="moCloseTitle"></strong>
                    <%: L.T("Company.ManageOpportunities.WillNoLongerAcceptNewApplications") %>
                </p>

                <div class="mo-dialog-actions">

                    <button type="button"
                        class="mo-btn mo-btn-light"
                        onclick="hideCloseDialog()">
                        <%: L.T("Company.ManageOpportunities.Cancel") %>
                    </button>

                    <button type="submit"
                        class="mo-btn mo-btn-danger"
                        name="moAction"
                        value="close"
                        onclick="document.getElementById('moCloseId').value = window.selectedOpportunityId;" data-ui-action="close" data-ui-validation="none" data-loading-label="Closing…">
                        <%: L.T("Company.ManageOpportunities.CloseOpportunity") %>
                    </button>

                </div>

            </div>

        </div>

        <input type="hidden" name="moId"
            id="moCloseId" value="" />

    <% } else if (Viewing != null) { %>

        <!-- View Opportunity (read only) -->

        <a href="ManageOpportunities.aspx" class="mo-muted">
            <%: L.T("Company.ManageOpportunities.BackToOpportunities") %>
        </a>

        <div class="mo-heading" style="margin-top:15px;">
            <div>
                <h2><%: Viewing.Title %></h2>
                <p class="mo-muted"><%: Viewing.Id %></p>
            </div>

            <div class="mo-actions">
                <span class='mo-badge <%=
                    Viewing.Status == OpportunityStatus.Closed
                    ? "closed"
                    : Viewing.Status == OpportunityStatus.Draft
                    ? "draft"
                    : ""
                %>'>
                    <%: StatusText(Viewing) %>
                </span>

                <a class="mo-btn"
                   href="ManageOpportunities.aspx?edit=<%: Server.UrlEncode(Viewing.Id) %>">
                    <%: L.T("Company.ManageOpportunities.Edit") %>
                </a>
            </div>
        </div>

        <div class="mo-card">

            <h3><%: L.T("Company.ManageOpportunities.OpportunityInformation") %></h3>

            <div class="mo-view-grid">
                <div>
                    <span class="mo-muted"><%: L.T("Company.ManageOpportunities.Department") %></span>
                    <p><%: TextOrDash(Viewing.Department) %></p>
                </div>
                <div>
                    <span class="mo-muted"><%: L.T("Company.ManageOpportunities.TrainingMode") %></span>
                    <p><%: TextOrDash(Viewing.TrainingMode) %></p>
                </div>
                <div>
                    <span class="mo-muted"><%: L.T("Company.ManageOpportunities.Location") %></span>
                    <p><%: TextOrDash(Viewing.Location) %></p>
                </div>
                <div>
                    <span class="mo-muted"><%: L.T("Company.ManageOpportunities.EligibleCollege") %></span>
                    <p><%: TextOrDash(Viewing.EligibleCollege) %></p>
                </div>
                <div>
                    <span class="mo-muted"><%: L.T("Company.ManageOpportunities.EligibleSpecializations") %></span>
                    <p><%: Viewing.EligibleMajors == null || Viewing.EligibleMajors.Count == 0
                            ? "-"
                            : string.Join(", ", Viewing.EligibleMajors) %></p>
                </div>
                <div>
                    <span class="mo-muted"><%: L.T("Company.ManageOpportunities.TechnologiesUsed") %></span>
                    <p><%: TextOrDash(Viewing.TechnologiesUsed) %></p>
                </div>
            </div>

            <div class="mo-view-block">
                <span class="mo-muted"><%: L.T("Company.ManageOpportunities.Description") %></span>
                <p><%: TextOrDash(Viewing.Description) %></p>
            </div>

            <div class="mo-view-block">
                <span class="mo-muted"><%: L.T("Company.ManageOpportunities.Requirements") %></span>
                <p><%: TextOrDash(Viewing.Requirements) %></p>
            </div>

        </div>

        <div class="mo-card">

            <h3><%: L.T("Company.ManageOpportunities.SeatsAndDates") %></h3>

            <div class="mo-view-grid">
                <div>
                    <span class="mo-muted"><%: L.T("Company.ManageOpportunities.SeatsFilledTotal") %></span>
                    <p><%: Viewing.FilledSeats %> / <%: Viewing.TotalSeats %></p>
                </div>
                <div>
                    <span class="mo-muted"><%: L.T("Company.ManageOpportunities.Duration") %></span>
                    <p><%: Viewing.DurationWeeks %> <%: L.T("Company.ManageOpportunities.Weeks") %></p>
                </div>
                <div>
                    <span class="mo-muted"><%: L.T("Company.ManageOpportunities.ApplicationDeadline") %></span>
                    <p><%: TextOrDash(DateText(Viewing.ApplicationDeadline)) %></p>
                </div>
                <div>
                    <span class="mo-muted"><%: L.T("Company.ManageOpportunities.StartDate") %></span>
                    <p><%: TextOrDash(DateText(Viewing.StartDate)) %></p>
                </div>
                <div>
                    <span class="mo-muted"><%: L.T("Company.ManageOpportunities.EndDate") %></span>
                    <p><%: TextOrDash(DateText(Viewing.EndDate)) %></p>
                </div>
            </div>

        </div>

    <% } else { %>

        <!-- Edit Opportunity -->

        <a href="ManageOpportunities.aspx" class="mo-muted">
            <%: L.T("Company.ManageOpportunities.BackToOpportunities") %>
        </a>

        <div class="mo-heading" style="margin-top:15px;">
            <div>
                <h2><%: L.T("Company.ManageOpportunities.EditOpportunity") %></h2>
                <p class="mo-muted">
                    <%: L.T("Company.ManageOpportunities.UpdateTheDetailsAndSaveYour") %>
                </p>
            </div>

            <span class="mo-badge">
                <%: Editing.Status.ToString() %>
            </span>
        </div>

        <div class="mo-card">

            <h3><%: L.T("Company.ManageOpportunities.OpportunityInformation") %></h3>
            <p class="mo-muted" style="margin-bottom:22px;">
                <%: L.T("Company.ManageOpportunities.ProvideTheMainDetailsOfThis") %>
            </p>

            <input type="hidden" name="moId"
                value="<%: Editing.Id %>" />

            <div class="mo-form-grid">

                <div class="mo-field">
                    <label><%: L.T("Company.ManageOpportunities.OpportunityTitle") %></label>
                    <input name="moTitle"
                        maxlength="160"
                        value="<%: Editing.Title %>" />
                </div>

                <div class="mo-field">
                    <label><%: L.T("Company.ManageOpportunities.Department2") %></label>
                    <input name="moDepartment"
                        maxlength="120"
                        value="<%: Editing.Department %>" />
                </div>

                <div class="mo-field">
                    <label><%: L.T("Company.ManageOpportunities.EligibleCollege") %></label>
                    <input readonly="readonly"
                        value="<%: CollegeName %>" />
                </div>

                <div class="mo-field">
                    <label><%: L.T("Company.ManageOpportunities.TrainingMode") %></label>
                    <select name="moMode">
                        <option value="On-site"
                            <%= Editing.TrainingMode == "On-site" ? "selected" : "" %>>
                            <%: L.T("Shared.Value.TrainingMode.Onsite") %>
                        </option>
                        <option value="Hybrid"
                            <%= Editing.TrainingMode == "Hybrid" ? "selected" : "" %>>
                            <%: L.T("Shared.Value.TrainingMode.Hybrid") %>
                        </option>
                        <option value="Remote"
                            <%= Editing.TrainingMode == "Remote" ? "selected" : "" %>>
                            <%: L.T("Shared.Value.TrainingMode.Remote") %>
                        </option>
                    </select>
                </div>

                <div class="mo-field">
                    <label><%: L.T("Company.ManageOpportunities.Location2") %></label>
                    <input name="moLocation"
                        maxlength="160"
                        value="<%: Editing.Location %>" />
                </div>

                <div class="mo-field">
                    <label><%: L.T("Company.ManageOpportunities.TechnologiesUsed") %></label>
                    <input name="moTechnologies"
                        maxlength="1000"
                        value="<%: Editing.TechnologiesUsed %>" />
                </div>

            </div>

            <div class="mo-field">
                <label><%: L.T("Company.ManageOpportunities.EligibleSpecializations2") %></label>

                <div class="mo-majors">

                    <% foreach (string major in Majors) { %>

                        <label class="mo-major">
                            <input type="checkbox"
                                name="moMajors"
                                value="<%: major %>"
                                <%= IsMajorSelected(major) ? "checked" : "" %> />
                            <%: major %>
                        </label>

                    <% } %>

                </div>
            </div>

            <div class="mo-field">
                <label><%: L.T("Company.ManageOpportunities.Description2") %></label>
                <textarea name="moDescription"
                    maxlength="5000"><%: Editing.Description %></textarea>
            </div>

            <div class="mo-field">
                <label><%: L.T("Company.ManageOpportunities.Requirements2") %></label>
                <textarea name="moRequirements"
                    maxlength="3000"><%: Editing.Requirements %></textarea>
            </div>

            <div class="mo-form-grid">

                <div class="mo-field">
                    <label><%: L.T("Company.ManageOpportunities.AvailableSeats") %></label>
                    <input type="number"
                        name="moSeats"
                        min="1"
                        max="10000"
                        value="<%: Editing.TotalSeats %>" />
                </div>

                <div class="mo-field">
                    <label><%: L.T("Company.ManageOpportunities.DurationWeeks") %></label>
                    <input type="number"
                        name="moDuration"
                        min="1"
                        max="104"
                        value="<%: Editing.DurationWeeks %>" />
                </div>

                <div class="mo-field">
                    <label><%: L.T("Company.ManageOpportunities.ApplicationDeadline2") %></label>
                    <input type="date"
                        name="moDeadline"
                        value="<%: DateText(Editing.ApplicationDeadline) %>" />
                </div>

                <div class="mo-field">
                    <label><%: L.T("Company.ManageOpportunities.StartDate2") %></label>
                    <input type="date"
                        name="moStart"
                        value="<%: DateText(Editing.StartDate) %>" />
                </div>

                <div class="mo-field">
                    <label><%: L.T("Company.ManageOpportunities.EndDate2") %></label>
                    <input type="date"
                        name="moEnd"
                        value="<%: DateText(Editing.EndDate) %>" />
                </div>

            </div>

            <div class="mo-form-footer">

                <a class="mo-btn mo-btn-light"
                    href="ManageOpportunities.aspx">
                    <%: L.T("Company.ManageOpportunities.Cancel") %>
                </a>

                <button type="submit"
                    class="mo-btn"
                    name="moAction"
                    value="save" data-ui-action="save" data-ui-validation="none" data-loading-label="Saving…">
                    <%: L.T("Company.ManageOpportunities.SaveChanges") %>
                </button>

            </div>

        </div>

    <% } %>

</div>


<script type="text/javascript">

    var selectedOpportunityId = "";

    function showCloseDialog(id, title) {

        selectedOpportunityId = id;

        var titleElement =
            document.getElementById("moCloseTitle");

        var dialog =
            document.getElementById("moDialog");

        if (titleElement && dialog) {

            titleElement.textContent = title;

            dialog.classList.add("show");
        }
    }

    function hideCloseDialog() {

        var dialog =
            document.getElementById("moDialog");

        if (dialog) {

            dialog.classList.remove("show");
        }
    }

    function prepareClose() {

        var hiddenInput =
            document.getElementById("moCloseId");

        if (hiddenInput) {

            hiddenInput.value = selectedOpportunityId;
        }
    }

</script>


</asp:Content>
