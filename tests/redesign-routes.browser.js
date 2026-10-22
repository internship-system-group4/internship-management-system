async page => {
 page.setDefaultTimeout(6000);page.setDefaultNavigationTimeout(20000);
 const base='http://localhost:58013',db='http://localhost:4930/firebase';
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
 check(routes.filter(r=>!r.kind).every(r=>r.foundation&&!r.overflow),'All rendered routes load foundation without viewport overflow');
 check(errors.length===0,'No uncaught page errors during route inventory');
 return {passed:checks.length,checks,routes,errors};
}
