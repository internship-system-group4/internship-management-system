(function () {
 'use strict';
 // Contact Us: the "Form readiness" indicator, the message counter, validation after leaving a field, and the
 // decorative envelope. Submission, the busy state and the duplicate-send guard stay in public-forms.js; the
 // server validates everything again.
 var form = document.querySelector('[data-contact-form]');
 if (!form || form.hasAttribute('data-contact-enhanced') || !window.publicFieldMessage) return;
 form.setAttribute('data-contact-enhanced', '');
 var fields = Array.prototype.slice.call(form.querySelectorAll('[data-public-required]'));
 if (!fields.length) {
  // "Message sent": move focus to the confirmation so it is read first after the redirect.
  // The browser's own #contact-form fragment handling resets focus at load, so focus again once loading is done.
  var sent = form.querySelector('.contact-sent h2');
  var focusSent = function () { if (sent) sent.focus({ preventScroll:true }); };
  focusSent();
  if (document.readyState === 'complete') requestAnimationFrame(focusSent);
  else window.addEventListener('load', function () { requestAnimationFrame(focusSent); }, { once:true });
  return;
 }
 var check = window.publicFieldMessage;
 var readiness = form.querySelector('[data-contact-readiness]');
 var readinessText = readiness.querySelector('[data-readiness-text]');
 var segments = readiness.querySelectorAll('.contact-readiness-bar i');
 var message = form.querySelector('textarea'), counter = form.querySelector('[data-contact-counter]');
 var envelope = document.querySelector('[data-contact-envelope]');

 function errorFor(input) { return document.getElementById(input.getAttribute('aria-describedby').split(' ')[0]); }
 function show(input) {
  var text = check(input);
  errorFor(input).textContent = text;
  input.setAttribute('aria-invalid', String(!!text));
 }
 // One segment per field, in form order. Locally valid only: nothing here means the message was sent or saved.
 // The count is ordinary text, not a live region, so typing is never announced.
 function update() {
  var ready = 0;
  fields.forEach(function (input, index) {
   var ok = !check(input);
   if (ok) ready++;
   if (segments[index]) segments[index].classList.toggle('is-on', ok);
  });
  readinessText.textContent = window.uimsT('ContactReadiness', ready, fields.length);
  if (envelope) {
   envelope.style.setProperty('--ready', String(ready / fields.length));
   envelope.classList.toggle('is-ready', ready === fields.length);
  }
 }
 function count() {
  var length = message.value.length, max = message.maxLength > 0 ? message.maxLength : 4000;
  counter.textContent = length.toLocaleString('en') + ' / ' + max.toLocaleString('en');
  counter.classList.toggle('is-near', length >= max * .9);
 }

 fields.forEach(function (input) {
  // Fields the server marked invalid are checked again as soon as they are left.
  if (input.getAttribute('aria-invalid') === 'true') input.setAttribute('data-touched', '');
  input.addEventListener('input', function () {
   input.setAttribute('data-touched', '');
   update();
   if (input === message) count();
  });
  input.addEventListener('blur', function () { if (input.hasAttribute('data-touched')) show(input); });
 });
 readiness.hidden = false;
 counter.hidden = false;
 update();
 count();
 // Values restored by the browser's back/forward cache.
 window.addEventListener('pageshow', function () { update(); count(); });
}());
