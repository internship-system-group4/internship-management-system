async page => {
 const base='http://localhost:57983',db='http://localhost:4902/firebase';let checks=0;
 const check=(ok,message)=>{if(!ok)throw Error(message);checks++;};
 const errors=[],consoleErrors=[];page.on('pageerror',e=>errors.push(e.message));page.on('console',m=>{if(m.type()==='error')consoleErrors.push(m.text());});
 const get=async path=>(await page.request.get(db+'/'+path+'.json')).json();
 const count=async()=>Object.keys(await get('ContactMessages')||{}).length;
 const routes=[['home','/Default.aspx'],['about','/Pages/Public/About.aspx'],['contact','/Pages/Public/Contact.aspx'],['login','/Pages/Account/Login.aspx'],['recovery','/Pages/Account/ForgotPassword.aspx'],['denied','/Pages/Public/AccessDenied.aspx']];
 await page.context().clearCookies();await page.request.post(db+'/__reset');
 for(const width of [1440,768,390,320])for(const [name,path] of routes){
  await page.setViewportSize({width,height:1000});const response=await page.goto(base+path);
  await page.evaluate(()=>Promise.all(document.getAnimations().map(a=>a.finished)));
  check(response.status()===200,'Renders '+name+' '+width);
  check(await page.locator('h1').count()===1,'One h1 '+name+' '+width);
  check(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),'No overflow '+name+' '+width);
  check(await page.locator('.public-header').count()===1&&await page.locator('.public-footer').count()===1,'Shared shell '+name);
  check(await page.locator('.uims-stub').count()===0,'No placeholders '+name);
  if(width!==320)await page.screenshot({path:'tests/artifacts/public-after-'+name+'-'+width+'.png',fullPage:true});
 }
 await page.setViewportSize({width:390,height:900});await page.goto(base+'/Default.aspx');
 await page.keyboard.press('Tab');check(await page.locator('.public-skip').evaluate(el=>el===document.activeElement),'Skip first');
 await page.keyboard.press('Enter');check(await page.locator('#public-content').evaluate(el=>el===document.activeElement),'Skip targets main');
 const menu=page.locator('.public-menu-toggle');await menu.click();
 check(await menu.getAttribute('aria-expanded')==='true','Mobile expansion');
 await page.keyboard.press('Tab');check(await page.locator('#publicNav a').first().evaluate(el=>el===document.activeElement),'Keyboard nav order');
 await page.keyboard.press('Escape');check(await menu.getAttribute('aria-expanded')==='false'&&await menu.evaluate(el=>el===document.activeElement),'Escape focus return');
 await menu.click();await page.locator('#publicNav a').filter({hasText:'How it works'}).click();
 check(page.url().endsWith('#how-it-works')&&await menu.getAttribute('aria-expanded')==='false','Anchor closes menu');
 await page.goto(base+'/Pages/Account/Login.aspx');
 await page.getByRole('button',{name:'Login',exact:true}).click();
 check(await page.getByLabel('Email address',{exact:true}).getAttribute('aria-invalid')==='true','Login required validation');
 check(await page.getByLabel('Email address',{exact:true}).evaluate(el=>el===document.activeElement),'Invalid field focused');
 await page.getByLabel('Password',{exact:true}).fill('Example-password');
 await page.getByRole('button',{name:'Show password'}).click();
 check(await page.getByLabel('Password',{exact:true}).getAttribute('type')==='text','Show password');
 check(await page.getByRole('button',{name:'Hide password'}).getAttribute('aria-pressed')==='true','Toggle state');
 await page.getByRole('button',{name:'Hide password'}).click();
 check(await page.getByLabel('Password',{exact:true}).getAttribute('type')==='password','Hide password');
 await page.getByRole('link',{name:'Forgot password?',exact:true}).click();
 await page.getByRole('button',{name:'Send Reset Link'}).click();
 check(await page.getByLabel('Email address',{exact:true}).getAttribute('aria-invalid')==='true','Recovery required validation');
 await page.goto(base+'/Pages/Public/Contact.aspx');await page.getByRole('button',{name:'Send message'}).click();
 check(await page.getByLabel('Full name *',{exact:true}).getAttribute('aria-invalid')==='true','Contact required validation');
 check(await count()===0,'Invalid form writes nothing');
 async function fillContact(){
  await page.getByLabel('Full name *',{exact:true}).fill('أسامة بني هاني');
  await page.getByLabel('Email address *',{exact:true}).fill('osama@example.com');
  await page.getByLabel('Subject *',{exact:true}).fill('Internship account access');
  await page.getByLabel('Message *',{exact:true}).fill('أحتاج مساعدة في الدخول إلى حساب التدريب الخاص بي في الجامعة.');
 }
 await fillContact();
 check(await page.getByLabel('Message *',{exact:true}).evaluate(el=>getComputedStyle(el).direction)==='rtl','Arabic input direction');
 await page.getByRole('button',{name:'Send message'}).click();
 check((await page.getByRole('alert').innerText()).includes('has been sent'),'Persisted success');
 const messages=await get('ContactMessages'),records=Object.values(messages);
 check(records.length===1&&records[0].Name==='أسامة بني هاني'&&records[0].Status==='New','Existing message contract');
 check(records[0].Id===Object.keys(messages)[0]&&records[0].SubmittedAt>0,'Server owned key and time');
 await page.reload();check(await count()===1,'Refresh cannot duplicate');
 await fillContact();await page.request.post(db+'/__fail-writes');await page.getByRole('button',{name:'Send message'}).click();
 check((await page.getByRole('alert').innerText()).includes('could not confirm'),'Write failure feedback');
 check(await page.getByLabel('Full name *',{exact:true}).inputValue()==='أسامة بني هاني','Failure retains input');
 check(await count()===1,'Write failure no new records');
 await page.request.post(db+'/__restore-writes');await page.getByRole('button',{name:'Send message'}).click();
 check(await count()===2,'Retry saves');
 await page.goto(base+'/Pages/Public/Contact.aspx');await fillContact();
 await page.getByLabel('Subject *',{exact:true}).fill('abc');
 await page.getByRole('button',{name:'Send message'}).evaluate(el=>{el.removeAttribute('onclick');el.form.noValidate=true;});
 await page.getByRole('button',{name:'Send message'}).click();
 check((await page.getByRole('alert').innerText()).includes('Check your details'),'Server validation when JS bypassed');
 check(await count()===2,'Invalid server input writes nothing');
 for(const [name,path] of routes){
  await page.goto(base+path);await page.evaluate(()=>document.documentElement.dir='rtl');
  check(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),'RTL overflow '+name);
 }
 await page.emulateMedia({reducedMotion:'reduce'});await page.goto(base+'/Default.aspx');
 check(await page.locator('.home-hero-image').evaluate(el=>getComputedStyle(el).animationName)==='none','Reduced motion');
 await page.emulateMedia({reducedMotion:'no-preference'});
 const context=await page.context().browser().newContext({javaScriptEnabled:false});const nojs=await context.newPage();
 await nojs.goto(base+'/Pages/Account/Login.aspx');await nojs.getByRole('button',{name:'Login',exact:true}).click();
 check((await nojs.getByRole('alert').innerText()).includes('Please enter your email and password'),'Login no JS server validation');
 await nojs.goto(base+'/Pages/Account/ForgotPassword.aspx');await nojs.getByRole('button',{name:'Send Reset Link'}).click();
 check((await nojs.getByRole('alert').innerText()).includes('Please enter your email'),'Recovery no JS server validation');
 await nojs.goto(base+'/Pages/Public/Contact.aspx');await nojs.getByRole('button',{name:'Send message'}).click();
 check((await nojs.getByRole('alert').innerText()).includes('Check your details'),'Contact no JS server validation');
 check(await nojs.locator('#publicNav').isVisible(),'No JS nav fallback');await context.close();
 check(errors.length===0,'No browser errors: '+errors.join(';'));
 check(consoleErrors.length===0,'No console errors: '+consoleErrors.join(';'));
 await page.setViewportSize({width:1440,height:1000});await page.goto(base+'/Default.aspx');
 return {passed:checks,pages:6,widths:[1440,768,390,320],consoleErrors,mode:'Local IIS + Postman Firebase simulation; real authentication/email untested'};
}
