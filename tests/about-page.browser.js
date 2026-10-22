async page => {
 // Run against tests/Start-LoginTestHost.ps1 (port 57992). About Us: content, the opening film and its controls,
 // the opening scroll transition, reveals, fallbacks and layout.
 const base='http://localhost:57992',url=base+'/Pages/Public/About.aspx';
 const checks=[];const check=(ok,name)=>{if(!ok)throw Error(name);checks.push(name);};
 const errors=[];const watch=p=>{p.on('pageerror',e=>errors.push(e.message));p.on('console',m=>{if(['error','warning'].includes(m.type()))errors.push(m.text().slice(0,200));});};watch(page);
 const preview=p=>p.locator('[data-film-preview]');
 const playing=p=>preview(p).evaluate(v=>!v.paused);
 await page.setViewportSize({width:1440,height:900});await page.emulateMedia({reducedMotion:'no-preference'});
 const response=await page.goto(url);check(response.status()===200,'About page responds 200');
 await page.waitForTimeout(1500);

 // Structure and accessibility.
 const outline=await page.evaluate(()=>[...document.querySelectorAll('main h1,main h2,main h3')].filter(h=>!h.closest('dialog')).map(h=>+h.tagName[1]));
 check(outline.filter(l=>l===1).length===1&&outline[0]===1&&outline.every((l,i)=>i===0||l<=outline[i-1]+1),'One H1 (in the opening) and no skipped heading levels');
 check(await page.evaluate(()=>[...document.querySelectorAll('main img')].every(i=>i.alt.trim().length>20&&i.getAttribute('width')&&i.getAttribute('height')&&i.loading==='lazy')),'Images described, sized and lazy');
 check(await page.locator('form').count()===1&&await page.locator('form form').count()===0,'Single server form, no nested forms');
 check(await page.evaluate(()=>[...document.querySelectorAll('.about-page button')].every(b=>b.type==='button')),'Page buttons never submit the Web Forms form');

 // Content accuracy.
 const text=await page.locator('main').innerText();
 for(const phrase of ['Discover GJU','Where Learning Meets Experience','Royal Decree in 2005','Established in 2005','Jordanian–German Cooperation','The German Year','Inspiring innovation through applied education.','Diversity, Equity and Inclusion','A Diverse Academic Community','About UIMS','The Journey Through UIMS','coordinator for final approval','Take the Next Step'])check(text.toLowerCase().includes(phrase.toLowerCase()),'Shows "'+phrase+'"');
 check(await page.locator('.about-school-list li').count()===8&&!/Medicine|Social Responsibility/.test(text),'Eight verified schools; only published values');
 check(/not the university’s official portal/.test(text)&&/not every official GJU administrative procedure/.test(text)&&!/Ahmad|Osama/.test(text),'Project not presented as official; team stays on Powered by');
 check(await page.locator('.about-next a[href="/Default.aspx#opportunities"]').count()===1&&await page.locator('.about-next a[href="/Pages/Public/Contact.aspx"]').count()===1,'Closing actions use real routes');

 // Opening: immersive frame under the navbar, muted preview, controls.
 const stage=await page.locator('.about-opening-stage').boundingBox(),nav=await page.locator('.public-header-inner').boundingBox();
 check(stage.y>=nav.y+nav.height-1&&stage.height>=900-96-2,'Film fills the viewport below the navbar ('+Math.round(stage.height)+'px)');
 const pv=await preview(page).evaluate(v=>({muted:v.muted,inline:v.playsInline,poster:!!v.poster,fit:getComputedStyle(v).objectFit,w:v.videoWidth,h:v.videoHeight}));
 check(pv.muted&&pv.inline&&pv.poster&&await playing(page),'Muted inline preview plays on desktop');
 check(pv.w===1280&&pv.h===538&&pv.fit==='cover','Preview is the verified 1280x538 film, filled without distortion');
 const toggle=page.locator('[data-film-toggle]'),sound=page.locator('[data-film-sound]');
 check((await toggle.boundingBox()).width>=44&&await toggle.getAttribute('aria-pressed')==='true'&&/Pause preview/.test(await toggle.innerText()),'Pause control (44px, labelled, pressed state)');
 await toggle.click();await page.waitForTimeout(200);check(!await playing(page)&&await toggle.getAttribute('aria-pressed')==='false','Pause stops the preview');
 await page.evaluate(()=>scrollTo({top:2600,behavior:'instant'}));await page.waitForTimeout(600);await page.evaluate(()=>scrollTo({top:0,behavior:'instant'}));await page.waitForTimeout(800);
 check(!await playing(page),'A paused preview is not restarted after scrolling away and back');
 await toggle.click();await page.waitForTimeout(300);check(await playing(page),'Play resumes the preview');
 await sound.click();await page.waitForTimeout(200);check(!await preview(page).evaluate(v=>v.muted)&&await sound.getAttribute('aria-pressed')==='true','Sound control turns sound on');
 await sound.click();check(await preview(page).evaluate(v=>v.muted),'Sound control turns sound off');
 // Lifecycle: a hidden tab or leaving the screen pauses it; it comes back only when we were the ones who paused it.
 await page.evaluate(()=>{Object.defineProperty(document,'hidden',{configurable:true,get:()=>true});document.dispatchEvent(new Event('visibilitychange'));});
 check(!await playing(page),'Hidden tab pauses the preview');
 await page.evaluate(()=>{Object.defineProperty(document,'hidden',{configurable:true,get:()=>false});document.dispatchEvent(new Event('visibilitychange'));});await page.waitForTimeout(300);
 check(await playing(page),'Visible tab resumes a system-paused preview');
 await page.evaluate(()=>scrollTo({top:2600,behavior:'instant'}));await page.waitForTimeout(600);check(!await playing(page),'Off-screen preview pauses');
 await page.evaluate(()=>scrollTo({top:0,behavior:'instant'}));await page.waitForTimeout(800);check(await playing(page),'Back on screen it resumes');

 // Full film: uncropped, native controls, sound, focus returns.
 const play=page.locator('[data-film-open]');check(/Play university film/.test(await play.innerText())&&/\.mp4$/.test(await play.getAttribute('href')),'Play university film (links to the file without script)');
 await play.focus();await page.keyboard.press('Enter');await page.waitForTimeout(1500);
 const full=await page.locator('[data-film-full]').evaluate(v=>({open:v.closest('dialog').open,controls:v.controls,fit:getComputedStyle(v).objectFit,t:v.currentTime,muted:v.muted,paused:v.paused}));
 check(full.open&&full.controls&&full.fit==='contain'&&full.t>.3&&!full.muted&&!full.paused,'Keyboard opens the full film: native controls, uncropped, with sound ('+JSON.stringify(full)+')');
 check(!await playing(page),'Preview pauses while the full film is open');
 await page.screenshot({path:'tests/artifacts/about-film-dialog-1440.png'});
 await page.keyboard.press('Escape');await page.waitForTimeout(300);
 check(!await page.locator('[data-film-dialog]').evaluate(d=>d.open)&&await page.locator('[data-film-full]').evaluate(v=>v.paused)&&await page.evaluate(()=>document.activeElement.hasAttribute('data-film-open')),'Escape closes the film, pauses it and returns focus');
 await page.waitForTimeout(300);check(await playing(page),'Preview resumes after the film closes');

 // Opening scroll transition: hold, lift the text, inset the frame, release without a gap, reverse.
 const probe=()=>page.evaluate(()=>{const o=document.querySelector('[data-film]'),s=o.querySelector('.about-opening-stage').getBoundingClientRect(),m=new DOMMatrix(getComputedStyle(o.querySelector('[data-film-frame]')).transform);
  return {y:scrollY,scale:m.a,copy:+getComputedStyle(o.querySelector('[data-opening-copy]')).opacity,stageTop:s.top,stageBottom:s.bottom,next:document.getElementById('discover-gju').getBoundingClientRect().top};});
 const runway=await page.evaluate(()=>{const o=document.querySelector('[data-film]');return o.offsetHeight-o.querySelector('.about-opening-stage').offsetHeight;});
 check(runway>=.6*900&&runway<=.9*900,'Opening runway about 75vh ('+runway+'px)');
 await page.mouse.move(700,500);
 const hold=[];for(let i=0;i<2;i++){await page.mouse.wheel(0,90);await page.waitForTimeout(400);hold.push(await probe());}
 check(hold.every(p=>p.scale>.999&&p.copy>.99&&Math.abs(p.stageTop-96)<1),'First part holds the film still under the navbar');
 for(let i=0;i<6;i++){await page.mouse.wheel(0,90);await page.waitForTimeout(250);}await page.waitForTimeout(700);
 const end=await probe();check(Math.abs(end.scale-.9)<.01&&end.copy<.02,'Text lifts away; frame settles inset ('+end.scale.toFixed(3)+')');
 await page.mouse.wheel(0,200);await page.waitForTimeout(600);const released=await probe();
 check(released.stageTop<96&&Math.abs(released.stageBottom-released.next)<=1,'Pin releases with no gap or overlap');
 await page.screenshot({path:'tests/artifacts/about-opening-released-1440.png'});
 for(let i=0;i<12;i++){await page.mouse.wheel(0,-100);await page.waitForTimeout(150);}await page.waitForTimeout(800);
 const back=await probe();check(back.y===0&&back.scale>.999&&back.copy>.99,'Transition reverses when scrolling up');
 // Fast scroll through the whole page: every reveal ends visible, the journey line completes.
 for(let y=0;y<9000;y+=700){await page.evaluate(y=>scrollTo({top:y,behavior:'instant'}),y);await page.waitForTimeout(90);}await page.waitForTimeout(1200);
 check(await page.evaluate(()=>[...document.querySelectorAll('[data-reveal]')].every(e=>e.classList.contains('is-revealed')&&getComputedStyle(e).opacity==='1')),'All reveals complete after a fast scroll');
 check(await page.locator('[data-journey-line]').evaluate(l=>new DOMMatrix(getComputedStyle(l).transform).a>.99),'Journey line completes');
 check(await preview(page).evaluate(v=>v.paused),'Preview paused far down the page');
 // Arriving through an anchor lands below the navbar despite the runway.
 await page.goto(url+'#about-uims');await page.waitForTimeout(1500);
 const anchored=await page.evaluate(()=>document.getElementById('about-uims').getBoundingClientRect().top);check(anchored>=95&&anchored<=130,'Anchor load lands on its section ('+Math.round(anchored)+'px)');
 await page.goto(url);await page.waitForTimeout(800);
 await page.getByRole('link',{name:/Explore our story/}).click();await page.waitForTimeout(1500);
 const cue=await page.evaluate(()=>document.getElementById('discover-gju').getBoundingClientRect().top);check(cue>=95&&cue<=130,'Explore our story is a working anchor ('+Math.round(cue)+'px)');

 // Layout across widths.
 for(const [width,height] of [[1440,900],[1024,768],[768,1024],[390,844],[320,640]]){
  await page.setViewportSize({width,height});await page.waitForTimeout(400);
  check(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),'No horizontal overflow at '+width);
 }
 check(await page.locator('[data-footer-map]').count()===1&&await page.locator('.uims-public-footer-powered').count()===1,'Footer map and Powered by preserved');

 // Phone: the film keeps its own frame, no autoplay, touch scrolling works, the journey is vertical.
 const phoneCtx=await page.context().browser().newContext({viewport:{width:390,height:844},hasTouch:true,isMobile:true});const phone=await phoneCtx.newPage();watch(phone);
 await phone.goto(url);await phone.waitForTimeout(1500);
 const frame=await phone.locator('[data-film-frame]').boundingBox();
 check(Math.abs(frame.width/frame.height-1280/538)<.02&&!await phone.locator('[data-film]').evaluate(o=>o.classList.contains('is-sequenced')),'Phone: uncropped 2.38:1 film, no pinned sequence');
 check(!await playing(phone)&&(await phone.locator('[data-film-toggle]').boundingBox()).height>=44,'Phone: no autoplay; 44px controls');
 await phone.screenshot({path:'tests/artifacts/about-opening-390.png'});
 const cdp=await phoneCtx.newCDPSession(phone);// A real finger drag (touch events); synthesizeScrollGesture is a no-op in this headless build on every page.
 await cdp.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[{x:200,y:700}]});for(let i=1;i<=10;i++)await cdp.send('Input.dispatchTouchEvent',{type:'touchMove',touchPoints:[{x:200,y:700-i*50}]});await cdp.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[]});await phone.waitForTimeout(800);const touched=await phone.evaluate(()=>scrollY);
 check(touched>900,'Touch scrolling moves the page ('+Math.round(touched)+'px)');
 const xs=await phone.locator('.about-steps li').evaluateAll(l=>l.map(e=>Math.round(e.getBoundingClientRect().left)));check(new Set(xs).size===1,'Phone journey is vertical');
 await phone.evaluate(()=>scrollTo({top:0,behavior:'instant'}));await phone.waitForTimeout(300);await phone.locator('[data-film-toggle]').tap();await phone.waitForTimeout(1500);check(await playing(phone),'Phone: tapping Play starts the preview');
 await phoneCtx.close();

 // Reduced motion: no pinning, no autoplay, everything static and visible.
 const calm=await page.context().browser().newContext({viewport:{width:1440,height:900},reducedMotion:'reduce'});const still=await calm.newPage();watch(still);await still.goto(url);await still.waitForTimeout(1500);
 check(!await still.locator('[data-film]').evaluate(o=>o.classList.contains('is-sequenced'))&&!await playing(still),'Reduced motion: no pinned sequence and no autoplay');
 check(await still.evaluate(()=>[...document.querySelectorAll('[data-reveal]')].every(e=>getComputedStyle(e).opacity==='1'&&getComputedStyle(e).transform==='none')),'Reduced motion: all content static and visible');
 await calm.close();

 const before=errors.length;
 // Script failure: content shows anyway (the inline guard drops the pre-hide after 3 s).
 const broken=await page.context().browser().newContext({viewport:{width:1440,height:900}});await broken.route('**/about.js*',r=>r.abort());const b=await broken.newPage();await b.goto(url);await b.waitForTimeout(3600);
 check(await b.evaluate(()=>!document.documentElement.classList.contains('about-motion')&&[...document.querySelectorAll('[data-reveal]')].every(e=>getComputedStyle(e).opacity==='1')),'about.js blocked: all content visible');await broken.close();
 const nojs=await page.context().browser().newContext({javaScriptEnabled:false,viewport:{width:1440,height:900}});const plain=await nojs.newPage();await plain.goto(url);
 check(await plain.evaluate(()=>[...document.querySelectorAll('[data-reveal]')].every(e=>getComputedStyle(e).opacity==='1'))&&await plain.locator('[data-film-open]').isVisible(),'Without JavaScript: content visible, film link available');await nojs.close();
 // Film unavailable: status message, controls disabled, the file link remains.
 const blocked=await page.context().browser().newContext({viewport:{width:1440,height:900}});await blocked.route('**/*.mp4',r=>r.abort());const bl=await blocked.newPage();await bl.goto(url);await bl.waitForTimeout(2500);
 check(/could not be loaded/.test(await bl.locator('[data-film-status]').innerText())&&await bl.locator('[data-film-toggle]').isDisabled(),'Unavailable film reports an error');await blocked.close();
 check(errors.slice(0,before).length===0,'No console errors or warnings: '+errors.join(' | '));
 return {passed:checks.length,checks};
}
