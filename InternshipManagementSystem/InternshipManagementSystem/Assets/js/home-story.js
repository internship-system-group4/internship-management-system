// Progressive Home enhancement. Content and the university photograph render first.
(() => {
 'use strict';
 const story=document.querySelector('[data-home-story]');if(!story||story.dataset.runtime)return;story.dataset.runtime='loading';
 const host=story.querySelector('[data-story-figure]'),toggle=host.querySelector('[data-story-toggle]'),loaderUrl=document.currentScript.src;
 let instance,started=false,disposed=false,observer,idle;
 const library=(file,name)=>window[name]?Promise.resolve():new Promise((resolve,reject)=>{const s=document.createElement('script');s.src=new URL(file,loaderUrl).href;s.async=true;s.onload=()=>window[name]?resolve():reject(new Error(name+' unavailable'));s.onerror=reject;document.head.append(s);});
 function fallback(){host.dataset.sceneState='fallback';toggle.hidden=true;story.classList.remove('is-live');story.classList.add('is-static','is-rest');story.querySelectorAll('[data-chapter]').forEach(c=>{c.inert=false;c.querySelector('.campus-copy').inert=false;c.style.opacity='';});host.querySelectorAll('[data-hotspot]').forEach(a=>a.hidden=true);host.querySelector('[data-story-status]').textContent='German Jordanian University | Campus photograph';}
 async function start(){if(started||disposed)return;started=true;try{const [module]=await Promise.all([import('./home-story-scene.js?v=20261023-i18n'),library('vendor/gsap.min.js','gsap').then(()=>library('vendor/ScrollTrigger.min.js','ScrollTrigger'))]);if(disposed)return;instance=await module.mountUniversityStory(story,host,fallback,()=>disposed);if(disposed)instance?.dispose();else host.universityStory=instance;}catch(_){if(!disposed)fallback();}}
 function schedule(){if('requestIdleCallback'in window)idle=requestIdleCallback(start,{timeout:1200});else idle=setTimeout(start,80);}
 if('IntersectionObserver'in window){observer=new IntersectionObserver(entries=>{if(entries.some(e=>e.isIntersecting)){observer.disconnect();schedule();}},{rootMargin:'100px'});observer.observe(host);}else schedule();
 window.addEventListener('pagehide',e=>{if(e.persisted)return;disposed=true;observer?.disconnect();if('cancelIdleCallback'in window)cancelIdleCallback(idle);else clearTimeout(idle);instance?.dispose();});
})();
