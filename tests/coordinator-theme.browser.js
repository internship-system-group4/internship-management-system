async page=>{
 const base='http://localhost:58137',browser=page.context().browser(),checks=[];
 const check=(ok,name)=>{if(!ok)throw Error(name);checks.push(name);};
 const c=await browser.newContext({viewport:{width:1440,height:900},reducedMotion:'no-preference'}),p=await c.newPage();
 await p.goto(base+'/__fixture.aspx?user=coordinator-one');await p.evaluate(()=>window.UimsTheme.set('light'));
 for(const route of ['Dashboard','ManageStudents','Companies','AcademicSupervisors','Groups','Placements','CompletionReview','ContactMessages','Account']){
  await p.goto(base+'/Pages/Coordinator/'+route+'.aspx');
  for(const target of ['dark','light']){
   await p.locator('[data-theme-toggle]').click();await p.waitForFunction(()=>document.documentElement.getAnimations({subtree:true}).some(a=>a.effect?.pseudoElement==='::view-transition-new(root)'&&a.playState==='running'));
   const during=await p.evaluate(()=>{const r=document.documentElement,a=r.getAnimations({subtree:true}).find(a=>a.effect?.pseudoElement==='::view-transition-new(root)');return {theme:r.dataset.theme,root:getComputedStyle(r).viewTransitionName,sidebar:getComputedStyle(document.querySelector('aside')).viewTransitionName,main:getComputedStyle(document.querySelector('main')).viewTransitionName,duration:a.effect.getTiming().duration,clip:getComputedStyle(r,'::view-transition-new(root)').clipPath};});
   check(during.theme===target&&during.root==='root'&&during.sidebar==='none'&&during.main==='none'&&during.duration===900&&during.clip.startsWith('circle('),'Real circular '+target+' reveal captures whole page: Coordinator/'+route);
   await p.waitForFunction(()=>!document.documentElement.classList.contains('uims-theme-reveal'));
   check(await p.evaluate(()=>getComputedStyle(document.documentElement).viewTransitionName==='none'&&getComputedStyle(document.querySelector('aside')).viewTransitionName==='portal-sidebar'&&getComputedStyle(document.querySelector('main')).viewTransitionName==='portal-main'),'Route transition names restored: '+route+'/'+target);
  }
 }
 await p.setViewportSize({width:390,height:760});await c.addCookies([{name:'uims-lang',value:'ar',url:base}]);await p.reload();await p.locator('.student-nav-toggle').click();await p.waitForTimeout(350);await p.locator('[data-theme-toggle]').click();await p.waitForTimeout(180);
 check(await p.evaluate(()=>document.documentElement.dir==='rtl'&&getComputedStyle(document.documentElement,'::view-transition-new(root)').clipPath.startsWith('circle(')),'Arabic mobile drawer uses circular theme reveal');await p.waitForFunction(()=>!document.documentElement.classList.contains('uims-theme-reveal'));
 await p.emulateMedia({reducedMotion:'reduce'});await p.locator('[data-theme-toggle]').click();check(await p.evaluate(()=>document.documentElement.dataset.theme==='light'&&!document.documentElement.classList.contains('uims-theme-reveal')),'Reduced motion switches immediately');
 await c.close();
 for(const [role,id]of[['Student','student-one'],['Company','supervisor-one'],['Academic','academic-one']]){
  const ctx=await browser.newContext({viewport:{width:1440,height:900},reducedMotion:'no-preference'}),q=await ctx.newPage();await q.goto(base+'/__fixture.aspx?user='+id);await q.goto(base+'/Pages/'+role+'/Dashboard.aspx');await q.locator('[data-theme-toggle]').click();await q.waitForFunction(()=>document.documentElement.getAnimations({subtree:true}).some(a=>a.effect?.pseudoElement==='::view-transition-new(root)'&&a.playState==='running'));check(true,'Existing circular reveal retained: '+role);await q.waitForFunction(()=>!document.documentElement.classList.contains('uims-theme-reveal'));await ctx.close();
 }
 return {passed:checks.length,coordinatorPages:9,checks};
}
