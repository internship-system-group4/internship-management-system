async page => {
 // Paired Light/Dark screenshots of the same routes and fixture data: tests/artifacts/theme/pairs/<name>-<theme>-<width>.png
 // Run against tests/Start-LoginTestHost.ps1 (57992) with the campus-login simulation (4910). Read-only.
 const OUT='tests/artifacts/theme/pairs/',base='http://localhost:57992';
 const sets=[['public',['/Default.aspx','/Pages/Public/About.aspx','/Pages/Public/Contact.aspx','/Pages/Account/Login.aspx','/Pages/Public/PoweredBy.aspx']],
  ['student-one',['/Pages/Student/Dashboard.aspx','/Pages/Student/StudentCVPortfolio.aspx']],['supervisor-one',['/Pages/Company/Dashboard.aspx','/Pages/Company/Account.aspx']],
  ['academic-one',['/Pages/Academic/Dashboard.aspx']],['coordinator-one',['/Pages/Coordinator/Dashboard.aspx','/Pages/Coordinator/ContactMessages.aspx']]];
 const done=[];
 for(const theme of ['light','dark'])for(const [w,h] of [[1440,900],[390,844]])for(const [who,routes] of sets){
  const ctx=await page.context().browser().newContext({viewport:{width:w,height:h},isMobile:w<500,hasTouch:w<500,reducedMotion:'reduce'});
  await ctx.addInitScript(t=>{try{localStorage.setItem('uims-theme',t);}catch(e){}},theme);
  const p=await ctx.newPage();if(who!=='public')await p.goto(base+'/__fixture.aspx?user='+who);
  for(const route of routes){
   await p.goto(base+route);await p.waitForTimeout(1500);
   const name=(who==='public'?'':who.split('-')[0]+'-')+route.split('/').pop().replace('.aspx','').toLowerCase();
   await p.screenshot({path:OUT+name+'-'+theme+'-'+w+'.png'});
   if(w===1440)await p.screenshot({path:OUT+name+'-'+theme+'-'+w+'-full.png',fullPage:true});
   done.push(name+'-'+theme+'-'+w);
  }
  await ctx.close();
 }
 return done.length;
}
