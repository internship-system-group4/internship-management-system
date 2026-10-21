(function () {
 'use strict';
 var toggle=document.querySelector('.public-menu-toggle'),menu=document.getElementById('publicNav');
 if(!toggle||!menu)return;
 var small=window.matchMedia('(max-width:900px)');
 function setOpen(open,focus){
  menu.classList.toggle('is-open',open&&small.matches);
  toggle.setAttribute('aria-expanded',String(open&&small.matches));
  toggle.setAttribute('aria-label',open&&small.matches?'Close main menu':'Open main menu');
  if(focus)toggle.focus();
 }
 toggle.addEventListener('click',function(){setOpen(toggle.getAttribute('aria-expanded')!=='true',false);});
 document.addEventListener('keydown',function(e){if(e.key==='Escape'&&toggle.getAttribute('aria-expanded')==='true'){e.preventDefault();setOpen(false,true);}});
 document.addEventListener('click',function(e){if(!e.target.closest('.public-navigation'))setOpen(false,false);});
 menu.addEventListener('click',function(e){if(e.target.closest('a'))setOpen(false,false);});
 small.addEventListener('change',function(){setOpen(false,false);});
 document.documentElement.classList.add('public-nav-ready');
}());
