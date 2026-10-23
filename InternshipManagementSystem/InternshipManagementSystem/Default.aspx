<%@ Page Language="C#" MasterPageFile="~/Layout/Public.master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="InternshipManagementSystem.Pages.PublicArea.Default" Title="Home | GJU Internship Management System" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
<meta name="description" content="Connect your studies with practical experience. Learn about the GJU internship journey and access your university internship portal." />
<link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/home.css?v=20261021-7") %>" />
<link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/home-story.css?v=20261022-campus-5") %>" />
<link rel="preload" href="<%: ResolveUrl("~/Assets/fonts/switzer-600.woff2") %>" as="font" type="font/woff2" crossorigin="anonymous" />
<link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/home-experience.css?v=20261022-taste-2") %>" />
<script defer src="<%: ResolveUrl("~/Assets/js/home-story.js?v=20261023-i18n") %>"></script>
<script defer src="<%: ResolveUrl("~/Assets/js/home-experience.js?v=20261022-navbar-1") %>"></script>
</asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="home-page">
<div class="home-story campus-story scene" data-scene="campus" data-home-story data-logo="<%: ResolveUrl("~/Assets/images/gju-logo.png") %>">
 <div class="campus-stage" data-story-figure data-scene-state="photo">
  <div class="home-story-viewport" data-story-viewport><img class="home-story-photo" src="<%: ResolveUrl("~/Assets/images/university/b270da86-de83-4a48-898d-7446958fbe45.png") %>" alt="<%: L.T("Home.Default.AerialPhotographOfGermanJordanianUniversity") %>" width="1200" height="675" fetchpriority="high" /></div>
  <div class="campus-hotspots" aria-label="<%: L.T("Home.Default.CampusLandmarks") %>"><a href="#university-gate" hidden data-hotspot="gate"><%: L.T("Home.Default.AboutTheSystem") %></a><a href="#colleges" hidden data-hotspot="colleges"><%: L.T("Home.Default.Colleges") %></a><a href="#how-it-works" hidden data-hotspot="wheel"><%: L.T("Home.Default.HowItWorks") %></a><a href="#opportunity-destination" hidden data-hotspot="opportunity"><%: L.T("Home.Default.Opportunities") %></a></div>
  <nav class="campus-chapter-nav" aria-label="<%: L.T("Home.Default.CampusStoryChapters") %>">
   <a href="#campus-overview" data-story-link="0" aria-label="<%: L.T("Home.Default.Chapter1TheCampus") %>" aria-current="step"><span class="campus-nav-label"><%: L.T("Home.Default.Campus") %></span></a>
   <a href="#university-gate" data-story-link="1" aria-label="<%: L.T("Home.Default.Chapter2TheConnection") %>"><span class="campus-nav-label"><%: L.T("Home.Default.Connect") %></span></a>
   <a href="#colleges" data-story-link="2" aria-label="<%: L.T("Home.Default.Chapter3YourField") %>"><span class="campus-nav-label"><%: L.T("Home.Default.Study") %></span></a>
   <a href="#how-it-works" data-story-link="3" aria-label="<%: L.T("Home.Default.Chapter4YourJourney") %>"><span class="campus-nav-label"><%: L.T("Home.Default.Journey") %></span></a>
   <a href="#opportunity-destination" data-story-link="4" aria-label="<%: L.T("Home.Default.Chapter5WhatComesNext") %>"><span class="campus-nav-label"><%: L.T("Home.Default.Explore") %></span></a>
  </nav>
  <div class="campus-scene-controls"><span data-story-status><%: L.T("Home.Default.GermanJordanianUniversityCampusPhotograph") %></span><button type="button" class="home-story-toggle" data-story-toggle aria-pressed="false" hidden><%: L.T("Home.Default.PauseCampusMotion") %></button></div>
 </div>
 <div class="campus-chapters">
 <section class="campus-chapter campus-opening" id="campus-overview" data-chapter="0" aria-labelledby="home-title"><div class="campus-copy">
  <h1 id="home-title" data-copy-zone><span><%: L.T("Home.Default.CampusToday") %></span> <span><%: L.T("Home.Default.CareerTomorrow") %></span></h1>
  <div class="campus-opening-intro" data-copy-zone>
  <p><%: L.T("Home.Default.YourInternshipJourneyAtGermanJordanian") %></p>
  <div class="public-actions"><a class="public-button" href="#opportunities"><%: L.T("Home.Default.ExploreInternships") %></a><a class="public-text-link" href="#how-it-works"><%: L.T("Home.Default.HowItWorks") %></a></div>
  <nav class="home-jump-nav" aria-label="<%: L.T("Home.Default.OnThisPage") %>"><a href="#colleges"><%: L.T("Home.Default.Colleges") %></a><a href="#internship-video"><%: L.T("Home.Default.ProcessVideo") %></a><a href="#opportunities"><%: L.T("Home.Default.Opportunities") %></a></nav>
  <a class="campus-scroll" href="#university-gate"><%: L.T("Home.Default.ExploreYourCampus") %> <span aria-hidden="true">&darr;</span></a>
 </div></div></section>
 <section class="campus-chapter" data-chapter="1" id="university-gate" aria-labelledby="gate-title"><div class="campus-copy"><h2 id="gate-title"><%: L.T("Home.Default.AShared") %><br /><%: L.T("Home.Default.StartingPoint") %></h2><p><%: L.T("Home.Default.UIMSConnectsStudentsCompaniesAndUniversity") %></p><a class="public-text-link" href="<%: ResolveUrl("~/Pages/Public/About.aspx") %>"><%: L.T("Home.Default.AboutTheInternshipSystem") %></a></div></section>
