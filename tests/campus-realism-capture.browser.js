async page=>{
 const errors=[];page.on('pageerror',e=>errors.push(String(e)));
 for(const [kind,width,height]of[['desktop',1440,1000],['mobile',390,844]]){
  await page.setViewportSize({width,height});await page.goto('http://localhost:57983/Default.aspx');await page.waitForFunction(()=>['ready','fallback'].includes(document.querySelector('[data-story-figure]').dataset.sceneState));
  if(await page.locator('[data-story-toggle]').isVisible())await page.locator('[data-story-toggle]').click();
  for(const i of [0,1,3]){await page.locator('[data-chapter="'+i+'"]').evaluate(el=>scrollTo({top:el.getBoundingClientRect().top+scrollY,behavior:'instant'}));await page.waitForTimeout(700);await page.screenshot({path:'tests/artifacts/realism-'+kind+'-'+i+'.png'});}
 }
 return {errors,snapshot:await page.locator('[data-story-figure]').evaluate(h=>h.universityStory?.snapshot())};
}
