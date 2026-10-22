// Local stand-in for the Firebase RTDB REST paths used by O01.
// Contract: https://firebase.google.com/docs/reference/rest/database
const http = require('http');
const crypto = require('crypto');
const student = { Id:'student-one', FullName:'Osama Banihani', Email:'osama@example.com', Role:1, IsActive:true, MustChangePassword:false, StudentNumber:'20260001', College:'Engineering', Major:'Computer Science', CvUrl:'https://example.com/cv.pdf' };
const coordinator = { Id:'coordinator-one', FullName:'Internship Coordinator', Email:'coordinator@example.com', Role:4, IsActive:true, MustChangePassword:false };
const supervisor = { Id:'supervisor-one', FullName:'Company Supervisor', Role:2, IsActive:true, MustChangePassword:false, CompanyId:'company-one', CompanyName:'Training Company' };
function seed() {
 const opportunity = { Id:'internship-one', Title:'Software Development Intern', CompanyId:'company-one', CompanyName:'Training Company', Location:'Amman, Jordan', Description:'Work with the engineering team to build useful web applications and learn through code reviews.', Requirements:'C#, HTML, CSS, and an interest in learning.', EligibleCollege:'Engineering', EligibleMajors:['Computer Science'], TotalSeats:4, FilledSeats:1, DurationWeeks:12, StartDate:Date.now()+86400000*30, ApplicationDeadline:Date.now()+86400000*7, Status:1 };
 return {users:{'student-one':student,'supervisor-one':supervisor,'other-supervisor':{...supervisor,Id:'other-supervisor',CompanyId:'company-two'},'coordinator-one':coordinator},opportunities:{'internship-one':opportunity}, applications:{},placements:{},companies:{},tasks:{},submissions:{},taskEvaluations:{},companyFinalEvaluations:{},academicFinalEvaluations:{},trainingHours:{},academicComments:{},completions:{},contactMessages:{},ContactMessages:{},publicOpportunityPreviews:{}};
}
// Serialize requests so compare-and-swap checks and writes are atomic like RTDB.
let requestQueue=Promise.resolve();
http.createServer((req,res) => {
 requestQueue=requestQueue.then(()=>handle(req,res)).catch(()=>{
   if(!res.headersSent)res.writeHead(500,{'Content-Type':'application/json'});
   res.end(JSON.stringify({error:'Mock request failed'}));
 });
}).listen(process.env.PORT || 4901);
async function handle(req,res) {
 const url = new URL(req.url,'http://localhost');
 const reply = (status,data) => { res.writeHead(status,{'Content-Type':'application/json'});res.end(JSON.stringify(data)); };
 let db = await pm.state.get('firebase.db'); if (!db) { db=seed(); await pm.state.set('firebase.db',db); }
 if (url.pathname==='/__reset' && req.method==='POST') { await pm.state.set('firebase.failPreviews',false);await pm.state.set('firebase.failMonitoring',false); await pm.state.set('firebase.db',seed()); await pm.state.set('firebase.failWrites',false); await pm.state.set('firebase.failPlacements',false); await pm.state.set('firebase.conflictNext',false); await pm.state.set('firebase.slowWrites',false); return reply(200,{ok:true}); }
 if (url.pathname==='/__slow-writes' && req.method==='POST') { await pm.state.set('firebase.slowWrites',true); return reply(200,{ok:true}); }
 if (url.pathname==='/__fail-previews' && req.method==='POST') { await pm.state.set('firebase.failPreviews',true);return reply(200,{ok:true}); }
 if (url.pathname==='/__restore-previews' && req.method==='POST') { await pm.state.set('firebase.failPreviews',false);return reply(200,{ok:true}); }
 if(req.method==='GET' && url.pathname.startsWith('/publicOpportunityPreviews') && await pm.state.get('firebase.failPreviews'))return reply(500,{error:'Preview read unavailable'});
 if (url.pathname==='/__fail-monitoring' && req.method==='POST') { await pm.state.set('firebase.failMonitoring',true); return reply(200,{ok:true}); }
 if (url.pathname==='/__restore-monitoring' && req.method==='POST') { await pm.state.set('firebase.failMonitoring',false); return reply(200,{ok:true}); }
 if (req.method==='GET' && url.pathname.startsWith('/trainingHours') && await pm.state.get('firebase.failMonitoring')) return reply(500,{error:'Simulated monitoring read failure'});
 if (url.pathname==='/__fail-placement-writes' && req.method==='POST') { await pm.state.set('firebase.failPlacements',true); return reply(200,{ok:true}); }
 if (url.pathname==='/__restore-writes' && req.method==='POST') { await pm.state.set('firebase.failWrites',false); await pm.state.set('firebase.slowWrites',false); await pm.state.set('firebase.failPlacements',false); return reply(200,{ok:true}); }
 if (url.pathname==='/__conflict-next' && req.method==='POST') { await pm.state.set('firebase.conflictNext',true); return reply(200,{ok:true}); }
 if (url.pathname==='/__fail-writes' && req.method==='POST') { await pm.state.set('firebase.failWrites',true); return reply(200,{ok:true}); }
 if (['PUT','PATCH'].includes(req.method) && (url.pathname.startsWith('/applications/') || (url.pathname.startsWith('/contactMessages/') || url.pathname.startsWith('/ContactMessages/'))) && await pm.state.get('firebase.failWrites')) return reply(500,{error:'Simulated write failure'});
 if (req.method==='PUT' && url.pathname.startsWith('/placements/') && await pm.state.get('firebase.failPlacements')) return reply(500,{error:'Simulated placement failure'});
 if (!url.pathname.endsWith('.json')) return reply(501,{error:'Endpoint not modelled'});
 const parts=url.pathname.slice(1,-5).split('/');
 if (!['users','opportunities','applications','placements','companies','tasks','submissions','taskEvaluations','companyFinalEvaluations','academicFinalEvaluations','trainingHours','academicComments','completions','contactMessages','ContactMessages','publicOpportunityPreviews','notifications','studentGroups','studentCvPortfolios','studentProfileExtras'].includes(parts[0])) return reply(501,{error:'Endpoint not modelled'});
 let parent=db; for (const key of parts.slice(0,-1)) { if (!parent[key]) parent[key]={}; parent=parent[key]; }
 const key=parts.at(-1); let value=parent[key] ?? null;
 const etag=value===null?'null_etag':'"'+crypto.createHash('sha256').update(JSON.stringify(value)).digest('hex')+'"';
 if(req.headers['x-firebase-etag']==='true') res.setHeader('ETag',etag);
 if(req.method==='GET') {
   if(url.searchParams.has('orderBy') && value) {
     const field=JSON.parse(url.searchParams.get('orderBy')), equal=JSON.parse(url.searchParams.get('equalTo'));
     value=Object.fromEntries(Object.entries(value).filter(([,v])=>v[field]===equal));
   }
   return reply(200,value);
 }
 if(req.method==='POST') {
   if(['contactMessages','ContactMessages'].includes(parts[0]) && await pm.state.get('firebase.failWrites')) return reply(500,{error:'Simulated write failure'});
   if(await pm.state.get('firebase.slowWrites')) await new Promise(r=>setTimeout(r,2500));
   let body=req.body;
   if(body===undefined) { let raw='';for await(const chunk of req) raw+=chunk;body=JSON.parse(raw); }
   if(typeof body==='string') body=JSON.parse(body);
   if(!parent[key]) parent[key]={};
   const name='-Fixture'+Date.now().toString(36)+crypto.randomBytes(4).toString('hex');
   parent[key][name]=body;await pm.state.set('firebase.db',db);return reply(200,{name});
 }
 if(req.method==='DELETE'){delete parent[key];await pm.state.set('firebase.db',db);return reply(200,null);}
 if(req.method==='PUT' || req.method==='PATCH') {
   if(req.headers['if-match'] && req.headers['if-match']!==etag) return reply(412,value);
   if(req.headers['if-match'] && req.headers['if-match']!=='null_etag' && await pm.state.get('firebase.conflictNext')) {
     await pm.state.set('firebase.conflictNext',false);
     parent[key]={...value,Status:1,DecidedBySupervisorId:'concurrent-supervisor',DecidedAt:Date.now()};
     await pm.state.set('firebase.db',db);return reply(412,parent[key]);
   }
   let body=req.body;
   if(body===undefined) { let raw='';for await(const chunk of req) raw+=chunk;body=JSON.parse(raw); }
   if(typeof body==='string') body=JSON.parse(body);
   parent[key]=req.method==='PATCH'?{...(value||{}),...body}:body;
   await pm.state.set('firebase.db',db);return reply(200,parent[key]);
 }
 return reply(501,{error:'Method not modelled'});
}