<section class="campus-chapter campus-colleges" data-chapter="2" id="colleges" aria-labelledby="colleges-title">
 <div class="campus-copy"><div class="home-section-heading"><h2 id="colleges-title"><%: L.T("Home.Default.YourField") %><br /><%: L.T("Home.Default.YourFuture") %></h2><p><%: L.T("Home.Default.ExploreTheCollegeProgramsAndSpecializations") %></p></div>
 <div class="home-college-layout"><details class="home-college" id="computing-college" open><summary><span><strong><%: Constants.CollegeName %></strong><small><%: L.T("Home.Default.ProgramsSpecializations") %></small></span><span class="home-college-action" aria-hidden="true"><span class="home-college-closed"><%: L.T("Home.Default.Explore") %></span><span class="home-college-open"><%: L.T("Home.Default.Close") %></span><b>+</b></span></summary><div class="home-college-content"> <div class="home-programs"><% foreach (var program in Constants.Programs) { %><article class="home-program"><h3><%: program %></h3><p><%: L.T("Home.Default.Specializations") %></p><ul><% foreach (var track in TracksFor(program)) { %><li><%: track %></li><% } %></ul></article><% } %></div>
</div></details></div></div>
</section>
<section class="campus-chapter campus-process" data-chapter="3" id="how-it-works" aria-labelledby="process-title">
 <div class="campus-copy"><div class="home-section-heading"><h2 id="process-title"><%: L.T("Home.Default.LearnApply") %><br /><%: L.T("Home.Default.Grow") %></h2><p><%: L.T("Home.Default.UnderstandEachStageBeforeYouBegin") %></p></div>
 <ol class="home-steps"><li><h3><%: L.T("Home.Default.ExploreOpportunities") %></h3><p><%: L.T("Home.Default.FindInternshipsThatMatchYourCollege") %></p></li><li><h3><%: L.T("Home.Default.ApplyConfirm") %></h3><p><%: L.T("Home.Default.ApplyFollowTheCompanyDecisionAnd") %></p></li><li><h3><%: L.T("Home.Default.TrainGrow") %></h3><p><%: L.T("Home.Default.CompleteTasksSubmitWorkAndLearn") %></p></li><li><h3><%: L.T("Home.Default.CompleteYourReview") %></h3><p><%: L.T("Home.Default.TrackApprovedHoursAndEvaluationsThrough") %></p></li></ol><a class="public-text-link" href="#internship-video"><%: L.T("Home.Default.WatchTheProcessGuide") %></a></div>
</section>
<section class="campus-chapter" data-chapter="4" id="opportunity-destination" aria-labelledby="destination-title"><div class="campus-copy"><h2 id="destination-title"><%: L.T("Home.Default.MakeYour") %><br /><%: L.T("Home.Default.NextMove") %></h2><p><%: L.T("Home.Default.DiscoverPublishedInternshipSummariesLogIn") %></p><div class="public-actions"><a class="public-button" href="#opportunities"><%: L.T("Home.Default.ExploreOpportunities2") %></a><a class="public-text-link" href="<%: ResolveUrl("~/Pages/Account/Login.aspx") %>"><%: L.T("Home.Default.LogInToYourPortal") %></a></div></div></section>
 </div>
</div>
<section class="home-section home-gallery" aria-labelledby="campus-gallery-title">
 <div class="home-section-heading"><h2 id="campus-gallery-title"><%: L.T("Home.Default.ACampus") %><br /><%: L.T("Home.Default.YouKnow") %></h2><p><%: L.T("Home.Default.TheEntranceTheCourtyardAndThe") %></p></div>
 <div class="home-gallery-layout">
  <figure class="home-gallery-main"><img src="<%: ResolveUrl("~/Assets/images/university/b774db96-c900-40dc-b579-3fa681fb49ec.png") %>" alt="<%: L.T("Home.Default.TimberCourtyardWaterwheelBesideItsLimestone") %>" width="1200" height="900" loading="lazy" /><figcaption><%: L.T("Home.Default.TheCourtyardWaterwheel") %></figcaption></figure>
  <figure><img src="<%: ResolveUrl("~/Assets/images/university/b1138b1f-421a-4fb1-9003-2d233d57c05c.png") %>" alt="<%: L.T("Home.Default.GJUGate1WithItsOriginal") %>" width="1200" height="800" loading="lazy" /><figcaption><%: L.T("Home.Default.Gate1GermanJordanianUniversity") %></figcaption></figure>
  <figure><img src="<%: ResolveUrl("~/Assets/images/university/4a85f19e-09cd-47d5-b8de-a18f277616a7.png") %>" alt="<%: L.T("Home.Default.GlazedUniversityConnectorFramedByLimestone") %>" width="1200" height="900" loading="lazy" /><figcaption><%: L.T("Home.Default.StoneGlassAndSharedSpaces") %></figcaption></figure>
 </div>
