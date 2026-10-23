async page => {
 const base=new URL(page.url()).origin,path='/Pages/Account/Login.aspx',checks=[];
 const check=(ok,name)=>{if(!ok)throw Error(name);checks.push(name);};
 const snapshot=()=>page.evaluate(()=>document.querySelector('[data-login-campus]').campusScene.snapshot());
 await page.setViewportSize({width:1440,height:1000});await page.goto(base+path);await page.locator('[data-scene-ready]').waitFor();
 const root=page.locator('[data-login-campus]'),pause=page.locator('[data-campus-pause]');
 await page.evaluate(()=>document.querySelector('[data-public-form]').dataset.submitting='true');await page.waitForTimeout(450);
 const pending=await snapshot();check(pending.state==='submitting'&&pending.leaves.join(',')==='-2.5,2.5','Pending authentication never opens the security gate');
 await page.evaluate(()=>delete document.querySelector('[data-public-form]').dataset.submitting);await page.waitForTimeout(100);check((await snapshot()).state==='idle','Cancelled checking returns to idle');
 await page.evaluate(()=>window.dispatchEvent(new PageTransitionEvent('pagehide',{persisted:true})));
 check(await page.locator('[data-campus-canvas] canvas').count()===0&&!await root.getAttribute('data-initialized'),'Pagehide disposes renderer and exposes fallback');
 for(let i=0;i<2;i++){
  await page.evaluate(()=>window.dispatchEvent(new PageTransitionEvent('pageshow',{persisted:true})));await page.locator('[data-scene-ready]').waitFor();
  check(await page.locator('[data-campus-canvas] canvas').count()===1,'Restoration creates exactly one scene: '+i);
  await pause.click();check((await snapshot()).paused,'Restored pause has one handler: '+i);await pause.click();
  if(i===0)await page.evaluate(()=>window.dispatchEvent(new PageTransitionEvent('pagehide',{persisted:true})));
 }
 await page.emulateMedia({reducedMotion:'reduce'});await page.waitForTimeout(120);const before=await snapshot();await page.waitForTimeout(160);const after=await snapshot();
 check(before.reduced&&before.draws===after.draws&&!await pause.isVisible(),'Runtime reduced-motion change stops rendering');
 await page.emulateMedia({reducedMotion:'no-preference'});await page.waitForTimeout(180);check(await pause.isVisible()&&(await snapshot()).draws>after.draws,'Ambient motion can resume');
 await page.setViewportSize({width:1024,height:768});await page.waitForTimeout(100);check(await page.locator('[data-campus-canvas] canvas').count()===1,'Resize preserves one renderer');
 await page.getByLabel('Email address',{exact:true}).fill('student@campus.test');await page.locator('.public-menu-toggle').click();await page.waitForTimeout(250);await page.evaluate(()=>window.confirm=()=>false);const initial=page.url();await page.locator('[data-lang-switch]:visible').click();check(page.url()===initial&&await page.getByLabel('Email address',{exact:true}).inputValue()==='student@campus.test','Language-switch cancellation preserves unsaved login input');
 await page.evaluate(()=>{const c=document.querySelector('[data-campus-canvas] canvas');c.getContext('webgl2').getExtension('WEBGL_lose_context').loseContext();});await page.waitForTimeout(200);
 check(!await root.getAttribute('data-scene-ready')&&await root.getAttribute('data-visual-mode')==='photo'&&!await pause.isVisible(),'Real WebGL context loss returns to campus photograph');
 return {passed:checks.length,checks};
}
