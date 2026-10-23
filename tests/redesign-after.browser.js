async page => {
 const base='http://localhost:58013';page.setDefaultNavigationTimeout(25000);
 for(const [role,id,detail] of [['Student','student-one','Opportunities.aspx'],['Company','supervisor-one','Applications.aspx'],['Academic','academic-one','StudentProgress.aspx?id=student-one'],['Coordinator','coordinator-one','CompletionReview.aspx']]){
  await page.context().clearCookies();await page.goto(base+'/__fixture.aspx?user='+id);
  for(const width of [1440,390])for(const [kind,route] of [['dashboard','Dashboard.aspx'],['work',detail]]){await page.setViewportSize({width,height:1000});await page.goto(base+'/Pages/'+role+'/'+route);await page.waitForTimeout(600);await page.screenshot({path:'tests/artifacts/redesign-after-'+role+'-'+kind+'-'+width+'.png',fullPage:true});}
 }
 await page.context().clearCookies();
 for(const [name,route] of [['Home','Default.aspx'],['About','Pages/Public/About.aspx'],['Contact','Pages/Public/Contact.aspx'],['Login','Pages/Account/Login.aspx'],['PoweredBy','Pages/Public/PoweredBy.aspx']])for(const width of [1440,390]){await page.setViewportSize({width,height:1000});await page.goto(base+'/'+route);await page.waitForTimeout(800);const captureHeight=Math.min(24000,await page.evaluate(()=>document.documentElement.scrollHeight));for(let y=0;y<captureHeight;y+=850){await page.evaluate(y=>window.scrollTo(0,y),y);await page.waitForTimeout(160);}await page.waitForTimeout(700);await page.evaluate(()=>window.scrollTo(0,0));await page.waitForTimeout(600);await page.screenshot({path:'tests/artifacts/redesign-after-'+name+'-'+width+'.png',fullPage:true});}
 return {captures:26,fixture:'Same dataset is restored before after-captures.'};
}
