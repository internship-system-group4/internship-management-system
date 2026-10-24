async page => {
 // Login 3D scene performance: cold/warm cache, desktop and throttled phone, measured through the Chrome DevTools Protocol.
 // Reports transferred bytes by type, form-ready and first-3D-frame times, main-thread long tasks during loading, input delay
 // while typing during loading, idle frame timing, and the scene's draw calls. Read-only; no sign-in.
 // Run against tests/Start-LoginTestHost.ps1 (headless Chromium; numbers are relative between runs on the same machine).
 const base='http://localhost:57994', path='/Pages/Account/Login.aspx', results={};
 const profiles={
  desktop:{viewport:{width:1440,height:900},cpu:1,net:null},
  'phone-throttled':{viewport:{width:390,height:844},isMobile:true,hasTouch:true,cpu:4,net:{latency:150,downloadThroughput:1.6e6/8,uploadThroughput:.75e6/8}}
 };
 async function run(name,profile){
  const ctx=await page.context().browser().newContext({viewport:profile.viewport,isMobile:!!profile.isMobile,hasTouch:!!profile.hasTouch});
  const p=await ctx.newPage();const cdp=await ctx.newCDPSession(p);
  await cdp.send('Network.enable');if(profile.net)await cdp.send('Network.emulateNetworkConditions',{offline:false,...profile.net});
  if(profile.cpu>1)await cdp.send('Emulation.setCPUThrottlingRate',{rate:profile.cpu});
  await p.addInitScript(()=>{
   window.__perf={long:[],inputs:[]};
   new PerformanceObserver(list=>{for(const e of list.getEntries())window.__perf.long.push([e.startTime,e.duration]);}).observe({type:'longtask',buffered:true});
   new MutationObserver(()=>{const r=document.querySelector('[data-login-campus]');if(r&&r.dataset.sceneReady&&!window.__perf.ready)window.__perf.ready=performance.now();if(r&&r.dataset.sceneFallback&&!window.__perf.fallback)window.__perf.fallback=performance.now();})
    .observe(document,{subtree:true,attributes:true,attributeFilter:['data-scene-ready','data-scene-fallback']});
   document.addEventListener('input',e=>{const t=e.timeStamp;requestAnimationFrame(()=>window.__perf.inputs.push(performance.now()-t));},true);
  });
  const sizes=new Map(),types=new Map();
  cdp.on('Network.responseReceived',e=>types.set(e.requestId,{url:e.response.url,type:e.type,enc:e.response.headers['content-encoding']||e.response.headers['Content-Encoding']||'',cache:e.response.headers['cache-control']||e.response.headers['Cache-Control']||'',status:e.response.status}));
  cdp.on('Network.loadingFinished',e=>sizes.set(e.requestId,e.encodedDataLength));
  const one=async label=>{
   sizes.clear();types.clear();
   await p.goto(base+path,{waitUntil:'domcontentloaded'});
   const formReady=await p.evaluate(()=>performance.now());
   // Type while the scene is still loading; record per-keystroke input-to-next-frame delay.
   await p.locator('input[type=email]').click();await p.keyboard.type('student@campus.test',{delay:40});
   await p.waitForFunction(()=>window.__perf.ready||window.__perf.fallback,null,{timeout:120000}).catch(()=>{});
   const perf=await p.evaluate(()=>window.__perf);
   // Idle frame timing for 4 s after the scene is up.
   const frames=await p.evaluate(()=>new Promise(res=>{const d=[];let last=0;const end=performance.now()+4000;function f(t){if(last)d.push(t-last);last=t;if(t<end)requestAnimationFrame(f);else res(d);}requestAnimationFrame(f);}));
   frames.sort((a,b)=>a-b);
   const byType={};let total=0;const assets=[];
   for(const [id,bytes] of sizes){const t=types.get(id);if(!t)continue;total+=bytes;const k=/\.glb/.test(t.url)?'model':/\.(png|jpe?g|webp|gif)/.test(t.url)?'image':/\.m?js/.test(t.url)?'script':/\.css/.test(t.url)?'style':/\.woff2?/.test(t.url)?'font':t.type.toLowerCase();byType[k]=(byType[k]||0)+bytes;
    if(bytes>20000)assets.push(Math.round(bytes/1024)+'KB '+t.status+' '+(t.enc||'-')+' '+t.url.replace(base,'').split('?')[0]);}
   const longDuring=perf.long.filter(([s])=>s<(perf.ready||perf.fallback||1e9));
   results[name+' '+label]={formReadyMs:Math.round(formReady),firstSceneMs:Math.round(perf.ready||0),fallback:!!perf.fallback,transferKB:Math.round(total/1024),byTypeKB:Object.fromEntries(Object.entries(byType).map(([k,v])=>[k,Math.round(v/1024)])),
    longTasksDuringLoad:longDuring.length,longTaskMsDuringLoad:Math.round(longDuring.reduce((s,[,d])=>s+d,0)),maxLongTaskMs:Math.round(Math.max(0,...longDuring.map(([,d])=>d))),
    inputDelayMs:{median:Math.round(perf.inputs.sort((a,b)=>a-b)[perf.inputs.length>>1]||0),max:Math.round(Math.max(0,...perf.inputs))},
    frameMs:{median:+(frames[frames.length>>1]||0).toFixed(1),p95:+(frames[Math.floor(frames.length*.95)]||0).toFixed(1),count:frames.length},
    bigAssets:label==='cold'?assets:undefined};
  };
  await one('cold');await one('warm');
  await ctx.close();
 }
 for(const [name,profile] of Object.entries(profiles))await run(name,profile);
 // Draw calls and triangles from the scene's own inspector (same module, isolated page, desktop size).
 const ctx=await page.context().browser().newContext({viewport:{width:1440,height:900}});const p=await ctx.newPage();
 await p.goto(base+path);await p.locator('[data-scene-ready]').waitFor({timeout:30000}).catch(()=>{});
 results.scene=await p.evaluate(()=>{const s=document.querySelector('[data-login-campus]').campusScene;return s?s.inspect():'inspector not exposed';}).then(s=>typeof s==='string'?s:{drawCalls:s.drawCalls,triangles:s.triangles,quality:s.quality,pixelRatio:s.pixelRatio});
 if(typeof results.scene==='string'){
  // Baseline builds without the page hook: create the scene in an isolated page instead.
  await p.setContent(`<style>body{margin:0}#root,[data-campus-canvas]{width:100vw;height:100vh}</style><div id="root" data-logo="${base}/Assets/images/gju-logo.png"><button data-campus-pause hidden>Pause</button><div data-campus-canvas></div></div><script type="importmap">{"imports":{"three":"${base}/Assets/js/vendor/three.module.min.js"}}</script>`);
  results.scene=await p.evaluate(async base=>{window.uimsT=k=>k;const m=await import(base+'/Assets/js/login-campus-scene.js?perf='+Date.now());const s=await m.createCampusScene(document.querySelector('#root'),{reducedMotion:false});await new Promise(r=>setTimeout(r,800));const i=s.inspect();s.dispose();return {drawCalls:i.drawCalls,triangles:i.triangles,isolated:true};},base);
 }
 await ctx.close();
 return JSON.stringify(results,null,1);
}
