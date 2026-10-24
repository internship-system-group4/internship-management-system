import * as THREE from '../vendor/three.module.min.js';
import { mergeGeometries, mergeVertices } from '../vendor/addons/utils/BufferGeometryUtils.js';
import { WORLD, rng, fbm, terrainHeight, FIELD, buildFieldTable, fieldCell, NOISE_GLSL, ribbonGeometry, canvas, canvasTexture, patchMaterial, CAMPUS_RADIUS } from './jisr-common.js';
import { ROADS, BUILDINGS, PARKING, HALL, COURTYARD, SOLAR_FIELD, CLIMAX_SPOT } from './jisr-layout.js';

const TERRAIN_SIZE = 12000, TERRAIN_SEGMENTS = 480;

// Terrain is built from our own grid so groundHeight() matches the rendered triangles exactly.
function createTerrain(fieldTable) {
 const n = TERRAIN_SEGMENTS, step = TERRAIN_SIZE / n, half = TERRAIN_SIZE / 2, heights = new Float32Array((n + 1) * (n + 1));
 const positions = new Float32Array((n + 1) * (n + 1) * 3), indices = [];
 for (let j = 0; j <= n; j++) for (let i = 0; i <= n; i++) {
  const x = -half + i * step, z = -half + j * step, k = j * (n + 1) + i, h = terrainHeight(x, z);
  heights[k] = h; positions.set([x, h, z], k * 3);
 }
 for (let j = 0; j < n; j++) for (let i = 0; i < n; i++) {
  const a = j * (n + 1) + i, b = a + 1, c = a + n + 1, d = c + 1;
  indices.push(a, c, b, b, c, d);
 }
 const geometry = new THREE.BufferGeometry();
 geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3)); geometry.setIndex(indices); geometry.computeVertexNormals();
 function groundHeight(x, z) {
  const fx = (x + half) / step, fz = (z + half) / step, i = Math.min(n - 1, Math.max(0, Math.floor(fx))), j = Math.min(n - 1, Math.max(0, Math.floor(fz)));
  const u = fx - i, v = fz - j, h00 = heights[j * (n + 1) + i], h10 = heights[j * (n + 1) + i + 1], h01 = heights[(j + 1) * (n + 1) + i], h11 = heights[(j + 1) * (n + 1) + i + 1];
  return u + v < 1 ? h00 + (h10 - h00) * u + (h01 - h00) * v : h11 + (h01 - h11) * (1 - u) + (h10 - h11) * (1 - v);
 }
 const material = patchMaterial(new THREE.MeshStandardMaterial({ color: '#ffffff', roughness: .97, metalness: 0 }), {
  key: 'jisr-terrain',
  uniforms: { uFieldTable: { value: fieldTable.texture }, uFieldGrid: { value: new THREE.Vector4(FIELD.cellX, FIELD.cellZ, FIELD.cols, FIELD.rows) }, uFieldAngle: { value: FIELD.angle }, uCampusR: { value: CAMPUS_RADIUS } },
  vertexHead: 'varying vec3 vJWorld;',
  vertex: { begin_vertex: '#include <begin_vertex>\n vJWorld = (modelMatrix * vec4(transformed, 1.0)).xyz;' },
  fragmentHead: `varying vec3 vJWorld; uniform sampler2D uFieldTable; uniform vec4 uFieldGrid; uniform float uFieldAngle; uniform float uCampusR;\n${NOISE_GLSL}\nvec3 lin(vec3 c){ return pow(c, vec3(2.2)); }`,
  fragment: {
   color_fragment: /* glsl */`
    #include <color_fragment>
    vec2 p = vJWorld.xz;
    float ca = cos(uFieldAngle), sa = sin(uFieldAngle);
    vec2 q = vec2(ca * p.x - sa * p.y, sa * p.x + ca * p.y);
    q.x += fract(floor(q.y / uFieldGrid.y) * 0.618) * uFieldGrid.x;
    vec2 cf = q / uFieldGrid.xy, id = floor(cf), f = fract(cf);
    ivec2 tc = clamp(ivec2(id + uFieldGrid.zw * 0.5), ivec2(0), ivec2(uFieldGrid.zw) - 1);
    vec4 info = texelFetch(uFieldTable, tc, 0);
    int kind = int(info.r * 255.0 + 0.5); float rnd = info.g; bool alongX = info.b > 0.5;
    // Many parcels are split into 2-4 strips owned by different farmers.
    float strips = kind == 4 ? 1.0 : floor(1.0 + rnd * 3.99);
    float across = alongX ? f.y : f.x, stripId = floor(across * strips), stripF = fract(across * strips);
    float sr = jHash(id * 1.37 + stripId * 7.1);
    float s = alongX ? f.x * uFieldGrid.x : f.y * uFieldGrid.y;
    float aa = 1.0 - smoothstep(0.25, 0.9, fwidth(s) / 1.1);
    float furrow = 0.5 + 0.5 * sin(s * 6.2831 / 1.1);
    int k2 = kind == 4 ? 4 : (sr < 0.33 ? kind : int(mod(float(kind) + floor(sr * 4.0), 4.0)));
    vec3 col;
    if (k2 == 0) col = lin(mix(vec3(0.5, 0.34, 0.24), vec3(0.44, 0.32, 0.24), sr)) * (0.84 + 0.24 * furrow * aa + (1.0 - aa) * 0.12);
    else if (k2 == 1) col = lin(mix(vec3(0.56, 0.55, 0.33), vec3(0.66, 0.6, 0.38), sr)) * (0.93 + 0.1 * furrow * aa);
    else if (k2 == 2) col = lin(mix(vec3(0.34, 0.42, 0.22), vec3(0.42, 0.48, 0.26), sr)) * (0.92 + 0.12 * furrow * aa);
    else if (k2 == 3) col = lin(mix(vec3(0.72, 0.6, 0.4), vec3(0.8, 0.69, 0.47), sr)) * (0.95 + 0.07 * furrow * aa);
    else if (k2 == 4) col = lin(vec3(0.58, 0.4, 0.29)) * (0.92 + 0.14 * jNoise(p * 0.7));
    else { float row = 0.5 + 0.5 * sin(s * 6.2831 / 1.7); col = mix(lin(vec3(0.47, 0.34, 0.25)), lin(vec3(0.33, 0.43, 0.22)), smoothstep(0.35, 0.65, row) * aa + (1.0 - aa) * 0.5); }
    // Patchy growth and moisture inside each strip.
    col *= 0.86 + 0.28 * jFbm3(p * 0.03 + sr * 10.0);
    float stripEdge = min(stripF, 1.0 - stripF) * (alongX ? uFieldGrid.y : uFieldGrid.x) / strips;
    float edge = min(min(f.x, 1.0 - f.x) * uFieldGrid.x, min(f.y, 1.0 - f.y) * uFieldGrid.y);
    col = mix(col * 0.86, col, smoothstep(0.0, 0.8, stripEdge));
    col = mix(col * 0.78, col, smoothstep(1.8, 4.0, edge));
    col = mix(col, lin(vec3(0.7, 0.6, 0.46)), (1.0 - smoothstep(0.5, 1.6, edge)) * 0.5);
    col *= 0.8 + 0.4 * jFbm3(p * 0.0025 + 4.0);
    // Campus terrace: dry grass and pale limestone dust.
    float campus = 1.0 - smoothstep(uCampusR - 50.0, uCampusR + 70.0, length(vec2(p.x * 0.85, p.y)));
    vec3 campusCol = mix(lin(vec3(0.69, 0.62, 0.45)), lin(vec3(0.56, 0.55, 0.35)), smoothstep(0.35, 0.7, jFbm3(p * 0.02)));
    campusCol *= 0.9 + 0.2 * jNoise(p * 0.6);
    col = mix(col, campusCol, campus);
    // Distant hills: bare limestone and scrub.
    float rockN = jFbm3(p * 0.01), rock = smoothstep(25.0, 150.0, vJWorld.y) * (0.6 + 0.4 * rockN);
    col = mix(col, lin(vec3(0.68, 0.6, 0.48)) * (0.8 + 0.3 * rockN), rock);
    diffuseColor.rgb = col;
   `
  }
 });
 const mesh = new THREE.Mesh(geometry, material); mesh.name = 'terrain'; mesh.receiveShadow = true;
 return { mesh, groundHeight };
}

