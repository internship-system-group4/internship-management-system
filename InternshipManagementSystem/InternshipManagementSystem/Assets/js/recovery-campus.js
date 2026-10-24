(function () {
 'use strict';
 // Password recovery page (ForgotPassword.aspx). The reset itself is the server postback (ForgotPassword.aspx.cs calls
 // Firebase). This script sends that same postback in the background so the campus scene can follow it:
 //   idle -> submitting (terminal "Processing…") -> success ("Reset Link Sent") or denied ("Please try again").
 // The scene only reaches "success" when the returned page says data-result="sent". The gate never opens here.
 // Without fetch the form posts back normally and the server renders the same states.
 const scriptUrl = document.currentScript.src;
 // The terminal shows "Processing…" for at least this long so the step is readable; the result is already final.
 const MIN_PROCESSING_MS = 900;

 function initialize() {
  const root = document.querySelector('[data-recovery-campus]');
  if (!root || root.dataset.initialized) return;
  root.dataset.initialized = 'true';
  const motion = matchMedia('(prefers-reduced-motion: reduce)');
  const form = root.querySelector('[data-public-form]');
  const serverForm = root.closest('form');
  const status = root.querySelector('[data-recovery-status]');
  const sent = root.querySelector('[data-recovery-sent]');
  const again = root.querySelector('[data-recovery-again]');
  const email = form.querySelector('input[type=email]');
  const button = form.querySelector('input[type=submit]');
  let scene = null, disposed = false, posted = false, request = null;

  function sceneState() {
   if (posted) return 'submitting';
   return root.dataset.result === 'sent' ? 'success' : root.dataset.result === 'error' ? 'denied' : 'idle';
  }
  // Undo public-forms.js's busy state (it set data-submitting and swapped the button text).
  function release() {
   form.removeAttribute('data-submitting'); form.removeAttribute('aria-busy');
   if (button) { button.removeAttribute('aria-disabled'); if (button.dataset.originalText) button.value = button.dataset.originalText; }
  }
  function alertBox() { return form.querySelector('[role="alert"]'); }

  function showProcessing() {
   root.dataset.state = 'submitting';
   const stale = alertBox(); if (stale) stale.style.setProperty('display', 'none', 'important');
   status.textContent = window.uimsT('RequestingReset');
   scene?.setState('submitting');
  }
  function showSent() {
   posted = false; release(); status.textContent = '';
   email.value = ''; email.removeAttribute('aria-invalid');
   root.dataset.result = 'sent'; root.dataset.state = 'sent';
   scene?.setState('success');
   sent.focus({ preventScroll:true }); sent.scrollIntoView?.({ block:'nearest' });
  }
  function showError(message) {
   posted = false; release(); status.textContent = '';
   root.dataset.result = 'error'; root.dataset.state = 'idle';
   let alert = alertBox();
   if (!alert) { alert = document.createElement('span'); alert.setAttribute('role', 'alert'); form.querySelector('.public-field').before(alert); }
   alert.className = 'alert alert-danger d-block'; alert.textContent = message; alert.style.removeProperty('display'); alert.tabIndex = -1;
   scene?.setState('denied');
   alert.focus({ preventScroll:true }); alert.scrollIntoView?.({ block:'nearest' });
  }
  // ASP.NET needs the fresh view state and event validation from each response for the next postback.
  function refreshHiddenFields(doc) {
   for (const field of serverForm.querySelectorAll('input[type=hidden][name^="__"]')) {
    const fresh = doc.querySelector('input[name="' + field.name + '"]'); if (fresh) field.value = fresh.value;
   }
  }
  function settle(started) {
   const left = (motion.matches ? 0 : MIN_PROCESSING_MS) - (performance.now() - started);
   return new Promise(resolve => setTimeout(resolve, Math.max(0, left)));
  }

  function submit(event) {
   // Another control of the master form (language, theme) posts back as usual.
   if (event.submitter && event.submitter !== button) return;
   if (posted) { event.preventDefault(); return; }
   if (form.dataset.submitting !== 'true' && !window.validateEmail()) { event.preventDefault(); return; }
   posted = true; showProcessing();
   if (!window.fetch || !window.DOMParser || !window.FormData) return; // native postback
   event.preventDefault();
   const started = performance.now(), data = new FormData(serverForm);
   data.set(button.name, button.dataset.originalText || button.value);
   request = new AbortController();
   const timeout = setTimeout(() => request.abort(), 40000);
   fetch(serverForm.action, { method:'POST', body:data, credentials:'same-origin', headers:{ 'Accept':'text/html' }, signal:request.signal })
    .then(response => { if (!response.ok) throw Error('HTTP ' + response.status); return response.text(); })
    .then(html => {
     const doc = new DOMParser().parseFromString(html, 'text/html');
     const next = doc.querySelector('[data-recovery-campus]');
     if (!next) throw Error('Unexpected response');
     refreshHiddenFields(doc);
     const message = doc.querySelector('[data-public-form] [role="alert"]')?.textContent.trim();
     return settle(started).then(() => {
      if (disposed) return;
      if (next.dataset.result === 'sent') showSent(); else showError(message || window.uimsT('RecoveryOffline'));
     });
    })
    .catch(() => settle(started).then(() => { if (!disposed) showError(window.uimsT('RecoveryOffline')); }))
    .finally(() => { clearTimeout(timeout); request = null; });
  }
  serverForm.addEventListener('submit', submit);
  // Enter in the email field always means "Send Reset Link", whatever the master form's first button is.
  function enter(event) { if (event.key === 'Enter' && !event.isComposing) { event.preventDefault(); button.click(); } }
  email.addEventListener('keydown', enter);
  // After a refusal the terminal returns to "ready" as soon as the visitor edits the address.
  function edited() { if (root.dataset.result === 'error' && !posted) { root.dataset.result = ''; scene?.setState('idle'); } }
  email.addEventListener('input', edited);
  function tryAgain() { root.dataset.result = ''; root.dataset.state = 'idle'; scene?.setState('idle'); email.focus(); }
  again.addEventListener('click', tryAgain);
  function pageShow() { if (!posted) return; posted = false; release(); root.dataset.state = 'idle'; status.textContent = ''; scene?.setState(sceneState()); }
  window.addEventListener('pageshow', pageShow);
  function changeMotion() { scene?.setReducedMotion(motion.matches); }
  motion.addEventListener('change', changeMotion);

  // The form works before (and without) the scene. Same scene module as Login, in recovery mode.
  import(new URL('./login-campus-scene.js?v=20261024-recovery-7', scriptUrl).href).then(async module => {
   if (disposed) return;
   const created = await module.createCampusScene(root, { reducedMotion:motion.matches, mode:'recovery' });
   if (disposed) { created.dispose(); return; }
   scene = created; root.campusScene = created; root.dataset.sceneReady = 'true';
   scene.setState(sceneState());
  }).catch(() => { root.dataset.sceneFallback = 'true'; });

  window.addEventListener('pagehide', function () {
   disposed = true; request?.abort(); scene?.dispose(); scene = null;
   root.removeAttribute('data-scene-ready'); delete root.campusScene; delete root.dataset.initialized;
   root.querySelector('[data-campus-pause]').hidden = true;
   serverForm.removeEventListener('submit', submit); email.removeEventListener('keydown', enter); email.removeEventListener('input', edited);
   again.removeEventListener('click', tryAgain); window.removeEventListener('pageshow', pageShow); motion.removeEventListener('change', changeMotion);
  }, { once:true });
 }
 initialize();
 window.addEventListener('pageshow', function (event) { if (event.persisted) initialize(); });
}());
