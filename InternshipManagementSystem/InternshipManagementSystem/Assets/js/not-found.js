(function () {
 'use strict';
 var scene = document.querySelector('[data-not-found]');
 if (!scene) return;
 var reduce = window.matchMedia ? matchMedia('(prefers-reduced-motion: reduce)') : null;
 var timer = 0, finished = false;
 function settle() {
  clearTimeout(timer); scene.classList.remove('nf-entering');
  scene.setAttribute('data-settled', 'true'); finished = true;
 }
 // CSS/SVG animation is time-based, finite and resolution-independent: no canvas,
 // particle allocation, render loop, resize rebuild or unsupported context API.
 if (!document.hidden && !(reduce && reduce.matches)) {
  scene.classList.add('nf-entering');
  timer = setTimeout(settle, 2200);
 } else settle();
 function background() { if (document.hidden && !finished) settle(); }
 function reduced(event) { if (event.matches) settle(); }
 document.addEventListener('visibilitychange', background);
 if (reduce) {
  if (reduce.addEventListener) reduce.addEventListener('change', reduced);
  else reduce.addListener(reduced);
 }
 // Geometry is CSS-relative. Resizing never removes figures or replays the entrance.
 window.addEventListener('pagehide', function () {
  settle(); document.removeEventListener('visibilitychange', background);
  if (reduce) { if (reduce.removeEventListener) reduce.removeEventListener('change', reduced); else reduce.removeListener(reduced); }
 }, { once:true });

 var back = document.querySelector('[data-nf-back]');
 if (!back) return;
 var previous = null, missing = [];
 try { missing = JSON.parse(sessionStorage.getItem('uims-missing-pages') || '[]'); if (!Array.isArray(missing)) missing = []; } catch (_) { missing = []; }
 try {
  var referrer = document.referrer ? new URL(document.referrer) : null;
  if (referrer && referrer.origin === location.origin && history.length > 1 &&
      referrer.pathname !== location.pathname && !/\/NotFound\.aspx$/i.test(referrer.pathname) &&
      missing.indexOf(referrer.origin + referrer.pathname) < 0) previous = referrer;
 } catch (_) { /* Keep the useful Contact link when the previous page cannot be established. */ }
 try {
  var current = location.origin + location.pathname;
  if (missing.indexOf(current) < 0) missing.push(current);
  sessionStorage.setItem('uims-missing-pages', JSON.stringify(missing.slice(-20)));
 } catch (_) { /* Storage is optional. */ }
 if (!previous) return;
 back.href = back.getAttribute('data-home');
 back.querySelector('span').textContent = back.getAttribute('data-back-label');
 back.addEventListener('click', function (event) {
  if (event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;
  // The validated referrer is evidence only, never a redirect destination.
  if (history.length > 1) { event.preventDefault(); history.back(); }
 });
}());
