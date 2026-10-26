
<%@ Page Title="Add Opportunity"
    Language="C#"
    MasterPageFile="~/Layout/Company.master"
    AutoEventWireup="true"
    CodeBehind="Opportunities.aspx.cs"
    Inherits="InternshipManagementSystem.Pages.CompanyArea.Opportunities" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">

<style>
.op-page {
    width: 100%;
    max-width: 1280px;
    margin: 0 auto;
    box-sizing: border-box;
    color: var(--th-fg-173451,#173451);
    font-family: inherit;
}

.op-back {
    color: var(--th-fg-285781,#285781);
    text-decoration: none;
    font-size: 13px;
    font-weight: 600;
}

.op-heading {
    margin: 12px 0 18px;
}

.op-heading h2 {
    font-size: 26px;
    font-weight: 750;
    margin-bottom: 4px;
}

.op-heading p {
    margin: 0;
    color: var(--ui-muted);
    font-size: 14px;
}

.op-card {
    width: 100%;
    max-width: none;
    box-sizing: border-box;
    padding: 24px 28px;
    border: 1.5px solid var(--th-line-ccd9e7,#ccd9e7);
    border-radius: 11px;
    background: var(--ui-surface,#ffffff);
    box-shadow: 0 2px 8px rgba(23,52,81,.035);
}

.op-card h3 {
    font-size: 17px;
    font-weight: 750;
    margin-bottom: 5px;
}

.op-subtitle {
    color: var(--ui-muted);
    font-size: 13px;
    margin-bottom: 18px;
}

.op-grid {
    display: grid;
    grid-template-columns: repeat(2,minmax(0,1fr));
    gap: 12px 22px;
}

.op-field {
    margin-bottom: 12px;
}

.op-field label {
    display: block;
    font-size: 13px;
    font-weight: 700;
    margin-bottom: 6px;
}

.op-field input,
.op-field select,
.op-field textarea {
    width: 100%;
    padding: 10px 12px;
    border: 1px solid var(--th-line-d0dce8,#d0dce8);
    border-radius: 7px;
    background: var(--ui-surface,#fff);
    color: var(--th-fg-173451,#173451);
    font: inherit;
    font-size: 14px;
    box-sizing: border-box;
}

.op-field textarea {
    min-height: 95px;
    resize: vertical;
}

.op-field input:focus,
.op-field select:focus,
.op-field textarea:focus {
    outline: 2px solid var(--th-line-9ec3e8,#9ec3e8);
    border-color: var(--th-line-4979a8,#4979a8);
}

.op-hint {
    display: block;
    margin-top: 6px;
    color: var(--ui-muted);
    font-size: 12px;
}

.op-majors {
    display: flex;
    flex-wrap: wrap;
    gap: 9px;
    margin-top: 6px;
}

.op-major {
    border: 1px solid var(--th-line-dbe5ef,#dbe5ef);
    border-radius: 8px;
    padding: 8px 11px;
    font-size: 13px;
    background: var(--th-bg-f8fafc,#f8fafc);
}

.op-major input {
    width: auto;
    margin-inline-end: 6px;
}

.op-footer {
    border-top: 1px solid var(--th-line-e5ebf1,#e5ebf1);
    padding-top: 18px;
    margin-top: 12px;
    display: flex;
    justify-content: flex-end;
    align-items: center;
    flex-wrap: wrap;
    gap: 9px;
}

.op-btn {
    padding: 10px 18px;
    border-radius: 7px;
    font-size: 13px;
    font-weight: 700;
    cursor: pointer;
    text-decoration: none;
    border: 1px solid var(--th-line-244f77,#244f77);
    background: var(--th-bg-244f77,#244f77);
    color: #fff;
    transition: background-color .2s ease,
                border-color .2s ease;
}

.op-btn-light {
    background: var(--ui-surface,#fff);
    color: var(--th-fg-244f77,#244f77);
}

.op-btn:hover {
    filter: brightness(.94);
}

.op-notice {
    padding: 13px 16px;
    border-radius: 8px;
    background: var(--th-bg-e6f5ed,#e6f5ed);
    color: var(--th-fg-17613d,#17613d);
    margin-bottom: 20px;
    max-width: none;
    box-sizing: border-box;
}

.op-notice.error {
    background: var(--th-bg-fff0ed,#fff0ed);
    color: var(--th-fg-a3392b,#a3392b);
}

/* Required stars */
.op-required-star {
    color: var(--th-fg-dc2626,#dc2626) !important;
    font-weight: 800;
}


@media (max-width: 900px) {
    .op-card {
        padding: 20px;
    }

    .op-grid {
        gap: 10px 16px;
    }
}

@media (max-width: 650px) {
    .op-page {
        width: 100%;
    }

    .op-card {
        background: var(--ui-surface,#ffffff);
        border: 2px solid var(--th-line-b8cadc,#b8cadc);
        border-radius: 12px;
        padding: 24px 28px;
        width: 100%;
        max-width: none;
        box-sizing: border-box;
        box-shadow: 0 3px 12px rgba(23,52,81,.06);
    }

    .op-grid {
        grid-template-columns: 1fr;
        gap: 0;
    }

    .op-footer {
        justify-content: flex-start;
    }
}
</style>
<link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/opportunity-form.css?v=20261026-1") %>" />

</asp:Content>

<asp:Content ID="Body"
    ContentPlaceHolderID="MainContent"
    runat="server">

<div class="op-page">

    <a class="op-back" href="ManageOpportunities.aspx">
        <%: L.T("Company.Opportunities.BackToOpportunities") %>
    </a>

    <div class="op-heading">
        <h2><%: L.T("Company.Opportunities.AddNewOpportunity") %></h2>
        <p><%: L.T("Company.Opportunities.CompleteTheDetailsBelowToCreate") %></p>
    </div>

    <% if (!string.IsNullOrEmpty(Notice)) { %>
        <div class='op-notice <%= IsError ? "error" : "" %>' role="alert">
            <%: Notice %>
        </div>
    <% } %>

    <div class="op-card oppf"
         data-opp-form
         data-prefix="op"
         data-past-rule="always"
         data-filled="0"
         data-today="<%: Today %>"
         data-messages="<%: MessagesJson %>">

        <div class="oppf-summary" data-summary role="alert" hidden></div>

        <!-- 1. Basic details -->
        <section class="oppf-step">
            <h3><span class="oppf-step-no">1</span><%: L.T("Company.OpportunityForm.StepBasics") %></h3>

            <div class="op-grid">
                <div class="op-field<%= Invalid("Title") %>" data-field>
                    <label for="opTitle"><%: L.T("Company.Opportunities.OpportunityTitle") %></label>
                    <input id="opTitle" name="opTitle" maxlength="160" autocomplete="off"
                        placeholder="<%: L.T("Company.Opportunities.EGWebDeveloperIntern") %>"
                        value="<%: Posted("opTitle") %>" />
                    <span class="oppf-error" data-error-for="Title" <%= Hidden("Title") %>><%: Error("Title") %></span>
                </div>

                <div class="op-field<%= Invalid("Department") %>" data-field>
                    <label for="opDepartment"><%: L.T("Company.Opportunities.Department") %></label>
                    <input id="opDepartment" name="opDepartment" maxlength="120"
                        placeholder="<%: L.T("Company.Opportunities.EGInformationTechnology") %>"
                        value="<%: Posted("opDepartment") %>" />
                    <span class="oppf-error" data-error-for="Department" <%= Hidden("Department") %>><%: Error("Department") %></span>
                </div>

                <div class="op-field<%= Invalid("Location") %>" data-field>
                    <label for="opLocation"><%: L.T("Company.Opportunities.Location") %></label>
                    <input id="opLocation" name="opLocation" maxlength="160"
                        placeholder="<%: L.T("Company.Opportunities.EGAmmanJordan") %>"
                        value="<%: Posted("opLocation") %>" />
                    <span class="oppf-error" data-error-for="Location" <%= Hidden("Location") %>><%: Error("Location") %></span>
                </div>

                <div class="op-field<%= Invalid("Mode") %>" data-field>
                    <label for="opMode"><%: L.T("Company.Opportunities.TrainingMode") %></label>
                    <select id="opMode" name="opMode">
                        <option value="On-site" <%= Selected("opMode", "On-site", true) %>><%: L.T("Shared.Value.TrainingMode.Onsite") %></option>
                        <option value="Hybrid" <%= Selected("opMode", "Hybrid", false) %>><%: L.T("Shared.Value.TrainingMode.Hybrid") %></option>
                        <option value="Remote" <%= Selected("opMode", "Remote", false) %>><%: L.T("Shared.Value.TrainingMode.Remote") %></option>
                    </select>
                    <span class="oppf-error" data-error-for="Mode" <%= Hidden("Mode") %>><%: Error("Mode") %></span>
                </div>
            </div>
            <input type="hidden" name="opType" value="Internship" />
        </section>

        <!-- 2. Who can apply -->
        <section class="oppf-step">
            <h3><span class="oppf-step-no">2</span><%: L.T("Company.OpportunityForm.StepWho") %></h3>
            <p class="op-hint oppf-lead"><%: L.T("Company.Opportunities.EligibleCollege") %>: <strong><%: CollegeName %></strong></p>

            <div class="op-field<%= Invalid("Majors") %>" data-field>
                <span class="oppf-label"><%: L.T("Company.Opportunities.EligibleSpecializations") %></span>
                <div class="op-majors" role="group" aria-label="<%: L.T("Company.Opportunities.EligibleSpecializations") %>">
                    <% foreach (string major in Majors) { %>
                        <label class="op-major">
                            <input type="checkbox" name="opMajors" value="<%: major %>" <%= MajorChecked(major) %> />
                            <%: major %>
                        </label>
                    <% } %>
                </div>
                <span class="oppf-error" data-error-for="Majors" <%= Hidden("Majors") %>><%: Error("Majors") %></span>
            </div>
        </section>

        <!-- 3. About the role -->
        <section class="oppf-step">
            <h3><span class="oppf-step-no">3</span><%: L.T("Company.OpportunityForm.StepRole") %></h3>

            <div class="op-field<%= Invalid("Description") %>" data-field>
                <label for="opDescription"><%: L.T("Company.Opportunities.Description") %></label>
                <textarea id="opDescription" name="opDescription" maxlength="5000"
                    placeholder="<%: L.T("Company.Opportunities.DescribeTheRoleResponsibilitiesAndLearning") %>"><%: Posted("opDescription") %></textarea>
                <span class="op-hint"><%: L.T("Company.OpportunityForm.DescriptionHint") %></span>
                <span class="oppf-error" data-error-for="Description" <%= Hidden("Description") %>><%: Error("Description") %></span>
            </div>

            <div class="op-grid">
                <div class="op-field<%= Invalid("Requirements") %>" data-field>
                    <label for="opRequirements"><%: L.T("Company.Opportunities.Requirements") %></label>
                    <textarea id="opRequirements" name="opRequirements" maxlength="3000"
                        placeholder="<%: L.T("Company.Opportunities.ListTheSkillsQualificationsAndRequirements") %>"><%: Posted("opRequirements") %></textarea>
                    <span class="oppf-error" data-error-for="Requirements" <%= Hidden("Requirements") %>><%: Error("Requirements") %></span>
                </div>

                <div class="op-field<%= Invalid("Technologies") %>" data-field>
                    <label for="opTechnologies"><%: L.T("Company.Opportunities.TechnologiesUsed") %></label>
                    <textarea id="opTechnologies" name="opTechnologies" maxlength="1000" class="oppf-short"
                        placeholder="<%: L.T("Company.Opportunities.EGCASPNETSQL") %>"><%: Posted("opTechnologies") %></textarea>
                    <span class="oppf-error" data-error-for="Technologies" <%= Hidden("Technologies") %>><%: Error("Technologies") %></span>
                </div>
            </div>
        </section>

        <!-- 4. Seats and dates: last date to apply -> start -> end -->
        <section class="oppf-step">
            <h3><span class="oppf-step-no">4</span><%: L.T("Company.OpportunityForm.StepDates") %></h3>
            <p class="op-hint oppf-lead"><%: L.T("Company.OpportunityForm.DatesHelp") %></p>

            <div class="oppf-dates">
                <div class="op-field<%= Invalid("Seats") %>" data-field>
                    <label for="opSeats"><%: L.T("Company.Opportunities.AvailableSeats") %></label>
                    <input id="opSeats" name="opSeats" type="number" min="1" max="500" step="1" inputmode="numeric"
                        placeholder="5" value="<%: Posted("opSeats") %>" />
                    <span class="oppf-error" data-error-for="Seats" <%= Hidden("Seats") %>><%: Error("Seats") %></span>
                </div>

                <div class="op-field<%= Invalid("Deadline") %>" data-field>
                    <label for="opDeadline"><%: L.T("Company.Opportunities.ApplicationDeadline") %></label>
                    <input id="opDeadline" name="opDeadline" type="date" min="<%: Today %>" value="<%: Posted("opDeadline") %>" />
                    <span class="oppf-error" data-error-for="Deadline" <%= Hidden("Deadline") %>><%: Error("Deadline") %></span>
                </div>

                <div class="op-field<%= Invalid("Start") %>" data-field>
                    <label for="opStart"><%: L.T("Company.Opportunities.StartDate") %></label>
                    <input id="opStart" name="opStart" type="date" value="<%: Posted("opStart") %>" />
                    <span class="oppf-error" data-error-for="Start" <%= Hidden("Start") %>><%: Error("Start") %></span>
                </div>

                <div class="op-field" data-field>
                    <span class="oppf-label"><%: L.T("Company.ManageOpportunities.EndDate") %></span>
                    <div class="oppf-auto" data-end-date><%: AutoEndText %></div>
                    <span class="op-hint"><%: L.T("Company.OpportunityForm.EndAuto") %></span>
                </div>
            </div>

            <p class="oppf-duration" data-duration data-empty="<%: L.T("Company.OpportunityForm.DurationEmpty") %>" aria-live="polite"><%: DurationText %></p>
        </section>

        <div class="op-footer">
            <span class="op-hint oppf-footer-hint"><%: L.T("Company.OpportunityForm.DraftHint") %></span>

            <a class="op-btn op-btn-light" href="ManageOpportunities.aspx">
                <%: L.T("Company.Opportunities.Cancel") %>
            </a>

            <button class="op-btn op-btn-light" type="submit" name="opAction" value="draft"
                data-opp-submit="draft"
                data-ui-action="save" data-ui-validation="none"
                data-loading-label="<%: L.T("Shared.I18n.Saving") %>">
                <%: L.T("Company.Opportunities.SaveDraft") %>
            </button>

            <button class="op-btn" type="submit" name="opAction" value="publish"
                data-opp-submit="complete"
                data-ui-action="publish" data-ui-validation="none"
                data-loading-label="<%: L.T("Shared.I18n.Publishing") %>">
                <%: L.T("Company.Opportunities.Publish") %>
            </button>
        </div>
    </div>
</div>

<script src="<%: ResolveUrl("~/Assets/js/opportunity-form.js?v=20261026-2") %>"></script>
</asp:Content>
