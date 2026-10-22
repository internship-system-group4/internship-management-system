async page => {
 // Run against tests/Start-LoginTestHost.ps1 (port 57992) using the repository roster.
 const base='http://localhost:57992',url=base+'/Pages/Public/PoweredBy.aspx';
 const team=[
  ['osama-banihani','Osama Banihani','Developer','osamabanihani124@gmail.com','https://github.com/osamabanihani','https://www.linkedin.com/in/osama-banihani-/',null,'Osama.jpg'],
  ['nada-alawneh','Nada Alawneh','Developer','nadaalawneh504@gmail.com','https://github.com/Nada-Alawneh','https://www.linkedin.com/in/nada-alawneh/',null,'Nada.jpg'],
  ['sara-aldoulat','Sara Aldoulat','QA','saraaldoulat2749@gmail.com','https://github.com/saraaldoulat2749-art',null,'https://saraaldoulat2749-art.github.io/Project1/','Sara%20Aldoulat.jpg'],
  ['saja-diabat','Saja Diabat','Developer','sajadiabat9@gmail.com','https://github.com/sajadiabat9-ui','https://www.linkedin.com/in/saja-diabat-585943380/',null,'Saja%20Diabat.jpg'],
  ['ahmad-bani-hamad','Ahmad Bani Hamad','Scrum Master','ahmad100.fa100@gmail.com','https://github.com/ahmadfa100','https://www.linkedin.com/in/ahmad-faisal-dev/',null,'Ahmad.jpg'],
  ['fatima-tawalbeh','Fatima Ehab Tawalbeh','Developer','fatimatawalbeh9@gmail.com','https://github.com/fatimaT2023','https://www.linkedin.com/in/fatima-tawalbeh/',null,'Fatima%20Tawalbeh.jpg'],
  ['sara-alrjoub','Sara Alrjoub','Product Owner','sararjoub31@gmail.com','https://github.com/sararjoub','https://www.linkedin.com/in/sara-al-rjoub-666aa22a6/',null,'Sara%20Al%20Rjoub.jpg']
 ];
 const checks=[];const check=(ok,name)=>{if(!ok)throw Error(name);checks.push(name);};
 const errors=[],warnings=[],models=new Map();const watch=p=>{p.on('pageerror',e=>errors.push(e.message));p.on('console',m=>{if(m.type()==='error')errors.push(m.text());if(m.type()==='warning')warnings.push(m.text());});p.on('response',r=>{if(r.url().endsWith('.glb'))models.set(r.url().split('/').pop(),r.status());});};watch(page);
 const root=p=>p.locator('[data-team-experience]');
 const ready=async p=>p.waitForFunction(()=>document.querySelector('[data-team-experience]').dataset.mode==='ready',null,{timeout:20000});
 const camera=async (p,state)=>p.waitForFunction(s=>document.querySelector('[data-team-experience]').dataset.camera===s,state,{timeout:6000});
 const toggle=p=>p.getByRole('button',{name:'Find a team member'});
 const choose=async (p,name)=>{if(await toggle(p).getAttribute('aria-expanded')!=='true')await toggle(p).click();await p.locator('#teamFinderList').getByRole('button',{name:new RegExp('^'+name)}).click();};

 await page.context().clearCookies();await page.emulateMedia({reducedMotion:'no-preference'});await page.setViewportSize({width:1440,height:900});
 await page.goto(url);await ready(page);await camera(page,'overview');
 // Full-page composition: one canvas, no visible roster grid, footer after the experience.
 check(await page.locator('[data-hall-canvas] canvas').count()===1,'One canvas');
 check(models.size===10&&[...models.values()].every(s=>s===200||s===304)&&!warnings.some(w=>w.includes('Seated figures unavailable')),'Ten seated Rocketbox figures load on desktop');
 check(!await page.locator('.team-roster').isVisible()&&await page.locator('.team-roster-section').isHidden(),'No visible team grid under the scene');
 const box=await root(page).boundingBox();check(Math.abs(box.height-900)<2&&box.x===0&&box.width===1440,'Experience fills the viewport edge to edge');
 const footerTop=await page.locator('footer').evaluate(f=>f.getBoundingClientRect().top+scrollY);check(footerTop>=box.y+box.height-1,'Footer follows the experience without overlap');
 // Team figures follow the roster's Character; seats are unchanged.
 const expectSeat={'osama-banihani':'L3-7','nada-alawneh':'C2-2','sara-aldoulat':'R3-2','saja-diabat':'L5-8','ahmad-bani-hamad':'C4-5','fatima-tawalbeh':'R5-3','sara-alrjoub':'C6-9'};
 const markerData=await page.$$eval('.team-label',l=>l.map(m=>({key:m.dataset.key,name:m.textContent,figure:m.dataset.figure,seat:m.dataset.seat})));
 for(const m of markerData){
  const male=m.key==='ahmad-bani-hamad'||m.key==='osama-banihani';
  check(male?/^Male_Adult_/.test(m.figure):/^Female_Adult_/.test(m.figure),m.name+' uses a '+(male?'male':'female')+' figure ('+m.figure+')');
  check(m.figure!=='Female_Adult_06'&&m.figure!=='Male_Adult_18','No inferred religious or hood-up attire for '+m.name);
  check(m.seat===expectSeat[m.key],m.name+' keeps seat '+expectSeat[m.key]);
 }
 // Name markers: all seven visible on the desktop overview, none overlapping.
 const boxes=await page.$$eval('.team-label:not([hidden])',l=>l.map(m=>{const r=m.getBoundingClientRect();return [r.left,r.top,r.right,r.bottom,m.textContent];}));
 check(boxes.length===7,'All seven name markers visible on desktop: '+boxes.map(b=>b[4]).join(', '));
 check(boxes.every((a,i)=>boxes.every((b,j)=>i===j||a[2]<=b[0]||b[2]<=a[0]||a[3]<=b[1]||b[3]<=a[1])),'Name markers do not overlap');
 check(await page.locator('.team-labels').getAttribute('aria-hidden')==='true','Markers are decorative duplicates for assistive technology');
 check(await page.getByRole('heading',{level:1}).innerText()==='Meet the team'&&(await page.locator('.team-eyebrow').innerText()).toLowerCase()==='powered by','Discreet Powered by / Meet the team title');
 // Finder lists all seven, in roster order, with equal treatment.
 await toggle(page).click();check(await toggle(page).getAttribute('aria-expanded')==='true','Finder opens');
 const names=await page.locator('#teamFinderList button').evaluateAll(b=>b.map(x=>x.querySelector('.team-finder-text span').textContent));
 check(JSON.stringify(names)===JSON.stringify(team.map(t=>t[1])),'Finder lists the seven members in order');
 check(await page.evaluate(()=>document.activeElement.closest('#teamFinderList')!==null),'Focus moves into the finder');
 await page.keyboard.press('ArrowDown');check(await page.evaluate(()=>document.activeElement.textContent.includes('Nada Alawneh')),'Arrow keys move through names');
 await page.keyboard.press('Escape');check(await toggle(page).getAttribute('aria-expanded')==='false'&&await toggle(page).evaluate(e=>e===document.activeElement),'Escape closes the finder and restores focus');
 // Each member: profile content, links, photo, focus, seat and camera.
 for(const [i,[key,name,role,email,github,linkedIn,portfolio,photo]] of team.entries()){
  const started=Date.now();await choose(page,name);await camera(page,'member:'+key);const took=Date.now()-started;
  const profile=page.locator('[data-team-profile]');
  check(await profile.isVisible()&&await profile.getAttribute('role')==='dialog'&&(await page.locator('#teamProfileName').innerText())===name,'Profile dialog for '+name);
  check(await page.locator('#teamProfileName').evaluate(e=>e===document.activeElement),'Focus moves to '+name+' in the profile');
  check((await page.locator('[data-team-profile-count]').innerText()).toLowerCase()===('team member '+(i+1)+' of 7'),'Position shown for '+name);
  check(await profile.locator('.team-member-role').innerText()===role,'Role for '+name);
  check(await profile.locator('.team-email').getAttribute('href')==='mailto:'+email,'Email for '+name);
  const links=await profile.locator('.team-links a').evaluateAll(a=>a.map(x=>[x.getAttribute('href'),x.target,x.rel]));
  const expected=[github,linkedIn,portfolio].filter(Boolean);
  check(JSON.stringify(links.map(l=>l[0]))===JSON.stringify(expected)&&links.every(l=>l[1]==='_blank'&&l[2].includes('noopener')),'Profile links for '+name);
  await page.waitForFunction(()=>{const i=document.querySelector('[data-team-profile] .team-portrait img');return i&&i.complete&&i.naturalWidth>0;});
  check((await profile.locator('.team-portrait img').getAttribute('src')).endsWith('/team/small/'+photo),'Photo for '+name);
  check(took<3000,'Camera settles on '+name+' ('+took+' ms)');
  await page.keyboard.press('Escape');
  check(await profile.isHidden()&&await toggle(page).evaluate(e=>e===document.activeElement),'Escape closes '+name+' and restores focus to the finder');
 }
 // Keyboard focus in the finder emphasizes that member in the hall; markers hide while the camera moves.
 await page.locator('[data-team-overview]').click();await camera(page,'overview');
 await toggle(page).click();await page.locator('#teamFinderList button').nth(2).focus();
 check((await page.locator('.team-label.is-active').allInnerTexts()).includes('Sara Aldoulat'),'Keyboard focus in the finder emphasizes the member');
 await page.keyboard.press('Escape');
 await page.locator('.team-label',{hasText:'Saja Diabat'}).click();
 check(await page.locator('.team-labels').evaluate(l=>l.classList.contains('is-moving')),'Markers step aside during camera moves');
 await camera(page,'member:saja-diabat');check(await page.locator('#teamProfileName').innerText()==='Saja Diabat','Clicking a name marker opens that member');
 check((await page.locator('.team-label.is-active').allInnerTexts()).includes('Saja Diabat'),'Selected member marker is emphasized');
 await page.keyboard.press('Escape');
 // Previous/next wrap, and interruption: a second selection mid-move wins.
 await choose(page,'Sara Alrjoub');await camera(page,'member:sara-alrjoub');
 await page.locator('[data-team-next]').click();await camera(page,'member:osama-banihani');check(await page.locator('#teamProfileName').innerText()==='Osama Banihani','Next wraps to the first member');
 await page.locator('[data-team-prev]').click();await camera(page,'member:sara-alrjoub');check(await page.locator('#teamProfileName').innerText()==='Sara Alrjoub','Previous wraps to the last member');
 await page.locator('[data-team-next]').click();await page.waitForTimeout(250);await page.locator('[data-team-next]').click();
 await camera(page,'member:nada-alawneh');check(await page.locator('#teamProfileName').innerText()==='Nada Alawneh','Interrupted camera move settles on the latest member');
 // Links stay usable: pointer can travel into the open profile.
 await page.locator('[data-team-profile] .team-email').hover();check(await page.locator('[data-team-profile]').isVisible(),'Profile stays open while the pointer moves into it');
 await page.screenshot({path:'tests/artifacts/team-hall-selected.png'});
 await page.locator('[data-team-close]').click();check(await page.locator('[data-team-profile]').isHidden(),'Close button closes the profile');
 check(await page.locator('[data-team-overview]').isVisible(),'View full hall offered after focusing a member');
 await page.locator('[data-team-overview]').click();await camera(page,'overview');check(await page.locator('[data-team-overview]').isHidden(),'View full hall restores the overview');
 await page.screenshot({path:'tests/artifacts/team-hall-overview.png'});
 // Hover and click in the hall: find highlighted seats by scanning; ordinary students show nothing.
 const stage=await page.locator('[data-hall-canvas]').boundingBox(),hovered=new Map();
 for(let y=stage.y+stage.height*.36;y<stage.y+stage.height*.72&&hovered.size<7;y+=11)for(let x=stage.x+500;x<stage.x+stage.width-40&&hovered.size<7;x+=11){
  await page.mouse.move(x,y);if(await page.locator('[data-team-hover]').isVisible()){const n=await page.locator('[data-team-hover] strong').innerText();if(!hovered.has(n))hovered.set(n,{x,y,role:await page.locator('[data-team-hover] span').innerText()});}
 }
 check(hovered.size>=3,'Hover labels found on highlighted seats: '+[...hovered.keys()].join(', '));
 check([...hovered].every(([n,v])=>team.some(t=>t[1]===n&&t[2]===v.role)),'Hover labels show the correct name and role');
 const [hoverName,spot]=[...hovered][0];await page.mouse.move(spot.x,spot.y);await page.mouse.click(spot.x,spot.y);
 await camera(page,'member:'+team.find(t=>t[1]===hoverName)[0]);check(await page.locator('#teamProfileName').innerText()===hoverName,'Click on a seat opens that member: '+hoverName);
 await page.keyboard.press('Escape');await page.locator('[data-team-overview]').click();await camera(page,'overview');
 // Keyboard-only path through the page controls.
 await toggle(page).focus();await page.keyboard.press('Enter');await page.keyboard.press('Enter');
 await camera(page,'member:osama-banihani');check(await page.locator('#teamProfileName').innerText()==='Osama Banihani','Keyboard opens a profile from the finder');
 await page.keyboard.press('Tab');check(await page.evaluate(()=>!!document.activeElement.closest('[data-team-profile]')),'Tab moves through the profile');
 check(await page.evaluate(()=>getComputedStyle(document.activeElement).outlineStyle!=='none'),'Visible focus in the profile');
 await page.keyboard.press('Escape');
 for(const width of [1440,768]){await page.setViewportSize({width,height:900});await page.waitForTimeout(150);check(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),'No overflow at '+width);}
 // Phone: bottom sheet, touch selection, no overflow.
 const phone=await page.context().browser().newContext({viewport:{width:390,height:844},hasTouch:true,isMobile:true});const mobile=await phone.newPage();watch(mobile);
 models.clear();await mobile.goto(url);await ready(mobile);await camera(mobile,'overview');
 check(models.size===5,'Phones load the lighter five-figure cast');
 await mobile.screenshot({path:'tests/artifacts/team-hall-390.png'});
 const mstage=await mobile.locator('[data-hall-canvas]').boundingBox();let tapSpot=null,tapName=null;
 for(let y=mstage.y+mstage.height*.3;y<mstage.y+mstage.height*.75&&!tapSpot;y+=7)for(let x=mstage.x+6;x<mstage.x+mstage.width-6&&!tapSpot;x+=7){await mobile.mouse.move(x,y);if(await mobile.locator('[data-team-hover]').isVisible()){tapSpot={x,y};tapName=await mobile.locator('[data-team-hover] strong').innerText();}}
 await mobile.mouse.move(1,1);check(!!tapSpot,'A team seat is reachable on a phone');
 await mobile.touchscreen.tap(tapSpot.x,tapSpot.y);await mobile.waitForSelector('[data-team-profile]:not([hidden])');
 check(await mobile.locator('#teamProfileName').innerText()===tapName,'Tap opens '+tapName);
 const sheet=await mobile.locator('[data-team-profile]').boundingBox();check(Math.abs(sheet.y+sheet.height-844)<2&&sheet.width>=389,'Profile is a bottom sheet on phones');
 await mobile.waitForFunction(()=>document.querySelector('[data-team-experience]').dataset.camera.startsWith('member:'));
 await mobile.screenshot({path:'tests/artifacts/team-hall-390-selected.png'});
 check(await mobile.locator('[data-team-close]').boundingBox().then(b=>b.width>=40&&b.height>=40),'Phone close control is a 40px+ target');
 await mobile.locator('[data-team-close]').click();
 for(const width of [390,320]){await mobile.setViewportSize({width,height:740});await mobile.waitForTimeout(150);check(await mobile.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),'No overflow at '+width);}
 await phone.close();
 // Reduced motion: no entrance flight, immediate focus.
 const calm=await page.context().browser().newContext({viewport:{width:1440,height:900},reducedMotion:'reduce'});const still=await calm.newPage();watch(still);
 await still.goto(url);await ready(still);await camera(still,'overview');
 const t0=Date.now();await choose(still,'Saja Diabat');await camera(still,'member:saja-diabat');check(Date.now()-t0<600,'Reduced motion moves immediately');
 await calm.close();
 // Lifecycle: hidden page disposes, persisted return rebuilds exactly one canvas.
 await page.setViewportSize({width:1440,height:900});await page.goto(url);await ready(page);
 await page.evaluate(()=>dispatchEvent(new PageTransitionEvent('pagehide',{persisted:true})));check(await page.locator('[data-hall-canvas] canvas').count()===0,'Pagehide releases the renderer');
 await page.evaluate(()=>dispatchEvent(new PageTransitionEvent('pageshow',{persisted:true})));await ready(page);check(await page.locator('[data-hall-canvas] canvas').count()===1,'Persisted return rebuilds one canvas');
 const broken=await page.context().browser().newContext({viewport:{width:1440,height:900}});await broken.route('**/*.glb',r=>r.abort());const bp=await broken.newPage();
 await bp.goto(url);await ready(bp);check(await bp.locator('[data-hall-canvas] canvas').count()===1,'Missing figure models fall back to simple figures, hall still ready');await broken.close();
 const before=errors.length;
 // Failure paths end in the readable list, never a blank screen.
 const fails=[
  ['WebGL unavailable',ctx=>ctx.addInitScript(()=>{const o=HTMLCanvasElement.prototype.getContext;HTMLCanvasElement.prototype.getContext=function(t,...a){return /webgl/.test(t)?null:o.call(this,t,...a);};}),true],
  ['Scene module fails to load',ctx=>ctx.route('**/powered-by-hall.js*',r=>r.abort()),true]
 ];
 for(const [label,setup,failed] of fails){
  const ctx=await page.context().browser().newContext({viewport:{width:1440,height:900}});await setup(ctx);const p=await ctx.newPage();
  await p.goto(url);await p.waitForFunction(()=>document.querySelector('[data-team-experience]').dataset.mode==='fallback',null,{timeout:20000});
  check(await p.locator('.team-roster').isVisible()&&await p.locator('.team-member').count()===7&&await p.locator('.team-failure').isVisible()===failed,label+': failure message and full team list');
  check(await p.locator('.team-member .team-email').count()===7,label+': emails remain available');
  if(label==='WebGL unavailable')await p.screenshot({path:'tests/artifacts/team-hall-fallback.png',fullPage:true});
  await ctx.close();
 }
 const nojs=await page.context().browser().newContext({javaScriptEnabled:false,viewport:{width:1440,height:900}});const plain=await nojs.newPage();
 await plain.goto(url);check(await plain.locator('.team-roster').isVisible()&&await plain.locator('.team-member').count()===7&&!await plain.locator('.team-failure').isVisible()&&await plain.locator('[data-hall-canvas] canvas').count()===0,'Without JavaScript the team list shows without an error');
 await nojs.close();
 check(errors.slice(0,before).length===0,'No console errors: '+errors.slice(0,before).join(' | '));
 return {passed:checks.length,checks};
}
