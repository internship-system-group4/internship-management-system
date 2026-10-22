
<%@ Page Language="C#" MasterPageFile="~/Layout/Student.master"
    AutoEventWireup="true"
    CodeBehind="OpportunityDetails.aspx.cs"
    Inherits="InternshipManagementSystem.Pages.StudentArea.OpportunityDetails"
    Title="Opportunity Details" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">

<style>
.od-page {
    --od-navy: #183d63;
    --od-blue: #28547d;
    --od-muted: #71839a;
    --od-border: #e0e8f2;
    max-width: 1200px;
    margin: 0 auto;
    padding-bottom: 35px;
    color: #1b3551;
}
.od-page * { box-sizing: border-box; }

.od-back {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    color: var(--od-blue);
    font-size: 13px;
    font-weight: 700;
    text-decoration: none;
    margin-bottom: 22px;
}
.od-back:hover { text-decoration: underline; }

.od-header {
    padding: 27px;
    background: #fff;
    border: 1px solid var(--od-border);
    border-radius: 15px;
    margin-bottom: 20px;
}
.od-header-top {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    gap: 15px;
    flex-wrap: wrap;
}
.od-label {
    color: #6183a2;
    font-size: 11px;
    font-weight: 800;
    letter-spacing: .6px;
    text-transform: uppercase;
    margin-bottom: 10px;
}
.od-header h2 {
    color: var(--od-navy);
    font-size: 28px;
    font-weight: 800;
    line-height: 1.4;
    margin: 0 0 9px;
}
.od-company {
    font-size: 14px;
    font-weight: 700;
    color: #56738e;
}
.od-badge {
    display: inline-block;
    background: #e6f6ec;
    color: #247449;
    border-radius: 30px;
    padding: 8px 13px;
    font-size: 11px;
    font-weight: 800;
    white-space: nowrap;
}
.od-badge-unavailable {
    background: #f0f2f5;
    color: #657488;
}
.od-header-divider {
    height: 1px;
    background: #e9eff5;
    margin: 22px 0;
}
.od-highlights {
    display: grid;
    grid-template-columns: repeat(4, minmax(0, 1fr));
    gap: 15px;
}
.od-highlight {
    min-width: 0;
    padding: 13px 14px;
    background: #f5f8fc;
    border-radius: 10px;
}
.od-highlight-label {
    display: block;
    font-size: 10px;
    font-weight: 700;
    color: #7b8ca1;
    margin-bottom: 7px;
}
.od-highlight-value {
    display: block;
    color: var(--od-navy);
    font-size: 13px;
    font-weight: 800;
    overflow-wrap: anywhere;
}
.od-grid {
    display: grid;
    grid-template-columns: minmax(0, 1.6fr) minmax(260px, 1fr);
    gap: 20px;
    align-items: start;
}
.od-panel {
    background: #fff;
    border: 1px solid var(--od-border);
    border-radius: 13px;
    padding: 23px;
    margin-bottom: 19px;
}
.od-panel h3 {
    color: var(--od-navy);
    font-size: 17px;
    font-weight: 800;
    margin: 0 0 17px;
}
.od-body-text {
    font-size: 13px;
    color: #60748b;
    line-height: 1.9;
    white-space: pre-wrap;
    overflow-wrap: anywhere;
    margin: 0;
}
.od-info-item {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    gap: 14px;
    padding: 13px 0;
    border-bottom: 1px solid #edf1f6;
}
.od-info-item:first-of-type { padding-top: 0; }
.od-info-item:last-of-type {
    border-bottom: 0;
    padding-bottom: 0;
}
.od-info-label {
    color: #75869b;
    font-size: 12px;
}
.od-info-value {
    color: #244867;
    font-size: 12px;
    font-weight: 800;
    text-align: right;
    overflow-wrap: anywhere;
}
.od-major-list {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
}
.od-major {
    display: inline-block;
    padding: 8px 11px;
    border-radius: 30px;
    background: #eef5fd;
    color: #315e89;
    font-size: 11px;
    font-weight: 700;
}
.od-apply-panel {
    border: 1px solid #cfe0f1;
    background: #f7fbff;
}
.od-apply-panel p {
    color: #6a7e94;
    font-size: 12px;
    line-height: 1.8;
    margin: 0 0 18px;
}
.od-button {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 100%;
    padding: 13px 18px;
    background: var(--od-navy);
    border: 0;
    border-radius: 9px;
    color: #fff !important;
    text-decoration: none !important;
    font-size: 13px;
    font-weight: 800;
    transition: .2s;
}
.od-button:hover { background: #102e4d; }
.od-button-light {
    background: #eaf1f9;
    color: var(--od-navy) !important;
    margin-top: 10px;
}
.od-button-light:hover { background: #dce9f6; }
.od-disabled {
    display: block;
    padding: 13px;
    background: #e9edf2;
    color: #64748b;
    border-radius: 9px;
    font-size: 12px;
    font-weight: 800;
    text-align: center;
}
.od-notice {
    background: #fff7e7;
    color: #805817;
    border: 1px solid #efd8ab;
    padding: 15px 17px;
    border-radius: 10px;
    font-size: 13px;
    margin-bottom: 20px;
}
.od-empty {
    padding: 50px 25px;
    border: 1px dashed #d0dfed;
    border-radius: 13px;
    background: #fff;
    text-align: center;
}
.od-empty h3 {
    color: var(--od-navy);
    font-size: 19px;
    margin: 0 0 12px;
}
.od-empty p {
    color: var(--od-muted);
    font-size: 13px;
    line-height: 1.8;
    margin-bottom: 18px;
}
.od-empty .od-button {
    width: auto;
}
@media(max-width: 950px) {
    .od-highlights {
        grid-template-columns: repeat(2, minmax(0, 1fr));
    }
    .od-grid { grid-template-columns: 1fr; }
}
@media(max-width: 520px) {
    .od-header { padding: 19px; }
    .od-header h2 { font-size: 22px; }
    .od-highlights { grid-template-columns: 1fr; }
    .od-panel { padding: 18px; }
}
</style>

</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

<div class="od-page">

    <a class="od-back"
       href="<%: ResolveUrl("~/Pages/Student/Opportunities.aspx") %>">
        &larr; Back to Explore Opportunities
    </a>

    <% if (!string.IsNullOrWhiteSpace(Notice)) { %>
        <div class="od-notice" role="alert">
            <%: Notice %>
        </div>
    <% } %>

    <% if (SelectedOpportunity == null) { %>

        <div class="od-empty">
            <h3>Opportunity Not Available</h3>
            <p>
                We couldn't display this opportunity.
                Please return to Explore Opportunities and choose
                another internship.
            </p>
            <a class="od-button"
               href="<%: ResolveUrl("~/Pages/Student/Opportunities.aspx") %>">
                Explore Opportunities
            </a>
        </div>

    <% } else { %>

        <div class="od-header">

            <div class="od-header-top">
                <div>
                    <div class="od-label">Internship Opportunity</div>
                    <h2><%: SelectedOpportunity.Title %></h2>
                    <div class="od-company">
                        <%: CompanyNameText %>
                    </div>
                </div>

                <span class='od-badge <%= CanApply ? "" : "od-badge-unavailable" %>'>
                    <%: CanApply ? "Open for Applications" : "Unavailable" %>
                </span>
            </div>

            <div class="od-header-divider"></div>

            <div class="od-highlights">

                <div class="od-highlight">
                    <span class="od-highlight-label">LOCATION</span>
                    <span class="od-highlight-value">
                        <%: ValueOrDefault(SelectedOpportunity.Location) %>
                    </span>
                </div>

                <div class="od-highlight">
                    <span class="od-highlight-label">DURATION</span>
                    <span class="od-highlight-value">
                        <%: SelectedOpportunity.DurationWeeks %> weeks
                    </span>
                </div>

                <div class="od-highlight">
                    <span class="od-highlight-label">AVAILABLE SEATS</span>
                    <span class="od-highlight-value">
                        <%: SelectedOpportunity.RemainingSeats %>
                        / <%: SelectedOpportunity.TotalSeats %>
                    </span>
                </div>

                <div class="od-highlight">
                    <span class="od-highlight-label">APPLICATION DEADLINE</span>
                    <span class="od-highlight-value">
                        <%: DisplayDate(SelectedOpportunity.ApplicationDeadline) %>
                    </span>
                </div>

            </div>
        </div>

        <div class="od-grid">

            <div>

                <section class="od-panel">
                    <h3>About This Opportunity</h3>
                    <p class="od-body-text"><%: ValueOrDefault(SelectedOpportunity.Description) %></p>
                </section>

                <section class="od-panel">
                    <h3>Requirements &amp; Qualifications</h3>
                    <p class="od-body-text"><%: ValueOrDefault(SelectedOpportunity.Requirements) %></p>
                </section>

                <section class="od-panel">
                    <h3>Who Can Apply?</h3>
                    <p class="od-body-text" style="margin-bottom:15px">
                        This opportunity is available to students whose
                        academic college and major meet the eligibility
                        requirements.
                    </p>

                    <div class="od-info-item">
                        <span class="od-info-label">Eligible College</span>
                        <span class="od-info-value">
                            <%: ValueOrDefault(SelectedOpportunity.EligibleCollege) %>
                        </span>
                    </div>

                    <div style="margin-top:18px">
                        <div class="od-info-label" style="margin-bottom:10px">
                            Eligible Majors
                        </div>

                        <div class="od-major-list">
                            <% if (SelectedOpportunity.EligibleMajors != null &&
                                   SelectedOpportunity.EligibleMajors.Count > 0) { %>

                                <% foreach (string major in SelectedOpportunity.EligibleMajors) { %>
                                    <span class="od-major"><%: major %></span>
                                <% } %>

                            <% } else { %>
                                <span class="od-major">All majors in eligible college</span>
                            <% } %>
                        </div>
                    </div>
                </section>

            </div>

            <div>

                <section class="od-panel">
                    <h3>Internship Information</h3>

                    <div class="od-info-item">
                        <span class="od-info-label">Company</span>
                        <span class="od-info-value"><%: CompanyNameText %></span>
                    </div>

                    <div class="od-info-item">
                        <span class="od-info-label">Location</span>
                        <span class="od-info-value">
                            <%: ValueOrDefault(SelectedOpportunity.Location) %>
                        </span>
                    </div>

                    <div class="od-info-item">
                        <span class="od-info-label">Training Duration</span>
                        <span class="od-info-value">
                            <%: SelectedOpportunity.DurationWeeks %> weeks
                        </span>
                    </div>

                    <div class="od-info-item">
                        <span class="od-info-label">Training Start</span>
                        <span class="od-info-value">
                            <%: DisplayDate(SelectedOpportunity.StartDate) %>
                        </span>
                    </div>

                    <div class="od-info-item">
                        <span class="od-info-label">Apply Before</span>
                        <span class="od-info-value">
                            <%: DisplayDate(SelectedOpportunity.ApplicationDeadline) %>
                        </span>
                    </div>

                    <div class="od-info-item">
                        <span class="od-info-label">Remaining Seats</span>
                        <span class="od-info-value">
                            <%: SelectedOpportunity.RemainingSeats %>
                        </span>
                    </div>

                </section>

                <section class="od-panel od-apply-panel">
                    <h3>Ready to Apply?</h3>

                    <p>
                        Interested in this opportunity?
                        Start your application and submit the
                        required information through the student portal.
                    </p>

                    <% if (CanApply) { %>

                        <a class="od-button" href="<%: ApplyUrl %>">
                            Apply Now &rarr;
                        </a>

                    <% } else { %>

                        <span class="od-disabled">
                            Applications Unavailable
                        </span>

                    <% } %>

                    <a class="od-button od-button-light"
                       href="<%: ResolveUrl("~/Pages/Student/MyApplications.aspx") %>">
                        My Applications
                    </a>
                </section>

            </div>

        </div>

    <% } %>

</div>

</asp:Content>