function roadTexture() {
 const c = canvas(512, 128), g = c.getContext('2d'), random = rng(55);
 g.fillStyle = '#4a4b4c'; g.fillRect(0, 0, 512, 128);
 for (let i = 0; i < 2600; i++) { const v = 60 + random() * 30; g.fillStyle = `rgba(${v},${v},${v - 2},${.25 + random() * .3})`; g.fillRect(random() * 512, random() * 128, 1.5, 1.5); }
 g.fillStyle = 'rgba(30,30,30,.25)'; g.fillRect(0, 34, 512, 16); g.fillRect(0, 78, 512, 16); // tyre tracks
 g.fillStyle = '#e9e5da'; g.fillRect(0, 5, 512, 4); g.fillRect(0, 119, 512, 4);
 g.fillRect(0, 62, 170, 4);
 return canvasTexture(c);
}

function createRoads(groundHeight) {
 const map = roadTexture(); map.repeat.set(1 / 12, 1);
 const asphalt = new THREE.MeshStandardMaterial({ map, roughness: .9, polygonOffset: true, polygonOffsetFactor: -2, polygonOffsetUnits: -4 });
 const kerb = new THREE.MeshStandardMaterial({ color: '#c9bea9', roughness: .95, polygonOffset: true, polygonOffsetFactor: -1, polygonOffsetUnits: -2 });
 const group = new THREE.Group(); group.name = 'roads';
 const add = (points, width) => {
  const dense = []; // subdivide so the ribbon hugs the ground
  for (let i = 0; i < points.length - 1; i++) { const a = points[i], b = points[i + 1], steps = Math.max(1, Math.ceil(Math.hypot(b.x - a.x, b.z - a.z) / 8)); for (let s = 0; s < steps; s++) dense.push({ x: a.x + (b.x - a.x) * s / steps, z: a.z + (b.z - a.z) * s / steps }); }
  dense.push(points[points.length - 1]);
  const road = new THREE.Mesh(ribbonGeometry(dense, width, .08, groundHeight), asphalt); road.receiveShadow = true; group.add(road);
  const side = new THREE.Mesh(ribbonGeometry(dense, width + 4, .04, groundHeight), kerb); side.receiveShadow = true; group.add(side);
 };
 add(ROADS.spine, 11); add(ROADS.access, 9); add(ROADS.loop, 8); add(ROADS.north, 7);
 return group;
}

