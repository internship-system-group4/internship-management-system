import * as THREE from './vendor/three.module.min.js';
import { createGateModel } from './home-gate-model.js';
import { architecturalUV } from './home-campus-materials.js';
import { mergeGeometries } from './vendor/addons/utils/BufferGeometryUtils.js';
import { createCampusActors } from './login-campus-actors.js?v=20261024-perf-1';

// Daylight sky painted once on a canvas: zenith blue, pale horizon, soft cumulus.
function skyTexture() {
 const canvas = document.createElement('canvas'); canvas.width = 1024; canvas.height = 512;
 const c = canvas.getContext('2d'), gradient = c.createLinearGradient(0,0,0,512);
 gradient.addColorStop(0,'#3d73b0'); gradient.addColorStop(.3,'#5f93cc'); gradient.addColorStop(.43,'#9cc2e4'); gradient.addColorStop(.49,'#d6e4ee'); gradient.addColorStop(.5,'#e6ece9'); gradient.addColorStop(1,'#e6ece9');
 c.fillStyle = gradient; c.fillRect(0,0,1024,512);
 let seed = 41; const random = () => { seed = (Math.imul(seed,1664525)+1013904223)>>>0; return seed/4294967296; };
 for (let cloud = 0; cloud < 16; cloud++) {
  const cx = random()*1024, cy = 150+random()*95, width = 60+random()*110;
  for (let puff = 0; puff < 9; puff++) {
   const x = cx+(random()-.5)*width, y = cy+(random()-.5)*width*.18, r = width*(.18+random()*.2);
   const g = c.createRadialGradient(x,y,0,x,y,r);
   g.addColorStop(0,'rgba(255,255,255,.85)'); g.addColorStop(.6,'rgba(255,255,255,.35)'); g.addColorStop(1,'rgba(255,255,255,0)');
   c.fillStyle = g; c.beginPath(); c.arc(x,y,r,0,Math.PI*2); c.fill();
  }
 }
 const texture = new THREE.CanvasTexture(canvas); texture.colorSpace = THREE.SRGBColorSpace; return texture;
}

// Gate 1 limestone: cream ashlar in ~0.6 m courses with faint joints, toned from the reference photo.
// One tile spans 2.4 m, so architecturalUV(geometry, 2.4) keeps courses at true scale.
function limestoneTexture() {
 const size = 512, canvas = document.createElement('canvas'); canvas.width = canvas.height = size;
 const c = canvas.getContext('2d'); let seed = 1907;
 const random = () => { seed = (Math.imul(seed,1664525)+1013904223)>>>0; return seed/4294967296; };
 c.fillStyle = '#dccfb5'; c.fillRect(0,0,size,size);
 const course = size/4;
 for (let row = 0; row < 4; row++) {
  const offset = row % 2 ? size/4 : 0;
  for (let col = -1; col < 3; col++) {
   const x = col*size/2+offset, tone = 214+Math.floor(random()*16)-8;
   c.fillStyle = `rgb(${tone+6},${tone-2},${tone-22})`; c.fillRect(x+1,row*course+1,size/2-2,course-2);
  }
 }
 for (let i = 0; i < 2600; i++) {
  const x = random()*size, y = random()*size, a = .05+random()*.08;
  c.fillStyle = random() < .5 ? `rgba(120,104,80,${a})` : `rgba(255,250,238,${a})`; c.fillRect(x,y,1+random()*2.5,1+random()*1.5);
 }
 c.strokeStyle = 'rgba(150,134,108,.55)'; c.lineWidth = 2;
 for (let row = 0; row <= 4; row++) { c.beginPath(); c.moveTo(0,row*course); c.lineTo(size,row*course); c.stroke(); }
 for (let row = 0; row < 4; row++) for (let col = 0; col < 3; col++) {
  const x = col*size/2+(row % 2 ? size/4 : 0); c.beginPath(); c.moveTo(x,row*course); c.lineTo(x,(row+1)*course); c.stroke();
 }
 const texture = new THREE.CanvasTexture(canvas); texture.colorSpace = THREE.SRGBColorSpace;
 texture.wrapS = texture.wrapT = THREE.RepeatWrapping; texture.anisotropy = 4; return texture;
}

function contactShadowTexture() {
 const canvas = document.createElement('canvas'); canvas.width = canvas.height = 64;
 const c = canvas.getContext('2d'), g = c.createRadialGradient(32,32,4,32,32,32);
 g.addColorStop(0,'rgba(40,36,29,.42)'); g.addColorStop(.55,'rgba(40,36,29,.18)'); g.addColorStop(1,'rgba(40,36,29,0)');
 c.fillStyle = g; c.fillRect(0,0,64,64); return new THREE.CanvasTexture(canvas);
}

// The photograph's right curb is painted in alternating black and white blocks.
function curbTexture() {
 const canvas = document.createElement('canvas'); canvas.width = 64; canvas.height = 8;
 const c = canvas.getContext('2d'); c.fillStyle = '#e9e7e1'; c.fillRect(0,0,64,8); c.fillStyle = '#262a2c'; c.fillRect(0,0,32,8);
 const texture = new THREE.CanvasTexture(canvas); texture.colorSpace = THREE.SRGBColorSpace;
 texture.wrapS = THREE.RepeatWrapping; texture.magFilter = THREE.NearestFilter; return texture;
}

async function identityTexture(logoUrl) {
 const c=document.createElement('canvas');c.width=512;c.height=320;const g=c.getContext('2d');
 g.fillStyle='#f4f3ed';g.fillRect(0,0,512,320);g.fillStyle='#234e73';g.fillRect(0,0,512,62);
 g.fillStyle='#fff';g.font='bold 25px Arial';g.fillText('GJU  |  UNIVERSITY ID',22,41);
 const logo=new Image();logo.src=logoUrl;try{await logo.decode();g.drawImage(logo,25,85,104,91);}catch(e){}
 g.fillStyle='#c4d2dc';g.fillRect(350,88,125,150);g.fillStyle='#657e91';g.beginPath();g.arc(412,132,28,0,Math.PI*2);g.fill();g.beginPath();g.ellipse(412,211,46,43,0,Math.PI,0);g.fill();
 g.fillStyle='#183d5b';g.font='bold 26px Arial';g.fillText('STUDENT',25,219);g.font='20px Arial';g.fillText('CAMPUS ACCESS',25,252);g.fillStyle='#c5a24d';g.fillRect(0,294,512,26);
 const map=new THREE.CanvasTexture(c);map.colorSpace=THREE.SRGBColorSpace;return map;
}

