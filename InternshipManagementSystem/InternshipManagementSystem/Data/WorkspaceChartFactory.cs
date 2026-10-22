using System;
using System.Collections.Generic;
using System.Linq;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;
namespace InternshipManagementSystem.Data {
 public class AnalyticsRecord { public string Title, Detail, Url; public long? Value; }
 public class AnalyticsCategory { public string Key,Label,Tone; public long Value; public List<AnalyticsRecord> Records; }
 public class AnalyticsKpi { public string Label,Context,Unit; public long Value; public bool Flow; public List<AnalyticsRecord> Records; }
 public class AnalyticsEvent { public long Date,Value; public AnalyticsRecord Record; }
 public class WorkspaceChartData {
  public string Role,Title,Scope,TrendTitle,TrendUnit,BarTitle,BarUnit,BarContext,DonutTitle,DonutUnit;
  public long Now=Time.NowMs(); public List<AnalyticsKpi> Kpis=new List<AnalyticsKpi>();
  public List<AnalyticsEvent> Events=new List<AnalyticsEvent>();public List<AnalyticsRecord> Undated=new List<AnalyticsRecord>();
  public List<AnalyticsCategory> Bars,Breakdown;
 }
 // Pure adapters of existing authorized read models. No network or writes.
 public static class WorkspaceChartFactory {
  static AnalyticsRecord R(string title,string detail,string url,long? value=null){return new AnalyticsRecord{Title=title??"Record",Detail=detail,Url=url,Value=value};}
  static AnalyticsCategory C(string key,string label,string tone,IEnumerable<AnalyticsRecord> rows){var list=rows.ToList();return new AnalyticsCategory{Key=key,Label=label,Tone=tone,Value=list.Count,Records=list};}
  static AnalyticsKpi K(string label,long value,string context,IEnumerable<AnalyticsRecord> rows,string unit="",bool flow=false){return new AnalyticsKpi{Label=label,Value=value,Context=context,Records=rows.ToList(),Unit=unit,Flow=flow};}
  static List<AnalyticsCategory> Applications(List<InternshipApplication> apps,string url){
   var labels=new[]{"Pending","Accepted","Rejected","Withdrawn"};var tones=new[]{"pending","approved","rejected","neutral"};
   var result=Enumerable.Range(0,4).Select(i=>C(labels[i].ToLowerInvariant(),labels[i],tones[i],apps.Where(a=>(int)a.Status==i).Select(a=>R(a.OpportunityTitle,"Current decision: "+labels[i],url)))).ToList();
   var other=apps.Where(a=>!Enum.IsDefined(typeof(ApplicationStatus),a.Status)).Select(a=>R(a.OpportunityTitle,"Decision unavailable",url)).ToList();if(other.Count>0)result.Add(C("unknown","Not recorded","neutral",other));return result;
  }
  // ReviewedAt and ApprovedAt default to zero, never constructor-generated dates.
  static void Hours(WorkspaceChartData m,List<TrainingHoursEntry> hours,string url){
   m.TrendTitle="Approved hours over time";m.TrendUnit="hours";
   foreach(var h in hours.Where(h=>h.Status==HoursStatus.Approved&&h.Hours>0)){
    var r=R("Approved training entry",h.Description??"Approved hours",url,h.Hours);
    if(h.ReviewedAt>0&&h.ReviewedAt<=m.Now)m.Events.Add(new AnalyticsEvent{Date=h.ReviewedAt,Value=h.Hours,Record=r});else m.Undated.Add(r);
   }
  }
  public static WorkspaceChartData Student(WorkspaceStudentData d){
   const string tasks="~/Pages/Student/MyTasks.aspx",apps="~/Pages/Student/MyApplications.aspx",progress="~/Pages/Student/Progress.aspx";
   var m=new WorkspaceChartData{Role="Student",Title="Training overview",Scope="Your own internship records. Current totals and dated approval activity.",BarTitle="Tasks by status",BarUnit="tasks",BarContext="Current status of tasks linked to your placement.",DonutTitle="Application decisions",DonutUnit="applications"};Hours(m,d.Hours,progress);
   var labels=new[]{"Assigned","Submitted","Under review","Needs revision","Resubmitted","Graded"};var tones=new[]{"active","review","review","pending","review","approved"};
   m.Bars=Enumerable.Range(0,6).Select(i=>C("task-"+i,labels[i],tones[i],d.Tasks.Where(t=>(int)t.Status==i).Select(t=>R(t.Title,"Current status: "+labels[i],tasks)))).ToList();
   var unknown=d.Tasks.Where(t=>!Enum.IsDefined(typeof(InternshipTaskStatus),t.Status)).Select(t=>R(t.Title,"Status not recorded",tasks)).ToList();if(unknown.Count>0)m.Bars.Add(C("unknown","Not recorded","neutral",unknown));
   m.Breakdown=Applications(d.Applications,apps);
   m.Kpis.Add(K("Applications",d.Applications.Count,"All your current application records",d.Applications.Select(a=>R(a.OpportunityTitle,"Decision: "+a.Status,apps))));
   m.Kpis.Add(K("Pending applications",d.Applications.Count(a=>a.Status==ApplicationStatus.Pending),"Awaiting a company decision",m.Breakdown[0].Records));
   m.Kpis.Add(K("Approved in range",0,"Current approved total: "+d.ApprovedHours+" h",new List<AnalyticsRecord>(),"h",true));
   var action=d.Tasks.Where(t=>t.Status==InternshipTaskStatus.Assigned||t.Status==InternshipTaskStatus.RevisionRequested).ToList();m.Kpis.Add(K("Tasks awaiting action",action.Count,"Assigned or returned for revision",action.Select(t=>R(t.Title,t.Status.ToString(),tasks))));return m;
  }
  public static WorkspaceChartData Company(WorkspaceCompanyData d){
   const string apps="~/Pages/Company/Applications.aspx",trainees="~/Pages/Company/Trainees.aspx",hours="~/Pages/Company/Tasks.aspx",review="~/Pages/Company/TaskReview.aspx";
   var m=new WorkspaceChartData{Role="Company",Title="Company activity",Scope="Your company's trainees, applications and review queues.",BarTitle="Work awaiting review",BarUnit="items",BarContext="Independent queues; a trainee may appear in more than one. Not a part-to-whole chart.",DonutTitle="Application decisions",DonutUnit="applications"};Hours(m,d.Hours,hours);m.Breakdown=Applications(d.Applications,apps);
   var active=d.Trainees.Where(t=>t.Placement.Status==PlacementStatus.Confirmed||t.Placement.Status==PlacementStatus.Active).Select(t=>R(t.StudentName,t.Placement.Status.ToString(),trainees)).ToList();
   var submissions=d.Submissions.Select(s=>R("Submission attempt "+s.AttemptNumber,"Student: "+s.StudentId+"; current status: "+s.Status,review)).ToList();
   var pending=d.Hours.Where(h=>h.Status==HoursStatus.Reported).Select(h=>R("Reported hours entry",h.Description??"Awaiting approval",hours,h.Hours)).ToList();
   m.Kpis.Add(K("Active trainees",active.Count,"Confirmed or active placements",active));m.Kpis.Add(K("Applications to review",d.PendingApplications,"Current pending decisions",m.Breakdown[0].Records));
   m.Kpis.Add(K("Submissions to evaluate",d.PendingSubmissions,"Submitted or under review",submissions));m.Kpis.Add(K("Hours awaiting approval",d.PendingHours,"Reported hours; not approved",pending,"h"));
   m.Bars=new List<AnalyticsCategory>{C("pending","Applications","pending",m.Breakdown[0].Records),C("review","Submissions","review",submissions),C("hours","Hour entries","active",pending)};return m;
  }
  public static WorkspaceChartData Academic(WorkspaceAcademicData d){
   const string progress="~/Pages/Academic/StudentProgress.aspx",evaluation="~/Pages/Academic/FinalEvaluation.aspx";Func<WorkspaceAcademicRow,AnalyticsRecord> record=r=>R(r.FullName,r.NextAction,progress+"?id="+Uri.EscapeDataString(r.Id));
   var m=new WorkspaceChartData{Role="Academic",Title="Assigned student overview",Scope="Only students assigned to you. Hours targets do not imply final completion.",BarTitle="Training progress",BarUnit="students",BarContext="Each assigned student appears in exactly one progress category.",DonutTitle="Academic assessment status",DonutUnit="students"};Hours(m,d.Hours,progress);
   m.Bars=new List<AnalyticsCategory>{C("met","Hours target met","approved",d.Students.Where(r=>r.HasPlacement&&r.RequiredHours>0&&r.ApprovedHours>=r.RequiredHours).Select(record)),C("training","Training","active",d.Students.Where(r=>r.HasPlacement&&r.RequiredHours>0&&r.ApprovedHours<r.RequiredHours).Select(record)),C("unset","Target not set","pending",d.Students.Where(r=>r.HasPlacement&&r.RequiredHours<=0).Select(record)),C("placement","No placement","neutral",d.Students.Where(r=>!r.HasPlacement).Select(record))};
   m.Breakdown=new List<AnalyticsCategory>{C("submitted","Submitted","approved",d.Students.Where(r=>r.AcademicSubmitted).Select(record)),C("ready","Ready for academic action","pending",d.Students.Where(r=>!r.AcademicSubmitted&&r.HasPlacement&&r.CompanySubmitted).Select(record)),C("company","Awaiting company feedback","review",d.Students.Where(r=>!r.AcademicSubmitted&&r.HasPlacement&&!r.CompanySubmitted).Select(record)),C("placement","Awaiting placement","neutral",d.Students.Where(r=>!r.AcademicSubmitted&&!r.HasPlacement).Select(record))};
   m.Kpis.Add(K("Assigned students",d.Students.Count,"Current assignment scope",d.Students.Select(record)));
   var training=d.Students.Where(r=>r.PlacementStatus==PlacementStatus.Confirmed||r.PlacementStatus==PlacementStatus.Active).ToList();m.Kpis.Add(K("Currently training",training.Count,"Confirmed or active placements",training.Select(record)));
   m.Kpis.Add(K("Academic action due",d.PendingEvaluations,"Company feedback received; academic not submitted",d.Students.Where(r=>r.CompanySubmitted&&!r.AcademicSubmitted).Select(r=>R(r.FullName,"Academic assessment due",evaluation))));
   m.Kpis.Add(K("Approved in range",0,"Dated company approvals for assigned students",new List<AnalyticsRecord>(),"h",true));return m;
  }
  public static WorkspaceChartData Coordinator(WorkspaceCoordinatorData d){
   const string review="~/Pages/Coordinator/CompletionReview.aspx",students="~/Pages/Coordinator/ManageStudents.aspx",groups="~/Pages/Coordinator/Groups.aspx";Func<CompletionQueueRow,AnalyticsRecord> record=r=>R(r.Overview.StudentName,r.StageText,review+"?id="+Uri.EscapeDataString(r.Overview.Placement.Id));
   var m=new WorkspaceChartData{Role="Coordinator",Title="Programme overview",Scope="Programme-wide current records and explicit coordinator approval events.",TrendTitle="Completion approvals over time",TrendUnit="completions",BarTitle="Students by college",BarUnit="students",BarContext="Current student profiles; missing colleges are labeled explicitly.",DonutTitle="Completion review status",DonutUnit="placements"};
   foreach(var row in d.Queue.Where(r=>r.IsApproved)){var rec=record(row);if(row.Completion.ApprovedAt>0&&row.Completion.ApprovedAt<=m.Now)m.Events.Add(new AnalyticsEvent{Date=row.Completion.ApprovedAt,Value=1,Record=rec});else m.Undated.Add(rec);}
   m.Bars=d.Students.GroupBy(s=>string.IsNullOrWhiteSpace(s.College)?"Not recorded":s.College).OrderBy(g=>g.Key).Select(g=>C("college-"+g.Key,g.Key,"active",g.Select(s=>R(s.FullName,"Current student profile",students)))).ToList();
   m.Breakdown=new List<AnalyticsCategory>{C("approved","Approved","approved",d.Queue.Where(r=>r.IsApproved).Select(record)),C("returned","Returned","rejected",d.Queue.Where(r=>!r.IsApproved&&r.IsReturned).Select(record)),C("ready","Ready for review","review",d.Queue.Where(r=>!r.IsApproved&&!r.IsReturned&&r.IsReady).Select(record)),C("company","Awaiting company","pending",d.Queue.Where(r=>!r.IsApproved&&!r.IsReturned&&!r.IsReady&&!r.CompanySubmitted).Select(record)),C("academic","Awaiting academic","neutral",d.Queue.Where(r=>!r.IsApproved&&!r.IsReturned&&!r.IsReady&&r.CompanySubmitted).Select(record))};
   m.Kpis.Add(K("Students in scope",d.Students.Count,"All current student profiles",d.Students.Select(s=>R(s.FullName,"Current student profile",students))));m.Kpis.Add(K("Pending assignments",d.UnassignedStudents,"Active profiles without an academic supervisor",d.Students.Where(s=>s.IsActive&&string.IsNullOrWhiteSpace(s.AcademicSupervisorId)).Select(s=>R(s.FullName,"Academic supervisor not assigned",groups))));
   m.Kpis.Add(K("Final reviews ready",d.Queue.Count(r=>r.IsReady&&!r.IsReturned),"Both assessments received; requirements still need review",d.Queue.Where(r=>r.IsReady&&!r.IsReturned).Select(record)));m.Kpis.Add(K("Approved in range",0,"Current approved completions: "+d.Queue.Count(r=>r.IsApproved),new List<AnalyticsRecord>(),"",true));return m;
  }
 }
}
