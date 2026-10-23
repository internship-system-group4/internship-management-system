async page => {
 // Short desktop and phone captures of the selector's circular reveal and icon response.
 const base='http://localhost:57992',dir='tests/artifacts/theme/recording/';
 const browser=page.context().browser();
 const pick=async(p,value)=>{const control=p.locator('[data-theme-control="menu"]:visible');await control.locator('[data-theme-toggle]').click();await control.locator('[data-theme-value="'+value+'"]').click();await p.waitForTimeout(900);};
 const desktop=await browser.newContext({viewport:{width:1280,height:800},recordVideo:{dir,size:{width:1280,height:800}}});
 const d=await desktop.newPage();await d.goto(base+'/Default.aspx');await d.waitForTimeout(700);await pick(d,'dark');await pick(d,'light');await d.goto(base+'/__fixture.aspx?user=coordinator-one');await d.goto(base+'/Pages/Coordinator/Dashboard.aspx');await d.waitForTimeout(700);await pick(d,'dark');
 const dv=d.video();await desktop.close();
 const mobile=await browser.newContext({viewport:{width:390,height:844},isMobile:true,hasTouch:true,recordVideo:{dir,size:{width:390,height:844}}});
 const m=await mobile.newPage();await m.goto(base+'/Default.aspx');await m.waitForTimeout(700);await m.locator('.public-menu-toggle').tap();await m.locator('.public-theme-mobile [data-theme-value="dark"]').tap();await m.waitForTimeout(900);await m.locator('.public-theme-mobile [data-theme-value="light"]').tap();await m.waitForTimeout(900);
 const mv=m.video();await mobile.close();
 return {desktop:await dv.path(),phone:await mv.path()};
}
