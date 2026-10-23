import * as THREE from '../vendor/three.module.min.js';
import { mergeGeometries } from '../vendor/addons/utils/BufferGeometryUtils.js';
import { WORLD, rng, canvas, patchMaterial } from './jisr-common.js';

// The climax: a migrating flock of white storks (Ciconia ciconia) crossing from the north-west
// (Europe) toward the south-east (Africa) over the student. Each bird is a detailed model whose
// wings bend at shoulder and wrist in the vertex shader; ~130 birds in nine groups.
const HALF_SPAN = .98, SHOULDER = .06, WRIST = .48;

// White coverts, black flight feathers, cut-out "fingers" at the wing tip.
function wingTexture() {
 const W = 512, H = 256, c = canvas(W, H), g = c.getContext('2d'), random = rng(31);
 g.clearRect(0, 0, W, H);
 // v = 0 leading edge (top), v = 1 trailing edge (bottom); u = 0 shoulder, u = 1 tip.
 g.fillStyle = '#f4f1ea'; g.fillRect(0, 0, W, H);
 for (let y = 18; y < H * .5; y += 14) { g.strokeStyle = 'rgba(160,150,135,.35)'; g.lineWidth = 1.2; g.beginPath(); for (let x = 0; x <= W; x += 16) g.lineTo(x, y + Math.sin(x * .2) * 2); g.stroke(); }
 // Black flight feathers on the rear half, and all of the outer hand.
 g.fillStyle = '#15130f'; g.beginPath(); g.moveTo(0, H * .52); for (let x = 0; x <= W; x += 8) g.lineTo(x, H * (.52 - .3 * Math.max(0, (x / W - .62) / .38))); g.lineTo(W, H); g.lineTo(0, H); g.fill();
 g.strokeStyle = 'rgba(90,86,80,.55)'; g.lineWidth = 1.4;
 for (let x = 6; x < W * .8; x += 11) { g.beginPath(); g.moveTo(x, H * .55); g.lineTo(x - 4, H); g.stroke(); }
 // Primary "fingers": slots of transparency at the tip.
 g.globalCompositeOperation = 'destination-out';
 for (let k = 0; k < 6; k++) { const x0 = W * (.825 + k * .029); g.beginPath(); g.moveTo(x0, H * (.08 + k * .025)); g.lineTo(x0 + 5, H); g.lineTo(x0 + 13, H); g.lineTo(x0 + 9, H * (.14 + k * .025)); g.fill(); }
 // Ragged trailing edge.
 for (let x = 0; x < W * .84; x += 9) { g.beginPath(); g.moveTo(x, H); g.lineTo(x + 4.5, H - 6 - random() * 6); g.lineTo(x + 9, H); g.fill(); }
 g.globalCompositeOperation = 'source-over';
 const t = new THREE.CanvasTexture(c); t.colorSpace = THREE.SRGBColorSpace; t.anisotropy = 8; return t;
}

function paint(geometry, hex, span = 0, side = 0, uv = [.08, .92]) {
 const g = geometry.index ? geometry.toNonIndexed() : geometry, n = g.attributes.position.count, c = new THREE.Color(hex);
 g.setAttribute('color', new THREE.Float32BufferAttribute(Array.from({ length: n * 3 }, (_, i) => [c.r, c.g, c.b][i % 3]), 3));
 g.setAttribute('aSpan', new THREE.Float32BufferAttribute(new Array(n).fill(span), 1));
 g.setAttribute('aSide', new THREE.Float32BufferAttribute(new Array(n).fill(side), 1));
 g.setAttribute('uv', new THREE.Float32BufferAttribute(Array.from({ length: n * 2 }, (_, i) => uv[i % 2]), 2));
 return g;
}

function wing(side) {
 const S = 16, C = 4, pos = [], uvs = [], spans = [], idx = [];
 for (let i = 0; i <= S; i++) {
  const s = i / S, x = side * (SHOULDER + s * HALF_SPAN);
  const lead = .1 + .04 * Math.sin(s * Math.PI * .9) - .08 * s * s;
  const chord = THREE.MathUtils.lerp(.52, .3, Math.pow(s, 1.3)) - (s > .82 ? .06 * (s - .82) / .18 : 0);
  for (let j = 0; j <= C; j++) {
   const v = j / C, z = lead - chord * v, y = -.012 * Math.sin(v * Math.PI) - .02 * s * s;
   pos.push(x, y, z); uvs.push(s, 1 - v); spans.push(Math.max(s, .0001));
  }
 }
 for (let i = 0; i < S; i++) for (let j = 0; j < C; j++) {
  const a = i * (C + 1) + j, b = a + C + 1;
  if (side > 0) idx.push(a, b, a + 1, b, b + 1, a + 1); else idx.push(a, a + 1, b, b, a + 1, b + 1);
 }
 const g = new THREE.BufferGeometry();
 g.setAttribute('position', new THREE.Float32BufferAttribute(pos, 3)); g.setAttribute('uv', new THREE.Float32BufferAttribute(uvs, 2)); g.setIndex(idx);
 g.computeVertexNormals();
 const n = g.toNonIndexed();
 const count = n.attributes.position.count;
 n.setAttribute('color', new THREE.Float32BufferAttribute(new Array(count * 3).fill(1), 3));
 const sp = [], sd = [];
 for (let k = 0; k < count; k++) { sp.push((Math.abs(n.attributes.position.getX(k)) - SHOULDER) / HALF_SPAN); sd.push(side); }
 n.setAttribute('aSpan', new THREE.Float32BufferAttribute(sp.map(v => Math.max(v, .0001)), 1)); n.setAttribute('aSide', new THREE.Float32BufferAttribute(sd, 1));
 return n;
}

