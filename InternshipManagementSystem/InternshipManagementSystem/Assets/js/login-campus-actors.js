import * as THREE from './vendor/three.module.min.js';
import { GLTFLoader } from './vendor/addons/loaders/GLTFLoader.js';

// Existing Microsoft Rocketbox avatar/mocap, MIT. See Assets/models/people/LICENSE.md.
// Independent skeletons and materials; geometry and texture pixels are shared.
function cloneRig(source) {
 const result = source.clone(true), nodes = new Map();
 function pair(a,b) { nodes.set(a,b); a.children.forEach((child,i)=>pair(child,b.children[i])); }
 pair(source,result);
 source.traverse(node=>{
  if (!node.isSkinnedMesh) return;
  const copy=nodes.get(node); copy.skeleton=node.skeleton.clone();
  copy.skeleton.bones=node.skeleton.bones.map(b=>nodes.get(b));
  copy.bind(copy.skeleton,node.bindMatrix.clone());
 });
 return result;
}

// Solve in world space, then convert rotations back to the animated local bone frame.
// This avoids assumptions about the FBX skeleton's local axes and preserves arm lengths.
// Temporaries are shared by both rigs (updates run one after another), so the per-frame IK allocates nothing.
const _a=new THREE.Vector3(),_b=new THREE.Vector3(),_c=new THREE.Vector3(),_dir=new THREE.Vector3(),_bend=new THREE.Vector3(),_joint=new THREE.Vector3(),_from=new THREE.Vector3(),_to=new THREE.Vector3();
const _before=new THREE.Quaternion(),_world=new THREE.Quaternion(),_turn=new THREE.Quaternion(),_parent=new THREE.Quaternion();
function rotateBone(bone,from,to,weight) {
 _before.copy(bone.quaternion);bone.getWorldQuaternion(_world);
 _turn.setFromUnitVectors(from.normalize(),to.normalize());
 bone.parent.getWorldQuaternion(_parent).invert();
 bone.quaternion.copy(_before).slerp(_parent.multiply(_turn.multiply(_world)),weight);
 bone.updateWorldMatrix(false,true);
}
function poseArm(upper,lower,hand,target,pole,weight) {
 if (!upper||!lower||!hand||weight<.001) return;
 upper.updateWorldMatrix(true,true);
 upper.getWorldPosition(_a);lower.getWorldPosition(_b);hand.getWorldPosition(_c);
 const l1=_a.distanceTo(_b),l2=_b.distanceTo(_c);_dir.copy(target).sub(_a);
 const distance=THREE.MathUtils.clamp(_dir.length(),Math.abs(l1-l2)+.005,l1+l2-.008);
 _dir.normalize();
 _bend.copy(pole).sub(_a);_bend.addScaledVector(_dir,-_bend.dot(_dir)).normalize();
 const along=(l1*l1-l2*l2+distance*distance)/(2*distance);
 _joint.copy(_a).addScaledVector(_dir,along).addScaledVector(_bend,Math.sqrt(Math.max(0,l1*l1-along*along)));
 rotateBone(upper,_from.copy(_b).sub(_a),_to.copy(_joint).sub(_a),weight);
 lower.getWorldPosition(_b);hand.getWorldPosition(_c);
 rotateBone(lower,_from.copy(_c).sub(_b),_to.copy(_a).addScaledVector(_dir,distance).sub(_b),weight);
}
const _up=new THREE.Vector3(0,1,0),_right=new THREE.Vector3(),_xAxis=new THREE.Vector3(1,0,0),_zAxis=new THREE.Vector3(0,0,1),_pole=new THREE.Vector3();
const _qa=new THREE.Quaternion(),_qb=new THREE.Quaternion(),_qWorld=new THREE.Quaternion(),_qParent=new THREE.Quaternion();

