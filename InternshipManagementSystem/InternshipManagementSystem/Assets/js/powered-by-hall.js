import * as THREE from './vendor/three.module.min.js';

// Meet the Team lecture hall. A fan-shaped, tiered hall seen from the lecturer's area,
// built procedurally (no model downloads) in the GJU material language: limestone-tone
// cladding, oak, navy upholstery and a clerestory window band. It is an interpretation,
// not a reconstruction of a specific GJU room. Rendering is on demand; nothing loops idle.

// SEAT_BACK: seat centre behind the row radius; the desk's near edge sits 12 cm in front of it.
const SEAT_BACK = .14, ROWS = 7, R0 = 6.2, DEPTH = 1.05, RISE = .36, SEAT_W = .62, AISLE = 1.15, WALL_R = 13.7, CEILING = 7.9;
const ARC = THREE.MathUtils.degToRad(60), SIDE = THREE.MathUtils.degToRad(70), SPLIT = THREE.MathUtils.degToRad(20);
const rowRadius = row => R0 + row*DEPTH, rowTop = row => (row+1)*RISE;
const polar = (radius, angle, y = 0) => new THREE.Vector3(radius*Math.sin(angle), y, -radius*Math.cos(angle));

function seeded(seed) { return () => { seed = (Math.imul(seed,1664525)+1013904223)>>>0; return seed/4294967296; }; }
function hash(text) { let h = 2166136261; for (const c of text) h = Math.imul(h ^ c.charCodeAt(0), 16777619); return h >>> 0; }

// ---- Layout: blocks, aisles and stable seat ids (block + row + seat from the left, e.g. C4-5). ----
function hallLayout() {
 const blocks = [], aisles = [], seats = [];
 for (let row = 0; row < ROWS; row++) {
  const radius = rowRadius(row), a = AISLE/2/radius;
  const ranges = { L:[-ARC,-SPLIT-a], C:[-SPLIT+a,SPLIT-a], R:[SPLIT+a,ARC] };
  aisles.push([row,-SIDE,-ARC],[row,-SPLIT-a,-SPLIT+a],[row,SPLIT-a,SPLIT+a],[row,ARC,SIDE]);
  for (const [block,[a0,a1]] of Object.entries(ranges)) {
   const count = Math.floor((a1-a0)*radius/SEAT_W), step = (a1-a0)/count;
   blocks.push({ row, a0, a1 });
   for (let i = 0; i < count; i++) seats.push({ id:`${block}${row+1}-${i+1}`, row, angle:a0+(i+.5)*step, last:i === count-1 });
  }
 }
 return { blocks, aisles, seats };
}

// ---- Geometry helpers ----
// Annular sector between two radii and angles, extruded upward; UVs are in metres.
function sector(r0, r1, a0, a1, height, y = 0) {
 const shape = new THREE.Shape(), n = Math.max(3, Math.ceil((a1-a0)*r1/.3));
 for (let i = 0; i <= n; i++) { const t = a0+(a1-a0)*i/n; shape[i ? 'lineTo' : 'moveTo'](r1*Math.sin(t), r1*Math.cos(t)); }
 for (let i = n; i >= 0; i--) { const t = a0+(a1-a0)*i/n; shape.lineTo(r0*Math.sin(t), r0*Math.cos(t)); }
 const geometry = new THREE.ExtrudeGeometry(shape, { depth:height, bevelEnabled:false, curveSegments:1 });
 geometry.rotateX(-Math.PI/2); geometry.translate(0, y, 0); return geometry;
}
function roundedRect(width, height, radius) {
 const shape = new THREE.Shape(), x = -width/2, y = -height/2;
 shape.moveTo(x+radius, y); shape.lineTo(x+width-radius, y); shape.absarc(x+width-radius, y+radius, radius, -Math.PI/2, 0);
 shape.lineTo(x+width, y+height-radius); shape.absarc(x+width-radius, y+height-radius, radius, 0, Math.PI/2);
 shape.lineTo(x+radius, y+height); shape.absarc(x+radius, y+height-radius, radius, Math.PI/2, Math.PI);
 shape.lineTo(x, y+radius); shape.absarc(x+radius, y+radius, radius, Math.PI, Math.PI*1.5); return shape;
}
function cushion(width, depth, thickness, radius) {
 const geometry = new THREE.ExtrudeGeometry(roundedRect(width, depth, radius), { depth:thickness, bevelEnabled:true, bevelThickness:.018, bevelSize:.018, bevelSegments:3, curveSegments:5 });
 geometry.center(); return geometry;
}
// Merge many geometries into one, keeping one draw group per material index.
function mergeByMaterial(list) {
 const buckets = new Map();
 for (const original of list) {
  const geometry = original.index ? original.toNonIndexed() : original;
  const groups = geometry.groups.length ? geometry.groups : [{ start:0, count:geometry.attributes.position.count, materialIndex:0 }];
  for (const group of groups) {
   if (!buckets.has(group.materialIndex)) buckets.set(group.materialIndex, { position:[], normal:[], uv:[] });
   const bucket = buckets.get(group.materialIndex), count = Math.min(group.count, geometry.attributes.position.count-group.start);
   for (const [name, size] of [['position',3],['normal',3],['uv',2]]) {
    const source = geometry.attributes[name].array, target = bucket[name];
    for (let i = group.start*size, end = (group.start+count)*size; i < end; i++) target.push(source[i]);
   }
  }
  if (geometry !== original) geometry.dispose(); original.dispose();
 }
 const merged = new THREE.BufferGeometry(), position = [], normal = [], uv = [];
 let start = 0;
 for (const [materialIndex, bucket] of [...buckets].sort((a,b) => a[0]-b[0])) {
  const count = bucket.position.length/3; merged.addGroup(start, count, materialIndex); start += count;
  for (const v of bucket.position) position.push(v); for (const v of bucket.normal) normal.push(v); for (const v of bucket.uv) uv.push(v);
 }
 merged.setAttribute('position', new THREE.Float32BufferAttribute(position,3));
 merged.setAttribute('normal', new THREE.Float32BufferAttribute(normal,3));
 merged.setAttribute('uv', new THREE.Float32BufferAttribute(uv,2));
 return merged;
}
const withMaterial = (geometry, index) => { geometry.groups.forEach(group => group.materialIndex = index); return geometry; };

