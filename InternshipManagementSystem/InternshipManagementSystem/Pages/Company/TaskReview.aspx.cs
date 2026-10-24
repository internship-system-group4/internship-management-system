using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;
using InternshipManagementSystem.Services;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Web.UI.WebControls;

namespace InternshipManagementSystem.Pages.CompanyArea
{
    public partial class TaskReview : CompanyPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCompanySubmissions();

                // Opened from a notification: show that submission straight away.
                string fromLink = Request.QueryString["submission"];
                if (!string.IsNullOrEmpty(fromLink)) OpenSubmission(fromLink);
            }
        }

        private void LoadCompanySubmissions()
        {
            string selectedTaskId = Request.QueryString["taskId"];

            List<object> companySubmissions = new List<object>();

            // Speed: both collections are read at the same time.
            FirebaseContext.Prefetch(
                FirebaseRead.Node(Constants.Paths.Tasks),
                FirebaseRead.Node(Constants.Paths.Submissions));

            List<InternshipTask> tasks =
                new TaskRepository().GetAll();

            List<Submission> submissions =
                new SubmissionRepository().GetAll();
            PlacementRepository placementRepository =
    new PlacementRepository();
            List<TaskEvaluation> evaluations =
                new TaskEvaluationRepository().GetAll();
            foreach (InternshipTask task in tasks)
            {
                if (task.CompanyId != CurrentSupervisor.CompanyId)
                    continue;


                if (!string.IsNullOrWhiteSpace(selectedTaskId) &&
                    task.Id != selectedTaskId)
                {
                    continue;
                }
                Placement placement =
    placementRepository.GetById(task.PlacementId);

                string traineeName =
                    placement != null &&
                    placement.CompanyId == CurrentSupervisor.CompanyId &&
                    placement.StudentId == task.StudentId &&
                    !string.IsNullOrWhiteSpace(placement.StudentName)
                        ? placement.StudentName
                        : L.T("Company.TaskReview.NameUnavailable");

                foreach (Submission submission in submissions)
                {
                    if (submission.TaskId == task.Id &&
                        submission.StudentId == task.StudentId &&
                        submission.PlacementId == task.PlacementId)
                    {
                        companySubmissions.Add(new
                        {
                            Id = submission.Id,
                            TaskId = submission.TaskId,
                            TaskTitle = task.Title,
                            StudentId = submission.StudentId,
                            TraineeName = traineeName,
                            AttemptNumber = submission.AttemptNumber,
                            Status = GetSubmissionStatusLabel(submission, evaluations),
                            StatusKey = GetSubmissionStatusLabel(submission, evaluations),
                            StatusCss = GetSubmissionStatusCss(
                                GetSubmissionStatusLabel(submission, evaluations)),
                            CanReview = IsReviewableSubmission(
                                submission, task, submissions, evaluations),
                            ActionLabel = GetSubmissionActionLabel(
                                submission, task, submissions, evaluations),
                            SubmittedAt = submission.SubmittedAt
                        });
                    }
                }
            }

            rptSubmissions.DataSource = companySubmissions;
            rptSubmissions.DataBind();
        }

        protected void rptSubmissions_ItemCommand(
            object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "ViewDetails") return;

            OpenSubmission(Convert.ToString(e.CommandArgument));
        }

        private void OpenSubmission(string submissionId)
        {
            if (!ApplicationRepository.IsValidKey(submissionId)) return;
            Submission submission =
                new SubmissionRepository().GetById(submissionId);

            if (submission == null) return;

            InternshipTask task =
                new TaskRepository().GetById(submission.TaskId);

            // لا نعرض تسليمًا خارج شركة المشرف الحالي.
            if (task == null ||
                task.CompanyId != CurrentSupervisor.CompanyId ||
                task.StudentId != submission.StudentId ||
                task.PlacementId != submission.PlacementId)
            {
                return;
            }

            ViewState["SelectedSubmissionId"] = submission.Id;
            List<Submission> taskAttempts =
                new SubmissionRepository().GetByTask(task.Id);
            List<TaskEvaluation> taskEvaluations =
                new TaskEvaluationRepository().GetByTask(task.Id);
            TaskEvaluation existingEvaluation =
                FindEvaluationForSubmission(taskEvaluations, submission.Id);
            bool canReview = IsReviewableSubmission(
                submission, task, taskAttempts, taskEvaluations);

            btnSaveGrade.Visible = canReview;
            btnRequestRevision.Visible = canReview;
            txtCodeQuality.Enabled = canReview;
            txtFunctionality.Enabled = canReview;
            txtDesignUsability.Enabled = canReview;
            txtDocumentation.Enabled = canReview;
            txtFeedback.Enabled = canReview;
            lblReviewStatus.Text = L.Value("Ui", GetSubmissionStatusLabel(
                submission, taskEvaluations));
            lblReviewStatus.CssClass = canReview
                ? "review-pending-badge"
                : existingEvaluation != null && existingEvaluation.RevisionRequested
                    ? "review-pending-badge review-revision-badge"
                    : "review-pending-badge review-complete-badge";
            pnlSubmissionDirectory.Visible = false;
            pnlSubmissionDetails.Visible = true;
            lblReviewMessage.CssClass = canReview
                ? "review-message"
                : "review-message text-muted";
            lblReviewMessage.Text = "";
            if (existingEvaluation != null)
            {
                string recordedFeedback = existingEvaluation.RevisionRequested
                    ? existingEvaluation.RevisionInstructions
                    : existingEvaluation.Feedback;
                string reviewSummary = existingEvaluation.RevisionRequested
                    ? L.T("Company.I18n.AresubmissionwasrequestedInstructions")
                    : L.T("Company.I18n.Thissubmissionwasevaluated") +
                      existingEvaluation.TotalScore.ToString("0.##") + " / " +
                      existingEvaluation.MaxScore.ToString("0.##") +
                      L.T("Company.I18n.Feedback");
                lblReviewMessage.Text = Server.HtmlEncode(
                    reviewSummary + (recordedFeedback ?? ""));
            }
            else if (!canReview)
            {
                lblReviewMessage.Text =
                    L.T("Company.TaskReview.ANewerSubmissionAttemptIsAvailable");
            }

            lblDetailTask.Text = Server.HtmlEncode(task.Title ?? "");
            lblTaskMaxScore.Text = task.MaxScore.ToString(
                "0.##", System.Globalization.CultureInfo.InvariantCulture);
            lblDetailAttempt.Text =
                submission.AttemptNumber.ToString();
            if (existingEvaluation != null && existingEvaluation.Components != null)
            {
                foreach (GradeComponent component in existingEvaluation.Components)
                {
                    if (component == null) continue;
                    string score = component.Score.ToString(
                        "0.##", System.Globalization.CultureInfo.InvariantCulture);
                    if (component.Name == "Code quality") txtCodeQuality.Text = score;
                    else if (component.Name == "Functionality") txtFunctionality.Text = score;
                    else if (component.Name == "Design & usability") txtDesignUsability.Text = score;
                    else if (component.Name == "Documentation") txtDocumentation.Text = score;
                }

                txtFeedback.Text = existingEvaluation.RevisionRequested
                    ? existingEvaluation.RevisionInstructions ?? ""
                    : existingEvaluation.Feedback ?? "";
            }
            Placement placement = new PlacementRepository()
                .GetById(submission.PlacementId);
            lblDetailTrainee.Text = Server.HtmlEncode(
                placement != null && !string.IsNullOrWhiteSpace(placement.StudentName)
                    ? placement.StudentName
                    : submission.StudentId);
            lblDetailSubmittedAt.Text = DateTimeOffset
                .FromUnixTimeMilliseconds(submission.SubmittedAt)
                .ToLocalTime()
                .ToString("dd MMM yyyy, h:mm tt");
            lblDetailDeadline.Text = task.Deadline > 0
                ? DateTimeOffset.FromUnixTimeMilliseconds(task.Deadline)
                    .ToLocalTime().ToString("dd MMM yyyy, h:mm tt")
                : L.T("Company.TaskReview.NotSet");

            lblDetailText.Text = Server.HtmlEncode(
                string.IsNullOrWhiteSpace(submission.DescriptionText)
                    ? L.T("Company.TaskReview.NoTextSubmitted")
                    : submission.DescriptionText);

            Uri link;
            lnkDetailWork.Visible =
                Uri.TryCreate(
                    submission.LinkUrl, UriKind.Absolute, out link) &&
                (link.Scheme == Uri.UriSchemeHttp ||
                 link.Scheme == Uri.UriSchemeHttps);

            if (lnkDetailWork.Visible)
            {
                lnkDetailWork.NavigateUrl = submission.LinkUrl;
            }

            Uri file;
            lnkDetailFile.Visible =
                Uri.TryCreate(
                    submission.FileUrl, UriKind.Absolute, out file) &&
                file.Scheme == Uri.UriSchemeHttps;

            if (lnkDetailFile.Visible)
            {
                lnkDetailFile.NavigateUrl = submission.FileUrl;
                lnkDetailFile.Text = string.IsNullOrWhiteSpace(submission.FileName)
                    ? L.T("Company.TaskReview.ViewSubmissionFile")
                    : L.T("Company.TaskReview.View") + Server.HtmlEncode(submission.FileName);
            }
        }

        private static TaskEvaluation FindEvaluationForSubmission(
            List<TaskEvaluation> evaluations, string submissionId)
        {
            if (evaluations == null) return null;

            foreach (TaskEvaluation evaluation in evaluations)
            {
                if (evaluation != null &&
                    evaluation.SubmissionId == submissionId)
                {
                    return evaluation;
                }
            }

            return null;
        }

        private static string GetSubmissionStatusLabel(
            Submission submission, List<TaskEvaluation> evaluations)
        {
            TaskEvaluation evaluation =
                FindEvaluationForSubmission(evaluations, submission.Id);

            if (evaluation != null)
            {
                return evaluation.RevisionRequested
                    ? "Revision requested"
                    : "Reviewed";
            }

            switch (submission.Status)
            {
                case SubmissionStatus.Submitted:
                    return "Awaiting review";
                case SubmissionStatus.UnderReview:
                    return "Under review";
                case SubmissionStatus.RevisionRequested:
                    return "Revision requested";
                case SubmissionStatus.Accepted:
                    return "Accepted";
                default:
                    return submission.Status.ToString();
            }
        }

        private static string GetSubmissionStatusCss(string status)
        {
            switch (status)
            {
                case "Awaiting review": return "submission-status status-awaiting";
                case "Under review": return "submission-status status-under-review";
                case "Revision requested": return "submission-status status-revision";
                case "Reviewed": return "submission-status status-reviewed";
                case "Accepted": return "submission-status status-reviewed";
                default: return "submission-status";
            }
        }

        private string GetSubmissionActionLabel(
            Submission submission,
            InternshipTask task,
            List<Submission> attempts,
            List<TaskEvaluation> evaluations)
        {
            if (IsReviewableSubmission(submission, task, attempts, evaluations))
            {
                return submission.Status == SubmissionStatus.UnderReview
                    ? L.T("Company.TaskReview.ContinueReview")
                    : L.T("Company.TaskReview.ReviewSubmission");
            }

            TaskEvaluation evaluation =
                FindEvaluationForSubmission(evaluations, submission.Id);
            if (evaluation != null)
            {
                return evaluation.RevisionRequested
                    ? L.T("Company.TaskReview.ViewRevisionRequest")
                    : L.T("Company.TaskReview.ViewEvaluation");
            }

            return L.T("Company.TaskReview.ViewAttempt");
        }
        private bool IsReviewableSubmission(
            Submission submission,
            InternshipTask task,
            List<Submission> attempts,
            List<TaskEvaluation> evaluations)
        {
            if (submission == null ||
                task == null ||
                task.CompanyId != CurrentSupervisor.CompanyId ||
                task.StudentId != submission.StudentId ||
                task.PlacementId != submission.PlacementId ||
                submission.TaskId != task.Id ||
                (submission.Status != SubmissionStatus.Submitted &&
                 submission.Status != SubmissionStatus.UnderReview) ||
                FindEvaluationForSubmission(evaluations, submission.Id) != null)
            {
                return false;
            }

            // Keep older attempts available for viewing, but only allow actions
            // on the latest attempt. Existing evaluations can be updated.
            if (attempts != null)
            {
                foreach (Submission attempt in attempts)
                {
                    if (attempt != null &&
                        attempt.StudentId == submission.StudentId &&
                        attempt.PlacementId == submission.PlacementId &&
                        (attempt.AttemptNumber > submission.AttemptNumber ||
                         (attempt.AttemptNumber == submission.AttemptNumber &&
                          attempt.SubmittedAt > submission.SubmittedAt)))
                    {
                        return false;
                    }
                }
            }

            return true;
        }
        protected void btnSaveGrade_Click(object sender, EventArgs e)
        {
            string submissionId =
                ViewState["SelectedSubmissionId"] as string;

            if (string.IsNullOrEmpty(submissionId)) return;

            SubmissionRepository submissionRepository =
                new SubmissionRepository();

            Submission submission =
                submissionRepository.GetById(submissionId);

            if (submission == null) return;

            TaskRepository taskRepository = new TaskRepository();
            InternshipTask task =
                taskRepository.GetById(submission.TaskId);

            // نعيد فحص الصلاحية عند الحفظ، حتى لو فُتحت التفاصيل سابقًا.
            if (task == null ||
                task.CompanyId != CurrentSupervisor.CompanyId ||
                task.StudentId != submission.StudentId ||
                task.PlacementId != submission.PlacementId)
            {
                return;
            }

            pnlSubmissionDetails.Visible = true;
            lblReviewMessage.CssClass = "text-danger d-block mt-3";
            lblReviewMessage.Text = "";
            if (!IsReviewableSubmission(
                    submission,
                    task,
                    submissionRepository.GetByTask(task.Id),
                    new TaskEvaluationRepository().GetByTask(task.Id)))
            {
                lblReviewMessage.Text = L.T("Company.TaskReview.ThisSubmissionIsAlreadyReviewedOr");
                return;
            }

            if (task.MaxScore <= 0)
            {
                lblReviewMessage.Text =
                    L.T("Company.TaskReview.ThisTaskHasNoValidGrading");
                return;
            }

            string feedback = txtFeedback.Text.Trim();

            if (feedback == "")
            {
                lblReviewMessage.Text =
                    L.T("Company.TaskReview.PleaseEnterFeedbackForTheStudent");
                return;
            }

            try
            {
                // نقيّم أحدث محاولة فقط.
                foreach (Submission attempt in
                    submissionRepository.GetByTask(task.Id))
                {
                    if (attempt.StudentId == submission.StudentId &&
                        attempt.PlacementId == submission.PlacementId &&
                        attempt.AttemptNumber >
                            submission.AttemptNumber)
                    {
                        lblReviewMessage.Text =
                            L.T("Company.TaskReview.ANewerSubmissionAttemptExistsReview");
                        return;
                    }
                }

                TaskEvaluationRepository evaluationRepository =
                    new TaskEvaluationRepository();

                TaskEvaluation evaluation = FindEvaluationForSubmission(
                    evaluationRepository.GetByTask(task.Id), submission.Id);
                bool isUpdatingEvaluation = evaluation != null;
                if (evaluation == null)
                {
                    evaluation = new TaskEvaluation();
                }

                // Use the task's saved rubric and update an existing review in place.
                evaluation.TaskId = task.Id;
                evaluation.SubmissionId = submission.Id;
                evaluation.PlacementId = submission.PlacementId;
                evaluation.StudentId = submission.StudentId;
                evaluation.EvaluatedBySupervisorId = CurrentSupervisor.Id;
                evaluation.Feedback = feedback;
                evaluation.MaxScore = task.MaxScore;
                evaluation.Components = new List<GradeComponent>();
                evaluation.RevisionRequested = false;
                evaluation.RevisionInstructions = "";

                List<GradeComponent> rubric = CreateUniversityRubric();
                TextBox[] scoreInputs =
                {
                    txtCodeQuality,
                    txtFunctionality,
                    txtDesignUsability,
                    txtDocumentation
                };

                for (int i = 0; i < rubric.Count; i++)
                {
                    GradeComponent criterion = rubric[i];
                    string enteredScore = scoreInputs[i].Text.Trim();

                    double score;
                    bool validScore = double.TryParse(
                        enteredScore,
                        System.Globalization.NumberStyles.Float,
                        System.Globalization.CultureInfo
                            .InvariantCulture,
                        out score);

                    if (!validScore ||
                        double.IsNaN(score) ||
                        double.IsInfinity(score) ||
                        score < 0 ||
                        score > criterion.MaxScore)
                    {
                        lblReviewMessage.Text = L.T("Company.I18n.Enteravalidscorefor") +
                            Server.HtmlEncode(criterion.Name) + " (0 to " +
                            criterion.MaxScore.ToString(
                                "0.##", System.Globalization.CultureInfo.InvariantCulture) + ").";
                        return;
                    }

                    evaluation.Components.Add(
                        new GradeComponent
                        {
                            Name = criterion.Name,
                            Description =
                                criterion.Description,
                            MaxScore = criterion.MaxScore,
                            Weight = criterion.Weight,
                            Score = score
                        });
                }

                // PercentOf يرجع نسبة؛ نحولها لعلامة من MaxScore
                // الخاص بهذه المهمة، وليس دائمًا من 100.
                evaluation.TotalScore =
                    GradingService.PercentOf(
                        evaluation.Components)
                    * task.MaxScore / 100.0;

                bool evaluationSaved;
                if (isUpdatingEvaluation)
                {
                    evaluation.EvaluatedAt = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
                    evaluationRepository.Update(
                        evaluation.Id,
                        new Dictionary<string, object>
                        {
                            { "TaskId", evaluation.TaskId },
                            { "SubmissionId", evaluation.SubmissionId },
                            { "PlacementId", evaluation.PlacementId },
                            { "StudentId", evaluation.StudentId },
                            { "EvaluatedBySupervisorId", evaluation.EvaluatedBySupervisorId },
                            { "Components", evaluation.Components },
                            { "TotalScore", evaluation.TotalScore },
                            { "MaxScore", evaluation.MaxScore },
                            { "Feedback", evaluation.Feedback },
                            { "RevisionRequested", false },
                            { "RevisionInstructions", "" },
                            { "EvaluatedAt", evaluation.EvaluatedAt }
                        });
                    evaluationSaved = true;
                }
                else
                {
                    evaluationSaved = !string.IsNullOrEmpty(
                        evaluationRepository.Insert(evaluation));
                }

                if (!evaluationSaved)
                {
                    lblReviewMessage.Text =
                        L.T("Company.TaskReview.TheGradeCouldNotBeSaved");
                    return;
                }

                try
                {
                    taskRepository.Update(
                        task.Id,
                        new Dictionary<string, object>
                        {
                            {
                                "Status",
                                InternshipTaskStatus.Graded
                            }
                        });
                }
                catch (FirebaseException)
                {
                    lblReviewMessage.Text =
                        L.T("Company.TaskReview.TheGradeWasSavedButThe");
                    return;
                }

                lblReviewMessage.CssClass =
                    "text-success d-block mt-3";
                lblReviewMessage.Text =
                    L.T("Company.TaskReview.GradeSavedSuccessfully");
            }
            catch (FirebaseException)
            {
                lblReviewMessage.Text =
                    L.T("Company.TaskReview.CouldNotLoadOrSaveThe");
            }
        }
        private static List<GradeComponent> CreateUniversityRubric()
        {
            return new List<GradeComponent>
            {
                new GradeComponent { Name = "Code quality", MaxScore = 25, Weight = 25 },
                new GradeComponent { Name = "Functionality", MaxScore = 35, Weight = 35 },
                new GradeComponent { Name = "Design & usability", MaxScore = 25, Weight = 25 },
                new GradeComponent { Name = "Documentation", MaxScore = 15, Weight = 15 }
            };
        }

        protected void btnRequestRevision_Click(object sender, EventArgs e)
        {
            lblReviewMessage.CssClass = "text-danger d-block mt-3";
            pnlSubmissionDetails.Visible = true;

            string submissionId = ViewState["SelectedSubmissionId"] as string;
            if (string.IsNullOrEmpty(submissionId))
            {
                lblReviewMessage.Text = L.T("Company.TaskReview.OpenASubmissionFirst");
                return;
            }

            Submission submission =
                new SubmissionRepository().GetById(submissionId);

            if (submission == null)
            {
                lblReviewMessage.Text = L.T("Company.TaskReview.SubmissionWasNotFound");
                return;
            }

            InternshipTask task =
                new TaskRepository().GetById(submission.TaskId);

            // نتأكد على السيرفر أن هذا التسليم تابع لشركة المشرف.
            if (task == null ||
                task.CompanyId != CurrentSupervisor.CompanyId ||
                task.StudentId != submission.StudentId ||
                task.PlacementId != submission.PlacementId)
            {
                lblReviewMessage.Text = L.T("Company.TaskReview.YouCannotReviewThisSubmission");
                return;
            }

            if (!IsReviewableSubmission(
                    submission,
                    task,
                    new SubmissionRepository().GetByTask(task.Id),
                    new TaskEvaluationRepository().GetByTask(task.Id)))
            {
                lblReviewMessage.Text = L.T("Company.TaskReview.ThisSubmissionIsAlreadyReviewedOr");
                return;
            }

            string instructions = txtFeedback.Text.Trim();

            if (instructions == "")
            {
                lblReviewMessage.Text = L.T("Company.TaskReview.TellTheStudentWhatNeedsTo");
                return;
            }

            TaskEvaluationRepository evaluationRepository =
                new TaskEvaluationRepository();
            TaskEvaluation revision = FindEvaluationForSubmission(
                evaluationRepository.GetByTask(task.Id), submission.Id);
            bool isUpdatingEvaluation = revision != null;
            if (revision == null)
            {
                revision = new TaskEvaluation();
            }

            revision.TaskId = task.Id;
            revision.SubmissionId = submission.Id;
            revision.PlacementId = submission.PlacementId;
            revision.StudentId = submission.StudentId;
            revision.EvaluatedBySupervisorId = CurrentSupervisor.Id;
            revision.RevisionRequested = true;
            revision.RevisionInstructions = instructions;
            revision.Feedback = "";
            revision.Components = new List<GradeComponent>();
            revision.TotalScore = 0;
            revision.MaxScore = task.MaxScore;

            try
            {
                bool revisionSaved;
                if (isUpdatingEvaluation)
                {
                    revision.EvaluatedAt = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
                    evaluationRepository.Update(
                        revision.Id,
                        new Dictionary<string, object>
                        {
                            { "TaskId", revision.TaskId },
                            { "SubmissionId", revision.SubmissionId },
                            { "PlacementId", revision.PlacementId },
                            { "StudentId", revision.StudentId },
                            { "EvaluatedBySupervisorId", revision.EvaluatedBySupervisorId },
                            { "Components", revision.Components },
                            { "TotalScore", 0 },
                            { "MaxScore", revision.MaxScore },
                            { "Feedback", "" },
                            { "RevisionRequested", true },
                            { "RevisionInstructions", revision.RevisionInstructions },
                            { "EvaluatedAt", revision.EvaluatedAt }
                        });
                    revisionSaved = true;
                }
                else
                {
                    revisionSaved = !string.IsNullOrEmpty(
                        evaluationRepository.Insert(revision));
                }

                if (!revisionSaved)
                {
                    lblReviewMessage.Text = L.T("Company.TaskReview.TheRevisionRequestCouldNotBe");
                    return;
                }

                new TaskRepository().Update(
                    task.Id,
                    new Dictionary<string, object>
                    {
                { "Status", InternshipTaskStatus.RevisionRequested }
                    });

                lblReviewMessage.CssClass = "text-success d-block mt-3";
                lblReviewMessage.Text = L.T("Company.TaskReview.RevisionRequestedSuccessfully");
                txtFeedback.Text = "";
                LoadCompanySubmissions();
            }
            catch (FirebaseException)
            {
                lblReviewMessage.Text =
                    L.T("Company.TaskReview.CouldNotCompleteTheRevisionRequest");
            }
        }
    }
}








