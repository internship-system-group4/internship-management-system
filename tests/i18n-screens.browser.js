async page => {
 // Paired English / Arabic screenshots (Light and Dark) of the public pages and the four dashboards.
 // Read-only against the disposable host and simulation. Output: tests/artifacts/i18n/<theme>/<lang>-<name>-<width>.png
 const base='http://localhost:57992',OUT='tests/artifacts/i18n/';
 const SHOTS=[
  ['public','home','/Default.aspx'],['public','about','/Pages/Public/About.aspx'],['public','contact','/Pages/Public/Contact.aspx'],
  ['public','powered-by','/Pages/Public/PoweredBy.aspx'],['public','login','/Pages/Account/Login.aspx'],
  ['student-one','student-dashboard','/Pages/Student/Dashboard.aspx'],['supervisor-one','company-dashboard','/Pages/Company/Dashboard.aspx'],
  ['academic-one','academic-dashboard','/Pages/Academic/Dashboard.aspx'],['coordinator-one','coordinator-dashboard','/Pages/Coordinator/Dashboard.aspx']
 ];
 const RUNS=[['light',1440,900],['light',390,844],['dark',1440,900]];
 const saved=[];
 for(const [theme,w,h] of RUNS)for(const lang of ['en','ar']){
  const ctx=await page.context().browser().newContext({viewport:{width:w,height:h},reducedMotion:'reduce',colorScheme:theme,isMobile:w<500,hasTouch:w<500});
  await ctx.addCookies([{name:'uims-lang',value:lang,url:base}]);
  await ctx.addInitScript(t=>{try{localStorage.setItem('uims-theme',t);}catch(e){}},theme);
  const p=await ctx.newPage();let who='';
  for(const [user,name,route] of SHOTS){
   if(theme==='dark'&&user==='public'&&name!=='home'&&name!=='contact')continue;
   if(user!=='public'&&user!==who){await p.goto(base+'/__fixture.aspx?user='+user);who=user;}
   await p.goto(base+route,{waitUntil:'load'});await p.waitForTimeout(900);
   const file=OUT+theme+'/'+lang+'-'+name+'-'+w+'.png';await p.screenshot({path:file,fullPage:false});saved.push(file);
  }
  await ctx.close();
 }
 return saved.length;
}