// Foliage material: wind sway in the vertex shader and back-lit translucency toward the sun.
export function foliageMaterial({ color = '#ffffff', sway = 1, key, map = null }) {
 const base = new THREE.MeshStandardMaterial({ color, vertexColors: true, roughness: 1, metalness: 0, envMapIntensity: .3 });
 if (map) Object.assign(base, { map, alphaTest: .42, side: THREE.DoubleSide, alphaToCoverage: true });
 return patchMaterial(base, {
  key, uniforms: { uTime: WORLD.uTime, uSunDir: WORLD.uSunDir, uSunColor: WORLD.uSunColor, uWind: WORLD.uWind, uSway: { value: sway } },
  vertexHead: 'uniform float uTime; uniform float uWind; uniform float uSway; varying vec3 vJWorld;',
  vertex: {
   begin_vertex: /* glsl */`
    #include <begin_vertex>
    vec3 ip = vec3(0.0);
    #ifdef USE_INSTANCING
     ip = vec3(instanceMatrix[3][0], 0.0, instanceMatrix[3][2]);
    #endif
    float hgt = max(position.y, 0.0);
    float gust = 0.55 + 0.45 * sin(uTime * 0.37 + ip.x * 0.006 - ip.z * 0.004);
    float w = sin(uTime * 1.45 + ip.x * 0.05 + ip.z * 0.07) * 0.65 + sin(uTime * 2.6 + ip.x * 0.13) * 0.35;
    transformed.x += w * gust * uWind * uSway * hgt * hgt * 0.0042;
    transformed.z += w * gust * uWind * uSway * hgt * hgt * 0.0024;
    transformed += normal * sin(uTime * 5.3 + position.x * 7.0 + position.z * 5.0 + ip.x) * 0.025 * uWind * step(0.6, hgt);
    #ifdef USE_INSTANCING
     vJWorld = (modelMatrix * instanceMatrix * vec4(transformed, 1.0)).xyz;
    #else
     vJWorld = (modelMatrix * vec4(transformed, 1.0)).xyz;
    #endif`
  },
  fragmentHead: 'uniform vec3 uSunDir; uniform vec3 uSunColor; varying vec3 vJWorld;',
  fragment: {
   emissivemap_fragment: /* glsl */`
    #include <emissivemap_fragment>
    vec3 jView = normalize(vJWorld - cameraPosition);
    float back = pow(max(dot(jView, uSunDir), 0.0), 4.0);
    totalEmissiveRadiance += uSunColor * diffuseColor.rgb * back * 0.55 * max(uSunDir.y + 0.05, 0.0) * 6.0;`
  }
 });
}

