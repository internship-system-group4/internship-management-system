/* Native disclosures remain usable without JavaScript. Motion never gates navigation. */
(function () {
    'use strict';
    var section = document.querySelector('[data-home-faq]');
    if (!section) return;
    var reduced = matchMedia('(prefers-reduced-motion: reduce)'), states = new Map(), observer;
    section.querySelectorAll('details').forEach(function (details) {
        var summary = details.querySelector('summary'), state = { expanded: details.open, animation: null };
        states.set(details, state);
        summary.addEventListener('click', function (event) {
            if (event.button > 0 || event.ctrlKey || event.metaKey || event.shiftKey || event.altKey) return;
            event.preventDefault();
            var start = details.getBoundingClientRect().height;
            if (state.animation) { state.animation.cancel(); state.animation = null; }
            state.expanded = !state.expanded;
            if (reduced.matches || !details.animate) { details.open = state.expanded; details.style.overflow = ''; return; }
            // Keep the real answer available while measuring; reverse from the current visible height.
            details.open = true;
            var border = getComputedStyle(details);
            var end = state.expanded ? details.getBoundingClientRect().height : summary.getBoundingClientRect().height + parseFloat(border.borderTopWidth) + parseFloat(border.borderBottomWidth);
            details.style.overflow = 'hidden';
            var animation = details.animate([{ height: start + 'px' }, { height: end + 'px' }], { duration: 300, easing: 'cubic-bezier(.16,1,.3,1)' });
            state.animation = animation;
            animation.finished.then(function () {
                if (state.animation !== animation) return;
                details.open = state.expanded; details.style.overflow = ''; state.animation = null;
            }).catch(function () {});
        });
    });
    function settle() {
        states.forEach(function (state, details) {
            if (state.animation) state.animation.cancel();
            state.animation = null; details.open = state.expanded; details.style.overflow = '';
        });
        if (observer) observer.disconnect();
        if (reduced.matches || !('IntersectionObserver' in window)) return;
        observer = new IntersectionObserver(function (entries) {
            if (!entries.some(function (entry) { return entry.isIntersecting; })) return;
            section.classList.add('is-in-view'); observer.disconnect();
        }, { threshold: .12 });
        observer.observe(section);
    }
    reduced.addEventListener('change', settle);
    window.addEventListener('resize', function () { if ([].some.call(section.querySelectorAll('details'), function (d) { return !!states.get(d).animation; })) settle(); }, { passive: true });
    settle();
}());

