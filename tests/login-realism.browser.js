// Run with playwright-cli run-code --filename tests/login-realism.browser.js
// Start on a local UIMS URL. No credentials, POSTs, or production data are used.
async page => {
 const base=new URL(page.url()).origin,checks=[],errors=[];
 const check=(value,name)=>{if(!value)throw Error(name);checks.push(name);};
 const context=await page.context().browser().newContext({viewport:{width:1280,height:720},recordVideo:{dir:'tests/artifacts/login-motion',size:{width:1280,height:720}}});
 const p=await context.newPage();p.on('pageerror',e=>errors.push(e.message));
 await p.goto(base+'/Pages/Account/Login.aspx');
 await p.locator('[data-scene-ready]').waitFor();
 await p.evaluate(()=>window.dispatchEvent(new PageTransitionEvent('pagehide')));
 await p.setContent(`<style>body{margin:0}#root,[data-campus-canvas]{width:100vw;height:100vh}button{position:fixed;z-index:2}</style><div id="root" data-logo="${base}/Assets/images/gju-logo.png"><button data-campus-pause>Pause</button><div data-campus-canvas></div></div><script type="importmap">{"imports":{"three":"${base}/Assets/js/vendor/three.module.min.js"}}</script>`);
 await p.evaluate(async base=>{window.uimsT=k=>k;const m=await import(base+'/Assets/js/login-campus-scene.js?v=20261024-idcard-2');window.scene=await m.createCampusScene(document.querySelector('#root'),{reducedMotion:false});},base);
 const inspect=()=>p.evaluate(()=>window.scene.inspect());
 check((await inspect()).actors.every(a=>a.bones===80),'Both characters have independent 80-bone rigs');
 const staging=await inspect();check(staging.actors[0].role==='campus-security'&&staging.flags[0].name==='jordan-flag'&&staging.flags[1].name==='germany-flag'&&staging.flags.every(f=>f.visible)&&staging.flags[0].x>staging.flags[1].x,'Campus guard; Jordan flag on the visitor right, Germany on the left');
 // Poles stand in the planters: off the 8.8 m road (edge stones at |x|=4.66), in front of the sliding-leaf track (z=.5) and the piers.
 check(staging.poles.length===2&&staging.poles.every(pole=>Math.abs(pole.x)>5.2&&pole.z>1.4&&pole.z<3.7)&&staging.poles[0].x===-staging.poles[1].x,'Flagpoles balanced on both sides, clear of the road and the gate track');
 for(const state of ['idle','submitting','denied','success']){
  await p.evaluate(s=>window.scene.setState(s),state);await p.waitForTimeout(450);const s=await inspect();
  check(s.state===state&&s.leaves.join(',')==='-2.5,2.5'&&s.card.every(Number.isFinite),'Finite pose and closed gate before verified entry: '+state);
 }
 await p.locator('[data-campus-pause]').click();await p.waitForTimeout(800);const stopped=await inspect();await p.waitForTimeout(150);
 check((await inspect()).draws===stopped.draws,'Pause stops ambient rendering');
 await p.locator('[data-campus-pause]').click();await p.waitForTimeout(100);check((await inspect()).draws>stopped.draws,'Resume restarts rendering');
 await p.evaluate(()=>window.scene.setReducedMotion(true));await p.waitForTimeout(100);const reduced=await inspect();await p.waitForTimeout(150);
 check((await inspect()).draws===reduced.draws,'Reduced motion stops ambient rendering');
 const immediate=await p.evaluate(async()=>{const t=performance.now();await window.scene.enter();return performance.now()-t;});check(immediate<100,'Reduced-motion entry resolves immediately');
 await p.evaluate(()=>{window.scene.setReducedMotion(false);window.finished=false;window.veiled=false;window.scene.enter({onVeil:()=>window.veiled=true}).then(()=>window.finished=true);});
 await p.waitForTimeout(1400);const midway=await inspect();check(midway.fov===40&&midway.actors[1].position[2]<6.25&&Math.abs(midway.leaves[0])>7,'Gate opens and student walks with constant FOV');
 // The 4.0 s entry: the student reaches the gate line as the veil starts and steps through by the end.
 await p.waitForTimeout(2900);const through=await inspect();check(await p.evaluate(()=>window.finished&&window.veiled),'Entry finishes and requests the navigation veil');
 check(through.actors[1].position[2]<.6,'Student walks through the open gate before the hand-off');
 await p.screenshot({path:'tests/artifacts/login-realism-entry.png'});
 await p.evaluate(()=>document.querySelector('canvas').dispatchEvent(new Event('webglcontextlost',{cancelable:true})));const lost=await inspect();
 await p.evaluate(()=>window.scene.setState('idle'));await p.waitForTimeout(120);check((await inspect()).draws===lost.draws,'Context loss cannot restart rendering');
 await p.evaluate(()=>window.scene.dispose());check(await p.locator('canvas').count()===0,'Dispose removes the canvas');
 await context.close();
 const ui=await page.context().browser().newContext(),q=await ui.newPage();q.on('pageerror',e=>errors.push(e.message));
 for(const lang of ['en','ar']){
  await ui.addCookies([{name:'uims-lang',value:lang,url:base}]);
  for(const theme of ['light','dark'])for(const width of [1440,390]){
   await q.setViewportSize({width,height:width===390?844:1000});await q.goto(base+'/Pages/Account/Login.aspx');await q.locator('[data-scene-ready]').waitFor();await q.evaluate(t=>window.UimsTheme.set(t),theme);
   check(await q.locator('html').getAttribute('dir')===(lang==='ar'?'rtl':'ltr')&&await q.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),'Direction and overflow: '+lang+'/'+theme+'/'+width);
   check(await q.locator('[data-public-form] input[type=submit]').isVisible(),'Login action available: '+lang+'/'+theme+'/'+width);
   await q.screenshot({path:`tests/artifacts/login-realism-${lang}-${theme}-${width}.png`,fullPage:true});
  }
 }
 await q.goto(base+'/Pages/Account/Login.aspx');
 const email=q.locator('input[type=email]'),password=q.locator('input[autocomplete=current-password]'),preview=q.locator('[data-id-value]'),form=q.locator('[data-public-form]');
 await email.fill('demo@example.com');check(await preview.innerText()==='demo@example.com'&&await form.getAttribute('data-typing')==='true','Account line and typing feedback respond immediately');
 await password.fill('Synthetic-only-2026');check(await preview.innerText()==='••••••••'&&!await preview.innerText().then(t=>t.includes('Synthetic')),'Card preview never exposes password text or length');
 await q.locator('#toggleButton').click();await password.focus();check(await preview.innerText()==='••••••••','Password stays masked on the card when field visibility changes');
 await q.emulateMedia({reducedMotion:'reduce'});await email.fill('reduced@example.com');check(await preview.innerText()==='reduced@example.com'&&!await form.getAttribute('data-typing'),'Reduced motion updates text immediately without typing animation');
 await q.emulateMedia({reducedMotion:'no-preference'});await email.fill('');check(await preview.innerText()==='you@example.com','Clearing input restores the card placeholder');
 await ui.route('**/Male_Adult_17_Animated*.glb',route=>route.abort());await q.goto(base+'/Pages/Account/Login.aspx');await q.locator('[data-scene-fallback]').waitFor();
 check(await q.locator('[data-public-form] input[type=submit]').isVisible(),'Unavailable avatar leaves the form usable');
 await q.locator('[data-public-form] input[type=submit]').click();check(await q.locator('[aria-invalid=true]').count()===2,'Required-field validation works with the fallback');
 await ui.close();check(errors.length===0,'No uncaught JavaScript errors');
 return {passed:checks.length,checks};
}
