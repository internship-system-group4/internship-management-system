
<%@ Page Title="Edit & Close Opportunities"
    Language="C#"
    MasterPageFile="~/Layout/Company.master"
    AutoEventWireup="true"
    CodeBehind="ManageOpportunities.aspx.cs"
    Inherits="InternshipManagementSystem.Pages.CompanyArea.ManageOpportunities" %>

<asp:Content ID="Head"
    ContentPlaceHolderID="head"
    runat="server">

<style>
.mo-wrap {
    max-width: 1100px;
    margin: 0 auto;
    color: var(--ink, #172b49);
}

.mo-top {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 15px;
    flex-wrap: wrap;
    margin-bottom: 22px;
}

.mo-top h2 {
    font-weight: 750;
    font-size: 1.65rem;
}

.mo-muted {
    color: var(--muted, #64748b);
}

.mo-card {
    background: var(--surface, #fff);
    border: 1px solid var(--line, #dce5ef);
    border-radius: 16px;
    padding: 22px;
    margin-bottom: 18px;
    box-shadow: 0 4px 16px rgba(17,36,64,.035);
}

.mo-list {
    display: grid;
    gap: 14px;
}

.mo-item {
    display: flex;
    justify-content: space-between;
    gap: 18px;
    align-items: center;
    flex-wrap: wrap;
}

.mo-item h3 {
    font-size: 1.08rem;
    font-weight: 700;
    margin: 0 0 6px;
}

.mo-meta {
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
    color: #617089;
    font-size: .9rem;
}

.mo-badge {
    display: inline-block;
    padding: 4px 11px;
    border-radius: 20px;
    font-size: .8rem;
    font-weight: 700;
    background: #e8f5ed;
    color: #18603b;
}

.mo-badge.closed {
    background: #f1f2f6;
    color: #64748b;
}

.mo-badge.draft {
    background: #fff2dc;
    color: #8b5e16;
}

.mo-actions {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
}

.mo-btn {
    border: 0;
    border-radius: 9px;
    padding: 10px 17px;
    font-weight: 700;
    background: var(--brand, #2259a5);
    color: white;
    cursor: pointer;
    text-decoration: none;
    display: inline-block;
}

.mo-btn:hover {
    color: white;
    filter: brightness(.94);
}

.mo-outline {
    background: #fff;
    color: var(--brand, #2259a5);
    border: 1px solid #c6d4e7;
}

.mo-outline:hover {
    color: var(--brand, #2259a5);
}

.mo-danger {
    background: #a52b40;
}

.mo-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 16px;
}

.mo-field {
    display: flex;
    flex-direction: column;
    gap: 6px;
}

.mo-field.full {
    grid-column: 1 / -1;
}

.mo-field label {
    font-weight: 650;
    font-size: .91rem;
}

.mo-field input,
.mo-field textarea,
.mo-field select {
    border: 1px solid #cbd5e1;
    border-radius: 9px;
    padding: 10px 12px;
    background: #fff;
    width: 100%;
}

.mo-field textarea {
    min-height: 105px;
}

.mo-checks {
    display: flex;
    gap: 15px;
    flex-wrap: wrap;
}

.mo-checks label {
    font-weight: 400;
}

.mo-checks input {
    width: auto;
    margin-right: 5px;
}

.mo-alert {
    padding: 13px 16px;
    border-radius: 9px;
    background: #eaf6ed;
    color: #17633d;
    margin-bottom: 18px;
}

.mo-alert.error {
    background: #fff0f0;
    color: #9c2334;
}

.mo-foot {
    display: flex;
    justify-content: flex-end;
    gap: 10px;
    margin-top: 20px;
}

.mo-empty {
    text-align: center;
    padding: 40px;
    color: #64748b;
}

@media (max-width: 650px) {
    .mo-grid {
        grid-template-columns: 1fr;
    }

    .mo-item {
        align-items: flex-start;
    }
}
</style>

</asp:Content>

<asp:Content ID="Body"
    ContentPlaceHolderID="MainContent"
    runat="server">

<div class="mo-wrap">

    <div class="mo-top">
        <div>
            <h2>Manage Internship Opportunities</h2>
            <p class="mo-muted">
                Edit or close opportunities belonging to your company.
            </p>
        </div>

        <a class="mo-btn" href="Opportunities.aspx">
            + Create Opportunity
        </a>
    </div>

    <% if (!string.IsNullOrEmpty(Notice)) { %>

        <div class="mo-alert <%= NoticeIsError ? "error" : "" %>"
             role="alert">
            <%: Notice %>
        </div>

    <% } %>

    <% if (Editing != null) { %>

    <section class="mo-card">

        <h3>Edit Opportunity</h3>

        <p class="mo-muted">
            Update the opportunity details below.
            Changes will be saved to Firebase.
            Company ownership and filled seats cannot be changed.
        </p>

        <input type="hidden"
               name="moAction"
               value="save" />

        <input type="hidden"
               name="moId"
               value="<%: Editing.Id %>" />

        <div class="mo-grid">

            <div class="mo-field full">
                <label for="moTitle">
                    Opportunity Title *
                </label>

                <input id="moTitle"
                       name="moTitle"
                       type="text"
                       maxlength="160"
                       required
                       value="<%: Field("moTitle", Editing.Title) %>" />
            </div>

            <div class="mo-field">
                <label for="moLocation">
                    Location *
                </label>

                <input id="moLocation"
                       name="moLocation"
                       type="text"
                       maxlength="160"
                       required
                       value="<%: Field("moLocation", Editing.Location) %>" />
            </div>

            <div class="mo-field">
                <label for="moCollege">
                    Eligible College *
                </label>

                <select id="moCollege"
                        name="moCollege"
                        required>

                    <option value="<%: College %>">
                        <%: College %>
                    </option>

                </select>
            </div>

            <div class="mo-field full">
                <label for="moDescription">
                    Description *
                </label>

                <textarea id="moDescription"
                          name="moDescription"
                          maxlength="5000"
                          required><%: Field("moDescription", Editing.Description) %></textarea>
            </div>

            <div class="mo-field full">
                <label for="moRequirements">
                    Requirements *
                </label>

                <textarea id="moRequirements"
                          name="moRequirements"
                          maxlength="3000"
                          required><%: Field("moRequirements", Editing.Requirements) %></textarea>
            </div>

            <div class="mo-field full">

                <label>
                    Eligible Majors *
                </label>

                <div class="mo-checks">

                    <% foreach (string major in Programs) { %>

                        <label>
                            <input type="checkbox"
                                   name="moMajors"
                                   value="<%: major %>"
                                   <%= MajorChecked(major) ? "checked" : "" %> />

                            <%: major %>
                        </label>

                    <% } %>

                </div>
            </div>

            <div class="mo-field">
                <label for="moSeats">
                    Total Seats *
                </label>

                <input id="moSeats"
                       type="number"
                       name="moSeats"
                       min="1"
                       max="10000"
                       required
                       value="<%: Field("moSeats", Editing.TotalSeats.ToString()) %>" />
            </div>

            <div class="mo-field">
                <label for="moDuration">
                    Duration (Weeks) *
                </label>

                <input id="moDuration"
                       type="number"
                       name="moDuration"
                       min="1"
                       max="104"
                       required
                       value="<%: Field("moDuration", Editing.DurationWeeks.ToString()) %>" />
            </div>

            <div class="mo-field">
                <label for="moDeadline">
                    Application Deadline *
                </label>

                <input id="moDeadline"
                       type="date"
                       name="moDeadline"
                       required
                       value="<%: Field("moDeadline", DateValue(Editing.ApplicationDeadline)) %>" />
            </div>

            <div class="mo-field">
                <label for="moStart">
                    Expected Start Date *
                </label>

                <input id="moStart"
                       type="date"
                       name="moStart"
                       required
                       value="<%: Field("moStart", DateValue(Editing.StartDate)) %>" />
            </div>

        </div>

        <div class="mo-foot">

            <a href="ManageOpportunities.aspx"
               class="mo-btn mo-outline">
                Cancel
            </a>

            <button type="submit"
                    class="mo-btn">
                Save Changes
            </button>

        </div>

    </section>

    <% } else { %>

    <div class="mo-list">

        <% if (OpportunityItems.Count == 0) { %>

            <div class="mo-card mo-empty">
                No opportunities found for your company.
                Create your first opportunity to get started.
            </div>

        <% } %>

        <% foreach (var item in OpportunityItems) { %>

        <article class="mo-card mo-item">

            <div>

                <h3>
                    <%: item.Title %>
                </h3>

                <div class="mo-meta">

                    <span>
                        <%: item.Location %>
                    </span>

                    <span>
                        <%: item.TotalSeats - item.FilledSeats %>
                        seats remaining
                    </span>

                    <span>
                        Deadline:
                        <%: DateValue(item.ApplicationDeadline) %>
                    </span>

                    <span class="mo-badge
                        <%= item.Status ==
                            InternshipManagementSystem.Common.OpportunityStatus.Closed
                            ? "closed"
                            : (item.Status ==
                                InternshipManagementSystem.Common.OpportunityStatus.Draft
                                ? "draft"
                                : "") %>">

                        <%: item.Status %>

                    </span>

                </div>

            </div>

            <div class="mo-actions">

                <a class="mo-btn mo-outline"
                   href="ManageOpportunities.aspx?edit=<%: Server.UrlEncode(item.Id) %>">
                    Edit
                </a>

                <% if (item.Status !=
                    InternshipManagementSystem.Common.OpportunityStatus.Closed) { %>

                    <button type="submit"
                            name="moClose"
                            value="<%: item.Id %>"
                            class="mo-btn mo-danger"
                            onclick="return confirm('Close this opportunity? Students will no longer be able to apply.');">
                        Close
                    </button>

                <% } %>

            </div>

        </article>

        <% } %>

    </div>

    <% } %>

</div>

</asp:Content>
