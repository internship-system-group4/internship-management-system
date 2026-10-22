async page => {
 const context = await page.context().browser().newContext({viewport:{width:390,height:844}});
 try {
  const loading = await context.newPage();
  // Simulate a busy device that has loaded assets but cannot draw its first frame yet.
  await loading.addInitScript(() => {
   const request = window.requestAnimationFrame.bind(window);
   const pending = new Map(); let next = -1;
   window.requestAnimationFrame = callback => {
    if (window.campusFramesReleased) return request(callback);
    const id = next--; pending.set(id, callback); return id;
   };
   const cancel = window.cancelAnimationFrame.bind(window);
   window.cancelAnimationFrame = id => id < 0 ? pending.delete(id) : cancel(id);
   window.releaseCampusFrames = () => {
    window.campusFramesReleased = true;
    pending.forEach(callback => request(callback)); pending.clear();
   };
  });
  await loading.goto('http://localhost:57983/Default.aspx');
  await loading.waitForFunction(() => document.querySelector('[data-story-figure]')?.universityStory, null, {polling:50});
  if (!await loading.locator('.home-story-photo').isVisible()) throw Error('Loading photo disappeared before the first frame');
  if (!await loading.locator('h1').isVisible()) throw Error('Heading unavailable while rendering waits');
  if (!await loading.getByRole('link',{name:'Explore internships',exact:false}).first().isVisible()) throw Error('CTA unavailable while rendering waits');
  await loading.evaluate(() => window.releaseCampusFrames());
  await loading.waitForFunction(() => document.querySelector('[data-story-figure]').dataset.sceneState === 'ready');
  if (await loading.locator('.home-story-photo').isVisible()) throw Error('Photo still covers the successful render');
  const targets = await loading.locator('[data-hotspot]:visible').evaluateAll(nodes => nodes.map(node => node.getBoundingClientRect().height));
  if (!targets.length || targets.some(height => height < 44)) throw Error('Mobile landmark target is smaller than 44px');
  return {passed:5,checks:['Photo persists before first frame','Heading available during loading','CTA available during loading','Photo yields to successful render','Mobile landmark targets at least 44px']};
 } finally { await context.close(); }
}
