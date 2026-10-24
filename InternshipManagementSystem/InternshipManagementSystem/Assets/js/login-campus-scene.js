import * as THREE from './vendor/three.module.min.js';
import { createGateModel } from './home-gate-model.js';
import { architecturalUV } from './home-campus-materials.js';

// Rigid, fictional adult figures: no likeness, dialogue, facial or skeletal animation.
function createPerson(uniform) {
 const root = new THREE.Group(); root.name = uniform ? 'campus-security-guard' : 'adult-campus-visitor';
 const skin = new THREE.MeshStandardMaterial({ color:uniform ? '#9a6e52' : '#c08d6b', roughness:.8 });
 const shirt = new THREE.MeshStandardMaterial({ color:uniform ? '#2b4f70' : '#e9e2d3', roughness:.9 });
 const outer = new THREE.MeshStandardMaterial({ color:uniform ? '#1f3a54' : '#6f7f73', roughness:.88 });
 const trousers = new THREE.MeshStandardMaterial({ color:uniform ? '#1f2b36' : '#3d4a55', roughness:.92 });
 const dark = new THREE.MeshStandardMaterial({ color:'#1d252b', roughness:.7 });
 function mesh(name, geometry, material, position, parent = root) {
  const object = new THREE.Mesh(geometry, material); object.name = name;
  object.position.fromArray(position); object.castShadow = true; parent.add(object); return object;
 }
 const torso = mesh('torso', new THREE.CapsuleGeometry(.21,.4,4,10), uniform ? shirt : outer, [0,1.15,0]); torso.scale.z = .72;
 if (!uniform) { const collar = mesh('shirt-collar', new THREE.CylinderGeometry(.1,.13,.08,10), shirt, [0,1.49,0]); collar.scale.z = .8; }
 mesh('neck', new THREE.CylinderGeometry(.07,.078,.12,10), skin, [0,1.54,0]);
 const head = new THREE.Group(); head.name = 'head-pivot'; head.position.set(0,1.6,0); root.add(head);
 const skull = mesh('head', new THREE.SphereGeometry(.145,16,12), skin, [0,.12,0], head); skull.scale.set(.88,1.12,.92);
 // Hair is a continuous upper hemisphere, seated on the head.
 mesh('hair', new THREE.SphereGeometry(.148,16,8,0,Math.PI*2,0,Math.PI/2.1), dark, [0,.155,-.008], head).scale.set(.9,1,.95);
 for (const side of [-1,1]) {
  mesh('trouser-leg-'+side, new THREE.CapsuleGeometry(.095,.62,4,8), trousers, [side*.11,.47,0]);
  const shoe = mesh('shoe-'+side, new THREE.SphereGeometry(.1,10,6), dark, [side*.11,.07,.05]); shoe.scale.set(1,.6,1.7);
 }
 const arms = [];
 for (const side of [-1,1]) {
  const pivot = new THREE.Group(); pivot.name = 'shoulder-'+side; pivot.position.set(side*.255,1.39,0); root.add(pivot);
  mesh('sleeve-'+side, new THREE.CapsuleGeometry(.072,.3,4,8), uniform ? shirt : outer, [0,-.17,0], pivot);
  mesh('forearm-'+side, new THREE.CapsuleGeometry(.058,.2,4,8), uniform ? skin : outer, [0,-.43,0], pivot);
  mesh('hand-'+side, new THREE.SphereGeometry(.062,10,8), skin, [0,-.6,0], pivot); arms.push(pivot);
 }
 if (uniform) {
  mesh('cap', new THREE.CylinderGeometry(.152,.15,.09,16), outer, [0,.27,0], head);
  mesh('cap-visor', new THREE.BoxGeometry(.22,.02,.13), dark, [0,.235,.13], head);
  mesh('badge', new THREE.BoxGeometry(.055,.07,.012), new THREE.MeshStandardMaterial({ color:'#cfae62', metalness:.5, roughness:.45 }), [-.09,1.3,.155]);
  mesh('shoulder-radio', new THREE.BoxGeometry(.05,.09,.03), dark, [.1,1.33,.155]);
  mesh('belt', new THREE.BoxGeometry(.4,.06,.29), dark, [0,.93,0]);
  for (const side of [-1,1]) mesh('epaulette-'+side, new THREE.BoxGeometry(.12,.02,.1), outer, [side*.17,1.47,0]);
 } else {
  // Lanyard and entry pass; the pass travels with the right hand when presented.
  mesh('lanyard', new THREE.TorusGeometry(.13,.008,4,24,Math.PI), new THREE.MeshStandardMaterial({ color:'#264f73', roughness:.8 }), [0,1.42,.1]).rotation.set(Math.PI*.55,0,Math.PI);
  const pass = mesh('entry-pass', new THREE.BoxGeometry(.09,.13,.01), new THREE.MeshStandardMaterial({ color:'#fbfbf8', roughness:.7 }), [0,-.66,.07], arms[1]);
  mesh('pass-band', new THREE.BoxGeometry(.09,.03,.012), new THREE.MeshStandardMaterial({ color:'#f2a900', roughness:.7 }), [0,.04,.001], pass);
 }
 return { root, arms, head };
}

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

