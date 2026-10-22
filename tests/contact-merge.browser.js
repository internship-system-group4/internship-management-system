async page=>{
 const base='http://localhost:57983',db='http://localhost:4903/firebase';let checks=0;const errors=[];
 const check=(ok,name)=>{if(!ok)throw Error(name);checks++;};page.on('pageerror',e=>errors.push(e.message));
 await page.context().clearCookies();await page.request.post(db+'/__reset');
 await page.goto(base+'/Pages/Public/Contact.aspx');
 await page.getByLabel('Full name *',{exact:true}).fill('Merge Verification');await page.getByLabel('Email address *',{exact:true}).fill('merge@example.com');
 await page.getByLabel('Subject *',{exact:true}).fill('Main merge inbox verification');await page.getByLabel('Message *',{exact:true}).fill('This message verifies the redesigned contact form still reaches the coordinator inbox after merging main.');
 const posted=page.waitForRequest(request=>request.method()==='POST'&&request.url().includes('/Public/Contact.aspx'));
 await page.getByRole('button',{name:'Send message',exact:true}).click();await page.waitForLoadState('load');
 check((await page.getByRole('alert').innerText()).includes('has been sent'),'Confirmed public submission');
 const records=await (await page.request.get(db+'/ContactMessages.json')).json();const entries=Object.entries(records);check(entries.length===1,'One stable message record');
 const originalPost=await posted;
 const replay=()=>page.request.post(originalPost.url(),{data:originalPost.postData(),headers:{'Content-Type':'application/x-www-form-urlencoded'}});
 await replay();check(Object.keys(await (await page.request.get(db+'/ContactMessages.json')).json()).length===1,'Repeated POST does not duplicate');
 const [id,record]=entries[0];check(record.Name==='Merge Verification'&&record.Email==='merge@example.com'&&record.Status==='New','Main inbox field contract');
 await page.reload();check(Object.keys(await (await page.request.get(db+'/ContactMessages.json')).json()).length===1,'Reload never resends');
 await page.request.put(db+'/users/merge-coordinator.json',{data:{Id:'merge-coordinator',Role:4,FullName:'Merge Coordinator',IsActive:true,MustChangePassword:false}});
 await page.goto(base+'/__fixture.aspx?user=merge-coordinator');await page.goto(base+'/Pages/Coordinator/ContactMessages.aspx');
 check((await page.locator('body').innerText()).includes(record.Subject),'Coordinator inbox reads public submission');
 await page.getByRole('link',{name:'Review',exact:true}).click();await page.waitForLoadState('load');
 await page.getByRole('button',{name:'Mark as Reviewed',exact:true}).waitFor({state:'visible'});
 check(await page.getByRole('button',{name:'Mark as Reviewed',exact:true}).isVisible(),'Existing review dialog works');
 await page.getByRole('button',{name:'Mark as Reviewed',exact:true}).click();await page.waitForLoadState('load');
 check((await (await page.request.get(db+'/ContactMessages/'+id+'.json')).json()).Status==='Reviewed','Existing review postback updates same record');
 await replay();check((await (await page.request.get(db+'/ContactMessages/'+id+'.json')).json()).Status==='Reviewed','Repeated old POST cannot reset reviewed status');
 check(errors.length===0,'No browser errors');return {passed:checks,mode:'Local Postman Firebase stand-in; merged public submit and coordinator review'};
}
