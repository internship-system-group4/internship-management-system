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

  // ---- decision confirm pop-up -------------------------------------------------
  // The buttons call UimsCrConfirm(this) from OnClientClick. The first click opens
  // the pop-up and stops the postback; "confirm" clicks the button again for real.
  function initConfirm() {
    var dialog = document.querySelector('[data-cr-confirm-dialog]');
    if (!dialog) return;
    document.body.appendChild(dialog);
    var title = dialog.querySelector('[data-cr-confirm-title]');
    var text = dialog.querySelector('[data-cr-confirm-text]');
    var points = dialog.querySelector('[data-cr-confirm-points]');
    var note = dialog.querySelector('[data-cr-confirm-note]');
    var noteText = dialog.querySelector('[data-cr-confirm-note-text]');
    var go = dialog.querySelector('[data-cr-confirm-go]');
    var cancel = dialog.querySelector('[data-cr-confirm-cancel]');
    var current = null, previousOverflow = '';

    function open(button) {
      current = button;
      var kind = button.getAttribute('data-cr-confirm');
      dialog.setAttribute('data-kind', kind);
      dialog.querySelectorAll('[data-cr-icon]').forEach(function (icon) { icon.style.display = icon.getAttribute('data-cr-icon') === kind ? '' : 'none'; });
      title.textContent = button.getAttribute('data-cr-title');
      text.textContent = button.getAttribute('data-cr-text');
      go.textContent = button.getAttribute('data-cr-go');
      points.innerHTML = '';
      (button.getAttribute('data-cr-points') || '').split('|').forEach(function (line) {
        if (!line) return;
        var li = document.createElement('li');
        li.textContent = line;
        points.appendChild(li);
      });
      var field = document.querySelector('.crx-decision-form textarea');
      var typed = field ? field.value.trim() : '';
      note.hidden = !typed;
      noteText.textContent = typed;
      previousOverflow = document.body.style.overflow;
      document.body.style.overflow = 'hidden';
      dialog.classList.remove('is-leaving');
      dialog.hidden = false;
      document.addEventListener('keydown', onKey);
      setTimeout(function () { cancel.focus({ preventScroll: true }); }, reduced ? 0 : 60);
    }
    function close(confirmed) {
      var button = current;
      document.removeEventListener('keydown', onKey);
      dialog.classList.add('is-leaving');
      setTimeout(function () {
        dialog.hidden = true;
        dialog.classList.remove('is-leaving');
        document.body.style.overflow = previousOverflow;
        if (!button) return;
        if (confirmed) { button.setAttribute('data-cr-confirmed', '1'); button.click(); }
        else button.focus({ preventScroll: true });
      }, reduced ? 0 : 180);
      current = null;
    }
    function onKey(event) {
      if (event.key === 'Escape') { event.preventDefault(); close(false); return; }
      if (event.key !== 'Tab') return;
      // Keep focus inside the two buttons while the pop-up is open.
      var first = cancel, last = go;
      if (event.shiftKey && document.activeElement === first) { event.preventDefault(); last.focus(); }
      else if (!event.shiftKey && document.activeElement === last) { event.preventDefault(); first.focus(); }
    }
    go.addEventListener('click', function () { close(true); });
    cancel.addEventListener('click', function () { close(false); });
    dialog.addEventListener('click', function (event) { if (event.target === dialog) close(false); });

    window.UimsCrConfirm = function (button) {
      if (button.getAttribute('data-cr-confirmed') === '1') { button.removeAttribute('data-cr-confirmed'); return true; }
      open(button);
      return false;
    };
  }

  function init() {
    document.querySelectorAll('[data-cr-queue]').forEach(initQueue);
    initStamp();
    initConfirm();
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init); else init();
}());