export async function createCampusScene(host, options) {
 const container = host.querySelector('[data-campus-canvas]');
 const pause = host.querySelector('[data-campus-pause]');
 const compact = innerWidth <= 640;
 let renderer, gate;
 const scene = new THREE.Scene();
 try {
  renderer = new THREE.WebGLRenderer({ antialias:!compact, alpha:false, powerPreference:'low-power' });
  gate = await createGateModel(host.dataset.logo);
 } catch (error) { renderer?.dispose(); throw error; }
 scene.background = new THREE.Color('#dfe9ef'); scene.fog = new THREE.Fog('#e3ebee',46,110);
 renderer.setPixelRatio(Math.min(devicePixelRatio,compact?1.25:1.5));
 renderer.shadowMap.enabled = !compact; renderer.shadowMap.type = THREE.PCFSoftShadowMap;
 renderer.outputColorSpace = THREE.SRGBColorSpace; renderer.toneMapping = THREE.ACESFilmicToneMapping;
 renderer.toneMappingExposure = 1.05; container.appendChild(renderer.domElement);
 scene.add(new THREE.HemisphereLight('#dcecff','#b8a98c',2.1));
 const sun = new THREE.DirectionalLight('#fff3df',3.4); sun.position.set(-9,15,13); sun.castShadow = true;
 sun.shadow.mapSize.set(1536,1536); Object.assign(sun.shadow.camera,{left:-14,right:14,top:12,bottom:-10,near:1,far:50}); sun.shadow.bias = -.0008; sun.shadow.normalBias = .02;
 scene.add(sun);
 const sky = new THREE.Mesh(new THREE.SphereGeometry(120,32,16), new THREE.MeshBasicMaterial({ map:skyTexture(), side:THREE.BackSide, fog:false, depthWrite:false, toneMapped:false }));
 sky.name = 'daylight-sky'; scene.add(sky);
 scene.add(gate.root);

 // Login's reference (b1138b1f) shows two Jordan flags inside the portal, unlike Home's staging.
 // Adapt this instance only, keeping the shared Home model and its callers unchanged.
 gate.parts.get('flagpoles').scale.y = 3.5 / 8.5;
 const jordan = gate.parts.get('jordan-flag'), germany = gate.parts.get('germany-flag');
 germany.visible = false;
 jordan.scale.setScalar(.6); jordan.position.set(-3.2 + .91,3,-1.35);
 const secondJordan = jordan.clone(); secondJordan.name = 'login-jordan-flag-right';
 secondJordan.position.x = 1.55 + .91; gate.root.add(secondJordan);
 // Reference-toned limestone courses on the stationary structure.
 const portal = gate.parts.get('limestone-portal').children[0].material;
 portal.map = limestoneTexture(); portal.color.set('#ffffff'); portal.needsUpdate = true;
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
 ground.name = 'campus-ground'; ground.rotation.x = -Math.PI/2; ground.position.y = -.26; ground.receiveShadow = true; scene.add(ground);
 const asphalt = new THREE.MeshStandardMaterial({ color:'#a3a7a6', roughness:.95 });
 block('approach-road-inner', [8.8,.02,60], [0,-.04,-37], asphalt, false);
 block('approach-road-outer', [8.8,.02,12], [0,-.2,10], asphalt, false);
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
 const trunkGeo = new THREE.CylinderGeometry(.12,.15,1.6,6), crownGeo = new THREE.IcosahedronGeometry(1,1);
 const trunkMat = new THREE.MeshStandardMaterial({ color:'#80705c', roughness:1 }), crownMat = new THREE.MeshStandardMaterial({ color:'#8aa07a', roughness:1, flatShading:true });
 for (const [x,z,s] of [[-9,-6,1.1],[-10.5,-11,1.3],[11,-8,1.2],[12.5,-15,1.4],[10,-22,1],[-24,-14,1.5],[-8,-36,1.2],[13,-33,1.3]]) {
  const trunk = new THREE.Mesh(trunkGeo,trunkMat); trunk.position.set(x,.8,z); surroundings.add(trunk);
  const crown = new THREE.Mesh(crownGeo,crownMat); crown.position.set(x,2.3*s,z); crown.scale.set(s*1.1,s*1.35,s*1.1); crown.castShadow = !compact; surroundings.add(crown);
 }

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

 const guard = createPerson(true), visitor = createPerson(false);
 guard.root.position.set(4.3,0,3.1); guard.root.rotation.y = -.75;
 visitor.root.position.set(2.85,0,3.95); visitor.root.rotation.y = 1.05; scene.add(guard.root, visitor.root);
 // Verification kiosk beside the guard; its status light is the only colour cue.
 const kiosk = new THREE.Group(); kiosk.name = 'verification-device'; kiosk.position.set(3.65,0,2.75); kiosk.rotation.y = -.5; scene.add(kiosk);
 const kioskMat = new THREE.MeshStandardMaterial({ color:'#2a3740', roughness:.55, metalness:.3 });
 const post = new THREE.Mesh(new THREE.CylinderGeometry(.04,.06,1.05,10),kioskMat); post.position.y = .52; post.castShadow = true;
 const reader = new THREE.Mesh(new THREE.BoxGeometry(.3,.2,.06),kioskMat); reader.position.set(0,1.1,0); reader.rotation.x = -.6; reader.castShadow = true;
 const lightMat = new THREE.MeshStandardMaterial({ color:'#3c4a52', emissive:'#000000', roughness:.4 });
 const indicator = new THREE.Mesh(new THREE.BoxGeometry(.2,.035,.012),lightMat); indicator.position.set(0,.03,.032); reader.add(indicator);
 kiosk.add(post,reader);
 const contact = new THREE.MeshBasicMaterial({ map:contactShadowTexture(), transparent:true, depthWrite:false });
 for (const person of [guard,visitor]) {
  const blob = new THREE.Mesh(new THREE.PlaneGeometry(.9,.9),contact); blob.rotation.x = -Math.PI/2; blob.position.y = .012; person.root.add(blob);
 }

 const camera = new THREE.PerspectiveCamera(38,1,.1,260);
 let basePosition = new THREE.Vector3(), baseTarget = new THREE.Vector3(), reduced = options.reducedMotion, paused = false, disposed = false, raf = 0;
 let state = 'idle', progress = 0, entryStart = 0, resolveEntry, onVeil, veiled = false, clock = 0, lastTime = 0, settling = 0, baseFov = 38;
 // Entry flight: a curve that lines up with the road first, then passes midway between
 // the flagpoles (x = -3.2 and 1.55) and carries on down the campus approach.
 const ENTRY_MS = 1400;
 const entryVia = new THREE.Vector3(-.6,1.9,8), exitPosition = new THREE.Vector3(-.8,1.65,-7), exitTarget = new THREE.Vector3(-.8,1.75,-30);
 const flightPoint = new THREE.Vector3(), flightLook = new THREE.Vector3();
 const easeInOut = t => t < .5 ? 4*t*t*t : 1-Math.pow(-2*t+2,3)/2;
 function resize() {
  const {width,height} = container.getBoundingClientRect(); if (!width || !height) return;
  renderer.setSize(width,height,false); camera.aspect = width/height;
  const aspect = width/height;
  if (aspect < .9) { basePosition.set(1.2,2.7,27.5); baseTarget.set(.7,2.2,0); baseFov = 44; }
  else if (width <= 1100) { basePosition.set(1.4,2.4,21); baseTarget.set(-2.6,2.8,0); baseFov = 40; }
  else { basePosition.set(1.4,2.1,20.5); baseTarget.set(-4.3,3,0); baseFov = 38; }
  if (!entryStart) { camera.fov = baseFov; camera.position.copy(basePosition); camera.lookAt(baseTarget); }
  camera.updateProjectionMatrix(); draw();
 }
 function draw() { if (!disposed) renderer.render(scene,camera); }
 // Restrained target poses; the loop eases toward them instead of snapping.
 const targets = { visitorArmX:0, visitorArmZ:0, visitorHead:0, guardHeadX:0, guardHeadY:0, guardArmX:0, guardArmZ:0 };
 function setTargets() {
  const checking = state === 'submitting', success = state === 'success', denied = state === 'denied';
  Object.assign(targets, {
   visitorArmX: checking || success ? -1.05 : 0, visitorArmZ: checking ? -.3 : 0, visitorHead: checking ? .12 : 0,
   guardHeadX: checking ? .22 : denied ? .12 : 0, guardHeadY: checking ? .35 : denied ? .5 : 0,
   guardArmX: success ? -.55 : 0, guardArmZ: success ? -1.15 : 0
  });
  // Amber while checking, green when verified, red when the details were refused.
  const light = success ? '#2fae6b' : checking ? '#e3a21a' : denied ? '#d64545' : null;
  lightMat.emissive.set(light || '#000000'); lightMat.color.set(light || '#3c4a52');
  settling = reduced ? 0 : 1;
 }
 function applyPose(rate) {
  const ease = (object, key, value) => { object[key] += (value - object[key]) * rate; };
  ease(visitor.arms[1].rotation,'x',targets.visitorArmX); ease(visitor.arms[1].rotation,'z',targets.visitorArmZ);
  ease(visitor.head.rotation,'x',targets.visitorHead);
  ease(guard.head.rotation,'x',targets.guardHeadX); ease(guard.head.rotation,'y',targets.guardHeadY);
  // The guard's own right arm (the -X side) gives the small welcoming gesture.
  ease(guard.arms[0].rotation,'x',targets.guardArmX); ease(guard.arms[0].rotation,'z',targets.guardArmZ);
  const remaining = Math.abs(visitor.arms[1].rotation.x - targets.visitorArmX) + Math.abs(guard.arms[0].rotation.z - targets.guardArmZ) + Math.abs(guard.head.rotation.y - targets.guardHeadY);
  if (remaining < .002) settling = 0;
 }
 function ambient(time) {
  if (reduced || paused) return;
  gate.updateCloth(time,.45);
  guard.root.position.y = .005*Math.sin(time*1.4);
  visitor.root.rotation.y = 1.05 + .025*Math.sin(time*.5);
 }
 function frame(now) {
  raf = 0; if (disposed || document.hidden) return;
  const delta = lastTime ? Math.min((now-lastTime)/1000,.05) : 0; clock += delta; lastTime = now;
  if (entryStart) {
   progress = Math.min((now-entryStart)/ENTRY_MS,1);
   // Gates finish opening well before the camera reaches them (~66% of the flight).
   const open = 1-Math.pow(1-Math.min(progress/.45,1),3);
   const t = easeInOut(Math.max(0,(progress-.06)/.94)), u = 1-t;
   leaves.forEach((leaf,i) => leaf.position.x = (i?1:-1)*(2.5+5.1*open));
   flightPoint.copy(basePosition).multiplyScalar(u*u).addScaledVector(entryVia,2*u*t).addScaledVector(exitPosition,t*t);
   flightLook.copy(baseTarget).lerp(exitTarget,1-Math.pow(1-Math.min(t/.7,1),2));
   camera.position.copy(flightPoint); camera.lookAt(flightLook);
   camera.fov = baseFov + 12*t*t; camera.updateProjectionMatrix();
   // The page veil starts fading in as the camera crosses the gateway.
   if (!veiled && progress >= .64) { veiled = true; onVeil?.(); }
   if(progress===1){entryStart=0;resolveEntry?.();resolveEntry=null;}
  }
  if (settling) applyPose(1-Math.exp(-delta*9));
  ambient(clock); draw();
  if (entryStart || settling || (!paused && !reduced)) raf = requestAnimationFrame(frame);
 }
 function start() { if (!raf && !disposed && !document.hidden) { lastTime = 0; raf = requestAnimationFrame(frame); } }
 function visibility() { if (document.hidden) { cancelAnimationFrame(raf); raf = 0; lastTime = 0; } else start(); }
 function snap() { applyPose(1); settling = 0; draw(); }
 function setReducedMotion(value) { reduced = value; pause.hidden = value; if (value) snap(); start(); }
 function togglePause() { paused = !paused; pause.textContent = (paused ? (typeof window.uimsT==='function'?window.uimsT:function(k){return k;})('ResumeScene') : (typeof window.uimsT==='function'?window.uimsT:function(k){return k;})('PauseScene')); pause.setAttribute('aria-pressed',String(paused)); start(); }
 function lost(event) { event.preventDefault(); host.removeAttribute('data-scene-ready'); cancelAnimationFrame(raf); raf = 0; pause.hidden = true; resolveEntry?.(); }
 const observer = new ResizeObserver(resize); observer.observe(container);
 document.addEventListener('visibilitychange',visibility); pause.addEventListener('click',togglePause); renderer.domElement.addEventListener('webglcontextlost',lost);
 resize(); setTargets(); snap(); pause.hidden = reduced; start();
 return {
  setState(value){state=value;setTargets();if(reduced)snap();start();},setReducedMotion,
  enter(options={}){onVeil=options.onVeil;veiled=false;if(reduced){onVeil?.();return Promise.resolve();}return new Promise(resolve=>{resolveEntry=resolve;entryStart=performance.now();start();});},
  dispose(){
   if(disposed)return;disposed=true;cancelAnimationFrame(raf);observer.disconnect();
   document.removeEventListener('visibilitychange',visibility);pause.removeEventListener('click',togglePause);renderer.domElement.removeEventListener('webglcontextlost',lost);
   const geometries=new Set(),materials=new Set(),textures=new Set();
   scene.traverse(object=>{if(object.geometry)geometries.add(object.geometry);for(const material of object.material?(Array.isArray(object.material)?object.material:[object.material]):[]){materials.add(material);for(const value of Object.values(material))if(value?.isTexture)textures.add(value);}});
   geometries.forEach(g=>g.dispose());textures.forEach(t=>t.dispose());materials.forEach(m=>m.dispose());renderer.dispose();renderer.domElement.remove();
  }
 };
}