// Organic blob: an icosphere pushed around by noise, with a dark-to-light vertex gradient.
function blob(radius, detail, seed, squash = 1, colorA, colorB) {
 const ico = new THREE.IcosahedronGeometry(radius, detail); ico.deleteAttribute('normal'); ico.deleteAttribute('uv');
 const g = mergeVertices(ico), p = g.attributes.position, random = rng(seed), colors = [];
 const ca = new THREE.Color(colorA), cb = new THREE.Color(colorB), tmp = new THREE.Color();
 const o = random() * 100;
 for (let i = 0; i < p.count; i++) {
  const x = p.getX(i), y = p.getY(i), z = p.getZ(i), n = .78 + fbm(x * 1.3 + o, z * 1.3 + y * .7, 3) * .5;
  p.setXYZ(i, x * n, y * n * squash, z * n);
  const t = THREE.MathUtils.clamp((y / radius) * .5 + .5, 0, 1);
  tmp.copy(ca).lerp(cb, t * .85 + random() * .15); colors.push(tmp.r, tmp.g, tmp.b);
 }
 g.setAttribute('color', new THREE.Float32BufferAttribute(colors, 3));
 g.computeVertexNormals(); return g;
}
function colored(geometry, hex) {
 const c = new THREE.Color(hex), colors = []; for (let i = 0; i < geometry.attributes.position.count; i++) colors.push(c.r, c.g, c.b);
 geometry.setAttribute('color', new THREE.Float32BufferAttribute(colors, 3)); return geometry.index ? geometry.toNonIndexed() : geometry;
}
function nonIndexed(g) { return g.index ? g.toNonIndexed() : g; }

// Painted leaf clusters (transparent background) for card canopies.
function leafTexture(kind, seed) {
 const c = canvas(256), g = c.getContext('2d'), random = rng(seed);
 const palette = kind === 'olive' ? ['#aab597', '#7d8b63', '#5f6e46', '#93a07d', '#4c5a37'] : kind === 'pine' ? ['#2d4423', '#3e5a2c', '#527039', '#24371d'] : ['#4d6a2f', '#6b8a40', '#3b5425', '#86a153', '#59783a'];
 g.strokeStyle = 'rgba(74,58,44,.9)'; g.lineWidth = 2;
 for (let i = 0; i < 9; i++) { const a = random() * 6.28; g.beginPath(); g.moveTo(128, 128); g.lineTo(128 + Math.cos(a) * 95, 128 + Math.sin(a) * 95); g.stroke(); }
 const n = kind === 'pine' ? 46 : 150;
 for (let i = 0; i < n; i++) {
  const a = random() * 6.28, r = Math.sqrt(random()) * 104, x = 128 + Math.cos(a) * r, y = 128 + Math.sin(a) * r;
  g.fillStyle = palette[Math.floor(random() * palette.length)]; g.strokeStyle = g.fillStyle;
  if (kind === 'pine') { g.lineWidth = 1.6; for (let k = 0; k < 16; k++) { const b = random() * 6.28, l = 10 + random() * 9; g.beginPath(); g.moveTo(x, y); g.lineTo(x + Math.cos(b) * l, y + Math.sin(b) * l); g.stroke(); } }
  else { g.save(); g.translate(x, y); g.rotate(random() * 6.28); g.beginPath(); if (kind === 'olive') g.ellipse(0, 0, 11 + random() * 6, 2.6 + random() * 1.4, 0, 0, 6.28); else g.ellipse(0, 0, 8 + random() * 4, 5 + random() * 2, 0, 0, 6.28); g.fill(); g.restore(); }
 }
 const t = canvasTexture(c, true, false); t.generateMipmaps = true; return t;
}