export function storkGeometry() {
 const parts = [];
 const profile = [[0, -.46], [.035, -.43], [.075, -.3], [.112, -.1], [.12, .05], [.1, .22], [.06, .32], [0, .36]].map(([r, y]) => new THREE.Vector2(r, y));
 const body = new THREE.LatheGeometry(profile, 14).rotateX(Math.PI / 2).scale(.86, .74, .92);
 parts.push(paint(body, '#f2efe8'));
 parts.push(paint(new THREE.CylinderGeometry(.028, .05, .34, 10).rotateX(Math.PI / 2).translate(0, .035, .47), '#f2efe8'));
 parts.push(paint(new THREE.SphereGeometry(.046, 12, 8).scale(.85, .9, 1.25).translate(0, .055, .66), '#f2efe8'));
 parts.push(paint(new THREE.ConeGeometry(.019, .24, 8).rotateX(Math.PI / 2).translate(0, .045, .82), '#d8442a'));
 for (const x of [-.034, .034]) {
  parts.push(paint(new THREE.CylinderGeometry(.011, .013, .38, 6).rotateX(Math.PI / 2 + .05).translate(x, -.05, -.56), '#c9432c'));
  parts.push(paint(new THREE.SphereGeometry(.02, 6, 4).scale(1, .6, 1.6).translate(x, -.06, -.76), '#b63c28'));
 }
 parts.push(wing(1), wing(-1));
 return mergeGeometries(parts.map(p => { for (const k of Object.keys(p.attributes)) if (!['position', 'normal', 'uv', 'color', 'aSpan', 'aSide'].includes(k)) p.deleteAttribute(k); if (!p.attributes.normal) p.computeVertexNormals(); return p; }));
}

const FLAP_GLSL = /* glsl */`
 uniform float uTime; uniform float uFlap;
 attribute float aSpan; attribute float aSide; attribute vec4 aBird;
 vec2 rot2(vec2 v, float a) { float c = cos(a), s = sin(a); return vec2(v.x * c - v.y * s, v.x * s + v.y * c); }
 vec3 stroke(vec3 p, bool isNormal, out float bob) {
  float ph = uTime * aBird.y + aBird.x;
  float glide = smoothstep(0.5, 0.95, sin(uTime * 0.31 + aBird.z * 6.2831) * 0.5 + 0.5);
  float amp = mix(1.0, 0.05, glide) * uFlap;
  float f = sin(ph);
  float shoulder = (f * 0.7 + 0.06) * amp + glide * 0.09;
  float wrist = sin(ph - 0.9) * 0.5 * amp - glide * 0.06;
  bob = -f * amp * 0.035;
  if (aSpan <= 0.0) return p;
  float px = ${SHOULDER.toFixed(3)} * aSide, a = shoulder * aSide;
  vec2 v = isNormal ? rot2(p.xy, a) : rot2(p.xy - vec2(px, 0.0), a) + vec2(px, 0.0);
  p.xy = v;
  if (aSpan > ${WRIST.toFixed(2)}) {
   float b = wrist * aSide * smoothstep(${WRIST.toFixed(2)}, ${(WRIST + .12).toFixed(2)}, aSpan);
   vec2 w0 = rot2(vec2((${SHOULDER.toFixed(3)} + ${WRIST.toFixed(2)} * ${HALF_SPAN.toFixed(2)}) * aSide - px, 0.0), a) + vec2(px, 0.0);
   p.xy = isNormal ? rot2(p.xy, b) : rot2(p.xy - w0, b) + w0;
  }
  return p;
 }`;

// Soft light the underside of the wings receives from the bright morning sky.
export const FILL = { value: new THREE.Color(.32, .36, .42) };
function storkMaterial() {
 const material = new THREE.MeshStandardMaterial({ map: wingTexture(), vertexColors: true, roughness: .85, side: THREE.DoubleSide, alphaTest: .5 });
 return patchMaterial(material, {
  key: 'jisr-hero-storks', uniforms: { uTime: WORLD.uTime, uFlap: { value: 1 }, uFill: FILL },
  vertexHead: FLAP_GLSL,
  vertex: {
   beginnormal_vertex: '#include <beginnormal_vertex>\n float jBobN; objectNormal = stroke(objectNormal, true, jBobN);',
   begin_vertex: '#include <begin_vertex>\n float jBob; transformed = stroke(transformed, false, jBob); transformed.y += jBob;'
  },
  fragmentHead: 'uniform vec3 uFill;',
  fragment: { emissivemap_fragment: '#include <emissivemap_fragment>\n totalEmissiveRadiance += diffuseColor.rgb * uFill;' }
 });
}

