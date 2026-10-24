<%@ Page Language="C#" MasterPageFile="~/Layout/Public.master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="InternshipManagementSystem.Pages.PublicArea.Default" Title="Home | GJU Internship Management System" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
<meta name="description" content="Connect your studies with practical experience. A real-time 3D journey across the German Jordanian University campus into the internships that start every career." />

<!-- 3D Hero Scripts & Styles (From Journey) -->
<script type="importmap">{ "imports": { "three": "<%= ResolveUrl("~/Assets/js/vendor/three.module.min.js") %>" } }</script>
<link rel="preload" href="<%: ResolveUrl("~/Assets/fonts/switzer-600.woff2") %>" as="font" type="font/woff2" crossorigin="anonymous" />
<link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/jisr.css?v=20261023-21") %>" />
<script defer src="<%: ResolveUrl("~/Assets/js/vendor/gsap.min.js") %>"></script>
<script defer src="<%: ResolveUrl("~/Assets/js/vendor/ScrollTrigger.min.js") %>"></script>
<script type="module" src="<%: ResolveUrl("~/Assets/js/jisr/jisr-hero.js?v=20261023-26") %>"></script>

<link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/home-discovery.css?v=20261024-5") %>" />
<script defer src="<%: ResolveUrl("~/Assets/js/home-discovery.js?v=20261024-4") %>"></script>
<link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/home-video-zoom.css?v=20261024-1") %>" />
<script defer src="<%: ResolveUrl("~/Assets/js/home-video-zoom.js?v=20261024-1") %>"></script>
<!-- Default Page Styles & Scripts -->
<link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/home.css?v=20261021-7") %>" />
<link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/home-experience.css?v=20261022-taste-2") %>" />
<script defer src="<%: ResolveUrl("~/Assets/js/home-experience.js?v=20261022-navbar-1") %>"></script>

