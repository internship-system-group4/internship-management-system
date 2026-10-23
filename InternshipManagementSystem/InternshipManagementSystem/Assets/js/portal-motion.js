/* Progressive navigation feedback. Never intercept native links or postbacks. */
(function () {
    'use strict';
    if (window.UimsMotion) return;
    var reduce = window.matchMedia('(prefers-reduced-motion: reduce)');
    var pending = new Map(), serial = 0, revealObserver, activeAnimations = new Set();
    var counterFinishes = new Set(), revealed = new WeakSet();
    var line = document.createElement('div');
    line.className = 'portal-loading-line';
    line.setAttribute('aria-hidden', 'true');
    line.appendChild(document.createElement('span'));
    var message = document.createElement('div');
    message.className = 'portal-route-status';
    message.setAttribute('role', 'status');
    message.setAttribute('aria-live', 'polite');
    message.setAttribute('aria-atomic', 'true');
    document.body.append(line, message);
    var messageTimer, finishTimer, navigationTimer, navigationToken;

    function begin(label) {
        var token = ++serial;
        pending.set(token, label || 'Loading');
        clearTimeout(finishTimer);
        clearTimeout(messageTimer);
        line.classList.add('is-loading');
        messageTimer = setTimeout(function () {
            message.textContent = label || 'Loading';
            message.classList.add('is-visible');
        }, 500);
        return token;
    }
    function end(token) {
        pending.delete(token);
        if (pending.size) return;
        clearTimeout(messageTimer);
        message.classList.remove('is-visible');
        message.textContent = '';
        finishTimer = setTimeout(function () { line.classList.remove('is-loading'); }, 120);
    }
    function reset() {
        pending.clear();
        clearTimeout(messageTimer); clearTimeout(finishTimer); clearTimeout(navigationTimer);
        line.classList.remove('is-loading');
        message.classList.remove('is-visible'); message.textContent = '';
        document.querySelectorAll('[data-pending-navigation]').forEach(function (link) {
            link.removeAttribute('data-pending-navigation');
        });
    }
    function track(animation) {
        activeAnimations.add(animation);
        var done = function () { activeAnimations.delete(animation); };
        animation.finished.then(done, done);
        return animation;
    }
    function count(element, delay) {
        if (element.dataset.counted || reduce.matches) return;
        element.dataset.counted = 'true';
        var finalText = element.textContent.trim(), target = Number(finalText.replace(/,/g, ''));
        if (!/^\d[\d,]*$/.test(finalText) || target <= 0 || target > 1000000) return;
        // Assistive technology always receives the final, accurate number.
        var accessible = document.createElement('span'), visual = document.createElement('span');
        accessible.className = 'visually-hidden'; accessible.textContent = finalText;
        visual.setAttribute('aria-hidden', 'true'); visual.textContent = finalText;
        element.replaceChildren(accessible, visual);
        var start, frame, finished = false;
        function finish() {
            if (finished) return;
            finished = true; cancelAnimationFrame(frame);
            visual.textContent = finalText; counterFinishes.delete(finish);
        }
        counterFinishes.add(finish);
        function step(now) {
            if (!element.isConnected || reduce.matches) { finish(); return; }
            if (start === undefined) start = now + delay;
            if (now < start) { frame = requestAnimationFrame(step); return; }
            var fraction = Math.min(1, (now - start) / 700);
            var value = Math.round(target * (1 - Math.pow(1 - fraction, 3)));
            visual.textContent = value.toLocaleString('en-US');
            if (fraction < 1) frame = requestAnimationFrame(step);
            else finish();
        }
        frame = requestAnimationFrame(step);
    }
    function reveal(element, index) {
        if (revealed.has(element)) return;
        revealed.add(element);
        if (reduce.matches || typeof element.animate !== 'function') return;
        var delay = Math.min(index * 40, 200);
        track(element.animate([
            { opacity: 0, transform: 'translateY(14px)' },
            { opacity: 1, transform: 'translateY(0)' }
        ], { duration: 520, delay: delay, easing: 'cubic-bezier(.22,1,.36,1)', fill: 'backwards' }));
        var number = element.querySelector('.dashboard-stat-number');
        if (number) count(number, delay + 60);
    }
    function animateDashboard(scope) {
        if (revealObserver) revealObserver.disconnect();
        if (reduce.matches) return;
        var items = Array.from(scope.querySelectorAll(
            '.dashboard-stat,.dashboard-attention,.dashboard-panel,.dashboard-actions,.dashboard-review'));
        if ('IntersectionObserver' in window) {
            revealObserver = new IntersectionObserver(function (entries) {
                entries.forEach(function (entry) {
                    if (!entry.isIntersecting) return;
                    reveal(entry.target, Number(entry.target.dataset.motionOrder || 0));
                    revealObserver.unobserve(entry.target);
                });
            }, { threshold: 0.08 });
        }
        items.forEach(function (element, index) {
            element.dataset.motionOrder = String(index < 6 ? index : 0);
            var bounds = element.getBoundingClientRect();
            if (bounds.top < innerHeight && bounds.bottom > 0) reveal(element, index < 6 ? index : 0);
            else if (revealObserver) revealObserver.observe(element);
        });
    }
    reduce.addEventListener('change', function () {
        if (!reduce.matches) return;
        activeAnimations.forEach(function (animation) { animation.cancel(); });
        counterFinishes.forEach(function (finish) { finish(); });
        if (revealObserver) revealObserver.disconnect();
    });
    document.addEventListener('click', function (event) {
        if (event.defaultPrevented || event.button !== 0 || event.ctrlKey || event.metaKey ||
            event.shiftKey || event.altKey) return;
        var anchor = event.target.closest('a[href]');
        if (!anchor || anchor.hasAttribute('download') || anchor.hasAttribute('data-no-transition') ||
            anchor.getAttribute('aria-disabled') === 'true' ||
            (anchor.target && anchor.target !== '_self')) return;
        var url;
        try { url = new URL(anchor.href, location.href); } catch (_) { return; }
        if (url.origin !== location.origin || !/^https?:$/.test(url.protocol) ||
            /\.(pdf|xlsx?|zip|csv)$/i.test(url.pathname) ||
            (url.pathname === location.pathname && url.search === location.search)) return;
        setTimeout(function () {
            if (event.defaultPrevented) return;
            var label = (anchor.getAttribute('title') || anchor.textContent || 'page').trim().replace(/\s+/g, ' ').slice(0, 60);
            navigationToken = begin('Opening ' + label);
            anchor.setAttribute('data-pending-navigation', 'true');
            // Downloads, cancelled navigation and unreachable destinations must
            // never leave an inert overlay or a permanent busy indicator.
            navigationTimer = setTimeout(function () {
                end(navigationToken); anchor.removeAttribute('data-pending-navigation');
            }, 15000);
        }, 0);
    });
    window.addEventListener('pagehide', reset);
    window.addEventListener('pageshow', function (event) { if (event.persisted) reset(); });
    window.UimsMotion = { begin: begin, end: end, animateDashboard: animateDashboard };
}());
