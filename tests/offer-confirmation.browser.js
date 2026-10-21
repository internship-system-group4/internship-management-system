async page => {
 const base='http://localhost:57982',db='http://localhost:4900/firebase';let checks=0;
 const check=(ok,message)=>{if(!ok)throw Error(message);checks++;};
 const get=async path=>(await page.request.get(db+'/'+path+'.json')).json();
 const put=async(path,data)=>page.request.put(db+'/'+path+'.json',{data});
 async function seed(){
  await page.request.post(db+'/__reset');
  await put('users/student-one',{...await get('users/student-one'),RequiredHours:160,AcademicSupervisorId:'academic-one'});
  const opportunity=await get('opportunities/internship-one');
  await put('opportunities/internship-two',{...opportunity,Id:'internship-two',Title:'Frontend Development Intern'});
  for(const [Id,OpportunityId,OpportunityTitle] of [['offer-one','internship-one','Software Development Intern'],['offer-two','internship-two','Frontend Development Intern']])
   await put('applications/'+Id,{Id,StudentId:'student-one',StudentName:'Osama Banihani',StudentMajor:'Computer Science',CompanyId:'company-one',CompanyName:'Training Company',OpportunityId,OpportunityTitle,CoverLetter:'I enjoy building web applications and learning through software engineering.',CvUrl:'https://example.com/cv.pdf',Status:1,DecidedBySupervisorId:'supervisor-one',DecidedAt:Date.now(),SubmittedAt:Date.now(),IsConfirmedByStudent:false});
 }
 async function applications(target=page){await target.goto(base+'/__fixture.aspx');await target.goto(base+'/Pages/Student/MyApplications.aspx');}
 const row=(id,target=page)=>target.locator('[data-application-id="'+id+'"]');
 async function confirm(id,target=page){await row(id,target).getByRole('checkbox').check();await row(id,target).getByRole('button',{name:'Confirm offer',exact:true}).click();}
 await page.setViewportSize({width:1440,height:1000});
 await seed();await applications();
 check(await page.getByRole('button',{name:'Confirm offer',exact:true}).count()===2,'Accepted offers can be confirmed');
 await row('offer-one').getByRole('button',{name:'Confirm offer',exact:true}).click();
 check((await page.getByRole('alert').innerText()).includes('understand'),'Consent required');
 check(await get('placements/student-one')===null,'No placement without consent');
 await page.screenshot({path:'tests/artifacts/accepted-offers-desktop.png',fullPage:true});
 await confirm('offer-one');
 let saved=await get('placements/student-one');
 check(saved.ApplicationId==='offer-one'&&saved.StudentId==='student-one'&&saved.Id==='student-one','Placement keyed by student UID');
 check(saved.CompanyId==='company-one'&&saved.CompanySupervisorId==='supervisor-one'&&saved.AcademicSupervisorId==='academic-one'&&saved.RequiredHours===160,'Placement relationships');
 check(saved.Status===1&&saved.ConfirmedAt>0&&saved.ApprovedHours===0,'Confirmed state and timestamp');
 check((await get('applications/offer-one')).IsConfirmedByStudent===true,'Application flag synced');
 check(await page.getByRole('button',{name:'Confirm offer',exact:true}).count()===0,'All other confirmations hidden');
 check((await page.locator('.confirmed-placement').innerText()).includes('Software Development Intern'),'Confirmed placement displayed');
 await page.reload();check((await get('placements/student-one')).ConfirmedAt===saved.ConfirmedAt,'Reload does not duplicate placement');
 await seed();await applications();await put('applications/offer-one',{...await get('applications/offer-one'),Status:0});
 await confirm('offer-one');check((await page.getByRole('alert').innerText()).includes('Only an accepted'),'Stale non-accepted offer blocked');
 check(await get('placements/student-one')===null,'Invalid status writes nothing');
 await seed();await applications();await put('applications/offer-one',{...await get('applications/offer-one'),StudentId:'another-student'});
 await confirm('offer-one');check((await page.getByRole('alert').innerText()).includes('does not belong'),'Other student blocked');
 await seed();await applications();await page.request.post(db+'/__fail-placement-writes');await confirm('offer-one');
 check((await page.getByRole('alert').innerText()).includes('could not confirm'),'Failed placement feedback');
 check(await get('placements/student-one')===null,'Failed write does not confirm');
 await seed();await applications();await page.request.post(db+'/__fail-writes');await confirm('offer-one');
 check((await get('placements/student-one')).ApplicationId==='offer-one','Placement survives secondary write failure');
 check(await page.getByRole('button',{name:'Sync confirmation'}).count()===1,'Repair action appears');
 check(await page.getByRole('button',{name:'Confirm offer',exact:true}).count()===0,'Partial failure cannot confirm second offer');
 await page.request.post(db+'/__restore-writes');await page.getByRole('button',{name:'Sync confirmation'}).click();
 check((await get('applications/offer-one')).IsConfirmedByStudent,'Retry repairs flag');
 // Two separate authenticated sessions for the same student avoid ASP.NET session serialization.
 await seed();await applications();
 const context=await page.context().browser().newContext();const competitor=await context.newPage();await applications(competitor);
 await row('offer-one').getByRole('checkbox').check();await row('offer-two',competitor).getByRole('checkbox').check();
 await Promise.all([row('offer-one').getByRole('button',{name:'Confirm offer',exact:true}).click(),row('offer-two',competitor).getByRole('button',{name:'Confirm offer',exact:true}).click()]);
 saved=await get('placements/student-one');
 check(Object.keys(await get('placements')).length===1,'Concurrent offers create exactly one placement');
 const flags=Object.values(await get('applications')).filter(a=>a.IsConfirmedByStudent);
 check(flags.length===1&&flags[0].Id===saved.ApplicationId,'Only winning offer marked confirmed');
 check(await page.getByRole('alert').count()+await competitor.getByRole('alert').count()===1,'Competing session sees conflict');
 await context.close();await page.reload();
 for(const width of [1440,390]){await page.setViewportSize({width,height:1000});check(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),'No overflow '+width);await page.screenshot({path:'tests/artifacts/confirmed-offer-'+width+'.png',fullPage:true});}
 await seed();await applications();await page.setViewportSize({width:1440,height:1000});
 return {passed:checks,system:'O03 Web Forms + local Firebase simulation'};
}
