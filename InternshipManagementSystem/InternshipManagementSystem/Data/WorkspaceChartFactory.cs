using System;
using System.Collections.Generic;
using System.Linq;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;
namespace InternshipManagementSystem.Data {
 public class AnalyticsRecord { public string Title, Detail, Url; public long? Value; }
 public class AnalyticsCategory { public string Key,Label,Tone; public long Value; public List<AnalyticsRecord> Records; /* Optional: page that lists this category (coordinator majors). */ public string Url; }
 public class AnalyticsKpi { public string Label,Context,Unit; public long Value; public bool Flow; public List<AnalyticsRecord> Records; }
 public class AnalyticsEvent { public long Date,Value; public AnalyticsRecord Record; }
 public class WorkspaceChartData {
  public string Role,Title,Scope,TrendTitle,TrendUnit,BarTitle,BarUnit,BarContext,DonutTitle,DonutUnit;
  public long Now=Time.NowMs(); public List<AnalyticsKpi> Kpis=new List<AnalyticsKpi>();
  public List<AnalyticsEvent> Events=new List<AnalyticsEvent>();public List<AnalyticsRecord> Undated=new List<AnalyticsRecord>();
  public List<AnalyticsCategory> Bars,Breakdown;
  // Optional, coordinator only: "horizontal" bars, a data-quality notice and a
  // title for the bar data table. Other roles leave these null (no change).
  public string BarLayout,BarNotice,BarDataTitle;
  // Optional: a fixed approval window in months. 0 keeps the 6 / 12 month
  // switch; the coordinator dashboard uses a fixed 12 month window instead.
  public int RangeMonths;
 }
 // Pure adapters of existing authorized read models. No network or writes.
 public static class WorkspaceChartFactory {
  static AnalyticsRecord R(string title,string detail,string url,long? value=null){return new AnalyticsRecord{Title=title??L.T("Workspace.Record"),Detail=detail,Url=url,Value=value};}
  static AnalyticsCategory C(string key,string label,string tone,IEnumerable<AnalyticsRecord> rows){var list=rows.ToList();return new AnalyticsCategory{Key=key,Label=label,Tone=tone,Value=list.Count,Records=list};}
  static AnalyticsKpi K(string label,long value,string context,IEnumerable<AnalyticsRecord> rows,string unit="",bool flow=false){return new AnalyticsKpi{Label=label,Value=value,Context=context,Records=rows.ToList(),Unit=unit,Flow=flow};}
  static List<AnalyticsCategory> Applications(List<InternshipApplication> apps,string url){
   var names=new[]{"Pending","Accepted","Rejected","Withdrawn"};var labels=names.Select(n=>L.Value("ApplicationStatus",n)).ToArray();var tones=new[]{"pending","approved","rejected","neutral"};
   var result=Enumerable.Range(0,4).Select(i=>C(names[i].ToLowerInvariant(),labels[i],tones[i],apps.Where(a=>(int)a.Status==i).Select(a=>R(a.OpportunityTitle,L.T("Workspace.CurrentDecision")+labels[i],url)))).ToList();
   var other=apps.Where(a=>!Enum.IsDefined(typeof(ApplicationStatus),a.Status)).Select(a=>R(a.OpportunityTitle,L.T("Workspace.DecisionUnavailable"),url)).ToList();if(other.Count>0)result.Add(C("unknown",L.T("Workspace.NotRecorded"),"neutral",other));return result;
  }
  // ReviewedAt and ApprovedAt default to zero, never constructor-generated dates.
  static void Hours(WorkspaceChartData m,List<TrainingHoursEntry> hours,string url){
   m.TrendTitle=L.T("Workspace.ApprovedHoursOverTime");m.TrendUnit=L.T("Workspace.UnitHours");
   foreach(var h in hours.Where(h=>h.Status==HoursStatus.Approved&&h.Hours>0)){
    var r=R(L.T("Workspace.ApprovedTrainingEntry"),h.Description??L.T("Workspace.ApprovedHours"),url,h.Hours);
    if(h.ReviewedAt>0&&h.ReviewedAt<=m.Now)m.Events.Add(new AnalyticsEvent{Date=h.ReviewedAt,Value=h.Hours,Record=r});else m.Undated.Add(r);
   }
  }
  public static WorkspaceChartData Student(WorkspaceStudentData d){
   const string tasks="~/Pages/Student/MyTasks.aspx",apps="~/Pages/Student/MyApplications.aspx",progress="~/Pages/Student/Progress.aspx";
   var m=new WorkspaceChartData{Role="Student",Title=L.T("Workspace.TrainingOverview"),Scope=L.T("Workspace.YourOwnInternshipRecordsCurrentTotalsAnd"),BarTitle=L.T("Workspace.TasksByStatus"),BarUnit=L.T("Workspace.UnitTasks"),BarContext=L.T("Workspace.CurrentStatusOfTasksLinkedToYour"),DonutTitle=L.T("Workspace.ApplicationDecisions"),DonutUnit=L.T("Workspace.UnitApplications")};Hours(m,d.Hours,progress);
   var labels=new[]{L.T("Workspace.Assigned"),L.T("Workspace.Submitted"),L.T("Workspace.UnderReview"),L.T("Workspace.NeedsRevision"),L.T("Workspace.Resubmitted"),L.T("Workspace.Graded")};var tones=new[]{"active","review","review","pending","review","approved"};
   m.Bars=Enumerable.Range(0,6).Select(i=>C("task-"+i,labels[i],tones[i],d.Tasks.Where(t=>(int)t.Status==i).Select(t=>R(t.Title,L.T("Workspace.CurrentStatus")+labels[i],tasks)))).ToList();
   var unknown=d.Tasks.Where(t=>!Enum.IsDefined(typeof(InternshipTaskStatus),t.Status)).Select(t=>R(t.Title,L.T("Workspace.StatusNotRecorded"),tasks)).ToList();if(unknown.Count>0)m.Bars.Add(C("unknown",L.T("Workspace.NotRecorded"),"neutral",unknown));
   m.Breakdown=Applications(d.Applications,apps);
   m.Kpis.Add(K(L.T("Workspace.Applications"),d.Applications.Count,L.T("Workspace.AllYourCurrentApplicationRecords"),d.Applications.Select(a=>R(a.OpportunityTitle,L.T("Workspace.Decision")+L.Value("ApplicationStatus",a.Status),apps))));
   m.Kpis.Add(K(L.T("Workspace.PendingApplications"),d.Applications.Count(a=>a.Status==ApplicationStatus.Pending),L.T("Workspace.AwaitingACompanyDecision"),m.Breakdown[0].Records));
   m.Kpis.Add(K(L.T("Workspace.ApprovedInRange"),0,L.T("Workspace.CurrentApprovedTotal")+d.ApprovedHours+" "+L.T("Workspace.UnitH"),new List<AnalyticsRecord>(),L.T("Workspace.UnitH"),true));
   var action=d.Tasks.Where(t=>t.Status==InternshipTaskStatus.Assigned||t.Status==InternshipTaskStatus.RevisionRequested).ToList();m.Kpis.Add(K(L.T("Workspace.TasksAwaitingAction"),action.Count,L.T("Workspace.AssignedOrReturnedForRevision"),action.Select(t=>R(t.Title,L.Value("TaskStatus",t.Status),tasks))));return m;
  }
  public static WorkspaceChartData Company(WorkspaceCompanyData d){
   const string apps="~/Pages/Company/Applications.aspx",trainees="~/Pages/Company/Trainees.aspx",hours="~/Pages/Company/Tasks.aspx",review="~/Pages/Company/TaskReview.aspx";
   var m=new WorkspaceChartData{Role="Company",Title=L.T("Workspace.CompanyActivity"),Scope=L.T("Workspace.YourCompanySTraineesApplicationsAndReview"),BarTitle=L.T("Workspace.WorkAwaitingReview"),BarUnit=L.T("Workspace.UnitItems"),BarContext=L.T("Workspace.IndependentQueuesATraineeMayAppearIn"),DonutTitle=L.T("Workspace.ApplicationDecisions"),DonutUnit=L.T("Workspace.UnitApplications")};Hours(m,d.Hours,hours);m.Breakdown=Applications(d.Applications,apps);
   var active=d.Trainees.Where(t=>t.Placement.Status==PlacementStatus.Confirmed||t.Placement.Status==PlacementStatus.Active).Select(t=>R(t.StudentName,L.Value("PlacementStatus",t.Placement.Status),trainees)).ToList();
   var submissions=d.Submissions.Select(s=>R(L.T("Workspace.SubmissionAttempt")+s.AttemptNumber,L.T("Workspace.Student")+s.StudentId+L.T("Workspace.CurrentStatus2")+s.Status,review)).ToList();
   var pending=d.Hours.Where(h=>h.Status==HoursStatus.Reported).Select(h=>R(L.T("Workspace.ReportedHoursEntry"),h.Description??L.T("Workspace.AwaitingApproval"),hours,h.Hours)).ToList();
   m.Kpis.Add(K(L.T("Workspace.ActiveTrainees"),active.Count,L.T("Workspace.ConfirmedOrActivePlacements"),active));m.Kpis.Add(K(L.T("Workspace.ApplicationsToReview"),d.PendingApplications,L.T("Workspace.CurrentPendingDecisions"),m.Breakdown[0].Records));
   m.Kpis.Add(K(L.T("Workspace.SubmissionsToEvaluate"),d.PendingSubmissions,L.T("Workspace.SubmittedOrUnderReview"),submissions));m.Kpis.Add(K(L.T("Workspace.HoursAwaitingApproval"),d.PendingHours,L.T("Workspace.ReportedHoursNotApproved"),pending,L.T("Workspace.UnitH")));
   m.Bars=new List<AnalyticsCategory>{C("pending",L.T("Workspace.Applications"),"pending",m.Breakdown[0].Records),C("review",L.T("Workspace.Submissions"),"review",submissions),C("hours",L.T("Workspace.HourEntries"),"active",pending)};return m;
  }
  public static WorkspaceChartData Academic(WorkspaceAcademicData d){
   const string progress="~/Pages/Academic/StudentProgress.aspx",evaluation="~/Pages/Academic/FinalEvaluation.aspx";Func<WorkspaceAcademicRow,AnalyticsRecord> record=r=>R(r.FullName,r.NextAction,progress+"?id="+Uri.EscapeDataString(r.Id));
   var m=new WorkspaceChartData{Role="Academic",Title=L.T("Workspace.AssignedStudentOverview"),Scope=L.T("Workspace.OnlyStudentsAssignedToYouHoursTargets"),BarTitle=L.T("Workspace.TrainingProgress"),BarUnit=L.T("Workspace.UnitStudents"),BarContext=L.T("Workspace.EachAssignedStudentAppearsInExactlyOne"),DonutTitle=L.T("Workspace.AcademicAssessmentStatus"),DonutUnit=L.T("Workspace.UnitStudents")};Hours(m,d.Hours,progress);
   m.Bars=new List<AnalyticsCategory>{C("met",L.T("Workspace.HoursTargetMet"),"approved",d.Students.Where(r=>r.HasPlacement&&r.RequiredHours>0&&r.ApprovedHours>=r.RequiredHours).Select(record)),C("training",L.T("Workspace.Training"),"active",d.Students.Where(r=>r.HasPlacement&&r.RequiredHours>0&&r.ApprovedHours<r.RequiredHours).Select(record)),C("unset",L.T("Workspace.TargetNotSet"),"pending",d.Students.Where(r=>r.HasPlacement&&r.RequiredHours<=0).Select(record)),C("placement",L.T("Workspace.NoPlacement"),"neutral",d.Students.Where(r=>!r.HasPlacement).Select(record))};
   m.Breakdown=new List<AnalyticsCategory>{C("submitted",L.T("Workspace.Submitted"),"approved",d.Students.Where(r=>r.AcademicSubmitted).Select(record)),C("ready",L.T("Workspace.ReadyForAcademicAction"),"pending",d.Students.Where(r=>!r.AcademicSubmitted&&r.HasPlacement&&r.CompanySubmitted).Select(record)),C("company",L.T("Workspace.AwaitingCompanyFeedback"),"review",d.Students.Where(r=>!r.AcademicSubmitted&&r.HasPlacement&&!r.CompanySubmitted).Select(record)),C("placement",L.T("Workspace.AwaitingPlacement"),"neutral",d.Students.Where(r=>!r.AcademicSubmitted&&!r.HasPlacement).Select(record))};
   m.Kpis.Add(K(L.T("Workspace.AssignedStudents"),d.Students.Count,L.T("Workspace.CurrentAssignmentScope"),d.Students.Select(record)));
   var training=d.Students.Where(r=>r.PlacementStatus==PlacementStatus.Confirmed||r.PlacementStatus==PlacementStatus.Active).ToList();m.Kpis.Add(K(L.T("Workspace.CurrentlyTraining"),training.Count,L.T("Workspace.ConfirmedOrActivePlacements"),training.Select(record)));
   m.Kpis.Add(K(L.T("Workspace.AcademicActionDue"),d.PendingEvaluations,L.T("Workspace.CompanyFeedbackReceivedAcademicNotSubmitted"),d.Students.Where(r=>r.CompanySubmitted&&!r.AcademicSubmitted).Select(r=>R(r.FullName,L.T("Workspace.AcademicAssessmentDue"),evaluation))));
   m.Kpis.Add(K(L.T("Workspace.ApprovedInRange"),0,L.T("Workspace.DatedCompanyApprovalsForAssignedStudents"),new List<AnalyticsRecord>(),L.T("Workspace.UnitH"),true));return m;
  }
  /// <summary>Students by Major for the coordinator. Each student is counted
  /// once (by Id). The three verified School of Computing programmes always
  /// appear; missing and unrecognised majors get their own categories and a
  /// verification notice - they are never mapped onto a programme, and the
  /// stored Major is never changed.</summary>
  static void StudentsByMajor(WorkspaceChartData m,List<Student> all,string studentsUrl){
   var unique=all.Where(s=>s!=null&&!string.IsNullOrEmpty(s.Id)).GroupBy(s=>s.Id).Select(g=>g.First()).ToList();
   Func<Student,AnalyticsRecord> rec=s=>R(s.FullName,string.IsNullOrWhiteSpace(s.Major)?L.T("Workspace.MajorNotRecorded"):L.T("Workspace.RecordedMajor")+s.Major,studentsUrl+"?id="+Uri.EscapeDataString(s.Id));
   m.Bars=new List<AnalyticsCategory>();
   foreach(var program in AcademicPrograms.All){var p=program;var cat=C("major-"+p.Key,p.Name,"active",unique.Where(s=>AcademicPrograms.Find(s.Major)==p).OrderBy(s=>s.FullName).Select(rec));cat.Url=studentsUrl+"?major="+p.Key;m.Bars.Add(cat);}
   var missing=unique.Where(s=>AcademicPrograms.Quality(s.Major)==MajorQuality.Missing).OrderBy(s=>s.FullName).ToList();
   var unknown=unique.Where(s=>AcademicPrograms.Quality(s.Major)==MajorQuality.Unrecognized).OrderBy(s=>s.FullName).ToList();
   if(missing.Count>0){var cat=C(AcademicPrograms.MissingKey,L.T("Workspace.MajorMissing"),"pending",missing.Select(rec));cat.Url=studentsUrl+"?major="+AcademicPrograms.MissingKey;m.Bars.Add(cat);}
   if(unknown.Count>0){var cat=C(AcademicPrograms.UnrecognizedKey,L.T("Workspace.MajorUnrecognized"),"pending",unknown.Select(rec));cat.Url=studentsUrl+"?major="+AcademicPrograms.UnrecognizedKey;m.Bars.Add(cat);}
   m.BarDataTitle=L.T("Workspace.ViewStudentBreakdown");
   int review=missing.Count+unknown.Count;if(review>0)m.BarNotice=L.F("Workspace.MajorVerificationNotice",review);
  }
  public static WorkspaceChartData Coordinator(WorkspaceCoordinatorData d){
   const string review="~/Pages/Coordinator/CompletionReview.aspx",students="~/Pages/Coordinator/ManageStudents.aspx",groups="~/Pages/Coordinator/Groups.aspx";Func<CompletionQueueRow,AnalyticsRecord> record=r=>R(r.Overview.StudentName,r.StageText,review+"?id="+Uri.EscapeDataString(r.Overview.Placement.Id));
   var m=new WorkspaceChartData{Role="Coordinator",Title=L.T("Workspace.ProgrammeOverview"),Scope=L.T("Workspace.ProgrammeWideCurrentRecordsAndExplicitCoordinator"),TrendTitle=L.T("Workspace.CompletionApprovalsOverTime"),TrendUnit=L.T("Workspace.UnitCompletions"),BarTitle=L.T("Workspace.StudentsByMajor"),BarUnit=L.T("Workspace.UnitStudents"),BarContext=L.T("Workspace.StudentsByMajorContext"),DonutTitle=L.T("Workspace.CompletionReviewStatus"),DonutUnit=L.T("Workspace.UnitPlacements")};
   foreach(var row in d.Queue.Where(r=>r.IsApproved)){var rec=record(row);if(row.Completion.ApprovedAt>0&&row.Completion.ApprovedAt<=m.Now)m.Events.Add(new AnalyticsEvent{Date=row.Completion.ApprovedAt,Value=1,Record=rec});else m.Undated.Add(rec);}
   StudentsByMajor(m,d.Students,students);
   // No completion breakdown chart here: the completion queue on the
   // dashboard already lists the same students. Fixed 12 month window.
   m.Breakdown=new List<AnalyticsCategory>();m.RangeMonths=12;
   m.Kpis.Add(K(L.T("Workspace.StudentsInScope"),d.Students.Count,L.T("Workspace.AllCurrentStudentProfiles"),d.Students.Select(s=>R(s.FullName,L.T("Workspace.CurrentStudentProfile"),students))));m.Kpis.Add(K(L.T("Workspace.PendingAssignments"),d.UnassignedStudents,L.T("Workspace.ActiveProfilesWithoutAnAcademicSupervisor"),d.Students.Where(s=>s.IsActive&&string.IsNullOrWhiteSpace(s.AcademicSupervisorId)).Select(s=>R(s.FullName,L.T("Workspace.AcademicSupervisorNotAssigned"),groups))));
   m.Kpis.Add(K(L.T("Workspace.FinalReviewsReady"),d.Queue.Count(r=>r.IsReady&&!r.IsReturned),L.T("Workspace.BothAssessmentsReceivedRequirementsStillNeedReview"),d.Queue.Where(r=>r.IsReady&&!r.IsReturned).Select(record)));m.Kpis.Add(K(L.T("Workspace.ApprovedInRange"),0,L.T("Workspace.CurrentApprovedCompletions")+d.Queue.Count(r=>r.IsApproved),new List<AnalyticsRecord>(),"",true));return m;
  }
 }
}
