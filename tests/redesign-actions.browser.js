async page => {
 const base='http://localhost:58013',db='http://localhost:4930/firebase',checks=[];
 const check=(ok,label)=>{if(!ok)throw Error(label);checks.push(label);};
 page.setDefaultTimeout(8000);await page.setViewportSize({width:390,height:1000});
 for(const [role,id,route,buttonId] of [['Student','student-one','DisplayEditProfile','btnSave'],['Company','supervisor-one','Account','btnSaveChanges'],['Academic','academic-one','Account','btnSaveChanges'],['Coordinator','coordinator-one','Account','btnSave']]){
  await page.context().clearCookies();await page.goto(base+'/__fixture.aspx?user='+id);await page.goto(base+'/Pages/'+role+'/'+route+'.aspx');
  if(role==='Company')await page.getByRole('button',{name:'Edit Profile',exact:true}).click();
  const phone='+9627900000'+checks.length;await page.locator('[id$="txtPhone"]').fill(phone);
  await page.evaluate(()=>{const frame=document.createElement('iframe');frame.hidden=true;frame.name='action-response';document.body.append(frame);document.querySelector('form').target=frame.name;});
  let posts=0;await page.route('**/Pages/'+role+'/'+route+'.aspx',async route=>{if(route.request().method()==='POST'){posts++;await new Promise(resolve=>setTimeout(resolve,1500));}await route.continue();});
  const response=page.waitForResponse(r=>r.url().includes('/'+role+'/'+route+'.aspx')&&r.request().method()==='POST');
  const button=page.locator('[id$="'+buttonId+'"]');await button.scrollIntoViewIfNeeded();
  const busy=await button.evaluate(button=>{const width=button.getBoundingClientRect().width;button.click();const result={label:button.value,disabled:button.disabled,aria:button.getAttribute('aria-disabled'),stable:Math.abs(width-button.getBoundingClientRect().width)<1};button.click();return result;});
  check(busy.label==='Saving…'&&!busy.disabled&&busy.aria==='true',role+' exposes real pending save');check(busy.stable,role+' save retains width');
  await page.screenshot({path:'tests/artifacts/redesign-loading-'+role+'-390.png',fullPage:true});
  await (await response).finished();await page.unrouteAll();
  const stored=await(await page.request.get(db+'/users/'+id+'.json')).json();check(posts===1&&stored[role==='Company'?'Phone':'PhoneNumber']===phone,role+' duplicate activation writes once');
  // A second save uses the normal full-page postback, without the capture-only iframe.
  await page.goto(base+'/Pages/'+role+'/'+route+'.aspx');if(role==='Company')await page.getByRole('button',{name:'Edit Profile',exact:true}).click();await page.locator('[id$="txtPhone"]').fill(phone+'1');
  await page.locator('[id$="'+buttonId+'"]').click();await page.waitForLoadState('load');
  const confirmed=await(await page.request.get(db+'/users/'+id+'.json')).json();check(confirmed[role==='Company'?'Phone':'PhoneNumber']===phone+'1',role+' normal full postback persists');
  await page.waitForFunction(()=>/success|profile updated/i.test(document.body.innerText));
  check((await page.locator('body').innerText()).toLowerCase().includes('success')||(await page.locator('body').innerText()).includes('Profile updated'),role+' server confirms save');
 }
 return {passed:checks.length,checks,scope:'Local fixture only. An iframe and delayed POST are capture-harness features only; normal full postbacks separately verified.'};
}
