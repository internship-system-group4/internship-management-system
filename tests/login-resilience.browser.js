async page => {
 // Login scene resilience: photo/form fallback without WebGL or without the character model, sign-in that never waits on a
 // stalled model, a single model download (the preload is reused), and no ambient render loop under reduced motion.
 // Run against tests/Start-LoginTestHost.ps1 (57994) with the campus-login simulation (4910); uses the fixture student.
 const base='http://localhost:57994', path='/Pages/Account/Login.aspx', checks=[];
 const check=(ok,name,detail)=>{if(!ok)throw Error(name+(detail?': '+JSON.stringify(detail):''));checks.push(name);};
 const browser=page.context().browser();
 const photoVisible=p=>p.evaluate(()=>{const img=document.querySelector('.login-campus-photo');const s=getComputedStyle(img);return img.complete&&img.naturalWidth>0&&s.visibility!=='hidden'&&+s.opacity>.9;});
 async function typed(p){await p.locator('input[type=email]').fill('student@campus.test');return p.evaluate(()=>document.querySelector('[data-id-value]').textContent);}

 // 1. No WebGL: the scene reports a fallback, the photograph stays, the form works.
 {
  const ctx=await browser.newContext({viewport:{width:1440,height:900}});
  await ctx.addInitScript(()=>{const get=HTMLCanvasElement.prototype.getContext;HTMLCanvasElement.prototype.getContext=function(type,...rest){return /webgl/.test(type)?null:get.call(this,type,...rest);};});
  const p=await ctx.newPage();await p.goto(base+path);
  await p.waitForFunction(()=>document.querySelector('[data-login-campus]').dataset.sceneFallback==='true',null,{timeout:20000});
  check(await photoVisible(p)&&await typed(p)==='student@campus.test','Without WebGL the photograph stays and the ID card form still responds');
  await ctx.close();
 }
 // 2. Model download fails: same fallback.
 {
  const ctx=await browser.newContext({viewport:{width:1440,height:900}});
  await ctx.route('**/*.glb',route=>route.abort('failed'));
  const p=await ctx.newPage();await p.goto(base+path);
  await p.waitForFunction(()=>document.querySelector('[data-login-campus]').dataset.sceneFallback==='true',null,{timeout:20000});
  check(await photoVisible(p)&&await typed(p)==='student@campus.test','A failed model download keeps the photograph and a usable form');
  await ctx.close();
 }
 // 3. Model never arrives: a verified sign-in still reaches the portal within the safety cap.
 {
  await page.request.post('http://localhost:4910/firebase/__reset').catch(()=>{});
  const ctx=await browser.newContext({viewport:{width:1440,height:900}});
  await ctx.route('**/*.glb',()=>{/* never answered */});
  const p=await ctx.newPage();await p.goto(base+path);
  await p.locator('input[type=email]').fill('student@campus.test');await p.locator('input[type=password]').fill('Fixture-pass-2026');
  const t0=Date.now();await p.locator('[data-public-form] input[type=submit]').click();
  await p.waitForURL('**/Pages/Student/Dashboard.aspx',{timeout:15000});const waited=Date.now()-t0;
  check(waited<7000,'Sign-in with a stalled model reaches the portal within the safety cap',waited);
  await ctx.close();
 }
 // 4. One model download per page view (the low-priority preload is the request the scene uses), and the scene fades in.
 {
  const ctx=await browser.newContext({viewport:{width:1440,height:900}});
  const p=await ctx.newPage();let models=0;p.on('request',r=>{if(/\.glb/.test(r.url()))models++;});
  await p.goto(base+path);await p.locator('[data-scene-ready]').waitFor({timeout:30000});await p.waitForTimeout(1200);
  const canvas=await p.evaluate(()=>+getComputedStyle(document.querySelector('[data-campus-canvas] canvas')).opacity);
  check(models===1,'The character model is downloaded once',models);
  check(canvas===1&&!(await photoVisible(p)),'The scene crossfades in and the photograph is hidden afterwards');
  const scene=await p.evaluate(()=>document.querySelector('[data-login-campus]').campusScene.inspect());
  check(scene.drawCalls<130,'Static scenery is merged (draw calls)',scene.drawCalls);
  await ctx.close();
 }
 // 5. Reduced motion: one still frame, then no render loop.
 {
  const ctx=await browser.newContext({viewport:{width:1440,height:900},reducedMotion:'reduce'});
  const p=await ctx.newPage();await p.goto(base+path);await p.locator('[data-scene-ready]').waitFor({timeout:30000});await p.waitForTimeout(600);
  const a=await p.evaluate(()=>document.querySelector('[data-login-campus]').campusScene.inspect().draws);await p.waitForTimeout(1200);
  const b=await p.evaluate(()=>document.querySelector('[data-login-campus]').campusScene.inspect().draws);
  check(a===b,'Reduced motion leaves no ambient render loop running',[a,b]);
  await ctx.close();
 }
 return {passed:checks.length,checks};
}
