import * as THREE from './vendor/three.module.min.js';
import { GLTFLoader } from './vendor/addons/loaders/GLTFLoader.js';
import { createGateModel } from './home-gate-model.js';
import { architecturalUV, loadCampusSurfaces } from './home-campus-materials.js';

// Reuse the project's MIT Rocketbox adult and captured idle motion, not a primitive mannequin.
async function createGuard() {
 const gltf=await new GLTFLoader().loadAsync(new URL('../models/people/Male_Adult_17_Animated.glb',import.meta.url).href);
 const root=new THREE.Group();root.name='campus-security-guard';root.add(gltf.scene);
 gltf.scene.traverse(o=>{if(!o.isMesh)return;o.castShadow=o.receiveShadow=true;o.frustumCulled=false;
  for(const m of [].concat(o.material)){m.roughness=.88;m.envMapIntensity=.45;
   if(m.name==='m022_body')m.onBeforeCompile=shader=>{shader.fragmentShader=shader.fragmentShader.replace('#include <map_fragment>',`#include <map_fragment>
    float skinMask=smoothstep(1.08,1.23,diffuseColor.r/max(diffuseColor.g,.001))*smoothstep(1.10,1.35,diffuseColor.r/max(diffuseColor.b,.001));
    float fold=dot(diffuseColor.rgb,vec3(.2126,.7152,.0722));
    diffuseColor.rgb=mix(vec3(.012,.027,.045)*(.4+fold*2.0),diffuseColor.rgb,skinMask);
   `);};
  }
 });
 const mixer=new THREE.AnimationMixer(gltf.scene);mixer.clipAction(gltf.animations.find(c=>c.name==='look')).play();mixer.update(0);root.updateMatrixWorld(true);
 const head=gltf.scene.getObjectByName('Bip01_Head'),chest=gltf.scene.getObjectByName('Bip01_Spine2');
 const navy=new THREE.MeshStandardMaterial({color:'#203849',roughness:.92}),black=new THREE.MeshStandardMaterial({color:'#161f26',roughness:.74}),gold=new THREE.MeshStandardMaterial({color:'#b79b62',roughness:.38,metalness:.65});
 function accessory(name,geo,mat,pos,bone){const m=new THREE.Mesh(geo,mat);m.name=name;m.position.fromArray(pos);m.castShadow=true;root.add(m);if(bone)bone.attach(m);return m;}
 const hp=head.getWorldPosition(new THREE.Vector3());
 const cap=accessory('security-cap',new THREE.SphereGeometry(.124,32,16,0,Math.PI*2,0,Math.PI/2),navy,[hp.x,hp.y+.105,hp.z]);cap.scale.set(1,.65,1.13);head.attach(cap);
 const visor=accessory('cap-visor',new THREE.SphereGeometry(.12,32,12),black,[hp.x,hp.y+.096,hp.z+.095]);visor.scale.set(1,.08,.8);head.attach(visor);
 accessory('cap-badge',new THREE.BoxGeometry(.032,.034,.005),gold,[hp.x,hp.y+.13,hp.z+.127],head);
 accessory('security-badge',new THREE.BoxGeometry(.045,.059,.008),gold,[-.09,1.32,.155],chest);
 accessory('shoulder-radio',new THREE.BoxGeometry(.052,.095,.025),black,[.105,1.36,.155],chest);
 accessory('radio-antenna',new THREE.CylinderGeometry(.003,.003,.065,8),black,[.12,1.437,.155],chest);
 const headRest=head.quaternion.clone(),gaze=new THREE.Quaternion(),euler=new THREE.Euler();let clock=0,lean=0;
 return {root,update(dt,checking){clock+=dt;lean+=((checking?1:0)-lean)*(1-Math.exp(-dt*4));head.quaternion.copy(headRest).multiply(gaze.setFromEuler(euler.set(.10*lean+.009*Math.sin(clock*1.1),-.18*lean+.025*Math.sin(clock*.4),0)));root.scale.y=1+.0012*Math.sin(clock*1.5);},dispose(){mixer.stopAllAction();mixer.uncacheRoot(gltf.scene);}};
}

