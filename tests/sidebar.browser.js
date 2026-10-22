async page => {
 const base='http://localhost:57983',db='http://localhost:4903/firebase';let checks=0,pages=0;const errors=[];
 const check=(ok,message)=>{if(!ok)throw Error(message);checks++;};
 const settle=()=>page.locator('[data-portal-sidebar]').evaluate(el=>Promise.all(el.getAnimations().map(a=>a.finished)));
 const width=()=>page.locator('[data-portal-sidebar]').evaluate(el=>Math.round(el.getBoundingClientRect().width));
 const overflow=()=>page.evaluate(()=>document.documentElement.scrollWidth>innerWidth);
 const out=async()=>{await page.locator('.uims-page-title').focus();await page.mouse.move(700,70);await page.evaluate(()=>document.activeElement.blur());await settle();};
 const nav=page.locator('[data-portal-sidebar]');
 page.on('pageerror',e=>errors.push(e.message));page.on('console',m=>{if(m.type()==='error')errors.push(m.text());});
 await page.request.post(db+'/__reset');await page.context().clearCookies();
 await page.goto(base+'/Default.aspx');await page.evaluate(()=>localStorage.removeItem('uims.sidebar.pinned'));
 for(const [id,Role,FullName] of [['academic-one',3,'Academic Supervisor'],['coordinator-one',4,'Internship Coordinator']]) {
  await page.request.put(db+'/users/'+id+'.json',{data:{Id:id,Role,FullName,IsActive:true,MustChangePassword:false,Email:id+'@example.com'}});
 }
 const roles=[
  {folder:'Student',id:'student-one',count:6,routes:['Dashboard','Profile','Opportunities','OpportunityDetails','Apply','MyApplications','MyTasks','Progress'],alias:{OpportunityDetails:'Opportunities',Apply:'MyApplications'},wrong:'Company'},
  {folder:'Company',id:'supervisor-one',count:8,routes:['Dashboard','Opportunities','Applications','Trainees','TraineeDetails','Tasks','TaskReview','FinalEvaluation','Account'],alias:{TraineeDetails:'Trainees'},wrong:'Academic'},
  {folder:'Academic',id:'academic-one',count:4,routes:['Dashboard','StudentProgress','FinalEvaluation','Account'],alias:{},wrong:'Coordinator'},
  {folder:'Coordinator',id:'coordinator-one',count:9,routes:['Dashboard','Students','Companies','AcademicSupervisors','Groups','Placements','PlacementDetails','CompletionReview','ContactMessages','Account'],alias:{PlacementDetails:'Placements'},wrong:'Student'}
 ];
 for(const role of roles){
  await page.setViewportSize({width:1440,height:900});await page.mouse.move(700,70);
  await page.goto(base+'/__fixture.aspx?user='+role.id);
  for(const route of role.routes){
   await page.goto(base+'/Pages/'+role.folder+'/'+route+'.aspx');
   check(await nav.count()===1,'Exactly one panel '+role.folder+'/'+route);
   check(await page.locator('.uims-side-link').count()===role.count,'Verified role menu '+role.folder+'/'+route);
   const active=nav.locator('[aria-current="page"]');
   check(await active.count()===1&&(await active.getAttribute('href')).endsWith('/'+(role.alias[route]||route)+'.aspx'),'Exact active route '+role.folder+'/'+route);
   check(!(await overflow()),'No desktop overflow '+role.folder+'/'+route);pages++;
  }
  for(const route of ['MyMeetings','Schedule']){
   await page.goto(base+'/Pages/Meetings/'+route+'.aspx');
   check((await page.locator('body').getAttribute('class')).startsWith(role.folder.toLowerCase()),'Meetings uses verified shell '+role.folder);
   check((await nav.locator('[aria-current="page"]').getAttribute('href')).endsWith('/MyMeetings.aspx'),'Meetings alias '+role.folder);pages++;
  }
  await page.goto(base+'/Pages/'+role.folder+'/Dashboard.aspx');
  check(await width()===60,'Initially collapsed '+role.folder);
  await nav.hover();await settle();check(await width()===300,'Hover expands '+role.folder);
  const first=nav.locator('.uims-side-link').first();await first.focus();await page.mouse.move(700,70);await settle();
  check(await width()===300,'Focus retains expansion '+role.folder);
  await out();check(await width()===60,'Pointer and focus leaving collapses '+role.folder);
  await page.locator('.uims-sidebar-pin').focus();await settle();check(await width()===300,'Keyboard focus expands '+role.folder);
  await page.locator('.uims-sidebar-pin').click();await out();check(await width()===300,'Pinned persists without hover/focus '+role.folder);
  await page.reload();check(await width()===300,'Pin survives postback/navigation '+role.folder);
  await page.screenshot({path:'tests/artifacts/sidebar-'+role.folder.toLowerCase()+'-expanded.png',fullPage:true});
  await page.locator('.uims-sidebar-pin').click();await out();check(await width()===60,'Unpin collapses after focus leaves '+role.folder);
  check((await first.getAttribute('title')).length>0,'Collapsed tooltips '+role.folder);
  const icon=await first.locator('svg').boundingBox();await nav.hover();await settle();const expandedIcon=await first.locator('svg').boundingBox();
  check(Math.abs(icon.x-expandedIcon.x)<1,'Stationary icons '+role.folder);
  check(await page.locator('form form').count()===0&&await page.locator('form').count()===1,'One Web Forms form '+role.folder);
  check(await nav.locator('button:not([type="button"])').count()===0,'Menu buttons do not post back '+role.folder);
  await page.setViewportSize({width:390,height:844});
  await page.waitForFunction(()=>document.querySelector('[data-portal-sidebar]').inert);
  const toggle=page.getByRole('button',{name:'Open navigation',exact:true});
  check(await toggle.isVisible(),'Mobile toggle '+role.folder);
  check(await nav.evaluate(el=>el.inert&&el.getAttribute('aria-hidden')==='true'),'Closed panel excluded from focus and AT '+role.folder);
  await toggle.click();await settle();check(await width()===390,'Full viewport panel '+role.folder);
  check(await nav.locator('.uims-side-link .uims-sidebar-label').first().evaluate(el=>getComputedStyle(el).opacity==='1'&&getComputedStyle(el).visibility==='visible'),'Mobile labels visible '+role.folder);
  check(await page.locator('.uims-content').evaluate(el=>el.inert),'Background inert '+role.folder);
  check(await page.evaluate(()=>getComputedStyle(document.body).overflow==='hidden'),'Scroll locked '+role.folder);
  check(await nav.getAttribute('role')==='dialog'&&await nav.getAttribute('aria-modal')==='true','Accessible mobile dialog '+role.folder);
  await page.screenshot({path:'tests/artifacts/sidebar-'+role.folder.toLowerCase()+'-mobile.png',fullPage:true});
  await page.keyboard.press('Shift+Tab');check(await nav.locator('.uims-sidebar-signout').evaluate(el=>el===document.activeElement),'Reverse focus wraps '+role.folder);
  await page.keyboard.press('Tab');check(await page.locator('.student-nav-close').evaluate(el=>el===document.activeElement),'Forward focus wraps '+role.folder);
  await page.keyboard.press('Escape');check(await toggle.evaluate(el=>el===document.activeElement),'Escape restores focus '+role.folder);
  check(await nav.evaluate(el=>el.inert)&&await page.locator('.uims-content').evaluate(el=>!el.inert),'Close resets inert '+role.folder);
  await toggle.click();await nav.locator('.uims-side-link').first().click();await page.waitForURL('**/'+role.folder+'/Dashboard.aspx');
  check(await nav.evaluate(el=>el.inert),'Destination selection closes '+role.folder);
  await page.getByRole('button',{name:'Open navigation',exact:true}).click();await page.setViewportSize({width:1440,height:900});await settle();
  check(await nav.evaluate(el=>!el.inert)&&!await page.locator('body').evaluate(el=>el.classList.contains('student-nav-open')),'Resize resets mobile state '+role.folder);
  await out();check(await width()===60,'Mobile state does not pin desktop '+role.folder);
  await page.locator('.uims-sidebar-pin').click();await out();
  await page.setViewportSize({width:390,height:844});await page.getByRole('button',{name:'Open navigation',exact:true}).click();await page.keyboard.press('Escape');
  await page.setViewportSize({width:1440,height:900});await out();check(await width()===300,'Desktop pin survives mobile cycle '+role.folder);
  await page.locator('.uims-sidebar-pin').click();await out();
  await page.goto(base+'/Pages/'+role.wrong+'/Dashboard.aspx');check(page.url().includes('AccessDenied'),'Wrong role still blocked '+role.folder);
  await page.goto(base+'/Pages/'+role.folder+'/Dashboard.aspx');await nav.hover();await settle();await page.getByRole('link',{name:'Log out',exact:true}).click();
  await page.waitForURL('**/Account/Login.aspx');await page.goto(base+'/Pages/'+role.folder+'/Dashboard.aspx');check(page.url().includes('Login.aspx'),'Logout clears trusted session '+role.folder);
 }
 // Existing real form: menu interactions cannot submit; validation and successful postback still work.
 await page.setViewportSize({width:1440,height:900});await page.goto(base+'/__fixture.aspx');
 await page.locator('.uims-sidebar-pin').click();check(page.url().includes('Apply.aspx'),'Pin does not submit form');
 const submit=page.locator('input[type=submit],button[type=submit]').first();
 await submit.click();check(page.url().includes('Apply.aspx')&&await page.locator('textarea').evaluate(el=>el.validity.valueMissing),'Existing validation survives');
 await page.locator('textarea').fill('I would like to develop my engineering skills through supervised internship tasks.');await page.getByRole('checkbox').check();await submit.click();
 await page.waitForURL('**/Student/MyApplications.aspx*');
 check((await page.locator('body').innerText()).includes('Software Development Intern'),'Existing application postback succeeds');
 await nav.hover();await settle();await page.locator('.uims-sidebar-pin').click();await out();
 // Long menu/name stress, authentic role plus controlled fixture profile value.
 const person=await (await page.request.get(db+'/users/coordinator-one.json')).json();
 await page.request.put(db+'/users/coordinator-one.json',{data:{...person,FullName:'Coordinator with a deliberately very long university account name for layout testing'}});
 await page.goto(base+'/__fixture.aspx?user=coordinator-one');await nav.hover();await settle();
 await page.setViewportSize({width:1000,height:420});await settle();
 check(await page.locator('.uims-sidebar-navigation').evaluate(el=>el.scrollHeight>el.clientHeight),'Long menu scrolls independently');
 check(await nav.locator('.uims-sidebar-signout').isVisible(),'Logout remains reachable on short screen');
 check(!(await overflow()),'Long account name does not overflow');
 await page.locator('.uims-sidebar-signout').focus();check(await nav.locator('.uims-sidebar-signout').evaluate(el=>el.getBoundingClientRect().bottom<=innerHeight),'Logout within viewport');
 await page.setViewportSize({width:390,height:600});await page.getByRole('button',{name:'Open navigation',exact:true}).click();await settle();check(!(await overflow()),'Long mobile name contained');
 await page.screenshot({path:'tests/artifacts/sidebar-long-mobile.png'});
 await page.keyboard.press('Escape');await page.evaluate(()=>document.documentElement.dir='rtl');
 await page.getByRole('button',{name:'Open navigation',exact:true}).click();await settle();check(await nav.evaluate(el=>el.getBoundingClientRect().x===0),'RTL panel opens fully');
 await page.screenshot({path:'tests/artifacts/sidebar-rtl-mobile.png'});await page.keyboard.press('Escape');await settle();
 check(await nav.evaluate(el=>el.getBoundingClientRect().x>=innerWidth-1),'RTL panel exits toward inline start');
 await page.setViewportSize({width:1440,height:900});await out();
 check(await nav.evaluate(el=>Math.abs(el.getBoundingClientRect().right-innerWidth)<1),'RTL rail on correct edge');
 check(!(await overflow()),'RTL no horizontal overflow');await page.evaluate(()=>document.documentElement.removeAttribute('dir'));
 await page.emulateMedia({reducedMotion:'reduce'});await nav.hover();check(await nav.evaluate(el=>getComputedStyle(el).transitionDuration==='0s'),'Reduced motion removes transitions');await page.emulateMedia({reducedMotion:'no-preference'});
 // Reinitialization, as invoked after partial postbacks, must not duplicate listeners.
 await page.evaluate(()=>{localStorage.setItem('uims.sidebar.pinned','false');for(let i=0;i<5;i++)window.UimsPortalNavigation.init();});
 const before=await page.locator('.uims-sidebar-pin').getAttribute('aria-pressed');await page.locator('.uims-sidebar-pin').click();check(await page.locator('.uims-sidebar-pin').getAttribute('aria-pressed')!==before,'Idempotent initialization');
 await page.locator('.uims-sidebar-pin').click();await out();
 for(const viewport of [{width:320,height:640},{width:768,height:900},{width:900,height:700},{width:901,height:700},{width:1920,height:1080}]) {
  await page.setViewportSize(viewport);await settle();check(!(await overflow()),'No overflow at '+viewport.width);
 }
 const context=await page.context().browser().newContext({javaScriptEnabled:false,viewport:{width:390,height:844}});const staticPage=await context.newPage();await staticPage.goto(base+'/__fixture.aspx');
 check(await staticPage.locator('.uims-side-link').first().isVisible(),'No-JS navigation usable');await context.close();
 await page.request.put(db+'/users/coordinator-one.json',{data:person});
 await page.setViewportSize({width:1440,height:900});await page.mouse.move(700,70);await page.goto(base+'/__fixture.aspx?user=coordinator-one');
 await page.screenshot({path:'tests/artifacts/sidebar-coordinator-collapsed.png',fullPage:true});
 await page.locator('.uims-sidebar-pin').focus();await page.keyboard.press('Tab');
 check(await nav.locator('.uims-side-link').first().evaluate(el=>el===document.activeElement),'Desktop Tab navigates expanded menu');
 await out();
 await page.evaluate(()=>{const old=document.querySelector('[data-portal-sidebar]');old.replaceWith(old.cloneNode(true));window.UimsPortalNavigation.init();window.UimsPortalNavigation.init();});
 await page.locator('.uims-sidebar-pin').click();check(await page.locator('.uims-sidebar-pin').getAttribute('aria-pressed')==='true','Replacement panel reinitializes without duplicate listeners');
 await page.locator('.uims-sidebar-pin').click();await out();
 check(errors.length===0,'No browser errors: '+errors.join('; '));
 return {passed:checks,protectedPages:pages,roles:4,consoleErrors:errors};
}
