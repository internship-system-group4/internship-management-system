// Run against a disposable IIS host and the Firebase Postman simulation on 4920.
// Exercises selection postbacks only; submits no evaluation or certificate.
async page => {
 const base=new URL(page.url()).origin,db='http://localhost:4920/firebase',checks=[];
 const check=(ok,name)=>{if(!ok)throw Error(name);checks.push(name);};
 await page.request.post(db+'/__reset');
 for(const [id,name,cv] of [['cv','Candidate with CV','https://example.com/cv.pdf'],['none','Candidate without CV',''],['unsafe','Candidate with unsafe URL','javascript:alert(1)']]){
  await page.request.put(db+'/users/eval-'+id+'.json',{data:{Id:'eval-'+id,FullName:name,Role:1,IsActive:true,Major:'Computer Science',CvUrl:cv}});
  await page.request.put(db+'/placements/eval-'+id+'.json',{data:{Id:'eval-'+id,StudentId:'eval-'+id,StudentName:name,CompanyId:'company-one',CompanyName:'Training Company',OpportunityId:'internship-one',OpportunityTitle:'Synthetic internship',Status:0}});
 }
 const ctx=await page.context().browser().newContext(),p=await ctx.newPage();
 const errors=[];p.on('pageerror',e=>errors.push(e.message));
 await p.goto(base+'/__fixture.aspx?user=supervisor-one');
 for(const language of ['en','ar']){
  await ctx.addCookies([{name:'uims-lang',value:language,url:base}]);
  const response=await p.goto(base+'/Pages/Company/FinalEvaluation.aspx');
  check(response.status()===200,'Page compiles: '+language);
  check(await p.locator('[id$=hlViewCV]').count()===0,'No CV action before selection: '+language);
  async function select(id,name){
   await Promise.all([p.waitForResponse(r=>r.request().method()==='POST'),p.locator('select[id$=ddlTrainees]').selectOption(id)]);
   if(name)await p.waitForFunction(expected=>document.querySelector('#jsStudentName').textContent===expected,name);
   check(await p.locator('#serverMessageModal.show').count()===0,'No selection exception: '+language+'/'+id);
  }
  await select('eval-cv','Candidate with CV');
  check(await p.locator('[id$=hlViewCV]').getAttribute('href')==='https://example.com/cv.pdf','CV link is populated: '+language);
  await select('eval-none','Candidate without CV');
  check(await p.locator('[id$=hlViewCV]').count()===0,'No stale CV after changing trainee: '+language);
  await select('eval-unsafe','Candidate with unsafe URL');
  check(await p.locator('[id$=hlViewCV]').count()===0,'Unsafe CV URL stays hidden: '+language);
  await select('eval-cv','Candidate with CV');
  await select('');
  check(await p.locator('[id$=hlViewCV]').count()===0,'Clearing selection hides CV without null reference: '+language);
 }
 check(errors.length===0,'No uncaught browser errors');
 await ctx.close();await page.request.post(db+'/__reset');return {passed:checks.length,checks};
}
