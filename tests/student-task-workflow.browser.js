// Stateful local Postman/IIS workflow; no live accounts or file storage are used.
async page => {
 const base=new URL(page.url()).origin,db='http://localhost:4940/firebase',checks=[];
 const check=(ok,name)=>{if(!ok)throw Error(name);checks.push(name);};
 const get=async path=>(await page.request.get(db+'/'+path+'.json')).json();
 const put=async(path,data)=>page.request.put(db+'/'+path+'.json',{data});
 await page.request.post(db+'/__reset');
 const now=Date.now();
 await put('placements/student-one',{Id:'student-one',StudentId:'student-one',StudentName:'Synthetic Student',CompanyId:'company-one',CompanySupervisorId:'supervisor-one',AcademicSupervisorId:'academic-one',OpportunityId:'internship-one',OpportunityTitle:'Synthetic training',Status:2,RequiredHours:160,ApprovedHours:0,StartDate:now-86400000,EndDate:now+86400000*30});
 const task={Id:'qa-submit',PlacementId:'student-one',StudentId:'student-one',CompanyId:'company-one',CreatedBySupervisorId:'supervisor-one',Title:'Synthetic submission task',Description:'Submit a test link.',Instructions:'Use a safe web URL.',Deadline:now+86400000,Status:0,MaxScore:20,Weight:1,RequiresFileUpload:false,Criteria:[{Name:'Quality',MaxScore:20,Weight:100}]};
 await put('tasks/qa-submit',task);
 const ctx=await page.context().browser().newContext({reducedMotion:'reduce'}),p=await ctx.newPage();
 await p.goto(base+'/__fixture.aspx?user=student-one');await p.goto(base+'/Pages/Student/MyTasks.aspx');
 await p.locator('textarea[id$=txtSubmissionText]').fill('Synthetic work submitted for local QA.');
 await p.locator('input[id$=txtSubmissionLink]').fill('https://example.com/work');
 await Promise.all([p.waitForResponse(r=>r.request().method()==='POST'),p.locator('input[id$=btnSubmitTask]').click()]);
 let attempts=Object.values(await get('submissions')||{});
 check(attempts.length===1&&attempts[0].AttemptNumber===1,'First submission is stored once');
 check((await get('tasks/qa-submit')).Status===1,'Task moves to Submitted');
 check((await get('placements/student-one')).ApprovedHours===0,'Task submission does not approve training hours');
 await p.reload();check(!await p.locator('input[id$=btnSubmitTask]').isVisible(),'Pending review does not allow a second submission');
 await put('tasks/qa-submit',{...task,Status:3});
 await put('taskEvaluations/qa-revision',{Id:'qa-revision',TaskId:'qa-submit',SubmissionId:attempts[0].Id,StudentId:'student-one',PlacementId:'student-one',EvaluatedBySupervisorId:'supervisor-one',RevisionRequested:true,RevisionInstructions:'Improve the explanation.',Feedback:'Synthetic review',EvaluatedAt:Date.now()});
 await p.reload();await p.locator('textarea[id$=txtSubmissionText]').fill('Improved synthetic work for the second attempt.');
 await Promise.all([p.waitForResponse(r=>r.request().method()==='POST'),p.locator('input[id$=btnSubmitTask]').click()]);
 attempts=Object.values(await get('submissions')||{});
 check(attempts.length===2&&attempts.some(a=>a.AttemptNumber===1)&&attempts.some(a=>a.AttemptNumber===2),'Resubmission preserves both attempts');
 check((await get('tasks/qa-submit')).Status===4,'Task moves to Resubmitted');
 await p.goto(base+'/Pages/Student/Progress.aspx');
 check((await p.locator('body').innerText()).includes('Improve the explanation.'),'Progress shows requested revision feedback');
 check(!(await p.locator('body').innerText()).includes('Server Error in'),'Progress renders after resubmission');
 await ctx.close();await page.request.post(db+'/__reset');return {passed:checks.length,checks};
}
