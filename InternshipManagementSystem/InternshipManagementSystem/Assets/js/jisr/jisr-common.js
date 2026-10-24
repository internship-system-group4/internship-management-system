import * as THREE from '../vendor/three.module.min.js';

// Shared helpers for the Jisr world. Units are metres, +x is east, -z is north, y is up.

// One set of world uniforms shared by reference with every patched material.
export const WORLD = {
 uTime: { value: 0 }, uSunDir: { value: new THREE.Vector3(0, .1, -1) }, uSunColor: { value: new THREE.Color('#ffb070') },
 uLights: { value: 1 }, uWind: { value: 1 }
};

export function rng(seed) {
 let s = seed >>> 0;
 return () => { s = (Math.imul(s, 1664525) + 1013904223) >>> 0; return s / 4294967296; };
}

// Value noise + fbm, used on the CPU so trees, roads and people sit exactly on the ground.
function hash2(x, z) { let h = Math.imul(x | 0, 374761393) ^ Math.imul(z | 0, 668265263); h = Math.imul(h ^ (h >>> 13), 1274126177); return ((h ^ (h >>> 16)) >>> 0) / 4294967296; }
function smooth(t) { return t * t * (3 - 2 * t); }
export function noise2(x, z) {
 const xi = Math.floor(x), zi = Math.floor(z), xf = smooth(x - xi), zf = smooth(z - zi);
 const a = hash2(xi, zi), b = hash2(xi + 1, zi), c = hash2(xi, zi + 1), d = hash2(xi + 1, zi + 1);
 return a + (b - a) * xf + (c - a) * zf + (a - b - c + d) * xf * zf;
}
export function fbm(x, z, octaves = 5) {
 let sum = 0, amp = .5, f = 1;
 for (let i = 0; i < octaves; i++) { sum += noise2(x * f, z * f) * amp; f *= 2.03; amp *= .5; }
 return sum;
}

// The campus sits on a flat terrace; farmland rolls gently; the far ring rises into hills.
export const CAMPUS_RADIUS = 260;
export function terrainHeight(x, z) {
 const d = Math.hypot(x * .85, z);
 const flat = THREE.MathUtils.smoothstep(d, CAMPUS_RADIUS, CAMPUS_RADIUS + 260);
 const rolling = (fbm(x * .0016 + 7.3, z * .0016 - 2.1, 4) - .5) * 26;
 const far = THREE.MathUtils.smoothstep(d, 1600, 4200);
 // Lower toward the east so the sunrise clears the horizon; ridged detail for eroded limestone hills.
 const east = 1 - .7 * THREE.MathUtils.smoothstep(x / Math.max(d, 1), .1, .85);
 const ridge = 1 - Math.abs(fbm(x * .0011 + 1.3, z * .0011 + 4.4, 4) * 2 - 1);
 const hills = (Math.pow(fbm(x * .00045 + 3.7, z * .00045 + 9.2, 5), 1.6) * 330 + ridge * ridge * 70) * east;
 return flat * rolling + far * hills - .4;
}

// Field parcels are laid out on a slightly rotated grid; trees and the shader read the same table.
export const FIELD = { angle: .32, cellX: 118, cellZ: 84, cols: 72, rows: 96 };
export function fieldCoords(x, z) {
 const c = Math.cos(FIELD.angle), s = Math.sin(FIELD.angle);
 return { u: c * x - s * z, v: s * x + c * z };
}
export function fieldCell(x, z) {
 const { u, v } = fieldCoords(x, z);
 return { i: Math.floor(u / FIELD.cellX) + FIELD.cols / 2, j: Math.floor(v / FIELD.cellZ) + FIELD.rows / 2, fu: u / FIELD.cellX - Math.floor(u / FIELD.cellX), fv: v / FIELD.cellZ - Math.floor(v / FIELD.cellZ) };
}
// Kinds: 0 ploughed, 1 young wheat, 2 lush green, 3 dry stubble, 4 olive grove, 5 vegetable rows
export function buildFieldTable(seed = 4711) {
 const random = rng(seed), data = new Uint8Array(FIELD.cols * FIELD.rows * 4), kinds = new Uint8Array(FIELD.cols * FIELD.rows);
 for (let j = 0; j < FIELD.rows; j++) for (let i = 0; i < FIELD.cols; i++) {
  const r = random();
  let kind = r < .32 ? 0 : r < .4 ? 1 : r < .46 ? 2 : r < .7 ? 3 : r < .92 ? 4 : 5;
  const k = j * FIELD.cols + i; kinds[k] = kind;
  data[k * 4] = kind; data[k * 4 + 1] = Math.floor(random() * 255); data[k * 4 + 2] = random() < .5 ? 0 : 255; data[k * 4 + 3] = 255;
 }
 const texture = new THREE.DataTexture(data, FIELD.cols, FIELD.rows, THREE.RGBAFormat);
 texture.magFilter = texture.minFilter = THREE.NearestFilter; texture.needsUpdate = true;
 return { texture, kind: (i, j) => (i < 0 || j < 0 || i >= FIELD.cols || j >= FIELD.rows) ? 3 : kinds[j * FIELD.cols + i] };
}

