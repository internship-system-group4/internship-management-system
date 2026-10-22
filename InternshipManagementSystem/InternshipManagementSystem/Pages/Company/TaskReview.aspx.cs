using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;
using InternshipManagementSystem.Services;
using System;
using System.Collections.Generic;
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
            List<Submission> companySubmissions = new List<Submission>();

            TaskRepository taskRepository = new TaskRepository();
            SubmissionRepository submissionRepository =
                new SubmissionRepository();

            List<InternshipTask> tasks =
                taskRepository.GetByCompany(CurrentSupervisor.CompanyId);

            foreach (InternshipTask task in tasks)
            {
                List<Submission> submissions =
                    submissionRepository.GetByTask(task.Id);

                foreach (Submission submission in submissions)
                {
                    if (submission.TaskId == task.Id &&
                        submission.StudentId == task.StudentId &&
                        submission.PlacementId == task.PlacementId)
                    {
                        companySubmissions.Add(submission);
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
                    ? "No text submitted."
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
                    "This task is not waiting for grading.";
                return;
            }

            if (task.Criteria == null ||
                task.Criteria.Count == 0 ||
                task.MaxScore <= 0)
            {
                lblReviewMessage.Text =
                    "This task has no valid grading criteria.";
                return;
            }

            string feedback = txtFeedback.Text.Trim();

            if (feedback == "")
            {
                lblReviewMessage.Text =
                    "Please enter feedback for the student.";
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
                            "A newer submission attempt exists. " +
                            "Review that one instead.";
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
                            "This submission has already been reviewed.";
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
                            "Enter a valid score for: " +
                            Server.HtmlEncode(criterion.Name);
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
                        "The grade could not be saved.";
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
                        "The grade was saved, but the task status " +
                        "was not updated. Check Firebase before " +
                        "trying again.";
                    return;
                }

                lblReviewMessage.CssClass =
                    "text-success d-block mt-3";
                lblReviewMessage.Text =
                    "Grade saved successfully.";
            }
            catch (FirebaseException)
            {
                lblReviewMessage.Text =
                    "Could not load or save the evaluation. " +
                    "Please try again.";
            }
        }
    }
}