function uniformMaterial(material) {
 const m=material.clone();
 m.roughness=.87;m.metalness=0;
 // Select blue/neutral fabric from the existing body map, retaining colored hands.
 // No face/skin texture is globally tinted blue.
 m.onBeforeCompile=shader=>{
  shader.fragmentShader=shader.fragmentShader.replace('#include <map_fragment>',`#include <map_fragment>
   float clothBlue = smoothstep(0.025, 0.15, diffuseColor.b - max(diffuseColor.r, diffuseColor.g));
   float clothNeutral = (1.0 - smoothstep(0.06, 0.19, abs(diffuseColor.r-diffuseColor.g)+abs(diffuseColor.g-diffuseColor.b))) * smoothstep(0.012, 0.08, dot(diffuseColor.rgb, vec3(0.2126,0.7152,0.0722)));
   float fabric = max(clothBlue,clothNeutral);
   float folds = 0.65 + dot(diffuseColor.rgb,vec3(0.2126,0.7152,0.0722))*1.5;
   diffuseColor.rgb = mix(diffuseColor.rgb,vec3(0.021,0.038,0.064)*folds,fabric);
  `);
 };
 m.customProgramCacheKey=()=> 'uims-security-fabric-v1';
 return m;
}

function accessory(root,geometry,material,position) {
 const mesh=new THREE.Mesh(geometry,material);mesh.position.fromArray(position);
 mesh.castShadow=true;mesh.receiveShadow=true;root.add(mesh);return mesh;
}

function addGuardDetails(model) {
 // Accessories follow the rig's head/chest rather than remaining at world coordinates.
 const head=model.getObjectByName('Bip01_Head'),chest=model.getObjectByName('Bip01_Spine2');
 const navy=new THREE.MeshStandardMaterial({color:'#15283c',roughness:.86});
 const black=new THREE.MeshStandardMaterial({color:'#172027',roughness:.65});
 const brass=new THREE.MeshStandardMaterial({color:'#bd9b50',metalness:.65,roughness:.42});
 const root=new THREE.Group();root.name='security-accessories';model.add(root);
 const cap=new THREE.Group();cap.name='security-cap';root.add(cap);
 accessory(cap,new THREE.CylinderGeometry(.093,.1,.065,32),navy,[0,0,0]);
 const visor=accessory(cap,new THREE.SphereGeometry(.11,24,12),navy,[0,-.026,.065]);visor.scale.set(1,.08,.8);
 accessory(cap,new THREE.BoxGeometry(.026,.023,.004),brass,[0,.002,.096]);
 const equipment=new THREE.Group();equipment.name='security-chest';root.add(equipment);
 accessory(equipment,new THREE.BoxGeometry(.035,.05,.009),brass,[-.085,.025,.108]);
 accessory(equipment,new THREE.BoxGeometry(.036,.065,.022),black,[.083,.02,.105]);
 accessory(equipment,new THREE.CylinderGeometry(.003,.003,.047,6),black,[.087,.074,.105]);
 // A legible bilingual uniform patch identifies campus security without impersonating a police unit.
 const label=document.createElement('canvas');label.width=512;label.height=192;
 const ink=label.getContext('2d');ink.fillStyle='#112338';ink.fillRect(0,0,512,192);
 ink.strokeStyle='#c5a45b';ink.lineWidth=8;ink.strokeRect(4,4,504,184);
 ink.fillStyle='#f3f4ec';ink.textAlign='center';ink.font='bold 50px Arial';ink.fillText('الأمن الجامعي',256,78);
 ink.font='bold 43px Arial';ink.fillText('CAMPUS SECURITY',256,147);
 const map=new THREE.CanvasTexture(label);map.colorSpace=THREE.SRGBColorSpace;
 const patch=new THREE.MeshStandardMaterial({map,roughness:.85});
 accessory(equipment,new THREE.BoxGeometry(.21,.079,.008),patch,[0,.105,.125]).name='campus-security-uniform-patch';
 // Shoulder boards with a brass button, and a duty belt with buckle at the waist.
 for(const side of [-1,1]){
  accessory(equipment,new THREE.BoxGeometry(.075,.012,.13),navy,[side*.165,.19,-.005]).name='shoulder-board';
  accessory(equipment,new THREE.SphereGeometry(.008,8,6),brass,[side*.165,.198,.05]);
 }
 const belt=accessory(equipment,new THREE.TorusGeometry(.155,.022,6,28),black,[0,-.36,-.012]);belt.name='duty-belt';belt.rotation.x=Math.PI/2;belt.scale.set(1.08,.78,1);
 accessory(equipment,new THREE.BoxGeometry(.05,.038,.012),brass,[0,-.36,.118]).name='belt-buckle';
 const up=new THREE.Vector3(0,1,0),forward=new THREE.Vector3(0,0,1),lean=new THREE.Vector3(),capEuler=new THREE.Euler();
 return (heading,yaw,pitch)=>{
  if(head){head.getWorldPosition(cap.position);cap.position.addScaledVector(up,.205);cap.quaternion.setFromEuler(capEuler.set(-pitch,yaw,0));}
  if(chest){chest.getWorldPosition(equipment.position);equipment.quaternion.identity();equipment.position.addScaledVector(lean.copy(forward).applyAxisAngle(up,heading),.008);}
  // root belongs to model; position the accessories in model-local coordinates.
  root.updateWorldMatrix(true,false);
  if(head)root.worldToLocal(cap.position);
  if(chest)root.worldToLocal(equipment.position);
 };
}