// Atmosphere shared by the sky dome and the depth-based fog, so the horizon and distant land always agree.
export const ATMOSPHERE_GLSL = /* glsl */`
uniform vec3 uSunDir;
uniform vec3 uZenith;
uniform vec3 uHorizon;
uniform vec3 uSunGlow;
uniform vec3 uGround;
vec3 atmosphere(vec3 dir) {
 float y = dir.y;
 float up = clamp(y, 0.0, 1.0);
 vec3 sky = mix(uHorizon, uZenith, smoothstep(0.0, 1.0, pow(up, 0.32)));
 float mu = max(dot(dir, uSunDir), 0.0);
 // Forward scattering lobe: broad warm glow plus a tight halo round the disc.
 float glow = pow(mu, 10.0) * 0.5 + pow(mu, 64.0) * 0.9;
 float horizonBand = exp(-abs(y) * 9.0);
 sky += uSunGlow * glow * (0.55 + horizonBand);
 sky += uSunGlow * horizonBand * 0.18 * pow(mu * 0.5 + 0.5, 3.0);
 vec3 below = mix(uHorizon, uGround, clamp(-y * 3.0, 0.0, 1.0));
 return y < 0.0 ? below + uSunGlow * glow * 0.4 : sky;
}
`;

export const NOISE_GLSL = /* glsl */`
float jHash(vec2 p) { p = fract(p * vec2(123.34, 456.21)); p += dot(p, p + 45.32); return fract(p.x * p.y); }
float jNoise(vec2 p) {
 vec2 i = floor(p), f = fract(p); vec2 u = f * f * (3.0 - 2.0 * f);
 return mix(mix(jHash(i), jHash(i + vec2(1.0, 0.0)), u.x), mix(jHash(i + vec2(0.0, 1.0)), jHash(i + vec2(1.0, 1.0)), u.x), u.y);
}
float jFbm3(vec2 p) { return jNoise(p) * 0.57 + jNoise(p * 2.03 + 17.1) * 0.29 + jNoise(p * 4.1 + 31.7) * 0.14; }
float jFbm(vec2 p) { float s = 0.0, a = 0.5; for (int i = 0; i < 5; i++) { s += jNoise(p) * a; p = p * 2.03 + 17.1; a *= 0.5; } return s; }
`;

// Ribbon along a polyline, draped on the terrain. u runs along the length in metres, v across 0..1.
export function ribbonGeometry(points, width, lift = .06, heightFn = terrainHeight) {
 const positions = [], uvs = [], indices = []; let length = 0;
 for (let i = 0; i < points.length; i++) {
  const p = points[i], prev = points[Math.max(0, i - 1)], next = points[Math.min(points.length - 1, i + 1)];
  const dx = next.x - prev.x, dz = next.z - prev.z, l = Math.hypot(dx, dz) || 1, nx = -dz / l, nz = dx / l;
  if (i > 0) length += Math.hypot(p.x - points[i - 1].x, p.z - points[i - 1].z);
  for (const side of [-1, 1]) {
   const x = p.x + nx * side * width / 2, z = p.z + nz * side * width / 2;
   positions.push(x, heightFn(x, z) + lift, z); uvs.push(length, side < 0 ? 0 : 1);
  }
  if (i > 0) { const a = (i - 1) * 2; indices.push(a, a + 2, a + 1, a + 1, a + 2, a + 3); }
 }
 const g = new THREE.BufferGeometry();
 g.setAttribute('position', new THREE.Float32BufferAttribute(positions, 3));
 g.setAttribute('uv', new THREE.Float32BufferAttribute(uvs, 2)); g.setIndex(indices); g.computeVertexNormals();
 return g;
}

// Evenly resample a polyline (closed or open) so movers travel at constant speed.
export function pathSampler(points, closed = false) {
 const pts = closed ? [...points, points[0]] : points, cumulative = [0];
 for (let i = 1; i < pts.length; i++) cumulative.push(cumulative[i - 1] + Math.hypot(pts[i].x - pts[i - 1].x, pts[i].z - pts[i - 1].z));
 const total = cumulative[cumulative.length - 1];
 return {
  total,
  at(distance, out = { x: 0, z: 0, heading: 0 }) {
   let d = closed ? ((distance % total) + total) % total : Math.min(Math.max(distance, 0), total), i = 1;
   while (i < cumulative.length - 1 && cumulative[i] < d) i++;
   const a = pts[i - 1], b = pts[i], t = (d - cumulative[i - 1]) / Math.max(1e-6, cumulative[i] - cumulative[i - 1]);
   out.x = a.x + (b.x - a.x) * t; out.z = a.z + (b.z - a.z) * t; out.heading = Math.atan2(b.x - a.x, b.z - a.z);
   return out;
  }
 };
}

export function canvas(w, h = w) { const c = document.createElement('canvas'); c.width = w; c.height = h; return c; }
export function canvasTexture(c, srgb = true, repeat = true) {
 const t = new THREE.CanvasTexture(c);
 if (srgb) t.colorSpace = THREE.SRGBColorSpace;
 if (repeat) t.wrapS = t.wrapT = THREE.RepeatWrapping;
 t.anisotropy = 8; return t;
}

// Inject GLSL into a built-in material while keeping its lighting and shadows.
export function patchMaterial(material, { uniforms = {}, vertexHead = '', vertex = {}, fragmentHead = '', fragment = {}, key }) {
 material.onBeforeCompile = shader => {
  Object.assign(shader.uniforms, uniforms);
  shader.vertexShader = vertexHead + '\n' + shader.vertexShader;
  for (const [chunk, code] of Object.entries(vertex)) shader.vertexShader = shader.vertexShader.replace(`#include <${chunk}>`, code);
  shader.fragmentShader = fragmentHead + '\n' + shader.fragmentShader;
  for (const [chunk, code] of Object.entries(fragment)) shader.fragmentShader = shader.fragmentShader.replace(`#include <${chunk}>`, code);
 };
 material.customProgramCacheKey = () => key;
 return material;
}
