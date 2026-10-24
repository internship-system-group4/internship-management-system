async page => {
 // Light/Dark lifecycle and opened components. Complements tests/theme.browser.js (toggle, reveal, persistence, tabs).
 //  - The saved theme is applied before first paint, and survives full postbacks, the language switch, sign-in and sign-out.
 //  - Repeated toggling raises exactly one uims:themechange per change (no duplicate handlers after postback).
 //  - Workspace charts repaint in the new theme without a reload.
 //  - Components that only exist once opened (notification menu, modals, mobile drawer, compact sidebar, validation
 //    messages) have no light surfaces in Dark and keep AA text contrast in both themes.
 // Run against tests/Start-LoginTestHost.ps1 (57992) with the campus-login simulation (4910).
 // Writes nothing to the simulation: searches and filters only, validation is triggered with empty forms.
 const base='http://localhost:57992', browser=page.context().browser();
 const checks=[];const check=(ok,name,detail)=>{if(!ok)throw Error(name+(detail?': '+JSON.stringify(detail).slice(0,400):''));checks.push(name);};
 // Scoped audit: AA text contrast against the composited background, and (Dark) light boxes larger than 1500px².
 const audit=(p,selector)=>p.evaluate(sel=>{
  const parse=s=>{const m=/rgba?\(([\d.]+)[ ,]+([\d.]+)[ ,]+([\d.]+)(?:[ ,/]+([\d.]+%?))?/.exec(s||'');if(!m)return null;const a=m[4]===undefined?1:m[4].endsWith('%')?parseFloat(m[4])/100:+m[4];return [+m[1],+m[2],+m[3],a];};
  const lin=c=>{c/=255;return c<=.04045?c/12.92:Math.pow((c+.055)/1.055,2.4);},L=c=>.2126*lin(c[0])+.7152*lin(c[1])+.0722*lin(c[2]);
  const over=(t,u)=>[t[0]*t[3]+u[0]*(1-t[3]),t[1]*t[3]+u[1]*(1-t[3]),t[2]*t[3]+u[2]*(1-t[3]),1];
  const bgOf=el=>{const layers=[];for(let e=el;e;e=e.parentElement){const s=getComputedStyle(e);if(/url\(/.test(s.backgroundImage))return null;const c=parse(s.backgroundColor);if(c&&c[3]>0){layers.push(c);if(c[3]>=.98)break;}}
   let b=layers.length&&layers[layers.length-1][3]>=.98?layers.pop():[255,255,255,1];for(let i=layers.length-1;i>=0;i--)b=over(layers[i],b);return b;};
  const shown=e=>{const r=e.getBoundingClientRect();if(r.width<2||r.height<2)return false;for(let x=e;x;x=x.parentElement){const s=getComputedStyle(x);if(s.display==='none'||s.visibility==='hidden'||+s.opacity===0)return false;}return true;};
  const dark=document.documentElement.dataset.theme==='dark',bad=[],light=[];
  document.querySelectorAll(sel).forEach(root=>[root,...root.querySelectorAll('*')].forEach(e=>{
   if(e.closest('svg,img,[class*=logo]'))return;const s=getComputedStyle(e),c=parse(s.backgroundColor),r=e.getBoundingClientRect();
   if(dark&&c&&c[3]>.45&&L(c)>.45&&r.width*r.height>=1500&&shown(e))light.push(e.className+' '+s.backgroundColor);
   const field=['INPUT','TEXTAREA','SELECT'].includes(e.tagName)&&!['hidden','checkbox','radio','file','range','color'].includes(e.type);
   if(!(field?(e.value||e.placeholder):[...e.childNodes].some(n=>n.nodeType===3&&n.textContent.trim().length>1))||!shown(e)||e.closest('[disabled],.disabled'))return;
   const fg=parse(s.color),bg=bgOf(e);if(!fg||!bg)return;const col=fg[3]<1?over(fg,bg):fg,x=L(col),y=L(bg),ratio=(Math.max(x,y)+.05)/(Math.min(x,y)+.05);
   const size=parseFloat(s.fontSize),large=size>=24||(+s.fontWeight>=700&&size>=18.66);
   if(ratio<(large?3:4.5))bad.push((e.className||e.tagName)+' "'+(field?(e.value||e.placeholder):e.textContent).trim().slice(0,30)+'" '+ratio.toFixed(2));
  }));
  return {bad,light};
 },selector);
 const theme=p=>p.evaluate(()=>document.documentElement.dataset.theme);
 const open=async(theme,w=1440,h=900)=>{const ctx=await browser.newContext({viewport:{width:w,height:h},reducedMotion:'reduce',isMobile:w<500,hasTouch:w<500});
  await ctx.addInitScript(t=>{if(t&&!sessionStorage.getItem('seeded')){try{localStorage.setItem('uims-theme',t);sessionStorage.setItem('seeded','1');}catch(e){}}
   // First paint: the theme attribute must already be on <html> when the body is parsed.
   document.addEventListener('readystatechange',()=>{if(document.readyState==='interactive')window.__firstTheme=document.documentElement.dataset.theme;},{once:true});
   window.__changes=0;document.addEventListener('uims:themechange',()=>window.__changes++);},theme);
  const p=await ctx.newPage();const errors=[];p.on('pageerror',e=>errors.push(e.message));return {ctx,p,errors};};

 // 1. Sign-in, postback, language switch, sign-out keep the saved Dark preference.
 {
  const {ctx,p,errors}=await open('dark');
  await p.goto(base+'/Pages/Account/Login.aspx');
  check(await p.evaluate(()=>window.__firstTheme)==='dark','Dark is applied before the page is parsed (no Light flash)');
  await p.locator('input[type=email]').first().fill('coordinator@campus.test');await p.locator('input[type=password]').first().fill('Fixture-pass-2026');
  await Promise.all([p.waitForURL('**/Pages/Coordinator/**',{timeout:30000}),p.locator('[data-public-form] input[type=submit]').click()]);
  check(await theme(p)==='dark'&&await p.evaluate(()=>window.__firstTheme)==='dark','Sign-in lands on the portal in Dark');
  await p.goto(base+'/Pages/Coordinator/Students.aspx');
  const search=p.locator('input[type=submit],button[type=submit]').filter({hasText:/Search/}).first();
  const [post]=await Promise.all([p.waitForRequest(r=>r.method()==='POST'&&r.isNavigationRequest()),search.click()]);await p.waitForLoadState('load');
  check(!!post&&await theme(p)==='dark'&&await p.evaluate(()=>window.__firstTheme)==='dark','Full postback keeps Dark from first paint');
  await p.locator('[data-lang-switch]:visible').first().click();await p.waitForLoadState('load');
  check(await p.evaluate(()=>document.documentElement.dir)==='rtl'&&await theme(p)==='dark','Switching to Arabic (RTL) keeps Dark');
  await p.locator('[data-lang-switch]:visible').first().click();await p.waitForLoadState('load');
  const before=await p.evaluate(()=>window.__changes);
  for(let i=0;i<6;i++){await p.locator('[data-theme-toggle]:visible').first().click();await p.waitForTimeout(60);}
  const after=await p.evaluate(()=>({n:window.__changes,t:document.documentElement.dataset.theme,saved:localStorage.getItem('uims-theme'),pressed:document.querySelector('[data-theme-toggle]').getAttribute('aria-pressed')}));
  check(after.n-before===6&&after.t==='dark'&&after.saved==='dark'&&after.pressed==='true','Six toggles after a postback raise six changes and end in Dark',after);
  await Promise.all([p.waitForLoadState('load'),p.locator('.student-logout a:visible').first().click()]);
  check(await theme(p)==='dark','Sign-out keeps the saved preference');
  check(!errors.length,'No page errors through the lifecycle',errors);
  await ctx.close();
 }

 // 2. Charts repaint on theme change without a reload.
 {
  const {ctx,p}=await open('light');
  await p.goto(base+'/__fixture.aspx?user=student-one');await p.goto(base+'/Pages/Student/Dashboard.aspx');await p.waitForSelector('[data-reference-analytics] [data-mark]',{timeout:15000}).catch(()=>{});await p.waitForTimeout(500);
  // Charts are DOM marks styled by tokens (bars, donut segments, gridlines, labels): read what is painted.
  const paint=()=>p.evaluate(()=>[...document.querySelectorAll('[data-reference-analytics] *')].filter(e=>e.getBoundingClientRect().width>0).slice(0,200).map(e=>{const s=getComputedStyle(e);return s.backgroundColor+s.backgroundImage.slice(0,60)+s.color+s.borderTopColor+s.fill+s.stroke;}).join('|'));
  const light=await paint();check(light.length>0,'Student dashboard renders chart marks');
  await p.locator('[data-theme-toggle]:visible').first().click();await p.waitForFunction(()=>document.documentElement.dataset.theme==='dark');await p.waitForTimeout(400);
  check(await paint()!==light,'Chart marks, axes and labels change with the theme without reload');
  const a=await audit(p,'[data-reference-analytics]');check(!a.bad.length&&!a.light.length,'Chart text and surfaces pass in Dark',a);
  await ctx.close();
 }

 // 3. Components that only exist once opened, in both themes.
 for(const t of ['light','dark']){
  const {ctx,p,errors}=await open(t);
  await p.goto(base+'/__fixture.aspx?user=supervisor-one');await p.goto(base+'/Pages/Company/Dashboard.aspx');
  await p.locator('.notice-bell summary:visible').first().click();await p.waitForSelector('.notice-bell[open] .notice-panel');await p.waitForTimeout(300);
  let a=await audit(p,'.notice-bell[open] .notice-panel');check(!a.bad.length&&!a.light.length,t+': notification panel',a);
  await p.locator('.notice-bell summary:visible').first().click();
  await p.locator('.uims-sidebar-pin').click();await p.waitForTimeout(250);
  a=await audit(p,'.uims-sidebar');check(!a.bad.length&&!a.light.length,t+': pinned sidebar',a);
  await p.goto(base+'/Pages/Company/Account.aspx');
  await p.locator('[data-bs-target="#editProfileModal"]').click();await p.waitForSelector('#editProfileModal.show');await p.waitForTimeout(300);
  a=await audit(p,'#editProfileModal .modal-content');check(!a.bad.length&&!a.light.length,t+': edit profile modal',a);
  await p.goto(base+'/Pages/Company/EvaluationReport.aspx');
  for(const id of ['scoresModal','feedbackModal','draftsModal']){
   await p.evaluate(id=>bootstrap.Modal.getOrCreateInstance(document.getElementById(id)).show(),id);await p.waitForSelector('#'+id+'.show');await p.waitForTimeout(300);
   a=await audit(p,'#'+id+' .modal-content');check(!a.bad.length&&!a.light.length,t+': '+id,a);
   await p.evaluate(id=>bootstrap.Modal.getInstance(document.getElementById(id)).hide(),id);await p.waitForTimeout(350);
  }
  // Validation states: empty public forms.
  await p.goto(base+'/Pages/Public/Contact.aspx');
  await p.locator('[data-public-form] input[type=submit],[data-public-form] button[type=submit]').first().click();await p.waitForTimeout(400);
  a=await audit(p,'[data-public-form]');check(!a.bad.length&&!a.light.length,t+': contact form with validation messages',a);
  await p.goto(base+'/Pages/Account/ForgotPassword.aspx');
  await p.locator('input[type=submit],button[type=submit]').first().click();await p.waitForTimeout(400);
  a=await audit(p,'main, .public-auth');check(!a.bad.length&&!a.light.length,t+': password recovery with validation',a);
  check(!errors.length,t+': no page errors in components',errors);
  await ctx.close();
  // Phone: the student drawer.
  const m=await open(t,390,844);
  await m.p.goto(base+'/__fixture.aspx?user=student-one');await m.p.goto(base+'/Pages/Student/Dashboard.aspx');
  await m.p.locator('.student-nav-toggle').click();await m.p.waitForTimeout(400);
  a=await audit(m.p,'#studentSidebar');check(!a.bad.length&&!a.light.length,t+': phone navigation drawer',a);
  await m.ctx.close();
 }
 return {passed:checks.length,checks};
}