<!-- === ULTRA CREATIVE STYLES === -->
<style>
    :root {
        --uims-navy: #284b63;
        --uims-heading: #1a252c;
    }
    
    /* === SECTION 2: HOW IT WORKS === */
    .home-how-it-works {
        width: 100vw;
        position: relative;
        left: 50%;
        right: 50%;
        margin-left: -50vw;
        margin-right: -50vw;
        padding: 110px 8%;
        background-color: #ffffff;
    }
    .home-how-it-works-inner {
        max-width: 1250px;
        margin: 0 auto;
    }

    .how-it-works-header {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 50px;
        align-items: center;
        margin-bottom: 60px;
    }
    .header-col-left h2 {
        font-size: 2.8rem;
        font-weight: 800;
        color: var(--uims-navy);
        margin: 0;
        line-height: 1.2;
        letter-spacing: -0.5px;
    }
    .header-col-right {
        display: flex;
        flex-direction: column;
        align-items: flex-start;
        border-left: 2px solid rgba(40, 75, 99, 0.15); 
        padding-left: 40px;
    }
    .home-badge {
        display: inline-block;
        padding: 8px 24px;
        background-color: rgba(40, 75, 99, 0.08);
        color: var(--uims-navy);
        font-weight: 700;
        font-size: 0.85rem;
        border-radius: 50px;
        margin-bottom: 18px;
        text-transform: uppercase;
        letter-spacing: 1.5px;
    }
    .header-col-right p {
        font-size: 1.05rem;
        color: #606f7b;
        line-height: 1.75;
        margin: 0;
        max-width: 95%;
    }
    
    @media (max-width: 768px) {
        .how-it-works-header {
            grid-template-columns: 1fr;
            gap: 30px;
        }
        .header-col-right {
            border-left: none;
            padding-left: 0;
        }
    }

    /* === الكاردات والأرقام === */
    .uims-steps-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
        gap: 30px;
        position: relative;
    }
    .uims-step-card {
        background: #ffffff;
        padding: 35px 28px;
        border-radius: 20px;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.04);
        position: relative;
        overflow: hidden;
        transition: all 0.4s cubic-bezier(0.165, 0.84, 0.44, 1);
        border: 1px solid rgba(40, 75, 99, 0.08);
        z-index: 1;
    }
    .uims-step-card::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 4px;
        background: var(--uims-navy);
        transform: scaleX(0);
        transform-origin: left;
        transition: transform 0.4s ease;
    }
    .uims-step-card:hover {
        transform: translateY(-8px);
        box-shadow: 0 20px 40px rgba(40, 75, 99, 0.12);
        border-color: rgba(40, 75, 99, 0.2);
    }
    .uims-step-card:hover::before {
        transform: scaleX(1);
    }
    
    .uims-step-number {
        position: absolute;
        top: 15px;
        right: 20px;
        font-size: 2.4rem;
        font-weight: 900;
        color: var(--uims-navy); 
        opacity: 0.35;
        letter-spacing: -1px;
        transition: all 0.3s ease;
    }
    .uims-step-card:hover .uims-step-number {
        opacity: 0.6;
        transform: scale(1.05);
    }
    
    .uims-step-icon {
        width: 54px;
        height: 54px;
        background-color: rgba(40, 75, 99, 0.08);
        color: var(--uims-navy);
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 14px;
        margin-bottom: 24px;
        transition: all 0.3s ease;
    }
    .uims-step-card:hover .uims-step-icon {
        background-color: var(--uims-navy);
        color: #ffffff;
        transform: scale(1.05);
    }
    .uims-step-icon svg {
        width: 26px;
        height: 26px;
    }
    .uims-step-card h3 {
        font-size: 1.25rem;
        font-weight: 700;
        color: var(--uims-heading);
        margin-bottom: 12px;
    }
    .uims-step-card p {
        font-size: 0.95rem;
        color: #606f7b;
        line-height: 1.65;
        margin: 0;
    }

    /* === SECTION 3: BLURRED VIDEO BACKGROUND ABOUT PREVIEW === */
    .home-video-about-section {
        width: 100vw;
        position: relative;
        left: 50%;
        right: 50%;
        margin-left: -50vw;
        margin-right: -50vw;
        overflow: hidden;
        padding: 110px 8%;
        color: #ffffff;
        margin-top: 0;
        margin-bottom: 0;
        background-color: #0f1c24; 
    }
    .home-bg-video {
        position: absolute;
        top: 50%;
        left: 50%;
        min-width: 100%;
        min-height: 100%;
        width: auto;
        height: auto;
        transform: translate(-50%, -50%) scale(1.02);
        object-fit: cover;
        z-index: 1;
        filter: blur(3px);
        opacity: 0.9;
    }
    .home-video-overlay {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: linear-gradient(135deg, rgba(20, 35, 50, 0.8) 0%, rgba(65, 35, 20, 0.85) 100%);
        z-index: 2;
    }
    .home-video-about-container {
        position: relative;
        z-index: 3;
        max-width: 1250px;
        margin: 0 auto;
        display: grid;
        grid-template-columns: 1.2fr 0.8fr;
        gap: 50px;
        align-items: center;
    }
    @media (max-width: 992px) {
        .home-video-about-container {
            grid-template-columns: 1fr;
            text-align: center;
        }
    }
    .home-video-about-content h2 {
        font-size: 2.6rem;
        font-weight: 800;
        line-height: 1.2;
        margin-bottom: 20px;
        color: #ffffff;
        letter-spacing: -0.5px;
    }
    .home-video-about-content p {
        font-size: 1.08rem;
        line-height: 1.75;
        color: rgba(255, 255, 255, 0.9);
        margin-bottom: 35px;
    }
    .home-video-about-btn {
        display: inline-flex;
        align-items: center;
        gap: 14px;
        background-color: #ffffff;
        color: var(--uims-navy);
        padding: 16px 36px;
        border-radius: 50px;
        font-weight: 700;
        font-size: 1.05rem;
        text-decoration: none;
        transition: all 0.35s cubic-bezier(0.165, 0.84, 0.44, 1);
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
    }
    .home-video-about-btn:hover {
        background-color: #f8fafc;
        transform: translateY(-4px);
        box-shadow: 0 15px 35px rgba(255, 255, 255, 0.2);
        color: #183144;
    }
    .home-video-about-btn svg {
        width: 20px;
        height: 20px;
        transition: transform 0.3s ease;
    }
    .home-video-about-btn:hover svg {
        transform: translateX(6px);
    }
    .home-video-features-grid {
        display: flex;
        flex-direction: column;
        gap: 20px;
    }
    .home-video-feature-card {
        background: rgba(255, 255, 255, 0.08);
        border: 1px solid rgba(255, 255, 255, 0.18);
        padding: 22px 26px;
        border-radius: 16px;
        backdrop-filter: blur(12px);
        transition: transform 0.3s ease, background 0.3s ease;
    }
    .home-video-feature-card:hover {
        background: rgba(255, 255, 255, 0.14);
        transform: translateX(6px);
        border-color: rgba(255, 255, 255, 0.35);
    }
    .home-video-feature-card h4 {
        font-size: 1.15rem;
        font-weight: 700;
        color: #ffffff;
        margin-bottom: 6px;
    }
    .home-video-feature-card p {
        font-size: 0.9rem;
        color: rgba(255, 255, 255, 0.85);
        margin: 0;
        line-height: 1.5;
    }

    /* === SECTION 4: CLEAN VIDEO PRESENTATION === */
    .home-process-video-section {
        width: 100vw;
        position: relative;
        left: 50%;
        right: 50%;
        margin-left: -50vw;
        margin-right: -50vw;
        padding: 120px 8%;
        background-color: #fdfefe;
        text-align: center;
    }
    .home-process-video-container {
        max-width: 1000px;
        margin: 0 auto;
    }
    .home-process-video-header {
        margin-bottom: 45px;
    }
    .home-process-video-header h2 {
        font-size: 2.8rem;
        font-weight: 800;
        color: var(--uims-navy);
        margin-bottom: 15px;
        letter-spacing: -0.5px;
        line-height: 1.3;
    }
    .home-process-video-header p {
        font-size: 1.1rem;
        color: #606f7b;
        max-width: 650px;
        margin: 0 auto;
        line-height: 1.7;
    }
    .home-process-video-wrapper {
        position: relative;
        width: 100%;
        border-radius: 24px;
        overflow: hidden;
        box-shadow: 0 25px 50px rgba(40, 75, 99, 0.15);
        border: 1px solid rgba(40, 75, 99, 0.08);
        background-color: #000;
        transition: transform 0.4s ease, box-shadow 0.4s ease;
    }
    .home-process-video-wrapper:hover {
        transform: translateY(-6px);
        box-shadow: 0 35px 60px rgba(40, 75, 99, 0.22);
    }
    .home-process-video-wrapper video {
        width: 100%;
        height: auto;
        display: block;
        border-radius: 24px;
        outline: none;
    }

    /* === SECTION 5: OPPORTUNITIES HERO BANNER === */
    .home-opp-banner-section {
        width: 100vw;
        position: relative;
        left: 50%;
        right: 50%;
        margin-left: -50vw;
        margin-right: -50vw;
        overflow: hidden;
        padding: 140px 8%;
        text-align: center;
        color: #ffffff;
        background-color: #0f1c24;
    }
    .home-opp-bg-video {
        position: absolute;
        top: 50%;
        left: 50%;
        min-width: 100%;
        min-height: 100%;
        width: auto;
        height: auto;
        transform: translate(-50%, -50%) scale(1.02);
        object-fit: cover;
        z-index: 1;
        filter: blur(6px);
        opacity: 0.75;
    }
    .home-opp-overlay {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: linear-gradient(135deg, rgba(15, 28, 36, 0.85) 0%, rgba(24, 49, 68, 0.9) 100%);
        z-index: 2;
    }
    .home-opp-banner-content {
        position: relative;
        z-index: 3;
        max-width: 800px;
        margin: 0 auto;
    }
    .home-opp-banner-content h2 {
        font-size: 3rem;
        font-weight: 800;
        color: #ffffff;
        margin-bottom: 20px;
        letter-spacing: -0.5px;
        line-height: 1.2;
    }
    .home-opp-banner-content p {
        font-size: 1.15rem;
        color: rgba(255, 255, 255, 0.85);
        line-height: 1.7;
        margin-bottom: 40px;
    }
    .home-opp-explore-btn {
        display: inline-flex;
        align-items: center;
        gap: 12px;
        background-color: #ffffff;
        color: var(--uims-navy);
        padding: 16px 38px;
        border-radius: 50px;
        font-weight: 700;
        font-size: 1.05rem;
        text-decoration: none;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
        transition: all 0.35s cubic-bezier(0.165, 0.84, 0.44, 1);
    }
    .home-opp-explore-btn:hover {
        background-color: #f8fafc;
        transform: translateY(-4px);
        box-shadow: 0 15px 35px rgba(255, 255, 255, 0.25);
        color: #183144;
        gap: 16px;
    }
    .home-opp-explore-btn svg {
        width: 20px;
        height: 20px;
        transition: transform 0.3s ease;
    }
    .home-opp-explore-btn:hover svg {
        transform: translateX(4px);
    }

    /* === SECTION 6: EXTENDED FULL-WIDTH CTA SECTION === */
    .home-cta-full-section {
        width: 100vw;
        position: relative;
        left: 50%;
        right: 50%;
        margin-left: -50vw;
        margin-right: -50vw;
        background-color: #f4f6f8;
        padding: 100px 8%;
    }
    .home-cta-full-inner {
        max-width: 1250px;
        margin: 0 auto;
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 40px;
    }
    .home-cta-text h2 {
        font-size: 2.3يرم; /* تم ضبط الحجم ليصبح أنيقاً */
        font-size: 2.2rem;
        font-weight: 800;
        color: var(--uims-navy); /* تعيين اللون الكحلي الهادئ بدلاً من الأسود */
        margin-bottom: 12px;
        letter-spacing: -0.5px;
        line-height: 1.25;
    }
    .home-cta-text p {
        font-size: 1.05rem;
        color: #606f7b;
        margin: 0;
        line-height: 1.6;
    }
    .home-cta-btn {
        display: inline-flex;
        align-items: center;
        gap: 12px;
        background-color: var(--uims-navy);
        color: #ffffff !important; /* لون أبيض صريح ومضمون لنص الزر */
        padding: 16px 36px;
        border-radius: 50px;
        font-weight: 700;
        font-size: 1.05rem;
        text-decoration: none;
        box-shadow: 0 10px 25px rgba(40, 75, 99, 0.2);
        transition: all 0.35s ease;
        white-space: nowrap;
    }
    .home-cta-btn:hover {
        background-color: #1a252c;
        transform: translateY(-3px);
        box-shadow: 0 15px 30px rgba(40, 75, 99, 0.3);
        gap: 16px;
        color: #ffffff !important;
    }
    .home-cta-btn svg {
        width: 18px;
        height: 18px;
        stroke: #ffffff; /* توحيد لون سهم الزر ليصبح أبيض واضحاً */
        transition: transform 0.3s ease;
    }
    .home-cta-btn:hover svg {
        transform: translateX(4px);
    }

    @media (max-width: 900px) {
        .home-cta-full-inner {
            flex-direction: column;
            align-items: flex-start;
            text-align: left;
        }
    }