// ---- Procedural textures at real-world scale (UVs in metres unless noted) ----
function canvasTexture(size, draw, repeat = 1) {
 const canvas = document.createElement('canvas'); canvas.width = canvas.height = size;
 draw(canvas.getContext('2d'), size);
 const texture = new THREE.CanvasTexture(canvas); texture.colorSpace = THREE.SRGBColorSpace;
 texture.wrapS = texture.wrapT = THREE.RepeatWrapping; texture.repeat.set(repeat, repeat); texture.anisotropy = 8; return texture;
}
const noise = (c, size, count, colors, random, w = 1.5, h = 1.5) => {
 for (let i = 0; i < count; i++) { c.fillStyle = colors[i % colors.length]; c.fillRect(random()*size, random()*size, w, h); }
};
// Carpet: fine heathered loop pile, one tile = 0.5 m.
const carpetTexture = () => canvasTexture(256, (c, s) => { c.fillStyle = '#7d848c'; c.fillRect(0,0,s,s); noise(c, s, 9000, ['#6d747c','#8c939b','#757c85','#646b73'], seeded(11), 1.2, 1.2); }, 2);
// Oak veneer: long, straight grain; one tile = 1.2 m.
const oakTexture = () => canvasTexture(512, (c, s) => {
 const random = seeded(23); c.fillStyle = '#c7a27a'; c.fillRect(0,0,s,s);
 for (let i = 0; i < 260; i++) { const y = random()*s, tone = random(); c.strokeStyle = tone < .5 ? 'rgba(120,80,45,.10)' : 'rgba(250,225,190,.10)'; c.lineWidth = .6+random()*1.6; c.beginPath(); c.moveTo(0,y); for (let x = 0; x <= s; x += 32) c.lineTo(x, y+Math.sin(x*.01+i)*2.2); c.stroke(); }
}, 1/1.2);
// Floor: oak strip flooring, 0.18 m boards, staggered; one tile = 2.16 m (plane UVs are 0..1, so repeat is set per use).
const floorTexture = () => canvasTexture(512, (c, s) => {
 const random = seeded(37), board = s/12;
 for (let row = 0; row < 12; row++) for (let x = -random()*s; x < s; x += s*(.4+random()*.35)) {
  const tone = 168+Math.floor(random()*26); c.fillStyle = `rgb(${tone+22},${tone-6},${tone-46})`; c.fillRect(x, row*board, s, board-1.2);
  c.fillStyle = 'rgba(70,45,25,.35)'; c.fillRect(x, row*board, 1.2, board);
 }
 noise(c, s, 3000, ['rgba(90,60,30,.08)','rgba(255,235,200,.08)'], random, 6, 1);
});
// Upholstery: a soft woven texture; one tile = 0.125 m.
const fabricTexture = () => canvasTexture(128, (c, s) => {
 c.fillStyle = '#8a8f96'; c.fillRect(0,0,s,s);
 for (let y = 0; y < s; y += 2) { c.fillStyle = y % 4 ? 'rgba(255,255,255,.05)' : 'rgba(0,0,0,.07)'; c.fillRect(0,y,s,1); }
 noise(c, s, 1200, ['rgba(0,0,0,.08)','rgba(255,255,255,.06)'], seeded(5));
}, 8);
// Clerestory view: bright daylight sky with faint cloud; UVs span the glass band.
function skyTexture() {
 const canvas = document.createElement('canvas'); canvas.width = 1024; canvas.height = 128;
 const c = canvas.getContext('2d'), g = c.createLinearGradient(0,0,0,128);
 g.addColorStop(0,'#c6dcf2'); g.addColorStop(1,'#eef4f8'); c.fillStyle = g; c.fillRect(0,0,1024,128);
 const random = seeded(3);
 for (let i = 0; i < 26; i++) { const x = random()*1024, y = 20+random()*70, r = 30+random()*60, cloud = c.createRadialGradient(x,y,0,x,y,r); cloud.addColorStop(0,'rgba(255,255,255,.55)'); cloud.addColorStop(1,'rgba(255,255,255,0)'); c.fillStyle = cloud; c.fillRect(x-r,y-r,r*2,r*2); }
 const texture = new THREE.CanvasTexture(canvas); texture.colorSpace = THREE.SRGBColorSpace; return texture;
}
const blobTexture = () => canvasTexture(64, (c, s) => {
 const g = c.createRadialGradient(s/2,s/2,2,s/2,s/2,s/2); g.addColorStop(0,'rgba(0,0,0,.55)'); g.addColorStop(.6,'rgba(0,0,0,.22)'); g.addColorStop(1,'rgba(0,0,0,0)');
 c.fillStyle = g; c.fillRect(0,0,s,s);
});
// Seat marker: a GJU-blue dot with a light core and a soft edge; normal blending reads on light and dark surfaces.
const glowTexture = () => canvasTexture(64, (c, s) => {
 const g = c.createRadialGradient(s/2,s/2,0,s/2,s/2,s/2); g.addColorStop(0,'rgba(235,247,255,1)'); g.addColorStop(.22,'rgba(70,170,230,1)'); g.addColorStop(.42,'rgba(0,128,200,.75)'); g.addColorStop(.7,'rgba(0,110,190,.18)'); g.addColorStop(1,'rgba(0,100,180,0)');
 c.fillStyle = g; c.fillRect(0,0,s,s);
});
// University sign: official logo with the bilingual name, navy on transparent.
async function signTexture(logoUrl) {
 const logo = new Image(); logo.src = logoUrl; await logo.decode().catch(() => null);
 const canvas = document.createElement('canvas'); canvas.width = 1600; canvas.height = 320;
 const c = canvas.getContext('2d');
 if (logo.naturalWidth) c.drawImage(logo, 20, 40, 320, 240);
 c.fillStyle = '#1e3550'; c.textBaseline = 'middle';
 c.font = '600 92px "Segoe UI", system-ui, sans-serif'; c.fillText('German Jordanian University', 380, 128, 1200);
 c.font = '500 64px "Segoe UI", system-ui, sans-serif'; c.direction = 'rtl'; c.textAlign = 'right';
 c.fillText('الجامعة الألمانية الأردنية', 1580, 230, 1200);
 const texture = new THREE.CanvasTexture(canvas); texture.colorSpace = THREE.SRGBColorSpace; texture.anisotropy = 8; return texture;
}

// Soft image-based lighting from a small generated room: daylit clerestory, ceiling strips, side glazing.
function environmentMap(renderer) {
 const env = new THREE.Scene(), disposables = [];
 const add = mesh => { env.add(mesh); disposables.push(mesh.geometry, mesh.material); return mesh; };
 add(new THREE.Mesh(new THREE.BoxGeometry(30,10,30), new THREE.MeshLambertMaterial({ color:'#8f8273', side:THREE.BackSide }))).position.y = 5;
 env.add(new THREE.AmbientLight('#ffffff', 1.2));
 const panel = (w, h, color, strength, position, rotation) => {
  const mesh = add(new THREE.Mesh(new THREE.PlaneGeometry(w,h), new THREE.MeshBasicMaterial({ color:new THREE.Color(color).multiplyScalar(strength), side:THREE.DoubleSide })));
  mesh.position.set(...position); mesh.rotation.set(...rotation);
 };
 panel(26,2.4,'#d6e7fb',5,[0,7.4,-14.9],[0,0,0]);
 for (const z of [-10,-5,0]) panel(22,.5,'#fff2df',7,[0,9.9,z],[Math.PI/2,0,0]);
 panel(12,5,'#e4eefb',2.5,[-14.9,4,2],[0,Math.PI/2,0]);
 const pmrem = new THREE.PMREMGenerator(renderer), target = pmrem.fromScene(env, .04);
 pmrem.dispose(); disposables.forEach(item => item.dispose());
 return target;
}

