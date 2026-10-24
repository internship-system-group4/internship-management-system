using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Services;

namespace InternshipManagementSystem.Pages.StudentArea
{
    public partial class Progress : InternshipManagementSystem.Security.StudentPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.QueryString["report"] == "1")
            {
                ServeReport();
                return;
            }
            LoadProgress();
        }

        private void LoadProgress()
        {
            Student student = CurrentStudent;
            Placement placement = new PlacementRepository().GetById(student.Id);
            if (placement == null || placement.StudentId != student.Id)
            {
                pnlNoPlacement.Visible = true;
                pnlProgress.Visible = false;
                return;
            }

            pnlNoPlacement.Visible = false;
            pnlProgress.Visible = true;
            CompletionRecord completion = new CompletionRepository().GetByStudent(student.Id);
            var completionRule = completion != null && completion.StudentId == student.Id && completion.PlacementId == placement.Id
                ? completion.EvaluationRuleSnapshot : null;
            litPlacement.Text = Server.HtmlEncode(string.IsNullOrWhiteSpace(placement.OpportunityTitle)
                ? L.T("Student.Progress.YourInternship") : placement.OpportunityTitle);
            litCompany.Text = Server.HtmlEncode(placement.CompanyName ?? L.T("Student.Progress.CompanyNotSpecified"));

            List<InternshipTask> tasks = new TaskRepository().GetByPlacement(placement.Id)
                .Where(t => t.StudentId == student.Id && !string.IsNullOrEmpty(t.Id)).ToList();
            HashSet<string> taskIds = new HashSet<string>(tasks.Select(t => t.Id), StringComparer.Ordinal);
            List<Submission> submissions = new SubmissionRepository().GetByPlacement(placement.Id)
                .Where(s => s.StudentId == student.Id && taskIds.Contains(s.TaskId)).ToList();
            // Only task evaluations are student-visible. Never read either final evaluation form here.
            List<TaskEvaluation> evaluations = new EvaluationRepository().GetTaskEvaluationsForStudent(student.Id)
                .Where(e => e.PlacementId == placement.Id && taskIds.Contains(e.TaskId)).ToList();

            List<TaskRow> rows = tasks.OrderBy(t => t.Deadline == 0 ? long.MaxValue : t.Deadline)
                .ThenBy(t => t.CreatedAt).Select(t => BuildTaskRow(t, submissions, evaluations)).ToList();
            rptTasks.DataSource = rows;
            rptTasks.DataBind();
            pnlNoTasks.Visible = rows.Count == 0;
            litTaskCount.Text = rows.Count.ToString(CultureInfo.InvariantCulture);
            litSubmittedCount.Text = rows.Count(r => r.HasSubmission).ToString(CultureInfo.InvariantCulture);
            litRevisionCount.Text = rows.Count(r => r.NeedsRevision).ToString(CultureInfo.InvariantCulture);
            litGradedCount.Text = rows.Count(r => r.HasGrade).ToString(CultureInfo.InvariantCulture);

            List<TrainingHoursEntry> entries = new HoursRepository().GetByPlacement(placement.Id)
                .Where(h => h.StudentId == student.Id).ToList();
            List<HoursRow> approved = entries.Where(h => h.Status == HoursStatus.Approved)
                .OrderByDescending(h => h.WorkDate).ThenByDescending(h => h.ReportedAt)
                .Select(h => new HoursRow
                {
                    Date = Time.DisplayDate(h.WorkDate > 0 ? h.WorkDate : h.ReportedAt),
                    Description = string.IsNullOrWhiteSpace(h.Description) ? L.T("Student.Progress.TrainingHours3") : h.Description,
                    Hours = h.Hours.ToString(CultureInfo.InvariantCulture)
                }).ToList();
            int approvedHours = entries.Where(h => h.Status == HoursStatus.Approved).Sum(h => Math.Max(0, h.Hours));
            int pendingHours = entries.Where(h => h.Status == HoursStatus.Reported).Sum(h => Math.Max(0, h.Hours));
            int requiredHours = completionRule != null ? completionRule.RequiredHours :
                placement.RequiredHours > 0 ? placement.RequiredHours : student.RequiredHours;
            int percent = requiredHours > 0
                ? (int)Math.Min(100, (approvedHours * 100L) / requiredHours) : 0;
            litHours.Text = approvedHours.ToString(CultureInfo.InvariantCulture);
            litRequiredHours.Text = requiredHours > 0
                ? requiredHours.ToString(CultureInfo.InvariantCulture) : completionRule != null && completionRule.RequiredDurationDays > 0
                    ? Server.HtmlEncode("Duration requirement: " + completionRule.RequiredDurationDays + " days") : L.T("Student.Progress.NotSet");
            litPendingHours.Text = pendingHours.ToString(CultureInfo.InvariantCulture);
            litHoursPercent.Text = percent.ToString(CultureInfo.InvariantCulture) + "%";
            hoursBar.Style["width"] = percent.ToString(CultureInfo.InvariantCulture) + "%";
            hoursProgress.Attributes["aria-valuenow"] = percent.ToString(CultureInfo.InvariantCulture);
            rptHours.DataSource = approved;
            rptHours.DataBind();
            pnlNoHours.Visible = approved.Count == 0;

            List<AcademicComment> comments = new AcademicCommentRepository().GetByPlacement(placement.Id)
                .Where(c => c.StudentId == student.Id && c.IsVisibleToStudent &&
                            !string.IsNullOrWhiteSpace(c.Comment))
                .OrderByDescending(c => c.CreatedAt).ToList();
            rptComments.DataSource = comments.Select(c => new CommentRow
            {
                Date = Time.Display(c.CreatedAt),
                Text = c.Comment
            }).ToList();
            rptComments.DataBind();
            pnlNoComments.Visible = comments.Count == 0;

            bool ownReview = completion != null && completion.PlacementId == placement.Id && completion.StudentId == student.Id;
            bool returnedOrRejected = ownReview && (completion.Status == CompletionStatus.NeedsCorrections || completion.Status == CompletionStatus.Rejected);
            pnlAdministrativeDecision.Visible = returnedOrRejected;
            if (returnedOrRejected)
            {
                litCompletionStatus.Text = completion.Status == CompletionStatus.NeedsCorrections ? L.T("Student.Progress.NeedsCorrections") : L.T("Student.Progress.Rejected");
                litCompletionNote.Text = Server.HtmlEncode(completion.CoordinatorNote ?? "");
            }
            bool approvedResult = completion != null && completion.PlacementId == placement.Id &&
                                  completion.StudentId == student.Id &&
                                  completion.Status == CompletionStatus.Approved;
            bool failedResult = completion != null && completion.PlacementId == placement.Id &&
                                completion.StudentId == student.Id &&
                                completion.Status == CompletionStatus.Rejected && completion.Result == "Fail";
            pnlFinalResult.Visible = approvedResult || failedResult;
            pnlAwaitingResult.Visible = !approvedResult && !failedResult && !returnedOrRejected;
            pnlApprovedDate.Visible = approvedResult;
            pnlFailedResult.Visible = failedResult;
            if (approvedResult || failedResult)
            {
                litFinalResult.Text = approvedResult ? Server.HtmlEncode(completion.Result ?? "Completed") : "Fail";
                if (approvedResult) litApprovedDate.Text = Time.DisplayDate(completion.ApprovedAt);
            }
            bool reportReady = approvedResult && PdfReportService.MayDownload(completion, student) &&
                               IsSafeReportUrl(completion.ReportFileUrl);
            pnlReportReady.Visible = reportReady;
            pnlReportPending.Visible = approvedResult && !reportReady;
        }

        protected void btnReport_Click(object sender, EventArgs e)
        {
            Student student = CurrentStudent;
            Placement placement = new PlacementRepository().GetById(student.Id);
            CompletionRecord completion = new CompletionRepository().GetByStudent(student.Id);
            if (placement == null || placement.StudentId != student.Id || completion == null ||
                completion.PlacementId != placement.Id || completion.StudentId != student.Id ||
                !PdfReportService.MayDownload(completion, student) ||
                !IsSafeReportUrl(completion.ReportFileUrl))
            {
                Response.StatusCode = 403;
                litReportError.Text = L.T("Student.Progress.TheApprovedReportIsNotAvailable");
                return;
            }

            Response.Redirect(completion.ReportFileUrl == PdfReportService.StudentReportPath
                ? ResolveUrl(PdfReportService.StudentReportPath) : completion.ReportFileUrl, true);
        }

        private static bool IsSafeReportUrl(string url)
        {
            return url == PdfReportService.StudentReportPath;
        }

        private void ServeReport()
        {
            Student student = CurrentStudent;
            Placement placement = new PlacementRepository().GetById(student.Id);
            CompletionRecord completion = new CompletionRepository().GetByStudent(student.Id);
            if (placement == null || placement.StudentId != student.Id || completion == null ||
                completion.PlacementId != placement.Id || completion.StudentId != student.Id ||
                completion.ReportFileUrl != PdfReportService.StudentReportPath ||
                !PdfReportService.MayDownload(completion, student))
            {
                Response.StatusCode = 403;
                return;
            }
            byte[] bytes = PdfReportService.CreateCompletionReportPdf(completion, student, placement);
            Response.Clear();
            Response.ContentType = "application/pdf";
            Response.AddHeader("Content-Disposition", "attachment; filename=internship-completion-report.pdf");
            Response.BinaryWrite(bytes);
            Response.End();
        }

        private static TaskRow BuildTaskRow(InternshipTask task, List<Submission> submissions,
                                            List<TaskEvaluation> evaluations)
        {
            List<Submission> attempts = submissions.Where(s => s.TaskId == task.Id).ToList();
            List<TaskEvaluation> reviews = evaluations.Where(e => e.TaskId == task.Id).ToList();
            Submission latestAttempt = attempts.OrderByDescending(s => s.SubmittedAt).FirstOrDefault();
            TaskEvaluation latestReview = reviews.OrderByDescending(e => e.EvaluatedAt).FirstOrDefault();
            TaskEvaluation latestGrade = reviews.Where(e => !e.RevisionRequested)
                .OrderByDescending(e => e.EvaluatedAt).FirstOrDefault();
            bool needsRevision = latestReview != null && latestReview.RevisionRequested &&
                                 (latestAttempt == null || latestReview.EvaluatedAt >= latestAttempt.SubmittedAt);
            if (latestReview == null && task.Status == InternshipTaskStatus.RevisionRequested)
                needsRevision = true;
            bool hasCurrentGrade = !needsRevision && latestGrade != null && latestGrade.MaxScore > 0 &&
                                   (latestAttempt == null || latestGrade.EvaluatedAt >= latestAttempt.SubmittedAt);
            bool resubmitted = latestReview != null && latestReview.RevisionRequested &&
                               latestAttempt != null && latestAttempt.SubmittedAt > latestReview.EvaluatedAt;
            List<HistoryRow> history = new List<HistoryRow>();
            foreach (Submission attempt in attempts)
            {
                history.Add(new HistoryRow
                {
                    SortTime = attempt.SubmittedAt,
                    Date = Time.Display(attempt.SubmittedAt),
                    Label = "Submission · attempt " + attempt.AttemptNumber.ToString(CultureInfo.InvariantCulture),
                    Detail = string.IsNullOrWhiteSpace(attempt.DescriptionText)
                        ? L.T("Student.Progress.WorkSubmitted") : attempt.DescriptionText,
                    Meta = !string.IsNullOrWhiteSpace(attempt.LinkUrl) ? L.T("Student.Progress.IncludesALink") :
                           !string.IsNullOrWhiteSpace(attempt.FileName) ? "File: " + attempt.FileName : ""
                });
            }
            foreach (TaskEvaluation review in reviews)
            {
                history.Add(new HistoryRow
                {
                    SortTime = review.EvaluatedAt,
                    Date = Time.Display(review.EvaluatedAt),
                    Label = review.RevisionRequested ? L.T("Student.Progress.RevisionRequested2") : L.T("Student.Progress.TaskEvaluated"),
                    Detail = review.RevisionRequested
                        ? RevisionDetail(review)
                        : FirstText(review.Feedback, L.T("Student.Progress.NoWrittenFeedbackWasProvided")),
                    Meta = review.RevisionRequested || review.MaxScore <= 0 ? "" :
                        Score(review.TotalScore) + " / " + Score(review.MaxScore)
                });
            }
            if (history.Count == 0)
            {
                history.Add(new HistoryRow
                {
                    Date = "",
                    Label = L.T("Student.Progress.NoSubmissionYet"),
                    Detail = L.T("Student.Progress.SubmitYourWorkFromMyTasks"),
                    Meta = ""
                });
            }
            return new TaskRow
            {
                Title = string.IsNullOrWhiteSpace(task.Title) ? L.T("Student.Progress.UntitledTask") : task.Title,
                Deadline = Time.DisplayDate(task.Deadline),
                Status = needsRevision ? L.T("Student.Progress.RevisionRequested2") : hasCurrentGrade ? "Graded" :
                    resubmitted ? "Resubmitted" : StatusLabel(task.Status),
                StatusClass = needsRevision ? "uims-pill-rejected" :
                    hasCurrentGrade ? "uims-pill-accepted" : "uims-pill-info",
                Grade = !hasCurrentGrade
                    ? L.T("Student.Progress.NotGraded") : Score(latestGrade.TotalScore) + " / " + Score(latestGrade.MaxScore),
                HasGrade = hasCurrentGrade,
                HasSubmission = attempts.Count > 0,
                NeedsRevision = needsRevision,
                History = history.OrderByDescending(h => h.SortTime).ToList()
            };
        }

        private static string Score(double score)
        {
            return score.ToString("0.##", CultureInfo.InvariantCulture);
        }

        private static string FirstText(params string[] choices)
        {
            return choices.FirstOrDefault(c => !string.IsNullOrWhiteSpace(c)) ?? "";
        }

        private static string RevisionDetail(TaskEvaluation review)
        {
            string detail = string.Join("\n", new[] { review.RevisionInstructions, review.Feedback }
                .Where(value => !string.IsNullOrWhiteSpace(value)).Distinct().ToArray());
            return string.IsNullOrEmpty(detail) ? L.T("Student.Progress.PleaseReviseThisSubmission") : detail;
        }

        private static string StatusLabel(InternshipTaskStatus status)
        {
            switch (status)
            {
                case InternshipTaskStatus.Assigned: return "Assigned";
                case InternshipTaskStatus.Submitted: return "Submitted";
                case InternshipTaskStatus.UnderReview: return L.T("Student.Progress.UnderReview2");
                case InternshipTaskStatus.RevisionRequested: return L.T("Student.Progress.RevisionRequested2");
                case InternshipTaskStatus.Resubmitted: return "Resubmitted";
                case InternshipTaskStatus.Graded: return "Graded";
                default: return L.T("Student.Progress.InProgress");
            }
        }

        public sealed class TaskRow
        {
            public string Title { get; set; }
            public string Deadline { get; set; }
            public string Status { get; set; }
            public string StatusClass { get; set; }
            public string Grade { get; set; }
            public bool HasGrade { get; set; }
            public bool HasSubmission { get; set; }
            public bool NeedsRevision { get; set; }
            public List<HistoryRow> History { get; set; }
        }

        public sealed class HistoryRow
        {
            public long SortTime { get; set; }
            public string Date { get; set; }
            public string Label { get; set; }
            public string Detail { get; set; }
            public string Meta { get; set; }
        }

        public sealed class HoursRow
        {
            public string Date { get; set; }
            public string Description { get; set; }
            public string Hours { get; set; }
        }

        public sealed class CommentRow
        {
            public string Date { get; set; }
            public string Text { get; set; }
        }
    }
}
