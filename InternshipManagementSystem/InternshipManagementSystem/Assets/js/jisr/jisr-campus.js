import * as THREE from '../vendor/three.module.min.js';
import { WORLD, rng, canvas, canvasTexture, patchMaterial } from './jisr-common.js';
import { BUILDINGS, HALL, COURTYARD, WATERWHEEL, GATE, PARKING, SOLAR_FIELD } from './jisr-layout.js';
import { createCourtyardModel } from '../courtyard-model.js';
import { createGateModel } from '../home-gate-model.js';

// One facade tile covers 14.4 m x 14.4 m: four storeys of 3.6 m.
const TILE = 14.4, PX = 1024, M = PX / TILE;

// Never let an asset stall the scene: anything slower than the timeout is skipped.
const withTimeout = (promise, ms) => Promise.race([promise, new Promise(resolve => setTimeout(() => resolve(null), ms))]);
async function loadImage(url) { try { const i = new Image(); i.src = url; await new Promise((ok, fail) => { i.onload = ok; i.onerror = fail; if (i.complete && i.naturalWidth) ok(); }); return i; } catch (_) { return null; } }

// GJU limestone: cream ashlar courses with per-block tone, overlaid with the real stone photograph texture.
function paintStone(g, random, stonePhoto, w = PX, h = PX) {
 g.fillStyle = '#e4d8c2'; g.fillRect(0, 0, w, h);
 const course = .6 * M;
 for (let y = 0; y < h; y += course) {
  let x = -random() * 1.2 * M;
  while (x < w) {
   const bw = (.8 + random() * .9) * M, t = random();
   g.fillStyle = `rgb(${226 + t * 10 | 0},${215 + t * 9 | 0},${193 + t * 9 | 0})`; g.fillRect(x, y, bw, course);
   g.fillStyle = 'rgba(120,104,82,.16)'; g.fillRect(x, y, 1.4, course); x += bw;
  }
  g.fillStyle = 'rgba(120,104,82,.2)'; g.fillRect(0, y, w, 1.4);
 }
 if (stonePhoto) { g.globalAlpha = .32; g.globalCompositeOperation = 'multiply'; const s = 2.4 * M; for (let y = 0; y < h; y += s) for (let x = 0; x < w; x += s) g.drawImage(stonePhoto, x, y, s, s); g.globalAlpha = 1; g.globalCompositeOperation = 'source-over'; }
 for (let i = 0; i < 2600; i++) { g.fillStyle = `rgba(90,76,58,${random() * .1})`; g.fillRect(random() * w, random() * h, 2, 2); }
 // Soft vertical weathering streaks below sills.
 for (let i = 0; i < 40; i++) { const x = random() * w, len = 60 + random() * 180, gr = g.createLinearGradient(0, 0, 0, len); gr.addColorStop(0, 'rgba(110,96,76,.12)'); gr.addColorStop(1, 'rgba(110,96,76,0)'); g.fillStyle = gr; g.save(); g.translate(x, random() * h); g.fillRect(0, 0, 3 + random() * 6, len); g.restore(); }
}

