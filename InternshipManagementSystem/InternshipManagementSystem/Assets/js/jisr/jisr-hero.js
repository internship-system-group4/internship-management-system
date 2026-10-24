import * as THREE from '../vendor/three.module.min.js';
import { WORLD } from './jisr-common.js';
import { createSky, timeOfDay } from './jisr-sky.js';
import { createLand } from './jisr-land.js';
import { createCampus } from './jisr-campus.js?v=20261024-grounding';
import { createLife } from './jisr-life.js';
import { createPost } from './jisr-post.js';
import { createStudent } from './jisr-student.js?v=20261024-grounding';
import { createStorkFlight, FLOCK_SECONDS, FILL } from './jisr-storks.js';

// Part 1 - the aerial opening (scroll 0 .. CUT). Unchanged: these shots, copy beats and pacing
// are the approved opening. p = scroll position of each key; el = sun elevation in degrees.
const SHOTS = [
 { p: 0, pos: [-470, 58, 40], target: [40, 22, 18], fov: 30, el: 2.4 },   // dawn: the campus against the sunrise
 { p: .2, pos: [-300, 84, 240], target: [0, 14, 10], fov: 33, el: 4 },    // swing south over the olive groves
 { p: .4, pos: [-118, 46, 92], target: [-10, 26, -18], fov: 38, el: 5.6 },  // approach the west wing crown
 { p: .52, pos: [-58, 36, 16], target: [8, 28, -46], fov: 44, el: 6.6 },    // skim between the steel pergolas
 { p: .66, pos: [-6, 17, 12], target: [-10, 6, -28], fov: 46, el: 8 },      // (descent continues into the courtyard)
 { p: .8, pos: [20, 8.5, 22], target: [-6, 5, -18], fov: 44, el: 9.2 },
 { p: 1, pos: [8, 62, 100], target: [-150, 22, -320], fov: 40, el: 12 }
];

// Part 2 - the student (CUT .. 1). The opening keeps its original scroll length (620 screen
// heights x CUT); the new story gets its own length so it is not rushed.
const CUT = .63, OPEN_SPAN_VH = 620, STORY_SPAN_VH = 760;
const FOLLOW_IN = [.63, .70];      // aerial -> over the shoulder
const ARRIVE = .86, LOOK_UP = [.862, .885], FLOCK = [.875, .995];

// The school reveals. Each is introduced thematically; the campus is an artistic interpretation,
// so no building is claimed as a school's real location.
const REVEALS = [
 { at: [4, 21], anchor: [46, 20, -12], aim: [46, 13, -12], key: 'computing' },       // look right: the east tower
 { at: [3.7, 6], anchor: [-46, 27, -6], aim: [-46, 15, -6], key: 'architecture' },     // look left and up: the pergola crown
 { at: [-28, -62], anchor: [-52, 2, -77], aim: [-52, 1, -77], key: 'sustainable' }     // look left: the solar field
];

