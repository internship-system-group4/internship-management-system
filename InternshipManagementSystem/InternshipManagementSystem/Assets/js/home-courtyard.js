// The photo and all page content work without this progressive enhancement.
(() => {
    'use strict';
    const host = document.querySelector('[data-courtyard]');
    if (!host) return;
    const viewport = host.querySelector('[data-courtyard-viewport]');
    const button = host.querySelector('[data-courtyard-toggle]');
    const status = host.querySelector('[data-courtyard-status]');
    let disposed = false, started = false, instance, observer;
    let idleId, idleTimer;
    const fallback = () => {
        host.dataset.sceneState = 'fallback'; button.hidden = true;
        status.textContent = 'Courtyard reference photograph';
    };
    async function load() {
        if (started || disposed) return;
        started = true;
        try {
            const module = await import('./courtyard-scene.js?v=20261023-i18n');
            if (disposed) return;
            instance = module.mountCourtyard(viewport, button, status, fallback);
            host.courtyardScene = instance;
        } catch (_) { fallback(); }
    }
    function schedule() {
        if ('requestIdleCallback' in window) idleId = requestIdleCallback(load, { timeout: 1500 });
        else idleTimer = setTimeout(load, 100);
    }
    if ('IntersectionObserver' in window) {
        observer = new IntersectionObserver(entries => {
            if (entries.some(e => e.isIntersecting)) { observer.disconnect(); schedule(); }
        }, { rootMargin: '120px' }); observer.observe(host);
    } else schedule();
    function dispose() {
        if (disposed) return;
        disposed = true; observer?.disconnect(); clearTimeout(idleTimer);
        if (idleId !== undefined) cancelIdleCallback(idleId);
        instance?.dispose();
    }
    window.addEventListener('pagehide', event => { if (!event.persisted) dispose(); });
})();
