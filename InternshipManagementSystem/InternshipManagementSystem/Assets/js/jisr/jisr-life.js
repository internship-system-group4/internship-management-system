import * as THREE from '../vendor/three.module.min.js';
import { mergeGeometries } from '../vendor/addons/utils/BufferGeometryUtils.js';
import { WORLD, rng, pathSampler, patchMaterial } from './jisr-common.js';
import { WALKS, ROADS, PARKING } from './jisr-layout.js';

// Tag every vertex of a part so one shader can colour and animate the merged figure.
function tagged(geometry, attrs) {
 const g = geometry.index ? geometry.toNonIndexed() : geometry; g.deleteAttribute('uv');
 for (const [name, value] of Object.entries(attrs)) g.setAttribute(name, new THREE.Float32BufferAttribute(new Array(g.attributes.position.count).fill(value), 1));
 return g;
}

// ---------- Students ----------
// Parts: 0 skin, 1 hair, 2 top, 3 trousers, 4 shoes, 5 backpack, 6 hijab. Limbs: 1/2 legs, 3/4 arms.
function personGeometry() {
 const P = [];
 const add = (g, part, limb = 0) => P.push(tagged(g, { aPart: part, aLimb: limb }));
 for (const [side, limb, arm] of [[-1, 1, 3], [1, 2, 4]]) {
  add(new THREE.CylinderGeometry(.078, .062, .86, 7).translate(side * .1, .47, 0), 3, limb);
  add(new THREE.BoxGeometry(.11, .08, .25).translate(side * .1, .04, .045), 4, limb);
  add(new THREE.CylinderGeometry(.062, .052, .34, 6).translate(side * .25, 1.28, 0), 2, arm);
  add(new THREE.CylinderGeometry(.052, .046, .3, 6).translate(side * .262, .98, .015), 2, arm);
  add(new THREE.SphereGeometry(.046, 6, 4).translate(side * .265, .8, .02), 0, arm);
 }
 add(new THREE.CylinderGeometry(.175, .165, .22, 8).translate(0, .96, 0), 3);
 add(new THREE.CylinderGeometry(.2, .172, .52, 9).scale(1, 1, .62).translate(0, 1.3, 0), 2);
 add(new THREE.SphereGeometry(.205, 9, 5).scale(1, .45, .64).translate(0, 1.52, 0), 2);
 add(new THREE.CylinderGeometry(.052, .058, .12, 6).translate(0, 1.6, 0), 0);
 add(new THREE.SphereGeometry(.104, 10, 8).scale(.92, 1.12, .98).translate(0, 1.72, .005), 0);
 add(new THREE.SphereGeometry(.112, 10, 6, 0, Math.PI * 2, 0, Math.PI * .55).scale(.95, 1.05, 1.02).translate(0, 1.735, -.012), 1);
 add(new THREE.SphereGeometry(.124, 10, 8).scale(.98, 1.12, 1.04).translate(0, 1.715, -.01), 6);
 add(new THREE.CylinderGeometry(.115, .23, .28, 10).scale(1, 1, .8).translate(0, 1.53, -.01), 6);
 add(new THREE.BoxGeometry(.3, .38, .16).translate(0, 1.28, -.18), 5);
 return mergeGeometries(P);
}

const SKIN = ['#8d5b3f', '#a8714f', '#c18a66', '#d6a283', '#7a4b33', '#b97f5c'];
const TOPS = ['#f1ede4', '#20334d', '#7d1f2a', '#3e5b47', '#c9b28c', '#2b2b2e', '#8aa4bf', '#d9d4c7', '#5c4a7a', '#b3542e', '#0f4c81', '#e8c46a'];
const BOTTOMS = ['#22262c', '#2f3c52', '#4a4136', '#1b1d22', '#5d6470', '#7b6a55'];