// Returns albedo, roughness, bump and emissive (lit rooms) canvases for one facade type.
function facadeSet(kind, seed, stonePhoto) {
 const random = rng(seed);
 const [albedo, rough, bump, emit] = [canvas(PX), canvas(PX), canvas(PX), canvas(PX)];
 const a = albedo.getContext('2d'), r = rough.getContext('2d'), b = bump.getContext('2d'), e = emit.getContext('2d');
 r.fillStyle = '#d9d9d9'; r.fillRect(0, 0, PX, PX); b.fillStyle = '#ffffff'; b.fillRect(0, 0, PX, PX); e.fillStyle = '#000'; e.fillRect(0, 0, PX, PX);
 const windows = [];
 if (kind === 'louvre') {
  // Curtain wall: dark glazing behind a white aluminium grid with horizontal sun louvres.
  a.fillStyle = '#2d5275'; a.fillRect(0, 0, PX, PX); r.fillStyle = '#101010'; r.fillRect(0, 0, PX, PX); b.fillStyle = '#202020'; b.fillRect(0, 0, PX, PX);
  for (let y = 0; y < PX; y += 3.6 * M) for (let x = 0; x < PX; x += 1.2 * M) { const lit = random() < .3; windows.push({ x: x + 4, y: y + 4, w: 1.2 * M - 8, h: 3.6 * M - 8, lit, warm: random() < .7 }); }
  for (const wdw of windows) if (wdw.lit) { e.fillStyle = '#ffd6a0'; e.globalAlpha = .35 + random() * .3; e.fillRect(wdw.x, wdw.y, wdw.w, wdw.h); }
  e.globalAlpha = 1;
  for (const ctx of [a, r, b]) {
   ctx.fillStyle = ctx === a ? '#eef0ee' : ctx === r ? '#7a7a7a' : '#ffffff';
   for (let x = 0; x < PX; x += 1.2 * M) ctx.fillRect(x - 5, 0, 10, PX);
   for (let y = 0; y < PX; y += 3.6 * M) ctx.fillRect(0, y - 9, PX, 18);
   for (let y = 0; y < PX; y += .3 * M) ctx.fillRect(0, y, PX, 5);
  }
  return { albedo, rough, bump, emit };
 }
 paintStone(a, random, stonePhoto);
 for (let floor = 0; floor < 4; floor++) {
  const top = floor * 3.6 * M;
  if (kind === 'strip') {
   // GJU's staggered ribbon windows: long horizontal strips at irregular offsets per storey.
   let x = random() * 2 * M;
   while (x < PX - 1.2 * M) {
    const len = (2 + Math.floor(random() * 5)) * 1.2 * M, height = (random() < .25 ? 1.5 : .95) * M;
    windows.push({ x, y: top + 3.6 * M - 1.15 * M - height, w: Math.min(len, PX - x - .4 * M), h: height, lit: random() < .38, warm: random() < .75, mull: 1.2 });
    x += len + (1 + random() * 3.5) * M;
   }
  } else {
   for (let x = (random() * 1.2 + .6) * M; x < PX - .8 * M; x += 2.4 * M) windows.push({ x, y: top + .7 * M, w: .7 * M, h: 2.3 * M, lit: random() < .4, warm: random() < .75, mull: 0 });
  }
 }
 for (const wdw of windows) {
  const gr = a.createLinearGradient(0, wdw.y, 0, wdw.y + wdw.h); gr.addColorStop(0, '#3f6f99'); gr.addColorStop(.5, '#2a527a'); gr.addColorStop(1, '#1f3d5e');
  a.fillStyle = '#a99c86'; a.fillRect(wdw.x - 6, wdw.y - 6, wdw.w + 12, wdw.h + 12); // deep stone reveal
  a.fillStyle = gr; a.fillRect(wdw.x, wdw.y, wdw.w, wdw.h);
  r.fillStyle = '#1c1c1c'; r.fillRect(wdw.x, wdw.y, wdw.w, wdw.h);
  b.fillStyle = '#3a3a3a'; b.fillRect(wdw.x - 4, wdw.y - 4, wdw.w + 8, wdw.h + 8); b.fillStyle = '#000'; b.fillRect(wdw.x, wdw.y, wdw.w, wdw.h);
  if (wdw.lit) { e.fillStyle = wdw.warm ? '#ffcf8e' : '#dfe9ff'; e.globalAlpha = .5 + random() * .5; e.fillRect(wdw.x, wdw.y, wdw.w, wdw.h); e.globalAlpha = 1; }
  if (wdw.mull) for (let mx = wdw.x + 1.2 * M; mx < wdw.x + wdw.w - 4; mx += 1.2 * M) for (const ctx of [a, b, e]) { ctx.fillStyle = ctx === a ? '#59626b' : ctx === b ? '#555' : '#000'; ctx.fillRect(mx - 3, wdw.y, 6, wdw.h); }
  // Sill.
  a.fillStyle = '#f1e9da'; a.fillRect(wdw.x - 6, wdw.y + wdw.h, wdw.w + 12, 7);
 }
 return { albedo, rough, bump, emit };
}

function facadeMaterial(set) {
 const map = canvasTexture(set.albedo), roughnessMap = canvasTexture(set.rough, false), bumpMap = canvasTexture(set.bump, false), emissiveMap = canvasTexture(set.emit);
 const material = new THREE.MeshStandardMaterial({ map, roughnessMap, bumpMap, bumpScale: 2.2, emissiveMap, emissive: '#ffffff', emissiveIntensity: 1.6, roughness: 1, metalness: 0, envMapIntensity: .75 });
 return material;
}

