<%@ Page Language="C#" MasterPageFile="~/Layout/Public.master" Title="404 - GJU Internship Management System" %>
<script runat="server">
protected override void OnLoad(System.EventArgs e){base.OnLoad(e);Response.StatusCode=404;Response.TrySkipIisCustomErrors=true;}
</script>
<asp:Content ID="GuardHead" ContentPlaceHolderID="head" runat="server"><meta name="robots" content="noindex, nofollow" /><style>#gju404{margin:-2rem 0;padding:0 0 25px;background:#09334f;color:#fff;overflow:hidden;font-family:'Segoe UI',Arial,sans-serif}#gju404 *{box-sizing:border-box}.uims-main:has(#gju404){padding:0;background:#09334f;min-height:calc(100vh - 140px)}body:has(#gju404){background:#09334f}#gju404{margin:0;min-height:calc(100vh - 140px)}#gju404 .guard-scene{position:relative;width:100%;height:650px;overflow:hidden;border:0;outline:0}#gju404 .guard-art{position:absolute;width:1000px;height:650px;left:50%;top:0;transform:translateX(-50%);overflow:visible}#gju404 .guard-copy{position:relative;z-index:2;max-width:530px;margin:0 7% 0 auto;padding-top:85px}#gju404 .guard-label{font-size:10px;letter-spacing:2.5px;color:#8db7cf;margin-bottom:22px}#gju404 h1{font-size:42px;font-weight:750;letter-spacing:-1.4px;line-height:1.2;margin:0 0 20px;color:#edf7ff}#gju404 h1 span{color:#a8d3ed}#gju404 .guard-copy p{font-size:15px;line-height:1.85;color:#a4c5d9;max-width:420px;margin:0 0 22px}#gju404 .guard-tag{font-size:9px;letter-spacing:1.7px;color:#81abc4}#gju404 .guard-controls{display:flex;justify-content:center;flex-wrap:wrap;gap:12px;padding:10px 20px 20px}#gju404 .guard-controls a,#gju404 .guard-controls button{font:600 12px 'Segoe UI',Arial,sans-serif;padding:11px 20px;border:1px solid #749bb4;border-radius:6px;cursor:pointer;text-decoration:none;background:transparent;color:#d5ebfa;transition:transform .2s,box-shadow .2s}#gju404 .guard-controls a{background:#def1ff;color:#123850}#gju404 .guard-controls a:hover,#gju404 .guard-controls button:hover{transform:translateY(-3px);box-shadow:0 6px 20px #64b5e92a}#gju404 a:focus-visible,#gju404 button:focus-visible{outline:3px solid #a4dfff;outline-offset:4px}#gju404 .guard-status{min-height:26px;text-align:center;color:#bddff2;font-size:11px;padding:0 20px}#gju404 .guard-footer{text-align:center;margin:0;color:#8db2c9;font-size:11px}#gju404 .guard-arm{transform-origin:202px 222px}#gju404 .guard-beam{transform-origin:202px 222px;pointer-events:none}#gju404 .guard-head{transform-origin:150px 193px}#gju404 .guard-eyes{transform-origin:150px 139px}#gju404 .guard-digits{pointer-events:none}
@media(min-width:1200px){#gju404 .guard-copy{margin-right:calc((100% - 1000px)/2 + 10px);max-width:530px}}
@media(max-width:800px){#gju404 .guard-scene{height:620px}#gju404 .guard-art{width:820px;height:533px;top:45px}#gju404 .guard-copy{padding-top:80px;margin-right:4%;max-width:48%}#gju404 h1{font-size:31px}#gju404 .guard-copy p{font-size:12px}#gju404 .guard-label{font-size:7px;letter-spacing:1px}#gju404 .guard-tag{font-size:7px;letter-spacing:.6px}}
@media(max-width:540px){#gju404 .guard-scene{height:700px}#gju404 .guard-art{width:650px;height:422px;top:0;left:calc(50% + 115px)}#gju404 .guard-copy{padding-top:388px;margin:0 auto;max-width:85%;text-align:center}#gju404 h1{font-size:29px}#gju404 .guard-copy p{font-size:12px;max-width:330px;margin:0 auto 20px}#gju404 .guard-label{font-size:8px;letter-spacing:1.3px;margin-bottom:15px}#gju404 .guard-tag{font-size:7px;letter-spacing:1px}#gju404 .guard-controls{gap:8px;padding-inline:10px}#gju404 .guard-controls a,#gju404 .guard-controls button{font-size:10px;padding:10px 13px}#gju404 .guard-footer{font-size:9px}}
@media(prefers-reduced-motion:reduce){#gju404 *{transition:none!important}}
@media(max-width:540px){#gju404 .guard-digits{transform:translate(130px,535px) rotate(10deg) scale(.8)}}
@media(min-width:541px) and (max-width:1000px){#gju404 .guard-art{width:100%;height:auto;top:20px}}
@media(max-width:540px){#gju404 .guard-art{left:calc(50% + 140px)}}
/* Refined layout: actions belong to the introduction; artwork sits below it. */
#gju404 .guard-scene{height:640px}
#gju404 .guard-copy{padding-top:65px;max-width:515px}
#gju404 .guard-label{margin-bottom:18px;font-size:9px}
#gju404 h1{font-size:38px;line-height:1.16;margin-bottom:16px}
#gju404 .guard-copy p{font-size:14px;line-height:1.8;max-width:425px;margin-bottom:22px}
#gju404 .guard-controls{justify-content:flex-start;padding:0;gap:9px;margin-bottom:13px}
#gju404 .guard-controls a,#gju404 .guard-controls button{padding:11px 17px;font-size:11px;border-radius:7px}
#gju404 .guard-status{text-align:left;padding:0;min-height:26px;max-width:440px;font-size:10px}
#gju404 .guard-tag{font-size:8px;letter-spacing:1.5px;display:block;opacity:.85}
#gju404 .guard-lit-digits{opacity:1!important}
#gju404 .guard-footer{padding-bottom:5px}
@media(min-width:1200px){#gju404 .guard-copy{max-width:515px;margin-right:calc((100% - 1000px)/2 + 10px)}}
@media(min-width:541px) and (max-width:1000px){#gju404 .guard-copy{padding-top:62px;max-width:52%;margin-right:4%}#gju404 h1{font-size:32px}#gju404 .guard-copy p{font-size:12px;max-width:340px}#gju404 .guard-controls a,#gju404 .guard-controls button{font-size:10px;padding:10px 12px}#gju404 .guard-tag{font-size:7px;letter-spacing:.9px}#gju404 .guard-label{font-size:7px;letter-spacing:1.6px}}
@media(max-width:540px){#gju404 .guard-scene{height:765px}#gju404 .guard-copy{padding-top:392px;max-width:88%;margin:0 auto}#gju404 h1{font-size:28px;line-height:1.2}#gju404 .guard-copy p{font-size:12px;max-width:310px;margin:0 auto 22px}#gju404 .guard-controls{justify-content:center;gap:7px;margin-bottom:10px}#gju404 .guard-controls a,#gju404 .guard-controls button{padding:10px 11px;font-size:10px}#gju404 .guard-status{text-align:center;font-size:9px;min-height:35px}#gju404 .guard-label{font-size:7px;letter-spacing:1.3px}#gju404 .guard-tag{font-size:7px;letter-spacing:.9px}}
#gju404 .guard-controls button{background:#123d58;color:#e7f5ff}
#gju404 {
    padding-top: 32px;
}

@media (max-width: 540px) {
    #gju404 {
        padding-top: 24px;
    }
}
</style></asp:Content>
<asp:Content ID="GuardBody" ContentPlaceHolderID="MainContent" runat="server"><section id="gju404" aria-labelledby="guard-title">
<div class="guard-scene">
<svg class="guard-art" viewBox="0 0 1000 650" aria-hidden="true">
<defs><linearGradient id="gju-shirt" x2="1" y2="1"><stop stop-color="#4d7b9b"/><stop offset=".42" stop-color="#2b5477"/><stop offset="1" stop-color="#102d48"/></linearGradient><linearGradient id="gju-skin" x2="1" y2="1"><stop stop-color="#f6d0aa"/><stop offset=".48" stop-color="#e6b28b"/><stop offset="1" stop-color="#c88d66"/></linearGradient><linearGradient id="gju-torch" x2="0" y2="1"><stop stop-color="#7497b2"/><stop offset=".5" stop-color="#223e57"/><stop offset="1" stop-color="#091c2e"/></linearGradient><linearGradient id="gju-beam"><stop stop-color="#F8FFE8" stop-opacity=".94"/><stop offset="1" stop-color="#F8FFE8" stop-opacity=".73"/></linearGradient><filter id="gju-soft"><feGaussianBlur stdDeviation="7"/></filter><linearGradient id="gju-cap" x2=".8" y2="1"><stop stop-color="#345f7d"/><stop offset="1" stop-color="#102d47"/></linearGradient><linearGradient id="gju-pants" x2="1" y2="0"><stop stop-color="#102c45"/><stop offset=".5" stop-color="#17374e"/><stop offset="1" stop-color="#0b2339"/></linearGradient><filter id="gju-ground"><feGaussianBlur stdDeviation="6"/></filter></defs>
<ellipse cx="161" cy="574" rx="116" ry="17" fill="#041e30" opacity=".6" filter="url(#gju-ground)"/>
<g class="guard-beam"><path d="M280 261 1020 365 920 790Z" fill="url(#gju-beam)"/><path d="M280 261 820 450 742 626Z" fill="#FFFFFF" opacity=".12"/></g>
<g class="guard-body">
<path d="m99 354-9 178 12 16 47-1 18-164 7 164 53 1 9-20-23-175Z" fill="url(#gju-pants)" stroke="#1f4058" stroke-width="1.4"/><path d="m102 529-14 24q-3 13 15 14l43-1 4-24m26-2-3 23 55 5q18 0 15-12l-17-24" fill="#061727" stroke="#2e4c62" stroke-width="2"/>
<path d="M108 389 101 507M202 390 216 514" fill="none" stroke="#406079" stroke-width="1.4" opacity=".7"/><path d="m112 452 16 6m61-7 15 7" stroke="#071e31" stroke-width="2" stroke-linecap="round"/><path d="m98 560 47-1m34 2 49 3" stroke="#416077" stroke-width="2" stroke-linecap="round"/>
<path d="m120 190-31 11q-18 11-21 37l-7 90 27 8 12-64-5 99q74 17 124-2l-7-116-22-50-38-12Z" fill="url(#gju-shirt)" stroke="#173952" stroke-width="1.8"/>
<path d="m80 230-13 93q-2 15 9 17l13-4 11-84" fill="#2b5574"/><path d="m69 318 21 5-1 13-23-5Z" fill="#183c59" stroke="#4e7996" stroke-width="1.2"/><path d="m68 332 19 4 1 22q0 12-7 13-8 0-12-8l-3-15Z" fill="url(#gju-skin)" stroke="#a77b5a" stroke-width="1.2"/><path d="m74 351 1 13m5-11 1 13" stroke="#bc8a65" stroke-width="1" stroke-linecap="round"/>
<path d="m130 181-5 27 28 29 34-32-9-24" fill="url(#gju-skin)"/><path d="m121 194 31 42-29 11-17-42m81-11-35 42 28 12 22-41" fill="#3f6d8d" stroke="#1e415e" stroke-width="1.6"/><path d="M152 236v127" stroke="#0a2238" stroke-width="3"/><path d="M153 251v111" stroke="#81a2b9" stroke-width="1"/><g fill="#abc2d1"><circle cx="160" cy="265" r="2"/><circle cx="160" cy="297" r="2"/><circle cx="160" cy="330" r="2"/></g>
<path d="M103 270h34v31h-34Z" fill="#1c4668" stroke="#5984a4"/><path d="m101 270 19 10 19-10" fill="#467292"/><rect x="176" y="266" width="29" height="34" rx="3" fill="#173e5e" stroke="#648fa9"/><text x="190" y="281" text-anchor="middle" fill="#d0e6f4" font-size="8" font-family="Arial" font-weight="700">GJU</text><path d="M180 288h20m-18 5h16" stroke="#87b4cf" stroke-width="1.5"/>
<path d="m89 211 19-8 4 9-20 8Z" fill="#183b57" stroke="#638ba5" stroke-width="1.2"/><circle cx="105" cy="210" r="2" fill="#b2c6d2"/>
<rect x="101" y="238" width="30" height="13" rx="2" fill="#153751" stroke="#7a9db5" stroke-width=".8"/><text x="116" y="247" text-anchor="middle" font-size="5.4" font-family="Arial" fill="#d5e8f3" letter-spacing=".5">SECURITY</text>
<g><rect x="78" y="219" width="17" height="36" rx="4" fill="#0b2338" stroke="#62849b" stroke-width="1.2"/><path d="M85 219v-12" stroke="#112c41" stroke-width="4" stroke-linecap="round"/><rect x="81" y="225" width="11" height="7" rx="1" fill="#6e99b0"/><path d="M82 238h9m-9 4h9m-9 4h9" stroke="#476a84" stroke-width="1.3"/><path d="M83 255q-9 33 14 53" fill="none" stroke="#102c42" stroke-width="3"/></g>
<path d="M104 318q10 7 23 1m49 1q12 8 25-1" fill="none" stroke="#6088a1" stroke-width="1" opacity=".45"/>
<rect x="88" y="352" width="132" height="17" rx="5" fill="#071b2b"/><rect x="143" y="351" width="24" height="19" rx="3" fill="#89a2b0"/><rect x="148" y="355" width="14" height="10" fill="#1a344b"/><rect x="98" y="342" width="20" height="36" rx="4" fill="#0b2133" stroke="#3f5d75"/>
<g class="guard-head">
<ellipse cx="109" cy="138" rx="11" ry="19" fill="#d8a67f"/><ellipse cx="193" cy="138" rx="10" ry="18" fill="#c68b65"/><path d="m109 98 2 51q0 45 40 48 38-4 41-45l-1-54Z" fill="url(#gju-skin)" stroke="#a57653" stroke-width="1.5"/><path d="m110 115-4-29 22-14 54 9 13 18-5 25-6-15-15-10-40 4-11 22Z" fill="#183047"/>
<path d="M119 126q8-5 17-1m21 0q9-3 18 3" stroke="#39483f" stroke-width="3.3" stroke-linecap="round"/>
<g class="guard-eyes"><ellipse cx="129" cy="139" rx="9" ry="6" fill="#fff4e9"/><ellipse cx="168" cy="140" rx="9" ry="6" fill="#fff4e9"/><g class="guard-pupils"><circle cx="132" cy="139" r="4" fill="#21394a"/><circle cx="171" cy="140" r="4" fill="#21394a"/><circle cx="133" cy="138" r="1.2" fill="#fff"/><circle cx="172" cy="139" r="1.2" fill="#fff"/></g></g>
<ellipse cx="122" cy="157" rx="9" ry="5" fill="#d48f75" opacity=".19"/><ellipse cx="178" cy="158" rx="8" ry="5" fill="#c58367" opacity=".15"/><path d="M113 132q-1 33 13 44" fill="none" stroke="#ffdfbd" stroke-width="4" stroke-linecap="round" opacity=".27"/><path d="m148 141-4 14 9 3" fill="none" stroke="#ad7656" stroke-width="2" stroke-linecap="round"/><path d="M134 169q15 12 30 0" fill="none" stroke="#906044" stroke-width="2" stroke-linecap="round"/>
<path d="M103 99q-1-45 47-49 48 0 51 49Z" fill="url(#gju-cap)" stroke="#65859b" stroke-width="1.5"/><path d="M100 98q54-12 102 3l-8 12q-51-9-92 0Z" fill="#071f34" stroke="#426783"/><path d="M110 96q42-7 82 2" fill="none" stroke="#9fb6c7" stroke-width="1.2" opacity=".6"/><path d="M116 77q11-17 30-19" fill="none" stroke="#81a1b6" stroke-width="2" opacity=".35"/><path d="M138 68h26v23h-26Z" fill="#284e6a" stroke="#7cabc6"/><text x="151" y="83" fill="#d8efff" font-size="9" font-family="Arial" font-weight="700" text-anchor="middle">GJU</text>
</g>
<g class="guard-arm">
<!-- One continuous sleeve and wrist; flashlight is behind the gripping fingers. -->
<path d="M184 207 C193 198 209 202 218 214 L235 238 Q239 243 247 243 L252 262 L236 270 Q226 274 217 264 L196 242 Q180 228 184 207Z" fill="url(#gju-shirt)" stroke="#102d46" stroke-width="2" stroke-linejoin="round"/>
<path d="M193 211 Q204 210 211 221 L228 244" fill="none" stroke="#5b87a5" stroke-width="2" stroke-linecap="round" opacity=".6"/>
<path d="M228 245 L241 240 L249 262 L237 268Z" fill="#477896" stroke="#183d59" stroke-width="1.4"/>
<g transform="translate(241 253) rotate(10)">
<rect x="-5" y="-9" width="39" height="21" rx="5" fill="url(#gju-torch)" stroke="#86a9be" stroke-width="1.3"/>
<path d="M27-9 40-16V19L27 11Z" fill="#30536e" stroke="#8db1c7" stroke-width="1.3"/>
<ellipse cx="40" cy="1.5" rx="5" ry="17.5" fill="#F8FFE8"/>
<ellipse cx="41" cy="1.5" rx="2" ry="13" fill="#fff"/>
<path d="M3-4H21" stroke="#a0bdca" stroke-width="1.5" opacity=".6"/>
</g>
<path d="M241 246 Q243 240 249 241 L260 245 Q268 245 268 251 L265 262 Q263 268 256 266 L245 263 Q239 259 239 253Z" fill="url(#gju-skin)" stroke="#9c6d50" stroke-width="1.4" stroke-linejoin="round"/>
<path d="M254 249 265 251 M253 255 264 257 M251 261 260 263" fill="none" stroke="#b87e58" stroke-width="1.2" stroke-linecap="round"/>
<path d="M242 250 Q245 239 250 243 L256 250 Q258 255 254 256 L248 250" fill="url(#gju-skin)" stroke="#a97855" stroke-width="1.2" stroke-linecap="round"/>
</g>
</g>
<g class="guard-digits" transform="translate(435 560) rotate(8)"><text x="5" y="14" font-family="Arial,sans-serif" font-weight="900" font-size="185" letter-spacing="-15" fill="#031c2c">404</text><text class="guard-lit-digits" x="0" y="0" font-family="Arial,sans-serif" font-weight="900" font-size="185" letter-spacing="-15" fill="#79b9db" stroke="#285e7e" stroke-width="2">404</text></g>
</svg>
<div class="guard-copy"><div class="guard-label">GERMAN JORDANIAN UNIVERSITY</div><h1 id="guard-title">Lost on campus?<br><span>We’ll guide you back.</span></h1><p>The page you’re looking for couldn’t be found. Let’s get you back to your internship journey at GJU.</p><div class="guard-controls"><a id="guard-home" href="<%: ResolveUrl(InternshipManagementSystem.Common.Constants.Routes.Home) %>">Back to GJU</a></div><div class="guard-status" role="status" aria-live="polite"></div></div>
</div>


<p class="guard-footer">University Internship Management System | GJU</p>
</section>
</asp:Content>
<asp:Content ID="GuardScripts" ContentPlaceHolderID="scripts" runat="server"><script>(function(){'use strict';
var root=document.getElementById('gju404');if(!root)return;var svg=root.querySelector('.guard-art'),arm=root.querySelector('.guard-arm'),beam=root.querySelector('.guard-beam'),head=root.querySelector('.guard-head'),eyes=root.querySelector('.guard-eyes'),pupils=root.querySelector('.guard-pupils'),digits=root.querySelector('.guard-lit-digits'),home=document.getElementById('guard-home'),status=root.querySelector('.guard-status');
var preference=matchMedia('(prefers-reduced-motion: reduce)'),paused=false,visible=true,active=false,frame=0,last=0,t=0,angle=0,target=0,pupilX=0,pupilY=0;
function paint(){arm.style.transform='rotate('+angle+'deg)';beam.style.transform='rotate('+angle+'deg)';head.style.transform='rotate('+(angle*.12)+'deg)';pupils.style.transform='translate('+pupilX+'px,'+pupilY+'px)';var blink=!preference.matches&&t%5200>5020;eyes.style.transform='scaleY('+(blink?.08:1)+')';var light=preference.matches?1:.6+.4*Math.sin(t*.0008);digits.style.opacity=String(light);}
function canRun(){return !paused&&!preference.matches&&!document.hidden&&visible;}
function tick(time){frame=0;if(!canRun())return;var dt=last?Math.min(60,time-last):16;last=time;t+=dt;if(!active)target=Math.sin(t*.0005)*9;angle+=(target-angle)*(1-Math.exp(-dt*.006));paint();frame=requestAnimationFrame(tick);}
function sync(){if(frame)cancelAnimationFrame(frame);frame=0;last=0;if(canRun())frame=requestAnimationFrame(tick);else paint();}
root.addEventListener('pointermove',function(e){if(paused)return;var matrix=svg.getScreenCTM();if(!matrix)return;var point=new DOMPoint(e.clientX,e.clientY).matrixTransform(matrix.inverse());target=Math.max(-18,Math.min(28,Math.atan2(point.y-222,point.x-202)*180/Math.PI-20));pupilX=Math.max(-3,Math.min(3,(point.x-150)/160));pupilY=Math.max(-2,Math.min(2,(point.y-139)/170));active=true;if(preference.matches){angle=target;paint();}},{passive:true});root.addEventListener('pointerleave',function(){active=false;pupilX=pupilY=0;});document.addEventListener('visibilitychange',sync);if(preference.addEventListener)preference.addEventListener('change',sync);else preference.addListener(sync);new IntersectionObserver(function(entries){visible=entries[0].isIntersecting;sync();}).observe(root);
if(root.hasAttribute('data-preview')){home.onclick=function(e){e.preventDefault();status.textContent='Preview: Back to GJU opens ~/Default.aspx inside your project.';};document.querySelectorAll('[data-preview-route]').forEach(function(a){a.onclick=function(e){e.preventDefault();status.textContent='UIMS route: '+a.getAttribute('data-preview-route');};});var menu=document.querySelector('[data-preview-menu]');if(menu)menu.onclick=function(){var open=menu.getAttribute('aria-expanded')!=='true';menu.setAttribute('aria-expanded',String(open));document.getElementById('preview-nav').classList.toggle('is-open',open);};}
sync();window.addEventListener('pagehide',function(){if(frame)cancelAnimationFrame(frame);});
}());
</script></asp:Content>