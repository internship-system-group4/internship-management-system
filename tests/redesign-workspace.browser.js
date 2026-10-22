async page => {
 const base='http://localhost:58013',db='http://localhost:4930/firebase',checks=[],routes=[],errors=[];
 page.setDefaultTimeout(7000);page.setDefaultNavigationTimeout(25000);
 const check=(ok,label)=>{if(!ok)throw Error(label);checks.push(label);};
 const put=async(path,data)=>page.request.put(db+'/'+path+'.json',{data});
 const get=async path=>(await page.request.get(db+'/'+path+'.json')).json();
 const login=async id=>{await page.context().clearCookies();await page.goto(base+'/__fixture.aspx?user='+id);};
 const dashboard=role=>page.goto(base+'/Pages/'+role+'/Dashboard.aspx');
 page.on('pageerror',error=>errors.push({url:page.url(),message:error.message}));
 for(const [role,id,count] of [['Student','student-one',5],['Company','supervisor-one',4],['Academic','academic-one',4],['Coordinator','coordinator-one',4]]){
  await login(id);
  for(const width of [1440,390]){
   await page.setViewportSize({width,height:1000});await dashboard(role);await page.waitForTimeout(650);
   check(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1),role+' fits '+width);
   check(await page.locator('[data-journey-template]').count()===count,role+' has actual workflow stages '+width);
   check(await page.locator('.ws-page-heading h2').evaluate(el=>parseFloat(getComputedStyle(el).fontSize)>=32),role+' heading is readable '+width);
   if(width===1440)check(await page.locator('.uims-sidebar-label').first().isVisible(),role+' desktop labels visible');
   const stageButtons=page.locator('[data-journey-template]');
   for(let i=0;i<count;i++){
    const button=stageButtons.nth(i);await button.click();const modal=page.locator('.ws-journey-modal.show');await modal.waitFor({state:'visible'});await page.waitForTimeout(340);
    check(await modal.getAttribute('role')==='dialog',role+' stage '+i+' exposes modal '+width);
    check(await modal.locator('.modal-title').innerText()===await button.getAttribute('data-journey-title'),role+' stage title matches '+i+' '+width);
    check(await modal.locator('a[href]').count()>0,role+' stage action has destination '+i+' '+width);
    if(i===2&&role==='Student'){
     check((await modal.innerText()).includes('72')&&(await modal.innerText()).includes('16'),'Approved and pending are separated in journey');
     await page.screenshot({path:'tests/artifacts/redesign-journey-modal-'+width+'.png',fullPage:width===390});
    }
    await page.keyboard.press('Tab');check(await modal.evaluate(el=>el.contains(document.activeElement)),role+' focus contained '+i+' '+width);
    await page.keyboard.press('Escape');await modal.waitFor({state:'hidden'});await page.waitForFunction(()=>!document.querySelector('.modal-backdrop'));
    check(await button.evaluate(el=>document.activeElement===el),role+' stage focus returned '+i+' '+width);
   }
   // Return marker to its actual current stage for the comparison capture.
   await dashboard(role);await page.waitForTimeout(650);await page.screenshot({path:'tests/artifacts/redesign-after-'+role+'-dashboard-'+width+'.png',fullPage:true});
  }
 }
 await login('student-one');await dashboard('Student');
 check(await page.locator('[aria-current="step"]').count()===1,'Student has one actual current stage');
 check(!((await page.locator('body').innerText()).includes('INTERNAL COMPANY ASSESSMENT'))&&!((await page.locator('body').innerText()).includes('PRIVATE OTHER COHORT')),'Student dashboard contains no confidential evaluation content');
 check((await page.locator('[data-journey-title="Completion"]').getAttribute('data-stage-state'))==='upcoming','Hours do not imply coordinator completion');
 const progress=page.locator('[data-ui-progress]').first();
 check(await progress.getAttribute('aria-valuenow')==='45','72 approved of 160 is 45 percent');
 const hours=await get('trainingHours/hours-approved');await put('trainingHours/hours-approved',{...hours,Hours:190});await dashboard('Student');
 check((await progress.getAttribute('aria-valuetext')).includes('190 approved')&&await progress.getAttribute('aria-valuenow')==='100','Over target values remain truthful with a bounded bar');
 const placement=await get('placements/student-one');await put('placements/student-one',{...placement,RequiredHours:0});await dashboard('Student');
 check(await progress.getAttribute('aria-valuenow')===null&&(await progress.getAttribute('aria-valuetext')).includes('not set'),'Zero target never invents completion');
 await put('placements/student-one',placement);await put('trainingHours/hours-approved',hours);
 const record=await get('completions/completion-one');await put('completions/completion-one',{...record,Status:4,ApprovedAt:Date.now()});await dashboard('Student');
 check(await page.locator('[data-journey-title="Completion"]').getAttribute('data-stage-state')==='completed','Only approved coordinator record completes student journey');
 await put('completions/completion-one',record);
 await login('academic-one');await dashboard('Academic');
 check(!((await page.locator('body').innerText()).includes('Private cohort student')),'Academic dashboard excludes another cohort');
 check(await page.locator('[data-workspace-row]').count()===2,'Assigned-student dashboard is scoped');
 await page.goto(base+'/Pages/Academic/StudentProgress.aspx?id=student-private');
 check(!((await page.locator('body').innerText()).includes('PRIVATE OTHER COHORT')),'Unassigned progress does not disclose internal data');
 await page.goto(base+'/Pages/Academic/FinalEvaluation.aspx');
 const opener=page.locator('[id*="btnOpenModal"]').first();await opener.click();await page.locator('#evaluationModal.show').waitFor({state:'visible'});
 await page.locator('[id$="hfSelectedStudentId"]').evaluate(el=>el.value='student-private');
 await page.locator('[id$="ddlPassFail"]').selectOption({index:1});
 await page.evaluate(()=>window.confirm=()=>true);await page.locator('[id$="btnSubmitEvaluation"]').click();
 check(Object.values(await get('academicFinalEvaluations')).filter(e=>e.StudentId==='student-private').length===1,'Tampered academic evaluation cannot write another assigned group');
 await login('student-one');await page.goto(base+'/Pages/Coordinator/CompletionReview.aspx');check(page.url().includes('AccessDenied'),'Completion remains coordinator-only');
 await page.emulateMedia({reducedMotion:'reduce'});await dashboard('Student');
 await page.locator('[data-journey-title="Training"]').click();await page.locator('.ws-journey-modal.show').waitFor({state:'visible'});
 check(await page.locator('.ws-journey-modal .modal-dialog').evaluate(el=>getComputedStyle(el).transitionDuration)==='0s','Reduced motion removes modal travel');
 await page.keyboard.press('Escape');await page.locator('.ws-journey-modal').waitFor({state:'hidden'});await page.emulateMedia({reducedMotion:'no-preference'});
 // Read failures are actual HTTP failures from the local dependency simulation.
 await page.request.post(db+'/__fail-monitoring');
 for(const [role,id] of [['Student','student-one'],['Company','supervisor-one'],['Academic','academic-one'],['Coordinator','coordinator-one']]){
  await login(id);await dashboard(role);await page.waitForTimeout(650);
  check(await page.locator('[role="alert"]:visible').count()>0,role+' real read failure has persistent error');
  check(await page.locator('[data-journey-template]').count()===0,role+' failure does not fabricate journey');
  await page.screenshot({path:'tests/artifacts/redesign-error-'+role+'-390.png',fullPage:true});
 }
 await page.request.post(db+'/__restore-monitoring');
 // Empty state: retain the four authorized users and remove their training records.
 for(const collection of ['placements','applications','tasks','submissions','trainingHours','taskEvaluations','completions','companyFinalEvaluations','academicFinalEvaluations'])await put(collection,{});
 const student=await get('users/student-one');await put('users/student-one',{...student,AcademicSupervisorId:''});const second=await get('users/student-two');await put('users/student-two',{...second,AcademicSupervisorId:''});
 for(const [role,id] of [['Student','student-one'],['Company','supervisor-one'],['Academic','academic-one'],['Coordinator','coordinator-one']]){
  await login(id);await dashboard(role);await page.waitForTimeout(650);check(await page.locator('.ws-empty:visible').count()>0,role+' has a truthful empty state');
  await page.screenshot({path:'tests/artifacts/redesign-empty-'+role+'-390.png',fullPage:true});
 }
 check(errors.length===0,'No uncaught page errors');
 return {passed:checks.length,checks,errors,scope:'Disposable Web Forms app + local Postman dependencies; no live verification.'};
}
