async page => {
 // Theme audit: opens every route as the right fixture role in Light and Dark and measures the rendered page.
 //  - lightSurfaces (Dark only): visible boxes ≥ 1500px² whose own background is light (relative luminance > .45),
 //    except printable documents (.uims-paper), which stay light by design.
 //  - contrast: text (and form-control values) below WCAG AA against the composited background behind it
 //    (4.5:1, or 3:1 for large text). Backgrounds over photos/canvas are counted as "unknown", not judged.
 //  - status, server errors, page errors and the theme attributes after load.
 // Run against tests/Start-LoginTestHost.ps1 with the campus-login simulation (4910); open the session on the host first
 // (playwright-cli open http://localhost:<port>/), otherwise 57992 is assumed. Read-only.
 // Options (window globals are not available here, so edit in place): THEMES, LANGS, WIDTHS, ONLY (route substring).
 const base=/^https?:/.test(page.url())?new URL(page.url()).origin:'http://localhost:57992', THEMES=['light','dark'], LANGS=['en'], WIDTHS=[[1440,900]], ONLY=null, SHOTS=null; // SHOTS='tests/artifacts/theme/audit/'
 const routes={
  public:['/Default.aspx','/Pages/Public/About.aspx','/Pages/Public/Contact.aspx','/Pages/Public/PoweredBy.aspx','/Pages/Public/Journey.aspx','/Pages/Public/AccessDenied.aspx','/Pages/Public/NotFound.aspx','/Pages/Public/404.aspx','/Pages/Account/Login.aspx','/Pages/Account/ForgotPassword.aspx','/Pages/Public/does-not-exist.aspx'],
  'student-one':['/Pages/Student/Dashboard.aspx','/Pages/Student/Opportunities.aspx','/Pages/Student/exploreOpport.aspx','/Pages/Student/OpportunityDetails.aspx?id=internship-one','/Pages/Student/Apply.aspx?opportunityId=internship-one','/Pages/Student/MyApplications.aspx','/Pages/Student/MyTasks.aspx','/Pages/Student/Progress.aspx','/Pages/Student/Profile.aspx','/Pages/Student/DisplayEditProfile.aspx','/Pages/Student/StudentCVPortfolio.aspx','/Pages/Account/Notifications.aspx','/Pages/Notifications/Inbox.aspx','/Pages/Account/ChangePassword.aspx','/Pages/Account/CompletionReport.aspx','/Pages/Meetings/MyMeetings.aspx'],
  'supervisor-one':['/Pages/Company/Dashboard.aspx','/Pages/Company/Opportunities.aspx','/Pages/Company/ManageOpportunities.aspx','/Pages/Company/ViewOpportunity.aspx?id=internship-one','/Pages/Company/Applications.aspx','/Pages/Company/ApplicantDocument.aspx','/Pages/Company/Trainees.aspx','/Pages/Company/TraineeDetails.aspx','/Pages/Company/Tasks.aspx','/Pages/Company/TaskReview.aspx','/Pages/Company/FinalEvaluation.aspx','/Pages/Company/EvaluationReport.aspx','/Pages/Company/Account.aspx','/Pages/Meetings/Schedule.aspx','/Pages/Meetings/MyMeetings.aspx','/Pages/Notifications/Inbox.aspx'],
  'academic-one':['/Pages/Academic/Dashboard.aspx','/Pages/Academic/StudentProgress.aspx','/Pages/Academic/FinalEvaluation.aspx','/Pages/Academic/Account.aspx','/Pages/Meetings/Schedule.aspx','/Pages/Reports/Grades.aspx','/Pages/Notifications/Inbox.aspx'],
  'coordinator-one':['/Pages/Coordinator/Dashboard.aspx','/Pages/Coordinator/Students.aspx','/Pages/Coordinator/ManageStudents.aspx','/Pages/Coordinator/AddStudent.aspx','/Pages/Coordinator/Companies.aspx','/Pages/Coordinator/AcademicSupervisors.aspx','/Pages/Coordinator/Groups.aspx','/Pages/Coordinator/ConfiguredGroups.aspx','/Pages/Coordinator/Placements.aspx','/Pages/Coordinator/PlacementDetails.aspx','/Pages/Coordinator/CompletionReview.aspx','/Pages/Coordinator/ContactMessages.aspx','/Pages/Coordinator/Account.aspx','/Pages/Coordinator/DemoStudent.aspx','/Pages/Reports/Grades.aspx','/Pages/Notifications/Inbox.aspx']
 };
 const measure=()=>{
  const parse=s=>{const m=/rgba?\(([\d.]+)[ ,]+([\d.]+)[ ,]+([\d.]+)(?:[ ,/]+([\d.]+%?))?/.exec(s||'');if(!m)return null;let a=m[4]===undefined?1:m[4].endsWith('%')?parseFloat(m[4])/100:+m[4];return [+m[1],+m[2],+m[3],a];};
  const lin=c=>{c/=255;return c<=.04045?c/12.92:Math.pow((c+.055)/1.055,2.4);};
  const L=c=>.2126*lin(c[0])+.7152*lin(c[1])+.0722*lin(c[2]);
  const ratio=(a,b)=>{const x=L(a),y=L(b);return (Math.max(x,y)+.05)/(Math.min(x,y)+.05);};
  const over=(top,under)=>{const a=top[3];return [top[0]*a+under[0]*(1-a),top[1]*a+under[1]*(1-a),top[2]*a+under[2]*(1-a),1];};
  const name=e=>{const c=typeof e.className==='string'?e.className.trim().split(/\s+/).filter(x=>x&&!/^(active|show|is-|ng-)/.test(x)).slice(0,2).join('.'):'';return e.tagName.toLowerCase()+(e.id?'#'+e.id.replace(/^(ctl00_|MainContent_|ContentPlaceHolder1_)+/,''):'')+(c?'.'+c:'');};
  const path=e=>{const p=e.parentElement;return (p&&p!==document.body?name(p)+' > ':'')+name(e);};
  const visible=e=>{const r=e.getBoundingClientRect();if(r.width<2||r.height<2)return false;for(let x=e;x;x=x.parentElement){const s=getComputedStyle(x);if(s.display==='none'||s.visibility==='hidden'||+s.opacity===0)return false;}return true;};
  const gradientMean=img=>{const cs=[...img.matchAll(/rgba?\([^)]+\)/g)].map(m=>parse(m[0])).filter(Boolean);if(!cs.length)return null;const n=cs.length;return [cs.reduce((s,c)=>s+c[0],0)/n,cs.reduce((s,c)=>s+c[1],0)/n,cs.reduce((s,c)=>s+c[2],0)/n,cs.reduce((s,c)=>s+c[3],0)/n];};
  // Background behind an element: composite every translucent layer up to the first opaque one.
  const bgOf=el=>{const layers=[];for(let e=el;e;e=e.parentElement){const s=getComputedStyle(e);if(/url\(/.test(s.backgroundImage))return null;if(['IMG','VIDEO','CANVAS','IFRAME'].includes(e.tagName))return null;
    let c=parse(s.backgroundColor);if(/gradient/.test(s.backgroundImage)){const g=gradientMean(s.backgroundImage);if(g)c=c&&c[3]>0?over(g,c):g;}
    if(c&&c[3]>0){layers.push(c);if(c[3]>=.98)break;}}
   let base=layers.length&&layers[layers.length-1][3]>=.98?layers.pop():[255,255,255,1];for(let i=layers.length-1;i>=0;i--)base=over(layers[i],base);return base;};
  // Anything painted over a canvas/photo region (absolutely positioned overlays) cannot be judged from CSS alone.
  const overMedia=el=>{const r=el.getBoundingClientRect(),cx=r.left+r.width/2,cy=r.top+r.height/2;return document.elementsFromPoint(Math.min(Math.max(cx,0),innerWidth-1),Math.min(Math.max(cy,0),innerHeight-1)).some(x=>['CANVAS','VIDEO','IMG'].includes(x.tagName)&&!el.contains(x));};
  const dark=document.documentElement.getAttribute('data-theme')==='dark';
  const out={theme:document.documentElement.getAttribute('data-theme'),bs:document.documentElement.getAttribute('data-bs-theme'),lightSurfaces:{},contrast:{},unknown:0,
   server:/Server Error in|Compilation Error|Parser Error|Runtime Error/.test(document.body?document.body.innerText.slice(0,600):''),url:location.pathname};
  const all=[...document.querySelectorAll('body *')];
  for(const e of all){
   if(e.closest('svg,.uims-sidebar-brand,.public-brand,[aria-hidden="true"].sr-only,noscript,script,style'))continue;
   const s=getComputedStyle(e);
   if(dark){const c=parse(s.backgroundColor),r=e.getBoundingClientRect();
    if(c&&c[3]>.45&&r.width*r.height>=1500&&L(c)>.45&&visible(e)&&!/logo/i.test(e.className+e.id)&&!e.closest('.uims-paper')){const k=path(e);out.lightSurfaces[k]=out.lightSurfaces[k]||{n:0,bg:s.backgroundColor,size:Math.round(r.width)+'x'+Math.round(r.height)};out.lightSurfaces[k].n++;}}
   const isField=['INPUT','TEXTAREA','SELECT'].includes(e.tagName)&&!['hidden','checkbox','radio','submit','button','image','file','range','color'].includes(e.type);
   const hasText=isField?!!(e.value||e.placeholder):[...e.childNodes].some(n=>n.nodeType===3&&n.textContent.trim().length>1);
   if(!hasText||!visible(e))continue;
   const fg=parse(s.color);if(!fg||fg[3]===0)continue;
   const bg=bgOf(e);if(!bg||overMedia(e)){out.unknown++;continue;}
   const color=fg[3]<1?over(fg,bg):fg;let rr=ratio(color,bg);
   const size=parseFloat(s.fontSize),bold=+s.fontWeight>=700,large=size>=24||(bold&&size>=18.66);
   const disabled=e.disabled||e.closest('[disabled],.disabled,[aria-disabled="true"]');
   const need=large?3:4.5;
   if(rr<need&&!disabled){const k=path(e);const prev=out.contrast[k];if(!prev||rr<prev.r)out.contrast[k]={r:Math.round(rr*100)/100,fg:s.color,bg:'rgb('+bg.slice(0,3).map(Math.round).join(',')+')',text:(isField?(e.value||e.placeholder):e.textContent).trim().slice(0,40),n:(prev?prev.n:0)+1};else prev.n++;}
  }
  return out;
 };
 const rows=[];
 for(const lang of LANGS)for(const [w,h] of WIDTHS)for(const theme of THEMES)for(const [who,list] of Object.entries(routes)){
  const todo=list.filter(r=>!ONLY||r.includes(ONLY));if(!todo.length)continue;
  const ctx=await page.context().browser().newContext({viewport:{width:w,height:h},reducedMotion:'reduce',isMobile:w<500,hasTouch:w<500});
  await ctx.addCookies([{name:'uims-lang',value:lang,url:base}]);
  await ctx.addInitScript(t=>{try{localStorage.setItem('uims-theme',t);}catch(e){}},theme);
  const p=await ctx.newPage();const errors=[];p.on('pageerror',e=>errors.push(e.message.slice(0,120)));p.on('console',m=>{if(m.type()==='error'&&!/favicon|Failed to load resource/.test(m.text()))errors.push('console: '+m.text().slice(0,120));});
  if(who!=='public')await p.goto(base+'/__fixture.aspx?user='+who);
  for(const route of todo){
   errors.length=0;let status=0;try{status=(await p.goto(base+route,{timeout:30000})).status();}catch(e){status=-1;}
   await p.waitForTimeout(900);
   const m=await p.evaluate(measure).catch(e=>({err:String(e).slice(0,120)}));
   if(SHOTS)await p.screenshot({path:SHOTS+(who==='public'?'':who.split('-')[0]+'-')+route.split('/').pop().split('?')[0].replace('.aspx','').toLowerCase()+'-'+theme+'-'+lang+'-'+w+'.png',fullPage:true}).catch(()=>{});
   rows.push({who,route,theme,lang,w,status,final:m.url,attr:m.theme+'/'+m.bs,server:m.server,errors:[...errors],light:m.lightSurfaces,contrast:m.contrast,unknown:m.unknown,err:m.err});
  }
  await ctx.close();
 }
 return JSON.stringify(rows);
}
