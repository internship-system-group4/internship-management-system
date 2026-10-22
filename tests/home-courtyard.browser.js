async page => {
 const base='http://localhost:57983';let checks=0;const errors=[];
 const check=(ok,message)=>{if(!ok)throw Error(message);checks++;};
 page.on('pageerror',e=>errors.push(e.message));page.on('console',m=>{if(m.type()==='error')errors.push(m.text());});
 const snap=()=>page.evaluate(()=>document.querySelector('[data-courtyard]').courtyardScene.snapshot());
 const wait=()=>page.waitForFunction(()=>!!document.querySelector('[data-courtyard]')?.courtyardScene);
 await page.context().clearCookies();await page.emulateMedia({reducedMotion:'no-preference'});
 await page.setViewportSize({width:1440,height:1000});await page.goto(base+'/Default.aspx');await wait();
 check(await page.locator('[data-courtyard-viewport] canvas').count()===1,'Actual WebGL canvas mounted');
 let a=await snap();await page.waitForTimeout(250);let b=await snap();
 check(b.angle<a.angle,'Wheel advances slowly around Z axle');
 check(JSON.stringify(a.architecture)===JSON.stringify(b.architecture),'Architecture remains stationary');
 check(b.triangles<30000&&b.calls<110,'Triangle and draw-call budget');
 check(b.textures>0&&b.geometries>0,'Actual GPU geometry and material textures');
 await page.locator('[data-courtyard-toggle]').click();a=await snap();await page.waitForTimeout(200);b=await snap();
 check(a.angle===b.angle&&a.draws===b.draws,'Pause stops motion and rendering');
 check(await page.locator('[data-courtyard-toggle]').getAttribute('aria-pressed')==='true','Pause state accessible');
 await page.locator('[data-courtyard-toggle]').press('Space');await page.waitForTimeout(100);check((await snap()).running,'Keyboard resumes');
 await page.locator('#internship-video').scrollIntoViewIfNeeded();await page.waitForFunction(()=>!document.querySelector('[data-courtyard]').courtyardScene.snapshot().visible);
 a=await snap();await page.waitForTimeout(150);b=await snap();check(a.draws===b.draws&&a.angle===b.angle,'Offscreen stops GPU loop');
 await page.locator('[data-courtyard-viewport]').scrollIntoViewIfNeeded();await page.waitForFunction(()=>document.querySelector('[data-courtyard]').courtyardScene.snapshot().running);
 check((await snap()).running,'Visible scene resumes');
 // Deterministic visibility-state delivery exercises the handler without relying on headless tab focus.
 await page.evaluate(()=>{Object.defineProperty(document,'hidden',{configurable:true,get:()=>true});document.dispatchEvent(new Event('visibilitychange'));});
 a=await snap();await page.waitForTimeout(150);b=await snap();check(!b.running&&a.draws===b.draws,'Hidden-document handler stops rendering');
 await page.evaluate(()=>{delete document.hidden;document.dispatchEvent(new Event('visibilitychange'));});
 check((await snap()).running,'Visibility handler resumes eligible scene');
 for(const width of [320,390,768,1440,2560]) {
  await page.setViewportSize({width,height:1000});await page.waitForTimeout(80);
  check(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1),'No page overflow at '+width);
  const s=await snap();check(s.width<=1200&&s.height<=1000,'Backing buffer capped at '+width);
  check(await page.locator('.home-hero-copy h1').isVisible()&&await page.locator('.home-hero-copy .public-button').isVisible(),'HTML title and CTA at '+width);
 }
 await page.evaluate(()=>window.testPhase='dynamic-reduced');await page.setViewportSize({width:1440,height:1000});await page.emulateMedia({reducedMotion:'reduce'});await page.waitForFunction(()=>document.querySelector('[data-courtyard]').courtyardScene.snapshot().state==='paused');
 a=await snap();await page.waitForTimeout(160);b=await snap();check(a.angle===b.angle&&!b.running,'Live reduced-motion setting pauses');
 await page.evaluate(()=>window.testPhase='reduced-reload');await page.reload();await wait();check((await snap()).state==='paused','Reduced motion starts static');
 await page.locator('[data-courtyard-toggle]').click();check((await snap()).running,'Explicit resume remains available under reduced motion');
 await page.locator('[data-courtyard-toggle]').click();
 await page.evaluate(()=>window.testPhase='screenshots');for(const width of [1440,768,390]) { await page.setViewportSize({width,height:1000});await page.evaluate(()=>scrollTo(0,0));await page.screenshot({path:'tests/artifacts/courtyard-home-'+width+'.png'}); }
 check(await page.locator('#opportunities').count()===1&&await page.locator('#internship-video').count()===1,'Opportunities and dedicated process video preserved');
 await page.locator('.home-hero-copy .public-text-link').click();check(new URL(page.url()).hash==='#how-it-works','Existing Home anchor navigation');
 await page.goto(base+'/Pages/Student/OpportunityDetails.aspx?id=internship-one');check(page.url().includes('/Account/Login.aspx'),'Full details stay protected');
 await page.goto(base+'/Pages/Student/Apply.aspx?opportunityId=internship-one');check(page.url().includes('/Account/Login.aspx'),'Applications stay protected');
 await page.goto(base+'/Default.aspx');await wait();
 await page.evaluate(()=>document.querySelector('[data-courtyard]').courtyardScene.dispose());
 a=await snap();await page.waitForTimeout(150);b=await snap();
 check(a.state==='disposed'&&!b.running&&a.draws===b.draws,'Disposal stops animation');
 check(await page.locator('[data-courtyard-viewport] canvas').count()===0,'Disposal removes canvas');
 check(b.geometries===0&&b.textures===0,'Disposal releases GPU resources');
 const context=await page.context().browser().newContext({viewport:{width:390,height:900},deviceScaleFactor:3});
 const p=await context.newPage();await p.goto(base+'/Default.aspx');await p.waitForFunction(()=>!!document.querySelector('[data-courtyard]')?.courtyardScene);
 check(await p.evaluate(()=>document.querySelector('[data-courtyard-viewport] canvas').width<=document.querySelector('[data-courtyard-viewport]').clientWidth*1.5+1),'High-DPR phone capped at 1.5');
 await p.evaluate(()=>document.querySelector('[data-courtyard-viewport] canvas').getContext('webgl2').getExtension('WEBGL_lose_context').loseContext());
 await p.waitForFunction(()=>document.querySelector('[data-courtyard]').dataset.sceneState==='fallback');
 check(await p.locator('.home-courtyard-photo').isVisible()&&await p.locator('[data-courtyard-viewport] canvas').count()===0,'Context loss returns photo');
 check(!(await p.locator('[data-courtyard-toggle]').isVisible()),'Context loss hides unusable control');
 await p.screenshot({path:'tests/artifacts/courtyard-fallback-mobile.png'});await context.close();
 const c2=await page.context().browser().newContext();const p2=await c2.newPage();
 await p2.addInitScript(()=>{const original=HTMLCanvasElement.prototype.getContext;HTMLCanvasElement.prototype.getContext=function(kind,...args){return /^webgl/.test(kind)?null:original.call(this,kind,...args);};});
 await p2.goto(base+'/Default.aspx');await p2.waitForFunction(()=>document.querySelector('[data-courtyard]').dataset.sceneState==='fallback');
 check(await p2.locator('.home-courtyard-photo').isVisible(),'WebGL unavailable photo fallback');
 check(await p2.locator('.home-hero-copy .public-button').isVisible(),'WebGL failure does not block CTA');await c2.close();
 const c3=await page.context().browser().newContext();const p3=await c3.newPage();await p3.route('**/courtyard-scene.js*',r=>r.abort());
 await p3.goto(base+'/Default.aspx');await p3.waitForFunction(()=>document.querySelector('[data-courtyard]').dataset.sceneState==='fallback');check(await p3.locator('.home-courtyard-photo').isVisible(),'Module load failure photo fallback');await c3.close();
 const c4=await page.context().browser().newContext({javaScriptEnabled:false,viewport:{width:390,height:900}});const p4=await c4.newPage();await p4.goto(base+'/Default.aspx');
 check(await p4.locator('.home-courtyard-photo').isVisible()&&await p4.locator('[data-courtyard-viewport] canvas').count()===0,'No-JS image fallback');
 check(await p4.locator('.home-hero-copy .public-button').isVisible()&&await p4.locator('#internship-video').count()===1,'No-JS content and navigation retained');await c4.close();
 check(errors.length===0,'No unexpected browser or console errors: '+errors.join(';'));
 await page.setViewportSize({width:1440,height:1000});await page.goto(base+'/Default.aspx');await wait();
 return {passed:checks,errors,viewports:[320,390,768,1440,2560],visibilityTest:'Deterministic document.hidden getter plus visibilitychange delivery; offscreen check uses real scrolling.'};
}

