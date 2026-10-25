// Uses synthetic display records in the disposable supervisor visual host only.
async page => {
 const base=new URL(page.url()).origin,checks=[],errors=[];
 const check=(ok,name)=>{if(!ok)throw Error(name);checks.push(name);};
 const context=await page.context().browser().newContext({viewport:{width:1440,height:1000},reducedMotion:'reduce'}),p=await context.newPage();p.on('pageerror',e=>errors.push(e.message));
 for(const user of ['supervisor-one','academic-one'])for(const lang of ['en','ar']){
  await context.addCookies([{name:'uims-lang',value:lang,url:base}]);await p.goto(base+'/__fixture.aspx?user='+user);
  await p.goto(base+'/Pages/Meetings/MyMeetings.aspx?ui-visual-fixture=1');
  const search=p.locator('#meetingLiveSearch'),view=p.locator('.meeting-toolbar select'),rows=p.locator('.meeting-table tr:has(td):visible'),clear=p.locator('.su-meeting-search-clear');
  let posts=0;const track=request=>{if(request.method()==='POST')posts++;};p.on('request',track);const url=p.url();
  check(await rows.count()===4&&await search.isVisible(),'Search available with all rows: '+user+'/'+lang);
  check(!await p.locator('input[id$=ApplyFilter]').isVisible(),'Apply is unnecessary under live enhancement: '+user+'/'+lang);
  await search.fill('PROGRESS');check(await rows.count()===1&&(await rows.innerText()).includes('progress'),'Case-insensitive title search: '+user+'/'+lang);
  await search.fill('احمد');check(await rows.count()===1&&(await rows.innerText()).includes('أحمد'),'Arabic name normalization: '+user+'/'+lang);
  await search.fill('weekly student');check(await rows.count()===1,'Title and person terms combine: '+user+'/'+lang);
  await view.selectOption('upcoming');check(await rows.count()===0&&await p.locator('.su-meeting-search-empty').isVisible(),'Text and selected view intersect: '+user+'/'+lang);
  await clear.click();check(await rows.count()===1&&!await clear.isVisible()&&await search.evaluate(e=>e===document.activeElement),'Clear keeps selected view and restores focus: '+user+'/'+lang);
  for(const category of ['incoming','sent','upcoming','history']){
   await view.selectOption(category);check(await rows.count()===1,'Server-authored view membership: '+user+'/'+lang+'/'+category);
  }
  await view.selectOption('all');check(await rows.count()===4,'All restores rows hidden by previous selections: '+user+'/'+lang);
  await search.fill('not-a-meeting');check(await rows.count()===0&&await p.locator('.su-meeting-search-summary').innerText().then(t=>t.includes('0')),'Visible no-results feedback and count: '+user+'/'+lang);
  await search.press('Enter');await p.waitForTimeout(80);check(posts===0&&p.url()===url,'Typing, selection and Enter never post or navigate: '+user+'/'+lang);
  await clear.click();check(await rows.count()===4,'Clearing restores complete list: '+user+'/'+lang);
  for(const theme of ['light','dark']){
   await p.evaluate(t=>window.UimsTheme.set(t),theme);await p.setViewportSize({width:390,height:844});
   check(await p.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),'Search stays within phone viewport: '+user+'/'+lang+'/'+theme);
  }
  await p.setViewportSize({width:1440,height:1000});await search.fill('progress');
  await p.screenshot({path:`tests/artifacts/meetings-live-${user}-${lang}.png`,fullPage:true});p.off('request',track);
  await p.goto(base+'/Pages/Meetings/MyMeetings.aspx?view=history&ui-visual-fixture=1');
  check(await p.locator('.meeting-table tr:has(td):visible').count()===1,'Initial server-selected view respected: '+user+'/'+lang);
  await p.locator('.meeting-toolbar select').selectOption('all');check(await p.locator('.meeting-table tr:has(td):visible').count()===4,'Switching from initial history restores all authorized rows: '+user+'/'+lang);
 }
 await context.close();
 const nojs=await page.context().browser().newContext({javaScriptEnabled:false}),n=await nojs.newPage();
 for(const user of ['supervisor-one','academic-one']){
  await n.goto(base+'/__fixture.aspx?user='+user);await n.goto(base+'/Pages/Meetings/MyMeetings.aspx?view=history&ui-visual-fixture=1');
  check(await n.locator('.meeting-table tr:has(td):visible').count()===1,'No-JavaScript initial view remains filtered: '+user);
 }
 await nojs.close();check(!errors.length,'No uncaught browser errors: '+errors.join(' | '));return {passed:checks.length,checks};
}
