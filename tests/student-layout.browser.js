async page => {
 const base='http://localhost:57982';
 await page.goto(base+'/__fixture.aspx');
 const routes=[['Dashboard','Dashboard'],['Profile','My Profile'],['Opportunities','Explore Opportunities'],['MyApplications','My Applications'],['MyTasks','My Tasks'],['Progress','My Progress & Evaluation']];
 let checked=0;
 for(const [route,label] of routes) {
   await page.goto(base+'/Pages/Student/'+route+'.aspx');
   if(await page.locator('.uims-sidebar-brand img').getAttribute('alt')!=='German Jordanian University') throw Error('Missing logo on '+route);
   if(await page.locator('.uims-side-link[aria-current="page"]').innerText()!==label) throw Error('Wrong active navigation on '+route);
   if(await page.locator('.uims-side-link svg').count()!==7) throw Error('Missing shared icons on '+route);
   if(await page.locator('.student-logout').count()!==1) throw Error('Duplicate logout on '+route);
   checked++;
 }
 await page.goto(base+'/Pages/Student/Apply.aspx?id=internship-one');
 await page.setViewportSize({width:1440,height:1000});
 await page.screenshot({path:'tests/artifacts/shared-layout-desktop.png',fullPage:true});
 await page.setViewportSize({width:390,height:1000});
 if(!await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth)) throw Error('Mobile overflow');
 await page.screenshot({path:'tests/artifacts/shared-layout-mobile.png',fullPage:true});
 const browser=page.context().browser();
 const context=await browser.newContext({javaScriptEnabled:false});
 const staticPage=await context.newPage();
 await staticPage.goto(base+'/__fixture.aspx');
 if(await staticPage.locator('.uims-side-link svg').count()!==7) throw Error('Sidebar depends on JavaScript');
 if(await staticPage.locator('.student-avatar').innerText()!=='OB') throw Error('Initials depend on JavaScript');
 await context.close();
 await page.getByRole('button',{name:'Open navigation',exact:true}).click();
 await page.getByRole('link',{name:'Log out',exact:true}).click();
 await page.waitForURL('**/Account/Login.aspx');
 await page.goto(base+'/Pages/Student/Dashboard.aspx');
 if(!page.url().includes('/Account/Login.aspx')) throw Error('Sign out did not clear session');
 await page.goto(base+'/__fixture.aspx');
 await page.setViewportSize({width:1440,height:1000});
 return {studentPagesChecked:checked, mobile:'passed',withoutJavaScript:'passed',logout:'passed'};
}
