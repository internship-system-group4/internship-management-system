async page => {
 const base='http://localhost:57982',db='http://localhost:4900/firebase';let checks=0;
 const check=(ok,message)=>{if(!ok)throw Error(message);checks++;};
 const get=async path=>(await page.request.get(db+'/'+path+'.json')).json();
 const put=async(path,data)=>{const response=await page.request.put(db+'/'+path+'.json',{data});if(!response.ok())throw Error('Seed failed '+path);};
 const visit=path=>page.goto(base+'/Pages/Coordinator/'+path+'.aspx');
 const details=()=>page.goto(base+'/Pages/Coordinator/PlacementDetails.aspx?id=student-one');
 const metric=async name=>page.locator('[data-metric="'+name+'"] strong').innerText();
 async function seed(){
  await page.request.post(db+'/__reset');
  for(const [Id,Role,FullName] of [['coordinator-one',4,'Internship Coordinator'],['academic-one',3,'Academic Supervisor']])await put('users/'+Id,{Id,Role,FullName,IsActive:true,MustChangePassword:false});
  const student=await get('users/student-one');
  await put('users/student-two',{...student,Id:'student-two',FullName:'Sara Ahmad',StudentNumber:'20260002',IsActive:false});
  await put('companies',{a:{Name:'Training Company',IsActive:true},b:{Name:'Other Company',IsActive:false}});
  const opportunity=await get('opportunities/internship-one');
  await put('opportunities/internship-closed',{...opportunity,Status:2});
  const placement={Id:'student-one',StudentId:'student-one',StudentName:'Osama Banihani',CompanyId:'company-one',CompanyName:'Training Company',CompanySupervisorId:'supervisor-one',CompanySupervisorName:'Company Supervisor',AcademicSupervisorId:'academic-one',OpportunityId:'internship-one',OpportunityTitle:'Software Development Intern',RequiredHours:160,ApprovedHours:999,Status:2,ConfirmedAt:Date.now(),StartDate:Date.now(),EndDate:Date.now()+86400000*90};
  await put('placements',{'student-one':placement,'student-two':{...placement,Id:'student-two',StudentId:'student-two',StudentName:'Sara Ahmad',CompanyName:'Other Company',Status:3,ConfirmedAt:Date.now()-1000},legacy:{...placement,Id:'legacy'},offered:{...placement,Id:'offered',StudentId:'offered',Status:0}});
  const task={PlacementId:'student-one',StudentId:'student-one',CompanyId:'company-one',Title:'Build application form',Description:'<script>untrusted task text</script>',MaxScore:10,Deadline:Date.now()-86400000,Status:5};
  await put('tasks',{graded:task,late:{...task,Title:'Prepare report',Status:0},decoy:{...task,Title:'Wrong student task',StudentId:'student-two',Status:0}});
  const submission={TaskId:'graded',PlacementId:'student-one',StudentId:'student-one',AttemptNumber:1,DescriptionText:'First attempt',LinkUrl:'javascript:alert(1)',ReportedHours:20,SubmittedAt:Date.now()-1000};
  await put('submissions',{first:submission,second:{...submission,AttemptNumber:2,DescriptionText:'Improved attempt',SubmittedAt:Date.now()},decoy:{...submission,TaskId:'missing',DescriptionText:'Wrong task attempt'}});
  const evaluation={TaskId:'graded',SubmissionId:'first',PlacementId:'student-one',StudentId:'student-one',TotalScore:8,MaxScore:10,Feedback:'Add validation',RevisionRequested:true,RevisionInstructions:'Check required fields',EvaluatedAt:Date.now()-1000};
  await put('taskEvaluations',{revision:evaluation,grade:{...evaluation,SubmissionId:'second',RevisionRequested:false,Feedback:'Validation works',EvaluatedAt:Date.now()},decoy:{...evaluation,TaskId:'late',Feedback:'Wrong evaluation'}});
  const hours={PlacementId:'student-one',StudentId:'student-one',Hours:20,Status:1,WorkDate:Date.now(),Description:'Approved work'};
  await put('trainingHours',{approved:hours,pending:{...hours,Hours:5,Status:0,Description:'Pending work'},rejected:{...hours,Hours:7,Status:2,Description:'Rejected work'},decoy:{...hours,StudentId:'student-two',Hours:500,Description:'Wrong student hours'}});
  const final={PlacementId:'student-one',StudentId:'student-one',CompanyId:'company-one',SupervisorId:'supervisor-one',TotalScore:42,MaxScore:50,IsSubmitted:true,OverallComment:'Private company assessment',SubmittedAt:Date.now()};
  await put('companyFinalEvaluations',{submitted:final,draft:{...final,IsSubmitted:false,OverallComment:'Draft should not override submitted',CreatedAt:Date.now()+1000}});
  await put('academicFinalEvaluations',{draft:{PlacementId:'student-one',StudentId:'student-one',AcademicSupervisorId:'academic-one',IsSubmitted:false,TotalScore:18,MaxScore:20,AcademicComments:'Private academic draft'}});
  await put('academicComments',{private:{PlacementId:'student-one',StudentId:'student-one',AcademicSupervisorId:'academic-one',Comment:'Private academic follow-up',IsVisibleToStudent:false,CreatedAt:Date.now()}});
  await put('completions',{review:{PlacementId:'student-one',StudentId:'student-one',Status:3,FinalScore:90,ReportFileUrl:'https://example.com/unapproved-report.pdf'}});
 }
 await seed();await page.setViewportSize({width:1440,height:1000});
 await page.goto(base+'/__fixture.aspx?user=coordinator-one');await visit('Dashboard');
 for(const [name,count] of [['students','2'],['companies','2'],['opportunities','2'],['placements','2'],['task-evaluations','2'],['final-evaluations','1']])check(await metric(name)===count,'Real linked count '+name);
 check((await page.locator('.monitor-attention').innerText()).includes('1 tasks past deadline'),'Only linked overdue tasks');
 check((await page.locator('.monitor-attention').innerText()).includes('5 h'),'Pending hours exclude mismatched student');
 check((await page.locator('[data-metric="students"]').innerText()).includes('1 active'),'Inactive profiles distinguished');
 await page.screenshot({path:'tests/artifacts/coordinator-dashboard-desktop.png',fullPage:true});
 await visit('Placements');
 check(await page.locator('[data-student-id]').count()===2,'Only canonical confirmed placements');
 check((await page.locator('[data-student-id="student-one"]').innerText()).includes('20 / 160 h'),'Hours derived from approved log, not stale cache');
 for(const query of ['osama','20260001','student-one','Training Company']){
  await page.getByLabel('Search placements').fill(query);await page.getByRole('button',{name:'Search',exact:true}).click();
  check(await page.locator('[data-student-id]').count()===1,'Search '+query);
 }
 await page.goto(base+'/Pages/Coordinator/Placements.aspx?status=3');
 check(await page.locator('[data-student-id="student-two"]').count()===1&&await page.locator('[data-student-id]').count()===1,'Status filter');
 await page.goto(base+'/Pages/Coordinator/Placements.aspx?q=NoMatch');
 check((await page.locator('.monitor-empty').innerText()).includes('No placements match'),'Filtered empty state');
 const initial=JSON.stringify(await get('placements'));
 await details();
 check(await page.locator('h2').innerText()==='Osama Banihani','Details runtime compiled');
 check(await page.locator('[data-approved-hours]').getAttribute('data-approved-hours')==='20','Approved only');
 check((await page.locator('#tasks').innerText()).includes('Out of 10'),'Actual task scale');
 check(await page.locator('#submissions .monitor-entry').count()===2,'Submission attempts preserved');
 check(await page.locator('#evaluations .monitor-entry').count()===2,'Only evaluation/task/submission matches');
 check((await page.locator('#evaluations').innerText()).includes('8 / 10'),'Actual grade scale');
 check((await page.locator('#evaluations').innerText()).includes('Check required fields'),'Revision feedback');
 check(await page.locator('#hours tbody tr').count()===3,'Hours log includes review states');
 check(!(await page.locator('.monitor-page').innerText()).includes('Wrong student'),'Mismatched records excluded');
 check(await page.locator('#tasks script').count()===0&&(await page.locator('#tasks').innerText()).includes('<script>'),'Stored text encoded');
 check(await page.locator('#submissions a[href^="javascript:"]').count()===0,'Unsafe submission link suppressed');
 check((await page.locator('.monitor-page').innerText()).includes('Private academic follow-up'),'Coordinator sees private follow-up');
 await page.getByText('View confidential company evaluation',{exact:true}).click();
 check((await page.locator('.monitor-page').innerText()).includes('Private company assessment'),'Submitted confidential evaluation');
 check(!(await page.locator('.monitor-page').innerText()).includes('Draft should not override'),'Submitted evaluation preferred');
 check(await page.locator('a[href*="unapproved-report"]').count()===0,'Report stays unavailable before approval');
 check(JSON.stringify(await get('placements'))===initial,'Monitoring never mutates placements');
 await put('trainingHours/approved',{...await get('trainingHours/approved'),Hours:25});await page.reload();
 check(await page.locator('[data-approved-hours]').getAttribute('data-approved-hours')==='25','Refresh loads updated Firebase values');
 await put('completions/review',{...await get('completions/review'),Status:4,Result:'Passed',FinalScore:84,ReportFileUrl:'https://example.com/approved-report.pdf'});await page.reload();
 check(await page.getByRole('link',{name:'Open official completion report'}).getAttribute('href')==='https://example.com/approved-report.pdf','Approved report available');
 check((await page.locator('.monitor-page').innerText()).includes('84%'),'Recorded approved final score');
 await page.screenshot({path:'tests/artifacts/coordinator-details-desktop.png',fullPage:true});
 for(const route of ['Dashboard','Placements','PlacementDetails.aspx?id=student-one']){
  await page.setViewportSize({width:390,height:900});
  await page.goto(base+'/Pages/Coordinator/'+(route.includes('.aspx')?route:route+'.aspx'));
  check(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),'No mobile body overflow '+route);
  check(await page.getByRole('button',{name:'Open navigation',exact:true}).isVisible(),'Shared hamburger '+route);
  await page.screenshot({path:'tests/artifacts/coordinator-'+route.split('.')[0].toLowerCase()+'-mobile.png',fullPage:true});
 }
 await page.setViewportSize({width:1440,height:1000});
 for(const [id,expect] of [['missing',404],['bad.key',200]]){
  const response=await page.goto(base+'/Pages/Coordinator/PlacementDetails.aspx?id='+id);
  check(response.status()===expect&&await page.getByRole('alert').count()===1,'Invalid/missing id handled '+id);
 }
 await page.request.post(db+'/__fail-monitoring');await visit('Dashboard');
 check(await page.getByRole('alert').count()===1&&await page.locator('[data-metric]').count()===0,'Failure is not fake zero statistics');
 await details();check(await page.getByRole('alert').count()===1&&await page.locator('#tasks').count()===0,'Details fail without partial confidential data');
 await page.request.post(db+'/__restore-monitoring');
 for(const user of ['student-one','supervisor-one','academic-one']){
  await page.goto(base+'/__fixture.aspx?user='+user);await details();
  check(page.url().includes('AccessDenied'),'Other role blocked '+user);
  check(!(await page.locator('body').innerText()).includes('Private company assessment'),'No confidential leak '+user);
 }
 await page.goto(base+'/__fixture.aspx?user=coordinator-one');
 const placements=await get('placements');
 for(let i=0;i<11;i++)await put('placements/demo-'+i,{...placements['student-one'],Id:'demo-'+i,StudentId:'demo-'+i,StudentName:'Paging Student '+i,ConfirmedAt:Date.now()+i});
 await page.goto(base+'/Pages/Coordinator/Placements.aspx?q=Paging&page=2');
 check(await page.locator('[data-student-id]').count()===1,'Filtered second page');
 check((await page.getByRole('link',{name:'Previous',exact:true}).getAttribute('href')).includes('q=Paging'),'Pagination retains filters');
 await page.goto(base+'/Pages/Coordinator/Placements.aspx?q=Paging&page=999');
 check(await page.locator('[data-student-id]').count()===1,'Out of range page clamped');
 await put('placements',placements);
 await put('users/student-two',null);await put('placements/student-two',{...placements['student-two'],RequiredHours:0});
 await page.goto(base+'/Pages/Coordinator/PlacementDetails.aspx?id=student-two');
 check((await page.locator('.monitor-page').innerText()).includes('Sara Ahmad'),'Archived profile snapshot fallback');
 check((await page.locator('[data-approved-hours]').innerText()).includes('requirement not configured'),'Zero requirement handled');
 check(await page.locator('#tasks .monitor-empty').count()===1,'Empty task state');
 await put('placements',{});await visit('Dashboard');
 check(await metric('placements')==='0'&&await page.locator('.monitor-empty').count()===1,'True zero and empty dashboard');
 await seed();await visit('Dashboard');
 return {passed:checks,system:'O06/O07/O08 Web Forms + local Firebase simulation; no live Firebase writes'};
}
