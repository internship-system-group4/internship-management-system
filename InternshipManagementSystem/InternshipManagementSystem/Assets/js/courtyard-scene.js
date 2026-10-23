import * as THREE from './vendor/three.module.min.js';
import { createCourtyardModel } from './courtyard-model.js';

export function mountCourtyard(viewport, toggle, status, fallback) {
    const host = viewport.closest('[data-courtyard]');
    const canvas = document.createElement('canvas'); canvas.setAttribute('aria-hidden', 'true');
    let renderer;
    try {
        renderer = new THREE.WebGLRenderer({ canvas, antialias: true, alpha: false, powerPreference: 'low-power' });
    } catch (_) { fallback(); return { dispose() {}, snapshot: () => ({ state: 'fallback' }) }; }
    renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 1.5));
    renderer.outputColorSpace = THREE.SRGBColorSpace; renderer.toneMapping = THREE.ACESFilmicToneMapping;
    renderer.toneMappingExposure = 1.05;
    renderer.shadowMap.enabled = true; renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    const scene = new THREE.Scene(); scene.background = new THREE.Color('#edf2f6');
    const camera = new THREE.PerspectiveCamera(38, 1, .1, 80);
    camera.position.set(10, 7.2, 14); camera.lookAt(-.3, 3, -.8);
    scene.add(new THREE.HemisphereLight('#e2eeff', '#9e8668', 1.4));
    const sun = new THREE.DirectionalLight('#fff0d8', 2.3); sun.position.set(7, 11, 8);
    sun.castShadow = true; sun.shadow.mapSize.set(1024, 1024);
    Object.assign(sun.shadow.camera, { left: -10, right: 10, top: 10, bottom: -10 });
    sun.shadow.normalBias = .04; scene.add(sun);
    const model = createCourtyardModel(); scene.add(model.root); viewport.append(canvas);
    const reduce = matchMedia('(prefers-reduced-motion: reduce)');
    let observedReduced = reduce.matches;
    let paused = observedReduced, visible = true, disposed = false, frame = 0, last = 0, draws = 0;
    let resizeObserver, intersectionObserver;
    function render() { if (!disposed) { renderer.render(scene, camera); draws++; } }
    function running() { return !disposed && !paused && visible && !document.hidden; }
    function tick(time) {
        // Also sample while drawing: some browsers/devtools coalesce media-change events.
        if (reduce.matches !== observedReduced) { onReduced(); return; }
        frame = 0; if (!running()) return;
        if (!last) last = time;
        // 30 fps cap; never catch up elapsed time after a hidden/offscreen interval.
        if (time - last >= 1000 / 30) {
            model.wheel.rotation.z -= Math.min((time - last) / 1000, .08) * .055;
            last = time; render();
        }
        frame = requestAnimationFrame(tick);
    }
    function sync() {
        if (reduce.matches !== observedReduced) {
            observedReduced = reduce.matches;
            if (observedReduced) paused = true;
        }
        cancelAnimationFrame(frame); frame = 0; last = 0;
        host.dataset.sceneState = disposed ? 'disposed' : (paused ? 'paused' : 'ready');
        toggle.textContent = (paused ? (typeof window.uimsT==='function'?window.uimsT:function(k){return k;})('ResumeWheelMotion') : (typeof window.uimsT==='function'?window.uimsT:function(k){return k;})('PauseWheelMotion'));
        toggle.setAttribute('aria-pressed', String(paused));
        if (running()) frame = requestAnimationFrame(tick);
    }
    function resize() {
        if (disposed) return;
        const width = Math.max(1, viewport.clientWidth), height = Math.max(1, viewport.clientHeight);
        // Limit the backing buffer as well as DPR for large displays.
        renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 1.5, 1200 / width, 1000 / height));
        renderer.setSize(width, height, false); camera.aspect = width / height;
        camera.zoom = Math.min(1, camera.aspect / 1.35);
        camera.updateProjectionMatrix(); render();
    }
    const onToggle = () => { paused = !paused; sync(); };
    const onReduced = () => { observedReduced = reduce.matches; if (observedReduced) paused = true; sync(); };
    const onVisibility = () => sync();
    const onLost = event => { event.preventDefault(); dispose(); fallback(); };
    toggle.addEventListener('click', onToggle); reduce.addEventListener('change', onReduced);
    document.addEventListener('visibilitychange', onVisibility); canvas.addEventListener('webglcontextlost', onLost);
    window.addEventListener('resize', resize);
    if ('ResizeObserver' in window) { resizeObserver = new ResizeObserver(resize); resizeObserver.observe(viewport); }
    if ('IntersectionObserver' in window) {
        intersectionObserver = new IntersectionObserver(entries => { visible = entries[0].isIntersecting; sync(); });
        intersectionObserver.observe(viewport);
    }
    function dispose() {
        if (disposed) return; disposed = true; cancelAnimationFrame(frame);
        resizeObserver?.disconnect(); intersectionObserver?.disconnect();
        toggle.removeEventListener('click', onToggle); reduce.removeEventListener('change', onReduced);
        document.removeEventListener('visibilitychange', onVisibility); window.removeEventListener('resize', resize);
        canvas.removeEventListener('webglcontextlost', onLost);
        const geometries = new Set(), materials = new Set(), textures = new Set();
        scene.traverse(o => { if (o.isInstancedMesh) o.dispose(); if (o.geometry) geometries.add(o.geometry); if (o.material) (Array.isArray(o.material) ? o.material : [o.material]).forEach(m => materials.add(m)); });
        materials.forEach(m => { Object.values(m).forEach(v => { if (v?.isTexture) textures.add(v); }); m.dispose(); });
        textures.forEach(t => t.dispose()); geometries.forEach(g => g.dispose());
        sun.shadow.dispose(); renderer.dispose(); renderer.forceContextLoss(); scene.clear(); canvas.remove();
        for (const part of model.parts.values()) part.clear();
        model.root.userData = {}; model.parts.clear();
        host.dataset.sceneState = 'disposed'; toggle.hidden = true;
    }
    resize(); toggle.hidden = false; status.textContent = 'GJU courtyard waterwheel · 3D reconstruction'; sync();
    return {
        dispose,
        snapshot: () => ({ state: host.dataset.sceneState, angle: model.wheel.rotation.z, draws, visible, hidden: document.hidden, reducedMotion: reduce.matches, running: running(), triangles: renderer.info.render.triangles, calls: renderer.info.render.calls, geometries: renderer.info.memory.geometries, textures: renderer.info.memory.textures, width: canvas.width, height: canvas.height, architecture: model.parts.get('arcade')?.matrixWorld.elements.slice() || null }),
        // Review hooks also support a future route lifecycle without global scene state.
        setCamera(position, target = [-.3, 3, -.8]) { camera.position.fromArray(position); camera.lookAt(...target); render(); },
        model
    };
}
