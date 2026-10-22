async page => {
 const base='http://localhost:57983',db='http://localhost:4903/firebase';let checks=0;
 const check=(ok,m)=>{if(!ok)throw Error(m);checks++;};
 const get=async path=>(await page.request.get(db+'/'+path+'.json')).json();
 const put=async(path,data)=>page.request.put(db+'/'+path+'.json',{data});
 await page.context().clearCookies();await page.request.post(db+'/__reset');
 const privateOpportunity=await get('opportunities/internship-one');
 await put('opportunities/internship-one',{...privateOpportunity,Requirements:'PRIVATE_REQUIREMENTS_SENTINEL',Description:'PRIVATE_FULL_DESCRIPTION_SENTINEL'});
 const preview={Id:'internship-one',Title:privateOpportunity.Title,CompanyName:privateOpportunity.CompanyName,Location:privateOpportunity.Location,Summary:'Learn through supervised web development work.',Status:1,RemainingSeats:privateOpportunity.TotalSeats-privateOpportunity.FilledSeats,ApplicationDeadline:privateOpportunity.ApplicationDeadline,PublishedAt:Date.now()};
 await put('publicOpportunityPreviews',{
  'internship-one':{...preview,Requirements:'PRIVATE_PREVIEW_EXTRA_SENTINEL'},
  closed:{...preview,Status:2},full:{...preview,RemainingSeats:0},expired:{...preview,ApplicationDeadline:1},
  missingStatus:{Title:'Do not show',RemainingSeats:2},'bad.key':preview,
  encoded:{...preview,Title:'<script>encoded title</script>',PublishedAt:0}
 });
 await page.goto(base+'/Default.aspx');
 check(await page.locator('[data-preview-id]').count()===2,'Only valid open previews');
 check((await page.locator('[data-preview-id="internship-one"]').innerText()).includes(privateOpportunity.Title),'Real modeled opportunity title');
 const html=await page.content();
 check(!html.includes('PRIVATE_REQUIREMENTS_SENTINEL')&&!html.includes('PRIVATE_FULL_DESCRIPTION_SENTINEL')&&!html.includes('PRIVATE_PREVIEW_EXTRA_SENTINEL'),'No private data in HTML');
 check(await page.locator('.home-preview script').count()===0&&(await page.locator('[data-preview-id="encoded"]').innerText()).includes('<script>'),'Summary data encoded');
 await page.locator('#colleges').evaluate(el=>el.scrollIntoView());
 if(!await page.locator('#computing-college').evaluate(el=>el.open)) await page.locator('#computing-college summary').click();
 check((await page.locator('.home-programs').innerText()).includes('Computer Vision and Robotics'),'Tracks from project data');
 check((await page.locator('#colleges').innerText()).includes('School of Computing'),'College from project data');
 check(await page.locator('.home-video-placeholder').count()===1&&(await page.locator('.home-video-placeholder').innerText()).includes('Development placeholder'),'Missing video explicitly identified');
 check(await page.locator('video source').count()===0,'No fake or broken video URL');
 await page.locator('[data-preview-id="internship-one"] a').click();
 check(page.url().includes('/Account/Login.aspx')&&page.url().includes('returnUrl='),'Summary action requires server authentication');
 for(const path of ['/Pages/Student/OpportunityDetails.aspx?id=internship-one','/Pages/Student/Apply.aspx?opportunityId=internship-one']){
  await page.goto(base+path);check(page.url().includes('/Account/Login.aspx'),'Direct protected route denied '+path);
  check(!(await page.content()).includes('PRIVATE_REQUIREMENTS_SENTINEL'),'Direct route never leaks details');
 }
 await page.request.post(db+'/__fail-previews');await page.goto(base+'/Default.aspx');
 check(await page.locator('.public-preview-notice[role="status"]').count()===1&&await page.locator('[data-preview-id]').count()===0,'Preview read failure is honest');
 check(await page.locator('h1').count()===1,'Homepage remains usable after Firebase failure');
 await page.request.post(db+'/__restore-previews');await put('publicOpportunityPreviews',{});await page.reload();
 check((await page.locator('.public-preview-notice').innerText()).includes('No public internship summaries'),'Empty state without invented opportunities');
 for(const [Id,Role] of [['academic-one',3],['coordinator-one',4]])await put('users/'+Id,{Id,Role,FullName:'Role test account',IsActive:true,MustChangePassword:false});
 for(const [id,dashboard] of [['student-one','/Student/Dashboard.aspx'],['supervisor-one','/Company/Dashboard.aspx'],['academic-one','/Academic/Dashboard.aspx'],['coordinator-one','/Coordinator/Dashboard.aspx']]){
  await page.goto(base+'/__fixture.aspx?user='+id);await page.goto(base+'/Pages/Account/Login.aspx?role=1');
  check(page.url().endsWith(dashboard),'Verified existing-session role redirect '+id);
 }
 await page.goto(base+'/__fixture.aspx?user=student-one');
 await put('users/student-one',{...await get('users/student-one'),Role:4});
 await page.goto(base+'/Pages/Account/Login.aspx');
 check(page.url().endsWith('/Coordinator/Dashboard.aspx'),'Role reread instead of cached session role');
 await put('users/student-one',{...await get('users/student-one'),Role:1,IsActive:false});
 await page.goto(base+'/Pages/Account/Login.aspx');
 check(page.url().includes('/Account/Login.aspx')&&(await page.getByRole('alert').innerText()).includes('not active'),'Deactivation blocks login redirect');
 await put('users/student-one',{...await get('users/student-one'),IsActive:true,MustChangePassword:true});
 await page.goto(base+'/__fixture.aspx?user=student-one');await page.goto(base+'/Pages/Account/Login.aspx');
 check(page.url().endsWith('/Account/ChangePassword.aspx'),'Temporary password gate retained');
 await page.context().clearCookies();
 await page.goto(base+'/Pages/Public/Contact.aspx');
 await page.getByLabel('Full name *',{exact:true}).fill('Osama Test');await page.getByLabel('Email address *',{exact:true}).fill('osama@example.com');
 await page.getByLabel('Subject *',{exact:true}).fill('Checking submission progress');await page.getByLabel('Message *',{exact:true}).fill('This local test checks message progress and prevents repeated clicks.');
 await page.evaluate(()=>document.querySelector('form').addEventListener('submit',e=>e.preventDefault(),{once:true}));
 await page.getByRole('button',{name:'Send message'}).click();
 check((await page.locator('[data-submit-status]').innerText()).includes('Sending your message'),'Accessible progress state');
 check(await page.locator('[data-public-form] input[type="submit"]').getAttribute('aria-disabled')==='true','Duplicate action disabled semantically');
 check(await page.evaluate(()=>window.validateContact())===false,'Repeated submission blocked during pending state');
 check(Object.keys(await get('contactMessages')||{}).length===0,'Progress never claims a saved record');
 await page.evaluate(()=>window.dispatchEvent(new Event('pageshow')));
 await page.getByRole('button',{name:'Send message'}).click();
 check((await page.getByRole('alert').innerText()).includes('has been sent')&&Object.keys(await get('contactMessages')).length===1,'Success only after confirmed save');
 await page.request.post(db+'/__reset');await put('publicOpportunityPreviews',{'internship-one':preview});
 for(const width of [1440,768,390]){
  await page.setViewportSize({width,height:1000});await page.goto(base+'/Default.aspx');
  await page.locator('#internship-video').scrollIntoViewIfNeeded();await page.evaluate(()=>scrollTo(0,0));
  await page.evaluate(()=>Promise.all(document.getAnimations().map(a=>a.finished)));
  check(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),'Previews/video no overflow '+width);
  await page.screenshot({path:'tests/artifacts/public-requirements-home-'+width+'.png',fullPage:true});
 }
 await page.emulateMedia({reducedMotion:'reduce'});await page.reload();
 check(await page.locator('.home-story-photo').evaluate(el=>getComputedStyle(el).animationName)==='none','Motion reduced');
 await page.emulateMedia({reducedMotion:'no-preference'});await page.setViewportSize({width:1440,height:1000});await page.goto(base+'/Default.aspx');
 return {passed:checks,mode:'Firebase stand-in + verified fixture sessions; no real Firebase sign-in or reset email asserted',missingAsset:'Official internship video and captions'};
}
