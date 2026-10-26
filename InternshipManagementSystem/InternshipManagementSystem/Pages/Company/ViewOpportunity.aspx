
<%@ Page Title="View Opportunity"
    Language="C#"
    MasterPageFile="~/Layout/Company.master"
    AutoEventWireup="true"
    CodeBehind="ViewOpportunity.aspx.cs"
    Inherits="InternshipManagementSystem.Pages.CompanyArea.ViewOpportunity" %>

<asp:Content ID="Head"
    ContentPlaceHolderID="head"
    runat="server">

<style>
.vo-page {
    max-width: 1150px;
    margin: 0 auto;
    color: var(--th-fg-173451,#173451);
}

.vo-back {
    display: inline-block;
    color: var(--th-fg-244f77,#244f77);
    text-decoration: none;
    font-weight: 650;
    font-size: 13px;
    margin-bottom: 22px;
}

.vo-heading {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    gap: 16px;
    margin-bottom: 24px;
}

.vo-heading h2 {
    font-size: 27px;
    font-weight: 750;
    margin: 0 0 8px;
}

.vo-muted {
    color: var(--ui-muted);
    font-size: 13px;
    line-height: 1.7;
}

.vo-card {
    background: var(--ui-surface,#fff);
    border: 1px solid var(--th-line-dce5ef,#dce5ef);
    border-radius: 11px;
    padding: 23px;
    margin-bottom: 20px;
}

.vo-card h3 {
    font-size: 17px;
    font-weight: 750;
    margin: 0 0 18px;
}

.vo-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 22px;
}

.vo-field {
    min-width: 0;
}

.vo-label {
    display: block;
    font-size: 12px;
    font-weight: 700;
    color: var(--ui-muted);
    margin-bottom: 7px;
}

.vo-value {
    font-size: 14px;
    font-weight: 600;
    line-height: 1.65;
    overflow-wrap: anywhere;
}

.vo-long {
    font-size: 14px;
    line-height: 1.85;
    white-space: pre-wrap;
    overflow-wrap: anywhere;
    margin: 0;
}

.vo-badge {
    display: inline-block;
    border-radius: 20px;
    padding: 6px 12px;
    background: var(--th-bg-e5f5ec,#e5f5ec);
    color: var(--th-fg-17603a,#17603a);
    font-size: 12px;
    font-weight: 750;
}

.vo-badge.draft {
    background: var(--th-bg-edf2f8,#edf2f8);
    color: var(--th-fg-526985,#526985);
}

.vo-badge.closed {
    background: var(--th-bg-f2eeee,#f2eeee);
    color: var(--th-fg-815b5b,#815b5b);
}

.vo-notice {
    background: var(--th-bg-fff0ed,#fff0ed);
    color: var(--th-fg-a3392b,#a3392b);
    padding: 15px;
    border-radius: 9px;
}

.vo-tag {
    display: inline-block;
    padding: 7px 11px;
    margin: 0 7px 7px 0;
    background: var(--th-bg-f3f7fb,#f3f7fb);
    border: 1px solid var(--th-line-dce5ef,#dce5ef);
    border-radius: 7px;
    font-size: 13px;
}

@media (max-width: 750px) {
    .vo-grid {
        grid-template-columns: 1fr;
    }

    .vo-heading {
        flex-direction: column;
    }
}
</style>

</asp:Content>

<asp:Content ID="Body"
    ContentPlaceHolderID="MainContent"
    runat="server">

<div class="vo-page">

    <a class="vo-back"
       href="ManageOpportunities.aspx">
        <%: L.T("Company.ViewOpportunity.BackToOpportunities") %>
    </a>

    <% if (!string.IsNullOrEmpty(ErrorMessage)) { %>

        <div class="vo-notice" role="alert">
            <%: ErrorMessage %>
        </div>

    <% } else if (Item != null) { %>

        <div class="vo-heading">
            <div>
                <h2><%: Display(Item.Title) %></h2>
                <div class="vo-muted">
                    <%: L.T("Company.ViewOpportunity.OpportunityDetailsReadOnlyView") %>
                </div>
            </div>

            <span class='vo-badge <%=
                Item.Status == OpportunityStatus.Closed
                ? "closed"
                : Item.Status == OpportunityStatus.Draft
                ? "draft"
                : ""
            %>'>
                <%: Item.Status.ToString() %>
            </span>
        </div>

        <!-- Opportunity Information -->

        <section class="vo-card">

            <h3><%: L.T("Company.ViewOpportunity.OpportunityInformation") %></h3>

            <div class="vo-grid">

                <div class="vo-field">
                    <span class="vo-label">
                        <%: L.T("Company.ViewOpportunity.OpportunityTitle") %>
                    </span>
                    <div class="vo-value">
                        <%: Display(Item.Title) %>
                    </div>
                </div>

                <div class="vo-field">
                    <span class="vo-label">
                        <%: L.T("Company.ViewOpportunity.Department") %>
                    </span>
                    <div class="vo-value">
                        <%: Display(Item.Department) %>
                    </div>
                </div>

                <div class="vo-field">
                    <span class="vo-label">
                        <%: L.T("Company.ViewOpportunity.TrainingMode") %>
                    </span>
                    <div class="vo-value">
                        <%: Display(Item.TrainingMode) %>
                    </div>
                </div>

                <div class="vo-field">
                    <span class="vo-label">
                        <%: L.T("Company.ViewOpportunity.Location") %>
                    </span>
                    <div class="vo-value">
                        <%: Display(Item.Location) %>
                    </div>
                </div>

                <div class="vo-field">
                    <span class="vo-label">
                        <%: L.T("Company.ViewOpportunity.EligibleCollege") %>
                    </span>
                    <div class="vo-value">
                        <%: Display(Item.EligibleCollege) %>
                    </div>
                </div>

                <div class="vo-field">
                    <span class="vo-label">
                        <%: L.T("Company.ViewOpportunity.TechnologiesUsed") %>
                    </span>
                    <div class="vo-value">
                        <%: Display(Item.TechnologiesUsed) %>
                    </div>
                </div>

                <div class="vo-field">
                    <span class="vo-label">
                        <%: L.T("Company.ViewOpportunity.OpportunityID") %>
                    </span>
                    <div class="vo-value">
                        <%: Item.Id %>
                    </div>
                </div>

                <div class="vo-field">
                    <span class="vo-label">
                        <%: L.T("Company.ViewOpportunity.Status") %>
                    </span>
                    <div class="vo-value">
                        <%: Item.Status.ToString() %>
                    </div>
                </div>

            </div>

        </section>

        <!-- Eligible Specializations -->

        <section class="vo-card">

            <h3><%: L.T("Company.ViewOpportunity.EligibleSpecializations") %></h3>

            <% if (Item.EligibleMajors != null &&
                   Item.EligibleMajors.Count > 0) { %>

                <% foreach (string major in Item.EligibleMajors) { %>

                    <span class="vo-tag">
                        <%: major %>
                    </span>

                <% } %>

            <% } else { %>

                <p class="vo-muted">
                    <%: L.T("Company.ViewOpportunity.NotSpecified") %>
                </p>

            <% } %>

        </section>

        <!-- Description -->

        <section class="vo-card">

            <h3><%: L.T("Company.ViewOpportunity.Description") %></h3>

            <p class="vo-long"><%: Display(Item.Description) %></p>

        </section>

        <!-- Requirements -->

        <section class="vo-card">

            <h3><%: L.T("Company.ViewOpportunity.Requirements") %></h3>

            <p class="vo-long"><%: Display(Item.Requirements) %></p>

        </section>

        <!-- Seats and Schedule -->

        <section class="vo-card">

            <h3><%: L.T("Company.ViewOpportunity.SeatsSchedule") %></h3>

            <div class="vo-grid">

                <div class="vo-field">
                    <span class="vo-label">
                        <%: L.T("Company.ViewOpportunity.TotalSeats") %>
                    </span>
                    <div class="vo-value">
                        <%: Item.TotalSeats %>
                    </div>
                </div>

                <div class="vo-field">
                    <span class="vo-label">
                        <%: L.T("Company.ViewOpportunity.FilledSeats") %>
                    </span>
                    <div class="vo-value">
                        <%: Item.FilledSeats %>
                    </div>
                </div>

                <div class="vo-field">
                    <span class="vo-label">
                        <%: L.T("Company.ViewOpportunity.Duration") %>
                    </span>
                    <div class="vo-value">
                        <%: InternshipManagementSystem.Services.OpportunityFormRules.DurationLabel(Item.DurationWeeks) %>
                    </div>
                </div>

                <div class="vo-field">
                    <span class="vo-label">
                        <%: L.T("Company.ViewOpportunity.ApplicationDeadline") %>
                    </span>
                    <div class="vo-value">
                        <%: DateText(Item.ApplicationDeadline) %>
                    </div>
                </div>

                <div class="vo-field">
                    <span class="vo-label">
                        <%: L.T("Company.ViewOpportunity.StartDate") %>
                    </span>
                    <div class="vo-value">
                        <%: DateText(Item.StartDate) %>
                    </div>
                </div>

                <div class="vo-field">
                    <span class="vo-label">
                        <%: L.T("Company.ViewOpportunity.EndDate") %>
                    </span>
                    <div class="vo-value">
                        <%: DateText(Item.EndDate) %>
                    </div>
                </div>

            </div>

        </section>

    <% } %>

</div>

</asp:Content>
