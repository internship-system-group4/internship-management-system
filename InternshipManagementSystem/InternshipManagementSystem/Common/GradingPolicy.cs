namespace InternshipManagementSystem.Common
{
    public static class GradingPolicy
    {
        // HYPOTHETICAL weights, scales and pass threshold; awaiting card X01.
        public const double TaskComponentWeight = 30;
        public const double CompanyFinalWeight = 45;
        public const double AcademicFinalWeight = 25;
        public const double CompanyEvaluationMaxScore = 100;
        public const double AcademicEvaluationMaxScore = 50;
        public const double PassMarkPercent = 60;

        public static bool WeightsAreValid()
        {
            double total = TaskComponentWeight + CompanyFinalWeight + AcademicFinalWeight;
            return System.Math.Abs(total - 100.0) < 0.001;
        }
    }
}
