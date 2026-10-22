async page => {
 const context=await page.context().browser().newContext({viewport:{width:390,height:844},isMobile:true,hasTouch:true});
 const mobile=await context.newPage();mobile.setDefaultTimeout(6000);
 try {
  await mobile.goto('http://localhost:58001/__fixture.aspx?user=student-one');
  const toggle=mobile.locator('.student-nav-toggle');
  await toggle.tap();
  if(await toggle.getAttribute('aria-expanded')!=='true')throw Error('Touch navigation did not open');
  await mobile.locator('.uims-side-link[href$="/MyTasks.aspx"]').tap();await mobile.waitForURL('**/Student/MyTasks.aspx');
  if(!mobile.url().includes('/Student/MyTasks.aspx'))throw Error('Touch navigation did not reach permitted route');
  await mobile.screenshot({path:'tests/artifacts/ui-touch-mobile.png',fullPage:true});
  return {passed:2,checks:['Touch opens mobile navigation','Touch link reaches permitted student route'],hasTouch:true};
 } finally { await context.close(); }
}
