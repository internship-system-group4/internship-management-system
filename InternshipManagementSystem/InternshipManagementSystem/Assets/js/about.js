(function () {
 'use strict';
 // About Us: the opening film (muted preview, its controls and the full-film dialog), the opening scroll transition
 // and once-per-visit section reveals. The page is complete without this script; it only adds behaviour.
 var page = document.querySelector('.about-page');
 if (!page) return;
 var root = document.documentElement;
 var reduce = matchMedia('(prefers-reduced-motion: reduce)');
 // Wide landscape screens get the immersive opening (matches the about.css media query).
 var WIDE = '(min-width:761px) and (min-aspect-ratio:5/4)';
 var MOTION = '(prefers-reduced-motion: no-preference)';
 var wide = matchMedia(WIDE);

 /* Opening film ------------------------------------------------------------------------------------------- */
 var opening = page.querySelector('[data-film]');
 var preview = opening.querySelector('[data-film-preview]');
 var toggle = opening.querySelector('[data-film-toggle]'), toggleLabel = opening.querySelector('[data-film-toggle-label]');
 var sound = opening.querySelector('[data-film-sound]'), soundLabel = opening.querySelector('[data-film-sound-label]');
 var status = opening.querySelector('[data-film-status]');
 var openFilm = opening.querySelector('[data-film-open]');
 var dialog = page.querySelector('[data-film-dialog]'), full = dialog.querySelector('[data-film-full]');
 // userPaused: the visitor paused the preview; it is never restarted for them.
 // heldBySystem: we paused it (off screen, hidden tab, dialog open) and may resume it.
 var userPaused = false, heldBySystem = false, inView = false, failed = false;

 function sync() {
  var playing = !preview.paused;
  toggle.setAttribute('aria-pressed', String(playing));
  toggleLabel.textContent = playing ? window.uimsT('PausePreview') : window.uimsT('PlayPreview');
  sound.setAttribute('aria-pressed', String(!preview.muted));
  soundLabel.textContent = preview.muted ? window.uimsT('SoundOn') : window.uimsT('SoundOff');
 }
 function play() {
  if (failed) return;
  var attempt = preview.play();
  // Autoplay may be refused (browser policy, data saver); the poster and the Play controls stay.
  if (attempt && attempt.catch) attempt.catch(function () { sync(); });
 }
 function hold() { if (!preview.paused) { heldBySystem = true; preview.pause(); } }
 function mayResume() { return heldBySystem && inView && !userPaused && !dialog.open && !document.hidden; }
 function resume() { if (mayResume()) { heldBySystem = false; play(); } }
 // A muted, looping preview only on wide screens, with motion welcome and no data-saver request.
 function previewWelcome() { return wide.matches && !reduce.matches && !(navigator.connection && navigator.connection.saveData); }

 opening.querySelector('[data-film-controls]').hidden = false;
 toggle.addEventListener('click', function () {
  if (preview.paused) { userPaused = false; heldBySystem = false; play(); }
  else { userPaused = true; heldBySystem = false; preview.pause(); }
 });
 sound.addEventListener('click', function () {
  preview.muted = !preview.muted;
  if (!preview.muted && preview.paused) { userPaused = false; play(); }
  sync();
 });
 ['play', 'pause', 'volumechange'].forEach(function (name) { preview.addEventListener(name, sync); });
 preview.addEventListener('waiting', function () { status.textContent = window.uimsT('FilmLoading'); });
 preview.addEventListener('playing', function () { status.textContent = ''; });
 preview.addEventListener('loadedmetadata', function () { if (window.ScrollTrigger) ScrollTrigger.refresh(); });
 preview.querySelector('source').addEventListener('error', function () {
  failed = true; status.textContent = window.uimsT('FilmFailed'); toggle.disabled = true; sound.disabled = true;
 });
 sync();

 // The complete film opens uncropped with native controls; sound only because the visitor asked for it.
 openFilm.addEventListener('click', function (event) {
  if (typeof dialog.showModal !== 'function') return; // follow the link to the file instead
  event.preventDefault();
  hold();
  dialog.showModal();
  var attempt = full.play();
  if (attempt && attempt.catch) attempt.catch(function () { /* the native controls remain */ });
 });
 dialog.querySelector('[data-film-close]').addEventListener('click', function () { dialog.close(); });
 dialog.addEventListener('click', function (event) { if (event.target === dialog) dialog.close(); });
 dialog.addEventListener('close', function () { full.pause(); resume(); });

 if ('IntersectionObserver' in window) {
  new IntersectionObserver(function (entries) {
   inView = entries[0].isIntersecting;
   if (!inView) hold();
   else if (heldBySystem) resume();
   else if (!userPaused && preview.paused && preview.currentTime === 0 && previewWelcome()) play();
  }, { threshold:.25 }).observe(opening.querySelector('[data-film-frame]'));
 }
 document.addEventListener('visibilitychange', function () { if (document.hidden) hold(); else resume(); });
 window.addEventListener('pagehide', hold);
 reduce.addEventListener('change', function () { if (reduce.matches) { heldBySystem = false; if (!preview.paused) preview.pause(); } });

 /* Section reveals: once per visit, 80ms stagger within a group ------------------------------------------- */
 page.querySelectorAll('[data-reveal-group]').forEach(function (group) {
  var size = parseInt(group.getAttribute('data-reveal-group'), 10) || 1;
  Array.prototype.forEach.call(group.children, function (child, index) {
   if (!child.hasAttribute('data-reveal')) child.setAttribute('data-reveal', '');
   child.style.setProperty('--i', Math.floor(index / size));
  });
 });
 var manual = []; // revealed by a scroll timeline instead (the journey steps on wide screens)
 function reveal(element) { element.classList.add('is-revealed'); }

 /* Scroll-linked motion (GSAP ScrollTrigger, already vendored for Home) ------------------------------------ */
 var gsap = window.gsap, ScrollTrigger = window.ScrollTrigger;
 if (gsap && ScrollTrigger) {
  gsap.registerPlugin(ScrollTrigger);
  var media = gsap.matchMedia();
  var navOffset = function () { return parseFloat(getComputedStyle(page).getPropertyValue('--about-nav')) || 96; };

  // Opening: the stage is sticky for a short runway. The film holds still, then the text lifts away and the frame
  // settles into a slightly inset, rounded picture. Scrubbed, so it reverses with the scroll. Playback is untouched.
  media.add(WIDE + ' and ' + MOTION, function () {
   var frame = opening.querySelector('[data-film-frame]');
   opening.classList.add('is-sequenced');
   var timeline = gsap.timeline({ defaults:{ ease:'none' }, scrollTrigger:{
    trigger:opening, start:function () { return 'top ' + navOffset() + 'px'; }, end:'bottom bottom', scrub:.5, invalidateOnRefresh:true } });
   timeline.to(opening.querySelector('[data-opening-cue]'), { autoAlpha:0, y:-8, duration:.15 }, .05)
    .to(opening.querySelector('[data-opening-copy]'), { autoAlpha:0, y:-40, duration:.45 }, .3)
    // The contrast gradient is only there for the text; it fades with it so the inset film reads clearly.
    .to(opening.querySelector('.about-opening-shade'), { opacity:.15, duration:.5 }, .3)
    .to(frame, { scale:.9, borderRadius:16, duration:.65 }, .3)
    .to({}, { duration:.05 });
   return function () { opening.classList.remove('is-sequenced'); };
  });

  media.add('(min-width:961px) and ' + MOTION, function () {
   // A small parallax on the first campus picture; it is scaled up so no edge ever shows.
   var figure = page.querySelector('[data-parallax]'), picture = figure && figure.querySelector('img, video');
   if (picture) {
    gsap.set(picture, { scale:1.08 });
    gsap.fromTo(picture, { yPercent:-3 }, { yPercent:3, ease:'none', scrollTrigger:{ trigger:figure, start:'top bottom', end:'bottom top', scrub:true } });
   }

   // Journey: one line runs from step to step with the section's scroll; each step appears as the line reaches it.
   var track = page.querySelector('[data-journey]'), line = track.querySelector('[data-journey-line]');
   var steps = Array.prototype.slice.call(track.querySelectorAll('.about-steps > li'));
   steps.forEach(function (step) { step.style.setProperty('--i', 0); manual.push(step); });
   var update = function (self) { steps.forEach(function (step, index) { if (self.progress >= index / (steps.length - 1) - .02) reveal(step); }); };
   gsap.fromTo(line, { scaleX:0 }, { scaleX:1, ease:'none', scrollTrigger:{ trigger:track, start:'top 80%', end:'bottom 62%', scrub:.4, onUpdate:update, onRefresh:update } });
   return function () { steps.forEach(reveal); manual.length = 0; };
  });

  if (document.fonts && document.fonts.ready) document.fonts.ready.then(function () { ScrollTrigger.refresh(); });
  window.addEventListener('pageshow', function (event) { if (event.persisted) ScrollTrigger.refresh(); });
 }

 if ('IntersectionObserver' in window && !reduce.matches) {
  var observer = new IntersectionObserver(function (entries) {
   entries.forEach(function (entry) { if (entry.isIntersecting) { reveal(entry.target); observer.unobserve(entry.target); } });
  }, { rootMargin:'0px 0px -12% 0px', threshold:0 });
  page.querySelectorAll('[data-reveal]').forEach(function (element) { if (manual.indexOf(element) < 0) observer.observe(element); });
  reduce.addEventListener('change', function () { if (reduce.matches) page.querySelectorAll('[data-reveal]').forEach(reveal); });
 } else {
  page.querySelectorAll('[data-reveal]').forEach(reveal);
 }

 // Arriving through an anchor below the opening: land on it again now that the opening has its final height.
 if (location.hash && opening.classList.contains('is-sequenced')) {
  var target = null;
  try { target = document.getElementById(decodeURIComponent(location.hash.slice(1))); } catch (e) { /* not an id */ }
  if (target && target !== opening && (opening.compareDocumentPosition(target) & Node.DOCUMENT_POSITION_FOLLOWING)) {
   requestAnimationFrame(function () { window.scrollTo({ top:target.getBoundingClientRect().top + window.scrollY - 112, behavior:'instant' }); });
  }
 }
 root.classList.add('about-ready');
}());
