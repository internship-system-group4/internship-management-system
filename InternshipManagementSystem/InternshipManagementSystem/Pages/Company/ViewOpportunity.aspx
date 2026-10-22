
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
    color: #173451;
}

.vo-back {
    display: inline-block;
    color: #244f77;
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
    color: #718298;
    font-size: 13px;
    line-height: 1.7;
}

.vo-card {
    background: #fff;
    border: 1px solid #dce5ef;
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
    color: #718298;
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
    background: #e5f5ec;
    color: #17603a;
    font-size: 12px;
    font-weight: 750;
}

.vo-badge.draft {
    background: #edf2f8;
    color: #526985;
}

.vo-badge.closed {
    background: #f2eeee;
    color: #815b5b;
}

.vo-notice {
    background: #fff0ed;
    color: #a3392b;
    padding: 15px;
    border-radius: 9px;
}

.vo-tag {
    display: inline-block;
    padding: 7px 11px;
    margin: 0 7px 7px 0;
    background: #f3f7fb;
    border: 1px solid #dce5ef;
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
        &larr; Back to opportunities
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
                    Opportunity details - Read-only view
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

            <h3>Opportunity Information</h3>

            <div class="vo-grid">

                <div class="vo-field">
                    <span class="vo-label">
                        Opportunity Title
                    </span>
                    <div class="vo-value">
                        <%: Display(Item.Title) %>
                    </div>
                </div>

                <div class="vo-field">
                    <span class="vo-label">
                        Department
                    </span>
                    <div class="vo-value">
                        <%: Display(Item.Department) %>
                    </div>
                </div>

                <div class="vo-field">
                    <span class="vo-label">
                        Training Mode
                    </span>
                    <div class="vo-value">
                        <%: Display(Item.TrainingMode) %>
                    </div>
                </div>

                <div class="vo-field">
                    <span class="vo-label">
                        Location
                    </span>
                    <div class="vo-value">
                        <%: Display(Item.Location) %>
                    </div>
                </div>

                <div class="vo-field">
                    <span class="vo-label">
                        Eligible College
                    </span>
                    <div class="vo-value">
                        <%: Display(Item.EligibleCollege) %>
                    </div>
                </div>

                <div class="vo-field">
                    <span class="vo-label">
                        Technologies Used
                    </span>
                    <div class="vo-value">
                        <%: Display(Item.TechnologiesUsed) %>
                    </div>
                </div>

                <div class="vo-field">
                    <span class="vo-label">
                        Opportunity ID
                    </span>
                    <div class="vo-value">
                        <%: Item.Id %>
                    </div>
                </div>

                <div class="vo-field">
                    <span class="vo-label">
                        Status
                    </span>
                    <div class="vo-value">
                        <%: Item.Status.ToString() %>
                    </div>
                </div>

            </div>

        </section>

        <!-- Eligible Specializations -->

        <section class="vo-card">

            <h3>Eligible Specializations</h3>

            <% if (Item.EligibleMajors != null &&
                   Item.EligibleMajors.Count > 0) { %>

                <% foreach (string major in Item.EligibleMajors) { %>

                    <span class="vo-tag">
                        <%: major %>
                    </span>

                <% } %>

            <% } else { %>

                <p class="vo-muted">
                    Not specified
                </p>

            <% } %>

        </section>

        <!-- Description -->

        <section class="vo-card">

            <h3>Description</h3>

            <p class="vo-long"><%: Display(Item.Description) %></p>

        </section>

        <!-- Requirements -->

        <section class="vo-card">

            <h3>Requirements</h3>

            <p class="vo-long"><%: Display(Item.Requirements) %></p>

        </section>

        <!-- Seats and Schedule -->

        <section class="vo-card">

            <h3>Seats &amp; Schedule</h3>

            <div class="vo-grid">

                <div class="vo-field">
                    <span class="vo-label">
                        Total Seats
                    </span>
                    <div class="vo-value">
                        <%: Item.TotalSeats %>
                    </div>
                </div>

                <div class="vo-field">
                    <span class="vo-label">
                        Filled Seats
                    </span>
                    <div class="vo-value">
                        <%: Item.FilledSeats %>
                    </div>
                </div>

                <div class="vo-field">
                    <span class="vo-label">
                        Duration
                    </span>
                    <div class="vo-value">
                        <%: Item.DurationWeeks %> weeks
                    </div>
                </div>

                <div class="vo-field">
                    <span class="vo-label">
                        Application Deadline
                    </span>
                    <div class="vo-value">
                        <%: DateText(Item.ApplicationDeadline) %>
                    </div>
                </div>

                <div class="vo-field">
                    <span class="vo-label">
                        Start Date
                    </span>
                    <div class="vo-value">
                        <%: DateText(Item.StartDate) %>
                    </div>
                </div>

                <div class="vo-field">
                    <span class="vo-label">
                        End Date
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
