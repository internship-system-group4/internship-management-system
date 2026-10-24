
<%@ Page Language="C#"
    MasterPageFile="~/Layout/Student.master"
    AutoEventWireup="true"
    CodeBehind="Opportunities.aspx.cs"
    Inherits="InternshipManagementSystem.Pages.StudentArea.Opportunities"
    Title="Explore Opportunities" %>

<asp:Content ID="Head"
    ContentPlaceHolderID="head"
    runat="server">

<style>
.explore-page {
    --ex-navy: var(--ui-primary);
    --ex-blue: #28547d;
<<<<<<< HEAD
    --ex-muted: var(--th-fg-71839a, #71839a);
    --ex-line: var(--th-line-e0e8f2, #e0e8f2);
=======
    --ex-muted: var(--ui-muted);
    --ex-line: var(--th-line-e0e8f2,#e0e8f2);
>>>>>>> 92609b2de163de49122c0c0aacaef691ee68bc27
    max-width: 1200px;
    margin: 0 auto;
    padding-bottom: 35px;
    color: var(--th-fg-1b3551, #1b3551);
}

.explore-page * {
    box-sizing: border-box;
}

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
    color: var(--ui-primary-text, var(--ex-navy));
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
    background: var(--th-bg-eaf2fb, #eaf2fb);
    color: var(--th-fg-24537e, #24537e);
    padding: 10px 15px;
    border-radius: 30px;
    font-size: 12px;
    font-weight: 800;
}

.ex-count-number {
    background: var(--ui-surface, #fff);
    border-radius: 50px;
    padding: 3px 9px;
}

.ex-hero {
    position: relative;
    overflow: hidden;
    background: linear-gradient(
        110deg,
        var(--th-bg-183e64, #183e64),
        var(--th-bg-316a99, #316a99)
    );
    border-radius: 15px;
    padding: 27px 29px;
    color: #fff;
    margin-bottom: 22px;
}

.ex-hero:after {
    content: "";
    position: absolute;
    inset-inline-end: -60px;
    top: -80px;
    width: 210px;
    height: 210px;
    border: 32px solid rgba(255,255,255,.07);
    border-radius: 50%;
    pointer-events: none;
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
    background: var(--ui-surface, #fff);
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
    color: var(--ui-primary-text, var(--ex-navy));
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
    border: 1px solid var(--th-line-d7e1ed, #d7e1ed);
    border-radius: 9px;
    outline: none;
    font: inherit;
    font-size: 13px;
    background: var(--th-bg-fbfdff, #fbfdff);
    color: inherit;
}

.ex-search-box input:focus {
    border-color: var(--th-line-5187b9, #5187b9);
    box-shadow: 0 0 0 3px rgba(55,113,167,.10);
}

.ex-search-icon {
    position: absolute;
    inset-inline-start: 14px;
    top: 12px;
    color: var(--th-fg-8395a8, #8395a8);
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
    transition: background .2s ease, transform .2s ease;
}

.ex-button:hover {
    background: var(--th-bg-102e4d, #102e4d);
    transform: translateY(-1px);
}

.ex-button-secondary {
    background: var(--th-bg-eef3f9, #eef3f9);
    color: var(--th-fg-28547d, #28547d) !important;
}

.ex-button-secondary:hover {
    background: var(--th-bg-e0eaf5, #e0eaf5);
}

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
    background: var(--th-bg-eef5fd, #eef5fd);
    color: var(--th-fg-315d88, #315d88);
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
    color: var(--ui-primary-text, var(--ex-navy));
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
    background: var(--ui-surface, #fff);
    border: 1px solid var(--ex-line);
    box-shadow: 0 4px 16px rgba(22,52,82,.035);
    transition: .2s ease;
}

.ex-card:hover {
    transform: translateY(-2px);
    border-color: var(--th-line-afc9e2, #afc9e2);
    box-shadow: 0 10px 25px rgba(22,52,82,.075);
}

.ex-card-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    gap: 10px;
}

.ex-card h3 {
    color: var(--ui-primary-text, var(--ex-navy));
    font-size: 17px;
    font-weight: 800;
    line-height: 1.45;
    margin: 0 0 7px;
    overflow-wrap: anywhere;
}

.ex-company {
    color: var(--th-fg-52718e, #52718e);
    font-size: 12px;
    font-weight: 700;
}

.ex-status {
    background: var(--th-bg-e7f6ed, #e7f6ed);
    color: var(--th-fg-247449, #247449);
    padding: 6px 10px;
    border-radius: 30px;
    font-size: 10px;
    font-weight: 800;
    white-space: nowrap;
}

.ex-description {
    margin: 17px 0;
<<<<<<< HEAD
    color: var(--th-fg-687c92, #687c92);
=======
    color: var(--ui-muted);
>>>>>>> 92609b2de163de49122c0c0aacaef691ee68bc27
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
    border-top: 1px solid var(--th-line-edf1f6, #edf1f6);
    border-bottom: 1px solid var(--th-line-edf1f6, #edf1f6);
}

.ex-detail-label {
    display: block;
<<<<<<< HEAD
    color: var(--th-fg-8191a5, #8191a5);
=======
    color: var(--ui-muted);
>>>>>>> 92609b2de163de49122c0c0aacaef691ee68bc27
    font-size: 10px;
    font-weight: 700;
    margin-bottom: 5px;
}

.ex-detail-value {
    display: block;
    color: var(--th-fg-284766, #284766);
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
    color: var(--th-fg-54728b, #54728b);
    font-weight: 700;
}

.ex-notice {
    padding: 15px 18px;
    margin-bottom: 20px;
    background: var(--th-bg-fff7e7, #fff7e7);
    border: 1px solid var(--th-line-f1d9ab, #f1d9ab);
    border-radius: 10px;
    color: var(--th-fg-805817, #805817);
    font-size: 13px;
}

.ex-empty {
    background: var(--ui-surface, #fff);
    border: 1px dashed var(--th-line-cfdeed, #cfdeed);
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
    background: var(--th-bg-edf4fc, #edf4fc);
    color: var(--th-fg-315f8a, #315f8a);
    font-size: 26px;
    margin: 0 auto 17px;
}

.ex-empty h3 {
    color: var(--ui-primary-text, var(--ex-navy));
    font-size: 18px;
    margin: 0 0 10px;
}

.ex-empty p {
    color: var(--ex-muted);
    font-size: 13px;
    line-height: 1.8;
    margin: 0 0 20px;
}

/* CONFIRMED INTERNSHIP */

.ex-confirmed {
    max-width: 720px;
    margin: 35px auto;
    padding: 45px 35px;
    text-align: center;
    background: var(--ui-surface, #fff);
    border: 1px solid var(--ex-line);
    border-radius: 18px;
    box-shadow: 0 12px 35px rgba(22,52,82,.06);
}

.ex-confirmed-icon {
    width: 76px;
    height: 76px;
    margin: 0 auto 22px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 50%;
    background: #e7f6ed;
    color: #17603a;
    font-size: 38px;
    font-weight: 800;
}

.ex-confirmed h2 {
    color: var(--ui-primary-text, var(--ex-navy));
    font-size: 27px;
    font-weight: 800;
    margin: 0 0 12px;
}

.ex-confirmed-message {
    color: var(--ex-muted);
    font-size: 14px;
    line-height: 1.9;
    margin: 0 auto 26px;
    max-width: 520px;
}

.ex-confirmed-details {
    background: var(--th-bg-eef5fd, #eef5fd);
    border: 1px solid var(--ex-line);
    border-radius: 13px;
    padding: 23px;
    margin-bottom: 25px;
    text-align: start;
}

.ex-confirmed-details span {
    display: block;
    color: var(--ex-muted);
    font-size: 11px;
    font-weight: 800;
    letter-spacing: .5px;
    margin-bottom: 9px;
}

.ex-confirmed-details h3 {
    color: var(--ui-primary-text, var(--ex-navy));
    font-size: 19px;
    font-weight: 800;
    margin: 0 0 8px;
}

.ex-confirmed-details p {
    color: var(--th-fg-52718e, #52718e);
    font-size: 13px;
    margin: 0;
}

.ex-confirmed .ex-button {
    min-width: 180px;
}

@media (max-width: 800px) {
    .ex-grid {
        grid-template-columns: 1fr;
    }
}

@media (max-width: 480px) {
    .ex-heading h2 {
        font-size: 23px;
    }

    .ex-hero {
        padding: 22px;
    }

    .ex-card-details {
        grid-template-columns: 1fr;
    }

    .ex-card-bottom {
        align-items: stretch;
    }

    .ex-card-bottom .ex-button {
        width: 100%;
    }

    .ex-confirmed {
        padding: 30px 20px;
    }

    .ex-confirmed h2 {
        font-size: 23px;
    }
}
</style>

</asp:Content>

<asp:Content ID="Body"
    ContentPlaceHolderID="MainContent"
    runat="server">

<div class="explore-page">

    <% if (HasConfirmedInternship) { %>

        <div class="ex-confirmed">

            <div class="ex-confirmed-icon">
                &#10003;
            </div>

            <h2>Internship Confirmed!</h2>

            <p class="ex-confirmed-message">
                Congratulations! You have successfully
                confirmed your internship placement.

                You can only have one confirmed internship
                at a time, so other internship opportunities
                are no longer available for application.
            </p>

            <div class="ex-confirmed-details">

                <span>YOUR CONFIRMED INTERNSHIP</span>

                <h3>
                    <%: ConfirmedPlacement.OpportunityTitle %>
                </h3>

                <p>
                    <%: ConfirmedPlacement.CompanyName %>
                </p>

            </div>

            <a class="ex-button"
               href="<%: ResolveUrl("~/Pages/Student/MyApplications.aspx") %>">
                View My Applications
            </a>

        </div>

    <% } else { %>

        <div class="ex-heading">
            <div>
                <h2>
                    <%: L.T("Student.Opportunities.ExploreOpportunities") %>
                </h2>

                <p>
                    <%: L.T("Student.Opportunities.FindInternshipOpportunitiesThatMatchYour") %>
                </p>
            </div>

            <div class="ex-count">
                <%: L.T("Student.Opportunities.AvailableOpportunities") %>

                <span class="ex-count-number">
                    <%: AvailableOpportunities.Count %>
                </span>
            </div>
        </div>

        <div class="ex-hero">
            <h3>
                <%: L.T("Student.Opportunities.DiscoverYourNextInternship") %>
            </h3>

            <p>
                <%: L.T("Student.Opportunities.ExploreOpportunitiesFromPartnerCompaniesDiscover") %>
            </p>
        </div>

        <% if (!string.IsNullOrEmpty(Notice)) { %>
            <div class="ex-notice" role="alert">
                <%: Notice %>
            </div>
        <% } %>

        <div class="ex-filter-panel">

            <div class="ex-filter-top">
                <strong>
                    <%: L.T("Student.Opportunities.SearchAcademicFilters") %>
                </strong>

                <span>
                    <%: L.T("Student.Opportunities.ResultsAreFilteredAutomaticallyForYour") %>
                </span>
            </div>

            <div class="ex-search-row">

                <div class="ex-search-box">
                    <span class="ex-search-icon">
                        &#9906;
                    </span>

                    <input id="exSearch"
                           type="search"
                           placeholder="<%: L.T("Student.Opportunities.SearchByOpportunityCompanyOrLocation") %>"
                           maxlength="100"
                           value="<%: SearchText %>" />
                </div>

                <button type="button"
                        class="ex-button"
                        onclick="searchOpportunities()">
                    <%: L.T("Student.Opportunities.Search") %>
                </button>

                <a class="ex-button ex-button-secondary"
                   href="<%: ResolveUrl("~/Pages/Student/Opportunities.aspx") %>">
                    <%: L.T("Student.Opportunities.Clear") %>
                </a>

            </div>

            <div class="ex-filter-note">

                <span class="ex-chip">
                    <%: L.T("Student.Opportunities.College") %>
                    <%: StudentCollege %>
                </span>

                <span class="ex-chip">
                    <%: L.T("Student.Opportunities.Major") %>
                    <%: StudentMajor %>
                </span>

                <span class="ex-chip">
                    <%: L.T("Student.Opportunities.StatusOpen") %>
                </span>

            </div>

        </div>

        <div class="ex-results-title">

            <h3>
                <%: L.T("Student.Opportunities.InternshipsForYou") %>
            </h3>

            <span>
                <%: AvailableOpportunities.Count %>
                <%: L.T("Student.Opportunities.MatchingOpportunities") %>
            </span>

        </div>

        <% if (AvailableOpportunities.Count == 0) { %>

            <div class="ex-empty">

                <div class="ex-empty-symbol">
                    &#128269;
                </div>

                <h3>
                    <%: L.T("Student.Opportunities.NoMatchingOpportunities") %>
                </h3>

                <p>
                    <%: L.T("Student.Opportunities.ThereAreCurrentlyNoAvailableInternships") %>
                    <br />
                    <%: L.T("Student.Opportunities.TryAnotherSearchOrCheckBack") %>
                </p>

                <a class="ex-button ex-button-secondary"
                   href="<%: ResolveUrl("~/Pages/Student/Opportunities.aspx") %>">
                    <%: L.T("Student.Opportunities.ResetSearch") %>
                </a>

            </div>

        <% } else { %>

            <div class="ex-grid">

                <% foreach (var opportunity in AvailableOpportunities) { %>

                    <article class="ex-card">

                        <div class="ex-card-header">

                            <div>
                                <h3>
                                    <%: opportunity.Title %>
                                </h3>

                                <div class="ex-company">
                                    <%: string.IsNullOrWhiteSpace(opportunity.CompanyName)
                                        ? "Partner Company"
                                        : opportunity.CompanyName %>
                                </div>
                            </div>

                            <span class="ex-status">
                                <%: L.T("Student.Opportunities.Open") %>
                            </span>

                        </div>

                        <p class="ex-description">
                            <%: ShortDescription(opportunity.Description) %>
                        </p>

                        <div class="ex-card-details">

                            <div>
                                <span class="ex-detail-label">
                                    <%: L.T("Student.Opportunities.LOCATION") %>
                                </span>

                                <span class="ex-detail-value">
                                    <%: string.IsNullOrWhiteSpace(opportunity.Location)
                                        ? "Not specified"
                                        : opportunity.Location %>
                                </span>
                            </div>

                            <div>
                                <span class="ex-detail-label">
                                    <%: L.T("Student.Opportunities.DURATION") %>
                                </span>

                                <span class="ex-detail-value">
                                    <%: opportunity.DurationWeeks %>
                                    <%: L.T("Student.Opportunities.Weeks") %>
                                </span>
                            </div>

                            <div>
                                <span class="ex-detail-label">
                                    <%: L.T("Student.Opportunities.AVAILABLESEATS") %>
                                </span>

                                <span class="ex-detail-value">
                                    <%: opportunity.RemainingSeats %>
                                    <%: L.T("Student.Opportunities.Of") %>
                                    <%: opportunity.TotalSeats %>
                                </span>
                            </div>

                            <div>
                                <span class="ex-detail-label">
                                    <%: L.T("Student.Opportunities.APPLICATIONDEADLINE") %>
                                </span>

                                <span class="ex-detail-value">
                                    <%: DisplayDate(opportunity.ApplicationDeadline) %>
                                </span>
                            </div>

                        </div>

                        <div class="ex-card-bottom">

                            <span class="ex-available">
                                <%: L.T("Student.Opportunities.MatchesYourAcademicProgram") %>
                            </span>

                            <a class="ex-button"
                               href="<%: DetailsUrl(opportunity.Id) %>">
                                <%: L.T("Student.Opportunities.ViewDetails") %>
                            </a>

                        </div>

                    </article>

                <% } %>

            </div>

        <% } %>

    <% } %>

</div>

<script type="text/javascript">

function searchOpportunities() {

    var input = document.getElementById("exSearch");

    if (!input) {
        return;
    }

    var search = input.value.trim();
    var url = "Opportunities.aspx";

    if (search.length > 0) {
        url += "?q=" + encodeURIComponent(search);
    }

    window.location.href = url;
}

(function () {

    var input = document.getElementById("exSearch");

    if (!input) {
        return;
    }

    input.addEventListener("keydown", function (event) {

        if (event.key === "Enter") {
            event.preventDefault();
            searchOpportunities();
        }

    });

})();

</script>

</asp:Content>
