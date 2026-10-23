<%@ Page Language="C#" MasterPageFile="~/Layout/Public.master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="InternshipManagementSystem.Pages.PublicArea.Default" Title="Home | GJU Internship Management System" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
<meta name="description" content="Connect your studies with practical experience. Learn about the GJU internship journey and access your university internship portal." />
<link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/home.css?v=20261021-7") %>" />
<link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/home-story.css?v=20261022-campus-5") %>" />
<link rel="preload" href="<%: ResolveUrl("~/Assets/fonts/switzer-600.woff2") %>" as="font" type="font/woff2" crossorigin="anonymous" />
<link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/home-experience.css?v=20261022-taste-2") %>" />
<script defer src="<%: ResolveUrl("~/Assets/js/home-story.js?v=20261023-theme-1") %>"></script>
<script defer src="<%: ResolveUrl("~/Assets/js/home-experience.js?v=20261022-navbar-1") %>"></script>
</asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="home-page">
<div class="home-story campus-story scene" data-scene="campus" data-home-story data-logo="<%: ResolveUrl("~/Assets/images/gju-logo.png") %>">
 <div class="campus-stage" data-story-figure data-scene-state="photo">
  <div class="home-story-viewport" data-story-viewport><img class="home-story-photo" src="<%: ResolveUrl("~/Assets/images/university/b270da86-de83-4a48-898d-7446958fbe45.png") %>" alt="Aerial photograph of German Jordanian University's stone buildings and courtyards" width="1200" height="675" fetchpriority="high" /></div>
  <div class="campus-hotspots" aria-label="Campus landmarks"><a href="#university-gate" hidden data-hotspot="gate">About the system</a><a href="#colleges" hidden data-hotspot="colleges">Colleges</a><a href="#how-it-works" hidden data-hotspot="wheel">How it works</a><a href="#opportunity-destination" hidden data-hotspot="opportunity">Opportunities</a></div>
  <nav class="campus-chapter-nav" aria-label="Campus story chapters">
   <a href="#campus-overview" data-story-link="0" aria-label="Chapter 1: The campus" aria-current="step"><span class="campus-nav-label">Campus</span></a>
   <a href="#university-gate" data-story-link="1" aria-label="Chapter 2: The connection"><span class="campus-nav-label">Connect</span></a>
   <a href="#colleges" data-story-link="2" aria-label="Chapter 3: Your field"><span class="campus-nav-label">Study</span></a>
   <a href="#how-it-works" data-story-link="3" aria-label="Chapter 4: Your journey"><span class="campus-nav-label">Journey</span></a>
   <a href="#opportunity-destination" data-story-link="4" aria-label="Chapter 5: What comes next"><span class="campus-nav-label">Explore</span></a>
  </nav>
  <div class="campus-scene-controls"><span data-story-status>German Jordanian University · Campus photograph</span><button type="button" class="home-story-toggle" data-story-toggle aria-pressed="false" hidden>Pause campus motion</button></div>
 </div>
 <div class="campus-chapters">
 <section class="campus-chapter campus-opening" id="campus-overview" data-chapter="0" aria-labelledby="home-title"><div class="campus-copy">
  <h1 id="home-title" data-copy-zone><span>Campus today.</span> <span>Career tomorrow.</span></h1>
  <div class="campus-opening-intro" data-copy-zone>
  <p>Your internship journey at German Jordanian University. Connect your studies with practical experience, from the first application to final review.</p>
  <div class="public-actions"><a class="public-button" href="#opportunities">Explore internships &rarr;</a><a class="public-text-link" href="#how-it-works">How it works</a></div>
  <nav class="home-jump-nav" aria-label="On this page"><a href="#colleges">Colleges</a><a href="#internship-video">Process video</a><a href="#opportunities">Opportunities</a></nav>
  <a class="campus-scroll" href="#university-gate">Explore your campus <span aria-hidden="true">&darr;</span></a>
 </div></div></section>
 <section class="campus-chapter" data-chapter="1" id="university-gate" aria-labelledby="gate-title"><div class="campus-copy"><h2 id="gate-title">A shared<br />starting point.</h2><p>UIMS connects students, companies and university supervisors. Manage applications, follow training tasks and stay connected through every stage of your internship.</p><a class="public-text-link" href="<%: ResolveUrl("~/Pages/Public/About.aspx") %>">About the internship system &rarr;</a></div></section>
