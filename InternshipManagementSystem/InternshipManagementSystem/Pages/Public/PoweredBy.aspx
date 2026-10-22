<%@ Page Language="C#" MasterPageFile="~/Layout/Public.master" AutoEventWireup="true" CodeBehind="PoweredBy.aspx.cs" Inherits="InternshipManagementSystem.Pages.PublicArea.PoweredBy" Title="Meet the Team | GJU Internship Management System" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"><script type="importmap">{ "imports": { "three": "<%= ResolveUrl("~/Assets/js/vendor/three.module.min.js") %>" } }</script><meta name="description" content="Meet the student development team behind the UIMS internship management platform." /><link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/powered-by.css?v=20261022-7") %>" /></asp:Content>
<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server"><script type="module" src="<%: ResolveUrl("~/Assets/js/powered-by.js?v=20261022-12") %>"></script></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<%-- The lecture hall is the team page. Without JavaScript or WebGL the same roster is shown as a plain list. --%>
<div class="team-experience" data-team-experience data-mode="fallback" data-members="<%: Members.Count %>" data-logo="<%: ResolveUrl("~/Assets/images/gju-logo.png") %>">
 <script>(function (root) {
  // Enhance only when scripting runs; a stalled scene still ends in the readable list.
  if (root.getAttribute('data-members') === '0') return;
  root.setAttribute('data-mode', 'loading');
  setTimeout(function () { if (root.getAttribute('data-mode') === 'loading') { root.setAttribute('data-mode', 'fallback'); root.setAttribute('data-failed', ''); } }, 15000);
 }(document.currentScript.parentElement));</script>
 <div class="team-stage" aria-hidden="true"><div data-hall-canvas></div></div>
 <div class="team-loading" role="status" aria-live="polite"><span data-team-loading-text>Preparing the lecture hall</span><span class="team-loading-bar"><span data-team-progress></span></span></div>

 <header class="team-heading">
  <p class="team-eyebrow">Powered by</p>
  <h1 id="team-title">Meet the team</h1>
  <% if (Members.Count > 0) { %><p class="team-lede">The students of Group 4 designed and built UIMS.<span class="team-lede-hall"> Each has a marked seat in this lecture hall.</span></p><% } %>
  <p class="team-credit">Development credit only, not a statement of university ownership or endorsement. Official information: <a href="<%: InternshipManagementSystem.Common.Constants.UniversityWebsite %>" target="_blank" rel="noopener noreferrer">GJU website<span class="visually-hidden"> (opens in a new tab)</span></a>.</p>
 </header>
 <p class="team-failure">The 3D lecture hall could not be shown on this device, so the team is listed below.</p>

 <% if (Members.Count > 0) { %>
 <div class="team-controls">
  <div class="team-finder" data-team-finder>
   <button type="button" class="team-finder-toggle" aria-expanded="false" aria-controls="teamFinderList"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" aria-hidden="true" focusable="false"><circle cx="11" cy="11" r="6.5" /><path d="m16 16 4.5 4.5" /></svg>Find a team member</button>
   <ul id="teamFinderList" class="team-finder-list" aria-label="Team members" hidden>
   <% foreach (var member in Members) { var photo = PhotoUrl(member); %>
    <li><button type="button" data-member-key="<%: member.Key %>"><span class="team-avatar" aria-hidden="true"><%: Initials(member.Name) %><% if (photo != null) { %><img src="<%: photo %>" alt="" width="36" height="36" loading="lazy" decoding="async" onerror="this.remove()" /><% } %></span><span class="team-finder-text"><span dir="auto"><%: member.Name %></span><small dir="auto"><%: member.Role %></small></span></button></li>
   <% } %>
   </ul>
  </div>
  <button type="button" class="team-overview" data-team-overview hidden><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><path d="M4 9V4h5M20 9V4h-5M4 15v5h5M20 15v5h-5" /></svg>View full hall</button>
 </div>
 <div class="team-hover" data-team-hover aria-hidden="true" hidden><strong dir="auto"></strong><span dir="auto"></span></div>

 <aside class="team-profile" data-team-profile role="dialog" aria-modal="false" aria-labelledby="teamProfileName" hidden>
  <div class="team-profile-bar">
   <span class="team-profile-count" data-team-profile-count></span>
   <button type="button" data-team-prev aria-label="Previous team member"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><path d="m14.5 6-6 6 6 6" /></svg></button>
   <button type="button" data-team-next aria-label="Next team member"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><path d="m9.5 6 6 6-6 6" /></svg></button>
   <button type="button" data-team-close aria-label="Close profile"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true" focusable="false"><path d="m6 6 12 12M18 6 6 18" /></svg></button>
  </div>
  <div class="team-profile-body" data-team-profile-body></div>
 </aside>
 <% } %>

 <section class="team-roster-section" aria-labelledby="teamRosterTitle">
  <h2 id="teamRosterTitle">The development team</h2>
  <% if (Members.Count == 0) { %>
  <p class="team-empty">Team profiles are being confirmed. Names, roles and profiles will appear here once each team member approves them for public display.</p>
  <% } else { %>
  <ol class="team-roster">
  <% foreach (var member in Members) { var photo = PhotoUrl(member); var github = SafeLink(member.GitHub); var linkedIn = SafeLink(member.LinkedIn); var portfolio = SafeLink(member.Portfolio); var email = SafeEmail(member.Email); %>
   <li class="team-member" id="member-<%: member.Key %>" data-member-key="<%: member.Key %>">
    <article class="team-member-card">
     <%-- Initials sit under the photo; a photo that fails to load removes itself and reveals them. --%>
     <span class="team-portrait" aria-hidden="true"><%: Initials(member.Name) %><% if (photo != null) { %><img src="<%: photo %>" alt="" width="120" height="120" loading="lazy" decoding="async" onerror="this.remove()" /><% } %></span>
     <div class="team-member-text">
      <h3 class="team-member-name" dir="auto"><%: member.Name %></h3>
      <p class="team-member-role" dir="auto"><%: member.Role %></p>
      <% if (!string.IsNullOrWhiteSpace(member.Bio)) { %><p class="team-member-bio" dir="auto"><%: member.Bio %></p><% } %>
      <% if (email != null) { %><a class="team-email" href="mailto:<%: email %>"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><rect x="3" y="5" width="18" height="14" rx="2" /><path d="m3 7 9 6 9-6" /></svg><span><span class="visually-hidden">Email <%: member.Name %>: </span><%: email %></span></a><% } %>
      <% if (github != null || linkedIn != null || portfolio != null) { %>
      <ul class="team-links">
       <% if (github != null) { %><li><a href="<%: github %>" target="_blank" rel="noopener noreferrer" aria-label="<%: member.Name %> on GitHub (opens in a new tab)"><svg viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path fill="currentColor" d="M12 2a10 10 0 0 0-3.16 19.49c.5.09.68-.22.68-.48v-1.7c-2.78.6-3.37-1.34-3.37-1.34-.45-1.16-1.11-1.47-1.11-1.47-.91-.62.07-.6.07-.6 1 .07 1.53 1.03 1.53 1.03.9 1.52 2.34 1.08 2.91.83.09-.65.35-1.08.63-1.33-2.22-.25-4.55-1.11-4.55-4.94 0-1.09.39-1.98 1.03-2.68-.1-.25-.45-1.27.1-2.65 0 0 .84-.27 2.75 1.02a9.56 9.56 0 0 1 5 0c1.91-1.29 2.75-1.02 2.75-1.02.55 1.38.2 2.4.1 2.65.64.7 1.03 1.59 1.03 2.68 0 3.84-2.34 4.69-4.57 4.93.36.31.68.92.68 1.85v2.74c0 .27.18.58.69.48A10 10 0 0 0 12 2z" /></svg><span>GitHub</span></a></li><% } %>
       <% if (linkedIn != null) { %><li><a href="<%: linkedIn %>" target="_blank" rel="noopener noreferrer" aria-label="<%: member.Name %> on LinkedIn (opens in a new tab)"><svg viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path fill="currentColor" d="M20.45 20.45h-3.56v-5.57c0-1.33-.02-3.04-1.85-3.04-1.86 0-2.14 1.45-2.14 2.94v5.67H9.34V9h3.42v1.56h.05c.48-.9 1.64-1.85 3.37-1.85 3.6 0 4.27 2.37 4.27 5.46v6.28zM5.34 7.43a2.06 2.06 0 1 1 0-4.13 2.06 2.06 0 0 1 0 4.13zM7.12 20.45H3.56V9h3.56v11.45zM22.22 0H1.77C.79 0 0 .77 0 1.73v20.54C0 23.23.79 24 1.77 24h20.45c.98 0 1.78-.77 1.78-1.73V1.73C24 .77 23.2 0 22.22 0z" /></svg><span>LinkedIn</span></a></li><% } %>
       <% if (portfolio != null) { %><li><a href="<%: portfolio %>" target="_blank" rel="noopener noreferrer" aria-label="<%: member.Name %>'s portfolio (opens in a new tab)"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" aria-hidden="true" focusable="false"><circle cx="12" cy="12" r="9" /><path d="M3 12h18M12 3c2.5 2.6 3.8 5.6 3.8 9s-1.3 6.4-3.8 9c-2.5-2.6-3.8-5.6-3.8-9S9.5 5.6 12 3z" /></svg><span>Portfolio</span></a></li><% } %>
      </ul>
      <% } %>
     </div>
    </article>
   </li>
  <% } %>
  </ol>
  <% } %>
 </section>
</div>
<script type="application/json" id="teamHallData"><%= TeamJson() %></script>
</asp:Content>
