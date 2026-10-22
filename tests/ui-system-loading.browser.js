async page => {
 // Capture a real pending POST without cross-document screenshot blanking.
 // Only this capture harness targets its response into an invisible iframe.
 const base='http://localhost:58001',db='http://localhost:4920/firebase';
 await page.context().clearCookies();await page.goto(base+'/__fixture.aspx?user=coordinator-one');
 await page.setViewportSize({width:390,height:1000});await page.goto(base+'/Pages/Coordinator/Account.aspx');
 await page.locator('[id$="txtName"]').fill('Loading capture fixture');
 await page.evaluate(()=>{const iframe=document.createElement('iframe');iframe.name='ui-capture-response';iframe.hidden=true;document.body.append(iframe);document.querySelector('form').target=iframe.name;});
 let posts=0;
 await page.route('**/Pages/Coordinator/Account.aspx',async route=>{if(route.request().method()==='POST'){posts++;await new Promise(resolve=>setTimeout(resolve,1800));}await route.continue();});
 const response=page.waitForResponse(r=>r.url().includes('/Coordinator/Account.aspx')&&r.request().method()==='POST');
 const busy=await page.evaluate(()=>{const button=document.querySelector('[id$="btnSave"]');const width=button.getBoundingClientRect().width;button.click();const result={label:button.value,disabled:button.disabled,aria:button.getAttribute('aria-disabled'),widthStable:Math.abs(width-button.getBoundingClientRect().width)<1};button.click();return result;});
 if(busy.label!=='Saving…'||busy.disabled||busy.aria!=='true'||!busy.widthStable)throw Error('Incorrect busy state '+JSON.stringify(busy));
 await page.screenshot({path:'tests/artifacts/ui-loading-mobile.png',fullPage:true});
 await response;
 const saved=await(await page.request.get(db+'/users/coordinator-one.json')).json();
 if(posts!==1||saved.FullName!=='Loading capture fixture')throw Error('Capture POST did not confirm exactly once');
 await page.unrouteAll();
 await page.evaluate(()=>{document.querySelector('form').removeAttribute('target');document.querySelector('iframe[name="ui-capture-response"]').remove();UimsUI.reset();});
 return {passed:3,busy,posts,confirmed:true,captureHarness:'Actual POST response sent into iframe for screenshot only; normal full postback independently verified in ui-system.browser.js.'};
}
