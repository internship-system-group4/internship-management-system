async page => {
 const base='http://localhost:57982', db='http://localhost:4900/firebase'; let checks=0;
 const check=(ok,message)=>{if(!ok)throw Error(message);checks++;};
 const get=async path=>(await page.request.get(db+'/'+path+'.json')).json();
 const put=async(path,data)=>page.request.put(db+'/'+path+'.json',{data});
 const app={Id:'review-one',StudentId:'student-one',StudentName:'Osama Banihani',StudentMajor:'Computer Science',CompanyId:'company-one',CompanyName:'Training Company',OpportunityId:'internship-one',OpportunityTitle:'Software Development Intern',CoverLetter:'I enjoy building web applications with C# and would love to learn from the engineering team.',CvUrl:'https://example.com/cv.pdf',Status:0,SubmittedAt:Date.now(),DecidedAt:0,IsConfirmedByStudent:false,ExtraField:'preserve-me'};
 async function reset(){await page.request.post(db+'/__reset');await put('applications/review-one',app);}
 async function company(){await page.goto(base+'/__fixture.aspx?user=supervisor-one');}
 async function error(text){check((await page.getByRole('alert').innerText()).includes(text),text);}
 async function reject(reason){const details=page.locator('.review-reject');if(!await details.evaluate(el=>el.open))await details.locator('summary').click();await page.getByRole('textbox',{name:'Reason for rejection (required)'}).fill(reason);await page.getByRole('button',{name:'Confirm rejection'}).click();}
 await page.setViewportSize({width:1440,height:1000});
 await reset(); await company();
 check(await page.getByRole('button',{name:'Accept application'}).count()===1,'Pending accept action');
 check(await page.locator('.uims-sidebar-brand img').isVisible(),'Shared company logo');
 check((await page.locator('.uims-side-link[aria-current="page"]').innerText())==='Applications Review','Active company navigation');
 await reject('   ');await error('rejection reason');
 check((await get('applications/review-one')).Status===0,'Missing reason preserves Pending');
 const field=page.getByRole('textbox',{name:'Reason for rejection (required)'});
 await field.evaluate(el=>el.removeAttribute('maxlength'));await reject('x'.repeat(2001));await error('2,000');
 await reject('We need more experience with C# & database design.');
 check((await page.getByRole('status').innerText()).includes('rejected'),'Rejection success');
 let saved=await get('applications/review-one');
 check(saved.Status===2&&saved.RejectionReason==='We need more experience with C# & database design.','Rejection persisted');
 check(saved.DecidedBySupervisorId==='supervisor-one'&&saved.DecidedAt>0,'Decision audit metadata');
 check(saved.ExtraField==='preserve-me'&&saved.SubmittedAt===app.SubmittedAt,'Other fields preserved');
 check(await page.getByRole('button',{name:'Accept application'}).count()===0,'Reviewed actions removed');
 await page.goto(base+'/__fixture.aspx');await page.goto(base+'/Pages/Student/MyApplications.aspx');
 check((await page.locator('.application-row').innerText()).includes('Rejected'),'Student sees Rejected');
 check((await page.locator('.application-row').innerText()).includes(saved.RejectionReason),'Student sees reason');
 await reset();await company();
 const stale=await page.context().newPage();await stale.goto(base+'/Pages/Company/Applications.aspx');
 await page.getByRole('button',{name:'Accept application'}).click();
 check((await page.getByRole('status').innerText()).includes('accepted'),'Accept success');
 saved=await get('applications/review-one');check(saved.Status===1&&!saved.IsConfirmedByStudent,'Accepted remains unconfirmed');
 check(await get('placements/student-one')===null,'Accept creates no placement');
 await stale.locator('.review-reject summary').click();
 await stale.getByRole('textbox',{name:'Reason for rejection (required)'}).fill('A stale decision should not overwrite acceptance.');
 await stale.getByRole('button',{name:'Confirm rejection'}).click();
 check((await stale.getByRole('alert').innerText()).includes('already been reviewed'),'Stale page blocked');
 check((await get('applications/review-one')).Status===1,'Acceptance not overwritten');await stale.close();
 await page.goto(base+'/__fixture.aspx');await page.goto(base+'/Pages/Student/MyApplications.aspx');
 check((await page.locator('.application-row').innerText()).includes('Accepted'),'Student sees Accepted');
 await reset();await company();await put('applications/review-one',{...app,CompanyId:'company-two'});
 await page.getByRole('button',{name:'Accept application'}).click();await error('not available to your company');
 check((await get('applications/review-one')).Status===0,'Other company write blocked');
 await reset();await company();await put('opportunities/internship-one',{...await get('opportunities/internship-one'),CompanyId:'company-two'});
 await page.getByRole('button',{name:'Accept application'}).click();await error('does not belong');
 await reset();await company();await page.request.post(db+'/__conflict-next');
 await reject('This should lose the concurrent decision race.');await error('changed during review');
 saved=await get('applications/review-one');
 check(saved.Status===1&&saved.DecidedBySupervisorId==='concurrent-supervisor','Concurrent winning decision preserved');
 await reset();await company();await page.request.post(db+'/__fail-writes');
 await reject('Keep this reason if the database is unavailable.');await error('could not confirm');
 check(await page.getByRole('textbox',{name:'Reason for rejection (required)'}).inputValue()==='Keep this reason if the database is unavailable.','Failed write preserves reason');
 check((await get('applications/review-one')).Status===0,'Failed decision does not change status');
 await reset();await page.goto(base+'/__fixture.aspx?user=other-supervisor');
 check(await page.locator('.application-row').count()===0,'Other company sees no applications');
 await page.goto(base+'/__fixture.aspx');await page.goto(base+'/Pages/Company/Applications.aspx');
 check(page.url().includes('AccessDenied'),'Student cannot review');
 await company();
 for(const width of [1440,768,390]) {
  await page.setViewportSize({width,height:1000});
  check(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),'No overflow '+width);
  await page.screenshot({path:'tests/artifacts/company-review-'+width+'.png',fullPage:true});
 }
 await page.getByRole('button',{name:'Open navigation',exact:true}).click();
 await page.locator('#companySidebar').evaluate(el=>Promise.all(el.getAnimations().map(a=>a.finished)));
 check(await page.getByRole('dialog',{name:'Company navigation'}).isVisible(),'Company shared hamburger');
 await page.keyboard.press('Escape');
 check(await page.getByRole('button',{name:'Open navigation',exact:true}).getAttribute('aria-expanded')==='false','Company Escape close');
 for(const [route,label] of [['Dashboard','Dashboard'],['Opportunities','Manage Opportunities'],['Trainees','My Trainees'],['Tasks','Manage Tasks'],['TaskReview','Review Submissions'],['FinalEvaluation','Final Evaluation'],['Account','My Account']]) {
  await page.setViewportSize({width:1440,height:1000});await page.goto(base+'/Pages/Company/'+route+'.aspx');
  check((await page.locator('.uims-side-link[aria-current="page"]').innerText())===label,'Shared company shell '+route);
 }
 await company(); await page.setViewportSize({width:1440,height:1000});
 return {passed:checks,system:'O05 real Web Forms + Firebase REST simulation'};
}