function createStudents(groundHeight) {
 const random = rng(77), walkers = [], samplers = WALKS.map(w => pathSampler(w, true));
 // Spread walkers in proportion to route length so short loops do not turn into queues.
 const totalLength = samplers.reduce((t, p) => t + p.total, 0);
 for (let i = 0; i < 120; i++) {
  let pick = random() * totalLength, k = 0; while (k < samplers.length - 1 && pick > samplers[k].total) { pick -= samplers[k].total; k++; }
  const path = samplers[k];
  walkers.push({ path, d: random() * path.total, speed: (1.05 + random() * .5) * (random() < .5 ? 1 : -1), lateral: (random() - .5) * 2.6, walk: 1, scale: .92 + random() * .13, phase: random() * 6.28 });
 }
 // Small standing groups chatting in the courtyard.
 for (const [cx, cz] of [[-8, 14], [12, 4], [-14, -12], [13, 28], [-40, 92], [30, 86], [52, -20]]) {
  const n = 2 + Math.floor(random() * 3);
  for (let k = 0; k < n; k++) { const a = k / n * Math.PI * 2 + random() * .4; walkers.push({ fixed: { x: cx + Math.cos(a) * .75, z: cz + Math.sin(a) * .75, heading: Math.atan2(-Math.cos(a), -Math.sin(a)) }, walk: 0, scale: .92 + random() * .13, phase: random() * 6.28 }); }
 }
 const count = walkers.length, geometry = personGeometry();
 const attr = (size, fn) => { const a = new Float32Array(count * size); walkers.forEach((w, i) => a.set(fn(w, i), i * size)); return new THREE.InstancedBufferAttribute(a, size); };
 const c = new THREE.Color(), pick = list => c.set(list[Math.floor(random() * list.length)]).toArray();
 geometry.setAttribute('aSkin', attr(3, () => pick(SKIN)));
 geometry.setAttribute('aTop', attr(3, () => pick(TOPS)));
 geometry.setAttribute('aBottom', attr(3, () => pick(BOTTOMS)));
 geometry.setAttribute('aScarf', attr(3, () => pick(['#e9dfd2', '#3a3f58', '#9a6b7a', '#d7c2a0', '#2f4d5c', '#c7a6a0', '#111418'])));
 geometry.setAttribute('aState', attr(4, w => [w.phase, w.walk, random() < .45 ? 1 : 0, random() < .5 ? 1 : 0]));
 // Near the camera during the student sequence, background walkers dissolve (dithered),
 // so only the detailed student is seen up close.
 const fade = new THREE.InstancedBufferAttribute(new Float32Array(count).fill(1), 1); fade.setUsage(THREE.DynamicDrawUsage); geometry.setAttribute('aFade', fade);
 const material = patchMaterial(new THREE.MeshStandardMaterial({ roughness: .85 }), {
  key: 'jisr-students', uniforms: { uTime: WORLD.uTime },
  vertexHead: /* glsl */`
   uniform float uTime; attribute float aPart; attribute float aLimb;
   attribute vec3 aSkin; attribute vec3 aTop; attribute vec3 aBottom; attribute vec3 aScarf; attribute vec4 aState; attribute float aFade;
   varying vec3 vJCol; varying float vFade;
   vec3 rotX(vec3 p, vec3 pivot, float a) { p -= pivot; float c = cos(a), s = sin(a); return vec3(p.x, p.y * c - p.z * s, p.y * s + p.z * c) + pivot; }`,
  vertex: {
   begin_vertex: /* glsl */`
    vec3 transformed = position; vFade = aFade;
    float walk = aState.y, ph = uTime * 5.6 + aState.x, swing = sin(ph) * 0.48 * walk;
    if (aLimb > 0.5 && aLimb < 2.5) transformed = rotX(transformed, vec3(0.0, 0.92, 0.0), aLimb < 1.5 ? swing : -swing);
    if (aLimb > 2.5) transformed = rotX(transformed, vec3(0.0, 1.45, 0.0), (aLimb < 3.5 ? -swing : swing) * 0.75);
    transformed.y += abs(cos(ph)) * 0.04 * walk;
    transformed.x += sin(uTime * 0.9 + aState.x) * 0.012 * (1.0 - walk) * transformed.y;
    float hijab = aState.z, bag = aState.w;
    if ((aPart > 0.5 && aPart < 1.5 && hijab > 0.5) || (aPart > 5.5 && hijab < 0.5) || (aPart > 4.5 && aPart < 5.5 && bag < 0.5)) transformed *= 0.0;
    vJCol = aPart < 0.5 ? aSkin : aPart < 1.5 ? vec3(0.025, 0.02, 0.016) : aPart < 2.5 ? aTop : aPart < 3.5 ? aBottom : aPart < 4.5 ? vec3(0.02) : aPart < 5.5 ? vec3(0.04, 0.05, 0.07) : aScarf;`
  },
  fragmentHead: 'varying vec3 vJCol; varying float vFade;',
  fragment: {
   clipping_planes_fragment: '#include <clipping_planes_fragment>\n if (vFade < 0.999 && vFade < fract(sin(dot(floor(gl_FragCoord.xy), vec2(12.9898, 78.233))) * 43758.5453)) discard;',
   color_fragment: '#include <color_fragment>\n diffuseColor.rgb *= vJCol;'
  }
 });
 const mesh = new THREE.InstancedMesh(geometry, material, count); mesh.name = 'students'; mesh.castShadow = true; mesh.receiveShadow = true; mesh.frustumCulled = false;
 const m = new THREE.Matrix4(), q = new THREE.Quaternion(), up = new THREE.Vector3(0, 1, 0), pos = new THREE.Vector3(), scl = new THREE.Vector3(), at = { x: 0, z: 0, heading: 0 };
 function update(dt, cameraPosition, nearFade = 0) {
  walkers.forEach((w, i) => {
   let x, z, heading;
   if (w.fixed) ({ x, z, heading } = w.fixed);
   else {
    w.d += w.speed * dt; w.path.at(w.d, at);
    heading = at.heading + (w.speed < 0 ? Math.PI : 0);
    x = at.x + Math.cos(at.heading) * w.lateral; z = at.z - Math.sin(at.heading) * w.lateral;
   }
   q.setFromAxisAngle(up, heading); pos.set(x, Math.max(.06, groundHeight(x, z)), z);
   const near = cameraPosition && nearFade > 0 ? 1 - THREE.MathUtils.smoothstep(Math.hypot(x - cameraPosition.x, z - cameraPosition.z), 9, 16) : 0;
   const f = 1 - nearFade * near;
   fade.setX(i, f); scl.setScalar(f < .02 ? 0 : w.scale); // fully dissolved walkers also drop their shadow
   mesh.setMatrixAt(i, m.compose(pos, q, scl));
  });
  mesh.instanceMatrix.needsUpdate = true; fade.needsUpdate = true;
 }
 update(0);
 return { mesh, update };
}