// Static scenery is drawn as one mesh per material: child meshes are baked into world space and merged. Meshes that move,
// deform or carry their own shader (people, flags, gate leaves' parents, the reader) are not passed in here.
function mergeStatic(group) {
 group.updateMatrixWorld(true);
 const buckets = new Map(), merged = [];
 group.traverse(object => {
  if (!object.isMesh || object.isSkinnedMesh || !object.visible) return;
  const key = object.material.uuid + (object.castShadow ? '|c' : '') + (object.receiveShadow ? '|r' : '');
  if (!buckets.has(key)) buckets.set(key, { material:object.material, cast:object.castShadow, receive:object.receiveShadow, parts:[] });
  const geometry = (object.geometry.index ? object.geometry : object.geometry.toNonIndexed()).clone().applyMatrix4(object.matrixWorld);
  for (const name of Object.keys(geometry.attributes)) if (!['position','normal','uv'].includes(name)) geometry.deleteAttribute(name);
  buckets.get(key).parts.push(geometry); merged.push(object);
 });
 for (const object of merged) object.removeFromParent();
 group.position.set(0,0,0); group.rotation.set(0,0,0); group.scale.set(1,1,1);
 group.traverse(object => { if (object !== group && object.isObject3D && !object.isMesh) { object.position.set(0,0,0); object.rotation.set(0,0,0); object.scale.set(1,1,1); } });
 for (const { material, cast, receive, parts } of buckets.values()) {
  const geometry = parts.length === 1 ? parts[0] : mergeGeometries(parts.filter(p => p.index), false) || parts[0];
  parts.forEach(p => { if (p !== geometry) p.dispose(); });
  const mesh = new THREE.Mesh(geometry, material); mesh.name = 'merged-' + (material.name || material.type); mesh.castShadow = cast; mesh.receiveShadow = receive; mesh.matrixAutoUpdate = false; mesh.updateMatrix();
  group.add(mesh);
 }
 return group;
}

