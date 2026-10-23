async page => {
 // Run against tests/Start-LoginTestHost.ps1 (port 57992) with the campus-login simulation on 4910.
 const base='http://localhost:57992',path='/Pages/Public/Contact.aspx',db='http://127.0.0.1:4910/firebase';
 const checks=[];const check=(ok,name)=>{if(!ok)throw Error(name);checks.push(name);};
 const errors=[];page.on('pageerror',e=>errors.push(e.message));
 const field=label=>page.getByLabel(label,{exact:true}),send=()=>page.locator('[data-public-form] input[type=submit]');
 await page.request.post(db+'/__reset');await page.context().clearCookies();await page.setViewportSize({width:1440,height:900});
 const response=await page.goto(base+path);
 check(/charset=utf-8/i.test(response.headers()['content-type']),'Response declares UTF-8');
 const html=await response.text();
 check(!/â€/.test(html),'No mojibake in page HTML');
 check((await page.locator('#messageHint').innerText()).startsWith('20–4,000 characters'),'Hint reads exactly 20–4,000 characters');
 // Client-side validation.
 await send().click();
 for (const label of ['Full name *','Email address *','Subject *','Message *']) check(await field(label).getAttribute('aria-invalid')==='true','Required: '+label);
 await field('Full name *').fill('Test Visitor');await field('Email address *').fill('not-an-email');await field('Subject *').fill('Account access');await field('Message *').fill('Too short');
 await send().click();
 check((await page.locator('#contactEmailError').innerText()).includes('valid'),'Invalid email rejected');
 check(await field('Message *').getAttribute('aria-invalid')==='true','Short message rejected client-side');
 // Server-side validation without JavaScript, including the code-behind's en dashes.
 const nojs=await page.context().browser().newContext({javaScriptEnabled:false});const plain=await nojs.newPage();
 await plain.goto(base+path);
 await plain.getByLabel('Full name *',{exact:true}).fill('Test Visitor');await plain.getByLabel('Email address *',{exact:true}).fill('visitor@example.com');
 await plain.getByLabel('Subject *',{exact:true}).fill('Account access');
 await plain.evaluate(()=>{const m=document.querySelector('textarea');m.removeAttribute('minlength');m.value='Too short';});
 await plain.locator('[data-public-form] input[type=submit]').click();await plain.waitForLoadState('domcontentloaded');
 const notice=await plain.getByRole('alert').innerText();
 check(notice.includes('name 2–100 characters')&&notice.includes('message 20–4,000 characters')&&!/â€/.test(notice),'Server validation message renders en dashes');
 await nojs.close();
 // Valid submission reaches the Firebase fixture.
 await page.goto(base+path);
 await field('Full name *').fill('Test Visitor');await field('Email address *').fill('visitor@example.com');await field('Subject *').fill('Account access question');
 await field('Message *').fill('Synthetic test message for the local Firebase fixture only.');
 await send().click();await page.waitForSelector('.alert-success');
 check((await page.locator('.alert-success').innerText()).includes('sent to the coordination team'),'Success notice after submission');
 const stored=Object.values(await (await page.request.get(db+'/ContactMessages.json')).json()||{});
 check(stored.length===1&&stored[0].Email==='visitor@example.com'&&stored[0].Status==='New'&&stored[0].Message.startsWith('Synthetic test message'),'Message saved to Firebase fixture');
 // Footer still credits the team page.
 const powered=page.locator('.uims-public-footer-powered');
 check((await powered.innerText()).trim()==='Powered by','Footer button reads Powered by');
 await powered.click();await page.waitForURL('**/Pages/Public/PoweredBy.aspx');
 check(await page.getByRole('heading',{level:1}).innerText()==='Meet the Team'&&await page.locator('.team-empty').isVisible()&&await page.locator('.team-card').count()===0,'Team page empty state');
 check(errors.length===0,'No JavaScript errors: '+errors.join(' | '));
 return {passed:checks.length,checks,stored:stored.length};
}
