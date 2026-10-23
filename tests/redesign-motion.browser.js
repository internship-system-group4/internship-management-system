async page => {
 const base='http://localhost:58013';await page.setViewportSize({width:1440,height:1000});
 await page.context().clearCookies();await page.goto(base+'/__fixture.aspx?user=student-one');await page.goto(base+'/Pages/Student/Dashboard.aspx');await page.waitForTimeout(800);
 for(const stage of ['Placement','Training','Evaluation']){
  await page.locator('[data-journey-title="'+stage+'"]').click();await page.locator('.ws-journey-modal.show').waitFor({state:'visible'});await page.waitForTimeout(800);
  await page.keyboard.press('Escape');await page.locator('.ws-journey-modal').waitFor({state:'hidden'});await page.waitForTimeout(300);
 }
 await page.context().clearCookies();await page.goto(base+'/__fixture.aspx?user=coordinator-one');await page.goto(base+'/Pages/Coordinator/Account.aspx');
 await page.locator('[id$="txtPhone"]').fill('+962790001234');await page.locator('[id$="btnSave"]').scrollIntoViewIfNeeded();
 // Delay belongs to the local test network, making actual pending feedback recordable.
 await page.route('**/Pages/Coordinator/Account.aspx',async route=>{if(route.request().method()==='POST')await new Promise(resolve=>setTimeout(resolve,1100));await route.continue();});
 await page.locator('[id$="btnSave"]').click();await page.waitForFunction(()=>document.querySelector('[data-ui-confirmed="true"]'));await page.waitForTimeout(800);
 const stored=await(await page.request.get('http://localhost:4930/firebase/users/coordinator-one.json')).json();if(stored.PhoneNumber!=='+962790001234')throw Error('Recorded save did not persist');
 await page.screenshot({path:'tests/artifacts/redesign-confirmed-save-1440.png',fullPage:true});await page.unrouteAll();
 return {passed:1,recorded:'Three journey selections, centered modal enter/exit and actual coordinator save. Local POST latency controlled by harness.'};
}
