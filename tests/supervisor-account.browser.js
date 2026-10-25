// Read-only UI verification. Does not submit profiles, photos or password changes.
async page => {
 const base=new URL(page.url()).origin,checks=[],errors=[];
 const check=(ok,name)=>{if(!ok)throw Error(name);checks.push(name);};
 const ctx=await page.context().browser().newContext({viewport:{width:1440,height:1000},reducedMotion:'reduce'}),p=await ctx.newPage();p.on('pageerror',e=>errors.push(e.message));
 for(const [user,role] of [['supervisor-one','Company'],['academic-one','Academic']]){
  await p.goto(base+'/__fixture.aspx?user='+user);
  for(const lang of ['en','ar']){
   await ctx.addCookies([{name:'uims-lang',value:lang,url:base}]);const response=await p.goto(base+'/Pages/'+role+'/Account.aspx');
   check(response.status()===200&&!/Server Error in|Parser Error/.test(await p.locator('body').innerText()),'Account renders: '+role+'/'+lang);
   check(await p.locator('.su-account-layout').count()===1&&await p.locator('.su-account-actions>*').count()===2,'Shared account structure and actions: '+role+'/'+lang);
   check(await p.locator('.su-account-identity h2').evaluate(e=>['start','left','right'].includes(getComputedStyle(e).textAlign)),'Profile name aligned consistently: '+role+'/'+lang);
   for(const theme of ['light','dark'])for(const width of [1440,390]){
    await p.evaluate(t=>window.UimsTheme.set(t),theme);await p.setViewportSize({width,height:width===390?844:1000});
    check(await p.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1),'Account fits viewport: '+role+'/'+lang+'/'+theme+'/'+width);
    check(await p.locator('.su-account-actions .su-button').evaluateAll(nodes=>nodes.every(e=>e.getBoundingClientRect().height>=44&&getComputedStyle(e).fontSize==='16px')),'Consistent account actions: '+role+'/'+lang+'/'+theme+'/'+width);
    if((theme==='light'&&width===1440)||(theme==='dark'&&width===390))await p.screenshot({path:`tests/artifacts/account-${role}-${lang}-${theme}-${width}.png`,fullPage:true});
   }
   await p.locator('.su-account-actions [data-bs-target="#editProfileModal"]').click();await p.locator('#editProfileModal.show').waitFor();
   check(await p.locator('#editProfileModal').getAttribute('aria-modal')==='true','Edit dialog semantics: '+role+'/'+lang);
   const name=p.locator('input[id$=txtFullName]'),phone=p.locator('input[id$=txtPhone]');
   check(role==='Academic'?await name.isDisabled():await name.isEditable(),'Role-specific name permissions retained: '+role+'/'+lang);
   await phone.fill('+962 7 1234 5678');await p.keyboard.press('Escape');await p.locator('#editProfileModal.show').waitFor({state:'hidden'});
   await p.locator('.su-account-actions [data-bs-target="#editProfileModal"]').click();await p.locator('#editProfileModal.show').waitFor();
   check(await phone.inputValue()==='+962 7 1234 5678','Cancel/reopen retains unsaved draft: '+role+'/'+lang);
   await p.screenshot({path:`tests/artifacts/account-edit-${role}-${lang}.png`});await p.keyboard.press('Escape');await p.locator('#editProfileModal.show').waitFor({state:'hidden'});
   check(await p.locator('input[id$=btnSaveChanges]').getAttribute('name').then(n=>n.includes('btnSaveChanges')),'Existing save control retained: '+role+'/'+lang);
   if(role==='Academic'){
    check(await p.locator('input[id$=txtEmail]').isDisabled()&&await p.locator('input[id$=txtUniversity]').isDisabled(),'Academic institutional fields stay read-only');
    await p.locator('[data-bs-target="#passwordModal"]').click();await p.locator('#passwordModal.show').waitFor();
    check(await p.locator('#passwordModal input[type=password]').count()===2,'Existing password controls retained');await p.keyboard.press('Escape');
   }else check(await p.locator('script[src*="bootstrap.bundle"]').count()===1,'Single Bootstrap runtime owns Company dialogs');
   await p.setViewportSize({width:375,height:812});await p.evaluate(()=>document.documentElement.style.fontSize='200%');
   check(await p.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1),'Account supports enlarged text: '+role+'/'+lang);
   check(await p.locator('.su-account-avatar-wrap').evaluate(avatar=>{const actions=document.querySelector('.su-account-actions');return actions.getBoundingClientRect().top>=avatar.getBoundingClientRect().bottom;}),'Header actions stay clear of avatar with enlarged text: '+role+'/'+lang);
   await p.evaluate(()=>document.documentElement.style.fontSize='');
  }
 }
 await ctx.close();check(errors.length===0,'No uncaught browser errors: '+errors.join(' | '));return {passed:checks.length,checks};
}
