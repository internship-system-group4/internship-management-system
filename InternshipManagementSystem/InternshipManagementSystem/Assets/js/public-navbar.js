/* Native Web Forms adaptation of the resizable navbar. No per-scroll geometry reads. */
(function () {
 'use strict';
 if(window.UimsPublicNavbar){window.UimsPublicNavbar.init();return;}
 var instance=null,partialHooked=false;
 function init(){
  var header=document.querySelector('[data-public-navbar]');
  if(!header||(instance&&instance.header===header))return;
  if(instance)instance.dispose();
  var body=header.querySelector('.public-header-inner'),menu=header.querySelector('#publicNav'),toggle=header.querySelector('.public-menu-toggle'),highlight=header.querySelector('.uims-public-nav-highlight');
  if(!body||!menu||!toggle||!highlight)return;
  var small=matchMedia('(max-width:1200px)'),abort=new AbortController(),opened=false,compact=null,scrolled=null,hovered=null,highlightFrame=0,anchorFrame=0;
  var anchorPending=!!location.hash,anchorFocus=false;
  var scene=document.querySelector('[data-navbar-scene]'),sceneStart=0,sceneEnd=0;
  var lastY=window.scrollY,travel=0,direction=0,overHeader=false;
  function measureScene(){
   if(!scene)return;
   var rect=scene.getBoundingClientRect();
   sceneStart=rect.top+window.scrollY;
   // Switch to the normal surface before the following section reaches the links.
   sceneEnd=sceneStart+rect.height-112;
  }
  function revealHeader(){if(scene)header.dataset.heroHidden='false';}
  function on(target,name,handler,options){target.addEventListener(name,handler,Object.assign({},options,{signal:abort.signal}));}
  function setOpen(value,restore){
   opened=!!value&&small.matches;
   header.dataset.menuOpen=String(opened);
   if(opened)revealHeader();
   if(!opened&&restore)toggle.focus();
   menu.classList.toggle('is-open',opened);
   toggle.setAttribute('aria-expanded',String(opened));toggle.setAttribute('aria-label',opened?window.uimsT('CloseMainMenu'):window.uimsT('OpenMainMenu'));
   menu.inert=small.matches&&!opened;
   if(small.matches&&!opened)menu.setAttribute('aria-hidden','true');else menu.removeAttribute('aria-hidden');
   // Explicit SVG paths work in browsers without support for CSS path interpolation.
   toggle.querySelector('path').setAttribute('d',opened?'M6 6 18 18M18 6 6 18':'M4 6h16M4 12h16M4 18h16');
  }
  function moveHighlight(){
   cancelAnimationFrame(highlightFrame);highlightFrame=requestAnimationFrame(function(){
    var focus=menu.contains(document.activeElement)?document.activeElement.closest('a'):null;
    var link=focus&&!focus.classList.contains('public-login')?focus:hovered;
    if(small.matches||!link){highlight.classList.remove('is-visible');return;}
    var rect=link.getBoundingClientRect(),parent=menu.getBoundingClientRect();
    // Physical translateX is intentional: measured coordinates also work in RTL.
    highlight.style.setProperty('--highlight-x',(rect.left-parent.left)+'px');highlight.style.setProperty('--highlight-width',rect.width+'px');highlight.style.left='0';highlight.style.right='auto';
    highlight.classList.add('is-visible');
   });
  }
  function updateCompact(){
   var y=Math.max(0,window.scrollY),hero=!!scene&&y>=sceneStart-8&&y<sceneEnd;
   var delta=y-lastY,nextDirection=Math.sign(delta);
   if(nextDirection&&nextDirection!==direction){travel=0;direction=nextDirection;}
   travel+=Math.abs(delta);lastY=y;
   if(scene){
    header.dataset.heroActive=String(hero);
    if(!hero||y<120||opened||overHeader||header.contains(document.activeElement))revealHeader();
    else if(direction<0&&travel>=12)revealHeader();
    else if(direction>0&&travel>=44)header.dataset.heroHidden='true';
   }
   var surface=y>8,next=!hero&&(compact===null?y>100:compact?y>88:y>112);
   if(surface!==scrolled){scrolled=surface;header.dataset.scrolled=String(scrolled);}
   if(next===compact)return;
   compact=next;header.dataset.compact=String(compact);
  }
  function scrollToAnchor(hash,focus){
   var target;try{target=document.getElementById(decodeURIComponent(hash.slice(1)));}catch(_){return false;}
   if(!target)return false;
   var y=target.getBoundingClientRect().top+window.scrollY-112;
   var story=target.closest('[data-home-story]');
   var chapter=target.closest('[data-chapter]');
   var trigger=story&&window.ScrollTrigger&&window.ScrollTrigger.getAll().find(function(item){return item.trigger===story;});
   if(chapter&&trigger&&!story.classList.contains('is-static')){
    var chapters=Array.from(story.querySelectorAll('[data-chapter]')),index=chapters.indexOf(chapter);
    y=trigger.start+(trigger.end-trigger.start)*index/Math.max(1,chapters.length-1);
   }
   window.scrollTo({top:Math.max(0,y),behavior:'instant'});updateCompact();
   if(focus){target.setAttribute('tabindex','-1');target.focus({preventScroll:true});}
   return true;
  }
  function reconcileAnchor(){
   if(!anchorPending||!location.hash)return;
   cancelAnimationFrame(anchorFrame);anchorFrame=requestAnimationFrame(function(){scrollToAnchor(location.hash,anchorFocus);anchorFocus=false;});
  }
  on(toggle,'click',function(){setOpen(!opened,false);});
  on(header,'focusin',revealHeader);
  on(header,'pointerenter',function(){overHeader=true;revealHeader();});
  on(header,'pointerleave',function(){overHeader=false;});
  on(document,'keydown',function(event){
   if(event.key==='Escape'&&opened){event.preventDefault();setOpen(false,true);}
   if(!['Shift','Control','Alt','Meta'].includes(event.key))anchorPending=false;
  });
  on(document,'click',function(event){if(!header.contains(event.target))setOpen(false,false);});
  on(menu,'click',function(event){
   var link=event.target.closest('a[href]');if(!link)return;
   if(event.button!==0||event.metaKey||event.ctrlKey||event.shiftKey||event.altKey)return;
   setOpen(false,small.matches);
   var url=new URL(link.href,location.href);
   if(url.origin===location.origin&&url.pathname===location.pathname&&url.search===location.search&&url.hash){
    event.preventDefault();if(location.hash!==url.hash)history.pushState(null,'',url.hash);
    anchorPending=true;anchorFocus=event.detail===0;reconcileAnchor();
   }
  });
  on(menu,'pointerover',function(event){var link=event.target.closest('a:not(.public-login)');if(link){hovered=link;moveHighlight();}});
  on(menu,'pointerleave',function(){hovered=null;moveHighlight();});
  on(menu,'focusin',moveHighlight);on(menu,'focusout',function(){queueMicrotask(moveHighlight);});
  on(body,'transitionend',function(event){if(event.propertyName==='width')moveHighlight();});
  on(window,'scroll',updateCompact,{passive:true});
  on(window,'pointerdown',function(){anchorPending=false;},{passive:true});
  on(window,'wheel',function(){anchorPending=false;},{passive:true});on(window,'touchstart',function(){anchorPending=false;},{passive:true});
  on(window,'resize',function(){measureScene();updateCompact();moveHighlight();reconcileAnchor();},{passive:true});
  on(small,'change',function(){var focused=menu.contains(document.activeElement);setOpen(false,small.matches&&focused);if(!small.matches&&document.activeElement===toggle)menu.querySelector('a').focus();hovered=null;moveHighlight();});
  on(window,'popstate',function(){anchorPending=!!location.hash;reconcileAnchor();updateCompact();});
  on(window,'hashchange',function(){anchorPending=!!location.hash;reconcileAnchor();});
  on(window,'pageshow',function(event){measureScene();updateCompact();if(!event.persisted)reconcileAnchor();});
  on(window,'load',function(){measureScene();updateCompact();reconcileAnchor();hookPartial();});
  var observer;
  if('ResizeObserver'in window){observer=new ResizeObserver(function(){measureScene();updateCompact();reconcileAnchor();});var content=document.getElementById('public-content');if(content)observer.observe(content);if(scene)observer.observe(scene);}
  document.documentElement.classList.add('uims-public-nav-ready');measureScene();setOpen(false,false);updateCompact();reconcileAnchor();
  instance={header:header,scrollToAnchor:scrollToAnchor,dispose:function(){abort.abort();observer?.disconnect();cancelAnimationFrame(highlightFrame);cancelAnimationFrame(anchorFrame);}};
 }
 function hookPartial(){if(!partialHooked&&window.Sys&&window.Sys.Application){window.Sys.Application.add_load(init);partialHooked=true;}}
 window.UimsPublicNavbar={init:init,scrollToAnchor:function(hash,focus){return instance?instance.scrollToAnchor(hash,focus):false;}};
 init();hookPartial();
}());
