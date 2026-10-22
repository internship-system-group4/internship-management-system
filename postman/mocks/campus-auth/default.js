// Test-only contract subset from AuthService.cs / Firebase Auth REST.
// Synthetic credentials only. Never contacts Firebase or sends email.
const http = require('http');
http.createServer(async (req,res) => {
 const path = new URL(req.url,'http://localhost').pathname;
 const send = (status,data) => {res.writeHead(status,{'Content-Type':'application/json'});res.end(JSON.stringify(data));};
 let body=req.body;
 if(body===undefined){let raw='';for await(const chunk of req)raw+=chunk;try{body=JSON.parse(raw);}catch{return send(400,{error:{message:'INVALID_JSON'}});}}
 if(typeof body==='string')body=JSON.parse(body);
 if(path==='/v1/accounts:sendOobCode'&&req.method==='POST')return send(200,{email:body.email});
 if(path!=='/v1/accounts:signInWithPassword'||req.method!=='POST')return send(501,{error:{message:'ENDPOINT_NOT_MODELLED'}});
 if(body.returnSecureToken!==true||typeof body.email!=='string'||typeof body.password!=='string')return send(400,{error:{message:'INVALID_ARGUMENT'}});
 await new Promise(resolve=>setTimeout(resolve,450));
 const ids={'student@campus.test':'student-one','company@campus.test':'supervisor-one','academic@campus.test':'academic-one','coordinator@campus.test':'coordinator-one','unknown@campus.test':'unknown-one'};
 const id=ids[body.email];
 if(!id||body.password!=='Fixture-pass-2026')return send(400,{error:{message:'INVALID_LOGIN_CREDENTIALS'}});
 send(200,{localId:id,email:body.email,idToken:'local-fixture-token',refreshToken:'local-fixture-refresh',expiresIn:'3600'});
}).listen(process.env.PORT);
