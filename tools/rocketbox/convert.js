// Development-only converter: Rocketbox FBX avatar + seated animation -> one static, seated GLB.
import * as THREE from 'three';
import { FBXLoader } from './vendor/loaders/FBXLoader.js';
import { TGALoader } from './vendor/loaders/TGALoader.js';
import { mergeVertices } from '/repo/InternshipManagementSystem/InternshipManagementSystem/Assets/js/vendor/addons/utils/BufferGeometryUtils.js';

const RAW = '/raw/Assets/';
const manager = new THREE.LoadingManager();
manager.addHandler(/\.tga$/i, new TGALoader(manager));

async function loadAvatar(name) {
 const loader = new FBXLoader(manager);
 loader.setResourcePath(`${RAW}Avatars/Adults/${name}/Textures/`);
 return loader.loadAsync(`${RAW}Avatars/Adults/${name}/Export/${name}.fbx`);
}

async function inspect(name) {
 const root = await loadAvatar(name);
 root.updateMatrixWorld(true);
 const meshes = [], bones = [];
 root.traverse(o => {
  if (o.isBone) bones.push(o.name);
  if (o.isMesh) {
   const materials = [].concat(o.material).map(m => ({ name:m.name, type:m.type, map:m.map?.name || m.map?.image?.src?.split('/').pop() || null, alphaMap:!!m.alphaMap, transparent:m.transparent }));
   meshes.push({ name:o.name, skinned:!!o.isSkinnedMesh, vertices:o.geometry.attributes.position.count, triangles:(o.geometry.index ? o.geometry.index.count : o.geometry.attributes.position.count)/3, groups:o.geometry.groups.length, visible:o.visible, materials });
  }
 });
 const box = new THREE.Box3().setFromObject(root);
 return { name, meshes, bones:bones.length, firstBones:bones.slice(0, 12), size:box.getSize(new THREE.Vector3()).toArray().map(v => +v.toFixed(2)), min:box.min.toArray().map(v => +v.toFixed(2)), rootScale:root.scale.toArray() };
}

const animations = new Map();
async function seatedClip(file) {
 if (!animations.has(file)) animations.set(file, new FBXLoader(manager).loadAsync(`${RAW}Animations/all_animations_max_motextr_static/${file}`).then(fbx => fbx.animations[0]));
 return animations.get(file);
}

// Downscale a loaded texture into a canvas; optionally use another texture's luminance as alpha.
function imageCanvas(texture, size, alphaTexture) {
 const draw = (tex) => {
  const image = tex.image, canvas = document.createElement('canvas');
  canvas.width = canvas.height = size;
  const c = canvas.getContext('2d');
  if (image.data) {
   const full = document.createElement('canvas'); full.width = image.width; full.height = image.height;
   const data = new ImageData(new Uint8ClampedArray(image.data.buffer, image.data.byteOffset, image.width*image.height*4), image.width, image.height);
   full.getContext('2d').putImageData(data, 0, 0);
   // DataTextures are stored bottom-up; flip so the canvas matches glTF's top-down convention.
   if (tex.flipY) { c.translate(0, size); c.scale(1, -1); }
   c.drawImage(full, 0, 0, size, size);
  } else c.drawImage(image, 0, 0, size, size);
  return canvas;
 };
 const color = draw(texture);
 if (alphaTexture) {
  const alpha = draw(alphaTexture).getContext('2d').getImageData(0, 0, size, size).data;
  const c = color.getContext('2d'), pixels = c.getImageData(0, 0, size, size);
  for (let i = 0; i < pixels.data.length; i += 4) pixels.data[i+3] = alpha[i];
  c.putImageData(pixels, 0, 0);
 }
 return color;
}