export async function mountJisr(host) {
 const stage = host.querySelector('[data-jisr-stage]'), canvas = host.querySelector('canvas');
 const reduced = matchMedia('(prefers-reduced-motion: reduce)').matches;
 const report = text => { const el = host.querySelector('[data-jisr-status]'); if (el) el.textContent = text; };

 let renderer;
 try { renderer = new THREE.WebGLRenderer({ canvas, antialias: false, powerPreference: 'high-performance', stencil: false }); }
 catch (_) { host.classList.add('jisr--static'); return null; }
 host.classList.remove('jisr--static');
 renderer.outputColorSpace = THREE.SRGBColorSpace; renderer.toneMapping = THREE.NoToneMapping;
 renderer.shadowMap.enabled = true; renderer.shadowMap.type = THREE.PCFSoftShadowMap;
 const mobile = matchMedia('(max-width: 760px)').matches || navigator.hardwareConcurrency <= 4;
 // Quality tier: integrated and mobile GPUs get 1x resolution, smaller shadows and lighter post.
 const glInfo = renderer.getContext().getExtension('WEBGL_debug_renderer_info');
 const gpu = glInfo ? renderer.getContext().getParameter(glInfo.UNMASKED_RENDERER_WEBGL) : '';
 const forcedQuality = new URLSearchParams(location.search).get('q');
 const low = forcedQuality ? forcedQuality === 'low' : mobile || /Intel|Mali|Adreno|PowerVR|SwiftShader|llvmpipe|Microsoft Basic/i.test(gpu);
 host.dataset.quality = low ? 'low' : 'high';
 renderer.shadowMap.type = low ? THREE.PCFShadowMap : THREE.PCFSoftShadowMap;

 const scene = new THREE.Scene();
 const camera = new THREE.PerspectiveCamera(32, 1, 1, 12000);
 const sky = createSky(); scene.add(sky.mesh);

 report('Shaping the land');
 await new Promise(r => setTimeout(r, 0));
 const land = createLand(); scene.add(land.root);
 report('Raising the campus');
 const campus = await createCampus({ logoUrl: host.dataset.logo, stoneUrl: host.dataset.stone, groundHeight: land.groundHeight }); scene.add(campus.root);
 report('Bringing it to life');
 const life = createLife(land.groundHeight); scene.add(life.root);
 let student = null;
 try { student = await createStudent(host.dataset.student); scene.add(student.root); } catch (error) { console.warn('Student model unavailable', error); }
 const flock = createStorkFlight(); scene.add(flock.mesh);

 const sun = new THREE.DirectionalLight('#ffffff', 3); sun.castShadow = true;
 sun.shadow.mapSize.setScalar(low ? 2048 : 4096); sun.shadow.bias = -.00025; sun.shadow.normalBias = .6; sun.shadow.radius = 3;
 Object.assign(sun.shadow.camera, { left: -170, right: 170, top: 170, bottom: -170, near: 10, far: 2400 });
 const hemi = new THREE.HemisphereLight('#ffffff', '#806a55', .7);
 scene.add(sun, sun.target, hemi);

 // Image-based lighting rendered from our own sky, refreshed as the sun climbs.
 const pmrem = new THREE.PMREMGenerator(renderer), envScene = new THREE.Scene(), envSky = createSky(); envScene.add(envSky.mesh);
 let envTarget = null, envElevation = -99;
 function refreshEnvironment(state) {
  if (Math.abs(state.elevation - envElevation) < .6) return;
  envElevation = state.elevation; envSky.apply(state, 0); envSky.uniforms.uStars.value = 0;
  const next = pmrem.fromScene(envScene, 0, 1, 20000); envTarget?.dispose(); envTarget = next; scene.environment = next.texture;
 }
 scene.environmentIntensity = .45;

 const post = createPost(renderer, { quality: low ? 'low' : 'high' });
 let dpr = Math.min(devicePixelRatio || 1, low ? 1 : 1.6);
 function resize() {
  const w = stage.clientWidth, h = stage.clientHeight;
  renderer.setPixelRatio(dpr); renderer.setSize(w, h, false); post.setSize(w, h, dpr);
  camera.aspect = w / h; camera.updateProjectionMatrix(); life.dust.material.uniforms.uPixel.value = dpr;
 }
 resize(); new ResizeObserver(resize).observe(stage);

 // Opening camera path (original).
 const posCurve = new THREE.CatmullRomCurve3(SHOTS.map(s => new THREE.Vector3(...s.pos)), false, 'centripetal');
 const tgtCurve = new THREE.CatmullRomCurve3(SHOTS.map(s => new THREE.Vector3(...s.target)), false, 'centripetal');
 const keyU = p => { let i = 0; while (i < SHOTS.length - 2 && SHOTS[i + 1].p <= p) i++; const a = SHOTS[i], b = SHOTS[i + 1], f = THREE.MathUtils.clamp((p - a.p) / (b.p - a.p), 0, 1); return { u: (i + f) / (SHOTS.length - 1), i, f }; };
 const lerpKey = (key, p) => { const { i, f } = keyU(p), s = f * f * (3 - 2 * f); return SHOTS[i][key] + (SHOTS[i + 1][key] - SHOTS[i][key]) * s; };
 const smooth = (x, a, b) => THREE.MathUtils.smoothstep(x, a, b), smoother = (x, a, b) => THREE.MathUtils.smootherstep(x, a, b);

 // Student schedule: distance along the walk for each scroll position, slowing to a stop at
 // every reveal so the head turn has time to land.
 const reveals = REVEALS.map(r => ({ ...r, dist: student ? student.distanceNear(r.at[0], r.at[1]) : 0, anchor: new THREE.Vector3(...r.anchor), aim: new THREE.Vector3(...r.aim), el: host.querySelector(`[data-reveal="${r.key}"]`), weight: 0 }));
 const L = student ? student.length : 1, [r1, r2, r3] = reveals.map(r => r.dist);
 const DIST_KEYS = [[CUT, 0], [.66, r1 - 7], [.675, r1 - 1.2], [.71, r1 + 1.2], [.735, r2 - 1.2], [.77, r2 + 1.2], [.80, r3 - 1.2], [.835, r3 + 1.2], [ARRIVE, L]];
 const distanceFor = p => { if (p <= DIST_KEYS[0][0]) return 0; for (let i = 1; i < DIST_KEYS.length; i++) { const [p1, d1] = DIST_KEYS[i], [p0, d0] = DIST_KEYS[i - 1]; if (p <= p1) return d0 + (d1 - d0) * (p - p0) / (p1 - p0); } return L; };

 // Scroll -> story progress. The opening maps exactly as before; the story uses the rest.
 const params = new URLSearchParams(location.search), forced = params.has('p') ? parseFloat(params.get('p')) : null;
 let target = forced ?? 0, progress = target;
 const vh = () => innerHeight / 100;
 const toProgress = px => { const open = CUT * OPEN_SPAN_VH * vh(), span = Math.max(1, host.offsetHeight - innerHeight); return px <= open ? px / (OPEN_SPAN_VH * vh()) : CUT + (1 - CUT) * THREE.MathUtils.clamp((px - open) / Math.max(1, span - open), 0, 1); };
 const toPixels = p => { const open = CUT * OPEN_SPAN_VH * vh(), span = host.offsetHeight - innerHeight; return p <= CUT ? p * OPEN_SPAN_VH * vh() : open + (p - CUT) / (1 - CUT) * (span - open); };
 const beats = [...host.querySelectorAll('[data-beat]')].map(el => { const [a, b] = el.dataset.beat.split(' ').map(Number); return { el, a, b }; });
 const climax = host.querySelector('[data-climax]');
 const rail = [...host.querySelectorAll('[data-jisr-rail] [data-at]')];
 function readScroll() { if (forced === null) target = toProgress(THREE.MathUtils.clamp(-host.getBoundingClientRect().top, 0, host.offsetHeight)); }
 if (window.gsap && window.ScrollTrigger && forced === null) {
  window.gsap.registerPlugin(window.ScrollTrigger);
  window.ScrollTrigger.create({ trigger: host, start: 'top top', end: 'bottom bottom', onUpdate: self => { target = toProgress(self.progress * (host.offsetHeight - innerHeight)); } });
 } else addEventListener('scroll', readScroll, { passive: true });
 readScroll();
 for (const a of rail) a.addEventListener('click', e => { e.preventDefault(); scrollTo({ top: host.offsetTop + toPixels(parseFloat(a.dataset.at)), behavior: reduced ? 'auto' : 'smooth' }); });

 const pointer = new THREE.Vector2(), pointerSmooth = new THREE.Vector2();
 addEventListener('pointermove', e => pointer.set(e.clientX / innerWidth * 2 - 1, e.clientY / innerHeight * 2 - 1), { passive: true });

 let paused = reduced, visible = true;
 const toggle = host.querySelector('[data-jisr-motion]');
 if (toggle) toggle.addEventListener('click', () => { paused = !paused; toggle.setAttribute('aria-pressed', String(paused)); toggle.textContent = paused ? 'Play scene motion' : 'Pause scene motion'; });
 new IntersectionObserver(entries => { visible = entries[0].isIntersecting; }).observe(stage);

 const camPos = new THREE.Vector3(), camTgt = new THREE.Vector3(), focus = new THREE.Vector3(), right = new THREE.Vector3();
 const followPos = new THREE.Vector3(), followTgt = new THREE.Vector3(), smoothPos = new THREE.Vector3(), smoothTgt = new THREE.Vector3();
 const headPos = new THREE.Vector3(), fwd = new THREE.Vector3(), side = new THREE.Vector3(), up = new THREE.Vector3(0, 1, 0), tmp = new THREE.Vector3(), skyGaze = new THREE.Vector3();
 const projected = new THREE.Vector3(), closeCentre = new THREE.Vector3();
 let clock = 12, last = performance.now(), frameAvg = 16, frames = 0, first = true, followReady = false, flockTime = 0, stageSet = false, simulateOnly = false;

 function frame(now) {
  requestAnimationFrame(frame);
  const elapsed = Math.min(.5, (now - last) / 1000); last = now;
  if (!visible || document.hidden) return;
  step(Math.min(.05, elapsed), elapsed);
 }

 // Over-the-shoulder pose from the student's position, heading, gaze and the look-up.
 function studentCamera(dt, lookUp, gazeAnchor, gazeWeight) {
  const s = student.state;
  student.headPosition(headPos);
  fwd.set(Math.sin(s.heading), 0, Math.cos(s.heading));
  side.set(-Math.cos(s.heading), 0, Math.sin(s.heading)); // the student's right
  // Over the right shoulder; while he looks aside the camera moves behind the opposite shoulder.
  const shoulder = THREE.MathUtils.lerp(1, Math.sign(s.yaw || 1), Math.min(1, Math.abs(s.yaw) * 1.6));
  const orbit = s.yaw * .42;
  tmp.copy(fwd).multiplyScalar(-THREE.MathUtils.lerp(2.9, 2.0, lookUp)).addScaledVector(side, .62 * shoulder).applyAxisAngle(up, orbit);
  followPos.copy(headPos).add(tmp); followPos.y = headPos.y + THREE.MathUtils.lerp(.3, -.38, lookUp);
  followTgt.copy(headPos).addScaledVector(fwd, 9).addScaledVector(up, -.55);
  if (gazeAnchor && gazeWeight > 0) followTgt.lerp(gazeAnchor, gazeWeight * .78);
  if (lookUp > 0) {
   // Gaze up toward the north-west sky, where the flock comes from.
   skyGaze.set(-.55, 0, -.83).normalize().multiplyScalar(30).add(headPos); skyGaze.y += 22 + 6 * smooth(flockTime, 10, 14);
   // Follow the closest birds as they sweep overhead, never tipping past the vertical.
   const track = smooth(flockTime, 9.6, 11.2) * (1 - smooth(flockTime, 13.1, 14)) * .75;
   if (track > 0) { flock.closeCentre(flockTime, closeCentre); if (closeCentre.y > headPos.y + 3 && closeCentre.distanceTo(headPos) < 90) skyGaze.lerp(closeCentre, track); }
   followTgt.lerp(skyGaze, lookUp);
  }
  const k = followReady ? 1 - Math.exp(-dt * 3.4) : 1;
  smoothPos.lerp(followPos, k); smoothTgt.lerp(followTgt, k); followReady = true;
 }

 function step(dt, elapsed = dt) {
  if (!paused) clock += dt;
  progress += (target - progress) * (1 - Math.exp(-elapsed * (reduced ? 30 : 3.2)));
  const p = progress;

  // Time of day and light (the opening keeps its keys; the story warms slowly toward morning).
  const el = p <= .7 ? lerpKey('el', p) : THREE.MathUtils.lerp(lerpKey('el', .7), 10.5, (p - .7) / .3);
  const state = timeOfDay(el);
  WORLD.uTime.value = clock; WORLD.uSunDir.value.copy(state.sunDir); WORLD.uSunColor.value.copy(state.sun).multiplyScalar(state.sunI / 3); WORLD.uLights.value = state.lights;
  sky.apply(state, clock); refreshEnvironment(state);
  FILL.value.copy(state.hemiSky).multiplyScalar(state.hemiI * .6);
  sun.color.copy(state.sun); sun.intensity = state.sunI; hemi.color.copy(state.hemiSky); hemi.groundColor.copy(state.hemiGround); hemi.intensity = state.hemiI;
  post.composite.uniforms.uWarmth.value = 1 - smooth(state.elevation, 4, 14);
  post.uniforms.uMist.value = .5 * (1 - smooth(state.elevation, 1, 10)) + .1;
  post.composite.uniforms.uExposure.value = .82 + (1 - smooth(state.elevation, 0, 6)) * .18;
  land.updateLights(state.lights);

  // Opening camera (original path).
  const { u } = keyU(Math.min(p, FOLLOW_IN[1]));
  posCurve.getPoint(u, camPos); tgtCurve.getPoint(u, camTgt);
  let fov = lerpKey('fov', Math.min(p, FOLLOW_IN[1]));

  // Story: the student, the reveals, the look-up and the flock.
  const blend = student ? smoother(p, FOLLOW_IN[0], FOLLOW_IN[1]) : 0;
  let gazeAnchor = null, gazeAim = null, gazeWeight = 0, lookUp = 0;
  if (student) {
   const d = student.state.dist;
   for (const r of reveals) {
    const w = smooth(d, r.dist - 6, r.dist - 1.6) * (1 - smooth(d, r.dist + 2.2, r.dist + 6.5));
    r.weight += (w - r.weight) * (1 - Math.exp(-elapsed * 4));
    if (r.weight > gazeWeight) { gazeWeight = r.weight; gazeAnchor = r.anchor; gazeAim = r.aim; }
   }
   const arrived = d > L - .6 ? 1 : 0;
   lookUp = smooth(p, LOOK_UP[0], LOOK_UP[1]) * arrived;
   const gazeTarget = lookUp > .01 ? skyGaze : gazeAnchor;
   if (!paused || p > CUT) student.update(p > CUT ? dt || .016 : 0, distanceFor(p), { target: gazeTarget, weight: Math.max(gazeWeight, lookUp) }, campus.surfaceHeight);
   student.root.visible = p > CUT - .02;
   if (blend > 0) {
    studentCamera(dt || .016, lookUp, gazeAim, gazeWeight);
    camPos.lerp(smoothPos, blend); camTgt.lerp(smoothTgt, blend);
    fov = THREE.MathUtils.lerp(fov, THREE.MathUtils.lerp(50, 58, lookUp), blend);
   } else followReady = false;

   // Flock time follows scroll but never faster than ~1.6x real time, and keeps drifting
   // gently while the reader lingers, so the birds never freeze mid-air.
   const flockTarget = smooth(p, FLOCK[0], FLOCK[1]) * FLOCK_SECONDS * arrived;
   const diff = flockTarget - flockTime;
   flockTime += THREE.MathUtils.clamp(diff, -elapsed * 6, elapsed * 1.6) + (diff > -1.2 && flockTarget > 0 && flockTime < FLOCK_SECONDS ? elapsed * .12 : 0);
   flockTime = THREE.MathUtils.clamp(flockTime, 0, FLOCK_SECONDS + 1);
   if (!stageSet && lookUp > 0) { flock.setStage(smoothPos, new THREE.Vector3(.55, 0, .83)); stageSet = true; }
   if (lookUp === 0 && flockTime < .01) stageSet = false;
   flock.update(flockTime, smooth(lookUp, 0, .3));
  }

  pointerSmooth.lerp(pointer, 1 - Math.exp(-dt * 2.5));
  const dist = camPos.distanceTo(camTgt), sway = reduced ? 0 : 1 - blend * .75;
  right.subVectors(camTgt, camPos).cross(camera.up).normalize();
  camPos.addScaledVector(right, pointerSmooth.x * Math.min(dist, 40) * .012 * sway); camPos.y -= pointerSmooth.y * Math.min(dist, 40) * .008 * sway;
  camPos.x += Math.sin(clock * .21) * .25 * sway; camPos.y += Math.sin(clock * .17) * .18 * sway; // handheld breath
  camera.position.copy(camPos); camera.lookAt(camTgt);
  camera.near = THREE.MathUtils.lerp(1, .25, blend);
  camera.fov = fov; camera.updateProjectionMatrix();
  sky.mesh.position.copy(camera.position);

  // Shadow frustum follows the area we are looking at; it tightens around the student for crisp close-ups.
  const box = THREE.MathUtils.lerp(170, 42, blend);
  if (sun.shadow.camera.right !== box) { Object.assign(sun.shadow.camera, { left: -box, right: box, top: box, bottom: -box }); sun.shadow.camera.updateProjectionMatrix(); }
  if (blend > .5 && student) focus.copy(student.root.position).addScaledVector(fwd, 10); else { focus.copy(camTgt).lerp(camPos, .35); focus.clampLength(0, 220); }
  focus.y = 0;
  const texel = box * 2 / sun.shadow.mapSize.x; focus.x = Math.round(focus.x / texel) * texel; focus.z = Math.round(focus.z / texel) * texel;
  sun.target.position.copy(focus); sun.position.copy(focus).addScaledVector(state.sunDir, 1100); sun.target.updateMatrixWorld();

  life.dust.material.uniforms.uAmount.value = smooth(p, .45, .62) * .9 + .1;
  if (!paused) { life.update(clock, dt, camera.position, blend); campus.update(clock, state.lights); }
  else campus.update(clock, state.lights);

  if (!simulateOnly) post.render(scene, camera, state, clock);

  // Copy: opening beats by scroll; reveal captions follow the gaze and sit beside the architecture.
  for (const b of beats) {
   const fadeIn = smooth(p, b.a - .01, b.a + .04), fadeOut = 1 - smooth(p, b.b - .04, b.b + .01), o = Math.min(fadeIn, fadeOut);
   b.el.style.opacity = o.toFixed(3); b.el.style.transform = `translate3d(0, ${((1 - fadeIn) * 16 - (1 - fadeOut) * 16).toFixed(1)}px, 0)`; b.el.style.visibility = o < .01 ? 'hidden' : 'visible';
  }
  const w = stage.clientWidth, h = stage.clientHeight;
  for (const r of reveals) {
   if (!r.el) continue;
   const o = smooth(r.weight, .55, .9) * blend;
   r.el.style.opacity = o.toFixed(3); r.el.style.visibility = o < .01 ? 'hidden' : 'visible';
   if (o > .01) {
    projected.copy(r.anchor).project(camera);
    const sx = (projected.x * .5 + .5) * w, sy = (1 - (projected.y * .5 + .5)) * h, cw = r.el.offsetWidth, ch = r.el.offsetHeight;
    const leftSide = sx > w * .5, x = THREE.MathUtils.clamp(leftSide ? sx - cw - 40 : sx + 40, 24, w - cw - 24), y = THREE.MathUtils.clamp(sy - ch * .5, 110, h - ch - 90);
    r.el.style.transform = `translate3d(${x.toFixed(0)}px, ${(y + (1 - o) * 10).toFixed(0)}px, 0)`;
   }
  }
  if (climax) { const o = smooth(flockTime, 8.6, 10.4) * smooth(p, FLOCK[0], FLOCK[0] + .02); climax.style.opacity = o.toFixed(3); climax.style.visibility = o < .01 ? 'hidden' : 'visible'; climax.style.transform = `translate3d(0, ${((1 - o) * 12).toFixed(1)}px, 0)`; }
  rail.forEach((a, i) => { const next = rail[i + 1] ? parseFloat(rail[i + 1].dataset.at) : 2; const on = p >= parseFloat(a.dataset.at) - .02 && p < next - .02; a.toggleAttribute('aria-current', on); });

  // Adaptive resolution.
  if (!simulateOnly) {
   frameAvg = frameAvg * .95 + (elapsed * 1000) * .05; frames++;
   if (frames > 90 && frameAvg > 26 && dpr > .8) { dpr = Math.max(.8, dpr - .15); resize(); frames = 0; }
  }
  if (first) { first = false; host.classList.add('jisr--ready'); report(''); }
  host.dataset.progress = p.toFixed(3);
 }
 requestAnimationFrame(frame);
 window.__jisr = {
  scene, camera, renderer, post, student, flock, reveals,
  setProgress: v => { target = progress = v; },
  // Development aid: simulate time passing (lets the student walk and the flock fly in tests).
  advance: (seconds, fps = 30) => { simulateOnly = true; try { for (let i = 0; i < seconds * fps; i++) step(1 / fps); } finally { simulateOnly = false; } },
  renderOnce: () => step(0),
  // Development aid: render one frame and POST it to a local capture server.
  capture: (name, url = 'http://127.0.0.1:8097/') => new Promise(resolve => { step(0); canvas.toBlob(b => fetch(url + name, { method: 'POST', body: b }).then(() => resolve(name)), 'image/jpeg', .9); }),
  info: () => ({ gpu, quality: low ? 'low' : 'high', dpr, frameAvg, dist: student?.state.dist, length: L, flockTime })
 };
 return window.__jisr;
}

const host = document.querySelector('[data-jisr]');
if (host) mountJisr(host).catch(error => { console.error(error); host.classList.add('jisr--static'); });