</style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<!-- === NEW 3D HERO SECTION (From Journey) === -->
<div class="jisr jisr--static" data-jisr data-navbar-scene data-logo="<%: ResolveUrl("~/Assets/images/gju-logo.png") %>" data-stone="<%: ResolveUrl("~/Assets/images/university/materials/stone-albedo.png") %>" data-student="<%: ResolveUrl("~/Assets/models/people/Male_Adult_17_Animated.glb") %>">
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
   <a href="#jisr-title" data-at="0">Dawn</a><a href="#jisr-bridge" data-at=".19">Bridge</a><a href="#jisr-system" data-at=".43">System</a><a href="#opportunities" data-at=".875">Journey</a>
  </nav>
  <button type="button" class="jisr-motion" data-jisr-motion aria-pressed="false">Pause scene motion</button>
 </div>
</div>
<script>(function () { var h = document.querySelector('[data-jisr]'); try { if (document.createElement('canvas').getContext('webgl2')) h.classList.remove('jisr--static'); } catch (e) { } })();</script>
<!-- === END OF NEW 3D HERO SECTION === -->

<!-- === REST OF DEFAULT.ASPX === -->
<div class="home-page">

<!-- === SECTION 2: HOW IT WORKS === -->
<section class="home-how-it-works" id="how-it-works" aria-labelledby="how-it-works-title">
 <div class="home-how-it-works-inner">
  <div class="how-it-works-header">
   <div class="header-col-left">
    <h2 id="how-it-works-title">How the Internship Process Works</h2>
   </div>
   <div class="header-col-right">
    <span class="home-badge">UIMS Journey</span>
    <p>From your first application to final evaluation, your professional journey is connected in four simple steps.</p>
   </div>
  </div>

  <div class="uims-steps-grid">
   <div class="uims-step-card">
    <div class="uims-step-number">01</div>
    <div class="uims-step-icon">
     <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
    </div>
    <h3>Explore & Apply</h3>
    <p>Browse verified internship opportunities published by partner companies, filter by your academic major, and apply instantly through your student portal.</p>
   </div>

   <div class="uims-step-card">
    <div class="uims-step-number">02</div>
    <div class="uims-step-icon">
     <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
    </div>
    <h3>Approval & Matching</h3>
    <p>University supervisors and company mentors review applications, secure institutional agreements, and formalize your placement terms safely.</p>
   </div>

   <div class="uims-step-card">
    <div class="uims-step-number">03</div>
    <div class="uims-step-icon">
     <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
    </div>
    <h3>Log Hours & Progress</h3>
    <p>Keep track of weekly tasks, log training hours dynamically, and share periodic performance logs with your academic supervisor in real time.</p>
   </div>

   <div class="uims-step-card">
    <div class="uims-step-number">04</div>
    <div class="uims-step-icon">
     <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
    </div>
    <h3>Final Evaluation</h3>
    <p>Receive comprehensive employer evaluations, conclude required credit hours, and successfully close your internship semester on the platform.</p>
   </div>
  </div>
 </div>
