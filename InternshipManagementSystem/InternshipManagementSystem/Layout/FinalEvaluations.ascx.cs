using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web.UI;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Layout
{
    /// <summary>Shows the company and academic final evaluations as two cards
    /// (score, submitted date, criteria and comments). Used by the coordinator's
    /// Completion Review and Placement Progress pages.</summary>
    public partial class FinalEvaluations : UserControl
    {
        public FinalCompanyEvaluation Company { get; set; }
        public FinalAcademicEvaluation Academic { get; set; }
        public string CompanySupervisorName { get; set; }
        public string AcademicSupervisorName { get; set; }

        /// <summary>When true, each card says how much it counts in the final result.</summary>
        public bool ShowWeights { get; set; }

        protected List<Card> Cards
        {
            get
            {
                List<Card> cards = new List<Card>();

                Card company = new Card
                {
                    Kicker = L.T("Coordinator.Final.CompanyKicker"),
                    Icon = "building",
                    Evaluator = Name(CompanySupervisorName),
                    WeightPercent = ShowWeights ? GradingPolicy.CompanyFinalWeight : 0
                };
                if (Company != null)
                {
                    company.HasDraft = !Company.IsSubmitted;
                    company.Submitted = Company.IsSubmitted;
                    company.Total = Company.TotalScore;
                    company.Max = Company.MaxScore;
                    company.SubmittedAt = Company.SubmittedAt;
                    company.Components = Company.Components ?? new List<GradeComponent>();
                    AddNote(company, L.T("Coordinator.Final.Strengths"), Company.Strengths, "is-good");
                    AddNote(company, L.T("Coordinator.Final.Improve"), Company.AreasForImprovement, "is-improve");
                    AddNote(company, L.T("Coordinator.Final.Overall"), Company.OverallComment, "");
                }
                cards.Add(Finish(company));

                Card academic = new Card
                {
                    Kicker = L.T("Coordinator.Final.AcademicKicker"),
                    Icon = "study",
                    Evaluator = Name(AcademicSupervisorName),
                    WeightPercent = ShowWeights ? GradingPolicy.AcademicFinalWeight : 0
                };
                if (Academic != null)
                {
                    academic.HasDraft = !Academic.IsSubmitted;
                    academic.Submitted = Academic.IsSubmitted;
                    academic.Total = Academic.TotalScore;
                    academic.Max = Academic.MaxScore;
                    academic.SubmittedAt = Academic.SubmittedAt;
                    academic.Components = Academic.Components ?? new List<GradeComponent>();
                    AddNote(academic, L.T("Coordinator.Final.AcademicComments"), Academic.AcademicComments, "");
                    AddNote(academic, L.T("Coordinator.Final.CompanyRemarks"), Academic.CompanyEvaluationRemarks, "");
                }
                cards.Add(Finish(academic));
                return cards;
            }
        }

        private static Card Finish(Card card)
        {
            card.Percent = card.Max > 0 ? card.Total * 100 / card.Max : 0;
            card.Components = card.Components.Where(c => c != null).ToList();
            if (card.Submitted)
            {
                card.StatusText = L.T("Coordinator.Review.Submitted");
                card.StatusCss = "dir-status is-active";
                card.CssState = "is-submitted";
            }
            else if (card.HasDraft)
            {
                card.StatusText = L.T("Coordinator.Review.Draft");
                card.StatusCss = "dir-status is-warning";
                card.CssState = "is-draft";
            }
            else
            {
                card.StatusText = L.T("Coordinator.Review.NotStarted");
                card.StatusCss = "dir-status is-neutral";
                card.CssState = "is-missing";
            }
            return card;
        }

        private static void AddNote(Card card, string label, string text, string css)
        {
            if (!string.IsNullOrWhiteSpace(text)) card.Notes.Add(new Note { Label = label, Text = text.Trim(), Css = css });
        }

        private static string Name(string value)
        {
            return string.IsNullOrWhiteSpace(value) ? L.T("Coordinator.Final.NotAssigned") : value;
        }

        protected static string Number(double value)
        {
            return value.ToString("0.##", CultureInfo.InvariantCulture);
        }

        /// <summary>Width of a bar, 0 to 100, as plain text for CSS.</summary>
        protected static string Bar(double percent)
        {
            if (percent < 0) percent = 0;
            if (percent > 100) percent = 100;
            return percent.ToString("0.#", CultureInfo.InvariantCulture);
        }

        protected class Card
        {
            public string Kicker, Icon, Evaluator, StatusText, StatusCss, CssState;
            public bool Submitted, HasDraft;
            public double Total, Max, Percent, WeightPercent;
            public long SubmittedAt;
            public List<GradeComponent> Components = new List<GradeComponent>();
            public List<Note> Notes = new List<Note>();
        }

        protected class Note
        {
            public string Label, Text, Css;
        }
    }
}
