async page => {
 const base='http://localhost:58013',db='http://localhost:4930/firebase',checks=[];
 const check=(ok,label)=>{if(!ok)throw Error(label);checks.push(label);};
 const get=async p=>(await page.request.get(db+'/'+p+'.json')).json();
 const put=async(p,data)=>page.request.put(db+'/'+p+'.json',{data});
 const login=async id=>{await page.context().clearCookies();await page.goto(base+'/__fixture.aspx?user='+id);};
 await page.setViewportSize({width:1440,height:1000});await login('student-one');await page.goto(base+'/Pages/Student/Dashboard.aspx');await page.waitForTimeout(750);
 const progress=page.locator('[data-ui-progress]').first();
 const originalHours=await get('trainingHours/hours-approved');await put('trainingHours/hours-approved',{...originalHours,Hours:104});
 // Exercise the shared refresh lifecycle with the confirmed dependency value.
 const confirmed=await get('trainingHours/hours-approved');
 const motion=await progress.evaluate((el,hours)=>{el.dataset.uiApproved=hours;UimsUI.refresh();const animation=el.getAnimations().find(a=>a.effect.getKeyframes().some(f=>f.width));const frames=animation?.effect.getKeyframes();UimsUI.refresh();return {from:frames?.[0].width,to:frames?.at(-1).width,stable:el.getAnimations().includes(animation)};},confirmed.Hours);
 check(motion.from==='45%'&&motion.to==='65%'&&motion.stable,'Progress animates previous true 45 to confirmed 65 without refresh replay');
 await page.emulateMedia({reducedMotion:'reduce'});await progress.evaluate(el=>{el.dataset.uiApproved='72';UimsUI.refresh();});check(await progress.evaluate(el=>el.getAnimations().length)===0,'Reduced motion cancels progress movement');await page.emulateMedia({reducedMotion:'no-preference'});
 await progress.evaluate(el=>{el.dataset.uiTarget='0';UimsUI.refresh();el.dataset.uiTarget='160';UimsUI.refresh();});check(await page.locator('[data-ui-progress-note]').count()===0,'Restored target removes stale missing-target explanation');await put('trainingHours/hours-approved',originalHours);
 // Opportunity eligibility is checked on list and direct application URLs.
 const opportunity=await get('opportunities/internship-one');await put('placements/student-one',null);await put('applications',{});
 for(const patch of [{EligibleMajors:['Architecture']},{EligibleCollege:'Business',EligibleMajors:[]}]){
  await put('opportunities/internship-one',{...opportunity,...patch});await page.goto(base+'/Pages/Student/Opportunities.aspx');check(!((await page.locator('body').innerText()).includes('Software Development Intern')),'Opportunity list respects '+Object.keys(patch)[0]);
  await page.goto(base+'/Pages/Student/Apply.aspx?id=internship-one');check((await page.getByRole('alert').innerText()).includes('college or major'),'Direct application respects '+Object.keys(patch)[0]);
 }
 await put('opportunities/internship-one',opportunity);
 await put('applications/accepted-stage',{Id:'accepted-stage',StudentId:'student-one',CompanyId:'company-one',OpportunityId:'internship-one',Status:1,SubmittedAt:Date.now()});await page.goto(base+'/Pages/Student/Dashboard.aspx');
 check(await page.locator('[aria-current="step"]').count()===1,'Accepted offer has one current journey stage');
 check(await page.locator('[data-journey-title="Application"]').getAttribute('data-stage-state')==='completed'&&await page.locator('[data-journey-title="Placement"]').getAttribute('data-stage-state')==='current','Accepted application advances to offer confirmation');

 // Lina has hours and a company final, but no academic final yet.
 await login('coordinator-one');await page.goto(base+'/Pages/Coordinator/Dashboard.aspx');
 await page.goto(base+'/Pages/Coordinator/CompletionReview.aspx?id=student-two');check(await page.locator('[id$="btnApprove"]').isDisabled(),'Incomplete evaluation gate disables coordinator approval');
 const final={Id:'academic-lina',PlacementId:'student-two',StudentId:'student-two',AcademicSupervisorId:'academic-one',IsSubmitted:true,TotalScore:100,MaxScore:100,SubmittedAt:Date.now()};
 await put('academicFinalEvaluations/academic-lina',final);
 const company=await get('companyFinalEvaluations/final-lina');await put('companyFinalEvaluations/final-lina',{...company,TotalScore:100,MaxScore:100});
 await page.goto(base+'/Pages/Coordinator/Dashboard.aspx');check(await page.locator('[data-workspace-row="student-two"]').evaluate(el=>el.classList.contains('ws-row-changed')),'Only changed completion row highlights after confirmed data update');
 await page.goto(base+'/Pages/Coordinator/CompletionReview.aspx?id=student-two');check(await page.locator('[id$="btnApprove"]').isEnabled(),'Passing finals and approved hours unlock coordinator review');
 await page.evaluate(()=>window.confirm=()=>true);await page.locator('[id$="btnApprove"]').click();await page.waitForURL('**/*done=approved');
 const completion=Object.values(await get('completions')).find(r=>r.StudentId==='student-two');check(completion.Status===4&&completion.ReviewedByCoordinatorId==='coordinator-one','Real coordinator handler stores approved completion');
 await login('student-two');await page.goto(base+'/Pages/Student/Dashboard.aspx');check(await page.locator('[data-journey-title="Completion"]').getAttribute('data-stage-state')==='completed','Student journey reflects actual coordinator write');
 check(!((await page.locator('body').innerText()).includes('INTERNAL COMPANY ASSESSMENT')),'Approved student dashboard still excludes internal evaluation comments');
 return {passed:checks.length,checks,scope:'Local dependency fixtures only; native confirmation auto-accepted in test harness.'};
}
