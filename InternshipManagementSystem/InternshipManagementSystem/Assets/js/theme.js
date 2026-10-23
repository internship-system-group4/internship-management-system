(function () {
 'use strict';
 // UIMS Light / Dark / System. The inline script in each master's <head> already applied the stored theme before the
 // first paint; this file keeps it in step (System changes, other tabs) and runs the selectors.
 // Preference (what the visitor chose) and theme (what is shown) are separate:
 //   localStorage['uims-theme'] = light | dark | system      (missing or invalid -> light)
 //   <html data-theme-preference> = the preference; <html data-theme data-bs-theme> = light | dark
 if (window.UimsTheme) { window.UimsTheme.bind(document); return; }
 var KEY = 'uims-theme', VALID = ['light', 'dark', 'system'];
 var root = document.documentElement;
 var systemDark = window.matchMedia ? matchMedia('(prefers-color-scheme: dark)') : null;
 var reduce = window.matchMedia ? matchMedia('(prefers-reduced-motion: reduce)') : null;
 // Labels come from the shared resources (window.uimsT, Assets/js/i18n.js); English if the dictionary is absent.
 var t = function (key, fallback) { return typeof window.uimsT === 'function' && window.UIMS_I18N && window.UIMS_I18N[key] ? window.uimsT.apply(null, arguments) : fallback; };
 var LABELS = { light:t('ThemeLight', 'Light'), dark:t('ThemeDark', 'Dark'), system:t('ThemeSystem', 'System') };
 var changingTimer = 0;

 function valid(value) { return VALID.indexOf(value) >= 0 ? value : 'light'; }
 function read() { try { return valid(localStorage.getItem(KEY)); } catch (e) { return 'light'; } }
 function write(value) { try { localStorage.setItem(KEY, value); } catch (e) { /* private mode or blocked: this page still switches */ } }
 function resolve(preference) { return preference === 'system' ? (systemDark && systemDark.matches ? 'dark' : 'light') : preference; }
 var preference = valid(root.getAttribute('data-theme-preference') || read());

 function apply(next, deliberate) {
  preference = valid(next);
  var theme = resolve(preference), before = root.getAttribute('data-theme');
  if (deliberate && before !== theme && !(reduce && reduce.matches)) {
   root.classList.add('uims-theme-changing');
   clearTimeout(changingTimer);
   changingTimer = setTimeout(function () { root.classList.remove('uims-theme-changing'); }, 240);
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
   if (toggle) { var name = LABELS[preference] + (preference === 'system' ? ' (' + LABELS[resolve('system')] + ')' : ''); toggle.setAttribute('aria-label', typeof window.uimsT === 'function' && window.UIMS_I18N && window.UIMS_I18N.ThemeLabel ? window.uimsT('ThemeLabel', name) : 'Colour theme: ' + name); }
  });
 }

 function choose(value) { write(valid(value)); apply(value, true); }

 // Menu button: Enter/Space/ArrowDown open on the checked item, arrows move, Home/End jump, Escape or Tab close.
 function bindMenu(control) {
  var toggle = control.querySelector('[data-theme-toggle]'), menu = control.querySelector('[role="menu"]');
  var items = Array.prototype.slice.call(menu.querySelectorAll('[role="menuitemradio"]'));
  function open(focusItem) {
   menu.hidden = false; toggle.setAttribute('aria-expanded', 'true');
   var target = focusItem || items.filter(function (i) { return i.getAttribute('aria-checked') === 'true'; })[0] || items[0];
   target.focus();
  }
  function close(refocus) { if (menu.hidden) return; menu.hidden = true; toggle.setAttribute('aria-expanded', 'false'); if (refocus) toggle.focus(); }
  toggle.addEventListener('click', function () { if (menu.hidden) open(); else close(true); });
  toggle.addEventListener('keydown', function (event) {
   if (event.key === 'ArrowDown' || event.key === 'ArrowUp') { event.preventDefault(); open(event.key === 'ArrowUp' ? items[items.length - 1] : null); }
  });
  items.forEach(function (item, index) {
   item.addEventListener('click', function () { choose(item.getAttribute('data-theme-value')); close(true); });
   item.addEventListener('keydown', function (event) {
    var next = null;
    if (event.key === 'ArrowDown') next = items[(index + 1) % items.length];
    else if (event.key === 'ArrowUp') next = items[(index - 1 + items.length) % items.length];
    else if (event.key === 'Home') next = items[0];
    else if (event.key === 'End') next = items[items.length - 1];
    else if (event.key === 'Escape') { event.preventDefault(); close(true); return; }
    else if (event.key === 'Tab') { close(false); return; }
    if (next) { event.preventDefault(); next.focus(); }
   });
  });
  document.addEventListener('click', function (event) { if (!control.contains(event.target)) close(false); });
  control.addEventListener('focusout', function (event) { if (!menu.hidden && event.relatedTarget && !control.contains(event.relatedTarget)) close(false); });
 }

 // Radio group: one tab stop; arrows move and select.
 function bindInline(control) {
  var radios = Array.prototype.slice.call(control.querySelectorAll('[role="radio"]'));
  radios.forEach(function (radio, index) {
   radio.addEventListener('click', function () { choose(radio.getAttribute('data-theme-value')); });
   radio.addEventListener('keydown', function (event) {
    var step = event.key === 'ArrowRight' || event.key === 'ArrowDown' ? 1 : event.key === 'ArrowLeft' || event.key === 'ArrowUp' ? -1 : 0;
    if (!step) return;
    if (getComputedStyle(control).direction === 'rtl' && (event.key === 'ArrowRight' || event.key === 'ArrowLeft')) step = -step;
    event.preventDefault();
    var next = radios[(index + step + radios.length) % radios.length];
    choose(next.getAttribute('data-theme-value')); next.focus();
   });
  });
 }

 function bind(scope) {
  scope.querySelectorAll('[data-theme-control]:not([data-theme-ready])').forEach(function (control) {
   control.setAttribute('data-theme-ready', '');
   if (control.getAttribute('data-theme-control') === 'inline') bindInline(control); else bindMenu(control);
   control.hidden = false;
  });
  syncControls();
 }

 // System: follow the operating system only while System is the preference.
 if (systemDark) {
  var onSystem = function () { if (preference === 'system') apply('system', true); };
  if (systemDark.addEventListener) systemDark.addEventListener('change', onSystem); else systemDark.addListener(onSystem);
 }
 // Other tabs.
 window.addEventListener('storage', function (event) { if (event.key === KEY || event.key === null) apply(read(), true); });
 // Back/forward cache: another page may have changed the preference meanwhile.
 window.addEventListener('pageshow', function (event) { if (event.persisted) apply(read(), false); });

 window.UimsTheme = {
  bind:bind,
  set:function (value) { choose(value); },
  get preference() { return preference; },
  get theme() { return resolve(preference); }
 };
 apply(preference, false);
 bind(document);
}());
