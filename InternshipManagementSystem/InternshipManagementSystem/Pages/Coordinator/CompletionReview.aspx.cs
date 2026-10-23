using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web.UI;
using System.Web.UI.WebControls;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Services;

namespace InternshipManagementSystem.Pages.CoordinatorArea
{
    public partial class CompletionReview : InternshipManagementSystem.Security.CoordinatorPage
    {
        private CompletionReviewEvidence initial;
        private string initialVersion;
        private string loadError;
        protected override void OnInit(EventArgs e)
        {
            ViewStateUserKey = Session.SessionID;
            base.OnInit(e);
            if (IsValidId(Request.QueryString["id"]))
            {
                try
                {
                    initial = ReadReview(Request.QueryString["id"], out initialVersion);
                    if (initial != null) BindRequirements(initial);
                }
                catch (FirebaseAuthExpiredException) { throw; }
                catch (FirebaseException) { loadError = "The review could not be loaded from Firebase. Retry after checking the connection."; }
                catch (InvalidOperationException ex) { loadError = ex.Message; }
            }
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            CompletionReviewService.RequireCoordinator(CurrentUser);
            Response.Cache.SetCacheability(System.Web.HttpCacheability.NoCache);
            Response.Cache.SetNoStore();
            if (Request.QueryString["certificate"] != null) { ServePdf(Request.QueryString["certificate"], true); return; }
            if (Request.QueryString["report"] != null) { ServePdf(Request.QueryString["report"], false); return; }
            if (loadError != null) { ShowMessage(loadError, false); return; }
            if (IsPostBack) return;
            try
            {
                BindPlacements();
                if (initial != null) DisplayReview(initial, initialVersion);
                else if (Request.QueryString["id"] != null) ShowMessage("Student or placement not found. Select a valid internship from the queue.", false);
            }
            catch (FirebaseAuthExpiredException) { throw; }
            catch (FirebaseException) { ShowMessage("The queue could not be loaded from Firebase. Please retry.", false); }
            catch (InvalidOperationException ex) { ShowMessage(ex.Message, false); }
        }
        private CompletionReviewEvidence ReadReview(string studentId, out string version)
        {
            version = null;
            var student = new UserRepository().GetStudent(studentId);
            var placement = new PlacementRepository().GetById(studentId);
            if (student == null || placement == null || placement.StudentId != studentId) return null;
            var record = new CompletionRepository().ReadForReview(placement.Id, out version);
            if (record != null && record.StudentId != studentId) throw new InvalidOperationException("Completion record belongs to another student.");
            var repository = new EvaluationRepository();
            return new CompletionReviewEvidence
            {
                Student = student, Placement = placement, Record = record,
                Rule = record == null ? null : record.EvaluationRuleSnapshot,
                Company = repository.GetCompanyFinalForPlacement(placement.Id),
                Academic = repository.GetAcademicFinalForPlacement(placement.Id),
                Tasks = new TaskRepository().GetByPlacement(placement.Id).Where(t => t.StudentId == studentId && !string.IsNullOrEmpty(t.Id)).ToList(),
                TaskEvaluations = repository.GetTaskEvaluationsForPlacement(placement.Id).Where(t => t.StudentId == studentId && t.EvaluatedBySupervisorId == placement.CompanySupervisorId).ToList(),
                Submissions = new SubmissionRepository().GetByPlacement(placement.Id).Where(s => s.StudentId == studentId).ToList(),
                Hours = new HoursRepository().GetByPlacement(placement.Id).Where(h => h.StudentId == studentId).ToList()
            };
        }
        protected void btnFilter_Click(object sender, EventArgs e)
        {
            try { BindPlacements(); if (initial != null) DisplayReview(initial, initialVersion); }
            catch (FirebaseAuthExpiredException) { throw; }
            catch (FirebaseException) { ShowMessage("Could not load the queue. Please retry.", false); }
            catch (InvalidOperationException ex) { ShowMessage(ex.Message, false); }
        }
        private void BindPlacements()
        {
            var rows = new List<PlacementListRow>();
            foreach (var p in new PlacementRepository().GetAll().Where(p => p.Status != PlacementStatus.Cancelled && IsValidId(p.StudentId)).OrderBy(p => p.StudentName))
            {
                string version;
                var e = ReadReview(p.StudentId, out version);
                if (e == null) continue;
                var a = CompletionReviewService.Assess(e, Time.NowMs());
                string status = Workflow(e, a);
                string searchable = string.Join(" ", new[] { e.Student.FullName, e.Student.StudentNumber, e.Student.Major, p.CompanyName });
                if (!string.IsNullOrEmpty(ddlStatus.SelectedValue) && status != ddlStatus.SelectedValue) continue;
                if (!string.IsNullOrWhiteSpace(txtSearch.Text) && searchable.IndexOf(txtSearch.Text.Trim(), StringComparison.OrdinalIgnoreCase) < 0) continue;
                rows.Add(new PlacementListRow { StudentName = First(e.Student.FullName, p.StudentName), StudentNumber = First(e.Student.StudentNumber, "Not recorded"), Program = First(e.Student.Major, "Not recorded"), Company = p.CompanyName,
                    InternshipType = e.Rule == null ? "Configuration required" : e.Rule.InternshipType,
                    TrainingStatus = p.Status + (p.EndDate > Time.NowMs() ? " · Training ongoing" : ""),
                    EvaluationStatus = a.EvaluationIssues.Count == 0 ? "Complete" : "Pending / configuration needed",
                    Status = status, ReviewUrl = ResolveUrl("~/Pages/Coordinator/CompletionReview.aspx?id=" + Server.UrlEncode(p.StudentId)) });
            }
            rptPlacements.DataSource = rows;
            rptPlacements.DataBind();
            pnlNoPlacements.Visible = rows.Count == 0;
        }
        private static string Workflow(CompletionReviewEvidence e, CompletionAssessment a)
        {
            if (e.Record != null && e.Record.Status == CompletionStatus.Approved) return "Approved";
            if (e.Record != null && e.Record.Status == CompletionStatus.Rejected) return "Rejected";
            if (e.Record != null && e.Record.Status == CompletionStatus.NeedsCorrections) return "Needs Corrections";
            if (e.Placement.EndDate <= 0 || e.Placement.EndDate > Time.NowMs()) return "In Progress";
            if (e.Rule != null && a.ApprovedHours < e.Rule.RequiredHours) return "In Progress";
            return a.EvaluationIssues.Count > 0 ? "Awaiting Evaluations" : "Ready for Review";
        }
        private void DisplayReview(CompletionReviewEvidence e, string version)
        {
            var a = CompletionReviewService.Assess(e, Time.NowMs());
            var r = e.Record;
            bool finalized = CompletionReviewService.IsFinal(r);
            bool approved = r != null && r.Status == CompletionStatus.Approved;
            pnlReview.Visible = true; pnlSelect.Visible = false;
            ViewState["ReviewVersion"] = version;
            litStudent.Text = Encode(First(e.Student.FullName, e.Placement.StudentName));
            var academic = new UserRepository().GetAcademicSupervisor(e.Placement.AcademicSupervisorId);
            litFacts.Text = Fact("Student number", e.Student.StudentNumber) + Fact("Academic program", e.Student.Major) +
                Fact("Company", e.Placement.CompanyName) + Fact("Company supervisor", e.Placement.CompanySupervisorName) +
                Fact("Academic supervisor", academic == null ? "Not assigned" : academic.FullName) +
                Fact("Internship type", e.Rule == null ? "Configuration required" : e.Rule.InternshipType) +
                Fact("Training start", Time.DisplayDate(e.Placement.StartDate)) + Fact("Training end", Time.DisplayDate(e.Placement.EndDate)) +
                Fact("Placement status", e.Placement.Status.ToString()) +
                Fact("School approval before training", PriorApprovalLabel(e)) +
                Fact("Approved training hours", a.ApprovedHours.ToString(CultureInfo.InvariantCulture)) +
                Fact("Required hours / duration", e.Rule == null ? "Configuration required" : e.Rule.RequiredHours + " hours / " + e.Rule.RequiredDurationDays + " days (where configured)");
            litCompanyEvidence.Text = Fact("Submission status", a.CompanySubmitted ? "Submitted" : "Missing, draft or invalid submission") +
                Fact("Evaluation on submitted scale", a.CompanySubmitted ? Score(e.Company.TotalScore, e.Company.MaxScore) : "Not submitted") +
                Fact("Company supervisor", e.Placement.CompanySupervisorName) + Fact("Submission date", a.CompanySubmitted ? Time.Display(e.Company.SubmittedAt) : "Not submitted");
            litAcademicEvidence.Text = Fact("Submission status", a.AcademicSubmitted ? "Submitted to coordinator" : "Missing, draft or invalid submission") +
                Fact("Evaluation on submitted scale", a.AcademicSubmitted ? Score(e.Academic.TotalScore, e.Academic.MaxScore) : "Not submitted") +
                Fact("Academic supervisor", academic == null ? "Not assigned" : academic.FullName) + Fact("Submission date", a.AcademicSubmitted ? Time.Display(e.Academic.SubmittedAt) : "Not submitted");
            litCompanyComments.Text = Encode(!a.CompanySubmitted ? "No submitted company comments." : string.Join("\n", new[] { e.Company.Strengths, e.Company.AreasForImprovement, e.Company.OverallComment }.Where(s => !string.IsNullOrWhiteSpace(s))));
            litAcademicComments.Text = Encode(!a.AcademicSubmitted ? "No submitted academic comments." : string.Join("\n", new[] { e.Academic.AcademicComments, e.Academic.CompanyEvaluationRemarks }.Where(s => !string.IsNullOrWhiteSpace(s))));
            litTasks.Text = "<p>" + Encode("Total assigned tasks: " + e.Tasks.Count + " · Completed tasks with current grades: " + a.CompletedTasks + " · Outstanding tasks: " + (e.Tasks.Count - a.CompletedTasks)) + "</p>";
            litRule.Text = e.Rule == null ? "<p role=\"status\">Configuration required. No default evaluation policy has been applied.</p>" :
                "<p>" + Encode("Evaluation Method: " + e.Rule.SourceClassification + " · " + e.Rule.EvaluationMethod + " · " + e.Rule.Id) + "</p>" +
                (e.Rule.EvaluationMethod == "Weighted" ? "<p>" + Encode("Tasks " + e.Rule.TaskWeight + "% / Company " + e.Rule.CompanyWeight + "% / Academic " + e.Rule.AcademicWeight + "%; passing criterion " + e.Rule.PassingPercent + "%. " +
                    (e.Rule.SourceClassification == "Project-Proposed" ? "These are project-proposed rules, not verified GJU internship grading policy." : "Official source reference: " + e.Rule.SourceUrl)) + "</p>" : "");
            ddlRule.Items.Clear(); ddlRule.Items.Add(new ListItem("Select an applicable rule", ""));
            foreach (var rule in new CompletionRuleRepository().GetAll().Where(rule => CompletionReviewService.Applies(rule, e.Student)))
                ddlRule.Items.Add(new ListItem(rule.InternshipType + " · " + rule.SourceClassification + " · " + rule.Id, rule.Id));
            if (e.Rule != null && ddlRule.Items.FindByValue(e.Rule.Id) != null) ddlRule.SelectedValue = e.Rule.Id;
            pnlConfiguration.Visible = !finalized;
            litIssues.Text = approved ? "<p>The approved record is read-only. Documents use the saved approval snapshot.</p>" :
                a.Issues.Count == 0 ? "<p role=\"status\">All configured evidence is verified. Pending Coordinator Approval.</p>" :
                "<ul role=\"status\">" + string.Join("", a.Issues.Select(i => "<li>" + Encode(i) + "</li>")) + "</ul>";
            BindRequirements(e);
            btnVerify.Visible = !finalized && e.Rule != null;
            litReviewStatus.Text = Encode(Workflow(e, a));
            litProposedResult.Text = Encode(finalized ? First(r.ProvisionalResult, First(r.Result, "Not recorded")) : First(a.Result, "Pending evidence or configuration"));
            var score = finalized ? r.ProvisionalScore : a.Score;
            pnlInternalScore.Visible = score.HasValue;
            litInternalScore.Text = score.HasValue ? Encode(score.Value.ToString("0.##", CultureInfo.InvariantCulture) + "%") : "";
            litSavedNote.Text = r == null ? "" : "<p class=\"review-comments\">" + Encode(r.CoordinatorNote) + "</p>";
            txtCoordinatorNote.Text = r == null ? "" : r.CoordinatorNote;
            pnlDecision.Visible = !finalized;
            btnApprove.Enabled = a.CanApprove && !finalized;
            pnlDownloads.Visible = approved;
            lnkReport.NavigateUrl = ResolveUrl("~/Pages/Coordinator/CompletionReview.aspx?report=" + Server.UrlEncode(e.Student.Id));
            lnkCertificate.NavigateUrl = ResolveUrl("~/Pages/Coordinator/CompletionReview.aspx?certificate=" + Server.UrlEncode(e.Student.Id));
            litAudit.Text = r == null || r.AuditTrail == null || r.AuditTrail.Count == 0 ? "<p>No recorded review history.</p>" :
                "<ul>" + string.Join("", r.AuditTrail.OrderByDescending(x => x.Timestamp).Select(x => "<li>" + Encode(Time.Display(x.Timestamp) + " · " + x.Action + " · " + x.CoordinatorId + " · " + x.Note) + "</li>")) + "</ul>";
        }
        private static string PriorApprovalLabel(CompletionReviewEvidence e)
        {
            var v = e.Record == null || e.Record.Verifications == null ? null : e.Record.Verifications.FirstOrDefault(x => x.Key == "prior-approval" && x.Confirmed);
            return v != null && v.EvidenceDate > 0 && v.EvidenceDate < e.Placement.StartDate ? "Verified · " + Time.DisplayDate(v.EvidenceDate) : "Not verified";
        }
        private void BindRequirements(CompletionReviewEvidence e)
        {
            rptRequirements.DataSource = e.Rule == null || e.Rule.Requirements == null ? new List<RequirementRow>() : e.Rule.Requirements.Select(q =>
            {
                var v = e.Record == null || e.Record.Verifications == null ? null : e.Record.Verifications.FirstOrDefault(x => x.Key == q.Key);
                return new RequirementRow { Key = q.Key, Label = q.Label, Source = q.SourceClassification + " · " + q.SourceUrl,
                    Confirmed = v != null && v.Confirmed, Reference = v == null ? "" : v.EvidenceReference,
                    Date = v == null || v.EvidenceDate <= 0 ? "" : Time.FromUnixMs(v.EvidenceDate).ToString("yyyy-MM-dd"),
                    NeedsDate = q.RequiresPriorApprovalDate, Editable = !CompletionReviewService.IsFinal(e.Record),
                    Audit = v == null ? "Not verified" : "Saved by " + v.CoordinatorId + " · " + Time.Display(v.VerifiedAt) };
            }).ToList();
            rptRequirements.DataBind();
        }
        private void Execute(Action<CompletionReviewEvidence, string> action)
        {
            try
            {
                CompletionReviewService.RequireCoordinator(CurrentUser);
                if (!IsValidId(Request.QueryString["id"])) throw new InvalidOperationException("Select a valid student.");
                string version;
                var e = ReadReview(Request.QueryString["id"], out version);
                if (e == null) throw new InvalidOperationException("Placement not found.");
                if (e.Placement.Status == PlacementStatus.Cancelled || e.Placement.Status == PlacementStatus.Offered)
                    throw new InvalidOperationException("This placement is not eligible for completion review.");
                if (CompletionReviewService.IsFinal(e.Record)) throw new InvalidOperationException("This review has a final decision and is read-only.");
                if (version != (string)ViewState["ReviewVersion"]) throw new InvalidOperationException("This review has changed. Reload it before saving.");
                action(e, version);
            }
            catch (FirebaseAuthExpiredException) { throw; }
            catch (FirebaseException) { ShowMessage("The review could not be saved. Reload to check the latest state before retrying.", false); }
            catch (InvalidOperationException ex) { ShowMessage(ex.Message, false); }
        }
        private void Save(CompletionReviewEvidence e, CompletionRecord r, string version, string action, string note)
        {
            if (r.AuditTrail == null) r.AuditTrail = new List<CompletionAuditEntry>();
            r.AuditTrail.Add(new CompletionAuditEntry { Action = action, Note = note, CoordinatorId = CurrentUser.Id, Timestamp = Time.NowMs() });
            r.ReviewedByCoordinatorId = CurrentUser.Id; r.ReviewedAt = Time.NowMs();
            if (!new CompletionRepository().SaveReview(r, version, CurrentUser)) throw new InvalidOperationException("Another request changed this review. Reload before retrying.");
            string refreshedVersion;
            var refreshed = ReadReview(e.Student.Id, out refreshedVersion);
            DisplayReview(refreshed, refreshedVersion);
            BindPlacements();
            ShowMessage(action + " saved.", true);
        }
        private CompletionRecord Record(CompletionReviewEvidence e)
        { return e.Record ?? new CompletionRecord { PlacementId = e.Placement.Id, StudentId = e.Student.Id }; }
        protected void btnRule_Click(object sender, EventArgs args)
        {
            Execute((e, version) =>
            {
                var rule = new CompletionRuleRepository().GetAll().SingleOrDefault(q => q.Id == ddlRule.SelectedValue);
                string issue = CompletionReviewService.ConfigurationIssue(rule, e.Student);
                if (issue != null) throw new InvalidOperationException(issue);
                var r = Record(e); r.EvaluationRuleSnapshot = rule; r.Verifications = new List<RequirementVerification>();
                r.Status = CompletionStatus.UnderCoordinatorReview;
                Save(e, r, version, "Review configuration", rule.Id);
            });
        }
        protected void btnVerify_Click(object sender, EventArgs args)
        {
            Execute((e, version) =>
            {
                string issue = CompletionReviewService.ConfigurationIssue(e.Rule, e.Student);
                if (issue != null) throw new InvalidOperationException(issue);
                var r = Record(e); var verifications = new List<RequirementVerification>();
                foreach (RepeaterItem item in rptRequirements.Items)
                {
                    string key = ((HiddenField)item.FindControl("requirementKey")).Value;
                    var requirement = e.Rule.Requirements.SingleOrDefault(q => q.Key == key);
                    if (requirement == null) throw new InvalidOperationException("The verification does not match the configured requirements. Reload the review.");
                    bool confirmed = ((CheckBox)item.FindControl("confirmed")).Checked;
                    string reference = ((TextBox)item.FindControl("evidenceReference")).Text.Trim();
                    if (reference.Length > 1000 || (confirmed && reference.Length == 0)) throw new InvalidOperationException("Each confirmation needs a supporting evidence reference of up to 1,000 characters.");
                    long date = 0;
                    if (confirmed && requirement.RequiresPriorApprovalDate)
                    {
                        DateTime parsed;
                        if (!DateTime.TryParseExact(((TextBox)item.FindControl("evidenceDate")).Text, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out parsed))
                            throw new InvalidOperationException("Enter the documented school approval date.");
                        // Date-only evidence uses Amman time, independent of the server time zone.
                        date = new DateTimeOffset(DateTime.SpecifyKind(parsed, DateTimeKind.Unspecified), TimeSpan.FromHours(3)).ToUnixTimeMilliseconds();
                        if (date >= e.Placement.StartDate) throw new InvalidOperationException("School approval must precede training.");
                    }
                    verifications.Add(new RequirementVerification { Key = key, Confirmed = confirmed, EvidenceReference = reference, EvidenceDate = date, CoordinatorId = CurrentUser.Id, VerifiedAt = Time.NowMs() });
                }
                if (verifications.Select(v => v.Key).Distinct().Count() != e.Rule.Requirements.Count) throw new InvalidOperationException("Reload the complete verification checklist.");
                r.Verifications = verifications;
                Save(e, r, version, "Evidence verification", "Supporting evidence references recorded for " + verifications.Count + " requirements.");
            });
        }
        protected void btnApprove_Click(object sender, EventArgs e) { Decide(CompletionStatus.Approved); }
        protected void btnCorrections_Click(object sender, EventArgs e) { Decide(CompletionStatus.NeedsCorrections); }
        protected void btnReject_Click(object sender, EventArgs e) { Decide(CompletionStatus.Rejected); }
        private void Decide(CompletionStatus status)
        {
            Execute((e, version) =>
            {
                string note = (txtCoordinatorNote.Text ?? "").Trim();
                long now = Time.NowMs();
                CompletionReviewService.ValidateDecision(CurrentUser, e, status, note, now);
                var a = CompletionReviewService.Assess(e, now);
                var r = Record(e);
                r.Status = status; r.CoordinatorNote = note;
                r.ProvisionalScore = a.Score; r.ProvisionalResult = a.Result;
                r.CompanyEvaluationId = e.Company == null ? null : e.Company.Id;
                r.AcademicEvaluationId = e.Academic == null ? null : e.Academic.Id;
                r.ApprovedHours = a.ApprovedHours; r.RequiredHours = e.Rule == null ? 0 : e.Rule.RequiredHours;
                r.TaskScorePercent = a.TaskPercent ?? 0; r.CompanyScorePercent = a.CompanyPercent ?? 0; r.AcademicScorePercent = a.AcademicPercent ?? 0;
                r.FinalScore = a.Score ?? 0;
                // Administrative rejection/corrections never assign an academic Fail.
                r.Result = status == CompletionStatus.Approved ? (a.Result == "Pass" ? "Pass" : "Completed") : null;
                r.ApprovedAt = status == CompletionStatus.Approved ? now : 0;
                r.ReportFileUrl = null; r.CertificateFileUrl = null;
                if (status == CompletionStatus.Approved)
                {
                    r.DocumentSnapshot = new CompletionDocumentSnapshot { StudentName = e.Student.FullName, StudentNumber = e.Student.StudentNumber, Program = e.Student.Major, CompanyName = e.Placement.CompanyName, InternshipType = e.Rule.InternshipType, StartDate = e.Placement.StartDate, EndDate = e.Placement.EndDate };
                    r.ReportFileUrl = PdfReportService.GenerateCompletionReport(r, e.Student);
                    r.CertificateFileUrl = PdfReportService.GenerateCertificate(r, e.Student);
                    // Check that both separate PDF artifacts can render before releasing their routes.
                    PdfReportService.CreateCompletionReportPdf(r, e.Student, e.Placement);
                    PdfReportService.CreateCertificatePdf(r, e.Student, e.Placement);
                }
                Save(e, r, version, status == CompletionStatus.NeedsCorrections ? "Return for Corrections" : status.ToString(), note);
                if (status == CompletionStatus.Approved)
                {
                    try { new PlacementRepository().Update(e.Placement.Id, new Dictionary<string, object> { { "Status", (int)PlacementStatus.Completed }, { "ApprovedHours", a.ApprovedHours } }); }
                    catch (FirebaseAuthExpiredException) { throw; }
                    catch (FirebaseException) { ShowMessage("Completion was approved and the report released. Placement summary could not sync; reload before any further action.", false); }
                }
            });
        }
        private void ServePdf(string studentId, bool certificate)
        {
            if (!IsValidId(studentId)) { Response.StatusCode = 404; return; }
            var student = new UserRepository().GetStudent(studentId);
            var placement = new PlacementRepository().GetById(studentId);
            var record = new CompletionRepository().GetByStudent(studentId);
            if (student == null || placement == null || record == null || record.PlacementId != placement.Id ||
                record.StudentId != studentId || !PdfReportService.MayDownload(record, CurrentUser)) { Response.StatusCode = 403; return; }
            byte[] bytes = certificate ? PdfReportService.CreateCertificatePdf(record, student, placement) : PdfReportService.CreateCompletionReportPdf(record, student, placement);
            Response.Clear(); Response.ContentType = "application/pdf";
            Response.AddHeader("Content-Disposition", "attachment; filename=internship-" + (certificate ? "certificate" : "completion-report") + ".pdf");
            Response.BinaryWrite(bytes); Response.End();
        }
        private void ShowMessage(string message, bool success) { lblMessage.Text = Encode(message); lblMessage.CssClass = success ? "alert alert-success d-block" : "alert alert-danger d-block"; lblMessage.Visible = true; }
        private string Encode(string text) { return Server.HtmlEncode(text ?? ""); }
        private string Fact(string label, string value) { return "<div class=\"review-fact\"><small>" + Encode(label) + "</small><strong>" + Encode(First(value, "Not recorded")) + "</strong></div>"; }
        private static string First(string value, string fallback) { return string.IsNullOrWhiteSpace(value) ? fallback : value; }
        private static string Score(double score, double max) { return CompletionReviewService.ValidScore(score, max) ? score.ToString("0.##", CultureInfo.InvariantCulture) + " / " + max.ToString("0.##", CultureInfo.InvariantCulture) : "No valid numeric score on submitted scale"; }
        private static bool IsValidId(string id) { return !string.IsNullOrEmpty(id) && Regex.IsMatch(id, @"\A[A-Za-z0-9_-]{1,128}\z"); }
        public sealed class PlacementListRow
        {
            public string StudentName { get; set; } public string StudentNumber { get; set; } public string Program { get; set; } public string Company { get; set; } public string InternshipType { get; set; } public string TrainingStatus { get; set; } public string EvaluationStatus { get; set; } public string Status { get; set; } public string ReviewUrl { get; set; }
        }
        public sealed class RequirementRow
        {
            public string Key { get; set; } public string Label { get; set; } public string Source { get; set; } public bool Confirmed { get; set; } public string Reference { get; set; } public string Date { get; set; } public bool NeedsDate { get; set; } public bool Editable { get; set; } public string Audit { get; set; }
        }
    }
}
