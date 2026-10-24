async page => {
 // Short desktop and phone captures of the selector's circular reveal and icon response.
 const base='http://localhost:57992',dir='tests/artifacts/theme/recording/';
 const browser=page.context().browser();
 const pick=async(p,value)=>{if(await p.locator('html').getAttribute('data-theme')!==value)await p.locator('[data-theme-toggle]:visible').click();await p.waitForTimeout(1100);};
 const desktop=await browser.newContext({viewport:{width:1280,height:800},recordVideo:{dir,size:{width:1280,height:800}}});
 const d=await desktop.newPage();await d.goto(base+'/Default.aspx');await d.waitForTimeout(700);await pick(d,'dark');await pick(d,'light');await d.goto(base+'/__fixture.aspx?user=coordinator-one');await d.goto(base+'/Pages/Coordinator/Dashboard.aspx');await d.waitForTimeout(700);await pick(d,'dark');
 const dv=d.video();await desktop.close();
 const mobile=await browser.newContext({viewport:{width:390,height:844},isMobile:true,hasTouch:true,recordVideo:{dir,size:{width:390,height:844}}});
 const m=await mobile.newPage();await m.goto(base+'/Default.aspx');await m.waitForTimeout(700);await m.locator('.public-menu-toggle').tap();await m.locator('.public-theme-mobile [data-theme-value="dark"]').tap();await m.waitForTimeout(1100);await m.locator('.public-theme-mobile [data-theme-value="light"]').tap();await m.waitForTimeout(1100);
 const mv=m.video();await mobile.close();
 return {desktop:await dv.path(),phone:await mv.path()};
}
