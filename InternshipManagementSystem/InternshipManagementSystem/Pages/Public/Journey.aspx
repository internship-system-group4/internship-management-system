<%@ Page Language="C#" MasterPageFile="~/Layout/Public.master" AutoEventWireup="true" CodeBehind="Journey.aspx.cs" Inherits="InternshipManagementSystem.Pages.PublicArea.Journey" Title="The Journey | GJU Internship Management System" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
<meta name="description" content="A real-time 3D journey across the German Jordanian University campus, through the eyes of a student, into the internships that start every career." />
<script type="importmap">{ "imports": { "three": "<%= ResolveUrl("~/Assets/js/vendor/three.module.min.js") %>" } }</script>
<link rel="preload" href="<%: ResolveUrl("~/Assets/fonts/switzer-600.woff2") %>" as="font" type="font/woff2" crossorigin="anonymous" />
<link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/jisr.css?v=20261023-21") %>" />
<script defer src="<%: ResolveUrl("~/Assets/js/vendor/gsap.min.js") %>"></script>
<script defer src="<%: ResolveUrl("~/Assets/js/vendor/ScrollTrigger.min.js") %>"></script>
<script type="module" src="<%: ResolveUrl("~/Assets/js/jisr/jisr-hero.js?v=20261023-26") %>"></script>
</asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="jisr jisr--static" data-jisr data-logo="<%: ResolveUrl("~/Assets/images/gju-logo.png") %>" data-stone="<%: ResolveUrl("~/Assets/images/university/materials/stone-albedo.png") %>" data-student="<%: ResolveUrl("~/Assets/models/people/Male_Adult_17_Animated.glb") %>">
 <div class="jisr-stage" data-jisr-stage>
  <canvas class="jisr-canvas" aria-hidden="true"></canvas>
  <img class="jisr-poster" src="<%: ResolveUrl("~/Assets/images/university/b270da86-de83-4a48-898d-7446958fbe45.png") %>" alt="Aerial view of the German Jordanian University campus in Madaba" width="1280" height="720" />
  <div class="jisr-loader" aria-hidden="true"><span class="jisr-loader-mark">German Jordanian University</span><span class="jisr-loader-bar"></span><span class="jisr-loader-status" data-jisr-status>Preparing the dawn</span></div>

  <section class="jisr-beat jisr-beat--hero" data-beat="0 .15" aria-labelledby="jisr-title">
   <p class="jisr-eyebrow">German Jordanian University <span aria-hidden="true">&middot;</span> Internship Management System</p>
   <h1 id="jisr-title">From Madaba to the world.</h1>
   <p class="jisr-lede">Every GJU internship starts here, on a campus built as a bridge between Jordan and Germany.</p>
   <p class="jisr-cue"><span aria-hidden="true"></span>Scroll to begin</p>
  </section>

  <section class="jisr-beat jisr-beat--left" data-beat=".19 .37" aria-labelledby="jisr-bridge">
   <p class="jisr-kicker">The German Year</p>
   <h2 id="jisr-bridge">A bridge, not a border.</h2>
   <p>Every autumn, white storks from Germany fly south over Jordan. At GJU the crossing runs the other way too: the German Year takes students to a partner university and into German industry.</p>
  </section>

  <section class="jisr-beat jisr-beat--right" data-beat=".43 .61" aria-labelledby="jisr-system">
   <p class="jisr-kicker">UIMS</p>
   <h2 id="jisr-system">One system for the whole journey.</h2>
   <p>UIMS connects students, companies and university supervisors, from the first application to the final evaluation.</p>
   <ul class="jisr-roles">
    <li><strong>Students</strong><span>Explore, apply, log hours</span></li>
    <li><strong>Companies</strong><span>Publish, select, mentor</span></li>
    <li><strong>Supervisors</strong><span>Follow, evaluate, approve</span></li>
   </ul>
  </section>

  <section class="jisr-beat jisr-beat--quiet" data-beat=".655 .672" aria-label="Story">
   <p>Every journey starts with a walk across campus.</p>
  </section>

  <aside class="jisr-reveal" data-reveal="computing" aria-hidden="true">
   <p class="jisr-reveal-label">School of Computing</p>
   <p class="jisr-reveal-line">Where ideas become technology.</p>
  </aside>
  <aside class="jisr-reveal" data-reveal="architecture" aria-hidden="true">
   <p class="jisr-reveal-label">School of Architecture and Built Environment</p>
   <p class="jisr-reveal-line">Designing the spaces we live in.</p>
  </aside>
  <aside class="jisr-reveal" data-reveal="sustainable" aria-hidden="true">
   <p class="jisr-reveal-label">School of Sustainable Systems Engineering</p>
   <p class="jisr-reveal-line">Engineering a sustainable tomorrow.</p>
  </aside>

  <section class="jisr-climax" data-climax aria-labelledby="jisr-climax-title">
   <h2 id="jisr-climax-title">Your Journey Begins Here.</h2>
   <a class="jisr-climax-link" href="#opportunities">Explore open internships <span aria-hidden="true">&darr;</span></a>
  </section>

  <nav class="jisr-rail" data-jisr-rail aria-label="Journey chapters">
   <a href="#jisr-title" data-at="0">Dawn</a><a href="#jisr-bridge" data-at=".19">Bridge</a><a href="#jisr-system" data-at=".43">System</a><a href="#schools" data-at=".64">Campus</a><a href="#opportunities" data-at=".875">Journey</a>
  </nav>
  <button type="button" class="jisr-motion" data-jisr-motion aria-pressed="false">Pause scene motion</button>
 </div>
