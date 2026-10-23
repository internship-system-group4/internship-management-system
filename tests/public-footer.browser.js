async page => {
 // Run against tests/Start-LoginTestHost.ps1 (port 57992) with the campus-login simulation on 4910.
 const base='http://localhost:57992';
 const checks=[];const check=(ok,name)=>{if(!ok)throw Error(name);checks.push(name);};
 const errors=[];page.on('pageerror',e=>errors.push(e.message));page.on('console',m=>{if(m.type()==='error'&&!/favicon/.test(m.text()))errors.push(m.text());});
 const pages=['/Default.aspx','/Pages/Public/About.aspx','/Pages/Public/Contact.aspx','/Pages/Public/PoweredBy.aspx','/Pages/Public/AccessDenied.aspx','/Pages/Account/Login.aspx','/Pages/Account/ForgotPassword.aspx'];
 await page.context().clearCookies();await page.emulateMedia({reducedMotion:'no-preference'});
 for (const width of [1440,768,390,320]) {
  await page.setViewportSize({width,height:900});
  for (const path of pages) {
   const response=await page.goto(base+path);check(response.status()===200,'200 '+path+' @'+width);
   const info=await page.evaluate(()=>{const f=document.querySelectorAll('footer');const footer=f[0];return {count:f.length,old:document.querySelectorAll('.public-footer').length,
    overflow:document.documentElement.scrollWidth>innerWidth,position:getComputedStyle(footer).position,powered:footer.querySelector('.uims-public-footer-powered')?.getBoundingClientRect().height};});
   check(info.count===1&&info.old===0,'One replaced footer '+path+' @'+width);
   check(!info.overflow,'No horizontal overflow '+path+' @'+width);
   check(info.position==='static'&&info.powered>=44,'Footer in flow, Powered by tappable '+path+' @'+width);
  }
 }
 await page.setViewportSize({width:1440,height:900});await page.goto(base+'/Pages/Public/About.aspx');
 await page.locator('footer').scrollIntoViewIfNeeded();
 const waves=await page.evaluate(()=>{const box=document.querySelector('.uims-public-footer-waves');const svgs=[...box.querySelectorAll('svg')];
  // Each path must be identical one period (1440 units) apart for the -50% loop to be seamless.
  const periodic=svgs.every(svg=>{const p=svg.querySelector('path');for(let x=0;x<1440;x+=37)for(let y=0;y<160;y+=9){const a=new DOMPoint(x,y),b=new DOMPoint(x+1440,y);if(p.isPointInFill(a)!==p.isPointInFill(b))return false;}return true;});
  return {hidden:box.getAttribute('aria-hidden'),events:getComputedStyle(box).pointerEvents,periodic,names:svgs.map(s=>getComputedStyle(s).animationName),widths:svgs.map(s=>s.getBoundingClientRect().width/box.getBoundingClientRect().width)};});
 check(waves.hidden==='true'&&waves.events==='none','Waves decorative and non-interactive');
 check(waves.periodic&&waves.widths.every(w=>Math.abs(w-2)<.01)&&waves.names.every(n=>n==='uims-footer-wave'),'Seamless wave loop geometry');
 const unblocked=await page.evaluate(()=>[...document.querySelectorAll('footer a, footer button:not([hidden])')].filter(el=>!el.closest('[data-footer-map-stage]')&&getComputedStyle(el).pointerEvents!=='none').every(el=>{el.scrollIntoView({block:'center',behavior:'instant'});const r=el.getBoundingClientRect();const hit=document.elementFromPoint(r.left+r.width/2,r.top+r.height/2);return el===hit||el.contains(hit);}));
 check(unblocked,'No footer link covered by decoration');
 const pause=page.locator('[data-footer-wave-pause]');check(await pause.isVisible(),'Pause control shown while waves move');
 await pause.click();check(await pause.getAttribute('aria-pressed')==='true'&&await page.evaluate(()=>getComputedStyle(document.querySelector('.uims-public-footer-wave')).animationPlayState)==='paused','Pause stops waves');
 await pause.click();check(await pause.getAttribute('aria-pressed')==='false','Waves resume');
 await page.emulateMedia({reducedMotion:'reduce'});await page.reload();
 check(await page.evaluate(()=>getComputedStyle(document.querySelector('.uims-public-footer-wave')).animationName)==='none'&&!await pause.isVisible(),'Reduced motion: static waves, no pause control');
 await page.emulateMedia({reducedMotion:'no-preference'});
 // Quick links: every footer destination resolves.
 const hrefs=await page.evaluate(()=>[...document.querySelectorAll('.uims-public-footer a')].map(a=>a.href).filter(h=>h.startsWith(location.origin)));
 for (const href of new Set(hrefs.map(h=>h.split('#')[0]))) check((await page.request.get(href)).status()===200,'Footer destination '+href.replace(base,''));
 const labels=await page.locator('footer nav a').allInnerTexts();
 check(JSON.stringify(labels)===JSON.stringify(['Home','About us','Opportunities','How it works','Contact us','Log in']),'Quick links signed out');
 check(!await page.locator('footer a[href="#"], footer input[type=email]').count(),'No placeholder links or fake subscribe');
 check(await page.locator('footer address').count()===2&&await page.locator('footer a[href^="mailto:"], footer a[href^="tel:"]').count()===0,'Contact uses existing details only');
 const map=page.getByRole('link',{name:/View on Google Maps/});
 check(await map.getAttribute('href')==='https://www.google.jo/maps/place/German+Jordanian+University+-+New+Campus/@31.776843,35.802555,17z/data=!3m1!4b1!4m2!3m1!1s0x151cac23316fd607:0xbcc3e00aab7f6fa9'&&await map.getAttribute('target')==='_blank'&&await map.getAttribute('rel')==='noopener noreferrer'&&await page.locator('#footerLocationTitle').innerText()==='University Location','University Location links to the official GJU main-campus map in a new tab');
 // The standard campus map ships in the markup (no-script view and fallback); the script holds it back while the flight map runs.
 const served=await (await page.request.get(base+'/Pages/Public/About.aspx')).text();
 check(/<iframe[^>]+data-footer-map-embed[^>]+src="https:\/\/www\.google\.com\/maps\/embed\?[^"]*31\.776843,35\.802555[^"]*"[^>]+loading="lazy"[^>]+referrerpolicy="strict-origin-when-cross-origin"/.test(served)&&/data-lat="31\.776843" data-lng="35\.802555"/.test(served),'Campus map section carries the verified coordinates and a lazy, titled standard embed');
 const official=page.locator('.uims-public-footer-official').first();check(await official.getAttribute('href')==='https://www.gju.edu.jo'&&(await official.innerText()).includes('GJU official website'),'Verified official link labelled');
 // Powered by: exact label, accessible name, same tab, real public page.
 const powered=page.locator('.uims-public-footer-powered');
 check((await powered.innerText()).trim()==='Powered by'&&await powered.getAttribute('aria-label')==='Powered by — Meet the development team'&&!await powered.getAttribute('target'),'Powered by label and same-tab link');
 await page.context().clearCookies();await powered.click();await page.waitForURL('**/Pages/Public/PoweredBy.aspx');
 check(await page.getByRole('heading',{level:1}).innerText()==='Meet the team','Team page opens without login');
 check(await page.locator('[data-team-experience] .team-member').count()===7,'Team page carries the full roster');
 check(await page.locator('.uims-public-nav').getByRole('link',{name:'Home',exact:true}).getAttribute('href')==='/Default.aspx','Home reachable from the team page');
 // Keyboard: Powered by is reachable and shows a visible focus ring.
 await page.locator('.uims-public-footer-official').first().focus();let reached=false;
 for(let i=0;i<16&&!reached;i++){await page.keyboard.press('Tab');reached=await page.evaluate(()=>document.activeElement.classList.contains('uims-public-footer-powered'));}
 check(reached&&await page.evaluate(()=>{const s=getComputedStyle(document.activeElement);return s.outlineStyle==='solid'&&parseFloat(s.outlineWidth)>=2;}),'Keyboard focus reaches Powered by with visible ring');
 // RTL: logical layout holds without overflow.
 await page.evaluate(()=>document.documentElement.dir='rtl');check(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),'RTL without overflow');
 // Signed in: the footer offers the verified role's dashboard.
 await page.goto(base+'/Pages/Account/Login.aspx');await page.getByLabel('Email address',{exact:true}).fill('student@campus.test');await page.getByLabel('Password',{exact:true}).fill('Fixture-pass-2026');
 await page.emulateMedia({reducedMotion:'reduce'});await page.locator('[data-public-form] input[type=submit]').click();await page.waitForURL('**/Pages/Student/Dashboard.aspx');
 check(await page.locator('.uims-public-footer').count()===0,'Private dashboard keeps its own layout');
 await page.goto(base+'/Pages/Public/About.aspx');const action=page.locator('footer nav a').last();
 check(await action.innerText()==='My dashboard'&&await action.getAttribute('href')==='/Pages/Student/Dashboard.aspx','Signed-in dashboard action');
 await page.emulateMedia({reducedMotion:'no-preference'});await page.context().clearCookies();
 check(errors.length===0,'No console errors: '+errors.join(' | '));
 return {passed:checks.length,checks};
}
