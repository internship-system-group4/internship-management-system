async page => {
 let lastPassed='(none)';
 try {
 // Run against tests/Start-LoginTestHost.ps1 (port 57992) with the campus-login simulation on 4910. All writes go to the
 // isolated Firebase fixture (postman/mocks/firebase), never to a live database.
 const base='http://localhost:57992',url=base+'/Pages/Public/Contact.aspx',fixture='http://127.0.0.1:4910/firebase';
 const checks=[];const check=(ok,name)=>{if(!ok)throw Error(name);checks.push(name);lastPassed=name;};
 const errors=[];const watch=p=>{p.on('pageerror',e=>errors.push(e.message));p.on('console',m=>{if(['error','warning'].includes(m.type()))errors.push(m.text().slice(0,200));});};watch(page);
 const A='tests/artifacts/';
 const stored=async()=>Object.values(await (await page.request.get(fixture+'/ContactMessages.json')).json()||{});
 await page.request.post(fixture+'/__reset');await page.request.post(fixture+'/__restore-writes');
 const name=p=>p.locator('#'+'MainContent_txtName'),email=p=>p.locator('#MainContent_txtEmail'),subject=p=>p.locator('#MainContent_txtSubject'),message=p=>p.locator('#MainContent_txtMessage'),send=p=>p.locator('#MainContent_btnSend');
 const err=(p,id)=>p.locator('#'+id).innerText();
 const ready=p=>p.locator('[data-readiness-text]').innerText();
 await page.setViewportSize({width:1440,height:900});await page.emulateMedia({reducedMotion:'no-preference'});
 await page.goto(url);await page.waitForTimeout(800);

 // Structure, labels and attributes.
 check(await page.locator('main h1').count()===1&&(await page.locator('main h1').innerText()).includes('Start a Conversation'),'One H1: Let’s Start a Conversation');
 check(await page.getByLabel('Full Name').getAttribute('autocomplete')==='name'&&await page.getByLabel('Email Address').getAttribute('autocomplete')==='email'&&await page.getByLabel('Email Address').getAttribute('type')==='email','Visible labels; name/email autocomplete and email type');
 check(await name(page).getAttribute('placeholder')==='Your full name'&&await subject(page).getAttribute('placeholder')==='What would you like to discuss?'&&await message(page).getAttribute('placeholder')==='Tell us how we can help…','Placeholders as specified (ellipsis renders correctly)');
 check(await name(page).getAttribute('maxlength')==='100'&&await subject(page).getAttribute('minlength')==='5'&&await message(page).getAttribute('maxlength')==='4000'&&await message(page).getAttribute('minlength')==='20','Field limits in the markup: name 2-100, subject 5-150, message 20-4,000');
 check(/All fields are required/.test(await page.locator('.contact-card-head').innerText())&&await page.getByText('Please do not include passwords or sensitive account information.').isVisible(),'Required-field explanation and sensitive-information note');
 check(await page.locator('[data-contact-envelope]').evaluate(e=>e.closest('[aria-hidden="true"]')!==null&&getComputedStyle(e.closest('.contact-envelope-tile')).pointerEvents==='none'),'Envelope is decorative: hidden from assistive tech, never takes clicks');
 check(await ready(page)==='0 of 4 fields ready'&&!(await page.locator('[data-contact-readiness]').getAttribute('aria-live')),'Form readiness starts at 0 of 4 and is not a live region');
 check(await page.evaluate(()=>[...document.querySelectorAll('.contact-page button')].every(b=>b.type==='button'))&&await page.locator('form').count()===1,'No nested forms; no stray submit buttons');

 // Keyboard order skips the honeypot.
 await name(page).focus();const order=[];for(let i=0;i<4;i++){await page.keyboard.press('Tab');order.push(await page.evaluate(()=>document.activeElement.id));}
 check(order.join()==='MainContent_txtEmail,MainContent_txtSubject,MainContent_txtMessage,MainContent_btnSend','Tab order: name, email, subject, message, send');

 // Validation timing: nothing on first focus, errors after leaving a field the visitor typed in.
 await name(page).focus();await email(page).focus();check(await err(page,'nameError')==='','No error just for visiting an empty field');
 await name(page).fill('A');await name(page).blur();
 check(await err(page,'nameError')==='Your name needs at least 2 characters.'&&await name(page).getAttribute('aria-invalid')==='true'&&(await name(page).getAttribute('aria-describedby')).startsWith('nameError'),'Short name: error beside the field, aria-invalid, described by the error');
 check(await page.locator('#nameError').evaluate(e=>getComputedStyle(e,'::before').content!=='none'),'Errors carry an icon, not colour alone');
 await name(page).focus();await page.waitForTimeout(300); // let the 180ms transition finish
 // Colours come from the shared UI tokens: --ui-danger for invalid fields, --ui-focus for the focus outline.
 const token=name=>page.evaluate(n=>{const probe=document.createElement('i');probe.style.color='var('+n+')';document.body.append(probe);const c=getComputedStyle(probe).color;probe.remove();return c;},name);
 const danger=await token('--ui-danger'),focusColor=await token('--ui-focus');
 const focusStyle=await name(page).evaluate(i=>({border:getComputedStyle(i).borderColor,outline:getComputedStyle(i).outlineStyle,outlineColor:getComputedStyle(i).outlineColor,width:parseFloat(getComputedStyle(i).outlineWidth)}));
 check(focusStyle.border===danger&&focusStyle.outline==='solid'&&focusStyle.outlineColor===focusColor&&focusStyle.width>=2,'Focused invalid field: danger border plus the visible shared focus outline');
 await name(page).fill('Lina Haddad');await name(page).blur();check(await err(page,'nameError')===''&&await ready(page)==='1 of 4 fields ready','Fixing the name clears the error; readiness 1 of 4');
 await email(page).fill('lina@');await email(page).blur();check(await err(page,'contactEmailError')==='Enter an email address like name@example.com.','Invalid email message');
 await email(page).focus();const ok=await email(page).evaluate(i=>({border:getComputedStyle(i).borderColor,ring:getComputedStyle(i).boxShadow}));
 await email(page).fill('lina.haddad@example.com');await page.waitForTimeout(300);
 const brand=await email(page).evaluate(i=>({border:getComputedStyle(i).borderColor,ring:getComputedStyle(i).boxShadow,label:getComputedStyle(i.closest('.public-field').querySelector('label')).color}));
 check(/38, 79, 115/.test(brand.border)&&/38, 79, 115/.test(brand.label)&&await email(page).evaluate((i,c)=>getComputedStyle(i).outlineStyle==='solid'&&getComputedStyle(i).outlineColor===c,focusColor),'Focused valid field: brand border and label, shared focus outline');
 await subject(page).fill('Acc');await subject(page).blur();check(await err(page,'subjectError')==='Your subject needs at least 5 characters.','Subject minimum 5');
 await subject(page).fill('Account access');
 await message(page).fill('x'.repeat(19));check(await ready(page)==='3 of 4 fields ready'&&!await page.locator('[data-contact-envelope]').evaluate(e=>e.classList.contains('is-ready')),'19-character message is not ready (3 of 4)');
 await message(page).fill('I cannot sign in to my student account.');
 check(await ready(page)==='4 of 4 fields ready'&&await page.locator('[data-contact-envelope]').evaluate(e=>e.classList.contains('is-ready')&&getComputedStyle(e).getPropertyValue('--ready').trim()==='1'),'All four ready: 4 of 4, envelope ready');
 check(await page.locator('[data-contact-counter]').innerText()==='39 / 4,000','Character count reflects the 4,000 limit');
 check(await page.locator('.contact-readiness-bar i.is-on').count()===4,'Four readiness segments on');
 await page.waitForTimeout(500);await page.locator('.contact-layout').screenshot({path:A+'contact-ready-1440.png'});

 // Submission: busy state, spinner, steady size, duplicate clicks blocked, success only after the save.
 await page.request.post(fixture+'/__slow-writes'); // the fixture holds the save for 2.5 s
 // Playwright stalls page scripts while a navigation is pending, so the page records its own state 200ms into the
 // submit (and tries a second click), and the test reads that record after the redirect.
 await page.evaluate(()=>{
  sessionStorage.removeItem('contactProbe');let submits=0;
  const box=b=>{const r=b.getBoundingClientRect();return [Math.round(r.width),Math.round(r.height)];};
  const button=document.getElementById('MainContent_btnSend'),size=box(button);
  document.forms[0].addEventListener('submit',()=>{submits++;sessionStorage.setItem('contactSubmits',String(submits));if(submits>1)return;
   setTimeout(()=>{const c=document.querySelector('.contact-card');
    const probe={value:button.value,ariaDisabled:button.getAttribute('aria-disabled'),busy:c.getAttribute('aria-busy'),spinner:getComputedStyle(document.querySelector('.contact-submit'),'::before').opacity,status:document.querySelector('[data-submit-status]').textContent,before:size,during:box(button),name:document.getElementById('MainContent_txtName').value};
    button.click();probe.secondClickSubmitted=submits>1;sessionStorage.setItem('contactProbe',JSON.stringify(probe));},200);});
 });
 await send(page).focus();await page.keyboard.press('Enter');
 await page.waitForURL(url+'?sent=1#contact-form',{timeout:15000});await page.waitForTimeout(1600);await page.request.post(fixture+'/__restore-writes');
 const busy=JSON.parse(await page.evaluate(()=>sessionStorage.getItem('contactProbe')));
 check(busy.value==='Sending…'&&busy.ariaDisabled==='true'&&busy.busy==='true'&&busy.spinner==='1'&&/Please wait for confirmation/.test(busy.status),'Sending… with spinner, aria-busy and a status message');
 check(busy.before[0]===busy.during[0]&&busy.before[1]===busy.during[1],'Button keeps its size while sending');
 check(busy.name==='Lina Haddad','Values stay while waiting');
 check(!busy.secondClickSubmitted&&await page.evaluate(()=>sessionStorage.getItem('contactSubmits'))==='1','A second click while sending is blocked');
 let saved=await stored();
 check(saved.length===1,'Two clicks saved one message');
 const m=saved[0];
 check(Object.keys(m).sort().join()==='Email,Message,Name,Status,Subject,SubmittedAt'&&m.Status==='New'&&typeof m.SubmittedAt==='number'&&m.Name==='Lina Haddad'&&m.Subject==='Account access','Saved with the existing contract: Name, Email, Subject, Message, Status "New", SubmittedAt (ms)');
 check(await page.locator('.contact-sent h2').innerText()==='Message sent'&&/Your message has been received\. Thank you for contacting us\./.test(await page.locator('.contact-sent').innerText()),'Confirmed save shows "Message sent" in the form area');
 check(await page.evaluate(()=>document.activeElement.matches('.contact-sent h2'))&&await page.locator('#MainContent_txtName').count()===0,'Confirmation takes focus; the form is replaced');
 check(await page.locator('.contact-sent-flap').evaluate(e=>getComputedStyle(e).animationName==='contact-flap-close')&&await page.locator('.contact-sent-check').evaluate(e=>getComputedStyle(e).animationName==='contact-check'),'Envelope closes and the check draws');
 await page.locator('.contact-layout').screenshot({path:A+'contact-success-1440.png'});
 await page.reload();await page.waitForTimeout(600);
 check(await page.locator('.contact-sent').count()===0&&(await stored()).length===1,'Refresh shows the form again and sends nothing twice');
 await page.goto(url);await page.waitForTimeout(300);
 // "Send another message".
 await page.request.post(fixture+'/__reset');
 await name(page).fill('Omar Saleh');await email(page).fill('omar@example.com');await subject(page).fill('Training question');await message(page).fill('Where should I ask about my weekly tasks?');
 await send(page).click();await page.waitForURL(url+'?sent=1#contact-form');await page.waitForTimeout(400);
 await page.getByRole('link',{name:'Send another message'}).click();await page.waitForTimeout(600);
 check(await name(page).inputValue()===''&&await message(page).inputValue()===''&&await ready(page)==='0 of 4 fields ready','Send another message opens an empty form');

 // Failure: values kept, error summary focused, no success, retry works.
 await page.request.post(fixture+'/__reset');await page.request.post(fixture+'/__fail-writes');
 await name(page).fill('Rana Odeh');await email(page).fill('rana.odeh@example.com');await subject(page).fill('Login problem');await message(page).fill('My password reset email has not arrived yet.');
 await send(page).click();await page.waitForLoadState();await page.waitForTimeout(600);
 const alertText=await page.locator('.contact-alert').innerText();
 check(/could not be sent right now/.test(alertText)&&!/Firebase|permission/i.test(alertText),'Failure: plain error summary without technical details');
 check(await page.evaluate(()=>document.activeElement.classList.contains('contact-alert'))&&await page.locator('.contact-sent').count()===0,'Failure: summary focused, no success shown');
 check(await name(page).inputValue()==='Rana Odeh'&&await message(page).inputValue()==='My password reset email has not arrived yet.'&&(await stored()).length===0,'Failure: values kept, nothing saved');
 await page.locator('.contact-card').screenshot({path:A+'contact-failure-1440.png'});
 await page.request.post(fixture+'/__restore-writes');
 await send(page).click();await page.waitForURL(url+'?sent=1#contact-form');await page.waitForTimeout(400);
 check(await page.locator('.contact-sent').count()===1&&(await stored()).length===1,'Retry after failure succeeds');

 // Client validation on submit: all four errors, first invalid field focused, nothing posted.
 await page.goto(url);await page.waitForTimeout(400);
 await send(page).click();await page.waitForTimeout(300);
 check([await err(page,'nameError'),await err(page,'contactEmailError'),await err(page,'subjectError'),await err(page,'messageError')].join('|')==='Enter your full name.|Enter your email address.|Enter a subject for your message.|Enter your message.','Empty submit: an error beside every field');
 check(await page.evaluate(()=>document.activeElement.id)==='MainContent_txtName'&&(await stored()).length===1,'Empty submit: first field focused, nothing posted');
 await page.screenshot({path:A+'contact-errors-1440.png'});

 // Without JavaScript: server validation, boundaries and success.
 const nojs=await page.context().browser().newContext({javaScriptEnabled:false,viewport:{width:1440,height:900}});const plain=await nojs.newPage();
 await plain.goto(url);
 await plain.locator('form').evaluate(f=>f.noValidate=true).catch(()=>{});
 await send(plain).click();await plain.waitForLoadState();
 check(await plain.locator('.contact-alert').isVisible()&&await err(plain,'nameError')==='Enter your full name.'&&await name(plain).getAttribute('aria-invalid')==='true','No JS: server errors beside fields with aria-invalid');
 await plain.goto(url);
 await name(plain).fill('N');await email(plain).fill('no-at-sign');await subject(plain).fill('abc');await message(plain).evaluate(t=>{t.removeAttribute('maxlength');t.removeAttribute('minlength');t.value='y'.repeat(4001);});
 await name(plain).evaluate(i=>i.removeAttribute('minlength'));await subject(plain).evaluate(i=>i.removeAttribute('minlength'));await email(plain).evaluate(i=>i.type='text');
 await send(plain).click();await plain.waitForLoadState();
 check([await err(plain,'nameError'),await err(plain,'contactEmailError'),await err(plain,'subjectError'),await err(plain,'messageError')].join('|')==='Your name needs 2 to 100 characters.|Enter an email address like name@example.com.|Your subject needs 5 to 150 characters.|Your message needs 20 to 4,000 characters.','No JS: server enforces name 2, email format, subject 5 and message 4,000 limits');
 await name(plain).fill('Sami Khalil');await email(plain).fill('sami@example.com');await subject(plain).fill('Hello');await message(plain).fill('z'.repeat(20));
 await send(plain).click();await plain.waitForLoadState();
 check(await plain.locator('.contact-sent h2').innerText()==='Message sent'&&(await stored()).length===2,'No JS: boundary values (subject 5, message 20) save and confirm');
 await nojs.close();

 // Coordinator compatibility: the saved messages appear in the coordinator inbox.
 const coord=await page.context().browser().newContext({viewport:{width:1440,height:900}});const cp=await coord.newPage();
 await cp.goto(base+'/__fixture.aspx?user=coordinator-one');await cp.goto(base+'/Pages/Coordinator/ContactMessages.aspx');await cp.waitForTimeout(800);
 const inbox=await cp.locator('main').innerText();
 check(/Login problem/.test(inbox)&&/Hello/.test(inbox)&&/rana\.odeh@example\.com/.test(inbox),'Coordinator inbox lists the saved messages');
 await cp.screenshot({path:A+'contact-coordinator-inbox.png'});await coord.close();

 // Reduced motion: no entrance or decorative movement.
 const calm=await page.context().browser().newContext({viewport:{width:1440,height:900},reducedMotion:'reduce'});const still=await calm.newPage();watch(still);await still.goto(url);await still.waitForTimeout(300);
 check(await still.evaluate(()=>getComputedStyle(document.querySelector('.contact-card')).animationName==='none'&&getComputedStyle(document.querySelector('.contact-envelope-letter')).transitionDuration==='0s'&&getComputedStyle(document.querySelector('.contact-intro')).opacity==='1'),'Reduced motion: no entrance, immediate envelope changes');
 await calm.close();

 // Layout across widths; long input wraps without overflow.
 for(const [width,height] of [[1440,900],[768,1024],[390,844],[320,640]]){
  await page.setViewportSize({width,height});await page.goto(url);await page.waitForTimeout(700);
  await email(page).fill('a.very.long.address.for.testing.wrapping.behaviour.on.small.screens@subdomain.example-university.edu');await email(page).blur();
  await message(page).fill('short');await message(page).blur();
  check(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),'No horizontal overflow at '+width);
  if(width<=390){const order=await page.evaluate(()=>['.contact-intro','.contact-card','.contact-figure'].map(s=>document.querySelector(s).getBoundingClientRect().top));check(order[0]<order[1]&&order[1]<order[2],'Phone '+width+': intro, then the form, then the picture');
   check((await send(page).boundingBox()).height>=48&&(await name(page).boundingBox()).height>=48,'Phone '+width+': 48px+ touch targets');}
  await page.screenshot({path:A+'contact-'+width+'-errors.png',fullPage:true});
 }
 check(await page.locator('[data-footer-map]').count()===1&&await page.locator('.uims-public-footer-powered').count()===1,'Footer map and Powered by preserved');
 check(errors.length===0,'No console errors or warnings: '+errors.join(' | '));
 return {passed:checks.length,checks};
 } catch (e) { throw Error(e.message.split(String.fromCharCode(10))[0]+' [after: '+lastPassed+']'); }
}