function roofMaterial(random) {
 const c = canvas(256), g = c.getContext('2d');
 g.fillStyle = '#c9c4b9'; g.fillRect(0, 0, 256, 256);
 for (let i = 0; i < 5000; i++) { const v = 170 + random() * 60; g.fillStyle = `rgba(${v},${v - 4},${v - 10},.5)`; g.fillRect(random() * 256, random() * 256, 2, 2); }
 g.strokeStyle = 'rgba(90,85,78,.35)'; g.lineWidth = 2; for (let i = 0; i <= 256; i += 64) { g.beginPath(); g.moveTo(i, 0); g.lineTo(i, 256); g.moveTo(0, i); g.lineTo(256, i); g.stroke(); }
 const map = canvasTexture(c); return new THREE.MeshStandardMaterial({ map, roughness: .95 });
}

// Box with UVs in facade tiles so windows keep their real size on any building.
function facadeBox(w, h, d, uOffset) {
 const g = new THREE.BoxGeometry(w, h, d), uv = g.attributes.uv;
 const widths = [d, d, w, w, w, w];
 for (let face = 0; face < 6; face++) for (let j = 0; j < 4; j++) {
  const i = face * 4 + j;
  if (face === 2 || face === 3) uv.setXY(i, uv.getX(i) * w / 8, uv.getY(i) * d / 8);
  else uv.setXY(i, uv.getX(i) * widths[face] / TILE + uOffset * (face + 1), uv.getY(i) * h / TILE);
 }
 return g;
}

