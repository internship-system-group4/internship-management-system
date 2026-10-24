/* Shared task popups (see Assets/css/task-dialogs.css).
   - Any button with data-task-dialog="<popup id>" opens that popup.
   - After a postback the server sets data-open="true" on the popup to show
     (a result, or the form again with its error), and it opens on page load. */
(function () {
    'use strict';

    function show(target) {
        var popup = typeof target === 'string' ? document.getElementById(target) : target;
        if (!popup || !window.bootstrap || !window.bootstrap.Modal) return false;
        window.bootstrap.Modal.getOrCreateInstance(popup).show();
        return false;
    }

    function init() {
        // The page content plays an entrance animation, which would keep a popup
        // inside it under the dark backdrop. Move popups to the top of the form
        // (still inside it, so their fields and buttons post back as before).
        var form = document.forms[0];
        if (form) {
            document.querySelectorAll('.uims-task-dialog').forEach(function (popup) {
                if (popup.parentElement !== form) form.appendChild(popup);
            });
        }
        var opened = document.querySelector('.uims-task-dialog[data-open="true"]');
        if (opened) show(opened);
    }

    document.addEventListener('click', function (event) {
        var opener = event.target.closest ? event.target.closest('[data-task-dialog]') : null;
        if (!opener) return;
        event.preventDefault();
        show(opener.getAttribute('data-task-dialog'));
    });

    // The portal fades between pages (portal-motion.css view transitions). That fade
    // is drawn above everything, so skip it when a popup opens with the page.
    window.addEventListener('pagereveal', function (event) {
        if (event.viewTransition && document.querySelector('.uims-task-dialog[data-open="true"]'))
            event.viewTransition.skipTransition();
    });

    window.UimsTaskDialog = { show: show };
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
    else init();
}());
