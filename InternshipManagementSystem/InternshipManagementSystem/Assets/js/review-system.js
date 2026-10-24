/* UIMS review system: staggered reveal, accurate meter fills and quiet number
   arrival for Student Progress and the Final Completion Review. Values always
   come from the server-rendered markup; this file only animates towards them. */
(function () {
  'use strict';
  var reduced = window.matchMedia && matchMedia('(prefers-reduced-motion: reduce)').matches;

  function revealAll(root) {
    var items = Array.prototype.slice.call(root.querySelectorAll('[data-rv-reveal]'));
    var startedAt = Date.now();
    items.forEach(function (el, i) {
      if (el.style.getPropertyValue('--rv-i')) return;
      el.style.setProperty('--rv-i', String(Math.min(i, 8)));
      el.setAttribute('data-rv-auto', '');
    });
    if (reduced || !('IntersectionObserver' in window)) { items.forEach(function (el) { el.classList.add('is-in'); }); return; }
    var observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) return;
        // Stagger only the first screen; sections reached by scrolling appear at once.
        if (Date.now() - startedAt > 900 && entry.target.hasAttribute('data-rv-auto')) entry.target.style.setProperty('--rv-i', '0');
        entry.target.classList.add('is-in');
        observer.unobserve(entry.target);
      });
    }, { rootMargin: '0px 0px -4% 0px', threshold: 0.02 });
    items.forEach(function (el) { observer.observe(el); });

    // Fallbacks so content is never left hidden: a cheap position check on
    // scroll (covers browsers that throttle observers), and a final timer.
    var pending = 0;
    function sweep() {
      pending = 0;
      var limit = window.innerHeight || document.documentElement.clientHeight;
      items.forEach(function (el) {
        if (el.classList.contains('is-in')) return;
        var rect = el.getBoundingClientRect();
        if (rect.top < limit && rect.bottom > 0) { el.style.setProperty('--rv-i', '0'); el.classList.add('is-in'); observer.unobserve(el); }
      });
    }
    window.addEventListener('scroll', function () { if (!pending) pending = setTimeout(sweep, 120); }, { passive: true });
    setTimeout(sweep, 1200);
    setTimeout(function () { items.forEach(function (el) { el.classList.add('is-in'); }); }, 4000);
  }

  /* Meters: <div class="rv-meter" data-rv-value="75" data-rv-pending><span></span></div>
     The bar starts at 0 and fills to the exact server value once visible. */
  function fillMeters(root) {
    var meters = Array.prototype.slice.call(root.querySelectorAll('.rv-meter[data-rv-value]'));
    function fill(meter) {
      var value = Math.max(0, Math.min(100, Number(meter.getAttribute('data-rv-value')) || 0));
      meter.style.setProperty('--rv-fill', String(value / 100));
      meter.removeAttribute('data-rv-pending');
    }
    if (reduced || !('IntersectionObserver' in window)) { meters.forEach(fill); return; }
    var observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) return;
        var meter = entry.target;
        observer.unobserve(meter);
        requestAnimationFrame(function () { requestAnimationFrame(function () { fill(meter); }); });
      });
    }, { threshold: 0.2 });
    meters.forEach(function (meter) { observer.observe(meter); });
  }

  /* Numbers with data-rv-count="120" count up once; the final text is always
     the server's exact value. */
  function countUp(root) {
    root.querySelectorAll('[data-rv-count]').forEach(function (el) {
      var target = Number(el.getAttribute('data-rv-count'));
      var finalText = el.textContent;
      if (reduced || document.hidden || !isFinite(target) || target <= 1 || target > 100000 || Math.floor(target) !== target) return;
      var start = null, duration = 700, done = false;
      function finish() { if (done) return; done = true; el.textContent = finalText; }
      function step(time) {
        if (done) return;
        if (start === null) start = time;
        var t = Math.min(1, (time - start) / duration), eased = 1 - Math.pow(1 - t, 3);
        if (t >= 1) { finish(); return; }
        el.textContent = String(Math.round(target * eased));
        requestAnimationFrame(step);
      }
      // Safety net: frames pause in background tabs, so the exact value is
      // restored on a timer whatever happens to the animation.
      setTimeout(finish, duration + 150);
      requestAnimationFrame(step);
    });
  }

  /* Print a PDF through a hidden frame, so the browser prints the document
     itself and never the dashboard around it. Falls back to a new tab. */
  var frame = null;
  function printPdf(url) {
    try {
      if (frame) frame.remove();
      frame = document.createElement("iframe");
      frame.setAttribute("aria-hidden", "true");
      frame.tabIndex = -1;
      frame.style.cssText = "position:fixed;right:0;bottom:0;width:1px;height:1px;border:0;opacity:0;pointer-events:none;";
      frame.onload = function () {
        setTimeout(function () {
          try { frame.contentWindow.focus(); frame.contentWindow.print(); }
          catch (e) { window.open(url, "_blank", "noopener"); }
        }, 250);
      };
      frame.src = url;
      document.body.appendChild(frame);
    } catch (e) {
      window.open(url, "_blank", "noopener");
    }
  }

  document.addEventListener("click", function (event) {
    var link = event.target.closest && event.target.closest("[data-rv-print]");
    if (!link || event.defaultPrevented || event.button !== 0 || event.ctrlKey || event.metaKey || event.shiftKey) return;
    event.preventDefault();
    printPdf(link.href);
  });

  function init() {
    document.querySelectorAll('.rv-scope').forEach(function (root) {
      if (root.dataset.rvReady) return;
      root.dataset.rvReady = 'true';
      revealAll(root);
      fillMeters(root);
      countUp(root);
    });
  }

  window.UimsReview = { init: init, reduced: reduced, printPdf: printPdf };
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init); else init();
}());
