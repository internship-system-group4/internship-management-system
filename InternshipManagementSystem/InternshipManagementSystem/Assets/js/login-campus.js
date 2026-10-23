(function () {
 'use strict';
 function initialize() {
  const root=document.querySelector('[data-login-campus]');if(!root||root.dataset.initialized)return;root.dataset.initialized='true';
  const script=document.currentScript?.src||new URL('../../Assets/js/login-campus.js',location.href).href;
  const form=root.querySelector('[data-public-form]'),serverForm=root.closest('form'),status=root.querySelector('[data-campus-status]'),pause=root.querySelector('[data-campus-pause]');
  const reduce=matchMedia('(prefers-reduced-motion: reduce)'),events=new AbortController(),signal=events.signal;
  let scene=null,disposed=false,posted=false;
  // Authentication always keeps the immediate server redirect, independent of 3D availability.
  root.querySelector('[data-campus-animation]').value='0';
  const destination=root.dataset.destination;
  if(destination&&/^\/(?:[^/?#]+\/)*Pages\/(?:(?:Student|Company|Academic|Coordinator)\/Dashboard|Account\/ChangePassword)\.aspx$/.test(destination)){location.replace(destination);return;}
  delete root.dataset.state;status.textContent='';root.dataset.visualMode='photo';
  function state(){const checking=form.dataset.submitting==='true';if(checking){root.dataset.state='submitting';status.textContent=window.uimsT('LoginChecking');}else{delete root.dataset.state;status.textContent='';}scene?.setState(checking?'submitting':'idle');}
  const observer=new MutationObserver(state);observer.observe(form,{attributes:true,attributeFilter:['data-submitting']});
  // Local module and model: photo and usable form remain visible throughout loading/failure.
  import(new URL('login-campus-scene.js?v=20261023-security-1',script).href).then(m=>m.createCampusScene(root,{reducedMotion:reduce.matches})).then(value=>{
   if(disposed){value.dispose();return;}scene=value;root.dataset.sceneReady='true';root.dataset.visualMode='3d';state();
   root.campusScene=scene;
  }).catch(()=>{if(!disposed){root.dataset.visualMode='photo';pause.hidden=true;}});
  reduce.addEventListener('change',()=>scene?.setReducedMotion(reduce.matches),{signal});
  serverForm.addEventListener('submit',event=>{if(posted){event.preventDefault();return;}if(form.dataset.submitting!=='true'&&!window.validateLogin()){event.preventDefault();return;}posted=true;},{signal});
  window.addEventListener('pageshow',()=>{posted=false;state();},{signal});
  window.addEventListener('pagehide',()=>{disposed=true;scene?.dispose();scene=null;delete root.campusScene;observer.disconnect();events.abort();root.removeAttribute('data-scene-ready');pause.hidden=true;delete root.dataset.initialized;},{once:true});
 }
 initialize();window.addEventListener('pageshow',event=>{if(event.persisted)initialize();});
}());
