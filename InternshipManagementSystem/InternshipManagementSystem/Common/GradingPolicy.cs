using System.Collections.Generic;
using InternshipManagementSystem.Models;

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

        /// <summary>Each company criterion is rated on this 1-5 scale.</summary>
        public const double CompanyCriterionMaxRating = 5;

        public static bool WeightsAreValid()
        {
            double total = TaskComponentWeight + CompanyFinalWeight + AcademicFinalWeight;
            return System.Math.Abs(total - 100.0) < 0.001;
        }

        /// <summary>
        /// The criteria of the company's final evaluation (cards N08, N09).
        /// HYPOTHETICAL weights based on common university co-op forms
        /// (Waterloo, Laurier, NACE competencies); awaiting card X01.
        /// The weights must add up to 100. Score holds the 1-5 rating.
        /// </summary>
        public static List<GradeComponent> CompanyFinalCriteria()
        {
            List<GradeComponent> criteria = new List<GradeComponent>();
            criteria.Add(Criterion("Task Performance", 25,
                "Completes assigned tasks, meets deadlines and acceptance criteria, reliable."));
            criteria.Add(Criterion("Quality of Work", 20,
                "Accurate, complete and maintainable work with few errors."));
            criteria.Add(Criterion("Technical Competency", 20,
                "Technical knowledge, implementation, debugging and problem-solving."));
            criteria.Add(Criterion("Collaboration & Communication", 15,
                "Teamwork, clear communication, knowledge sharing and responsiveness."));
            criteria.Add(Criterion("Professionalism", 10,
                "Accountability, punctuality, initiative and professional conduct."));
            criteria.Add(Criterion("Learning & Improvement", 10,
                "Skill development, adaptability and response to feedback."));
            return criteria;
        }

        /// <summary>Text for each point of the 1-5 rating scale.</summary>
        public static string RatingLabel(int rating)
        {
            switch (rating)
            {
                case 1: return "Unsatisfactory";
                case 2: return "Needs Improvement";
                case 3: return "Meets Expectations";
                case 4: return "Exceeds Expectations";
                case 5: return "Outstanding";
                default: return "Not rated";
            }
        }

        private static GradeComponent Criterion(string name, double weight, string description)
        {
            GradeComponent component = new GradeComponent();
            component.Name = name;
            component.Description = description;
            component.Weight = weight;
            component.MaxScore = CompanyCriterionMaxRating;
            component.Score = 0;
            return component;
        }
    }
}
