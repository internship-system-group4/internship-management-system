// Disposable IIS host + Firebase Postman simulation on port 4920 only.
async page => {
 const base=new URL(page.url()).origin,db='http://localhost:4920/firebase',checks=[];
 const check=(ok,name)=>{if(!ok)throw Error(name);checks.push(name);};
 await page.request.post(db+'/__reset');
 for(const [id,cv,portfolio] of [['available','https://example.com/cv.pdf',''],['missing','',''],['unsafe','javascript:alert(1)',''],['portfolio','','https://example.com/portfolio']]){
  await page.request.put(db+'/users/modal-'+id+'.json',{data:{Id:'modal-'+id,FullName:'Synthetic candidate',Role:1,IsActive:true,Major:'Computer Science',CvUrl:cv,PortfolioUrl:portfolio}});
  await page.request.put(db+'/placements/modal-'+id+'.json',{data:{Id:'modal-'+id,StudentId:'modal-'+id,StudentName:'Synthetic candidate',CompanyId:'company-one',CompanyName:'Training Company',OpportunityId:'internship-one',OpportunityTitle:'Synthetic internship',Status:0,RequiredHours:160}});
 }
 const ctx=await page.context().browser().newContext(),p=await ctx.newPage(),errors=[];
 p.on('pageerror',e=>errors.push(e.message));
 await p.goto(base+'/__fixture.aspx?user=supervisor-one');
 for(const lang of ['en','ar'])for(const theme of ['light','dark'])for(const id of ['available','missing','unsafe','portfolio']){
  await ctx.addCookies([{name:'uims-lang',value:lang,url:base}]);
  await p.setViewportSize({width:lang==='ar'?390:1440,height:900});
  const response=await p.goto(base+'/Pages/Company/TraineeDetails.aspx?id=modal-'+id);
  check(response.status()===200,'Page compiles: '+lang+'/'+theme+'/'+id);
  await p.evaluate(t=>window.UimsTheme.set(t),theme);
  const opener=p.locator('[data-bs-target="#cvModal"]');await opener.click();await p.locator('#cvModal.show').waitFor();await p.waitForFunction(()=>document.activeElement.closest('#cvModal')&&!bootstrap.Modal.getInstance(document.getElementById('cvModal'))._isTransitioning);
  const available=['available','portfolio'].includes(id);
  check(await p.locator('#btnOpenRealCv').count()===(available?1:0)&&await p.locator('#divNoCv').count()===(available?0:1),'Exactly one document state: '+lang+'/'+theme+'/'+id);
  if(available)check(await p.locator('#btnOpenRealCv').getAttribute('href')===(id==='available'?'https://example.com/cv.pdf':'https://example.com/portfolio'),'Correct document target: '+id);
  check(await p.locator('#cvModal').getAttribute('aria-labelledby')==='traineeCvTitle','Modal has an accessible title');
  check(await p.locator('#cvModal .modal-content').evaluate(e=>{const r=e.getBoundingClientRect();return r.left>=0&&r.right<=innerWidth&&r.height<=innerHeight;}),'Modal fits viewport: '+lang+'/'+theme+'/'+id);
  if(lang==='ar'&&theme==='dark'&&id==='missing')await p.screenshot({path:'tests/artifacts/trainee-document-modal-ar-dark.png'});
  await p.keyboard.press('Escape');await p.locator('#cvModal.show').waitFor({state:'hidden'});await p.waitForFunction(()=>document.activeElement.matches('[data-bs-target="#cvModal"]'));
  check(await opener.evaluate(e=>e===document.activeElement),'Escape closes and restores focus');
 }
 await ctx.close();await page.request.post(db+'/__reset');check(errors.length===0,'No uncaught browser errors');return {passed:checks.length,checks};
}