// A canopy made of crossed leaf cards inside an ellipsoid, with normals pointing out from the
// centre so the whole crown shades as one soft volume.
function cardCanopy({ count, radius, center, size, seed, dark = .55, light = 1.08 }) {
 const random = rng(seed), pos = [], nor = [], uvs = [], col = [], idx = [], up = new THREE.Vector3(0, 1, 0);
 const n = new THREE.Vector3(), t = new THREE.Vector3(), b = new THREE.Vector3(), p = new THREE.Vector3(), nn = new THREE.Vector3();
 for (let i = 0; i < count; i++) {
  n.set(random() * 2 - 1, random() * 2 - 1, random() * 2 - 1).normalize();
  const r = .5 + .5 * Math.sqrt(random());
  p.set(center[0] + n.x * radius[0] * r, center[1] + n.y * radius[1] * r, center[2] + n.z * radius[2] * r);
  nn.set((p.x - center[0]) / radius[0], (p.y - center[1]) / radius[1], (p.z - center[2]) / radius[2]).normalize();
  const face = new THREE.Vector3(random() * 2 - 1, random() * 2 - 1, random() * 2 - 1).normalize().lerp(nn, .5).normalize();
  t.crossVectors(face, Math.abs(face.y) > .9 ? new THREE.Vector3(1, 0, 0) : up).normalize(); b.crossVectors(face, t);
  const s = size * (.75 + random() * .5), h = (p.y - (center[1] - radius[1])) / (2 * radius[1]), shade = dark + (light - dark) * Math.min(1, Math.max(0, h * .8 + nn.y * .2 + .1));
  const base = pos.length / 3;
  for (const [u, v] of [[0, 0], [1, 0], [1, 1], [0, 1]]) {
   pos.push(p.x + t.x * (u - .5) * s + b.x * (v - .5) * s, p.y + t.y * (u - .5) * s + b.y * (v - .5) * s, p.z + t.z * (u - .5) * s + b.z * (v - .5) * s);
   nor.push(nn.x, nn.y, nn.z); uvs.push(u, v); col.push(shade, shade, shade * .97);
  }
  idx.push(base, base + 1, base + 2, base, base + 2, base + 3);
 }
 const g = new THREE.BufferGeometry();
 g.setAttribute('position', new THREE.Float32BufferAttribute(pos, 3)); g.setAttribute('normal', new THREE.Float32BufferAttribute(nor, 3));
 g.setAttribute('uv', new THREE.Float32BufferAttribute(uvs, 2)); g.setAttribute('color', new THREE.Float32BufferAttribute(col, 3)); g.setIndex(idx);
 return g;
}
function mergeCards(list) { return mergeGeometries(list.map(g => g.index ? g.toNonIndexed() : g)); }
const SPECIES = {
 olive: () => ({ trunk: mergeGeometries([colored(new THREE.CylinderGeometry(.14, .3, 1.9, 6).translate(0, .9, 0), '#5a4c3f'), colored(new THREE.CylinderGeometry(.08, .14, 1.4, 5).rotateZ(.6).translate(.45, 2.1, 0), '#5a4c3f'), colored(new THREE.CylinderGeometry(.08, .14, 1.4, 5).rotateZ(-.7).translate(-.45, 2.1, .1), '#5a4c3f')].map(g => { g.deleteAttribute('uv'); return g; })),
  crown: mergeCards([cardCanopy({ count: 26, radius: [1.6, 1.1, 1.6], center: [.5, 3.0, 0], size: 1.25, seed: 4 }), cardCanopy({ count: 22, radius: [1.4, 1.0, 1.4], center: [-.7, 2.8, .4], size: 1.2, seed: 5 }), cardCanopy({ count: 16, radius: [1.2, .9, 1.2], center: [0, 3.6, -.5], size: 1.1, seed: 6 })]) }),
 shade: () => ({ trunk: (() => { const g = colored(new THREE.CylinderGeometry(.15, .26, 3.2, 6).translate(0, 1.6, 0), '#5b4a3c'); g.deleteAttribute('uv'); return g; })(),
  crown: mergeCards([cardCanopy({ count: 70, radius: [2.6, 2.0, 2.6], center: [0, 4.6, 0], size: 1.5, seed: 9 }), cardCanopy({ count: 30, radius: [1.7, 1.4, 1.7], center: [1.2, 3.9, .6], size: 1.3, seed: 10 })]) }),
 pine: () => ({ trunk: (() => { const g = colored(new THREE.CylinderGeometry(.16, .32, 7.2, 6).translate(0, 3.4, 0), '#58463a'); g.deleteAttribute('uv'); return g; })(),
  crown: mergeCards([cardCanopy({ count: 48, radius: [3.0, 1.2, 3.0], center: [0, 7.6, 0], size: 1.9, seed: 12, dark: .5 }), cardCanopy({ count: 26, radius: [2.0, 1.0, 2.0], center: [1.6, 6.6, .9], size: 1.7, seed: 13, dark: .5 }), cardCanopy({ count: 20, radius: [1.8, .9, 1.8], center: [-1.5, 6.9, -1.0], size: 1.6, seed: 14, dark: .5 })]) })
};

