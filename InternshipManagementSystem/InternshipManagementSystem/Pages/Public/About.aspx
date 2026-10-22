<%@ Page Language="C#" MasterPageFile="~/Layout/Public.master" AutoEventWireup="true" CodeBehind="About.aspx.cs" Inherits="InternshipManagementSystem.Pages.PublicArea.About" Title="About | GJU Internship Management System" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
<meta name="description" content="Learn about the German Jordanian University, its applied education approach, and UIMS, the Group 4 internship management student project." />
<link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/about.css?v=20261022-5") %>" />
<%-- Entrance reveals pre-hide content only when motion is welcome and about.js actually starts; if it has not
     started within 3 s, everything is shown as normal. --%>
<script>(function(d){if(matchMedia('(prefers-reduced-motion: reduce)').matches)return;d.classList.add('about-motion');setTimeout(function(){if(!d.classList.contains('about-ready'))d.classList.remove('about-motion');},3000);}(document.documentElement));</script>
</asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<%-- About Us. University facts were checked against gju.edu.jo (About the University, University Identity, Programs) on
     22 October 2026; see docs/25-about-page.md. Styles: Assets/css/about.css (scoped to .about-page). Motion and the
     film controls: Assets/js/about.js. --%>
<div class="public-page about-page">

 <%-- Opening: the university film. On wide screens it fills the viewport under the navbar (muted preview, cropped to fill);
      on narrow or portrait screens it keeps its own 2.38:1 frame above the text. The full film always opens uncropped,
      with native controls and sound, in the dialog below. --%>
 <section class="about-opening" id="campus-film" aria-labelledby="about-title" data-film>
  <div class="about-opening-stage">
   <div class="about-opening-frame" data-film-frame>
    <video class="about-opening-video" data-film-preview muted playsinline loop preload="none" width="1280" height="538" poster="<%: ResolveUrl("~/Assets/images/about/about-film-poster.jpg") %>" aria-label="Muted preview of the German Jordanian University film: campus buildings, students and the German Year">
     <source src="<%: ResolveUrl(FilmPath) %>" type='video/mp4; codecs="avc1.64001F, mp4a.40.2"' />
    </video>
    <div class="about-opening-shade" aria-hidden="true"></div>
    <div class="about-film-controls" data-film-controls hidden>
     <button type="button" class="about-film-control" data-film-toggle aria-pressed="false">
      <svg class="is-play" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M8 5.5v13l10.5-6.5z" fill="currentColor" /></svg>
      <svg class="is-pause" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M7.5 5h3v14h-3zM13.5 5h3v14h-3z" fill="currentColor" /></svg>
      <span class="visually-hidden" data-film-toggle-label>Play preview</span>
     </button>
     <button type="button" class="about-film-control" data-film-sound aria-pressed="false">
      <svg class="is-muted" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><path d="M4 9.5h3.5L12 6v12l-4.5-3.5H4z" /><path d="m16 9.5 5 5M21 9.5l-5 5" /></svg>
      <svg class="is-sound" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><path d="M4 9.5h3.5L12 6v12l-4.5-3.5H4z" /><path d="M15.5 9a4 4 0 0 1 0 6M18 6.5a7.5 7.5 0 0 1 0 11" /></svg>
      <span class="visually-hidden" data-film-sound-label>Turn sound on</span>
     </button>
    </div>
    <p class="about-film-status" data-film-status role="status" aria-live="polite"></p>
   </div>
   <div class="public-container about-opening-copy" data-opening-copy>
    <p class="about-eyebrow">Discover GJU</p>
    <h1 id="about-title">Where Learning Meets Experience</h1>
    <p class="about-opening-lead">Explore the campus, the university&rsquo;s applied learning approach and the purpose behind our internship management project.</p>
    <a class="public-button about-film-play" href="<%: ResolveUrl(FilmPath) %>" data-film-open>
     <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M8 5.5v13l10.5-6.5z" fill="currentColor" /></svg>
     Play university film<span class="visually-hidden"> (1 min 48 s, with sound)</span>
    </a>
   </div>
   <a class="about-scroll-cue" href="#discover-gju" data-opening-cue>Explore our story <span aria-hidden="true">&darr;</span></a>
  </div>
 </section>

 <section class="about-section about-overview" id="discover-gju" aria-labelledby="university-title">
  <div class="public-container about-split">
   <div class="about-copy" data-reveal>
    <p class="about-eyebrow">The university</p>
    <h2 id="university-title">German Jordanian University</h2>
    <p>The German Jordanian University (GJU) is a public Jordanian university, founded by Royal Decree in 2005 following a memorandum of understanding between the governments of Jordan and Germany.</p>
    <p>Its education links academic study with practical experience and with what industry needs, following the German model of applied sciences.</p>
    <ul class="about-facts">
     <li><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><rect x="3.5" y="5" width="17" height="15" rx="2" /><path d="M3.5 10h17M8 3v4M16 3v4" /></svg><span>Established in 2005</span></li>
     <li><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><circle cx="9" cy="12" r="5.5" /><circle cx="15" cy="12" r="5.5" /></svg><span>Jordanian&ndash;German Cooperation</span></li>
    </ul>
    <a class="about-official" href="<%: Constants.UniversityWebsite %>" target="_blank" rel="noopener noreferrer">Visit the official GJU website<span class="visually-hidden"> (opens in a new tab)</span> <span aria-hidden="true">&#8599;</span></a>
   </div>
   <figure class="about-figure" data-reveal="clip" data-parallax>
    <img src="<%: ResolveUrl("~/Assets/images/about/about-gate-1.jpg") %>" alt="Gate 1 of the German Jordanian University campus, with the university name in Arabic and English" width="1080" height="810" loading="lazy" decoding="async" />
   </figure>
  </div>
 </section>

 <section class="about-section about-distinctive" aria-labelledby="distinctive-title">
  <div class="public-container">
   <div class="about-section-head" data-reveal>
    <p class="about-eyebrow">The GJU approach</p>
    <h2 id="distinctive-title">What Makes GJU Distinctive</h2>
   </div>
   <ul class="about-features" data-reveal-group>
    <li>
     <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><path d="M2 9.5 12 4.5l10 5-10 5z" /><path d="M6 11.5V16c3.5 2.6 8.5 2.6 12 0v-4.5M22 9.5v5" /></svg>
     <h3>Applied Education</h3>
     <p>Connecting academic knowledge with practical projects and professional experience.</p>
    </li>
    <li>
     <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><circle cx="12" cy="12" r="9" /><path d="M3 12h18M12 3c2.5 2.6 3.8 5.6 3.8 9s-1.3 6.4-3.8 9c-2.5-2.6-3.8-5.6-3.8-9S9.5 5.6 12 3z" /></svg>
     <h3>The German Year</h3>
     <p>A distinctive international experience combining a study semester at a partner university with an internship semester in Germany.</p>
    </li>
    <li>
     <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><path d="M3 21V11l5 3v-3l5 3v-3l5 3V4h3v17z" /><path d="M7 18h2M12 18h2M17 18h1" /></svg>
     <h3>Industry Connections</h3>
     <p>Building relationships between education and professional practice through training, collaboration and industry engagement.</p>
    </li>
   </ul>
  </div>
 </section>

 <section class="about-section about-identity" aria-labelledby="identity-title">
  <div class="public-container">
   <div class="about-section-head" data-reveal="fade">
    <p class="about-eyebrow">University identity</p>
    <h2 id="identity-title">The University&rsquo;s Vision and Mission</h2>
   </div>
   <div class="about-identity-grid">
    <div data-reveal="fade">
     <h3>Vision</h3>
     <p class="about-vision">Inspiring innovation through applied education.</p>
    </div>
    <div data-reveal="fade" style="--i:1">
     <h3>Mission</h3>
     <p>Providing applied education and scientific research that support entrepreneurship and sustainable development through engagement with industry and with local, German and global partners.</p>
    </div>
   </div>
   <div class="about-values" data-reveal="fade" style="--i:2">
    <h3 id="values-title">Selected values</h3>
    <ul aria-labelledby="values-title">
     <li>Diversity, Equity and Inclusion</li>
     <li>Innovation and Entrepreneurial Spirit</li>
     <li>Sustainability</li>
     <li>Loyalty and Engagement</li>
    </ul>
   </div>
   <p class="about-note">English summary of the identity published by German Jordanian University. These are the university&rsquo;s statements, not the development team&rsquo;s.</p>
  </div>
 </section>

 <section class="about-section about-schools" aria-labelledby="schools-title">
  <div class="public-container about-split is-reversed">
   <div class="about-copy">
    <div data-reveal>
     <p class="about-eyebrow">Academic schools</p>
     <h2 id="schools-title">A Diverse Academic Community</h2>
     <p>GJU&rsquo;s programs are organized across eight schools.</p>
    </div>
    <ul class="about-school-list" data-reveal-group="3">
     <li>Business School</li>
     <li>School of Applied Humanities and Social Sciences</li>
     <li>School of Applied Medical Sciences</li>
     <li>School of Applied Technical Sciences</li>
     <li>School of Architecture and Built Environment</li>
     <li>School of Computing</li>
     <li>School of Sustainable Systems Engineering</li>
     <li>School of Nursing</li>
    </ul>
    <p class="about-note">This list describes the university. UIMS, our student project, is currently configured for the <%: Constants.CollegeName %> only.</p>
    <a class="about-official" href="https://www.gju.edu.jo/gju-programs" target="_blank" rel="noopener noreferrer">Explore GJU programs on the official website<span class="visually-hidden"> (opens in a new tab)</span> <span aria-hidden="true">&#8599;</span></a>
   </div>
   <figure class="about-figure" data-reveal="clip">
    <img src="<%: ResolveUrl("~/Assets/images/about/about-campus-aerial.jpg") %>" alt="Aerial view of the German Jordanian University campus buildings and surrounding farmland" width="1280" height="720" loading="lazy" decoding="async" />
   </figure>
  </div>
 </section>

 <section class="about-section about-project" id="about-uims" aria-labelledby="uims-title">
  <%-- The hand-over from the university's story to our own project. --%>
  <div class="about-chapter" data-reveal="line">
   <div class="public-container"><p>From the university to our project</p></div>
  </div>
  <div class="public-container">
   <div class="about-split">
    <div class="about-copy" data-reveal>
     <p class="about-eyebrow">Our student project</p>
     <h2 id="uims-title">About UIMS</h2>
     <p class="about-lead">UIMS is an internship management project designed to connect students, company supervisors, academic supervisors and internship coordinators in one organized experience.</p>
     <p>Its purpose is to make the internship journey clearer by organizing applications, training tasks, approved hours, feedback and completion evaluations.</p>
     <p class="about-note">UIMS is a Group 4 student project. It is not the university&rsquo;s official portal and does not replace MyGJU or published university policies.</p>
    </div>
    <figure class="about-figure" data-reveal="clip">
     <img src="<%: ResolveUrl("~/Assets/images/about/about-students.jpg") %>" alt="Students talking on a path between GJU campus buildings" width="960" height="685" loading="lazy" decoding="async" />
    </figure>
   </div>
   <h3 class="about-subhead" data-reveal>Project objectives</h3>
   <ul class="about-objectives" data-reveal-group>
    <li>Help students discover relevant internship opportunities.</li>
    <li>Organize applications and training activities.</li>
    <li>Make progress, feedback and approved hours easier to follow.</li>
    <li>Support coordination between students, supervisors and coordinators.</li>
   </ul>
  </div>
 </section>

 <section class="about-section about-journey" aria-labelledby="journey-title">
  <div class="public-container">
   <div class="about-section-head" data-reveal>
    <p class="about-eyebrow">Our project workflow</p>
    <h2 id="journey-title">The Journey Through UIMS</h2>
    <p>How the internship moves through UIMS. This describes our project&rsquo;s workflow, not every official GJU administrative procedure.</p>
   </div>
   <div class="about-steps-track" data-journey>
    <span class="about-steps-line" aria-hidden="true"><span data-journey-line></span></span>
    <ol class="about-steps" data-reveal-group>
     <li><h3>Discover</h3><p>Visitors can browse opportunity summaries; full details and applications require signing in.</p></li>
     <li><h3>Apply</h3><p>Students apply to opportunities open to their college and major under the system&rsquo;s rules.</p></li>
     <li><h3>Train</h3><p>Trainees complete tasks and receive feedback from their company supervisor.</p></li>
     <li><h3>Track</h3><p>Progress, feedback and approved hours stay visible as the internship continues.</p></li>
     <li><h3>Complete</h3><p>The company&rsquo;s final evaluation goes to the academic supervisor, who forwards the academic evaluation to the coordinator for final approval.</p></li>
    </ol>
   </div>
  </div>
 </section>

 <section class="about-section about-next" aria-labelledby="next-title">
  <div class="public-container about-next-inner" data-reveal-group>
   <h2 id="next-title">Take the Next Step</h2>
   <p>Explore internship opportunities and start connecting your learning with practical experience.</p>
   <div class="public-actions">
    <a class="public-button" href="<%: ResolveUrl("~/Default.aspx") %>#opportunities">Explore Opportunities</a>
    <a class="public-button public-button-secondary" href="<%: ResolveUrl("~/Pages/Public/Contact.aspx") %>">Contact Us</a>
   </div>
  </div>
 </section>

 <%-- The complete film: uncropped, native controls, sound only after the visitor asks for it. Captions: none exist. --%>
 <dialog class="about-film-dialog" data-film-dialog aria-labelledby="film-dialog-title">
  <div class="about-film-dialog-head">
   <h2 id="film-dialog-title">University introduction film</h2>
   <button type="button" class="about-film-close" data-film-close>Close<span class="visually-hidden"> the film</span></button>
  </div>
  <div class="about-film-dialog-frame">
   <video data-film-full controls playsinline preload="none" width="1280" height="538" poster="<%: ResolveUrl("~/Assets/images/about/about-film-poster.jpg") %>" aria-labelledby="film-dialog-title">
    <source src="<%: ResolveUrl(FilmPath) %>" type='video/mp4; codecs="avc1.64001F, mp4a.40.2"' />
    <p>Your browser cannot play this video here. <a href="<%: ResolveUrl(FilmPath) %>">Open the campus film (MP4, 13&nbsp;MB)</a>.</p>
   </video>
  </div>
  <p class="about-film-dialog-note">1 min 48 s &middot; Captions are not available for this film. <a href="<%: ResolveUrl(FilmPath) %>" target="_blank" rel="noopener noreferrer">Open the video file<span class="visually-hidden"> (opens in a new tab)</span></a></p>
 </dialog>

</div>
</asp:Content>
<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server">
<script src="<%: ResolveUrl("~/Assets/js/vendor/gsap.min.js") %>" defer></script>
<script src="<%: ResolveUrl("~/Assets/js/vendor/ScrollTrigger.min.js") %>" defer></script>
<script src="<%: ResolveUrl("~/Assets/js/about.js?v=20261022-2") %>" defer></script>
</asp:Content>
