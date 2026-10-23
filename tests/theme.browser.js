async page => {
 // Light / Dark / System theme behaviour. Run against tests/Start-LoginTestHost.ps1 (57992) with the campus-login
 // simulation (4910). Only fixture data is touched; nothing is written to Firebase.
 const base='http://localhost:57992';
 let lastPassed='(none)';const checks=[];const check=(ok,name)=>{if(!ok)throw Error(name+' [after: '+lastPassed+']');checks.push(name);lastPassed=name;};
 const errors=[];const watch=p=>{p.on('pageerror',e=>errors.push(e.message));p.on('console',m=>{if(m.type()==='error')errors.push(m.text().slice(0,200));});};
 const browser=page.context().browser();
 const state=p=>p.evaluate(()=>{const r=document.documentElement;let stored;try{stored=localStorage.getItem('uims-theme');}catch(e){stored='unavailable';}
  return {theme:r.dataset.theme,bs:r.getAttribute('data-bs-theme'),pref:r.dataset.themePreference,scheme:r.style.colorScheme,stored,bg:getComputedStyle(document.body).backgroundColor};});
 const reveal=p=>p.evaluate(()=>{const animation=document.documentElement.getAnimations({subtree:true}).find(a=>a.effect&&a.effect.pseudoElement==='::view-transition-new(root)');if(!animation)return null;const frames=animation.effect.getKeyframes(),read=value=>{const m=/circle\(([\d.]+)px at ([\d.]+)px ([\d.]+)px\)/.exec(value||'');return m?{radius:Number(m[1]),x:Number(m[2]),y:Number(m[3])}:null;};return {from:read(frames[0].clipPath),to:read(frames[frames.length-1].clipPath),width:innerWidth,height:innerHeight};});
 // Records when data-theme first appears, to compare with the browser's first paint.
 const timing=()=>{window.__themeSetAt=null;new MutationObserver((m,o)=>{if(document.documentElement.hasAttribute('data-theme')){window.__themeSetAt=performance.now();o.disconnect();}}).observe(document,{attributes:true,subtree:true,attributeFilter:['data-theme']});};

 // 1. First visit: Light even though the OS prefers Dark.
 const ctx=await browser.newContext({viewport:{width:1440,height:900},colorScheme:'dark'});await ctx.addInitScript(timing);
 const p=await ctx.newPage();watch(p);
 const posts=[];p.on('request',r=>{if(r.method()==='POST'&&r.url().includes('localhost:57992'))posts.push(r.url());});
 await p.goto(base+'/Pages/Public/Contact.aspx');await p.waitForTimeout(500);
 let s=await state(p);
 check(s.theme==='light'&&s.bs==='light'&&s.pref==='light'&&s.scheme==='light'&&s.stored===null,'First visit is Light with an OS that prefers Dark');
 check(s.bg==='rgb(246, 248, 255)','Light keeps the original page background (#f6f8ff)');
 // 2. Menu button: keyboard opens on the checked item, arrows move, Enter chooses, focus returns, no submit.
 const toggle=p.locator('.public-theme-desktop [data-theme-toggle]');
 check(await toggle.getAttribute('aria-haspopup')==='menu'&&await toggle.getAttribute('aria-expanded')==='false'&&/Colour theme: Light/.test(await toggle.getAttribute('aria-label'))&&await toggle.getAttribute('type')==='button','Theme button: named, menu popup, type=button');
 const box=await toggle.boundingBox();check(box.width>=44&&box.height>=44,'Theme button is a 44px target');
 await toggle.focus();await p.keyboard.press('Enter');await p.waitForTimeout(100);
 check(await toggle.getAttribute('aria-expanded')==='true'&&await p.evaluate(()=>document.activeElement.getAttribute('data-theme-value'))==='light','Enter opens the menu on the current choice');
 check(await p.locator('.public-theme-desktop [role="menuitemradio"]').count()===3&&await p.locator('.public-theme-desktop [role="menuitemradio"][aria-checked="true"]').count()===1,'Three menu radio items, one checked');
 await p.keyboard.press('ArrowDown');check(await p.evaluate(()=>document.activeElement.getAttribute('data-theme-value'))==='dark','ArrowDown moves to Dark');
 await p.keyboard.press('End');check(await p.evaluate(()=>document.activeElement.getAttribute('data-theme-value'))==='system','End moves to System');
 await p.keyboard.press('Home');await p.keyboard.press('Escape');
 check(await toggle.getAttribute('aria-expanded')==='false'&&await p.evaluate(()=>document.activeElement.hasAttribute('data-theme-toggle'))&&(await state(p)).theme==='light','Escape closes without changing the theme and returns focus');
 await p.keyboard.press('ArrowDown');await p.keyboard.press('ArrowDown');
 await p.evaluate(()=>{window.__changing=false;window.__revealSeen=false;const item=document.activeElement,r=item.getBoundingClientRect();window.__expectedRevealOrigin={x:r.left+r.width/2,y:r.top+r.height/2};new MutationObserver((m,o)=>{const root=document.documentElement;if(root.classList.contains('uims-theme-changing'))window.__changing=true;if(root.classList.contains('uims-theme-reveal'))window.__revealSeen=true;}).observe(document.documentElement,{attributes:true,attributeFilter:['class']});});
 await p.keyboard.press('Enter');await p.waitForTimeout(60);
 const circle=await reveal(p),origin=await p.evaluate(()=>window.__expectedRevealOrigin),circleSeen=await p.evaluate(()=>window.__revealSeen);
 if(await p.evaluate(()=>typeof document.startViewTransition==='function')){
  check(circleSeen&&circle&&circle.from&&circle.to&&Math.abs(circle.from.x-origin.x)<1&&Math.abs(circle.from.y-origin.y)<1,'The circular reveal begins at the activated option center');
  const farthest=Math.hypot(Math.max(circle.from.x,circle.width-circle.from.x),Math.max(circle.from.y,circle.height-circle.from.y));
  check(circle.from.radius===0&&circle.to.radius>=farthest-1,'The reveal reaches every viewport corner');
 } else check(!circleSeen&&await p.evaluate(()=>document.documentElement.dataset.theme==='dark'&&document.documentElement.classList.contains('uims-theme-changing')),'Unsupported View Transitions: theme applies through the restrained fallback');
 check(!await p.evaluate(()=>window.__changing),'View Transition does not run the competing root colour fade');
 await p.waitForTimeout(400);s=await state(p);
 check(s.theme==='dark'&&s.bs==='dark'&&s.pref==='dark'&&s.scheme==='dark'&&s.stored==='dark','Choosing Dark applies and saves it');
 check(s.bg!=='rgb(246, 248, 255)'&&!await p.evaluate(()=>document.documentElement.classList.contains('uims-theme-changing')),'Dark background applied without the competing colour fade');
 await p.waitForTimeout(300);check(!await p.evaluate(()=>document.documentElement.classList.contains('uims-theme-reveal')),'Theme transition state cleans up after the reveal');
 check(await toggle.getAttribute('aria-expanded')==='false'&&await p.evaluate(()=>document.activeElement.hasAttribute('data-theme-toggle'))&&/Colour theme: Dark/.test(await toggle.getAttribute('aria-label')),'Menu closes, focus returns, the button names the new choice');
 check(posts.length===0&&!await p.locator('#MainContent_txtName').getAttribute('aria-invalid'),'Theme controls never submitted the form');
 await p.mouse.click(5,300);
 // 3. Reload and navigation: Dark is in place before the first paint.
 for(const route of ['/Pages/Public/Contact.aspx','/Default.aspx','/Pages/Public/About.aspx','/Pages/Account/Login.aspx']){
  await p.goto(base+route);await p.waitForTimeout(300);
  const t=await p.evaluate(()=>({set:window.__themeSetAt,paint:(performance.getEntriesByType('paint').find(e=>e.name==='first-paint')||{}).startTime,theme:document.documentElement.dataset.theme}));
  check(t.theme==='dark'&&t.set!==null&&(t.paint===undefined||t.set<=t.paint),'Dark before first paint on '+route+' (set '+(t.set||0).toFixed(1)+'ms, paint '+(t.paint||0).toFixed(1)+'ms)');
 }
 // 4. Cross-tab: a second tab follows a change made in the first.
 const q=await ctx.newPage();watch(q);await q.goto(base+'/Pages/Public/About.aspx');await q.waitForTimeout(300);
 check((await state(q)).theme==='dark','Second tab opens in Dark');
 await q.evaluate(()=>{window.__revealSeen=false;new MutationObserver(()=>{if(document.documentElement.classList.contains('uims-theme-reveal'))window.__revealSeen=true;}).observe(document.documentElement,{attributes:true,attributeFilter:['class']});});
 await p.goto(base+'/Pages/Public/Contact.aspx');await p.evaluate(()=>window.UimsTheme.set('light'));await q.waitForTimeout(500);
 check((await state(q)).theme==='light'&&(await state(q)).pref==='light'&&!await q.evaluate(()=>window.__revealSeen),'Other tab follows the saved preference without a viewport reveal');
 // 5. System follows the OS only while chosen.
 await p.evaluate(()=>{window.__revealSeen=false;new MutationObserver(()=>{if(document.documentElement.classList.contains('uims-theme-reveal'))window.__revealSeen=true;}).observe(document.documentElement,{attributes:true,attributeFilter:['class']});window.UimsTheme.set('system');});await p.waitForTimeout(200);
 check((await state(p)).theme==='dark'&&(await state(p)).pref==='system','System resolves to Dark when the OS is Dark');
 await p.emulateMedia({colorScheme:'light'});await p.waitForFunction(()=>document.documentElement.dataset.theme==='light',null,{timeout:3000}).catch(()=>{});
 check((await state(p)).theme==='light'&&(await state(p)).pref==='system'&&!await p.evaluate(()=>window.__revealSeen),'System follows OS changes without a viewport reveal');
 await p.evaluate(()=>window.UimsTheme.set('dark'));await p.emulateMedia({colorScheme:'dark'});await p.waitForTimeout(100);await p.emulateMedia({colorScheme:'light'});await p.waitForTimeout(300);
 check((await state(p)).theme==='dark','An OS change does not override an explicit Dark');
 await p.evaluate(()=>window.UimsTheme.set('light'));await p.emulateMedia({colorScheme:'dark'});await p.waitForTimeout(300);
 check((await state(p)).theme==='light','An OS change does not override an explicit Light');
 await ctx.close();

 // 6. Invalid and unavailable storage.
 const bad=await browser.newContext({viewport:{width:1440,height:900},colorScheme:'dark'});await bad.addInitScript(()=>{try{if(!sessionStorage.getItem('seeded')){localStorage.setItem('uims-theme','purple');sessionStorage.setItem('seeded','1');}}catch(e){}});
 const b=await bad.newPage();watch(b);await b.goto(base+'/Pages/Public/About.aspx');await b.waitForTimeout(300);
 check((await state(b)).theme==='light'&&(await state(b)).pref==='light','Invalid stored value falls back to Light');await bad.close();
 const blocked=await browser.newContext({viewport:{width:1440,height:900}});await blocked.addInitScript(()=>{Object.defineProperty(window,'localStorage',{get(){throw new DOMException('blocked','SecurityError');}});});
 const k=await blocked.newPage();watch(k);await k.goto(base+'/Pages/Public/Contact.aspx');await k.waitForTimeout(300);
 check((await state(k)).theme==='light','Unavailable storage: page loads in Light');
 await k.evaluate(()=>window.UimsTheme.set('dark'));check((await state(k)).theme==='dark','Unavailable storage: switching still works for this page');await blocked.close();

 // 7. Mobile navigation: the radio group inside the menu.
 const mob=await browser.newContext({viewport:{width:390,height:844},isMobile:true,hasTouch:true,colorScheme:'light'});const m=await mob.newPage();watch(m);
 await m.goto(base+'/Pages/Public/About.aspx');await m.waitForTimeout(400);
 check(!await m.locator('.public-theme-desktop').isVisible(),'Phone: the header button gives way to the menu control');
 await m.locator('.public-menu-toggle').tap();await m.waitForTimeout(300);
 const radios=m.locator('.public-theme-mobile [role="radio"]');
 check(await radios.count()===3&&await m.locator('.public-theme-mobile [role="radiogroup"]').getAttribute('aria-labelledby')!==null&&await radios.nth(0).getAttribute('aria-checked')==='true','Phone menu: labelled radio group, Light checked');
 check((await radios.nth(1).boundingBox()).height>=44,'Phone menu: 44px choices');
 await m.evaluate(()=>{window.__revealSeen=false;const r=document.querySelector('.public-theme-mobile [data-theme-value="dark"]').getBoundingClientRect();window.__expectedRevealOrigin={x:r.left+r.width/2,y:r.top+r.height/2};new MutationObserver(()=>{if(document.documentElement.classList.contains('uims-theme-reveal'))window.__revealSeen=true;}).observe(document.documentElement,{attributes:true,attributeFilter:['class']});});
 await radios.nth(1).tap();await m.waitForTimeout(60);
 const mobileCircle=await reveal(m),mobileOrigin=await m.evaluate(()=>window.__expectedRevealOrigin);
 if(await m.evaluate(()=>typeof document.startViewTransition==='function'))check(await m.evaluate(()=>window.__revealSeen)&&mobileCircle&&Math.abs(mobileCircle.from.x-mobileOrigin.x)<1&&Math.abs(mobileCircle.from.y-mobileOrigin.y)<1,'Phone reveal starts at the tapped Light/Dark/System choice');
 await m.waitForTimeout(700);check((await state(m)).theme==='dark'&&await radios.nth(1).getAttribute('aria-checked')==='true','Tapping Dark applies it');
 await radios.nth(0).tap();await m.waitForTimeout(700);check((await state(m)).theme==='light','Phone Dark to Light selection works');
 await radios.nth(1).tap();await m.waitForTimeout(700);check((await state(m)).theme==='dark','Phone Light to Dark selection works');
 await radios.nth(1).focus();
 await m.evaluate(()=>{window.__revealSeen=false;const r=document.querySelector('.public-theme-mobile [data-theme-value="system"]').getBoundingClientRect();window.__expectedRevealOrigin={x:r.left+r.width/2,y:r.top+r.height/2};});
 await m.keyboard.press('ArrowRight');await m.waitForFunction(()=>document.documentElement.dataset.themePreference==='system');await m.waitForTimeout(60);
 const systemCircle=await reveal(m),systemOrigin=await m.evaluate(()=>window.__expectedRevealOrigin);
 if(await m.evaluate(()=>typeof document.startViewTransition==='function'))check(await m.evaluate(()=>window.__revealSeen)&&systemCircle&&Math.abs(systemCircle.from.x-systemOrigin.x)<1&&Math.abs(systemCircle.from.y-systemOrigin.y)<1,'System selection also reveals from its focused radio when it changes appearance');
 check((await state(m)).pref==='system'&&(await state(m)).theme==='light'&&await m.evaluate(()=>document.activeElement.getAttribute('data-theme-value'))==='system','Arrow keys move and select in the radio group');
 await m.evaluate(()=>window.UimsTheme.set('dark'));
 for(const route of ['/Default.aspx','/Pages/Public/Contact.aspx','/Pages/Public/PoweredBy.aspx','/Pages/Account/Login.aspx']){await m.goto(base+route);await m.waitForTimeout(500);check(await m.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),'Phone Dark: no horizontal overflow on '+route);}
 await mob.close();

 // 7b. Without View Transitions, the selector uses the current restrained change path.
 const fallback=await browser.newContext({viewport:{width:1280,height:800},colorScheme:'light'});await fallback.addInitScript(()=>Object.defineProperty(document,'startViewTransition',{value:undefined,configurable:true}));
 const f=await fallback.newPage();watch(f);await f.goto(base+'/Pages/Public/About.aspx');await f.waitForTimeout(300);
 const fallbackToggle=f.locator('.public-theme-desktop [data-theme-toggle]');await fallbackToggle.click();await f.locator('.public-theme-desktop [data-theme-value="dark"]').click();await f.waitForTimeout(60);
 check((await state(f)).theme==='dark'&&(await state(f)).stored==='dark'&&await f.evaluate(()=>document.documentElement.classList.contains('uims-theme-changing'))&&!await f.evaluate(()=>document.documentElement.classList.contains('uims-theme-reveal')),'No View Transition support: Dark saves and uses the restrained fallback');
 await f.waitForTimeout(220);check(!await f.evaluate(()=>document.documentElement.classList.contains('uims-theme-changing')),'Fallback transition state cleans up');await fallback.close();

 // 8. Portal: header menu, full postback keeps the theme, charts recolour without re-rendering.
 const portal=await browser.newContext({viewport:{width:1440,height:900}});const w=await portal.newPage();watch(w);
 await w.goto(base+'/__fixture.aspx?user=coordinator-one');await w.goto(base+'/Pages/Coordinator/Dashboard.aspx');await w.waitForTimeout(800);
 const ptoggle=w.locator('.uims-topbar [data-theme-toggle]');
 check(await ptoggle.isVisible()&&await ptoggle.getAttribute('type')==='button','Portal header has the theme button');
 const before=await w.evaluate(()=>{const line=document.querySelector('.ws-reference svg line');window.__chartNode=line;return line?getComputedStyle(line).stroke:null;});
 await ptoggle.click();await w.locator('.uims-topbar [data-theme-value="dark"]').click();await w.waitForTimeout(400);
 const after=await w.evaluate(()=>{const line=document.querySelector('.ws-reference svg line');return {same:line===window.__chartNode,stroke:line?getComputedStyle(line).stroke:null};});
 check((await state(w)).theme==='dark'&&before!==null&&after.same&&after.stroke!==before,'Charts recolour in place: same SVG nodes, new gridline colour');
 await w.goto(base+'/Pages/Coordinator/ContactMessages.aspx');await w.waitForTimeout(500);
 const searchButton=w.locator('input[type="submit"], button[type="submit"]').filter({hasText:/Search/}).first();
 const submit=(await searchButton.count())?searchButton:w.locator('input[type="submit"][value*="Search"]').first();
 await Promise.all([w.waitForLoadState('load'),submit.click()]);await w.waitForTimeout(600);
 check((await state(w)).theme==='dark'&&await w.evaluate(()=>!!document.querySelector('[data-theme-control][data-theme-ready]')),'Full postback keeps Dark and re-binds the selector once');
 check(await w.evaluate(()=>document.querySelectorAll('.uims-topbar [data-theme-control]').length)===1,'One selector per header (no duplicates)');
 await portal.close();

 // 9. Reduced motion: no transition class.
 const calm=await browser.newContext({viewport:{width:1440,height:900},reducedMotion:'reduce'});const c=await calm.newPage();watch(c);await c.goto(base+'/Pages/Public/About.aspx');
 await c.evaluate(()=>{window.__changing=false;new MutationObserver(()=>{if(document.documentElement.classList.contains('uims-theme-changing'))window.__changing=true;}).observe(document.documentElement,{attributes:true});});
 await c.evaluate(()=>window.UimsTheme.set('dark'));await c.waitForTimeout(300);check(!await c.evaluate(()=>window.__changing)&&(await state(c)).theme==='dark','Reduced motion: the change is immediate');
 await calm.close();

 // 10. Without JavaScript: Light, selector hidden, page usable.
 const nojs=await browser.newContext({javaScriptEnabled:false,viewport:{width:1440,height:900},colorScheme:'dark'});const n=await nojs.newPage();await n.goto(base+'/Pages/Public/Contact.aspx');
 check(await n.evaluate(()=>getComputedStyle(document.body).backgroundColor)==='rgb(246, 248, 255)'&&!await n.locator('[data-theme-control]').first().isVisible(),'Without JavaScript: Light, selector hidden');
 await nojs.close();
 check(errors.length===0,'No uncaught errors: '+errors.join(' | '));
 return {passed:checks.length,checks};
}