export async function createCampus({ logoUrl, stoneUrl, groundHeight }) {
 const root = new THREE.Group(); root.name = 'campus';
 const random = rng(1909), stonePhoto = stoneUrl ? await withTimeout(loadImage(stoneUrl), 4000) : null;
 const facades = {
  strip: [facadeMaterial(facadeSet('strip', 11, stonePhoto)), facadeMaterial(facadeSet('strip', 12, stonePhoto))],
  slots: [facadeMaterial(facadeSet('slots', 21, stonePhoto))],
  louvre: [facadeMaterial(facadeSet('louvre', 31, stonePhoto))]
 };
 const allFacades = [...facades.strip, ...facades.slots, ...facades.louvre];
 const roof = roofMaterial(random);
 const parapetCanvas = canvas(512); paintStone(parapetCanvas.getContext('2d'), rng(7), stonePhoto, 512, 512);
 const parapetMap = canvasTexture(parapetCanvas); parapetMap.repeat.set(1 / 7.2, 1 / 7.2);
 const stone = new THREE.MeshStandardMaterial({ map: parapetMap, roughness: .9 });
 const steel = new THREE.MeshStandardMaterial({ color: '#e6e6e1', roughness: .42, metalness: .35 });
 const glass = new THREE.MeshStandardMaterial({ color: '#21323f', roughness: .06, metalness: .1, envMapIntensity: 1.6, emissive: '#ffcf96', emissiveIntensity: .25 });
 const panel = new THREE.MeshStandardMaterial({ color: '#1a2a44', roughness: .18, metalness: .45, envMapIntensity: 1.4 });
 const unit = new THREE.BoxGeometry(1, 1, 1);
 const beams = [], equipment = [], panels = [];
 const addBox = (list, x, y, z, sx, sy, sz, ry = 0) => list.push({ x, y, z, sx, sy, sz, ry });

 for (const b of BUILDINGS) {
  const g = new THREE.Group(); g.name = b.id; g.position.set(b.x, 0, b.z); root.add(g);
  const base = b.glassBase ? 4.2 : 0, set = facades[b.facade], facade = set[Math.floor(random() * set.length)];
  const body = new THREE.Mesh(facadeBox(b.w, b.h - base, b.d, random()), [facade, facade, roof, roof, facade, facade]);
  body.position.y = base + (b.h - base) / 2; body.castShadow = body.receiveShadow = true; g.add(body);
  if (b.glassBase) {
   const lobby = new THREE.Mesh(facadeBox(b.w - 2.4, base, b.d - 2.4, random()), [facades.louvre[0], facades.louvre[0], roof, roof, facades.louvre[0], facades.louvre[0]]); lobby.position.y = base / 2; lobby.receiveShadow = true; g.add(lobby);
   for (let x = -b.w / 2 + 1.2; x <= b.w / 2 - 1.2; x += 6) for (const z of [-b.d / 2 + 1.2, b.d / 2 - 1.2]) addBox(equipment, b.x + x, base / 2, b.z + z, .7, base, .7);
  }
  // Stone parapet.
  for (const [sx, sz, px, pz] of [[b.w, .5, 0, b.d / 2 - .25], [b.w, .5, 0, -b.d / 2 + .25], [.5, b.d, b.w / 2 - .25, 0], [.5, b.d, -b.w / 2 + .25, 0]]) {
   const p = new THREE.Mesh(new THREE.BoxGeometry(sx + .3, 1.1, sz + .3), stone); p.position.set(px, b.h + .55, pz); p.castShadow = p.receiveShadow = true; g.add(p);
  }
  // Rooftop stair core and plant.
  addBox(equipment, b.x + (random() - .5) * b.w * .4, b.h + 1.8, b.z + (random() - .5) * b.d * .4, 5, 3.6, 4.2);
  for (let i = 0; i < 4; i++) addBox(equipment, b.x + (random() - .5) * b.w * .7, b.h + .7, b.z + (random() - .5) * b.d * .7, 1.4 + random(), 1.2, 2 + random() * 1.4);
  if (b.crown) {
   // Signature GJU steel pergola crown: columns, primary beams and a fine slat grid that stripes the roof with shadow.
   const top = b.h + 5.2, ow = b.w + .8, od = b.d + .8;
   for (let x = -ow / 2; x <= ow / 2 + .01; x += ow / Math.round(ow / 7.2)) for (const z of [-od / 2, od / 2]) addBox(beams, b.x + x, b.h + 2.6, b.z + z, .4, 5.2, .4);
   for (let z = -od / 2 + od / Math.round(od / 7.2); z < od / 2 - .01; z += od / Math.round(od / 7.2)) for (const x of [-ow / 2, ow / 2]) addBox(beams, b.x + x, b.h + 2.6, b.z + z, .4, 5.2, .4);
   addBox(beams, b.x, top, b.z - od / 2, ow, .7, .35); addBox(beams, b.x, top, b.z + od / 2, ow, .7, .35);
   addBox(beams, b.x - ow / 2, top, b.z, .35, .7, od); addBox(beams, b.x + ow / 2, top, b.z, .35, .7, od);
   for (let x = -ow / 2 + 3.6; x < ow / 2 - .5; x += 3.6) addBox(beams, b.x + x, top, b.z, .28, .55, od);
   for (let z = -od / 2 + 1.5; z < od / 2 - .3; z += 1.5) addBox(beams, b.x, top + .38, b.z + z, ow, .18, .09);
  }
  if (b.solar) {
   for (let z = -b.d / 2 + 2.5; z < b.d / 2 - 2; z += 3.4) for (let x = -b.w / 2 + 2; x < b.w / 2 - 2; x += 2.15) panels.push({ x: b.x + x, y: b.h + 1.05, z: b.z + z, sx: 2, sy: .06, sz: 1.9, rx: -.38 });
  }
 }
 // Sports hall with a curved standing-seam roof.
 {
  const hall = new THREE.Group(); hall.position.set(HALL.x, 0, HALL.z); root.add(hall);
  const wall = new THREE.Mesh(facadeBox(HALL.w, HALL.h, HALL.d, .3), [facades.slots[0], facades.slots[0], roof, roof, facades.slots[0], facades.slots[0]]); wall.position.y = HALL.h / 2; wall.castShadow = wall.receiveShadow = true; hall.add(wall);
  const vault = new THREE.Mesh(new THREE.CylinderGeometry(HALL.d / 2 + .6, HALL.d / 2 + .6, HALL.w + 1, 48, 1, false, -Math.PI / 2, Math.PI), new THREE.MeshStandardMaterial({ color: '#cfd3d4', roughness: .38, metalness: .55 }));
  vault.rotation.z = Math.PI / 2; vault.scale.set(.28, 1, 1); vault.position.y = HALL.h; vault.castShadow = vault.receiveShadow = true; hall.add(vault);
 }
 // Solar canopy parking.
 for (let row = 0; row < 5; row++) {
  const z = PARKING.z - PARKING.d / 2 + 6 + row * 11;
  for (let x = PARKING.x - PARKING.w / 2 + 2; x < PARKING.x + PARKING.w / 2 - 2; x += 2.1) panels.push({ x, y: 3.4, z, sx: 2, sy: .08, sz: 6.4, rx: .14 });
  for (let x = PARKING.x - PARKING.w / 2 + 4; x < PARKING.x + PARKING.w / 2; x += 9) addBox(beams, x, 1.7, z, .25, 3.4, .25);
 }

 for (let z = SOLAR_FIELD.z - SOLAR_FIELD.d / 2 + 4; z < SOLAR_FIELD.z + SOLAR_FIELD.d / 2; z += 8) {
  for (let x = SOLAR_FIELD.x - SOLAR_FIELD.w / 2; x < SOLAR_FIELD.x + SOLAR_FIELD.w / 2; x += 2.1) panels.push({ x, y: 1.7, z, sx: 2, sy: .06, sz: 4.2, rx: .42 });
  for (let x = SOLAR_FIELD.x - SOLAR_FIELD.w / 2 + 2; x < SOLAR_FIELD.x + SOLAR_FIELD.w / 2; x += 6) { addBox(beams, x, 1.25, z - 1.4, .12, 2.5, .12); addBox(beams, x, .7, z + 1.4, .12, 1.4, .12); }
 }
 const instancedBoxes = (list, material, name, shadow = true) => {
  const mesh = new THREE.InstancedMesh(unit, material, list.length), m = new THREE.Matrix4(), q = new THREE.Quaternion(), e = new THREE.Euler();
  list.forEach((o, i) => { e.set(o.rx || 0, o.ry || 0, 0); q.setFromEuler(e); m.compose(new THREE.Vector3(o.x, o.y, o.z), q, new THREE.Vector3(o.sx, o.sy, o.sz)); mesh.setMatrixAt(i, m); });
  mesh.name = name; mesh.castShadow = shadow; mesh.receiveShadow = true; mesh.frustumCulled = false; root.add(mesh); return mesh;
 };
 instancedBoxes(beams, steel, 'pergola-crowns');
 instancedBoxes(equipment, new THREE.MeshStandardMaterial({ color: '#b9b5ac', roughness: .8 }), 'roof-plant');
 instancedBoxes(panels, panel, 'solar-panels');

 // Paved campus core and the brighter courtyard.
 const paveCanvas = canvas(512), pg = paveCanvas.getContext('2d');
 pg.fillStyle = '#c4b49a'; pg.fillRect(0, 0, 512, 512);
 for (let y = 0; y < 512; y += 64) for (let x = 0; x < 512; x += 128) { const t = random(); pg.fillStyle = `rgb(${212 + t * 16 | 0},${199 + t * 13 | 0},${176 + t * 11 | 0})`; pg.fillRect(x + (y / 64 % 2) * 64 + 1, y + 1, 126, 62); }
 for (let i = 0; i < 4000; i++) { pg.fillStyle = `rgba(100,90,75,${random() * .08})`; pg.fillRect(random() * 512, random() * 512, 2, 2); }
 const paveMap = canvasTexture(paveCanvas); paveMap.repeat.set(1, 1);
 const pavingMaterial = new THREE.MeshStandardMaterial({ map: paveMap, roughness: .92 });
 const paved = (x0, x1, z0, z1, y, scale) => {
  const g = new THREE.PlaneGeometry(x1 - x0, z1 - z0); g.rotateX(-Math.PI / 2);
  const uv = g.attributes.uv; for (let i = 0; i < uv.count; i++) uv.setXY(i, uv.getX(i) * (x1 - x0) / scale, uv.getY(i) * (z1 - z0) / scale);
  const m = new THREE.Mesh(g, pavingMaterial); m.position.set((x0 + x1) / 2, y, (z0 + z1) / 2); m.receiveShadow = true; root.add(m); return m;
 };
 paved(-74, 68, -90, 104, .02, 12);
 paved(COURTYARD.x0, COURTYARD.x1, COURTYARD.z0, COURTYARD.z1, .05, 7.2);
 paved(PARKING.x - PARKING.w / 2, PARKING.x + PARKING.w / 2, PARKING.z - PARKING.d / 2, PARKING.z + PARKING.d / 2, .02, 20).material = new THREE.MeshStandardMaterial({ color: '#77756f', roughness: .9 });
 // Planters with shrubs in the courtyard.
 const shrubMat = new THREE.MeshStandardMaterial({ color: '#5d7343', roughness: .95 });
 for (const [x, z, w, d] of [[-24, 8, 4, 14], [22, 8, 4, 14], [-2, 22, 14, 3.5], [-18, -6, 6, 3], [14, -14, 6, 3]]) {
  const p = new THREE.Mesh(new THREE.BoxGeometry(w, .7, d), stone); p.position.set(x, .4, z); p.castShadow = p.receiveShadow = true; root.add(p);
  for (let i = 0; i < Math.round(w * d / 5); i++) { const s = new THREE.Mesh(new THREE.IcosahedronGeometry(.7 + random() * .5, 1), shrubMat); s.position.set(x + (random() - .5) * (w - 1), 1.0, z + (random() - .5) * (d - 1)); s.scale.y = .7; s.castShadow = true; root.add(s); }
 }

 // Courtyard landscape: a blue-tiled water channel running south from the waterwheel, lawns, benches and lamps.
 const waterCanvas = canvas(128), wc = waterCanvas.getContext('2d');
 for (let y = 0; y < 128; y++) for (let x = 0; x < 128; x++) { const v = 128 + Math.sin(x / 128 * Math.PI * 6 + Math.sin(y / 128 * Math.PI * 4) * 1.5) * 30 + Math.sin(y / 128 * Math.PI * 10) * 14; wc.fillStyle = `rgb(${v | 0},${(128 + Math.cos(y / 128 * Math.PI * 8 + x / 40) * 26) | 0},255)`; wc.fillRect(x, y, 1, 1); }
 const waterNormal = canvasTexture(waterCanvas, false); waterNormal.repeat.set(1, 2.5);
 const water = new THREE.MeshStandardMaterial({ color: '#4a9bb0', roughness: .08, metalness: .05, normalMap: waterNormal, normalScale: new THREE.Vector2(.35, .35), envMapIntensity: 1.5 });
 const tileCanvas = canvas(128), tc = tileCanvas.getContext('2d'); tc.fillStyle = '#4f8fa2'; tc.fillRect(0, 0, 128, 128); tc.strokeStyle = '#d8e4e4'; tc.lineWidth = 3; for (let i = 0; i <= 128; i += 32) { tc.beginPath(); tc.moveTo(i, 0); tc.lineTo(i, 128); tc.moveTo(0, i); tc.lineTo(128, i); tc.stroke(); }
 const tileMap = canvasTexture(tileCanvas); tileMap.repeat.set(1, 4);
 // A reflecting pool in front of the waterwheel (kept short so paths can pass its south end).
 const channel = new THREE.Group(); channel.position.set(WATERWHEEL.x, 0, -15); root.add(channel);
 const bed = new THREE.Mesh(new THREE.BoxGeometry(3, .3, 14), new THREE.MeshStandardMaterial({ map: tileMap, roughness: .5 })); bed.position.y = .1; bed.receiveShadow = true; channel.add(bed);
 const surface = new THREE.Mesh(new THREE.PlaneGeometry(2.7, 13.6).rotateX(-Math.PI / 2), water); surface.position.y = .32; surface.receiveShadow = true; channel.add(surface);
 for (const x of [-1.65, 1.65]) { const c = new THREE.Mesh(new THREE.BoxGeometry(.4, .5, 14.4), stone); c.position.set(x, .25, 0); c.castShadow = c.receiveShadow = true; channel.add(c); }
 const grassCanvas = canvas(256), gc = grassCanvas.getContext('2d'); gc.fillStyle = '#5d7a37'; gc.fillRect(0, 0, 256, 256);
 for (let i = 0; i < 9000; i++) { const t = random(); gc.fillStyle = `rgba(${70 + t * 60 | 0},${100 + t * 50 | 0},${40 + t * 20 | 0},.6)`; gc.fillRect(random() * 256, random() * 256, 1.5, 3); }
 const grassMap = canvasTexture(grassCanvas); grassMap.repeat.set(3, 3);
 const lawnMaterial = new THREE.MeshStandardMaterial({ map: grassMap, roughness: 1 }), benches = [];
 for (const [x0, x1, z0, z1] of [[-22, -12.5, -2, 24], [6, 18, -10, 22]]) {
  const lawn = new THREE.Mesh(new THREE.BoxGeometry(x1 - x0, .25, z1 - z0), lawnMaterial); lawn.position.set((x0 + x1) / 2, .12, (z0 + z1) / 2); lawn.receiveShadow = true; root.add(lawn);
  for (const [sx, sz, px, pz] of [[x1 - x0 + .5, .25, 0, (z1 - z0) / 2], [x1 - x0 + .5, .25, 0, -(z1 - z0) / 2], [.25, z1 - z0, (x1 - x0) / 2, 0], [.25, z1 - z0, -(x1 - x0) / 2, 0]]) { const k = new THREE.Mesh(new THREE.BoxGeometry(sx, .45, sz), stone); k.position.set((x0 + x1) / 2 + px, .22, (z0 + z1) / 2 + pz); k.castShadow = k.receiveShadow = true; root.add(k); }
  for (let z = z0 + 3; z < z1 - 2; z += 6) for (const x of [x0 - 1.1, x1 + 1.1]) addBox(benches, x, .24, z, .55, .45, 2);
 }
 const lampGroup = [], lampHeads = [];
 for (const [x, z] of [[-28, -30], [-28, 0], [-28, 30], [26, -30], [26, 0], [26, 30], [-6, 30], [6, -34], [-40, 70], [40, 75], [0, 100], [-60, 30], [60, 20]]) { lampGroup.push({ x, y: 2.1, z, sx: .12, sy: 4.2, sz: .12 }); lampHeads.push({ x, y: 4.35, z, sx: .5, sy: .3, sz: .5 }); }
 const lampMaterial = new THREE.MeshStandardMaterial({ color: '#333', emissive: '#ffc27a', emissiveIntensity: 6, roughness: .5 });
 instancedBoxes(benches, new THREE.MeshStandardMaterial({ color: '#8a6d52', roughness: .8 }), 'benches');
 instancedBoxes(lampGroup, steel, 'courtyard-lamp-posts'); instancedBoxes(lampHeads, lampMaterial, 'courtyard-lamps', false);

 // Real GJU landmarks reused from the existing project models.
 const courtyard = createCourtyardModel({ textureSize: 512 });
 const cBox = new THREE.Box3().setFromObject(courtyard.root), cSize = cBox.getSize(new THREE.Vector3());
 const cScale = 12 / Math.max(cSize.x, cSize.z);
 courtyard.root.scale.setScalar(cScale); courtyard.root.position.set(WATERWHEEL.x, .05 - cBox.min.y * cScale, WATERWHEEL.z);
 courtyard.root.traverse(o => { if (o.isMesh) { o.castShadow = true; o.receiveShadow = true; } });
 root.add(courtyard.root);
 let gate = null;
 try {
  gate = await withTimeout(createGateModel(logoUrl), 4000);
  if (!gate) throw new Error("gate timed out");
  gate.root.position.set(GATE.x, groundHeight(GATE.x, GATE.z) + .1, GATE.z); gate.root.rotation.y = GATE.rotation;
  gate.root.traverse(o => { if (o.isMesh) { o.castShadow = true; o.receiveShadow = true; } });
  root.add(gate.root);
 } catch (_) { gate = null; }

 return {
  root, courtyardSize: cSize.multiplyScalar(cScale),
  update(time, lights) {
   courtyard.wheel.rotation.z -= .0045;
   gate?.updateCloth(time, .9);
   for (const f of allFacades) f.emissiveIntensity = lights * 2.6;
   glass.emissiveIntensity = .05 + lights * .6;
   lampMaterial.emissiveIntensity = lights * 9;
   waterNormal.offset.y = -time * .02; waterNormal.offset.x = Math.sin(time * .3) * .02;
  }
 };
}
