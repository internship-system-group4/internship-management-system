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
            Placement=p, Student=new Student {Id="student",FullName="<script>alert('fixture')</script>",StudentNumber="0001",University=rule.University,College=rule.School,Major="Computer Engineering",AcademicSupervisorId="academic"}, Rule=policy,
            Record=new CompletionRecord {Id="student",StudentId=p.StudentId,PlacementId=p.Id,Status=CompletionStatus.UnderCoordinatorReview,EvaluationRuleSnapshot=policy,
                Verifications=policy.Requirements.Select(q=>new RequirementVerification {Key=q.Key,Confirmed=true,EvidenceReference="Synthetic fixture evidence",EvidenceDate=p.StartDate-86400000,CoordinatorId=actor.Id,VerifiedAt=now-1000}).ToList()},
            Company=new FinalCompanyEvaluation {Id="ce",PlacementId=p.Id,StudentId=p.StudentId,CompanyId=p.CompanyId,SupervisorId=p.CompanySupervisorId,IsSubmitted=true,SubmittedAt=now-2000,TotalScore=9,MaxScore=10,OverallComment="<img src=x onerror=alert('fixture')>CONFIDENTIAL COMPANY"},
            Academic=new FinalAcademicEvaluation {Id="ae",PlacementId=p.Id,StudentId=p.StudentId,AcademicSupervisorId=p.AcademicSupervisorId,IsSubmitted=true,SubmittedAt=now-1000,TotalScore=40,MaxScore=50,AcademicComments="CONFIDENTIAL ACADEMIC"},
            Tasks=new List<InternshipTask> {new InternshipTask {Id="task",PlacementId=p.Id,StudentId=p.StudentId,CompanyId=p.CompanyId,Status=InternshipTaskStatus.Graded,Weight=2}},
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
        foreach(int worked in new[]{0,80,159}) {
            e=Evidence();e.Placement.RequiredHours=e.Student.RequiredHours=e.Rule.RequiredHours=80;e.Rule.RequiredDurationDays=0;e.Hours[0].Hours=worked;
            a=CompletionReviewService.Assess(e,now);Check(!a.CanApprove&&a.RequiredHours==160,"Sub-160 requirement bypassed minimum");
            Denied(()=>CompletionReviewService.ValidateDecision(actor,e,CompletionStatus.Approved,"",now),"Server approved fewer than 160 hours");
        }
        e=Evidence();e.Rule.RequiredHours=0;e.Rule.RequiredDurationDays=28;e.Hours.Clear();Check(!CompletionReviewService.Assess(e,now).CanApprove,"Duration-only rule bypassed hours");
        e=Evidence();e.Placement.RequiredHours=240;Check(!CompletionReviewService.Assess(e,now).CanApprove,"Higher placement requirement ignored");
        e=Evidence();e.Student.RequiredHours=240;Check(!CompletionReviewService.Assess(e,now).CanApprove,"Higher student requirement ignored");
        e=Evidence();e.Rule.RequiredHours=240;Check(!CompletionReviewService.Assess(e,now).CanApprove,"Higher rule requirement ignored");
        e=Evidence();e.Placement.RequiredHours=e.Student.RequiredHours=e.Rule.RequiredHours=80;Check(CompletionReviewService.Assess(e,now).CanApprove,"Exactly 160 approved hours blocked");
        e=Evidence();e.Hours[0].ReviewedAt=now+1;Check(!CompletionReviewService.Assess(e,now).CanApprove,"Future approval counted");
        e=Evidence();e.Hours[0].WorkDate=e.Placement.StartDate-1;Check(!CompletionReviewService.Assess(e,now).CanApprove,"Out-of-period work counted");
        e=Evidence();e.Hours[0].StudentId="other";Check(!CompletionReviewService.Assess(e,now).CanApprove,"Another student's hours counted");
        e=Evidence();e.Hours[0].PlacementId="other";Check(!CompletionReviewService.Assess(e,now).CanApprove,"Another placement's hours counted");
        e=Evidence();e.Hours[0].Hours=-160;Check(!CompletionReviewService.Assess(e,now).CanApprove,"Negative hours counted");
        e=Evidence();e.Placement.CompanyName=" ";Check(!CompletionReviewService.Assess(e,now).CanApprove,"Missing company name approved");
        e=Evidence();e.Company.SupervisorId="other";Check(!CompletionReviewService.Assess(e,now).CanApprove,"Wrong company supervisor accepted");
        e=Evidence();e.Academic.AcademicSupervisorId="other";Check(!CompletionReviewService.Assess(e,now).CanApprove,"Wrong academic supervisor accepted");
        e=Evidence();e.Hours[0].Hours=159;
        var progress=new PlacementProgressData {Overview=new PlacementOverview {Placement=e.Placement,Student=e.Student,ApprovedHours=999},Completion=e.Record,
            CompanyFinal=e.Company,AcademicFinal=e.Academic,Tasks=e.Tasks,Evaluations=e.TaskEvaluations,Submissions=e.Submissions,Hours=e.Hours};
        Check(!CompletionService.Summarise(progress).CanApprove&&CompletionService.Summarise(progress).ApprovedHours==159,"Legacy service trusted cached hours");
        e=Evidence();e.Rule.EvaluationMethod="EvidenceOnly";e.Rule.RequireCurrentTaskGrades=false;e.Company.MaxScore=e.Academic.MaxScore=0;e.Tasks.Clear();a=CompletionReviewService.Assess(e,now);Check(a.CanApprove&&!a.Score.HasValue,"Evidence-only method imposed numeric grade");
        e=Evidence();e.Company.TotalScore=double.NaN;Check(!CompletionReviewService.Assess(e,now).CanApprove,"NaN accepted");
        e=Evidence();e.Rule.PassingPercent=null;Check(!CompletionReviewService.Assess(e,now).CanApprove,"Missing passing criterion defaulted");
        e=Evidence();e.TaskEvaluations[0].SubmissionId="old";Check(!CompletionReviewService.Assess(e,now).CanApprove,"Stale task grade accepted");
        e=Evidence();e.TaskEvaluations[0].EvaluatedBySupervisorId="other";Check(!CompletionReviewService.Assess(e,now).CanApprove,"Unassigned task evaluator accepted");
        e=Evidence();e.Placement.EndDate=now+86400000;Check(!CompletionReviewService.Assess(e,now).CanApprove,"Future training approved");
        e=Evidence();e.Record.Status=CompletionStatus.Approved;e.Record.Result="Pass";e.Record.ApprovedAt=now;
        e.Record.ApprovedHours=160;e.Record.RequiredHours=160;
        e.Record.DocumentSnapshot=new CompletionDocumentSnapshot {StudentName="Approved Fixture",StudentNumber="0001",Program="Computer Engineering",CompanyName="Approved Company",StartDate=e.Placement.StartDate,EndDate=e.Placement.EndDate};
        e.Record.ReportFileUrl=PdfReportService.ReportUrl(e.Record.Id);
        byte[] first=PdfReportService.GenerateCompletionReport(e.Record,e.Student,e.Placement,actor.FullName);
        e.Student.FullName="Changed";e.Placement.CompanyName="Changed";
        Check(first.SequenceEqual(PdfReportService.GenerateCompletionReport(e.Record,e.Student,e.Placement,actor.FullName)),"Approved report changed with profile");
        File.WriteAllBytes(Path.Combine(output,"completion-report.pdf"),first);
        File.WriteAllBytes(Path.Combine(output,"completion-certificate.pdf"),PdfReportService.GenerateCertificate(e.Record,e.Student,e.Placement,actor.FullName));
        Check(PdfReportService.MayDownload(e.Record,e.Student)&&!PdfReportService.MayDownload(e.Record,new Student {Id="other"}),"PDF ownership failed");
        e.Record.StudentName="سارة الرجوب";
        e.Record.CompanyName="شركة التدريب";
        byte[] arabicReport=PdfReportService.GenerateCompletionReport(e.Record,e.Student,e.Placement,actor.FullName);
        byte[] arabicCertificate=PdfReportService.GenerateCertificate(e.Record,e.Student,e.Placement,actor.FullName);
        string nameHex="FEFF"+BitConverter.ToString(Encoding.BigEndianUnicode.GetBytes(e.Record.StudentName)).Replace("-", "");
        Check(Encoding.ASCII.GetString(arabicReport).Contains("/ActualText <"+nameHex+">"),"Arabic report name was lost");
        Check(Encoding.ASCII.GetString(arabicCertificate).Contains("/ActualText <"+nameHex+">"),"Arabic certificate name was lost");
        Check(SimplePdf.TextWidth(e.Record.StudentName,26,true)>0,"Arabic glyph measurement failed");
        File.WriteAllBytes(Path.Combine(output,"completion-report-arabic.pdf"),arabicReport);
        File.WriteAllBytes(Path.Combine(output,"completion-certificate-arabic.pdf"),arabicCertificate);
    }
    static readonly Dictionary<string,Dictionary<string,object>> db=new Dictionary<string,Dictionary<string,object>>();
    static readonly Dictionary<string,int> versions=new Dictionary<string,int>();
    static void Seed()
    {
        var e=Evidence();
        e.Placement.CompanyName=null;e.Placement.RequiredHours=80;e.Placement.ApprovedHours=999;
        db["companies"]=new Dictionary<string,object>{{"company",new Company {Id="company",Name="Fixture & Company"}}};
        db["opportunities"]=new Dictionary<string,object>();
        db["applications"]=new Dictionary<string,object>();
        db["users"]=new Dictionary<string,object>{{"student",e.Student},{"other",new Student {Id="other",FullName="Other fixture student"}},{"coord",actor},{"academic",new AcademicSupervisor {Id="academic",FullName="Fixture Academic"}},{"companyUser",new CompanySupervisor {Id="companyUser",CompanyId="company",FullName="Fixture Company Supervisor"}}};
        db["placements"]=new Dictionary<string,object>{{"student",e.Placement}};
        db["completions"]=new Dictionary<string,object>();
        db["companyFinalEvaluations"]=new Dictionary<string,object>{{"ce",e.Company}};
        db["academicFinalEvaluations"]=new Dictionary<string,object>{{"ae",e.Academic}};
        db["tasks"]=new Dictionary<string,object>{{"task",e.Tasks[0]}};
        db["taskEvaluations"]=new Dictionary<string,object>{{"te",e.TaskEvaluations[0]}};
        db["submissions"]=new Dictionary<string,object>{{"submission",e.Submissions[0]}};
        db["trainingHours"]=new Dictionary<string,object>{{"hours",e.Hours[0]}};
        db["academicComments"]=new Dictionary<string,object>();db["studentGroups"]=new Dictionary<string,object>();
        db["notifications"]=new Dictionary<string,object>();
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
                if(parts.Length>2) {
                    object existing;var rootMap=collection.TryGetValue(parts[1],out existing)?Map(existing):new Dictionary<string,object>();
                    var parent=rootMap;
                    for(int i=2;i<parts.Length-1;i++) {
                        object child;var nested=parent.TryGetValue(parts[i],out child)?Map(child):new Dictionary<string,object>();
                        parent[parts[i]]=nested;parent=nested;
                    }
                    string leaf=parts[parts.Length-1];
                    if(request[0]=="GET") {object value;if(parent.TryGetValue(leaf,out value))result=Json.Serialize(value);}
                    else {parent[leaf]=Json.Deserialize<object>(body);collection[parts[1]]=rootMap;db[parts[0]]=collection;versions[path]=v+1;result=body;}
                } else if(request[0]=="POST"&&parts.Length==2) {
                    object existing;var recipient=collection.TryGetValue(parts[1],out existing)?Map(existing):new Dictionary<string,object>();
                    string key="notice-"+(recipient.Count+1);recipient[key]=Json.Deserialize<object>(body);
                    collection[parts[1]]=recipient;db[parts[0]]=collection;result=Json.Serialize(new Dictionary<string,string>{{"name",key}});
                } else if(request[0]=="PATCH"&&parts.Length==1) {
                    foreach(var update in Json.ToMap(body)) {
                        string[] keys=update.Key.Split('/');
                        if(keys.Length!=2)throw new Exception("Unexpected fixture multi-path write");
                        object existing;var recipient=collection.TryGetValue(keys[0],out existing)?Map(existing):new Dictionary<string,object>();
                        recipient[keys[1]]=update.Value;collection[keys[0]]=recipient;
                    }
                    db[parts[0]]=collection;versions[path]=v+1;result=body;
                } else if(request[0]=="PUT"||request[0]=="PATCH") {
                    string match;if(headers.TryGetValue("if-match",out match)&&match!=etag&&!(match=="null_etag"&&!collection.ContainsKey(parts[1])))status="412 Precondition Failed";
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
        if(extra!=null)foreach(var f in extra)fields[(f.Key.StartsWith("ctl00$")||f.Key.StartsWith("__"))?f.Key:"ctl00$MainContent$"+f.Key]=f.Value;
        return string.Join("&",fields.Select(kv=>HttpUtility.UrlEncode(kv.Key)+"="+HttpUtility.UrlEncode(kv.Value)));
    }
    static CookieContainer Login(string root,string id){var c=new CookieContainer();Body(Request(root,c,"/FixtureLogin.aspx?id="+id));return c;}
    static string PostPage(string root, CookieContainer cookies, string path, string html, string action, Dictionary<string,string> extra=null)
    {
        using (var response=Request(root,cookies,path,Form(html,action,extra)))
        {
            if (response.StatusCode==HttpStatusCode.Redirect)
                return Body(Request(root,cookies,new Uri(new Uri(root),response.Headers["Location"]).PathAndQuery));
            return new StreamReader(response.GetResponseStream()).ReadToEnd();
        }
    }
    static void HttpChecks(string root,string output)
    {
        string review="/Pages/Coordinator/CompletionReview.aspx?id=student";
        var student=Login(root,"student");
        using(var denied=Request(root,student,review))Check(denied.StatusCode==HttpStatusCode.Redirect&&denied.Headers["Location"].Contains("AccessDenied"),"Student accessed coordinator review");
        var company=Login(root,"companyUser");
        using(var denied=Request(root,company,review))Check(denied.StatusCode==HttpStatusCode.Redirect,"Company accessed coordinator review");
        string companyPage="/Pages/Company/FinalEvaluation.aspx?id=student";
        string html=Body(Request(root,company,companyPage));
        Check(html.Contains("Send approved certificate to trainee"),"Company certificate sharing action did not render");
        Check(html.Contains("Final evaluation submitted")&&!html.Contains("CONFIDENTIAL ACADEMIC"),"Company submitted evaluation state or confidentiality failed");
        var academic=Login(root,"academic");
        Check(Body(Request(root,academic,"/Pages/Academic/FinalEvaluation.aspx?id=student")).Contains("CONFIDENTIAL COMPANY"),"Assigned academic cannot see company evidence");
        Check(!Body(Request(root,student,"/Pages/Student/Progress.aspx")).Contains("CONFIDENTIAL COMPANY"),"Student viewed confidential final evaluation");
        Check(Body(Request(root,student,"/FixtureConfidential.aspx"))=="DENIED","Repository allowed confidential student read");
        // Submit the actual current company form. It must not finalize the placement.
        db["companyFinalEvaluations"].Clear();db["academicFinalEvaluations"].Clear();
        html=Body(Request(root,company,companyPage));
        var scores=new Dictionary<string,string>{{"ddlTrainees","student"},{"txtTechSkills","36"},{"txtWorkQuality","22"},{"txtProfessionalism","18"},{"txtCommunication","14"},{"txtActualHours","160"},{"ddlPerformance","Excellent"},{"ddlRecommendation","Recommend"},{"txtStrengths","Synthetic strengths"},{"txtImprovements","Synthetic improvements"},{"__EVENTTARGET","ctl00$MainContent$btnSendReport"}};
        string saved=PostPage(root,company,companyPage,html,"noop",scores);
        var companyEvaluation=Json.Deserialize<FinalCompanyEvaluation>(Json.Serialize(db["companyFinalEvaluations"]["student"]));
        Check(companyEvaluation.IsSubmitted&&companyEvaluation.TotalScore==90&&companyEvaluation.MaxScore==100&&companyEvaluation.SupervisorId=="companyUser","Company form did not save confidential evaluation");
        Check(((Placement)db["placements"]["student"]).Status!=PlacementStatus.Completed,"Company evaluation bypassed coordinator completion");
        Check(saved.Contains("Evaluation submitted"),"Company form did not acknowledge submission");
        html=Body(Request(root,company,companyPage));
        string tooEarly=PostPage(root,company,companyPage,html,"noop",new Dictionary<string,string>{{"ddlTrainees","student"},{"__EVENTTARGET","ctl00$MainContent$btnSendCert"}});
        Check(tooEarly.Contains("approved certificate is not available yet")&&!db["notifications"].ContainsKey("student"),
            "Certificate was shared before coordinator approval");
        string academicPage="/Pages/Academic/FinalEvaluation.aspx?id=student";
        html=Body(Request(root,academic,academicPage));
        saved=PostPage(root,academic,academicPage,html,"btnSubmitEvaluation",new Dictionary<string,string>{{"hfSelectedStudentId","student"},{"ddlPassFail","100"},{"txtAcademicComments","Synthetic academic comments"}});
        var academicEvaluation=Json.Deserialize<FinalAcademicEvaluation>(Json.Serialize(db["academicFinalEvaluations"]["student"]));
        Check(academicEvaluation.IsSubmitted&&academicEvaluation.AcademicSupervisorId=="academic","Academic form did not save evaluation");
        var coordinator=Login(root,"coord");html=Body(Request(root,coordinator,review));
        Check(!html.Contains("Server Error in")&&html.Contains("Fixture &amp; Company"),"Coordinator review failed to resolve company");
        string blocked=PostPage(root,coordinator,review,html,"btnApprove");
        Check(db["completions"].Count==0||Stored().Status!=CompletionStatus.Approved,"Unverified completion was approved");
        // Verify each current manual checklist row with a reference through its real postback.
        html=Body(Request(root,coordinator,review));var fields=new Dictionary<string,string>();
        foreach(Match m in Regex.Matches(html,"<select[^>]+name=\"([^\"]*ddlStatus)\"")) {
            string name=m.Groups[1].Value;fields[name]="Verified";fields[name.Replace("ddlStatus","txtEvidence")]="Synthetic verified record";
        }
        Check(fields.Count>0,"Coordinator manual checklist was not rendered");
        html=PostPage(root,coordinator,review,html,"btnSaveChecks",fields);
        Check(Stored().Checks!=null&&Stored().Checks.Count>0,"Manual evidence checks were not saved");
        foreach(int hours in new[]{0,80,159}) {
            var entry=Evidence().Hours[0];entry.Hours=hours;db["trainingHours"]["hours"]=entry;
            html=Body(Request(root,coordinator,review));PostPage(root,coordinator,review,html,"btnApprove");
            Check(Stored().Status!=CompletionStatus.Approved,"Under-hours completion approved");
        }
        db["trainingHours"]["hours"]=Evidence().Hours[0];html=Body(Request(root,coordinator,review));
        string stale=html;html=PostPage(root,coordinator,review,html,"btnApprove");
        var approved=Stored();
        Check(approved.Status==CompletionStatus.Approved&&approved.ApprovedAt>0&&approved.DocumentSnapshot!=null,"Eligible completion was not approved and snapshotted");
        Check(approved.RequiredHours==160&&approved.ApprovedHours==160,"Approval did not use approved source hours and minimum");
        PostPage(root,coordinator,review,stale,"btnApprove");
        Check(Stored().ApprovedAt==approved.ApprovedAt,"Duplicate approval replaced the decision");
        html=Body(Request(root,company,companyPage));
        string shared=PostPage(root,company,companyPage,html,"noop",new Dictionary<string,string>{{"ddlTrainees","student"},{"__EVENTTARGET","ctl00$MainContent$btnSendCert"}});
        Check(shared.Contains("Certificate shared"),"Company could not share the approved certificate");
        var notices=Map(db["notifications"]["student"]);
        Check(notices.Values.Select(Map).Any(n=>Convert.ToString(n["Key"])=="ApprovedCertificateShared"&&
            Convert.ToString(n["Link"]).Contains("doc=certificate")),"Trainee did not receive the certificate link");
        foreach(string route in new[]{"/Pages/Account/CompletionReport.aspx?id=student","/Pages/Account/CompletionReport.aspx?id=student&doc=certificate"})
            using(var pdf=Request(root,student,route))Check(pdf.ContentType=="application/pdf"&&pdf.Headers["Cache-Control"].Contains("no-store"),"Protected PDF was missing or cacheable");
        bool otherDenied=false;
        try { Body(Request(root,Login(root,"other"),"/Pages/Account/CompletionReport.aspx?id=student&doc=certificate")); }
        catch(Exception ex) { otherDenied=ex.Message.Contains("not available"); }
        Check(otherDenied,"Another student accessed the approved certificate");
        File.WriteAllText(Path.Combine(output,"review-approved.html"),html);
    }
    static int Main(string[] args)
    {
        int databasePort=args.Length>2?int.Parse(args[2]):19083, webPort=args.Length>3?int.Parse(args[3]):19084;
        Process iis=null;var listener=new TcpListener(IPAddress.Loopback,databasePort);
        try {
            string app=Path.GetFullPath(args[0]),output=Path.GetFullPath(args[1]);Directory.CreateDirectory(output);
            rule=Json.Deserialize<List<CompletionRule>>(File.ReadAllText(Path.Combine(app,"App_Data/completion-rules.json")))[0];UnitChecks(output);Seed();
            listener.Start();new Thread(()=>Serve(listener)){IsBackground=true}.Start();string host=Path.Combine(output,"web");Directory.CreateDirectory(host);
            foreach(string folder in new[]{"Layout","Pages","Assets","App_Data","App_GlobalResources","bin"})foreach(string file in Directory.GetFiles(Path.Combine(app,folder),"*",SearchOption.AllDirectories)){string target=Path.Combine(host,file.Substring(app.Length+1));Directory.CreateDirectory(Path.GetDirectoryName(target));File.Copy(file,target,true);}
            File.WriteAllText(Path.Combine(host,"Web.config"),"<configuration><appSettings><add key='Firebase.DatabaseUrl' value='http://localhost:"+databasePort+"'/><add key='Firebase.ApiKey' value='fixture'/><add key='Firebase.ReadCacheSeconds' value='0'/></appSettings><system.web><compilation debug='true' targetFramework='4.7.2'/><pages><namespaces><add namespace='InternshipManagementSystem.Common'/></namespaces></pages><httpRuntime targetFramework='4.7.2'/><customErrors mode='Off'/></system.web></configuration>");
            File.WriteAllText(Path.Combine(host,"FixtureLogin.aspx"),"<%@ Page Language=\"C#\" %><%@ Import Namespace=\"InternshipManagementSystem.Data\" %><%@ Import Namespace=\"InternshipManagementSystem.Security\" %><script runat=\"server\">protected void Page_Load(object sender,EventArgs e){SessionHelper.SignIn(new UserRepository().GetPerson(Request.QueryString[\"id\"]),Request.QueryString[\"id\"]);Response.Write(\"Fixture ready\");}</script>");
            File.WriteAllText(Path.Combine(host,"FixtureConfidential.aspx"),"<%@ Page Language=\"C#\" %><%@ Import Namespace=\"InternshipManagementSystem.Data\" %><script runat=\"server\">protected void Page_Load(object sender,EventArgs e){try{new EvaluationRepository().GetCompanyFinalForPlacement(\"student\");Response.Write(\"EXPOSED\");}catch(UnauthorizedAccessException){Response.Write(\"DENIED\");}}</script>");
            File.WriteAllText(Path.Combine(host,"FixtureConfirm.aspx"),"<%@ Page Language=\"C#\" %><%@ Import Namespace=\"InternshipManagementSystem.Data\" %><%@ Import Namespace=\"InternshipManagementSystem.Security\" %><%@ Import Namespace=\"InternshipManagementSystem.Models\" %><script runat=\"server\">protected void Page_Load(object sender,EventArgs e){var result=new PlacementRepository().ConfirmAcceptedOffer((Student)SessionHelper.Current,\"offer\");Response.Write(result.Placement.CompanyName);}</script>");
            File.WriteAllText(Path.Combine(host,"FixtureQueue.aspx"),"<%@ Page Language=\"C#\" %><%@ Import Namespace=\"InternshipManagementSystem.Data\" %><script runat=\"server\">protected void Page_Load(object sender,EventArgs e){var row=new CoordinatorMonitoringRepository().LoadCompletionQueue()[0];Response.Write(row.IsReady+\"|\"+row.Overview.HoursText);}</script>");
            var log=new StringBuilder();
            iis=Process.Start(new ProcessStartInfo {FileName=@"C:\Program Files\IIS Express\iisexpress.exe",Arguments="/path:\""+host+"\" /port:"+webPort+" /systray:false",UseShellExecute=false,CreateNoWindow=true,RedirectStandardOutput=true,RedirectStandardError=true});
            iis.OutputDataReceived+=(s,e)=>{lock(log)log.AppendLine(e.Data);};iis.ErrorDataReceived+=(s,e)=>{lock(log)log.AppendLine(e.Data);};iis.BeginOutputReadLine();iis.BeginErrorReadLine();bool ready=false;
            for(int attempt=0;attempt<10&&!ready;attempt++){try{Body(Request(("http://localhost:"+webPort),new CookieContainer(),"/FixtureLogin.aspx?id=coord"));ready=true;}catch{if(iis.HasExited)throw new Exception("IIS exited: "+log);Thread.Sleep(400);}}
            Check(ready,"IIS fixture did not start");HttpChecks(("http://localhost:"+webPort),output);Console.WriteLine("PASS: "+checks+" completion review checks. Fixture artifacts: "+output);return 0;
        }catch(Exception ex){Console.Error.WriteLine(ex);return 1;}finally{listener.Stop();if(iis!=null&&!iis.HasExited){iis.Kill();iis.WaitForExit();}}
    }
}
