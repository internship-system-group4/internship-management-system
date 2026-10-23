(function () {
 'use strict';
 // Script text: window.uimsT and window.UIMS_I18N are defined inline in each master's <head>.
 if (window.__uimsI18nGuard) return;
 window.__uimsI18nGuard = true;

 // Switching language loads the page again (a GET). If a form here has unsaved changes, ask first.
 var dirty = false;
 function track(event) {
  var field = event.target;
  if (!field || !field.closest || !field.closest('form') || field.closest('[data-theme-control], .uims-lang-inline, [data-no-dirty]')) return;
  if (/^(search|hidden|button|submit|reset)$/.test(field.type || '')) return;
  dirty = true;
 }
 document.addEventListener('input', track, true);
 document.addEventListener('change', track, true);
 document.addEventListener('submit', function () { dirty = false; }, true);
 document.addEventListener('click', function (event) {
  var link = event.target.closest ? event.target.closest('[data-lang-switch]') : null;
  if (!link || !dirty) return;
  if (!window.confirm(window.uimsT('LanguageUnsavedConfirm'))) event.preventDefault();
 });

 // Text people type or stored records (names, cover letters, feedback) take their own direction.
 // Free-text fields get dir="auto"; in Arabic, a text block with Latin letters and no Arabic is user content
 // (the interface itself is translated), so it gets dir="auto" too and its punctuation stays in place.
 function bidi(scope) {
  var rtl = document.documentElement.dir === 'rtl';
  (scope || document).querySelectorAll('textarea, input[type="text"], input[type="search"], input:not([type]), [data-user-content], p, li, dd, blockquote, td').forEach(function (el) {
   if (el.hasAttribute('dir')) return;
   if (el.matches('textarea, input, [data-user-content]')) { el.setAttribute('dir', 'auto'); return; }
   if (!rtl || el.children.length) return;
   var text = el.textContent;
   if (/[A-Za-z]{2}/.test(text) && !/[؀-ۿ]/.test(text)) el.setAttribute('dir', 'auto');
  });
 }
 if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', function () { bidi(); });
 else bidi();
 if (window.Sys && window.Sys.WebForms) window.Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function () { bidi(); });
}());