// ---------- Birds ----------
function birdGeometry({ span, body, stork }) {
 const parts = [];
 const add = (g, wing, color) => { const t = tagged(g, { aWing: wing }); const col = new THREE.Color(color), arr = []; for (let i = 0; i < t.attributes.position.count; i++) arr.push(col.r, col.g, col.b); t.setAttribute('color', new THREE.Float32BufferAttribute(arr, 3)); parts.push(t); };
 add(new THREE.SphereGeometry(body, 8, 6).scale(.7, .6, 2.1), 0, stork ? '#f4f1ea' : '#5c6066');
 if (stork) {
  add(new THREE.CylinderGeometry(.035, .05, .55, 5).rotateX(Math.PI / 2 - .2).translate(0, .06, .62), 0, '#f4f1ea');
  add(new THREE.ConeGeometry(.035, .28, 5).rotateX(Math.PI / 2).translate(0, .1, 1.02), 0, '#d0452b');
  for (const s of [-1, 1]) add(new THREE.CylinderGeometry(.014, .014, .75, 4).rotateX(Math.PI / 2).translate(s * .05, -.04, -.75), 0, '#c9452c');
 }
 // Each wing: inner (light) and outer (darker or black-tipped) panels, flexing by aWing.
 for (const s of [-1, 1]) {
  for (const [a, b, color] of [[0, .55, stork ? '#f6f3ec' : '#71767d'], [.55, 1, stork ? '#151515' : '#4c5056']]) {
   const g = new THREE.BufferGeometry(), x0 = s * (body * .5 + a * span / 2), x1 = s * (body * .5 + b * span / 2), chord = stork ? .55 : .17;
   const pos = [x0, 0, chord * .5, x1, 0, chord * .4 - b * .04, x1, 0, -chord * .5, x0, 0, chord * .5, x1, 0, -chord * .5, x0, 0, -chord * .6];
   g.setAttribute('position', new THREE.Float32BufferAttribute(pos, 3)); g.computeVertexNormals();
   const t = tagged(g, { aWing: 0 }), w = t.attributes.aWing; for (let i = 0; i < w.count; i++) w.setX(i, Math.abs(t.attributes.position.getX(i)) / (span / 2));
   const col = new THREE.Color(color), arr = []; for (let i = 0; i < t.attributes.position.count; i++) arr.push(col.r, col.g, col.b); t.setAttribute('color', new THREE.Float32BufferAttribute(arr, 3)); parts.push(t);
  }
 }
 return mergeGeometries(parts);
}

