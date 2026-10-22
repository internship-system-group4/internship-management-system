import * as THREE from './vendor/three.module.min.js';

// A single static computing symbol for the project's single configured college.
export function mountCollegeSymbol(host) {
    let renderer;
    try { renderer = new THREE.WebGLRenderer({ alpha: true, antialias: true, powerPreference: 'low-power' }); }
    catch (_) { return { dispose() {} }; }
    const canvas = renderer.domElement; canvas.setAttribute('aria-hidden', 'true'); canvas.style.visibility = 'hidden'; host.append(canvas);
    let shaderFailed = false; renderer.debug.onShaderError = () => { shaderFailed = true; };
    renderer.setPixelRatio(Math.min(devicePixelRatio || 1, 1.25));
    renderer.outputColorSpace = THREE.SRGBColorSpace;
    const scene = new THREE.Scene(), group = new THREE.Group(); scene.add(group);
    const camera = new THREE.OrthographicCamera(-2.2, 2.2, 2.2, -2.2, .1, 20); camera.position.set(4, 5, 6); camera.lookAt(0, 0, 0);
    const body = new THREE.MeshStandardMaterial({ color: '#264f73', roughness: .48, metalness: .25 });
    const silver = new THREE.MeshStandardMaterial({ color: '#bdccd6', roughness: .38, metalness: .7 });
    const chip = new THREE.Mesh(new THREE.BoxGeometry(2.1, .35, 2.1), body); group.add(chip);
    const die = new THREE.Mesh(new THREE.BoxGeometry(1.24, .08, 1.24), silver); die.position.y = .215; group.add(die);
    const pins = new THREE.InstancedMesh(new THREE.BoxGeometry(.15, .1, .42), silver, 24), transform = new THREE.Object3D();
    for (let edge = 0; edge < 4; edge++) for (let i = 0; i < 6; i++) {
        const t = -.78 + i * .31; transform.position.set(edge % 2 === 0 ? t : (edge === 1 ? 1.23 : -1.23), -.03, edge % 2 === 1 ? t : (edge === 0 ? 1.23 : -1.23));
        transform.rotation.y = edge % 2 ? Math.PI / 2 : 0; transform.updateMatrix(); pins.setMatrixAt(edge * 6 + i, transform.matrix);
    }
    group.add(pins); group.rotation.y = -.18;
    scene.add(new THREE.HemisphereLight('#ecf5ff', '#8b9ca8', 2));
    const light = new THREE.DirectionalLight('#ffffff', 3); light.position.set(-3, 5, 4); scene.add(light);
    let disposed = false, visible = true, dirty = true, draws = 0, observer, resizeObserver;
    function draw() {
        if (!disposed && visible && !document.hidden) {
            try { renderer.render(scene, camera); } catch (_) { dispose(); return; }
            if (shaderFailed) { dispose(); return; }
            canvas.style.visibility = 'visible'; dirty = false; draws++;
        }
    }
    function resize() { if (disposed) return; renderer.setSize(host.clientWidth, host.clientHeight, false); dirty = true; draw(); }
    function onVisibility() { if (dirty) draw(); }
    if ('IntersectionObserver' in window) { observer = new IntersectionObserver(e => { visible = e[0].isIntersecting; if (visible && dirty) draw(); }); observer.observe(host); }
    if ('ResizeObserver' in window) { resizeObserver = new ResizeObserver(resize); resizeObserver.observe(host); }
    function dispose() {
        if (disposed) return; disposed = true; observer?.disconnect(); resizeObserver?.disconnect(); document.removeEventListener('visibilitychange', onVisibility);
        host.removeEventListener('webglcontextlost', lost, true); pins.dispose(); chip.geometry.dispose(); die.geometry.dispose(); pins.geometry.dispose(); body.dispose(); silver.dispose(); renderer.dispose(); renderer.forceContextLoss(); canvas.remove();
    }
    const lost = event => { event.preventDefault(); dispose(); };
    host.addEventListener('webglcontextlost', lost, true); document.addEventListener('visibilitychange', onVisibility);
    resize();
    return { dispose, snapshot: () => ({ draws, disposed, visible }) };
}