/* A duplicated visual track loops smoothly. Only the three original examples enter keyboard/AT navigation. */
(function () {
    'use strict';
    var viewport = document.querySelector('[data-preview-carousel]');
    if (!viewport || viewport.dataset.carouselReady || !viewport.animate) return;
    viewport.dataset.carouselReady = 'true';
    var originals = Array.from(viewport.children), section = viewport.closest('.home-discovery');
    if (!originals.length) return;
    var controls = section.querySelector('[data-preview-controls]'), button = controls.querySelector('[data-preview-pause]');
    var reduced = matchMedia('(prefers-reduced-motion: reduce)'), hoverable = matchMedia('(hover:hover)');
    var animation = null, track = null, group = null, duration = 1, lap = 0, resizeFrame = 0, lastWidth = 0;
    var manual = false, hovered = false, focused = false, visible = false;
    function sync() {
        var paused = manual || hovered || focused || !visible || document.hidden;
        if (animation) { if (paused) animation.pause(); else animation.play(); }
        button.setAttribute('aria-pressed', String(manual));
        button.querySelector('[data-preview-pause-text]').textContent = manual ? button.dataset.resumeLabel : button.dataset.pauseLabel;
        button.querySelector('[data-preview-pause-icon]').setAttribute('d', manual ? 'M8 5l11 7-11 7z' : 'M8 5v14M16 5v14');
    }
    function clone(card) {
        var copy = card.cloneNode(true);
        copy.classList.remove('is-peeked');
        copy.dataset.carouselClone = 'true'; copy.setAttribute('aria-hidden', 'true'); copy.removeAttribute('id');
        copy.querySelectorAll('[id]').forEach(function (el) { el.removeAttribute('id'); });
        copy.querySelectorAll('a,button,input,select,textarea,[tabindex]').forEach(function (el) { el.setAttribute('tabindex', '-1'); });
        return copy;
    }
    function showFocusedCard(card) {
        if (!animation || !card || card.dataset.carouselClone) return;
        viewport.scrollLeft = 0;
        var offset = Math.max(0, card.offsetLeft - Math.max(16, (viewport.clientWidth - card.offsetWidth) / 2));
        animation.currentTime = offset / lap * duration;
    }
    function build() {
        resizeFrame = 0;
        section.style.setProperty('--hd-page-width', document.documentElement.clientWidth + 'px');
        section.classList.add('is-opportunity-rail');
        var phase = animation ? (Number(animation.currentTime) % duration) / duration : 0;
        var active = document.activeElement;
        if (animation) animation.cancel(); animation = null;
        viewport.replaceChildren.apply(viewport, originals);
        viewport.classList.remove('is-marquee'); controls.hidden = true;
        if (reduced.matches) {
            if (active && originals.some(function (card) { return card.contains(active); })) active.focus({ preventScroll: true });
            lastWidth = viewport.clientWidth; return;
        }
        viewport.classList.add('is-marquee'); controls.hidden = false;
        track = document.createElement('div'); track.className = 'hd-carousel-track';
        group = document.createElement('div'); group.className = 'hd-carousel-group';
        originals.forEach(function (card) { group.appendChild(card); });
        track.appendChild(group); viewport.replaceChildren(track);
        var repeats = 0;
        while (group.getBoundingClientRect().width < viewport.clientWidth + originals[0].offsetWidth && repeats++ < 12) {
            originals.forEach(function (card) { group.appendChild(clone(card)); });
        }
        lap = group.getBoundingClientRect().width;
        var duplicate = group.cloneNode(true); duplicate.setAttribute('aria-hidden', 'true');
        duplicate.querySelectorAll('.hd-preview').forEach(function (card) { card.dataset.carouselClone = 'true'; card.setAttribute('aria-hidden', 'true'); });
        duplicate.querySelectorAll('a,button,[tabindex]').forEach(function (el) { el.setAttribute('tabindex', '-1'); });
        track.appendChild(duplicate);
        duration = lap / 30 * 1000;
        animation = track.animate([{ transform: 'translateX(0)' }, { transform: 'translateX(-' + lap + 'px)' }], { duration: duration, iterations: Infinity, easing: 'linear' });
        animation.currentTime = phase * duration; lastWidth = viewport.clientWidth;
        if (active && originals.some(function (card) { return card.contains(active); })) { active.focus({ preventScroll: true }); showFocusedCard(active.closest('.hd-preview')); }
        sync();
    }
    function rebuild() { if (!resizeFrame) resizeFrame = requestAnimationFrame(build); }
    button.addEventListener('click', function () {
        manual = !manual;
        if (!manual) viewport.querySelectorAll('.is-peeked').forEach(function (card) { card.classList.remove('is-peeked'); });
        sync();
    });
    viewport.addEventListener('pointerenter', function (event) { if (event.pointerType !== 'touch' && hoverable.matches) { hovered = true; sync(); } });
    viewport.addEventListener('pointerleave', function () { hovered = false; sync(); });
    viewport.addEventListener('pointerdown', function (event) {
        if (event.pointerType !== 'touch' || event.target.closest('a,button')) return;
        var card = event.target.closest('.hd-preview'); if (!card) return;
        viewport.querySelectorAll('.is-peeked').forEach(function (item) { item.classList.remove('is-peeked'); });
        card.classList.add('is-peeked'); manual = true; sync();
    });
    viewport.addEventListener('focusin', function (event) { focused = true; sync(); showFocusedCard(event.target.closest('.hd-preview')); });
    viewport.addEventListener('focusout', function () { queueMicrotask(function () { focused = viewport.contains(document.activeElement); sync(); }); });
    reduced.addEventListener('change', rebuild);
    window.addEventListener('resize', rebuild, { passive: true });
    document.addEventListener('visibilitychange', sync);
    if ('IntersectionObserver' in window) {
        var observer = new IntersectionObserver(function (entries) { visible = entries[0].isIntersecting; sync(); });
        observer.observe(viewport);
    } else visible = true;
    if ('ResizeObserver' in window) new ResizeObserver(function () { if (Math.abs(viewport.clientWidth - lastWidth) > 1) rebuild(); }).observe(viewport);
    if (document.fonts) document.fonts.ready.then(rebuild);
    build();
}());