// ---- People: seated adults built from smooth shared parts, posed in seat space (+z toward the desk). ----
const SKINS = ['#efcfb4','#e2b796','#cf9f7c','#b9845f','#9a6748','#7a4d34'];
const CLOTHES = ['#5b6672','#8c9198','#b8b0a3','#6a7868','#7d665a','#d8d3ca','#465568','#9ba7b3','#6b5f55','#3f4752','#a28f7c','#55636e','#c4b7a3'];
const PANTS = ['#2f3540','#3b3f48','#22303f','#4c4944','#596370','#2b2b2e'];
const HAIR = ['#1c1814','#2d2119','#4a3424','#262422','#6a4e34','#3a2b20'];
const HIJABS = ['#c7b8a6','#5f4855','#2e3c52','#e2dbd0','#7f6756','#3d5756','#9aa8b4','#a78172','#4b4f5c'];
const SHOES = ['#1f2023','#3a2f27','#e9e6e0','#2c3440'];
const limbGeometry = (top, bottom) => () => new THREE.CylinderGeometry(top, bottom, 1, 12, 1);
const sphere = (r, w = 16, h = 12) => () => new THREE.SphereGeometry(r, w, h);
const PART = {
 torso: () => new THREE.LatheGeometry([[0,0],[.125,0],[.14,.05],[.15,.15],[.163,.26],[.17,.33],[.158,.39],[.115,.435],[.05,.46],[0,.462]].map(([x,y]) => new THREE.Vector2(x,y)), 24),
 pelvis: sphere(.1), joint: sphere(.055, 12, 10), elbow: sphere(.044, 10, 8), knee: sphere(.062, 12, 10),
 upperArm: limbGeometry(.054,.044), forearm: limbGeometry(.042,.032), thigh: limbGeometry(.08,.062), shin: limbGeometry(.058,.045), neck: limbGeometry(.044,.05),
 hand: sphere(.045, 12, 8), shoe: sphere(.05, 12, 8), head: sphere(.1, 24, 18), jaw: sphere(.072, 18, 12), nose: sphere(.018, 8, 6), ear: sphere(.022, 8, 6),
 hairBack: sphere(.1, 20, 14), hairCap: () => new THREE.SphereGeometry(.104, 24, 12, 0, Math.PI*2, 0, Math.PI*.5),
 hairFall: () => new THREE.CapsuleGeometry(.085, .2, 4, 12), bun: sphere(.048, 12, 10),
 hijab: () => new THREE.SphereGeometry(.113, 24, 16, Math.PI/2+.72, Math.PI*2-1.44, 0, Math.PI*.82),
 drape: () => new THREE.LatheGeometry([[.06,.1],[.09,.06],[.15,-.02],[.19,-.08],[.195,-.1]].map(([x,y]) => new THREE.Vector2(x,y)), 24, Math.PI*.12, Math.PI*1.76),
 collar: () => new THREE.TorusGeometry(.052, .012, 6, 20), hood: sphere(.09, 14, 10),
 laptopBase: () => new THREE.BoxGeometry(.32,.014,.22), laptopScreen: () => new THREE.BoxGeometry(.32,.21,.008),
 notebook: () => new THREE.BoxGeometry(.21,.008,.28), pen: () => new THREE.CylinderGeometry(.005,.005,.14,6).rotateZ(Math.PI/2)
};
const ROUGH = { head:.55, jaw:.55, nose:.55, ear:.55, hand:.55, neck:.55, laptopBase:.35, laptopScreen:.2, shoe:.5 };
const local = (position, rotation = [0,0,0], scale = [1,1,1]) => new THREE.Matrix4().compose(new THREE.Vector3(...position), new THREE.Quaternion().setFromEuler(new THREE.Euler(...rotation)), new THREE.Vector3(...scale));
function limb(from, to) {
 const a = new THREE.Vector3(...from), b = new THREE.Vector3(...to), length = a.distanceTo(b);
 return new THREE.Matrix4().compose(a.clone().add(b).multiplyScalar(.5), new THREE.Quaternion().setFromUnitVectors(new THREE.Vector3(0,1,0), a.sub(b).normalize()), new THREE.Vector3(1,length,1));
}
function lookFor(random) {
 const pick = list => list[Math.floor(random()*list.length)], style = random(), item = random();
 const shirt = pick(CLOTHES), skin = pick(SKINS);
 return { skin, shirt, sleeve:random() < .62 ? shirt : skin, trim:'#' + new THREE.Color(shirt).multiplyScalar(.82).getHexString(), pants:pick(PANTS), shoe:pick(SHOES), hair:pick(HAIR), hijab:pick(HIJABS),
  style: style < .28 ? 'hijab' : style < .44 ? 'long' : style < .52 ? 'bun' : 'short', top:random() < .3 ? 'hoodie' : 'collar',
  item: item < .48 ? 'laptop' : item < .82 ? 'notebook' : 'none', device:'#2b2e33', paper:'#f2eee6', lean:(random()-.5)*.08, turn:(random()-.5)*.3 };
}
function personParts(look) {
 const parts = [], push = (part, matrix, role) => parts.push([part, matrix, role]);
 push('pelvis', local([0,.6,.02],[0,0,0],[1.55,1,1.25]), 'pants');
 for (const s of [-1,1]) {
  push('thigh', limb([s*.09,.6,.02],[s*.1,.6,.44]), 'pants');
  push('knee', local([s*.1,.6,.45]), 'pants');
  push('shin', limb([s*.1,.6,.46],[s*.1,.1,.5]), 'pants');
  push('shoe', local([s*.1,.055,.56],[0,0,0],[1,.75,2.1]), 'shoe');
  push('joint', local([s*.17,.95,.01]), 'shirt');
  push('upperArm', limb([s*.18,.95,.01],[s*.22,.79,.28]), 'shirt');
  push('elbow', local([s*.22,.785,.285]), 'sleeve');
  push('forearm', limb([s*.22,.785,.29],[s*.12,.775,.52]), 'sleeve');
  push('hand', local([s*.1,.766,.58],[0,s*.35,0],[.85,.5,1.4]), 'skin');
 }
 push('torso', local([0,.6,0],[.06+look.lean,0,0],[1,1,.68]), 'shirt');
 if (look.top === 'hoodie') push('hood', local([0,1.0,-.09],[0,0,0],[1.6,.8,.9]), 'trim');
 else push('collar', local([0,1.03,.035],[Math.PI/2,0,0]), 'trim');
 push('neck', limb([0,1.1,.04],[0,1.02,.03]), 'skin');
 // Head parts turn together around the neck for a less uniform crowd.
 const head = (position, rotation = [0,0,0], scale = [1,1,1]) => new THREE.Matrix4().makeRotationY(look.turn).multiply(local(position, rotation, scale));
 push('head', head([0,1.2,.05],[0,0,0],[.86,1.08,.97]), 'skin');
 push('jaw', head([0,1.14,.075],[0,0,0],[.92,.78,.95]), 'skin');
 push('nose', head([0,1.195,.148],[0,0,0],[1,1.3,1.5]), 'skin');
 if (look.style === 'hijab') {
  push('hijab', head([0,1.205,.045],[0,0,0],[.9,1.08,1]), 'hijab');
  push('drape', local([0,1.08,.03],[0,0,0],[.85,.75,.75]), 'hijab');
 } else {
  for (const s of [-1,1]) push('ear', head([s*.087,1.2,.04],[0,0,0],[.6,1,.9]), 'skin');
  push('hairBack', head([0,1.215,.028],[0,0,0],[.9,1.05,.93]), 'hair');
  push('hairCap', head([0,1.205,.05],[-.32,0,0],[.88,1.1,.98]), 'hair');
  if (look.style === 'long') push('hairFall', head([0,1.08,-.035],[.1,0,0],[1.25,1,.7]), 'hair');
  if (look.style === 'bun') push('bun', head([0,1.3,-.03]), 'hair');
 }
 if (look.item === 'laptop') {
  push('laptopBase', local([0,.749,.6]), 'device');
  push('laptopScreen', local([0,.854,.742],[.3,0,0]), 'device');
 } else if (look.item === 'notebook') {
  push('notebook', local([.04,.745,.58],[0,.2,0]), 'paper');
  push('pen', local([.17,.752,.58],[0,.55,0]), 'device');
 }
 return parts;
}

