async page => {
 const base=new URL(page.url()).origin, browser=page.context().browser();
 const checks=[],errors=[];
 const check=(ok,name)=>{if(!ok)throw Error(name);checks.push(name);};
 const ctx=await browser.newContext({viewport:{width:1440,height:900},colorScheme:'dark'});
 const p=await ctx.newPage();p.on('pageerror',e=>errors.push(e.message));
 const state=()=>p.evaluate(()=>({theme:document.documentElement.dataset.theme,pref:document.documentElement.dataset.themePreference,saved:localStorage.getItem('uims-theme')}));
 const toggle=()=>p.locator('[data-theme-toggle]:visible').first();
 const wait=theme=>p.waitForFunction(t=>document.documentElement.dataset.theme===t,theme);
 await p.goto(base+'/Pages/Public/Contact.aspx');
 check((await state()).theme==='light','Default Light ignores OS Dark');
 check(await p.locator('[data-theme-value="system"], [data-theme-icon="system"], [role="menu"]').count()===0,'No System option or theme popup');
 check(await toggle().getAttribute('type')==='button'&&await toggle().getAttribute('aria-pressed')==='false','Native toggle exposes state and cannot submit');
 let posts=0;p.on('request',r=>{if(r.method()==='POST')posts++;});
 await p.evaluate(()=>{const root=document.documentElement,animate=root.animate;root.animate=function(frames,options){window.__themeAnimation={frames,options};return animate.call(this,frames,options);};});
 await toggle().click();await wait('dark');
 check((await state()).saved==='dark'&&await toggle().getAttribute('aria-pressed')==='true','One click selects and saves Dark');
 if(await p.evaluate(()=>typeof document.startViewTransition==='function')) {
  await p.waitForFunction(()=>window.__themeAnimation);
  check(await p.evaluate(()=>window.__themeAnimation.options.pseudoElement==='::view-transition-new(root)'&&window.__themeAnimation.options.duration===900&&window.__themeAnimation.frames.clipPath[0].startsWith('circle(0px')),'Circular reveal runs for 900ms');
 }
 // Real rapid clicks interrupt the reveal without leaving the button blocked or the saved state behind.
 const rect=await toggle().boundingBox();
 for(let i=0;i<3;i++){await p.mouse.click(rect.x+rect.width/2,rect.y+rect.height/2);await p.waitForTimeout(50);}
 await wait('light');await p.waitForTimeout(1000);
 check((await state()).saved==='light'&&!await p.evaluate(()=>document.documentElement.classList.contains('uims-theme-reveal')),'Rapid clicks keep the final choice and clean up the reveal');
 await toggle().focus();await p.keyboard.press('Space');await wait('dark');await p.waitForTimeout(1000);
 await p.keyboard.press('Enter');await wait('light');await p.waitForTimeout(1000);
 check(posts===0,'Space, Enter and pointer activation never submit the form');
 await toggle().click();await wait('dark');await p.waitForTimeout(1000);
 await p.reload();check((await state()).theme==='dark','Dark persists through reload');
 await p.goto(base+'/Pages/Public/About.aspx');check((await state()).theme==='dark','Dark persists across routes');
 const q=await ctx.newPage();await q.goto(base+'/Pages/Public/Contact.aspx');
 await p.evaluate(()=>window.UimsTheme.set('light'));await q.waitForFunction(()=>document.documentElement.dataset.theme==='light');
 check(await q.locator('[data-theme-toggle]:visible').getAttribute('aria-pressed')==='false','Second tab follows preference and toggle state');await q.close();
 await p.emulateMedia({reducedMotion:'reduce'});await toggle().click();await wait('dark');
 check(!await p.evaluate(()=>document.documentElement.classList.contains('uims-theme-reveal')),'Reduced motion switches immediately');
 await p.emulateMedia({reducedMotion:'no-preference'});
 await p.evaluate(()=>{document.startViewTransition=undefined;});await toggle().click();await wait('light');
 check((await state()).saved==='light','Unsupported View Transitions still switch');
 await p.goto(base+'/Pages/Public/Contact.aspx?ui-lang=ar');
 check(await p.locator('html').getAttribute('dir')==='rtl'&&/[\u0600-\u06ff]/.test(await toggle().getAttribute('aria-label')),'Arabic toggle is localized in RTL');
 await toggle().click();await wait('dark');await p.waitForTimeout(1000);
 await p.locator('.public-theme-desktop').screenshot({path:'tests/artifacts/theme/direct-toggle-ar-dark.png'});
 await ctx.close();
 const mob=await browser.newContext({viewport:{width:390,height:844},isMobile:true,hasTouch:true});
 const m=await mob.newPage();m.on('pageerror',e=>errors.push(e.message));
 await m.goto(base+'/Pages/Public/Contact.aspx');await m.locator('.public-menu-toggle').click();
 const radios=m.locator('.public-theme-mobile [role="radio"]');
 check(await radios.count()===2,'Phone has only Light and Dark');
 await radios.locator('..').locator('[data-theme-value="dark"]').tap();await m.waitForFunction(()=>document.documentElement.dataset.theme==='dark');
 check(await radios.locator('..').locator('[data-theme-value="dark"]').getAttribute('aria-checked')==='true','Phone tap selects Dark immediately');
 const lightBox=await m.locator('.public-theme-mobile [data-theme-value="light"]').boundingBox();
 await m.touchscreen.tap(lightBox.x+lightBox.width/2,lightBox.y+lightBox.height/2);
 await m.waitForFunction(()=>document.documentElement.dataset.theme==='light');
 check(await m.evaluate(()=>localStorage.getItem('uims-theme')==='light'),'A rapid second phone tap interrupts the reveal and selects Light');
 await m.waitForTimeout(1000);await m.locator('.public-theme-mobile').screenshot({path:'tests/artifacts/theme/direct-toggle-mobile.png'});
 await mob.close();
 const legacy=await browser.newContext({colorScheme:'dark'});await legacy.addInitScript(()=>{localStorage.setItem('uims-theme','system');});
 const l=await legacy.newPage();await l.goto(base+'/Pages/Public/Contact.aspx');
 check(await l.evaluate(()=>localStorage.getItem('uims-theme')==='dark'&&document.documentElement.dataset.themePreference==='dark'),'Existing System preference migrates once to current Light/Dark appearance');await legacy.close();
 check(errors.length===0,'No browser errors: '+errors.join(' | '));
 return {passed:checks.length,checks};
}
