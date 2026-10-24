async page => {
 // Read-only regression test against the disposable application fixture host.
 // ui-fixture is optional: a host with display fixtures also exercises populated rows.
 const base=new URL(page.url()).origin,checks=[];
 const check=(value,name)=>{if(!value)throw Error(name);checks.push(name);};
 for(const lang of ['en','ar']){
  const ctx=await page.context().browser().newContext({viewport:{width:1440,height:1000},reducedMotion:'reduce'});
  await ctx.addCookies([{name:'uims-lang',value:lang,url:base}]);
  await ctx.addInitScript(()=>localStorage.setItem('uims-theme','light'));
  const p=await ctx.newPage();await p.goto(base+'/__fixture.aspx?user=supervisor-one');
  for(const route of ['/Pages/Company/Dashboard.aspx','/Pages/Company/Trainees.aspx?ui-fixture=1','/Pages/Company/TraineeDetails.aspx?id=student-one&ui-fixture=1']){
   const response=await p.goto(base+route);
   check(response.status()===200,lang+' '+route+' renders');
   for(const theme of ['light','dark']){
    if(await p.evaluate(()=>document.documentElement.dataset.theme)!==theme){
     await p.locator('[data-theme-toggle]:visible').first().click();
     await p.waitForFunction(t=>document.documentElement.dataset.theme===t,theme);
     await p.waitForTimeout(300);
    }
    const result=await p.evaluate(()=>{
     const probe=document.createElement('i');probe.style.backgroundColor='var(--ui-surface)';probe.hidden=true;document.body.appendChild(probe);
     const allowed=[];for(const value of ['var(--ui-surface)','var(--ui-surface-raised)','var(--ui-neutral-soft)',...(document.documentElement.dataset.theme==='light'?['var(--bs-light,#f8f9fa)']:[])]){probe.style.backgroundColor=value;allowed.push(getComputedStyle(probe).backgroundColor);}probe.remove();
     const surfaces=[...document.querySelectorAll('.search-container,.metric-card,.card-custom,.card-custom-header,.workflow-link')].filter(e=>e.getBoundingClientRect().width>0);
     return {count:surfaces.length,bad:surfaces.filter(e=>!allowed.includes(getComputedStyle(e).backgroundColor)).map(e=>e.className),saved:localStorage.getItem('uims-theme'),server:/Server Error in|Compilation Error|Parser Error/.test(document.body.innerText.slice(0,400))};
    });
    check(result.count>0&&!result.bad.length&&!result.server,lang+' '+theme+' shared Company surfaces: '+result.bad.join(', '));
    check(result.saved===theme,lang+' '+theme+' preference remains saved');
   }
  }
  await ctx.close();
 }
 return {passed:checks.length,checks};
}
