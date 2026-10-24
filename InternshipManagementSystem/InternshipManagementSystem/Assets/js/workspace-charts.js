/* Reference analytics: native SVG, local authorized records, no chart framework or network. */
(function(){
 'use strict';
 if(window.UimsReferenceAnalytics){window.UimsReferenceAnalytics.refresh();return;}
 const NS='http://www.w3.org/2000/svg',reduced=matchMedia('(prefers-reduced-motion: reduce)'),instances=new Map(),locale=window.uimsLang==='ar'?'ar-JO-u-nu-latn-ca-gregory':'en',format=new Intl.NumberFormat(locale,{maximumFractionDigits:1}),t=function(){return typeof window.uimsT==='function'?window.uimsT.apply(null,arguments):arguments[0];};
 const number=n=>format.format(n),month=d=>new Intl.DateTimeFormat(locale,{month:'short',year:'2-digit',timeZone:'UTC'}).format(new Date(d));
 function node(tag,cls,text){const n=document.createElement(tag);if(cls)n.className=cls;if(text!==undefined)n.textContent=text;return n;}
 function svg(tag,attrs,text){const n=document.createElementNS(NS,tag);Object.entries(attrs||{}).forEach(([k,v])=>n.setAttribute(k,String(v)));if(text!==undefined)n.textContent=text;return n;}
 function sum(events){return events.reduce((n,e)=>n+e.Value,0);}
 function setKpiValue(element,value,animate){element.textContent=value;if(!animate||reduced.matches)return;element.classList.remove('ra-value-arriving');void element.offsetWidth;element.classList.add('ra-value-arriving');}
 function buckets(events){const map=new Map();events.forEach(e=>{const d=new Date(e.Date),key=Date.UTC(d.getUTCFullYear(),d.getUTCMonth(),1);if(!map.has(key))map.set(key,{date:key,value:0,records:[]});const b=map.get(key);b.value+=e.Value;b.records.push(e.Record);});return [...map.values()].sort((a,b)=>a.date-b.date);}
 function curve(points){
  if(!points.length)return '';if(points.length===1)return 'M'+points[0].join(',');
  const slopes=points.slice(1).map((p,i)=>(p[1]-points[i][1])/(p[0]-points[i][0])),tangents=points.map((p,i)=>i===0?slopes[0]:i===points.length-1?slopes.at(-1):slopes[i-1]*slopes[i]<=0?0:2/(1/slopes[i-1]+1/slopes[i]));
  let d='M'+points[0].join(',');for(let i=0;i<points.length-1;i++){const a=points[i],b=points[i+1],dx=(b[0]-a[0])/3;d+=' C'+[a[0]+dx,a[1]+dx*tangents[i],b[0]-dx,b[1]-dx*tangents[i+1],b[0],b[1]].join(',');}return d;
 }
 function enter(plot,animate){if(animate&&!reduced.matches){plot.getAnimations().forEach(a=>a.cancel());plot.animate([{opacity:.35,clipPath:'inset(0 100% 0 0)'},{opacity:1,clipPath:'inset(0 0 0 0)'}],{duration:320,easing:'cubic-bezier(.16,1,.3,1)'});}}
 function chartBase(plot,maximum,labels){
  const w=Math.max(210,plot.clientWidth),h=250,pad={l:38,r:14,t:12,b:labels?68:35},innerW=w-pad.l-pad.r,innerH=h-pad.t-pad.b,step=Math.max(1,Math.ceil(maximum/4)),top=step*4,base=h-pad.b;
  const drawing=svg('svg',{viewBox:'0 0 '+w+' '+h,'aria-hidden':'true'});
  for(let i=0;i<=4;i++){const y=base-innerH*i/4;drawing.append(svg('line',{x1:pad.l,x2:w-pad.r,y1:y,y2:y,stroke:'var(--ui-border)','stroke-width':1}),svg('text',{x:pad.l-8,y:y+4,'text-anchor':'end'},number(step*i)));}
  plot.replaceChildren(drawing);return {drawing,w,h,pad,innerW,innerH,base,top};
 }
 function create(root){
  const data=JSON.parse(root.querySelector('[data-analytics-model]').textContent),rangeButtons=[...root.querySelectorAll('[data-range]')],marker=root.querySelector('.ra-range-marker'),modal=root.querySelector('.ra-record-modal'),tooltip=root.querySelector('.ra-tooltip');
  let range=data.RangeMonths>0?data.RangeMonths:6,current=[],points=[],opener=null,recordRows=[],recordPage=0,recordScope='',width=0,frame=0;
  const safeUrl=value=>{const raw=value?.startsWith('~/')?root.dataset.appRoot+value.slice(2):value;try{const url=new URL(raw,location.href);return url.origin===location.origin&&/^https?:$/.test(url.protocol)?url.href:'#';}catch(_){return '#';}};
  const stockScope=t('ChartCurrentSnapshot',new Date(data.Now).toISOString().slice(0,10));
  function mark(animate){const button=rangeButtons.find(b=>Number(b.dataset.range)===range);if(!button||!marker)return;const x=button.offsetLeft,w=button.offsetWidth,from=getComputedStyle(marker).transform;marker.getAnimations().forEach(a=>a.cancel());marker.style.width=w+'px';marker.style.transform='translateX('+x+'px)';if(animate&&!reduced.matches&&from!=='none')marker.animate([{transform:from},{transform:marker.style.transform}],{duration:340,easing:'cubic-bezier(.16,1,.3,1)'});}
  function pageRecords(){
   const list=modal.querySelector('.ra-record-list');list.replaceChildren();const start=recordPage*10,rows=recordRows.slice(start,start+10);
   rows.forEach(record=>{const li=node('li'),body=node('div');body.append(node('strong','',record.Title),node('p','',record.Detail||''));const link=node('a','',t('ChartOpenRecord'));link.href=safeUrl(record.Url);body.append(link);li.append(body);if(record.Value!==null&&record.Value!==undefined)li.append(node('b','',number(record.Value)));list.append(li);});
   modal.querySelector('[data-record-empty]').hidden=rows.length>0;
   const prev=modal.querySelector('[data-record-page="-1"]'),next=modal.querySelector('[data-record-page="1"]');prev.disabled=recordPage===0;next.disabled=start+10>=recordRows.length;
   modal.querySelector('[data-record-page-label]').textContent=recordRows.length?t('ChartRecordRange',start+1,Math.min(start+10,recordRows.length),recordRows.length):t('ChartZeroRecords');
   modal.querySelector('[data-record-scope]').textContent=recordScope;window.UimsUI?.refresh(modal);
  }
  function records(title,rows,scope,target){opener=target instanceof SVGElement&&!target.hasAttribute('tabindex')?root.querySelector('[data-data-toggle]'):target;recordRows=rows;recordScope=scope;recordPage=0;modal.querySelector('.modal-title').textContent=title;pageRecords();tooltip.hidden=true;if(opener?.matches('button'))opener.setAttribute('aria-expanded','true');bootstrap.Modal.getOrCreateInstance(modal).show(opener);}
  modal.addEventListener('hidden.bs.modal',()=>{if(opener?.isConnected){opener.setAttribute('aria-expanded','false');if(!opener.disabled)opener.focus();}});
  function area(animate){
   const plot=root.querySelector('[data-plot="trend"]');
   if(!points.length){const unknown=data.Undated.length>0;plot.replaceChildren(node('div','ra-empty',unknown&&!data.Events.length?t('ChartHistoryUnavailable'):t('ChartNoDatedInPeriod')));plot.dataset.state=unknown&&!data.Events.length?'missing':'empty';return;}
   plot.dataset.state=points.length===1?'single':'ready';const c=chartBase(plot,Math.max(...points.map(p=>p.value)),false),coords=points.map((p,i)=>[c.pad.l+(points.length===1?c.innerW/2:c.innerW*(p.date-points[0].date)/(points.at(-1).date-points[0].date)),c.base-c.innerH*p.value/c.top]),path=curve(coords);
   if(points.length>1){const gradientId=modal.id+'_fill',defs=svg('defs'),gradient=svg('linearGradient',{id:gradientId,x1:0,x2:0,y1:0,y2:1});gradient.append(svg('stop',{offset:'0%','stop-color':'var(--ra-approved)','stop-opacity':.14}),svg('stop',{offset:'100%','stop-color':'var(--ra-approved)','stop-opacity':.02}));defs.append(gradient);c.drawing.append(defs,svg('path',{d:path+' L'+coords.at(-1)[0]+','+c.base+' L'+coords[0][0]+','+c.base+' Z',fill:'url(#'+gradientId+')'}),svg('path',{d:path,fill:'none',stroke:'var(--ra-approved)','stroke-width':2,'stroke-linejoin':'round','stroke-linecap':'round'}));}
   coords.forEach((p,i)=>{c.drawing.append(svg('circle',{cx:p[0],cy:p[1],r:4,fill:'var(--ra-approved)',stroke:'var(--ui-surface)','stroke-width':2,'data-mark':'trend','data-index':i}));const interval=Math.max(1,Math.ceil(points.length/(c.w<350?3:6)));if(i%interval===0||i===points.length-1)c.drawing.append(svg('text',{x:p[0],y:c.h-10,'text-anchor':i===0?'start':i===points.length-1?'end':'middle'},month(points[i].date)));});enter(plot,animate);
  }
  // Opt-in horizontal bars (coordinator Students by Major). Bar length is the
  // exact count on one shared scale; zero stays zero. Rows are focusable.
  function hbar(animate){
   const plot=root.querySelector('[data-plot="bar"]'),items=data.Bars,total=items.reduce((n,p)=>n+p.Value,0);plot.classList.add('ra-plot-h');
   if(!items.length||total===0){plot.style.height='';plot.dataset.state='empty';plot.replaceChildren(node('div','ra-empty',t('ChartNoStudentsByMajor')));return;}
   const rtl=getComputedStyle(root).direction==='rtl',w=Math.max(240,plot.clientWidth),barH=16,pad=6,valueW=58;
   const context=document.createElement('canvas').getContext('2d');context.font='600 16px '+getComputedStyle(root).fontFamily;
   const width=s=>context.measureText(s).width,cap=w*.42-20;
   // Long programme names wrap onto two balanced lines; if a line still does not fit, labels go above the bars.
   const lines=items.map(p=>{if(width(p.Label)<=cap)return [p.Label];const words=p.Label.split(' ');let best=null;for(let i=1;i<words.length;i++){const a=words.slice(0,i).join(' '),b=words.slice(i).join(' '),m=Math.max(width(a),width(b));if(!best||m<best.m)best={a,b,m};}return best?[best.a,best.b]:[p.Label];});
   const longest=Math.max(...lines.flat().map(width)),narrow=w<440||longest>cap;
   const labelW=narrow?0:longest+20,rowH=narrow?64:(lines.some(l=>l.length>1)?56:48),h=items.length*rowH+pad*2;
   const max=Math.max(...items.map(p=>p.Value),1),x0=labelW,span=Math.max(20,w-valueW-x0),X=x=>rtl?w-x:x;
   plot.style.height=h+'px';
   const drawing=svg('svg',{viewBox:'0 0 '+w+' '+h,role:'presentation'});
   items.forEach((p,i)=>{
    const top=pad+i*rowH,cy=narrow?top+rowH-barH/2-9:top+rowH/2,len=p.Value>0?Math.max(4,span*p.Value/max):0;
    const row=svg('g',{class:'ra-hrow'+(p.Tone==='active'?'':' is-quality'),'data-mark':'bar','data-index':i,tabindex:0,role:'button','aria-label':p.Label+': '+number(p.Value)+' '+data.BarUnit+(total?' ('+number(Math.round(p.Value/total*1000)/10)+'%)':'')});
    row.append(svg('rect',{x:0,y:top,width:w,height:rowH,rx:8,class:'ra-hhit'}));
    if(narrow)row.append(svg('text',{x:X(4),y:top+18,'text-anchor':rtl?'end':'start',class:'ra-hlabel'},p.Label));
    else{const label=svg('text',{x:X(labelW-16),y:cy+5-(lines[i].length-1)*9,'text-anchor':rtl?'start':'end',class:'ra-hlabel'});lines[i].forEach((line,j)=>label.append(svg('tspan',{x:X(labelW-16),dy:j?18:0},line)));row.append(label);}
    row.append(svg('rect',{x:rtl?w-x0-span:x0,y:cy-barH/2,width:span,height:barH,rx:barH/2,class:'ra-htrack'}));
    if(len>0)row.append(svg('rect',{x:rtl?w-x0-len:x0,y:cy-barH/2,width:len,height:barH,rx:Math.min(barH/2,len/2),fill:'var(--ra-'+p.Tone+')',class:'ra-hfill'}));
    row.append(svg('text',{x:X(x0+len+10),y:cy+5,'text-anchor':rtl?'end':'start',class:'ra-hvalue','data-bar-value':i},number(p.Value)));
    drawing.append(row);
   });
   plot.replaceChildren(drawing);plot.dataset.state='ready';
   if(animate&&!reduced.matches)drawing.querySelectorAll('.ra-hrow').forEach((row,i)=>{const delay=40+i*30,fill=row.querySelector('.ra-hfill'),value=row.querySelector('.ra-hvalue');if(fill)fill.animate([{transform:'scaleX(0)'},{transform:'scaleX(1)'}],{duration:380,delay,easing:'cubic-bezier(.16,1,.3,1)',fill:'both'});value.animate([{opacity:0,transform:'translateX('+(rtl?8:-8)+'px)'},{opacity:1,transform:'translateX(0)'}],{duration:220,delay:delay+220,easing:'ease-out',fill:'both'});});
  }
  function bar(animate){
   if(data.BarLayout==='horizontal'){hbar(animate);return;}
   const plot=root.querySelector('[data-plot="bar"]'),items=data.Bars;
   if(!items.length){plot.replaceChildren(node('div','ra-empty',t('ChartNoCategoryRecords')));return;}
   const c=chartBase(plot,Math.max(...items.map(p=>p.Value)),true),cell=c.innerW/items.length,bw=Math.min(24,cell*.42);
   const context=document.createElement('canvas').getContext('2d');context.font='13px '+getComputedStyle(root).fontFamily;
   const aliases={'Applications':'Apps','Submissions':'Work','Hour entries':'Hour entries','Hours target met':'Target met','Target not set':'No target','No placement':'No place','Under review':'Review','Needs revision':'Revision','Resubmitted':'Resubmit'};
   const labels=items.map(p=>context.measureText(p.Label).width>cell-8?(aliases[p.Label]||p.Label):p.Label);
   const compact=labels.some(label=>context.measureText(label).width>cell-8);

   items.forEach((p,i)=>{const center=c.pad.l+cell*(i+.5),height=p.Value/c.top*c.innerH;const mark=svg('rect',{x:center-bw/2,y:c.base-height,width:bw,height:height,rx:4,fill:'var(--ra-'+p.Tone+')','data-mark':'bar','data-index':i});c.drawing.append(mark);
    const short=labels[i];const label=svg('text',{x:center,y:c.base+21,'text-anchor':compact?'end':'middle'},short);
    if(compact)label.setAttribute('transform',`rotate(-35 ${center} ${c.base+21})`);else if(context.measureText(short).width>cell-8&&short.includes(' ')){const words=short.split(' '),middle=Math.ceil(words.length/2);label.textContent='';label.append(svg('tspan',{x:center,dy:0},words.slice(0,middle).join(' ')),svg('tspan',{x:center,dy:16},words.slice(middle).join(' ')));}c.drawing.append(label);
    c.drawing.append(svg('text',{x:center,y:Math.max(12,c.base-height-7),'text-anchor':'middle',fill:'var(--ui-ink)','data-bar-value':i},number(p.Value)));
   });if(animate&&!reduced.matches)c.drawing.querySelectorAll('[data-mark="bar"]').forEach((mark,i)=>{const delay=Math.min(i*18,90);mark.animate([{transform:'scaleY(.08)',opacity:.35},{transform:'scaleY(1)',opacity:1}],{duration:280,delay,easing:'cubic-bezier(.16,1,.3,1)',fill:'both'});c.drawing.querySelector('[data-bar-value="'+i+'"]').animate([{opacity:0},{opacity:1}],{duration:160,delay:delay+150,easing:'ease-out',fill:'both'});});enter(plot,animate);
  }
  function donut(animate){
   const plot=root.querySelector('[data-plot="donut"]');if(!plot)return;const total=data.Breakdown.reduce((n,p)=>n+p.Value,0),drawing=svg('svg',{viewBox:'0 0 180 180','aria-hidden':'true'}),r=80,inner=54;let angle=-Math.PI/2;
   drawing.append(svg('circle',{cx:90,cy:90,r:67,fill:'none',stroke:'var(--ui-neutral-soft)','stroke-width':26}));
   data.Breakdown.forEach((p,i)=>{if(!p.Value)return;const arc=Math.min(Math.PI*2-.00001,p.Value/total*Math.PI*2),end=angle+arc,point=(radius,a)=>[90+radius*Math.cos(a),90+radius*Math.sin(a)],a=point(r,angle),b=point(r,end),d=point(inner,end),e=point(inner,angle);const path=`M${a} A${r},${r} 0 ${arc>Math.PI?1:0} 1 ${b} L${d} A${inner},${inner} 0 ${arc>Math.PI?1:0} 0 ${e} Z`;drawing.append(svg('path',{d:path,fill:'var(--ra-'+p.Tone+')',stroke:'var(--ui-surface)','stroke-width':2,'data-mark':'donut','data-index':i}));angle=end;});
    drawing.append(svg('text',{x:90,y:81,'text-anchor':'middle','font-size':13},data.DonutUnit),svg('text',{x:90,y:111,'text-anchor':'middle','font-size':28,'font-weight':600},number(total)));plot.replaceChildren(drawing);plot.dataset.total=total;if(animate&&!reduced.matches)drawing.querySelectorAll('[data-mark="donut"]').forEach((mark,i)=>mark.animate([{opacity:.2,transform:'scale(.88)'},{opacity:1,transform:'scale(1)'}],{duration:260,delay:Math.min(i*20,100),easing:'cubic-bezier(.16,1,.3,1)',fill:'both'}));
   data.Breakdown.forEach((p,i)=>{root.querySelector('[data-share="'+i+'"]').textContent=total?(p.Value>0&&p.Value/total<.01?'<1%':number(Math.round(p.Value/total*1000)/10)+'%'):'—';});enter(plot,animate);
  }
  function render(animate){
   const now=new Date(data.Now),start=Date.UTC(now.getUTCFullYear(),now.getUTCMonth()-range+1,1),previousStart=start-(data.Now-start);
   current=data.Events.filter(e=>e.Date>=start&&e.Date<=data.Now);const previous=data.Events.filter(e=>e.Date>=previousStart&&e.Date<start),value=sum(current),prev=sum(previous),historyKnown=data.Events.length>0||data.Undated.length===0;points=buckets(current);
   root.dataset.selectedRange=range;root.querySelector('[data-range-caption]').textContent=t(rangeButtons.length?'ChartRangeCaption':'ChartFixedRangeCaption',month(start),month(data.Now),range);
   root.querySelector('[data-trend-subtitle]').textContent=t('ChartTrendSubtitle',data.TrendUnit);
   root.querySelectorAll('[data-kpi]').forEach(card=>{const index=Number(card.dataset.kpi),kpi=data.Kpis[index];if(!kpi.Flow)return;setKpiValue(card.querySelector('[data-kpi-value]'),historyKnown?number(value):'—',animate);const compare=card.querySelector('[data-kpi-comparison]');compare.textContent=!historyKnown?t('ChartHistoryMissing'):prev>0?t('ChartVsPrevious',(value>=prev?'+':'')+number((value/prev-1)*100)):t('ChartNoPercentage');
    const spark=card.querySelector('.ra-spark');spark.replaceChildren();if(points.length>=2){const max=Math.max(...points.map(p=>p.value),1),coords=points.map((p,i)=>[3+(p.date-points[0].date)*66/(points.at(-1).date-points[0].date),27-p.value/max*24]),drawing=svg('svg',{viewBox:'0 0 72 30',width:72,height:30});drawing.append(svg('path',{d:curve(coords),fill:'none',stroke:'var(--ra-approved)','stroke-width':2,'stroke-linecap':'round'}));spark.append(drawing);}
   });
   const note=root.querySelector('[data-history-note]');note.replaceChildren(document.createTextNode(points.length===1?t('ChartOneMonth'):t('ChartOnlyMonths')));
   note.append(document.createTextNode(data.Role==='Coordinator'?t('ChartCoordinatorNote'):t('ChartReviewDateNote')));
   if(data.Undated.length){const button=node('button','ra-table-action',t(data.Undated.length===1?'ChartUndatedOne':'ChartUndatedMany',data.Undated.length));button.type='button';button.dataset.undated='true';note.append(' ',button);}
   const body=root.querySelector('[data-trend-rows]');body.replaceChildren();points.forEach((point,i)=>{const tr=node('tr'),label=node('th','',month(point.date));label.scope='row';const value=node('td','',number(point.value)),action=node('td'),button=node('button','ra-table-action',t('ChartViewRecords'));button.type='button';button.dataset.records='trend';button.dataset.category=i;button.setAttribute('aria-label',t('ChartViewRecordsFor',month(point.date)));action.append(button);tr.append(label,value,action);body.append(tr);});if(!points.length){const tr=node('tr'),td=node('td','',t('ChartNoDatedWindow'));td.colSpan=3;tr.append(td);body.append(tr);}
   rangeButtons.forEach(b=>{const selected=Number(b.dataset.range)===range;b.setAttribute('aria-checked',String(selected));b.tabIndex=selected?0:-1;b.disabled=data.Events.length===0;});mark(animate);area(animate);
  }
  const legend=root.querySelector('[data-bar-legend]');if(data.BarLayout!=='horizontal')data.Bars.forEach((point,i)=>{const button=node('button');button.type='button';button.dataset.records='bar';button.dataset.category=i;button.setAttribute('aria-haspopup','dialog');const swatch=node('i');swatch.dataset.tone=point.Tone;swatch.setAttribute('aria-hidden','true');button.append(swatch,document.createTextNode(point.Label));legend.append(button);});
  root.querySelectorAll('[data-kpi]').forEach((card,i)=>{card.style.setProperty('--ra-delay',i*25+'ms');card.querySelector('[data-kpi-value]').classList.add('ra-value-arriving');});
  function chooseRange(button){if(button.disabled)return;range=Number(button.dataset.range);tooltip.hidden=true;render(true);}
  root.addEventListener('keydown',event=>{const mark=event.target.closest&&event.target.closest('[data-mark][tabindex]');if(mark&&(event.key==='Enter'||event.key===' ')){event.preventDefault();mark.dispatchEvent(new MouseEvent('click',{bubbles:true}));}});
  root.addEventListener('focusin',event=>{const mark=event.target.closest&&event.target.closest('[data-mark][tabindex]');if(!mark)return;const point=data.Bars[Number(mark.dataset.index)];if(!point)return;tooltip.textContent=point.Label+' · '+number(point.Value)+' '+data.BarUnit;tooltip.hidden=false;const rect=mark.getBoundingClientRect(),tip=tooltip.getBoundingClientRect();tooltip.style.left=Math.max(12,Math.min(innerWidth-tip.width-12,rect.left+rect.width/2-tip.width/2))+'px';tooltip.style.top=Math.max(12,rect.top-tip.height-8)+'px';});
  root.addEventListener('focusout',event=>{if(event.target.closest&&event.target.closest('[data-mark][tabindex]'))tooltip.hidden=true;});
  root.addEventListener('keydown',event=>{const button=event.target.closest('[data-range]');if(!button||!['ArrowLeft','ArrowRight','Home','End'].includes(event.key))return;event.preventDefault();const index=rangeButtons.indexOf(button),next=event.key==='Home'?0:event.key==='End'?rangeButtons.length-1:(index+((event.key==='ArrowLeft')!==(document.documentElement.dir==='rtl')?-1:1)+rangeButtons.length)%rangeButtons.length;chooseRange(rangeButtons[next]);rangeButtons[next].focus();});
  root.addEventListener('click',event=>{
   const target=event.target.closest('button,a,[data-mark]');if(!target)return;
   if(target.matches('[data-range]')){chooseRange(target);return;}
   if(target.matches('[data-kpi]')){const kpi=data.Kpis[Number(target.dataset.kpi)],missing=kpi.Flow&&!data.Events.length&&data.Undated.length;records(kpi.Label,kpi.Flow?(missing?data.Undated:current.map(e=>e.Record)):kpi.Records,kpi.Flow?(missing?t('ChartUndatedNoDates'):t('ChartRangeScope',month(Date.UTC(new Date(data.Now).getUTCFullYear(),new Date(data.Now).getUTCMonth()-range+1,1)),month(data.Now))):stockScope,target);return;}
   if(target.matches('[data-undated]')){records(t('ChartUndatedTitle'),data.Undated,t('ChartUndatedScope'),target);return;}
   if(target.matches('[data-data-toggle]')){event.preventDefault();const details=root.querySelector('[data-data-table="'+target.dataset.dataToggle+'"]');details.open=!details.open;if(details.open)details.querySelector('summary').focus();return;}
   if(target.matches('[data-record-page]')){recordPage=Math.max(0,Math.min(Math.ceil(recordRows.length/10)-1,recordPage+Number(target.dataset.recordPage)));pageRecords();if(target.disabled)modal.querySelector('.modal-title').focus();return;}
   const kind=target.dataset.records||target.dataset.mark,index=Number(target.dataset.category??target.dataset.index);
   if(kind==='trend'&&points[index])records(month(points[index].date)+' · '+data.TrendUnit,points[index].records,t('ChartMonthScope'),target);
   else if(kind==='bar'||kind==='donut'){const point=(kind==='bar'?data.Bars:data.Breakdown)[index];records(point.Label,point.Records,stockScope,target);}
  });
  root.addEventListener('pointerover',event=>{const mark=event.target.closest('[data-mark]');if(!mark)return;const kind=mark.dataset.mark,index=Number(mark.dataset.index),point=kind==='trend'?points[index]:(kind==='bar'?data.Bars:data.Breakdown)[index];if(!point)return;tooltip.textContent=kind==='trend'?`${month(point.date)} · ${number(point.value)} ${data.TrendUnit}`:`${point.Label} · ${number(point.Value)} ${kind==='bar'?data.BarUnit:data.DonutUnit}`;tooltip.hidden=false;});
  root.addEventListener('pointermove',event=>{if(tooltip.hidden)return;const rect=tooltip.getBoundingClientRect();tooltip.style.left=Math.max(12,Math.min(innerWidth-rect.width-12,event.clientX+14))+'px';tooltip.style.top=Math.max(12,Math.min(innerHeight-rect.height-12,event.clientY+14))+'px';});
  root.addEventListener('pointerout',event=>{if(event.target.closest('[data-mark]'))tooltip.hidden=true;});
  const observer=new ResizeObserver(()=>{const next=root.clientWidth;if(Math.abs(next-width)<1)return;width=next;cancelAnimationFrame(frame);frame=requestAnimationFrame(()=>{mark(false);area(false);bar(false);});});observer.observe(root);
  render(true);bar(true);donut(true);root.dataset.analyticsReady='true';
  return {dispose(){observer.disconnect();cancelAnimationFrame(frame);bootstrap.Modal.getInstance(modal)?.dispose();},reduce(){root.getAnimations({subtree:true}).forEach(a=>a.cancel());}};
 }
 function refresh(){for(const [root,instance]of instances)if(!root.isConnected){instance.dispose();instances.delete(root);}document.querySelectorAll('[data-reference-analytics]').forEach(root=>{if(instances.has(root))return;try{instances.set(root,create(root));}catch(error){root.dataset.analyticsReady='error';const message=node('p','ra-empty',t('ChartFailed'));message.setAttribute('role','alert');root.prepend(message);}});}
 window.UimsReferenceAnalytics={refresh};window.UimsCharts={refresh};refresh();document.addEventListener('DOMContentLoaded',refresh,{once:true});
 reduced.addEventListener('change',()=>{if(reduced.matches)instances.forEach(instance=>instance.reduce());});
 if(window.Sys?.WebForms)Sys.WebForms.PageRequestManager.getInstance().add_endRequest(refresh);
}());
