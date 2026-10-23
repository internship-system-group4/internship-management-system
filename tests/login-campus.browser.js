async page => {
 const base='http://localhost:57992',db='http://127.0.0.1:4910/firebase';
 const checks=[];const check=(ok,name)=>{if(!ok)throw Error(name);checks.push(name);};
 const errors=[];page.on('pageerror',error=>errors.push(error.message));
 const path='/Pages/Account/Login.aspx';
 const email=()=>page.getByLabel('Email address',{exact:true}),password=()=>page.getByLabel('Password',{exact:true});
 const button=()=>page.locator('[data-public-form] input[type=submit]');
 const fill=async(address,pass='Fixture-pass-2026')=>{await email().fill(address);await password().fill(pass);};
 await page.request.post(db+'/__reset');
 for(const [id,role] of [['academic-one',3],['coordinator-one',4],['unknown-one',99]])
  await page.request.put(db+'/users/'+id+'.json',{data:{Id:id,Role:role,FullName:'Synthetic test account',IsActive:true,MustChangePassword:false}});
 await page.context().clearCookies();await page.setViewportSize({width:1440,height:1000});await page.goto(base+path);
 await page.waitForSelector('[data-scene-ready]');
 check(await page.locator('canvas').count()===1,'One progressively loaded canvas');
 await button().click();check(await email().getAttribute('aria-invalid')==='true','Empty email validation');
 check(await password().getAttribute('aria-invalid')==='true','Empty password validation');
 await fill('bad-address');await button().click();check((await page.locator('#emailError').innerText()).includes('valid'),'Invalid email validation');
 await fill('student@campus.test');await page.locator('#toggleButton').click();
 check(await password().getAttribute('type')==='text'&&await page.locator('#toggleButton').getAttribute('aria-pressed')==='true','Accessible show password');
 await page.locator('#toggleButton').click();check(await password().getAttribute('type')==='password','Hide password');
 await page.getByRole('link',{name:'Forgot password?'}).click();check(page.url().endsWith('/Account/ForgotPassword.aspx'),'Recovery navigation');
 // Do not submit recovery: no email delivery is exercised.
 await page.goto(base+path);await fill('student@campus.test','wrong');
 await page.evaluate(()=>document.querySelector('form').addEventListener('submit',event=>event.preventDefault(),{once:true}));
 await button().click();
 check(await page.evaluate(()=>window.validateLogin())===false,'Duplicate submit validator blocked');
 await page.evaluate(()=>window.dispatchEvent(new Event('pageshow')));
 const failResponse=page.waitForResponse(r=>r.url().endsWith(path)&&r.request().method()==='POST');
 await button().click({noWaitAfter:true});
 await failResponse;await page.waitForLoadState('domcontentloaded');
 check((await page.getByRole('alert').innerText()).includes('Incorrect email or password'),'Generic authentication failure');
 check(await email().inputValue()==='student@campus.test','Email preserved after failure');
 check(!await button().isDisabled()&&!await page.locator('[data-entering]').count(),'Failure restores retry and leaves gate closed');
 for(const [address,destination] of [['student','Student'],['company','Company'],['academic','Academic'],['coordinator','Coordinator']]) {
  await page.context().clearCookies();await page.goto(base+path+'?role=4&returnUrl=https://example.org');await fill(address+'@campus.test');
  const responsePromise=page.waitForResponse(r=>r.url().includes(path)&&r.request().method()==='POST');
  await button().click({noWaitAfter:true});const response=await responsePromise;const html=await response.text();
  check(response.status()===200&&html.includes('data-destination="/Pages/'+destination+'/Dashboard.aspx"'),'Server-confirmed destination '+destination);
  check(!html.includes('local-fixture-token')&&!html.includes('local-fixture-refresh')&&!html.includes('Fixture-pass-2026'),'No credentials or tokens emitted '+destination);
  check(response.headers()['refresh']==='3; url=/Pages/'+destination+'/Dashboard.aspx','Server redirect fallback '+destination);
  if(address==='student') {
   await page.waitForSelector('[data-entering]');
   await page.screenshot({path:'tests/artifacts/login-verified-success.png'});
  }
  await page.waitForURL('**/Pages/'+destination+'/Dashboard.aspx');check(true,'Actual protected redirect '+destination);
 }
 await page.context().clearCookies();await page.goto(base+path);await fill('unknown@campus.test');await button().click();
 check(page.url().includes(path)&&await page.getByRole('alert').count()===1&&!await page.locator('[data-entering]').count(),'Unknown role cannot enter');
 await page.emulateMedia({reducedMotion:'reduce'});await page.goto(base+path);await page.waitForSelector('[data-scene-ready]');
 check(await page.locator('[data-campus-animation]').inputValue()==='0'&&!await page.locator('[data-campus-pause]').isVisible(),'Reduced motion static mode');
 await fill('student@campus.test');await button().click();await page.waitForURL('**/Pages/Student/Dashboard.aspx');check(true,'Reduced motion immediate server redirect');
 await page.emulateMedia({reducedMotion:'no-preference'});await page.context().clearCookies();
 await page.route('**/login-campus-scene.js',r=>r.abort());await page.goto(base+path);await page.waitForSelector('[data-scene-fallback]');
 check(await page.locator('.login-campus-photo').isVisible(),'Image fallback when scene fails');
 await fill('student@campus.test');await button().click();await page.waitForURL('**/Pages/Student/Dashboard.aspx');check(true,'Scene failure still redirects');await page.unroute('**/login-campus-scene.js');
 await page.context().clearCookies();
 await page.route('**/login-campus-scene.js',r=>r.fulfill({contentType:'text/javascript',body:'export async function createCampusScene(){return {setState(){},setReducedMotion(){},dispose(){},enter(){throw new Error("Injected animation failure");}}}'}));
 await page.goto(base+path);await fill('student@campus.test');await button().click();await page.waitForURL('**/Pages/Student/Dashboard.aspx');check(true,'Animation exception still redirects');await page.unroute('**/login-campus-scene.js');
 await page.context().clearCookies();
 const nojs=await page.context().browser().newContext({javaScriptEnabled:false});const plain=await nojs.newPage();
 await plain.goto(base+path);await plain.getByLabel('Email address',{exact:true}).fill('student@campus.test');await plain.getByLabel('Password',{exact:true}).fill('Fixture-pass-2026');await plain.locator('[data-public-form] input[type=submit]').click();
 await plain.waitForURL('**/Pages/Student/Dashboard.aspx');check(true,'No JavaScript real server login');await nojs.close();
 for(const width of [1440,768,390]) {
  await page.setViewportSize({width,height:width===390?844:1000});await page.goto(base+path);await page.waitForSelector('[data-scene-ready]');
  check(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),'No overflow '+width);
  await page.screenshot({path:'tests/artifacts/login-'+width+'.png',fullPage:true});
 }
 await page.getByLabel('Email address',{exact:true}).focus();await page.keyboard.press('Tab');
 check(await password().evaluate(el=>el===document.activeElement),'Keyboard email to password');
 await page.keyboard.press('Tab');check(await page.locator('#toggleButton').evaluate(el=>el===document.activeElement),'Keyboard password toggle');
 check(errors.length===0,'No JavaScript errors: '+errors.join(','));
 return {passed:checks.length,checks};
}
