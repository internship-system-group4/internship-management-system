// Run against the disposable four-role fixture host after redesign-fixture.browser.js.
// Only navigation, selection postbacks and local dialogs; no production records or saves.
async page => {
 const base=new URL(page.url()).origin, checks=[];
 const check=(ok,label)=>{if(!ok)throw Error(label);checks.push(label);};
 for(const lang of ['ar','en'])for(const width of [1440,390]) {
  const ctx=await page.context().browser().newContext({viewport:{width,height:1000},reducedMotion:'reduce'});
  await ctx.addCookies([{name:'uims-lang',value:lang,url:base}]);
  const p=await ctx.newPage(), errors=[]; p.on('pageerror',e=>errors.push(e.message));
  const label=lang+'/'+width;
  await p.goto(base+'/__fixture.aspx?user=supervisor-one');
  await p.goto(base+'/Pages/Company/FinalEvaluation.aspx');
  await p.evaluate(()=>generateCertificate());
  check(await p.locator('#clientAlertModal').isVisible(),label+' certificate requires a selected trainee');
  check((await p.locator('#clientAlertMessage').innerText()).includes(lang==='ar'?'اختيار متدرب':'select a trainee'),label+' validation uses the current language');
  await p.evaluate(()=>bootstrap.Modal.getInstance(document.getElementById('clientAlertModal')).hide());
  await Promise.all([p.waitForNavigation(),p.locator('[id$=ddlTrainees]').selectOption('student-one')]);
  check((await p.locator('#jsStudentMajor').innerText()).includes(lang==='ar'?'الحاسوب':'Computer Science'),label+' selected major is localized');
  await p.evaluate(()=>showOfficialReportModal());
  await p.locator('#officialReportModal').waitFor({state:'visible'});
  check(await p.locator('#officialReportModal').isVisible(),label+' report opens after selection in either language');
  check(await p.locator('#repMajor').innerText()===await p.locator('#jsStudentMajor').innerText(),label+' report uses the actual student major');
  const report=await p.locator('#officialReportModal').innerText();
  check(!/(Company|Shared)\.[A-Za-z]/.test(report),label+' no missing resource keys in report');
  if(lang==='ar')check(!/Academic Major|Trainee Student|Max Score|Awarded|Report Generated|No strengths noted|No improvements noted|Print Report|Send to Academic/.test(report),label+' report headings and empty feedback are Arabic');
  check(await p.locator('[id$=ddlPerformance] option[value="Excellent"]').count()===1,label+' translated options retain stored values');
  const metric=await p.locator('#officialReportModal').evaluate(el=>({overflow:el.scrollWidth-el.clientWidth,dir:getComputedStyle(el).direction}));
  check(metric.overflow<=1&&metric.dir===(lang==='ar'?'rtl':'ltr'),label+' report direction and viewport fit');
  await p.screenshot({path:`tests/artifacts/arabic-review-20261026/report-${lang}-${width}.png`});
  await p.evaluate(()=>bootstrap.Modal.getInstance(document.getElementById('officialReportModal')).hide());
  await p.evaluate(()=>generateCertificate());
  await p.locator('#certificateModal').waitFor({state:'visible'});
  check((await p.locator('#certStudentName').innerText())==='Osama Banihani',label+' certificate accepts the selected trainee');
  const certificateOverflow=await p.locator('#certificateModal .modal-body').evaluate(el=>el.scrollWidth-el.clientWidth);
  check(certificateOverflow<=1,label+' certificate fits the viewport');
  await p.screenshot({path:`tests/artifacts/arabic-review-20261026/certificate-${lang}-${width}.png`});
  await p.evaluate(()=>bootstrap.Modal.getInstance(document.getElementById('certificateModal')).hide());
  await p.goto(base+'/Pages/Company/ManageOpportunities.aspx?edit=internship-one');
  if(lang==='ar') {
  check((await p.locator('main').textContent()).includes('الحاسوب'),label+' configured majors display in Arabic');
   check(await p.locator('input[name="moMajors"][value="Computer Science"]').count()===1,label+' translated majors keep original submit values');
  }
  await p.goto(base+'/Pages/Reports/Grades.aspx');
  check((await p.locator('.grades-scope').innerText())===(lang==='ar'?'التدريبات المسندة إليك':'Your assigned internships'),label+' report scope is localized');
  const applicant=await p.goto(base+'/Pages/Company/ApplicantDocument.aspx?id=missing-record');
  check(applicant.status()===404,label+' unavailable applicant document remains protected');
  const applicantMessage=await p.locator('[role=alert]').innerText();
  check(lang==='ar'?/[\u0600-\u06ff]/.test(applicantMessage):/application/i.test(applicantMessage),label+' applicant-document refusal is localized');
  await p.goto(base+'/__fixture.aspx?user=student-one');
  await p.goto(base+'/Pages/Student/SubmissionDetails.aspx?id=submission-one');
  check(await p.locator('nav[aria-label="'+(lang==='ar'?'مسار التنقل':'Breadcrumb')+'"]').count()===1,label+' submission breadcrumb is localized');
  await p.goto(base+'/__fixture.aspx?user=coordinator-one');
  await p.goto(base+'/Pages/Coordinator/DemoStudent.aspx');
  check(await p.locator('html').getAttribute('lang')===lang,label+' development page follows language preference');
  check(await p.locator('#uims-i18n-gaps').textContent()==='""',label+' development page has no missing resources');
  const denied=await p.request.get(base+'/Pages/Account/CompletionReport.aspx?id=missing-record');
  check(denied.status()===404,label+' unavailable completion report remains protected');
  check((await denied.text()).includes(lang==='ar'?'التقرير':'report'),label+' completion refusal is localized');
  check(errors.length===0,label+' no browser script errors: '+errors.join('; '));
  await ctx.close();
 }
 return {passed:checks.length,checks};
}
