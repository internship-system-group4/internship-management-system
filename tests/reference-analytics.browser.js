async page=>{
 const base='http://localhost:58015',db='http://localhost:4930/firebase',checks=[],errors=[];
 const check=(ok,label)=>{if(!ok)throw Error(label);checks.push(label);};
 const login=async id=>{await page.context().clearCookies();await page.goto(base+'/__fixture.aspx?user='+id);};
 const model=()=>page.locator('[data-analytics-model]').evaluate(el=>JSON.parse(el.textContent));
 page.setDefaultTimeout(8000);page.on('pageerror',e=>errors.push(e.message));
 for(const [role,id,flow] of [['Student','student-one',[32,72]],['Company','supervisor-one',null],['Academic','academic-one',[192,232]],['Coordinator','coordinator-one',[1,2]]]){
  await login(id);
  for(const width of [1440,768,390,320]){
   await page.setViewportSize({width,height:1000});await page.goto(base+'/Pages/'+role+'/Dashboard.aspx');await page.evaluate(()=>document.fonts.ready);await page.waitForTimeout(720);
   const root=page.locator('[data-reference-analytics]');check(await root.getAttribute('data-analytics-ready')==='true',role+' analytics initialized '+width);
   check(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1),role+' viewport fits '+width);
   check(await page.locator('[data-kpi]').count()===4,role+' four truthful KPIs '+width);
   check(await page.locator('.ws-journey').evaluate(el=>el.getBoundingClientRect().top<document.querySelector('.ra-root').getBoundingClientRect().top),role+' journey stays above analytics '+width);
   if(width===1440)check(await page.locator('.ra-primary').evaluate(el=>getComputedStyle(el).gridTemplateColumns.split(' ').length)===2,role+' two primary columns');
   const data=await model();check(Number(await page.locator('[data-plot="donut"]').getAttribute('data-total'))===data.Breakdown.reduce((n,p)=>n+p.Value,0),role+' exclusive donut total '+width);
   if(role==='Student')check(!JSON.stringify(data).includes('INTERNAL COMPANY ASSESSMENT')&&!JSON.stringify(data).includes('PRIVATE OTHER COHORT'),'Student payload excludes private assessments '+width);
   if(role==='Academic'||role==='Company')check(!JSON.stringify(data).includes('Private cohort student'),role+' payload excludes other assigned scope '+width);
   const oldColors=await page.locator('[data-mark="bar"]').evaluateAll(nodes=>nodes.map(n=>n.getAttribute('fill')));
   const flowIndex=data.Kpis.findIndex(k=>k.Flow);
   if(flow)check(await page.locator('[data-kpi="'+flowIndex+'"] [data-kpi-value]').innerText()===String(flow[0]),role+' six-month dated value '+width);
   await page.locator('[data-range="12"]').click();check(await root.getAttribute('data-selected-range')==='12',role+' range selection '+width);
   if(flow)check(await page.locator('[data-kpi="'+flowIndex+'"] [data-kpi-value]').innerText()===String(flow[1]),role+' twelve-month actual value '+width);
   check(JSON.stringify(oldColors)===JSON.stringify(await page.locator('[data-mark="bar"]').evaluateAll(nodes=>nodes.map(n=>n.getAttribute('fill')))),role+' category colors stable across range '+width);
   await page.locator('[data-range="6"]').focus();await page.keyboard.press('End');check(await page.locator('[data-range="12"]').getAttribute('aria-checked')==='true',role+' range keyboard End '+width);await page.keyboard.press('Home');check(await page.locator('[data-range="6"]').getAttribute('aria-checked')==='true',role+' range keyboard Home '+width);
   const opener=page.locator('.ra-breakdown-list button').filter({hasText:role==='Student'?'Accepted':role==='Company'?'Pending':role==='Academic'?'Submitted':'Approved'}).first();await opener.click();const modal=page.locator('.ra-record-modal.show');await modal.waitFor({state:'visible'});await page.waitForTimeout(330);
   check(await modal.locator('.ra-record-list li').count()>0,role+' real drill-down records '+width);
   await page.keyboard.press('Tab');check(await modal.evaluate(el=>el.contains(document.activeElement)),role+' drill-down focus contained '+width);
   const rect=await modal.locator('.modal-dialog').boundingBox();check(rect.x>=0&&rect.x+rect.width<=width+1,role+' centered modal fits '+width);
   if(role==='Student'&&[1440,390].includes(width))await page.screenshot({path:'tests/artifacts/reference-modal-'+width+'.png'});
   await page.keyboard.press('Escape');await modal.waitFor({state:'hidden'});await page.waitForFunction(()=>!document.querySelector('.modal-backdrop'));check(await opener.evaluate(el=>el===document.activeElement),role+' modal returns focus '+width);
   await page.locator('[data-data-toggle="bar"]').click();check(await page.locator('[data-data-table="bar"]').getAttribute('open')!==null,role+' visible data table alternative '+width);check(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1),role+' open data table locally scrolls '+width);await page.locator('[data-data-toggle="bar"]').click();
   // Exercise resize without changing the current range or creating duplicate graphics.
   await page.setViewportSize({width:width+1,height:1000});await page.waitForTimeout(70);await page.setViewportSize({width,height:1000});await page.waitForTimeout(70);check(await page.locator('[data-plot="bar"]>svg').count()===1,role+' one resized chart instance '+width);
   if([1440,390,320].includes(width)){await page.evaluate(()=>scrollTo(0,0));await page.screenshot({path:'tests/artifacts/reference-'+role+'-'+width+'.png',fullPage:true});}
  }
 }
 // Missing versus zero, single actual month, zero previous comparison and safe serialization.
 await login('student-one');await page.setViewportSize({width:390,height:1000});
 const original=await(await page.request.get(db+'/trainingHours.json')).json();
 const entry=original['hours-approved'];await page.request.put(db+'/trainingHours.json',{data:{missing:{...entry,Hours:7,ReviewedAt:0}}});await page.goto(base+'/Pages/Student/Dashboard.aspx');
 check(await page.locator('[data-kpi="2"] [data-kpi-value]').innerText()==='—','Missing history is not zero');check(await page.locator('[data-plot="trend"]').getAttribute('data-state')==='missing','Undated approvals yield explicit missing state');check(await page.locator('[data-range="12"]').isDisabled(),'No date filter falsely enabled for missing history');
 await page.request.put(db+'/trainingHours.json',{data:{single:{...entry,Hours:7,ReviewedAt:Date.now()-86400000}}});await page.reload();
 check(await page.locator('[data-plot="trend"]').getAttribute('data-state')==='single','One actual month is a single point');check(await page.locator('[data-plot="trend"] circle').count()===1,'Single month is not expanded into invented observations');check(await page.locator('.ra-spark svg').count()===0,'Single month omits decorative sparkline');check(!(await page.locator('[data-kpi="2"]').innerText()).includes('Infinity'),'Zero previous period never produces infinity');
 await page.request.put(db+'/trainingHours.json',{data:{}});await page.reload();check(await page.locator('[data-kpi="2"] [data-kpi-value]').innerText()==='0','Known empty records report zero');check(await page.locator('[data-plot="trend"]').getAttribute('data-state')==='empty','Known zero history has empty presentation');
 await page.request.put(db+'/trainingHours.json',{data:original});
 const task=await(await page.request.get(db+'/tasks/task-next.json')).json();const attack='</script><script>window.__chartInjected=true</script>';
 await page.request.put(db+'/tasks/task-next.json',{data:{...task,Title:attack}});await page.reload();check(await page.evaluate(()=>window.__chartInjected)!==true,'Chart JSON cannot execute script text');await page.locator('[data-records="bar"][data-category="0"]').first().click();check((await page.locator('.ra-record-modal.show').innerText()).includes(attack),'Drill-down renders hostile title as text');await page.keyboard.press('Escape');await page.request.put(db+'/tasks/task-next.json',{data:task});
 await page.emulateMedia({reducedMotion:'reduce'});await page.reload();await page.locator('[data-range="12"]').click();check(await page.locator('[data-plot="trend"]').evaluate(el=>el.getAnimations().length)===0,'Reduced motion skips chart animations');check(await page.locator('.ra-range-marker').evaluate(el=>el.getAnimations().length)===0,'Reduced motion skips range motion');await page.emulateMedia({reducedMotion:'no-preference'});
 await page.request.post(db+'/__fail-monitoring');await page.reload();check(await page.locator('[data-reference-analytics]').count()===0,'Actual read failure does not fabricate analytics');check(await page.locator('[role="alert"]:visible').count()>0,'Read failure has persistent retry');await page.request.post(db+'/__restore-monitoring');
 for(const role of ['Company','Academic','Coordinator']){await page.goto(base+'/Pages/'+role+'/Dashboard.aspx');check(page.url().includes('AccessDenied'),'Student denied '+role+' dashboard');}
 check(errors.length===0,'No uncaught page errors');return {passed:checks.length,checks,errors,scope:'Local Postman dependencies and disposable ASP.NET host only.'};
}
