
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

/* Duration spinner */
#opDuration {
    appearance: auto;
    -moz-appearance: auto;
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

</asp:Content>

<asp:Content ID="Body"
    ContentPlaceHolderID="MainContent"
    runat="server">

<div class="op-page">

    <a class="op-back" href="ManageOpportunities.aspx">
        <%: L.T("Company.Opportunities.BackToOpportunities") %>
    </a>

    <div class="op-heading">
        <h2>
            <%: L.T("Company.Opportunities.AddNewOpportunity") %>
        </h2>
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

        <h3>
            <%: L.T("Company.Opportunities.BasicInformation") %>
        </h3>

        <p class="op-subtitle">
            <%: L.T("Company.Opportunities.ProvideTheMainDetailsOfThis") %>
        </p>

        <!-- Basic Information -->
        <div class="op-grid">

            <div class="op-field">
                <label for="opTitle">
                    <%: L.T("Company.Opportunities.OpportunityTitle") %>
                </label>
                <input id="opTitle"
                    name="opTitle"
                    maxlength="160"
                    placeholder="<%: L.T("Company.Opportunities.EGWebDeveloperIntern") %>"
                    value="<%: Request.Form["opTitle"] %>" />
            </div>

            <div class="op-field">
                <label for="opDepartment">
                    <%: L.T("Company.Opportunities.Department") %>
                </label>
                <input id="opDepartment"
                    name="opDepartment"
                    maxlength="120"
                    placeholder="<%: L.T("Company.Opportunities.EGInformationTechnology") %>"
                    value="<%: Request.Form["opDepartment"] %>" />
            </div>

            <div class="op-field">
                <label>
                    <%: L.T("Company.Opportunities.EligibleCollege") %>
                </label>
                <input value="<%: CollegeName %>"
                    readonly="readonly" />
            </div>

            <div class="op-field">
                <label for="opType">
                    <%: L.T("Company.Opportunities.OpportunityType") %>
                </label>
                <select id="opType" name="opType">
                    <option value="Internship">
                        <%: L.T("Shared.Value.OpportunityType.Internship") %>
                    </option>
                </select>
            </div>

            <div class="op-field">
                <label for="opLocation">
                    <%: L.T("Company.Opportunities.Location") %>
                </label>
                <input id="opLocation"
                    name="opLocation"
                    maxlength="160"
                    placeholder="<%: L.T("Company.Opportunities.EGAmmanJordan") %>"
                    value="<%: Request.Form["opLocation"] %>" />
            </div>

            <div class="op-field">
                <label for="opMode">
                    <%: L.T("Company.Opportunities.TrainingMode") %>
                </label>
                <select id="opMode" name="opMode">
                    <option value="On-site">
                        <%: L.T("Shared.Value.TrainingMode.Onsite") %>
                    </option>
                    <option value="Hybrid">
                        <%: L.T("Shared.Value.TrainingMode.Hybrid") %>
                    </option>
                    <option value="Remote">
                        <%: L.T("Shared.Value.TrainingMode.Remote") %>
                    </option>
                </select>
            </div>

        </div>

        <!-- Eligible Specializations -->
        <div class="op-field">
            <label>
                <%: L.T("Company.Opportunities.EligibleSpecializations") %>
            </label>

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

        <!-- Description -->
        <div class="op-field">
            <label for="opDescription">
                <%: L.T("Company.Opportunities.Description") %>
            </label>
            <textarea id="opDescription"
                name="opDescription"
                maxlength="5000"
                placeholder="<%: L.T("Company.Opportunities.DescribeTheRoleResponsibilitiesAndLearning") %>"><%: Request.Form["opDescription"] %></textarea>
        </div>

        <!-- Requirements -->
        <div class="op-field">
            <label for="opRequirements">
                <%: L.T("Company.Opportunities.Requirements") %>
            </label>
            <textarea id="opRequirements"
                name="opRequirements"
                maxlength="3000"
                placeholder="<%: L.T("Company.Opportunities.ListTheSkillsQualificationsAndRequirements") %>"><%: Request.Form["opRequirements"] %></textarea>
        </div>

        <!-- Technologies -->
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

        <!-- Seats, Duration, Dates -->
        <div class="op-grid">

            <!-- Available Seats -->
            <div class="op-field">
                <label for="opSeats">
                    <%: L.T("Company.Opportunities.AvailableSeats") %>
                </label>
                <input id="opSeats"
                    name="opSeats"
                    type="number"
                    min="1"
                    max="10000"
                    placeholder="e.g. 5"
                    value="<%: Request.Form["opSeats"] %>" />
            </div>

            <!-- Duration -->
            <div class="op-field">
                <label for="opDuration">
                    <%: L.T("Company.Opportunities.DurationWeeks") %>
                </label>
                <input id="opDuration"
                    name="opDuration"
                    type="number"
                    min="1"
                    max="13"
                    step="1"
                    placeholder="e.g. 12"
                    value="<%: Request.Form["opDuration"] %>" />
            </div>

            <!-- Start Date: Left -->
            <div class="op-field">
                <label for="opStart">
                    <%: L.T("Company.Opportunities.StartDate") %>
                </label>
                <input id="opStart"
                    name="opStart"
                    type="date"
                    value="<%: Request.Form["opStart"] %>" />
            </div>

            <!-- End Date: Right -->
            <div class="op-field">
                <label for="opEnd">
                    <%: L.T("Company.Opportunities.EndDate") %>
                </label>
                <input id="opEnd"
                    name="opEnd"
                    type="date"
                    value="<%: Request.Form["opEnd"] %>" />
            </div>

            <!-- Last Date to Apply: Below Start and End -->
            <div class="op-field">
                <label for="opDeadline">
                    <%: L.T("Company.Opportunities.LastDateToApply") %>
                    <span class="op-required-star">*</span>
                </label>
                <input id="opDeadline"
                    name="opDeadline"
                    type="date"
                    value="<%: Request.Form["opDeadline"] %>" />
            </div>

        </div>

        <!-- Footer Buttons -->
        <div class="op-footer">

            <a class="op-btn op-btn-light"
                href="ManageOpportunities.aspx">
                <%: L.T("Company.Opportunities.Cancel") %>
            </a>

            <button class="op-btn op-btn-light"
                type="submit"
                name="opAction"
                value="draft"
                data-ui-action="save"
                data-ui-validation="none"
                data-loading-label="<%: L.T("Shared.I18n.Saving") %>">
                <%: L.T("Company.Opportunities.SaveDraft") %>
            </button>

            <button class="op-btn"
                type="submit"
                name="opAction"
                value="publish"
                data-ui-action="publish"
                data-ui-validation="none"
                data-loading-label="<%: L.T("Shared.I18n.Publishing") %>">
                <%: L.T("Company.Opportunities.Publish") %>
            </button>

        </div>

    </div>

</div>

<script type="text/javascript">
(function () {
    function highlightRequiredStars() {
        var labels = document.querySelectorAll(
            '.op-page .op-field label'
        );

        Array.prototype.forEach.call(labels, function (label) {
            Array.prototype.forEach.call(
                Array.prototype.slice.call(label.childNodes),
                function (node) {
                    if (node.nodeType !== 3 ||
                        node.nodeValue.indexOf('*') === -1) {
                        return;
                    }

                    var parts = node.nodeValue.split('*');
                    var fragment = document.createDocumentFragment();

                    parts.forEach(function (part, index) {
                        if (index > 0) {
                            var star = document.createElement('span');
                            star.className = 'op-required-star';
                            star.textContent = '*';
                            fragment.appendChild(star);
                        }

                        if (part) {
                            fragment.appendChild(
                                document.createTextNode(part)
                            );
                        }
                    });

                    node.parentNode.replaceChild(fragment, node);
                }
            );
        });
    }

    if (document.readyState === 'loading') {
        document.addEventListener(
            'DOMContentLoaded',
            highlightRequiredStars
        );
    } else {
        highlightRequiredStars();
    }
})();
</script>

</asp:Content>
