// Full route/UI inventory against a disposable IIS host and local Postman simulation.
// Never run against production: this seeds and resets synthetic Firebase data.
async page => {
 const base=new URL(page.url()).origin, db='http://localhost:4940/firebase';
 const routes={
  public:['Default.aspx','Pages/Public/About.aspx','Pages/Public/Contact.aspx','Pages/Public/PoweredBy.aspx','Pages/Public/AccessDenied.aspx','Pages/Public/Journey.aspx','Pages/Public/404.aspx','Pages/Public/NotFound.aspx','Pages/Account/Login.aspx','Pages/Account/ForgotPassword.aspx'],
  'student-one':['Student/Dashboard','Student/Opportunities','Student/exploreOpport','Student/OpportunityDetails?id=internship-one','Student/Apply?opportunityId=internship-one','Student/MyApplications','Student/MyTasks','Student/Progress','Student/Profile','Student/DisplayEditProfile','Student/StudentCVPortfolio','Account/Notifications','Notifications/Inbox','Account/ChangePassword','Meetings/MyMeetings','Meetings/Schedule'],
  'supervisor-one':['Company/Dashboard','Company/Opportunities','Company/ManageOpportunities','Company/ViewOpportunity?id=internship-one','Company/Applications','Company/Trainees','Company/TraineeDetails?id=student-one','Company/Tasks','Company/TaskReview?id=qa-task','Company/FinalEvaluation','Company/EvaluationReport?id=student-one','Company/Account'],
  'academic-one':['Academic/Dashboard','Academic/StudentProgress?id=student-one','Academic/FinalEvaluation?id=student-one','Academic/Account','Reports/Grades'],
  'coordinator-one':['Coordinator/Dashboard','Coordinator/Students','Coordinator/ManageStudents','Coordinator/Companies','Coordinator/AcademicSupervisors','Coordinator/Groups','Coordinator/ConfiguredGroups','Coordinator/Placements','Coordinator/PlacementDetails?id=student-one','Coordinator/CompletionReview','Coordinator/CompletionReview?id=student-one','Coordinator/ContactMessages','Coordinator/Account','Coordinator/AddStudent','Coordinator/DemoStudent']
 };
 const put=async(path,data)=>{const r=await page.request.put(db+'/'+path+'.json',{data});if(!r.ok())throw Error('Synthetic seed failed: '+path);};
 await page.request.post(db+'/__reset');
 const now=Date.now(),day=86400000;
 await put('companies/company-one',{Id:'company-one',Name:'Synthetic Training Company',IsActive:true});
 await put('users/student-one',{Id:'student-one',FullName:'Synthetic Student',Email:'student@campus.test',Role:1,IsActive:true,MustChangePassword:false,StudentNumber:'QA-001',University:'German Jordanian University',College:'School of Computing',Major:'Computer Science',RequiredHours:160,AcademicSupervisorId:'academic-one',CvUrl:'https://example.com/cv.pdf'});
 await put('users/student-two',{Id:'student-two',FullName:'Second Synthetic Student',Email:'second@example.test',Role:1,IsActive:true,StudentNumber:'QA-002',College:'School of Computing',Major:'Computer Science',RequiredHours:160,AcademicSupervisorId:'academic-one'});
 await put('users/academic-one',{Id:'academic-one',FullName:'Synthetic Academic Supervisor',Email:'academic@campus.test',Role:3,IsActive:true,MustChangePassword:false});
 await put('users/supervisor-one',{Id:'supervisor-one',FullName:'Synthetic Company Supervisor',Email:'company@campus.test',Role:2,CompanyId:'company-one',CompanyName:'Synthetic Training Company',IsActive:true,MustChangePassword:false});
 await put('studentGroups/qa-group',{Id:'qa-group',Name:'QA Supervision',AcademicSupervisorId:'academic-one',StudentIds:['student-one','student-two'],IsActive:true});
 await put('opportunities/internship-one',{Id:'internship-one',Title:'Synthetic Software Internship',CompanyId:'company-one',CompanyName:'Synthetic Training Company',Location:'Amman',EligibleCollege:'School of Computing',EligibleMajors:['Computer Science'],Status:1,TotalSeats:5,FilledSeats:1,DurationWeeks:12,StartDate:now+day*7,EndDate:now+day*90,ApplicationDeadline:now+day*5,Description:'A synthetic internship used only for isolated quality assurance.',Requirements:'Programming fundamentals',TrainingMode:'Hybrid'});
 const placement={Id:'student-one',StudentId:'student-one',StudentName:'Synthetic Student',CompanyId:'company-one',CompanyName:'Synthetic Training Company',CompanySupervisorId:'supervisor-one',CompanySupervisorName:'Synthetic Company Supervisor',AcademicSupervisorId:'academic-one',ApplicationId:'qa-application',OpportunityId:'internship-one',OpportunityTitle:'Synthetic Software Internship',Status:2,RequiredHours:160,ApprovedHours:40,StartDate:now-day*20,EndDate:now+day*30,ConfirmedAt:now-day*21};
 await put('placements/student-one',placement);
 await put('applications/qa-application',{Id:'qa-application',StudentId:'student-one',StudentName:'Synthetic Student',StudentMajor:'Computer Science',OpportunityId:'internship-one',OpportunityTitle:'Synthetic Software Internship',CompanyId:'company-one',Status:1,IsConfirmedByStudent:true,SubmittedAt:now-day*22,DecidedAt:now-day*21,CoverLetter:'Synthetic application for isolated quality assurance.',CvUrl:'https://example.com/cv.pdf'});
 await put('applications/qa-pending',{Id:'qa-pending',StudentId:'student-two',StudentName:'Second Synthetic Student',StudentMajor:'Computer Science',OpportunityId:'internship-one',OpportunityTitle:'Synthetic Software Internship',CompanyId:'company-one',Status:0,SubmittedAt:now-day,CoverLetter:'Synthetic pending application for isolated quality assurance.'});
 await put('tasks/qa-task',{Id:'qa-task',PlacementId:'student-one',StudentId:'student-one',CompanyId:'company-one',CreatedBySupervisorId:'supervisor-one',Title:'QA accessible form',Description:'Build a clear form.',Instructions:'Submit a link for review.',Deadline:now+day*3,Status:0,MaxScore:20,Weight:1,Criteria:[{Id:'clarity',Name:'Clarity',MaxScore:20,Weight:100}]});
 await put('trainingHours/qa-hours',{Id:'qa-hours',PlacementId:'student-one',StudentId:'student-one',Hours:40,Status:1,WorkDate:now-day,ReportedAt:now-day,ReviewedAt:now-day/2,ReviewedById:'supervisor-one',Description:'Synthetic approved training'});
 const all=[],networkErrors=[];
 for(const lang of ['en','ar'])for(const [width,theme] of [[1440,'light'],[390,'dark'],[1440,'dark'],[390,'light']])for(const [user,list] of Object.entries(routes)){
  const ctx=await page.context().browser().newContext({viewport:{width,height:900},reducedMotion:'reduce'}),p=await ctx.newPage();
  await ctx.addCookies([{name:'uims-lang',value:lang,url:base}]);
  const errors=[],assetErrors=[];p.on('pageerror',e=>errors.push(e.message));p.on('response',r=>{const u=new URL(r.url());if(u.origin===base&&u.pathname.startsWith('/Assets/')&&r.status()>=400)assetErrors.push({path:u.pathname,status:r.status()});});
  if(user!=='public')await p.goto(base+'/__fixture.aspx?user='+user);
  for(const name of list){
   errors.length=0;assetErrors.length=0;
   const [stem,query]=name.split('?'),route=user==='public'?name:'Pages/'+stem+'.aspx'+(query?'?'+query:'');
   try{
    const response=await p.goto(base+'/'+route,{waitUntil:'domcontentloaded',timeout:30000});
    await p.evaluate(t=>window.UimsTheme&&window.UimsTheme.set(t),theme);
    await p.waitForTimeout(180);
    const result=await p.evaluate(()=>({url:location.pathname,title:document.title,lang:document.documentElement.lang,dir:document.documentElement.dir,overflow:document.documentElement.scrollWidth-innerWidth,serverError:/Server Error in|Compilation Error|Parser Error/.test(document.body.innerText.slice(0,600)),missing:[...document.querySelectorAll('input:not([type=hidden]):not([type=submit]):not([type=button]),select,textarea')].filter(e=>e.getClientRects().length&&!e.disabled&&!e.labels?.length&&!e.getAttribute('aria-label')&&!e.getAttribute('aria-labelledby')&&!e.title).map(e=>e.id||e.name)}));
    all.push({route,user,expectedLang:lang,width,theme,status:response.status(),...result,errors:[...errors],assetErrors:[...assetErrors]});
   }catch(e){all.push({route,user,lang,width,theme,error:e.message});}
  }
  await ctx.close();
 }
 const problems=all.filter(r=>r.error||(r.status!==200&&!/Public\/(404|NotFound)\.aspx/.test(r.route))||r.serverError||r.overflow>1||r.errors.length||r.assetErrors?.length||r.lang!==r.expectedLang||r.dir!==(r.lang==='ar'?'rtl':'ltr'));
 return {visited:all.length,problems,missingLabels:all.filter(r=>r.missing?.length),all};
}