</section>
<!-- === END OF HOW IT WORKS === -->

<!-- === SECTION 3: BLURRED VIDEO BACKGROUND ABOUT PREVIEW === -->
<section class="home-video-about-section">
 <video autoplay muted loop playsinline class="home-bg-video">
  <source src="<%: ResolveUrl("~/Assets/video/about-bg.mp4?v=2") %>" type="video/mp4" />
 </video>
 <div class="home-video-overlay"></div>

 <div class="home-video-about-container">
  <div class="home-video-about-content">
   <span class="home-badge" style="background-color: rgba(255, 255, 255, 0.15); color: #ffffff;">Discover GJU & UIMS</span>
   <h2>Where Academic Excellence Meets Industry Practice</h2>
   <p>The German Jordanian University (GJU) bridges cultures and engineering standards. Our Internship Management System (UIMS) connects the university's diverse academic disciplines, ambitious students, and leading industrial partners into one seamless ecosystem.</p>
   <a class="home-video-about-btn" href="<%: ResolveUrl("~/Pages/Public/About.aspx") %>">
    <span>Explore Our Complete Story & Disciplines</span>
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="5" y1="12" x2="19" y2="12"></line><polyline points="12 5 19 12 12 19"></polyline></svg>
   </a>
  </div>

  <div class="home-video-features-grid">
   <div class="home-video-feature-card">
    <h4>Academic Integration</h4>
    <p>Seamlessly coordinates between university supervisors and faculty requirements.</p>
   </div>
   <div class="home-video-feature-card">
    <h4>Industry Partnerships</h4>
    <p>Direct bridge connecting top Jordanian and international enterprises with talent.</p>
   </div>
   <div class="home-video-feature-card">
    <h4>Real-time Tracking</h4>
    <p>Live progress logs, hours tracking, and transparent evaluation milestones.</p>
   </div>
  </div>
 </div>
