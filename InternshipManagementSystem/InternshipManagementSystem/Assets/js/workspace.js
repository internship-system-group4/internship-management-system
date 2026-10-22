/* Workspace interactions. Existing server handlers and Bootstrap retain ownership of writes and dialogs. */
(function () {
 'use strict';
 if(window.UimsWorkspace){window.UimsWorkspace.refresh();return;}
 const reduced=matchMedia('(prefers-reduced-motion: reduce)'),ease='cubic-bezier(.16,1,.3,1)';
 const owner=document.body.dataset.uiOwner||'',route=location.pathname;
 const storage={get(key){try{return JSON.parse(sessionStorage.getItem(key)||'null');}catch(_){return null;}},set(key,value){try{sessionStorage.setItem(key,JSON.stringify(value));}catch(_){}},remove(key){try{sessionStorage.removeItem(key);}catch(_){}}};
 function lineTo(line,transform,animate){const from=getComputedStyle(line).transform;line.getAnimations().forEach(a=>a.cancel());line.style.transform=transform;if(animate&&!reduced.matches&&from!=='none')line.animate([{transform:from},{transform}],{duration:360,easing:ease});}
 function journey(node){
  if(node.dataset.wsBound)return;node.dataset.wsBound='true';
  const track=node.querySelector('.ws-journey-track'),marker=node.querySelector('.ws-journey-marker'),buttons=[...node.querySelectorAll('[data-journey-template]')];
  const connector=document.createElement('div');connector.className='ws-journey-connector';connector.setAttribute('aria-hidden','true');track.prepend(connector);
  let selected=buttons.find(b=>b.dataset.stageState==='current')||buttons[0];
  function mark(button,animate){
   buttons.forEach(b=>b.classList.toggle('is-selected',b===button));
   const rect=button.getBoundingClientRect(),rail=track.getBoundingClientRect(),first=buttons[0].getBoundingClientRect();
   const x=rect.left-rail.left+track.scrollLeft,w=rect.width;
   lineTo(marker,'translateX('+x+'px) scaleX('+w+')',animate);
   const start=first.left-rail.left+track.scrollLeft+27,end=x+27;
   connector.style.left=start+'px';lineTo(connector,'scaleX('+Math.max(0,end-start)+')',animate);
  }
  mark(selected,false);
  if(track.scrollWidth>track.clientWidth)track.scrollLeft=Math.max(0,selected.offsetLeft-(track.clientWidth-selected.offsetWidth)/2);
  buttons.forEach(button=>button.addEventListener('click',()=>{
   selected=button;mark(button,true);
   const template=document.getElementById(button.dataset.journeyTemplate),dialog=document.getElementById(button.dataset.journeyDialog);
   if(!template||!dialog||!window.bootstrap)return;
   const body=dialog.querySelector('[data-journey-body]');body.replaceChildren(template.content.cloneNode(true));
   dialog.querySelector('.modal-title').textContent=button.dataset.journeyTitle;
   let actions=dialog.querySelector('[data-journey-actions]');if(!actions){actions=document.createElement('div');actions.dataset.journeyActions='';dialog.querySelector('.modal-footer').prepend(actions);}
   actions.replaceChildren();const links=body.querySelector('.ws-dialog-actions');if(links)actions.append(links);
   buttons.forEach(b=>b.setAttribute('aria-expanded',String(b===button)));
   window.UimsUI?.refresh(dialog);
   bootstrap.Modal.getOrCreateInstance(dialog).show(button);
  }));
  const dialog=document.getElementById(buttons[0]?.dataset.journeyDialog);
  dialog?.addEventListener('hidden.bs.modal',()=>buttons.forEach(b=>b.setAttribute('aria-expanded','false')));
  // Native layout changes (pin, viewport, font load) keep the selected marker anchored.
  const observer=new ResizeObserver(()=>mark(selected,false));observer.observe(track);
 }
 function reserveActions(scope){
  scope.querySelectorAll('[data-ui-action]').forEach(button=>{
   if(button.dataset.wsSized)return;button.dataset.wsSized='true';
   const style=getComputedStyle(button),canvas=document.createElement('canvas'),context=canvas.getContext('2d');
   if(!context)return;context.font=style.font;
   const label=button.dataset.loadingLabel||'Working…';
   const needed=Math.ceil(context.measureText(label).width+parseFloat(style.paddingLeft||0)+parseFloat(style.paddingRight||0)+26);
   const rect=button.getBoundingClientRect(),available=button.parentElement.clientWidth;
   if(rect.width<needed&&needed<=available)button.style.minWidth=needed+'px';
  });
 }
 function confirmed(scope){
  const notices=[...scope.querySelectorAll('.alert-success,.application-success,.completion-success,[data-ui-confirmed="true"]')].filter(n=>n.textContent.trim()&&n.getClientRects().length);
  notices.forEach(notice=>{if(notice.dataset.wsConfirmed)return;notice.dataset.wsConfirmed='true';notice.classList.add('ui-confirmed');notice.setAttribute('role','status');if(!notice.querySelector('.ui-icon'))notice.prepend(UimsUI.icon('approved'));});
  const key='uims.workspace.action.'+owner,pending=storage.get(key);
  if(!pending||pending.path!==route||Date.now()-pending.at>60000)return;
  storage.remove(key);
  if(!notices.length)return;
  const button=document.getElementById(pending.id),labels={save:'Saved',create:'Created',submit:'Submitted',accept:'Accepted',confirm:'Confirmed',update:'Updated',upload:'Uploaded',delete:'Deleted',send:'Sent',add:'Updated'};
  if(!button||!labels[pending.action]||button.dataset.uiAction!==pending.action)return;
  const input=button.tagName==='INPUT',original=input?button.value:button.innerHTML;
  if(input)button.value=labels[pending.action];else{button.replaceChildren(UimsUI.icon('approved'),document.createTextNode(' '+labels[pending.action]));}
  button.dataset.uiState='success';button.classList.add('ui-confirmed');
  setTimeout(()=>{if(button.dataset.uiState!=='success')return;if(input)button.value=original;else button.innerHTML=original;button.dataset.uiState='idle';button.classList.remove('ui-confirmed');},1500);
 }
 function changedRows(scope){
  if(!owner)return;
  scope.querySelectorAll('[data-workspace-row],[data-application-id]').forEach(row=>{
   const id=row.dataset.workspaceRow||row.dataset.applicationId,status=row.dataset.workspaceStatus||row.querySelector('.badge,.application-status,.monitor-status')?.textContent.trim();
   if(!id||!status)return;
   const key='uims.workspace.row.'+owner+'.'+route+'.'+id,previous=storage.get(key);
   if(previous&&previous!==status&&!row.dataset.wsHighlighted){row.dataset.wsHighlighted='true';row.classList.add('ws-row-changed');setTimeout(()=>row.classList.remove('ws-row-changed'),1400);}
   storage.set(key,status);
  });
 }
 function refresh(scope=document){
  const meanings={'Dashboard.aspx':'chart','Opportunities.aspx':'briefcase','Applications.aspx':'people','MyApplications.aspx':'document','Trainees.aspx':'people','Tasks.aspx':'document','MyTasks.aspx':'document','TaskReview.aspx':'approved','FinalEvaluation.aspx':'study','MyMeetings.aspx':'calendar','StudentProgress.aspx':'people','Progress.aspx':'chart','ManageStudents.aspx':'people','Companies.aspx':'building','AcademicSupervisors.aspx':'study','Groups.aspx':'people','Placements.aspx':'briefcase','CompletionReview.aspx':'approved','ContactMessages.aspx':'mail'};
  scope.querySelectorAll('.uims-side-link').forEach(link=>{if(link.dataset.wsIcon)return;const name=meanings[link.getAttribute('href').split('/').pop()];if(name){link.querySelector('svg')?.replaceWith(UimsUI.icon(name));link.dataset.wsIcon='true';}});
  scope.querySelectorAll('[data-workspace-journey]').forEach(journey);
  scope.querySelectorAll('.modal-dialog').forEach(dialog=>dialog.classList.add('modal-dialog-centered'));
  reserveActions(scope);confirmed(scope);changedRows(scope);
 }
 window.UimsWorkspace={refresh};refresh();
 document.addEventListener('DOMContentLoaded',()=>refresh(),{once:true});
 window.addEventListener('pageshow',()=>refresh());
}());