<section class="campus-chapter campus-colleges" data-chapter="2" id="colleges" aria-labelledby="colleges-title">
 <div class="campus-copy"><div class="home-section-heading"><h2 id="colleges-title">Your field.<br />Your future.</h2><p>Explore the college, programs and specializations currently supported by the internship portal.</p></div>
 <div class="home-college-layout"><details class="home-college" id="computing-college" open><summary><span><strong><%: Constants.CollegeName %></strong><small>Programs &amp; specializations</small></span><span class="home-college-action" aria-hidden="true"><span class="home-college-closed">Explore</span><span class="home-college-open">Close</span><b>+</b></span></summary><div class="home-college-content"> <div class="home-programs"><% foreach (var program in Constants.Programs) { %><article class="home-program"><h3><%: program %></h3><p>Specializations</p><ul><% foreach (var track in TracksFor(program)) { %><li><%: track %></li><% } %></ul></article><% } %></div>
</div></details></div></div>
</section>
<section class="campus-chapter campus-process" data-chapter="3" id="how-it-works" aria-labelledby="process-title">
 <div class="campus-copy"><div class="home-section-heading"><h2 id="process-title">Learn. Apply.<br />Grow.</h2><p>Understand each stage before you begin. Your company and academic supervisors guide your progress along the way.</p></div>
 <ol class="home-steps"><li><h3>Explore opportunities</h3><p>Find internships that match your college and major.</p></li><li><h3>Apply &amp; confirm</h3><p>Apply, follow the company decision and confirm one accepted offer.</p></li><li><h3>Train &amp; grow</h3><p>Complete tasks, submit work and learn from your supervisors' feedback.</p></li><li><h3>Complete your review</h3><p>Track approved hours and evaluations through the final university review.</p></li></ol><a class="public-text-link" href="#internship-video">Watch the process guide &darr;</a></div>
</section>
<section class="campus-chapter" data-chapter="4" id="opportunity-destination" aria-labelledby="destination-title"><div class="campus-copy"><h2 id="destination-title">Make your<br />next move.</h2><p>Discover published internship summaries. Log in with your university account to view full details and apply.</p><div class="public-actions"><a class="public-button" href="#opportunities">Explore opportunities &darr;</a><a class="public-text-link" href="<%: ResolveUrl("~/Pages/Account/Login.aspx") %>">Log in to your portal</a></div></div></section>
 </div>
</div>
<section class="home-section home-gallery" aria-labelledby="campus-gallery-title">
 <div class="home-section-heading"><h2 id="campus-gallery-title">A campus<br />you know.</h2><p>The entrance, the courtyard and the spaces between. Explore the German Jordanian University landmarks that shape this experience.</p></div>
 <div class="home-gallery-layout">
  <figure class="home-gallery-main"><img src="<%: ResolveUrl("~/Assets/images/university/b774db96-c900-40dc-b579-3fa681fb49ec.png") %>" alt="Timber courtyard waterwheel beside its limestone support and blue water basin at GJU" width="1200" height="900" loading="lazy" /><figcaption>The courtyard waterwheel</figcaption></figure>
  <figure><img src="<%: ResolveUrl("~/Assets/images/university/b1138b1f-421a-4fb1-9003-2d233d57c05c.png") %>" alt="GJU Gate 1 with its original bilingual university sign and metal entrance gates" width="1200" height="800" loading="lazy" /><figcaption>Gate 1, German Jordanian University</figcaption></figure>
  <figure><img src="<%: ResolveUrl("~/Assets/images/university/4a85f19e-09cd-47d5-b8de-a18f277616a7.png") %>" alt="Glazed university connector framed by limestone buildings, steps and a courtyard tree" width="1200" height="900" loading="lazy" /><figcaption>Stone, glass and shared spaces</figcaption></figure>
 </div>