function flock({ count, span, body, stork, seed, center }) {
 const random = rng(seed), geometry = birdGeometry({ span, body, stork });
 const birds = Array.from({ length: count }, (_, i) => ({ p: random() * 6.28, a: .4 + random() * .5, b: .3 + random() * .4, r: (stork ? 22 : 9) + random() * (stork ? 50 : 16), h: (random() - .5) * (stork ? 30 : 8), rate: stork ? 3.6 + random() * .6 : 13 + random() * 4, i }));
 geometry.setAttribute('aBird', new THREE.InstancedBufferAttribute(new Float32Array(birds.flatMap(b => [b.p, b.rate])), 2));
 const material = patchMaterial(new THREE.MeshStandardMaterial({ vertexColors: true, roughness: .8, side: THREE.DoubleSide }), {
  key: stork ? 'jisr-storks' : 'jisr-birds', uniforms: { uTime: WORLD.uTime, uGlide: { value: stork ? 1 : 0 } },
  vertexHead: 'uniform float uTime; uniform float uGlide; attribute float aWing; attribute vec2 aBird;',
  vertex: {
   begin_vertex: /* glsl */`
    #include <begin_vertex>
    float flapOn = mix(1.0, smoothstep(0.25, 0.75, sin(uTime * 0.23 + aBird.x * 3.0) * 0.5 + 0.5), uGlide);
    float flap = sin(uTime * aBird.y + aBird.x) * flapOn + (1.0 - flapOn) * 0.12;
    transformed.y += flap * pow(aWing, 1.25) * ${(span * .38).toFixed(3)};
    transformed.y -= aWing * aWing * ${(span * .04).toFixed(3)} * flapOn;`
  }
 });
 const mesh = new THREE.InstancedMesh(geometry, material, count); mesh.castShadow = true; mesh.frustumCulled = false; mesh.name = stork ? 'white-storks' : 'pigeons';
 const m = new THREE.Matrix4(), p0 = new THREE.Vector3(), p1 = new THREE.Vector3(), q = new THREE.Quaternion(), look = new THREE.Matrix4(), up = new THREE.Vector3(0, 1, 0), scl = new THREE.Vector3(1, 1, 1), bankQ = new THREE.Quaternion(), fwd = new THREE.Vector3(0, 0, 1);
 const position = (b, t, out) => {
  const c = center(t);
  if (stork) { const ang = t * (.11 + b.a * .04) + b.p; return out.set(c.x + Math.cos(ang) * b.r, c.y + b.h + Math.sin(t * .2 + b.p) * 6 + ang * 0, c.z + Math.sin(ang) * b.r); }
  return out.set(c.x + Math.sin(t * b.a + b.p) * b.r + Math.sin(t * 1.7 + b.p) * 1.5, c.y + b.h + Math.sin(t * b.b * 2 + b.p) * 2.5, c.z + Math.cos(t * b.b + b.p * 1.3) * b.r);
 };
 function update(t) {
  for (const b of birds) {
   position(b, t, p0); position(b, t + .15, p1);
   const dir = p1.clone().sub(p0); const turn = dir.clone().normalize();
   look.lookAt(p1, p0, up); q.setFromRotationMatrix(look);
   // Bank into turns.
   const p2 = position(b, t + .3, new THREE.Vector3()); const curvature = new THREE.Vector3().subVectors(p2, p1).normalize().cross(turn).y;
   bankQ.setFromAxisAngle(fwd, THREE.MathUtils.clamp(curvature * 6, -.6, .6)); q.multiply(bankQ);
   mesh.setMatrixAt(b.i, m.compose(p0, q, scl));
  }
  mesh.instanceMatrix.needsUpdate = true;
 }
 return { mesh, update };
}

