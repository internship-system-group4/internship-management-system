using System;
using System.Globalization;
using System.Linq;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Pages.CoordinatorArea
{
    public partial class PlacementDetails : Security.CoordinatorPage
    {
        protected PlacementProgressData Progress;
        protected string LoadError;

        protected void Page_Load(object sender, EventArgs e)
        {
            string id = Request.QueryString["id"] ?? Request.QueryString["studentId"];
            if (!ApplicationRepository.IsValidKey(id)) { LoadError = L.T("Coordinator.PlacementDetails.ChooseAStudentFromPlacementsProgress"); return; }
            try
            {
                Progress = new CoordinatorMonitoringRepository().LoadDetails(id);
                if (Progress == null) { Response.StatusCode = 404; Response.TrySkipIisCustomErrors = true; LoadError = L.T("Coordinator.PlacementDetails.ThisConfirmedPlacementCouldNotBe"); }
            }
            catch (FirebaseException) { LoadError = L.T("Coordinator.PlacementDetails.WeCouldNotLoadInternshipProgress"); }
            catch (InvalidOperationException) { LoadError = L.T("Coordinator.PlacementDetails.FirebaseIsNotConfiguredContactThe"); }

            if (Progress != null)
            {
                // The same two evaluation cards as the Completion Review.
                ucFinal.Company = Progress.CompanyFinal;
                ucFinal.Academic = Progress.AcademicFinal;
                ucFinal.CompanySupervisorName = Progress.CompanySupervisorName;
                ucFinal.AcademicSupervisorName = Progress.AcademicSupervisorName;
            }
        }

        protected int GradedCount
        {
            get { return Progress.Tasks.Count(t => t.Status == InternshipTaskStatus.Graded); }
        }

        /// <summary>How many of the two final evaluations are submitted (0, 1 or 2).</summary>
        protected int FinalsSubmitted
        {
            get
            {
                return (Progress.CompanyFinal != null && Progress.CompanyFinal.IsSubmitted ? 1 : 0)
                     + (Progress.AcademicFinal != null && Progress.AcademicFinal.IsSubmitted ? 1 : 0);
            }
        }

        protected string Score(double value, double maximum)
        {
            return maximum > 0 ? value.ToString("0.##", CultureInfo.InvariantCulture) + " / " + maximum.ToString("0.##", CultureInfo.InvariantCulture) : L.T("Coordinator.PlacementDetails.NotScored");
        }

        protected static string Show(string value)
        {
            return string.IsNullOrWhiteSpace(value) ? "—" : value;
        }

        protected bool SafeLink(string value) { return ApplicationRepository.IsSafeDocumentUrl(value) || InternshipManagementSystem.Services.TaskSubmissionStorage.IsSafeUrl(value); }

        protected string TaskTitle(string taskId)
        {
            InternshipTask task = Progress.Tasks.FirstOrDefault(t => t.Id == taskId);
            return task == null ? "—" : task.Title;
        }

        /// <summary>The supervisor's review of one attempt (grade or change request), if any.</summary>
        protected TaskEvaluation FeedbackFor(string submissionId)
        {
            return Progress.Evaluations.FirstOrDefault(ev => ev.SubmissionId == submissionId);
        }

        /// <summary>Newest real grade of a task as "8 / 10", or a dash.</summary>
        protected string TaskGrade(InternshipTask task)
        {
            TaskEvaluation grade = Progress.Evaluations.FirstOrDefault(ev => ev.TaskId == task.Id && !ev.RevisionRequested);
            if (grade == null) return "—";
            return Score(grade.TotalScore, grade.MaxScore > 0 ? grade.MaxScore : task.MaxScore);
        }

        protected static string TaskCss(InternshipTaskStatus status)
        {
            switch (status)
            {
                case InternshipTaskStatus.Graded: return "dir-status is-active";
                case InternshipTaskStatus.RevisionRequested: return "dir-status is-warning";
                case InternshipTaskStatus.Assigned: return "dir-status is-neutral";
                default: return "dir-status is-info";
            }
        }

        protected static string HoursCss(HoursStatus status)
        {
            switch (status)
            {
                case HoursStatus.Approved: return "dir-status is-active";
                case HoursStatus.Rejected: return "dir-status is-inactive";
                default: return "dir-status is-warning";
            }
        }
    }
}