function oliveGeometry(detail) {
 const parts = [colored(new THREE.CylinderGeometry(.16, .3, 1.7, 6).translate(0, .75, 0), '#4d4136')];
 const random = rng(301 + detail);
 for (let i = 0; i < 5; i++) {
  const a = i / 5 * Math.PI * 2, r = i === 0 ? 0 : 1.05;
  parts.push(nonIndexed(blob(1.25 + random() * .35, detail, 40 + i, .72, '#3f4a2e', '#8d9a72').translate(Math.cos(a) * r, 2.6 + random() * .5, Math.sin(a) * r)));
 }
 return mergeGeometries(parts.map(p => { p.deleteAttribute('uv'); return p; }));
}
function cypressGeometry() {
 const profile = [[0, -.5], [.32, .2], [.68, 1.4], [.82, 3.4], [.76, 5.8], [.55, 8.2], [.26, 10.2], [.04, 11.6]].map(([r, y]) => new THREE.Vector2(r, y));
 const g = new THREE.LatheGeometry(profile, 12), p = g.attributes.position, colors = [], dark = new THREE.Color('#1c2c1c'), light = new THREE.Color('#4f6640'), tmp = new THREE.Color();
 for (let i = 0; i < p.count; i++) {
  const x = p.getX(i), y = p.getY(i), z = p.getZ(i), n = .82 + fbm(x * 2.2 + 3, z * 2.2 + y * .9, 3) * .45;
  p.setXYZ(i, x * n, y, z * n); tmp.copy(dark).lerp(light, THREE.MathUtils.clamp(y / 11, 0, 1) * .8 + (n - .82) * .5); colors.push(tmp.r, tmp.g, tmp.b);
 }
 g.setAttribute('color', new THREE.Float32BufferAttribute(colors, 3)); g.computeVertexNormals(); g.deleteAttribute('uv');
 return g;
}
function insideAny(x, z, pad) {
 for (const b of BUILDINGS) if (Math.abs(x - b.x) < b.w / 2 + pad && Math.abs(z - b.z) < b.d / 2 + pad) return true;
 if (Math.abs(x - HALL.x) < HALL.w / 2 + pad && Math.abs(z - HALL.z) < HALL.d / 2 + pad) return true;
 if (Math.abs(x - PARKING.x) < PARKING.w / 2 + pad && Math.abs(z - PARKING.z) < PARKING.d / 2 + pad) return true;
 if (Math.abs(x - SOLAR_FIELD.x) < SOLAR_FIELD.w / 2 + pad && Math.abs(z - SOLAR_FIELD.z) < SOLAR_FIELD.d / 2 + pad) return true;
 if (x > COURTYARD.x0 && x < COURTYARD.x1 && z > COURTYARD.z0 && z < COURTYARD.z1) return true;
 return false;
}
function nearRoad(x, z, clearance) {
 for (const line of Object.values(ROADS)) for (let i = 0; i < line.length - 1; i++) {
  const a = line[i], b = line[i + 1], dx = b.x - a.x, dz = b.z - a.z, t = THREE.MathUtils.clamp(((x - a.x) * dx + (z - a.z) * dz) / (dx * dx + dz * dz), 0, 1);
  if (Math.hypot(x - a.x - dx * t, z - a.z - dz * t) < clearance) return true;
 }
 return false;
}

function instanced(geometry, material, transforms, { shadows = true, name, tile = 220 }) {
 const tiles = new Map();
 for (const t of transforms) { const k = Math.floor(t.x / tile) + ',' + Math.floor(t.z / tile); if (!tiles.has(k)) tiles.set(k, []); tiles.get(k).push(t); }
 const group = new THREE.Group(); group.name = name;
 for (const list of tiles.values()) group.add(instancedTile(geometry, material, list, shadows, name));
 return group;
}
function instancedTile(geometry, material, transforms, shadows, name) {
 const mesh = new THREE.InstancedMesh(geometry, material, transforms.length), m = new THREE.Matrix4(), q = new THREE.Quaternion(), s = new THREE.Vector3(), up = new THREE.Vector3(0, 1, 0);
 transforms.forEach((t, i) => { q.setFromAxisAngle(up, t.r); s.set(t.s, t.s * (t.sy || 1), t.s); m.compose(new THREE.Vector3(t.x, t.y, t.z), q, s); mesh.setMatrixAt(i, m); });
 mesh.castShadow = shadows; mesh.receiveShadow = true; mesh.name = name; mesh.instanceMatrix.needsUpdate = true; mesh.computeBoundingSphere(); mesh.boundingSphere.radius += 14; mesh.frustumCulled = true;
 return mesh;
}

