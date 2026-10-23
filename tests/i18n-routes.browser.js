async page => {
 // Opens every route in English and Arabic as the right role and reports status, direction, server errors,
 // missing/fallback text (from #uims-i18n-gaps), horizontal overflow and page errors. Optional screenshots.
 // Run against tests/Start-LoginTestHost.ps1 (57992) with the campus-login simulation (4910). Read-only.
 const base='http://localhost:57992', LANGS=['en','ar'], WIDTHS=[[1440,900],[390,844],[320,700]], SHOTS=null; // e.g. SHOTS='tests/artifacts/i18n/routes/'
 const routes={
  public:['/Default.aspx','/Pages/Public/About.aspx','/Pages/Public/Contact.aspx','/Pages/Public/PoweredBy.aspx','/Pages/Public/AccessDenied.aspx','/Pages/Account/Login.aspx','/Pages/Account/ForgotPassword.aspx'],
  'student-one':['/Pages/Student/Dashboard.aspx','/Pages/Student/Opportunities.aspx','/Pages/Student/OpportunityDetails.aspx?id=internship-one','/Pages/Student/Apply.aspx?opportunityId=internship-one','/Pages/Student/MyApplications.aspx','/Pages/Student/MyTasks.aspx','/Pages/Student/Progress.aspx','/Pages/Student/Profile.aspx','/Pages/Student/DisplayEditProfile.aspx','/Pages/Student/StudentCVPortfolio.aspx','/Pages/Account/Notifications.aspx','/Pages/Account/ChangePassword.aspx','/Pages/Meetings/MyMeetings.aspx'],
  'supervisor-one':['/Pages/Company/Dashboard.aspx','/Pages/Company/Opportunities.aspx','/Pages/Company/ManageOpportunities.aspx','/Pages/Company/ViewOpportunity.aspx?id=internship-one','/Pages/Company/Applications.aspx','/Pages/Company/Trainees.aspx','/Pages/Company/TraineeDetails.aspx','/Pages/Company/Tasks.aspx','/Pages/Company/TaskReview.aspx','/Pages/Company/FinalEvaluation.aspx','/Pages/Company/Account.aspx','/Pages/Meetings/Schedule.aspx'],
  'academic-one':['/Pages/Academic/Dashboard.aspx','/Pages/Academic/StudentProgress.aspx','/Pages/Academic/FinalEvaluation.aspx','/Pages/Academic/Account.aspx'],
  'coordinator-one':['/Pages/Coordinator/Dashboard.aspx','/Pages/Coordinator/Students.aspx','/Pages/Coordinator/ManageStudents.aspx','/Pages/Coordinator/Companies.aspx','/Pages/Coordinator/AcademicSupervisors.aspx','/Pages/Coordinator/Groups.aspx','/Pages/Coordinator/ConfiguredGroups.aspx','/Pages/Coordinator/Placements.aspx','/Pages/Coordinator/PlacementDetails.aspx','/Pages/Coordinator/CompletionReview.aspx','/Pages/Coordinator/ContactMessages.aspx']
 };
 const rows=[];
 for(const lang of LANGS)for(const [w,h] of WIDTHS)for(const [who,list] of Object.entries(routes)){
  const ctx=await page.context().browser().newContext({viewport:{width:w,height:h},reducedMotion:'reduce',isMobile:w<500,hasTouch:w<500});
  await ctx.addCookies([{name:'uims-lang',value:lang,url:base}]);
  const p=await ctx.newPage();const errors=[];p.on('pageerror',e=>errors.push(e.message.slice(0,100)));
  if(who!=='public')await p.goto(base+'/__fixture.aspx?user='+who);
  for(const route of list){
   errors.length=0;let status=0;try{status=(await p.goto(base+route,{timeout:30000})).status();}catch(e){status=-1;}
   await p.waitForTimeout(500);
   const info=await p.evaluate(()=>{const g=document.getElementById('uims-i18n-gaps');let gaps=[];try{gaps=g?JSON.parse(g.textContent).split(' ').filter(Boolean):[];}catch(e){}
    return {dir:document.documentElement.dir,htmlLang:document.documentElement.lang,server:/Server Error in|Compilation Error|Parser Error/.test(document.body?document.body.innerText.slice(0,400):''),gaps,overflow:document.documentElement.scrollWidth-document.documentElement.clientWidth,title:document.title};}).catch(e=>({err:String(e).slice(0,80)}));
   if(SHOTS)await p.screenshot({path:SHOTS+lang+'-'+(who+route).replace(/[^a-z0-9]+/gi,'-').toLowerCase()+'-'+w+'.png',fullPage:true}).catch(()=>{});
   rows.push({lang,w,who,route,status,...info,errors:errors.slice(0,2)});
  }
  await ctx.close();
 }
 const problems=rows.filter(r=>r.status!==200||r.server||r.err||r.htmlLang!==r.lang||r.overflow>0||r.errors.length||(r.lang==='ar'&&r.dir!=='rtl'));
 const gapCount=rows.filter(r=>r.lang==='ar').reduce((n,r)=>n+(r.gaps?r.gaps.length:0),0);
 return {routes:rows.length,problems,gapCount,gaps:[...new Set(rows.flatMap(r=>r.gaps||[]))].slice(0,80)};
}