function bakeSkin(mesh) {
 const source = mesh.geometry, count = source.attributes.position.count;
 const position = new Float32Array(count*3), normal = new Float32Array(count*3);
 const v = new THREE.Vector3(), n = new THREE.Vector3(), skin = new THREE.Matrix4(), part = new THREE.Matrix4(), normalMatrix = new THREE.Matrix3();
 const skinIndex = source.attributes.skinIndex, skinWeight = source.attributes.skinWeight, bones = mesh.skeleton.boneMatrices;
 mesh.skeleton.update();
 for (let i = 0; i < count; i++) {
  v.fromBufferAttribute(source.attributes.position, i); mesh.applyBoneTransform(i, v); v.applyMatrix4(mesh.matrixWorld);
  position.set([v.x, v.y, v.z], i*3);
  // Blend the bone matrices the same way for the normal.
  skin.set(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0);
  for (let k = 0; k < 4; k++) {
   const weight = skinWeight.getComponent(i, k); if (!weight) continue;
   part.fromArray(bones, skinIndex.getComponent(i, k)*16);
   for (let e = 0; e < 16; e++) skin.elements[e] += part.elements[e]*weight;
  }
  skin.premultiply(mesh.bindMatrixInverse).multiply(mesh.bindMatrix).premultiply(mesh.matrixWorld);
  n.fromBufferAttribute(source.attributes.normal, i).applyMatrix3(normalMatrix.getNormalMatrix(skin)).normalize();
  normal.set([n.x, n.y, n.z], i*3);
 }
 const geometry = new THREE.BufferGeometry();
 geometry.setAttribute('position', new THREE.BufferAttribute(position, 3));
 geometry.setAttribute('normal', new THREE.BufferAttribute(normal, 3));
 geometry.setAttribute('uv', source.attributes.uv.clone());
 if (source.index) geometry.setIndex(source.index.clone());
 for (const group of source.groups) geometry.addGroup(group.start, group.count, group.materialIndex);
 return geometry;
}

// Pose the avatar on a frame of Rocketbox's own seated-at-table motion, then freeze it.
async function pose(name, { time = 1, female = name.startsWith('Female') } = {}) {
 const root = await loadAvatar(name), clip = await seatedClip(female ? 'f_sit_table_idle_neutral_01.max.fbx' : 'm_sit_table_idle_neutral_01.max.fbx');
 const mixer = new THREE.AnimationMixer(root); mixer.clipAction(clip).play(); mixer.setTime(time);
 root.updateMatrixWorld(true);
 let mesh = null; root.traverse(o => { if (o.isSkinnedMesh) mesh = o; });
 const bone = n => root.getObjectByName(n).getWorldPosition(new THREE.Vector3());
 return { root, mesh, clip, bone };
}

async function measure(name, time) {
 const { mesh, clip, bone } = await pose(name, { time });
 const geometry = bakeSkin(mesh); geometry.computeBoundingBox();
 const p = v => v.toArray().map(x => +x.toFixed(1));
 return { clip:clip.name, duration:+clip.duration.toFixed(2), tracks:clip.tracks.length, min:p(geometry.boundingBox.min), max:p(geometry.boundingBox.max),
  pelvis:p(bone('Bip01_Pelvis')), head:p(bone('Bip01_Head')), handL:p(bone('Bip01_L_Hand')), handR:p(bone('Bip01_R_Hand')), toeL:p(bone('Bip01_L_Toe0')), toeR:p(bone('Bip01_R_Toe0')) };
}

// Frames chosen from sampling the clips: upright, forearms resting on the desk.
const FRAME = { female:1.5, male:12 };