export async function createCampusScene(host, options) {
 // User Timing marks (scene:*) record each initialization stage for the performance checks.
 const stage = name => performance.mark('scene:' + name);
 stage('start');
 const container = host.querySelector('[data-campus-canvas]');
 const pause = host.querySelector('[data-campus-pause]');
 const compact = innerWidth <= 640;
 let renderer, gate, actors, environmentTarget;
 const scene = new THREE.Scene();
 try {
  renderer = new THREE.WebGLRenderer({ antialias:!compact, alpha:false, powerPreference:'low-power' });
  [gate,actors] = await Promise.all([createGateModel(host.dataset.logo),createCampusActors()]);
  stage('assets');
 } catch (error) { renderer?.dispose(); actors?.dispose(); throw error; }
 scene.background = new THREE.Color('#dbe5eb'); scene.fog = new THREE.Fog('#dbe5eb',48,120);
 // Resolution starts at the device ratio (capped) and adapts to measured frame time in small steps (see adapt()).
 const maxRatio = Math.min(devicePixelRatio, compact ? 1.25 : 1.5), minRatio = Math.min(maxRatio, compact ? .8 : 1);
 let pixelRatio = maxRatio; renderer.setPixelRatio(pixelRatio);
 renderer.shadowMap.enabled = true; renderer.shadowMap.type = THREE.PCFSoftShadowMap;
 renderer.outputColorSpace = THREE.SRGBColorSpace; renderer.toneMapping = THREE.ACESFilmicToneMapping;
 renderer.toneMappingExposure = .92; container.appendChild(renderer.domElement);
 scene.add(new THREE.HemisphereLight('#c9ddf3','#a48e70',.78));
 const sun = new THREE.DirectionalLight('#fff1dd',3.05); sun.position.set(-7,11,9); sun.castShadow = true;
 sun.shadow.mapSize.set(compact?1024:2048,compact?1024:2048);sun.shadow.radius=2; Object.assign(sun.shadow.camera,{left:-14,right:14,top:12,bottom:-10,near:1,far:50}); sun.shadow.bias = -.00015; sun.shadow.normalBias = .015;
 scene.add(sun);
 const sky = new THREE.Mesh(new THREE.SphereGeometry(120,32,16), new THREE.MeshBasicMaterial({ map:skyTexture(), side:THREE.BackSide, fog:false, depthWrite:false, toneMapped:false }));
 sky.name = 'daylight-sky'; scene.add(sky);
 const environmentScene = new THREE.Scene(); environmentScene.add(sky.clone());
 const pmrem = new THREE.PMREMGenerator(renderer); environmentTarget=pmrem.fromScene(environmentScene,.025,.1,220);
 scene.environment=environmentTarget.texture; scene.environmentIntensity=.45; pmrem.dispose();
 stage('environment');
 scene.add(gate.root);

 // Flags fly from freestanding poles in the planters in front of the piers, clear of the road, the sliding leaves (which
 // travel along z=.5) and both characters: Jordan on the visitor's right, Germany on the left. The gate model's own poles
 // inside the opening are hidden; its two cloth simulations are reused and stay pinned to the new poles.
 gate.parts.get('flagpoles').visible = false;
 const jordan = gate.parts.get('jordan-flag'), germany = gate.parts.get('germany-flag');
 // Flags fly above the lintel line so neither covers the gate sign or logo.
 const FLAG_SCALE = .52, POLE_HEIGHT = 7, FLAG_TOP = 6.92;
 const flagPoles = [['jordan', jordan, 5.9], ['germany', germany, -5.9]].map(([country, flag, x]) => ({ country, flag, x, z:2.45 }));
 // Reference-toned limestone courses on the stationary structure.
 const portal = gate.parts.get('limestone-portal').children[0].material;
 const stoneLoader=new THREE.TextureLoader();
 const surfacePath=new URL('../images/university/materials/',import.meta.url);
 const maps=await Promise.allSettled(['stone-albedo.png','stone-roughness.png','stone-height.png'].map(name=>stoneLoader.loadAsync(new URL(name,surfacePath).href)));
 portal.map=maps[0].status==='fulfilled'?maps[0].value:limestoneTexture();portal.map.colorSpace=THREE.SRGBColorSpace;
 for(const item of maps)if(item.status==='fulfilled'){item.value.wrapS=item.value.wrapT=THREE.RepeatWrapping;item.value.anisotropy=compact?2:4;}
 if(maps[1].status==='fulfilled')portal.roughnessMap=maps[1].value;
 if(maps[2].status==='fulfilled'){portal.bumpMap=maps[2].value;portal.bumpScale=.012;}
 portal.color.set('#eee8d9');portal.roughness=.9;
 portal.onBeforeCompile=shader=>{shader.fragmentShader=shader.fragmentShader.replace('#include <map_fragment>', '#include <map_fragment>\n float limestoneTone=dot(diffuseColor.rgb,vec3(.2126,.7152,.0722)); diffuseColor.rgb=mix(diffuseColor.rgb,vec3(limestoneTone)*vec3(1.04,1.01,.94),.68);');};portal.needsUpdate=true;
 for (const id of ['limestone-portal','right-return']) gate.parts.get(id).traverse(o => { if (o.isMesh && o.material === portal) architecturalUV(o.geometry,2.4); });
 // Reference details: recessed sign band and four soffit downlights under the lintel.
 const soffit = new THREE.MeshStandardMaterial({ color:'#1f2427', roughness:.6 });
 const lampGeo = new THREE.CylinderGeometry(.13,.13,.2,12);
 for (const x of [-3.9,-1.3,1.3,3.9]) { const can = new THREE.Mesh(lampGeo,soffit); can.name = 'soffit-light'; can.position.set(x,3.5,.2); gate.root.add(can); }

 // Long approach road, curbs, low wall, lamps and a distant hall, read from the photograph's background.
 const surroundings = new THREE.Group(); surroundings.name = 'campus-surroundings'; scene.add(surroundings);
 function block(name, size, position, material, shadow = true) {
  const m = new THREE.Mesh(new THREE.BoxGeometry(...size), material); m.name = name; m.position.fromArray(position);
  m.castShadow = shadow; m.receiveShadow = true; surroundings.add(m); return m;
 }
 const ground = new THREE.Mesh(new THREE.PlaneGeometry(260,260), new THREE.MeshStandardMaterial({ color:'#d6cfbf', roughness:1 }));
 ground.name = 'campus-ground'; ground.rotation.x = -Math.PI/2; ground.position.y = -.035; ground.receiveShadow = true; scene.add(ground);
 const asphalt = new THREE.MeshStandardMaterial({ color:'#a3a7a6', roughness:.95 });
 block('approach-road-inner', [8.8,.02,60], [0,-.015,-37], asphalt, false);
 block('approach-road-outer', [8.8,.02,12], [0,-.015,10], asphalt, false);
 const curbMap = curbTexture(); curbMap.repeat.set(30,1);
 const curb = new THREE.MeshStandardMaterial({ map:curbMap, roughness:.8 });
 // Side faces map u along z; the top face is swapped so its stripes also run along the curb.
 const curbGeo = block('painted-curb', [.25,.22,60], [4.55,.06,-37], curb, false).geometry, uv = curbGeo.attributes.uv;
 for (let i = 8; i < 12; i++) uv.setXY(i,uv.getY(i),uv.getX(i));
 block('sidewalk-right', [2.4,.14,60], [5.9,.0,-37], new THREE.MeshStandardMaterial({ color:'#ddd6c7', roughness:.95 }), false);
 block('terracotta-wall', [.35,1.05,44], [7.3,.45,-30], new THREE.MeshStandardMaterial({ color:'#d7b49a', roughness:.95 }));
 const hall = new THREE.MeshStandardMaterial({ color:'#ddd3c1', roughness:.9 });
 block('sport-hall', [16,4.6,9], [-14,2.05,-24], hall);
 block('sport-hall-band', [16.05,.7,9.05], [-14,3.7,-24], new THREE.MeshStandardMaterial({ color:'#c9bfad', roughness:.9 }), false);
 block('distant-fields', [140,.1,30], [0,-.2,-95], new THREE.MeshStandardMaterial({ color:'#a9b48f', roughness:1 }), false);
 const poleMat = new THREE.MeshStandardMaterial({ color:'#8c9497', metalness:.4, roughness:.5 });
 const poleGeo = new THREE.CylinderGeometry(.06,.08,7,8), armGeo = new THREE.BoxGeometry(1.3,.06,.08), headGeo = new THREE.BoxGeometry(.5,.08,.22);
 for (let i = 0; i < 6; i++) for (const side of [-1,1]) {
  if (side < 0 && i < 1) continue;
  const z = -10 - i*9, x = side*5.1;
  const pole = new THREE.Mesh(poleGeo,poleMat); pole.position.set(x,3.3,z); pole.castShadow = !compact;
  const arm = new THREE.Mesh(armGeo,poleMat); arm.position.set(x-side*.62,6.75,z);
  const lamp = new THREE.Mesh(headGeo,poleMat); lamp.position.set(x-side*1.2,6.7,z);
  pole.name = 'street-lamp'; surroundings.add(pole,arm,lamp);
 }
 const trunkGeo = new THREE.CylinderGeometry(.12,.15,1.6,6), crownGeo = new THREE.SphereGeometry(1,20,14);
 const trunkMat = new THREE.MeshStandardMaterial({ color:'#80705c', roughness:1 }), crownMat = new THREE.MeshStandardMaterial({ color:'#8aa07a', roughness:1 });
 const crownVertices=crownGeo.attributes.position;
 for(let i=0;i<crownVertices.count;i++){const x=crownVertices.getX(i),y=crownVertices.getY(i),z=crownVertices.getZ(i);const r=1+.11*Math.sin(x*10+y*6)*Math.cos(z*9-y*4);crownVertices.setXYZ(i,x*r,y*r,z*r);}crownGeo.computeVertexNormals();
 for (const [x,z,s] of [[-9,-6,1.1],[-10.5,-11,1.3],[11,-8,1.2],[12.5,-15,1.4],[10,-22,1],[-24,-14,1.5],[-8,-36,1.2],[13,-33,1.3]]) {
  const trunk = new THREE.Mesh(trunkGeo,trunkMat); trunk.position.set(x,.8,z); surroundings.add(trunk);
  const crown = new THREE.Mesh(crownGeo,crownMat); crown.position.set(x,2.3*s,z); crown.scale.set(s*1.1,s*1.35,s*1.1); crown.castShadow = !compact; surroundings.add(crown);
 }

 // Entrance detail at real-world scale (metres). Every object rests on the ground, a curb or a planter; nothing crosses
 // the road, the sliding-leaf track (z=.5) or the characters' paths. Materials and geometries are shared.
 const detail = new THREE.Group(); detail.name = 'entrance-detail'; scene.add(detail);
 function surfaceTexture(size, draw) {
  const c = document.createElement('canvas'); c.width = c.height = size; draw(c.getContext('2d'), size);
  const map = new THREE.CanvasTexture(c); map.wrapS = map.wrapT = THREE.RepeatWrapping; map.colorSpace = THREE.SRGBColorSpace; map.anisotropy = compact ? 2 : 4; return map;
 }
 function grain(g, s, base, spread, count, seed) {
  for (let i = 0; i < count; i++) { seed = (Math.imul(seed, 1664525) + 1013904223) >>> 0; const v = base + (seed >>> 27) % spread - spread / 2; g.fillStyle = `rgb(${v},${v},${v - 3})`; g.fillRect(seed % s, (seed >>> 9) % s, 2, 2); }
 }
 // Forecourt: 0.6 x 0.3 m limestone setts in running bond (one tile = 1.2 m square).
 const paverMap = surfaceTexture(256, (g, s) => {
  g.fillStyle = '#e8e5dc'; g.fillRect(0, 0, s, s); grain(g, s, 226, 18, 1800, 11);
  g.strokeStyle = 'rgba(120,112,98,.55)'; g.lineWidth = 2;
  for (let r = 0; r < 4; r++) { const y = r * s / 4; g.beginPath(); g.moveTo(0, y); g.lineTo(s, y); g.stroke();
   for (let k = -1; k < 3; k++) { const x = (r % 2 ? s / 4 : 0) + k * s / 2; g.beginPath(); g.moveTo(x, y); g.lineTo(x, y + s / 4); g.stroke(); } }
 });
 paverMap.repeat.set(17 / 1.2, 11 / 1.2);
 const forecourt = gate.parts.get('ground').getObjectByName('forecourt');
 if (forecourt) { forecourt.material = forecourt.material.clone(); Object.assign(forecourt.material, { map:paverMap, roughness:.86 }); forecourt.material.color.set('#f6f3ec'); }
 // Asphalt: a faint aggregate grain instead of a flat fill.
 const asphaltMap = surfaceTexture(128, (g, s) => { g.fillStyle = '#a2a6a5'; g.fillRect(0, 0, s, s); grain(g, s, 160, 34, 1400, 5); });
 asphaltMap.repeat.set(4.4, 6); asphalt.map = asphaltMap; asphalt.color.set('#ffffff'); asphalt.needsUpdate = true;
 const entranceRoad = gate.parts.get('ground').getObjectByName('entrance-road');
 if (entranceRoad) { entranceRoad.material = asphalt; }
 // Restrained road paint: centre dashes on the approach, a stop line before the gate, and the checkpoint box around the reader.
 const paint = new THREE.MeshStandardMaterial({ color:'#eceee9', roughness:.72, polygonOffset:true, polygonOffsetFactor:-2, polygonOffsetUnits:-2 });
 const markGeo = new THREE.PlaneGeometry(1, 1);
 function mark(name, w, l, x, z, y = .001) { const m = new THREE.Mesh(markGeo, paint); m.name = name; m.rotation.x = -Math.PI / 2; m.scale.set(w, l, 1); m.position.set(x, y, z); m.receiveShadow = true; detail.add(m); return m; }
 for (let z = 8.2; z < 17; z += 3.4) mark('centre-dash', .1, 1.5, 0, z);
 mark('stop-line', 4, .28, 2.2, 1.6, -.012);
 for (const [w, l, x, z] of [[2.7, .08, 2.05, 4.75], [2.7, .08, 2.05, 7.25], [.08, 2.5, .72, 6], [.08, 2.5, 3.38, 6]]) mark('checkpoint-box', w, l, x, z);
 // Stone curbs and grass verges along the approach (the painted curbs beyond the gate stay as they were).
 const curbStone = new THREE.MeshStandardMaterial({ color:'#cfc8b8', roughness:.86 });
 const verge = new THREE.MeshStandardMaterial({ color:'#9aab7f', roughness:1 });
 for (const side of [-1, 1]) {
  block('approach-curb', [.2, .14, 12.2], [side * 4.5, .055, 10.1], curbStone, false);
  block('grass-verge', [6, .04, 12.2], [side * 7.6, -.005, 10.1], verge, false);
 }
 // Matching sidewalk on the left beyond the gate, narrow enough to clear the sport hall.
 block('sidewalk-left', [1.2, .14, 60], [-5.3, 0, -37], new THREE.MeshStandardMaterial({ color:'#ddd6c7', roughness:.95 }), false);
 const leftCurbGeo = block('painted-curb-left', [.25, .22, 60], [-4.55, .06, -37], curb, false).geometry, leftUv = leftCurbGeo.attributes.uv;
 for (let i = 8; i < 12; i++) leftUv.setXY(i, leftUv.getY(i), leftUv.getX(i));

 // Planters in front of each pier: stone kerb, soil, ground cover and clipped shrubs; each holds a flagpole.
 const planterStone = new THREE.MeshStandardMaterial({ color:'#d6c9ad', roughness:.88 });
 const soil = new THREE.MeshStandardMaterial({ color:'#7f8f62', roughness:1 });
 const shrub = new THREE.MeshStandardMaterial({ color:'#6f8d5c', roughness:.95 });
 const contactPlane = new THREE.PlaneGeometry(1, 1);
 const contactShadow = new THREE.MeshBasicMaterial({ map:contactShadowTexture(), transparent:true, depthWrite:false, opacity:.42 });
 function groundContact(x, z, w, d, y) { const m = new THREE.Mesh(contactPlane, contactShadow); m.rotation.x = -Math.PI / 2; m.scale.set(w, d, 1); m.position.set(x, y, z); detail.add(m); }
 const PLANTER = { inner:5.05, outer:7.55, front:3.75, back:1.35, top:.27, floor:-.05 };
 for (const side of [-1, 1]) {
  const cx = side * (PLANTER.inner + PLANTER.outer) / 2, cz = (PLANTER.front + PLANTER.back) / 2, w = PLANTER.outer - PLANTER.inner, d = PLANTER.front - PLANTER.back, h = PLANTER.top - PLANTER.floor, y = PLANTER.floor + h / 2;
  block('planter-kerb-front', [w, h, .14], [cx, y, PLANTER.front - .07], planterStone);
  block('planter-kerb-back', [w, h, .14], [cx, y, PLANTER.back + .07], planterStone);
  block('planter-kerb-inner', [.14, h, d - .28], [side * (PLANTER.inner + .07), y, cz], planterStone);
  block('planter-kerb-outer', [.14, h, d - .28], [side * (PLANTER.outer - .07), y, cz], planterStone);
  block('planter-bed', [w - .28, .02, d - .28], [cx, PLANTER.top - .06, cz], soil, false);
  for (const [dx, dz, s] of [[-.85, -.7, .34], [.85, -.72, .3], [-.9, .72, .3], [.88, .7, .34], [0, .78, .26]]) {
   const bush = new THREE.Mesh(crownGeo, shrub); bush.name = 'planter-shrub';
   bush.scale.set(s * 1.25, s * .8, s * 1.1); bush.position.set(cx + side * dx, PLANTER.top - .05 + s * .7, cz + dz);
   bush.castShadow = !compact; bush.receiveShadow = true; detail.add(bush);
  }
 }
 // Flagpoles: satin aluminium, stone collar, truck and gilt finial, halyard tied off at a cleat.
 const aluminium = new THREE.MeshStandardMaterial({ color:'#d3d8db', metalness:.75, roughness:.32 });
 const gilt = new THREE.MeshStandardMaterial({ color:'#c9a24e', metalness:.85, roughness:.3 });
 const poleShaft = new THREE.CylinderGeometry(.042, .066, POLE_HEIGHT, 14), collarGeo = new THREE.CylinderGeometry(.15, .17, .14, 18);
 const truckGeo = new THREE.CylinderGeometry(.07, .07, .05, 14), finialGeo = new THREE.SphereGeometry(.068, 16, 10);
 const halyardGeo = new THREE.CylinderGeometry(.0045, .0045, 1, 4), cleatGeo = new THREE.BoxGeometry(.025, .09, .02);
 const ropeMat = new THREE.MeshStandardMaterial({ color:'#f1efe8', roughness:.9 });
 for (const pole of flagPoles) {
  const base = PLANTER.top - .06, assembly = new THREE.Group(); assembly.name = pole.country + '-flag-assembly'; assembly.position.set(pole.x, base, pole.z); detail.add(assembly);
  // The slender shaft casts no shadow: at this sun angle it would draw a line across the gate logo.
  const shaft = new THREE.Mesh(poleShaft, aluminium); shaft.position.y = POLE_HEIGHT / 2; assembly.add(shaft);
  const collar = new THREE.Mesh(collarGeo, planterStone); collar.position.y = .07; collar.castShadow = true; assembly.add(collar);
  const truck = new THREE.Mesh(truckGeo, aluminium); truck.position.y = POLE_HEIGHT + .025; assembly.add(truck);
  const finial = new THREE.Mesh(finialGeo, gilt); finial.position.y = POLE_HEIGHT + .11; finial.castShadow = true; assembly.add(finial);
  const halyard = new THREE.Mesh(halyardGeo, ropeMat); halyard.scale.y = POLE_HEIGHT - 1.25; halyard.position.set(.05, 1.25 + (POLE_HEIGHT - 1.25) / 2, .02); assembly.add(halyard);
  const cleat = new THREE.Mesh(cleatGeo, aluminium); cleat.position.set(.06, 1.2, 0); assembly.add(cleat);
  groundContact(pole.x, pole.z, .7, .7, base + .002);
  // Hoisted to the truck; the cloth's pinned edge sits on the halyard side of the shaft.
  const flag = pole.flag, width = 2.85 * FLAG_SCALE, height = (pole.country === 'jordan' ? 2.85 / 2 : 2.85 * 3 / 5) * FLAG_SCALE;
  flag.scale.setScalar(FLAG_SCALE); flag.position.set(pole.x + .06 + width / 2, base + FLAG_TOP - height / 2, pole.z);
  // Thin cloth casts no shadow: at this sun angle it would darken the gate sign and logo.
  flag.castShadow = false; flag.receiveShadow = true;
 }

 // Gate stone: a darker plinth course at each pier foot (it also seats the piers on the paving), a projecting coping on
 // the lintel, and fine horizontal joints on the pier faces.
 const plinthStone = new THREE.MeshStandardMaterial({ color:'#cdbd9d', roughness:.92 });
 const jointMat = new THREE.MeshStandardMaterial({ color:'#a89b80', roughness:1 });
 const jointGeo = new THREE.BoxGeometry(1.0, .012, .006);
 for (const side of [-1, 1]) {
  const plinth = new THREE.Mesh(new THREE.BoxGeometry(1.17, .36, 1.02), plinthStone); plinth.name = 'pier-plinth'; plinth.position.set(side * 5.6, .13, 0); plinth.castShadow = plinth.receiveShadow = true; detail.add(plinth);
  for (const y of [1.2, 2.4]) { const joint = new THREE.Mesh(jointGeo, jointMat); joint.name = 'pier-joint'; joint.position.set(side * 5.6, y, .453); detail.add(joint); }
 }
 const coping = new THREE.Mesh(new THREE.BoxGeometry(12.45, .09, 1.04), plinthStone); coping.name = 'lintel-coping'; coping.position.set(0, 5.445, 0); coping.castShadow = coping.receiveShadow = true; detail.add(coping);
 // Security equipment, kept restrained: one dome-less bullet camera on the right pier, facing the approach.
 const housing = new THREE.MeshStandardMaterial({ color:'#e7eaec', roughness:.45, metalness:.1 }), lensMat = new THREE.MeshStandardMaterial({ color:'#11171b', roughness:.2, metalness:.4 });
 const cctv = new THREE.Group(); cctv.name = 'cctv-camera'; cctv.position.set(5.12, 3.25, .5); cctv.rotation.set(-.32, -.35, 0); detail.add(cctv);
 const cctvArm = new THREE.Mesh(new THREE.BoxGeometry(.04, .04, .16), housing); cctvArm.position.z = .02; cctv.add(cctvArm);
 const cctvBody = new THREE.Mesh(new THREE.BoxGeometry(.09, .085, .25), housing); cctvBody.position.set(0, -.05, .14); cctvBody.castShadow = true; cctv.add(cctvBody);
 const lens = new THREE.Mesh(new THREE.CylinderGeometry(.028, .028, .012, 16), lensMat); lens.rotation.x = Math.PI / 2; lens.position.set(0, -.05, .27); cctv.add(lens);

 // Static scenery and entrance detail: one draw call per material instead of one per object.
 stage('built'); mergeStatic(surroundings); mergeStatic(detail); stage('merged');

 // The existing photographed structure stays fixed. These complete sliding leaves
 // deliberately use a symbolic mechanism; no claim about the real gate hardware.
 gate.parts.get('metal-gates').visible = false;
 const leaves = []; const metal = new THREE.MeshStandardMaterial({ color:'#7c8588', metalness:.6, roughness:.42 });
 const barGeo = new THREE.BoxGeometry(.034,2.3,.034);
 function bar(parent,name,size,pos) {
  const m = new THREE.Mesh(new THREE.BoxGeometry(...size),metal); m.name = name; m.position.fromArray(pos); m.castShadow = true; parent.add(m);
 }
 for (const side of [-1,1]) {
  const leaf = new THREE.Group(); leaf.name = 'symbolic-sliding-gate-'+side; leaf.position.set(side*2.5,0,.5); scene.add(leaf); leaves.push(leaf);
  for (const y of [.12,1.95,2.42]) bar(leaf,'rail-'+y,[4.96,.07,.07],[0,y,0]);
  for (const x of [-2.44,2.44]) bar(leaf,'stile-'+x,[.09,2.42,.08],[x,1.27,0]);
  for (let i = 1; i < 24; i++) { const v = new THREE.Mesh(barGeo,metal); v.name = 'vertical-'+i; v.position.set(-2.44+i*4.88/24,1.2,0); v.castShadow = true; leaf.add(v); }
 }
 // Each leaf slides as a unit: its 28 rails, stiles and bars become one mesh in the leaf's own frame.
 for (const leaf of leaves) { const x = leaf.position.x; leaf.position.set(0,0,0); mergeStatic(leaf); leaf.position.set(x,0,.5); for (const m of leaf.children) m.matrixAutoUpdate = true; }

 // Fictional adults with independent skinned skeletons and licensed motion-capture clips.
 const guard=actors.guard,visitor=actors.student;
 const guardHome=new THREE.Vector3(2.65,0,5.35),visitorHome=new THREE.Vector3(1.3,0,6.25);
 guard.root.position.copy(guardHome);visitor.root.position.copy(visitorHome);
 const guardHeading=-1.17,visitorHeading=2.15;
 guard.root.rotation.y=guardHeading;visitor.root.rotation.y=visitorHeading;scene.add(guard.root,visitor.root);

 const kiosk=new THREE.Group();kiosk.name='verification-device';kiosk.position.set(1.7,0,6.1);kiosk.rotation.y=-.62;scene.add(kiosk);
 const kioskMat=new THREE.MeshStandardMaterial({color:'#27343e',roughness:.58,metalness:.32});
 const post=new THREE.Mesh(new THREE.CylinderGeometry(.04,.065,1.05,16),kioskMat);post.position.y=.525;post.castShadow=true;
 const reader=new THREE.Mesh(new THREE.BoxGeometry(.22,.16,.055),kioskMat);reader.position.set(0,1.1,0);reader.rotation.x=-.42;reader.castShadow=true;
 const lightMat=new THREE.MeshStandardMaterial({color:'#344a53',emissive:'#162a33',emissiveIntensity:.5,roughness:.38});
 const indicator=new THREE.Mesh(new THREE.BoxGeometry(.16,.016,.006),lightMat);indicator.position.set(0,.04,.03);reader.add(indicator);
 // Bolted base plate and a small rain hood over the reader face; the post meets the road instead of floating on it.
 const plate=new THREE.Mesh(new THREE.CylinderGeometry(.16,.17,.022,20),kioskMat);plate.position.y=.011;plate.receiveShadow=true;
 const hood=new THREE.Mesh(new THREE.BoxGeometry(.25,.012,.1),kioskMat);hood.position.set(0,.09,-.012);hood.rotation.x=.18;reader.add(hood);
 kiosk.add(post,reader,plate);
 kiosk.updateWorldMatrix(true,true);
 const readerPoint=reader.localToWorld(new THREE.Vector3(0,0,.07));
 const cardTexture=await identityTexture(host.dataset.logo);
 const card=new THREE.Mesh(new THREE.BoxGeometry(.086,.054,.0018),new THREE.MeshStandardMaterial({map:cardTexture,roughness:.34,metalness:0}));
 card.name='student-university-id';card.castShadow=true;scene.add(card);
 const contact=new THREE.MeshBasicMaterial({map:contactShadowTexture(),transparent:true,depthWrite:false,opacity:.5});
 for(const person of [guard,visitor]){
  const blob=new THREE.Mesh(new THREE.PlaneGeometry(.66,.55),contact);blob.rotation.x=-Math.PI/2;blob.position.y=.004;person.root.add(blob);
 }
 const kioskShadow=new THREE.Mesh(new THREE.PlaneGeometry(.5,.5),contact);kioskShadow.rotation.x=-Math.PI/2;kioskShadow.position.y=.003;kiosk.add(kioskShadow);

 const camera=new THREE.PerspectiveCamera(38,1,.1,220);
 let basePosition=new THREE.Vector3(),baseTarget=new THREE.Vector3(),reduced=!!options.reducedMotion,paused=false,disposed=false,raf=0;
 let state='idle',progress=0,entryStart=0,resolveEntry,onVeil,veiled=false,clock=0,lastTime=0,draws=0,contextLost=false;
 let reachWeight=0,welcomeWeight=0,walkDistance=0,lastWalkDistance=0,heading=visitorHeading;
 // Entry: the gates open, then the student turns toward the far side of the gate and walks through it at a natural pace.
 const ENTRY_MS=4000,WALK_FROM=.06,WALK_SPEED=1.8,walkGoal=new THREE.Vector3(.55,0,-2.2);
 const flightPoint=new THREE.Vector3(),flightLook=new THREE.Vector3(),exitPosition=new THREE.Vector3(),exitTarget=new THREE.Vector3();
 const gazeReader=readerPoint.clone(),guardGaze=new THREE.Vector3(),visitorGaze=new THREE.Vector3();
 const handPoint=new THREE.Vector3();
 // Per-frame temporaries, reused so the render loop allocates nothing.
 const guardFace=new THREE.Vector3(guardHome.x,1.64,guardHome.z),guardReach=new THREE.Vector3(2.28,1.16,5.66),cardOffset=new THREE.Vector3(0,-.025,.018);
 const cardEuler=new THREE.Euler(),cardRest=new THREE.Quaternion(),cardScan=new THREE.Quaternion().setFromEuler(new THREE.Euler(-.42,-.62,0));
 const visitorPose={},guardPose={};
 const smooth=t=>t*t*(3-2*t);
 function resize(){
  const {width,height}=container.getBoundingClientRect();if(!width||!height)return;
  renderer.setSize(width,height,false);camera.aspect=width/height;
  const aspect=width/height;
  if(aspect<.9){basePosition.set(1,2,25);baseTarget.set(.4,2,1.1);camera.fov=46;}
  else if(width<=1100){basePosition.set(1.3,1.85,19);baseTarget.set(-2,2.45,.5);camera.fov=41;}
  else{basePosition.set(1,1.8,21);baseTarget.set(-2.9,2.7,.5);camera.fov=40;}
  // Side-by-side layouts frame the gate beside the card; in RTL the card is on the right, so the aim swings to the other side
  // (mirrored about the camera, eased back slightly so both flagpoles stay clear of the card).
  if(aspect>=.9&&document.documentElement.dir==="rtl")baseTarget.x=2*basePosition.x-baseTarget.x-.4;
  exitPosition.copy(basePosition).add(new THREE.Vector3(-.25,0,-1.6));exitTarget.copy(baseTarget).add(new THREE.Vector3(.1,-.12,-1));
  if(!entryStart){camera.position.copy(basePosition);camera.lookAt(baseTarget);}
  camera.updateProjectionMatrix();draw();
 }
 function draw(){if(!disposed&&!contextLost){renderer.render(scene,camera);draws++;}}
 function setTargets(){
  const color=state==='success'?'#52c491':state==='submitting'?'#dfa849':state==='denied'?'#c75c54':'#527485';
  lightMat.color.set(color);lightMat.emissive.set(color);lightMat.emissiveIntensity=state==='idle'?.18:.55;
 }
 function updatePeople(dt,snap=false){
  const k=snap?1:1-Math.exp(-dt*4.8);
  const reach=state==='submitting'?.94:state==='success'?.72:state==='denied'?.28:.12;
  reachWeight+=(reach-reachWeight)*k;
  welcomeWeight+=((state==='success'?1:0)-welcomeWeight)*k;
  const walking=entryStart&&progress>WALK_FROM;
  const pos=visitor.root.position;
  const angle=walking?Math.atan2(walkGoal.x-pos.x,walkGoal.z-pos.z):visitorHeading;
  heading+=Math.atan2(Math.sin(angle-heading),Math.cos(angle-heading))*(snap?1:1-Math.exp(-dt*(walking?5:3.2)));
  visitor.root.rotation.y=heading;
  // Steps follow the body's current heading (no sideways slide while turning) and ease in over the first half second.
  if(walking&&!snap&&!paused&&!reduced){
   const since=(progress-WALK_FROM)*ENTRY_MS/1000,turned=Math.max(0,Math.cos(angle-heading));
   const step=WALK_SPEED*Math.min(1,since/.5)*turned*dt;
   pos.x+=Math.sin(heading)*step;pos.z+=Math.cos(heading)*step;walkDistance+=step;
  }
  guardGaze.set(visitor.root.position.x,1.64,visitor.root.position.z);
  visitorGaze.copy(state==='submitting'?gazeReader:guardFace);
  // While nothing is happening, each of them occasionally glances away: the guard down the approach road, the student up
  // at the gate sign. Different periods keep the glances from lining up; the gaze follower eases each turn.
  if(state==='idle'&&!entryStart&&!reduced){
   if(clock%9.5>7.4)guardGaze.set(1.2,1.5,15);
   if((clock+4)%12.5>10.9)visitorGaze.set(-.6,3.9,.5);
  }
  const still=snap||reduced||paused;
  const motionDt=still?0:dt;
  Object.assign(visitorPose,{time:clock,heading,walking:walking?1:0,step:walkDistance-lastWalkDistance,target:visitorGaze,reach:readerPoint,reachWeight:walking?0:reachWeight,still});
  Object.assign(guardPose,{time:clock,heading:guardHeading,walking:0,step:0,target:state==='submitting'?gazeReader:guardGaze,reach:guardReach,reachWeight:state==='submitting'?.35:welcomeWeight*.52,still});
  visitor.update(motionDt,visitorPose);guard.update(motionDt,guardPose);
  lastWalkDistance=walkDistance;
  if(visitor.hand){
   visitor.hand.getWorldPosition(handPoint);card.position.copy(handPoint).add(cardOffset);
   // Align the laminated ID with the reader while presenting it; otherwise it rests naturally in the hand.
   cardRest.setFromEuler(cardEuler.set(-.28,heading,0));card.quaternion.copy(cardRest).slerp(cardScan,reachWeight);
  }
 }
 // Gradual quality: frame intervals are averaged; after a sustained slow second the resolution drops by 0.1, and after
 // five fast seconds it climbs back by 0.05. Steps are small, so the change reads as a slight softening, not a jump.
 let interval=16.7,slowFor=0,fastFor=0,frameCost=0;
 function adapt(ms){
  interval+=(Math.min(ms,100)-interval)*.05;
  slowFor=interval>24?slowFor+ms:0; fastFor=interval<15?fastFor+ms:0;
  let next=pixelRatio;
  if(slowFor>1000&&pixelRatio>minRatio){next=Math.max(minRatio,pixelRatio-.1);slowFor=0;}
  else if(fastFor>5000&&pixelRatio<maxRatio){next=Math.min(maxRatio,pixelRatio+.05);fastFor=0;}
  if(next!==pixelRatio){pixelRatio=next;renderer.setPixelRatio(pixelRatio);const {width,height}=container.getBoundingClientRect();if(width&&height)renderer.setSize(width,height,false);}
 }
 function frame(now){
  raf=0;if(disposed||contextLost||document.hidden)return;
  const begin=performance.now();
  if(lastTime&&!paused)adapt(now-lastTime);
  const dt=lastTime?Math.min((now-lastTime)/1000,.05):1/60;lastTime=now;
  if(!paused&&!reduced)clock+=dt;
  if(entryStart){
   progress=Math.min((now-entryStart)/ENTRY_MS,1);
   const open=smooth(Math.min(progress/.34,1));leaves[0].position.x=-(2.5+5.1*open);leaves[1].position.x=2.5+5.1*open;
   const travel=smooth(Math.max(0,(progress-.08)/.92));
   flightPoint.copy(basePosition).lerp(exitPosition,travel);flightLook.copy(baseTarget).lerp(exitTarget,travel);
   camera.position.copy(flightPoint);camera.lookAt(flightLook);
   // A human-speed dolly and the shared veil bridge the remaining walk; no FOV acceleration.
   if(!veiled&&progress>=.9){veiled=true;onVeil?.();}
  }
  updatePeople(dt);if(!paused&&!reduced)gate.updateCloth(clock,.32);draw();
  frameCost+=(performance.now()-begin-frameCost)*.1;
  if(entryStart&&progress>=1){entryStart=0;const done=resolveEntry;resolveEntry=null;done?.();}
  const settling=Math.abs(reachWeight-(state==='submitting'?.94:state==='success'?.72:state==='denied'?.28:.12))>.002;
  if(entryStart||settling||(!paused&&!reduced))raf=requestAnimationFrame(frame);
 }
 function start(){if(!raf&&!disposed&&!contextLost&&!document.hidden){lastTime=0;raf=requestAnimationFrame(frame);}}
 function visibility(){if(document.hidden){cancelAnimationFrame(raf);raf=0;lastTime=0;}else start();}
 function setReducedMotion(value){reduced=value;pause.hidden=value;if(value){updatePeople(0,true);draw();}start();}
 function togglePause(){paused=!paused;pause.textContent=window.uimsT(paused?'ResumeScene':'PauseScene');pause.setAttribute('aria-pressed',String(paused));start();}
 function lost(event){event.preventDefault();contextLost=true;host.removeAttribute('data-scene-ready');cancelAnimationFrame(raf);raf=0;pause.hidden=true;resolveEntry?.();resolveEntry=null;}
 const observer=new ResizeObserver(resize);observer.observe(container);
 document.addEventListener('visibilitychange',visibility);pause.addEventListener('click',togglePause);renderer.domElement.addEventListener('webglcontextlost',lost);
 updatePeople(0,true);setTargets();
 // Compile every shader before the first frame (parallel where the driver supports it), so the first visible frame is
 // complete and no program compiles mid-animation; the caller crossfades from the photograph only after this resolves.
 try { await renderer.compileAsync(scene,camera); } catch (error) { /* older drivers compile on first render */ }
 stage('compiled'); resize(); stage('first-frame');pause.hidden=reduced;start();host.dataset.actorFidelity='skinned';
 return {
  setState(value){if(!['idle','submitting','success','denied'].includes(value))return;state=value;setTargets();if(reduced)updatePeople(0,true);start();},setReducedMotion,
  enter(options={}){onVeil=options.onVeil;veiled=false;if(reduced){onVeil?.();return Promise.resolve();}if(resolveEntry)return Promise.resolve();return new Promise(resolve=>{resolveEntry=resolve;entryStart=performance.now();lastWalkDistance=walkDistance=0;start();});},
  snapshot(){return this.inspect();},
  inspect(){return {state,progress,paused,reduced,contextLost,draws,pixelRatio,frameCostMs:+frameCost.toFixed(2),frameIntervalMs:+interval.toFixed(1),triangles:renderer.info.render.triangles,flags:[jordan,germany].map(flag=>({name:flag.name,visible:flag.visible,x:flag.position.x})),poles:flagPoles.map(pole=>({country:pole.country,x:pole.x,z:pole.z})),leaves:leaves.map(leaf=>leaf.position.x),actors:[guard.root,visitor.root].map(root=>({name:root.name,role:root.userData.role,position:root.position.toArray(),bones:root.getObjectByProperty('isSkinnedMesh',true)?.skeleton.bones.length})),card:card.position.toArray(),camera:camera.position.toArray(),fov:camera.fov,drawCalls:renderer.info.render.calls};},
  dispose(){
   if(disposed)return;disposed=true;cancelAnimationFrame(raf);observer.disconnect();actors.dispose();
   document.removeEventListener('visibilitychange',visibility);pause.removeEventListener('click',togglePause);renderer.domElement.removeEventListener('webglcontextlost',lost);
   const geometries=new Set(),materials=new Set(),textures=new Set();
   scene.traverse(object=>{if(object.geometry)geometries.add(object.geometry);for(const material of object.material?(Array.isArray(object.material)?object.material:[object.material]):[]){materials.add(material);for(const value of Object.values(material))if(value?.isTexture)textures.add(value);}});
   geometries.forEach(g=>g.dispose());textures.forEach(t=>t.dispose());materials.forEach(m=>m.dispose());environmentTarget?.dispose();renderer.renderLists.dispose();renderer.dispose();renderer.forceContextLoss();renderer.domElement.remove();resolveEntry?.();resolveEntry=null;
  }
 };
}