function addStudentDetails(model) {
 // A plain daypack worn on both shoulders; it follows the chest like the guard's equipment.
 const chest=model.getObjectByName('Bip01_Spine2');
 const pack=new THREE.MeshStandardMaterial({color:'#2f3d36',roughness:.82}),strap=new THREE.MeshStandardMaterial({color:'#1f2824',roughness:.8});
 const root=new THREE.Group();root.name='student-daypack';model.add(root);
 const bag=new THREE.Group();root.add(bag);
 // Soft rounded shell pressed against the back (a flattened capsule), with a front pocket in the same fabric.
 const shell=accessory(bag,new THREE.CapsuleGeometry(.105,.17,6,16),pack,[0,-.05,-.145]);shell.name='daypack-body';shell.scale.set(1.3,1,.55);
 const pocket=accessory(bag,new THREE.CapsuleGeometry(.07,.05,4,12),pack,[0,-.13,-.205]);pocket.name='daypack-pocket';pocket.scale.set(1.45,1,.45);
 accessory(bag,new THREE.BoxGeometry(.06,.012,.05),strap,[0,.15,-.155]).name='daypack-handle';
 for(const side of [-1,1]){
  accessory(bag,new THREE.BoxGeometry(.04,.012,.2),strap,[side*.085,.19,-.04]).name='daypack-strap-over';
  accessory(bag,new THREE.BoxGeometry(.04,.28,.012),strap,[side*.085,.03,.115]).name='daypack-strap-front';
 }
 return ()=>{
  if(!chest)return;
  chest.getWorldPosition(bag.position);bag.quaternion.identity();
  root.updateWorldMatrix(true,false);root.worldToLocal(bag.position);
 };
}

