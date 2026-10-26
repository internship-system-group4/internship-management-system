<%@ Page Language="C#" MasterPageFile="~/Layout/Public.master" AutoEventWireup="true" CodeBehind="Journey.aspx.cs" Inherits="InternshipManagementSystem.Pages.PublicArea.Journey" Title="The Journey | GJU Internship Management System" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
<meta name="description" content="A real-time 3D journey across the German Jordanian University campus, through the eyes of a student, into the internships that start every career." />
<script type="importmap">{ "imports": { "three": "<%= ResolveUrl("~/Assets/js/vendor/three.module.min.js") %>" } }</script>
<link rel="preload" href="<%: ResolveUrl("~/Assets/fonts/switzer-600.woff2") %>" as="font" type="font/woff2" crossorigin="anonymous" />
<link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/jisr.css?v=20261023-21") %>" />
<script defer src="<%: ResolveUrl("~/Assets/js/vendor/gsap.min.js") %>"></script>
<script defer src="<%: ResolveUrl("~/Assets/js/vendor/ScrollTrigger.min.js") %>"></script>
<script type="module" src="<%: ResolveUrl("~/Assets/js/jisr/jisr-hero.js?v=20261024-grounding") %>"></script>
</asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="jisr jisr--static" data-jisr data-logo="<%: ResolveUrl("~/Assets/images/gju-logo.png") %>" data-stone="<%: ResolveUrl("~/Assets/images/university/materials/stone-albedo.png") %>" data-student="<%: ResolveUrl("~/Assets/models/people/Male_Adult_17_Animated.web.glb") %>">
 <div class="jisr-stage" data-jisr-stage>
  <canvas class="jisr-canvas" aria-hidden="true"></canvas>
  <img class="jisr-poster" src="<%: ResolveUrl("~/Assets/images/university/b270da86-de83-4a48-898d-7446958fbe45.png") %>" alt="<%: L.T("Public.Journey.AerialViewOfTheGermanJordanian") %>" width="1280" height="720" />
  <div class="jisr-loader" aria-hidden="true"><span class="jisr-loader-mark"><%: L.T("Public.Journey.GermanJordanianUniversity") %></span><span class="jisr-loader-bar"></span><span class="jisr-loader-status" data-jisr-status><%: L.T("Public.Journey.PreparingTheDawn") %></span></div>

  <section class="jisr-beat jisr-beat--hero" data-beat="0 .15" aria-labelledby="jisr-title">
   <p class="jisr-eyebrow"><%: L.T("Public.Journey.GermanJordanianUniversity") %> <span aria-hidden="true">&middot;</span> <%: L.T("Public.Journey.InternshipManagementSystem") %></p>
   <h1 id="jisr-title"><%: L.T("Public.Journey.FromMadabaToTheWorld") %></h1>
   <p class="jisr-lede"><%: L.T("Public.Journey.EveryGJUInternshipStartsHereOn") %></p>
   <p class="jisr-cue"><span aria-hidden="true"></span><%: L.T("Public.Journey.ScrollToBegin") %></p>
  </section>

  <section class="jisr-beat jisr-beat--left" data-beat=".19 .37" aria-labelledby="jisr-bridge">
   <p class="jisr-kicker"><%: L.T("Public.Journey.TheGermanYear") %></p>
   <h2 id="jisr-bridge"><%: L.T("Public.Journey.ABridgeNotABorder") %></h2>
   <p><%: L.T("Public.Journey.EveryAutumnWhiteStorksFromGermany") %></p>
  </section>

  <section class="jisr-beat jisr-beat--right" data-beat=".43 .61" aria-labelledby="jisr-system">
   <p class="jisr-kicker">UIMS</p>
   <h2 id="jisr-system"><%: L.T("Public.Journey.OneSystemForTheWholeJourney") %></h2>
   <p><%: L.T("Public.Journey.UIMSConnectsStudentsCompaniesAndUniversity") %></p>
   <ul class="jisr-roles">
    <li><strong><%: L.T("Public.Journey.Students") %></strong><span><%: L.T("Public.Journey.ExploreApplyLogHours") %></span></li>
    <li><strong><%: L.T("Public.Journey.Companies") %></strong><span><%: L.T("Public.Journey.PublishSelectMentor") %></span></li>
    <li><strong><%: L.T("Public.Journey.Supervisors") %></strong><span><%: L.T("Public.Journey.FollowEvaluateApprove") %></span></li>
   </ul>
  </section>

  <section class="jisr-beat jisr-beat--quiet" data-beat=".655 .672" aria-label="<%: L.T("Public.Journey.Story") %>">
   <p><%: L.T("Public.Journey.EveryJourneyStartsWithAWalk") %></p>
  </section>

  <aside class="jisr-reveal" data-reveal="computing" aria-hidden="true">
   <p class="jisr-reveal-label"><%: L.T("Public.Journey.SchoolOfComputing") %></p>
   <p class="jisr-reveal-line"><%: L.T("Public.Journey.WhereIdeasBecomeTechnology") %></p>
  </aside>
  <aside class="jisr-reveal" data-reveal="architecture" aria-hidden="true">
   <p class="jisr-reveal-label"><%: L.T("Public.Journey.SchoolOfArchitectureAndBuiltEnvironment") %></p>
   <p class="jisr-reveal-line"><%: L.T("Public.Journey.DesigningTheSpacesWeLiveIn") %></p>
  </aside>
  <aside class="jisr-reveal" data-reveal="sustainable" aria-hidden="true">
   <p class="jisr-reveal-label"><%: L.T("Public.Journey.SchoolOfSustainableSystemsEngineering") %></p>
   <p class="jisr-reveal-line"><%: L.T("Public.Journey.EngineeringASustainableTomorrow") %></p>
  </aside>

  <section class="jisr-climax" data-climax aria-labelledby="jisr-climax-title">
   <h2 id="jisr-climax-title"><%: L.T("Public.Journey.YourJourneyBeginsHere") %></h2>
   <a class="jisr-climax-link" href="#opportunities"><%: L.T("Public.Journey.ExploreOpenInternships") %> <span aria-hidden="true">&darr;</span></a>
  </section>

  <nav class="jisr-rail" data-jisr-rail aria-label="<%: L.T("Public.Journey.JourneyChapters") %>">
   <a href="#jisr-title" data-at="0"><%: L.T("Public.Journey.Dawn") %></a><a href="#jisr-bridge" data-at=".19"><%: L.T("Public.Journey.Bridge") %></a><a href="#jisr-system" data-at=".43"><%: L.T("Public.Journey.System") %></a><a href="#schools" data-at=".64"><%: L.T("Public.Journey.Campus") %></a><a href="#opportunities" data-at=".875"><%: L.T("Public.Journey.Journey") %></a>
  </nav>
  <button type="button" class="jisr-motion" data-jisr-motion aria-pressed="false"><%: L.T("Public.Journey.PauseSceneMotion") %></button>
 </div>
