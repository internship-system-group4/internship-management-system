async page => {
 // Captures every route for the theme work. Edit OUT and THEME before running:
 //   THEME null  = no stored preference (first visit), 'light' | 'dark' | 'system' = stored preference.
 // Run against tests/Start-LoginTestHost.ps1 (57992) with the campus-login simulation (4910). Read-only.
 const OUT='tests/artifacts/theme/light-before/', THEME=null, WIDTHS=[[1440,900],[390,844]];
 const base='http://localhost:57992';
 const routes={
  public:['/Default.aspx','/Pages/Public/About.aspx','/Pages/Public/Contact.aspx','/Pages/Public/PoweredBy.aspx','/Pages/Public/AccessDenied.aspx','/Pages/Account/Login.aspx','/Pages/Account/ForgotPassword.aspx'],
  'student-one':['/Pages/Student/Dashboard.aspx','/Pages/Student/Opportunities.aspx','/Pages/Student/exploreOpport.aspx','/Pages/Student/OpportunityDetails.aspx?id=internship-one','/Pages/Student/Apply.aspx?opportunityId=internship-one','/Pages/Student/MyApplications.aspx','/Pages/Student/MyTasks.aspx','/Pages/Student/Progress.aspx','/Pages/Student/Profile.aspx','/Pages/Student/DisplayEditProfile.aspx','/Pages/Student/StudentCVPortfolio.aspx','/Pages/Account/Notifications.aspx','/Pages/Account/ChangePassword.aspx','/Pages/Account/CompletionReport.aspx','/Pages/Meetings/MyMeetings.aspx'],
  'supervisor-one':['/Pages/Company/Dashboard.aspx','/Pages/Company/Opportunities.aspx','/Pages/Company/ManageOpportunities.aspx','/Pages/Company/ViewOpportunity.aspx?id=internship-one','/Pages/Company/Applications.aspx','/Pages/Company/Trainees.aspx','/Pages/Company/TraineeDetails.aspx','/Pages/Company/Tasks.aspx','/Pages/Company/TaskReview.aspx','/Pages/Company/FinalEvaluation.aspx','/Pages/Company/Account.aspx','/Pages/Company/ApplicantDocument.aspx','/Pages/Meetings/Schedule.aspx'],
  'academic-one':['/Pages/Academic/Dashboard.aspx','/Pages/Academic/StudentProgress.aspx','/Pages/Academic/FinalEvaluation.aspx','/Pages/Academic/Account.aspx'],
  'coordinator-one':['/Pages/Coordinator/Dashboard.aspx','/Pages/Coordinator/Students.aspx','/Pages/Coordinator/ManageStudents.aspx','/Pages/Coordinator/AddStudent.aspx','/Pages/Coordinator/Companies.aspx','/Pages/Coordinator/AcademicSupervisors.aspx','/Pages/Coordinator/Groups.aspx','/Pages/Coordinator/ConfiguredGroups.aspx','/Pages/Coordinator/Placements.aspx','/Pages/Coordinator/PlacementDetails.aspx','/Pages/Coordinator/CompletionReview.aspx','/Pages/Coordinator/ContactMessages.aspx']
 };
 const result=[];
 for(const [who,list] of Object.entries(routes)){
  for(const [w,h] of WIDTHS){
   const ctx=await page.context().browser().newContext({viewport:{width:w,height:h},reducedMotion:'reduce',isMobile:w<500,hasTouch:w<500});
   if(THEME)await ctx.addInitScript(t=>{try{localStorage.setItem('uims-theme',t);}catch(e){}},THEME);
   const p=await ctx.newPage();const errors=[];p.on('pageerror',e=>errors.push(e.message.slice(0,120)));
   if(who!=='public')await p.goto(base+'/__fixture.aspx?user='+who);
   for(const route of list){
    let status=0;try{const r=await p.goto(base+route,{waitUntil:'load',timeout:30000});status=r?r.status():0;}catch(e){status=-1;}
    await p.waitForTimeout(900);
    const name=(who+route).replace(/[^a-z0-9]+/gi,'-').replace(/-aspx/gi,'').replace(/^-|-$/g,'').toLowerCase();
    const info=await p.evaluate(()=>({path:location.pathname,theme:document.documentElement.getAttribute('data-theme'),overflow:document.documentElement.scrollWidth-innerWidth})).catch(()=>({}));
    await p.screenshot({path:OUT+name+'-'+w+'.png',fullPage:true,animations:'disabled'}).catch(()=>{});
    result.push([who,route,w,status,info.path,info.theme,info.overflow]);
   }
   if(errors.length)result.push([who,'ERRORS',w,errors.slice(0,3).join(' | ')]);
   await ctx.close();
  }
 }
 return result;
}
