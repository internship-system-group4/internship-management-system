async page => {
 const db='http://localhost:4930/firebase',now=Date.now();
 const put=async(path,data)=>{const response=await page.request.put(db+'/'+path+'.json',{data});if(!response.ok())throw Error('Fixture write '+path);};
 await page.request.post(db+'/__reset');
 const base={IsActive:true,MustChangePassword:false,University:'German Jordanian University',College:'Engineering',Major:'Computer Science',RequiredHours:160,CvUrl:'https://example.test/cv.pdf'};
 await put('users',{
  'student-one':{...base,Id:'student-one',Role:1,FullName:'Osama Banihani',Email:'student@campus.test',StudentNumber:'20260001',ApprovedHours:72,AcademicSupervisorId:'academic-one'},
  'student-two':{...base,Id:'student-two',Role:1,FullName:'Lina Haddad',Email:'lina@example.test',StudentNumber:'20260002',ApprovedHours:160,AcademicSupervisorId:'academic-one'},
  'student-three':{...base,Id:'student-three',Role:1,FullName:'Omar Nasser',Email:'omar@example.test',StudentNumber:'20260003'},
  'student-four':{...base,Id:'student-four',Role:1,FullName:'Rania Najjar',Email:'rania@example.test',StudentNumber:'20260004'},
  'supervisor-one':{Id:'supervisor-one',Role:2,FullName:'Dina Khalil',Email:'company@campus.test',CompanyId:'company-one',CompanyName:'Training Company',IsActive:true},
  'academic-one':{Id:'academic-one',Role:3,FullName:'Nour Al-Khatib',Email:'academic@campus.test',Department:'Computer Science',IsActive:true},
  'coordinator-one':{Id:'coordinator-one',Role:4,FullName:'Hani Suleiman',Email:'coordinator@campus.test',IsActive:true},
  'student-private':{...base,Id:'student-private',Role:1,FullName:'Private cohort student',AcademicSupervisorId:'other-academic'},
  'other-supervisor':{Id:'other-supervisor',Role:2,FullName:'Other Supervisor',CompanyId:'company-two',IsActive:true}
 });
 await put('companies',{'company-one':{Id:'company-one',Name:'Training Company',IsActive:true},'company-two':{Id:'company-two',Name:'Other Company',IsActive:true}});
 const opportunity=(await(await page.request.get(db+'/opportunities/internship-one.json')).json());
 await put('opportunities/internship-one',{...opportunity,CompanySupervisorId:'supervisor-one',ApplicationDeadline:now+86400000*45,StartDate:now-86400000*30,Title:'Software Development Intern'});
 const placement={CompanyId:'company-one',CompanyName:'Training Company',CompanySupervisorId:'supervisor-one',CompanySupervisorName:'Dina Khalil',AcademicSupervisorId:'academic-one',OpportunityId:'internship-one',OpportunityTitle:'Software Development Intern',RequiredHours:160,StartDate:now-86400000*30,EndDate:now+86400000*45,ConfirmedAt:now-86400000*32,Status:2};
 await put('placements',{
  'student-one':{...placement,Id:'student-one',StudentId:'student-one',StudentName:'Osama Banihani',ApprovedHours:72},
  'student-two':{...placement,Id:'student-two',StudentId:'student-two',StudentName:'Lina Haddad',ApprovedHours:160,Status:3},
  'student-private':{...placement,Id:'student-private',StudentId:'student-private',StudentName:'Private cohort student',CompanyId:'company-two',AcademicSupervisorId:'other-academic'}
 });
 const application={CompanyId:'company-one',CompanyName:'Training Company',OpportunityId:'internship-one',OpportunityTitle:'Software Development Intern',StudentMajor:'Computer Science',CvUrl:'https://example.test/cv.pdf',CoverLetter:'I am interested in building useful, accessible web applications with the engineering team.',SubmittedAt:now-86400000,Status:0};
 await put('applications',{'application-one':{...application,Id:'application-one',StudentId:'student-one',StudentName:'Osama Banihani',Status:1,IsConfirmedByStudent:true,SubmittedAt:now-86400000*33,DecidedAt:now-86400000*32},'application-three':{...application,Id:'application-three',StudentId:'student-three',StudentName:'Omar Nasser'},'application-four':{...application,Id:'application-four',StudentId:'student-four',StudentName:'Rania Najjar',SubmittedAt:now-3600000*4}});
 const task={PlacementId:'student-one',StudentId:'student-one',CompanyId:'company-one',CreatedBySupervisorId:'supervisor-one',Description:'Build a usable, well-tested internship application experience.',Instructions:'Share a link and explain your decisions.',MaxScore:10,Weight:1,CreatedAt:now-86400000*5,Criteria:[{Id:'usability',Name:'Usability',Points:10,Weight:100}]};
 await put('tasks',{'task-next':{...task,Id:'task-next',Title:'Build an accessible application form',Deadline:now+86400000*2,Status:0},'task-review':{...task,Id:'task-review',Title:'Review the placement data model',Deadline:now+86400000,Status:1},'task-graded':{...task,Id:'task-graded',Title:'Document the API contract',Deadline:now-86400000*3,Status:5}});
 await put('submissions',{'submission-one':{Id:'submission-one',TaskId:'task-review',PlacementId:'student-one',StudentId:'student-one',AttemptNumber:1,Status:0,DescriptionText:'The updated model is ready for review.',LinkUrl:'https://example.test/review',ReportedHours:16,SubmittedAt:now-3600000*3}});
 await put('taskEvaluations',{'grade-one':{Id:'grade-one',TaskId:'task-graded',SubmissionId:'graded-submission',StudentId:'student-one',PlacementId:'student-one',TotalScore:8,MaxScore:10,Feedback:'Clear documentation.',EvaluatedAt:now-86400000*2}});
 const hours={PlacementId:'student-one',StudentId:'student-one',WorkDate:now-86400000,ReportedAt:now-86400000,Description:'Application development',Status:1};
 await put('trainingHours',{'hours-approved':{...hours,Hours:72},'hours-pending':{...hours,Hours:16,Status:0},'hours-lina':{...hours,PlacementId:'student-two',StudentId:'student-two',Hours:160}});
 await put('companyFinalEvaluations',{'final-lina':{Id:'final-lina',PlacementId:'student-two',StudentId:'student-two',CompanyId:'company-one',SupervisorId:'supervisor-one',IsSubmitted:true,TotalScore:42,MaxScore:50,OverallComment:'INTERNAL COMPANY ASSESSMENT',SubmittedAt:now-86400000}});
 await put('academicFinalEvaluations',{'academic-private':{Id:'academic-private',PlacementId:'student-private',StudentId:'student-private',AcademicSupervisorId:'other-academic',IsSubmitted:true,AcademicComments:'PRIVATE OTHER COHORT',TotalScore:19,MaxScore:20}});
 await put('completions',{'completion-one':{Id:'completion-one',PlacementId:'student-one',StudentId:'student-one',Status:1,CreatedAt:now-86400000},'completion-lina':{Id:'completion-lina',PlacementId:'student-two',StudentId:'student-two',Status:2,CreatedAt:now-86400000}});
 await put('notifications',{'student-one':{'notification-one':{Id:'notification-one',RecipientId:'student-one',Type:'Task',Title:'A new task is ready',Message:'Build an accessible application form.',Link:'~/Pages/Student/MyTasks.aspx',CreatedAt:now-3600000,IsRead:false}}});
 return {fixture:'Four-role equivalent populated UI data',approved:72,pending:16,required:160,seededAt:now};
}
