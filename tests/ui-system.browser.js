async page => {
 page.setDefaultTimeout(6000);page.setDefaultNavigationTimeout(20000);
 const base='http://localhost:58001',db='http://localhost:4920/firebase';
 const checks=[],routes=[],errors=[];
 const check=(ok,name)=>{checks.push({name,passed:!!ok});if(!ok)throw Error(name);};
 const get=async path=>(await page.request.get(db+'/'+path+'.json')).json();
 const put=async(path,data)=>{const r=await page.request.put(db+'/'+path+'.json',{data});if(!r.ok())throw Error('Fixture seed '+path);};
 const login=async id=>{await page.context().clearCookies();await page.goto(base+'/__fixture.aspx?user='+id);};
 const go=route=>page.goto(base+'/'+route);
 page.on('pageerror',error=>errors.push({url:page.url(),message:error.message}));
 await page.request.post(db+'/__reset');
 for(const [Id,Role] of [['academic-one',3],['coordinator-one',4]])await put('users/'+Id,{Id,Role,FullName:Role===3?'Academic Supervisor':'Internship Coordinator',Email:Id+'@example.test',IsActive:true,MustChangePassword:false});
 const student=await get('users/student-one');
 await put('users/student-one',{...student,ApprovedHours:72,RequiredHours:160,AcademicSupervisorId:'academic-one'});
 const placement={Id:'student-one',StudentId:'student-one',StudentName:'Osama Banihani',CompanyId:'company-one',CompanyName:'Training Company',CompanySupervisorId:'supervisor-one',CompanySupervisorName:'Company Supervisor',AcademicSupervisorId:'academic-one',OpportunityId:'internship-one',OpportunityTitle:'Software Development Intern',RequiredHours:160,ApprovedHours:72,Status:2,ConfirmedAt:Date.now(),StartDate:Date.now(),EndDate:Date.now()+86400000*90};
 await put('placements/student-one',placement);
 const hours={PlacementId:'student-one',StudentId:'student-one',Hours:72,Status:1,WorkDate:Date.now(),ReportedAt:Date.now(),Description:'Approved fixture work'};
 await put('trainingHours',{approved:hours,pending:{...hours,Hours:40,Status:0,Description:'Pending fixture work'}});
 await put('tasks/ui-task',{Id:'ui-task',PlacementId:'student-one',StudentId:'student-one',CompanyId:'company-one',Title:'Prepare an accessible form',Description:'Use labels and validation.',Instructions:'Submit a link.',MaxScore:10,Weight:1,Deadline:Date.now()+86400000,Status:0,CreatedBySupervisorId:'supervisor-one',Criteria:[{Id:'criterion-one',Name:'Usability',Description:'Clear field labels',MaxScore:10,Weight:100}]});
 const sets={
  Public:['Default.aspx','Pages/Public/About.aspx','Pages/Public/Contact.aspx','Pages/Public/PoweredBy.aspx','Pages/Public/AccessDenied.aspx','Pages/Account/Login.aspx','Pages/Account/ForgotPassword.aspx'],
  Student:['Dashboard','Apply?opportunityId=internship-one','DisplayEditProfile','exploreOpport','MyApplications','MyTasks','Opportunities','OpportunityDetails?id=internship-one','Profile','Progress','StudentCVPortfolio'],
  Company:['Account','Applications','Dashboard','FinalEvaluation','ManageOpportunities','Opportunities','TaskReview','Tasks','TraineeDetails?id=student-one','Trainees','ViewOpportunity?id=internship-one'],
  Academic:['Account','Dashboard','FinalEvaluation?id=student-one','StudentProgress?id=student-one'],
  Coordinator:['AcademicSupervisors','Account','AddStudent','Companies','CompletionReview','ConfiguredGroups','ContactMessages','Dashboard','Groups','ManageStudents','PlacementDetails?id=student-one','Placements','Students']
 };
 for(const [role,list] of Object.entries(sets)){
  if(role==='Public')await page.context().clearCookies();else await login({Student:'student-one',Company:'supervisor-one',Academic:'academic-one',Coordinator:'coordinator-one'}[role]);
  for(const name of list){
   const [stem,query]=name.split('?');const route=role==='Public'?name:'Pages/'+role+'/'+stem+'.aspx'+(query?'?'+query:'');
   for(const width of [1440,390]){
    await page.setViewportSize({width,height:1000});const response=await go(route);
    const result=await page.evaluate(()=>({title:document.title,foundation:!!window.UimsUI,tokens:getComputedStyle(document.documentElement).getPropertyValue('--ui-primary').trim(),overflow:document.documentElement.scrollWidth>innerWidth+1,serverError:document.title.includes('Error')||document.body.innerText.includes('Server Error in'),url:location.pathname}));
    routes.push({route,width,status:response.status(),...result});
   }
  }
 }
 await login('student-one');
 for(const route of ['Pages/Account/Notifications.aspx','Pages/Account/ChangePassword.aspx','Pages/Meetings/MyMeetings.aspx','Pages/Meetings/Schedule.aspx']){const response=await go(route);routes.push({route,width:390,status:response.status(),...(await page.evaluate(()=>({foundation:!!window.UimsUI,overflow:document.documentElement.scrollWidth>innerWidth+1,serverError:document.body.innerText.includes('Server Error in'),url:location.pathname})))});}
 // Negative checks for direct document endpoints: no authorized fixture document exists.
 for(const route of ['Pages/Account/CompletionReport.aspx?id=student-one','Pages/Company/ApplicantDocument.aspx?id=missing&type=portfolio']){const response=await go(route);routes.push({route,width:390,status:response.status(),kind:'authorization/document negative check',url:new URL(page.url()).pathname});}
 check(routes.every(r=>r.status<500&&!r.serverError),'Every inventory route avoids a server error');
 // Data-backed dashboard captures, one final pair per role.
 for(const [role,id] of [['Student','student-one'],['Company','supervisor-one'],['Academic','academic-one'],['Coordinator','coordinator-one']]){
  await login(id);for(const width of [1440,390]){await page.setViewportSize({width,height:1000});await go('Pages/'+role+'/Dashboard.aspx');await page.waitForTimeout(320);await page.screenshot({path:'tests/artifacts/ui-after-'+role+'-'+width+'.png',fullPage:true});check(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1),role+' dashboard fits '+width);if(role==='Company'&&width===390)check(await page.locator('.ui-table-hint:visible').count()===0,'Empty company table does not request horizontal scrolling');if(role==='Academic'&&width===390)check(await page.locator('.ui-table-hint:visible').count()>0,'Real overflowing columns expose scrolling guidance');}
 }
 await login('student-one');await go('Pages/Student/Progress.aspx');
 const progress=page.locator('[data-ui-progress]').first();
 check((await progress.getAttribute('aria-valuetext')).includes('72 approved hours'),'Progress uses approved 72 hours, excludes pending 40');
 await put('trainingHours/approved',{...hours,Hours:190});await go('Pages/Student/Progress.aspx');
 check((await progress.getAttribute('aria-valuetext')).includes('190 approved hours')&&(await progress.getAttribute('aria-valuenow'))==='100','Over target remains truthful and visually bounded');
 await put('placements/student-one',{...placement,RequiredHours:0});await put('users/student-one',{...student,RequiredHours:0,AcademicSupervisorId:'academic-one'});await go('Pages/Student/Progress.aspx');
 check(await progress.getAttribute('aria-valuenow')===null&&(await progress.getAttribute('aria-valuetext')).includes('not set'),'Missing requirement is explicit');
 await put('placements/student-one',placement);await put('users/student-one',{...student,RequiredHours:160,AcademicSupervisorId:'academic-one'});await put('trainingHours/approved',hours);
 // Company custom modal: real opener, keyboard containment, Escape and focus return.
 await login('supervisor-one');await go('Pages/Company/Tasks.aspx');
 const open=page.locator('button[onclick="showTaskForm()"]');await open.click();
 const dialog=page.locator('#taskModal');await dialog.waitFor({state:'visible'});
 check(await dialog.getAttribute('role')==='dialog','Custom modal exposes dialog semantics');
 await page.waitForFunction(()=>document.getElementById('taskModal').contains(document.activeElement));
 const last=dialog.locator('button,input,select,textarea,a[href]').filter({visible:true}).last();await last.focus();await page.keyboard.press('Tab');
 check(await page.evaluate(()=>document.getElementById('taskModal').contains(document.activeElement)),'Custom modal contains Tab');
 await page.waitForTimeout(300);await page.screenshot({path:'tests/artifacts/ui-modal-mobile.png',fullPage:true});
 await page.keyboard.press('Escape');await dialog.waitFor({state:'hidden'});
 check(await open.evaluate(el=>el===document.activeElement),'Custom modal restores opener focus');
 await page.emulateMedia({reducedMotion:'reduce'});await open.click();
 check(await dialog.evaluate(el=>getComputedStyle(el.querySelector('.task-modal-dialog')||el).animationDuration)==='0s','Reduced motion removes modal travel');
 await page.keyboard.press('Escape');await dialog.waitFor({state:'hidden'});await page.emulateMedia({reducedMotion:'no-preference'});
 // Coordinator real full postback, client validation and duplicate suppression during a delayed real request.
 await login('coordinator-one');await go('Pages/Coordinator/Account.aspx');
 const name=page.locator('input[id$="txtName"]'),save=page.locator('[id$="btnSave"]');
 await name.fill('');await save.click();
 check(await page.locator('[data-ui-error-summary]').isVisible(),'Web Forms validation has actionable summary');
 check(await name.getAttribute('aria-invalid')==='true','Failed field is associated with error');
 await page.screenshot({path:'tests/artifacts/ui-validation-mobile.png',fullPage:true});
 await name.fill('Coordinator UI fixture');let posts=0;
 await page.route('**/Pages/Coordinator/Account.aspx',async route=>{if(route.request().method()==='POST'){posts++;await new Promise(resolve=>setTimeout(resolve,1800));}await route.continue();});
 const navigation=page.waitForNavigation({timeout:15000});
 const busy=await page.evaluate(()=>{const button=document.querySelector('[id$="btnSave"]');button.click();const result={disabled:button.disabled,aria:button.getAttribute('aria-disabled'),state:button.dataset.uiState};button.click();return result;});
 check(!busy.disabled&&busy.aria==='true'&&busy.state==='loading','Busy preserves posted submit control name');
 // Cross-document POST busy state is asserted atomically above; no blank navigation screenshot is claimed.
 await navigation;await page.unroute('**/Pages/Coordinator/Account.aspx');
 check(posts===1,'Duplicate click sends exactly one POST');
 check((await get('users/coordinator-one')).FullName==='Coordinator UI fixture','Server confirms coordinator profile save');
 check((await page.locator('[id$="btnSave"]').getAttribute('data-ui-state'))!=='loading','Full postback restores actionable button');
 // Academic mutation uses current server placement ownership.
 await login('academic-one');await go('Pages/Academic/StudentProgress.aspx?id=student-one');
 await page.locator('[data-bs-target="#collapseComments"]').click();
 await page.locator('[id$="txtNewComment"]').fill('UI fixture follow-up: review the accessible form.');
 await page.locator('[id$="btnSaveComment"]').click();
 check(Object.values(await get('academicComments')||{}).some(c=>c.Comment==='UI fixture follow-up: review the accessible form.'),'Academic comment confirmed by stored record');
 // Filtering and empty state are actual GET navigation, no simulated content.
 await login('coordinator-one');await go('Pages/Coordinator/Placements.aspx?q=NoMatchingUiFixture');
 check((await page.locator('.monitor-empty').innerText()).includes('No placements match'),'Filter produces helpful empty state');
 await go('Pages/Coordinator/Placements.aspx');
 check(await page.locator('[data-student-id="student-one"]').count()===1,'Clearing filter restores actual placement');
 // Refresh is safe to call repeatedly without duplicate wrappers or icons.
 const idempotent=await page.evaluate(()=>{const before=document.querySelectorAll('.ui-icon,.ui-table-scroll,.ui-button-frame').length;UimsUI.refresh();UimsUI.refresh();return before===document.querySelectorAll('.ui-icon,.ui-table-scroll,.ui-button-frame').length;});
 check(idempotent,'Shared initialization is idempotent');
 await login('student-one');await go('Pages/Coordinator/Account.aspx');
 check(!page.url().includes('/Coordinator/Account.aspx'),'Student cannot enter coordinator route');
 return {checks,routes,errors,limitations:['Local Postman Firebase/auth stand-ins only; no live Firebase verification.','No UpdatePanels exist; optional lifecycle adapter is structural only.','Document endpoints tested for rejection, not actual file download.']};
}
