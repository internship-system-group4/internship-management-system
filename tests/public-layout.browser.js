async page => {
 const base='http://localhost:57982';let checks=0;
 const check=(ok,message)=>{if(!ok)throw Error(message);checks++;};
 await page.context().clearCookies();
 for(const route of ['/Default.aspx','/Pages/Public/About.aspx','/Pages/Public/Contact.aspx','/Pages/Public/AccessDenied.aspx','/Pages/Account/Login.aspx','/Pages/Account/ForgotPassword.aspx']){
  await page.setViewportSize({width:1440,height:1000});await page.goto(base+route);
  check(await page.locator('.public-header').count()===1,'Shared Navbar '+route);
  check(await page.locator('.public-footer').count()===1,'Shared Footer '+route);
  check(await page.locator('.public-header img').evaluate(el=>el.complete&&el.naturalWidth>0),'Logo loads '+route);
  check(await page.locator('.public-header').getByRole('link',{name:'Log in',exact:true}).count()===1,'Anonymous login action '+route);
 }
 await page.goto(base+'/Default.aspx');
 for(const width of [1440,768,390]){
  await page.setViewportSize({width,height:1000});
  check(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),'No overflow '+width);
  await page.screenshot({path:'tests/artifacts/public-shell-'+width+'.png',fullPage:true});
 }
 const toggle=page.getByRole('button',{name:'Open main menu',exact:true});
 check(await toggle.isVisible(),'Public hamburger visible');
 await toggle.click();check(await page.locator('#publicNav').isVisible(),'Menu opens');
 await page.keyboard.press('Escape');check(await toggle.getAttribute('aria-expanded')==='false','Escape closes menu');
 await toggle.click();await page.getByRole('navigation',{name:'Main navigation'}).getByRole('link',{name:'About us',exact:true}).click();
 await page.waitForURL('**/About.aspx');check(await page.locator('.public-links a[aria-current="page"]').innerText()==='About us','Current page highlighted');
 await page.setViewportSize({width:1440,height:1000});
 await page.getByRole('navigation',{name:'Main navigation'}).getByRole('link',{name:'Opportunities',exact:true}).click();
 check(page.url().includes('/Account/Login.aspx')&&page.url().includes('returnUrl='),'Opportunity link respects login');
 const context=await page.context().browser().newContext({javaScriptEnabled:false,viewport:{width:390,height:900}});
 const noJs=await context.newPage();await noJs.goto(base+'/Default.aspx');
 check(await noJs.getByRole('navigation',{name:'Main navigation'}).getByRole('link',{name:'About us',exact:true}).isVisible(),'No-JS mobile navigation works');
 check(await noJs.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),'No-JS mobile no overflow');await context.close();
 await page.goto(base+'/__fixture.aspx');await page.goto(base+'/Default.aspx');
 check((await page.getByRole('link',{name:'My dashboard',exact:true}).getAttribute('href')).endsWith('/Student/Dashboard.aspx'),'Authenticated dashboard action');
 await page.goto(base+'/Pages/Account/ChangePassword.aspx');
 check(await page.locator('.public-header').count()===1,'Change Password uses shared Navbar');
 check(await page.locator('.public-footer').count()===1,'Change Password uses shared Footer');
 return {passed:checks,publicPages:6,protectedAccountPages:1};
}
