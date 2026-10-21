
<%@ Page Title="Explore Opportunities"
    Language="C#"
    MasterPageFile="~/Layout/Student.master"
    AutoEventWireup="true"
    CodeBehind="Opportunities.aspx.cs"
    Inherits="InternshipManagementSystem.Pages.StudentArea.Opportunities" %>

<asp:Content ID="Head"
    ContentPlaceHolderID="head"
    runat="server">

<style>
.ex-page {
    max-width: 1150px;
    margin: 0 auto;
    color: var(--ink, #172b49);
}

.ex-header {
    margin-bottom: 24px;
}

.ex-header h2 {
    font-size: 1.65rem;
    font-weight: 750;
    margin-bottom: 8px;
}

.ex-muted {
    color: var(--muted, #64748b);
}

.ex-panel {
    background: var(--surface, #fff);
    border: 1px solid var(--line, #dce5ef);
    border-radius: 15px;
    padding: 22px;
    margin-bottom: 22px;
}

.ex-filter {
    display: flex;
    gap: 12px;
    flex-wrap: wrap;
    align-items: flex-end;
}

.ex-search {
    flex: 1;
    min-width: 220px;
}

.ex-label {
    display: block;
    font-size: .9rem;
    font-weight: 650;
    margin-bottom: 7px;
}

.ex-input {
    width: 100%;
    padding: 11px 13px;
    border: 1px solid #cbd5e1;
    border-radius: 9px;
    background: #fff;
}

.ex-btn {
    display: inline-block;
    padding: 11px 19px;
    border-radius: 9px;
    border: none;
    background: var(--brand, #2259a5);
    color: white;
    font-weight: 700;
    text-decoration: none;
    cursor: pointer;
}

.ex-btn:hover {
    color: #fff;
    filter: brightness(.94);
}

.ex-btn-light {
    background: #edf3fa;
    color: #244c82;
}

.ex-btn-light:hover {
    color: #244c82;
}

.ex-summary {
    display: flex;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: 10px;
    margin-bottom: 17px;
}

.ex-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 18px;
}

.ex-card {
    background: var(--surface, #fff);
    border: 1px solid var(--line, #dce5ef);
    border-radius: 15px;
    padding: 22px;
    display: flex;
    flex-direction: column;
    gap: 13px;
    box-shadow: 0 4px 16px rgba(20, 40, 70, .035);
}

.ex-card-top {
    display: flex;
    justify-content: space-between;
    gap: 12px;
    align-items: flex-start;
}

.ex-card h3 {
    font-size: 1.15rem;
    font-weight: 750;
    margin: 0;
}

.ex-company {
    color: #536580;
    font-weight: 600;
}

.ex-badge {
    padding: 5px 11px;
    border-radius: 30px;
    background: #e6f5eb;
    color: #18613b;
    font-size: .78rem;
    font-weight: 750;
    white-space: nowrap;
}

.ex-desc {
    color: #5c6d82;
    line-height: 1.65;
    overflow-wrap: anywhere;
}

.ex-meta {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 12px;
    font-size: .9rem;
}

.ex-meta strong {
    display: block;
    color: #243d5b;
    margin-bottom: 3px;
}

.ex-card-footer {
    margin-top: auto;
    padding-top: 12px;
    border-top: 1px solid #e6edf4;
}

.ex-empty {
    text-align: center;
    padding: 40px 20px;
    color: #64748b;
}

.ex-notice {
    background: #fff4e5;
    color: #87520e;
    border-radius: 10px;
    padding: 14px 17px;
    margin-bottom: 18px;
}

@media (max-width: 800px) {
    .ex-grid {
        grid-template-columns: 1fr;
    }
}

@media (max-width: 450px) {
    .ex-meta {
        grid-template-columns: 1fr;
    }
}
</style>

</asp:Content>

<asp:Content ID="Body"
    ContentPlaceHolderID="MainContent"
    runat="server">

<div class="ex-page">

    <div class="ex-header">
        <h2>Explore Internship Opportunities</h2>

        <p class="ex-muted">
            Discover internships that match your academic program.
        </p>
    </div>

    <% if (!string.IsNullOrEmpty(Notice)) { %>

        <div class="ex-notice" role="alert">
            <%: Notice %>
        </div>

    <% } %>

    <!-- Search -->

    <div class="ex-panel">

        <div class="ex-filter">

            <div class="ex-search">

                <label class="ex-label" for="exSearch">
                    Search opportunities
                </label>

                <input id="exSearch"
                       class="ex-input"
                       type="search"
                       maxlength="100"
                       placeholder="Title, company, location..."
                       value="<%: SearchText %>" />

            </div>

            <button class="ex-btn"
                    type="button"
                    onclick="searchOpportunities()">
                Search
            </button>

            <a class="ex-btn ex-btn-light"
               href="Opportunities.aspx">
                Clear
            </a>

        </div>

    </div>

    <!-- Results Count -->

    <div class="ex-summary">

        <div>
            <strong>
                <%: AvailableOpportunities.Count %>
                opportunities found
            </strong>
        </div>

        <div class="ex-muted">
            <%: StudentCollege %>
            &bull;
            <%: StudentMajor %>
        </div>

    </div>

    <!-- Empty State -->

    <% if (AvailableOpportunities.Count == 0) { %>

        <div class="ex-panel ex-empty">

            <h3>No matching opportunities</h3>

            <p>
                There are currently no open internships
                matching your academic program and search.
            </p>

        </div>

    <% } else { %>

        <!-- Opportunity Cards -->

        <div class="ex-grid">

            <% foreach (var opportunity in AvailableOpportunities) { %>

                <article class="ex-card">

                    <div class="ex-card-top">

                        <h3>
                            <%: opportunity.Title %>
                        </h3>

                        <span class="ex-badge">
                            Open
                        </span>

                    </div>

                    <div class="ex-company">
                        <%: opportunity.CompanyName %>
                    </div>

                    <p class="ex-desc">
                        <%:
                            opportunity.Description != null &&
                            opportunity.Description.Length > 170
                                ? opportunity.Description.Substring(0, 170) + "..."
                                : opportunity.Description
                        %>
                    </p>

                    <div class="ex-meta">

                        <div>
                            <strong>Location</strong>
                            <%: opportunity.Location %>
                        </div>

                        <div>
                            <strong>Available Seats</strong>
                            <%: opportunity.RemainingSeats %>
                        </div>

                        <div>
                            <strong>Duration</strong>
                            <%: opportunity.DurationWeeks %>
                            weeks
                        </div>

                        <div>
                            <strong>Apply Before</strong>
                            <%: DisplayDate(opportunity.ApplicationDeadline) %>
                        </div>

                    </div>

                    <div class="ex-card-footer">

                        <a class="ex-btn"
                           href="<%: DetailsUrl(opportunity.Id) %>">
                            View Details
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

    if (!input) {
        return;
    }

    var search = input.value.trim();

    var url = "Opportunities.aspx";

    if (search) {
        url += "?q=" + encodeURIComponent(search);
    }

    window.location.href = url;
}

(function () {
    var input = document.getElementById("exSearch");

    if (input) {
        input.addEventListener("keydown", function (event) {
            if (event.key === "Enter") {
                event.preventDefault();
                searchOpportunities();
            }
        });
    }
})();
</script>

</asp:Content>
