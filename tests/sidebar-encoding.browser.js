async page => {
 // Run against tests/Start-LoginTestHost.ps1 (port 57992) with the campus-login simulation on 4910.
 const base='http://localhost:57992',db='http://127.0.0.1:4910/firebase';
 const checks=[];const check=(ok,name)=>{if(!ok)throw Error(name);checks.push(name);};
 const errors=[];page.on('pageerror',e=>errors.push(e.message));
 await page.request.post(db+'/__reset');
 for(const [id,role] of [['academic-one',3],['coordinator-one',4]])
  await page.request.put(db+'/users/'+id+'.json',{data:{Id:id,Role:role,FullName:'Synthetic test account',IsActive:true,MustChangePassword:false}});
 await page.emulateMedia({reducedMotion:'reduce'});await page.setViewportSize({width:1440,height:900});
 for (const [account,area] of [['student','Student'],['company','Company'],['academic','Academic'],['coordinator','Coordinator']]) {
  await page.context().clearCookies();await page.goto(base+'/Pages/Account/Login.aspx');
  await page.getByLabel('Email address',{exact:true}).fill(account+'@campus.test');await page.getByLabel('Password',{exact:true}).fill('Fixture-pass-2026');
  const responsePromise=page.waitForResponse(r=>r.url().endsWith('/Pages/'+area+'/Dashboard.aspx'));
  await page.locator('[data-public-form] input[type=submit]').click();const response=await responsePromise;await page.waitForLoadState('domcontentloaded');
  const html=await response.text();
  check(!/â€/.test(html),'No mojibake in '+area+' dashboard HTML');
  const title=await page.locator('.uims-sidebar-account').getAttribute('title');
  check(/^\S.* — My account$/.test(title),area+' sidebar title uses an em dash: '+title);
  check(await page.locator('.uims-sidebar').isVisible(),area+' sidebar visible');
  // Every sidebar destination is allowed for this role (no redirect to Login or Access Denied).
  const hrefs=[...new Set(await page.locator('.uims-sidebar a[href]').evaluateAll(links=>links.map(a=>a.href)))].filter(h=>/^https?:/.test(h)); // Sign out is a postback, not a URL.
  const redirects=[];
  for (const href of hrefs) {
   const r=await page.request.get(href,{maxRedirects:0}),location=r.headers()['location']||'';
   // A page may bounce back inside its own role area (e.g. a missing ?id); Login or Access Denied would mean lost permission.
   const allowed=r.status()===200||(r.status()===302&&!/Login|AccessDenied/i.test(location)&&location.includes('/Pages/'+area+'/'));
   if(r.status()===302)redirects.push(href.replace(base,'')+' -> '+location);
   check(allowed,area+' link '+href.replace(base,'')+' '+r.status()+' '+location);
  }
  if(redirects.length)checks.push(area+' in-role redirects: '+redirects.join(', '));
  // Desktop: pin expands, unpin collapses once pointer and focus leave.
  const sidebar=page.locator('[data-portal-sidebar]'),pin=page.locator('.uims-sidebar-pin');
  await page.evaluate(()=>{try{localStorage.removeItem('uims.sidebar.pinned');}catch(_){}});await page.reload();
  await page.mouse.move(1400,600);check(await sidebar.getAttribute('data-expanded')==='false',area+' sidebar starts collapsed');
  await pin.click();check(await sidebar.getAttribute('data-expanded')==='true'&&await pin.getAttribute('aria-pressed')==='true',area+' pin expands sidebar');
  await pin.click();await page.mouse.move(1400,600);await page.evaluate(()=>document.activeElement.blur());await page.waitForTimeout(50);
  check(await sidebar.getAttribute('data-expanded')==='false'&&await pin.getAttribute('aria-pressed')==='false',area+' unpin collapses sidebar');
  // Mobile: menu opens the drawer; Escape closes it and returns focus to the toggle.
  await page.setViewportSize({width:390,height:844});
  const toggle=page.locator('.student-nav-toggle');await toggle.click();
  check(await toggle.getAttribute('aria-expanded')==='true'&&await page.evaluate(()=>document.body.classList.contains('student-nav-open')),area+' mobile drawer opens');
  await page.keyboard.press('Escape');
  check(await toggle.getAttribute('aria-expanded')==='false'&&await toggle.evaluate(el=>el===document.activeElement),area+' Escape closes drawer and restores focus');
  await page.setViewportSize({width:1440,height:900});
 }
 await page.emulateMedia({reducedMotion:'no-preference'});await page.context().clearCookies();
 check(errors.length===0,'No JavaScript errors: '+errors.join(' | '));
 return {passed:checks.length,checks};
}
