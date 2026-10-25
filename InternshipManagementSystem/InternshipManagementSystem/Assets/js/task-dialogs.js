/* Task dialogs work without a CDN and keep their controls inside the Web Forms form. */
(function () {
    'use strict';
    var active = null;
    var returnFocus = null;
    function close() {
        if (!active) return;
        active.classList.remove('is-open');
        active.setAttribute('aria-hidden', 'true');
        document.body.classList.remove('task-dialog-lock');
        active = null;
        if (returnFocus && document.contains(returnFocus)) returnFocus.focus();
    }
    function show(target) {
        var popup = typeof target === 'string' ? document.getElementById(target) : target;
        if (!popup) return false;
        if (active && active !== popup) close();
        returnFocus = document.activeElement;
        active = popup;
        popup.classList.add('is-open');
        popup.setAttribute('aria-hidden', 'false');
        document.body.classList.add('task-dialog-lock');
        var focusTarget = popup.querySelector('.btn-close, [data-task-dialog-close], input, textarea, button');
        if (focusTarget) focusTarget.focus();
        return false;
    }
    function init() {
        var form = document.forms[0];
        if (form) document.querySelectorAll('.uims-task-dialog').forEach(function (popup) {
            if (popup.parentElement !== form) form.appendChild(popup);
        });
        var opened = document.querySelector('.uims-task-dialog[data-open="true"]');
        if (opened) show(opened);
    }
    document.addEventListener('click', function (event) {
        var opener = event.target.closest ? event.target.closest('[data-task-dialog]') : null;
        if (opener) { event.preventDefault(); show(opener.getAttribute('data-task-dialog')); return; }
        var dismiss = event.target.closest ? event.target.closest('[data-task-dialog-close], [data-bs-dismiss="modal"]') : null;
        if (dismiss && active && active.contains(dismiss)) {
            event.preventDefault(); event.stopPropagation(); close();
        } else if (active && event.target === active) close();
    }, true);
    document.addEventListener('keydown', function (event) {
        if (!active) return;
        if (event.key === 'Escape') { event.preventDefault(); close(); return; }
        if (event.key !== 'Tab') return;
        var focusable = Array.prototype.slice.call(active.querySelectorAll('button:not([disabled]), input:not([disabled]), textarea:not([disabled]), a[href], [tabindex]:not([tabindex="-1"])'));
        if (!focusable.length) return;
        if (event.shiftKey && document.activeElement === focusable[0]) { event.preventDefault(); focusable[focusable.length - 1].focus(); }
        else if (!event.shiftKey && document.activeElement === focusable[focusable.length - 1]) { event.preventDefault(); focusable[0].focus(); }
    });
    window.addEventListener('pagereveal', function (event) {
        if (event.viewTransition && document.querySelector('.uims-task-dialog[data-open="true"]')) event.viewTransition.skipTransition();
    });
    window.UimsTaskDialog = { show: show, close: close };
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
    else init();
}());
