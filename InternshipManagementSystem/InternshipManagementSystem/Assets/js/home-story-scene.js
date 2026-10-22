import * as THREE from './vendor/three.module.min.js';
import { createCampusModel } from './home-campus-model.js?v=20261022-campus-5';

export async function mountUniversityStory(story,host,fallback,cancelled){
 const viewport=host.querySelector('[data-story-viewport]'),toggle=host.querySelector('[data-story-toggle]'),chapters=[...story.querySelectorAll('[data-chapter]')],hotspots=[...host.querySelectorAll('[data-hotspot]')];
 const model=await createCampusModel(story.dataset.logo);let renderer,environmentTarget,disposed=false,shaderFailed=false,timeline,observer,resizeObserver;
 function freeModel(){const geometries=new Set(),materials=new Set(),textures=new Set();model.root.traverse(o=>{if(o.geometry)geometries.add(o.geometry);if(o.material)for(const m of Array.isArray(o.material)?o.material:[o.material])materials.add(m);});materials.forEach(m=>{Object.values(m).forEach(t=>{if(t?.isTexture)textures.add(t);});m.dispose();});textures.forEach(t=>t.dispose());geometries.forEach(g=>g.dispose());environmentTarget?.dispose();model.surfaces.environment.dispose();model.root.clear();model.parts.clear();}
 if(cancelled()){freeModel();return;}
 const canvas=document.createElement('canvas');canvas.setAttribute('aria-hidden','true');canvas.style.visibility='hidden';
 try{renderer=new THREE.WebGLRenderer({canvas,antialias:true,powerPreference:'low-power'});}catch(_){freeModel();fallback();return {dispose(){},snapshot:()=>({state:'fallback'})};}
 renderer.debug.onShaderError=()=>{shaderFailed=true;};renderer.outputColorSpace=THREE.SRGBColorSpace;renderer.toneMapping=THREE.ACESFilmicToneMapping;renderer.toneMappingExposure=1.02;renderer.shadowMap.type=THREE.PCFSoftShadowMap;
 const scene=new THREE.Scene();scene.background=new THREE.Color('#f1f3f2');scene.environmentIntensity=.85;
 const environmentGenerator=new THREE.PMREMGenerator(renderer);try{environmentTarget=environmentGenerator.fromCubemap(model.surfaces.environment);scene.environment=environmentTarget.texture;}catch(_){freeModel();renderer.dispose();renderer.forceContextLoss();fallback();return {dispose(){},snapshot:()=>({state:'fallback'})};}finally{environmentGenerator.dispose();}
 scene.add(model.root,new THREE.HemisphereLight('#e5effb','#b0a18c',.85));
 const sun=new THREE.DirectionalLight('#fff3de',3.4);sun.position.set(-18,26,16);sun.castShadow=true;sun.shadow.mapSize.set(2048,2048);Object.assign(sun.shadow.camera,{left:-23,right:23,top:23,bottom:-23,near:1,far:80});sun.shadow.normalBias=.018;sun.shadow.bias=-.00012;sun.shadow.radius=4;scene.add(sun);
 const camera=new THREE.PerspectiveCamera(35,1,.1,150),target=new THREE.Vector3(),raycaster=new THREE.Raycaster();
 const reduced=matchMedia('(prefers-reduced-motion: reduce)'),compact=matchMedia('(max-width: 680px)');
 const gsap=window.gsap;gsap.registerPlugin(window.ScrollTrigger);
 // Five views of ONE stationary campus. All travel remains outside solid architecture.
 const poses=[{p:[28,24,39],t:[0,1,0]},{p:[7,7.5,27],t:[-6,2.8,8]},{p:[15,20,27],t:[-4,3,-5]},{p:[22,11.5,15],t:[7,3,-3]},{p:[20,12,26],t:[8,1.8,8]}];
 let progress={value:0},time=0,draws=0,raf=0,last=0,dirty=true,hasRendered=false,paused=reduced.matches,visible=true,observedReduced=reduced.matches;
 const eligible=()=>!disposed&&visible&&!document.hidden,motion=()=>!paused&&!reduced.matches;
 function schedule(){if(eligible()&&!raf)raf=requestAnimationFrame(tick);}function requestRender(){dirty=true;schedule();}
 function cameraPose(){
  let value=reduced.matches?0:progress.value*4,ix=Math.min(3,Math.floor(value)),f=value-ix;f=THREE.MathUtils.smoothstep(f,.18,.83);
  const a=poses[ix],b=poses[ix+1];camera.position.fromArray(a.p).lerp(new THREE.Vector3(...b.p),f);target.fromArray(a.t).lerp(new THREE.Vector3(...b.t),f);
  const mobileWeight=THREE.MathUtils.smoothstep(value,1.7,2.5),opening=1-THREE.MathUtils.smoothstep(value,.08,.85);
  if(compact.matches){const entranceFocus=1-Math.min(1,Math.abs(value-1));camera.position.sub(target).multiplyScalar(1.2+mobileWeight*.35-entranceFocus*.1).add(target);camera.fov=43;}else if(viewport.clientWidth<1000){camera.position.sub(target).multiplyScalar(1.08).add(target);camera.fov=38;}else{const framing=[.78,.92,.9,.88,.9];camera.position.sub(target).multiplyScalar(THREE.MathUtils.lerp(framing[ix],framing[ix+1],f)).add(target);camera.fov=35;}
  const w=viewport.clientWidth,h=viewport.clientHeight,offsetX=compact.matches?0:-w*.14*(1-opening),offsetY=compact.matches?-h*(.25+mobileWeight*.11+opening*.02):-h*.18*opening;
  camera.setViewOffset(w,h,offsetX,offsetY,w,h);camera.updateProjectionMatrix();camera.lookAt(target);camera.updateMatrixWorld();
  scene.updateMatrixWorld(true);projectHotspots();
 }
 function projectHotspots(){
  const w=viewport.clientWidth,h=viewport.clientHeight,occupied=[],stageRect=host.getBoundingClientRect();
  const local=r=>({left:r.left-stageRect.left,right:r.right-stageRect.left,top:r.top-stageRect.top,bottom:r.bottom-stageRect.top});
  const copy=chapters.flatMap(c=>{const zones=[...c.querySelectorAll('[data-copy-zone]')];return(zones.length?zones:[c.querySelector('.campus-copy')]).map(zone=>zone.getBoundingClientRect());}).filter(r=>r.bottom>0&&r.top<h).map(local);
  for(const element of [host.querySelector('.campus-chapter-nav'),document.querySelector('[data-public-navbar] .public-header-inner')]){
   const r=element?.getBoundingClientRect();if(r?.width&&r.height)occupied.push(local(r));
  }
  for(const link of hotspots){
   const point=model.landmarks[link.dataset.hotspot],p=point.clone().project(camera),x=(p.x*.5+.5)*w,y=(-p.y*.5+.5)*h;
   raycaster.setFromCamera(new THREE.Vector2(p.x,p.y),camera);const distance=camera.position.distanceTo(point);const hit=raycaster.intersectObject(model.root,true)[0];
   const width=link.offsetWidth||140,height=44,original={left:x-width/2,top:y-height};
   const overlaps=(pos,r)=>pos.left<r.right+10&&pos.left+width>r.left-10&&pos.top<r.bottom+10&&pos.top+height>r.top-10;
   const blockers=[...copy,...occupied];
   const fits=pos=>pos.left>=10&&pos.left+width<=w-10&&pos.top>=10&&pos.top+height<=h-65&&!blockers.some(r=>overlaps(pos,r));
   // The floating navbar needs a clear lane. Try nearby label positions before hiding a visible landmark.
   // Ray occlusion and the underlying landmark/camera positions are unchanged.
   const candidates=[original];
   for(const r of blockers.filter(r=>overlaps(original,r)))candidates.push(
    {left:r.right+14,top:original.top},{left:r.left-width-14,top:original.top},
    {left:original.left,top:r.top-height-14},{left:original.left,top:r.bottom+14});
   const position=candidates.find(pos=>Math.hypot(pos.left-original.left,pos.top-original.top)<=240&&fits(pos));
   const hidden=reduced.matches||p.z< -1||p.z>1||!position||(hit&&hit.distance<distance-.8);
   link.hidden=!!hidden;if(!hidden){link.style.transform=`translate(${Math.round(position.left)}px,${Math.round(position.top)}px)`;occupied.push({left:position.left,right:position.left+width,top:position.top,bottom:position.top+height});}
  }
 }
 function chapterState(){const height=innerHeight;chapters.forEach(c=>{const r=c.getBoundingClientRect(),alpha=reduced.matches?1:Math.min(THREE.MathUtils.clamp((.85-r.top/height)/.4,0,1),THREE.MathUtils.clamp((r.bottom/height-.35)/.35,0,1));c.querySelector('.campus-copy').inert=alpha<.03;c.style.opacity=String(alpha);});const active=Math.min(4,Math.round(progress.value*4));host.querySelectorAll('[data-story-link]').forEach(link=>{if(Number(link.dataset.storyLink)===active)link.setAttribute('aria-current','step');else link.removeAttribute('aria-current');});projectHotspots();}
 function updateState(){story.classList.toggle('is-live',hasRendered&&!reduced.matches&&!!timeline?.scrollTrigger);story.classList.toggle('is-rest',reduced.matches);host.dataset.sceneState=!hasRendered?'loading':paused||reduced.matches?'paused':'ready';toggle.textContent=paused||reduced.matches?'Resume campus motion':'Pause campus motion';toggle.setAttribute('aria-pressed',String(paused||reduced.matches));toggle.hidden=!hasRendered||reduced.matches;}
 function tick(now){raf=0;if(!eligible())return;if(observedReduced!==reduced.matches){onPreference();return;}if(!last)last=now-34;const dt=now-last;if(dt>=1000/30){if(motion()){time+=Math.min(dt/1000,.08);model.update(time,compact.matches?.65:1);}if(dirty||motion()){try{renderer.render(scene,camera);}catch(_){dispose();fallback();return;}if(shaderFailed){dispose();fallback();return;}canvas.style.visibility='visible';draws++;dirty=false;if(!hasRendered){hasRendered=true;updateState();}}last=now;}if(dirty||motion())schedule();}
 function sync(){if(disposed)return;cancelAnimationFrame(raf);raf=0;last=0;updateState();schedule();}
 function configureScroll(){timeline?.scrollTrigger?.kill();timeline?.kill();timeline=null;story.classList.toggle('is-static',reduced.matches);
  if(!reduced.matches)timeline=gsap.fromTo(progress,{value:0},{value:1,ease:'none',duration:1,scrollTrigger:{trigger:story,start:'top top',end:()=>'+='+Math.max(1,story.offsetHeight-host.offsetHeight),scrub:.45,invalidateOnRefresh:true,onRefresh(){cameraPose();chapterState();requestRender();}},onUpdate(){cameraPose();chapterState();requestRender();}});
  cameraPose();chapterState();requestRender();
 }
 function resize(){if(disposed)return;if(reduced.matches!==observedReduced){onPreference();return;}const w=Math.max(1,viewport.clientWidth),h=Math.max(1,viewport.clientHeight);renderer.setPixelRatio(Math.min(devicePixelRatio||1,compact.matches?1.25:1.5,1800/w,1200/h));renderer.setSize(w,h,false);renderer.shadowMap.enabled=!compact.matches;camera.aspect=w/h;cameraPose();chapterState();requestRender();}
 function onPreference(){observedReduced=reduced.matches;if(observedReduced){paused=true;model.update(0,.4);}configureScroll();sync();}
 const onToggle=()=>{paused=!paused;sync();},onVisibility=()=>{if(reduced.matches!==observedReduced)onPreference();sync();if(eligible())requestRender();},onCompact=()=>{resize();window.ScrollTrigger.refresh();},onLost=e=>{e.preventDefault();dispose();fallback();},onScroll=()=>{if(reduced.matches!==observedReduced)onPreference();chapterState();},onCollege=()=>{model.selectCollege(story.querySelector('#computing-college').open);requestRender();};
 function dispose(){if(disposed)return;disposed=true;story.classList.remove('is-live');story.classList.add('is-rest');cancelAnimationFrame(raf);observer?.disconnect();resizeObserver?.disconnect();timeline?.scrollTrigger?.kill();timeline?.kill();toggle.removeEventListener('click',onToggle);reduced.removeEventListener('change',onPreference);compact.removeEventListener('change',onCompact);document.removeEventListener('visibilitychange',onVisibility);window.removeEventListener('resize',resize);window.removeEventListener('scroll',onScroll);canvas.removeEventListener('webglcontextlost',onLost);story.querySelector('#computing-college').removeEventListener('toggle',onCollege);chapters.forEach(c=>{c.inert=false;c.querySelector('.campus-copy').inert=false;c.style.opacity='';});freeModel();sun.shadow.dispose();scene.clear();renderer.dispose();renderer.forceContextLoss();canvas.remove();toggle.hidden=true;hotspots.forEach(h=>h.hidden=true);host.dataset.sceneState='disposed';}
 viewport.append(canvas);toggle.addEventListener('click',onToggle);reduced.addEventListener('change',onPreference);compact.addEventListener('change',onCompact);document.addEventListener('visibilitychange',onVisibility);window.addEventListener('resize',resize);window.addEventListener('scroll',onScroll,{passive:true});canvas.addEventListener('webglcontextlost',onLost);story.querySelector('#computing-college').addEventListener('toggle',onCollege);
 if('IntersectionObserver'in window){observer=new IntersectionObserver(e=>{visible=e[0].isIntersecting;sync();});observer.observe(story);}if('ResizeObserver'in window){resizeObserver=new ResizeObserver(resize);resizeObserver.observe(viewport);}
 host.querySelector('[data-story-status]').textContent='GJU | Architectural miniature';resize();configureScroll();onCollege();sync();
 return {dispose,model,snapshot:()=>({state:host.dataset.sceneState,time,draws,progress:progress.value,camera:camera.position.toArray(),target:target.toArray(),visible,reduced:reduced.matches,compact:compact.matches,running:eligible()&&motion(),triangles:renderer.info.render.triangles,calls:renderer.info.render.calls,textures:renderer.info.memory.textures,geometries:renderer.info.memory.geometries,width:canvas.width,height:canvas.height,triggerActive:!!timeline?.scrollTrigger})};
}
