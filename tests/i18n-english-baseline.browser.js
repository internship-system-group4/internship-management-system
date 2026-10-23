async page => {
 // English must look as it did before localization. Screenshots the same English pages from the committed build
 // (baseline host, 57993) and the working copy (57992). Compare with: python -I tools/i18n/compare-english.py
 const hosts={before:'http://localhost:57993',after:'http://localhost:57992'},OUT='tests/artifacts/i18n/english-';
 const pages=[['public','home','/Default.aspx'],['public','about','/Pages/Public/About.aspx'],['public','contact','/Pages/Public/Contact.aspx'],
  ['public','login','/Pages/Account/Login.aspx'],['public','forgot','/Pages/Account/ForgotPassword.aspx'],
  ['student-one','student-dashboard','/Pages/Student/Dashboard.aspx'],['student-one','student-tasks','/Pages/Student/MyTasks.aspx'],['student-one','student-profile','/Pages/Student/Profile.aspx'],
  ['supervisor-one','company-dashboard','/Pages/Company/Dashboard.aspx'],['supervisor-one','company-final','/Pages/Company/FinalEvaluation.aspx'],
  ['academic-one','academic-dashboard','/Pages/Academic/Dashboard.aspx'],['coordinator-one','coordinator-dashboard','/Pages/Coordinator/Dashboard.aspx'],
  ['coordinator-one','coordinator-companies','/Pages/Coordinator/Companies.aspx']];
 const overflow={};
 for(const [w,h] of [[1440,900],[390,844],[320,700]])for(const [tag,base] of Object.entries(hosts)){
  const ctx=await page.context().browser().newContext({viewport:{width:w,height:h},reducedMotion:'reduce',isMobile:w<500,hasTouch:w<500});
  await ctx.addCookies([{name:'uims-lang',value:'en',url:base}]);const p=await ctx.newPage();let who='';
  for(const [user,name,route] of pages){
   if(user!=='public'&&user!==who){await p.goto(base+'/__fixture.aspx?user='+user);who=user;}
   await p.goto(base+route,{waitUntil:'load'});await p.waitForTimeout(900);
   await p.addStyleTag({content:'*,*::before,*::after{animation:none!important;transition:none!important;caret-color:transparent!important}canvas,video{visibility:hidden!important}'});
   overflow[tag+' '+w+' '+name]=await p.evaluate(()=>document.documentElement.scrollWidth-document.documentElement.clientWidth);
   if(w!==320)await p.screenshot({path:OUT+tag+'/'+name+'-'+w+'.png',fullPage:false});
  }
  await ctx.close();
 }
 return Object.fromEntries(Object.entries(overflow).filter(([k,v])=>v>0));
}
