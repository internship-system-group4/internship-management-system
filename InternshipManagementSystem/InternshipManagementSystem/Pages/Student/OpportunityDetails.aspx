
<%@ Page Title="Opportunity Details"
    Language="C#"
    MasterPageFile="~/Layout/Student.master"
    AutoEventWireup="true"
    CodeBehind="OpportunityDetails.aspx.cs"
    Inherits="InternshipManagementSystem.Pages.StudentArea.OpportunityDetails" %>

<asp:Content ID="Head"
    ContentPlaceHolderID="head"
    runat="server">

<style>
.od-page {
    max-width: 1100px;
    margin: 0 auto;
    color: var(--ink, #172b49);
}

.od-back {
    display: inline-block;
    color: var(--brand, #2259a5);
    text-decoration: none;
    font-weight: 650;
    margin-bottom: 22px;
}

.od-back:hover {
    text-decoration: underline;
}

.od-card {
    background: var(--surface, #fff);
    border: 1px solid var(--line, #dce5ef);
    border-radius: 16px;
    padding: 26px;
    margin-bottom: 20px;
}

.od-header {
    display: flex;
    justify-content: space-between;
    gap: 18px;
    flex-wrap: wrap;
    align-items: flex-start;
}

.od-header h2 {
    font-size: 1.7rem;
    font-weight: 750;
    margin-bottom: 10px;
}

.od-company {
    color: #5b6b82;
    font-weight: 600;
}

.od-badge {
    display: inline-block;
    padding: 7px 13px;
    border-radius: 30px;
    background: #e7f5ec;
    color: #17643c;
    font-weight: 750;
    font-size: .85rem;
}

.od-badge.closed {
    background: #f1f2f5;
    color: #64748b;
}

.od-grid {
    display: grid;
    grid-template-columns:
        minmax(0, 2fr) minmax(240px, 1fr);
    gap: 20px;
}

.od-section {
    margin-bottom: 26px;
}

.od-section:last-child {
    margin-bottom: 0;
}

.od-section h3 {
    font-size: 1.1rem;
    font-weight: 750;
    margin-bottom: 12px;
}

.od-description {
    color: #4e6179;
    line-height: 1.8;
    white-space: pre-wrap;
    overflow-wrap: anywhere;
}

.od-info {
    display: grid;
    gap: 15px;
}

.od-info-item {
    padding-bottom: 13px;
    border-bottom: 1px solid #e6edf4;
}

.od-info-item:last-child {
    border-bottom: 0;
}

.od-info-label {
    display: block;
    font-size: .83rem;
    color: #64748b;
    margin-bottom: 4px;
}

.od-info-value {
    display: block;
    font-weight: 700;
    overflow-wrap: anywhere;
}

.od-btn {
    display: inline-block;
    width: 100%;
    text-align: center;
    background: var(--brand, #2259a5);
    color: #fff;
    border-radius: 10px;
    padding: 13px 23px;
    font-weight: 750;
    text-decoration: none;
    border: 0;
}

.od-btn:hover {
    color: #fff;
    filter: brightness(.94);
}

.od-disabled {
    display: block;
    padding: 13px;
    border-radius: 10px;
    background: #edf0f4;
    color: #64748b;
    font-weight: 650;
    text-align: center;
}

.od-notice {
    padding: 15px 18px;
    border-radius: 10px;
    background: #fff3df;
    color: #80520d;
    margin-bottom: 20px;
}

.od-actions {
    margin-top: 20px;
}

@media (max-width: 800px) {
    .od-grid {
        grid-template-columns: 1fr;
    }
}

@media (max-width: 480px) {
    .od-card {
        padding: 18px;
    }

    .od-header h2 {
        font-size: 1.4rem;
    }
}
</style>

</asp:Content>

<asp:Content ID="Body"
    ContentPlaceHolderID="MainContent"
    runat="server">

<div class="od-page">

    <a class="od-back"
       href="Opportunities.aspx">
        &larr; Back to Opportunities
    </a>

    <% if (!string.IsNullOrEmpty(Notice)) { %>

        <div class="od-notice" role="alert">
            <%: Notice %>
        </div>

    <% } %>

    <% if (SelectedOpportunity != null) { %>

        <!-- Opportunity Header -->

        <div class="od-card">

            <div class="od-header">

                <div>
                    <h2>
                        <%: SelectedOpportunity.Title %>
                    </h2>

                    <div class="od-company">
                        <%: SelectedOpportunity.CompanyName %>
                    </div>
                </div>

                <span class='od-badge <%= CanApply ? "" : "closed" %>'>
                    <%: CanApply ? "Open" : "Unavailable" %>
                </span>

            </div>

        </div>

        <!-- Main Details -->

        <div class="od-grid">

            <div>

                <section class="od-card">

                    <div class="od-section">

                        <h3>About This Opportunity</h3>

                        <div class="od-description"><%: SelectedOpportunity.Description %></div>

                    </div>

                    <div class="od-section">

                        <h3>Requirements</h3>

                        <div class="od-description"><%: SelectedOpportunity.Requirements %></div>

                    </div>

                    <div class="od-section">

                        <h3>Student Eligibility</h3>

                        <div class="od-info">

                            <div class="od-info-item">

                                <span class="od-info-label">
                                    Eligible College
                                </span>

                                <span class="od-info-value">
                                    <%: SelectedOpportunity.EligibleCollege %>
                                </span>

                            </div>

                            <div class="od-info-item">

                                <span class="od-info-label">
                                    Eligible Majors
                                </span>

                                <span class="od-info-value">
                                    <%: EligibleMajorsText %>
                                </span>

                            </div>

                        </div>

                    </div>

                </section>

            </div>

            <!-- Sidebar -->

            <aside>

                <section class="od-card">

                    <div class="od-section">

                        <h3>Internship Overview</h3>

                        <div class="od-info">

                            <div class="od-info-item">

                                <span class="od-info-label">
                                    Company
                                </span>

                                <span class="od-info-value">
                                    <%: SelectedOpportunity.CompanyName %>
                                </span>

                            </div>

                            <div class="od-info-item">

                                <span class="od-info-label">
                                    Location
                                </span>

                                <span class="od-info-value">
                                    <%: SelectedOpportunity.Location %>
                                </span>

                            </div>

                            <div class="od-info-item">

                                <span class="od-info-label">
                                    Duration
                                </span>

                                <span class="od-info-value">
                                    <%: SelectedOpportunity.DurationWeeks %>
                                    weeks
                                </span>

                            </div>

                            <div class="od-info-item">

                                <span class="od-info-label">
                                    Total Seats
                                </span>

                                <span class="od-info-value">
                                    <%: SelectedOpportunity.TotalSeats %>
                                </span>

                            </div>

                            <div class="od-info-item">

                                <span class="od-info-label">
                                    Available Seats
                                </span>

                                <span class="od-info-value">
                                    <%: SelectedOpportunity.RemainingSeats %>
                                </span>

                            </div>

                            <div class="od-info-item">

                                <span class="od-info-label">
                                    Application Deadline
                                </span>

                                <span class="od-info-value">
                                    <%: DisplayDate(SelectedOpportunity.ApplicationDeadline) %>
                                </span>

                            </div>

                            <div class="od-info-item">

                                <span class="od-info-label">
                                    Expected Start Date
                                </span>

                                <span class="od-info-value">
                                    <%: DisplayDate(SelectedOpportunity.StartDate) %>
                                </span>

                            </div>

                        </div>

                    </div>

                    <!-- Apply Button -->

                    <div class="od-actions">

                        <% if (CanApply) { %>

                            <a class="od-btn"
                               href="<%: ApplyUrl %>">
                                Apply for Internship
                            </a>

                        <% } else { %>

                            <span class="od-disabled">
                                Applications Unavailable
                            </span>

                        <% } %>

                    </div>

                </section>

            </aside>

        </div>

    <% } %>

</div>

</asp:Content>
