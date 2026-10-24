async page => {
 const base='http://localhost:58128';
 let checks=0;
 const assert=(ok,name)=>{if(!ok)throw Error(name);checks++;};
 for(const lang of ['en','ar']) {
  await page.goto(base+'/Pages/Public/Contact.aspx?ui-lang='+lang);
  for(const theme of ['light','dark']) {
   await page.evaluate(t=>window.UimsTheme.set(t),theme);
   for(const width of [1440,1280,1201,1200,1120,974,768,390,320]) {
    await page.setViewportSize({width,height:844});
    for(const y of [0,200]) {
     await page.evaluate(y=>scrollTo(0,y),y);await page.waitForTimeout(300);
     const menu=page.locator('.public-menu-toggle');
     const mobile=await menu.isVisible();
     assert(mobile===(width<=1200),'Responsive breakpoint '+width);
     if(mobile&&await menu.getAttribute('aria-expanded')!=='true')await menu.click();
     const geometry=await page.evaluate(()=>{
      const bar=document.querySelector('.public-header-inner').getBoundingClientRect();
      const selectors=innerWidth>1200?['.public-brand',...Array.from(document.querySelectorAll('.public-links>a')).map((_,i)=>'.public-links>a:nth-of-type('+(i+1)+')'),'.public-theme-desktop']:['.public-brand','.public-menu-toggle'];
      const rects=selectors.map(s=>{const r=document.querySelector(s).getBoundingClientRect();return {left:r.left,right:r.right,top:r.top,bottom:r.bottom};});
      const overlap=rects.some((a,i)=>rects.slice(i+1).some(b=>Math.min(a.right,b.right)-Math.max(a.left,b.left)>.5&&Math.min(a.bottom,b.bottom)-Math.max(a.top,b.top)>.5));
      const within=rects.every(r=>r.left>=bar.left&&r.right<=bar.right);
      const lang=document.querySelector(innerWidth>1200?'.public-theme-desktop .uims-lang-control':'.public-theme-mobile .uims-lang-control').getBoundingClientRect();
      return {overlap,within,overflow:document.documentElement.scrollWidth>innerWidth,selectorVisible:lang.left>=0&&lang.right<=innerWidth};
     });
     assert(!geometry.overlap&&geometry.within&&!geometry.overflow&&geometry.selectorVisible,JSON.stringify({lang,theme,width,y,geometry}));
     if(theme==='dark'&&y===200&&[1280,974,390].includes(width))await page.locator(width>1200?'.public-header-inner':'#publicNav').screenshot({path:'tests/artifacts/navbar-controls-'+lang+'-'+width+'.png'});
    }
   }
  }
 }
 return {checks};
}
