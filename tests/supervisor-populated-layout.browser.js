// UI regressions from populated screenshots. Requires prepare-supervisor-visual-host.py.
// Display fixtures exist only in the disposable host. No save, decision or meeting request is sent.
async page => {
 const base=new URL(page.url()).origin,checks=[],errors=[];
 const check=(ok,name)=>{if(!ok)throw Error(name);checks.push(name);};
 const context=await page.context().browser().newContext({viewport:{width:1920,height:1080},reducedMotion:'reduce'}),p=await context.newPage();p.on('pageerror',e=>errors.push(e.message));
 await p.goto(base+'/__fixture.aspx?user=supervisor-one');
 for(const path of ['ManageOpportunities.aspx?ui-visual-fixture=1','ManageOpportunities.aspx?edit=visual-opportunity-one&ui-visual-fixture=1','ViewOpportunity.aspx?id=visual-opportunity-one&ui-visual-fixture=1']){
  const response=await p.goto(base+'/Pages/Company/'+path);
  check(response.status()===200&&!/Server Error in|Parser Error/.test(await p.locator('body').innerText()),'Populated opportunity view renders: '+path);
  check(await p.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),'Opportunity page stays within viewport: '+path);
  if(path.includes('edit=')){
   check(await p.locator('.mo-form-footer button[value=save]').count()===1&&!(await p.locator('.mo-form-footer').innerText()).includes('class='),'Save button contains only its label and retains save value');
   check(await p.locator('textarea').evaluateAll(nodes=>nodes.every(n=>n.getBoundingClientRect().height>=143)),'Descriptions have useful visible editing height');
  }else if(path.startsWith('Manage')){
   check(await p.locator('.mo-actions .su-button').evaluateAll(nodes=>nodes.every(n=>getComputedStyle(n).whiteSpace==='nowrap'&&n.scrollWidth<=n.clientWidth+1)),'Full action labels do not split or clip');
   check(!(await p.locator('.mo-table').innerText()).includes('visual-opportunity-one'),'Technical IDs do not dominate list rows');
  }
  const name=path.includes('edit=')?'edit':path.startsWith('View')?'details':'list';await p.screenshot({path:'tests/artifacts/supervisor-opportunity-'+name+'.png',fullPage:true});
 }
 await p.goto(base+'/Pages/Company/Tasks.aspx');check(await p.locator('.tasks-search').evaluate(e=>parseFloat(getComputedStyle(e).paddingInlineStart)>=42),'Task search text clears its icon');
 check(await p.locator('.tasks-search-wrap').evaluate(e=>getComputedStyle(e,'::before').content==='none'&&e.querySelectorAll('svg').length===1),'Search uses one real SVG instead of overlapping pseudo-elements');
 for(const user of ['supervisor-one','academic-one']){
  await p.goto(base+'/__fixture.aspx?user='+user);
  for(const lang of ['en','ar']){
   await context.addCookies([{name:'uims-lang',value:lang,url:base}]);await p.goto(base+'/Pages/Meetings/MyMeetings.aspx?ui-visual-fixture=1');
   check(await p.locator('.meeting-table tr:has(td)').count()===4,'Populated meetings shown: '+user+'/'+lang);
   check(await p.locator('.meeting-toolbar select').count()===1&&await p.locator('input[id$=RefreshButton]').isVisible()&&!await p.locator('input[id$=ApplyFilter]').isVisible(),'Live selector and Refresh are available without Apply: '+user+'/'+lang);
   check(!await p.locator('.meeting-toolbar button[onclick*=filterDialog]').isVisible(),'Redundant view-popup trigger stays hidden: '+user+'/'+lang);
   for(const theme of ['light','dark']){
    await p.evaluate(t=>window.UimsTheme.set(t),theme);
    for(const width of [1440,390]){
     await p.setViewportSize({width,height:width===390?844:1000});
     check(await p.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1),'Meeting layout contains table: '+user+'/'+lang+'/'+theme+'/'+width);
     check(await p.locator('.meeting-btn:visible').evaluateAll(nodes=>nodes.every(e=>e.getBoundingClientRect().height>=43.5&&getComputedStyle(e).fontSize==='16px')),'Meeting actions match supervisor buttons: '+user+'/'+lang+'/'+theme+'/'+width);
     if((lang==='en'&&theme==='light'&&width===1440)||(lang==='ar'&&theme==='dark'&&width===390))await p.screenshot({path:`tests/artifacts/supervisor-meetings-${user}-${lang}-${theme}-${width}.png`,fullPage:true});
    }
   }
   await p.setViewportSize({width:1440,height:1000});
   const opener=p.locator('.meeting-hero button');await opener.click();await p.locator('#requestDialog[open]').waitFor();
   check(await p.locator('#requestDialog .meeting-close svg').count()===1&&!(await p.locator('#requestDialog .meeting-close').innerText()).trim(),'Close icon is an encoding-safe SVG: '+user+'/'+lang);
   await p.locator('input[id$=MeetingTitle]').fill('Synthetic draft');await p.keyboard.press('Escape');await opener.click();
   check(await p.locator('input[id$=MeetingTitle]').inputValue()==='Synthetic draft','Closing/reopening preserves the request draft: '+user+'/'+lang);
   check(await p.locator('#requestDialog').evaluate(e=>e.contains(document.activeElement)),'Native dialog owns keyboard focus: '+user+'/'+lang);
   await p.screenshot({path:`tests/artifacts/supervisor-meeting-request-${user}-${lang}.png`});await p.keyboard.press('Escape');
   await p.setViewportSize({width:390,height:844});await opener.click();
   check(await p.locator('#requestDialog').evaluate(e=>{const r=e.getBoundingClientRect();return r.left>=0&&r.right<=innerWidth&&r.top>=0&&r.bottom<=innerHeight;}),'Phone request dialog stays in viewport: '+user+'/'+lang);
   check(await p.locator('#requestDialog .meeting-dialog-actions').evaluate(e=>e.getBoundingClientRect().bottom<=innerHeight),'Phone request actions remain reachable: '+user+'/'+lang);
   await p.screenshot({path:`tests/artifacts/supervisor-meeting-request-phone-${user}-${lang}.png`});await p.keyboard.press('Escape');await p.setViewportSize({width:1440,height:1000});
   await p.evaluate(()=>window.showMeetingDialog('detailsDialog'));await p.locator('#detailsDialog[open]').waitFor();
   check(await p.locator('#detailsDialog .meeting-agenda').evaluate(e=>getComputedStyle(e).textAlign==='start'),'Agenda is readable and aligned: '+user+'/'+lang);
   await p.screenshot({path:`tests/artifacts/supervisor-meeting-details-${user}-${lang}.png`});await p.keyboard.press('Escape');
  }
  // Live selection replaces the Apply click without submitting the form.
  const beforeFilter=p.url();let posts=0;const track=request=>{if(request.method()==='POST')posts++;};p.on('request',track);
  await p.locator('.meeting-toolbar select').selectOption('history');
  check(await p.locator('.meeting-toolbar select').inputValue()==='history'&&await p.locator('.meeting-table tr:has(td):visible').count()===1&&p.url()===beforeFilter&&posts===0,'Live view filters in place without postback: '+user);p.off('request',track);
 }
 await context.close();check(errors.length===0,'No uncaught browser errors: '+errors.join(' | '));
 return {passed:checks.length,checks};
}
