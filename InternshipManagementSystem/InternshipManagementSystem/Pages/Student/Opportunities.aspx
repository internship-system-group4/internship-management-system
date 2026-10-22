
<%@ Page Language="C#" MasterPageFile="~/Layout/Student.master"
    AutoEventWireup="true" CodeBehind="Opportunities.aspx.cs"
    Inherits="InternshipManagementSystem.Pages.StudentArea.Opportunities"
    Title="Explore Opportunities" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
<style>
.explore-page {
    --ex-navy: var(--ui-primary);
    --ex-blue: #28547d;
    --ex-muted: #71839a;
    --ex-line: #e0e8f2;
    max-width: 1200px;
    margin: 0 auto;
    padding-bottom: 35px;
    color: #1b3551;
}
.explore-page * { box-sizing: border-box; }
.ex-heading {
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: 14px;
    margin-bottom: 23px;
}
.ex-heading h2 {
    font-size: 27px;
    font-weight: 800;
    color: var(--ex-navy);
    margin: 0 0 7px;
}
.ex-heading p {
    color: var(--ex-muted);
    font-size: 13px;
    margin: 0;
}
.ex-count {
    display: inline-flex;
    align-items: center;
    gap: 9px;
    background: #eaf2fb;
    color: #24537e;
    padding: 10px 15px;
    border-radius: 30px;
    font-size: 12px;
    font-weight: 800;
}
.ex-count-number {
    background: #fff;
    border-radius: 50px;
    padding: 3px 9px;
}
.ex-hero {
    position: relative;
    overflow: hidden;
    background: linear-gradient(110deg, #183e64, #316a99);
    border-radius: 15px;
    padding: 27px 29px;
    color: #fff;
    margin-bottom: 22px;
}
.ex-hero:after {
    content: "";
    position: absolute;
    right: -60px;
    top: -80px;
    width: 210px;
    height: 210px;
    border: 32px solid rgba(255,255,255,.07);
    border-radius: 50%;
}
.ex-hero h3 {
    color: #fff;
    font-size: 21px;
    margin: 0 0 10px;
    font-weight: 800;
}
.ex-hero p {
    color: #e4eff9;
    font-size: 13px;
    line-height: 1.7;
    margin: 0;
    max-width: 650px;
}
.ex-filter-panel {
    background: #fff;
    border: 1px solid var(--ex-line);
    border-radius: 13px;
    padding: 21px;
    margin-bottom: 21px;
}
.ex-filter-top {
    display: flex;
    justify-content: space-between;
    flex-wrap: wrap;
    align-items: center;
    gap: 10px;
    margin-bottom: 16px;
}
.ex-filter-top strong {
    font-size: 14px;
    color: var(--ex-navy);
}
.ex-filter-top span {
    color: var(--ex-muted);
    font-size: 12px;
}
.ex-search-row {
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
}
.ex-search-box {
    position: relative;
    flex: 1;
    min-width: 210px;
}
.ex-search-box input {
    width: 100%;
    padding: 12px 14px 12px 41px;
    border: 1px solid #d7e1ed;
    border-radius: 9px;
    outline: none;
    font: inherit;
    font-size: 13px;
    background: #fbfdff;
}
.ex-search-box input:focus {
    border-color: #5187b9;
    box-shadow: 0 0 0 3px rgba(55,113,167,.10);
}
.ex-search-icon {
    position: absolute;
    left: 14px;
    top: 12px;
    color: #8395a8;
    font-size: 16px;
}
.ex-button {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    padding: 12px 19px;
    border: 0;
    border-radius: 9px;
    background: var(--ex-navy);
    color: #fff !important;
    font-size: 12px;
    font-weight: 800;
    text-decoration: none !important;
    cursor: pointer;
}
.ex-button:hover { background: #102e4d; }
.ex-button-secondary {
    background: #eef3f9;
    color: #28547d !important;
}
.ex-button-secondary:hover { background: #e0eaf5; }
.ex-filter-note {
    display: flex;
    gap: 9px;
    flex-wrap: wrap;
    margin-top: 15px;
}
.ex-chip {
    display: inline-block;
    padding: 7px 11px;
    border-radius: 30px;
    background: #eef5fd;
    color: #315d88;
    font-size: 11px;
    font-weight: 700;
}
.ex-results-title {
    display: flex;
    justify-content: space-between;
    gap: 10px;
    align-items: center;
    margin: 0 0 16px;
}
.ex-results-title h3 {
    color: var(--ex-navy);
    font-size: 17px;
    margin: 0;
    font-weight: 800;
}
.ex-results-title span {
    color: var(--ex-muted);
    font-size: 12px;
}
.ex-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 18px;
}
.ex-card {
    display: flex;
    flex-direction: column;
    min-width: 0;
    padding: 22px;
    border-radius: 13px;
    background: #fff;
    border: 1px solid var(--ex-line);
    box-shadow: 0 4px 16px rgba(22,52,82,.035);
    transition: .2s ease;
}
.ex-card:hover {
    transform: translateY(-2px);
    border-color: #afc9e2;
    box-shadow: 0 10px 25px rgba(22,52,82,.075);
}
.ex-card-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    gap: 10px;
}
.ex-card h3 {
    color: var(--ex-navy);
    font-size: 17px;
    font-weight: 800;
    line-height: 1.45;
    margin: 0 0 7px;
    overflow-wrap: anywhere;
}
.ex-company {
    color: #52718e;
    font-size: 12px;
    font-weight: 700;
}
.ex-status {
    background: #e7f6ed;
    color: #247449;
    padding: 6px 10px;
    border-radius: 30px;
    font-size: 10px;
    font-weight: 800;
    white-space: nowrap;
}
.ex-description {
    margin: 17px 0;
    color: #687c92;
    font-size: 12px;
    line-height: 1.85;
    overflow-wrap: anywhere;
}
.ex-card-details {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 15px;
    margin-top: auto;
    padding: 17px 0;
    border-top: 1px solid #edf1f6;
    border-bottom: 1px solid #edf1f6;
}
.ex-detail-label {
    display: block;
    color: #8191a5;
    font-size: 10px;
    font-weight: 700;
    margin-bottom: 5px;
}
.ex-detail-value {
    display: block;
    color: #284766;
    font-size: 12px;
    font-weight: 800;
    overflow-wrap: anywhere;
}
.ex-card-bottom {
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: 12px;
    padding-top: 17px;
}
.ex-available {
    font-size: 11px;
    color: #54728b;
    font-weight: 700;
}
.ex-notice {
    padding: 15px 18px;
    margin-bottom: 20px;
    background: #fff7e7;
    border: 1px solid #f1d9ab;
    border-radius: 10px;
    color: #805817;
    font-size: 13px;
}
.ex-empty {
    background: #fff;
    border: 1px dashed #cfdeed;
    border-radius: 13px;
    padding: 55px 25px;
    text-align: center;
}
.ex-empty-symbol {
    width: 58px;
    height: 58px;
    display: grid;
    place-items: center;
    border-radius: 50%;
    background: #edf4fc;
    color: #315f8a;
    font-size: 26px;
    margin: 0 auto 17px;
}
.ex-empty h3 {
    color: var(--ex-navy);
    font-size: 18px;
    margin: 0 0 10px;
}
.ex-empty p {
    color: var(--ex-muted);
    font-size: 13px;
    line-height: 1.8;
    margin: 0 0 20px;
}
@media(max-width: 800px) {
    .ex-grid { grid-template-columns: 1fr; }
}
@media(max-width: 480px) {
    .ex-heading h2 { font-size: 23px; }
    .ex-hero { padding: 22px; }
    .ex-card-details { grid-template-columns: 1fr; }
    .ex-card-bottom { align-items: stretch; }
    .ex-card-bottom .ex-button { width: 100%; }
}
</style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

<div class="explore-page">

    <div class="ex-heading">
        <div>
            <h2>Explore Opportunities</h2>
            <p>Find internship opportunities that match your academic program.</p>
        </div>
        <div class="ex-count">
            Available Opportunities
            <span class="ex-count-number"><%: AvailableOpportunities.Count %></span>
        </div>
    </div>

    <div class="ex-hero">
        <h3>Discover Your Next Internship</h3>
        <p>
            Explore opportunities from partner companies, discover the skills
            you can develop, and take the next step in your career.
        </p>
    </div>

    <% if (!string.IsNullOrEmpty(Notice)) { %>
        <div class="ex-notice" role="alert"><%: Notice %></div>
    <% } %>

    <div class="ex-filter-panel">
        <div class="ex-filter-top">
            <strong>Search &amp; Academic Filters</strong>
            <span>Results are filtered automatically for your program.</span>
        </div>

        <div class="ex-search-row">
            <div class="ex-search-box">
                <span class="ex-search-icon">&#9906;</span>
                <input id="exSearch" type="search"
                       placeholder="Search by opportunity, company or location..."
                       maxlength="100"
                       value="<%: SearchText %>" />
            </div>
            <button type="button" class="ex-button"
                    onclick="searchOpportunities()">Search</button>
            <a class="ex-button ex-button-secondary"
               href="<%: ResolveUrl("~/Pages/Student/Opportunities.aspx") %>">
                Clear
            </a>
        </div>

        <div class="ex-filter-note">
            <span class="ex-chip">College: <%: StudentCollege %></span>
            <span class="ex-chip">Major: <%: StudentMajor %></span>
            <span class="ex-chip">Status: Open</span>
        </div>
    </div>

    <div class="ex-results-title">
        <h3>Internships For You</h3>
        <span><%: AvailableOpportunities.Count %> matching opportunities</span>
    </div>

    <% if (AvailableOpportunities.Count == 0) { %>

        <div class="ex-empty">
            <div class="ex-empty-symbol">&#128269;</div>
            <h3>No Matching Opportunities</h3>
            <p>
                There are currently no available internships matching
                your academic program and search.
                <br />
                Try another search or check back later.
            </p>
            <a class="ex-button ex-button-secondary"
               href="<%: ResolveUrl("~/Pages/Student/Opportunities.aspx") %>">
                Reset Search
            </a>
        </div>

    <% } else { %>

        <div class="ex-grid">
            <% foreach (var opportunity in AvailableOpportunities) { %>
                <article class="ex-card">

                    <div class="ex-card-header">
                        <div>
                            <h3><%: opportunity.Title %></h3>
                            <div class="ex-company">
                                <%: string.IsNullOrWhiteSpace(opportunity.CompanyName)
                                    ? "Partner Company"
                                    : opportunity.CompanyName %>
                            </div>
                        </div>
                        <span class="ex-status">Open</span>
                    </div>

                    <p class="ex-description">
                        <%: ShortDescription(opportunity.Description) %>
                    </p>

                    <div class="ex-card-details">
                        <div>
                            <span class="ex-detail-label">LOCATION</span>
                            <span class="ex-detail-value">
                                <%: string.IsNullOrWhiteSpace(opportunity.Location)
                                    ? "Not specified"
                                    : opportunity.Location %>
                            </span>
                        </div>
                        <div>
                            <span class="ex-detail-label">DURATION</span>
                            <span class="ex-detail-value">
                                <%: opportunity.DurationWeeks %> weeks
                            </span>
                        </div>
                        <div>
                            <span class="ex-detail-label">AVAILABLE SEATS</span>
                            <span class="ex-detail-value">
                                <%: opportunity.RemainingSeats %>
                                of <%: opportunity.TotalSeats %>
                            </span>
                        </div>
                        <div>
                            <span class="ex-detail-label">APPLICATION DEADLINE</span>
                            <span class="ex-detail-value">
                                <%: DisplayDate(opportunity.ApplicationDeadline) %>
                            </span>
                        </div>
                    </div>

                    <div class="ex-card-bottom">
                        <span class="ex-available">
                            &#10003; Matches your academic program
                        </span>
                        <a class="ex-button"
                           href="<%: DetailsUrl(opportunity.Id) %>">
                            View Details &rarr;
                        </a>
                    </div>

                </article>
            <% } %>
        </div>

    <% } %>

</div>

<script type="text/javascript">
function searchOpportunities() {
    var input = document.getElementById("exSearch");
    if (!input) return;

    var search = input.value.trim();
    var url = "Opportunities.aspx";

    if (search.length > 0) {
        url += "?q=" + encodeURIComponent(search);
    }

    window.location.href = url;
}

(function () {
    var input = document.getElementById("exSearch");
    if (!input) return;

    input.addEventListener("keydown", function (event) {
        if (event.key === "Enter") {
            event.preventDefault();
            searchOpportunities();
        }
    });
})();
</script>

</asp:Content>
