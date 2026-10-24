async page => {
 // Run only in the disposable fixture host. Filter probes modify the local DOM, never database records.
 const base=new URL(page.url()).origin, results=[];
 const check=(ok,name)=>{if(!ok)throw Error(name);results.push(name);};
 for(const theme of ['light','dark'])for(const width of [1440,390]){
  const ctx=await page.context().browser().newContext({viewport:{width,height:1000},reducedMotion:'reduce'});
  await ctx.addCookies([{name:'uims-lang',value:'ar',url:base}]);
  await ctx.addInitScript(t=>localStorage.setItem('uims-theme',t),theme);
  const p=await ctx.newPage(),errors=[];p.on('pageerror',e=>errors.push(e.message));
  const label=theme+'/'+width;
  await p.goto(base+'/__fixture.aspx?user=supervisor-one');
  await p.goto(base+'/Pages/Company/Tasks.aspx');
  check(await p.locator('#tasksStatusFilter option[value="Pending review"]').innerText()==='بانتظار المراجعة',label+' Arabic label keeps English filter value');
  await p.evaluate(()=>{
   const tr=document.createElement('tr');tr.dataset.taskStatus='Pending review';tr.dataset.department='test';tr.innerHTML='<td>مهمة تجريبية للفحص</td>';tr.id='local-i18n-filter-probe';document.getElementById('companyTasksBody').appendChild(tr);
  });
  await p.locator('#tasksStatusFilter').selectOption('Pending review');
  check(await p.locator('#local-i18n-filter-probe').isVisible(),label+' task filter matches stable key');
  await p.locator('#tasksStatusFilter').selectOption('Reviewed');
  check(!await p.locator('#local-i18n-filter-probe').isVisible(),label+' task filter excludes another status');
  await p.evaluate(()=>document.getElementById('local-i18n-filter-probe').remove());
  await p.locator('#btnOpenCreateTask').click();
  check(/إنشاء مهمة/.test(await p.locator('#taskCreateView').innerText()),label+' task create view is Arabic');
  check(!/Task title|Task information|Required fields/.test(await p.locator('#taskCreateView').innerText()),label+' task form has no English UI headings');
  await p.screenshot({path:`tests/artifacts/arabic-tasks-${theme}-${width}.png`,fullPage:false});
  await p.goto(base+'/Pages/Company/TaskReview.aspx');
  await p.evaluate(()=>{
   const tr=document.createElement('tr');tr.dataset.reviewStatus='Awaiting review';tr.dataset.reviewTask='مهمة تجريبية';tr.dataset.reviewTrainee='طالب تجريبي';tr.id='local-review-filter-probe';tr.innerHTML='<td>تسليم تجريبي للفحص</td>';document.querySelector('.submission-table tbody').appendChild(tr);
  });
  await p.locator('#submissionStatusFilter').selectOption('Awaiting review');
  check(await p.locator('#local-review-filter-probe').isVisible(),label+' submission filter matches original key');
  check(/عرض/.test(await p.locator('#submissionFilterSummary').innerText()),label+' live submission count is Arabic');
  await p.goto(base+'/Pages/Meetings/MyMeetings.aspx');
  await p.evaluate(()=>{document.getElementById('noticeDialog')?.close();showMeetingDialog('requestDialog');});
  check(/طلب اجتماع/.test(await p.locator('#requestDialog').innerText()),label+' meeting request dialog is Arabic');
  await p.evaluate(()=>{closeMeetingDialog('requestDialog');confirmMeetingAction(document.createElement('button'),'send');});
  check(/هل تريد إرسال/.test(await p.locator('#confirmTitle').innerText()),label+' meeting confirmation is Arabic');
  await p.evaluate(()=>document.querySelectorAll('dialog[open]').forEach(d=>d.close()));
  await p.goto(base+'/__fixture.aspx?user=coordinator-one');
  await p.goto(base+'/Pages/Coordinator/Account.aspx');
  check(!/ACCOUNT SECURITY|PHONE NUMBER|Edit Profile/.test(await p.locator('main').innerText()),label+' coordinator account labels are Arabic');
  await p.screenshot({path:`tests/artifacts/arabic-coordinator-account-${theme}-${width}.png`,fullPage:true});
  await p.goto(base+'/__fixture.aspx?user=academic-one');
  await p.goto(base+'/Pages/Academic/Dashboard.aspx');
  check(await p.locator('[data-simple-workspace]').count()===1,label+' simple Academic dashboard preserved');
  check(/الطلاب/.test(await p.locator('[data-simple-workspace]').innerText()),label+' Academic workspace is Arabic');
  await p.screenshot({path:`tests/artifacts/arabic-academic-${theme}-${width}.png`,fullPage:true});
  check(!errors.length,label+' no page JavaScript errors: '+errors.join(';'));
  await ctx.close();
 }
 // Route and query preservation, dirty form protection, and language preference persistence.
 const ctx=await page.context().browser().newContext({viewport:{width:1440,height:1000}}),p=await ctx.newPage();
 await ctx.addCookies([{name:'uims-lang',value:'ar',url:base}]);
 await p.goto(base+'/Pages/Public/Contact.aspx?topic=general');
 const field=p.locator('[data-public-form] input[type=text]').first();await field.fill('نص غير محفوظ للفحص');
 await p.evaluate(()=>{window.__confirmText='';window.confirm=s=>{window.__confirmText=s;return false;};});
 await p.locator('[data-lang-switch]:visible').first().click();
 check(await p.evaluate(()=>document.documentElement.lang)==='ar'&&await field.inputValue()==='نص غير محفوظ للفحص','Cancel language switch keeps Arabic and unsaved input');
 check(/[\u0600-\u06ff]/.test(await p.evaluate(()=>window.__confirmText)),'Unsaved confirmation is Arabic');
 await p.evaluate(()=>window.confirm=()=>true);
 await Promise.all([p.waitForNavigation(),p.locator('[data-lang-switch]:visible').first().click()]);
 check(new URL(p.url()).pathname==='/Pages/Public/Contact.aspx'&&new URL(p.url()).searchParams.get('topic')==='general','Language switch keeps route and safe query');
 check(await p.evaluate(()=>document.documentElement.lang)==='en'&&await p.evaluate(()=>document.documentElement.dir)==='ltr','English destination uses English and LTR');
 await p.reload();check(await p.evaluate(()=>document.documentElement.lang)==='en','Saved preference persists after reload');
 await ctx.close();return {passed:results.length,results};
}
