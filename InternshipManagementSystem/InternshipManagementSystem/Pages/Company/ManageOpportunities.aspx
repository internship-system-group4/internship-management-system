
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
    color: #173451;
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
    color: #718298;
    font-size: 13px;
}

.mo-btn {
    display: inline-block;
    padding: 10px 17px;
    border: 1px solid #244f77;
    background: #244f77;
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
    background: #fff;
    color: #244f77;
}

.mo-btn-light:hover {
    color: #244f77;
}

.mo-btn-danger {
    background: #b42318;
    border-color: #b42318;
}

.mo-stats {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 18px;
    margin-bottom: 23px;
}

.mo-stat,
.mo-card {
    background: #fff;
    border: 1px solid #dce5ef;
    border-radius: 11px;
    padding: 20px;
}

.mo-stat strong {
    display: block;
    font-size: 29px;
    color: #163e62;
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
    text-align: left;
    background: #f3f7fb;
    color: #48627d;
    padding: 13px;
    white-space: nowrap;
}

.mo-table td {
    border-bottom: 1px solid #e6edf3;
    padding: 14px 13px;
    vertical-align: middle;
}

.mo-table tr:last-child td {
    border-bottom: 0;
}

.mo-title {
    font-weight: 750;
    color: #173451;
}

.mo-badge {
    display: inline-block;
    padding: 5px 10px;
    border-radius: 20px;
    background: #e5f5ec;
    color: #17603a;
    font-size: 12px;
    font-weight: 700;
}

.mo-badge.draft {
    background: #edf2f8;
    color: #526985;
}

.mo-badge.closed {
    background: #f2eeee;
    color: #815b5b;
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
    background: #e5f5ec;
    color: #17603a;
    padding: 13px 16px;
    border-radius: 8px;
    margin-bottom: 20px;
}

.mo-notice.error {
    background: #fff0ed;
    color: #a3392b;
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
    border: 1px solid #d6e1eb;
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
    background: #f7f9fc;
    border: 1px solid #dce5ef;
    padding: 9px 12px;
    border-radius: 7px;
    font-size: 13px;
}