</section>
<section class="home-section home-video" id="internship-video" aria-labelledby="video-title"><div class="home-video-intro"><h2 id="video-title"><%: L.T("Home.Default.SeeThePath") %><br /><%: L.T("Home.Default.Ahead") %></h2><p><%: L.T("Home.Default.UnderstandTheInternshipProcessUseThis") %></p><a class="public-text-link" href="#how-it-works"><%: L.T("Home.Default.ExploreTheFourSteps") %></a></div>
<% if (ProcessVideoAvailable) { %><video class="home-process-video" controls preload="metadata" playsinline poster="<%: ResolveUrl("~/Assets/images/home-campus.jpg") %>" aria-label="<%: L.T("Home.Default.UniversityInternshipProcessVideo") %>"><source src="<%: ResolveUrl("~/Assets/video/internship-process.mp4") %>" type="video/mp4" /><% if (ProcessCaptionsAvailable) { %><track kind="captions" src="<%: ResolveUrl("~/Assets/video/internship-process.en.vtt") %>" srclang="en" label="English" default /><% } %><%: L.T("Home.Default.YourBrowserDoesNotSupportVideo") %> <a href="<%: ResolveUrl("~/Assets/video/internship-process.mp4") %>"><%: L.T("Home.Default.OpenTheVideo") %></a>.</video><% if (!ProcessCaptionsAvailable) { %><p class="home-access-note"><%: L.T("Home.Default.DevelopmentNoticeCaptionsForThisVideo") %></p><% } %>
<% } else { %><div class="home-video-visual"><img src="<%: ResolveUrl("~/Assets/images/university/6753e8dc-1deb-4e1d-848c-79304737fb69.png") %>" alt="<%: L.T("Home.Default.TheRealGermanJordanianUniversityCourtyard") %>" width="1200" height="800" loading="lazy" /><div class="home-video-placeholder" role="note"><strong><%: L.T("Home.Default.OfficialVideoComingHere") %></strong><p><%: L.T("Home.Default.DevelopmentPlaceholderTheUniversitySInternship") %></p><a class="public-text-link" href="#how-it-works"><%: L.T("Home.Default.ReadTheInternshipSteps") %></a></div></div><% } %></section>
<section class="home-section" id="opportunities" aria-labelledby="opportunities-title">
 <div class="home-section-heading"><h2 id="opportunities-title"><%: L.T("Home.Default.TheNextChapter") %><br /><%: L.T("Home.Default.IsYours") %></h2><p><%: L.T("Home.Default.ExperienceInYourFieldStartsWith") %></p></div>
 <h3 class="home-preview-title"><%: L.T("Home.Default.AvailableInternshipPreviews") %></h3>
 <% if (PreviewError != null) { %><p class="public-preview-notice" role="status"><%: PreviewError %></p><% } else if (Previews.Count == 0) { %><p class="public-preview-notice"><%: L.T("Home.Default.NoPublicInternshipSummariesArePublished") %></p><% } else { %>
 <div class="home-preview-grid"><% foreach (var preview in Previews) { %><article class="home-preview" data-preview-id="<%: preview.Id %>"><h3><%: preview.Title %></h3><p class="home-preview-meta"><%: preview.CompanyName %><% if (!string.IsNullOrWhiteSpace(preview.Location)) { %> &middot; <%: preview.Location %><% } %></p><p><%: preview.Summary %></p><a class="public-text-link" href="<%: ResolveUrl("~/Pages/Student/OpportunityDetails.aspx") %>?id=<%: Server.UrlEncode(preview.Id) %>"><%: L.T("Home.Default.LogInToViewDetails") %> <span aria-hidden="true">&rarr;</span></a></article><% } %></div>
 <% } %><p class="home-access-note"><%: L.T("Home.Default.OnlyPublishedSummariesArePublicFull") %></p>
</section>
<section class="home-cta" aria-labelledby="cta-title"><div><h2 id="cta-title"><%: L.T("Home.Default.ReadyForYourNextChapter") %></h2><p><%: L.T("Home.Default.ContinueWithYourUniversityInternshipAccount") %></p></div><a class="public-button" href="<%: ResolveUrl("~/Pages/Account/Login.aspx") %>"><%: L.T("Home.Default.LogInToGetStarted") %> <span aria-hidden="true">&rarr;</span></a></section>
</div>
</asp:Content>
