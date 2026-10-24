<%@ Page Language="C#" MasterPageFile="~/Layout/Public.master" AutoEventWireup="true" CodeBehind="About.aspx.cs" Inherits="InternshipManagementSystem.Pages.PublicArea.About" Title="About | GJU Internship Management System" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
<meta name="description" content="Learn about the German Jordanian University, its applied education approach, and UIMS, the Group 4 internship management student project." />
<link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/about.css?v=20261022-5") %>" />
<%-- Entrance reveals pre-hide content only when motion is welcome and about.js actually starts; if it has not
     started within 3 s, everything is shown as normal. --%>
<script>(function (d) { if (matchMedia('(prefers-reduced-motion: reduce)').matches) return; d.classList.add('about-motion'); setTimeout(function () { if (!d.classList.contains('about-ready')) d.classList.remove('about-motion'); }, 3000); }(document.documentElement));</script>
<style>
    /* تنسيق الفيديوهات داخل الحاويات لتبدو كأنها صور احترافية متحركة */
    .about-figure video {
        width: 100%;
        height: 100%;
        object-fit: cover;
        border-radius: 16px;
        display: block;
        box-shadow: 0 15px 35px rgba(0, 0, 0, 0.12);
    }
</style>
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
    <video class="about-opening-video" data-film-preview muted playsinline loop preload="none" width="1280" height="538" poster="<%: ResolveUrl("~/Assets/video/about-film-poster.jpg") %>" aria-label="<%: L.T("Public.About.MutedPreviewOfTheGermanJordanian") %>">
     <source src="<%: ResolveUrl(FilmPath) %>" type='video/mp4; codecs="avc1.64001F, mp4a.40.2"' />
    </video>
    <div class="about-opening-shade" aria-hidden="true"></div>
    <div class="about-film-controls" data-film-controls hidden>
     <button type="button" class="about-film-control" data-film-toggle aria-pressed="false">
      <svg class="is-play" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M8 5.5v13l10.5-6.5z" fill="currentColor" /></svg>
      <svg class="is-pause" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M7.5 5h3v14h-3zM13.5 5h3v14h-3z" fill="currentColor" /></svg>
      <span class="visually-hidden" data-film-toggle-label><%: L.T("Public.About.PlayPreview") %></span>
     </button>
     <button type="button" class="about-film-control" data-film-sound aria-pressed="false">
      <svg class="is-muted" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><path d="M4 9.5h3.5L12 6v12l-4.5-3.5H4z" /><path d="m16 9.5 5 5M21 9.5l-5 5" /></svg>
      <svg class="is-sound" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><path d="M4 9.5h3.5L12 6v12l-4.5-3.5H4z" /><path d="M15.5 9a4 4 0 0 1 0 6M18 6.5a7.5 7.5 0 0 1 0 11" /></svg>
      <span class="visually-hidden" data-film-sound-label><%: L.T("Public.About.TurnSoundOn") %></span>
     </button>
    </div>
    <p class="about-film-status" data-film-status role="status" aria-live="polite"></p>
   </div>
   <div class="public-container about-opening-copy" data-opening-copy>
    <p class="about-eyebrow"><%: L.T("Public.About.DiscoverGJU") %></p>
    <h1 id="about-title"><%: L.T("Public.About.WhereLearningMeetsExperience") %></h1>
    <p class="about-opening-lead"><%: L.T("Public.About.ExploreTheCampusTheUniversityS") %></p>
    <a class="public-button about-film-play" href="<%: ResolveUrl(FilmPath) %>" data-film-open>
     <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M8 5.5v13l10.5-6.5z" fill="currentColor" /></svg>
     <%: L.T("Public.About.PlayUniversityFilm") %><span class="visually-hidden"> <%: L.T("Public.About.1Min48SWithSound") %></span>
    </a>
   </div>
   <a class="about-scroll-cue" href="#discover-gju" data-opening-cue><%: L.T("Public.About.ExploreOurStory") %> <span aria-hidden="true">&darr;</span></a>
  </div>
 </section>

 <section class="about-section about-overview" id="discover-gju" aria-labelledby="university-title">
  <div class="public-container about-split">
   <div class="about-copy" data-reveal>
    <p class="about-eyebrow"><%: L.T("Public.About.TheUniversity") %></p>
    <h2 id="university-title"><%: L.T("Public.About.GermanJordanianUniversity") %></h2>
    <p><%: L.T("Public.About.TheGermanJordanianUniversityGJUIs") %></p>
    <p><%: L.T("Public.About.ItsEducationLinksAcademicStudyWith") %></p>
    <ul class="about-facts">
     <li><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><rect x="3.5" y="5" width="17" height="15" rx="2" /><path d="M3.5 10h17M8 3v4M16 3v4" /></svg><span><%: L.T("Public.About.EstablishedIn2005") %></span></li>
     <li><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><circle cx="9" cy="12" r="5.5" /><circle cx="15" cy="12" r="5.5" /></svg><span><%: L.T("Public.About.JordanianGermanCooperation") %></span></li>
    </ul>
    <a class="about-official" href="<%: Constants.UniversityWebsite %>" target="_blank" rel="noopener noreferrer"><%: L.T("Public.About.VisitTheOfficialGJUWebsite") %><span class="visually-hidden"> <%: L.T("Public.About.OpensInANewTab") %></span> <span aria-hidden="true">&#8599;</span></a>
   </div>
   <%-- فيديو البوابة الأول: aboutGate.mp4 --%>
   <figure class="about-figure" data-reveal="clip" data-parallax>
    <video autoplay muted loop playsinline preload="metadata">
     <source src="<%: ResolveUrl("~/Assets/video/aboutGate.mp4") %>" type="video/mp4" />
     <%: L.T("Public.About.YourBrowserDoesNotSupportThe") %>
    </video>
   </figure>
  </div>
 </section>

 <section class="about-section about-distinctive" aria-labelledby="distinctive-title">
  <div class="public-container">
   <div class="about-section-head" data-reveal>
    <p class="about-eyebrow"><%: L.T("Public.About.TheGJUApproach") %></p>
    <h2 id="distinctive-title"><%: L.T("Public.About.WhatMakesGJUDistinctive") %></h2>
   </div>
   <ul class="about-features" data-reveal-group>
    <li>
     <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><path d="M2 9.5 12 4.5l10 5-10 5z" /><path d="M6 11.5V16c3.5 2.6 8.5 2.6 12 0v-4.5M22 9.5v5" /></svg>
     <h3><%: L.T("Public.About.AppliedEducation") %></h3>
     <p><%: L.T("Public.About.ConnectingAcademicKnowledgeWithPracticalProjects") %></p>
    </li>
    <li>
     <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><circle cx="12" cy="12" r="9" /><path d="M3 12h18M12 3c2.5 2.6 3.8 5.6 3.8 9s-1.3 6.4-3.8 9c-2.5-2.6-3.8-5.6-3.8-9S9.5 5.6 12 3z" /></svg>
     <h3><%: L.T("Public.About.TheGermanYear") %></h3>
     <p><%: L.T("Public.About.ADistinctiveInternationalExperienceCombiningA") %></p>
    </li>
    <li>
     <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><path d="M3 21V11l5 3v-3l5 3v-3l5 3V4h3v17z" /><path d="M7 18h2M12 18h2M17 18h1" /></svg>
     <h3><%: L.T("Public.About.IndustryConnections") %></h3>
     <p><%: L.T("Public.About.BuildingRelationshipsBetweenEducationAndProfessional") %></p>
    </li>
   </ul>
  </div>
 </section>

 <section class="about-section about-identity" aria-labelledby="identity-title">
  <div class="public-container">
   <div class="about-section-head" data-reveal="fade">
    <p class="about-eyebrow"><%: L.T("Public.About.UniversityIdentity") %></p>
    <h2 id="identity-title"><%: L.T("Public.About.TheUniversitySVisionAndMission") %></h2>
   </div>
   <div class="about-identity-grid">
    <div data-reveal="fade">
     <h3><%: L.T("Public.About.Vision") %></h3>
     <p class="about-vision"><%: L.T("Public.About.InspiringInnovationThroughAppliedEducation") %></p>
    </div>
    <div data-reveal="fade" style="--i:1">
     <h3><%: L.T("Public.About.Mission") %></h3>
     <p><%: L.T("Public.About.ProvidingAppliedEducationAndScientificResearch") %></p>
    </div>
   </div>
   <div class="about-values" data-reveal="fade" style="--i:2">
    <h3 id="values-title"><%: L.T("Public.About.SelectedValues") %></h3>
    <ul aria-labelledby="values-title">
     <li><%: L.T("Public.About.DiversityEquityAndInclusion") %></li>
     <li><%: L.T("Public.About.InnovationAndEntrepreneurialSpirit") %></li>
     <li><%: L.T("Public.About.Sustainability") %></li>
     <li><%: L.T("Public.About.LoyaltyAndEngagement") %></li>
    </ul>
   </div>
   <p class="about-note"><%: L.T("Public.About.EnglishSummaryOfTheIdentityPublished") %></p>
  </div>
 </section>

 <section class="about-section about-schools" aria-labelledby="schools-title">
  <div class="public-container about-split is-reversed">
   <div class="about-copy">
    <div data-reveal>
     <p class="about-eyebrow"><%: L.T("Public.About.AcademicSchools") %></p>
     <h2 id="schools-title"><%: L.T("Public.About.ADiverseAcademicCommunity") %></h2>
     <p><%: L.T("Public.About.GJUSProgramsAreOrganizedAcross") %></p>
    </div>
    <ul class="about-school-list" data-reveal-group="3">
     <li><%: L.T("Public.About.BusinessSchool") %></li>
     <li><%: L.T("Public.About.SchoolOfAppliedHumanitiesAndSocial") %></li>
     <li><%: L.T("Public.About.SchoolOfAppliedMedicalSciences") %></li>
     <li><%: L.T("Public.About.SchoolOfAppliedTechnicalSciences") %></li>
     <li><%: L.T("Public.About.SchoolOfArchitectureAndBuiltEnvironment") %></li>
     <li><%: L.T("Public.About.SchoolOfComputing") %></li>
     <li><%: L.T("Public.About.SchoolOfSustainableSystemsEngineering") %></li>
     <li><%: L.T("Public.About.SchoolOfNursing") %></li>
    </ul>
    <p class="about-note"><%: L.T("Public.About.ThisListDescribesTheUniversityUIMS") %> <%: Constants.CollegeName %> <%: L.T("Public.About.Only") %></p>
    <a class="about-official" href="https://www.gju.edu.jo/gju-programs" target="_blank" rel="noopener noreferrer"><%: L.T("Public.About.ExploreGJUProgramsOnTheOfficial") %><span class="visually-hidden"> <%: L.T("Public.About.OpensInANewTab") %></span> <span aria-hidden="true">&#8599;</span></a>
   </div>
   <%-- فيديو المجتمع الأكاديمي: Academic Community.mp4 --%>
   <figure class="about-figure" data-reveal="clip">
    <video autoplay muted loop playsinline preload="metadata">
     <source src="<%: ResolveUrl("~/Assets/video/Academic Community.mp4") %>" type="video/mp4" />
     <%: L.T("Public.About.YourBrowserDoesNotSupportThe") %>
    </video>
   </figure>
  </div>
 </section>

 <section class="about-section about-project" id="about-uims" aria-labelledby="uims-title">
  <%-- The hand-over from the university's story to our own project. --%>
  <div class="about-chapter" data-reveal="line">
   <div class="public-container"><p><%: L.T("Public.About.FromTheUniversityToOurProject") %></p></div>
  </div>
  <div class="public-container">
   <div class="about-split">
    <div class="about-copy" data-reveal>
     <p class="about-eyebrow"><%: L.T("Public.About.OurStudentProject") %></p>
     <h2 id="uims-title"><%: L.T("Public.About.AboutUIMS") %></h2>
     <p class="about-lead"><%: L.T("Public.About.UIMSIsAnInternshipManagementProject") %></p>
     <p><%: L.T("Public.About.ItsPurposeIsToMakeThe") %></p>
     <p class="about-note"><%: L.T("Public.About.UIMSIsAGroup4Student") %></p>
    </div>
    <%-- فيديو مشروع UIMS: About UIMS.mp4 --%>
    <figure class="about-figure" data-reveal="clip">
     <video autoplay muted loop playsinline preload="metadata">
      <source src="<%: ResolveUrl("~/Assets/video/About UIMS.mp4") %>" type="video/mp4" />
      <%: L.T("Public.About.YourBrowserDoesNotSupportThe") %>
     </video>
    </figure>
   </div>
   <h3 class="about-subhead" data-reveal><%: L.T("Public.About.ProjectObjectives") %></h3>
   <ul class="about-objectives" data-reveal-group>
    <li><%: L.T("Public.About.HelpStudentsDiscoverRelevantInternshipOpportunities") %></li>
    <li><%: L.T("Public.About.OrganizeApplicationsAndTrainingActivities") %></li>
    <li><%: L.T("Public.About.MakeProgressFeedbackAndApprovedHours") %></li>
    <li><%: L.T("Public.About.SupportCoordinationBetweenStudentsSupervisorsAnd") %></li>
   </ul>
  </div>
 </section>

 <section class="about-section about-journey" aria-labelledby="journey-title">
  <div class="public-container">
   <div class="about-section-head" data-reveal>
    <p class="about-eyebrow"><%: L.T("Public.About.OurProjectWorkflow") %></p>
    <h2 id="journey-title"><%: L.T("Public.About.TheJourneyThroughUIMS") %></h2>
    <p><%: L.T("Public.About.HowTheInternshipMovesThroughUIMS") %></p>
   </div>
   <div class="about-steps-track" data-journey>
    <span class="about-steps-line" aria-hidden="true"><span data-journey-line></span></span>
    <ol class="about-steps" data-reveal-group>
     <li><h3><%: L.T("Public.About.Discover") %></h3><p><%: L.T("Public.About.VisitorsCanBrowseOpportunitySummariesFull") %></p></li>
     <li><h3><%: L.T("Public.About.Apply") %></h3><p><%: L.T("Public.About.StudentsApplyToOpportunitiesOpenTo") %></p></li>
     <li><h3><%: L.T("Public.About.Train") %></h3><p><%: L.T("Public.About.TraineesCompleteTasksAndReceiveFeedback") %></p></li>
     <li><h3><%: L.T("Public.About.Track") %></h3><p><%: L.T("Public.About.ProgressFeedbackAndApprovedHoursStay") %></p></li>
     <li><h3><%: L.T("Public.About.Complete") %></h3><p><%: L.T("Public.About.TheCompanySFinalEvaluationGoes") %></p></li>
    </ol>
   </div>
  </div>
 </section>

 <section class="about-section about-next" aria-labelledby="next-title">
  <div class="public-container about-next-inner" data-reveal-group>
   <h2 id="next-title"><%: L.T("Public.About.TakeTheNextStep") %></h2>
   <p><%: L.T("Public.About.ExploreInternshipOpportunitiesAndStartConnecting") %></p>
   <div class="public-actions">
    <a class="public-button" href="<%: ResolveUrl("~/Default.aspx") %>#opportunities"><%: L.T("Public.About.ExploreOpportunities") %></a>
    <a class="public-button public-button-secondary" href="<%: ResolveUrl("~/Pages/Public/Contact.aspx") %>"><%: L.T("Public.About.ContactUs") %></a>
   </div>
  </div>
 </section>

 <%-- The complete film: uncropped, native controls, sound only after the visitor asks for it. Captions: none exist. --%>
 <dialog class="about-film-dialog" data-film-dialog aria-labelledby="film-dialog-title">
  <div class="about-film-dialog-head">
   <h2 id="film-dialog-title"><%: L.T("Public.About.UniversityIntroductionFilm") %></h2>
   <button type="button" class="about-film-close" data-film-close><%: L.T("Public.About.Close") %><span class="visually-hidden"> <%: L.T("Public.About.TheFilm") %></span></button>
  </div>
  <div class="about-film-dialog-frame">
   <video data-film-full controls playsinline preload="none" width="1280" height="538" poster="<%: ResolveUrl("~/Assets/video/about-film-poster.jpg") %>" aria-labelledby="film-dialog-title">
    <source src="<%: ResolveUrl(FilmPath) %>" type='video/mp4; codecs="avc1.64001F, mp4a.40.2"' />
    <p><%: L.T("Public.About.YourBrowserCannotPlayThisVideo") %> <a href="<%: ResolveUrl(FilmPath) %>"><%: L.T("Public.About.OpenTheCampusFilmMP413") %></a>.</p>
   </video>
  </div>
  <p class="about-film-dialog-note"><%: L.T("Public.About.1Min48SCaptionsAre") %> <a href="<%: ResolveUrl(FilmPath) %>" target="_blank" rel="noopener noreferrer"><%: L.T("Public.About.OpenTheVideoFile") %><span class="visually-hidden"> <%: L.T("Public.About.OpensInANewTab") %></span></a></p>
 </dialog>

</div>
</asp:Content>
<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server">
<script src="<%: ResolveUrl("~/Assets/js/vendor/gsap.min.js") %>" defer></script>
<script src="<%: ResolveUrl("~/Assets/js/vendor/ScrollTrigger.min.js") %>" defer></script>
<script src="<%: ResolveUrl("~/Assets/js/about.js?v=20261024-qa-3") %>" defer></script>
</asp:Content>