const rowShift = j => { const r = (j - FIELD.rows / 2) * .618; return (r - Math.floor(r)) * FIELD.cellX; };
function createVegetation(groundHeight, fieldTable) {
 const group = new THREE.Group(); group.name = 'vegetation';
 const random = rng(2026), near = [], far = [], cypress = [], pines = [], shade = [];
 // Olive groves on their parcels, in rows 9 m apart.
 const R = 1700, c = Math.cos(-.32), s = Math.sin(-.32);
 for (let j = 0; j < FIELD.rows; j++) for (let i = 0; i < FIELD.cols; i++) {
  if (fieldTable.kind(i, j) !== 4) continue;
  const u0 = (i - FIELD.cols / 2) * FIELD.cellX, v0 = (j - FIELD.rows / 2) * FIELD.cellZ;
  for (let a = 7; a < FIELD.cellX - 5; a += 9) for (let b = 7; b < FIELD.cellZ - 5; b += 9) {
   const u = u0 + a - rowShift(j) + (random() - .5) * 1.6, v = v0 + b + (random() - .5) * 1.6, x = c * u - s * v, z = s * u + c * v, d = Math.hypot(x, z);
   if (d > R || d < CAMPUS_RADIUS + 30 || nearRoad(x, z, 12)) continue;
   (d < 620 ? near : far).push({ x, z, y: groundHeight(x, z) - .1, r: random() * 6.28, s: .75 + random() * .5 });
  }
 }
 // Cypress avenues along the approach road and the campus loop.
 const avenue = (line, offset, spacing, from, to) => {
  for (let i = 0; i < line.length - 1; i++) {
   const a = line[i], b = line[i + 1], len = Math.hypot(b.x - a.x, b.z - a.z), nx = -(b.z - a.z) / len, nz = (b.x - a.x) / len;
   for (let d = 0; d < len; d += spacing) {
    const px = a.x + (b.x - a.x) * d / len, pz = a.z + (b.z - a.z) * d / len;
    if (pz < from || pz > to) continue;
    for (const side of [-1, 1]) { const x = px + nx * offset * side, z = pz + nz * offset * side; if (!insideAny(x, z, 2) && Math.hypot(x - CLIMAX_SPOT.x, z - CLIMAX_SPOT.z) > CLIMAX_SPOT.clear) cypress.push({ x, z, y: groundHeight(x, z), r: random() * 6.28, s: .8 + random() * .45, sy: 1 + random() * .25 }); }
   }
  }
 };
 avenue(ROADS.spine, 11, 8.5, -1400, 1400); avenue(ROADS.loop, 9.5, 11, -500, 500); avenue(ROADS.access, 8, 8, -500, 500);
 // Aleppo pines and shade trees on the campus terrace.
 // Aleppo pines in a few loose clumps on the campus edge.
 for (const [cx, cz, n] of [[-170, -120, 9], [190, 40, 8], [-210, 60, 7], [40, 190, 9], [-60, 200, 6], [210, -220, 7], [-30, -240, 6]]) {
  for (let k = 0; k < n; k++) { const x = cx + (random() - .5) * 40, z = cz + (random() - .5) * 40; if (!insideAny(x, z, 6) && !nearRoad(x, z, 8)) pines.push({ x, z, y: groundHeight(x, z), r: random() * 6.28, s: .75 + random() * .45 }); }
 }
 // Campus olives: loose orchard rows on the open terrace, as in the aerial photograph.
 for (let x = -250; x < 250; x += 11) for (let z = -260; z < 260; z += 11) {
  const jx = x + (random() - .5) * 4, jz = z + (random() - .5) * 4, d = Math.hypot(jx * .85, jz);
  if (d > CAMPUS_RADIUS - 10 || random() < .35 || insideAny(jx, jz, 9) || nearRoad(jx, jz, 9) || (Math.abs(jx) < 78 && Math.abs(jz) < 102)) continue;
  near.push({ x: jx, z: jz, y: groundHeight(jx, jz) - .1, r: random() * 6.28, s: .8 + random() * .4 });
 }
 for (const p of [[-17, 3], [-17, 17], [12, -5], [12, 9], [13, 19], [-24, 28], [22, 26], [-6, 44], [24, 46], [-70, 22], [-70, -18], [62, 24], [-30, 90], [30, 90], [0, 92], [-60, 96], [52, 92], [-48, 74], [56, 66], [62, -52], [-66, -60]]) shade.push({ x: p[0], z: p[1], y: groundHeight(p[0], p[1]), r: random() * 6.28, s: .85 + random() * .3 });

 const oliveLeaves = leafTexture('olive', 21), broadLeaves = leafTexture('broad', 22), pineNeedles = leafTexture('pine', 23);
 const bark = new THREE.MeshStandardMaterial({ vertexColors: true, roughness: .95 });
 const species = (kind, list, map, sway, name) => {
  const s = SPECIES[kind]();
  group.add(instanced(s.trunk, bark, list, { name: name + '-trunks' }));
  group.add(instanced(s.crown, foliageMaterial({ key: 'cards-' + kind, map, sway }), list, { name: name + '-crowns' }));
 };
 species('olive', near, oliveLeaves, 1.4, 'olive-near');
 species('shade', shade, broadLeaves, 1.1, 'shade');
 species('pine', pines, pineNeedles, .8, 'pine');
 group.add(instanced(oliveGeometry(0), foliageMaterial({ key: 'olive', sway: 1.4 }), far, { shadows: false, name: 'olive-far' }));
 group.add(instanced(cypressGeometry(), foliageMaterial({ key: 'cypress', sway: 1 }), cypress, { name: 'cypress' }));
 return group;
}

