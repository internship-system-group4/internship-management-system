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
            }
        }

        private void LoadCompanySubmissions()
        {
            string selectedTaskId = Request.QueryString["taskId"];

            List<object> companySubmissions = new List<object>();

            List<InternshipTask> tasks =
                new TaskRepository().GetAll();

            List<Submission> submissions =
                new SubmissionRepository().GetAll();
            PlacementRepository placementRepository =
    new PlacementRepository();
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
                        : "Name unavailable";

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
                            Status = submission.Status,
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

            string submissionId = Convert.ToString(e.CommandArgument);

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

            rptReviewCriteria.DataSource =
                task.Criteria ?? new List<GradeComponent>();
            rptReviewCriteria.DataBind();

            pnlSubmissionDetails.Visible = true;
            lblReviewMessage.Text = "";

            lblDetailTask.Text = Server.HtmlEncode(task.Title ?? "");
            lblDetailAttempt.Text =
                submission.AttemptNumber.ToString();

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
            }
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

            if (task.Status != InternshipTaskStatus.Submitted &&
                task.Status != InternshipTaskStatus.Resubmitted)
            {
                lblReviewMessage.Text =
                    L.T("Company.TaskReview.ThisTaskIsNotWaitingFor");
                return;
            }

            if (task.Criteria == null ||
                task.Criteria.Count == 0 ||
                task.MaxScore <= 0)
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

                // لا ننشئ تقييمًا ثانيًا لنفس محاولة التسليم.
                foreach (TaskEvaluation previous in
                    evaluationRepository.GetAll())
                {
                    if (previous.SubmissionId == submission.Id)
                    {
                        lblReviewMessage.Text =
                            L.T("Company.TaskReview.ThisSubmissionHasAlreadyBeenReviewed");
                        return;
                    }
                }

                // نستخدم معايير المهمة المحفوظة، لا أرقامًا من المتصفح.
                rptReviewCriteria.DataSource = task.Criteria;
                rptReviewCriteria.DataBind();

                TaskEvaluation evaluation = new TaskEvaluation
                {
                    TaskId = task.Id,
                    SubmissionId = submission.Id,
                    PlacementId = submission.PlacementId,
                    StudentId = submission.StudentId,
                    EvaluatedBySupervisorId =
                        CurrentSupervisor.Id,
                    Feedback = feedback,
                    MaxScore = task.MaxScore
                };

                for (int i = 0; i < task.Criteria.Count; i++)
                {
                    GradeComponent criterion =
                        task.Criteria[i];

                    TextBox scoreBox =
                        (TextBox)rptReviewCriteria.Items[i]
                            .FindControl("txtScore");

                    string enteredScore =
                        Request.Form[scoreBox.UniqueID];

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
                        lblReviewMessage.Text =
                            L.F("Company.TaskReview.EnterAValidScoreFor", Server.HtmlEncode(criterion.Name));
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

                string evaluationId =
                    evaluationRepository.Insert(evaluation);

                if (string.IsNullOrEmpty(evaluationId))
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
        protected void btnRequestRevision_Click(object sender, EventArgs e)
        {
            lblReviewMessage.CssClass = "text-danger d-block mt-3";
            pnlSubmissionDetails.Visible = true;

            string submissionId = ViewState["SelectedSubmissionId"] as string;
            if (string.IsNullOrEmpty(submissionId))
            {
                lblReviewMessage.Text = "Open a submission first.";
                return;
            }

            Submission submission =
                new SubmissionRepository().GetById(submissionId);

            if (submission == null)
            {
                lblReviewMessage.Text = "Submission was not found.";
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
                lblReviewMessage.Text = "You cannot review this submission.";
                return;
            }

            if (task.Status != InternshipTaskStatus.Submitted &&
                task.Status != InternshipTaskStatus.Resubmitted)
            {
                lblReviewMessage.Text = "This task is not waiting for review.";
                return;
            }

            string instructions = txtRevisionInstructions.Text.Trim();

            if (instructions == "")
            {
                lblReviewMessage.Text = "Tell the student what needs to be changed.";
                return;
            }

            TaskEvaluation revision = new TaskEvaluation();
            revision.TaskId = task.Id;
            revision.SubmissionId = submission.Id;
            revision.PlacementId = submission.PlacementId;
            revision.StudentId = submission.StudentId;
            revision.EvaluatedBySupervisorId = CurrentSupervisor.Id;
            revision.RevisionRequested = true;
            revision.RevisionInstructions = instructions;
            revision.MaxScore = task.MaxScore;

            try
            {
                new TaskEvaluationRepository().Insert(revision);

                new TaskRepository().Update(
                    task.Id,
                    new Dictionary<string, object>
                    {
                { "Status", InternshipTaskStatus.RevisionRequested }
                    });

                lblReviewMessage.CssClass = "text-success d-block mt-3";
                lblReviewMessage.Text = "Revision requested successfully.";
                txtRevisionInstructions.Text = "";
                LoadCompanySubmissions();
            }
            catch (FirebaseException)
            {
                lblReviewMessage.Text =
                    "Could not complete the revision request. Check Firebase before trying again.";
            }
        }
    }
}