async page => {
 const base=new URL(page.url()).origin,db='http://127.0.0.1:4912/firebase',path='/Pages/Account/Login.aspx';
 const browser=page.context().browser(),checks=[],errors=[];
 const check=(ok,name)=>{if(!ok)throw Error(name+' [after '+checks.at(-1)+']');checks.push(name);};
 const ctx=await browser.newContext({viewport:{width:1440,height:1000}}),p=await ctx.newPage();p.on('pageerror',e=>errors.push(e.message));
 const email=()=>p.getByLabel('Email address',{exact:true}),password=()=>p.getByLabel('Password',{exact:true}),button=()=>p.locator('[data-public-form] input[type=submit]');
 const fill=async(address,pass='Fixture-pass-2026')=>{await email().fill(address);await password().fill(pass);};
 await p.request.post(db+'/__reset');
 for(const [id,role] of [['academic-one',3],['coordinator-one',4],['unknown-one',99]])await p.request.put(db+'/users/'+id+'.json',{data:{Id:id,Role:role,FullName:'Synthetic UI fixture',IsActive:true,MustChangePassword:false}});
 await p.goto(base+path);await p.locator('[data-scene-ready]').waitFor();
 check(await p.locator('[data-login-campus]').getAttribute('data-visual-mode')==='3d'&&await p.locator('[data-campus-canvas] canvas').count()===1,'Progressive 3D checkpoint loads exactly one renderer');
 check(await p.locator('.login-campus-photo').evaluate(e=>e.naturalWidth===1080),'Existing campus photograph remains available as fallback');
 check(await p.locator('.public-password input').evaluate(e=>getComputedStyle(e).borderWidth==='0px'&&getComputedStyle(e).fontSize==='16px'),'Password field has one border and consistent text');
 const before=await p.evaluate(()=>document.querySelector('[data-login-campus]').campusScene.snapshot().camera);
 const box=await p.locator('[data-campus-canvas]').boundingBox();await p.mouse.move(box.x+box.width*.9,box.y+box.height*.7);await p.waitForTimeout(500);
 check(await p.evaluate(x=>Math.abs(document.querySelector('[data-login-campus]').campusScene.snapshot().camera[0]-x)>.03,before[0]),'Camera depth follows pointer smoothly');
 await p.locator('[data-campus-pause]').click();await p.waitForTimeout(100);const stopped=await p.evaluate(()=>document.querySelector('[data-login-campus]').campusScene.snapshot().draws);await p.waitForTimeout(200);
 check(await p.evaluate(n=>document.querySelector('[data-login-campus]').campusScene.snapshot().draws===n,stopped),'Pause stops ambient render work');
 await p.locator('[data-campus-pause]').click();
 await button().click();check(await email().getAttribute('aria-invalid')==='true'&&await password().getAttribute('aria-invalid')==='true','Empty fields have localized validation and focus');
 await fill('bad-address');await button().click();check((await p.locator('#emailError').innerText()).includes('valid'),'Invalid email is rejected before submission');
 await fill('student@campus.test');await p.locator('#toggleButton').click();check(await password().getAttribute('type')==='text'&&await p.locator('#toggleButton').getAttribute('aria-pressed')==='true','Password visibility remains accessible');await p.locator('#toggleButton').click();
 await email().focus();await p.keyboard.press('Tab');check(await password().evaluate(e=>document.activeElement===e),'Keyboard goes directly from email to password');await p.keyboard.press('Tab');check(await p.locator('#toggleButton').evaluate(e=>document.activeElement===e),'Password toggle follows the password field');await p.keyboard.press('Tab');check(await p.locator('[id$=lnkForgotPassword]').evaluate(e=>document.activeElement===e),'Recovery link follows the password controls');
 await Promise.all([p.waitForNavigation(),p.locator('[id$=lnkForgotPassword]').click()]);check(new URL(p.url()).pathname.endsWith('/ForgotPassword.aspx'),'Recovery navigation works');
 await p.goto(base+path);await fill('student@campus.test','wrong');await Promise.all([p.waitForNavigation(),button().click()]);
 check((await p.getByRole('alert').innerText()).includes('Incorrect email or password')&&await email().inputValue()==='student@campus.test'&&!await button().isDisabled(),'Authentication failure preserves email and allows retry');
 await fill('student@campus.test','wrong');await p.evaluate(()=>document.querySelector('form').addEventListener('submit',e=>e.preventDefault(),{once:true}));await button().click();
 check(await p.evaluate(()=>window.validateLogin())===false,'Duplicate submit remains blocked');
 await p.goto(base+path);
 for(const [address,role] of [['student','Student'],['company','Company'],['academic','Academic'],['coordinator','Coordinator']]) {
  await ctx.clearCookies();await p.goto(base+path+'?role=4&returnUrl=https://example.org');await fill(address+'@campus.test');
  const post=p.waitForResponse(r=>r.request().method()==='POST'&&r.url().includes(path));
  await button().click({noWaitAfter:true});const response=await post;
  check(response.status()===302&&response.headers().location==='/Pages/'+role+'/Dashboard.aspx'&&!response.headers().refresh,'Immediate server redirect to verified '+role+' dashboard, without presentation delay');
  await p.waitForURL('**/Pages/'+role+'/Dashboard.aspx');
 }
 await ctx.clearCookies();await p.goto(base+path+'?returnUrl='+encodeURIComponent('/Pages/Student/Apply.aspx?opportunityId=internship-one'));await fill('student@campus.test');
 const resume=p.waitForResponse(r=>r.request().method()==='POST'&&r.url().includes(path));await button().click({noWaitAfter:true});
 check((await resume).headers().location==='/Pages/Student/Apply.aspx?opportunityId=internship-one','Existing safe return to an internship application is preserved');
 await ctx.clearCookies();await p.goto(base+path);await fill('unknown@campus.test');await Promise.all([p.waitForNavigation(),button().click()]);
 check(new URL(p.url()).pathname===path&&await p.getByRole('alert').count()===1,'Unknown role is rejected by the unchanged server authorization');
 for(const lang of ['en','ar']) {
  await ctx.clearCookies();await ctx.addCookies([{name:'uims-lang',value:lang,url:base}]);await p.goto(base+path);
  for(const theme of ['light','dark']) {
   await p.evaluate(t=>window.UimsTheme.set(t),theme);
   for(const width of [1440,1024,768,390,320]) {
    await p.setViewportSize({width,height:width<500?844:1000});await p.goto(base+path);await p.locator('[data-scene-ready]').waitFor();await p.waitForTimeout(250);
    check(await p.locator('html').getAttribute('dir')===(lang==='ar'?'rtl':'ltr')&&await p.locator('html').getAttribute('data-theme')===theme,'Language, direction and saved theme: '+lang+'/'+theme+'/'+width);
    check(await p.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),'No horizontal overflow: '+lang+'/'+theme+'/'+width);
    if(width<500)check(await button().evaluate(e=>e.getBoundingClientRect().bottom<innerHeight),'Sign-in action stays in the first phone viewport: '+lang+'/'+theme+'/'+width);
    if([1440,390].includes(width))await p.screenshot({path:'tests/artifacts/login-security-'+lang+'-'+theme+'-'+width+'.png',fullPage:true,animations:'disabled'});
   }
  }
 }
 check(await p.evaluate(()=>!performance.getEntriesByType('resource').some(r=>/maplibre-gl/.test(r.name))),'Login does not load the unrelated footer map');
 await ctx.close();
 const reduced=await browser.newContext({reducedMotion:'reduce'}),r=await reduced.newPage();await r.goto(base+path);await r.locator('[data-scene-ready]').waitFor();
 check(await r.locator('.login-campus-photo').evaluate(e=>getComputedStyle(e).transform==='none')&&!await r.locator('[data-campus-pause]').isVisible(),'Reduced motion uses a static scene and hides ambient control');await reduced.close();
 const mob=await browser.newContext({viewport:{width:390,height:844},isMobile:true,hasTouch:true}),m=await mob.newPage();await m.goto(base+path);await m.locator('[data-scene-ready]').waitFor();
 check(await m.locator('[data-campus-canvas] canvas').count()===1&&await m.locator('[data-campus-pause]').isVisible(),'Touch devices retain a pause control for ambient motion');await m.screenshot({path:'tests/artifacts/login-security-phone.png',fullPage:true,animations:'disabled'});await mob.close();
 const nojs=await browser.newContext({javaScriptEnabled:false}),n=await nojs.newPage();await n.goto(base+path);await n.getByLabel('Email address',{exact:true}).fill('student@campus.test');await n.getByLabel('Password',{exact:true}).fill('Fixture-pass-2026');await n.locator('[data-public-form] input[type=submit]').click();await n.waitForURL('**/Pages/Student/Dashboard.aspx');check(true,'JavaScript-disabled server login still works');await nojs.close();
 const failed=await browser.newContext(),f=await failed.newPage();f.on('pageerror',e=>errors.push(e.message));await failed.route('**/Male_Adult_17_Animated.glb',route=>route.fulfill({status:404,contentType:'text/plain',body:''}));await f.goto(base+path);await f.getByLabel('Email address',{exact:true}).fill('student@campus.test');await f.getByLabel('Password',{exact:true}).fill('Fixture-pass-2026');await f.locator('[data-public-form] input[type=submit]').click();await f.waitForURL('**/Pages/Student/Dashboard.aspx');check(true,'Model failure cannot block real server login');await failed.close();
 check(errors.length===0,'No uncaught JavaScript errors: '+errors.join(' | '));
 return {passed:checks.length,checks};
}
