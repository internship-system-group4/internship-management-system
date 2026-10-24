async page => {
 // Login gate scene captures for visual review: desktop/phone, English/Arabic, Light/Dark, character close-ups, and a short
 // recording of a verified entry with the disposable fixture student. Writes under tests/artifacts/login-scene/<OUT>/.
 // Run against tests/Start-LoginTestHost.ps1 with the campus-login simulation (4910). Set OUT to 'before' or 'after'.
 const base='http://localhost:57994', OUT='after', dir='tests/artifacts/login-scene/'+OUT+'/', done=[];
 const views=[['desktop-en-light','en','light',1440,900],['desktop-en-dark','en','dark',1440,900],['desktop-ar-light','ar','light',1440,900],['phone-en-light','en','light',390,844],['phone-ar-dark','ar','dark',390,844]];
 for(const [name,lang,theme,w,h] of views){
  const ctx=await page.context().browser().newContext({viewport:{width:w,height:h},deviceScaleFactor:w<500?2:(name==='desktop-en-light'?3:1.5),isMobile:w<500,hasTouch:w<500});
  await ctx.addCookies([{name:'uims-lang',value:lang,url:base}]);await ctx.addInitScript(t=>localStorage.setItem('uims-theme',t),theme);
  const p=await ctx.newPage();const errors=[];p.on('pageerror',e=>errors.push(e.message));
  await p.goto(base+'/Pages/Account/Login.aspx');await p.locator('[data-scene-ready]').waitFor({timeout:20000}).catch(()=>{});await p.waitForTimeout(2500);
  await p.screenshot({path:dir+name+'.png'});
  if(name==='desktop-en-light'){
   await p.screenshot({path:dir+'closeup-people.png',clip:{x:940,y:470,width:230,height:200}});
   await p.screenshot({path:dir+'closeup-gate.png',clip:{x:500,y:150,width:940,height:560}});
   await p.locator('input[type=email]').fill('student@campus.test');await p.locator('input[type=password]').fill('wrong-pass-1');
   await p.locator('[data-public-form] input[type=submit]').click();await p.waitForTimeout(900);
   await p.screenshot({path:dir+'closeup-reader-denied.png',clip:{x:940,y:470,width:230,height:200}});
  }
  done.push(name+(errors.length?' errors:'+errors.join('|'):''));await ctx.close();
 }
 // Recording: idle, then a verified entry through the gate.
 const ctx=await page.context().browser().newContext({viewport:{width:1280,height:720},recordVideo:{dir:dir+'video/',size:{width:1280,height:720}}});
 const p=await ctx.newPage();await p.goto(base+'/Pages/Account/Login.aspx');await p.locator('[data-scene-ready]').waitFor({timeout:20000}).catch(()=>{});await p.waitForTimeout(2500);
 await p.locator('input[type=email]').fill('student@campus.test');await p.waitForTimeout(400);await p.locator('input[type=password]').fill('Fixture-pass-2026');await p.waitForTimeout(400);
 await p.locator('[data-public-form] input[type=submit]').click();await p.waitForURL('**/Pages/Student/Dashboard.aspx',{timeout:20000}).catch(()=>{});await p.waitForTimeout(800);
 const video=p.video();await ctx.close();done.push('video '+await video.path());
 return done;
}
