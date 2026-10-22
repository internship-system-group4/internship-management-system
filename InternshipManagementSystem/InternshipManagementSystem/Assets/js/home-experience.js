// One-time entrances for real page content; everything is visible without this script.
(() => {
 'use strict';
 const page=document.querySelector('.home-page');if(!page||page.dataset.detailRuntime)return;page.dataset.detailRuntime='ready';
 const reduced=matchMedia('(prefers-reduced-motion: reduce)');let observer;
 // Explicit native scrolling also reaches chapters whose inner copy is currently inert.
 // Camera motion continues to come solely from the existing ScrollTrigger timeline.
 function onAnchor(event){
  if(event.defaultPrevented||event.button!==0||event.metaKey||event.ctrlKey||event.shiftKey||event.altKey)return;
  const link=event.target.closest('a[href^="#"]');if(!link||!page.contains(link)||!link.hash)return;
  let target;try{target=document.getElementById(decodeURIComponent(link.hash.slice(1)));}catch(_){return;}
  if(!target||!page.contains(target))return;
  event.preventDefault();if(location.hash!==link.hash)history.pushState(null,'',link.hash);
  target.scrollIntoView({block:'start',behavior:'instant'});
  if(event.detail===0){target.setAttribute('tabindex','-1');requestAnimationFrame(()=>target.focus({preventScroll:true}));}
 }
 function onHistory(){
  if(window.UimsPublicNavbar)return; // Shared navbar owns header-aware history/anchor restoration.
  if(!location.hash)return;
  let target;try{target=document.getElementById(decodeURIComponent(location.hash.slice(1)));}catch(_){return;}
  if(target&&page.contains(target))requestAnimationFrame(()=>target.scrollIntoView({block:'start',behavior:'instant'}));
 }
 function connect(){
  observer?.disconnect();
  if(reduced.matches||!('IntersectionObserver'in window))return;
  observer=new IntersectionObserver(entries=>{for(const entry of entries)if(entry.isIntersecting){entry.target.classList.add('home-arrived');observer.unobserve(entry.target);}},{threshold:.12});
  page.querySelectorAll('.home-section h2,.home-section-heading>p,.home-gallery figure,.home-video-intro>p,.home-video-visual,.home-cta h2,.home-cta p,.home-cta .public-button').forEach((node,index)=>{
   node.style.setProperty('--arrival-delay',(index%3)*70+'ms');if(!node.classList.contains('home-arrived'))observer.observe(node);
  });
 }
 connect();reduced.addEventListener('change',connect);page.addEventListener('click',onAnchor);window.addEventListener('popstate',onHistory);window.addEventListener('hashchange',onHistory);
 window.addEventListener('pagehide',event=>{if(event.persisted)return;observer?.disconnect();reduced.removeEventListener('change',connect);page.removeEventListener('click',onAnchor);window.removeEventListener('popstate',onHistory);window.removeEventListener('hashchange',onHistory);},{once:true});
})();