// Groups: when they start (in flock seconds), how they fly past, and their formation.
const GROUPS = [
 { t: .6, n: 10, h: 105, lat: -80, kind: 'loose' },
 { t: 1.4, n: 14, h: 82, lat: 50, kind: 'skein' },
 { t: 2.4, n: 20, h: 62, lat: -28, kind: 'loose' },
 { t: 3.3, n: 16, h: 50, lat: 34, kind: 'skein' },
 { t: 4.2, n: 28, h: 40, lat: -8, kind: 'loose' },
 { t: 5.2, n: 22, h: 30, lat: 18, kind: 'skein' },
 { t: 6.1, n: 9, h: 8.5, lat: -1, kind: 'close' },
 { t: 6.8, n: 18, h: 19, lat: -15, kind: 'loose' },
 { t: 7.6, n: 16, h: 58, lat: 72, kind: 'loose' },
 { t: 8.2, n: 18, h: 26, lat: 6, kind: 'skein' }
];
export const FLOCK_SECONDS = 14;

export function createStorkFlight() {
 const random = rng(7071), birds = [];
 for (const g of GROUPS) {
  for (let i = 0; i < g.n; i++) {
   let off;
   if (g.kind === 'skein') { const k = Math.ceil(i / 2), s = i % 2 ? 1 : -1; off = [s * k * 2.6 + (random() - .5) * 1.2, (random() - .5) * 1.4, -k * 2.1 + (random() - .5) * 1.2]; }
   else if (g.kind === 'close') off = [(random() - .5) * 11, random() * 4.5, (random() - .5) * 14];
   else off = [(random() - .5) * 34, (random() - .5) * 10, (random() - .5) * 26];
   birds.push({ g, off, tc: g.t + 5.2 + (random() - .5) * .8 + (g.kind === 'close' ? i * .22 : 0), phase: random() * 6.28, rate: 11 + random() * 3, glide: random(), scale: .92 + random() * .18, wob: random() * 6.28 });
  }
 }
 const geometry = storkGeometry();
 geometry.setAttribute('aBird', new THREE.InstancedBufferAttribute(new Float32Array(birds.flatMap(b => [b.phase, b.rate, b.glide, 0])), 4));
 const mesh = new THREE.InstancedMesh(geometry, storkMaterial(), birds.length);
 mesh.name = 'migration-flock'; mesh.frustumCulled = false; mesh.castShadow = false; mesh.visible = false;

 const m = new THREE.Matrix4(), q = new THREE.Quaternion(), qb = new THREE.Quaternion(), pos = new THREE.Vector3(), scl = new THREE.Vector3();
 const look = new THREE.Matrix4(), up = new THREE.Vector3(0, 1, 0), ahead = new THREE.Vector3(), fwdAxis = new THREE.Vector3(0, 0, 1);
 const V = 13.5, E = .95, APPEAR = 10; // cruise speed near the camera, far-field acceleration, seconds before crossing
 let anchor = new THREE.Vector3(), travel = new THREE.Vector3(1, 0, 1).normalize(), side = new THREE.Vector3();

 function birdAt(b, t, out) {
  const dt = t - b.tc, along = V * dt - E * Math.pow(Math.max(0, -dt), 3);
  const w = Math.sin(t * .6 + b.wob);
  out.copy(anchor).addScaledVector(up, b.g.h + b.off[1] + w * .6).addScaledVector(side, b.g.lat + b.off[0] + Math.sin(t * .4 + b.wob) * 1.2).addScaledVector(travel, along + b.off[2]);
  return out;
 }
 return {
  mesh, count: birds.length,
  closeCentre(t, out) { const close = birds.filter(b => b.g.kind === 'close'); out.set(0, 0, 0); const p = new THREE.Vector3(); for (const b of close) out.add(birdAt(b, t, p)); return out.multiplyScalar(1 / Math.max(1, close.length)); },
  // anchor: the camera position during the climax; travel: horizontal flight direction (NW -> SE).
  setStage(cameraPosition, direction) { anchor.copy(cameraPosition); travel.copy(direction).setY(0).normalize(); side.crossVectors(up, travel).normalize(); },
  update(t, visibleWeight) {
   mesh.visible = visibleWeight > .001;
   if (!mesh.visible) return;
   birds.forEach((b, i) => {
    const appear = THREE.MathUtils.smoothstep(t, b.tc - APPEAR, b.tc - APPEAR + 1.5);
    birdAt(b, t, pos); birdAt(b, t + .05, ahead);
    look.lookAt(ahead, pos, up); q.setFromRotationMatrix(look);
    qb.setFromAxisAngle(fwdAxis, Math.sin(t * .5 + b.wob) * .12); q.multiply(qb);
    scl.setScalar(b.scale * appear * visibleWeight);
    mesh.setMatrixAt(i, m.compose(pos, q, scl));
   });
   mesh.instanceMatrix.needsUpdate = true;
  }
 };
}