</div>
<script>(function(){var h=document.querySelector('[data-jisr]');try{if(document.createElement('canvas').getContext('webgl2'))h.classList.remove('jisr--static');}catch(e){}})();</script>

<div class="jisr-after">
 <section class="jisr-section jisr-opps" id="opportunities" aria-labelledby="opps-title">
  <header class="jisr-section-head">
   <p class="jisr-kicker">Open internships</p>
   <h2 id="opps-title">Where will your journey take you?</h2>
   <p>Summaries published by our partner companies. Browse freely; sign in with your university account to see full details and apply.</p>
  </header>
  <% if (PreviewError != null) { %>
   <p class="jisr-notice" role="status"><%: PreviewError %></p>
  <% } else if (Previews.Count == 0) { %>
   <p class="jisr-notice">No internship summaries are published right now. Check back soon, or log in to see opportunities in your student portal.</p>
  <% } else { %>
  <div class="row g-4">
   <% foreach (var item in Previews) { %>
   <div class="col-md-6 col-xl-4">
    <article class="jisr-opp" data-opportunity-id="<%: item.Id %>">
     <p class="jisr-opp-company"><%: item.CompanyName %></p>
     <h3><%: item.Title %></h3>
     <ul class="jisr-opp-meta">
      <% if (!string.IsNullOrWhiteSpace(item.Location)) { %><li><%: item.Location %></li><% } %>
      <% if (!string.IsNullOrWhiteSpace(item.Specialization)) { %><li><%: item.Specialization %></li><% } %>
      <% if (item.RemainingSeats > 0) { %><li><%: item.RemainingSeats %> <%: item.RemainingSeats == 1 ? "seat" : "seats" %> left</li><% } %>
     </ul>
     <p class="jisr-opp-summary"><%: item.Summary %></p>
     <div class="jisr-opp-foot">
      <% var deadline = DeadlineText(item.ApplicationDeadline); if (deadline != null) { %><span><%: deadline %></span><% } %>
      <a class="btn jisr-btn" href="<%: ApplyUrl(item.Id) %>">Apply now</a>
     </div>
    </article>
   </div>
   <% } %>
  </div>
  <% } %>
  <p class="jisr-small">Only published summaries are public. Full details and applications require a signed-in student account; after signing in you return to the opportunity you chose.</p>
 </section>

 <section class="jisr-section jisr-schools" id="schools" aria-labelledby="schools-title">
  <header class="jisr-section-head">
   <p class="jisr-kicker">Academic directory</p>
   <h2 id="schools-title">Eight schools. One university.</h2>
   <p>The schools of German Jordanian University. UIMS currently supports internships for the <%: InternshipManagementSystem.Common.Constants.CollegeName %>; more schools will follow.</p>
  </header>
  <div class="row g-3">
   <% foreach (var school in Schools) { %>
   <div class="col-md-6 col-xl-3">
    <details class="jisr-school<%= school.OnUims ? " is-supported" : "" %>"<%= school.OnUims ? " open" : "" %>>
     <summary>
      <span class="jisr-school-short"><%: school.Short %></span>
      <strong><%: school.Name %></strong>
      <em><%: school.Line %></em>
      <% if (school.OnUims) { %><span class="jisr-badge">On UIMS</span><% } %>
     </summary>
     <div class="jisr-school-body">
      <p class="jisr-school-label"><%: school.ProgramLabel %></p>
      <ul>
       <% foreach (var program in school.Programs) { %>
        <li><%: program %><% var tracks = school.OnUims ? TracksFor(program) : new string[0]; if (tracks.Length > 0) { %><small>Specializations: <%: string.Join(", ", tracks) %></small><% } %></li>
       <% } %>
      </ul>
     </div>
    </details>
   </div>
   <% } %>
  </div>
  <p class="jisr-small">Programme names from gju.edu.jo. The campus in the 3D scene is an artistic interpretation; schools are introduced thematically, not by building.</p>
 </section>

 <section class="jisr-section jisr-process" id="how-it-works" aria-labelledby="process-title">
  <header class="jisr-section-head">
   <p class="jisr-kicker">How it works</p>
   <h2 id="process-title">Learn. Apply. Grow.</h2>
   <p>Your company and academic supervisors guide your progress at every stage.</p>
  </header>
  <ol class="jisr-steps">
   <li><span>01</span><h3>Explore opportunities</h3><p>Find internships that match your school and major.</p></li>
   <li><span>02</span><h3>Apply and confirm</h3><p>Apply, follow the company decision and confirm one accepted offer.</p></li>
   <li><span>03</span><h3>Train and grow</h3><p>Complete tasks, submit work and learn from your supervisors' feedback.</p></li>
   <li><span>04</span><h3>Complete your review</h3><p>Track approved hours and evaluations through the final university review.</p></li>
  </ol>
 </section>

 <section class="jisr-section jisr-video" id="internship-video" aria-labelledby="video-title">
  <header class="jisr-section-head">
   <p class="jisr-kicker">Process video</p>
   <h2 id="video-title">See the path ahead.</h2>
   <p>A short guide to the internship process. Ask your coordinator about school-specific requirements.</p>
  </header>
  <% if (ProcessVideoAvailable) { %>
   <video class="jisr-video-player" controls preload="metadata" playsinline poster="<%: ResolveUrl("~/Assets/images/home-campus.jpg") %>" aria-label="University internship process video"><source src="<%: ResolveUrl("~/Assets/video/internship-process.mp4") %>" type="video/mp4" /><% if (ProcessCaptionsAvailable) { %><track kind="captions" src="<%: ResolveUrl("~/Assets/video/internship-process.en.vtt") %>" srclang="en" label="English" default /><% } %>Your browser does not support video. <a href="<%: ResolveUrl("~/Assets/video/internship-process.mp4") %>">Open the video</a>.</video>
  <% } else { %>
   <div class="jisr-video-placeholder" role="note">
    <img src="<%: ResolveUrl("~/Assets/images/university/6753e8dc-1deb-4e1d-848c-79304737fb69.png") %>" alt="The German Jordanian University courtyard with its timber waterwheel" width="1200" height="800" loading="lazy" />
    <div><strong>The official process video will play here.</strong><p>The university's internship process video and captions have not been provided yet.</p></div>
   </div>
  <% } %>
 </section>

 <section class="jisr-section jisr-cta" aria-labelledby="cta-title">
  <h2 id="cta-title">Ready for your next chapter?</h2>
  <a class="btn btn-lg jisr-btn" href="<%: ResolveUrl("~/Pages/Account/Login.aspx") %>">Log in to your portal</a>
 </section>
</div>
</asp:Content>
