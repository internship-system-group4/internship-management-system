// Local synthetic accounts only; never run this seed/reset against a live database.
async page => {
 const base=new URL(page.url()).origin,db='http://localhost:4940/firebase',checks=[];
 const check=(ok,name)=>{if(!ok)throw Error(name);checks.push(name);};
 await page.request.post(db+'/__reset');
 const protectedRoutes=['Student/Profile','Company/Account','Academic/Account','Coordinator/Account'];
 const users=['student-one','supervisor-one','academic-one','coordinator-one'];
 const browser=page.context().browser();
 const anon=await browser.newContext(),a=await anon.newPage();
 for(const route of protectedRoutes){await a.goto(base+'/Pages/'+route+'.aspx');check(a.url().includes('/Account/Login.aspx'),'Anonymous access blocked: '+route);}
 check((await a.request.get(base+'/Pages/Notifications/Feed.ashx')).status()===401,'Anonymous notification API denied');
 await anon.close();
 for(let i=0;i<users.length;i++){
  const ctx=await browser.newContext(),p=await ctx.newPage();
  await p.goto(base+'/__fixture.aspx?user='+users[i]);
  for(let j=0;j<protectedRoutes.length;j++)if(j!==i){await p.goto(base+'/Pages/'+protectedRoutes[j]+'.aspx');check(p.url().includes('AccessDenied'),'Wrong role blocked: '+users[i]+'/'+protectedRoutes[j]);}
  check((await p.request.post(base+'/Pages/Notifications/Feed.ashx',{form:{id:'all'}})).status()===403,'Notification mutation requires CSRF token: '+users[i]);
  check((await p.request.delete(base+'/Pages/Notifications/Feed.ashx')).status()===405,'Unsupported notification method denied: '+users[i]);
  const pdf=await p.request.get(base+'/Pages/Account/CompletionReport.aspx?id=missing');
  check(!pdf.headers()['content-type']?.includes('application/pdf'),'Missing confidential report is never served: '+users[i]);
  await ctx.close();
 }
 // Actual password sign-in through the real AuthService HTTP client, pointed at Postman.
 for(const [email,route] of [['student@campus.test','Student'],['company@campus.test','Company'],['academic@campus.test','Academic'],['coordinator@campus.test','Coordinator']]){
  const ctx=await browser.newContext({reducedMotion:'reduce'}),p=await ctx.newPage();
  await p.goto(base+'/Pages/Account/Login.aspx?returnUrl=https://example.test/forged');
  await p.locator('input[id$=txtEmail]').fill(email);await p.locator('input[id$=txtPassword]').fill('Fixture-pass-2026');
  await p.locator('input[id$=btnLogin]').click();await p.waitForURL('**/Pages/'+route+'/Dashboard.aspx');
  check(new URL(p.url()).origin===base,'Safe sign-in destination and role routing: '+route);
  await ctx.close();
 }
 // Postbacks must recheck account activation rather than trusting a previously cached session.
 const ctx=await browser.newContext(),p=await ctx.newPage();await p.goto(base+'/__fixture.aspx?user=student-one');
 const user=await (await p.request.get(db+'/users/student-one.json')).json();
 await p.request.put(db+'/users/student-one.json',{data:{...user,IsActive:false}});
 const denied=await p.request.post(base+'/Pages/Student/Profile.aspx',{form:{spAction:'save',spFullName:'Must not be saved'},maxRedirects:0});
 check(denied.status()===302&&denied.headers().location.includes('Login.aspx'),'Deactivation blocks postback before its handler');
 check((await (await p.request.get(db+'/users/student-one.json')).json()).FullName===user.FullName,'Blocked postback did not change profile');
 await ctx.close();await page.request.post(db+'/__reset');return {passed:checks.length,checks};
}
