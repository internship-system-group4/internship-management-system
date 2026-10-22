async page => {
 const checks=[],errors=[];
 const check=(ok,name)=>{if(!ok)throw Error(name);checks.push(name);};
 try {
 page.on('pageerror',error=>errors.push(String(error)));
 await page.setViewportSize({width:1440,height:1000});
 await page.emulateMedia({reducedMotion:'no-preference'});
 await page.goto('http://localhost:57983/Default.aspx');
 await page.waitForFunction(()=>document.querySelector('[data-story-figure]')?.universityStory?.snapshot().state==='ready');
 await page.locator('[data-story-toggle]').click();
 check(await page.locator('.campus-chapter-nav a').count()===5,'Five named chapter navigation links');
 check(await page.locator('[data-story-link="0"]').getAttribute('aria-current')==='step','Opening chapter announced as current');
 await page.locator('[data-hotspot="colleges"]').click();
 await page.waitForFunction(()=>document.querySelector('[data-story-link="2"]').getAttribute('aria-current')==='step');
 check(page.url().endsWith('#colleges'),'Landmark remains clickable through the expansive opening title');
 await page.locator('[data-story-link="0"]').focus();await page.keyboard.press('Enter');
 await page.waitForFunction(()=>document.querySelector('[data-story-figure]').universityStory.snapshot().progress<.01);
 check(page.url().endsWith('#campus-overview'),'Keyboard chapter navigation restores overview');
 await page.goBack();
 await page.waitForFunction(()=>document.querySelector('[data-story-figure]').universityStory.snapshot().progress>.35);
 check(page.url().endsWith('#colleges'),'Browser Back restores the prior chapter');
 await page.goForward();
 await page.waitForFunction(()=>document.querySelector('[data-story-figure]').universityStory.snapshot().progress<.01);
 check(page.url().endsWith('#campus-overview'),'Browser Forward restores the overview');
 await page.locator('[data-story-link="4"]').click();
 await page.waitForFunction(()=>document.querySelector('[data-story-link="4"]').getAttribute('aria-current')==='step');
 check(page.url().endsWith('#opportunity-destination'),'Chapter navigation follows native scroll to final view');
 await page.locator('#internship-video').scrollIntoViewIfNeeded();
 check(await page.locator('.home-video-visual>img').evaluate(image=>image.complete&&image.naturalWidth>0),'Real courtyard photograph loads in guide section');
 check(await page.locator('.home-video-placeholder').isVisible()&&await page.locator('video source').count()===0,'Guide remains honest about missing video');
 await page.screenshot({path:'tests/artifacts/redesign-guide-desktop.png'});
 await page.locator('#opportunities').scrollIntoViewIfNeeded();
 await page.screenshot({path:'tests/artifacts/redesign-opportunities-desktop.png'});
 for(const width of [320,390,768]){
  await page.setViewportSize({width,height:900});
  await page.goto('http://localhost:57983/Default.aspx');
  await page.waitForFunction(()=>document.querySelector('[data-story-figure]')?.universityStory?.snapshot().state==='ready');
  const link=page.getByRole('link',{name:'Chapter 2: The connection',exact:true});
  await link.click();
  await page.waitForFunction(()=>document.querySelector('[data-story-link="1"]').getAttribute('aria-current')==='step');
  check(page.url().endsWith('#university-gate'),'Named chapter navigation works at '+width+'px');
  check(!await page.evaluate(()=>document.documentElement.scrollWidth>innerWidth),'Redesign has no horizontal overflow at '+width+'px');
 }
 await page.emulateMedia({reducedMotion:'reduce'});
 await page.waitForFunction(()=>document.querySelector('[data-home-story]').classList.contains('is-static'));
 check(!await page.locator('.campus-chapter-nav').isVisible(),'Reduced motion returns to normal document navigation');
 check(errors.length===0,'No new page errors');
 return {passed:checks.length,checks,errors};
 } catch(error) {
  const state=await page.evaluate(()=>({hash:location.hash,scroll:scrollY,state:document.querySelector('[data-story-figure]')?.universityStory?.snapshot()}));
  throw new Error(error.message+'; after '+JSON.stringify(checks)+'; page '+JSON.stringify(state));
 }
}
