async page=>{
 const db='http://localhost:4930/firebase',now=Date.now(),date=months=>{const d=new Date(now);return Date.UTC(d.getUTCFullYear(),d.getUTCMonth()-months,10,12);};
 const get=async p=>(await page.request.get(db+'/'+p+'.json')).json();
 const put=async(p,data)=>{const response=await page.request.put(db+'/'+p+'.json',{data});if(!response.ok())throw Error('Fixture '+p);};
 const hours=await get('trainingHours/hours-approved');
 await put('trainingHours/hours-approved',{...hours,Hours:20,ReviewedAt:date(1)});
 await put('trainingHours/hours-second',{...hours,Hours:12,ReviewedAt:date(3)});
 await put('trainingHours/hours-older',{...hours,Hours:40,ReviewedAt:date(8)});
 const lina=await get('trainingHours/hours-lina');await put('trainingHours/hours-lina',{...lina,ReviewedAt:date(2)});
 const completion=await get('completions/completion-lina');await put('completions/completion-lina',{...completion,Status:4,ApprovedAt:date(2),ReviewedByCoordinatorId:'coordinator-one'});
 await put('academicFinalEvaluations/academic-lina',{Id:'academic-lina',StudentId:'student-two',PlacementId:'student-two',AcademicSupervisorId:'academic-one',IsSubmitted:true,TotalScore:100,MaxScore:100,SubmittedAt:date(2)});
 await put('completions/completion-private',{Id:'completion-private',StudentId:'student-private',PlacementId:'student-private',Status:4,ApprovedAt:date(8),ReviewedByCoordinatorId:'coordinator-one'});
 const users=await get('users');await put('users/student-four',{...users['student-four'],College:'Business'});
 return {fixture:'Reference analytics, local isolated records only',studentApproved:72,pending:16,range6:32,range12:72,monthBuckets:[date(1),date(3),date(8)]};
}