// Static seated GLB: metres, facing +z, feet on y = 0, pelvis over the origin; 512 px textures.
async function bake(name, size = 512) {
 const female = name.startsWith('Female');
 const { mesh } = await pose(name, { time:female ? FRAME.female : FRAME.male, female });
 // TGA textures arrive after the FBX resolves; wait until every map has pixels.
 // A pending DataTexture reports a 1x1 placeholder without data, so wait for real pixels.
 const ready = texture => !texture || !!texture.image?.data || (texture.image instanceof HTMLImageElement && texture.image.complete && texture.image.naturalWidth > 0);
 for (let waited = 0; ![].concat(mesh.material).every(m => ready(m.map) && ready(m.alphaMap)); waited += 100) {
  if (waited > 60000) throw new Error('Textures did not load for ' + name);
  await new Promise(resolve => setTimeout(resolve, 100));
 }
 // The FBX mesh is unindexed; welding shared vertices keeps the GLB small (groups stay valid).
 const baked = bakeSkin(mesh); baked.scale(.01, .01, .01);
 const geometry = mergeVertices(baked, 1e-5);
 if (!geometry.groups.length) for (const group of baked.groups) geometry.addGroup(group.start, group.count, group.materialIndex);
 const materials = [].concat(mesh.material).map(source => {
  const cutout = source.transparent || !!source.alphaMap;
  const separateAlpha = source.alphaMap && source.alphaMap.image !== source.map?.image ? source.alphaMap : null;
  const canvas = imageCanvas(source.map, size, separateAlpha);
  const map = new THREE.CanvasTexture(canvas); map.colorSpace = THREE.SRGBColorSpace; map.flipY = false;
  map.userData.mimeType = cutout ? 'image/png' : 'image/jpeg';
  return new THREE.MeshStandardMaterial({ name:source.name, map, roughness:.82, metalness:0, alphaTest:cutout ? .5 : 0, side:cutout ? THREE.DoubleSide : THREE.FrontSide });
 });
 const figure = new THREE.Mesh(geometry, materials); figure.name = name;
 const scene = new THREE.Scene(); scene.add(figure);
 const { GLTFExporter } = await import('./vendor/exporters/GLTFExporter.js');
 const glb = await new GLTFExporter().parseAsync(scene, { binary:true });
 geometry.computeBoundingBox();
 return { glb, triangles:(geometry.index ? geometry.index.count : geometry.attributes.position.count)/3, box:geometry.boundingBox };
}

// Trigger a browser download so the automation can save the file into Assets/models/people/.
async function download(name) {
 const { glb, triangles, box } = await bake(name);
 const link = document.createElement('a'); link.href = URL.createObjectURL(new Blob([glb], { type:'model/gltf-binary' })); link.download = name + '.glb'; link.click();
 return { name, bytes:glb.byteLength, triangles, min:box.min.toArray().map(v => +v.toFixed(3)), max:box.max.toArray().map(v => +v.toFixed(3)) };
}

// Preview a saved GLB on a neutral turntable (front and three-quarter views).
async function preview(url) {
 const { GLTFLoader } = await import('/repo/InternshipManagementSystem/InternshipManagementSystem/Assets/js/vendor/addons/loaders/GLTFLoader.js');
 const gltf = await new GLTFLoader().loadAsync(url);
 const renderer = new THREE.WebGLRenderer({ antialias:true }); renderer.setSize(900, 520); renderer.outputColorSpace = THREE.SRGBColorSpace;
 document.body.append(renderer.domElement);
 const scene = new THREE.Scene(); scene.background = new THREE.Color('#cfd3d6');
 scene.add(new THREE.HemisphereLight('#ffffff', '#776655', 2.2)); const sun = new THREE.DirectionalLight('#ffffff', 2); sun.position.set(2,4,3); scene.add(sun);
 for (const [x, rot] of [[-.6, 0], [.6, -.8]]) { const copy = gltf.scene.clone(); copy.position.x = x; copy.rotation.y = rot; scene.add(copy); }
 const camera = new THREE.PerspectiveCamera(30, 900/520, .1, 20); camera.position.set(0, 1.1, 3.2); camera.lookAt(0, .7, 0);
 renderer.render(scene, camera);
 let tris = 0; gltf.scene.traverse(o => { if (o.isMesh) tris += o.geometry.index.count/3; });
 return { tris, vertices:gltf.scene.children[0].geometry?.attributes.position.count ?? null };
}

window.converter = { preview, inspect, loadAvatar, measure, pose, bakeSkin, imageCanvas, bake, download, THREE };
window.converterReady = true;
