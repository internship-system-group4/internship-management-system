
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
    color: #173451;
    font-family: inherit;
}

.op-back {
    color: #285781;
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
    color: #718298;
    font-size: 14px;
}

.op-card {
    background: #fff;
    border: 1px solid #dce5ef;
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
    color: #718298;
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
    border: 1px solid #d6e1eb;
    border-radius: 7px;
    background: #fff;
    color: #173451;
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
    outline: 2px solid #9ec3e8;
    border-color: #4979a8;
}

.op-hint {
    display: block;
    margin-top: 6px;
    color: #7a8ba0;
    font-size: 12px;
}

.op-majors {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    margin-top: 8px;
}

.op-major {
    border: 1px solid #dbe5ef;
    border-radius: 8px;
    padding: 9px 12px;
    font-size: 13px;
    background: #f8fafc;
}

.op-major input {
    width: auto;
    margin-right: 6px;
}

.op-footer {
    border-top: 1px solid #e5ebf1;
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
    border: 1px solid #244f77;
    background: #244f77;
    color: #fff;
}

.op-btn-light {
    background: #fff;
    color: #244f77;
}

.op-btn:hover {
    filter: brightness(.94);
}

.op-notice {
    padding: 13px 16px;
    border-radius: 8px;
    background: #e6f5ed;
    color: #17613d;
    margin-bottom: 20px;
    max-width: 850px;
}

.op-notice.error {
    background: #fff0ed;
    color: #a3392b;
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
        &larr; Back to opportunities
    </a>

    <div class="op-heading">
        <h2>Add new opportunity</h2>
        <p>
            Complete the details below to create
            an internship opportunity.
        </p>
    </div>

    <% if (!string.IsNullOrEmpty(Notice)) { %>
        <div class='op-notice <%= IsError ? "error" : "" %>'>
            <%: Notice %>
        </div>
    <% } %>

    <div class="op-card">

        <h3>Basic information</h3>
        <p class="op-subtitle">
            Provide the main details of this opportunity.
        </p>

        <div class="op-grid">

            <div class="op-field">
                <label for="opTitle">Opportunity title *</label>
                <input id="opTitle" name="opTitle"
                    maxlength="160"
                    placeholder="e.g. Web Developer Intern"
                    value="<%: Request.Form["opTitle"] %>" />
            </div>

            <div class="op-field">
                <label for="opDepartment">Department *</label>
                <input id="opDepartment" name="opDepartment"
                    maxlength="120"
                    placeholder="e.g. Information Technology"
                    value="<%: Request.Form["opDepartment"] %>" />
            </div>

            <div class="op-field">
                <label>Eligible college</label>
                <input value="<%: CollegeName %>"
                    readonly="readonly" />
            </div>

            <div class="op-field">
                <label for="opType">Opportunity type</label>
                <select id="opType" name="opType">
                    <option value="Internship">Internship</option>
                </select>
            </div>

            <div class="op-field">
                <label for="opLocation">Location *</label>
                <input id="opLocation" name="opLocation"
                    maxlength="160"
                    placeholder="e.g. Amman, Jordan"
                    value="<%: Request.Form["opLocation"] %>" />
            </div>

            <div class="op-field">
                <label for="opMode">Training mode</label>
                <select id="opMode" name="opMode">
                    <option value="On-site">On-site</option>
                    <option value="Hybrid">Hybrid</option>
                    <option value="Remote">Remote</option>
                </select>
            </div>

        </div>

        <div class="op-field">
            <label>Eligible specializations *</label>

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
                Select the university majors eligible to apply.
            </span>
        </div>

        <div class="op-field">
            <label for="opDescription">Description *</label>
            <textarea id="opDescription"
                name="opDescription"
                maxlength="5000"
                placeholder="Describe the role, responsibilities and learning objectives..."><%: Request.Form["opDescription"] %></textarea>
        </div>

        <div class="op-field">
            <label for="opRequirements">Requirements *</label>
            <textarea id="opRequirements"
                name="opRequirements"
                maxlength="3000"
                placeholder="List the skills, qualifications and requirements..."><%: Request.Form["opRequirements"] %></textarea>
        </div>

        <div class="op-field">
            <label for="opTechnologies">
                Technologies used
            </label>
            <input id="opTechnologies"
                name="opTechnologies"
                maxlength="1000"
                placeholder="e.g. C#, ASP.NET, SQL, HTML, CSS"
                value="<%: Request.Form["opTechnologies"] %>" />
        </div>

        <div class="op-grid">

            <div class="op-field">
                <label for="opSeats">Available seats *</label>
                <input id="opSeats" name="opSeats"
                    type="number" min="1" max="10000"
                    placeholder="e.g. 5"
                    value="<%: Request.Form["opSeats"] %>" />
            </div>

            <div class="op-field">
                <label for="opDuration">
                    Duration (weeks) *
                </label>
                <input id="opDuration" name="opDuration"
                    type="number" min="1" max="104"
                    placeholder="e.g. 12"
                    value="<%: Request.Form["opDuration"] %>" />
            </div>

            <div class="op-field">
                <label for="opDeadline">
                    Application deadline *
                </label>
                <input id="opDeadline" name="opDeadline"
                    type="date"
                    value="<%: Request.Form["opDeadline"] %>" />
            </div>

            <div class="op-field">
                <label for="opStart">Start date *</label>
                <input id="opStart" name="opStart"
                    type="date"
                    value="<%: Request.Form["opStart"] %>" />
            </div>

            <div class="op-field">
                <label for="opEnd">End date *</label>
                <input id="opEnd" name="opEnd"
                    type="date"
                    value="<%: Request.Form["opEnd"] %>" />
            </div>

        </div>

        <div class="op-footer">
            <a class="op-btn op-btn-light"
                href="ManageOpportunities.aspx">
                Cancel
            </a>

            <button class="op-btn op-btn-light"
                type="submit" name="opAction" value="draft">
                Save draft
            </button>

            <button class="op-btn"
                type="submit" name="opAction" value="publish">
                Publish
            </button>
        </div>

    </div>

</div>

</asp:Content>
