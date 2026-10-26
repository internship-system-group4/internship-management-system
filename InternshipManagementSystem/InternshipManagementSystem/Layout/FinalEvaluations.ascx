<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="FinalEvaluations.ascx.cs" Inherits="InternshipManagementSystem.Layout.FinalEvaluations" %>
<%-- The two final evaluations side by side: company supervisor and academic supervisor.
     Coordinator only (confidential). Styles: Assets/css/coordinator-pages.css (.fe-*). --%>
<div class="fe-grid">
<% foreach (var card in Cards) { %>
    <article class="fe-card <%: card.CssState %>" aria-label="<%: card.Kicker %>">
        <header class="fe-head">
            <span class="dir-stat-icon" data-ui-icon="<%: card.Icon %>" aria-hidden="true"></span>
            <div class="fe-head-text">
                <span class="fe-kicker"><%: card.Kicker %></span>
                <span class="fe-title"><%: L.T("Coordinator.Final.Title") %></span>
                <span class="fe-who"><%: card.Evaluator %></span>
            </div>
            <span class="<%: card.StatusCss %>"><%: card.StatusText %></span>
        </header>
        <% if (!card.Submitted) { %>
        <div class="fe-waiting">
            <span class="dir-result-icon <%: card.HasDraft ? "is-warning" : "" %>"><span data-ui-icon="<%: card.HasDraft ? "edit" : "clock" %>" aria-hidden="true"></span></span>
            <strong><%: card.HasDraft ? L.T("Coordinator.Final.DraftTitle") : L.T("Coordinator.Final.WaitingTitle") %></strong>
            <span><%: L.F(card.HasDraft ? "Coordinator.Final.DraftText" : "Coordinator.Final.WaitingText", card.Evaluator) %></span>
        </div>
        <% } else { %>
        <div class="fe-body">
            <div class="fe-score">
                <div class="fe-score-num"><strong><%: Number(card.Total) %></strong><span>/ <%: Number(card.Max) %></span></div>
                <div class="fe-score-side">
                    <div class="fe-score-line"><b><%: Number(card.Percent) %>%</b><span class="fe-date"><span data-ui-icon="calendar" aria-hidden="true"></span><%: L.F("Coordinator.Final.SubmittedOn", InternshipManagementSystem.Common.Time.Friendly(card.SubmittedAt)) %></span></div>
                    <div class="dir-progress" aria-hidden="true"><span style="--dir-p:<%: Bar(card.Percent) %>%"></span></div>
                </div>
            </div>
            <% if (card.Components.Count > 0) { %>
            <div>
                <p class="fe-sub"><%: L.T("Coordinator.Final.Criteria") %></p>
                <ul class="fe-criteria">
                <% foreach (var c in card.Components) { %>
                    <li><span class="fe-crit-name"><%: c.Name %></span><span class="fe-crit-bar" aria-hidden="true"><i style="--p:<%: Bar(c.MaxScore > 0 ? c.Score * 100 / c.MaxScore : 0) %>%"></i></span><span class="fe-crit-score"><%: Number(c.Score) %> / <%: Number(c.MaxScore) %></span></li>
                <% } %>
                </ul>
            </div>
            <% } %>
            <% if (card.Notes.Count > 0) { %>
            <div class="fe-notes">
            <% foreach (var note in card.Notes) { %>
                <div class="fe-note <%: note.Css %>"><span class="fe-note-label"><%: note.Label %></span><div class="fe-note-text"><%: note.Text %></div></div>
            <% } %>
            </div>
            <% } %>
        </div>
        <% } %>
        <% if (card.WeightPercent > 0) { %><footer class="fe-foot"><%: L.F("Coordinator.Final.Weight", card.WeightPercent) %></footer><% } %>
    </article>
<% } %>
</div>