</section>
<!-- === END OF BLURRED VIDEO BACKGROUND ABOUT PREVIEW === -->

<!-- === SECTION 4: CLEAN VIDEO PRESENTATION === -->
<section class="home-process-video-section" id="internship-video" aria-labelledby="video-title" data-scroll-video>
 <div class="home-process-video-container">
  
  <div class="home-process-video-header">
   <h2 id="video-title">Bridge the Gap</h2>
   <p>Take a closer look at the UIMS experience. Watch how our platform seamlessly connects your academic milestones with real-world industry opportunities.</p>
   <p class="home-video-scroll-hint" data-video-scroll-hint hidden><%: L.T("Public.Home.VideoScrollHint") %></p>
  </div>
  
  <div class="home-video-runway" data-video-runway><div class="home-video-stage" data-video-stage>
  <div class="home-process-video-wrapper" data-video-frame>
    <video controls muted preload="metadata" playsinline aria-label="University Internship Process Video">
     <source src="<%: ResolveUrl("~/Assets/video/UIMS.mp4") %>" type="video/mp4" />
     <% if (ProcessCaptionsAvailable) { %>
      <track kind="captions" src="<%: ResolveUrl("~/Assets/video/internship-process.en.vtt") %>" srclang="en" label="English" default />
     <% } %>
     Your browser does not support the video tag. <a href="<%: ResolveUrl("~/Assets/video/UIMS.mp4") %>">Open the video directly</a>.
    </video>
  </div>
  </div></div>

 </div>