.mo-major input {
    width: auto;
    margin-right: 5px;
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
    background: #fff;
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
    color: #173451;
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
                <h2>Manage opportunities</h2>
                <p class="mo-muted">
                    Create, update and track your internship postings.
                </p>
            </div>

            <a href="Opportunities.aspx" class="mo-btn">
                + Add opportunity
            </a>
        </div>

        <div class="mo-stats">

            <div class="mo-stat">
                <span class="mo-muted">Open opportunities</span>
                <strong><%: OpenCount %></strong>
                <span class="mo-muted">Accepting applications</span>
            </div>

            <div class="mo-stat">
                <span class="mo-muted">Drafts</span>
                <strong><%: DraftCount %></strong>
                <span class="mo-muted">Not published</span>
            </div>

            <div class="mo-stat">
                <span class="mo-muted">Closed opportunities</span>
                <strong><%: ClosedCount %></strong>
                <span class="mo-muted">
                    No longer accepting applications
                </span>
            </div>

        </div>

        <div class="mo-card">

            <h3>All opportunities</h3>
            <p class="mo-muted">
                <%: OpportunityItems.Count %>
                postings in total
            </p>

            <div class="mo-table-wrap">

                <table class="mo-table">

                    <thead>
                        <tr>
                            <th>Opportunity</th>
                            <th>Specialization</th>
                            <th>Seats</th>
                            <th>Deadline</th>
                            <th>Status</th>
                            <th>Actions</th>
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
                                              View
                                               </a>

                                        <!-- Edit Opportunity -->
                                               <a class="mo-btn mo-btn-light mo-small"
                                               href="ManageOpportunities.aspx?edit=<%: Server.UrlEncode(item.Id) %>">
                                                     Edit
                                            </a>


                                    <% if (item.Status != OpportunityStatus.Closed) { %>

                                        <button type="button"
                                           class="mo-btn mo-btn-light mo-small"
                                               data-id="<%: item.Id %>"
                                                       data-title="<%: item.Title %>"
                                             onclick="showCloseDialog(this.getAttribute('data-id'), this.getAttribute('data-title'))">
                                                                Close
                                                       </button>

                                              <% } %>

                                </div>
                            </td>

                        </tr>

                    <% } %>

                    <% if (OpportunityItems.Count == 0) { %>
                        <tr>
                            <td colspan="6" style="text-align:center;padding:30px;">
                                No opportunities created yet.
                            </td>
                        </tr>
                    <% } %>

                    </tbody>

                </table>

            </div>

        </div>

        <!-- Close Confirmation Dialog -->

        <div id="moDialog" class="mo-dialog"
            role="dialog" aria-modal="true"
            aria-labelledby="moDialogTitle">

            <div class="mo-dialog-box">

                <h3 id="moDialogTitle">
                    Close this opportunity?
                </h3>

                <p class="mo-muted">
                    <strong id="moCloseTitle"></strong>
                    will no longer accept new applications.
                    Existing applications will remain saved.
                </p>

                <div class="mo-dialog-actions">

                    <button type="button"
                        class="mo-btn mo-btn-light"
                        onclick="hideCloseDialog()">
                        Cancel
                    </button>

                    <button type="submit"
                        class="mo-btn mo-btn-danger"
                        name="moAction"
                        value="close"
                        onclick="document.getElementById('moCloseId').value = window.selectedOpportunityId;">
                        Close opportunity
                    </button>

                </div>

            </div>

        </div>

        <input type="hidden" name="moId"
            id="moCloseId" value="" />

    <% } else if (Viewing != null) { %>

        <!-- View Opportunity (read only) -->

        <a href="ManageOpportunities.aspx" class="mo-muted">
            &larr; Back to opportunities
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
                    Edit
                </a>
            </div>
        </div>

        <div class="mo-card">

            <h3>Opportunity information</h3>

            <div class="mo-view-grid">
                <div>
                    <span class="mo-muted">Department</span>
                    <p><%: TextOrDash(Viewing.Department) %></p>
                </div>
                <div>
                    <span class="mo-muted">Training mode</span>
                    <p><%: TextOrDash(Viewing.TrainingMode) %></p>
                </div>
                <div>
                    <span class="mo-muted">Location</span>
                    <p><%: TextOrDash(Viewing.Location) %></p>
                </div>
                <div>
                    <span class="mo-muted">Eligible college</span>
                    <p><%: TextOrDash(Viewing.EligibleCollege) %></p>
                </div>
                <div>
                    <span class="mo-muted">Eligible specializations</span>
                    <p><%: Viewing.EligibleMajors == null || Viewing.EligibleMajors.Count == 0
                            ? "-"
                            : string.Join(", ", Viewing.EligibleMajors) %></p>
                </div>
                <div>
                    <span class="mo-muted">Technologies used</span>
                    <p><%: TextOrDash(Viewing.TechnologiesUsed) %></p>
                </div>
            </div>

            <div class="mo-view-block">
                <span class="mo-muted">Description</span>
                <p><%: TextOrDash(Viewing.Description) %></p>
            </div>

            <div class="mo-view-block">
                <span class="mo-muted">Requirements</span>
                <p><%: TextOrDash(Viewing.Requirements) %></p>
            </div>

        </div>

        <div class="mo-card">

            <h3>Seats and dates</h3>

            <div class="mo-view-grid">
                <div>
                    <span class="mo-muted">Seats (filled / total)</span>
                    <p><%: Viewing.FilledSeats %> / <%: Viewing.TotalSeats %></p>
                </div>
                <div>
                    <span class="mo-muted">Duration</span>
                    <p><%: Viewing.DurationWeeks %> weeks</p>
                </div>
                <div>
                    <span class="mo-muted">Application deadline</span>
                    <p><%: TextOrDash(DateText(Viewing.ApplicationDeadline)) %></p>
                </div>
                <div>
                    <span class="mo-muted">Start date</span>
                    <p><%: TextOrDash(DateText(Viewing.StartDate)) %></p>
                </div>
                <div>
                    <span class="mo-muted">End date</span>
                    <p><%: TextOrDash(DateText(Viewing.EndDate)) %></p>
                </div>
            </div>

        </div>

    <% } else { %>

        <!-- Edit Opportunity -->

        <a href="ManageOpportunities.aspx" class="mo-muted">
            &larr; Back to opportunities
        </a>

        <div class="mo-heading" style="margin-top:15px;">
            <div>
                <h2>Edit opportunity</h2>
                <p class="mo-muted">
                    Update the details and save your changes.
                </p>
            </div>

            <span class="mo-badge">
                <%: Editing.Status.ToString() %>
            </span>
        </div>

        <div class="mo-card">

            <h3>Opportunity information</h3>
            <p class="mo-muted" style="margin-bottom:22px;">
                Provide the main details of this opportunity.
            </p>

            <input type="hidden" name="moId"
                value="<%: Editing.Id %>" />

            <div class="mo-form-grid">

                <div class="mo-field">
                    <label>Opportunity title *</label>
                    <input name="moTitle"
                        maxlength="160"
                        value="<%: Editing.Title %>" />
                </div>

                <div class="mo-field">
                    <label>Department *</label>
                    <input name="moDepartment"
                        maxlength="120"
                        value="<%: Editing.Department %>" />
                </div>

                <div class="mo-field">
                    <label>Eligible college</label>
                    <input readonly="readonly"
                        value="<%: CollegeName %>" />
                </div>

                <div class="mo-field">
                    <label>Training mode</label>
                    <select name="moMode">
                        <option value="On-site"
                            <%= Editing.TrainingMode == "On-site" ? "selected" : "" %>>
                            On-site
                        </option>
                        <option value="Hybrid"
                            <%= Editing.TrainingMode == "Hybrid" ? "selected" : "" %>>
                            Hybrid
                        </option>
                        <option value="Remote"
                            <%= Editing.TrainingMode == "Remote" ? "selected" : "" %>>
                            Remote
                        </option>
                    </select>
                </div>

                <div class="mo-field">
                    <label>Location *</label>
                    <input name="moLocation"
                        maxlength="160"
                        value="<%: Editing.Location %>" />
                </div>

                <div class="mo-field">
                    <label>Technologies used</label>
                    <input name="moTechnologies"
                        maxlength="1000"
                        value="<%: Editing.TechnologiesUsed %>" />
                </div>

            </div>

            <div class="mo-field">
                <label>Eligible specializations *</label>

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
                <label>Description *</label>
                <textarea name="moDescription"
                    maxlength="5000"><%: Editing.Description %></textarea>
            </div>

            <div class="mo-field">
                <label>Requirements *</label>
                <textarea name="moRequirements"
                    maxlength="3000"><%: Editing.Requirements %></textarea>
            </div>

            <div class="mo-form-grid">

                <div class="mo-field">
                    <label>Available seats *</label>
                    <input type="number"
                        name="moSeats"
                        min="1"
                        max="10000"
                        value="<%: Editing.TotalSeats %>" />
                </div>

                <div class="mo-field">
                    <label>Duration (weeks) *</label>
                    <input type="number"
                        name="moDuration"
                        min="1"
                        max="104"
                        value="<%: Editing.DurationWeeks %>" />
                </div>

                <div class="mo-field">
                    <label>Application deadline *</label>
                    <input type="date"
                        name="moDeadline"
                        value="<%: DateText(Editing.ApplicationDeadline) %>" />
                </div>

                <div class="mo-field">
                    <label>Start date *</label>
                    <input type="date"
                        name="moStart"
                        value="<%: DateText(Editing.StartDate) %>" />
                </div>

                <div class="mo-field">
                    <label>End date *</label>
                    <input type="date"
                        name="moEnd"
                        value="<%: DateText(Editing.EndDate) %>" />
                </div>

            </div>

            <div class="mo-form-footer">

                <a class="mo-btn mo-btn-light"
                    href="ManageOpportunities.aspx">
                    Cancel
                </a>

                <button type="submit"
                    class="mo-btn"
                    name="moAction"
                    value="save">
                    Save changes
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