</section>
<section class="home-section home-video" id="internship-video" aria-labelledby="video-title"><div class="home-video-intro"><h2 id="video-title">See the path<br />ahead.</h2><p>Understand the internship process. Use this guide alongside the steps above, and ask your coordinator about university-specific requirements.</p><a class="public-text-link" href="#how-it-works">Explore the four steps &uarr;</a></div>
<% if (ProcessVideoAvailable) { %><video class="home-process-video" controls preload="metadata" playsinline poster="<%: ResolveUrl("~/Assets/images/home-campus.jpg") %>" aria-label="University internship process video"><source src="<%: ResolveUrl("~/Assets/video/internship-process.mp4") %>" type="video/mp4" /><% if (ProcessCaptionsAvailable) { %><track kind="captions" src="<%: ResolveUrl("~/Assets/video/internship-process.en.vtt") %>" srclang="en" label="English" default /><% } %>Your browser does not support video. <a href="<%: ResolveUrl("~/Assets/video/internship-process.mp4") %>">Open the video</a>.</video><% if (!ProcessCaptionsAvailable) { %><p class="home-access-note">Development notice: captions for this video have not been provided.</p><% } %>
<% } else { %><div class="home-video-visual"><img src="<%: ResolveUrl("~/Assets/images/university/6753e8dc-1deb-4e1d-848c-79304737fb69.png") %>" alt="The real German Jordanian University courtyard, with its timber waterwheel, limestone buildings and glazed connector" width="1200" height="800" loading="lazy" /><div class="home-video-placeholder" role="note"><strong>Official video coming here.</strong><p>Development placeholder: the university's internship process video and captions have not been provided yet.</p><a class="public-text-link" href="#how-it-works">Read the internship steps &rarr;</a></div></div><% } %></section>
<section class="home-section" id="opportunities" aria-labelledby="opportunities-title">
 <div class="home-section-heading"><h2 id="opportunities-title">The next chapter<br />is yours.</h2><p>Experience in your field starts with a first look. Browse published summaries, then log in to view full details and apply through your student portal.</p></div>
 <h3 class="home-preview-title">Available internship previews</h3>
 <% if (PreviewError != null) { %><p class="public-preview-notice" role="status"><%: PreviewError %></p><% } else if (Previews.Count == 0) { %><p class="public-preview-notice">No public internship summaries are published right now. Check back later or log in to view your student portal.</p><% } else { %>
 <div class="home-preview-grid"><% foreach (var preview in Previews) { %><article class="home-preview" data-preview-id="<%: preview.Id %>"><h3><%: preview.Title %></h3><p class="home-preview-meta"><%: preview.CompanyName %><% if (!string.IsNullOrWhiteSpace(preview.Location)) { %> &middot; <%: preview.Location %><% } %></p><p><%: preview.Summary %></p><a class="public-text-link" href="<%: ResolveUrl("~/Pages/Student/OpportunityDetails.aspx") %>?id=<%: Server.UrlEncode(preview.Id) %>">Log in to view details <span aria-hidden="true">&rarr;</span></a></article><% } %></div>
 <% } %><p class="home-access-note">Only published summaries are public. Full details and applications require an authenticated student account.</p>
</section>
<section class="home-cta" aria-labelledby="cta-title"><div><h2 id="cta-title">Ready for your next chapter?</h2><p>Continue with your university internship account.</p></div><a class="public-button" href="<%: ResolveUrl("~/Pages/Account/Login.aspx") %>">Log in to get started <span aria-hidden="true">&rarr;</span></a></section>
</div>
</asp:Content>
