(function () {
 'use strict';
 const scriptUrl = document.currentScript.src;
 // Defense in depth. Only the server emits these URLs, after role resolution.
 const ROUTE = /^\/(?:[^/?#]+\/)*Pages\/(?:(?:(?:Student|Company|Academic|Coordinator)\/Dashboard|Account\/ChangePassword)\.aspx|Student\/Apply\.aspx\?opportunityId=[A-Za-z0-9_%.-]+)$/;
 function initialize() {
 const root = document.querySelector('[data-login-campus]');
 if (!root || root.dataset.initialized) return;
 root.dataset.initialized = 'true';
 const motion = matchMedia('(prefers-reduced-motion: reduce)');
 const preference = root.querySelector('[data-campus-animation]');
 const status = root.querySelector('[data-campus-status]');
 const form = root.querySelector('[data-public-form]');
 const serverForm = root.closest('form');
 let scene, sceneReady, disposed = false, completed = false, destination = null, safety = 0;

 // Presentation only: no credential storage and no duplicate authentication controller.
 const identityValue=form.querySelector('[data-id-value]'),identityLabel=form.querySelector('[data-id-label]');
 const emailField=form.querySelector('input[type=email]'),secretField=form.querySelector('input[autocomplete=current-password]');
 let typingTimer=0,inkAnimation;
 function updateIdentity(event) {
  if(!identityValue||!emailField||!secretField)return;
  const secret=document.activeElement===secretField;
  identityLabel.textContent=form.querySelector('label[for="'+(secret?secretField.id:emailField.id)+'"]').textContent;
  identityValue.textContent=secret ? (secretField.value ? '••••••••' : '— — — —') : (emailField.value||identityValue.dataset.placeholder);
  form.dataset.idField=secret?'password':'email';
  if(event?.type==='input'&&!event.isComposing&&!motion.matches){
   form.dataset.typing='true';clearTimeout(typingTimer);
   typingTimer=setTimeout(()=>{delete form.dataset.typing;},650);
   inkAnimation?.cancel();
   const ink=form.querySelector('.login-id-ink i');
   if(ink?.animate)inkAnimation=ink.animate([{transform:'translateX(-100%)'},{transform:'translateX(100%)'}],{duration:460,easing:'cubic-bezier(.2,.65,.3,1)'});
  }
 }
 function stopTyping(){clearTimeout(typingTimer);delete form.dataset.typing;inkAnimation?.cancel();}
 function identityInput(event){if(event.target===emailField||event.target===secretField)updateIdentity(event);}
 form.addEventListener('input',identityInput);form.addEventListener('change',identityInput);form.addEventListener('focusin',identityInput);
 form.addEventListener('focusout',stopTyping);updateIdentity();
 // The printed card tilts a few degrees under a fine pointer and its gloss and hologram follow; nothing moves under reduced motion.
 const idCard=form.querySelector('[data-id-card]');
 if(idCard&&matchMedia('(pointer:fine)').matches){
  let tiltFrame=0;
  idCard.addEventListener('pointermove',event=>{
   if(motion.matches)return;
   cancelAnimationFrame(tiltFrame);
   tiltFrame=requestAnimationFrame(()=>{
    const box=idCard.getBoundingClientRect(),x=(event.clientX-box.left)/box.width,y=(event.clientY-box.top)/box.height;
    idCard.dataset.tilting='';idCard.style.setProperty('--mx',(x*100).toFixed(1)+'%');idCard.style.setProperty('--my',(y*100).toFixed(1)+'%');
    idCard.style.setProperty('--tilt-y',((x-.5)*8).toFixed(2)+'deg');idCard.style.setProperty('--tilt-x',((.5-y)*6).toFixed(2)+'deg');
   });
  });
  idCard.addEventListener('pointerleave',()=>{cancelAnimationFrame(tiltFrame);delete idCard.dataset.tilting;for(const name of ['--mx','--my','--tilt-x','--tilt-y'])idCard.style.removeProperty(name);});
 }

 function approved(url) { return !!url && ROUTE.test(url); }
 // The login page ends on the same veil the portal starts on (theme.css), so the swap is invisible.
 function navigate() {
  if (completed || !destination) return;
  completed = true; clearTimeout(safety);
  try { sessionStorage.setItem('uims-arrival', String(Date.now())); } catch (e) { /* storage blocked */ }
  location.replace(destination);
 }
 // The veil always gets its full fade (420ms in login-campus.css), even if the flight skipped frames.
 let veilAt = 0;
 function showVeil() {
  if (veilAt) return;
  veilAt = performance.now(); document.documentElement.dataset.loginVeil = 'on';
 }
 function coverAndGo() {
  showVeil();
  setTimeout(navigate, motion.matches ? 0 : Math.max(0, 400 - (performance.now() - veilAt)));
 }
 // Fetch the portal while the gate animation plays, so it is ready when the camera arrives.
 function prefetch(url) {
  if (HTMLScriptElement.supports?.('speculationrules')) {
   const rules = document.createElement('script'); rules.type = 'speculationrules';
   rules.textContent = JSON.stringify({ prefetch:[{ source:'list', urls:[url] }] });
   document.head.appendChild(rules);
  } else {
   const link = document.createElement('link'); link.rel = 'prefetch'; link.href = url; document.head.appendChild(link);
  }
 }
 function welcome(text) {
  if (!text || root.querySelector('.login-campus-welcome')) return;
  const badge = document.createElement('p'); badge.className = 'login-campus-welcome'; badge.setAttribute('aria-hidden', 'true');
  badge.textContent = text; root.querySelector('.login-campus-layout').appendChild(badge);
 }

 // Verified: run the welcome and the walk through the gate, then hand off to the portal.
 function succeed(url) {
  destination = url; prefetch(url);
  // The welcome plays in the scene at the top of the page; bring it back into view if the visitor had scrolled.
  if (scrollY > 0) scrollTo({ top:0, behavior:motion.matches ? 'auto' : 'smooth' });
  status.textContent = window.uimsT('LoginOpening');
  // Hard cap: a stalled scene never holds the visitor at the gate.
  safety = setTimeout(coverAndGo, 5200);
  if (motion.matches) { navigate(); return; }
  const play = () => {
   if (completed) return;
   if (!scene) { coverAndGo(); return; }
   scene.setState('success'); root.dataset.entering = 'true';
   // A short beat for the guard's welcome and the green light, then the gates open.
   setTimeout(() => {
    scene.enter({ onVeil:showVeil }).then(coverAndGo, coverAndGo);
   }, 300);
  };
  if (scene) play(); else (sceneReady || Promise.resolve()).then(play, play);
 }

 function setPreference() { preference.value = motion.matches ? '0' : '1'; }
 setPreference();
 function submitting() {
  if (form.dataset.submitting !== 'true' || destination) return;
  root.dataset.state = 'submitting';
  const stale = form.querySelector('[role="alert"]'); if (stale) stale.style.setProperty('display', 'none', 'important');
  status.textContent = window.uimsT('LoginChecking');
  scene?.setState('submitting');
 }
 const observer = new MutationObserver(submitting);
 observer.observe(form, { attributes:true, attributeFilter:['data-submitting'] });

 // Failure: keep the scene running and show the server's message in place.
 function fail(doc) {
  posted = false;
  for (const field of serverForm.querySelectorAll('input[type=hidden][name^="__"]')) {
   const fresh = doc.querySelector('input[name="' + field.name + '"]'); if (fresh) field.value = fresh.value;
  }
  const incoming = doc.querySelector('[data-public-form] [role="alert"]');
  let alert = form.querySelector('[role="alert"]');
  if (incoming) {
   if (!alert) { alert = document.createElement('span'); alert.setAttribute('role', 'alert'); form.querySelector('.public-field').before(alert); }
   alert.className = incoming.className; alert.textContent = incoming.textContent; alert.style.removeProperty('display'); alert.tabIndex = -1;
  }
  const password = form.querySelector('input[type=password],input[autocomplete="current-password"]');
  if (password) password.value = '';
  stopTyping();updateIdentity();
  form.removeAttribute('data-submitting'); form.removeAttribute('aria-busy');
  const button = form.querySelector('input[type="submit"]');
  if (button) { button.removeAttribute('aria-disabled'); if (button.dataset.originalText) button.value = button.dataset.originalText; }
  root.dataset.state = 'idle'; status.textContent = '';
  scene?.setState('denied');
  // Focus without the browser's jump-scroll, then reveal the message only as far as needed.
  const focusTarget = alert || password;
  focusTarget?.focus({ preventScroll:true }); focusTarget?.scrollIntoView?.({ block:'nearest' });
 }

 // Post in the background so the same scene carries straight into the welcome (no page reload).
 let posted = false;
 function submit(event) {
  if (destination || posted) { event.preventDefault(); return; }
  if (form.dataset.submitting !== 'true' && !window.validateLogin()) { event.preventDefault(); return; }
  posted = true; submitting();
  if (!window.fetch || !window.DOMParser || motion.matches) return; // native postback keeps working
  event.preventDefault();
  const data = new FormData(serverForm);
  const button = event.submitter || form.querySelector('input[type="submit"]');
  if (button?.name) data.set(button.name, button.dataset.originalText || button.value);
  fetch(serverForm.action, { method:'POST', body:data, credentials:'same-origin', headers:{ 'Accept':'text/html' } })
   .then(response => {
    if (response.redirected) { destination = new URL(response.url).pathname + new URL(response.url).search; navigate(); return null; }
    return response.text();
   })
   .then(html => {
    if (html == null || disposed) return;
    const doc = new DOMParser().parseFromString(html, 'text/html');
    const next = doc.querySelector('[data-login-campus]')?.dataset.destination;
    if (approved(next)) { welcome(doc.querySelector('.login-campus-welcome')?.textContent); succeed(next); }
    else fail(doc);
   })
   .catch(() => { posted = true; serverForm.submit(); });
 }
 serverForm.addEventListener('submit', submit);
 function pageShow() { posted = false; if (!destination) { root.dataset.state = 'idle'; scene?.setState('idle'); status.textContent = ''; } }
 window.addEventListener('pageshow', pageShow);
 function changeMotion() { setPreference(); if(motion.matches)stopTyping(); scene?.setReducedMotion(motion.matches); if (destination && motion.matches) navigate(); }
 motion.addEventListener('change', changeMotion);

 // The form is usable before this dynamic import starts.
 sceneReady = import(new URL('./login-campus-scene.js?v=20261024-perf-1', scriptUrl).href).then(async module => {
  if (disposed || completed) return;
  const created = await module.createCampusScene(root, { reducedMotion:motion.matches });
  if (disposed || completed) { created.dispose(); return; }
  // data-scene-ready starts the CSS crossfade from the photograph; the first complete frame is already drawn.
  scene = created; root.campusScene = created; root.dataset.sceneReady = 'true';
  if (!destination) submitting();
 }).catch(() => { root.dataset.sceneFallback = 'true'; });

 // Fallback path: a full postback (no fetch, or it failed) rendered the verified page.
 const rendered = root.dataset.destination;
 if (approved(rendered)) succeed(rendered);

 window.addEventListener('pagehide', function () {
  disposed = true; observer.disconnect(); scene?.dispose(); clearTimeout(safety);
  stopTyping();form.removeEventListener('input',identityInput);form.removeEventListener('change',identityInput);form.removeEventListener('focusin',identityInput);form.removeEventListener('focusout',stopTyping);
  root.removeAttribute('data-scene-ready'); delete root.campusScene;
  delete root.dataset.initialized;
  root.querySelector('[data-campus-pause]').hidden = true;
  serverForm.removeEventListener('submit', submit);
  motion.removeEventListener('change', changeMotion);
  window.removeEventListener('pageshow', pageShow);
 }, { once:true });
 }
 initialize();
 window.addEventListener('pageshow', function(event) { if(event.persisted) { document.documentElement.removeAttribute('data-login-veil'); initialize(); } });
}());
