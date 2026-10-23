async page => {
 // Compares tests/artifacts/theme/light-before/*.png with light-after/*.png pixel by pixel (channel difference > 12).
 // Reports per image: same size, changed pixels, and the bounding box of the changes. Read-only; no server needed.
 const dir='file:///C:/Users/user/Desktop/Project3/internship-management-system/tests/artifacts/theme/';
 const names=FILES;
 await page.goto(dir+'diff.html');
 const out=[];
 for(const name of names){
  const r=await page.evaluate(async([a,b])=>{
   const load=src=>new Promise((res,rej)=>{const i=new Image();i.onload=()=>res(i);i.onerror=()=>rej(src);i.src=src;});
   let A,B;try{[A,B]=await Promise.all([load(a),load(b)]);}catch(e){return {missing:String(e)};}
   const w=Math.min(A.width,B.width),h=Math.min(A.height,B.height);
   const c=document.createElement('canvas');c.width=w;c.height=h;const x=c.getContext('2d',{willReadFrequently:true});
   x.drawImage(A,0,0);const da=x.getImageData(0,0,w,h).data;x.clearRect(0,0,w,h);x.drawImage(B,0,0);const db=x.getImageData(0,0,w,h).data;
   let n=0,minX=w,minY=h,maxX=-1,maxY=-1;
   for(let i=0;i<da.length;i+=4){if(Math.abs(da[i]-db[i])>12||Math.abs(da[i+1]-db[i+1])>12||Math.abs(da[i+2]-db[i+2])>12){n++;const p=i/4,px=p%w,py=(p-px)/w;if(px<minX)minX=px;if(px>maxX)maxX=px;if(py<minY)minY=py;if(py>maxY)maxY=py;}}
   return {size:[A.width,A.height,B.width,B.height],changed:n,share:+(n/(w*h)*100).toFixed(3),box:n?[minX,minY,maxX,maxY]:null};
  },[dir+'light-before/'+name,dir+'light-after/'+name]);
  out.push([name,r]);
 }
 return out;
}