// ---------- Traffic ----------
function carGeometry() {
 const s = new THREE.Shape(); const pts = [[-2.25, .32], [2.25, .32], [2.28, .74], [1.95, .86], [1.05, .97], [.45, 1.42], [-1.15, 1.45], [-1.95, 1.02], [-2.26, .96]];
 s.moveTo(...pts[0]); pts.slice(1).forEach(p => s.lineTo(...p)); s.closePath();
 const body = new THREE.ExtrudeGeometry(s, { depth: 1.62, bevelEnabled: true, bevelThickness: .06, bevelSize: .06, bevelSegments: 2 });
 body.translate(0, 0, -.81); body.rotateY(-Math.PI / 2);
 const parts = [];
 const bodyNI = body.index ? body.toNonIndexed() : body, pos = bodyNI.attributes.position, part = [];
 for (let i = 0; i < pos.count; i++) part.push(pos.getY(i) > 1.0 && Math.abs(pos.getX(i)) < .84 ? 1 : 0);
 bodyNI.deleteAttribute('uv'); bodyNI.setAttribute('aPart', new THREE.Float32BufferAttribute(part, 1)); parts.push(bodyNI);
 for (const [x, z] of [[-.78, 1.4], [.78, 1.4], [-.78, -1.45], [.78, -1.45]]) parts.push(tagged(new THREE.CylinderGeometry(.33, .33, .24, 10).rotateZ(Math.PI / 2).translate(x, .33, z), { aPart: 2 }));
 for (const x of [-.6, .6]) { parts.push(tagged(new THREE.BoxGeometry(.32, .12, .05).translate(x, .76, 2.3), { aPart: 3 })); parts.push(tagged(new THREE.BoxGeometry(.32, .1, .05).translate(x, .8, -2.3), { aPart: 4 })); }
 return mergeGeometries(parts);
}
function busGeometry() {
 const parts = [];
 const body = tagged(new THREE.BoxGeometry(2.5, 2.7, 12).translate(0, 1.75, 0), { aPart: 0 }); parts.push(body);
 parts.push(tagged(new THREE.BoxGeometry(2.54, .9, 11.2).translate(0, 2.25, .1), { aPart: 1 }));
 for (const [x, z] of [[-1.05, 3.8], [1.05, 3.8], [-1.05, -3.8], [1.05, -3.8]]) parts.push(tagged(new THREE.CylinderGeometry(.5, .5, .3, 10).rotateZ(Math.PI / 2).translate(x, .5, z), { aPart: 2 }));
 for (const x of [-.8, .8]) { parts.push(tagged(new THREE.BoxGeometry(.4, .16, .05).translate(x, .8, 6.02), { aPart: 3 })); parts.push(tagged(new THREE.BoxGeometry(.3, .25, .05).translate(x, 1, -6.02), { aPart: 4 })); }
 return mergeGeometries(parts);
}
function vehicleMaterial(key) {
 return patchMaterial(new THREE.MeshStandardMaterial({ roughness: .3, metalness: .45, envMapIntensity: 1.3 }), {
  key, uniforms: { uLights: WORLD.uLights },
  vertexHead: 'attribute float aPart; varying float vPart;',
  vertex: { begin_vertex: '#include <begin_vertex>\n vPart = aPart;' },
  fragmentHead: 'uniform float uLights; varying float vPart;',
  fragment: {
   color_fragment: /* glsl */`
    #include <color_fragment>
    if (vPart > 0.5 && vPart < 1.5) diffuseColor.rgb = vec3(0.012, 0.016, 0.022);
    else if (vPart > 1.5 && vPart < 2.5) diffuseColor.rgb = vec3(0.015);
    else if (vPart > 2.5) diffuseColor.rgb = vec3(0.6);`,
   emissivemap_fragment: /* glsl */`
    #include <emissivemap_fragment>
    if (vPart > 2.5 && vPart < 3.5) totalEmissiveRadiance += vec3(1.0, 0.86, 0.62) * (0.4 + uLights * 14.0);
    if (vPart > 3.5) totalEmissiveRadiance += vec3(1.0, 0.05, 0.02) * (0.6 + uLights * 6.0);`,
   roughnessmap_fragment: '#include <roughnessmap_fragment>\n if (vPart > 0.5 && vPart < 1.5) roughnessFactor = 0.05; if (vPart > 1.5 && vPart < 2.5) roughnessFactor = 0.9;'
  }
 });
}
const PAINT = ['#f2f2ef', '#f2f2ef', '#c9ccd0', '#1c1e22', '#f3c31b', '#f3c31b', '#7a1d22', '#2b4a6b', '#8f9396', '#f3c31b'];

