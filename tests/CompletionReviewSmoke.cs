// Synthetic, isolated fixtures only. Never connects to live Firebase.
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Web;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Services;

class CompletionReviewSmoke
{
    static int checks;
    static long now = Time.NowMs();
    static CompletionRule rule;
    static Coordinator actor = new Coordinator { Id = "coord", FullName = "Fixture Coordinator" };
    static void Check(bool ok, string message) { checks++; if (!ok) throw new Exception(message); }
    static void Denied(Action action, string message)
    {
        try { action(); }
        catch (InvalidOperationException) { checks++; return; }
        catch (UnauthorizedAccessException) { checks++; return; }
        throw new Exception(message);
    }
    static CompletionReviewEvidence Evidence()
    {
        var p = new Placement { Id="student", StudentId="student", CompanyId="company", CompanyName="Fixture Company", CompanySupervisorId="companyUser", CompanySupervisorName="Fixture Supervisor", AcademicSupervisorId="academic", StartDate=now-40L*86400000, EndDate=now-10L*86400000, Status=PlacementStatus.AwaitingCompletion };
        var policy = Json.Deserialize<CompletionRule>(Json.Serialize(rule));
        return new CompletionReviewEvidence {
            Placement=p, Student=new Student {Id="student",FullName="<script>alert('fixture')</script>",StudentNumber="0001",University=rule.University,College=rule.School,Major="Computer Engineering"}, Rule=policy,
            Record=new CompletionRecord {Id="student",StudentId=p.StudentId,PlacementId=p.Id,Status=CompletionStatus.UnderCoordinatorReview,EvaluationRuleSnapshot=policy,
                Verifications=policy.Requirements.Select(q=>new RequirementVerification {Key=q.Key,Confirmed=true,EvidenceReference="Synthetic fixture evidence",EvidenceDate=p.StartDate-86400000,CoordinatorId=actor.Id,VerifiedAt=now-1000}).ToList()},
            Company=new FinalCompanyEvaluation {Id="ce",PlacementId=p.Id,StudentId=p.StudentId,CompanyId=p.CompanyId,SupervisorId=p.CompanySupervisorId,IsSubmitted=true,SubmittedAt=now-2000,TotalScore=9,MaxScore=10,OverallComment="<img src=x onerror=alert('fixture')>CONFIDENTIAL COMPANY"},
            Academic=new FinalAcademicEvaluation {Id="ae",PlacementId=p.Id,StudentId=p.StudentId,AcademicSupervisorId=p.AcademicSupervisorId,IsSubmitted=true,SubmittedAt=now-1000,TotalScore=40,MaxScore=50,AcademicComments="CONFIDENTIAL ACADEMIC"},
            Tasks=new List<InternshipTask> {new InternshipTask {Id="task",PlacementId=p.Id,StudentId=p.StudentId,Weight=2}},
            TaskEvaluations=new List<TaskEvaluation> {new TaskEvaluation {Id="te",TaskId="task",SubmissionId="submission",PlacementId=p.Id,StudentId=p.StudentId,EvaluatedBySupervisorId=p.CompanySupervisorId,EvaluatedAt=now-3000,TotalScore=4,MaxScore=5}},
            Submissions=new List<Submission> {new Submission {Id="submission",TaskId="task",PlacementId=p.Id,StudentId=p.StudentId,SubmittedAt=now-4000}},
            Hours=new List<TrainingHoursEntry> {new TrainingHoursEntry {Id="hours",PlacementId=p.Id,StudentId=p.StudentId,Hours=160,WorkDate=p.StartDate+86400000,Status=HoursStatus.Approved,ReviewedById="academic",ReviewedAt=now-5000}}
        };
    }
    static void UnitChecks(string output)
    {
        var e=Evidence(); var a=CompletionReviewService.Assess(e,now);
        Check(a.CanApprove && Math.Abs(a.Score.Value-84.5)<.001 && e.Record.Status!=CompletionStatus.Approved,"Mixed scales or separation of evaluation and approval failed");
        CompletionReviewService.ValidateDecision(actor,e,CompletionStatus.Approved,"",now); checks++;
        e.Company=null; a=CompletionReviewService.Assess(e,now); Check(!a.CanApprove&&!a.CompanyPercent.HasValue,"Missing company evaluation counted as zero or approved");
        e=Evidence();e.Academic.IsSubmitted=false;Check(!CompletionReviewService.Assess(e,now).CanApprove,"Draft academic evaluation accepted");
        e=Evidence();e.Hours[0].Status=HoursStatus.Reported;Check(!CompletionReviewService.Assess(e,now).CanApprove,"Unapproved hours accepted");
        e=Evidence();e.Hours[0].ReviewedById=null;Check(!CompletionReviewService.Assess(e,now).CanApprove,"Hours without reviewer accepted");
        e=Evidence();e.Record.Verifications.First(v=>v.Key=="documents").Confirmed=false;Check(!CompletionReviewService.Assess(e,now).CanApprove,"Missing documents accepted");
        e=Evidence();e.Record.Verifications[0].EvidenceReference="";Check(!CompletionReviewService.Assess(e,now).CanApprove,"Checkbox without evidence accepted");
        e=Evidence();e.Record.Verifications.First(v=>v.Key=="prior-approval").EvidenceDate=e.Placement.StartDate+1;Check(!CompletionReviewService.Assess(e,now).CanApprove,"Late approval accepted");
        e=Evidence();Denied(()=>CompletionReviewService.ValidateDecision(actor,e,CompletionStatus.NeedsCorrections,"",now),"Corrections without note accepted");
        CompletionReviewService.ValidateDecision(actor,e,CompletionStatus.NeedsCorrections,"Synthetic reason",now);checks++;
        Denied(()=>CompletionReviewService.ValidateDecision(actor,e,CompletionStatus.Rejected,"",now),"Rejection without note accepted");
        e.Record.Status=CompletionStatus.Approved;Denied(()=>CompletionReviewService.ValidateDecision(actor,e,CompletionStatus.Approved,"",now),"Duplicate approval accepted");
        Denied(()=>CompletionReviewService.ValidateDecision(new Student {Id="student"},Evidence(),CompletionStatus.Approved,"",now),"Student approval accepted");
        Denied(()=>CompletionReviewService.ValidateDecision(new AcademicSupervisor {Id="academic"},Evidence(),CompletionStatus.Approved,"",now),"Academic approval accepted");
        e=Evidence();e.Rule=null;a=CompletionReviewService.Assess(e,now);Check(!a.CanApprove&&!a.Score.HasValue&&a.Issues.Any(x=>x.Contains("No default")),"Missing configuration silently defaulted");
        e=Evidence();e.Rule.RequiredHours=300;e.Rule.RequiredDurationDays=140;e.Rule.InternshipType="Synthetic International";Check(!CompletionReviewService.Assess(e,now).CanApprove,"International duration ignored");
        e=Evidence();e.Rule.RequiredHours=80;e.Rule.RequiredDurationDays=0;e.Hours[0].Hours=80;Check(CompletionReviewService.Assess(e,now).CanApprove,"Universal 160-hour minimum imposed");
        e=Evidence();e.Rule.EvaluationMethod="EvidenceOnly";e.Rule.RequireCurrentTaskGrades=false;e.Company.MaxScore=e.Academic.MaxScore=0;e.Tasks.Clear();a=CompletionReviewService.Assess(e,now);Check(a.CanApprove&&!a.Score.HasValue,"Evidence-only method imposed numeric grade");
        e=Evidence();e.Company.TotalScore=double.NaN;Check(!CompletionReviewService.Assess(e,now).CanApprove,"NaN accepted");
        e=Evidence();e.Rule.PassingPercent=null;Check(!CompletionReviewService.Assess(e,now).CanApprove,"Missing passing criterion defaulted");
        e=Evidence();e.TaskEvaluations[0].SubmissionId="old";Check(!CompletionReviewService.Assess(e,now).CanApprove,"Stale task grade accepted");
        e=Evidence();e.TaskEvaluations[0].EvaluatedBySupervisorId="other";Check(!CompletionReviewService.Assess(e,now).CanApprove,"Unassigned task evaluator accepted");
        e=Evidence();e.Placement.EndDate=now+86400000;Check(!CompletionReviewService.Assess(e,now).CanApprove,"Future training approved");
        e=Evidence();e.Record.Status=CompletionStatus.Approved;e.Record.Result="Pass";e.Record.ApprovedAt=now;
        e.Record.ApprovedHours=160;e.Record.RequiredHours=160;
        e.Record.DocumentSnapshot=new CompletionDocumentSnapshot {StudentName="Approved Fixture",StudentNumber="0001",Program="Computer Engineering",CompanyName="Approved Company",StartDate=e.Placement.StartDate,EndDate=e.Placement.EndDate};
        e.Record.ReportFileUrl=PdfReportService.GenerateCompletionReport(e.Record,e.Student);
        byte[] first=PdfReportService.CreateCompletionReportPdf(e.Record,e.Student,e.Placement);
        e.Student.FullName="Changed";e.Placement.CompanyName="Changed";
        Check(first.SequenceEqual(PdfReportService.CreateCompletionReportPdf(e.Record,e.Student,e.Placement)),"Approved report changed with profile");
        File.WriteAllBytes(Path.Combine(output,"completion-report.pdf"),first);
        File.WriteAllBytes(Path.Combine(output,"completion-certificate.pdf"),PdfReportService.CreateCertificatePdf(e.Record,e.Student,e.Placement));
        Check(PdfReportService.MayDownload(e.Record,e.Student)&&!PdfReportService.MayDownload(e.Record,new Student {Id="other"}),"PDF ownership failed");
    }
    static readonly Dictionary<string,Dictionary<string,object>> db=new Dictionary<string,Dictionary<string,object>>();
    static readonly Dictionary<string,int> versions=new Dictionary<string,int>();
    static void Seed()
    {
        var e=Evidence();
        db["users"]=new Dictionary<string,object>{{"student",e.Student},{"coord",actor},{"academic",new AcademicSupervisor {Id="academic",FullName="Fixture Academic"}},{"companyUser",new CompanySupervisor {Id="companyUser",CompanyId="company",FullName="Fixture Company Supervisor"}}};
        db["placements"]=new Dictionary<string,object>{{"student",e.Placement}};
        db["completions"]=new Dictionary<string,object>();
        db["companyFinalEvaluations"]=new Dictionary<string,object>{{"ce",e.Company}};
        db["academicFinalEvaluations"]=new Dictionary<string,object>{{"ae",e.Academic}};
        db["tasks"]=new Dictionary<string,object>{{"task",e.Tasks[0]}};
        db["taskEvaluations"]=new Dictionary<string,object>{{"te",e.TaskEvaluations[0]}};
        db["submissions"]=new Dictionary<string,object>{{"submission",e.Submissions[0]}};
        db["trainingHours"]=new Dictionary<string,object>{{"hours",e.Hours[0]}};
        db["academicComments"]=new Dictionary<string,object>();db["studentGroups"]=new Dictionary<string,object>();
    }
    static Dictionary<string,object> Map(object value) { return Json.ToMap(Json.Serialize(value)); }
    static CompletionRecord Stored() { return Json.Deserialize<CompletionRecord>(Json.Serialize(db["completions"]["student"])); }
    static void Serve(TcpListener listener)
    {
        while(true) {
            TcpClient client;try{client=listener.AcceptTcpClient();}catch(SocketException){return;}
            using(client)using(var stream=client.GetStream()) {
                var reader=new StreamReader(stream,Encoding.UTF8,false,1024,true);string line=reader.ReadLine();if(line==null)continue;
                string[] request=line.Split(' ');var headers=new Dictionary<string,string>(StringComparer.OrdinalIgnoreCase);
                while(!string.IsNullOrEmpty(line=reader.ReadLine())){int n=line.IndexOf(':');if(n>0)headers[line.Substring(0,n)]=line.Substring(n+1).Trim();}
                string body="",length;if(headers.TryGetValue("Content-Length",out length)){char[] chars=new char[int.Parse(length)];int used=0;while(used<chars.Length){int got=reader.Read(chars,used,chars.Length-used);if(got==0)break;used+=got;}body=new string(chars,0,used);}
                var url=new Uri("http://localhost:19083"+request[1]);var query=HttpUtility.ParseQueryString(url.Query);
                string path=url.AbsolutePath.Trim('/').Replace(".json","");string[] parts=path.Split('/');int v;versions.TryGetValue(path,out v);string etag="\""+v+"\"",status="200 OK",result="null";
                Dictionary<string,object> collection;if(!db.TryGetValue(parts[0],out collection))collection=new Dictionary<string,object>();
                if(request[0]=="PUT"||request[0]=="PATCH") {
                    string match;if(headers.TryGetValue("if-match",out match)&&match!=etag)status="412 Precondition Failed";
                    else {object value=Json.ToMap(body);if(request[0]=="PATCH"&&collection.ContainsKey(parts[1])){var old=Map(collection[parts[1]]);foreach(var kv in (Dictionary<string,object>)value)old[kv.Key]=kv.Value;value=old;}collection[parts[1]]=value;db[parts[0]]=collection;versions[path]=v+1;result=Json.Serialize(value);}
                } else if(parts.Length>1){object value;if(collection.TryGetValue(parts[1],out value))result=Json.Serialize(value);}
                else {string order=(query["orderBy"]??"").Trim('"'),equal=(query["equalTo"]??"").Trim('"');result=Json.Serialize(collection.Where(kv=>order.Length==0||(Map(kv.Value).ContainsKey(order)&&Convert.ToString(Map(kv.Value)[order],CultureInfo.InvariantCulture)==equal)).ToDictionary(kv=>kv.Key,kv=>kv.Value));}
                byte[] payload=Encoding.UTF8.GetBytes(result),header=Encoding.ASCII.GetBytes("HTTP/1.1 "+status+"\r\nETag: "+etag+"\r\nContent-Type: application/json\r\nConnection: close\r\nContent-Length: "+payload.Length+"\r\n\r\n");stream.Write(header,0,header.Length);stream.Write(payload,0,payload.Length);
            }
        }
    }
    static HttpWebResponse Request(string root,CookieContainer cookies,string path,string post=null)
    {
        var r=(HttpWebRequest)WebRequest.Create(root+path);r.CookieContainer=cookies;r.AllowAutoRedirect=false;r.Timeout=30000;
        if(post!=null){r.Method="POST";r.ContentType="application/x-www-form-urlencoded";byte[] b=Encoding.UTF8.GetBytes(post);using(var s=r.GetRequestStream())s.Write(b,0,b.Length);}
        try{return (HttpWebResponse)r.GetResponse();}catch(WebException ex){if(ex.Response==null)throw;using(var reader=new StreamReader(ex.Response.GetResponseStream()))throw new Exception(reader.ReadToEnd());}
    }
    static string Body(HttpWebResponse response){using(response)using(var reader=new StreamReader(response.GetResponseStream()))return reader.ReadToEnd();}
    static string Form(string html,string action,Dictionary<string,string> extra=null)
    {
        var fields=new Dictionary<string,string>();
        foreach(Match m in Regex.Matches(html,"<input[^>]+type=\"hidden\"[^>]*>")){string name=Regex.Match(m.Value,"name=\"([^\"]+)\"").Groups[1].Value;fields[name]=HttpUtility.HtmlDecode(Regex.Match(m.Value,"value=\"([^\"]*)\"").Groups[1].Value);}
        fields["ctl00$MainContent$"+action]="click";
        if(extra!=null)foreach(var f in extra)fields[f.Key.StartsWith("ctl00$")?f.Key:"ctl00$MainContent$"+f.Key]=f.Value;
        return string.Join("&",fields.Select(kv=>HttpUtility.UrlEncode(kv.Key)+"="+HttpUtility.UrlEncode(kv.Value)));
    }
    static CookieContainer Login(string root,string id){var c=new CookieContainer();Body(Request(root,c,"/FixtureLogin.aspx?id="+id));return c;}
    static void HttpChecks(string root,string output)
    {
        string page="/Pages/Coordinator/CompletionReview.aspx?id=student";
        var student=Login(root,"student");using(var denied=Request(root,student,page))Check(denied.StatusCode==HttpStatusCode.Redirect&&denied.Headers["Location"].Contains("AccessDenied"),"Student accessed coordinator review");
        var company=Login(root,"companyUser");using(var denied=Request(root,company,page))Check(denied.StatusCode==HttpStatusCode.Redirect,"Company accessed coordinator review");
        string companyHtml=Body(Request(root,company,"/Pages/Company/FinalEvaluation.aspx?id=student"));Check(companyHtml.Contains("Final evaluation submitted")&&!companyHtml.Contains("CONFIDENTIAL ACADEMIC"),"Company evaluation workflow failed");
        var academic=Login(root,"academic");Check(Body(Request(root,academic,"/Pages/Academic/FinalEvaluation.aspx?id=student")).Contains("CONFIDENTIAL COMPANY"),"Academic workflow did not receive company evaluation");
        var cookies=Login(root,"coord");string html=Body(Request(root,cookies,page));File.WriteAllText(Path.Combine(output,"review-initial.html"),html);
        Check(html.Contains("No default evaluation policy")&&html.Contains("&lt;script&gt;")&&!html.Contains("<script>alert('fixture')"),"Missing configuration or HTML encoding failed");
        html=Body(Request(root,cookies,page,Form(html,"btnRule",new Dictionary<string,string>{{"ddlRule",rule.Id}})));
        Check(html.Contains("Review configuration saved")&&html.Contains("Project-Proposed"),"Configuration save failed");
        var fields=new Dictionary<string,string>();foreach(Match m in Regex.Matches(html,"<input[^>]+type=\"checkbox\"[^>]*>")){string name=Regex.Match(m.Value,"name=\"([^\"]+)\"").Groups[1].Value;fields[name]="on";fields[name.Replace("confirmed","evidenceReference")]="Synthetic archive evidence";string dateName=name.Replace("confirmed","evidenceDate");if(html.Contains("name=\""+dateName+"\""))fields[dateName]=Time.FromUnixMs(now-45L*86400000).ToString("yyyy-MM-dd");}
        html=Body(Request(root,cookies,page,Form(html,"btnVerify",fields)));Check(html.Contains("Evidence verification saved"),"Verification postback failed");
        Check(Stored().Verifications.Count==rule.Requirements.Count&&Stored().Verifications.All(v=>v.CoordinatorId==actor.Id&&v.VerifiedAt>0),"Evidence audit missing");
        string stale=html;Check(Body(Request(root,cookies,page,Form(html,"btnCorrections"))).Contains("A reason is required"),"HTTP corrections accepted missing reason");
        html=Body(Request(root,cookies,page,Form(html,"btnCorrections",new Dictionary<string,string>{{"txtCoordinatorNote","Synthetic corrections reason"}})));
        Check(Stored().Status==CompletionStatus.NeedsCorrections&&Stored().Result==null&&Stored().ReportFileUrl==null&&Stored().CertificateFileUrl==null,"Corrections released PDF or academic failure");
        string correctionProgress=Body(Request(root,student,"/Pages/Student/Progress.aspx"));
        Check(correctionProgress.Contains("Needs Corrections")&&correctionProgress.Contains("Synthetic corrections reason"),"Student did not receive actionable correction details");
        Check(Body(Request(root,cookies,page,Form(stale,"btnApprove"))).Contains("review has changed"),"Stale form overwrote review");
        html=Body(Request(root,cookies,page,Form(html,"btnApprove")));var approved=Stored();
        Check(approved.Status==CompletionStatus.Approved&&approved.ApprovedAt>0&&approved.ReviewedByCoordinatorId==actor.Id&&approved.ReportFileUrl!=null&&approved.DocumentSnapshot!=null,"Eligible HTTP approval failed");
        Check(!html.Contains("value=\"Approve Internship Completion\"")&&html.Contains("Approved Documents"),"Approved record is editable");
        Check(Body(Request(root,cookies,page,Form(stale,"btnApprove"))).Contains("final decision")&&Stored().AuditTrail.Count==approved.AuditTrail.Count,"Duplicate approval modified record");
        string progress=Body(Request(root,student,"/Pages/Student/Progress.aspx"));Check(!progress.Contains("CONFIDENTIAL COMPANY")&&!progress.Contains("CONFIDENTIAL ACADEMIC"),"Student viewed confidential evaluations");
        foreach(string route in new[]{"/Pages/Student/Progress.aspx?report=1","/Pages/Coordinator/CompletionReview.aspx?report=student","/Pages/Coordinator/CompletionReview.aspx?certificate=student"})using(var pdf=Request(root,route.Contains("Student")?student:cookies,route))Check(pdf.ContentType=="application/pdf","Protected PDF download failed");
        string etag;FirebaseContext.GetVersioned("completions/student",out etag);Check(FirebaseContext.PutIfVersion("completions/student",approved,etag),"Conditional Firebase write failed");Check(!FirebaseContext.PutIfVersion("completions/student",approved,etag),"Stale ETag overwrite accepted");
        File.WriteAllText(Path.Combine(output,"review-approved.html"),html);
        db["completions"]["student"]=Evidence().Record;versions["completions/student"]++;
        html=Body(Request(root,cookies,page));Check(Body(Request(root,cookies,page,Form(html,"btnReject"))).Contains("A reason is required"),"HTTP rejection accepted missing reason");
        html=Body(Request(root,cookies,page,Form(html,"btnReject",new Dictionary<string,string>{{"txtCoordinatorNote","Synthetic rejection reason"}})));
        Check(Stored().Status==CompletionStatus.Rejected&&Stored().Result==null&&Stored().ReportFileUrl==null,"Rejection released a PDF or academic failure");
        Check(Body(Request(root,student,"/FixtureConfidential.aspx"))=="DENIED","Repository allowed student to read final evaluation");
        db["completions"].Clear();db["companyFinalEvaluations"].Clear();db["academicFinalEvaluations"].Clear();
        string companyForm=Body(Request(root,company,"/Pages/Company/FinalEvaluation.aspx?id=student"));
        string companySaved=Body(Request(root,company,"/Pages/Company/FinalEvaluation.aspx?id=student",Form(companyForm,"btnSubmit",new Dictionary<string,string>{{"ddlPlacement","student"},{"txtScore","18"},{"txtMaximum","20"},{"txtComments","Synthetic company review"}})));
        Check(companySaved.Contains("submitted successfully")&&Json.Deserialize<FinalCompanyEvaluation>(Json.Serialize(db["companyFinalEvaluations"]["student"])).SupervisorId=="companyUser","Company submission postback failed");
        string academicForm=Body(Request(root,academic,"/Pages/Academic/FinalEvaluation.aspx?id=student"));
        string academicSaved=Body(Request(root,academic,"/Pages/Academic/FinalEvaluation.aspx?id=student",Form(academicForm,"btnSubmit",new Dictionary<string,string>{{"ddlPlacement","student"},{"txtScore","7"},{"txtMaximum","10"},{"txtComments","Synthetic academic review"}})));
        var submitted=Json.Deserialize<FinalAcademicEvaluation>(Json.Serialize(db["academicFinalEvaluations"]["student"]));
        Check(academicSaved.Contains("submitted successfully")&&submitted.IsSubmitted&&submitted.SubmittedAt>0&&submitted.AcademicSupervisorId=="academic","Academic submission postback failed");
    }
    static int Main(string[] args)
    {
        Process iis=null;var listener=new TcpListener(IPAddress.Loopback,19083);
        try {
            string app=Path.GetFullPath(args[0]),output=Path.GetFullPath(args[1]);Directory.CreateDirectory(output);
            rule=Json.Deserialize<List<CompletionRule>>(File.ReadAllText(Path.Combine(app,"App_Data/completion-rules.json")))[0];UnitChecks(output);Seed();
            listener.Start();new Thread(()=>Serve(listener)){IsBackground=true}.Start();string host=Path.Combine(output,"web");Directory.CreateDirectory(host);
            foreach(string folder in new[]{"Layout","Pages","Assets","App_Data","bin"})foreach(string file in Directory.GetFiles(Path.Combine(app,folder),"*",SearchOption.AllDirectories)){string target=Path.Combine(host,file.Substring(app.Length+1));Directory.CreateDirectory(Path.GetDirectoryName(target));File.Copy(file,target,true);}
            File.WriteAllText(Path.Combine(host,"Web.config"),"<configuration><appSettings><add key='Firebase.DatabaseUrl' value='http://localhost:19083'/><add key='Firebase.ApiKey' value='fixture'/></appSettings><system.web><compilation debug='true' targetFramework='4.7.2'/><httpRuntime targetFramework='4.7.2'/><customErrors mode='Off'/></system.web></configuration>");
            File.WriteAllText(Path.Combine(host,"FixtureLogin.aspx"),"<%@ Page Language=\"C#\" %><%@ Import Namespace=\"InternshipManagementSystem.Data\" %><%@ Import Namespace=\"InternshipManagementSystem.Security\" %><script runat=\"server\">protected void Page_Load(object sender,EventArgs e){SessionHelper.SignIn(new UserRepository().GetPerson(Request.QueryString[\"id\"]),Request.QueryString[\"id\"]);Response.Write(\"Fixture ready\");}</script>");
            File.WriteAllText(Path.Combine(host,"FixtureConfidential.aspx"),"<%@ Page Language=\"C#\" %><%@ Import Namespace=\"InternshipManagementSystem.Data\" %><script runat=\"server\">protected void Page_Load(object sender,EventArgs e){try{new EvaluationRepository().GetCompanyFinalForPlacement(\"student\");Response.Write(\"EXPOSED\");}catch(UnauthorizedAccessException){Response.Write(\"DENIED\");}}</script>");
            var log=new StringBuilder();
            iis=Process.Start(new ProcessStartInfo {FileName=@"C:\Program Files\IIS Express\iisexpress.exe",Arguments="/path:\""+host+"\" /port:19084 /systray:false",UseShellExecute=false,CreateNoWindow=true,RedirectStandardOutput=true,RedirectStandardError=true});
            iis.OutputDataReceived+=(s,e)=>{lock(log)log.AppendLine(e.Data);};iis.ErrorDataReceived+=(s,e)=>{lock(log)log.AppendLine(e.Data);};iis.BeginOutputReadLine();iis.BeginErrorReadLine();bool ready=false;
            for(int attempt=0;attempt<10&&!ready;attempt++){try{Body(Request("http://localhost:19084",new CookieContainer(),"/FixtureLogin.aspx?id=coord"));ready=true;}catch{if(iis.HasExited)throw new Exception("IIS exited: "+log);Thread.Sleep(400);}}
            Check(ready,"IIS fixture did not start");HttpChecks("http://localhost:19084",output);Console.WriteLine("PASS: "+checks+" completion review checks. Fixture artifacts: "+output);return 0;
        }catch(Exception ex){Console.Error.WriteLine(ex);return 1;}finally{listener.Stop();if(iis!=null&&!iis.HasExited){iis.Kill();iis.WaitForExit();}}
    }
}
