// =============================================================================
//  UIMS - Group 4   |   Owner: Suja / Ahmad  (Trello card X01 + A11)
//  The university's grade weights. Single source of truth for card A11.
// =============================================================================

namespace InternshipManagementSystem.Common
{
    /// <summary>
    /// Every weight and scale the final result depends on, in one place.
    ///
    /// TODO(Suja, card X01): replace these with the real figures for the
    /// university assigned to Group 4, and write the source in
    /// docs/01-university-rules.md. If the university does not publish them,
    /// the document must say in so many words that the method is hypothetical -
    /// the requirements document demands that disclosure.
    ///
    /// The requirements also forbid assuming every activity is out of 100, so
    /// each scale below is a separate value rather than a shared constant.
    /// </summary>
    public static class GradingPolicy
    {
        // --- weights of the three components of the final result (sum = 100)
        public const double TaskComponentWeight = 30;      // graded tasks
        public const double CompanyFinalWeight = 45;       // company's final evaluation
        public const double AcademicFinalWeight = 25;      // academic final evaluation

        // --- scales
        public const double CompanyEvaluationMaxScore = 100;
        public const double AcademicEvaluationMaxScore = 50;

        /// <summary>Minimum final percentage the university requires to pass.</summary>
        public const double PassMarkPercent = 60;

        /// <summary>Called by GradingService so a wrong edit above fails loudly
        /// instead of silently producing wrong grades.</summary>
        public static bool WeightsAreValid()
        {
            double total = TaskComponentWeight + CompanyFinalWeight + AcademicFinalWeight;
            return System.Math.Abs(total - 100.0) < 0.001;
        }

        /// <summary>TODO(Suja): replace with the university's own letter bands.</summary>
        public static string ToLetter(double percent)
        {
            if (percent >= 90) return "A";
            if (percent >= 85) return "B+";
            if (percent >= 80) return "B";
            if (percent >= 75) return "C+";
            if (percent >= 70) return "C";
            if (percent >= 65) return "D+";
            if (percent >= PassMarkPercent) return "D";
            return "F";
        }
    }
}
