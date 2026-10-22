/* Shared progressive enhancement. Server results remain the authority. No auth data lives here. */
(function () {
 'use strict';
 if (window.UimsUI) { window.UimsUI.refresh(); return; }
 const ns='http://www.w3.org/2000/svg',reduced=matchMedia('(prefers-reduced-motion: reduce)');
 const paths={
  plus:'M12 5v14M5 12h14',edit:'m15 5 4 4M4 20l4-1L20 7l-4-4L4 15z',save:'m5 12 4 4L19 6',
  search:'M21 21l-5-5M18 10a8 8 0 1 1-16 0 8 8 0 0 1 16 0',filter:'M4 5h16l-6 7v6l-4 2v-8z',
  download:'M12 3v12m-5-5 5 5 5-5M4 17v4h16v-4',upload:'M12 16V4m-5 5 5-5 5 5M4 17v4h16v-4',
  trash:'M3 6h18M9 6V3h6v3M6 6l1 15h10l1-15M10 10v7m4-7v7',close:'m6 6 12 12M6 18 18 6',
  back:'m11 5-7 7 7 7M4 12h16',next:'m9 5 7 7-7 7',clock:'M12 8v5l3 2M22 12a10 10 0 1 1-20 0 10 10 0 0 1 20 0',
  approved:'m8 12 3 3 5-6M22 12a10 10 0 1 1-20 0 10 10 0 0 1 20 0',
  warning:'m12 3 10 18H2zM12 9v5m0 3v.01',info:'M12 11v6m0-10v.01M22 12a10 10 0 1 1-20 0 10 10 0 0 1 20 0',
  people:'M16 21v-3a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v3M13 6a4 4 0 1 1-8 0 4 4 0 0 1 8 0m3-3a4 4 0 0 1 0 8m3 3a4 4 0 0 1 3 4v3',
  person:'M20 21v-3a6 6 0 0 0-6-6h-4a6 6 0 0 0-6 6v3M16 5a4 4 0 1 1-8 0 4 4 0 0 1 8 0',
  mail:'M3 5h18v14H3zM3 5l9 8 9-8',building:'M4 21V3h16v18M8 7h1m6 0h1M8 11h1m6 0h1M10 21v-6h4v6',
  briefcase:'M3 7h18v14H3zM8 7V3h8v4M3 12a20 20 0 0 0 18 0M10 13h4',
  phone:'M6 3 3 5c0 8 8 16 16 16l2-3-5-4-3 2a12 12 0 0 1-5-5l2-3z',
  calendar:'M3 5h18v16H3zM7 2v6m10-6v6M3 10h18',document:'M5 2h9l5 5v15H5zM14 2v6h5M8 12h8m-8 4h8',
  eye:'M2 12s4-7 10-7 10 7 10 7-4 7-10 7S2 12 2 12m13 0a3 3 0 1 1-6 0 3 3 0 0 1 6 0',
  chat:'M3 3h18v14H8l-5 4z',camera:'M3 7h4l2-3h6l2 3h4v14H3zM16 13a4 4 0 1 1-8 0 4 4 0 0 1 8 0',
  study:'m2 8 10-5 10 5-10 5zM6 11v7l6 3 6-3v-7m4-3v9',chart:'M3 3v18h18M6 15l5-5 4 3 5-8',
  calculator:'M5 2h14v20H5zM8 5h8v4H8zM8 13h1m6 0h1m-8 4h1m6 0h1'
 };
 const bi={ 'plus-lg':'plus','pencil-square':'edit',search:'search','arrow-left':'back','chevron-right':'next','check-lg':'save','check-circle-fill':'approved','circle-fill':'info',envelope:'mail','envelope-exclamation':'warning','envelope-check':'approved','envelope-open':'mail',building:'building',telephone:'phone',briefcase:'briefcase',camera:'camera',people:'people',person:'person','person-lines-fill':'person','journal-check':'approved','journal-bookmark':'document',calculator:'calculator','chat-text':'chat',eye:'eye',mortarboard:'study',calendar:'calendar','calendar-check':'calendar','calendar-event':'calendar','graph-up':'chart','file-text':'document' };
 function icon(name) {const svg=document.createElementNS(ns,'svg');svg.setAttribute('viewBox','0 0 24 24');svg.setAttribute('aria-hidden','true');svg.classList.add('ui-icon');const p=document.createElementNS(ns,'path');p.setAttribute('d',paths[name]||paths.info);svg.append(p);return svg;}
 const states={assigned:['info','document'],resubmitted:['info','document'],'awaiting company evaluation':['info','clock'],'awaiting academic evaluation':['info','clock'],'ready for review':['warning','clock'],pending:['warning','clock'],draft:['neutral','document'],submitted:['info','document'],'under review':['info','clock'],'awaiting approval':['warning','clock'],approved:['success','approved'],accepted:['success','approved'],confirmed:['success','approved'],active:['info','info'],open:['info','info'],completed:['success','approved'],rejected:['danger','close'],closed:['neutral','close'],inactive:['neutral','close'],deactivated:['neutral','close'],returned:['warning','back'],'revision requested':['warning','edit'],graded:['success','approved'],withdrawn:['neutral','back']};
 let candidate=null,pending=null,partialFocus=null,prm=null;
 const dialogs=new Map();let activeDialog=null;
 const originals=new WeakMap(),values=new Map(),modalOpeners=new WeakMap();
 function announce(text) {let node=document.getElementById('ui-operation-status');if(!node){node=document.createElement('p');node.id='ui-operation-status';node.className='visually-hidden';node.setAttribute('role','status');node.setAttribute('aria-live','polite');document.body.append(node);}node.textContent=text;}
 function start(button) {
  if(!button?.matches('[data-ui-action]')||button.disabled)return true;
  if(pending)return false;
  pending=button;originals.set(button,{text:button.tagName==='INPUT'?button.value:null,html:button.tagName==='INPUT'?null:button.innerHTML,style:button.getAttribute('style')});
  const rect=button.getBoundingClientRect();button.style.minWidth=rect.width+'px';button.style.width=rect.width+'px';button.style.minHeight=rect.height+'px';
  const label=button.dataset.loadingLabel||'Working…';
  button.setAttribute('aria-disabled','true');button.dataset.uiState='loading';button.classList.add('ui-loading');
  if(button.tagName==='INPUT')button.value=label;else button.textContent=label;
  const frame=button.closest('.ui-button-frame');if(frame){frame.setAttribute('data-ui-state','loading');frame.style.color=getComputedStyle(button).color;}
  (button.closest('[data-ui-region]')||button.closest('main')||button.parentElement).setAttribute('aria-busy','true');
  try{if(document.body.dataset.uiOwner&&button.id)sessionStorage.setItem('uims.workspace.action.'+document.body.dataset.uiOwner,JSON.stringify({path:location.pathname,id:button.id,action:button.dataset.uiAction,at:Date.now()}));}catch(_){}
  announce(label+' Please wait for server confirmation.');return true;
 }
 function reset() {
  if(pending){const original=originals.get(pending);if(original){if(original.text!==null)pending.value=original.text;else pending.innerHTML=original.html;if(original.style===null)pending.removeAttribute('style');else pending.setAttribute('style',original.style);}
   pending.removeAttribute('aria-disabled');pending.dataset.uiState='idle';pending.classList.remove('ui-loading');pending.closest('.ui-button-frame')?.removeAttribute('data-ui-state');
   (pending.closest('[data-ui-region]')||pending.closest('main')||pending.parentElement)?.removeAttribute('aria-busy');}
  pending=null;candidate=null;
 }
 function errorSummary(form) {
  const failures=[];
  (window.Page_Validators||[]).forEach(v=>{if(v.isvalid===false&&v.enabled!==false){const field=document.getElementById(v.controltovalidate);if(field){field.setAttribute('aria-invalid','true');if(v.id){const ids=new Set((field.getAttribute('aria-describedby')||'').split(' ').filter(Boolean));ids.add(v.id);field.setAttribute('aria-describedby',[...ids].join(' '));}failures.push({field,text:v.errormessage||v.textContent||'Check this field.'});}}});
  if(!failures.length)return;
  let summary=form.querySelector('[data-ui-error-summary]');if(!summary){summary=document.createElement('div');summary.dataset.uiErrorSummary='';summary.className='ui-error-summary';summary.setAttribute('role','alert');summary.tabIndex=-1;(form.querySelector('main')||form).prepend(summary);}
  summary.replaceChildren();const heading=document.createElement('strong');heading.textContent='Please check the following fields.';summary.append(heading);
  failures.forEach(item=>{const link=document.createElement('a');link.textContent=item.text;link.href='#'+item.field.id;link.addEventListener('click',e=>{e.preventDefault();item.field.focus();});summary.append(link);});summary.focus();
 }
 function progress(element) {
  const approved=Number(element.dataset.uiApproved),target=Number(element.dataset.uiTarget);
  if(!Number.isFinite(approved)||!Number.isFinite(target)||element.dataset.uiApproved===undefined)return;
  const actual=Math.max(0,approved),valid=target>0,percent=valid?Math.min(100,actual/target*100):0;
  element.setAttribute('role','progressbar');element.setAttribute('aria-label','Approved training hours');element.setAttribute('aria-valuemin','0');element.setAttribute('aria-valuemax','100');
  if(valid)element.setAttribute('aria-valuenow',String(Math.round(percent)));else element.removeAttribute('aria-valuenow');
  element.setAttribute('aria-valuetext',valid?actual+' approved hours of '+target+' required hours':actual+' approved hours. Training hours target is not set.');
  const key=element.id||element;let previous=values.get(key);const owner=document.body.dataset.uiOwner,cacheKey=owner&&element.id?'uims.workspace.progress.'+owner+'.'+location.pathname+'.'+element.id:null;if(previous===undefined&&cacheKey){try{const cached=JSON.parse(sessionStorage.getItem(cacheKey)||'null');if(cached&&Number.isFinite(cached.percent))previous=cached.percent;}catch(_){}}element.style.width=percent+'%';if(reduced.matches)element.getAnimations().forEach(animation=>animation.cancel());else if(previous!==undefined&&previous!==percent){element.getAnimations().forEach(animation=>animation.cancel());element.animate([{width:previous+'%'},{width:percent+'%'}],{duration:600,easing:'cubic-bezier(.16,1,.3,1)'});}
  values.set(key,percent);if(cacheKey){try{sessionStorage.setItem(cacheKey,JSON.stringify({percent,approved:actual,target}));}catch(_){}}
  if(!valid){let note=element.parentElement.nextElementSibling;if(!note?.matches('[data-ui-progress-note]')){note=document.createElement('small');note.dataset.uiProgressNote='';note.className='ui-progress-note';element.parentElement.after(note);}note.textContent='Training hours target is not set. Ask your coordinator.';}else{const note=element.parentElement.nextElementSibling;if(note?.matches('[data-ui-progress-note]'))note.remove();}
 }
 function refresh(scope=document) {
  scope.querySelectorAll('[data-ui-icon],i.bi').forEach(node=>{let name=node.dataset.uiIcon;if(!name){for(const cls of node.classList)if(cls.startsWith('bi-'))name=bi[cls.slice(3)];}if(!name||node.dataset.uiIconReady)return;node.dataset.uiIcon=name;node.dataset.uiIconReady='true';node.setAttribute('aria-hidden','true');node.replaceChildren(icon(name));});
  scope.querySelectorAll('.badge,.monitor-status,.application-status,.status-badge,.sd-status,.ca-status').forEach(node=>{if(node.querySelector('a,button,input'))return;const text=node.textContent.trim().toLowerCase(),state=states[text];if(!state)return;node.classList.add('ui-status');node.dataset.uiTone=state[0];if(!node.querySelector('.ui-icon'))node.prepend(icon(state[1]));});
  scope.querySelectorAll('[data-ui-progress]').forEach(progress);
  scope.querySelectorAll('[data-ui-toast="true"]').forEach(node=>{if(node.dataset.uiNotified)return;node.dataset.uiNotified='true';notify(node.textContent.trim());node.hidden=true;});
  scope.querySelectorAll('[data-ui-action]').forEach(button=>{if(button.tagName==='INPUT'&&!button.closest('.ui-button-frame')){const wrap=document.createElement('span');wrap.className='ui-button-frame';if(button.getBoundingClientRect().width>=button.parentElement.clientWidth-4)wrap.classList.add('ui-button-block');button.before(wrap);wrap.append(button);}});
  scope.querySelectorAll('.uims-main-inner label:not([for]),.modal label:not([for])').forEach(label=>{const field=label.parentElement.querySelector('input:not([type=hidden]),select,textarea');if(field?.id)label.htmlFor=field.id;});
  scope.querySelectorAll('.alert,.public-field-error,.ui-field-error').forEach(node=>{if(node.classList.contains('alert-danger'))node.setAttribute('role','alert');else if(node.classList.contains('alert-success'))node.setAttribute('role','status');});
  scope.querySelectorAll('.uims-main-inner table').forEach(table=>{table.classList.add('ui-table');table.classList.toggle('ui-table-empty',table.rows.length===1&&table.rows[0].cells.length===1);if(!table.closest('.table-responsive,.monitor-table-scroll,.ui-table-scroll')){const wrap=document.createElement('div');wrap.className='ui-table-scroll';table.before(wrap);wrap.append(table);}});
  scope.querySelectorAll('.table-responsive,.monitor-table-scroll,.ui-table-scroll').forEach(node=>{const overflow=node.scrollWidth>node.clientWidth;let hint=node.previousElementSibling;if(!hint?.classList.contains('ui-table-hint')&&overflow){hint=document.createElement('p');hint.className='ui-table-hint';hint.textContent='Scroll horizontally to see all columns and actions.';node.before(hint);}if(hint?.classList.contains('ui-table-hint'))hint.hidden=!overflow;if(overflow){node.tabIndex=0;node.setAttribute('role','region');if(!node.getAttribute('aria-label'))node.setAttribute('aria-label','Scrollable results table');}else{node.removeAttribute('tabindex');node.removeAttribute('role');}});
  scope.querySelectorAll('.completion-checks li').forEach(item=>{const complete=item.classList.contains('is-ok');item.dataset.uiStep=complete?'completed':'blocked';const marker=item.querySelector('span[aria-hidden="true"]');if(marker&&!marker.querySelector('svg'))marker.replaceChildren(icon(complete?'approved':'clock'));});
  scope.querySelectorAll('.nav-tabs').forEach(list=>{const tabs=[...list.querySelectorAll('[data-bs-toggle="tab"]')];if(!tabs.length)return;list.setAttribute('role','tablist');tabs.forEach(tab=>{const id=(tab.getAttribute('data-bs-target')||'').slice(1),panel=document.getElementById(id);tab.setAttribute('role','tab');tab.setAttribute('aria-controls',id);tab.setAttribute('aria-selected',String(tab.classList.contains('active')));tab.tabIndex=tab.classList.contains('active')?0:-1;if(panel){panel.setAttribute('role','tabpanel');if(tab.id)panel.setAttribute('aria-labelledby',tab.id);}});});
  scope.querySelectorAll('[role="tablist"]').forEach(list=>{if(list.dataset.uiKeys)return;list.dataset.uiKeys='true';list.addEventListener('keydown',event=>{if(event.defaultPrevented)return;if(!['ArrowRight','ArrowLeft','Home','End'].includes(event.key))return;const tabs=[...list.querySelectorAll('[role="tab"]')].filter(t=>!t.disabled);let index=tabs.indexOf(document.activeElement);if(index<0)return;event.preventDefault();index=event.key==='Home'?0:event.key==='End'?tabs.length-1:(index+(event.key==='ArrowRight'?1:-1)+tabs.length)%tabs.length;tabs[index].focus();tabs[index].click();});});
  scope.querySelectorAll('button.btn-close:not([aria-label])').forEach(button=>button.setAttribute('aria-label','Close'));
  wireForms();wirePartial();
  wireDialogs(scope);window.UimsWorkspace?.refresh(scope);
 }
 function wireDialogs(scope) {
  for(const [node,record] of dialogs)if(!node.isConnected){record.observer.disconnect();dialogs.delete(node);}
  scope.querySelectorAll('[data-ui-dialog]').forEach(node=>{if(dialogs.has(node))return;
   const record={open:false,opener:null,observer:null,background:[]};dialogs.set(node,record);
   const focusables=()=>[...node.querySelectorAll('button,a[href],input:not([type="hidden"]),select,textarea,[tabindex="0"]')].filter(el=>!el.disabled&&el.getClientRects().length);
   function sync(){const open=getComputedStyle(node).display!=='none'&&node.getAttribute('aria-hidden')!=='true'&&!node.hidden;
    if(open===record.open)return;record.open=open;
    if(open){activeDialog=node;record.opener=document.activeElement;node.setAttribute('role','dialog');node.setAttribute('aria-modal','true');node.tabIndex=-1;node.dataset.uiOpen='true';
     let branch=node;while(branch.parentElement&&branch.parentElement!==document.body){for(const sibling of branch.parentElement.children){if(sibling!==branch&&!sibling.inert){sibling.inert=true;record.background.push(sibling);}}branch=branch.parentElement;}
     requestAnimationFrame(()=>{(focusables()[0]||node).focus({preventScroll:true});});
    }else{node.removeAttribute('data-ui-open');node.removeAttribute('data-ui-closing');record.background.forEach(el=>el.inert=false);record.background=[];activeDialog=null;if(record.opener?.isConnected)record.opener.focus({preventScroll:true});}
   }
   const callback=node.dataset.uiClose,original=window[callback];
   if(typeof original==='function'&&!original.uiWrapped){const close=function(...args){if(!record.open||reduced.matches)return original.apply(this,args);if(node.dataset.uiClosing)return;node.dataset.uiClosing='true';setTimeout(()=>{original.apply(this,args);sync();},200);};close.uiWrapped=true;window[callback]=close;}
   node.addEventListener('keydown',event=>{if(event.key==='Escape'){event.preventDefault();event.stopImmediatePropagation();window[callback]?.();return;}if(event.key!=='Tab')return;const list=focusables();if(!list.length){event.preventDefault();node.focus();return;}const first=list[0],last=list.at(-1);if(event.shiftKey&&document.activeElement===first){event.preventDefault();last.focus();}else if(!event.shiftKey&&document.activeElement===last){event.preventDefault();first.focus();}},true);
   node.addEventListener('click',event=>{if(event.target===node)window[callback]?.();});
   record.observer=new MutationObserver(sync);record.observer.observe(node,{attributes:true,attributeFilter:['class','style','aria-hidden','hidden']});sync();
  });
 }
 document.addEventListener('focusin',event=>{if(activeDialog&&!activeDialog.contains(event.target))activeDialog.focus({preventScroll:true});});
 function wireForms() {document.querySelectorAll('form').forEach(form=>{if(form.dataset.uiBound)return;form.dataset.uiBound='true';
  const native=form.submit;form.submit=function(){const target=form.elements.__EVENTTARGET?.value,button=target?document.getElementsByName(target)[0]:candidate;if(button?.matches('[data-ui-action]')&&!start(button))return;return native.call(form);};
  form.addEventListener('submit',event=>{if(event.defaultPrevented)return;const button=event.submitter||candidate;if(!button?.matches('[data-ui-action]'))return;if(window.Page_IsValid===false&&button.dataset.uiValidation!=='none'){event.preventDefault();reset();errorSummary(form);return;}if(!start(button))event.preventDefault();});
 });}
 function wirePartial(){const manager=window.Sys?.WebForms?.PageRequestManager;if(!manager)return;const instance=manager.getInstance();if(prm===instance)return;prm=instance;
  prm.add_initializeRequest((_,args)=>{const button=args.get_postBackElement();if(button?.matches('[data-ui-action]')&&pending&&pending!==button)args.set_cancel(true);});
  prm.add_beginRequest((_,args)=>{partialFocus=document.activeElement?.id;const button=args.get_postBackElement();if(!pending)start(button);});
  prm.add_endRequest(()=>{reset();refresh();const field=partialFocus&&document.getElementById(partialFocus);if(field)field.focus({preventScroll:true});partialFocus=null;});
 }
 document.addEventListener('click',event=>{const opener=event.target.closest('[data-ui-modal-opener]');if(opener?.id){try{sessionStorage.setItem('uims-dialog-opener',JSON.stringify({path:location.pathname,id:opener.id,modal:opener.dataset.uiModalOpener}));}catch(_){}}const button=event.target.closest('[data-ui-action]');if(!button)return;if(pending){event.preventDefault();event.stopImmediatePropagation();return;}candidate=button;},true);
 document.addEventListener('click',event=>{if(!candidate)return;queueMicrotask(()=>{if(!event.defaultPrevented&&window.Page_IsValid===false&&candidate?.dataset.uiValidation!=='none'){reset();errorSummary(document.querySelector('form'));}});});
 document.addEventListener('invalid',event=>{reset();const field=event.target;if(!field.closest('.uims-portal'))return;
  field.setAttribute('aria-invalid','true');if(!field.id)return;
  const errorId=field.id+'-ui-error';let error=document.getElementById(errorId);if(!error){error=document.createElement('span');error.id=errorId;error.className='ui-field-error';error.setAttribute('aria-live','polite');field.after(error);}
  error.textContent=field.validationMessage;const ids=new Set((field.getAttribute('aria-describedby')||'').split(' ').filter(Boolean));ids.add(errorId);field.setAttribute('aria-describedby',[...ids].join(' '));
 },true);
 document.addEventListener('input',event=>{if(event.target.getAttribute('aria-invalid')==='true')event.target.removeAttribute('aria-invalid');const error=document.getElementById(event.target.id+'-ui-error');if(error)error.textContent='';});
 document.addEventListener('show.bs.modal',event=>{let opener=event.relatedTarget||document.activeElement;try{const saved=JSON.parse(sessionStorage.getItem('uims-dialog-opener')||'null');if(saved?.path===location.pathname&&saved.modal===event.target.id)opener=document.getElementById(saved.id)||opener;}catch(_){}modalOpeners.set(event.target,opener);const modal=event.target;if(!modal.getAttribute('aria-labelledby')){const title=modal.querySelector('.modal-title');if(title){if(!title.id)title.id='ui-modal-title-'+Math.random().toString(36).slice(2);modal.setAttribute('aria-labelledby',title.id);}}});
 document.addEventListener('hidden.bs.modal',event=>{const opener=modalOpeners.get(event.target);if(opener?.isConnected)opener.focus({preventScroll:true});try{sessionStorage.removeItem('uims-dialog-opener');}catch(_){} });
 let resizeTimer;window.addEventListener('resize',()=>{clearTimeout(resizeTimer);resizeTimer=setTimeout(()=>refresh(),150);});
 window.addEventListener('pageshow',()=>{reset();refresh();});
 function notify(text) {let region=document.querySelector('.ui-toast-region');if(!region){region=document.createElement('div');region.className='ui-toast-region';region.setAttribute('role','status');document.body.append(region);}region.replaceChildren();const toast=document.createElement('div');toast.className='ui-toast';const message=document.createElement('span');message.textContent=text;const close=document.createElement('button');close.type='button';close.setAttribute('aria-label','Dismiss notification');close.append(icon('close'));close.addEventListener('click',()=>toast.remove());toast.append(icon('approved'),message,close);region.append(toast);}
 window.UimsUI={refresh,reset,notify,icon,beginRegion(region){region.setAttribute('aria-busy','true');},endRegion(region){region.removeAttribute('aria-busy');refresh(region);}};
 refresh();
}());
