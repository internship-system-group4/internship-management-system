
<%@ Page Title="Add Opportunity"
    Language="C#"
    MasterPageFile="~/Layout/Company.master"
    AutoEventWireup="true"
    CodeBehind="Opportunities.aspx.cs"
    Inherits="InternshipManagementSystem.Pages.CompanyArea.Opportunities" %>

<asp:Content ID="Head" ContentPlaceHolderID="head"
    runat="server">

<style>
.op-page {
    max-width: 1120px;
    margin: 0 auto;
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
    margin: 14px 0 24px;
}

.op-heading h2 {
    font-size: 26px;
    font-weight: 750;
    margin-bottom: 6px;
}

.op-heading p {
    color: var(--th-fg-718298,#718298);
    font-size: 14px;
}

.op-card {
    background: var(--ui-surface,#fff);
    border: 1px solid var(--th-line-dce5ef,#dce5ef);
    border-radius: 12px;
    padding: 26px;
    max-width: 850px;
}

.op-card h3 {
    font-size: 17px;
    font-weight: 750;
    margin-bottom: 5px;
}

.op-subtitle {
    color: var(--th-fg-718298,#718298);
    font-size: 13px;
    margin-bottom: 24px;
}

.op-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 18px;
}

.op-field {
    margin-bottom: 19px;
}

.op-field label {
    display: block;
    font-size: 13px;
    font-weight: 700;
    margin-bottom: 7px;
}

.op-field input,
.op-field select,
.op-field textarea {
    width: 100%;
    padding: 11px 12px;
    border: 1px solid var(--th-line-d6e1eb,#d6e1eb);
    border-radius: 7px;
    background: var(--ui-surface,#fff);
    color: var(--th-fg-173451,#173451);
    font: inherit;
    font-size: 14px;
    box-sizing: border-box;
}

.op-field textarea {
    min-height: 105px;
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
    color: var(--th-fg-7a8ba0,#7a8ba0);
    font-size: 12px;
}

.op-majors {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    margin-top: 8px;
}

.op-major {
    border: 1px solid var(--th-line-dbe5ef,#dbe5ef);
    border-radius: 8px;
    padding: 9px 12px;
    font-size: 13px;
    background: var(--th-bg-f8fafc,#f8fafc);
}

.op-major input {
    width: auto;
    margin-inline-end: 6px;
}

.op-footer {
    border-top: 1px solid var(--th-line-e5ebf1,#e5ebf1);
    padding-top: 20px;
    margin-top: 14px;
    display: flex;
    justify-content: flex-end;
    align-items: center;
    flex-wrap: wrap;
    gap: 10px;
}

.op-btn {
    padding: 11px 19px;
    border-radius: 7px;
    font-size: 13px;
    font-weight: 700;
    cursor: pointer;
    text-decoration: none;
    border: 1px solid var(--th-line-244f77,#244f77);
    background: var(--th-bg-244f77,#244f77);
    color: #fff;
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
    max-width: 850px;
}

.op-notice.error {
    background: var(--th-bg-fff0ed,#fff0ed);
    color: var(--th-fg-a3392b,#a3392b);
}

@media (max-width: 650px) {
    .op-grid {
        grid-template-columns: 1fr;
    }

    .op-card {
        padding: 17px;
    }
}
</style>

</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent"
    runat="server">

<div class="op-page">

    <a class="op-back" href="ManageOpportunities.aspx">
        <%: L.T("Company.Opportunities.BackToOpportunities") %>
    </a>

    <div class="op-heading">
        <h2><%: L.T("Company.Opportunities.AddNewOpportunity") %></h2>
        <p>
            <%: L.T("Company.Opportunities.CompleteTheDetailsBelowToCreate") %>
        </p>
    </div>

    <% if (!string.IsNullOrEmpty(Notice)) { %>
        <div class='op-notice <%= IsError ? "error" : "" %>'>
            <%: Notice %>
        </div>
    <% } %>

    <div class="op-card">

        <h3><%: L.T("Company.Opportunities.BasicInformation") %></h3>
        <p class="op-subtitle">
            <%: L.T("Company.Opportunities.ProvideTheMainDetailsOfThis") %>
        </p>

        <div class="op-grid">

            <div class="op-field">
                <label for="opTitle"><%: L.T("Company.Opportunities.OpportunityTitle") %></label>
                <input id="opTitle" name="opTitle"
                    maxlength="160"
                    placeholder="<%: L.T("Company.Opportunities.EGWebDeveloperIntern") %>"
                    value="<%: Request.Form["opTitle"] %>" />
            </div>

            <div class="op-field">
                <label for="opDepartment"><%: L.T("Company.Opportunities.Department") %></label>
                <input id="opDepartment" name="opDepartment"
                    maxlength="120"
                    placeholder="<%: L.T("Company.Opportunities.EGInformationTechnology") %>"
                    value="<%: Request.Form["opDepartment"] %>" />
            </div>

            <div class="op-field">
                <label><%: L.T("Company.Opportunities.EligibleCollege") %></label>
                <input value="<%: CollegeName %>"
                    readonly="readonly" />
            </div>

            <div class="op-field">
                <label for="opType"><%: L.T("Company.Opportunities.OpportunityType") %></label>
                <select id="opType" name="opType">
                    <option value="Internship"><%: L.T("Shared.Value.OpportunityType.Internship") %></option>
                </select>
            </div>

            <div class="op-field">
                <label for="opLocation"><%: L.T("Company.Opportunities.Location") %></label>
                <input id="opLocation" name="opLocation"
                    maxlength="160"
                    placeholder="<%: L.T("Company.Opportunities.EGAmmanJordan") %>"
                    value="<%: Request.Form["opLocation"] %>" />
            </div>

            <div class="op-field">
                <label for="opMode"><%: L.T("Company.Opportunities.TrainingMode") %></label>
                <select id="opMode" name="opMode">
                    <option value="On-site"><%: L.T("Shared.Value.TrainingMode.Onsite") %></option>
                    <option value="Hybrid"><%: L.T("Shared.Value.TrainingMode.Hybrid") %></option>
                    <option value="Remote"><%: L.T("Shared.Value.TrainingMode.Remote") %></option>
                </select>
            </div>

        </div>

        <div class="op-field">
            <label><%: L.T("Company.Opportunities.EligibleSpecializations") %></label>

            <div class="op-majors">
                <% foreach (string major in Majors) { %>
                    <label class="op-major">
                        <input type="checkbox"
                            name="opMajors"
                            value="<%: major %>" />
                        <%: major %>
                    </label>
                <% } %>
            </div>

            <span class="op-hint">
                <%: L.T("Company.Opportunities.SelectTheUniversityMajorsEligibleTo") %>
            </span>
        </div>

        <div class="op-field">
            <label for="opDescription"><%: L.T("Company.Opportunities.Description") %></label>
            <textarea id="opDescription"
                name="opDescription"
                maxlength="5000"
                placeholder="<%: L.T("Company.Opportunities.DescribeTheRoleResponsibilitiesAndLearning") %>"><%: Request.Form["opDescription"] %></textarea>
        </div>

        <div class="op-field">
            <label for="opRequirements"><%: L.T("Company.Opportunities.Requirements") %></label>
            <textarea id="opRequirements"
                name="opRequirements"
                maxlength="3000"
                placeholder="<%: L.T("Company.Opportunities.ListTheSkillsQualificationsAndRequirements") %>"><%: Request.Form["opRequirements"] %></textarea>
        </div>

        <div class="op-field">
            <label for="opTechnologies">
                <%: L.T("Company.Opportunities.TechnologiesUsed") %>
            </label>
            <input id="opTechnologies"
                name="opTechnologies"
                maxlength="1000"
                placeholder="<%: L.T("Company.Opportunities.EGCASPNETSQL") %>"
                value="<%: Request.Form["opTechnologies"] %>" />
        </div>

        <div class="op-grid">

            <div class="op-field">
                <label for="opSeats"><%: L.T("Company.Opportunities.AvailableSeats") %></label>
                <input id="opSeats" name="opSeats"
                    type="number" min="1" max="10000"
                    placeholder="e.g. 5"
                    value="<%: Request.Form["opSeats"] %>" />
            </div>

            <div class="op-field">
                <label for="opDuration">
                    <%: L.T("Company.Opportunities.DurationWeeks") %>
                </label>
                <input id="opDuration" name="opDuration"
                    type="number" min="1" max="104"
                    placeholder="e.g. 12"
                    value="<%: Request.Form["opDuration"] %>" />
            </div>

            <div class="op-field">
                <label for="opDeadline">
                    <%: L.T("Company.Opportunities.ApplicationDeadline") %>
                </label>
                <input id="opDeadline" name="opDeadline"
                    type="date"
                    value="<%: Request.Form["opDeadline"] %>" />
            </div>

            <div class="op-field">
                <label for="opStart"><%: L.T("Company.Opportunities.StartDate") %></label>
                <input id="opStart" name="opStart"
                    type="date"
                    value="<%: Request.Form["opStart"] %>" />
            </div>

            <div class="op-field">
                <label for="opEnd"><%: L.T("Company.Opportunities.EndDate") %></label>
                <input id="opEnd" name="opEnd"
                    type="date"
                    value="<%: Request.Form["opEnd"] %>" />
            </div>

        </div>

        <div class="op-footer">
            <a class="op-btn op-btn-light"
                href="ManageOpportunities.aspx">
                <%: L.T("Company.Opportunities.Cancel") %>
            </a>

            <button class="op-btn op-btn-light"
                type="submit" name="opAction" value="draft" data-ui-action="save" data-ui-validation="none" data-loading-label="Saving…">
                <%: L.T("Company.Opportunities.SaveDraft") %>
            </button>

            <button class="op-btn"
                type="submit" name="opAction" value="publish" data-ui-action="publish" data-ui-validation="none" data-loading-label="Publishing…">
                <%: L.T("Company.Opportunities.Publish") %>
            </button>
        </div>

    </div>

</div>

</asp:Content>
