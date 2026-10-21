async page => {
 const base='http://localhost:57982',db='http://localhost:4900/firebase';let checks=0,pages=0;
 const check=(ok,message)=>{if(!ok)throw Error(message);checks++;};
 for(const [id,Role,FullName] of [['academic-one',3,'Academic Supervisor'],['coordinator-one',4,'Internship Coordinator']]) {
  await page.request.put(db+'/users/'+id+'.json',{data:{Id:id,Role,FullName,IsActive:true,MustChangePassword:false,Email:id+'@example.com'}});
 }
 const roles=[
  {folder:'Student',id:'student-one',name:'Student',count:7,routes:['Dashboard','Profile','Opportunities','OpportunityDetails','Apply','MyApplications','MyTasks','Progress'],alias:{OpportunityDetails:'Opportunities',Apply:'MyApplications'},wrong:'Company'},
  {folder:'Company',id:'supervisor-one',name:'Company',count:9,routes:['Dashboard','Opportunities','Applications','Trainees','TraineeDetails','Tasks','TaskReview','FinalEvaluation','Account'],alias:{TraineeDetails:'Trainees'},wrong:'Academic'},
  {folder:'Academic',id:'academic-one',name:'Academic',count:5,routes:['Dashboard','StudentProgress','FinalEvaluation','Account'],alias:{},wrong:'Coordinator'},
  {folder:'Coordinator',id:'coordinator-one',name:'Coordinator',count:10,routes:['Dashboard','Students','Companies','AcademicSupervisors','Groups','Placements','PlacementDetails','CompletionReview','ContactMessages','Account'],alias:{PlacementDetails:'Placements'},wrong:'Student'}
 ];
 for(const role of roles){
  await page.setViewportSize({width:1440,height:1000});
  await page.goto(base+'/__fixture.aspx?user='+role.id);
  for(const route of role.routes){
   await page.goto(base+'/Pages/'+role.folder+'/'+route+'.aspx');
   check(await page.locator('.uims-sidebar').count()===1,'Exactly one sidebar '+role.folder+'/'+route);
   check(await page.locator('.uims-side-link').count()===role.count,'Role-specific links '+role.folder+'/'+route);
   const href=await page.locator('.uims-side-link[aria-current="page"]').getAttribute('href');
   check(href.endsWith('/'+(role.alias[route]||route)+'.aspx'),'Active navigation '+role.folder+'/'+route);
   check(await page.locator('body').getAttribute('class')===role.folder.toLowerCase()+'-portal uims-portal','Correct role shell');
   pages++;
  }
  for(const route of ['MyMeetings','Schedule']){
   await page.goto(base+'/Pages/Meetings/'+route+'.aspx');
   check(await page.locator('body').getAttribute('class')===role.folder.toLowerCase()+'-portal uims-portal','Meetings retains '+role.folder+' shell');
   check((await page.locator('.uims-side-link[aria-current="page"]').getAttribute('href')).endsWith('/MyMeetings.aspx'),'Active Meetings');pages++;
  }
  await page.goto(base+'/Pages/'+role.folder+'/Dashboard.aspx');
  await page.screenshot({path:'tests/artifacts/'+role.folder.toLowerCase()+'-shell-desktop.png',fullPage:true});
  await page.setViewportSize({width:390,height:900});
  const toggle=page.getByRole('button',{name:'Open navigation',exact:true});
  check(await toggle.isVisible(),'Mobile hamburger '+role.folder);
  check(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),'Mobile overflow '+role.folder);
  await toggle.click();
  const sidebar=page.locator('[data-portal-sidebar]');
  await sidebar.evaluate(el=>Promise.all(el.getAnimations().map(a=>a.finished)));
  check(await page.getByRole('dialog',{name:role.name+' navigation'}).isVisible(),'Accessible drawer '+role.folder);
  await page.screenshot({path:'tests/artifacts/'+role.folder.toLowerCase()+'-shell-mobile.png',fullPage:true});
  await page.keyboard.press('Escape');
  check(await toggle.getAttribute('aria-expanded')==='false','Escape '+role.folder);
  await page.goto(base+'/Pages/'+role.wrong+'/Dashboard.aspx');
  check(page.url().includes('AccessDenied'),'Wrong role remains blocked '+role.folder);
  await page.goto(base+'/Pages/'+role.folder+'/Dashboard.aspx');
  await page.getByRole('button',{name:'Open navigation',exact:true}).click();
  await page.getByRole('link',{name:'Log out',exact:true}).click();
  await page.waitForURL('**/Account/Login.aspx');
  await page.goto(base+'/Pages/'+role.folder+'/Dashboard.aspx');
  check(page.url().includes('Login.aspx'),'Logout protects '+role.folder);
 }
 await page.goto(base+'/__fixture.aspx');
 await page.setViewportSize({width:1440,height:1000});
 return {passed:checks,protectedPages:pages,roles:4};
}
