import * as THREE from '../vendor/three.module.min.js';
import { GLTFLoader } from '../vendor/addons/loaders/GLTFLoader.js';

// The student the camera follows: a rigged Microsoft Rocketbox avatar (MIT) with motion-capture
// walk and look-around clips (see Assets/models/people/README.md). Root motion was removed when the
// GLB was made, so this module decides where he walks; the walk clip is phase-locked to distance
// travelled (1.215 m per 1.2 s cycle), so feet never slide at any speed.
const STRIDE = 1.2146, CYCLE = 1.2;

// Path through the campus (metres): courtyard -> past the waterwheel -> passage -> north plaza.
// Round the south planter on its west side, then pass between the west lawn and the
// small planter. Keep clearance for the body and the spline's rounded corners.
export const STUDENT_PATH = [
 [4, 33], [0, 28], [-7, 27], [-10.3, 25.8], [-10.3, 22], [-10.3, 18], [-5, 17],
 [3, 18], [3.6, 14], [3.6, 6], [2, -1], [-6, -4], [-13, -3.3], [-18, -3.3],
 [-23, -4], [-26, -12], [-28, -24], [-29, -30], [-28, -36], [-28, -44], [-28, -60], [-27, -72]
];

export async function createStudent(url) {
 const gltf = await new GLTFLoader().loadAsync(url);
 const root = new THREE.Group(); root.name = 'student-follow';
 const model = gltf.scene; root.add(model);
 model.traverse(o => {
  if (o.isMesh) { o.castShadow = true; o.receiveShadow = true; o.frustumCulled = false; for (const m of [].concat(o.material)) { m.envMapIntensity = .55; m.roughness = .8; } }
 });
 const mixer = new THREE.AnimationMixer(model), clip = name => gltf.animations.find(a => a.name === name);
 const walk = mixer.clipAction(clip('walk')), look = mixer.clipAction(clip('look'));
 walk.play(); walk.timeScale = 0; look.play();
 const bone = name => model.getObjectByName(name);
 const chain = [[bone('Bip01_Spine2'), .22], [bone('Bip01_Neck'), .33], [bone('Bip01_Head'), .45]].filter(([b]) => b);
 const head = bone('Bip01_Head');

 // Cache only shoe vertices, then use their animated positions to keep the supporting
 // sole on the paving through both the walk and idle clips (their root heights differ).
 root.updateMatrixWorld(true);
 const vertex = new THREE.Vector3(), bounds = new THREE.Box3().setFromObject(model, true), soles = [];
 model.traverse(mesh => {
  if (!mesh.isSkinnedMesh) return;
  const indices = [];
  for (let i = 0; i < mesh.geometry.attributes.position.count; i++) {
   mesh.getVertexPosition(i, vertex).applyMatrix4(mesh.matrixWorld);
   if (vertex.y < bounds.min.y + .12) indices.push(i);
  }
  if (indices.length) soles.push({ mesh, indices });
 });

 const curve = new THREE.CatmullRomCurve3(STUDENT_PATH.map(([x, z]) => new THREE.Vector3(x, 0, z)), false, 'centripetal', .5);
 const length = curve.getLength();
 const at = new THREE.Vector3(), tangent = new THREE.Vector3();
 const state = { dist: 0, speed: 0, heading: Math.PI, walkWeight: 0, yaw: 0, pitch: 0 };

 const up = new THREE.Vector3(0, 1, 0), tmpQ = new THREE.Quaternion(), parentQ = new THREE.Quaternion(), worldQ = new THREE.Quaternion(), delta = new THREE.Quaternion();
 const headPos = new THREE.Vector3(), dir = new THREE.Vector3(), forward = new THREE.Vector3(), right = new THREE.Vector3();

 // Distance along the path -> position and facing.
 function place(dist) {
  const u = THREE.MathUtils.clamp(dist / length, 0, 1);
  curve.getPointAt(u, at); curve.getTangentAt(u, tangent);
  return { x: at.x, z: at.z, heading: Math.atan2(tangent.x, tangent.z) };
 }

 // Turn spine, neck and head toward a world point on top of the mocap pose.
 function applyGaze(target, weight, dt) {
  head.getWorldPosition(headPos);
  forward.set(Math.sin(state.heading), 0, Math.cos(state.heading));
  let yaw = 0, pitch = 0;
  if (target && weight > 0) {
   dir.subVectors(target, headPos).normalize();
   const flat = Math.hypot(dir.x, dir.z) || 1e-6;
   yaw = Math.atan2(forward.z * dir.x - forward.x * dir.z, forward.x * dir.x + forward.z * dir.z);
   pitch = Math.atan2(dir.y, flat);
   yaw = THREE.MathUtils.clamp(yaw, -1.35, 1.35) * weight; pitch = THREE.MathUtils.clamp(pitch, -.35, 1.05) * weight;
  }
  // Critically damped follow: heads lead slightly, never snap.
  const k = 1 - Math.exp(-dt * 3.2);
  state.yaw += (yaw - state.yaw) * k; state.pitch += (pitch - state.pitch) * k;
  right.set(-Math.cos(state.heading), 0, Math.sin(state.heading));
  for (const [b, share] of chain) {
   delta.setFromAxisAngle(up, state.yaw * share).multiply(tmpQ.setFromAxisAngle(right, state.pitch * share));
   b.getWorldQuaternion(worldQ); b.parent.getWorldQuaternion(parentQ);
   worldQ.premultiply(delta); b.quaternion.copy(parentQ.invert().multiply(worldQ));
   b.updateMatrixWorld(true);
  }
 }

 return {
  root, length, curve,
  get state() { return state; },
  headPosition: out => head.getWorldPosition(out),
  // targetDist comes from scroll; the student follows at a believable walking pace.
  update(dt, targetDist, gaze, surfaceHeight) {
   // A big jump (chapter link, very fast scroll) cuts like a film edit instead of a long catch-up walk.
   if (Math.abs(targetDist - state.dist) > 30) state.dist = targetDist - Math.sign(targetDist - state.dist) * 6;
   const diff = targetDist - state.dist, maxFwd = 2.8 * dt, maxBack = 7 * dt;
   const stepDist = THREE.MathUtils.clamp(diff * (1 - Math.exp(-dt * 2.4)), -maxBack, maxFwd);
   state.dist = THREE.MathUtils.clamp(state.dist + stepDist, 0, length);
   const speed = dt > 0 ? Math.abs(stepDist) / dt : 0;
   state.speed += (speed - state.speed) * (1 - Math.exp(-dt * 5));
   const p = place(state.dist);
   let dh = p.heading - state.heading; dh = Math.atan2(Math.sin(dh), Math.cos(dh));
   state.heading += dh * (1 - Math.exp(-dt * 4));
   const surfaceY = surfaceHeight(p.x, p.z);
   root.position.set(p.x, surfaceY, p.z); root.rotation.y = state.heading;
   // Walk/idle blend and phase-locked stride.
   const w = THREE.MathUtils.smoothstep(state.speed, .05, .45);
   state.walkWeight += (w - state.walkWeight) * (1 - Math.exp(-dt * 4));
   walk.setEffectiveWeight(state.walkWeight); look.setEffectiveWeight(1 - state.walkWeight);
   walk.time = ((state.dist / STRIDE) % 1 + 1) % 1 * CYCLE;
   mixer.update(dt);
   root.updateMatrixWorld(true);
   let soleY = Infinity;
   for (const { mesh, indices } of soles) for (const i of indices) {
    mesh.getVertexPosition(i, vertex).applyMatrix4(mesh.matrixWorld);
    soleY = Math.min(soleY, vertex.y);
   }
   if (Number.isFinite(soleY)) {
    root.position.y += surfaceY + .003 - soleY;
    root.updateMatrixWorld(true);
   }
   applyGaze(gaze?.target, gaze?.weight ?? 0, dt);
  },
  distanceNear(x, z) {
   let best = 0, bestD = Infinity;
   for (let i = 0; i <= 400; i++) { const d = length * i / 400, p = place(d), e = Math.hypot(p.x - x, p.z - z); if (e < bestD) { bestD = e; best = d; } }
   return best;
  },
  place
 };
}