function createStreetLights(groundHeight) {
 const poles = [], heads = [], m = new THREE.Matrix4();
 const place = (line, offset, spacing) => {
  for (let i = 0; i < line.length - 1; i++) {
   const a = line[i], b = line[i + 1], len = Math.hypot(b.x - a.x, b.z - a.z), nx = -(b.z - a.z) / len, nz = (b.x - a.x) / len;
   for (let d = spacing / 2; d < len; d += spacing) {
    const px = a.x + (b.x - a.x) * d / len, pz = a.z + (b.z - a.z) * d / len;
    if (Math.abs(pz) > 1100) continue;
    for (const side of [-1, 1]) { const x = px + nx * offset * side, z = pz + nz * offset * side, y = groundHeight(x, z); if (Math.hypot(x - CLIMAX_SPOT.x, z - CLIMAX_SPOT.z) < 32) continue; poles.push([x, y, z]); heads.push([x - nx * side * 1.2, y + 8.1, z - nz * side * 1.2]); }
   }
  }
 };
 place(ROADS.spine, 6.8, 38); place(ROADS.loop, 5.6, 30);
 const pole = new THREE.InstancedMesh(new THREE.CylinderGeometry(.08, .12, 8.4, 6).translate(0, 4.2, 0), new THREE.MeshStandardMaterial({ color: '#6c7377', roughness: .5, metalness: .6 }), poles.length);
 const lampMaterial = new THREE.MeshStandardMaterial({ color: '#2a2a28', emissive: '#ffb765', emissiveIntensity: 6, roughness: .4 });
 const head = new THREE.InstancedMesh(new THREE.BoxGeometry(.9, .16, .36), lampMaterial, heads.length);
 poles.forEach((p, i) => { m.makeTranslation(p[0], p[1], p[2]); pole.setMatrixAt(i, m); });
 heads.forEach((p, i) => { m.makeTranslation(p[0], p[1], p[2]); head.setMatrixAt(i, m); });
 pole.castShadow = true; pole.frustumCulled = head.frustumCulled = false;
 const group = new THREE.Group(); group.name = 'street-lights'; group.add(pole, head);
 return { group, update(lights) { lampMaterial.emissiveIntensity = lights * 9; lampMaterial.emissive.setRGB(1, .62 + (1 - lights) * .1, .3); } };
}

export function createLand() {
 const fieldTable = buildFieldTable();
 const terrain = createTerrain(fieldTable);
 const roads = createRoads(terrain.groundHeight);
 const vegetation = createVegetation(terrain.groundHeight, fieldTable);
 const lights = createStreetLights(terrain.groundHeight);
 const root = new THREE.Group(); root.name = 'land'; root.add(terrain.mesh, roads, vegetation, lights.group);
 return { root, groundHeight: terrain.groundHeight, updateLights: lights.update };
}
