/* Native sticky scrolling drives one video frame; it never intercepts input or requests browser fullscreen. */
(function () {
    'use strict';
    var host = document.querySelector('[data-scroll-video]');
    if (!host || host.dataset.videoZoomReady) return;
    host.dataset.videoZoomReady = 'true';
    var runway = host.querySelector('[data-video-runway]'), stage = host.querySelector('[data-video-stage]');
    var frame = host.querySelector('[data-video-frame]'), video = host.querySelector('video');
    var hint = host.querySelector('[data-video-scroll-hint]'), navbar = document.querySelector('[data-public-navbar]');
    var reduced = matchMedia('(prefers-reduced-motion: reduce)'), enabled = false, raf = 0, needsMeasure = false;
    var top = 0, width = 0, height = 0, initialWidth = 0, initialHeight = 0, span = 1;
    function reset() {
        enabled = false; host.classList.remove('is-scroll-video'); hint.hidden = true;
        frame.style.removeProperty('--video-frame-width'); frame.style.removeProperty('--video-frame-height'); frame.style.removeProperty('--video-frame-radius');
        if (navbar) delete navbar.dataset.videoImmersive;
    }
    function update() {
        raf = 0;
        if (!enabled) return;
        if (needsMeasure) {
            needsMeasure = false;
            top = runway.getBoundingClientRect().top + window.scrollY;
            width = document.documentElement.clientWidth; height = stage.getBoundingClientRect().height;
            initialWidth = Math.min(1000, Math.max(1, width - (width <= 760 ? 32 : 48)), height * .72 * 16 / 9);
            initialHeight = initialWidth * 9 / 16; span = Math.max(1, height * .85);
        }
        var distance = window.scrollY - top, progress = Math.max(0, Math.min(1, distance / span));
        var eased = progress * progress * (3 - 2 * progress);
        frame.style.setProperty('--video-frame-width', (initialWidth + (width - initialWidth) * eased) + 'px');
        frame.style.setProperty('--video-frame-height', (initialHeight + (height - initialHeight) * eased) + 'px');
        frame.style.setProperty('--video-frame-radius', (24 * (1 - eased)) + 'px');
        if (navbar) {
            var immersive = progress >= .9 && distance <= height * 1.2;
            if (navbar.dataset.videoImmersive !== String(immersive)) navbar.dataset.videoImmersive = String(immersive);
        }
    }
    function schedule(measure) {
        needsMeasure = needsMeasure || measure;
        if (enabled && !raf) raf = requestAnimationFrame(update);
    }
    function configure() {
        if (reduced.matches || video.error || video.readyState < 1) { reset(); return; }
        enabled = true; host.classList.add('is-scroll-video'); hint.hidden = false; schedule(true);
    }
    window.addEventListener('scroll', function () { schedule(false); }, { passive: true });
    window.addEventListener('resize', function () { schedule(true); }, { passive: true });
    if (window.visualViewport) window.visualViewport.addEventListener('resize', function () { schedule(true); }, { passive: true });
    window.addEventListener('pageshow', configure);
    video.addEventListener('loadedmetadata', configure); video.addEventListener('error', reset);
    reduced.addEventListener('change', configure);
    if ('ResizeObserver' in window) {
        var observer = new ResizeObserver(function () { schedule(true); });
        observer.observe(document.getElementById('public-content') || host);
    }
    if (document.fonts) document.fonts.ready.then(function () { schedule(true); });
    configure();
}());
