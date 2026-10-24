async page=>{
 const base=new URL(page.url()).origin,db='http://127.0.0.1:4912/firebase',dir='C:/Users/user/Desktop/Project3/internship-management-system/tests/artifacts/',browser=page.context().browser(),checks=[],errors=[];
 const check=(ok,name)=>{if(!ok)throw Error(name);checks.push(name);};
 const roles=[['Student','student-one'],['Company','supervisor-one'],['Academic','academic-one'],['Coordinator','coordinator-one']];
 for(const [role,id]of roles){
  const c=await browser.newContext({viewport:{width:1440,height:900}}),p=await c.newPage();p.on('pageerror',e=>errors.push({url:p.url(),message:e.message}));
  const data=await(await p.request.get(db+'/users/'+id+'.json')).json();await p.request.put(db+'/users/'+id+'.json',{data:{...data,FullName:role+' Development Account',IsActive:true,MustChangePassword:false}});
  await p.goto(base+'/__fixture.aspx?user='+id);await p.goto(base+'/Pages/'+role+'/Dashboard.aspx');
  check(await p.locator('[data-portal-sidebar] .uims-page-title').count()===1&&await p.locator('.uims-content .uims-page-title,.uims-content .uims-user').count()===0,'All former header content belongs to sidebar: '+role);
  check(await p.locator('[data-lang-switch]').count()===1&&await p.locator('[data-theme-toggle]').count()===1&&await p.locator('.uims-notify-button').count()===1&&await p.locator('.uims-sidebar-account').count()===1,'Single language/theme/bell/account control: '+role);
  check(await p.locator('.uims-sidebar-account').innerText().then(t=>t.includes(role+' Development Account')),'Trusted user name retained: '+role);
  check(await p.locator('.uims-topbar').evaluate(e=>getComputedStyle(e).display==='none'),'Desktop header space removed: '+role);
  check(await p.locator('.uims-sidebar-navigation').evaluate(e=>getComputedStyle(e).scrollbarWidth==='none'&&getComputedStyle(e).overflowY==='auto'),'Scrollbar hidden while scrolling stays enabled: '+role);
  let posts=0;p.on('request',r=>{if(r.method()==='POST')posts++;});
  await p.locator('[data-theme-toggle]').click();check(await p.locator('html').getAttribute('data-theme')==='dark','Sidebar theme toggle works: '+role);await p.waitForTimeout(1100);
  await p.locator('.uims-notify-button').click();const menu=p.locator('.uims-notify-menu');check(await menu.isVisible(),'Notifications open in sidebar: '+role);
  check(await menu.evaluate(e=>{const r=e.getBoundingClientRect();return r.left>=0&&r.right<=innerWidth&&r.top>=0&&r.bottom<=innerHeight;}),'Notification menu stays in viewport: '+role);
  await p.keyboard.press('Escape');check(!await menu.isVisible(),'Escape closes notifications: '+role);check(posts===0,'Utility buttons never post the form: '+role);
  await p.locator('[data-lang-switch]').click();await p.waitForLoadState();check(await p.locator('html').getAttribute('dir')==='rtl','Sidebar language uses server RTL navigation: '+role);
  check(await p.locator('.uims-sidebar-context').innerText().then(t=>!t.includes('Shared.')),'Portal context is translated: '+role);
  for(const width of [1440,390,320]){
   await p.setViewportSize({width,height:width===1440?900:720});await p.waitForTimeout(350);
   if(width<901)await p.locator('.student-nav-toggle').click();await p.waitForTimeout(350);
   check(await p.locator('.uims-sidebar-tools [data-lang-switch]').isVisible()&&await p.locator('.uims-sidebar-tools [data-theme-toggle]').isVisible()&&await p.locator('.uims-sidebar-tools .uims-notify-button').isVisible(),'All tools visible in Arabic/dark at '+width+': '+role);
   check(await p.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),'No page overflow at '+width+': '+role);
   if(width<901){
    check(await p.locator('.uims-content').evaluate(e=>e.inert),'Mobile background inert: '+role+'/'+width);
    await p.locator('.uims-notify-button').click();check(await menu.evaluate(e=>{const r=e.getBoundingClientRect();return r.left>=0&&r.right<=innerWidth&&r.top>=0&&r.bottom<=innerHeight;}),'Mobile notification bounds: '+role+'/'+width);
    await p.keyboard.press('Escape');check(await p.locator('[data-portal-sidebar]').getAttribute('role')==='dialog','First Escape leaves navigation open: '+role+'/'+width);
    if(width===390)await p.screenshot({path:dir+'sidebar-unified-'+role.toLowerCase()+'-ar-dark-mobile.png',animations:'disabled'});
    await p.keyboard.press('Escape');check(await p.locator('.student-nav-toggle').evaluate(e=>e===document.activeElement),'Drawer Escape restores focus: '+role+'/'+width);
   }else await p.screenshot({path:dir+'sidebar-unified-'+role.toLowerCase()+'-ar-dark.png',animations:'disabled'});
  }
  await p.setViewportSize({width:1440,height:900});await p.locator('[data-lang-switch]').click();await p.waitForLoadState();await p.locator('[data-theme-toggle]').click();await p.waitForTimeout(1300);
  await p.locator('.uims-sidebar-pin').click();await p.mouse.move(700,60);await p.evaluate(()=>document.activeElement.blur());await p.waitForTimeout(400);
  check(await p.locator('[data-portal-sidebar]').evaluate(e=>Math.round(e.getBoundingClientRect().width)===76),'Compact sidebar still works: '+role);
  check(await p.locator('.uims-sidebar-tools [data-lang-switch]').isVisible(),'Compact language remains accessible: '+role);
  await p.reload();await p.waitForTimeout(400);check(await p.locator('[data-portal-sidebar]').getAttribute('data-expanded')==='false','Compact preference persists: '+role);
  await p.locator('.uims-sidebar-pin').focus();await p.keyboard.press('Tab');check(await p.locator('.uims-side-link').first().evaluate(e=>e===document.activeElement),'Keyboard expands navigation and reaches links: '+role);
  await p.locator('.uims-sidebar-pin').click();await p.mouse.move(700,50);await p.evaluate(()=>document.activeElement.blur());await p.waitForTimeout(400);
  await p.locator('.uims-sidebar-signout').click();await p.waitForURL('**/Login.aspx');check(true,'Existing logout postback works: '+role);
  await p.request.put(db+'/users/'+id+'.json',{data});await c.close();
 }
 // Stress a long menu and account name in a short viewport; hidden scrollbar must not block access.
 const c=await browser.newContext({viewport:{width:1000,height:420}}),p=await c.newPage();await p.goto(base+'/__fixture.aspx?user=coordinator-one');await p.goto(base+'/Pages/Coordinator/Dashboard.aspx');
 check(await p.locator('.uims-sidebar-navigation').evaluate(e=>e.scrollHeight>e.clientHeight&&e.clientHeight>24),'Long coordinator menu has a usable scroll region');
 await p.locator('.uims-side-link').last().focus();check(await p.locator('.uims-sidebar-navigation').evaluate(e=>e.scrollTop>0),'Keyboard focus scrolls to the last link without a visible bar');
 await p.locator('.uims-notify-button').click();check(await p.locator('.uims-notify-menu').evaluate(e=>{const r=e.getBoundingClientRect();return r.top>=0&&r.bottom<=innerHeight;}),'Notification panel fits short desktop');await p.keyboard.press('Escape');
 check(await p.locator('.uims-sidebar-signout').evaluate(e=>e.getBoundingClientRect().bottom<=innerHeight),'Logout remains in short viewport');
 await p.screenshot({path:dir+'sidebar-unified-short.png',animations:'disabled'});
 await p.setViewportSize({width:390,height:600});await p.locator('.student-nav-toggle').click();await p.waitForTimeout(350);await p.locator('.student-nav-close').focus();await p.keyboard.press('Shift+Tab');check(await p.locator('.uims-sidebar-signout').evaluate(e=>e===document.activeElement),'Mobile reverse Tab wraps to logout');await p.keyboard.press('Tab');check(await p.locator('.student-nav-close').evaluate(e=>e===document.activeElement),'Mobile forward Tab wraps to close');await p.keyboard.press('Escape');
 await p.goto(base+'/Pages/Coordinator/Account.aspx');await p.locator('input[type=text]').first().fill('Unsaved account edit');await p.locator('.student-nav-toggle').click();await p.evaluate(()=>window.confirm=()=>false);const initial=p.url();await p.locator('[data-lang-switch]').click();check(p.url()===initial&&await p.locator('[data-portal-sidebar]').getAttribute('role')==='dialog','Cancelled language switch preserves unsaved form and open drawer');
 await c.close();const baseline=errors.filter(e=>e.url.endsWith('/Pages/Account/Login.aspx')&&e.message==='Transition was aborted because of invalid state. ViewTransition opt-in disabled');const unexpected=errors.filter(e=>!baseline.includes(e));check(unexpected.length===0,'No new page JavaScript errors: '+JSON.stringify(unexpected));return {passed:checks.length,checks,knownBaselineTransitionErrors:baseline};
}
