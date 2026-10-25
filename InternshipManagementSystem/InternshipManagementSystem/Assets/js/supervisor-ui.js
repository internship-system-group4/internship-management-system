/* Presentation adapter for Company and Academic masters only.
   Existing handlers, localization, validation and server postbacks retain ownership. */
(function () {
 'use strict';
 if(!document.body.matches('.company-portal,.academic-portal'))return;
 if(window.UimsSupervisorUI){window.UimsSupervisorUI.refresh();return;}
 const root=document.querySelector('.uims-main-inner');if(!root)return;
 const excluded=node=>!!node.closest('.uims-paper,[data-su-exclude]');
 const buttons='.btn,.mo-btn,.op-btn,.meeting-btn,.btn-preview,.review-preview-toggle,.tasks-page-button,.review-primary-button,.review-secondary-button,.submission-view-button,.tasks-review-button,.review-work-link,.cv-btn-theme';
 const badges='.ui-status,.badge,.meeting-status,.vo-badge,.application-status,.status-badge,.status-pill-fixed,.mo-badge,.mo-status,.op-status,.review-pending-badge,.review-complete-badge,.review-revision-badge,.tasks-status,.tasks-status-badge,.tasks-submission-status';
 const panels='.card,.uims-card,.card-custom,.sw-panel,.mo-card,.op-card,.vo-card,.submission-card,.review-card,.tasks-table-card,.create-task-card';
 const metrics='.metric-card,.sw-metric,.tasks-stat-card,.mo-stat,.meeting-stat';
 const iconMap={
  'person-badge':'person','person-badge-fill':'person','person-circle':'person','person-fill':'person','person-vcard':'person',
  'card-list':'document','file-earmark-text':'document','file-earmark-pdf':'document','file-earmark-check':'approved','file-earmark-arrow-down':'download',
  'check-circle':'approved','check-circle-fill':'approved','check2-circle':'approved','x-circle':'close','x-circle-fill':'close',
  'arrow-left':'back','arrow-right':'next','arrow-down':'download','arrow-down-circle':'download','download':'download',
  'eye-slash':'eye','eye-slash-fill':'eye','eye-fill':'eye','send-check':'save','send':'save','save':'save',
  'pencil':'edit','pencil-fill':'edit','pencil-square':'edit','trash3':'trash','trash':'trash',
  'clock':'clock','clock-history':'clock','hourglass-split':'clock','calendar-event':'calendar','calendar-check':'calendar',
  'geo-alt':'building','geo-alt-fill':'building','building-fill':'building','award':'study','award-fill':'study',
  'list-check':'approved','list-task':'document','journal-check':'approved','journal-text':'document','journal-bookmark':'document',
  'graph-up-arrow':'chart','graph-up':'chart','bar-chart':'chart','info-circle':'info','exclamation-circle':'warning',
  'briefcase-fill':'briefcase','box-arrow-up-right':'next','link-45deg':'next','telephone-fill':'phone','envelope-fill':'mail',
  'people-fill':'people','buildings-fill':'building','book':'document','file-earmark-person':'person','person-workspace':'person',
  'file-earmark-pdf-fill':'document','file-earmark-text-fill':'document','send-fill':'save','printer':'document'
 };
 function tone(node){
  if(node.dataset.uiTone)return node.dataset.uiTone;
  const classes=node.className;
  if(node.matches('.meeting-status')){
   const state=node.dataset.state||'';
   if(/approved|completed/i.test(state))return 'success';
   if(/pending|waiting/i.test(state))return 'warning';
   if(/declined|rejected|cancelled/i.test(state))return 'danger';
   return 'neutral';
  }
  if(node.matches('.vo-badge:not(.closed):not(.draft)'))return 'info';
  if(node.matches('.tasks-status-reviewed'))return 'success';
  if(node.matches('.mo-badge:not(.draft):not(.inactive)'))return 'info';
  if(/(?:status-|badge-|bg-|text-)(?:accepted|approved|confirmed|completed|success|green)|review-complete/.test(classes))return 'success';
  if(/(?:status-|badge-|bg-|text-)(?:rejected|danger|red)/.test(classes))return 'danger';
  if(/(?:status-|badge-|bg-|text-)(?:pending|warning|yellow|revision)|review-revision/.test(classes))return 'warning';
  if(/(?:status-|badge-|bg-|text-)(?:active|open|progress|info|blue|primary)|review-pending/.test(classes))return 'info';
  return 'neutral';
 }
 let fieldSequence=0;
 function refresh(){
  const title=[...root.querySelectorAll('h1,h2,h3')].find(node=>!excluded(node)&&!node.closest('.modal,.create-task-overlay,.task-modal-overlay,.task-success-overlay'));
  title?.classList.add('su-page-title');
  root.querySelectorAll(buttons).forEach(node=>{
   if(excluded(node)||node.matches('.btn-close'))return;
   node.classList.add('su-button');
   const danger=node.matches('.btn-danger,.mo-btn-danger,.meeting-btn-danger,.review-reject-button,[data-ui-tone=danger]');
   const primary=node.matches('.btn-primary,.btn-brand,.btn-save,.btn-send,.meeting-btn-primary,.tasks-create-button,.review-primary-button,.review-details-primary,.mo-btn:not(.mo-btn-light):not(.mo-btn-danger),.op-btn:not(.op-btn-light)');
   node.dataset.suVariant=danger?'danger':primary?'primary':node.matches('.btn-warning,.btn-style-warning')?'accent':'secondary';
  });
  root.querySelectorAll('input:not([type=hidden]):not([type=submit]):not([type=button]):not([type=checkbox]):not([type=radio]):not([type=range]):not([type=file]),select,textarea').forEach(field=>{
   if(excluded(field))return;field.classList.add('su-field');
   const adjacentLabel=field.parentElement.querySelector(':scope > label:not([for])');
   if(!field.labels?.length&&adjacentLabel&&!adjacentLabel.contains(field)){
    if(!field.id){do{field.id='su-field-'+(++fieldSequence);}while(document.querySelectorAll('#'+field.id).length>1);}
    adjacentLabel.htmlFor=field.id;
   }
   if(!field.labels?.length&&!field.hasAttribute('aria-label')&&!field.hasAttribute('aria-labelledby')){
    const label=field.placeholder||field.title||(field.tagName==='SELECT'?field.options[0]?.text:null);
    if(label)field.setAttribute('aria-label',label);
   }
  });
  root.querySelectorAll('input[type=checkbox],input[type=radio]').forEach(field=>{
   if(excluded(field))return;field.classList.add('su-choice');
   for(const label of field.labels||[])label.classList.add('su-choice-label');
  });
  root.querySelectorAll(badges).forEach(node=>{
   if(excluded(node)||node.querySelector('a,button,input')||!node.textContent.trim())return;
   node.classList.add('su-badge');node.dataset.suTone=tone(node);
  });
  root.querySelectorAll(panels).forEach(node=>{if(!excluded(node))node.classList.add('su-panel');});
  root.querySelectorAll(metrics).forEach(node=>{if(!excluded(node))node.classList.add('su-metric');});
  root.querySelectorAll('i.bi').forEach(node=>{
   if(excluded(node)||node.dataset.uiIconReady)return;
   const key=[...node.classList].find(c=>c.startsWith('bi-'))?.slice(3),name=iconMap[key];
   if(name&&window.UimsUI){
    const svg=window.UimsUI.icon(name);if(key==='printer')svg.querySelector('path').setAttribute('d','M6 9V3h12v6M6 18H3V9h18v9h-3M6 14h12v7H6zM17 12h.01');
    node.dataset.uiIcon=name;node.dataset.uiIconReady='true';node.setAttribute('aria-hidden','true');node.replaceChildren(svg);
   }
  });
  root.querySelectorAll('.edit-badge').forEach(node=>{
   if(node.textContent.trim()==='✎'&&window.UimsUI){node.replaceChildren(window.UimsUI.icon('edit'));}
   if(node.tagName==='LABEL'&&!node.hasAttribute('tabindex')){
    node.tabIndex=0;node.setAttribute('role','button');node.setAttribute('aria-label',node.title||window.uimsT('Edit'));
    node.addEventListener('keydown',event=>{if(event.key==='Enter'||event.key===' '){event.preventDefault();document.getElementById(node.htmlFor)?.click();}});
   }
  });
  root.querySelectorAll('.progress-fill,.progress-bar,[data-ui-progress]').forEach(bar=>{
   if(excluded(bar))return;bar.classList.add('su-progress-fill');bar.parentElement.classList.add('su-progress-track');
   if(!bar.hasAttribute('role'))bar.setAttribute('role','progressbar');
   if(!bar.hasAttribute('aria-label')&&!bar.hasAttribute('aria-labelledby'))bar.setAttribute('aria-label',window.uimsT('SupervisorProgress'));
   if(!bar.hasAttribute('aria-valuemin'))bar.setAttribute('aria-valuemin','0');
   if(!bar.hasAttribute('aria-valuemax'))bar.setAttribute('aria-valuemax','100');
   if(!bar.hasAttribute('data-ui-progress')){
    const width=bar.style.width;if(width.endsWith('%')&&Number.isFinite(parseFloat(width)))bar.setAttribute('aria-valuenow',String(Math.max(0,Math.min(100,parseFloat(width)))));
   }
  });
 }
 // Keep the real server filter and Apply button; expose them directly for supervisors.
 const meetingToolbar=root.querySelector('.meeting-toolbar'),filterDialog=document.getElementById('filterDialog');
 if(meetingToolbar&&filterDialog){
  const field=filterDialog.querySelector('select'),label=filterDialog.querySelector('label'),apply=filterDialog.querySelector('input[type=submit]');
  if(field&&label&&apply){
   const group=document.createElement('div');group.className='su-meeting-view';
   group.append(label,field);meetingToolbar.prepend(group,apply);
   const old=meetingToolbar.querySelector('button[onclick*="filterDialog"]');if(old)old.hidden=true;
   // Filter already-authorized rows in place. Server-supplied groups retain exact view semantics.
   const records=root.querySelector('.meeting-table-wrap');
   if(records){
    const rows=[...records.querySelectorAll('[data-meeting-views]')].map(marker=>{
     const row=marker.closest('tr');return {marker,row,groups:marker.dataset.meetingViews.split(' '),text:marker.textContent+' '+(row.cells[1]?.textContent||'')};
    });
    const normalize=value=>value.normalize('NFKC').toLocaleLowerCase().replace(/[\u064B-\u065F\u0670\u0640]/g,'').replace(/[أإآ]/g,'ا').replace(/ى/g,'ي').trim();
    const searchGroup=document.createElement('div');searchGroup.className='su-meeting-search';
    const searchLabel=document.createElement('label');searchLabel.htmlFor='meetingLiveSearch';searchLabel.textContent=window.uimsT('MeetingSearchLabel');
    const searchBox=document.createElement('div');searchBox.className='su-meeting-search-box';
    const input=document.createElement('input');input.id='meetingLiveSearch';input.type='search';input.maxLength=200;input.autocomplete='off';input.placeholder=window.uimsT('MeetingSearchPlaceholder');
    if(!records.id)records.id='meetingLiveRecords';input.setAttribute('aria-controls',records.id);
    const clear=document.createElement('button');clear.type='button';clear.className='su-meeting-search-clear';clear.setAttribute('aria-label',window.uimsT('MeetingClearSearch'));clear.append(window.UimsUI.icon('close'));
    searchBox.append(window.UimsUI.icon('search'),input,clear);searchGroup.append(searchLabel,searchBox);meetingToolbar.prepend(searchGroup);
    const summary=document.createElement('output');summary.className='su-meeting-search-summary';summary.setAttribute('aria-live','polite');summary.setAttribute('aria-atomic','true');
    const empty=document.createElement('p');empty.className='su-meeting-search-empty';empty.textContent=window.uimsT('MeetingSearchEmpty');
    root.querySelector('.meeting-view-bar')?.append(summary);records.after(empty);
    rows.forEach(item=>item.search=normalize(item.text));
    function filter(){
     const terms=normalize(input.value).split(/\s+/).filter(Boolean);let visible=0;
     rows.forEach(item=>{const match=item.groups.includes(field.value)&&terms.every(term=>item.search.includes(term));item.row.hidden=!match;item.marker.removeAttribute('data-initial-view');if(match)visible++;});
     clear.hidden=!input.value;empty.hidden=visible!==0||rows.length===0;
     const text=window.uimsT('MeetingSearchResults',visible,rows.length);if(summary.textContent!==text)summary.textContent=text;
     const viewName=root.querySelector('[id$=MeetingViewName]');if(viewName&&viewName.textContent!==field.selectedOptions[0].text)viewName.textContent=field.selectedOptions[0].text;
    }
    input.addEventListener('input',filter);input.addEventListener('search',filter);
    input.addEventListener('keydown',event=>{if(event.key==='Enter')event.preventDefault();});
    clear.addEventListener('click',()=>{input.value='';filter();input.focus();});field.addEventListener('change',filter);
    apply.hidden=true;filter();
   }
  }
 }
 const taskSearch=root.querySelector('.tasks-search-wrap');
 if(taskSearch&&window.UimsUI&&!taskSearch.querySelector('.su-search-icon')){
  const icon=window.UimsUI.icon('search');icon.classList.add('su-search-icon');taskSearch.prepend(icon);
 }
 // Reuse the existing dialog focus trap and Escape/return-focus behavior for the task overlays.
 for(const [id,close] of [['taskCreateView','showTasksList'],['taskDetailsOverlay','closeTaskDetails'],['taskSuccessOverlay','closeTaskSuccessDialog'],['moDialog','hideToggleDialog']]){
  const dialog=document.getElementById(id);if(dialog){dialog.dataset.uiDialog='';dialog.dataset.uiClose=close;}
 }
 window.UimsUI?.refresh();refresh();
 let refreshFrame=0;
 const observer=new MutationObserver(changes=>{
  if(changes.every(change=>change.target.nodeType===1&&change.target.closest('.su-meeting-search-summary,[id$=MeetingViewName]')))return;
  if(refreshFrame)return;refreshFrame=requestAnimationFrame(()=>{refreshFrame=0;refresh();});
 });
 // Observe new postback/client-rendered content, not class/style changes caused by this adapter.
 observer.observe(root,{childList:true,subtree:true});
 window.Sys?.WebForms?.PageRequestManager?.getInstance().add_endRequest(()=>{window.UimsUI?.refresh();refresh();});
 window.addEventListener('pageshow',()=>{observer.observe(root,{childList:true,subtree:true});refresh();});
 window.addEventListener('pagehide',()=>{observer.disconnect();cancelAnimationFrame(refreshFrame);refreshFrame=0;});
 window.UimsSupervisorUI={refresh};
}());