function textureCanvas(w,h,paint){const c=document.createElement('canvas');c.width=w;c.height=h;paint(c.getContext('2d'),c);const t=new THREE.CanvasTexture(c);t.colorSpace=THREE.SRGBColorSpace;t.anisotropy=4;return t;}
function noiseTexture(stone=false){return textureCanvas(512,512,(c)=>{let seed=1907;const rand=()=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed/4294967296;};
 if(stone){c.fillStyle='#d2c9b6';c.fillRect(0,0,512,512);for(let row=0;row<4;row++)for(let col=-1;col<3;col++){const v=202+Math.floor(rand()*22)-11;c.fillStyle=`rgb(${v+6},${v-2},${v-22})`;c.fillRect(col*256+(row%2?128:0)+1,row*128+1,254,126);}for(let i=0;i<15000;i++){c.fillStyle=rand()<.5?'rgba(90,80,60,.1)':'rgba(255,250,230,.1)';c.fillRect(rand()*512,rand()*512,1+rand()*2,1+rand()*2);}}
 else{const data=c.createImageData(512,512);for(let i=0;i<data.data.length;i+=4){const v=100+rand()*56;data.data[i]=v;data.data[i+1]=data.data[i+2]=v+2;data.data[i+3]=255;}c.putImageData(data,0,0);}
 });}
function skyTexture(){return textureCanvas(1024,512,c=>{const g=c.createLinearGradient(0,0,0,512);g.addColorStop(0,'#3d73b0');g.addColorStop(.35,'#80b0da');g.addColorStop(.5,'#e3ebee');g.addColorStop(1,'#e3ebee');c.fillStyle=g;c.fillRect(0,0,1024,512);for(let i=0;i<14;i++){const x=(i*277%1024),y=165+(i*31%75),r=40+i%4*13;const a=c.createRadialGradient(x,y,0,x,y,r);a.addColorStop(0,'rgba(255,255,255,.65)');a.addColorStop(1,'rgba(255,255,255,0)');c.fillStyle=a;c.fillRect(x-r,y-r,r*2,r*2);}});}
function bevelBox(w,h,d){const shape=new THREE.Shape();shape.moveTo(-w/2+.025,-h/2+.025);shape.lineTo(w/2-.025,-h/2+.025);shape.lineTo(w/2-.025,h/2-.025);shape.lineTo(-w/2+.025,h/2-.025);shape.closePath();const geo=new THREE.ExtrudeGeometry(shape,{depth:d-.05,bevelEnabled:true,bevelThickness:.025,bevelSize:.025,bevelSegments:2,steps:1});geo.translate(0,0,-(d-.05)/2);const p=geo.attributes.position,n=geo.attributes.normal,uv=geo.attributes.uv;for(let i=0;i<p.count;i++)uv.setXY(i,(Math.abs(n.getX(i))>.5?p.getZ(i):p.getX(i))/2.4,(Math.abs(n.getY(i))>.5?p.getZ(i):p.getY(i))/2.4);return geo;}
function disposeScene(scene){const gs=new Set(),ms=new Set(),ts=new Set();scene.traverse(o=>{if(o.geometry)gs.add(o.geometry);for(const m of o.material?[].concat(o.material):[]){ms.add(m);Object.values(m).forEach(t=>{if(t?.isTexture)ts.add(t);});}});gs.forEach(g=>g.dispose());ms.forEach(m=>m.dispose());ts.forEach(t=>t.dispose());}

