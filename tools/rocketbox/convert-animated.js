// Development-only converter: Rocketbox FBX avatar + motion-capture clips -> one skinned, animated GLB.
// Unlike convert.js (frozen seated figures), this keeps the skeleton so the page can blend walk,
// idle and look clips and turn the head procedurally. See tools/rocketbox/README.md.
import * as THREE from 'three';
import { FBXLoader } from './vendor/loaders/FBXLoader.js';
import { TGALoader } from './vendor/loaders/TGALoader.js';

const RAW = '/raw/Assets/';
const manager = new THREE.LoadingManager();
manager.addHandler(/\.tga$/i, new TGALoader(manager));

const CLIPS = {
 walk: 'all_animations_max_motextr_xy/m_walk_neutral_01.max.fbx',
 stop: 'all_animations_max_motextr_xy/m_walk_stop.max.fbx',
 look: 'all_animations_max_motextr_static/m_idle_look_around_01.max.fbx'
};

async function loadAvatar(name) {
 const loader = new FBXLoader(manager);
 loader.setResourcePath(`${RAW}Avatars/Adults/${name}/Textures/`);
 return loader.loadAsync(`${RAW}Avatars/Adults/${name}/Export/${name}.fbx`);
}
async function loadClip(key) {
 const fbx = await new FBXLoader(manager).loadAsync(`${RAW}Animations/${CLIPS[key]}`);
 const clip = fbx.animations[0]; clip.name = key; return clip;
}

// Which bone carries the root motion, and along which axis does the walk travel?
function motionReport(clip) {
 const out = [];
 for (const track of clip.tracks) {
  if (!track.name.endsWith('.position')) continue;
  const v = track.values, n = v.length / 3, first = [v[0], v[1], v[2]], last = [v[(n - 1) * 3], v[(n - 1) * 3 + 1], v[(n - 1) * 3 + 2]];
  const delta = last.map((x, i) => +(x - first[i]).toFixed(2));
  if (delta.some(d => Math.abs(d) > 1)) out.push({ track: track.name, delta, keys: n });
 }
 return out;
}

async function inspect(name) {
 const root = await loadAvatar(name);
 const report = { bones: [], meshes: [], clips: {} };
 root.traverse(o => {
  if (o.isBone && report.bones.length < 8) report.bones.push(o.name);
  if (o.isMesh) report.meshes.push({ name: o.name, skinned: !!o.isSkinnedMesh, vertices: o.geometry.attributes.position.count, materials: [].concat(o.material).map(m => ({ name: m.name, map: !!m.map, normalMap: !!m.normalMap, transparent: m.transparent, alphaMap: !!m.alphaMap })) });
 });
 report.rootRotation = root.rotation.toArray().slice(0, 3).map(v => +v.toFixed(3));
 report.rootScale = root.scale.toArray();
 for (const key of Object.keys(CLIPS)) { const clip = await loadClip(key); report.clips[key] = { duration: +clip.duration.toFixed(2), tracks: clip.tracks.length, motion: motionReport(clip) }; }
 return report;
}

// Remove horizontal travel from the root bone so code decides where the student walks.
// The stride length per second is returned so playback can be matched to ground speed.
function stripRootMotion(clip, rootTrack, axes) {
 if (Array.isArray(rootTrack)) return Math.max(...rootTrack.map(t => stripRootMotion(clip, t, axes)));
 const track = clip.tracks.find(t => t.name === rootTrack);
 if (!track) return 0;
 const v = track.values, times = track.times, n = times.length;
 let speed = 0;
 for (const axis of axes) {
  const a = v[axis], b = v[(n - 1) * 3 + axis], rate = (b - a) / (times[n - 1] - times[0]);
  speed = Math.max(speed, Math.abs(rate));
  for (let i = 0; i < n; i++) v[i * 3 + axis] -= a + rate * (times[i] - times[0]);
 }
 return speed;
}

function waitForTextures(mesh) {
 const ready = t => !t || !!t.image?.data || (t.image instanceof HTMLImageElement && t.image.complete && t.image.naturalWidth > 0);
 return new Promise((resolve, reject) => {
  let waited = 0;
  const tick = () => {
   if ([].concat(mesh.material).every(m => ready(m.map))) return resolve();
   if ((waited += 100) > 60000) return reject(new Error('textures timed out'));
   setTimeout(tick, 100);
  };
  tick();
 });
}

function textureCanvas(texture, size) {
 const image = texture.image, canvas = document.createElement('canvas'); canvas.width = canvas.height = size;
 const c = canvas.getContext('2d');
 if (image.data) {
  const full = document.createElement('canvas'); full.width = image.width; full.height = image.height;
  full.getContext('2d').putImageData(new ImageData(new Uint8ClampedArray(image.data.buffer, image.data.byteOffset, image.width * image.height * 4), image.width, image.height), 0, 0);
  if (texture.flipY) { c.translate(0, size); c.scale(1, -1); }
  c.drawImage(full, 0, 0, size, size);
 } else c.drawImage(image, 0, 0, size, size);
 return canvas;
}

// Bake: skinned mesh + skeleton + clips, metres, facing +z, feet on y = 0.
async function bake(name, { rootTrack, axes, size = 1024 } = {}) {
 const root = await loadAvatar(name);
 let mesh = null; root.traverse(o => { if (o.isSkinnedMesh && !mesh) mesh = o; });
 await waitForTextures(mesh);
 const clips = {}; for (const key of Object.keys(CLIPS)) clips[key] = await loadClip(key);
 const walkSpeed = stripRootMotion(clips.walk, rootTrack, axes);
 stripRootMotion(clips.stop, rootTrack, axes);
 stripRootMotion(clips.look, rootTrack, axes);
 // Smaller file: drop scale tracks and redundant keys (mocap holds many bones still).
 for (const clip of Object.values(clips)) { clip.tracks = clip.tracks.filter(t => !t.name.endsWith('.scale')); clip.optimize(); }
 const materials = [].concat(mesh.material).map(source => {
  const map = new THREE.CanvasTexture(textureCanvas(source.map, size)); map.colorSpace = THREE.SRGBColorSpace; map.flipY = false; map.userData.mimeType = 'image/jpeg';
  let normalMap = null;
  if (source.normalMap?.image?.data || source.normalMap?.image?.naturalWidth) { normalMap = new THREE.CanvasTexture(textureCanvas(source.normalMap, size)); normalMap.flipY = false; normalMap.userData.mimeType = 'image/jpeg'; }
  return new THREE.MeshStandardMaterial({ name: source.name, map, normalMap, roughness: .78, metalness: 0 });
 });
 mesh.material = materials.length === 1 ? materials[0] : materials;
 root.scale.multiplyScalar(.01);
 root.name = 'student';
 const scene = new THREE.Scene(); scene.add(root);
 const { GLTFExporter } = await import('./vendor/exporters/GLTFExporter.js');
 const glb = await new GLTFExporter().parseAsync(scene, { binary: true, animations: Object.values(clips) });
 return { glb, walkSpeed: walkSpeed * .01, durations: Object.fromEntries(Object.entries(clips).map(([k, c]) => [k, +c.duration.toFixed(2)])) };
}

async function save(name, options) {
 const result = await bake(name, options);
 await fetch('/save/' + name + '_Animated.glb', { method: 'POST', body: result.glb });
 return { bytes: result.glb.byteLength, walkSpeed: +result.walkSpeed.toFixed(3), durations: result.durations };
}

window.animatedConverter = { inspect, bake, save, THREE };
window.animatedConverterReady = true;
