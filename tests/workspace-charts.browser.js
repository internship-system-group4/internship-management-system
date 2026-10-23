async page => {
 const base='http://localhost:58014',db='http://localhost:4930/firebase',checks=[],errors=[];
 const check=(ok,label)=>{if(!ok)throw Error(label);checks.push(label);};
 page.setDefaultTimeout(8000);page.setDefaultNavigationTimeout(25000);
 page.on('pageerror',e=>errors.push(e.message));
 const login=async id=>{await page.context().clearCookies();await page.goto(base+'/__fixture.aspx?user='+id);};
 for(const [role,id,views] of [['Student','student-one',3],['Company','supervisor-one',2],['Academic','academic-one',2],['Coordinator','coordinator-one',3]]){
  await login(id);
  for(const width of [1440,390]){
   await page.setViewportSize({width,height:1000});await page.goto(base+'/Pages/'+role+'/Dashboard.aspx');await page.evaluate(()=>document.fonts.ready);await page.waitForTimeout(600);
   check(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1),role+' no viewport overflow '+width);
   check(await page.locator('[data-workspace-chart]').count()===1,role+' has one actual chart '+width);
   check(await page.locator('[data-chart-view] option').count()===views,role+' has correct views '+width);
   const style=await page.locator('body').evaluate(el=>({family:getComputedStyle(el).fontFamily,size:getComputedStyle(el).fontSize,canvas:getComputedStyle(el).backgroundColor,loaded:document.fonts.check('18px "Noto Sans"')}));
   check(style.family.includes('Noto Sans')&&parseFloat(style.size)>=18&&style.loaded,role+' new local font loaded at18px '+width);
   check(style.canvas==='rgb(246, 248, 255)',role+' approved blue canvas '+width);
   const sidebar=await page.locator('.uims-sidebar').evaluate(el=>getComputedStyle(el).backgroundColor);check(sidebar==='rgb(245, 245, 245)',role+' original light navigation '+width);
   await page.screenshot({path:'tests/artifacts/charts-'+role+'-'+width+'.png',fullPage:true});
   const picker=page.locator('[data-chart-view]');
   for(let view=0;view<views;view++){
    await picker.selectOption(String(view));const panel=page.locator('[data-chart-panel="'+view+'"]');check(await page.locator('[data-chart-panel]:visible').count()===1,role+' view changes without postback '+view+' '+width);
    const bar=panel.locator('[data-chart-bar]').last();await bar.click();
    check(await panel.locator('[data-chart-detail-value]').innerText()===await bar.getAttribute('data-chart-value'),role+' selection reports true value '+view+' '+width);
    check(await bar.getAttribute('aria-pressed')==='true',role+' selection is semantic '+view+' '+width);
    await page.keyboard.press('Home');check(await panel.locator('[data-chart-bar]').first().evaluate(el=>el===document.activeElement),role+' Home moves keyboard focus '+view+' '+width);
    await page.keyboard.press('ArrowDown');check(await panel.locator('[data-chart-bar]').nth(1).evaluate(el=>el===document.activeElement),role+' arrows move focus '+view+' '+width);
    await panel.locator('[data-chart-sort]').click();const values=await panel.locator('[data-chart-bar]').evaluateAll(nodes=>nodes.map(n=>Number(n.dataset.chartValue)));check(values.every((v,i)=>!i||values[i-1]>=v),role+' sorts actual values '+view+' '+width);
    await panel.locator('[data-chart-sort]').click();check(await panel.locator('[data-chart-bar]').first().getAttribute('data-chart-order')==='0',role+' restores original category order '+view+' '+width);
    check((await panel.locator('[data-chart-detail-link]').getAttribute('href')).includes('/Pages/'+role+'/'),role+' related records stay in role '+view+' '+width);
   }
  }
 }
 await login('student-one');await page.goto(base+'/Pages/Student/Dashboard.aspx');
 const values=await page.locator('[data-chart-panel="0"] [data-chart-bar]').evaluateAll(nodes=>nodes.map(n=>Number(n.dataset.chartValue)));
 check(JSON.stringify(values)==='[72,16,160]','Student chart separates72approved16pending160target');
 check(!(await page.locator('body').innerText()).includes('INTERNAL COMPANY ASSESSMENT'),'Student charts disclose no confidential assessments');
 await page.request.post(db+'/__fail-monitoring');await page.reload();check(await page.locator('[data-workspace-chart]').count()===0,'Real read failure does not display fabricated chart');check(await page.locator('[role="alert"]:visible').count()>0,'Read error remains actionable');await page.request.post(db+'/__restore-monitoring');
 for(const key of ['trainingHours','applications','tasks'])await page.request.put(db+'/'+key+'.json',{data:{}});
 await page.reload();await page.locator('[data-chart-view]').selectOption('2');check(await page.locator('[data-chart-panel="2"] .ws-chart-empty').isVisible(),'Empty chart explicitly reports zero records');
 check(await page.locator('[data-chart-panel="2"] [data-chart-bar]').evaluateAll(nodes=>nodes.every(n=>n.dataset.chartValue==='0')),'Empty chart preserves zero values');
 await page.emulateMedia({reducedMotion:'reduce'});check(await page.locator('.ws-chart-fill').first().evaluate(el=>getComputedStyle(el).transitionDuration)==='0s','Reduced motion removes chart transitions');await page.emulateMedia({reducedMotion:'no-preference'});
 check(errors.length===0,'No uncaught JavaScript errors');
 return {passed:checks.length,checks,errors,scope:'Disposable Web Forms and local Postman dependencies; no live Firebase verification.'};
}
