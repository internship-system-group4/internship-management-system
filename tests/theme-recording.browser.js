async page => {
 // Records theme switching to tests/artifacts/theme/recording/ (needs Playwright's ffmpeg). Read-only.
 const base='http://localhost:57992',DIR='tests/artifacts/theme/recording/';
 const ctx=await page.context().browser().newContext({viewport:{width:1280,height:800},recordVideo:{dir:DIR,size:{width:1280,height:800}}});
 const p=await ctx.newPage();
 const pick=async value=>{await p.locator('[data-theme-control="menu"]:visible [data-theme-toggle]').first().click();await p.waitForTimeout(500);await p.locator('[data-theme-control="menu"]:visible [data-theme-value="'+value+'"]').first().click();await p.waitForTimeout(1300);};
 await p.goto(base+'/Pages/Public/About.aspx');await p.waitForTimeout(2500);
 await pick('dark');await p.mouse.wheel(0,700);await p.waitForTimeout(1500);await p.mouse.wheel(0,900);await p.waitForTimeout(1200);
 await pick('light');await pick('dark');
 await p.goto(base+'/Pages/Public/Contact.aspx');await p.waitForTimeout(1800);
 await p.locator('#MainContent_txtName').fill('Lina Haddad');await p.locator('#MainContent_txtEmail').fill('lina@');await p.locator('#MainContent_txtSubject').focus();await p.waitForTimeout(1200);
 await pick('light');await pick('dark');
 await p.goto(base+'/__fixture.aspx?user=coordinator-one');await p.goto(base+'/Pages/Coordinator/Dashboard.aspx');await p.waitForTimeout(2000);
 await pick('light');await p.mouse.wheel(0,600);await p.waitForTimeout(1200);await pick('dark');await p.waitForTimeout(800);
 await p.keyboard.press('Home');await pick('system');await p.waitForTimeout(800);
 const video=p.video();await ctx.close();
 // Phone: the radio row in the mobile menu.
 const mob=await page.context().browser().newContext({viewport:{width:390,height:844},isMobile:true,hasTouch:true,recordVideo:{dir:DIR,size:{width:390,height:844}}});
 const m=await mob.newPage();await m.goto(base+'/Default.aspx');await m.waitForTimeout(2000);
 await m.locator('.public-menu-toggle').tap();await m.waitForTimeout(900);
 await m.locator('.public-theme-mobile [data-theme-value="dark"]').tap();await m.waitForTimeout(1500);
 await m.locator('.public-theme-mobile [data-theme-value="light"]').tap();await m.waitForTimeout(1200);
 await m.locator('.public-theme-mobile [data-theme-value="dark"]').tap();await m.waitForTimeout(1000);
 await m.locator('.public-menu-toggle').tap();await m.waitForTimeout(800);await m.mouse.wheel(0,900);await m.waitForTimeout(1500);
 const phone=m.video();await mob.close();
 return {desktop:await video.path(),phone:await phone.path()};
}
