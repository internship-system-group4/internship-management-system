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

            List<InternshipTask> tasks =
                new TaskRepository().GetAll();

            List<Submission> submissions =
                new SubmissionRepository().GetAll();

            foreach (InternshipTask task in tasks)
            {
                if (task.CompanyId != CurrentSupervisor.CompanyId)
                    continue;

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

        protected void btnSaveGrade_Click(object sender, EventArgs e) { SaveReview(false); }
        protected void btnRequestRevision_Click(object sender, EventArgs e) { SaveReview(true); }
        private void SaveReview(bool revision)
        {
            pnlSubmissionDetails.Visible = true;
            lblReviewMessage.CssClass = "text-danger d-block mt-3";
            try {
                string id = ViewState["SelectedSubmissionId"] as string;
                var submission = new SubmissionRepository().GetById(id);
                var task = submission == null ? null : new TaskRepository().GetById(submission.TaskId);
                if (task == null) throw new InvalidOperationException("Select a submission first.");
                var scores = new List<double>();
                if (!revision) {
                    rptReviewCriteria.DataSource = task.Criteria; rptReviewCriteria.DataBind();
                    foreach (RepeaterItem item in rptReviewCriteria.Items) {
                        var box = (TextBox)item.FindControl("txtScore"); double score;
                        if (!double.TryParse(Request.Form[box.UniqueID], System.Globalization.NumberStyles.Float, System.Globalization.CultureInfo.InvariantCulture, out score))
                            throw new InvalidOperationException("Enter a numeric mark for each criterion.");
                        scores.Add(score);
                    }
                }
                TaskWorkflowService.Review(id, revision, scores, revision ? txtRevisionInstructions.Text.Trim() : txtFeedback.Text.Trim());
                lblReviewMessage.CssClass = "text-success d-block mt-3";
                lblReviewMessage.Text = revision ? "Revision requested successfully." : L.T("Company.TaskReview.GradeSavedSuccessfully");
                txtRevisionInstructions.Text = txtFeedback.Text = "";
                LoadCompanySubmissions();
            } catch (Exception ex) {
                EmailNotificationService.LogFailure(ex);
                lblReviewMessage.Text = Server.HtmlEncode(ex is InvalidOperationException || ex is UnauthorizedAccessException ? ex.Message : "Could not save this review. Please try again.");
            }
        }
    }
}
