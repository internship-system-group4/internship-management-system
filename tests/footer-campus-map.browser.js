async page => {
 // Run against tests/Start-LoginTestHost.ps1 (port 57992). Needs network access to tiles.openfreemap.org.
 const url='http://localhost:57992/Pages/Public/About.aspx';
 const checks=[];const check=(ok,name)=>{if(!ok)throw Error(name);checks.push(name);};
 const errors=[];const watch=p=>{p.on('pageerror',e=>errors.push(e.message));p.on('console',m=>{if(['error','warning'].includes(m.type())&&!/Campus map: showing/.test(m.text()))errors.push(m.text().slice(0,200));});};watch(page);
 const state=p=>p.locator('[data-footer-map]').getAttribute('data-footer-map-state');
 const until=(p,s,timeout=25000)=>p.waitForFunction(s=>document.querySelector('[data-footer-map]').dataset.footerMapState===s,s,{timeout});
 const stage=p=>p.locator('[data-footer-map-stage]');
 await page.setViewportSize({width:1440,height:900});await page.emulateMedia({reducedMotion:'no-preference'});
 await page.goto(url);
 check(await state(page)==='idle'&&await page.locator('[data-footer-map-embed]').count()===0,'Enhanced map waits off-screen; embed held back');
 check(!(await page.evaluate(()=>[...document.scripts].some(s=>/maplibre/.test(s.src))))&&await page.locator('canvas.maplibregl-canvas').count()===0,'Map runtime not loaded at page load');
 // Geometry: a 280 x 180 map in the right-hand column, link columns to its left, above the copyright row.
 const box=await stage(page).boundingBox(),bottom=await page.locator('.uims-public-footer-bottom').boundingBox(),grid=await page.locator('.uims-public-footer-grid').boundingBox();
 check(Math.round(box.width)===280&&Math.round(box.height)===180&&Math.abs(box.x+box.width-(bottom.x+bottom.width))<=1&&grid.x+grid.width<box.x&&box.y+box.height<bottom.y,'Compact 280x180 map right-aligned beside the footer links');
 check(await page.evaluate(()=>{const s=document.querySelector('.uims-public-footer-campus').getBoundingClientRect();return s.width===280&&s.height<300;}),'Location column stays compact');
 // Flight: plays once on arrival, about four seconds, marker and controls only at the end.
 await stage(page).scrollIntoViewIfNeeded();await until(page,'flying');const t0=Date.now();
 check(await page.locator('.uims-campus-marker').count()===0&&!await page.locator('[data-footer-map-directions]').evaluate(a=>getComputedStyle(a).opacity==='1'),'Marker and controls held back during the flight');
 await until(page,'done',12000);const took=Date.now()-t0;
 check(took>3500&&took<6000,'Descent lasts about four seconds ('+took+' ms)');
 check((await page.locator('.uims-campus-marker').innerText()).trim()==='German Jordanian University','Campus marker labelled German Jordanian University');
 await page.waitForTimeout(400); // MapLibre positions a new marker on its next render.
 const marker=await page.locator('.uims-campus-marker i').boundingBox(),sb=await stage(page).boundingBox();
 check(marker.x>sb.x+sb.width*.3&&marker.x<sb.x+sb.width*.7&&marker.y>sb.y+sb.height*.25&&marker.y<sb.y+sb.height*.75,'Campus marker framed near the centre');
 const directions=page.locator('[data-footer-map-directions]');
 check(await directions.getAttribute('href')==='https://www.google.com/maps/dir/?api=1&destination=31.776843,35.802555'&&await directions.getAttribute('target')==='_blank'&&await directions.getAttribute('rel')==='noopener noreferrer'&&await directions.isVisible(),'Get directions to the verified campus');
 check(await page.locator('[data-footer-map-replay]').isVisible(),'Replay flight offered');
 // Attribution is a collapsed (i) toggle; its text stays in the control.
 const attribution=await page.locator('.maplibregl-ctrl-attrib').textContent();check(/OpenStreetMap/.test(attribution)&&/OpenFreeMap/.test(attribution),'Map data attribution present (compact toggle)');
 // Not replayed by scrolling away and back.
 await page.mouse.wheel(0,-900);await page.waitForTimeout(400);await stage(page).scrollIntoViewIfNeeded();await page.waitForTimeout(700);
 check(await state(page)==='done','Scrolling back does not replay the flight');
 // Wheel over the map scrolls the page (zoom needs Ctrl until the map is activated).
 const before=await page.evaluate(()=>scrollY);await page.mouse.move(sb.x+sb.width/2,sb.y+sb.height/2);await page.mouse.wheel(0,-300);await page.waitForTimeout(400);
 check(await page.evaluate(()=>scrollY)<before,'Mouse wheel over the map scrolls the page');
 // Replay, then interrupt by dragging.
 await stage(page).scrollIntoViewIfNeeded();await page.locator('[data-footer-map-replay]').click();await until(page,'flying');await page.waitForTimeout(800);
 const c=await stage(page).boundingBox();await page.mouse.move(c.x+c.width/2,c.y+c.height/2);await page.mouse.down();await page.mouse.move(c.x+c.width/2+80,c.y+c.height/2+30,{steps:5});await page.mouse.up();
 await until(page,'done',3000);check(await page.locator('.uims-campus-marker').count()===1,'Dragging interrupts the flight and hands over the map');
 await stage(page).screenshot({path:'tests/artifacts/footer-campus-final-1440.png'});
 // Leaving mid-flight lands the camera instead of animating unseen.
 await page.locator('[data-footer-map-replay]').click();await until(page,'flying');await page.evaluate(()=>scrollTo(0,0));
 await until(page,'done',3000);check(true,'Leaving the viewport mid-flight lands the camera');
 // Phone: 260-320px, touch scrolling stays with the page (two fingers to pan the map).
 const phone=await page.context().browser().newContext({viewport:{width:390,height:844},hasTouch:true,isMobile:true});const mobile=await phone.newPage();watch(mobile);
 await mobile.goto(url);await stage(mobile).scrollIntoViewIfNeeded();await until(mobile,'done',25000);
 const mbox=await stage(mobile).boundingBox();const mgrid=await mobile.locator('.uims-public-footer-grid').boundingBox();check(Math.round(mbox.width)===280&&Math.round(mbox.height)===180&&mbox.y>mgrid.y+mgrid.height,'Phone map stacks below the links at 280x180');
 check(await mobile.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),'No horizontal overflow on phones');
 check(await mobile.evaluate(()=>{const m=document.querySelector('.maplibregl-canvas-container');return !!m&&getComputedStyle(document.querySelector('.maplibregl-canvas')).touchAction!=='none';}),'Touch panning is cooperative (page keeps one-finger scrolling)');
 await stage(mobile).screenshot({path:'tests/artifacts/footer-campus-final-390.png'});
 await phone.close();
 for(const width of [1024,768,320]){await page.setViewportSize({width,height:900});await page.waitForTimeout(200);check(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),'No horizontal overflow at '+width);}
 check(await page.evaluate(()=>{const c=document.querySelector('canvas.maplibregl-canvas'),s=document.querySelector('[data-footer-map-canvas]');return Math.abs(c.clientWidth-s.clientWidth)<=1&&Math.abs(c.clientHeight-s.clientHeight)<=1;}),'Map renderer follows its container size at 320px');
 // Reduced motion: final view straight away, no replay offer.
 const calm=await page.context().browser().newContext({viewport:{width:1440,height:900},reducedMotion:'reduce'});const still=await calm.newPage();watch(still);
 await still.goto(url);await stage(still).scrollIntoViewIfNeeded();await until(still,'done',25000);
 check(await still.locator('.uims-campus-marker').count()===1&&await still.locator('[data-footer-map-replay]').isHidden(),'Reduced motion shows the final campus view without a flight');
 await calm.close();
 const before2=errors.length;
 // Fallbacks keep a real campus map and the directions link.
 for(const [label,setup] of [['WebGL unavailable',ctx=>ctx.addInitScript(()=>{const o=HTMLCanvasElement.prototype.getContext;HTMLCanvasElement.prototype.getContext=function(t,...a){return /webgl/.test(t)?null:o.call(this,t,...a);};})],
                             ['Map style unreachable',ctx=>ctx.route('**/tiles.openfreemap.org/**',r=>r.abort())],
                             ['Map runtime blocked',ctx=>ctx.route('**/maplibre-gl.mjs*',r=>r.abort())]]){
  const ctx=await page.context().browser().newContext({viewport:{width:1440,height:900}});await setup(ctx);const p=await ctx.newPage();
  await p.goto(url);await stage(p).scrollIntoViewIfNeeded();await until(p,'fallback',25000);
  check(await p.locator('[data-footer-map-embed]').isVisible()&&(await p.locator('[data-footer-map-embed]').getAttribute('src')).startsWith('https://www.google.com/maps/embed?')&&await p.locator('[data-footer-map-directions]').isVisible(),label+': standard campus map and directions remain');
  await ctx.close();
 }
 const nojs=await page.context().browser().newContext({javaScriptEnabled:false,viewport:{width:1440,height:900}});const plain=await nojs.newPage();
 await plain.goto(url);check(await plain.locator('[data-footer-map-embed]').count()===1&&await plain.locator('[data-footer-map-directions]').isVisible(),'Without JavaScript the standard map and directions show');
 await nojs.close();
 check(await page.locator('.uims-public-footer-powered').isVisible()&&await page.locator('.uims-public-footer-wave').count()===3,'Waves and Powered by preserved');
 check(errors.slice(0,before2).length===0,'No console errors or warnings: '+errors.join(' | '));
 return {passed:checks.length,checks};
}
