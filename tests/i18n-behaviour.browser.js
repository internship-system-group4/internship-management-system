async page => {
 // Language switching behaviour against the disposable host (57992) and the campus-login simulation (4910).
 // Writes only to the simulation (reset first); never to a live service.
 const base='http://localhost:57992',db='http://127.0.0.1:4910/firebase';
 const checks=[];const check=(ok,name)=>{if(!ok)throw Error(name);checks.push(name);};
 const errors=[];page.on('pageerror',e=>errors.push(e.message));
 const html=async()=>page.evaluate(()=>({lang:document.documentElement.lang,dir:document.documentElement.dir,rtlCss:[...document.styleSheets].some(s=>/bootstrap\.rtl\.min\.css/.test(s.href||'')),ltrCss:[...document.styleSheets].some(s=>/bootstrap\.min\.css/.test(s.href||''))}));
 const langControl=()=>page.locator('.uims-lang-control:visible').first();
 const langLink=()=>langControl().locator('[data-lang-switch]:not([aria-current="page"])').first();
 await page.request.post(db+'/__reset');
 await page.context().clearCookies();await page.setViewportSize({width:1440,height:1000});

 // English is the default; exactly one Bootstrap build is loaded.
 await page.goto(base+'/Pages/Public/Contact.aspx?topic=general');let h=await html();
 check(h.lang==='en'&&h.dir==='ltr'&&h.ltrCss&&!h.rtlCss,'English default with the LTR Bootstrap build only');
 const controlBox=await langControl().boundingBox();
 check(await langControl().getAttribute('role')==='group'&&await langControl().getAttribute('data-current-lang')==='en'&&await langControl().locator('.uims-lang-option').count()===2&&await langControl().locator('[aria-current="page"]').getAttribute('data-lang-switch')==='en'&&controlBox.width>=112&&controlBox.width<=132&&controlBox.height>=40&&controlBox.height<=44,'Segmented control has two accessible options, English selected, and compact 120×44 sizing');
 check(await page.evaluate(()=>getComputedStyle(document.querySelector('.uims-lang-control')).direction)==='ltr'&&await langControl().locator('[data-lang-switch="ar"]').innerText()==='عربي','Option order stays EN then Arabic in LTR');

 // A failed postback (server validation) stays a POST; switching language afterwards is a GET to the same page.
 const posts=[];page.on('request',r=>{if(r.method()==='POST'&&r.url().includes('/Contact.aspx'))posts.push(r.url());});
 // form.submit() skips the client checks: a plain postback with empty fields, rejected by the server.
 await Promise.all([page.waitForNavigation(),page.evaluate(()=>HTMLFormElement.prototype.submit.call(document.forms[0]))]);
 const postsBefore=posts.length;check(postsBefore>=1,'Validation round trip is a postback');
 check(new URL(await langLink().getAttribute('href'),base).searchParams.get('ui-lang')==='ar','Selector is a plain link carrying ui-lang');
 await langLink().focus();const nav=page.waitForRequest(r=>r.isNavigationRequest()&&r.url().includes('ui-lang=ar'));await Promise.all([page.waitForNavigation(),page.keyboard.press('Enter')]);const req=await nav;await page.waitForLoadState('load');
 check(req.method()==='GET'&&posts.length===postsBefore,'Language switch is a GET and does not replay the POST');
 check(new URL(page.url()).pathname==='/Pages/Public/Contact.aspx'&&new URL(page.url()).searchParams.get('topic')==='general'&&!page.url().includes('ui-lang'),'Same page, safe query kept, switch parameter removed');
 h=await html();check(h.lang==='ar'&&h.dir==='rtl'&&h.rtlCss&&!h.ltrCss,'Arabic with the RTL Bootstrap build only');
 check(await langControl().getAttribute('data-current-lang')==='ar'&&await langControl().locator('[aria-current="page"]').getAttribute('data-lang-switch')==='ar'&&await langLink().getAttribute('hreflang')==='en','Language toggle updates its selected state and target after switching');
 const cookie=(await page.context().cookies()).find(c=>c.name==='uims-lang');check(cookie&&cookie.value==='ar'&&cookie.httpOnly&&cookie.sameSite==='Lax','First-party HttpOnly SameSite=Lax cookie');

 // Arabic client validation messages.
 await page.reload();await page.locator('[data-public-form] input[type=submit],[data-public-form] button[type=submit]').first().click();
 const message=await page.locator('[data-public-form] [role=alert]:visible, [data-public-form] .field-error:visible, [data-public-form] [id$=Error]:visible').first().innerText().catch(()=> '');
 check(/[؀-ۿ]/.test(message),'Client validation message is Arabic: '+message);

 // Dirty form: dismissing the confirmation keeps the page and the typed text; accepting switches.
 await page.reload();const field=page.locator('[data-public-form] input[type=text]:visible').first();await field.fill('نص تجريبي');
 await page.evaluate(()=>{window.__asked=[];window.confirm=m=>{window.__asked.push(m);return false;};});await langLink().click();await page.waitForTimeout(400);const dialogText=(await page.evaluate(()=>window.__asked))[0]||'';
 check(/[؀-ۿ]/.test(dialogText)&&(await html()).lang==='ar'&&await field.inputValue()==='نص تجريبي','Unsaved changes: confirmation in Arabic, cancel keeps the form');
 await page.evaluate(()=>{window.confirm=()=>true;});await Promise.all([page.waitForNavigation(),langLink().click()]);await page.waitForLoadState('load');
 check((await html()).lang==='en','Unsaved changes: accepting switches language');

 // Login and logout keep the choice; postbacks in the portal keep it.
 await page.goto(base+'/Pages/Account/Login.aspx?ui-lang=ar');await page.waitForLoadState('load');check((await html()).dir==='rtl','Login page in Arabic');
 await page.locator('#txtEmail, input[type=email]').first().fill('student@campus.test');await page.locator('input[type=password]').first().fill('Fixture-pass-2026');
 await page.locator('[data-public-form] input[type=submit]').click();await page.waitForURL('**/Pages/Student/Dashboard.aspx');
 h=await html();check(h.lang==='ar'&&h.dir==='rtl','Language survives sign-in');
 const side=await page.evaluate(()=>{const s=document.querySelector('.uims-sidebar').getBoundingClientRect();return s.left>innerWidth/2;});check(side,'Sidebar on the right in Arabic');
 check((await page.locator('.uims-user').innerText()).includes('الطالب'),'Role label translated (الطالب)');
 await page.goto(base+'/Pages/Account/Notifications.aspx');const [portalPost]=await Promise.all([page.waitForRequest(r=>r.isNavigationRequest()&&r.method()==='POST'),page.waitForNavigation(),page.evaluate(()=>HTMLFormElement.prototype.submit.call(document.forms[0]))]);
 check(portalPost.url().includes('Notifications.aspx')&&(await html()).dir==='rtl','Language survives a portal postback');
 await page.locator('.uims-sidebar-signout, [id$=btnSignOut]').first().click({force:true});await page.waitForURL('**/Login.aspx**');
 check((await html()).dir==='rtl','Language survives sign-out');

 // The narrow public navigation uses the same single toggle.
 await page.setViewportSize({width:390,height:844});await page.goto(base+'/Default.aspx');await page.locator('.public-menu-toggle').click();
 const mobileControl=page.locator('.public-theme-mobile .uims-lang-control');
 check(await mobileControl.count()===1&&await mobileControl.getAttribute('data-current-lang')==='ar'&&await mobileControl.locator('.uims-lang-option').count()===2&&await mobileControl.locator('[aria-current="page"]').getAttribute('data-lang-switch')==='ar','Mobile menu has one accessible Arabic-selected segmented control');
 const mobileBox=await mobileControl.boundingBox();check(mobileBox.width>=112&&mobileBox.width<=132&&mobileBox.height>=40&&mobileBox.height<=44,'Mobile language control keeps its compact touch-friendly dimensions');
 await Promise.all([page.waitForNavigation(),mobileControl.locator('[data-lang-switch="en"]').click()]);
 check((await html()).lang==='en'&&await page.locator('.public-theme-mobile .uims-lang-control').getAttribute('data-current-lang')==='en','Mobile control switches back to English');

 // Invalid cookie values fall back to English.
 for(const value of ['xx','ar-SA','%3Cscript%3E']){await page.context().addCookies([{name:'uims-lang',value,url:base}]);await page.goto(base+'/Default.aspx');check((await html()).lang==='en','Invalid cookie "'+value+'" falls back to English');}
 check(errors.length===0,'No page errors: '+errors.join(' | '));
 return {passed:checks.length,checks};
}
