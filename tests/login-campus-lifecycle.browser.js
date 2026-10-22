async page => {
 const base='http://localhost:57992',path='/Pages/Account/Login.aspx';let endpoint;
 const checks=[];const check=(ok,name)=>{if(!ok)throw Error(name);checks.push(name);};
 await page.context().clearCookies();await page.emulateMedia({reducedMotion:'no-preference'});
 await page.exposeFunction('recordCampusEndpoint',value=>{endpoint=value;});
 // Observe the real rendered geometry without adding a debug interface to the app.
 await page.route('**/login-campus-scene.js',async route=>{
  const response=await route.fetch();let source=await response.text();
  source=source.replace('return {\n  setState(value)', 'window.__campusReview={scene,camera,leaves,guard,visitor};\n return {\n  setState(value)');
  source=source.replace('if(progress===1){', 'if(progress===1){window.recordCampusEndpoint({cameraZ:camera.position.z,leafX:leaves.map(leaf=>leaf.position.x),duration:now-entryStart,portalX:gate.parts.get("limestone-portal").position.x});');
  await route.fulfill({response,body:source});
 });
 await page.goto(base+path);await page.waitForFunction(()=>!!window.__campusReview);
 const original=await page.evaluate(()=>window.__campusReview.leaves.map(leaf=>leaf.position.x));
 check(original[0]===-2.5&&original[1]===2.5,'Actual closed leaf positions');
 await page.evaluate(()=>document.querySelector('form').addEventListener('submit',e=>e.preventDefault(),{once:true}));
 await page.getByLabel('Email address',{exact:true}).fill('student@campus.test');await page.getByLabel('Password',{exact:true}).fill('Fixture-pass-2026');
 await page.locator('[data-public-form] input[type=submit]').click();
 await page.waitForFunction(()=>document.querySelector('[data-login-campus]').dataset.state==='submitting');
 // Poses ease toward their targets; wait for the restrained gesture to settle.
 await page.waitForFunction(()=>window.__campusReview.visitor.arms[1].rotation.x<-.9);
 const pending=await page.evaluate(()=>({leaves:window.__campusReview.leaves.map(leaf=>leaf.position.x),arm:window.__campusReview.visitor.arms[1].rotation.x}));
 check(JSON.stringify(pending.leaves)===JSON.stringify(original)&&pending.arm<-.5,'Present pass while actual gates stay closed');
 await page.evaluate(()=>window.dispatchEvent(new Event('pageshow')));
 await page.locator('[data-public-form] input[type=submit]').click();await page.waitForURL('**/Pages/Student/Dashboard.aspx');
 check(endpoint&&endpoint.cameraZ<.5&&endpoint.leafX.every(x=>Math.abs(x)>7)&&endpoint.portalX===0,'Camera crosses gate plane, leaves clear passage, portal stationary');
 check(endpoint.duration>=1250&&endpoint.duration<1500,'Measured entry animation 1.25–1.5 seconds');
 await page.context().clearCookies();await page.goto(base+path);await page.waitForSelector('[data-scene-ready]');
 await page.evaluate(()=>window.dispatchEvent(new PageTransitionEvent('pagehide',{persisted:true})));
 check(await page.locator('[data-campus-canvas] canvas').count()===0&&await page.locator('.login-campus-photo').isVisible(),'Pagehide disposes canvas and exposes photo');
 await page.evaluate(()=>window.dispatchEvent(new PageTransitionEvent('pageshow',{persisted:true})));
 await page.waitForSelector('[data-scene-ready]');check(await page.locator('[data-campus-canvas] canvas').count()===1,'Persisted pageshow reconstructs exactly one canvas');
 await page.locator('[data-campus-pause]').click();check(await page.locator('[data-campus-pause]').getAttribute('aria-pressed')==='true','Restored pause control works');
 await page.evaluate(()=>{const canvas=document.querySelector('canvas');const gl=canvas.getContext('webgl2');gl.getExtension('WEBGL_lose_context').loseContext();});
 await page.waitForFunction(()=>!document.querySelector('[data-login-campus]').hasAttribute('data-scene-ready'));
 check(await page.locator('.login-campus-photo').isVisible()&&!await page.locator('[data-campus-pause]').isVisible(),'Actual WebGL context loss shows photographic fallback');
 await page.unroute('**/login-campus-scene.js');
 return {passed:checks.length,checks,endpoint};
}