function createTraffic(groundHeight) {
 const random = rng(99), movers = [];
 const lane = (points, offset) => points.map((p, i) => {
  const a = points[Math.max(0, i - 1)], b = points[Math.min(points.length - 1, i + 1)], l = Math.hypot(b.x - a.x, b.z - a.z) || 1;
  return { x: p.x + (b.z - a.z) / l * offset * -1, z: p.z + (b.x - a.x) / l * offset };
 });
 const spineN = pathSampler(lane(ROADS.spine, 2.7)), spineS = pathSampler(lane([...ROADS.spine].reverse(), 2.7)), loop = pathSampler(lane(ROADS.loop, 2), true);
 for (let i = 0; i < 30; i++) movers.push({ path: spineN, d: i / 30 * spineN.total + random() * 60, speed: 15 + random() * 6, bus: i % 9 === 4 });
 for (let i = 0; i < 30; i++) movers.push({ path: spineS, d: i / 30 * spineS.total + random() * 60, speed: 15 + random() * 6, bus: i % 11 === 6 });
 for (let i = 0; i < 9; i++) movers.push({ path: loop, d: i / 9 * loop.total, speed: 6 + random() * 2.5, bus: i === 3 });
 for (let row = 0; row < 5; row++) for (let k = 0; k < 15; k++) if (random() < .62) {
  const x = PARKING.x - PARKING.w / 2 + 5 + k * 6.1, z = PARKING.z - PARKING.d / 2 + 6 + row * 11 + (random() < .5 ? -2.6 : 2.6);
  movers.push({ fixed: { x, z, heading: random() < .5 ? 0 : Math.PI }, bus: false });
 }
 const cars = movers.filter(m => !m.bus), buses = movers.filter(m => m.bus);
 const carMesh = new THREE.InstancedMesh(carGeometry(), vehicleMaterial('jisr-cars'), cars.length), busMesh = new THREE.InstancedMesh(busGeometry(), vehicleMaterial('jisr-bus'), buses.length);
 const c = new THREE.Color();
 cars.forEach((m, i) => carMesh.setColorAt(i, c.set(PAINT[Math.floor(random() * PAINT.length)])));
 buses.forEach((m, i) => busMesh.setColorAt(i, c.set(i % 2 ? '#f4f4f1' : '#e9e6dd')));
 for (const mesh of [carMesh, busMesh]) { mesh.castShadow = true; mesh.receiveShadow = true; mesh.frustumCulled = false; }
 carMesh.name = 'cars'; busMesh.name = 'buses';
 const m4 = new THREE.Matrix4(), q = new THREE.Quaternion(), up = new THREE.Vector3(0, 1, 0), pos = new THREE.Vector3(), one = new THREE.Vector3(1, 1, 1), at = { x: 0, z: 0, heading: 0 }, ahead = { x: 0, z: 0, heading: 0 };
 const place = (list, mesh, dt) => {
  list.forEach((v, i) => {
   let x, z, heading, pitch = 0;
   if (v.fixed) ({ x, z, heading } = v.fixed);
   else {
    v.d += v.speed * dt; if (!v.path.closed && v.d > v.path.total) v.d -= v.path.total;
    v.path.at(v.d % v.path.total, at); v.path.at((v.d % v.path.total) + 3, ahead); x = at.x; z = at.z; heading = at.heading;
    pitch = Math.atan2(groundHeight(ahead.x, ahead.z) - groundHeight(x, z), 3);
   }
   q.setFromAxisAngle(up, heading); q.multiply(new THREE.Quaternion().setFromAxisAngle(new THREE.Vector3(1, 0, 0), -pitch));
   pos.set(x, groundHeight(x, z) + .1, z); mesh.setMatrixAt(i, m4.compose(pos, q, one));
  });
  mesh.instanceMatrix.needsUpdate = true;
 };
 const group = new THREE.Group(); group.name = 'traffic'; group.add(carMesh, busMesh);
 const update = dt => { place(cars, carMesh, dt); place(buses, busMesh, dt); };
 update(0);
 return { group, update };
}

