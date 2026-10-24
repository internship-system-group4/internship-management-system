async page => {
 const base=new URL(page.url()).origin,browser=page.context().browser(),checks=[],errors=[];
 const check=(ok,name)=>{if(!ok)throw Error(name);checks.push(name);};
 const watch=p=>p.on('pageerror',e=>errors.push(e.message));
 const ctx=await browser.newContext({viewport:{width:1440,height:1000}}),p=await ctx.newPage();watch(p);
 const status=[];
 for(const path of ['/missing-uims-page.aspx','/missing-uims-route','/Assets/js/not-a-real-file.js','/missing-uims-script.js','/Pages/Public/NotFound.aspx']) {
  const r=await p.request.get(base+path,{maxRedirects:0}),body=await r.text();
  check(r.status()===404&&!r.headers().location,'404 without redirect: '+path);
  if(!path.startsWith('/Assets/'))check(body.includes('data-not-found')&&!/Stack Trace|Physical Path|Exception Details|Source Error/.test(body),'Custom body without internals: '+path);
  else check(!body.includes('data-not-found'),'Missing asset does not recursively render the error document');
  status.push({path,status:r.status(),contentType:r.headers()['content-type']||'',bytes:body.length});
 }
 for(const item of [{path:'/__status.aspx?code=403',status:403},{path:'/__status.aspx?code=500',status:500},{path:'/Pages/Student/Dashboard.aspx',status:302}]) {
  const r=await p.request.get(base+item.path,{maxRedirects:0});
  check(r.status()===item.status&&!(await r.text()).includes('data-not-found'),'Other status preserved: '+item.path);
 }
 let response=await p.goto(base+'/missing-uims-route?topic=test&returnUrl=https%3A%2F%2Fexample.org');
 check(response.status()===404&&new URL(p.url()).pathname==='/missing-uims-route','Public missing route retains its original URL');
 check(await p.locator('h1').isVisible()&&await p.locator('.nf-home').isVisible(),'Message and navigation are visible immediately');
 check(await p.locator('.nf-home').getAttribute('href')==='/Default.aspx'&&await p.locator('[data-nf-back]').getAttribute('href')==='/Pages/Public/Contact.aspx','Direct visit and untrusted returnUrl keep real Home and Contact links');
 check((await p.locator('[data-lang-switch]').getAttribute('href')).startsWith('/missing-uims-route?'),'Native IIS execution keeps the original language-switch route');
 await Promise.all([p.waitForNavigation(),p.locator('[data-lang-switch]').click()]);
 check(await p.locator('html').getAttribute('lang')==='ar'&&new URL(p.url()).pathname==='/missing-uims-route'&&new URL(p.url()).searchParams.get('topic')==='test','Arabic switch preserves the native missing route and safe query');
 check(!p.url().includes('ui-lang')&&!p.url().includes('NotFound.aspx'),'No error-handler path or language-switch parameter in destination URL');

 // Composition matrix, with geometry assertions at narrow widths and in RTL.
 for(const lang of ['en','ar']) {
  await ctx.addCookies([{name:'uims-lang',value:lang,url:base}]);
  for(const theme of ['light','dark']) {
   await p.evaluate(t=>window.UimsTheme.set(t),theme);
   for(const width of [1440,390,320]) {
    await p.setViewportSize({width,height:width===1440?1000:844});
    response=await p.goto(base+'/missing-uims-page.aspx');
    check(response.status()===404&&await p.locator('html').getAttribute('dir')===(lang==='ar'?'rtl':'ltr')&&await p.locator('html').getAttribute('data-theme')===theme,'Server language and saved theme: '+lang+'/'+theme+'/'+width);
    check(await p.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),'No horizontal overflow: '+lang+'/'+theme+'/'+width);
    const geometry=await p.evaluate(()=>{const text=document.querySelector('.nf-message').getBoundingClientRect();return [...document.querySelectorAll('.nf-figure')].filter(e=>getComputedStyle(e).display!=='none').every(e=>{const r=e.getBoundingClientRect();return r.right<=text.left||r.left>=text.right||r.bottom<=text.top||r.top>=text.bottom;});});
    check(geometry,'Figures stay away from message and controls: '+lang+'/'+theme+'/'+width);
    await p.waitForFunction(()=>document.querySelector('[data-not-found]').dataset.settled==='true');
    if(width!==390)await p.screenshot({path:'tests/artifacts/not-found-'+lang+'-'+theme+'-'+width+'.png',fullPage:true});
    check(await p.locator('.nf-decor').getAttribute('aria-hidden')==='true'&&await p.locator('.nf-decor').evaluate(e=>getComputedStyle(e).pointerEvents)==='none','Decorations are noninteractive and hidden from assistive technology');
   }
  }
 }
 check(await p.evaluate(()=>performance.getEntriesByType('resource').every(r=>new URL(r.name).origin===location.origin)),'No Firebase, CDN, video, map or 3D dependency');
 // Browser zoom equivalent: doubling the root font must remain scrollable and unclipped.
 await p.setViewportSize({width:320,height:568});await p.locator('html').evaluate(e=>e.style.fontSize='200%');
 check(await p.locator('h1').isVisible()&&await p.locator('.nf-home').isVisible()&&await p.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),'200% text size remains readable without horizontal clipping');
 await p.reload();await p.waitForFunction(()=>document.querySelector('[data-not-found]').dataset.settled==='true');await p.setViewportSize({width:390,height:700});
 check(!await p.locator('[data-not-found]').evaluate(e=>e.classList.contains('nf-entering'))&&await p.locator('.nf-figure').count()===3,'Resize keeps figures and does not restart the entrance');

 // Follow an actual link so the browser, not an untrusted returnUrl, supplies history evidence.
 await ctx.addCookies([{name:'uims-lang',value:'en',url:base}]);await p.goto(base+'/Pages/Public/Contact.aspx');
 const follow=async path=>{await p.evaluate(path=>{document.getElementById('broken-link-fixture')?.remove();const a=document.createElement('a');a.id='broken-link-fixture';a.href=path;a.textContent='Missing page fixture';document.body.prepend(a);},path);await p.locator('#broken-link-fixture').focus();await Promise.all([p.waitForNavigation(),p.keyboard.press('Enter')]);};
 await follow('/back-test-missing.aspx');
 check(await p.locator('[data-nf-back]').innerText()==='Go Back','Same-origin previous page enables Go Back');
 await Promise.all([p.waitForNavigation(),p.locator('[data-nf-back]').click()]);
 check(new URL(p.url()).pathname==='/Pages/Public/Contact.aspx','Go Back returns to the established previous page');
 await follow('/loop-test-first.aspx');await follow('/loop-test-second.aspx');
 check(await p.locator('[data-nf-back]').getAttribute('href')==='/Pages/Public/Contact.aspx','A previous known 404 cannot create a back-navigation loop');
 await p.goto(base+'/external-referrer-missing',{referer:'https://example.org/elsewhere'});
 check(await p.locator('[data-nf-back]').getAttribute('href')==='/Pages/Public/Contact.aspx','External referrer keeps the safe Contact fallback');
 await p.locator('.nf-home').focus();await p.keyboard.press('Tab');await p.keyboard.press('Shift+Tab');
 check(await p.locator('.nf-home').evaluate(e=>getComputedStyle(e).outlineStyle!=='none'),'Keyboard focus is visible');
 await Promise.all([p.waitForNavigation(),p.keyboard.press('Enter')]);
 check(new URL(p.url()).pathname==='/Default.aspx','Home works as a real keyboard-activated link');
 await ctx.close();

 const reduced=await browser.newContext({reducedMotion:'reduce',viewport:{width:390,height:844}}),r=await reduced.newPage();watch(r);
 await r.goto(base+'/reduced-motion-missing');
 check(await r.locator('[data-not-found]').getAttribute('data-settled')==='true'&&await r.locator('.nf-decor').evaluate(e=>e.getAnimations({subtree:true}).length===0),'Reduced motion renders the settled composition immediately');await reduced.close();
 const nojs=await browser.newContext({javaScriptEnabled:false,viewport:{width:320,height:844}}),n=await nojs.newPage();
 await n.goto(base+'/no-js-missing.aspx');
 check(await n.locator('h1').isVisible()&&await n.locator('.nf-home').getAttribute('href')==='/Default.aspx'&&await n.locator('[data-nf-back]').getAttribute('href')==='/Pages/Public/Contact.aspx','Without JavaScript the content, Home and useful fallback remain available');
 await Promise.all([n.waitForNavigation(),n.locator('.nf-home').click()]);check(new URL(n.url()).pathname==='/Default.aspx','Home navigation works with JavaScript disabled');await nojs.close();
 const fallback=await browser.newContext({viewport:{width:390,height:844}});
 await fallback.addInitScript(()=>{HTMLCanvasElement.prototype.getContext=function(){throw Error('Canvas unavailable fixture');};});
 await fallback.route('**/Assets/images/gju-logo.png',route=>route.fulfill({status:404,contentType:'text/plain',body:''}));
 const f=await fallback.newPage();watch(f);await f.goto(base+'/asset-failure-missing');
 check(await f.locator('h1').isVisible()&&await f.locator('canvas').count()===0&&await f.locator('.nf-home').isVisible(),'Missing decorative image and unavailable canvas do not affect content or navigation');
 await f.evaluate(()=>{Object.defineProperty(document,'hidden',{configurable:true,get:()=>true});document.dispatchEvent(new Event('visibilitychange'));});
 check(await f.locator('[data-not-found]').getAttribute('data-settled')==='true','Backgrounding safely settles the one-shot entrance');await fallback.close();
 check(errors.length===0,'No uncaught JavaScript errors (expected HTTP 404 resource responses excluded): '+errors.join(' | '));
 return {passed:checks.length,http:status,checks};
}
