/* One panel, two responsive states; storage contains only the desktop pin preference. */
(function () {
    'use strict';
    if (window.UimsPortalNavigation) { window.UimsPortalNavigation.init(); return; }
    var activePanel = null;
    function init() {
        var sidebar = document.querySelector('[data-portal-sidebar]');
        if (!sidebar || (activePanel && activePanel.element === sidebar)) return;
        if (activePanel) activePanel.dispose();
        var toggle = document.querySelector('.student-nav-toggle');
        var close = sidebar.querySelector('.student-nav-close');
        var pin = sidebar.querySelector('.uims-sidebar-pin');
        var backdrop = document.querySelector('.student-nav-backdrop');
        var content = document.querySelector('.uims-content');
        if (!toggle || !close || !pin || !backdrop || !content) return;
        var media = window.matchMedia('(max-width: 900px)');
        var controller = new AbortController();
        var opened = false, hovered = false, pinned = false;
        try { pinned = localStorage.getItem('uims.sidebar.pinned') !== 'false'; } catch (_) { /* Storage may be unavailable. */ }
        function on(target, name, handler) { target.addEventListener(name, handler, { signal: controller.signal }); }
        function desktop() {
            var expanded = !media.matches && (pinned || hovered || sidebar.contains(document.activeElement));
            sidebar.dataset.expanded = String(expanded);
            pin.setAttribute('aria-expanded', String(expanded));
            pin.setAttribute('aria-pressed', String(pinned));
            pin.setAttribute('aria-label', pinned ? 'Unpin navigation' : 'Pin navigation open');
            pin.title = pinned ? 'Unpin navigation' : 'Pin navigation open';
            pin.querySelector('span').textContent = pinned ? 'Unpin navigation' : 'Pin navigation';
        }
        function mobile(value, restoreFocus) {
            opened = value && media.matches;
            if (!opened) {
                content.inert = false;
                content.removeAttribute('aria-hidden');
                if (restoreFocus && media.matches) toggle.focus();
            }
            document.body.classList.toggle('student-nav-open', opened);
            document.documentElement.classList.toggle('student-nav-open', opened);
            toggle.setAttribute('aria-expanded', String(opened));
            toggle.setAttribute('aria-label', opened ? 'Close navigation' : 'Open navigation');
            backdrop.hidden = !opened;
            sidebar.inert = media.matches && !opened;
            content.inert = opened;
            if (media.matches && !opened) sidebar.setAttribute('aria-hidden', 'true');
            else sidebar.removeAttribute('aria-hidden');
            if (opened) {
                sidebar.setAttribute('role', 'dialog');
                sidebar.setAttribute('aria-modal', 'true');
                close.focus();
                content.setAttribute('aria-hidden', 'true');
            } else {
                content.removeAttribute('aria-hidden');
                sidebar.removeAttribute('role');
                sidebar.removeAttribute('aria-modal');
            }
            desktop();
        }
        on(toggle, 'click', function () { mobile(!opened, true); });
        on(close, 'click', function () { mobile(false, true); });
        on(backdrop, 'click', function () { mobile(false, true); });
        on(pin, 'click', function () {
            pinned = !pinned;
            try { localStorage.setItem('uims.sidebar.pinned', String(pinned)); } catch (_) { /* UI state only. */ }
            desktop();
        });
        on(sidebar, 'pointerenter', function (event) { if (event.pointerType !== 'touch') { hovered = true; desktop(); } });
        on(sidebar, 'pointerleave', function () { hovered = false; desktop(); });
        on(sidebar, 'focusin', desktop);
        on(sidebar, 'focusout', function () { queueMicrotask(desktop); });
        on(sidebar, 'click', function (event) { if (opened && event.target.closest('a[href]')) mobile(false, true); });
        on(document, 'keydown', function (event) {
            if (!opened) return;
            if (event.key === 'Escape') { event.preventDefault(); mobile(false, true); }
            else if (event.key === 'Tab') {
                var targets = Array.from(sidebar.querySelectorAll('a[href],button:not([disabled]),[tabindex="0"]'))
                    .filter(function (element) { return element.getClientRects().length && getComputedStyle(element).visibility !== 'hidden'; });
                var first = targets[0], last = targets[targets.length - 1];
                if (!first) { event.preventDefault(); sidebar.focus(); return; }
                if (event.shiftKey && (document.activeElement === first || !sidebar.contains(document.activeElement))) { event.preventDefault(); last.focus(); }
                else if (!event.shiftKey && (document.activeElement === last || !sidebar.contains(document.activeElement))) { event.preventDefault(); first.focus(); }
            }
        });
        on(media, 'change', function () {
            hovered = false;
            var focusedInside = sidebar.contains(document.activeElement);
            if (media.matches && focusedInside) toggle.focus();
            mobile(false, false);
            if (!media.matches && (document.activeElement === close || document.activeElement === toggle)) pin.focus();
            desktop();
        });
        sidebar.querySelectorAll('.uims-sidebar-avatar img').forEach(function (image) {
            on(image, 'error', function () { image.hidden = true; });
            if (image.complete && !image.naturalWidth) image.hidden = true;
        });
        activePanel = { element: sidebar, dispose: function () { mobile(false, false); controller.abort(); } };
        pin.setAttribute('aria-controls', sidebar.id);
        document.documentElement.classList.add('student-nav-ready');
        mobile(false, false);
    }
    var hooked = false;
    function hookPartialRendering() {
        if (!hooked && window.Sys && window.Sys.Application) { window.Sys.Application.add_load(init); hooked = true; }
    }
    window.UimsPortalNavigation = { init: init };
    init(); hookPartialRendering();
    window.addEventListener('load', hookPartialRendering, { once: true });
}());
