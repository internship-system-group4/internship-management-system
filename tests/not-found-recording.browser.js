async page => {
 const base=new URL(page.url()).origin,browser=page.context().browser();
 const desktop=await browser.newContext({viewport:{width:1280,height:900},recordVideo:{dir:'tests/artifacts/not-found/recording',size:{width:1280,height:900}}});
 const d=await desktop.newPage();await d.goto(base+'/recording-missing.aspx');await d.waitForTimeout(2700);
 await d.locator('[data-theme-toggle]').click();await d.waitForTimeout(1100);
 await Promise.all([d.waitForNavigation(),d.locator('[data-lang-switch]').click()]);await d.waitForTimeout(2700);
 const dv=d.video();await desktop.close();await dv.saveAs('tests/artifacts/not-found-desktop.webm');
 const mobile=await browser.newContext({viewport:{width:390,height:844},isMobile:true,hasTouch:true,recordVideo:{dir:'tests/artifacts/not-found/recording',size:{width:390,height:844}}});
 const m=await mobile.newPage();await m.goto(base+'/recording-missing-route?ui-lang=ar');await m.waitForTimeout(2700);
 await m.locator('[data-theme-toggle]').tap();await m.waitForTimeout(1100);
 const mv=m.video();await mobile.close();await mv.saveAs('tests/artifacts/not-found-mobile.webm');
 return {desktop:'tests/artifacts/not-found-desktop.webm',mobile:'tests/artifacts/not-found-mobile.webm'};
}
