async page=>{
 const base='http://localhost:58014';let captures=0;const checks=[];
 for(const [role,id,route] of [['Student','student-one','Profile.aspx'],['Company','supervisor-one','Applications.aspx'],['Academic','academic-one','StudentProgress.aspx?id=student-one'],['Coordinator','coordinator-one','CompletionReview.aspx']]){
  await page.context().clearCookies();await page.goto(base+'/__fixture.aspx?user='+id);
  for(const width of [1440,390]){
   await page.setViewportSize({width,height:1000});await page.goto(base+'/Pages/'+role+'/'+route);await page.evaluate(()=>document.fonts.ready);await page.waitForTimeout(400);
   if(!await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1))throw Error(role+' work page overflow');
   if(role==='Student'&&await page.locator('.sp-error').isVisible())throw Error('Profile must load actual fields');
   await page.screenshot({path:'tests/artifacts/charts-'+role+'-work-'+width+'.png',fullPage:true});captures++;checks.push(role+' work fits '+width);
  }
 }
 await page.context().clearCookies();
 for(const [name,route] of [['Home','Default.aspx'],['About','Pages/Public/About.aspx'],['Contact','Pages/Public/Contact.aspx'],['Login','Pages/Account/Login.aspx'],['PoweredBy','Pages/Public/PoweredBy.aspx']])for(const width of [1440,390]){
  await page.setViewportSize({width,height:1000});await page.goto(base+'/'+route);await page.evaluate(()=>document.fonts.ready);await page.waitForTimeout(900);if(name==='PoweredBy')await page.waitForFunction(()=>{const root=document.querySelector('[data-team-experience]');return root.dataset.mode==='ready'&&root.dataset.camera==='overview';},null,{timeout:25000});
  if(!await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1))throw Error(name+' overflow');
  const font=await page.locator('body').evaluate(el=>getComputedStyle(el).fontFamily);if(!font.includes('Noto Sans'))throw Error(name+' font');
  await page.screenshot({path:'tests/artifacts/charts-'+name+'-'+width+'.png'});captures++;checks.push(name+' approved font and fits '+width);
 }
 return {captures,checks,scope:'Current desktop/mobile work pages and public first viewport; cinematic content preserved.'};
}
