using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using Newtonsoft.Json;

namespace InternshipManagementSystem.Pages.CoordinatorArea
{
    public partial class Dashboard : InternshipManagementSystem.Security.CoordinatorPage
    {
        protected WorkspaceChartData Model { get; private set; }
        public class MonthTotal { public string Label, ChartLabel; public long Value; }
        protected List<MonthTotal> Months { get; private set; } = new List<MonthTotal>();
        protected string RangeCaption { get; private set; }
        protected string Comparison { get; private set; }
        protected string HistoryNote { get; private set; }
        protected CoordinatorDashboardData Summary { get; private set; }
        protected List<FollowUpItem> FollowUps { get; private set; }
        public class FollowUpItem
        {
            public string Label, Context, Unit;
            public long Value;
            public List<AnalyticsRecord> Records;
        }
        protected string Text(string key) { return L.T("Coordinator.Dashboard." + key); }
        private string MajorLabel(string major)
        {
            string key = major == "Computer Science" ? "MajorComputerScience" : major == "Computer Engineering" ? "MajorComputerEngineering" : major == "Game Design and Media Informatics" ? "MajorGameDesign" : null;
            return key == null ? major : Text(key);
        }
        protected string Percent(long value) { return (Model.Kpis[0].Value == 0 ? 0 : value * 100.0 / Model.Kpis[0].Value).ToString("0.#", CultureInfo.InvariantCulture); }
        protected string[] KpiIcons = { "icon-people", "icon-file", "icon-clock", "icon-check" };
        protected string[] KpiActions { get { return new[] { "ViewStudents", "ViewActivePlacements", "ViewReviews", "ViewApprovals" }.Select(Text).ToArray(); } }
        protected string SafeJson { get { return JsonConvert.SerializeObject(new { Model, Months, FollowUps, AppRoot = ResolveUrl("~/") }, new JsonSerializerSettings { StringEscapeHandling = StringEscapeHandling.EscapeHtml }); } }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack || !FirebaseContext.IsConfigured) return;
            try
            {
                var data = new WorkspaceDashboardRepository().LoadCoordinator();
                var model = WorkspaceChartFactory.Coordinator(data);
                Summary = data.Summary;
                // Every placement appears once. Received evaluations with unmet
                // requirements must not be labelled "awaiting academic".
                Func<CompletionQueueRow, bool> returned = q => q.IsReturned || (q.Completion != null && (q.Completion.NeedsCorrections || q.Completion.IsRejectedFinal));
                Func<CompletionQueueRow, bool> readyForReview = q => q.ReviewStatus == CompletionQueueRow.ReviewReady && !returned(q);
                Func<CompletionQueueRow, bool> waiting = q => !q.IsApproved && !returned(q) && !readyForReview(q);
                Func<string, string, string, IEnumerable<CompletionQueueRow>, AnalyticsCategory> stage = (key, label, tone, rows) => {
                    var records = rows.Select(q => new AnalyticsRecord { Title = q.Overview.StudentName, Detail = q.Overview.Placement.CompanyName,
                        Url = "~/Pages/Coordinator/CompletionReview.aspx?id=" + Uri.EscapeDataString(q.Overview.Placement.Id) }).ToList();
                    return new AnalyticsCategory { Key = key, Label = label, Tone = tone, Value = records.Count, Records = records };
                };
                model.Breakdown = new List<AnalyticsCategory> {
                    stage("ready", Text("ReadyForReview"), "review", data.Queue.Where(readyForReview)),
                    stage("returned", L.T("Workspace.Returned"), "rejected", data.Queue.Where(q => returned(q) && !q.IsApproved)),
                    stage("company", L.T("Workspace.AwaitingCompany"), "pending", data.Queue.Where(q => waiting(q) && !q.CompanySubmitted)),
                    stage("academic", L.T("Workspace.AwaitingAcademic"), "neutral", data.Queue.Where(q => waiting(q) && q.CompanySubmitted && !q.AcademicSubmitted)),
                    stage("requirements", Text("RequirementsPending"), "pending", data.Queue.Where(q => waiting(q) && q.CompanySubmitted && q.AcademicSubmitted)),
                    stage("approved", L.T("Workspace.Approved"), "approved", data.Queue.Where(q => q.IsApproved))
                };
                string[] standardMajors = { "Computer Science", "Computer Engineering", "Game Design and Media Informatics" };
                // Use exactly the KPI population, including inactive and legacy profiles.
                var students = data.Students;
                var majors = standardMajors.Concat(students.Select(s => string.IsNullOrWhiteSpace(s.Major) ? L.T("Workspace.NotRecorded") : s.Major.Trim()))
                    .Distinct(StringComparer.OrdinalIgnoreCase);
                model.Bars = majors.Select(major => {
                    var records = students.Where(s => string.Equals(string.IsNullOrWhiteSpace(s.Major) ? L.T("Workspace.NotRecorded") : s.Major.Trim(), major, StringComparison.OrdinalIgnoreCase))
                        .OrderBy(s => s.FullName).Select(s => new AnalyticsRecord { Title = s.FullName, Detail = s.StudentNumber + " · " + MajorLabel(major), Url = "~/Pages/Coordinator/ManageStudents.aspx?id=" + Uri.EscapeDataString(s.Id) }).ToList();
                    return new AnalyticsCategory { Key = major, Label = MajorLabel(major), Tone = "active", Value = records.Count, Records = records };
                }).ToList();
                model.Kpis[0].Label = Text("StudentProfiles");
                model.Kpis[0].Context = string.Format(Text("StudentProfileContext"), Summary.ActiveStudents, students.Count - Summary.ActiveStudents);
                model.Kpis[0].Records = model.Bars.SelectMany(b => b.Records).OrderBy(r => r.Title).ToList();
                var unassigned = new FollowUpItem { Label = Text("UnassignedStudents"), Context = Text("AssignmentHelp"), Value = data.UnassignedStudents,
                    Records = students.Where(s => s.IsActive && string.IsNullOrWhiteSpace(s.AcademicSupervisorId)).OrderBy(s => s.FullName).Select(s => new AnalyticsRecord {
                        Title = s.FullName, Detail = s.StudentNumber, Url = "~/Pages/Coordinator/ManageStudents.aspx?id=" + Uri.EscapeDataString(s.Id) }).ToList() };
                var active = data.Queue.Where(q => q.Overview.Placement.Status == PlacementStatus.Active || q.Overview.Placement.Status == PlacementStatus.Confirmed).ToList();
                model.Kpis[1] = new AnalyticsKpi { Label = Text("ActivePlacements"), Context = Text("ActivePlacementContext"), Value = active.Count,
                    Records = active.Select(q => new AnalyticsRecord { Title = q.Overview.StudentName, Detail = q.Overview.Placement.CompanyName, Url = "~/Pages/Coordinator/PlacementDetails.aspx?id=" + Uri.EscapeDataString(q.Overview.Placement.Id) }).ToList() };
                model.Kpis[2].Label = Text("ReadyForReview");
                model.Kpis[2].Context = Text("ReadyHelp");
                model.Kpis[2].Records = model.Breakdown.First(b => b.Key == "ready").Records;
                model.Kpis[2].Value = model.Kpis[2].Records.Count;
                model.Kpis[3].Label = Text("ApprovalsLastYear");
                model.Kpis[3].Context = Text("RecordedApprovalDates");
                var openPlacementIds = new HashSet<string>(data.Queue.Where(q => q.Overview.Placement.Status != PlacementStatus.Completed).Select(q => q.Overview.Placement.Id));
                var overdueTasks = Summary.OverdueTaskItems.Where(task => openPlacementIds.Contains(task.PlacementId)).ToList();
                var pendingHourRows = data.Queue.Where(q => openPlacementIds.Contains(q.Overview.Placement.Id) && q.Overview.PendingHours > 0).ToList();
                FollowUps = new List<FollowUpItem> {
                    unassigned,
                    new FollowUpItem { Label = Text("OverdueTasks"), Context = Text("OverdueHelp"), Value = overdueTasks.Count,
                        Records = overdueTasks.Select(task => new AnalyticsRecord { Title = task.Title,
                            Detail = data.Queue.Where(q => q.Overview.Placement.Id == task.PlacementId).Select(q => q.Overview.StudentName).FirstOrDefault(),
                            Url = "~/Pages/Coordinator/PlacementDetails.aspx?id=" + Uri.EscapeDataString(task.PlacementId) }).ToList() },
                    new FollowUpItem { Label = Text("PendingHours"), Context = Text("PendingHoursHelp"), Value = pendingHourRows.Sum(q => q.Overview.PendingHours), Unit = L.T("Workspace.UnitH"),
                        Records = pendingHourRows.Select(q => new AnalyticsRecord { Title = q.Overview.StudentName, Value = q.Overview.PendingHours,
                            Detail = q.Overview.PendingHours + " " + L.T("Workspace.UnitH") + " · " + q.Overview.Placement.CompanyName,
                            Url = "~/Pages/Coordinator/PlacementDetails.aspx?id=" + Uri.EscapeDataString(q.Overview.Placement.Id) }).ToList() },
                    new FollowUpItem { Label = Text("ReturnedCompletions"), Context = Text("ReturnedHelp"), Value = model.Breakdown.First(b => b.Key == "returned").Value,
                        Records = model.Breakdown.First(b => b.Key == "returned").Records }
                };
                var now = DateTimeOffset.FromUnixTimeMilliseconds(model.Now).UtcDateTime;
                var start = new DateTime(now.Year, now.Month, 1, 0, 0, 0, DateTimeKind.Utc).AddMonths(-11);
                var culture = CultureInfo.GetCultureInfo(L.IsArabic ? "ar-JO" : "en-US");
                for(int i=0;i<12;i++) {
                    var month = start.AddMonths(i);
                    long from = new DateTimeOffset(month).ToUnixTimeMilliseconds(), until = new DateTimeOffset(month.AddMonths(1)).ToUnixTimeMilliseconds();
                    Months.Add(new MonthTotal { Label = month.ToString("MMM yy", culture), ChartLabel = month.ToString(L.IsArabic ? "MM/yy" : "MMM yy", CultureInfo.InvariantCulture), Value = model.Events.Where(a => a.Date >= from && a.Date < until).Sum(a => a.Value) });
                }
                RangeCaption = string.Format(L.T("Coordinator.Dashboard.TwelveMonthCaption"), Months[0].Label, Months[11].Label);
                long rangeStart = new DateTimeOffset(start).ToUnixTimeMilliseconds(), previousStart = new DateTimeOffset(start.AddMonths(-12)).ToUnixTimeMilliseconds();
                long previous = model.Events.Where(a => a.Date >= previousStart && a.Date < rangeStart).Sum(a => a.Value);
                long current = Months.Sum(m => m.Value);
                model.Kpis[3].Value = current;
                model.Kpis[3].Records = model.Events.Where(a => a.Date >= rangeStart && a.Date <= model.Now).Select(a => a.Record).ToList();
                Comparison = previous > 0 ? string.Format(L.T("Shared.Js.ChartVsPrevious"), ((current - previous) * 100.0 / previous).ToString("+0.#;-0.#;0", CultureInfo.InvariantCulture)) : "";
                int recordedMonths = Months.Count(m => m.Value > 0);
                HistoryNote = L.T(recordedMonths == 1 ? "Shared.Js.ChartOneMonth" : "Coordinator.Dashboard.DatedApprovalsNote") + " " + L.T("Shared.Js.ChartCoordinatorNote");
                if (model.Undated.Count > 0) HistoryNote += " " + string.Format(L.T("Coordinator.Dashboard.UndatedApprovals"), model.Undated.Count);
                Model = model;
            }
            catch (FirebaseException) { /* The visible retry state must never report a read failure as zero. */ }
        }

        protected string KpiValue(int index)
        {
            return Model.Kpis[index].Value.ToString("N0", CultureInfo.InvariantCulture);
        }
    }
}
