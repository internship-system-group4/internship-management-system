// Local stand-in for the Firebase RTDB REST paths used by O01.
// Contract: https://firebase.google.com/docs/reference/rest/database
const http = require('http');
const student = { Id:'student-one', FullName:'Osama Banihani', Email:'osama@example.com', Role:1, IsActive:true, MustChangePassword:false, StudentNumber:'20260001', College:'Engineering', Major:'Computer Science', CvUrl:'https://example.com/cv.pdf' };
const supervisor = { Id:'supervisor-one', FullName:'Company Supervisor', Role:2, IsActive:true, MustChangePassword:false, CompanyId:'company-one', CompanyName:'Training Company' };
function seed() {
 const opportunity = { Id:'internship-one', Title:'Software Development Intern', CompanyId:'company-one', CompanyName:'Training Company', Location:'Amman, Jordan', Description:'Work with the engineering team to build useful web applications and learn through code reviews.', Requirements:'C#, HTML, CSS, and an interest in learning.', EligibleCollege:'Engineering', EligibleMajors:['Computer Science'], TotalSeats:4, FilledSeats:1, DurationWeeks:12, StartDate:Date.now()+86400000*30, ApplicationDeadline:Date.now()+86400000*7, Status:1 };
 return {users:{'student-one':student,'supervisor-one':supervisor,'other-supervisor':{...supervisor,Id:'other-supervisor',CompanyId:'company-two'}},opportunities:{'internship-one':opportunity}, applications:{},placements:{}};
}
http.createServer(async (req,res) => {
 const url = new URL(req.url,'http://localhost');
 const reply = (status,data) => { res.writeHead(status,{'Content-Type':'application/json'});res.end(JSON.stringify(data)); };
 let db = await pm.state.get('firebase.db'); if (!db) { db=seed(); await pm.state.set('firebase.db',db); }
 if (url.pathname==='/__reset' && req.method==='POST') { await pm.state.set('firebase.db',seed()); await pm.state.set('firebase.failWrites',false); return reply(200,{ok:true}); }
 if (url.pathname==='/__fail-writes' && req.method==='POST') { await pm.state.set('firebase.failWrites',true); return reply(200,{ok:true}); }
 if (req.method==='PUT' && url.pathname.startsWith('/applications/') && await pm.state.get('firebase.failWrites')) return reply(500,{error:'Simulated write failure'});
 if (!url.pathname.endsWith('.json')) return reply(501,{error:'Endpoint not modelled'});
 const parts=url.pathname.slice(1,-5).split('/');
 if (!['users','opportunities','applications','placements'].includes(parts[0])) return reply(501,{error:'Endpoint not modelled'});
 let parent=db; for (const key of parts.slice(0,-1)) { if (!parent[key]) parent[key]={}; parent=parent[key]; }
 const key=parts.at(-1); let value=parent[key] ?? null;
 if(req.method==='GET') {
   if(url.searchParams.has('orderBy') && value) {
     const field=JSON.parse(url.searchParams.get('orderBy')), equal=JSON.parse(url.searchParams.get('equalTo'));
     value=Object.fromEntries(Object.entries(value).filter(([,v])=>v[field]===equal));
   }
   return reply(200,value);
 }
 if(req.method==='PUT') {
   if(req.headers['if-match']==='null_etag' && value!==null) return reply(412,value);
   let body=req.body;
   if(body===undefined) { let raw='';for await(const chunk of req) raw+=chunk;body=JSON.parse(raw); }
   if(typeof body==='string') body=JSON.parse(body);
   parent[key]=body;await pm.state.set('firebase.db',db);return reply(200,body);
 }
 return reply(501,{error:'Method not modelled'});
}).listen(process.env.PORT || 4901);
