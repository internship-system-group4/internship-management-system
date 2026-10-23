using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Services;

namespace InternshipManagementSystem.Pages.CoordinatorArea
{
    public partial class Dashboard : InternshipManagementSystem.Security.CoordinatorPage
    {
        protected bool HasData { get; private set; }
        protected string LoadError { get; private set; }
        protected string StudentCount { get; private set; } = "—";
        protected string CompanyCount { get; private set; } = "—";
        protected string ActivePlacementCount { get; private set; } = "—";
        protected string OpportunityCount { get; private set; } = "—";
        protected string ReviewHeading { get; private set; } = "Completion reviews";
        protected string ReviewDescription { get; private set; } = "Open the review workspace to check final evaluations and internship completion.";
        protected List<Placement> RecentPlacements { get; private set; } = new List<Placement>();

        protected string FirstName
        {
            get
            {
                string name = CurrentUser == null ? null : CurrentUser.FullName;
                return string.IsNullOrWhiteSpace(name) ? "Coordinator" : name.Trim().Split(' ')[0];
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // No dashboard postback actions; sign-out remains in the master.
            if (IsPostBack) return;
            if (!FirebaseContext.IsConfigured)
            {
                LoadError = "The program overview is unavailable until the database is configured.";
                return;
            }

            try
            {
                // Read each collection once. Publish the overview only after all reads
                // succeed, so a failed read cannot masquerade as a zero count.
                var students = new UserRepository().GetByRole(UserRole.Student);
                var companies = new CompanyRepository().GetAll();
                var opportunities = new OpportunityRepository().GetAll();
                var placements = new PlacementRepository().GetAll();
                var completions = new CompletionRepository().GetAll();
                var hours = new HoursRepository().GetAll();
                foreach (var placement in placements)
                {
                    var student = students.OfType<Student>().FirstOrDefault(s => s.Id == placement.StudentId);
                    var completion = completions.FirstOrDefault(c => c.PlacementId == placement.Id && c.StudentId == placement.StudentId);
                    placement.ApprovedHours = (int)Math.Min(int.MaxValue, CompletionReviewService.ApprovedHours(hours, placement, Time.NowMs()));
                    placement.RequiredHours = CompletionReviewService.RequiredHours(placement, student, completion == null ? null : completion.EvaluationRuleSnapshot);
                }

                StudentCount = Count(students.Count);
                CompanyCount = Count(companies.Count);
                OpportunityCount = Count(opportunities.Count(o => o.Status == OpportunityStatus.Open));
                ActivePlacementCount = Count(placements.Count(p =>
                    p.Status == PlacementStatus.Confirmed || p.Status == PlacementStatus.Active));
                RecentPlacements = placements.OrderByDescending(p => p.ConfirmedAt)
                    .ThenBy(p => p.Id, StringComparer.Ordinal).Take(5).ToList();

                int pending = completions.Count(c => c.Status == CompletionStatus.UnderCoordinatorReview);
                ReviewHeading = pending == 0 ? "Room for the next milestone" :
                    Count(pending) + (pending == 1 ? " review awaits you" : " reviews await you");
                ReviewDescription = pending == 0
                    ? "No completion records are currently awaiting coordinator review."
                    : "Help students take the final step. Check their evaluations and completion requirements.";
                HasData = true;
            }
            catch (FirebaseException)
            {
                LoadError = "We couldn't load your program overview. Please try again.";
            }
            // FirebaseAuthExpiredException intentionally reaches SecurePage's login redirect.
        }

        private static string Count(int value)
        {
            return value.ToString("N0", CultureInfo.InvariantCulture);
        }

        protected static int Progress(Placement placement)
        {
            return placement.RequiredHours <= 0 ? 0 :
                (int)Math.Max(0L, Math.Min(100L, placement.ApprovedHours * 100L / placement.RequiredHours));
        }

        protected static string Initials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "?";
            string[] parts = name.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            return (parts[0].Substring(0, 1) +
                (parts.Length > 1 ? parts[parts.Length - 1].Substring(0, 1) : "")).ToUpperInvariant();
        }

        protected static string StatusLabel(PlacementStatus status)
        {
            switch (status)
            {
                case PlacementStatus.Confirmed: return "Confirmed";
                case PlacementStatus.Active: return "Active";
                case PlacementStatus.AwaitingCompletion: return "In review";
                case PlacementStatus.Completed: return "Completed";
                case PlacementStatus.Cancelled: return "Cancelled";
                default: return "Offered";
            }
        }

        protected static string StatusClass(PlacementStatus status)
        {
            switch (status)
            {
                case PlacementStatus.Active:
                case PlacementStatus.Completed: return "is-success";
                case PlacementStatus.AwaitingCompletion: return "is-warning";
                case PlacementStatus.Cancelled: return "is-danger";
                default: return "is-info";
            }
        }
    }
}
