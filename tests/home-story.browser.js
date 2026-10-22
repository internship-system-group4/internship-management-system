async page => {
 const base='http://localhost:57983';let checks=0;const errors=[];
 const check=(ok,m)=>{if(!ok)throw Error(m);checks++;};
 page.on('pageerror',e=>errors.push(e.message));page.on('console',m=>{if(m.type()==='error')errors.push(m.text());});
 const ready=()=>page.waitForFunction(()=>{const a=document.querySelector('[data-story-figure]')?.universityStory;return a&&a.snapshot().draws>0;});
 const snap=()=>page.evaluate(()=>document.querySelector('[data-story-figure]').universityStory.snapshot());
 await page.context().clearCookies();await page.emulateMedia({reducedMotion:'no-preference'});await page.setViewportSize({width:1440,height:1000});
 await page.goto(base+'/Default.aspx');await ready();
 check(await page.locator('[data-story-viewport] canvas').count()===1,'Actual 3D canvas mounted');
 check(await page.locator('[data-courtyard]').count()===0,'Waterwheel replaced in Home');
 check(await page.locator('.public-brand img').first().isVisible(),'Official HTML logo visible');
 check(await page.locator('#home-title').isVisible()&&await page.locator('.home-story-opening .public-button').isVisible(),'HTML headline and login action');
 check((await snap()).triggerActive,'GSAP ScrollTrigger active on desktop');
 const flags=await page.evaluate(()=>{
  const flags=document.querySelector('[data-story-figure]').universityStory.model.flags;
  return flags.map(f=>{
   const c=f.mesh.material.map.image,ctx=c.getContext('2d');const at=(u,v)=>Array.from(ctx.getImageData(Math.floor(u*c.width),Math.floor(v*c.height),1,1).data).slice(0,3);
   let tips=0;
   if(f.country==='jordan'){
    const cx=c.width/2*c.height/(c.height+2*Math.hypot(c.width/2,c.height/2)),cy=c.height/2,r=c.width/28*.8;
    const white=[];for(let i=0;i<720;i++){let a=i*Math.PI*2/720;const p=ctx.getImageData(Math.round(cx+Math.cos(a)*r),Math.round(cy+Math.sin(a)*r),1,1).data;white.push(p[0]>235&&p[1]>235&&p[2]>235);}
    for(let i=0;i<720;i++)if(white[i]&&!white[(i+719)%720])tips++;
   }
   return {country:f.country,ratio:f.width/f.height,colors:[at(.8,.15),at(.8,.5),at(.8,.85)],tips};
  });
 });
 const jordan=flags.find(f=>f.country==='jordan'),germany=flags.find(f=>f.country==='germany');
 check(Math.abs(jordan.ratio-2)<.001&&Math.abs(germany.ratio-5/3)<.001,'National flag proportions');
 check(JSON.stringify(jordan.colors)==='[[0,0,0],[255,255,255],[0,122,61]]','Jordan actual texture stripe colors');
 check(jordan.tips===7,'Jordan actual texture has seven star tips');
 check(JSON.stringify(germany.colors)==='[[0,0,0],[221,0,0],[255,206,0]]','German actual texture stripe colors');
 const hoist=()=>page.evaluate(()=>document.querySelector('[data-story-figure]').universityStory.model.flags.map(f=>{const a=f.mesh.geometry.attributes.position;return Array.from({length:a.count},(_,i)=>i).filter(i=>Math.abs(a.getX(i)+f.width/2)<.001).map(i=>[a.getX(i),a.getY(i),a.getZ(i)]);}));
 let a=await snap(),pinned=await hoist();await page.waitForTimeout(200);let b=await snap();
 check(b.time>a.time,'Continuous cloth movement');check(JSON.stringify(pinned)===JSON.stringify(await hoist()),'Cloth hoist remains attached');
 const fixed=()=>page.evaluate(()=>document.querySelector('[data-story-figure]').universityStory.model.parts.get('limestone-portal').matrixWorld.elements.slice());
 const architecture=await fixed();
 await page.locator('[data-story-toggle]').click();a=await snap();await page.waitForTimeout(150);b=await snap();
 check(a.time===b.time&&a.draws===b.draws,'Pause stops continuous motion/render loop');
 check(await page.locator('[data-story-toggle]').getAttribute('aria-pressed')==='true','Pause state exposed');
 await page.evaluate(()=>scrollTo(0,440));await page.waitForFunction(()=>document.querySelector('[data-story-figure]').universityStory.snapshot().progress>.98);
 b=await snap();check(b.camera[1]<a.camera[1]-3,'Scroll descends camera toward gate');
 check(b.time===a.time&&b.draws>a.draws,'Paused flags allow user-driven camera transition');
 check(JSON.stringify(await fixed())===JSON.stringify(architecture),'Gate remains spatially fixed');
 await page.setViewportSize({width:390,height:900});await page.waitForFunction(()=>document.querySelector('[data-story-figure]').universityStory.snapshot().targetMode==='overview');
 check(!(await snap()).triggerActive,'Resize at gate releases desktop scroll tween');
 await page.setViewportSize({width:1440,height:1000});await page.waitForFunction(()=>document.querySelector('[data-story-figure]').universityStory.snapshot().progress>.98);
 check((await snap()).triggerActive,'Resize back restores gate scroll position');
 await page.evaluate(()=>scrollTo(0,0));await page.waitForFunction(()=>document.querySelector('[data-story-figure]').universityStory.snapshot().progress<.01);
 check((await snap()).camera[1]>9,'Reverse scroll returns to flags');
 await page.locator('[data-story-toggle]').focus();await page.keyboard.press('Space');check((await snap()).running,'Keyboard resumes flag motion');
 await page.locator('.home-jump-nav a[href="#colleges"]').click();check(new URL(page.url()).hash==='#colleges','Direct colleges navigation');
 const summary=page.locator('#computing-college summary');await summary.focus();await page.keyboard.press('Enter');
 check(await page.locator('#computing-college').evaluate(e=>e.open),'Keyboard opens college');
 check(await page.locator('.home-programs').isVisible(),'Programs revealed');
 check(await page.locator('.home-college').count()===1,'Only configured college');
 check(await page.locator('.home-program h3').allTextContents().then(x=>x.join('|')==='Computer Engineering|Computer Science'),'Configured programs only');
 check((await page.locator('.home-programs').innerText()).includes('Cyber Security')&&(await page.locator('.home-programs').innerText()).includes('Computer Vision and Robotics'),'Configured specializations');
 check(!(await page.locator('#colleges').innerText()).includes('Medicine'),'No invented college');
 await page.waitForFunction(()=>!!document.querySelector('[data-college-symbol]').collegeSymbol);check(await page.locator('[data-college-symbol] canvas').count()===1,'Lightweight 3D computing symbol');
 await summary.focus();await page.keyboard.press('Space');check(!(await page.locator('#computing-college').evaluate(e=>e.open)),'Keyboard closes college');
 for(const id of ['internship-video','opportunities']){
  await page.evaluate(()=>scrollTo(0,0));await page.locator('.home-jump-nav a[href="#'+id+'"]').click();check(new URL(page.url()).hash==='#'+id,'Direct '+id+' navigation');
 }
 await page.locator('#internship-video').scrollIntoViewIfNeeded();await page.waitForFunction(()=>!document.querySelector('[data-story-figure]').universityStory.snapshot().visible);
 a=await snap();await page.waitForTimeout(150);b=await snap();check(a.draws===b.draws&&a.time===b.time,'Offscreen scene stops while reading/watching video');
 const video=page.locator('.home-process-video');let videoStatus;
 if(await video.count()) {check(await video.getAttribute('controls')!==null&&!!await video.getAttribute('poster'),'Video controls and poster');videoStatus='Native control/poster attributes checked; actual playback requires supplied media.';}
 else {check((await page.locator('.home-video-placeholder').innerText()).includes('official video pending'),'Explicit missing-video placeholder');videoStatus='Official video/captions missing; playback could not be tested.';}
 check(await page.locator('.home-steps li').count()===4,'Four existing internship stages retained');
 await page.evaluate(()=>scrollTo(0,0));await page.waitForFunction(()=>document.querySelector('[data-story-figure]').universityStory.snapshot().visible);
 await page.evaluate(()=>{Object.defineProperty(document,'hidden',{configurable:true,get:()=>true});document.dispatchEvent(new Event('visibilitychange'));});
 a=await snap();await page.waitForTimeout(120);check(!(await snap()).running&&(await snap()).draws===a.draws,'Hidden-document handler stops render loop');
 await page.evaluate(()=>{delete document.hidden;document.dispatchEvent(new Event('visibilitychange'));});
 await page.emulateMedia({reducedMotion:'reduce'});await page.waitForFunction(()=>{const s=document.querySelector('[data-story-figure]').universityStory.snapshot();return !s.triggerActive&&s.reduced&&s.camera[1]===6.5;});
 a=await snap();await page.waitForTimeout(150);b=await snap();check(!b.running&&a.time===b.time&&!b.triggerActive,'Reduced motion is static and removes scroll tween');
 await page.evaluate(()=>scrollTo(0,400));await page.waitForTimeout(100);check(JSON.stringify(a.camera)===JSON.stringify((await snap()).camera),'Reduced-motion camera remains static');
 await page.emulateMedia({reducedMotion:'no-preference'});await page.goto(base+'/Default.aspx');await ready();
 for(const width of [320,390,768,1440,2560]){
  await page.setViewportSize({width,height:1000});await page.waitForTimeout(100);
  check(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1),'No horizontal overflow '+width);
  const s=await snap();check(s.width<=1200&&s.height<=1000,'Canvas buffer cap '+width);
  check(s.targetMode===(width<=820?'overview':'scroll'),'Responsive scene mode '+width);
 }
 await page.setViewportSize({width:390,height:900});await page.evaluate(()=>scrollTo(0,0));await page.screenshot({path:'tests/artifacts/story-mobile-final.png'});
 await page.locator('#colleges').scrollIntoViewIfNeeded();await page.locator('#computing-college summary').click();await page.evaluate(()=>scrollTo(0,document.querySelector('#colleges').getBoundingClientRect().top+scrollY-24));await page.screenshot({path:'tests/artifacts/story-colleges-mobile.png'});
 await page.setViewportSize({width:1440,height:1000});await page.goto(base+'/Default.aspx');await ready();await page.locator('[data-story-toggle]').click();await page.screenshot({path:'tests/artifacts/story-flags-final.png'});await page.evaluate(()=>scrollTo(0,420));await page.waitForTimeout(500);await page.screenshot({path:'tests/artifacts/story-gate-final.png'});
 await page.locator('#computing-college summary').click();await page.evaluate(()=>scrollTo(0,document.querySelector('#colleges').getBoundingClientRect().top+scrollY-24));await page.screenshot({path:'tests/artifacts/story-colleges-final.png'});
 await page.goto(base+'/Pages/Student/OpportunityDetails.aspx?id=internship-one');check(page.url().includes('/Account/Login.aspx'),'Anonymous full details denied on server');
 await page.goto(base+'/Pages/Student/Apply.aspx?opportunityId=internship-one');check(page.url().includes('/Account/Login.aspx'),'Anonymous application denied on server');
 await page.goto(base+'/Default.aspx');await ready();await page.evaluate(()=>document.querySelector('[data-story-figure]').universityStory.dispose());a=await snap();await page.waitForTimeout(120);b=await snap();
 check(a.state==='disposed'&&a.draws===b.draws&&!b.triggerActive,'Disposal kills animation and ScrollTrigger');
 check(b.textures===0&&b.geometries===0&&await page.locator('[data-story-viewport] canvas').count()===0,'GPU resources and canvas released');
 const browser=page.context().browser();
 const c1=await browser.newContext({viewport:{width:390,height:900},deviceScaleFactor:3});const p1=await c1.newPage();await p1.goto(base+'/Default.aspx');await p1.waitForFunction(()=>!!document.querySelector('[data-story-figure]')?.universityStory);
 check(await p1.evaluate(()=>document.querySelector('[data-story-viewport] canvas').width<=document.querySelector('[data-story-viewport]').clientWidth*1.5+1),'High DPR is capped');
 await p1.evaluate(()=>document.querySelector('[data-story-viewport] canvas').getContext('webgl2').getExtension('WEBGL_lose_context').loseContext());await p1.waitForFunction(()=>document.querySelector('[data-story-figure]').dataset.sceneState==='fallback');check(await p1.locator('.home-story-photo').isVisible(),'WebGL context loss photo fallback');await p1.screenshot({path:'tests/artifacts/story-fallback-mobile.png'});await c1.close();
 const c2=await browser.newContext();const p2=await c2.newPage();await p2.addInitScript(()=>{const original=HTMLCanvasElement.prototype.getContext;HTMLCanvasElement.prototype.getContext=function(kind,...args){return /^webgl/.test(kind)?null:original.call(this,kind,...args);};});await p2.goto(base+'/Default.aspx');await p2.waitForFunction(()=>document.querySelector('[data-story-figure]').dataset.sceneState==='fallback');check(await p2.locator('.home-story-photo').isVisible(),'Unavailable WebGL fallback');check(await p2.locator('.home-story-opening .public-button').isVisible(),'Fallback retains HTML action');await c2.close();
 const c3=await browser.newContext();const p3=await c3.newPage();await p3.route('**/ScrollTrigger.min.js',r=>r.abort());await p3.goto(base+'/Default.aspx');await p3.waitForFunction(()=>document.querySelector('[data-story-figure]').dataset.sceneState==='fallback');check(await p3.locator('.home-story-photo').isVisible(),'Failed animation dependency fallback');await c3.close();
 const c4=await browser.newContext({javaScriptEnabled:false,viewport:{width:390,height:900}});const p4=await c4.newPage();await p4.goto(base+'/Default.aspx');check(await p4.locator('.home-story-photo').isVisible(),'No-JS reference image');await p4.locator('#computing-college summary').click();check(await p4.locator('.home-programs').isVisible(),'College selection works without JavaScript');check((await p4.locator('.home-programs').innerText()).includes('Data Science'),'All specialization content available without 3D');await c4.close();
 check(errors.length===0,'Unexpected browser/console errors: '+errors.join(';'));
 await page.setViewportSize({width:1440,height:1000});await page.goto(base+'/Default.aspx');await ready();
 return {passed:checks,errors,videoStatus,viewports:[320,390,768,1440,2560],hiddenTest:'Deterministic hidden getter/visibilitychange; offscreen check uses real scroll.'};
}
