async page=>{
 await page.setViewportSize({width:1440,height:1000});await page.goto('http://localhost:57983/Default.aspx');await page.waitForFunction(()=>document.querySelector('[data-story-figure]').universityStory?.snapshot().state==='ready');
 await page.locator('[data-story-toggle]').click();
 for(let i=0;i<5;i++){await page.locator('[data-chapter="'+i+'"]').evaluate(el=>window.scrollTo({top:el.getBoundingClientRect().top+scrollY,behavior:"instant"}));await page.waitForTimeout(1000);await page.screenshot({path:'tests/artifacts/campus-desktop-chapter-'+(i+1)+'.png'});}
 await page.setViewportSize({width:390,height:844});await page.goto('http://localhost:57983/Default.aspx');await page.waitForFunction(()=>document.querySelector('[data-story-figure]').universityStory?.snapshot().state==='ready');await page.locator('[data-story-toggle]').click();
 for(let i=0;i<5;i++){await page.locator('[data-chapter="'+i+'"]').evaluate(el=>window.scrollTo({top:el.getBoundingClientRect().top+scrollY,behavior:"instant"}));await page.waitForTimeout(1000);await page.screenshot({path:'tests/artifacts/campus-mobile-chapter-'+(i+1)+'.png'});}
 return {state:await page.locator('[data-story-figure]').evaluate(h=>h.universityStory.snapshot()),overflow:await page.evaluate(()=>document.documentElement.scrollWidth>innerWidth)};
}