export async function createCampusScene(host,options={}) {
 const container=host.querySelector('[data-campus-canvas]'),pause=host.querySelector('[data-campus-pause]'),compact=innerWidth<=640;
 const scene=new THREE.Scene();let renderer,guard,surfaces,environment,pmrem;
 try {
  renderer=new THREE.WebGLRenderer({antialias:!compact,powerPreference:'low-power'});
  renderer.setPixelRatio(Math.min(devicePixelRatio,compact?1.25:1.5));renderer.shadowMap.enabled=true;renderer.shadowMap.type=THREE.PCFSoftShadowMap;
  renderer.outputColorSpace=THREE.SRGBColorSpace;renderer.toneMapping=THREE.ACESFilmicToneMapping;renderer.toneMappingExposure=.95;
  const gate=await createGateModel(host.dataset.logo);scene.add(gate.root);gate.root.position.z=-8;
  guard=await createGuard();scene.add(guard.root);guard.root.position.set(-.35,0,6.9);guard.root.rotation.y=.24;
  surfaces=await loadCampusSurfaces();pmrem=new THREE.PMREMGenerator(renderer);environment=pmrem.fromCubemap(surfaces.environment);scene.environment=environment.texture;
  scene.background=new THREE.Color('#dfe9ef');scene.fog=new THREE.Fog('#e3ebee',40,100);
  const sky=new THREE.Mesh(new THREE.SphereGeometry(120,32,16),new THREE.MeshBasicMaterial({map:skyTexture(),side:THREE.BackSide,fog:false,depthWrite:false,toneMapped:false}));sky.name='daylight-sky';scene.add(sky);
  scene.add(new THREE.HemisphereLight('#dcecff','#b8a98c',1.7));const sun=new THREE.DirectionalLight('#fff3df',2.5);sun.position.set(-9,15,13);sun.castShadow=true;sun.shadow.mapSize.set(compact?768:1536,compact?768:1536);Object.assign(sun.shadow.camera,{left:-16,right:16,top:16,bottom:-16,near:1,far:60});sun.shadow.bias=-.0004;sun.shadow.normalBias=.015;scene.add(sun);
  function box(name,size,pos,mat,parent=scene){const m=new THREE.Mesh(new THREE.BoxGeometry(...size),mat);m.name=name;m.position.fromArray(pos);m.castShadow=m.receiveShadow=true;parent.add(m);return m;}
  const stone=gate.parts.get('limestone-portal').children[0].material,stoneMap=noiseTexture(true);stoneMap.wrapS=stoneMap.wrapT=THREE.RepeatWrapping;stone.map=stoneMap;stone.color.set('#fff');stone.needsUpdate=true;
  gate.parts.get('limestone-portal').traverse(o=>{if(o.isMesh){const {width:w,height:h,depth:d}=o.geometry.parameters;o.geometry.dispose();o.geometry=bevelBox(w,h,d);}});
  gate.parts.get('right-return').traverse(o=>{if(o.isMesh&&o.material===stone)architecturalUV(o.geometry,2.4);});
  gate.parts.get('ground').visible=false;gate.parts.get('flagpoles').scale.y=3.5/8.5;gate.parts.get('germany-flag').visible=false;
  const jordan=gate.parts.get('jordan-flag');jordan.scale.setScalar(.6);jordan.position.set(-2.29,3,-1.35);const flag2=jordan.clone();flag2.name='login-jordan-flag-right';flag2.position.x=2.46;gate.root.add(flag2);
  const metal=new THREE.MeshStandardMaterial({color:'#78858a',metalness:.6,roughness:.45}),dark=new THREE.MeshStandardMaterial({color:'#17232d',roughness:.48,metalness:.16});
  for(const x of [-3.9,-1.3,1.3,3.9])box('soffit-light',[.22,.16,.22],[x,3.52,0],dark,gate.root);
  const roadMap=noiseTexture();roadMap.wrapS=roadMap.wrapT=THREE.RepeatWrapping;const asphalt=new THREE.MeshStandardMaterial({color:'#9a9e9d',map:roadMap,roughness:.96});
  const ground=box('outer-forecourt',[40,.04,30],[0,-.04,4],asphalt);architecturalUV(ground.geometry,1.5);
  const inner=box('approach-road',[8.8,.04,70],[0,-.02,-37],asphalt);architecturalUV(inner.geometry,1.5);
  const paving=new THREE.MeshStandardMaterial({map:surfaces.paving,roughness:.92});
  box('right-sidewalk',[2.4,.14,60],[5.9,0,-37],paving);box('left-sidewalk',[2.4,.14,60],[-5.9,0,-37],paving);
  const curbMaterials=['#dddcd4','#30373a'].map(color=>new THREE.MeshStandardMaterial({color,roughness:.93}));
  for(let i=0;i<42;i++)for(const side of [-1,1])box('painted-curb',[.22,.18,.7],[side*4.58,.04,-8-i*.7],curbMaterials[i%2]);
  const wall=new THREE.MeshStandardMaterial({color:'#d2b49a',roughness:.95});box('boundary-wall',[.3,1.05,44],[7.3,.45,-30],wall);
  box('distant-sports-hall',[16,4.6,9],[-14,2.05,-24],stone);box('distant-hall-band',[16.05,.7,9.05],[-14,3.7,-24],wall);
  const poleGeo=new THREE.CylinderGeometry(.045,.065,6.4,12);for(let i=0;i<6;i++)for(const side of [-1,1]){const x=side*5.1,z=-13-i*9;const pole=new THREE.Mesh(poleGeo,metal);pole.name='street-lamp';pole.position.set(x,3.2,z);scene.add(pole);box('lamp-arm',[1.3,.05,.07],[x-side*.6,6.38,z],metal);box('lamp-head',[.45,.07,.22],[x-side*1.2,6.35,z],metal);}
  const trunkGeo=new THREE.CylinderGeometry(.09,.16,2.9,12),trunkMat=new THREE.MeshStandardMaterial({color:'#71634e',roughness:1}),leafGeo=new THREE.PlaneGeometry(1.6,1.25),leafMat=new THREE.MeshStandardMaterial({map:surfaces.foliage,alphaTest:.42,side:THREE.DoubleSide,roughness:.92,color:'#718266'});
  let leafSeed=39;const rand=()=>{leafSeed=(Math.imul(leafSeed,1664525)+1013904223)>>>0;return leafSeed/4294967296;};for(const [x,z]of[[-9,-10],[-11,-18],[10,-12],[12,-20],[-9,-32],[12,-35]]){const trunk=new THREE.Mesh(trunkGeo,trunkMat);trunk.name='olive-trunk';trunk.position.set(x,1.4,z);scene.add(trunk);for(let j=0;j<32;j++){const leaf=new THREE.Mesh(leafGeo,leafMat);leaf.name='olive-leaf-cluster';const az=rand()*Math.PI*2,r=Math.sqrt(rand())*1.6;leaf.position.set(x+Math.cos(az)*r,2.8+(rand()-.5)*1.5,z+Math.sin(az)*r);leaf.rotation.set((rand()-.5)*1.5,rand()*Math.PI,rand()*.6);scene.add(leaf);}}
  // Batch repeated foliage and curbs; this keeps the same depth with far fewer draw calls.
  function instanceParts(name,materials){for(const mat of materials){const items=[];scene.traverse(o=>{if(o.isMesh&&o.name===name&&o.material===mat)items.push(o);});if(!items.length)continue;const batch=new THREE.InstancedMesh(items[0].geometry,mat,items.length);batch.name=name+'-batch';batch.receiveShadow=true;const geometries=new Set();items.forEach((m,i)=>{m.updateMatrix();batch.setMatrixAt(i,m.matrix);m.removeFromParent();if(m.geometry!==batch.geometry)geometries.add(m.geometry);});geometries.forEach(g=>g.dispose());batch.computeBoundingSphere();scene.add(batch);}}
  instanceParts('olive-leaf-cluster',[leafMat]);instanceParts('painted-curb',curbMaterials);
  // Closed until the server navigates to the authenticated route; no cosmetic success on a timer.
  gate.parts.get('metal-gates').visible=false;const leaves=[];for(const side of [-1,1]){const leaf=new THREE.Group();leaf.name='security-gate-leaf';leaf.position.set(side*2.5,0,-7.5);scene.add(leaf);leaves.push(leaf);for(const y of [.12,1.95,2.42])box('gate-rail',[4.96,.07,.07],[0,y,0],metal,leaf);for(let i=0;i<25;i++)box('gate-bar',[.035,2.4,.035],[-2.44+i*4.88/24,1.25,0],metal,leaf);}

  const kiosk=new THREE.Group();kiosk.name='university-id-checkpoint';kiosk.position.set(.95,0,7.4);kiosk.rotation.y=.18;scene.add(kiosk);
  const brushed=new THREE.MeshStandardMaterial({color:'#52616c',roughness:.43,metalness:.78});
  box('pedestal-foot',[.64,.07,.51],[0,.035,0],brushed,kiosk);box('pedestal-column',[.35,1.03,.28],[0,.58,-.05],brushed,kiosk);
  const consoleHead=new THREE.Group();consoleHead.name='reader-console';consoleHead.position.y=1.19;consoleHead.rotation.x=-.27;kiosk.add(consoleHead);box('reader-housing',[.63,.45,.1],[0,0,0],dark,consoleHead);
  const lightMat=new THREE.MeshStandardMaterial({color:'#809cab',emissive:'#152936',roughness:.3});box('reader-status-strip',[.48,.012,.004],[0,.177,.054],lightMat,consoleHead);
  const display=document.createElement('canvas');display.width=768;display.height=512;const dc=display.getContext('2d'),displayMap=new THREE.CanvasTexture(display);displayMap.colorSpace=THREE.SRGBColorSpace;
  box('reader-screen',[.49,.29,.005],[0,.005,.055],new THREE.MeshStandardMaterial({map:displayMap,emissiveMap:displayMap,emissive:'#fff',emissiveIntensity:.45,roughness:.25}),consoleHead);
  for(const x of [-.283,.283])for(const y of [-.19,.19]){const screw=new THREE.Mesh(new THREE.CylinderGeometry(.006,.006,.004,12),brushed);screw.name='reader-fastener';screw.rotation.x=Math.PI/2;screw.position.set(x,y,.053);consoleHead.add(screw);}
  const cardMap=textureCanvas(1024,640,c=>{c.fillStyle='#f3f5f4';c.fillRect(0,0,1024,640);c.fillStyle='#264f73';c.fillRect(0,0,1024,146);c.fillStyle='#fff';c.font='600 48px sans-serif';c.fillText('German Jordanian University',40,89);c.fillStyle='#efb12b';c.fillRect(0,146,1024,12);c.fillStyle='#172e40';c.font='600 58px sans-serif';c.fillText('UNIVERSITY ID',300,272);c.font='36px sans-serif';c.fillText('Campus access',300,338);c.font='26px sans-serif';c.fillStyle='#60717c';c.fillText('SAMPLE / UIMS',300,405);c.fillStyle='#d9e1e5';c.fillRect(42,205,210,255);c.fillStyle='#8a9eac';c.beginPath();c.arc(147,285,47,0,Math.PI*2);c.fill();c.beginPath();c.ellipse(147,410,80,65,0,0,Math.PI*2);c.fill();c.fillStyle='#203849';for(let i=0;i<84;i++)if(i*17%11>4)c.fillRect(42+i*11,533,4,58);});
  // Sample card on a physical support, never a real user's ID or a floating credential.
  const pass=new THREE.Group();pass.name='university-identity-card';pass.position.set(.22,1.05,.23);pass.rotation.set(-.15,-.12,-.12);kiosk.add(pass);
  box('card-laminate',[.38,.238,.006],[0,0,0],new THREE.MeshPhysicalMaterial({color:'#f0f2f0',roughness:.3,clearcoat:.65}),pass);box('card-printed-face',[.371,.231,.001],[0,0,.0037],new THREE.MeshPhysicalMaterial({map:cardMap,roughness:.42,clearcoat:.3}),pass);box('card-support',[.43,.025,.12],[.15,.917,.2],dark,kiosk);
  const ar=document.documentElement.lang==='ar';function screen(checking){dc.fillStyle='#10232f';dc.fillRect(0,0,768,512);dc.fillStyle=checking?'#edc773':'#a8c6d8';dc.textAlign='center';dc.font='600 49px sans-serif';dc.fillText(ar?(checking?'جارٍ التحقق':'الأمن الجامعي'):(checking?'Checking identity':'Campus security'),384,165);dc.font='35px sans-serif';dc.fillStyle='#dce8ee';dc.fillText(ar?(checking?'يرجى الانتظار':'الدخول بالهوية الجامعية'):(checking?'Please wait':'University ID access'),384,260);dc.strokeStyle=checking?'#edc773':'#668a9f';dc.lineWidth=7;dc.beginPath();dc.roundRect(335,320,98,67,12);dc.stroke();displayMap.needsUpdate=true;}
  container.appendChild(renderer.domElement);
  const camera=new THREE.PerspectiveCamera(50,1,.1,260),basePosition=new THREE.Vector3(),baseTarget=new THREE.Vector3(0,1.85,-4);
  let lastDraw=0;
  let reduced=!!options.reducedMotion,paused=false,disposed=false,contextLost=false,state='idle',raf=0,last=0,time=0,draws=0,px=0,py=0,vx=0,vy=0;
  function draw(){if(!disposed&&!contextLost){renderer.render(scene,camera);draws++;}}
  function resize(){const {width,height}=container.getBoundingClientRect();if(!width||!height)return;renderer.setSize(width,height,false);camera.aspect=width/height;basePosition.set(1.2,1.85,width/height<1.05?12:10.5);camera.position.copy(basePosition);camera.lookAt(baseTarget);camera.updateProjectionMatrix();draw();}
  function frame(now){raf=0;if(disposed||contextLost||document.hidden)return;if(now-lastDraw<32){raf=requestAnimationFrame(frame);return;}lastDraw=now;const dt=last?Math.min((now-last)/1000,.05):0;last=now;
   if(!paused&&!reduced){time+=dt;gate.updateCloth(time,.3);guard.update(dt,state==='submitting');const k=1-Math.exp(-dt*4);vx+=(px-vx)*k;vy+=(py-vy)*k;camera.position.copy(basePosition);camera.position.x+=vx;camera.position.y+=vy;camera.lookAt(baseTarget);}
   draw();if(!paused&&!reduced)raf=requestAnimationFrame(frame);
  }
  function start(){if(!raf&&!disposed&&!contextLost&&!document.hidden){last=0;raf=requestAnimationFrame(frame);}}
  function setState(value){state=value==='submitting'?'submitting':'idle';lightMat.color.set(state==='submitting'?'#edc773':'#809cab');lightMat.emissive.set(state==='submitting'?'#a47c26':'#152936');screen(state==='submitting');start();}
  function setReducedMotion(value){reduced=value;pause.hidden=value;if(value){vx=vy=0;camera.position.copy(basePosition);camera.lookAt(baseTarget);}start();}
  function toggle(){paused=!paused;pause.setAttribute('aria-pressed',String(paused));pause.textContent=paused?pause.dataset.resumeLabel:pause.dataset.pauseLabel;start();}
  function visibility(){if(document.hidden){cancelAnimationFrame(raf);raf=0;last=0;}else start();}
  function lost(e){e.preventDefault();contextLost=true;host.removeAttribute('data-scene-ready');host.dataset.visualMode='photo';pause.hidden=true;cancelAnimationFrame(raf);raf=0;}
  function pointer(e){if(e.pointerType!=='mouse')return;const r=container.getBoundingClientRect();px=((e.clientX-r.left)/r.width-.5)*.22;py=-((e.clientY-r.top)/r.height-.5)*.08;}
  function leave(){px=py=0;}
  const observer=new ResizeObserver(resize);observer.observe(container);pause.addEventListener('click',toggle);document.addEventListener('visibilitychange',visibility);container.addEventListener('pointermove',pointer,{passive:true});container.addEventListener('pointerleave',leave);renderer.domElement.addEventListener('webglcontextlost',lost);
  resize();setState('idle');pause.hidden=reduced;pause.setAttribute('aria-pressed','false');pause.textContent=pause.dataset.pauseLabel;start();
  return {setState,setReducedMotion,snapshot(){return {state,paused,reduced,draws,camera:camera.position.toArray(),card:pass.getWorldPosition(new THREE.Vector3()).toArray(),leaves:leaves.map(l=>l.position.x),triangles:renderer.info.render.triangles,drawCalls:renderer.info.render.calls};},dispose(){if(disposed)return;disposed=true;cancelAnimationFrame(raf);observer.disconnect();pause.removeEventListener('click',toggle);document.removeEventListener('visibilitychange',visibility);container.removeEventListener('pointermove',pointer);container.removeEventListener('pointerleave',leave);renderer.domElement.removeEventListener('webglcontextlost',lost);guard.dispose();disposeScene(scene);Object.values(surfaces).forEach(t=>t?.dispose());environment.dispose();pmrem.dispose();renderer.dispose();renderer.domElement.remove();}};
 } catch(error){guard?.dispose();disposeScene(scene);Object.values(surfaces||{}).forEach(t=>t?.dispose());environment?.dispose();pmrem?.dispose();renderer?.dispose();renderer?.domElement.remove();throw error;}
}
