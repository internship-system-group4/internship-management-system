(function () {
 'use strict';
 var reduce=window.matchMedia('(prefers-reduced-motion: reduce)');
 if('IntersectionObserver' in window&&!reduce.matches){
  var observer=new IntersectionObserver(function(entries){entries.forEach(function(entry){
   if(entry.isIntersecting){entry.target.classList.add('public-revealed');observer.unobserve(entry.target);}
  });},{threshold:.12});
  document.querySelectorAll('.home-section,.public-page>.public-section').forEach(function(section){observer.observe(section);});
  reduce.addEventListener('change',function(event){if(event.matches){observer.disconnect();document.querySelectorAll('.public-revealed').forEach(function(el){el.classList.remove('public-revealed');});}});
 }
}());
