import * as THREE from './vendor/three.module.min.js';
import { createGateModel } from './home-gate-model.js';
import { createCourtyardModel } from './courtyard-model.js';
import { loadCampusSurfaces, architecturalUV } from './home-campus-materials.js?v=20261022-campus-5';

// Curated miniature: landmark proportions follow photographs; adjacency is artistic.
export async function createCampusModel(logoUrl) {
 const surfaces=await loadCampusSurfaces();
 const root=new THREE.Group();root.name='campusRoot';
 const group=name=>{const g=new THREE.Group();g.name=name;root.add(g);return g;};
 const entranceGroup=group('entranceGroup'),waterwheelGroup=group('waterwheelGroup'),buildingsGroup=group('buildingsGroup'),landscapeGroup=group('landscapeGroup'),opportunityMarkerGroup=group('opportunityMarkerGroup');
 const stone=new THREE.MeshStandardMaterial({color:'#f3e6d1',roughness:.9,map:surfaces.albedo,bumpMap:surfaces.height,bumpScale:.024,roughnessMap:surfaces.roughness}),edge=new THREE.MeshStandardMaterial({color:'#b4a58c',roughness:.9}),paving=new THREE.MeshStandardMaterial({color:'#f3eee5',roughness:.96,map:surfaces.paving}),glass=new THREE.MeshPhysicalMaterial({color:'#466779',roughness:.16,metalness:.38,clearcoat:.55,clearcoatRoughness:.15,envMapIntensity:1.2}),frame=new THREE.MeshStandardMaterial({color:'#c7cecd',roughness:.6,metalness:.25}),green=new THREE.MeshStandardMaterial({color:'#566b42',roughness:1}),trunk=new THREE.MeshStandardMaterial({color:'#75614c',roughness:1}),navy=new THREE.MeshStandardMaterial({color:'#264f73',roughness:.6});
 const cube=new THREE.BoxGeometry(1,1,1);
 // Neutral limestone tint balances the warm photograph; glazing is a dielectric, not metal.
 stone.color.set('#e5edf1');stone.bumpScale=.014;
 glass.color.set('#355363');glass.metalness=0;glass.roughness=.12;glass.ior=1.5;glass.clearcoat=.8;glass.envMapIntensity=1.6;
 function box(parent,name,size,pos,material){const m=new THREE.Mesh(material===stone||material===paving?architecturalUV(new THREE.BoxGeometry(...size),material===paving?1.8:.9):cube,material);m.name=name;if(material!==stone&&material!==paving)m.scale.fromArray(size);m.position.fromArray(pos);m.castShadow=m.receiveShadow=true;parent.add(m);return m;}
 box(landscapeGroup,'thin-architectural-base',[33,.55,29],[0,-.45,-1],edge);box(landscapeGroup,'campus-paving',[32.8,.15,28.8],[0,-.1,-1],paving);
 const gate=await createGateModel(logoUrl);gate.root.scale.setScalar(.65);gate.root.position.set(-6,.06,8);entranceGroup.add(gate.root);
 // Reduce the forecourt to fit the curated base; gate structure remains unchanged.
 const forecourt=gate.root.getObjectByName('forecourt');forecourt.scale.x=.86;
 const courtyard=createCourtyardModel({textureSize:256});courtyard.root.position.set(7,.08,-3);courtyard.root.scale.setScalar(.83);waterwheelGroup.add(courtyard.root);
 // Apply shared reference stone maps to the existing, independently built landmarks.
 const changedGeometries=new Set();
 for(const landmark of [gate.root,courtyard.root])landmark.traverse(o=>{
  if(!o.isMesh)return;
  if(o.material?.bumpMap&&(o.material.color.getHexString()!=='38291f')){
   if(!changedGeometries.has(o.geometry)){architecturalUV(o.geometry);changedGeometries.add(o.geometry);}
  }
 });
 const courtyardStone=courtyard.root.userData.sculptRuntime.materials.stone;
 for(const mat of [gate.root.getObjectByName('portal-lintel').material,courtyardStone]){
  for(const key of ['map','bumpMap','roughnessMap'])if(mat[key])mat[key].dispose();
  mat.map=surfaces.albedo;mat.bumpMap=surfaces.height;mat.roughnessMap=surfaces.roughness;mat.bumpScale=.014;mat.roughness=.88;mat.color.set(mat===courtyardStone?'#e9ece9':'#e0e7e9');
 }
 const courtyardMaterials=courtyard.root.userData.sculptRuntime.materials;
 courtyardMaterials.timber.color.set('#302c25');courtyardMaterials.timber.roughness=.83;courtyardMaterials.timber.bumpScale=.026;
 courtyardMaterials.water.color.set('#276c76');courtyardMaterials.water.normalMap=surfaces.waterNormal;courtyardMaterials.water.normalScale=new THREE.Vector2(.18,.18);courtyardMaterials.water.roughness=.18;courtyardMaterials.water.metalness=.36;courtyardMaterials.water.envMapIntensity=1.15;
 const ventMaterial=new THREE.MeshStandardMaterial({color:'#b5b3a5',roughness:.65,metalness:.12});
 box(courtyard.root,'reference-bearing-vent',[.61,.92,.08],[1.35,2.3,1.2],ventMaterial);
 for(let row=0;row<9;row++)box(courtyard.root,'vent-louver-'+row,[.56,.035,.09],[1.35,1.92+row*.092,1.26],frame);
 for(const pier of courtyard.parts.get('bearings').children)if(pier.name.startsWith('axle-pier')){pier.scale.x=1.5;pier.scale.z=1.2;}
 const windows=[],recesses=[],frames=[],joints=[];
 function recordWindow(x,y,z,width,rotation=0){
  const q=new THREE.Quaternion().setFromAxisAngle(new THREE.Vector3(0,1,0),rotation),pos=new THREE.Vector3(x,y,z),m=new THREE.Matrix4();
  const at=(dx,dy,dz,sx,sy,sz)=>m.clone().compose(pos.clone().add(new THREE.Vector3(dx,dy,dz).applyQuaternion(q)),q,new THREE.Vector3(sx,sy,sz));
  windows.push(at(0,0,.035,width,.36,.04));recesses.push(at(0,0,0,width+.09,.45,.035));
  for(const side of [-1,1]){frames.push(at(side*(width/2+.015),0,.05,.035,.43,.055));frames.push(at(0,side*.205,.06,width+.06,.035,.095));}
 }

 function academicBlock(name,x,z,w,h,d,connector=false){
  const g=new THREE.Group();g.name=name;g.position.set(x,0,z);buildingsGroup.add(g);
  box(g,name+'-limestone',[w,h,d],[0,h/2,0],stone);box(g,name+'-roof',[w+.16,.14,d+.16],[0,h+.04,0],edge);
  for(let row=0;row<5;row++){
   const y=1+row*(h-1.3)/5;
   for(let col=0;col<7;col++)recordWindow(x-w*.43+col*w*.142,y,z+d/2+.015,w*.092);
   for(let col=0;col<3;col++)recordWindow(x+w/2+.015,y,z-d*.31+col*d*.31,d*.22,Math.PI/2);
  }
  for(let row=1;row<h/.6;row++){
   joints.push(new THREE.Matrix4().compose(new THREE.Vector3(x,row*.6,z+d/2+.008),new THREE.Quaternion(),new THREE.Vector3(w,.012,.014)));
   joints.push(new THREE.Matrix4().compose(new THREE.Vector3(x+w/2+.008,row*.6,z),new THREE.Quaternion(),new THREE.Vector3(.014,.012,d)));
  }
  if(connector){box(g,'glazed-connector',[2.6,h-.3,.14],[-w/2+1.4,h/2,d/2+.05],glass);for(let i=0;i<6;i++)box(g,'connector-mullion',[.035,h-.3,.08],[-w/2+.15+i*.5,h/2,d/2+.14],frame);for(let j=0;j<8;j++)box(g,'connector-transom',[2.6,.04,.08],[-w/2+1.4,.4+j*(h-.5)/7,d/2+.14],frame);}
  // Restrained rooftop louver line, repeatedly visible in courtyard references.
  for(let i=0;i<8;i++)box(g,'roof-louver',[.055,.06,.9],[-w/2+i*w/8,h+.22,d/2-.1],frame);
  return g;
 }
 academicBlock('western-courtyard-wing',-6,-7,11,7.8,3.7,true);academicBlock('northern-stone-wing',7,-11,10,7,3.2);
 const contactMaterial=new THREE.MeshBasicMaterial({map:surfaces.contactShadow,transparent:true,opacity:.6,depthWrite:false,polygonOffset:true,polygonOffsetFactor:-1});
 const contactGeometry=new THREE.PlaneGeometry(1,1);
 for(const [name,x,z,w,d] of [['west-wing',-6,-7,14,7],['north-wing',7,-11,13,6],['courtyard',7,-3,11,5],['gate-left',-9.65,8,2.8,2.8],['gate-right',-2.35,8,2.8,2.8]]){
  const shadow=new THREE.Mesh(contactGeometry,contactMaterial);shadow.name=name+'-contact-occlusion';shadow.rotation.x=-Math.PI/2;shadow.scale.set(w,d,1);shadow.position.set(x,.012,z);shadow.userData.explodeWithParent=true;landscapeGroup.add(shadow);
 }
 function instance(name,material,matrices,geometry=cube){const batch=new THREE.InstancedMesh(geometry,material,matrices.length);matrices.forEach((m,i)=>batch.setMatrixAt(i,m));batch.name=name;batch.receiveShadow=true;return batch;}
 const winBatch=instance('repeated-window-bands',glass,windows);windows.forEach((_,i)=>winBatch.setColorAt(i,new THREE.Color().setHSL(.55,.1,.68+(i*17%7)*.025)));buildingsGroup.add(winBatch);
 buildingsGroup.add(instance('recessed-window-shadows',new THREE.MeshStandardMaterial({color:'#354448',roughness:.92}),recesses),instance('window-frames-and-sills',frame,frames),instance('limestone-course-joints',new THREE.MeshStandardMaterial({color:'#bcae94',roughness:1}),joints));
 // Irregular smooth lobes, varied olive tones and branched trunks replace identical faceted crowns.
 const crownMatrices=[],stemMatrices=[],branchMatrices=[],leafColors=[];let seed=1023;
 const random=()=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed/4294967296;};
 for(let i=0;i<18;i++){
  const x=(i<9?-14.4:14.3)+(random()-.5)*.35,z=-11+(i%9)*2.8+(random()-.5)*.35,h=2.4+random()*.7;
  stemMatrices.push(new THREE.Matrix4().compose(new THREE.Vector3(x,h*.3,z),new THREE.Quaternion(),new THREE.Vector3(1,h*.6,1)));
  for(let leaf=0;leaf<62;leaf++){
   const angle=random()*Math.PI*2,radius=Math.sqrt(random())*.83,dy=(random()-.5)*1.25;
   const q=new THREE.Quaternion().setFromEuler(new THREE.Euler((random()-.5)*.8,random()*Math.PI*2,(random()-.5)*.5));
   crownMatrices.push(new THREE.Matrix4().compose(new THREE.Vector3(x+Math.cos(angle)*radius,h-.15+dy,z+Math.sin(angle)*radius),q,new THREE.Vector3(.65+random()*.35,.7+random()*.4,1)));
   leafColors.push(new THREE.Color().setHSL(.24+random()*.035,.25+random()*.15,.3+random()*.2));
  }
  for(let j=0;j<3;j++){
   const a=j*Math.PI*2/3+i,start=new THREE.Vector3(x,h*.4,z),end=new THREE.Vector3(x+Math.cos(a)*.52,h*.8,z+Math.sin(a)*.52),delta=end.clone().sub(start);
   branchMatrices.push(new THREE.Matrix4().compose(start.add(end).multiplyScalar(.5),new THREE.Quaternion().setFromUnitVectors(new THREE.Vector3(0,1,0),delta.clone().normalize()),new THREE.Vector3(.55,delta.length(),.55)));
  }
 }
 const foliageMaterial=new THREE.MeshStandardMaterial({color:'#f3f4e8',map:surfaces.foliage,alphaTest:.4,side:THREE.DoubleSide,roughness:.9});foliageMaterial.forceSinglePass=true;
 const crowns=instance('natural-canopy-clusters',foliageMaterial,crownMatrices,new THREE.PlaneGeometry(1,1));leafColors.forEach((c,i)=>crowns.setColorAt(i,c));crowns.castShadow=true;
 const stems=instance('tree-trunks',trunk,stemMatrices,new THREE.CylinderGeometry(.09,.13,1,8)),branches=instance('tree-branches',trunk,branchMatrices,new THREE.CylinderGeometry(.07,.1,1,6));landscapeGroup.add(crowns,stems,branches);
 box(landscapeGroup,'central-walking-path',[2.5,.04,20],[-1,.025,-1],paving);box(landscapeGroup,'courtyard-cross-path',[23,.045,2],[1,.03,2.2],paving);
 for(const [x,z] of [[-11,1],[11,6],[-9,-2],[1,-10]]){box(landscapeGroup,'low-planter',[2.4,.45,1.3],[x,.21,z],stone);for(let j=0;j<5;j++){const shrub=new THREE.Mesh(new THREE.SphereGeometry(.43,8,5),green);shrub.name='planter-foliage';shrub.position.set(x-.8+j*.4,.6,z+(j%2?-.15:.15));shrub.scale.set(1,.8,1);landscapeGroup.add(shrub);}}
 // Symbolic School of Computing chip, not a claim about a building's actual use.
 const chip=new THREE.Group();chip.name='symbolic-computing-marker';chip.position.set(-5,8.35,-6);buildingsGroup.add(chip);box(chip,'computing-chip',[1.6,.2,1.6],[0,0,0],navy);box(chip,'chip-die',[.8,.12,.8],[0,.15,0],frame);for(let i=0;i<5;i++)for(const side of [-1,1]){box(chip,'chip-pin',[.15,.08,.4],[-.65+i*.32,0,side*.94],frame);box(chip,'chip-pin',[.4,.08,.15],[side*.94,0,-.65+i*.32],frame);}
 const selection=new THREE.Mesh(new THREE.TorusGeometry(1.55,.035,6,40),new THREE.MeshBasicMaterial({color:'#a8782e'}));selection.rotation.x=Math.PI/2;selection.position.set(-5,8.25,-6);selection.name='college-selection-highlight';buildingsGroup.add(selection);
 opportunityMarkerGroup.position.set(8,0,8);box(opportunityMarkerGroup,'opportunity-sign-post',[.12,3.6,.12],[0,1.8,0],frame);box(opportunityMarkerGroup,'opportunity-direction',[2.4,1.1,.16],[0,3.2,0],navy);
 const arrow=new THREE.Shape();arrow.moveTo(-.65,-.08);arrow.lineTo(.22,-.08);arrow.lineTo(.22,-.25);arrow.lineTo(.65,0);arrow.lineTo(.22,.25);arrow.lineTo(.22,.08);arrow.lineTo(-.65,.08);arrow.closePath();const arrowMesh=new THREE.Mesh(new THREE.ShapeGeometry(arrow),new THREE.MeshBasicMaterial({color:'#ffffff'}));arrowMesh.position.set(0,3.2,.09);opportunityMarkerGroup.add(arrowMesh);
 const landmarks={gate:new THREE.Vector3(-6,5,8),colleges:new THREE.Vector3(-5,9.4,-6),wheel:new THREE.Vector3(8,6,-3),opportunity:new THREE.Vector3(8,4.4,8)};
 const water=courtyard.parts.get('water');
 return {root,parts:new Map(root.children.map(g=>[g.name,g])),gate,courtyard,landmarks,selection,surfaces,update(time,strength=1){gate.updateCloth(time,strength*.6);courtyard.wheel.rotation.z=-time*.075;surfaces.waterNormal.offset.set(time*.012,time*.007);if(water)water.children.forEach((o,i)=>{if(o.material?.transparent)o.material.opacity=.17+Math.sin(time*.6+i)*.025;});},selectCollege(selected){selection.visible=selected;chip.scale.setScalar(selected?1.1:1);}};
}
