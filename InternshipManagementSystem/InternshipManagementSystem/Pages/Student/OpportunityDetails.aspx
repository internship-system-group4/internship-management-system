
<%@ Page Language="C#" MasterPageFile="~/Layout/Student.master"
    AutoEventWireup="true"
    CodeBehind="OpportunityDetails.aspx.cs"
    Inherits="InternshipManagementSystem.Pages.StudentArea.OpportunityDetails"
    Title="Opportunity Details" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">

<style>
.od-page {
    --od-navy: var(--ui-primary);
    --od-blue: #28547d;
    --od-muted: var(--ui-muted);
    --od-border: var(--th-line-e0e8f2,#e0e8f2);
    max-width: 1200px;
    margin: 0 auto;
    padding-bottom: 35px;
    color: var(--th-fg-1b3551,#1b3551);
}
.od-page * { box-sizing: border-box; }

.od-back {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    color: var(--ui-primary-text,var(--od-blue));
    font-size: 13px;
    font-weight: 700;
    text-decoration: none;
    margin-bottom: 22px;
}
.od-back:hover { text-decoration: underline; }

.od-header {
    padding: 27px;
    background: var(--ui-surface,#fff);
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
    color: var(--ui-muted);
    font-size: 11px;
    font-weight: 800;
    letter-spacing: .6px;
    text-transform: uppercase;
    margin-bottom: 10px;
}
.od-header h2 {
    color: var(--ui-primary-text,var(--od-navy));
    font-size: 28px;
    font-weight: 800;
    line-height: 1.4;
    margin: 0 0 9px;
}
.od-company {
    font-size: 14px;
    font-weight: 700;
    color: var(--th-fg-56738e,#56738e);
}
.od-badge {
    display: inline-block;
    background: var(--th-bg-e6f6ec,#e6f6ec);
    color: var(--th-fg-247449,#247449);
    border-radius: 30px;
    padding: 8px 13px;
    font-size: 11px;
    font-weight: 800;
    white-space: nowrap;
}
.od-badge-unavailable {
    background: var(--th-bg-f0f2f5,#f0f2f5);
    color: var(--th-fg-657488,#657488);
}
.od-header-divider {
    height: 1px;
    background: var(--th-bg-e9eff5,#e9eff5);
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
    background: var(--th-bg-f5f8fc,#f5f8fc);
    border-radius: 10px;
}
.od-highlight-label {
    display: block;
    font-size: 10px;
    font-weight: 700;
    color: var(--ui-muted);
    margin-bottom: 7px;
}
.od-highlight-value {
    display: block;
    color: var(--ui-primary-text,var(--od-navy));
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
    background: var(--ui-surface,#fff);
    border: 1px solid var(--od-border);
    border-radius: 13px;
    padding: 23px;
    margin-bottom: 19px;
}
.od-panel h3 {
    color: var(--ui-primary-text,var(--od-navy));
    font-size: 17px;
    font-weight: 800;
    margin: 0 0 17px;
}
.od-body-text {
    font-size: 13px;
    color: var(--th-fg-60748b,#60748b);
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
    border-bottom: 1px solid var(--th-line-edf1f6,#edf1f6);
}
.od-info-item:first-of-type { padding-top: 0; }
.od-info-item:last-of-type {
    border-bottom: 0;
    padding-bottom: 0;
}
.od-info-label {
    color: var(--ui-muted);
    font-size: 12px;
}
.od-info-value {
    color: var(--th-fg-244867,#244867);
    font-size: 12px;
    font-weight: 800;
    text-align: end;
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
    background: var(--th-bg-eef5fd,#eef5fd);
    color: var(--th-fg-315e89,#315e89);
    font-size: 11px;
    font-weight: 700;
}
.od-apply-panel {
    border: 1px solid var(--th-line-cfe0f1,#cfe0f1);
    background: var(--th-bg-f7fbff,#f7fbff);
}
.od-apply-panel p {
    color: var(--ui-muted);
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
.od-button:hover { background: var(--th-bg-102e4d,#102e4d); }
.od-button-light {
    background: var(--th-bg-eaf1f9,#eaf1f9);
    color: var(--ui-primary-text,var(--od-navy)) !important;
    margin-top: 10px;
}
.od-button-light:hover { background: var(--th-bg-dce9f6,#dce9f6); }
.od-disabled {
    display: block;
    padding: 13px;
    background: var(--th-bg-e9edf2,#e9edf2);
    color: var(--ui-muted);
    border-radius: 9px;
    font-size: 12px;
    font-weight: 800;
    text-align: center;
}
.od-notice {
    background: var(--th-bg-fff7e7,#fff7e7);
    color: var(--th-fg-805817,#805817);
    border: 1px solid var(--th-line-efd8ab,#efd8ab);
    padding: 15px 17px;
    border-radius: 10px;
    font-size: 13px;
    margin-bottom: 20px;
}
.od-empty {
    padding: 50px 25px;
    border: 1px dashed var(--th-line-d0dfed,#d0dfed);
    border-radius: 13px;
    background: var(--ui-surface,#fff);
    text-align: center;
}
.od-empty h3 {
    color: var(--ui-primary-text,var(--od-navy));
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
        <%: L.T("Student.OpportunityDetails.BackToExploreOpportunities") %>
    </a>

    <% if (!string.IsNullOrWhiteSpace(Notice)) { %>
        <div class="od-notice" role="alert">
            <%: Notice %>
        </div>
    <% } %>

    <% if (SelectedOpportunity == null) { %>

        <div class="od-empty">
            <h3><%: L.T("Student.OpportunityDetails.OpportunityNotAvailable") %></h3>
            <p>
                <%: L.T("Student.OpportunityDetails.WeCouldnTDisplayThisOpportunity") %>
            </p>
            <a class="od-button"
               href="<%: ResolveUrl("~/Pages/Student/Opportunities.aspx") %>">
                <%: L.T("Student.OpportunityDetails.ExploreOpportunities") %>
            </a>
        </div>

    <% } else { %>

        <div class="od-header">

            <div class="od-header-top">
                <div>
                    <div class="od-label"><%: L.T("Student.OpportunityDetails.InternshipOpportunity") %></div>
                    <h2><%: SelectedOpportunity.Title %></h2>
                    <div class="od-company">
                        <%: CompanyNameText %>
                    </div>
                </div>

                <span class='od-badge <%= ExistingApplication == null && !CanApply ? "od-badge-unavailable" : "" %>'>
                    <%: ExistingApplication != null ? L.T("Student.Opportunities.Applied") + " · " + L.Value("Ui", ExistingApplication.Status) : CanApply ? L.T("Student.Opportunities.Open") : L.T("Student.OpportunityDetails.ApplicationsUnavailable") %>
                </span>
            </div>

            <div class="od-header-divider"></div>

            <div class="od-highlights">

                <div class="od-highlight">
                    <span class="od-highlight-label"><%: L.T("Student.OpportunityDetails.LocationCaps") %></span>
                    <span class="od-highlight-value">
                        <%: ValueOrDefault(SelectedOpportunity.Location) %>
                    </span>
                </div>

                <div class="od-highlight">
                    <span class="od-highlight-label"><%: L.T("Student.OpportunityDetails.DURATION") %></span>
                    <span class="od-highlight-value">
                        <%: SelectedOpportunity.DurationWeeks %> <%: L.T("Student.OpportunityDetails.Weeks") %>
                    </span>
                </div>

                <div class="od-highlight">
                    <span class="od-highlight-label"><%: L.T("Student.OpportunityDetails.AVAILABLESEATS") %></span>
                    <span class="od-highlight-value">
                        <%: SelectedOpportunity.RemainingSeats %>
                        / <%: SelectedOpportunity.TotalSeats %>
                    </span>
                </div>

                <div class="od-highlight">
                    <span class="od-highlight-label"><%: L.T("Student.OpportunityDetails.APPLICATIONDEADLINE") %></span>
                    <span class="od-highlight-value">
                        <%: DisplayDate(SelectedOpportunity.ApplicationDeadline) %>
                    </span>
                </div>

            </div>
        </div>

        <div class="od-grid">

            <div>

                <section class="od-panel">
                    <h3><%: L.T("Student.OpportunityDetails.AboutThisOpportunity") %></h3>
                    <p class="od-body-text"><%: ValueOrDefault(SelectedOpportunity.Description) %></p>
                </section>

                <section class="od-panel">
                    <h3><%: L.T("Student.OpportunityDetails.RequirementsQualifications") %></h3>
                    <p class="od-body-text"><%: ValueOrDefault(SelectedOpportunity.Requirements) %></p>
                </section>

                <section class="od-panel">
                    <h3><%: L.T("Student.OpportunityDetails.WhoCanApply") %></h3>
                    <p class="od-body-text" style="margin-bottom:15px">
                        <%: L.T("Student.OpportunityDetails.ThisOpportunityIsAvailableToStudents") %>
                    </p>

                    <div class="od-info-item">
                        <span class="od-info-label"><%: L.T("Student.OpportunityDetails.EligibleCollege") %></span>
                        <span class="od-info-value">
                            <%: ValueOrDefault(SelectedOpportunity.EligibleCollege) %>
                        </span>
                    </div>

                    <div style="margin-top:18px">
                        <div class="od-info-label" style="margin-bottom:10px">
                            <%: L.T("Student.OpportunityDetails.EligibleMajors") %>
                        </div>

                        <div class="od-major-list">
                            <% if (SelectedOpportunity.EligibleMajors != null &&
                                   SelectedOpportunity.EligibleMajors.Count > 0) { %>

                                <% foreach (string major in SelectedOpportunity.EligibleMajors) { %>
                                    <span class="od-major"><%: major %></span>
                                <% } %>

                            <% } else { %>
                                <span class="od-major"><%: L.T("Student.OpportunityDetails.AllMajorsInEligibleCollege") %></span>
                            <% } %>
                        </div>
                    </div>
                </section>

            </div>

            <div>

                <section class="od-panel">
                    <h3><%: L.T("Student.OpportunityDetails.InternshipInformation") %></h3>

                    <div class="od-info-item">
                        <span class="od-info-label"><%: L.T("Student.OpportunityDetails.Company") %></span>
                        <span class="od-info-value"><%: CompanyNameText %></span>
                    </div>

                    <div class="od-info-item">
                        <span class="od-info-label"><%: L.T("Student.OpportunityDetails.Location") %></span>
                        <span class="od-info-value">
                            <%: ValueOrDefault(SelectedOpportunity.Location) %>
                        </span>
                    </div>

                    <div class="od-info-item">
                        <span class="od-info-label"><%: L.T("Student.OpportunityDetails.TrainingDuration") %></span>
                        <span class="od-info-value">
                            <%: SelectedOpportunity.DurationWeeks %> <%: L.T("Student.OpportunityDetails.Weeks") %>
                        </span>
                    </div>

                    <div class="od-info-item">
                        <span class="od-info-label"><%: L.T("Student.OpportunityDetails.TrainingStart") %></span>
                        <span class="od-info-value">
                            <%: DisplayDate(SelectedOpportunity.StartDate) %>
                        </span>
                    </div>

                    <div class="od-info-item">
                        <span class="od-info-label"><%: L.T("Student.OpportunityDetails.ApplyBefore") %></span>
                        <span class="od-info-value">
                            <%: DisplayDate(SelectedOpportunity.ApplicationDeadline) %>
                        </span>
                    </div>

                    <div class="od-info-item">
                        <span class="od-info-label"><%: L.T("Student.OpportunityDetails.RemainingSeats") %></span>
                        <span class="od-info-value">
                            <%: SelectedOpportunity.RemainingSeats %>
                        </span>
                    </div>

                </section>

                <section class="od-panel od-apply-panel">
                    <h3><%: ExistingApplication != null ? L.T("Student.Opportunities.Applied") : L.T("Student.OpportunityDetails.ReadyToApply") %></h3>

                    <% if (ExistingApplication == null) { %>
                    <p>
                        <%: L.T("Student.OpportunityDetails.InterestedInThisOpportunityStartYour") %>
                    </p>
                    <% } %>

                    <% if (CanApply || ExistingApplication != null) { %>

                        <a class="od-button" href="<%: ApplyUrl %>">
                            <%: ExistingApplication != null ? L.T("Student.MyApplications.ViewApplication") : L.T("Student.OpportunityDetails.ApplyNow") %>
                        </a>

                    <% } else { %>

                        <span class="od-disabled">
                            <%: L.T("Student.OpportunityDetails.ApplicationsUnavailable") %>
                        </span>

                    <% } %>

                    <a class="od-button od-button-light"
                       href="<%: ResolveUrl("~/Pages/Student/MyApplications.aspx") %>">
                        <%: L.T("Student.OpportunityDetails.MyApplications") %>
                    </a>
                </section>

            </div>

        </div>

    <% } %>

</div>

</asp:Content>