// ---- Seated Rocketbox figures (Assets/models/people, MIT; see LICENSE.md there) ----
const FIGURES = ['Female_Adult_04','Female_Adult_06','Female_Adult_08','Female_Adult_09','Female_Adult_14','Male_Adult_06','Male_Adult_09','Male_Adult_11','Male_Adult_17','Male_Adult_18'];
// Phones load a lighter five-figure cast (about 2 MB instead of 5 MB).
const COMPACT_FIGURES = ['Female_Adult_06','Female_Adult_08','Male_Adult_11','Male_Adult_17','Male_Adult_18'];
const DESK_ITEMS = new Set(['laptopBase','laptopScreen','notebook','pen']);
async function loadFigures(compact) {
 const { GLTFLoader } = await import('./vendor/addons/loaders/GLTFLoader.js');
 const loader = new GLTFLoader(), base = new URL('../models/people/', import.meta.url);
 return Promise.all((compact ? COMPACT_FIGURES : FIGURES).map(async name => {
  const gltf = await loader.loadAsync(new URL(name + '.glb', base).href);
  // GLTFLoader splits a multi-material mesh into primitives that share one vertex buffer.
  // Rebuild a single indexed geometry with one group per material so each figure is one instanced mesh.
  const parts = []; gltf.scene.traverse(object => { if (object.isMesh) parts.push(object); });
  const shared = parts[0].geometry, materials = [], byMaterial = new Map();
  for (const part of parts) {
   if (part.geometry.attributes.position !== shared.attributes.position) throw new Error(name + ': unexpected vertex layout');
   const key = part.material.name;
   if (!byMaterial.has(key)) { byMaterial.set(key, []); materials.push(part.material); }
   const target = byMaterial.get(key); for (const value of part.geometry.index.array) target.push(value);
  }
  const geometry = new THREE.BufferGeometry(), index = [];
  for (const name of ['position','normal','uv']) geometry.setAttribute(name, shared.attributes[name]);
  [...byMaterial.values()].forEach((values, materialIndex) => { geometry.addGroup(index.length, values.length, materialIndex); for (const value of values) index.push(value); });
  geometry.setIndex(index); geometry.computeBoundingSphere();
  for (const material of materials) { material.roughness = .8; material.metalness = 0; if (material.map) material.map.anisotropy = 4; }
  return { name, geometry, materials };
 }));
}