function makeActor(gltf,guard) {
 const root=new THREE.Group();root.name=guard?'campus-security-guard':'university-student';
 root.userData.role=guard?'campus-security':'student';
 const model=cloneRig(gltf.scene);root.add(model);
 model.traverse(o=>{
  if(!o.isMesh)return;
  o.castShadow=true;o.receiveShadow=true;o.frustumCulled=false;
  const materials=[].concat(o.material).map(m=>{
   const copy=guard&&/body/i.test(m.name)?uniformMaterial(m):m.clone();
   copy.roughness=guard ? .86 : .79;copy.envMapIntensity=.6;
   if(copy.normalMap)copy.normalScale.set(.6,.6);
   return copy;
  });o.material=Array.isArray(o.material)?materials:materials[0];
 });
 const mixer=new THREE.AnimationMixer(model),find=name=>gltf.animations.find(a=>a.name===name);
 const idle=mixer.clipAction(find('look')),walk=mixer.clipAction(find('walk'));
 idle.play();idle.time=guard?5.2:1.4;idle.timeScale=guard ? .4 : .55;
 walk.play();walk.timeScale=0;walk.setEffectiveWeight(0);
 const bone=name=>model.getObjectByName('Bip01_'+name);
 const head=bone('Head'),neck=bone('Neck'),chest=bone('Spine2');
 const neutralHead=head?.quaternion.clone(),neutralNeck=neck?.quaternion.clone();
 const arm=[bone('R_UpperArm'),bone('R_Forearm'),bone('R_Hand')];
 const details=guard?addGuardDetails(model):addStudentDetails(model);
 const spine=bone('Spine');
 let blend=0,travel=0,gazeYaw=0,gazePitch=0,phase=0;
 const forward=new THREE.Vector3(),direction=new THREE.Vector3(),headAt=new THREE.Vector3();
 function update(dt,{time,heading,walking=0,step=0,target,reach,reachWeight=0,still=false}) {
  const k=still?1:1-Math.exp(-dt*6);
  blend+=(walking-blend)*k;travel+=Math.max(0,step);
  walk.setEffectiveWeight(blend);idle.setEffectiveWeight(1-blend);
  walk.time=(travel/1.2146*1.2)%walk.getClip().duration;
  mixer.update(still?0:dt);root.updateWorldMatrix(true,true);
  if(head&&target){
   head.getWorldPosition(headAt);direction.subVectors(target,headAt);
   forward.set(Math.sin(heading),0,Math.cos(heading));
   const yaw=THREE.MathUtils.clamp(Math.atan2(forward.z*direction.x-forward.x*direction.z,forward.x*direction.x+forward.z*direction.z),-.65,.65);
   const pitch=THREE.MathUtils.clamp(Math.atan2(direction.y,Math.hypot(direction.x,direction.z)),-.32,.25);
   const follow=still?1:1-Math.exp(-dt*3.8);gazeYaw+=(yaw-gazeYaw)*follow;gazePitch+=(pitch-gazePitch)*follow;
   _right.set(-Math.cos(heading),0,Math.sin(heading));
   for(let i=0;i<2;i++){
    const b=i?head:neck,share=i?.65:.35,neutral=i?neutralHead:neutralNeck;if(!b)continue;
    b.quaternion.copy(neutral);b.updateWorldMatrix(false,true);
    _qa.setFromAxisAngle(_up,gazeYaw*share).multiply(_qb.setFromAxisAngle(_right,gazePitch*share));
    b.getWorldQuaternion(_qWorld);b.parent.getWorldQuaternion(_qParent).invert();
    b.quaternion.copy(_qParent.multiply(_qWorld.premultiply(_qa)));b.updateWorldMatrix(false,true);
   }
  }
  // Restrained life on top of the mocap idle: slow breathing in the chest and an unhurried weight shift through the spine
  // (the pelvis and feet are left to the clip, so the shoes stay planted). Both fade out while walking.
  if(!still){
   const settle=1-blend,breath=Math.sin(time*1.3+(guard?1.7:0)),shift=Math.sin(time*.29+(guard?.9:2.4));
   if(chest)chest.quaternion.multiply(_qa.setFromAxisAngle(_xAxis,breath*.011*settle));
   if(spine)spine.quaternion.multiply(_qa.setFromAxisAngle(_zAxis,shift*.02*settle));
  }
  if(reach)poseArm(arm[0],arm[1],arm[2],reach,_pole.set(root.position.x+(guard ? .45 : -.45),.95,root.position.z+.3),reachWeight);
  root.updateWorldMatrix(true,true);details?.(heading,gazeYaw,gazePitch);phase=time;
 }
 return {root,model,update,hand:arm[2],head,
  dispose(){mixer.stopAllAction();mixer.uncacheRoot(model);model.traverse(o=>{if(o.isSkinnedMesh)o.skeleton.dispose();});},
  // Pose initialization does not advance the ambient timeline.
  get phase(){return phase;}
 };
}

export async function createCampusActors() {
 const url=new URL('../models/people/Male_Adult_17_Animated.web.glb',import.meta.url);
 // Generous timeout: on a slow connection the form is already usable over the photograph, so a late model is still worth showing.
 const controller=new AbortController(),timeout=setTimeout(()=>controller.abort(),45000);
 let gltf;
 try{
  const response=await fetch(url,{signal:controller.signal});if(!response.ok)throw Error('Avatar unavailable');
  gltf=await new GLTFLoader().parseAsync(await response.arrayBuffer(),new URL('.',url).href);
 }finally{clearTimeout(timeout);}
 const guard=makeActor(gltf,true),student=makeActor(gltf,false);
 return {guard,student,dispose(){guard.dispose();student.dispose();}};
}