</div>
<script>(function(){var h=document.querySelector('[data-jisr]');try{if(document.createElement('canvas').getContext('webgl2'))h.classList.remove('jisr--static');}catch(e){}})();</script>

<div class="jisr-after">
 <section class="jisr-section jisr-opps" id="opportunities" aria-labelledby="opps-title">
  <header class="jisr-section-head">
   <p class="jisr-kicker"><%: L.T("Public.Journey.OpenInternships") %></p>
   <h2 id="opps-title"><%: L.T("Public.Journey.WhereWillYourJourneyTakeYou") %></h2>
   <p><%: L.T("Public.Journey.SummariesPublishedByOurPartnerCompanies") %></p>
  </header>
  <% if (PreviewError != null) { %>
   <p class="jisr-notice" role="status"><%: PreviewError %></p>
  <% } else if (Previews.Count == 0) { %>
   <p class="jisr-notice"><%: L.T("Public.Journey.NoInternshipSummariesArePublishedRight") %></p>
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
      <% if (item.RemainingSeats > 0) { %><li><%: item.RemainingSeats %> <%: item.RemainingSeats == 1 ? "seat" : "seats" %> <%: L.T("Public.Journey.Left") %></li><% } %>
     </ul>
     <p class="jisr-opp-summary"><%: item.Summary %></p>
     <div class="jisr-opp-foot">
      <% var deadline = DeadlineText(item.ApplicationDeadline); if (deadline != null) { %><span><%: deadline %></span><% } %>
      <a class="btn jisr-btn" href="<%: ApplyUrl(item.Id) %>"><%: L.T("Public.Journey.ApplyNow") %></a>
     </div>
    </article>
   </div>
   <% } %>
  </div>
  <% } %>
  <p class="jisr-small"><%: L.T("Public.Journey.OnlyPublishedSummariesArePublicFull") %></p>
 </section>

 <section class="jisr-section jisr-schools" id="schools" aria-labelledby="schools-title">
  <header class="jisr-section-head">
   <p class="jisr-kicker"><%: L.T("Public.Journey.AcademicDirectory") %></p>
   <h2 id="schools-title"><%: L.T("Public.Journey.EightSchoolsOneUniversity") %></h2>
   <p><%: L.T("Public.Journey.TheSchoolsOfGermanJordanianUniversity") %> <%: L.Value("Directory", InternshipManagementSystem.Common.Constants.CollegeName) %><%: L.T("Public.Journey.MoreSchoolsWillFollow") %></p>
  </header>
  <div class="row g-3">
   <% foreach (var school in Schools) { %>
   <div class="col-md-6 col-xl-3">
    <details class="jisr-school<%= school.OnUims ? " is-supported" : "" %>"<%= school.OnUims ? " open" : "" %>>
     <summary>
      <span class="jisr-school-short"><%: school.Short %></span>
      <strong><%: L.Value("Directory", school.Name) %></strong>
      <em><%: L.Value("Directory", school.Line) %></em>
      <% if (school.OnUims) { %><span class="jisr-badge"><%: L.T("Public.Journey.OnUIMS") %></span><% } %>
     </summary>
     <div class="jisr-school-body">
      <p class="jisr-school-label"><%: L.Value("Directory", school.ProgramLabel) %></p>
      <ul>
       <% foreach (var program in school.Programs) { %>
        <li><%: L.Value("Directory", program) %><% var tracks = school.OnUims ? TracksFor(program) : new string[0]; if (tracks.Length > 0) { %><small><%: L.T("Public.Journey.Specializations") %> <%: string.Join(", ", tracks) %></small><% } %></li>
       <% } %>
      </ul>
     </div>
    </details>
   </div>
   <% } %>
  </div>
  <p class="jisr-small"><%: L.T("Public.Journey.ProgrammeNamesFromGjuEduJo") %></p>
 </section>

 <section class="jisr-section jisr-process" id="how-it-works" aria-labelledby="process-title">
  <header class="jisr-section-head">
   <p class="jisr-kicker"><%: L.T("Public.Journey.HowItWorks") %></p>
   <h2 id="process-title"><%: L.T("Public.Journey.LearnApplyGrow") %></h2>
   <p><%: L.T("Public.Journey.YourCompanyAndAcademicSupervisorsGuide") %></p>
  </header>
  <ol class="jisr-steps">
   <li><span>01</span><h3><%: L.T("Public.Journey.ExploreOpportunities") %></h3><p><%: L.T("Public.Journey.FindInternshipsThatMatchYourSchool") %></p></li>
   <li><span>02</span><h3><%: L.T("Public.Journey.ApplyAndConfirm") %></h3><p><%: L.T("Public.Journey.ApplyFollowTheCompanyDecisionAnd") %></p></li>
   <li><span>03</span><h3><%: L.T("Public.Journey.TrainAndGrow") %></h3><p><%: L.T("Public.Journey.CompleteTasksSubmitWorkAndLearn") %></p></li>
   <li><span>04</span><h3><%: L.T("Public.Journey.CompleteYourReview") %></h3><p><%: L.T("Public.Journey.TrackApprovedHoursAndEvaluationsThrough") %></p></li>
  </ol>
 </section>

 <section class="jisr-section jisr-video" id="internship-video" aria-labelledby="video-title">
  <header class="jisr-section-head">
   <p class="jisr-kicker"><%: L.T("Public.Journey.ProcessVideo") %></p>
   <h2 id="video-title"><%: L.T("Public.Journey.SeeThePathAhead") %></h2>
   <p><%: L.T("Public.Journey.AShortGuideToTheInternship") %></p>
  </header>
  <% if (ProcessVideoAvailable) { %>
   <video class="jisr-video-player" controls preload="metadata" playsinline poster="<%: ResolveUrl("~/Assets/images/home-campus.jpg") %>" aria-label="<%: L.T("Public.Journey.UniversityInternshipProcessVideo") %>"><source src="<%: ResolveUrl("~/Assets/video/internship-process.mp4") %>" type="video/mp4" /><% if (ProcessCaptionsAvailable) { %><track kind="captions" src="<%: ResolveUrl("~/Assets/video/internship-process.en.vtt") %>" srclang="en" label="English" default /><% } %><%: L.T("Public.Journey.YourBrowserDoesNotSupportVideo") %> <a href="<%: ResolveUrl("~/Assets/video/internship-process.mp4") %>"><%: L.T("Public.Journey.OpenTheVideo") %></a>.</video>
  <% } else { %>
   <div class="jisr-video-placeholder" role="note">
    <img src="<%: ResolveUrl("~/Assets/images/university/6753e8dc-1deb-4e1d-848c-79304737fb69.png") %>" alt="<%: L.T("Public.Journey.TheGermanJordanianUniversityCourtyardWith") %>" width="1200" height="800" loading="lazy" />
    <div><strong><%: L.T("Public.Journey.TheOfficialProcessVideoWillPlay") %></strong><p><%: L.T("Public.Journey.TheUniversitySInternshipProcessVideo") %></p></div>
   </div>
  <% } %>
 </section>

 <section class="jisr-section jisr-cta" aria-labelledby="cta-title">
  <h2 id="cta-title"><%: L.T("Public.Journey.ReadyForYourNextChapter") %></h2>
  <a class="btn btn-lg jisr-btn" href="<%: ResolveUrl("~/Pages/Account/Login.aspx") %>"><%: L.T("Public.Journey.LogInToYourPortal") %></a>
 </section>
</div>
</asp:Content>