</section>
<!-- === END OF CLEAN VIDEO PRESENTATION === -->

<!-- === SECTION 5: OPPORTUNITIES HERO BANNER === -->
<section class="home-opp-banner-section" id="opportunities" aria-labelledby="opportunities-title">
 <video autoplay muted loop playsinline class="home-opp-bg-video">
  <source src="<%: ResolveUrl("~/Assets/video/opportunities-bg.mp4") %>" type="video/mp4" />
 </video>
 <div class="home-opp-overlay"></div>

 <div class="home-opp-banner-content">
  <span class="home-badge" style="background-color: rgba(255, 255, 255, 0.15); color: #ffffff;">Gateway to Careers</span>
  <h2 id="opportunities-title">Your Next Professional Chapter Awaits</h2>
  <p><%: L.T("Public.Home.BannerIntro") %></p>
  <a class="home-opp-explore-btn" href="#opportunity-previews">
   <span><%: L.T("Public.Home.BrowseSummaries") %></span>
   <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="5" y1="12" x2="19" y2="12"></line><polyline points="12 5 19 12 12 19"></polyline></svg>
  </a>
 </div>
</section>
<!-- === END OF OPPORTUNITIES HERO BANNER === -->

<section class="home-discovery home-opportunity-previews" id="opportunity-previews" aria-labelledby="preview-title">
 <header class="hd-section-heading"><div><h2 id="preview-title"><%: L.T("Public.Home.PreviewTitle") %></h2><p><%: L.T("Public.Home.PreviewIntro") %></p></div><a class="hd-browse" href="<%: ResolveUrl("~/Pages/Account/Login.aspx") %>"><%: L.T("Public.Home.FindCurrent") %><svg class="hd-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 5 7 7-7 7" /></svg></a></header>
 <div class="hd-rail-toolbar"><p class="hd-access-note"><span class="hd-demo-label"><%: L.T("Public.Home.DemoLabel") %></span><span><%: L.T("Public.Home.DemoNote") %></span></p>
 </div>
 <div class="hd-preview-grid" data-preview-carousel role="region" aria-labelledby="preview-title">
 <% foreach (var preview in Previews) { %>
 <article class="hd-preview">
  <div class="hd-card-top"><span class="hd-role-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="<%: preview.IconPath %>" /></svg></span><p class="hd-company"><%: preview.CompanyName %></p></div><div class="hd-preview-heading"><h3><%: preview.Title %></h3></div>
  <p class="hd-summary"><%: preview.Summary %></p>
  <dl class="hd-preview-facts"><div><dt class="visually-hidden"><%: L.T("Public.Home.Location") %></dt><dd><svg class="hd-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" aria-hidden="true"><path d="M20 10c0 6-8 12-8 12S4 16 4 10a8 8 0 1 1 16 0zM15 10a3 3 0 1 1-6 0 3 3 0 0 1 6 0" /></svg><%: preview.Location %></dd></div><div><dt class="visually-hidden"><%: L.T("Public.Home.Specialization") %></dt><dd><svg class="hd-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" aria-hidden="true"><path d="m2 8 10-5 10 5-10 5zM6 11v7l6 3 6-3v-7m4-3v9" /></svg><%: preview.Specialization %></dd></div></dl>
  <div class="hd-preview-actions"><a class="hd-details" href="<%: ResolveUrl("~/Pages/Account/Login.aspx") %>"><%: L.T("Public.Home.MoreDetails") %><svg class="hd-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 5 7 7-7 7" /></svg></a></div>
 </article>
 <% } %>
 </div>
 <div class="hd-preview-motion-controls" data-preview-controls hidden><button type="button" class="hd-motion-toggle" data-preview-pause aria-pressed="false" data-pause-label="<%: L.T("Public.Home.PauseCards") %>" data-resume-label="<%: L.T("Public.Home.ResumeCards") %>"><svg class="hd-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" aria-hidden="true"><path data-preview-pause-icon d="M8 5v14M16 5v14" /></svg><span data-preview-pause-text><%: L.T("Public.Home.PauseCards") %></span></button><span class="visually-hidden"><%: L.T("Public.Home.CardMotionHint") %></span></div>
