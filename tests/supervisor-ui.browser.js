// Start tests/Start-LoginTestHost.ps1 with the existing local fixture service.
// Copy tests/fixtures/supervisor-components.aspx to TestRoot/__supervisor-kit.aspx.
// UI-only: no grading, applications, account changes, or other write actions are submitted.
async page => {
 const base=new URL(page.url()).origin,checks=[],errors=[],routes=[];
 const check=(ok,name)=>{if(!ok)throw Error(name);checks.push(name);};
 const context=await page.context().browser().newContext({viewport:{width:1440,height:1000},reducedMotion:'reduce'}),p=await context.newPage();
 p.on('pageerror',e=>errors.push(e.message));
 const groups={
  'supervisor-one':['Company/Dashboard.aspx','Company/ManageOpportunities.aspx','Company/Opportunities.aspx','Company/Applications.aspx','Company/Trainees.aspx','Company/Tasks.aspx','Company/TaskReview.aspx','Company/FinalEvaluation.aspx','Company/EvaluationReport.aspx','Company/Account.aspx'],
  'academic-one':['Academic/Dashboard.aspx','Academic/StudentProgress.aspx','Academic/FinalEvaluation.aspx','Academic/Account.aspx']
 };
 for(const [user,paths] of Object.entries(groups)){
  await p.goto(base+'/__fixture.aspx?user='+user);
  for(const path of paths){
   const response=await p.goto(base+'/Pages/'+path);await p.waitForTimeout(80);
   check(response.status()===200&&!/Server Error in|Compilation Error|Parser Error/.test(await p.locator('body').innerText()),'Page renders: '+path);
   check(await p.locator('body.uims-supervisor').count()===1&&await p.evaluate(()=>!!window.UimsSupervisorUI),'Scoped presentation loaded: '+path);
   routes.push(path);
   for(const theme of ['light','dark']){
    await p.evaluate(t=>window.UimsTheme.set(t),theme);
    const measured=await p.evaluate(()=>({
     overflow:document.documentElement.scrollWidth>innerWidth+1,
     buttons:[...document.querySelectorAll('.su-button')].filter(e=>e.getClientRects().length&&!e.closest('.modal:not(.show),[hidden]')).map(e=>{const s=getComputedStyle(e);return {height:e.getBoundingClientRect().height,radius:s.borderRadius,font:s.fontSize};}),
     missingFields:[...document.querySelectorAll('.su-field')].filter(e=>e.getClientRects().length&&!e.labels?.length&&!e.getAttribute('aria-label')&&!e.getAttribute('aria-labelledby')).map(e=>e.id)
    }));
    check(!measured.overflow,'No desktop overflow: '+theme+'/'+path);
    check(measured.buttons.every(b=>b.height>=43.5&&b.radius==='8px'&&b.font==='16px'),'Consistent visible buttons: '+theme+'/'+path);
    check(!measured.missingFields.length,'Fields have accessible names: '+path+' '+measured.missingFields.join(','));
   }
  }
 }
 for(const role of ['company','academic']){
  await p.goto(base+'/__fixture.aspx?user='+(role==='company'?'supervisor-one':'academic-one'));
  await p.goto(base+'/__supervisor-kit.aspx?role='+role);
  check(await p.locator('.su-badge').count()===3,'All semantic badge variants normalized: '+role);
  check(await p.locator('#kitProgress').getAttribute('aria-valuenow')==='65','Progress uses approved/required values: '+role);
  check(await p.locator('#kitPaperBadge').getAttribute('class')==='badge','Printable content excluded: '+role);
  for(const theme of ['light','dark']){
   await p.evaluate(t=>window.UimsTheme.set(t),theme);
   const contrast=await p.evaluate(()=>{
    const rgb=s=>(s.match(/[\d.]+/g)||[]).slice(0,3).map(Number),lum=c=>c.map(n=>{n/=255;return n<=.04045?n/12.92:((n+.055)/1.055)**2.4;}).reduce((s,n,i)=>s+n*[.2126,.7152,.0722][i],0);
    return [...document.querySelectorAll('.su-badge,#kitPrimary,#kitSecondary,#kitDanger')].map(e=>{const s=getComputedStyle(e),a=lum(rgb(s.color)),b=lum(rgb(s.backgroundColor));return (Math.max(a,b)+.05)/(Math.min(a,b)+.05);});
   });
   check(contrast.every(n=>n>=4.5),'Button and badge text contrast: '+role+'/'+theme);
   await p.screenshot({path:`tests/artifacts/supervisor-kit-${role}-${theme}.png`,fullPage:true});
  }
  await p.locator('#kitOpen').click();await p.locator('#kitModal.show').waitFor();
  check(await p.locator('#kitModal').getAttribute('aria-modal')==='true','Bootstrap dialog semantics retained: '+role);
  check(await p.locator('#kitCheck').evaluate(e=>e.labels.length>0&&getComputedStyle(e).width==='20px'),'Checkbox label and sizing: '+role);
  await p.locator('#kitCheck').focus();await p.keyboard.press('Space');check(await p.locator('#kitCheck').isChecked(),'Native checkbox keyboard activation: '+role);
  await p.locator('#kitComment').fill('Synthetic feedback');await p.keyboard.press('Escape');await p.locator('#kitModal.show').waitFor({state:'hidden'});
  await p.waitForFunction(()=>document.activeElement===document.getElementById('kitOpen'));
  check(await p.locator('#kitOpen').evaluate(e=>e===document.activeElement),'Dialog returns keyboard focus: '+role);
 }
 await p.goto(base+'/__fixture.aspx?user=supervisor-one');await p.goto(base+'/Pages/Company/Tasks.aspx');
 await p.evaluate(()=>window.showTaskForm());await p.waitForTimeout(100);
 check(await p.locator('#taskCreateView').evaluate(e=>e.contains(document.activeElement)),'Task dialog moves focus inside');
 await p.keyboard.press('Shift+Tab');check(await p.locator('#taskCreateView').evaluate(e=>e.contains(document.activeElement)),'Task dialog traps keyboard focus');
 await p.keyboard.press('Escape');await p.waitForTimeout(100);
 check(!await p.locator('#taskCreateView').isVisible(),'Task dialog Escape closes');
 await p.goto(base+'/Pages/Company/ManageOpportunities.aspx');
 const opportunityOpener=p.locator('.mo-heading .mo-btn').first();await opportunityOpener.focus();
 await p.evaluate(()=>window.showToggleDialog('synthetic-only','UI fixture opportunity','deactivate'));await p.waitForTimeout(100);
 check(await p.locator('#moDialog').evaluate(e=>e.contains(document.activeElement)),'Opportunity confirmation focuses inside');
 check(await p.locator('#moConfirmButton').getAttribute('value')==='toggle'&&!(await p.locator('#moConfirmButton').innerText()).includes('class='),'Confirmation markup is clean and original submit value is preserved');
 await p.keyboard.press('Escape');await p.waitForTimeout(100);
 check(!await p.locator('#moDialog').isVisible()&&await opportunityOpener.evaluate(e=>document.activeElement===e),'Opportunity confirmation closes and returns focus');
 await p.goto(base+'/__fixture.aspx?user=academic-one');await p.goto(base+'/Pages/Academic/StudentProgress.aspx');
 await p.locator('input[id$=txtSearch]').fill('No matching student');
 await Promise.all([p.waitForNavigation(),p.locator('input[id$=btnSearch]').click()]);
 check(await p.locator('input[id$=txtSearch]').inputValue()==='No matching student','Academic search server postback preserved');
 for(const [user,paths] of Object.entries({
  'supervisor-one':['Company/Dashboard.aspx','Company/Trainees.aspx','Company/Tasks.aspx','Company/Applications.aspx','Company/Opportunities.aspx','Company/Account.aspx'],
  'academic-one':['Academic/Dashboard.aspx','Academic/StudentProgress.aspx','Academic/Account.aspx']
 })){
  await context.addCookies([{name:'uims-lang',value:'ar',url:base}]);await p.goto(base+'/__fixture.aspx?user='+user);
  await p.setViewportSize({width:390,height:844});
  for(const path of paths){
   await p.goto(base+'/Pages/'+path);await p.evaluate(()=>window.UimsTheme.set('dark'));
   check(await p.locator('html').getAttribute('dir')==='rtl'&&await p.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1),'Arabic Dark phone layout: '+path);
   if(path.endsWith('Dashboard.aspx')||path.endsWith('Tasks.aspx'))await p.screenshot({path:'tests/artifacts/supervisor-phone-'+path.split('/')[0]+'-'+path.split('/')[1]+'.png',fullPage:true});
  }
 }
 for(const [user,path] of [['supervisor-one','Company/Tasks.aspx'],['academic-one','Academic/Dashboard.aspx']]){
  await context.addCookies([{name:'uims-lang',value:'en',url:base}]);await p.goto(base+'/__fixture.aspx?user='+user);
  for(const viewport of [{width:375,height:812},{width:844,height:390}]){
   await p.setViewportSize(viewport);await p.goto(base+'/Pages/'+path);
   for(const size of ['100%','200%']){
    await p.evaluate(value=>document.documentElement.style.fontSize=value,size);
    check(await p.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1),'Small/landscape text scaling: '+path+'/'+viewport.width+'/'+size);
   }
  }
 }
 for(const [user,path] of [['student-one','Student/Dashboard.aspx'],['coordinator-one','Coordinator/Dashboard.aspx']]){
  await p.goto(base+'/__fixture.aspx?user='+user);await p.goto(base+'/Pages/'+path);
  check(await p.locator('body.uims-supervisor').count()===0&&!await p.evaluate(()=>!!window.UimsSupervisorUI)&&await p.locator('link[href*=supervisor-ui]').count()===0,'Other role unchanged: '+path);
 }
 await context.close();check(!errors.length,'No uncaught browser errors: '+errors.join(' | '));
 return {passed:checks.length,routes,checks};
}
