/* Final Completion Review: queue search and status filters, scoped PDF printing
   and the one-time approval stamp. The stamp markup is only rendered by the
   server after a successful, saved approval; this file never decides that. */
(function () {
  'use strict';
  var t = typeof window.uimsT === 'function' ? window.uimsT : function (k) { return k; };
  var reduced = window.matchMedia && matchMedia('(prefers-reduced-motion: reduce)').matches;

  // ---- queue filters ---------------------------------------------------------
  function initQueue(root) {
    var rows = Array.prototype.slice.call(root.querySelectorAll('[data-cr-row]'));
    if (!rows.length) return;
    var search = root.querySelector('[data-cr-search]');
    var chips = Array.prototype.slice.call(root.querySelectorAll('[data-cr-filter]'));
    var visibleCount = root.querySelector('[data-cr-visible]');
    var announce = root.querySelector('[data-cr-announce]');
    var nomatch = root.querySelector('[data-cr-nomatch]');
    var status = 'all';
    var timer = 0;

    function apply() {
      var term = (search && search.value || '').trim().toLowerCase();
      var shown = 0;
      rows.forEach(function (row) {
        var ok = (status === 'all' || row.getAttribute('data-status') === status)
              && (!term || (row.getAttribute('data-search') || '').indexOf(term) >= 0);
        row.hidden = !ok;
        if (ok) shown++;
      });
      if (visibleCount) visibleCount.textContent = String(shown);
      if (nomatch) nomatch.hidden = shown > 0;
      clearTimeout(timer);
      timer = setTimeout(function () { if (announce) announce.textContent = t('ReviewQueueShowing', shown, rows.length); }, 350);
    }

    chips.forEach(function (chip) {
      chip.addEventListener('click', function () {
        status = chip.getAttribute('data-cr-filter');
        chips.forEach(function (c) { c.setAttribute('aria-pressed', String(c === chip)); });
        apply();
      });
    });
    if (search) search.addEventListener('input', apply);
  }

  // ---- the approval stamp ------------------------------------------------------
  function initStamp() {
    var stage = document.querySelector('[data-cr-stamp]');
    if (!stage) return;
    // Lift the stage to <body> so no transformed ancestor clips the fixed overlay.
    document.body.appendChild(stage);
    var close = stage.querySelector('[data-cr-stamp-close]');
    var previousOverflow = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    setTimeout(function () { if (close) close.focus({ preventScroll: true }); }, reduced ? 0 : 900);

    function finish() {
      if (stage.classList.contains('is-leaving')) return;
      stage.classList.add('is-leaving');
      document.removeEventListener('keydown', onKey);
      setTimeout(function () {
        stage.remove();
        document.body.style.overflow = previousOverflow;
        var decision = document.getElementById('crDecision');
        var docs = document.querySelector('[data-cr-docs]');
        if (decision) decision.scrollIntoView({ behavior: reduced ? 'auto' : 'smooth', block: 'start' });
        if (docs) {
          docs.classList.add('is-revealing');
          var first = docs.querySelector('a');
          if (first) setTimeout(function () { first.focus({ preventScroll: true }); }, reduced ? 0 : 400);
        }
      }, reduced ? 0 : 220);
    }
    function onKey(event) {
      if (event.key === 'Escape') { event.preventDefault(); finish(); }
      // Only one control inside: keep focus on it while the dialog is open.
      if (event.key === 'Tab' && close) { event.preventDefault(); close.focus(); }
    }
    document.addEventListener('keydown', onKey);
    if (close) close.addEventListener('click', finish);
    stage.addEventListener('click', function (event) { if (event.target === stage) finish(); });
  }

  function init() {
    document.querySelectorAll('[data-cr-queue]').forEach(initQueue);
    initStamp();
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init); else init();
}());