</section>


<!-- === SECTION 6: EXTENDED FULL-WIDTH CTA SECTION === -->
<section class="home-cta-full-section" aria-labelledby="cta-title">
 <div class="home-cta-full-inner">
  <div class="home-cta-text">
   <h2 id="cta-title">Ready for your next chapter?</h2>
   <p>Continue with your university internship account.</p>
  </div>
  <a class="home-cta-btn" href="<%: ResolveUrl("~/Pages/Account/Login.aspx") %>">
   <span>Log in to get started</span>
   <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="5" y1="12" x2="19" y2="12"></line><polyline points="12 5 19 12 12 19"></polyline></svg>
  </a>
 </div>
</section>
<!-- === END OF CTA SECTION === -->

<section class="home-discovery home-faq" id="questions" aria-labelledby="faq-title" data-home-faq>
 <div class="hd-faq-layout">
  <header class="hd-faq-intro"><span class="hd-curiosity-line" aria-hidden="true"></span><h2 id="faq-title"><%: L.T("Public.Home.FaqTitle") %></h2><p><%: L.T("Public.Home.FaqIntro") %></p></header>
  <div class="hd-faq-list">
<details class="hd-faq-item" open><summary><h3><%: L.T("Public.Home.Faq1Question") %></h3><span class="hd-faq-symbol"><svg class="hd-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 5v14M5 12h14" /></svg></span></summary><div class="hd-faq-answer"><p><%: L.T("Public.Home.Faq1Answer") %></p></div></details>
<details class="hd-faq-item"><summary><h3><%: L.T("Public.Home.Faq2Question") %></h3><span class="hd-faq-symbol"><svg class="hd-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 5v14M5 12h14" /></svg></span></summary><div class="hd-faq-answer"><p><%: L.T("Public.Home.Faq2Answer") %></p></div></details>
<details class="hd-faq-item"><summary><h3><%: L.T("Public.Home.Faq3Question") %></h3><span class="hd-faq-symbol"><svg class="hd-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 5v14M5 12h14" /></svg></span></summary><div class="hd-faq-answer"><p><%: L.T("Public.Home.Faq3Answer") %></p></div></details>
<details class="hd-faq-item"><summary><h3><%: L.T("Public.Home.Faq4Question") %></h3><span class="hd-faq-symbol"><svg class="hd-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 5v14M5 12h14" /></svg></span></summary><div class="hd-faq-answer"><p><%: L.T("Public.Home.Faq4Answer") %></p></div></details>
<details class="hd-faq-item"><summary><h3><%: L.T("Public.Home.Faq5Question") %></h3><span class="hd-faq-symbol"><svg class="hd-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 5v14M5 12h14" /></svg></span></summary><div class="hd-faq-answer"><p><%: L.T("Public.Home.Faq5Answer") %></p></div></details>
<details class="hd-faq-item"><summary><h3><%: L.T("Public.Home.Faq6Question") %></h3><span class="hd-faq-symbol"><svg class="hd-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 5v14M5 12h14" /></svg></span></summary><div class="hd-faq-answer"><p><%: L.T("Public.Home.Faq6Answer") %></p></div></details>
</div><div class="hd-faq-contact"><a href="<%: ResolveUrl("~/Pages/Public/Contact.aspx") %>"><%: L.T("Public.Home.MoreQuestions") %><svg class="hd-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 5 7 7-7 7" /></svg></a></div></div></section>


</div>
</asp:Content>
