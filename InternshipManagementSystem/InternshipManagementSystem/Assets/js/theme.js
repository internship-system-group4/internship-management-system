(function () {
 'use strict';
 // Light/Dark preference is applied before first paint by each master's inline script.
 // Controls share persistence, cross-tab synchronization and the interruptible circular reveal.
 if (window.UimsTheme) { window.UimsTheme.bind(document); return; }
 var KEY = 'uims-theme', VALID = ['light', 'dark'];
 var root = document.documentElement;
 var reduce = window.matchMedia ? matchMedia('(prefers-reduced-motion: reduce)') : null;
 // Labels come from the shared resources (window.uimsT, Assets/js/i18n.js); English if the dictionary is absent.
 var t = function (key, fallback) { return typeof window.uimsT === 'function' && window.UIMS_I18N && window.UIMS_I18N[key] ? window.uimsT.apply(null, arguments) : fallback; };
 var LABELS = { light:t('ThemeLight', 'Light'), dark:t('ThemeDark', 'Dark') };
 var changingTimer = 0, iconTimer = 0, transitionRequest = 0, activeTransition = null;

 function valid(value) { return VALID.indexOf(value) >= 0 ? value : 'light'; }
 function read() { try { return valid(localStorage.getItem(KEY)); } catch (e) { return 'light'; } }
 function write(value) { try { localStorage.setItem(KEY, value); } catch (e) { /* private mode or blocked: this page still switches */ } }
 function resolve(preference) { return valid(preference); }
 var preference = valid(root.getAttribute('data-theme-preference') || read());

 function cancelReveal() {
  var transition = activeTransition; activeTransition = null;
  if (transition && typeof transition.skipTransition === 'function') { try { transition.skipTransition(); } catch (e) { /* already finished */ } }
  root.classList.remove('uims-theme-reveal');
 }

 function animateIcons() {
  if (reduce && reduce.matches) return;
  clearTimeout(iconTimer); root.classList.add('uims-theme-icon-changing');
  iconTimer = setTimeout(function () { root.classList.remove('uims-theme-icon-changing'); }, 360);
 }

 function apply(next, deliberate, inReveal, animateIcon) {
  if (!inReveal && activeTransition) { transitionRequest++; cancelReveal(); }
  if (!animateIcon) { clearTimeout(iconTimer); root.classList.remove('uims-theme-icon-changing'); }
  if (reduce && reduce.matches) { clearTimeout(changingTimer); root.classList.remove('uims-theme-changing', 'uims-theme-icon-changing'); }
  preference = valid(next);
  var theme = resolve(preference), before = root.getAttribute('data-theme');
  if (deliberate && before !== theme && !(reduce && reduce.matches)) {
   clearTimeout(changingTimer);
   if (inReveal) root.classList.remove('uims-theme-changing');
   else { root.classList.add('uims-theme-changing'); changingTimer = setTimeout(function () { root.classList.remove('uims-theme-changing'); }, 240); }
  }
  root.setAttribute('data-theme-preference', preference);
  root.setAttribute('data-theme', theme);
  root.setAttribute('data-bs-theme', theme);
  root.style.colorScheme = theme;
  syncControls();
  if (before !== theme) document.dispatchEvent(new CustomEvent('uims:themechange', { detail:{ preference:preference, theme:theme } }));
 }

 function syncControls() {
  document.querySelectorAll('[data-theme-control]').forEach(function (control) {
   control.querySelectorAll('[data-theme-value]').forEach(function (option) {
    var on = option.getAttribute('data-theme-value') === preference;
    option.setAttribute('aria-checked', String(on));
    if (option.getAttribute('role') === 'radio') option.tabIndex = on ? 0 : -1;
   });
   var toggle = control.querySelector('[data-theme-toggle]');
   if (toggle) { toggle.setAttribute('aria-pressed', String(preference === 'dark')); toggle.setAttribute('aria-label', LABELS.dark); toggle.title = LABELS[preference === 'dark' ? 'light' : 'dark']; }
  });
 }

 function originFrom(control) {
  if (!control || typeof control.getBoundingClientRect !== 'function') return null;
  var rect = control.getBoundingClientRect();
  return { x:rect.left + rect.width / 2, y:rect.top + rect.height / 2, width:window.innerWidth, height:window.innerHeight };
 }

 function reveal(next, origin, request) {
  root.classList.remove('uims-theme-changing', 'uims-theme-icon-changing'); clearTimeout(changingTimer); clearTimeout(iconTimer);
  root.classList.add('uims-theme-reveal');
  var transition;
  try {
   transition = document.startViewTransition(function () { if (request === transitionRequest) apply(next, false, true, true); });
  } catch (error) {
   root.classList.remove('uims-theme-reveal'); animateIcons(); apply(next, true, false, true); return;
  }
  activeTransition = transition;
  function cleanup() { if (activeTransition === transition) { activeTransition = null; root.classList.remove('uims-theme-reveal'); } }
  Promise.resolve(transition.ready).then(function () {
   if (request !== transitionRequest || activeTransition !== transition) return;
   var radius = Math.hypot(Math.max(origin.x, origin.width - origin.x), Math.max(origin.y, origin.height - origin.y));
   try {
    var animation = root.animate({ clipPath:['circle(0px at ' + origin.x + 'px ' + origin.y + 'px)', 'circle(' + radius + 'px at ' + origin.x + 'px ' + origin.y + 'px)'] },
     { duration:900, easing:'cubic-bezier(.4,0,.2,1)', pseudoElement:'::view-transition-new(root)' });
    Promise.resolve(animation.finished).catch(function () { /* skipped transitions are expected during rapid choices */ });
   } catch (error) { cancelReveal(); }
  }, function () { if (request === transitionRequest && root.getAttribute('data-theme') !== resolve(next)) apply(next, false); });
  Promise.resolve(transition.updateCallbackDone).catch(function () { if (request === transitionRequest) apply(next, false); });
  Promise.resolve(transition.finished).then(cleanup, cleanup);
 }

 function choose(value, control) {
  var next = valid(value), beforePreference = preference, origin = originFrom(control);
  write(next); preference = next;
  var changesAppearance = root.getAttribute('data-theme') !== resolve(next), request = ++transitionRequest;
  if (activeTransition) cancelReveal();
  if (changesAppearance && origin && !(reduce && reduce.matches) && typeof document.startViewTransition === 'function') { reveal(next, origin, request); return; }
  if (control && beforePreference !== next) animateIcons();
  apply(next, true, false, !!(control && beforePreference !== next));
 }

 // Native button handles mouse, touch, Enter and Space without a menu or delay.
 function bindToggle(control) {
  var toggle = control.querySelector('[data-theme-toggle]');
  toggle.addEventListener('click', function () { choose(preference === 'dark' ? 'light' : 'dark', toggle); });
 }

 // A root View Transition can hit-test a rapid second click against <html>, because
 // the real control is temporarily represented by its snapshot. Forward only clicks
 // inside a visible theme option; normal button clicks keep their native handler.
 document.addEventListener('click', function (event) {
  if (!activeTransition || event.target !== root || event.button !== 0) return;
  var toggles = document.querySelectorAll('[data-theme-toggle], [data-theme-value]');
  for (var i = 0; i < toggles.length; i++) {
   var rect = toggles[i].getBoundingClientRect();
   if (rect.width && rect.height && event.clientX >= rect.left && event.clientX <= rect.right && event.clientY >= rect.top && event.clientY <= rect.bottom) {
    event.preventDefault(); event.stopImmediatePropagation();
    choose(toggles[i].getAttribute('data-theme-value') || (preference === 'dark' ? 'light' : 'dark'), toggles[i]); break;
   }
  }
 });

 // Radio group: one tab stop; arrows move and select.
 function bindInline(control) {
  var radios = Array.prototype.slice.call(control.querySelectorAll('[role="radio"]'));
  radios.forEach(function (radio, index) {
   radio.addEventListener('click', function () { choose(radio.getAttribute('data-theme-value'), radio); });
   radio.addEventListener('keydown', function (event) {
    var step = event.key === 'ArrowRight' || event.key === 'ArrowDown' ? 1 : event.key === 'ArrowLeft' || event.key === 'ArrowUp' ? -1 : 0;
    if (!step) return;
    if (getComputedStyle(control).direction === 'rtl' && (event.key === 'ArrowRight' || event.key === 'ArrowLeft')) step = -step;
    event.preventDefault();
    var next = radios[(index + step + radios.length) % radios.length];
    choose(next.getAttribute('data-theme-value'), next); next.focus();
   });
  });
 }

 function bind(scope) {
  scope.querySelectorAll('[data-theme-control]:not([data-theme-ready])').forEach(function (control) {
   control.setAttribute('data-theme-ready', '');
   if (control.getAttribute('data-theme-control') === 'inline') bindInline(control); else bindToggle(control);
   control.hidden = false;
  });
  syncControls();
 }

 if (reduce) {
  var onReducedMotion = function (event) {
   if (!event.matches) return;
   transitionRequest++; cancelReveal(); clearTimeout(changingTimer); clearTimeout(iconTimer);
   root.classList.remove('uims-theme-changing', 'uims-theme-icon-changing'); apply(preference, false);
  };
  if (reduce.addEventListener) reduce.addEventListener('change', onReducedMotion); else reduce.addListener(onReducedMotion);
 }
 // Other tabs.
 window.addEventListener('storage', function (event) { if (event.key === KEY || event.key === null) apply(read(), true); });
 // Back/forward cache: another page may have changed the preference meanwhile.
 window.addEventListener('pageshow', function (event) { if (event.persisted) apply(read(), false); });
 window.addEventListener('pagehide', function () {
  if (activeTransition) { transitionRequest++; cancelReveal(); apply(preference, false); }
  clearTimeout(changingTimer); clearTimeout(iconTimer); root.classList.remove('uims-theme-changing', 'uims-theme-icon-changing', 'uims-theme-reveal');
 });

 window.UimsTheme = {
  bind:bind,
  set:function (value) { choose(value); },
  get preference() { return preference; },
  get theme() { return resolve(preference); }
 };
 apply(preference, false);
 bind(document);
}());