// ---------- Sunlit dust ----------
function createDust() {
 const count = 1400, random = rng(5), base = new Float32Array(count * 3), seeds = new Float32Array(count);
 for (let i = 0; i < count; i++) { base.set([random() * 60, random() * 30, random() * 60], i * 3); seeds[i] = random(); }
 const g = new THREE.BufferGeometry(); g.setAttribute('position', new THREE.BufferAttribute(base, 3)); g.setAttribute('aSeed', new THREE.BufferAttribute(seeds, 1));
 const material = new THREE.ShaderMaterial({
  transparent: true, depthWrite: false, blending: THREE.AdditiveBlending,
  uniforms: { uTime: WORLD.uTime, uSunDir: WORLD.uSunDir, uSunColor: WORLD.uSunColor, uPixel: { value: 1 }, uAmount: { value: 1 } },
  vertexShader: /* glsl */`
   uniform float uTime; uniform float uPixel; attribute float aSeed; varying float vA; varying vec3 vView;
   void main() {
    vec3 drift = vec3(sin(uTime * 0.13 + aSeed * 40.0) * 2.0 + uTime * 0.35, uTime * 0.08 + sin(uTime * 0.2 + aSeed * 9.0), cos(uTime * 0.11 + aSeed * 30.0) * 2.0);
    vec3 box = vec3(60.0, 30.0, 60.0);
    vec3 p = mod(position + drift - cameraPosition + box * 0.5, box) - box * 0.5 + cameraPosition;
    vec4 mv = viewMatrix * vec4(p, 1.0);
    gl_Position = projectionMatrix * mv;
    float d = -mv.z;
    gl_PointSize = clamp((0.05 + aSeed * 0.05) * uPixel * 900.0 / d, 0.0, 9.0 * uPixel);
    vA = smoothstep(1.0, 4.0, d) * (1.0 - smoothstep(18.0, 30.0, d));
    vView = normalize(p - cameraPosition);
   }`,
  fragmentShader: /* glsl */`
   uniform vec3 uSunDir; uniform vec3 uSunColor; uniform float uAmount; varying float vA; varying vec3 vView;
   void main() {
    float r = length(gl_PointCoord - 0.5); if (r > 0.5) discard;
    float forward = 0.15 + pow(max(dot(vView, uSunDir), 0.0), 6.0) * 2.2;
    gl_FragColor = vec4(uSunColor * forward * (1.0 - r * 2.0) * vA * 0.9 * uAmount, 1.0);
   }`
 });
 const points = new THREE.Points(g, material); points.frustumCulled = false; points.name = 'sunlit-dust';
 return { points, material };
}

export function createLife(groundHeight) {
 const root = new THREE.Group(); root.name = 'life';
 const students = createStudents(groundHeight);
 const pigeons = flock({ count: 46, span: .66, body: .09, stork: false, seed: 3, center: t => ({ x: Math.cos(t * .045) * 70 - 10, y: 46 + Math.sin(t * .13) * 8, z: Math.sin(t * .06) * 60 - 10 }) });
 const sparrows = flock({ count: 30, span: .5, body: .07, stork: false, seed: 8, center: t => ({ x: -150 + Math.sin(t * .07) * 60, y: 22 + Math.sin(t * .3) * 4, z: 40 + Math.cos(t * .05) * 80 }) });
 const storks = flock({ count: 14, span: 2.0, body: .2, stork: true, seed: 14, center: t => ({ x: -140 + Math.sin(t * .01) * 60, y: 135, z: -60 + Math.cos(t * .013) * 40 }) });
 const traffic = createTraffic(groundHeight);
 const dust = createDust();
 root.add(students.mesh, pigeons.mesh, sparrows.mesh, storks.mesh, traffic.group, dust.points);
 return {
  root, dust,
  update(t, dt, cameraPosition, nearFade) { students.update(dt, cameraPosition, nearFade); pigeons.update(t); sparrows.update(t); storks.update(t); traffic.update(dt); }
 };
}