// ---- Scene ----
export async function createLectureHall({ container, members, logo, reducedMotion, onProgress, onHover, onSelect, onLost, onCamera }) {
 const progress = async (value, label) => { onProgress?.(value, label); await new Promise(requestAnimationFrame); };
 const compact = Math.min(innerWidth, innerHeight) < 700 || matchMedia('(pointer: coarse)').matches;
 await progress(.08, 'Preparing the lecture hall');
 const probe = document.createElement('canvas');
 if (!probe.getContext('webgl2') && !probe.getContext('webgl')) throw new Error('WebGL is not available');
 const renderer = new THREE.WebGLRenderer({ antialias:!compact, powerPreference:'high-performance' });
 renderer.setPixelRatio(Math.min(devicePixelRatio, compact ? 1.25 : 1.6));
 renderer.outputColorSpace = THREE.SRGBColorSpace; renderer.toneMapping = THREE.ACESFilmicToneMapping; renderer.toneMappingExposure = 1.02;
 renderer.shadowMap.enabled = !compact; renderer.shadowMap.type = THREE.PCFSoftShadowMap;
 container.appendChild(renderer.domElement);
 const scene = new THREE.Scene(), envTarget = environmentMap(renderer);
 scene.background = new THREE.Color('#2c2723'); scene.environment = envTarget.texture; scene.environmentIntensity = .85;
 const textures = [];
 const tex = texture => { textures.push(texture); return texture; };
 const shadowed = (mesh, cast = true) => { mesh.castShadow = cast && !compact; mesh.receiveShadow = !compact; return mesh; };

 // Light: daylight from the high side glazing, a soft frontal fill and one accent for the selected seat.
 scene.add(new THREE.HemisphereLight('#fbf3e8','#5d4d40',.35));
 const sun = new THREE.DirectionalLight('#fff0dc', 2.4); sun.position.set(-16,22,10); sun.target.position.set(0,0,-7);
 sun.castShadow = !compact; sun.shadow.mapSize.set(2048,2048);
 Object.assign(sun.shadow.camera, { left:-17, right:17, top:15, bottom:-15, near:4, far:70 }); sun.shadow.bias = -.0004; sun.shadow.normalBias = .03;
 scene.add(sun, sun.target);
 const fill = new THREE.DirectionalLight('#e9eefb', .55); fill.position.set(5,9,16); scene.add(fill);
 const accent = new THREE.SpotLight('#ffe9cc', 0, 7, .36, .85, 1.4); scene.add(accent, accent.target);

 await progress(.22, 'Building the room');
 const layout = hallLayout();
 const M = {
  carpet: new THREE.MeshStandardMaterial({ color:'#7a8089', map:tex(carpetTexture()), roughness:1 }),
  oak: new THREE.MeshStandardMaterial({ color:'#ffffff', map:tex(oakTexture()), roughness:.5 }),
  oakDark: new THREE.MeshStandardMaterial({ color:'#a98563', map:tex(oakTexture()), roughness:.62 }),
  nosing: new THREE.MeshStandardMaterial({ color:'#b9b6b0', roughness:.35, metalness:.6 }),
  stone: new THREE.MeshStandardMaterial({ color:'#ffffff', roughness:.86 }),
  gap: new THREE.MeshStandardMaterial({ color:'#3a332d', roughness:.9, side:THREE.BackSide }),
  plaster: new THREE.MeshStandardMaterial({ color:'#ebe5db', roughness:.92 }),
  timber: new THREE.MeshStandardMaterial({ color:'#a8805c', roughness:.55, side:THREE.DoubleSide }),
  ceiling: new THREE.MeshStandardMaterial({ color:'#3b342e', roughness:.95 }),
  fabric: new THREE.MeshStandardMaterial({ color:'#3e5a7e', map:tex(fabricTexture()), roughness:.92 }),
  shell: new THREE.MeshStandardMaterial({ color:'#2d3137', roughness:.45, metalness:.2 }),
  glow: new THREE.MeshBasicMaterial({ color:new THREE.Color('#fff4e3').multiplyScalar(1.6) }),
  step: new THREE.MeshBasicMaterial({ color:new THREE.Color('#ffd9a6').multiplyScalar(1.4) })
 };
 const floorMap = tex(floorTexture()); floorMap.repeat.set(30/2.16, 24/2.16);
 const floor = shadowed(new THREE.Mesh(new THREE.PlaneGeometry(30,24), new THREE.MeshStandardMaterial({ map:floorMap, color:'#b59a7c', roughness:.48 })), false);
 floor.rotation.x = -Math.PI/2; floor.position.z = -2; scene.add(floor);

 // Back wall: limestone-tone cladding panels on a dark joint, an oak band, the clerestory and a fascia.
 const wallBase = new THREE.Mesh(new THREE.CylinderGeometry(WALL_R+.02, WALL_R+.02, CEILING, 72, 1, true, Math.PI-SIDE-.03, 2*SIDE+.06), M.gap);
 wallBase.position.y = CEILING/2; scene.add(wallBase);
 const columns = Math.round(2*SIDE*WALL_R/1.25), panelRows = [[2.6,1.15],[3.77,1.15],[4.94,1.15]];
 const panels = shadowed(new THREE.InstancedMesh(new THREE.BoxGeometry(1, 1, .05), M.stone, columns*panelRows.length), false);
 const tint = new THREE.Color(), random = seeded(41); let index = 0;
 const bays = [];
 for (let column = 0; column < columns; column++) {
  const angle = -SIDE + (column+.5)*2*SIDE/columns, width = 2*SIDE*WALL_R/columns - .016;
  // Every fourth bay is a timber acoustic panel of vertical slats instead of stone.
  if (column % 4 === 2 && Math.abs(angle) > .2) { bays.push([angle, width]); continue; }
  for (const [y, height] of panelRows) {
   panels.setMatrixAt(index, new THREE.Matrix4().compose(polar(WALL_R-.03, angle, y+height/2), new THREE.Quaternion().setFromEuler(new THREE.Euler(0,-angle,0)), new THREE.Vector3(width, height-.016, 1)));
   const shade = .93 + random()*.07; panels.setColorAt(index++, tint.setRGB(.92*shade, .87*shade, .78*shade));
  }
 }
 panels.count = index; scene.add(panels);
 const slatsPerBay = 9, baySlats = new THREE.InstancedMesh(new THREE.BoxGeometry(1,3.5,.06), M.timber, bays.length*slatsPerBay);
 bays.forEach(([angle, width], b) => { for (let i = 0; i < slatsPerBay; i++) {
  const offset = (i-(slatsPerBay-1)/2)*width/slatsPerBay, position = polar(WALL_R-.06, angle + offset/WALL_R, 4.35);
  baySlats.setMatrixAt(b*slatsPerBay+i, new THREE.Matrix4().compose(position, new THREE.Quaternion().setFromEuler(new THREE.Euler(0,-angle,0)), new THREE.Vector3(width/slatsPerBay*.62,1,1)));
 } });
 scene.add(shadowed(baySlats, false));
 const band = (y, height, material, radius = WALL_R-.06) => { const mesh = new THREE.Mesh(new THREE.CylinderGeometry(radius, radius, height, 72, 1, true, Math.PI-SIDE-.02, 2*SIDE+.04), material); mesh.position.y = y; scene.add(mesh); return mesh; };
 band(6.2, .26, M.timber);
 band(7.0, 1.3, new THREE.MeshBasicMaterial({ map:tex(skyTexture()), side:THREE.BackSide }), WALL_R+.05);
 band(7.78, .24, M.timber);
 const mullionCount = Math.round(2*SIDE*WALL_R/1.6)+1, mullions = new THREE.InstancedMesh(new THREE.BoxGeometry(.07,1.34,.1), M.shell, mullionCount);
 for (let i = 0; i < mullionCount; i++) { const angle = -SIDE + i*2*SIDE/(mullionCount-1); mullions.setMatrixAt(i, new THREE.Matrix4().compose(polar(WALL_R-.02, angle, 7.0), new THREE.Quaternion().setFromEuler(new THREE.Euler(0,-angle,0)), new THREE.Vector3(1,1,1))); }
 scene.add(mullions);
 const sign = new THREE.Mesh(new THREE.PlaneGeometry(4,.8), new THREE.MeshStandardMaterial({ map:tex(await signTexture(logo)), transparent:true, roughness:.6 }));
 sign.position.copy(polar(WALL_R-.24, 0, 5.25)); scene.add(sign);

 // Side and front walls close the room.
 for (const s of [-1,1]) {
  const a = polar(WALL_R, s*SIDE), b = new THREE.Vector3(s*5.8, 0, 9.5), length = a.distanceTo(b);
  const wall = shadowed(new THREE.Mesh(new THREE.PlaneGeometry(length, CEILING), M.plaster), false);
  wall.position.set((a.x+b.x)/2, CEILING/2, (a.z+b.z)/2); wall.lookAt(new THREE.Vector3(0, CEILING/2, -2)); scene.add(wall);
 }
 const front = new THREE.Mesh(new THREE.PlaneGeometry(12, CEILING), M.plaster); front.position.set(0, CEILING/2, 9.5); front.rotation.y = Math.PI; scene.add(front);

 // Ceiling: dark acoustic backing, oak slats and recessed linear lights.
 const backing = new THREE.Mesh(new THREE.PlaneGeometry(32,26), M.ceiling); backing.rotation.x = Math.PI/2; backing.position.set(0, CEILING+.02, -2); scene.add(backing);
 const slatCount = 104, slats = new THREE.InstancedMesh(new THREE.BoxGeometry(30,.09,.06), M.timber, slatCount);
 for (let i = 0; i < slatCount; i++) slats.setMatrixAt(i, local([0, CEILING-.05, 9.4 - i*.22]));
 scene.add(slats);
 for (const z of [-2.6,-6.6,-10.6]) { const strip = new THREE.Mesh(new THREE.BoxGeometry(24,.03,.16), M.glow); strip.position.set(0, CEILING-.1, z); scene.add(strip); }

 await progress(.4, 'Setting out the tiers');
 // Tiers: full-height steps under the seating, half steps in the aisles, metal nosings and step lights.
 const tierParts = [], stepLights = [];
 for (const block of layout.blocks) {
  const radius = rowRadius(block.row), outer = block.row === ROWS-1 ? WALL_R+.4 : radius+DEPTH/2;
  tierParts.push(sector(radius-DEPTH/2, outer, block.a0, block.a1, rowTop(block.row)));
 }
 for (const [row, a0, a1] of layout.aisles) {
  const radius = rowRadius(row), inner = radius-DEPTH/2, outer = row === ROWS-1 ? WALL_R+.4 : radius+DEPTH/2, top = rowTop(row);
  tierParts.push(sector(inner, radius, a0, a1, top-RISE/2), sector(radius, outer, a0, a1, top));
  tierParts.push(withMaterial(sector(inner, inner+.05, a0, a1, .008, top-RISE/2), 2), withMaterial(sector(radius, radius+.05, a0, a1, .008, top), 2));
  const middle = (a0+a1)/2;
  stepLights.push(polar(inner-.005, middle, top-RISE/2-.08), polar(radius-.005, middle, top-.08));
 }
 scene.add(shadowed(new THREE.Mesh(mergeByMaterial(tierParts), [M.carpet, M.oakDark, M.nosing]), false));
 const lights = new THREE.InstancedMesh(new THREE.BoxGeometry(.16,.03,.02), M.step, stepLights.length);
 stepLights.forEach((position, i) => lights.setMatrixAt(i, new THREE.Matrix4().compose(position, new THREE.Quaternion().setFromEuler(new THREE.Euler(0, -Math.atan2(position.x, -position.z), 0)), new THREE.Vector3(1,1,1))));
 scene.add(lights);

 // Desks: oak worktops with a front modesty panel, one continuous run per block and row.
 const deskParts = [];
 for (const block of layout.blocks) {
  const radius = rowRadius(block.row), top = rowTop(block.row);
  deskParts.push(sector(radius-.52, radius+SEAT_BACK-.12, block.a0+.01, block.a1-.01, .035, top+.705));
  deskParts.push(withMaterial(sector(radius-.525, radius-.495, block.a0+.01, block.a1-.01, .69, top+.015), 1));
 }
 scene.add(shadowed(new THREE.Mesh(mergeByMaterial(deskParts), [M.oak, M.oakDark])));

 // Lecturer's area: lectern and a long front table with a laptop.
 const box = (size, position, material, rotation = [0,0,0]) => { const mesh = shadowed(new THREE.Mesh(new THREE.BoxGeometry(...size), material)); mesh.position.set(...position); mesh.rotation.set(...rotation); scene.add(mesh); return mesh; };
 box([.9,1.02,.58], [-3.3,.51,-2.0], M.oakDark); box([1.0,.04,.66], [-3.3,1.06,-1.98], M.oak, [-.16,0,0]);
 box([2.6,.04,.8], [2.4,.74,-2.6], M.oak); box([2.5,.62,.03], [2.4,.4,-2.95], M.oakDark);
 for (const x of [1.2,3.6]) box([.05,.72,.7], [x,.36,-2.6], M.shell);
 box([.34,.015,.24], [2.0,.77,-2.55], M.shell); box([.34,.22,.01], [2.0,.88,-2.68], M.shell, [-.3,0,0]);

 await progress(.58, 'Placing the seats');
 // Seats: rounded upholstered cushion and back on a dark shell, standards between seats, contact shadows.
 const seatMap = new Map(layout.seats.map(seat => [seat.id, seat]));
 const teamSeats = assignSeats(members, layout.seats, seatMap);
 const occupied = new Set(teamSeats.values()), crowd = seeded(715);
 for (const seat of layout.seats) if (!occupied.has(seat.id) && crowd() < .56) occupied.add(seat.id);
 const seatFrame = seat => new THREE.Matrix4().compose(polar(rowRadius(seat.row)+SEAT_BACK, seat.angle, rowTop(seat.row)), new THREE.Quaternion().setFromEuler(new THREE.Euler(0,-seat.angle,0)), new THREE.Vector3(1,1,1));
 // Empty seats are folded up, as fixed lecture seating is.
 const folded = local([0,.46,-.2]).multiply(local([0,0,0],[-1.42,0,0])).multiply(local([0,0,.2]));
 const chairParts = [
  [cushion(.48,.44,.05,.07).rotateX(-Math.PI/2), M.fabric, seat => occupied.has(seat.id) ? local([0,.46,0]) : folded],
  [cushion(.48,.52,.045,.07), M.fabric, () => local([0,.8,-.2],[-.12,0,0])],
  [cushion(.5,.55,.03,.07), M.shell, () => local([0,.79,-.24],[-.12,0,0])],
  [new THREE.BoxGeometry(.05,.62,.42), M.shell, () => local([-.31,.31,-.1])],
  [cushion(.05,.4,.03,.02).rotateX(-Math.PI/2), M.shell, () => local([-.31,.64,-.06])]
 ];
 for (const [geometry, material, place] of chairParts) {
  const mesh = shadowed(new THREE.InstancedMesh(geometry, material, layout.seats.length));
  layout.seats.forEach((seat, i) => mesh.setMatrixAt(i, seatFrame(seat).multiply(place(seat))));
  scene.add(mesh);
 }
 const ends = layout.seats.filter(seat => seat.last), standardEnd = shadowed(new THREE.InstancedMesh(new THREE.BoxGeometry(.05,.62,.42), M.shell, ends.length));
 ends.forEach((seat, i) => standardEnd.setMatrixAt(i, seatFrame(seat).multiply(local([.31,.31,-.1])))); scene.add(standardEnd);
 const blobs = new THREE.InstancedMesh(new THREE.PlaneGeometry(.8,.8), new THREE.MeshBasicMaterial({ map:tex(blobTexture()), transparent:true, depthWrite:false, opacity:.55 }), layout.seats.length);
 layout.seats.forEach((seat, i) => blobs.setMatrixAt(i, seatFrame(seat).multiply(local([0,.006,.05],[-Math.PI/2,0,0]))));
 blobs.renderOrder = 1; scene.add(blobs);

 await progress(.74, 'Seating the students');
 // Students: seated Rocketbox figures (MIT, baked by tools/rocketbox), one instanced batch per figure.
 // Team members use the same generic figures, chosen by seat, so no individual appearance is implied;
 // identity lives in the profile photo. If the models cannot load, procedural figures stand in.
 const seated = layout.seats.filter(seat => occupied.has(seat.id));
 const figures = await loadFigures(compact).catch(error => { console.warn('Seated figures unavailable; using simple figures.', error); return null; });
 const color = new THREE.Color();
 if (figures) {
  const bySeat = new Map(seated.map(seat => [seat.id, figures[hash(seat.id + 'figure') % figures.length]]));
  for (const figure of figures) {
   const seats = seated.filter(seat => bySeat.get(seat.id) === figure);
   const mesh = shadowed(new THREE.InstancedMesh(figure.geometry, figure.materials, seats.length));
   seats.forEach((seat, i) => mesh.setMatrixAt(i, seatFrame(seat).multiply(local([0,0,-.02],[0,(seeded(hash(seat.id))()-.5)*.14,0]))));
   scene.add(mesh);
  }
  textures.push(...figures.flatMap(figure => figure.materials.map(material => material.map).filter(Boolean)));
 }
 // Desk items for everyone; full procedural bodies only when the figures are unavailable.
 const buckets = new Map();
 for (const seat of seated) {
  const look = lookFor(seeded(hash(seat.id))), frame = seatFrame(seat);
  for (const [part, matrix, role] of personParts(look)) {
   if (figures && !DESK_ITEMS.has(part)) continue;
   if (!buckets.has(part)) buckets.set(part, []);
   buckets.get(part).push([frame.clone().multiply(figures ? local([0,0,-.1]).multiply(matrix) : matrix), look[role]]);
  }
 }
 for (const [part, items] of buckets) {
  const material = new THREE.MeshStandardMaterial({ roughness:ROUGH[part] ?? .86, side:part === 'hijab' || part === 'drape' ? THREE.DoubleSide : THREE.FrontSide });
  const mesh = shadowed(new THREE.InstancedMesh(PART[part](), material, items.length));
  items.forEach(([matrix, tint], i) => { mesh.setMatrixAt(i, matrix); mesh.setColorAt(i, color.set(tint)); });
  scene.add(mesh);
 }

 await progress(.88, 'Marking the team seats');
 // Team cue: a slim backlit strip on the seat back plus a soft glow; hover and selection brighten it.
 const glowMap = tex(glowTexture()), people = new Map(), hitboxes = [];
 const hitGeometry = new THREE.BoxGeometry(.72,1.2,1.05), plaqueGeometry = new THREE.BoxGeometry(.46,.032,.05);
 for (const member of members) {
  const seat = seatMap.get(teamSeats.get(member.key)); if (!seat) continue;
  const frame = seatFrame(seat);
  const plaqueMaterial = new THREE.MeshStandardMaterial({ color:'#8fc6ea', emissive:'#2f8fd0', emissiveIntensity:1.2, roughness:.3 });
  // Mounted along the top of the seat back, so it stays visible either side of the occupant's head.
  const plaque = new THREE.Mesh(plaqueGeometry, plaqueMaterial); plaque.applyMatrix4(frame.clone().multiply(local([0,1.112,-.235],[-.12,0,0])));
  // A small screen-constant glow keeps every team seat findable from the full-hall view.
  const glow = new THREE.Sprite(new THREE.SpriteMaterial({ map:glowMap, transparent:true, depthWrite:false, depthTest:false, opacity:.85, sizeAttenuation:false }));
  glow.position.copy(new THREE.Vector3(0,1.46,-.12).applyMatrix4(frame)); glow.scale.set(.032,.032,1); glow.renderOrder = 2;
  const hit = new THREE.Mesh(hitGeometry); hit.visible = false; hit.applyMatrix4(frame.clone().multiply(local([0,.85,.32]))); hit.userData.key = member.key;
  scene.add(plaque, glow, hit); hitboxes.push(hit);
  people.set(member.key, { member, seat, plaqueMaterial, glow, head:new THREE.Vector3(0,1.32,.05).applyMatrix4(frame), level:0, target:0 });
 }

 // ---- Camera choreography ----
 const camera = new THREE.PerspectiveCamera(40, 1, .1, 90);
 const pose = { position:new THREE.Vector3(), target:new THREE.Vector3(), offX:0, offY:0 };
 let width = 1, height = 1, frameMode = 'wide', insets = { right:0, bottom:0 }, focused = null, tween = null;
 let reduced = reducedMotion, hovered = null, selected = null, raf = 0, disposed = false, lastTime = 0;
 function overviewPose() {
  const aspect = width/height;
  frameMode = aspect < .9 ? 'portrait' : aspect < 1.35 ? 'square' : 'wide';
  camera.fov = { portrait:62, square:48, wide:42 }[frameMode];
  return {
   position: { portrait:new THREE.Vector3(0,5.5,3.6), square:new THREE.Vector3(0,4.4,8), wide:new THREE.Vector3(0,3.7,7.6) }[frameMode],
   target: { portrait:new THREE.Vector3(0,1.6,-8.2), square:new THREE.Vector3(0,2.0,-8), wide:new THREE.Vector3(0,2.45,-8.6) }[frameMode]
  };
 }
 function memberPose(key) {
  overviewPose();
  const head = people.get(key).head, toward = new THREE.Vector3(-head.x, 0, -head.z).normalize();
  const portrait = frameMode === 'portrait';
  return { position:head.clone().addScaledVector(toward, portrait ? 6.8 : 6.2).add(new THREE.Vector3(0, portrait ? 2.6 : 1.9, 0)), target:head.clone().add(new THREE.Vector3(0,-.25,0)) };
 }
 const goal = () => ({ ...(focused ? memberPose(focused) : overviewPose()), offX:insets.right/2, offY:insets.bottom/2 });
 function applyPose() {
  camera.position.copy(pose.position); camera.lookAt(pose.target);
  if (pose.offX || pose.offY) camera.setViewOffset(width, height, pose.offX, pose.offY, width, height); else camera.clearViewOffset();
  camera.updateProjectionMatrix();
 }
 const ease = t => t < .5 ? 4*t*t*t : 1-Math.pow(-2*t+2,3)/2;
 // Interrupts cleanly: every move starts from wherever the camera is now, position and target together.
 // onCamera reports 'moving', then 'overview' or 'member:<key>' once the camera settles.
 const settled = () => onCamera?.(focused ? 'member:' + focused : 'overview');
 function moveTo(to, duration, lift = 0) {
  if (reduced || !duration) { tween = null; Object.assign(pose, { position:to.position.clone(), target:to.target.clone(), offX:to.offX, offY:to.offY }); applyPose(); request(); settled(); return; }
  onCamera?.('moving');
  const from = { position:pose.position.clone(), target:pose.target.clone(), offX:pose.offX, offY:pose.offY };
  const control = from.position.clone().lerp(to.position, .5).add(new THREE.Vector3(0, lift, 0));
  tween = { from, to, control, start:performance.now(), duration }; request();
 }
 function stepTween(now) {
  if (!tween) return;
  const t = Math.min((now - tween.start)/tween.duration, 1), k = ease(t), { from, to, control } = tween;
  const a = from.position.clone().lerp(control, k), b = control.clone().lerp(to.position, k);
  pose.position.copy(a.lerp(b, k)); pose.target.copy(from.target).lerp(to.target, k);
  pose.offX = from.offX + (to.offX-from.offX)*k; pose.offY = from.offY + (to.offY-from.offY)*k;
  applyPose(); if (t === 1) { tween = null; settled(); }
 }

 // ---- Interaction ----
 const raycaster = new THREE.Raycaster(), pointer = new THREE.Vector2(), canvas = renderer.domElement;
 function pick(event) {
  const rect = canvas.getBoundingClientRect();
  pointer.set((event.clientX-rect.left)/rect.width*2-1, -((event.clientY-rect.top)/rect.height)*2+1);
  raycaster.setFromCamera(pointer, camera);
  return raycaster.intersectObjects(hitboxes, false)[0]?.object.userData.key ?? null;
 }
 function screenPoint(key) {
  const point = people.get(key)?.head.clone().project(camera);
  if (!point || point.z > 1) return null;
  return { x:(point.x+1)/2*width, y:(1-point.y)/2*height };
 }
 function highlight() {
  for (const [key, person] of people) person.target = key === selected ? 1 : key === hovered ? .6 : 0;
  const lit = people.get(selected ?? hovered);
  if (lit) {
   const toward = new THREE.Vector3(-lit.head.x, 0, -lit.head.z).normalize();
   accent.position.copy(lit.head).addScaledVector(toward, 1.4).add(new THREE.Vector3(0,2.6,0)); accent.target.position.copy(lit.head).add(new THREE.Vector3(0,-.5,0));
  }
  accent.userData.goal = lit ? (selected ? 14 : 8) : 0; request();
 }
 function setHover(key) {
  if (hovered === key) return; hovered = key; canvas.style.cursor = key ? 'pointer' : '';
  onHover?.(key && key !== selected ? key : null, key && key !== selected ? screenPoint(key) : null); highlight();
 }
 const move = event => { if (event.pointerType !== 'touch') setHover(pick(event)); };
 const leave = () => setHover(null);
 const click = event => { const key = pick(event); if (key) { setHover(null); onSelect?.(key); } };
 canvas.addEventListener('pointermove', move); canvas.addEventListener('pointerleave', leave); canvas.addEventListener('click', click);

 // ---- Render loop: on demand, paused while hidden ----
 function frame(now) {
  raf = 0; if (disposed || document.hidden) return;
  const delta = lastTime ? Math.min((now-lastTime)/1000, .05) : 0; lastTime = now;
  stepTween(now);
  let moving = !!tween;
  for (const person of people.values()) {
   const next = reduced ? person.target : person.level + (person.target-person.level)*Math.min(delta*10, 1);
   person.level = Math.abs(next-person.target) < .01 ? person.target : next; if (person.level !== person.target) moving = true;
   person.plaqueMaterial.emissiveIntensity = 1.2 + person.level*1.3; person.glow.material.opacity = .85 + person.level*.15; person.glow.scale.setScalar(.032 + person.level*.016);
  }
  const lightGoal = accent.userData.goal ?? 0;
  accent.intensity = reduced ? lightGoal : accent.intensity + (lightGoal-accent.intensity)*Math.min(delta*8, 1);
  if (Math.abs(accent.intensity-lightGoal) > .05) moving = true;
  if (hovered && hovered !== selected) onHover?.(hovered, screenPoint(hovered));
  renderer.render(scene, camera);
  if (moving) raf = requestAnimationFrame(frame); else lastTime = 0;
 }
 function request() { if (!raf && !disposed && !document.hidden) raf = requestAnimationFrame(frame); }
 function resize() {
  const rect = container.getBoundingClientRect(); if (!rect.width || !rect.height) return;
  width = rect.width; height = rect.height; renderer.setSize(width, height, false); camera.aspect = width/height;
  if (!tween) { const to = goal(); Object.assign(pose, { position:to.position, target:to.target, offX:to.offX, offY:to.offY }); applyPose(); }
  request();
 }
 const observer = new ResizeObserver(resize); observer.observe(container);
 const visibility = () => { if (!document.hidden) { lastTime = 0; if (tween) tween.start = performance.now() - tween.duration; request(); } };
 document.addEventListener('visibilitychange', visibility);
 const lost = event => { event.preventDefault(); onLost?.(); };
 canvas.addEventListener('webglcontextlost', lost);

 resize();
 await progress(.96, 'Lighting the hall');
 renderer.compile(scene, camera); renderer.render(scene, camera);
 await progress(1);

 return {
  intro() {
   const to = goal();
   if (reduced) { moveTo(to, 0); return; }
   Object.assign(pose, { position:to.position.clone().add(new THREE.Vector3(-6, 2.6, -3.6)), target:to.target.clone().add(new THREE.Vector3(1.6, .8, -1.5)), offX:to.offX, offY:to.offY });
   applyPose(); moveTo(to, 2200, .4);
  },
  focus(key, nextInsets) {
   if (!people.has(key)) return;
   focused = key; selected = key; insets = nextInsets || insets; setHover(null); highlight();
   moveTo(goal(), 1150, .9);
  },
  overview(nextInsets) {
   focused = null; selected = null; insets = nextInsets || { right:0, bottom:0 }; highlight();
   moveTo(goal(), 1150, .6);
  },
  setInsets(nextInsets) { insets = nextInsets; moveTo(goal(), reduced ? 0 : 450); },
  setReducedMotion(value) { reduced = value; if (value && tween) moveTo(tween.to, 0); request(); },
  seatOf: key => teamSeats.get(key),
  screenPoint,
  camera, // read-only diagnostics for tests
  dispose() {
   if (disposed) return; disposed = true; cancelAnimationFrame(raf); observer.disconnect();
   document.removeEventListener('visibilitychange', visibility);
   canvas.removeEventListener('pointermove', move); canvas.removeEventListener('pointerleave', leave); canvas.removeEventListener('click', click); canvas.removeEventListener('webglcontextlost', lost);
   const geometries = new Set(), materials = new Set();
   scene.traverse(object => { if (object.geometry) geometries.add(object.geometry); for (const m of [].concat(object.material || [])) materials.add(m); });
   geometries.forEach(g => g.dispose()); materials.forEach(m => m.dispose()); textures.forEach(t => t.dispose());
   envTarget.dispose(); renderer.dispose(); canvas.remove();
  }
 };
}

// Roster seats when valid and free; otherwise the next free seat from a spread-out preference list.
function assignSeats(members, seats, seatMap) {
 const taken = new Set(), result = new Map();
 for (const member of members) {
  const seat = member.seat && seatMap.get(member.seat);
  if (seat && !taken.has(seat.id)) { taken.add(seat.id); result.set(member.key, seat.id); }
 }
 const spare = seats.filter(seat => seat.row >= 1 && seat.row <= 5 && Math.abs(seat.angle) < ARC*.8).sort((a,b) => hash(a.id) - hash(b.id));
 for (const member of members) {
  if (result.has(member.key)) continue;
  const seat = spare.find(candidate => !taken.has(candidate.id) && [...taken].every(id => { const other = seatMap.get(id); return other.row !== candidate.row || Math.abs(other.angle-candidate.angle)*rowRadius(candidate.row) > 1.5; }));
  if (seat) { taken.add(seat.id); result.set(member.key, seat.id); }
 }
 return result;
}
