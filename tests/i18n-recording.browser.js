async page => {
 // Short recording of language switching: public home -> Arabic -> Contact (Arabic validation) -> sign in as the
 // fixture student (Arabic persists) -> dashboard -> back to English. Disposable host + simulation only.
 const base='http://localhost:57992';
 const ctx=await page.context().browser().newContext({viewport:{width:1280,height:800},recordVideo:{dir:'tests/artifacts/i18n/recording/',size:{width:1280,height:800}}});
 const p=await ctx.newPage();const pause=ms=>p.waitForTimeout(ms);
 const link=()=>p.locator('[data-lang-switch]:visible').first();
 await p.goto(base+'/Default.aspx');await pause(1800);
 await link().click();await p.waitForLoadState('load');await pause(2200);
 await p.mouse.wheel(0,700);await pause(1400);await p.mouse.wheel(0,-700);await pause(600);
 await p.goto(base+'/Pages/Public/Contact.aspx');await pause(1500);
 await p.locator('[data-public-form] input[type=submit],[data-public-form] button[type=submit]').first().click();await pause(1800);
 await p.goto(base+'/Pages/Account/Login.aspx');await pause(1200);
 await p.locator('input[type=email]').first().fill('student@campus.test');await p.locator('input[type=password]').first().fill('Fixture-pass-2026');await pause(500);
 await p.locator('[data-public-form] input[type=submit]').click();await p.waitForURL('**/Pages/Student/Dashboard.aspx');await pause(2600);
 await p.mouse.wheel(0,600);await pause(1500);await p.mouse.wheel(0,-600);await pause(600);
 await link().click();await p.waitForLoadState('load');await pause(2400);
 const video=p.video();await ctx.close();return await video.path();
}
