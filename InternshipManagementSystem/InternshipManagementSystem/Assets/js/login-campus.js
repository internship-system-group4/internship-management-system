(function () {
 'use strict';
 const scriptUrl = document.currentScript.src;
 function initialize() {
 const root = document.querySelector('[data-login-campus]');
 if (!root || root.dataset.initialized) return;
 root.dataset.initialized = 'true';
 const motion = matchMedia('(prefers-reduced-motion: reduce)');
 const preference = root.querySelector('[data-campus-animation]');
 const status = root.querySelector('[data-campus-status]');
 const form = root.querySelector('[data-public-form]');
 const destination = root.dataset.destination;
 let scene, disposed = false, completed = false;
 // Defense in depth. Only the server emits this URL, after role resolution.
 const approved = destination && /^\/(?:[^/?#]+\/)*Pages\/(?:(?:Student|Company|Academic|Coordinator)\/Dashboard|Account\/ChangePassword)\.aspx$/.test(destination);
 function navigate() { if (!completed && approved) { completed = true; location.replace(destination); } }
 if (approved) {
  // Start before importing anything; unavailable WebGL never holds up login.
  setTimeout(navigate, 1700);
  status.textContent = 'Welcome. Opening your portal…';
  if (motion.matches) { navigate(); return; }
 }
 function setPreference() { preference.value = motion.matches ? '0' : '1'; }
 setPreference();
 function submitting() {
  if (form.dataset.submitting !== 'true' || approved) return;
  root.dataset.state = 'submitting';
  status.textContent = 'Checking your account. Please wait…';
  scene?.setState('submitting');
 }
 // Observe the existing validator's accepted state; do not replace its postback logic.
 const observer = new MutationObserver(submitting);
 observer.observe(form, { attributes:true, attributeFilter:['data-submitting'] });
 // Also block native Enter/programmatic requestSubmit retries.
 let posted = false;
 function submit(event) {
  if (approved || posted) { event.preventDefault(); return; }
  if (form.dataset.submitting !== 'true' && !window.validateLogin()) { event.preventDefault(); return; }
  posted = true; submitting();
 }
 const serverForm = root.closest('form'); serverForm.addEventListener('submit', submit);
 function pageShow() { posted = false; if (!approved) { root.dataset.state = 'idle'; scene?.setState('idle'); status.textContent = ''; } }
 window.addEventListener('pageshow', pageShow);
 function changeMotion() { setPreference(); scene?.setReducedMotion(motion.matches); if (approved && motion.matches) navigate(); }
 motion.addEventListener('change', changeMotion);
 // The form is usable before this dynamic import starts.
 import(new URL('./login-campus-scene.js', scriptUrl).href).then(async module => {
  if (disposed || completed) return;
  scene = await module.createCampusScene(root, { reducedMotion:motion.matches });
  if (disposed || completed) { scene.dispose(); return; }
  root.dataset.sceneReady = 'true';
  if (approved) {
   scene.setState('success'); root.dataset.entering = 'true';
   scene.enter().then(navigate).catch(navigate);
  } else submitting();
 }).catch(() => { root.dataset.sceneFallback = 'true'; if (approved) navigate(); });
 window.addEventListener('pagehide', function () {
  disposed = true; observer.disconnect(); scene?.dispose();
  root.removeAttribute('data-scene-ready');
  delete root.dataset.initialized;
  root.querySelector('[data-campus-pause]').hidden = true;
  serverForm.removeEventListener('submit', submit);
  motion.removeEventListener('change', changeMotion);
  window.removeEventListener('pageshow', pageShow);
 }, { once:true });
 }
 initialize();
 window.addEventListener('pageshow', function(event) { if(event.persisted) initialize(); });
}());
