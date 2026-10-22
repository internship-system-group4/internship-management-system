import * as THREE from './vendor/three.module.min.js';

// Stone pixels originate in the supplied courtyard photograph, not a stock library.
export async function loadCampusSurfaces() {
 const loader=new THREE.TextureLoader(),base=new URL('../images/university/materials/',import.meta.url);
 const results=await Promise.allSettled(['stone-albedo.png','stone-height.png','stone-roughness.png'].map(file=>loader.loadAsync(new URL(file,base).href)));
 const [albedo,height,roughness]=results.map(r=>r.status==='fulfilled'?r.value:null);
 for(const texture of [albedo,height,roughness])if(texture){texture.wrapS=texture.wrapT=THREE.RepeatWrapping;texture.anisotropy=4;}
 if(albedo)albedo.colorSpace=THREE.SRGBColorSpace;
 const pixels=new Uint8Array(128*128*4);let seed=812;
 for(let y=0;y<128;y++)for(let x=0;x<128;x++){const i=(y*128+x)*4,a=x/128*Math.PI*8,b=y/128*Math.PI*6;pixels[i]=128+Math.sin(a+b)*22+Math.sin(b*2)*9;pixels[i+1]=128+Math.cos(b-a*.5)*19;pixels[i+2]=250;pixels[i+3]=255;}
 const waterNormal=new THREE.DataTexture(pixels,128,128,THREE.RGBAFormat);waterNormal.wrapS=waterNormal.wrapT=THREE.RepeatWrapping;waterNormal.repeat.set(4,2);waterNormal.magFilter=THREE.LinearFilter;waterNormal.needsUpdate=true;
 const faces=Array.from({length:6},(_,face)=>{const c=document.createElement('canvas');c.width=c.height=128;const ctx=c.getContext('2d'),gradient=ctx.createLinearGradient(0,0,0,128);gradient.addColorStop(0,face===3?'#a99a80':'#a6c5df');gradient.addColorStop(.55,'#e1eaf0');gradient.addColorStop(1,face===2?'#d5e4ee':'#baaf9b');ctx.fillStyle=gradient;ctx.fillRect(0,0,128,128);return c;});
 const environment=new THREE.CubeTexture(faces);environment.colorSpace=THREE.SRGBColorSpace;environment.needsUpdate=true;
 const leaves=document.createElement('canvas');leaves.width=leaves.height=128;const ctx=leaves.getContext('2d');
 let leafSeed=715;const random=()=>{leafSeed=(Math.imul(leafSeed,1664525)+1013904223)>>>0;return leafSeed/4294967296;};
 // Elliptical clusters have a leafy silhouette instead of the previous square confetti patches.
 for(let i=0;i<155;i++){const angle=random()*Math.PI*2,radius=Math.sqrt(random()),x=64+Math.cos(angle)*radius*55,y=64+Math.sin(angle)*radius*48;ctx.fillStyle=['#d7dfc5','#a3b684','#bcca9f','#8da36d'][i%4];ctx.beginPath();ctx.ellipse(x,y,4+random()*4,2+random()*2,random()*Math.PI,0,Math.PI*2);ctx.fill();}
 const foliage=new THREE.CanvasTexture(leaves);foliage.colorSpace=THREE.SRGBColorSpace;foliage.anisotropy=2;
 const pavingCanvas=document.createElement('canvas');pavingCanvas.width=pavingCanvas.height=256;const pc=pavingCanvas.getContext('2d');pc.fillStyle='#b9b4a9';pc.fillRect(0,0,256,256);
 for(let row=0;row<4;row++)for(let col=0;col<4;col++){const shade=207+Math.floor(random()*14);pc.fillStyle=`rgb(${shade+5},${shade+3},${shade-2})`;pc.fillRect(col*64+1,row*64+1,62.5,62.5);}
 const paving=new THREE.CanvasTexture(pavingCanvas);paving.wrapS=paving.wrapT=THREE.RepeatWrapping;paving.colorSpace=THREE.SRGBColorSpace;paving.anisotropy=4;
 // Low-frequency contact occlusion remains inexpensive on phones with shadow maps disabled.
 const shadowCanvas=document.createElement('canvas');shadowCanvas.width=shadowCanvas.height=128;
 const shadowContext=shadowCanvas.getContext('2d'),shadowGradient=shadowContext.createRadialGradient(64,64,12,64,64,64);
 shadowGradient.addColorStop(0,'rgba(40,36,29,.46)');shadowGradient.addColorStop(.5,'rgba(40,36,29,.25)');shadowGradient.addColorStop(1,'rgba(40,36,29,0)');
 shadowContext.fillStyle=shadowGradient;shadowContext.fillRect(0,0,128,128);
 const contactShadow=new THREE.CanvasTexture(shadowCanvas);contactShadow.colorSpace=THREE.SRGBColorSpace;
 return {albedo,height,roughness,waterNormal,environment,foliage,paving,contactShadow};
}

// Give each box face UVs measured in model units, so stone courses do not stretch.
export function architecturalUV(geometry,unit=.9) {
 const {width=1,height=1,depth=1}=geometry.parameters||{},uv=geometry.attributes.uv;
 if(!uv||geometry.type!=='BoxGeometry')return geometry;
 const sizes=[[depth,height],[depth,height],[width,depth],[width,depth],[width,height],[width,height]];
 for(let face=0;face<6;face++)for(let j=0;j<4;j++){const i=face*4+j;uv.setXY(i,uv.getX(i)*sizes[face][0]/unit,uv.getY(i)*sizes[face][1]/unit);}
 uv.needsUpdate=true;return geometry;
}
