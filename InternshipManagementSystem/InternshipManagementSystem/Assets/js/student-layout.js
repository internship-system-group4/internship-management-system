/* Shared responsive navigation for Student.master. No Bootstrap dependency. */
(function () {
    'use strict';
    var sidebar = document.getElementById('studentSidebar');
    var toggle = document.querySelector('.student-nav-toggle');
    var close = document.querySelector('.student-nav-close');
    var backdrop = document.querySelector('.student-nav-backdrop');
    var content = document.querySelector('.uims-content');
    if (!sidebar || !toggle || !close || !backdrop || !content) return;
    var smallScreen = window.matchMedia('(max-width: 900px)');
    var opened = false;

    function setOpen(value, restoreFocus) {
        opened = value && smallScreen.matches;
        document.body.classList.toggle('student-nav-open', opened);
        toggle.setAttribute('aria-expanded', String(opened));
        toggle.setAttribute('aria-label', opened ? 'Close navigation' : 'Open navigation');
        backdrop.hidden = !opened;
        sidebar.inert = smallScreen.matches && !opened;
        content.inert = opened;
        if (opened) {
            sidebar.setAttribute('role', 'dialog');
            sidebar.setAttribute('aria-modal', 'true');
            close.focus();
            content.setAttribute('aria-hidden', 'true');
        } else {
            content.removeAttribute('aria-hidden');
            sidebar.removeAttribute('role');
            sidebar.removeAttribute('aria-modal');
            if (restoreFocus && smallScreen.matches) toggle.focus();
        }
    }

    toggle.addEventListener('click', function () { setOpen(!opened, true); });
    close.addEventListener('click', function () { setOpen(false, true); });
    backdrop.addEventListener('click', function () { setOpen(false, true); });
    sidebar.addEventListener('click', function (event) {
        if (event.target.closest('a')) setOpen(false, true);
    });
    document.addEventListener('keydown', function (event) {
        if (!opened) return;
        if (event.key === 'Escape') {
            event.preventDefault();
            setOpen(false, true);
        } else if (event.key === 'Tab') {
            var targets = sidebar.querySelectorAll('a[href], button:not([disabled])');
            var first = targets[0], last = targets[targets.length - 1];
            if (event.shiftKey && document.activeElement === first) {
                event.preventDefault(); last.focus();
            } else if (!event.shiftKey && document.activeElement === last) {
                event.preventDefault(); first.focus();
            }
        }
    });
    smallScreen.addEventListener('change', function () {
        var focusedInSidebar = sidebar.contains(document.activeElement);
        setOpen(false, focusedInSidebar);
    });
    setOpen(false, false);
    document.documentElement.classList.add('student-nav-ready');
}());
